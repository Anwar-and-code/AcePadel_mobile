import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const FROM_EMAIL = "AcePadel <noreply@armasoft.ci>";

interface EmailNotificationRequest {
  type: "reservation_confirmed" | "reservation_reminder" | "event_published" | "custom";
  title: string;
  body: string;
  data?: Record<string, string>;
  target_type: "single" | "multiple" | "all";
  target_user_ids?: string[];
  sent_by?: string;
}

// ─── HTML Email Templates — AcePadel Design System ───────────────────
// Brand: Gold #E8C547 + Black #1A1A1A | Accent: #D4AF37 | Dark Gold: #B8860B
const BRAND_GOLD = "#E8C547";
const BRAND_DEEP_GOLD = "#D4AF37";
const BRAND_DARK_GOLD = "#B8860B";
const BRAND_BLACK = "#1A1A1A";
const GOLD_LIGHT = "#FFF9E6";
const GOLD_BORDER = "#F5E6B8";

function baseTemplate(content: string, preheader: string): string {
  return `<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="color-scheme" content="light">
  <title>AcePadel</title>
  <!--[if mso]><style>table,td{font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif!important}</style><![endif]-->
</head>
<body style="font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif;background-color:#F5F5F5;margin:0;padding:0;-webkit-text-size-adjust:100%;">
  <span style="display:none;font-size:1px;color:#F5F5F5;max-height:0;overflow:hidden;">${preheader}</span>
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background-color:#F5F5F5;">
    <tr><td align="center" style="padding:30px 15px;">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:520px;background-color:#FFFFFF;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.08);">
        <!-- Header -->
        <tr><td style="background-color:${BRAND_BLACK};padding:28px 30px;text-align:center;">
          <h1 style="margin:0;font-size:24px;font-weight:800;letter-spacing:0.5px;">
            <span style="color:${BRAND_GOLD};">ace</span><span style="color:#FFFFFF;">padel</span>
          </h1>
        </td></tr>
        <!-- Gold accent line -->
        <tr><td style="height:3px;background:linear-gradient(90deg,${BRAND_GOLD},${BRAND_DEEP_GOLD},${BRAND_GOLD});"></td></tr>
        <!-- Content -->
        <tr><td style="padding:35px 30px;">
          ${content}
        </td></tr>
        <!-- Footer -->
        <tr><td style="background-color:${BRAND_BLACK};padding:20px 30px;text-align:center;">
          <p style="color:#9A9590;font-size:11px;margin:0 0 4px 0;">Cet email a \u00e9t\u00e9 envoy\u00e9 automatiquement par AcePadel.</p>
          <p style="color:#5D5D5D;font-size:10px;margin:0;">\u00a9 ${new Date().getFullYear()} <span style="color:${BRAND_GOLD};">ace</span><span style="color:#B0B0B0;">padel</span> \u2014 Tous droits r\u00e9serv\u00e9s</p>
        </td></tr>
      </table>
    </td></tr>
  </table>
</body>
</html>`;
}

