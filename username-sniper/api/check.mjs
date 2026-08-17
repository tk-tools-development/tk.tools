/**
 * Vercel / Netlify-style serverless function version of the checker proxy.
 * Deploy this repo to Vercel and the endpoint is https://<project>.vercel.app/api/check
 */

const DISCORD_ENDPOINT = "https://discord.com/api/v9/unique-username/username-attempt-unauthed";
const USERNAME_RE = /^[a-z0-9._]{2,32}$/;

function isValid(username) {
  return (
    typeof username === "string" &&
    USERNAME_RE.test(username) &&
    !username.includes("..") &&
    !username.startsWith(".") &&
    !username.endsWith(".")
  );
}

export default async function handler(req, res) {
  const origin = process.env.ALLOWED_ORIGIN || "*";
  res.setHeader("access-control-allow-origin", origin);
  res.setHeader("access-control-allow-methods", "POST, OPTIONS");
  res.setHeader("access-control-allow-headers", "content-type");

  if (req.method === "OPTIONS") {
    res.status(204).end();
    return;
  }
  if (req.method !== "POST") {
    res.status(405).json({ error: 'use POST with {"username":"abc"}' });
    return;
  }

  const body = typeof req.body === "string" ? JSON.parse(req.body || "{}") : req.body || {};
  const username = typeof body.username === "string" ? body.username.trim().toLowerCase() : "";
  if (!isValid(username)) {
    res.status(400).json({ error: "invalid username" });
    return;
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
    const data = await upstream.json().catch(() => ({}));
    res.status(429).json({ error: "rate limited", retry_after: data.retry_after ?? 2 });
    return;
  }
  if (!upstream.ok) {
    res.status(502).json({ error: `discord returned ${upstream.status}` });
    return;
  }

  const data = await upstream.json();
  if (typeof data.taken !== "boolean") {
    res.status(502).json({ error: "unexpected response from discord" });
    return;
  }
  res.status(200).json({ username, taken: data.taken });
}
