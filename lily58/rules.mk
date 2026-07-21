# Lily58 — "Timeless" Programmer Keymap : rules.mk

OLED_ENABLE     = no
MOUSEKEY_ENABLE = yes
EXTRAKEY_ENABLE = yes
AUDIO_ENABLE    = no
RGBLIGHT_ENABLE = no

# === New features for the timeless build ===

# Combos — used for parens and a few extras on the home row
COMBO_ENABLE    = yes

# Caps Word — tap both shifts to enter; auto-disables on space/etc
# Handy for SCREAMING_SNAKE_CASE constants
CAPS_WORD_ENABLE = yes

# Link-time optimization — shrinks binary, leaves headroom for the
# extra layer + combos + Flow Tap
LTO_ENABLE      = yes
VIA_ENABLE = no
