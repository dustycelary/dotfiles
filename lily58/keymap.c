#include QMK_KEYBOARD_H

enum layer_number {
    _BASE = 0,
    _NAV,
    _SYM,
    _NUM,
    _FUN,
    _WIN,
    _FUN2
};

// Home-row mod aliases
#define HM_A  LCTL_T(KC_A)
#define HM_S  LALT_T(KC_S)
#define HM_D  LGUI_T(KC_D)
#define HM_F  LSFT_T(KC_F)
#define HM_J  RSFT_T(KC_J)
#define HM_K  RGUI_T(KC_K)
#define HM_L  RALT_T(KC_L)
#define HM_SC RCTL_T(KC_SCLN)

// Hyper macro for QMK
#define HYP_B HYPR(KC_B)
#define HYP_N HYPR(KC_N)
#define HYP_UP HYPR(KC_UP)
#define HYP_LFT HYPR(KC_LEFT)
#define HYP_DWN HYPR(KC_DOWN)
#define HYP_RGT HYPR(KC_RIGHT)

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {

/* BASE (Layer 0)
 * ,-----------------------------------------.                    ,-----------------------------------------.
 * | ESC  |   1  |   2  |   3  |   4  |   5  |                    |   6  |   7  |   8  |   9  |   0  |   -  |
 * |------+------+------+------+------+------|                    |------+------+------+------+------+------|
 * | Tab  |   Q  |   W  |   E  |   R  |   T  |                    |   Y  |   U  |   I  |   O  |   P  |   \  |
 * |------+------+------+------+------+------|                    |------+------+------+------+------+------|
 * |LCTRL |A/CTL |S/ALT |D/GUI |F/SFT |   G  |-------.    ,-------|   H  |J/SFT |K/GUI |L/ALT |;/CTL |   '  |
 * |------+------+------+------+------+------|   [   |    |   ]   |------+------+------+------+------+------|
 * | GRAVE|   Z  |   X  |   C  |   V  |   B  |-------|    |-------|   N  |   M  |   ,  |   .  |   /  | F24  |
 * `-----------------------------------------/       /     \      \-----------------------------------------'
 *                   | LAlt | FUN/ESC| NAV/TAB| /Space  /       \ SYM/RET \  |NUM/BSP| OSM_SFT| RGUI |
 *                   `----------------------------'           '------''--------------------'
 */
[_BASE] = LAYOUT(
  KC_ESC,  KC_1,    KC_2,    KC_3,    KC_4,    KC_5,                       KC_6,    KC_7,    KC_8,    KC_9,    KC_0,    KC_MINS,
  KC_TAB,  KC_Q,    KC_W,    KC_E,    KC_R,    KC_T,                       KC_Y,    KC_U,    KC_I,    KC_O,    KC_P,    KC_BSLS,
  KC_LCTL, HM_A,    HM_S,    HM_D,    HM_F,    KC_G,                       KC_H,    HM_J,    HM_K,    HM_L,    HM_SC,   KC_QUOT,
  KC_GRV,  KC_Z,    KC_X,    KC_C,    KC_V,    KC_B,   KC_LBRC,   KC_RBRC, KC_N,    KC_M,    KC_COMM, KC_DOT,  KC_SLSH, KC_F24,
                    KC_LALT, LT(_FUN, KC_ESC), LT(_NAV, KC_TAB), KC_SPC,   LT(_SYM, KC_ENT), LT(_NUM, KC_BSPC), OSM(MOD_LSFT), KC_RGUI
),

/* NAV (Layer 1) */
[_NAV] = LAYOUT(
  _______, _______, _______, _______, _______, _______,                    _______, _______, _______, _______, _______, _______,
  _______, KC_MPRV, KC_MPLY, KC_MNXT, HYP_B,   HYP_N,                      KC_UNDO, KC_CUT,  KC_COPY, KC_PSTE, KC_AGIN, _______,
  _______, KC_LCTL, KC_LALT, KC_LGUI, KC_LSFT, HYP_UP,                     KC_LEFT, KC_DOWN, KC_UP,   KC_RGHT, KC_CAPS, _______,
  KC_MUTE, KC_VOLD, KC_VOLU, HYP_LFT, HYP_DWN, HYP_RGT, _______,  _______, KC_HOME, KC_PGDN, KC_PGUP, KC_END,  KC_INS,  _______,
                    _______, _______, _______, _______,           KC_ENT,  KC_BSPC, KC_CAPS, _______
),

/* SYM (Layer 2) */
[_SYM] = LAYOUT(
  _______, _______, _______, _______, _______, _______,                    _______, _______, _______, _______, _______, _______,
  _______, KC_LBRC, KC_AMPR, KC_ASTR, KC_LPAR, KC_RBRC,                    XXXXXXX, XXXXXXX, _______, _______, _______, _______,
  _______, KC_COLN, KC_DLR,  KC_PERC, KC_CIRC, KC_PLUS,                    XXXXXXX, KC_RSFT, KC_RGUI, KC_RALT, KC_RCTL, _______,
  XXXXXXX, KC_DQT,  KC_EXLM, KC_AT,   KC_HASH, KC_PIPE, _______,  _______, _______, _______, _______, _______, _______, _______,
                    _______, KC_LPAR, KC_RPAR, KC_UNDS,           _______, _______, _______, _______
),

/* NUM (Layer 3) */
[_NUM] = LAYOUT(
  _______, _______, _______, _______, _______, _______,                    _______, _______, _______, _______, _______, _______,
  _______, KC_LBKT, KC_7,    KC_8,    KC_9,    KC_RBKT,                    _______, _______, _______, _______, _______, _______,
  _______, KC_SCLN, KC_4,    KC_5,    KC_6,    KC_EQL,                     _______, KC_RSFT, KC_RGUI, KC_RALT, KC_RCTL, _______,
  XXXXXXX, KC_SQT,  KC_1,    KC_2,    KC_3,    KC_BSLS, _______,  _______, _______, _______, _______, _______, _______, _______,
                    _______, KC_DOT,  KC_0,    KC_MINS,           _______, _______, _______, _______
),

/* FUN (Layer 4) */
[_FUN] = LAYOUT(
  _______, _______, _______, _______, _______, _______,                    _______, _______, _______, _______, _______, _______,
  _______, KC_F11,  KC_F12,  KC_F13,  KC_F14,  KC_F15,                     XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, _______,
  _______, KC_F6,   KC_F7,   KC_F8,   KC_F9,   KC_F10,                     _______, KC_RSFT, KC_RGUI, KC_RALT, KC_RCTL, _______,
  XXXXXXX, KC_F1,   KC_F2,   KC_F3,   KC_F4,   KC_F5,   _______,  _______, KC_F16,  KC_F17,  KC_F18,  KC_F19,  KC_F20,  _______,
                    _______, KC_APP,  _______, _______,           XXXXXXX, MO(_FUN2), KC_DEL,  _______
),

/* WIN (Layer 5) */
[_WIN] = LAYOUT(
  _______, _______, _______, _______, _______, _______,                    _______, _______, _______, _______, _______, _______,
  _______, XXXXXXX, KC_WH_U, XXXXXXX, XXXXXXX, XXXXXXX,                    XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, _______,
  _______, KC_WH_L, KC_WH_D, KC_WH_R, XXXXXXX, XXXXXXX,                    C(G(KC_LEFT)), C(G(KC_DOWN)), C(G(KC_UP)), C(G(KC_RIGHT)), XXXXXXX, _______,
  TG(_WIN), XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, _______, _______, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, _______,
                    _______, XXXXXXX, XXXXXXX, XXXXXXX,           _______, C(G(KC_F)), XXXXXXX, _______
),

/* FUN2 (Layer 6) */
[_FUN2] = LAYOUT(
  _______, _______, _______, _______, _______, _______,                    _______, _______, _______, _______, _______, _______,
  _______, KC_F11,  KC_F12,  KC_F13,  KC_F14,  KC_F15,                     _______, _______, _______, _______, _______, _______,
  _______, KC_F6,   KC_F7,   KC_F8,   KC_F9,   KC_F10,                     _______, KC_RSFT, KC_RGUI, KC_RALT, KC_RCTL, _______,
  _______, KC_F1,   KC_F2,   KC_F3,   KC_F4,   KC_F5,   _______,  _______, KC_F16,  KC_F17,  KC_F18,  KC_F19,  KC_F20,  _______,
                    _______, _______, _______, _______,           _______, _______, _______, _______
)

};

