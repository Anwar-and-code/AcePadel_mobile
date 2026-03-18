import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const FIREBASE_SERVICE_ACCOUNT = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");

interface NotificationRequest {
  type: "reservation_confirmed" | "reservation_reminder" | "event_published" | "custom";
  title: string;
  body: string;
  data?: Record<string, string>;
  target_type: "single" | "multiple" | "all";
  target_user_ids?: string[];
  sent_by?: string;
}

async function getAccessToken(serviceAccount: { client_email: string; private_key: string; token_uri: string }): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "RS256", typ: "JWT" };
  const payload = {
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: serviceAccount.token_uri,
    iat: now,
    exp: now + 3600,
  };

  const encode = (obj: unknown) => btoa(JSON.stringify(obj)).replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
  const unsignedToken = `${encode(header)}.${encode(payload)}`;

  const pemContents = serviceAccount.private_key
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\n/g, "");
  const binaryDer = Uint8Array.from(atob(pemContents), (c) => c.charCodeAt(0));

  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    binaryDer,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    new TextEncoder().encode(unsignedToken)
  );

  const signedToken = `${unsignedToken}.${btoa(String.fromCharCode(...new Uint8Array(signature))).replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_")}`;

  const tokenRes = await fetch(serviceAccount.token_uri, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${signedToken}`,
  });

  const tokenData = await tokenRes.json();
  if (!tokenData.access_token) {
    throw new Error(`Failed to get access token: ${JSON.stringify(tokenData)}`);
  }
  return tokenData.access_token;
}

async function sendToDevice(
  accessToken: string,
  projectId: string,
  token: string,
  title: string,
  body: string,
  data?: Record<string, string>
): Promise<{ success: boolean; shouldDeactivate: boolean }> {
  const message: Record<string, unknown> = {
    message: {
      token,
      notification: { title, body },
      android: {
        priority: "high",
        notification: { sound: "default", channel_id: "padelhouse_notifications" },
      },
      apns: {
        headers: {
          "apns-push-type": "alert",
          "apns-priority": "10",
        },
        payload: {
          aps: {
            sound: "default",
            badge: 1,
            "mutable-content": 1,
          },
        },
      },
    },
  };

  if (data) {
    (message.message as Record<string, unknown>).data = data;
  }

  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(message),
    }
  );

  if (!res.ok) {
    const errText = await res.text();
    console.error(`FCM send failed for token ${token.substring(0, 20)}...: ${errText}`);
    const shouldDeactivate = errText.includes("UNREGISTERED") || errText.includes("INVALID_ARGUMENT") || errText.includes("NOT_FOUND");
    return { success: false, shouldDeactivate };
  }
  return { success: true, shouldDeactivate: false };
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Authorization, Content-Type, apikey, x-client-info",
      },
    });
  }

  try {
    if (!FIREBASE_SERVICE_ACCOUNT) {
      throw new Error("FIREBASE_SERVICE_ACCOUNT secret is not configured");
    }

    const serviceAccount = JSON.parse(FIREBASE_SERVICE_ACCOUNT);
    const firebaseProjectId = serviceAccount.project_id;

    const body: NotificationRequest = await req.json();
    const { type, title, body: notifBody, data, target_type, target_user_ids, sent_by } = body;

    if (!type || !title || !notifBody || !target_type) {
      return new Response(JSON.stringify({ error: "Missing required fields: type, title, body, target_type" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    let query = supabase.from("fcm_tokens").select("token, user_id").eq("is_active", true);

    if (target_type === "single" && target_user_ids?.length === 1) {
      query = query.eq("user_id", target_user_ids[0]);
    } else if (target_type === "multiple" && target_user_ids?.length) {
      query = query.in("user_id", target_user_ids);
    }

    const { data: tokens, error: tokensError } = await query;
    if (tokensError) throw tokensError;

    if (!tokens || tokens.length === 0) {
      await supabase.from("notification_logs").insert({
        type, title, body: notifBody, data: data || {},
        target_type, target_user_ids: target_user_ids || [],
        total_sent: 0, total_failed: 0, sent_by: sent_by || null,
      });

      return new Response(JSON.stringify({ success: true, sent: 0, failed: 0, message: "No active tokens found" }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const accessToken = await getAccessToken(serviceAccount);

    let sent = 0;
    let failed = 0;
    const invalidTokens: string[] = [];

    for (const { token } of tokens) {
      const result = await sendToDevice(accessToken, firebaseProjectId, token, title, notifBody, data);
      if (result.success) {
        sent++;
      } else {
        failed++;
        if (result.shouldDeactivate) {
          invalidTokens.push(token);
        }
      }
    }

    if (invalidTokens.length > 0) {
      await supabase
        .from("fcm_tokens")
        .update({ is_active: false, updated_at: new Date().toISOString() })
        .in("token", invalidTokens);
    }

    await supabase.from("notification_logs").insert({
      type, title, body: notifBody, data: data || {},
      target_type, target_user_ids: target_user_ids || [],
      total_sent: sent, total_failed: failed, sent_by: sent_by || null,
    });

    return new Response(
      JSON.stringify({ success: true, sent, failed, total_tokens: tokens.length }),
      { headers: { "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Error:", error);
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : "Unknown error" }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
