import "jsr:@supabase/functions-js/edge-runtime.d.ts";

// This function has been deprecated and is no longer needed.
// All app images have been seeded to the app-assets bucket.
Deno.serve(async (_req: Request) => {
  return new Response(
    JSON.stringify({ error: "This function has been deprecated. Images are already seeded." }),
    { status: 410, headers: { "Content-Type": "application/json" } },
  );
});