/* ============================================================
 * CHORDAL HOLD HANDEDNESS
 * ============================================================ */
const char chordal_hold_layout[MATRIX_ROWS][MATRIX_COLS] PROGMEM = LAYOUT(
  'L','L','L','L','L','L',                'R','R','R','R','R','R',
  'L','L','L','L','L','L',                'R','R','R','R','R','R',
  'L','L','L','L','L','L',                'R','R','R','R','R','R',
  'L','L','L','L','L','L','L',        'R','R','R','R','R','R','R',
      '*','*','*','*',                    '*','*','*','*'
);

/* ============================================================
 * PER-KEY TAPPING TERMS
 * ============================================================
 */
uint16_t get_tapping_term(uint16_t keycode, keyrecord_t *record) {
    switch (keycode) {
        case HM_A:
        case HM_SC:
        case HM_S:
        case HM_L:
        case HM_D:
        case HM_K:
            return 280;
        case HM_F:
        case HM_J:
            return 220;
        default:
            return TAPPING_TERM;
    }
}

/* ============================================================
 * COMBOS
 * ============================================================ */
enum combos {
    CB_CAPSW,
    CB_CAPS,
};

const uint16_t PROGMEM combo_df[]  = {HM_D, HM_F, COMBO_END};
const uint16_t PROGMEM combo_jk[]  = {HM_J, HM_K, COMBO_END};

combo_t key_combos[] = {
    [CB_CAPSW] = COMBO(combo_df, KC_F19),
    [CB_CAPS]  = COMBO(combo_jk, KC_CAPS),
};
