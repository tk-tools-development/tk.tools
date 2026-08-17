/**
 * Cloudflare Worker: proxies Discord's unauthenticated username-availability check
 * so the static site can call it from the browser (Discord sends no CORS headers).
 *
 * Deploy:  cd worker && npx wrangler deploy
 * Then put https://<your-worker>.workers.dev/check into the site's "Checker API URL".
 */

const DISCORD_ENDPOINT = "https://discord.com/api/v9/unique-username/username-attempt-unauthed";

const USERNAME_RE = /^[a-z0-9._]{2,32}$/;

function corsHeaders(origin) {
  return {
    "access-control-allow-origin": origin || "*",
    "access-control-allow-methods": "POST, OPTIONS",
    "access-control-allow-headers": "content-type",
    "access-control-max-age": "86400"
  };
}

function json(body, status, origin) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json", ...corsHeaders(origin) }
  });
}

function isValid(username) {
  return (
    typeof username === "string" &&
    USERNAME_RE.test(username) &&
    !username.includes("..") &&
    !username.startsWith(".") &&
    !username.endsWith(".")
  );
}

export default {
  async fetch(request, env) {
    const allowed = env && env.ALLOWED_ORIGIN ? env.ALLOWED_ORIGIN : "*";
    const origin = allowed === "*" ? "*" : allowed;

    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: corsHeaders(origin) });
    }
    if (request.method !== "POST") {
      return json({ error: "use POST with {\"username\":\"abc\"}" }, 405, origin);
    }

    let payload;
    try {
      payload = await request.json();
    } catch (err) {
      return json({ error: "invalid JSON body" }, 400, origin);
    }

    const username = typeof payload.username === "string" ? payload.username.trim().toLowerCase() : "";
    if (!isValid(username)) {
      return json({ error: "invalid username" }, 400, origin);
    }

    const upstream = await fetch(DISCORD_ENDPOINT, {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/122.0 Safari/537.36",
        "x-discord-locale": "en-US"
      },
      body: JSON.stringify({ username })
    });

    if (upstream.status === 429) {
      const body = await upstream.json().catch(() => ({}));
      return json({ error: "rate limited", retry_after: body.retry_after ?? 2 }, 429, origin);
    }
    if (!upstream.ok) {
      return json({ error: `discord returned ${upstream.status}` }, 502, origin);
    }

    const data = await upstream.json();
    if (typeof data.taken !== "boolean") {
      return json({ error: "unexpected response from discord" }, 502, origin);
    }
    return json({ username, taken: data.taken }, 200, origin);
  }
};