function reservationConfirmedTemplate(data: Record<string, string>, userName: string): string {
  const terrain = data.terrain || "Terrain";
  const date = data.date || "";
  const startTime = data.start_time || "";
  return baseTemplate(`
    <div style="text-align:center;margin-bottom:25px;">
      <div style="display:inline-block;background-color:${GOLD_LIGHT};border-radius:50%;padding:16px;margin-bottom:12px;">
        <span style="font-size:32px;">\u2705</span>
      </div>
      <h2 style="color:${BRAND_BLACK};margin:0;font-size:20px;font-weight:700;">R\u00e9servation confirm\u00e9e</h2>
    </div>
    <p style="color:#575350;font-size:14px;line-height:1.6;margin:0 0 20px 0;">Bonjour <strong style="color:${BRAND_BLACK};">${userName}</strong>,</p>
    <p style="color:#575350;font-size:14px;line-height:1.6;margin:0 0 25px 0;">Votre r\u00e9servation a \u00e9t\u00e9 confirm\u00e9e avec succ\u00e8s !</p>
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background-color:${GOLD_LIGHT};border-radius:12px;border:1px solid ${GOLD_BORDER};margin-bottom:25px;">
      <tr><td style="padding:20px;">
        <table role="presentation" width="100%" cellpadding="0" cellspacing="0">
          <tr>
            <td style="padding:6px 0;"><span style="color:#9A9590;font-size:12px;text-transform:uppercase;letter-spacing:0.5px;">Terrain</span></td>
            <td style="padding:6px 0;text-align:right;"><strong style="color:${BRAND_BLACK};font-size:14px;">${terrain}</strong></td>
          </tr>
          <tr><td colspan="2" style="border-bottom:1px solid ${GOLD_BORDER};padding:4px 0;"></td></tr>
          <tr>
            <td style="padding:6px 0;"><span style="color:#9A9590;font-size:12px;text-transform:uppercase;letter-spacing:0.5px;">Date</span></td>
            <td style="padding:6px 0;text-align:right;"><strong style="color:${BRAND_BLACK};font-size:14px;">${date}</strong></td>
          </tr>
          <tr><td colspan="2" style="border-bottom:1px solid ${GOLD_BORDER};padding:4px 0;"></td></tr>
          <tr>
            <td style="padding:6px 0;"><span style="color:#9A9590;font-size:12px;text-transform:uppercase;letter-spacing:0.5px;">Heure</span></td>
            <td style="padding:6px 0;text-align:right;"><strong style="color:${BRAND_BLACK};font-size:14px;">${startTime}</strong></td>
          </tr>
        </table>
      </td></tr>
    </table>
    <p style="color:#9A9590;font-size:13px;line-height:1.5;margin:0;text-align:center;">\u00c0 bient\u00f4t sur les terrains ! \ud83c\udfbe</p>
  `, `Votre r\u00e9servation sur ${terrain} le ${date} \u00e0 ${startTime} est confirm\u00e9e.`);
}

function reservationReminderTemplate(data: Record<string, string>, userName: string): string {
  const terrain = data.terrain || "Terrain";
  const date = data.date || "";
  const startTime = data.start_time || "";
  return baseTemplate(`
    <div style="text-align:center;margin-bottom:25px;">
      <div style="display:inline-block;background-color:${GOLD_LIGHT};border-radius:50%;padding:16px;margin-bottom:12px;">
        <span style="font-size:32px;">\u23f0</span>
      </div>
      <h2 style="color:${BRAND_BLACK};margin:0;font-size:20px;font-weight:700;">Rappel de r\u00e9servation</h2>
    </div>
    <p style="color:#575350;font-size:14px;line-height:1.6;margin:0 0 20px 0;">Bonjour <strong style="color:${BRAND_BLACK};">${userName}</strong>,</p>
    <p style="color:#575350;font-size:14px;line-height:1.6;margin:0 0 25px 0;">Votre r\u00e9servation commence dans <strong style="color:${BRAND_DARK_GOLD};">2 heures</strong> !</p>
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background-color:${GOLD_LIGHT};border-radius:12px;border:1px solid ${GOLD_BORDER};margin-bottom:25px;">
      <tr><td style="padding:20px;">
        <table role="presentation" width="100%" cellpadding="0" cellspacing="0">
          <tr>
            <td style="padding:6px 0;"><span style="color:#9A9590;font-size:12px;text-transform:uppercase;letter-spacing:0.5px;">Terrain</span></td>
            <td style="padding:6px 0;text-align:right;"><strong style="color:${BRAND_BLACK};font-size:14px;">${terrain}</strong></td>
          </tr>
          <tr><td colspan="2" style="border-bottom:1px solid ${GOLD_BORDER};padding:4px 0;"></td></tr>
          <tr>
            <td style="padding:6px 0;"><span style="color:#9A9590;font-size:12px;text-transform:uppercase;letter-spacing:0.5px;">Date</span></td>
            <td style="padding:6px 0;text-align:right;"><strong style="color:${BRAND_BLACK};font-size:14px;">${date}</strong></td>
          </tr>
          <tr><td colspan="2" style="border-bottom:1px solid ${GOLD_BORDER};padding:4px 0;"></td></tr>
          <tr>
            <td style="padding:6px 0;"><span style="color:#9A9590;font-size:12px;text-transform:uppercase;letter-spacing:0.5px;">Heure</span></td>
            <td style="padding:6px 0;text-align:right;"><strong style="color:${BRAND_BLACK};font-size:14px;">${startTime}</strong></td>
          </tr>
        </table>
      </td></tr>
    </table>
    <p style="color:#9A9590;font-size:13px;line-height:1.5;margin:0;text-align:center;">N'oubliez pas votre raquette ! \ud83c\udfd3</p>
  `, `Rappel : votre r\u00e9servation sur ${terrain} commence dans 2h (${startTime}).`);
}

