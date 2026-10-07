#!/bin/bash
# Render every AeroSpace binding as a grouped HTML cheat sheet and show it as
# a Hammerspoon overlay (esc closes it). Bindings are read live from AeroSpace,
# so the sheet always matches the loaded config.
export PATH="/opt/homebrew/bin:$PATH"

out="${TMPDIR:-/tmp}/aerospace-keys.html"
dump=$(for mode in main service resize; do
    printf '%s\t' "$mode"
    aerospace config --get "mode.${mode}.binding" --json | tr -d '\n'
    printf '\n'
done)

/usr/bin/python3 - "$out" "$dump" <<'EOF'
import html, json, re, sys

MODS = {"alt": "⌥", "ctrl": "⌃", "shift": "⇧", "cmd": "⌘"}
KEYS = {
    "leftSquareBracket": "[", "rightSquareBracket": "]", "slash": "/",
    "backslash": "\\", "quote": "'", "comma": ",", "period": ".",
    "minus": "-", "equal": "=", "semicolon": ";", "backtick": "`",
    "space": "Space", "enter": "↩", "esc": "esc", "tab": "⇥",
    "backspace": "⌫", "left": "←", "right": "→", "up": "↑", "down": "↓",
}

def keycaps(binding):
    parts = binding.split("-")
    caps = [MODS.get(p, p) for p in parts[:-1]]
    last = parts[-1]
    caps.append(KEYS.get(last, last.upper() if len(last) == 1 else last))
    return "".join(f"<kbd>{html.escape(c)}</kbd>" for c in caps)

SCRIPTS = {"show-floating.sh": "List floating windows", "show-keys.sh": "This cheat sheet"}

def phrase(s):
    s = re.sub(r"\s*--(focus-follows-window|wrap-around)", "", s)
    w = s.split()
    c, a = w[0], " ".join(w[1:])
    if c == "exec-and-forget":
        if a.startswith("open -na "):
            return "New " + a[9:] + " window"
        return SCRIPTS.get(a.split("/")[-1], "Run " + a)
    if c == "focus":
        return "Focus " + a
    if c == "move":
        return "Move window " + a
    if c == "workspace":
        return {"prev": "Previous workspace", "next": "Next workspace"}.get(a, "Go to " + a)
    if c == "move-node-to-workspace":
        return "Send window to " + a
    if c == "move-node-to-monitor":
        return f"Send window to {a} monitor"
    if c == "focus-monitor":
        return f"Focus {a} monitor"
    if c == "move-workspace-to-monitor":
        return f"Send workspace to {a} monitor"
    if c == "layout":
        if a in ("accordion",):
            return "accordion"
        return {"floating tiling": "Toggle floating",
                "h_tiles v_tiles": "Tiles, flip orientation",
                "v_accordion h_accordion": "Accordion, flip orientation"}.get(a, "Layout " + a)
    if c == "join-with":
        return "Join " + a
    if c == "resize":
        dim, amt = w[-2], w[-1]
        return f"{dim.capitalize()} {amt.replace('-', '−')}"
    if c == "mode":
        return a.capitalize() + " mode"
    if s.startswith("focus-back-and-forth"):
        return "Last window, else last workspace"
    return {"fullscreen": "Fullscreen", "balance-sizes": "Balance sizes",
            "reload-config": "Reload config",
            "flatten-workspace-tree": "Flatten workspace (undo joins)",
            "close-all-windows-but-current": "Close all other windows"}.get(s, s)

def describe(cmd):
    steps = [x.strip() for x in cmd.split(";") if x.strip() and x.strip() != "mode main"]
    if not steps:
        return "Back to main mode"
    out = [phrase(x) for x in steps]
    if len(out) == 2 and out[1] == "accordion":
        return out[0] + " (accordion)"
    return ", then ".join(out)

def group(mode, cmd):
    if mode != "main":
        return mode
    c = cmd.split()[0]
    if c == "focus":
        return "Focus"
    if c == "move":
        return "Move window"
    if c in ("workspace", "move-node-to-workspace", "workspace-back-and-forth") or "workspace" in cmd and "monitor" not in cmd:
        return "Workspaces"
    if "monitor" in cmd:
        return "Monitors"
    if c in ("layout", "fullscreen", "balance-sizes", "resize"):
        return "Layout"
    if c == "mode":
        return "Modes"
    return "Launch"

ORDER = ["Focus", "Move window", "Workspaces", "Monitors", "Layout", "Modes", "Launch", "service", "resize"]
TITLES = {"service": "Service mode", "resize": "Resize mode"}
NOTES = {"service": "⌥Space or ⌥\\ to enter", "resize": "⌥R to enter"}

