/* Discord username finder — generates candidates, verifies each one, shows only free names. */

const LETTERS = "abcdefghijklmnopqrstuvwxyz";
const DIGITS = "0123456789";
const SYMBOLS = "._";

const el = (id) => document.getElementById(id);

const ui = {
  length: el("length"),
  charset: el("charset"),
  customChars: el("customChars"),
  pattern: el("pattern"),
  mode: el("mode"),
  count: el("count"),
  concurrency: el("concurrency"),
  delay: el("delay"),
  apiUrl: el("apiUrl"),
  noRepeat: el("noRepeat"),
  noLeadingDigit: el("noLeadingDigit"),
  skipSeen: el("skipSeen"),
  start: el("start"),
  stop: el("stop"),
  clear: el("clear"),
  copyAll: el("copyAll"),
  download: el("download"),
  results: el("results"),
  empty: el("empty"),
  message: el("message"),
  barFill: el("barFill"),
  statChecked: el("statChecked"),
  statAvailable: el("statAvailable"),
  statTaken: el("statTaken"),
  statErrors: el("statErrors"),
  statState: el("statState")
};

const state = {
  running: false,
  cancel: false,
  checked: 0,
  available: 0,
  taken: 0,
  errors: 0,
  total: 0,
  seen: new Set(),
  found: []
};

/* ---------- settings persistence ---------- */

const SETTINGS_KEY = "discord-username-finder.settings";
const SETTING_FIELDS = ["length", "charset", "customChars", "pattern", "mode", "count", "concurrency", "delay", "apiUrl"];
const SETTING_FLAGS = ["noRepeat", "noLeadingDigit", "skipSeen"];

function loadSettings() {
  let saved = {};
  try {
    saved = JSON.parse(localStorage.getItem(SETTINGS_KEY) || "{}");
  } catch (err) {
    saved = {};
  }
  for (const key of SETTING_FIELDS) {
    if (typeof saved[key] === "string") ui[key].value = saved[key];
  }
  for (const key of SETTING_FLAGS) {
    if (typeof saved[key] === "boolean") ui[key].checked = saved[key];
  }
  if (!ui.apiUrl.value) ui.apiUrl.value = defaultApiUrl();
  syncCustomCharsState();
}

function saveSettings() {
  const data = {};
  for (const key of SETTING_FIELDS) data[key] = ui[key].value;
  for (const key of SETTING_FLAGS) data[key] = ui[key].checked;
  try {
    localStorage.setItem(SETTINGS_KEY, JSON.stringify(data));
  } catch (err) {
    /* storage unavailable — settings just won't persist */
  }
}

function defaultApiUrl() {
  const configured = (window.SNIPER_CONFIG && window.SNIPER_CONFIG.apiUrl) || "";
  if (configured) return configured;
  // Running behind the bundled local proxy? Then /check is served from the same origin.
  if (location.protocol === "http:" || location.protocol === "https:") {
    if (location.hostname === "localhost" || location.hostname === "127.0.0.1") {
      return `${location.origin}/check`;
    }
  }
  return "";
}

/* ---------- candidate generation ---------- */

function alphabetFor(charset, custom) {
  switch (charset) {
    case "letters": return LETTERS;
    case "numbers": return DIGITS;
    case "alnum": return LETTERS + DIGITS;
    case "alnum_symbols": return LETTERS + DIGITS + SYMBOLS;
    case "custom": return dedupe(custom.toLowerCase().replace(/[^a-z0-9._]/g, ""));
    default: return LETTERS;
  }
}

function dedupe(text) {
  return [...new Set(text.split(""))].join("");
}

/** Turns a pattern like "L?N" into a per-slot list of allowed characters. */
function slotsFor(length, pattern, alphabet) {
  const slots = [];
  const chars = (pattern || "").trim().toLowerCase();
  for (let i = 0; i < length; i++) {
    const token = chars[i];
    if (!token || token === "?") {
      slots.push(alphabet);
    } else if (token === "l") {
      slots.push(intersect(alphabet, LETTERS) || LETTERS);
    } else if (token === "n") {
      slots.push(intersect(alphabet, DIGITS) || DIGITS);
    } else if (/[a-z0-9._]/.test(token)) {
      slots.push(token); // literal character
    } else {
      slots.push(alphabet);
    }
  }
  return slots;
}

