/* Lily58 — "Timeless" Programmer Keymap : config.h
 * ---------------------------------------------------
 * Inspired by urob's ZMK "timeless homerow mods" philosophy,
 * translated to QMK equivalents.
 *
 * Goal: timing should be IRRELEVANT during normal typing.
 * Achieved with three layered defences:
 *
 *   1. FLOW_TAP   (= ZMK's `require-prior-idle-ms`)
 *      If you JUST tapped another alpha key, the next mod-tap key
 *      immediately resolves as a TAP — no waiting. This is what
 *      makes home-row mods feel instantaneous during prose typing.
 *
 *   2. CHORDAL_HOLD   (= ZMK's positional-hold-tap, opposite-hand rule)
 *      Same-hand rolls never trigger mods. So "as", "sad", "fed",
 *      "kid" are always letters, never Cmd-S or Shift-D.
 *
 *   3. Long TAPPING_TERM (250ms) + PERMISSIVE_HOLD
 *      Once typing pauses, the long term means timing rarely
 *      decides anything. Cross-hand chords resolve when the second
 *      key is pressed-and-released, not when a timer expires.
 *
 * The combined effect: during fast typing, Flow Tap handles it
 * (no timer). During slow deliberate input, Permissive Hold
 * handles it (event-driven, not timer-driven). The 250ms term
 * only matters for two edge cases urob lists:
 *   - same-hand mod + alpha (hold the mod, wait, tap alpha)
 *   - tapping a mod alone with nothing after (rare)
 */

#pragma once

// === TAPPING TERM ===
// Long, like urob's 280ms. Timing is rarely the deciding factor
// once Flow Tap and Chordal Hold are in play.
#define TAPPING_TERM 250
#define TAPPING_TERM_PER_KEY      // pinkies & indexes get different terms

// === FLOW TAP (THE TIMELESS PIECE) ===
// If the previous key was tapped within 150ms, the next mod-tap
// resolves immediately as TAP. This is urob's `require-prior-idle-ms`.
// Rule of thumb: 10500 / your_WPM. At 130 WPM, 80ms would be the
// minimum; 150ms is safer and still feels instant.
#define FLOW_TAP_TERM 150

// === CHORDAL HOLD ===
// Same-hand rolls always tap. The opposite-hand rule.
#define CHORDAL_HOLD

// === COMPANION RESOLUTION FLAGS ===
// PERMISSIVE_HOLD: cross-hand chord resolves as hold when the
// other key is pressed AND released before the mod-tap is released.
// This is the "balanced" flavor urob uses in ZMK.
#define PERMISSIVE_HOLD

// QUICK_TAP_TERM = 0 prevents auto-repeat on double-tap of a
// mod-tap key (otherwise double-tapping 'a' fast gives "aaaaa").
#define QUICK_TAP_TERM 0

// === COMBOS ===
// We use combos for parens on the home row so you can type
// ( and ) without leaving the base layer.
#define COMBO_TERM 40             // tight — must be near-simultaneous
#define COMBO_MUST_TAP_PER_COMBO  // combos require a fresh tap
#define COMBO_TERM_PER_COMBO

// === SPLIT KEYBOARD ===
#define SOFT_SERIAL_PIN D2
#define EE_HANDS