function eventPublishedTemplate(data: Record<string, string>, title: string, body: string): string {
  const eventTitle = data.event_title || title;
  const startDate = data.start_date || "";
  return baseTemplate(`
    <div style="text-align:center;margin-bottom:25px;">
      <div style="display:inline-block;background-color:${GOLD_LIGHT};border-radius:50%;padding:16px;margin-bottom:12px;">
        <span style="font-size:32px;">\ud83c\udf89</span>
      </div>
      <h2 style="color:${BRAND_BLACK};margin:0;font-size:20px;font-weight:700;">Nouvel \u00e9v\u00e9nement</h2>
    </div>
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background-color:${GOLD_LIGHT};border-radius:12px;border:1px solid ${GOLD_BORDER};margin-bottom:25px;">
      <tr><td style="padding:24px;text-align:center;">
        <h3 style="color:${BRAND_DARK_GOLD};margin:0 0 8px 0;font-size:18px;font-weight:700;">${eventTitle}</h3>
        <p style="color:#575350;font-size:14px;margin:0 0 12px 0;line-height:1.5;">${body}</p>
        ${startDate ? `<p style="color:${BRAND_DEEP_GOLD};font-size:13px;font-weight:600;margin:0;">\ud83d\udcc5 ${startDate}</p>` : ""}
      </td></tr>
    </table>
    <p style="color:#575350;font-size:14px;line-height:1.6;margin:0;text-align:center;">Ouvrez l'application AcePadel pour plus de d\u00e9tails et pour vous inscrire.</p>
  `, `Nouvel \u00e9v\u00e9nement : ${eventTitle}`);
}

function customTemplate(title: string, body: string): string {
  return baseTemplate(`
    <div style="text-align:center;margin-bottom:25px;">
      <div style="display:inline-block;background-color:${GOLD_LIGHT};border-radius:50%;padding:16px;margin-bottom:12px;">
        <span style="font-size:32px;">\ud83d\udce2</span>
      </div>
      <h2 style="color:${BRAND_BLACK};margin:0;font-size:20px;font-weight:700;">${title}</h2>
    </div>
    <p style="color:#575350;font-size:14px;line-height:1.7;margin:0 0 20px 0;text-align:center;">${body}</p>
    <p style="color:#9A9590;font-size:13px;line-height:1.5;margin:0;text-align:center;">Ouvrez l'application AcePadel pour en savoir plus.</p>
  `, title);
}

function getEmailHtml(req: EmailNotificationRequest, userName: string): string {
  switch (req.type) {
    case "reservation_confirmed":
      return reservationConfirmedTemplate(req.data || {}, userName);
    case "reservation_reminder":
      return reservationReminderTemplate(req.data || {}, userName);
    case "event_published":
      return eventPublishedTemplate(req.data || {}, req.title, req.body);
    case "custom":
    default:
      return customTemplate(req.title, req.body);
  }
}