function intersect(a, b) {
  return a.split("").filter((c) => b.includes(c)).join("");
}

/** Discord rules: 2–32 chars, a-z 0-9 . _ only, no consecutive dots, no leading/trailing dot. */
function isValidDiscordName(name) {
  if (!/^[a-z0-9._]{2,32}$/.test(name)) return false;
  if (name.includes("..")) return false;
  if (name.startsWith(".") || name.endsWith(".")) return false;
  return true;
}

function passesFilters(name, opts) {
  if (!isValidDiscordName(name)) return false;
  if (opts.noRepeat && new Set(name.split("")).size !== name.length) return false;
  if (opts.noLeadingDigit && DIGITS.includes(name[0])) return false;
  if (opts.skipSeen && state.seen.has(name)) return false;
  return true;
}

function randomCandidate(slots) {
  let out = "";
  for (const slot of slots) {
    out += slot[Math.floor(Math.random() * slot.length)];
  }
  return out;
}

/** Yields candidates: every combination in order, or random picks. */
function* candidates(slots, mode, limit, opts) {
  if (mode === "sequential") {
    const indexes = new Array(slots.length).fill(0);
    let produced = 0;
    while (produced < limit) {
      const name = slots.map((slot, i) => slot[indexes[i]]).join("");
      if (passesFilters(name, opts)) {
        produced++;
        yield name;
      }
      let pos = slots.length - 1;
      while (pos >= 0) {
        indexes[pos]++;
        if (indexes[pos] < slots[pos].length) break;
        indexes[pos] = 0;
        pos--;
      }
      if (pos < 0) return; // exhausted every combination
    }
    return;
  }

  let produced = 0;
  let attempts = 0;
  const maxAttempts = limit * 400 + 2000;
  while (produced < limit && attempts < maxAttempts) {
    attempts++;
    const name = randomCandidate(slots);
    if (!passesFilters(name, opts)) continue;
    produced++;
    yield name;
  }
}

/* ---------- availability checking ---------- */

async function checkUsername(apiUrl, username) {
  const response = await fetch(apiUrl, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ username })
  });
  if (response.status === 429) {
    const body = await response.json().catch(() => ({}));
    const retryAfter = Number(body.retry_after || body.retryAfter || 2);
    const err = new Error("rate limited");
    err.rateLimited = true;
    err.retryAfter = Math.min(Math.max(retryAfter, 1), 30);
    throw err;
  }
  if (!response.ok) {
    throw new Error(`checker returned HTTP ${response.status}`);
  }
  const data = await response.json();
  if (typeof data.taken !== "boolean") {
    throw new Error("unexpected response from checker");
  }
  return !data.taken;
}

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

/* ---------- rendering ---------- */

function setState(text) {
  ui.statState.textContent = text;
}

function showMessage(text) {
  if (!text) {
    ui.message.hidden = true;
    ui.message.textContent = "";
    return;
  }
  ui.message.hidden = false;
  ui.message.textContent = text;
}

function renderStats() {
  ui.statChecked.textContent = state.checked;
  ui.statAvailable.textContent = state.available;
  ui.statTaken.textContent = state.taken;
  ui.statErrors.textContent = state.errors;
  const pct = state.total ? Math.min(100, (state.checked / state.total) * 100) : 0;
  ui.barFill.style.width = `${pct}%`;
}

function addResult(username) {
  state.found.push(username);
  ui.empty.hidden = true;
  const li = document.createElement("li");
  const label = document.createElement("span");
  label.textContent = username;
  const copy = document.createElement("button");
  copy.textContent = "Copy";
  copy.addEventListener("click", async () => {
    await copyText(username);
    copy.textContent = "Copied";
    setTimeout(() => { copy.textContent = "Copy"; }, 1200);
  });
  li.append(label, copy);
  ui.results.prepend(li);
}

async function copyText(text) {
  try {
    await navigator.clipboard.writeText(text);
  } catch (err) {
    const area = document.createElement("textarea");
    area.value = text;
    document.body.append(area);
    area.select();
    document.execCommand("copy");
    area.remove();
  }
}

