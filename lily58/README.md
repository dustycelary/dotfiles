# Lily58 "Timeless" Programmer Keymap — Setup Guide

This is the **timeless** variant: a QMK port of urob's ZMK home-row mod philosophy. Designed so timing is **irrelevant during normal typing** — only events matter.

The big additions over the previous version:

| Feature | What it does |
|---|---|
| **Flow Tap** | If you just tapped an alpha key, the next mod-tap key is *immediately* a tap. No timer. (QMK's version of ZMK's `require-prior-idle-ms`.) |
| **Longer 250ms tapping term** | Combined with Flow Tap, timing only matters in two rare edge cases. |
| **Per-key tapping terms** | Pinkies get +50ms, ring +25ms, index −30ms. Matches finger speed and strength. |
| **Combos for `(` `)` `{` `}`** | Type parens on the base layer without going to LOWER. |
| **Caps Word** | F+J combo enters auto-shifting mode for `SCREAMING_CASE`. |
| **Mouse layer** | New 5th layer for cursor/scroll/clicks when your mouse is unreachable. |
| **`F+J` combo** | Both index fingers = Caps Word. Easy to hit. |

## Files

- `keymap.c` — 5 layers + combos + per-key tuning
- `config.h` — Flow Tap, Chordal Hold, Permissive Hold, long term
- `rules.mk` — enables Combos and Caps Word; OLED stays off

## Setup (same as before)

```bash
# 1. Update QMK (Flow Tap needs recent QMK — late 2025+)
cd ~/qmk_firmware
git pull origin master

# 2. Drop files in
mkdir -p ~/qmk_firmware/keyboards/lily58/keymaps/timeless
cp keymap.c config.h rules.mk ~/qmk_firmware/keyboards/lily58/keymaps/timeless/

# 3. Compile
qmk compile -kb lily58 -km timeless

# 4. Flash each half (EE_HANDS)
qmk flash -kb lily58 -km timeless -bl avrdude-split-left
qmk flash -kb lily58 -km timeless -bl avrdude-split-right
```