groups = {}
for line in sys.argv[2].splitlines():
    if not line.strip():
        continue
    mode, raw = line.split("\t", 1)
    for key, cmd in json.loads(raw).items():
        if isinstance(cmd, list):
            cmd = "; ".join(cmd)
        groups.setdefault(group(mode, cmd), []).append((key, cmd))

ORDER_KEYS = "hjklyuiop"
DIRS = {"left": 0, "down": 1, "up": 2, "right": 3, "prev": 4, "next": 5}

def sort_key(item):
    key, cmd = item
    last = key.split("-")[-1]
    words = describe(cmd).lower().split()
    dir_ = next((DIRS[x] for x in words if x in DIRS), 9)
    pos = ORDER_KEYS.index(last) if len(last) == 1 and last in ORDER_KEYS else 99
    return (key.count("-"), dir_ if pos == 99 else 0, pos, describe(cmd))

cards = []
for name in ORDER:
    rows = groups.get(name)
    if not rows:
        continue
    body = "".join(
        f"<tr><td class=k>{keycaps(k)}</td><td class=d title='{html.escape(c)}'>{html.escape(describe(c))}</td></tr>"
        for k, c in sorted(rows, key=sort_key)
    )
    note = f"<span class=note>{NOTES[name]}</span>" if name in NOTES else ""
    cls = " mode" if name in NOTES else ""
    cards.append(f"<section class='card{cls}'><h2>{TITLES.get(name, name)}{note}</h2><table>{body}</table></section>")

page = f"""<!doctype html><html><head><meta charset=utf-8><title>AeroSpace keys</title><style>
:root {{ --bg:#f6f6f4; --card:#fff; --ink:#1d1d1f; --mute:#6e6e73; --line:#e6e6e3;
        --kbd:#f1f1ef; --kbdline:#cfcfcb; --accent:#0a7cff; }}
@media (prefers-color-scheme: dark) {{
  :root {{ --bg:#161618; --card:#212124; --ink:#f2f2f2; --mute:#9a9aa0; --line:#2f2f33;
          --kbd:#2c2c30; --kbdline:#444449; --accent:#4da3ff; }} }}
* {{ box-sizing:border-box }}
html, body {{ margin:0; height:100%; background:transparent; overflow:hidden }}
.sheet {{ height:100%; overflow:auto; padding:28px; background:var(--bg); color:var(--ink);
       border-radius:16px; border:1px solid var(--line);
       font:13px/1.4 -apple-system, BlinkMacSystemFont, sans-serif; }}
h1 {{ font-size:20px; margin:0 0 18px; font-weight:650; letter-spacing:-.01em }}
h1 span {{ color:var(--mute); font-weight:400; font-size:13px; margin-left:10px }}
.grid {{ columns:340px; column-gap:16px }}
.card {{ break-inside:avoid; background:var(--card); border:1px solid var(--line);
        border-radius:12px; padding:14px 16px 10px; margin:0 0 16px }}
.card.mode {{ border-top:3px solid var(--accent) }}
h2 {{ font-size:11px; text-transform:uppercase; letter-spacing:.08em; color:var(--mute);
     margin:0 0 8px; font-weight:600; display:flex; justify-content:space-between }}
.note {{ text-transform:none; letter-spacing:0; color:var(--accent); font-weight:500 }}
table {{ width:100%; border-collapse:collapse }}
td {{ padding:5px 0; border-top:1px solid var(--line); vertical-align:middle }}
tr:first-child td {{ border-top:0 }}
td.k {{ white-space:nowrap; width:1%; padding-right:14px }}
td.d {{ font-size:13px }}
kbd {{ display:inline-block; min-width:22px; padding:2px 6px; margin-right:3px; text-align:center;
      font:600 12px -apple-system, sans-serif; background:var(--kbd);
      border:1px solid var(--kbdline); border-bottom-width:2px; border-radius:5px }}
</style></head><body>
<div class=sheet><h1>AeroSpace<span>esc to close</span></h1>
<div class=grid>{''.join(cards)}</div></div>
</body></html>"""

open(sys.argv[1], "w").write(page)
EOF

# Shown by the Hammerspoon overlay in ~/.hammerspoon/aerospace-keys.lua. A
# Quick Look panel is the fallback, but AeroSpace pulls focus back from it
# within a second, which closes it.
if pgrep -xq Hammerspoon; then
    open -g "hammerspoon://aerospace-keys?file=$out"
else
    qlmanage -p "$out" >/dev/null 2>&1
fi
