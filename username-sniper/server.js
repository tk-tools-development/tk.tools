/**
 * Local dev server: serves the site AND the /check proxy on http://localhost:8080
 * so you can use the tool without deploying anything.
 *
 *   node server.js        then open http://localhost:8080
 *
 * No dependencies — plain Node (18+).
 */

const http = require("http");
const fs = require("fs");
const path = require("path");

const PORT = Number(process.env.PORT || 8080);
const ROOT = __dirname;
const DISCORD_ENDPOINT = "https://discord.com/api/v9/unique-username/username-attempt-unauthed";
const USERNAME_RE = /^[a-z0-9._]{2,32}$/;

const MIME = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".svg": "image/svg+xml",
  ".ico": "image/x-icon",
  ".png": "image/png"
};

function isValid(username) {
  return (
    USERNAME_RE.test(username) &&
    !username.includes("..") &&
    !username.startsWith(".") &&
    !username.endsWith(".")
  );
}

function sendJson(res, status, body) {
  const text = JSON.stringify(body);
  res.writeHead(status, {
    "content-type": "application/json",
    "access-control-allow-origin": "*",
    "access-control-allow-headers": "content-type",
    "access-control-allow-methods": "POST, OPTIONS"
  });
  res.end(text);
}

async function handleCheck(req, res) {
  const chunks = [];
  for await (const chunk of req) chunks.push(chunk);
  let username = "";
  try {
    username = String(JSON.parse(Buffer.concat(chunks).toString() || "{}").username || "").trim().toLowerCase();
  } catch (err) {
    return sendJson(res, 400, { error: "invalid JSON body" });
  }
  if (!isValid(username)) return sendJson(res, 400, { error: "invalid username" });

  try {
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
      return sendJson(res, 429, { error: "rate limited", retry_after: data.retry_after ?? 2 });
    }
    if (!upstream.ok) return sendJson(res, 502, { error: `discord returned ${upstream.status}` });
    const data = await upstream.json();
    if (typeof data.taken !== "boolean") return sendJson(res, 502, { error: "unexpected response from discord" });
    return sendJson(res, 200, { username, taken: data.taken });
  } catch (err) {
    return sendJson(res, 502, { error: `request to discord failed: ${err.message}` });
  }
}

function serveStatic(req, res) {
  const requested = decodeURIComponent(new URL(req.url, "http://localhost").pathname);
  const relative = requested === "/" ? "index.html" : requested.replace(/^\/+/, "");
  const filePath = path.join(ROOT, relative);
  if (!filePath.startsWith(ROOT)) {
    res.writeHead(403).end("forbidden");
    return;
  }
  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404, { "content-type": "text/plain" }).end("not found");
      return;
    }
    res.writeHead(200, { "content-type": MIME[path.extname(filePath)] || "application/octet-stream" });
    res.end(data);
  });
}

http
  .createServer((req, res) => {
    const { pathname } = new URL(req.url, "http://localhost");
    if (pathname === "/check") {
      if (req.method === "OPTIONS") {
        res.writeHead(204, {
          "access-control-allow-origin": "*",
          "access-control-allow-headers": "content-type",
          "access-control-allow-methods": "POST, OPTIONS"
        });
        res.end();
        return;
      }
      if (req.method !== "POST") return sendJson(res, 405, { error: 'use POST with {"username":"abc"}' });
      handleCheck(req, res);
      return;
    }
    serveStatic(req, res);
  })
  .listen(PORT, () => {
    console.log(`Username finder running at http://localhost:${PORT}`);
  });