If `qmk compile` complains about `FLOW_TAP_TERM` being undefined, your QMK is older than the Flow Tap merge (PR #25125, late 2025). Update with `git pull origin master` from `~/qmk_firmware`.

## How the timeless logic actually plays out

A walkthrough of three scenarios you'll hit constantly:

**Scenario 1 — Typing "data" at 130 WPM**

You tap `D`, `A`, `T`, `A` in quick succession. All are letters even though `D` and `A` are mod-taps.

- `D` pressed → mod-tap, undecided
- `A` pressed → Chordal Hold sees same-hand, settles `D` as TAP. Output: `d`
- `T` pressed within Flow Tap window (150ms of previous tap) → `A` immediately resolves as TAP. Output: `a`
- `A` pressed within Flow Tap window → `T` was just a normal key, but `A` itself is a mod-tap; Flow Tap fires it as tap immediately. Output: `t`
- Final `A` resolves on release. Output: `a`

Total experienced delay: **zero**. Same as a regular keyboard.

**Scenario 2 — Holding Cmd+S to save**

You've stopped typing for a moment, then hold `A` (Cmd) and tap `S` to save (but wait — `S` is on the same hand!). Need to use opposite hand. Try `A` (Cmd) and tap... actually, save = Cmd+S, same hand. Use the dedicated `LGUI` thumb key instead, or:

You realize this and instead hold `;` (right pinky = Cmd) and tap `S`:

- `;` pressed → mod-tap, undecided
- `S` pressed → Chordal Hold: opposite hand, OK to be a mod
- `S` released → Permissive Hold fires: `;` resolves as GUI, then `S` taps. Output: **Cmd+S** ✓

**Scenario 3 — The edge case urob mentions**

You want Ctrl+C but both `D` (Ctrl) and `C` are left-handed. You'd need same-hand mod+key. The solution: hold the mod for longer than `TAPPING_TERM` (250ms), then tap. After 250ms, `D` resolves as hold regardless of what's next. Then tap `C` → Ctrl+C.

In practice this comes up rarely — Ctrl+C is left-hand on QWERTY, so use right-side `K` (Ctrl) + left-hand `C` instead: easier.

## The combo cheat sheet

Press both keys near-simultaneously (within 40ms):

| Combo | Output | Why |
|---|---|---|
| `W` + `E` | `(` | Left-hand paren |
| `I` + `O` | `)` | Right-hand paren, symmetric |
| `X` + `C` | `{` | Left-hand brace |
| `,` + `.` | `}` | Right-hand brace, symmetric |
| `D` + `F` | `Esc` | Index+middle, vim-friendly |
| `J` + `K` | `Backspace` | Right index+middle |
| `F` + `J` | `Caps Word` | Both index fingers, easy to hit |

Combos use `COMBO_MUST_TAP_PER_COMBO`, meaning the keys must be freshly tapped (not held from a previous keystroke). This prevents misfires when typing words like "we" or "io".

## Caps Word

Press `F` + `J` simultaneously. The next word you type is in CAPS. It auto-disables on space, period, or other word breakers. Numbers and underscores pass through, which is exactly what you want for `MAX_BUFFER_SIZE`.

Press `F`+`J` again to cancel mid-word.

## The mouse layer (new!)

Tap inner thumbs to reach ADJUST, then tap the `T` or `Y` position to **toggle mouse mode on**. You're now on Layer 4 with:

- Right hand home row = mouse cursor (J K L = left/down/right, I = up)
- `U` / `O` = horizontal scroll left/right
- Top row = vertical scroll
- `J K L` (lower thumb area) = mouse buttons (L/Middle/R)
- Left thumb = left click, right thumb = right click
- Bottom-right Shift position = toggle mouse mode OFF

Use it when your mouse is across the desk, you're on a couch, or you want to dismiss a dialog without breaking flow.

## Layer summary

| # | Name | Access | Purpose |
|---|---|---|---|
| 0 | QWERTY | default | letters, numbers, basic punctuation |
| 1 | LOWER | hold left thumb | symbols, F1-F12, numpad |
| 2 | RAISE | hold right thumb | arrows, nav, window mgmt, media, clipboard |
| 3 | ADJUST | hold both thumbs | reset, bootloader, mouse-toggle |
| 4 | MOUSE | toggle from ADJUST | cursor / scroll / click |

## Tuning if it misbehaves

**Flow Tap feels delayed (you see input lag):**
- Decrease `FLOW_TAP_TERM` in `config.h` from 150 → 100
- Rule of thumb: `10500 / your_WPM`. At 130 WPM, the minimum is ~80ms.

**Modifiers fail to register when you wanted them:**
- Flow Tap might be eating them. Pause briefly before deliberate modifier holds, or
- Increase `FLOW_TAP_TERM` slightly: 150 → 175

**Same-hand rolls still produce false mods (rare with Chordal Hold + Flow Tap, but possible):**
- Decrease `TAPPING_TERM` to 220
- Verify the `chordal_hold_layout` array in `keymap.c` is correct

**A specific finger (usually pinky) fights you:**
- Adjust its per-key tapping term in the `get_tapping_term()` function. Bump pinky to `+75` or `+100`.

**Combo for parens fires while typing "we" or "io":**
- Lower `COMBO_TERM` from 40 to 30 in `config.h`
- The keys must be near-simultaneous; sequential presses won't trigger it

## Comparison to urob's setup

This is a **faithful port of the principles**, not a 1:1 clone. Differences:

| Concept | urob (ZMK) | This config (QMK) |
|---|---|---|
| Idle short-circuit | `require-prior-idle-ms: 150` | `FLOW_TAP_TERM 150` ✓ equivalent |
| Opposite-hand rule | `hold-trigger-key-positions` + `hold-trigger-on-release` | `CHORDAL_HOLD` ✓ equivalent |
| Hold flavor | `balanced` | `PERMISSIVE_HOLD` ✓ equivalent |
| Tapping term | 280ms | 250ms (close) |
| Combos for symbols | extensive (his whole symbol "layer") | partial (just `( ) { }`) |
| Symbol layer | none — combos only | full LOWER layer (you have 58 keys, can afford it) |
| Caps Word access | sticky-shift on thumb | F+J combo |

The biggest philosophical difference: urob is on a 34-key board where layers are precious. With 58 keys, having dedicated layers + combos for the most-used symbols is the right trade-off.

## Where to learn more

- QMK Flow Tap docs: https://docs.qmk.fm/tap_hold#flow-tap
- QMK Chordal Hold docs: https://docs.qmk.fm/tap_hold#chordal-hold
- urob's writeup: https://github.com/urob/zmk-config#timeless-homerow-mods
- Precondition's home-row mods guide: https://precondition.github.io/home-row-mods