function getSubject(req: EmailNotificationRequest): string {
  switch (req.type) {
    case "reservation_confirmed":
      return "\u2705 R\u00e9servation confirm\u00e9e \u2014 AcePadel";
    case "reservation_reminder":
      return "\u23f0 Rappel : votre r\u00e9servation dans 2h \u2014 AcePadel";
    case "event_published":
      return `\ud83c\udf89 ${req.data?.event_title || req.title} \u2014 AcePadel`;
    case "custom":
    default:
      return `${req.title} \u2014 AcePadel`;
  }
}

// ─── Main Handler ─────────────────────────────────────────────────────
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
    if (!RESEND_API_KEY) {
      console.warn("RESEND_API_KEY not configured — skipping email");
      return new Response(
        JSON.stringify({ success: false, sent: 0, failed: 0, message: "RESEND_API_KEY not configured" }),
        { headers: { "Content-Type": "application/json" } }
      );
    }

    const body: EmailNotificationRequest = await req.json();
    const { type, title, body: notifBody, data, target_type, target_user_ids, sent_by } = body;

    if (!type || !title || !notifBody || !target_type) {
      return new Response(
        JSON.stringify({ error: "Missing required fields: type, title, body, target_type" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // Fetch target users with emails
    let query = supabase.from("profiles").select("id, email, first_name, last_name");

    if (target_type === "single" && target_user_ids?.length === 1) {
      query = query.eq("id", target_user_ids[0]);
    } else if (target_type === "multiple" && target_user_ids?.length) {
      query = query.in("id", target_user_ids);
    } else {
      // target_type === 'all' → all joueurs
      query = query.eq("role", "JOUEUR");
    }

    const { data: users, error: usersError } = await query;
    if (usersError) throw usersError;

    if (!users || users.length === 0) {
      return new Response(
        JSON.stringify({ success: true, sent: 0, failed: 0, message: "No users with email found" }),
        { headers: { "Content-Type": "application/json" } }
      );
    }

    // Filter users who have an email
    const usersWithEmail = users.filter((u: any) => u.email && u.email.trim() !== "");

    if (usersWithEmail.length === 0) {
      return new Response(
        JSON.stringify({ success: true, sent: 0, failed: 0, message: "No users with email found" }),
        { headers: { "Content-Type": "application/json" } }
      );
    }

    let sent = 0;
    let failed = 0;
    const subject = getSubject(body);

    // Send emails (batch by 50 for Resend limits)
    const batchSize = 50;
    for (let i = 0; i < usersWithEmail.length; i += batchSize) {
      const batch = usersWithEmail.slice(i, i + batchSize);
      
      // Send individually to personalize with user name
      const promises = batch.map(async (user: any) => {
        const userName = `${user.first_name || ""} ${user.last_name || ""}`.trim() || "Joueur";
        const html = getEmailHtml(body, userName);

        try {
          const res = await fetch("https://api.resend.com/emails", {
            method: "POST",
            headers: {
              Authorization: `Bearer ${RESEND_API_KEY}`,
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              from: FROM_EMAIL,
              to: [user.email],
              subject,
              html,
            }),
          });

          if (res.ok) {
            sent++;
          } else {
            const errText = await res.text();
            console.error(`Email failed for ${user.email}: ${errText}`);
            failed++;
          }
        } catch (err) {
          console.error(`Email error for ${user.email}:`, err);
          failed++;
        }
      });

      await Promise.all(promises);
    }

    console.log(`Email notifications: ${sent} sent, ${failed} failed for type=${type}`);

    return new Response(
      JSON.stringify({ success: true, sent, failed, total_users: usersWithEmail.length }),
      { headers: { "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Email notification error:", error);
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : "Unknown error" }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