/* ---------- main run loop ---------- */

async function run() {
  const apiUrl = ui.apiUrl.value.trim();
  if (!apiUrl) {
    showMessage("Set a Checker API URL under Advanced first (deploy worker/ or api/ from this repo).");
    return;
  }

  const length = Number(ui.length.value);
  const alphabet = alphabetFor(ui.charset.value, ui.customChars.value);
  if (!alphabet) {
    showMessage("Your custom character set is empty. Use only a–z, 0–9, dot or underscore.");
    return;
  }

  const opts = {
    noRepeat: ui.noRepeat.checked,
    noLeadingDigit: ui.noLeadingDigit.checked,
    skipSeen: ui.skipSeen.checked
  };
  const slots = slotsFor(length, ui.pattern.value, alphabet);
  const limit = Math.max(1, Math.min(20000, Number(ui.count.value) || 1));
  const concurrency = Math.max(1, Math.min(10, Number(ui.concurrency.value) || 1));
  const delay = Math.max(0, Math.min(10000, Number(ui.delay.value) || 0));

  const queue = [...candidates(slots, ui.mode.value, limit, opts)];
  if (!queue.length) {
    showMessage("No candidates matched those settings — loosen the pattern or filters.");
    return;
  }

  showMessage("");
  state.running = true;
  state.cancel = false;
  state.checked = 0;
  state.available = 0;
  state.taken = 0;
  state.errors = 0;
  state.total = queue.length;
  renderStats();
  ui.start.disabled = true;
  ui.stop.disabled = false;
  setState(`Checking ${queue.length} names…`);

  let cursor = 0;
  const worker = async () => {
    while (!state.cancel) {
      const index = cursor++;
      if (index >= queue.length) return;
      const username = queue[index];
      state.seen.add(username);
      try {
        const free = await checkUsername(apiUrl, username);
        if (free) {
          state.available++;
          addResult(username);
        } else {
          state.taken++;
        }
      } catch (err) {
        if (err.rateLimited) {
          setState(`Rate limited — waiting ${err.retryAfter}s`);
          cursor--; // retry this name after the wait
          await sleep(err.retryAfter * 1000);
          setState("Checking…");
          continue;
        }
        state.errors++;
        showMessage(`Last error: ${err.message}`);
      }
      state.checked++;
      renderStats();
      if (delay) await sleep(delay);
    }
  };

  await Promise.all(Array.from({ length: concurrency }, worker));

  state.running = false;
  ui.start.disabled = false;
  ui.stop.disabled = true;
  setState(state.cancel ? "Stopped" : "Done");
}

/* ---------- wiring ---------- */

function syncCustomCharsState() {
  ui.customChars.disabled = ui.charset.value !== "custom";
}

ui.charset.addEventListener("change", () => {
  syncCustomCharsState();
  saveSettings();
});

for (const key of SETTING_FIELDS) ui[key].addEventListener("change", saveSettings);
for (const key of SETTING_FLAGS) ui[key].addEventListener("change", saveSettings);

ui.start.addEventListener("click", () => {
  if (state.running) return;
  saveSettings();
  run();
});

ui.stop.addEventListener("click", () => {
  state.cancel = true;
  setState("Stopping…");
});

ui.clear.addEventListener("click", () => {
  state.found = [];
  ui.results.innerHTML = "";
  ui.empty.hidden = false;
  state.checked = state.available = state.taken = state.errors = state.total = 0;
  renderStats();
  showMessage("");
  setState("Idle");
});

ui.copyAll.addEventListener("click", async () => {
  if (!state.found.length) return;
  await copyText(state.found.join("\n"));
  ui.copyAll.textContent = "Copied";
  setTimeout(() => { ui.copyAll.textContent = "Copy all"; }, 1200);
});

ui.download.addEventListener("click", () => {
  if (!state.found.length) return;
  const blob = new Blob([state.found.join("\n") + "\n"], { type: "text/plain" });
  const link = document.createElement("a");
  link.href = URL.createObjectURL(blob);
  link.download = "available-usernames.txt";
  link.click();
  URL.revokeObjectURL(link.href);
});

loadSettings();
renderStats();
