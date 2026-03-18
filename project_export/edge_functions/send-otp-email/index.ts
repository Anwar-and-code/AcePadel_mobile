import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { email } = await req.json();
    
    if (!email) {
      return new Response(
        JSON.stringify({ success: false, error: 'Email requis' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Create Supabase client with service role
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const resendApiKey = Deno.env.get('RESEND_API_KEY');
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Generate 4-digit OTP
    const code = String(Math.floor(1000 + Math.random() * 9000));
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    // Invalidate old codes
    await supabase
      .from('otp_codes')
      .update({ expires_at: new Date().toISOString() })
      .eq('email', email.toLowerCase())
      .eq('verified', false)
      .gt('expires_at', new Date().toISOString());

    // Insert new OTP code
    const { error: insertError } = await supabase
      .from('otp_codes')
      .insert({
        email: email.toLowerCase(),
        code: code,
        expires_at: expiresAt.toISOString(),
      });

    if (insertError) {
      console.error('Insert error:', insertError);
      return new Response(
        JSON.stringify({ success: false, error: 'Erreur lors de la création du code' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Send email via Resend
    if (resendApiKey) {
      const emailHtml = `<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="color-scheme" content="light">
  <title>AcePadel</title>
  <!--[if mso]><style>table,td{font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif!important}</style><![endif]-->
</head>
<body style="font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif;background-color:#F5F5F5;margin:0;padding:0;-webkit-text-size-adjust:100%;">
  <span style="display:none;font-size:1px;color:#F5F5F5;max-height:0;overflow:hidden;">Votre code de v\u00e9rification AcePadel : ${code}</span>
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background-color:#F5F5F5;">
    <tr><td align="center" style="padding:30px 15px;">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:480px;background-color:#FFFFFF;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.08);">
        <!-- Header -->
        <tr><td style="background-color:#1A1A1A;padding:32px 30px;text-align:center;">
          <h1 style="margin:0;font-size:28px;font-weight:800;letter-spacing:0.5px;">
            <span style="color:#E8C547;">ace</span><span style="color:#FFFFFF;">padel</span>
          </h1>
        </td></tr>
        <!-- Gold accent line -->
        <tr><td style="height:3px;background:linear-gradient(90deg,#E8C547,#D4AF37,#E8C547);"></td></tr>
        <!-- Content -->
        <tr><td style="padding:40px 30px;text-align:center;">
          <div style="display:inline-block;background-color:#FFF9E6;border-radius:50%;padding:16px;margin-bottom:16px;">
            <span style="font-size:32px;">\u{1F512}</span>
          </div>
          <h2 style="color:#1A1A1A;margin:0 0 8px 0;font-size:20px;font-weight:700;">Votre code de v\u00e9rification</h2>
          <p style="color:#575350;font-size:14px;line-height:1.6;margin:0 0 28px 0;">Utilisez ce code pour vous connecter \u00e0 AcePadel</p>
          <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="margin-bottom:28px;">
            <tr><td align="center">
              <div style="background-color:#FFF9E6;border:2px solid #F5E6B8;border-radius:12px;padding:20px 24px;display:inline-block;">
                <span style="font-size:36px;font-weight:800;letter-spacing:10px;color:#B8860B;">${code}</span>
              </div>
            </td></tr>
          </table>
          <p style="color:#9A9590;font-size:12px;margin:0;">Ce code expire dans <strong style="color:#D4AF37;">10 minutes</strong></p>
        </td></tr>
        <!-- Footer -->
        <tr><td style="background-color:#1A1A1A;padding:20px 30px;text-align:center;">
          <p style="color:#9A9590;font-size:11px;margin:0 0 4px 0;">Si vous n'avez pas demand\u00e9 ce code, ignorez cet email.</p>
          <p style="color:#5D5D5D;font-size:10px;margin:0;">\u00a9 ${new Date().getFullYear()} <span style="color:#E8C547;">ace</span><span style="color:#B0B0B0;">padel</span> \u2014 Tous droits r\u00e9serv\u00e9s</p>
        </td></tr>
      </table>
    </td></tr>
  </table>
</body>
</html>`;

      const resendResponse = await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${resendApiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          from: 'AcePadel <noreply@armasoft.ci>',
          to: [email],
          subject: `${code} - Votre code AcePadel`,
          html: emailHtml,
        }),
      });

      if (!resendResponse.ok) {
        const errorData = await resendResponse.text();
        console.error('Resend error:', errorData);
        // Continue anyway - code is saved in DB
      } else {
        console.log(`Email sent successfully to ${email}`);
      }
    } else {
      console.warn('RESEND_API_KEY not configured - email not sent');
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: `Code envoyé à ${email}`,
        expires_in_seconds: 600,
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  } catch (error) {
    console.error('Error:', error);
    return new Response(
      JSON.stringify({ success: false, error: 'Erreur serveur' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});
