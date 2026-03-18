import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

Deno.serve(async (req: Request) => {
  // Allow only POST (from cron) or GET (manual trigger)
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
        "Access-Control-Allow-Headers": "Authorization, Content-Type, apikey",
      },
    });
  }

  try {
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // Find reservations starting in ~2 hours (window: 1h50 to 2h10 to avoid missing any)
    const now = new Date();
    const twoHoursFromNow = new Date(now.getTime() + 2 * 60 * 60 * 1000);
    const windowStart = new Date(twoHoursFromNow.getTime() - 10 * 60 * 1000); // 1h50
    const windowEnd = new Date(twoHoursFromNow.getTime() + 10 * 60 * 1000);   // 2h10

    const today = now.toISOString().split("T")[0];
    const tomorrow = new Date(now.getTime() + 24 * 60 * 60 * 1000).toISOString().split("T")[0];

    // Fetch confirmed reservations for today/tomorrow with time slots
    const { data: reservations, error } = await supabase
      .from("reservations")
      .select(`
        id, reservation_date, user_id, client_id, status,
        terrain:terrains(id, code),
        time_slot:time_slots(id, start_time, end_time, price),
        user:profiles!reservations_user_id_profiles_fkey(id, first_name, last_name, phone)
      `)
      .in("reservation_date", [today, tomorrow])
      .in("status", ["CONFIRMED", "PENDING"]);

    if (error) throw error;
    if (!reservations || reservations.length === 0) {
      return new Response(JSON.stringify({ message: "No reservations to remind", count: 0 }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    // Filter reservations that start within the 2h window
    const toRemind = reservations.filter((r: any) => {
      if (!r.time_slot?.start_time) return false;
      const [hours, minutes] = r.time_slot.start_time.split(":").map(Number);
      const reservationStart = new Date(`${r.reservation_date}T${String(hours).padStart(2, "0")}:${String(minutes).padStart(2, "0")}:00`);
      return reservationStart >= windowStart && reservationStart <= windowEnd;
    });

    if (toRemind.length === 0) {
      return new Response(JSON.stringify({ message: "No reservations in 2h window", count: 0 }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    // Send reminder for each reservation
    let sent = 0;
    let failed = 0;

    for (const reservation of toRemind) {
      const r = reservation as any;
      const terrainCode = r.terrain?.code || "Terrain";
      const startTime = r.time_slot?.start_time?.substring(0, 5) || "";
      const endTime = r.time_slot?.end_time?.substring(0, 5) || "";
      const userName = r.user ? `${r.user.first_name || ""} ${r.user.last_name || ""}`.trim() : "";

      const title = "Rappel de r\u00e9servation \u23F0";
      const body = `Votre r\u00e9servation sur ${terrainCode} est dans 2h (${startTime} - ${endTime}). \u00C0 bient\u00F4t !`;

      const notifPayload = {
        type: "reservation_reminder",
        title,
        body,
        data: {
          reservation_id: String(r.id),
          terrain: terrainCode,
          date: r.reservation_date,
          start_time: startTime,
        },
        target_type: "single" as const,
        target_user_ids: [r.user_id],
        sent_by: "system_cron",
      };

      // Send push notification
      const pushRes = await fetch(`${SUPABASE_URL}/functions/v1/send-push-notification`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
        },
        body: JSON.stringify(notifPayload),
      });

      // Send email notification
      const emailRes = await fetch(`${SUPABASE_URL}/functions/v1/send-email-notification`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
        },
        body: JSON.stringify(notifPayload),
      });

      if (pushRes.ok || emailRes.ok) {
        sent++;
      } else {
        failed++;
        const pushErr = !pushRes.ok ? await pushRes.text() : "";
        const emailErr = !emailRes.ok ? await emailRes.text() : "";
        console.error(`Failed reminder for reservation ${r.id}: push=${pushErr}, email=${emailErr}`);
      }
    }

    return new Response(
      JSON.stringify({ message: "Reminders processed", total: toRemind.length, sent, failed }),
      { headers: { "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Reminder error:", error);
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : "Unknown error" }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
