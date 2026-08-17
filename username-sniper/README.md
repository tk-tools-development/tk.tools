# Discord Username Finder

A small website that generates 3–4 character Discord usernames, verifies each one against
Discord, and lists **only the names that are actually available**. Names that are taken never
show up in the output.

- Length: 3 or 4 characters
- Character sets: letters only, numbers only, letters + numbers, letters + numbers + `.`/`_`, or your own custom characters
- Optional pattern, e.g. `LLNN` (two letters then two numbers), `L?N?`, or literals like `x??z`
  - `L` = letter, `N` = number, `?` = any allowed character, anything else = that exact character
- Random mode (sample candidates) or sequential mode (walk every combination in order)
- Filters: no repeated characters, don't start with a number, skip names already checked
- Progress counters, stop button, copy-one / copy-all, download as `.txt`
- Settings are remembered in your browser

## Why a proxy is needed

Discord's availability endpoint (`/api/v9/unique-username/username-attempt-unauthed`) does not
send CORS headers, so a page on GitHub Pages cannot call it directly. This repo includes three
ways to run a tiny proxy that forwards the check — pick one.

### Option A — Cloudflare Worker (free, recommended for the hosted site)

```bash
cd username-sniper/worker
npx wrangler login
npx wrangler deploy
```

Wrangler prints a URL like `https://discord-username-check.<you>.workers.dev`.
Your checker URL is that plus `/check`.

To lock the proxy to your own site, uncomment the `ALLOWED_ORIGIN` var in `wrangler.toml`.

### Option B — Vercel

Deploy the repo to Vercel; `username-sniper/api/check.mjs` becomes `https://<project>.vercel.app/api/check`.

### Option C — Run everything locally (no deploy)

```bash
cd username-sniper
node server.js         # Node 18+
# open http://localhost:8080
```

The local server serves the site and the `/check` proxy on the same origin, so the checker URL
is filled in automatically.

## Hosting the site on GitHub Pages

1. Put your proxy URL into `username-sniper/assets/config.js`:

   ```js
   window.SNIPER_CONFIG = { apiUrl: "https://discord-username-check.you.workers.dev/check" };
   ```

   (Or leave it empty and paste the URL into the **Checker API URL** box under *Advanced*.)
2. In the repo: **Settings → Pages → Build and deployment → Source: GitHub Actions**.
3. Push to `main`. The workflow in `.github/workflows/pages.yml` publishes the
   `username-sniper/` folder to `https://tk-tools-development.github.io/tk.tools/`.

## Using it

1. Pick length + character set (and a pattern if you want something specific).
2. Set how many names to check. Keep **Requests at a time** low (2–3) and the **delay** at
   300 ms or more — Discord rate limits aggressively, and the tool automatically pauses and
   retries when it gets a 429.
3. Press **Start checking**. Available names appear in section 3 as they're confirmed.
4. Copy a name and set it in Discord: **User Settings → Account → Edit → Username**.

## Notes and limits

- The check is a live query against Discord, but availability is not a reservation — a
  3-character name can be taken by someone else seconds later.
- This tool does **not** log into Discord or change your account. Claiming is manual, on
  purpose: automating account actions (self-bots, token automation) violates Discord's Terms
  of Service and gets accounts disabled.
- Hammering the endpoint from one IP will get that IP temporarily blocked. The defaults are
  deliberately gentle; raise them at your own risk.
