// Supabase Edge Function: uploadthing-handler
// Route handler untuk UploadThing (mengotorisasi upload file attachment gambar dari client iOS)

import { createRouteHandler } from "https://esm.sh/uploadthing/server"

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
}

// Upload configuration: Batasan file attachment jpeg maks 5MB
const uploadRouter = {
  attachmentUploader: {
    maxFileSize: "5MB",
    maxFileCount: 1,
    accept: ["image/jpeg", "image/png"],
  },
}

const handler = createRouteHandler({
  router: uploadRouter,
  config: {
    token: Deno.env.get("UPLOADTHING_TOKEN"),
  },
})

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders })
  }

  const response = await handler(req)

  const newHeaders = new Headers(response.headers)
  for (const [key, val] of Object.entries(corsHeaders)) {
    newHeaders.set(key, val)
  }

  return new Response(response.body, {
    status: response.status,
    headers: newHeaders,
  })
})
