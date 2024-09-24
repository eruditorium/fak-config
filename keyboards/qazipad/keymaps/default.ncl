let { tap, hold, td, combo, macro, ..} = import "fak/keycode.ncl" in
let util = import "fak/util_functions.ncl" in

let kc = tap.reg.kc in
let ks = tap.reg.ks in
let md = hold.reg.mod in
let tm = tap.reg.mod in
let tl = tap.layer in
let lt = hold.reg.layer in
let fak = tap.custom.fak in
let media = tap.custom.media in
let me = tap.custom.media in
let XXXX = tap.none & hold.none in

let ki = {
  hp = { decision = 'hold, trigger_on = 'press },
  tp = { decision = 'tap, trigger_on = 'press },
  hr = { decision = 'hold, trigger_on = 'release },
  tr = { decision = 'tap, trigger_on = 'release },
  xx = { decision = 'none },
} in

let cto = 50 in
let virtual_keys' = [
	# LEFT
	combo.make cto [ 4,  5], # TAB,
	combo.make cto [ 3,  4], # ESC,
	combo.make cto [ 4, 17], # LCBR
	combo.make cto [ 5, 18], # LBRC
	combo.make cto [ 6, 19], # LPRN
    #  RIGHT
	combo.make cto [ 10,  11], # BSPC
	combo.make cto [ 9, 22], # RPRN
	combo.make cto [ 10, 23], # RBRC
	combo.make cto [ 11, 24], # RCBR
  combo.make cto [ 36, 37], # ENT
    # BOTTOM
  combo.make cto [ 41, 42],  # mute
	] in
	
let virtual_key_count = std.array.length virtual_keys' in
let key_count = 48 + virtual_key_count in

let layouts = {
  COLEMAK = "QWFPGJLUY'ARSTDHNEIOZXCVBKM,.;",
  APTMAK  = "QWFP  LUY'RSTHBJNAIOZCGDKXM,.;",  
} in

let make_hrm = fun key_idx =>
  let htb_hrm_base = fun eager => {
    timeout_ms = 180,
    # quick_tap_ms = 100,
    # quick_tap_interrupt_ms = 500,
    # global_quick_tap_ms = 80,
    eager_decision = eager,
    timeout_decision = 'hold,
  } in

  let virtual_interrupts = std.array.replicate virtual_key_count ki.hr in

  let htb_hrm_left = fun eager => htb_hrm_base eager & {
    key_interrupts = [
      ki.hr, ki.hr, ki.hr,   ki.tp, ki.tp, ki.tp, ki.tp, ki.tp,    ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,
      ki.hr, ki.hr, ki.hr,   ki.tr, ki.tr, ki.tr, ki.tr, ki.tr,    ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,
      ki.hr, ki.hr, ki.hr,   ki.tp, ki.tp, ki.tp, ki.tp, ki.tp,    ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,
      ki.hr,    ki.hr,       ki.hr,  ki.hr,             ki.hr,        ki.hr,     ki.hr, ki.hr, ki.hr,
    ] @ virtual_interrupts
  } in

  let htb_hrm_right = fun eager => htb_hrm_base eager & {
    key_interrupts = [
      ki.hr, ki.hr, ki.hr,   ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,    ki.tp, ki.tp, ki.tp, ki.tp, ki.tp,       
      ki.hr, ki.hr, ki.hr,   ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,    ki.tr, ki.tr, ki.tr, ki.tr, ki.tr,
      ki.hr, ki.hr, ki.hr,   ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,    ki.tp, ki.tp, ki.tp, ki.tp, ki.tp,
      ki.hr,   ki.hr,        ki.hr,    ki.hr,        ki.hr, ki.hr, ki.hr, ki.hr, ki.hr,
    ] @ virtual_interrupts
  } in

  let hrm_mods = [
    md.lsft, md.lgui, md.lalt, md.lctl, md.ralt,
    md.ralt, md.rctl, md.lalt, md.rgui, md.rsft,
  ] in

  let hrm_key_indices = [10, 11, 12, 13, 14, 15, 16, 17, 18, 19] in

  if std.array.elem key_idx hrm_key_indices then
    let mod_idx = util.array.index_of key_idx hrm_key_indices in
    let side = if mod_idx < (std.array.length hrm_mods / 2) then 'left else 'right in
    let mod = std.array.at mod_idx hrm_mods in

    mod & hold.reg.behavior (
      (if side == 'left then htb_hrm_left else htb_hrm_right)
      (if mod == md.lgui || mod == md.lalt || mod == md.rgui || mod == md.ralt then 'none else 'hold)
    )
  else
    {}
in

let alphas = fun layout => layout
  |> std.string.characters
  |> util.array.enumerate
  |> std.array.map (
      fun { index, value } => kc."%{value}"
      & make_hrm index
    )
in

let thumb = fun thumb_idx =>
  let thumb_behavior = {
    timeout_ms = 180,
    timeout_decision = 'hold,
    key_interrupts = std.array.replicate key_count ki.hr,
  } in
  [
    kc.SPC  & lt 1 & hold.reg.behavior thumb_behavior,
    kc.ENT  & lt 1 & hold.reg.behavior thumb_behavior, 
    media.VOLU & lt 2 & hold.reg.behavior thumb_behavior, 
  ]
  |> std.array.at thumb_idx
in

let cu = {
  # copy custom stuff from example
  COPY = md.lctl & kc.INS, # md.lctl & kc.C,
  PSTE = md.lsft & kc.INS, # md.lctl & kc.V,
  CUT  = md.lctl & kc.X,
} in

let combos_base = [
  kc.TAB, kc.ESC, ks.LCBR, kc.LBRC, ks.LPRN,
  kc.BSPC, ks.RPRN, kc.RBRC, ks.RCBR, kc.ENT,
  media.MUTE
] in

{
  virtual_keys = virtual_keys',
  layers = [
    let bcol = fun key_idx => (alphas layouts.COLEMAK) |> std.array.at key_idx in
    # ALPHAS
    [ 
      kc.KP_7, kc.KP_8, kc.KP_9,    bcol  0, bcol  1, bcol  2, bcol  3, bcol  4, bcol  5, bcol  6, bcol  7, bcol  8, bcol  9, 
      kc.KP_4, kc.KP_5, kc.KP_6,    bcol 10, bcol 11, bcol 12, bcol 13, bcol 14, bcol 15, bcol 16, bcol 17, bcol 18, bcol 19,
      kc.KP_1, kc.KP_2, kc.KP_3,    bcol 20, bcol 21, bcol 22, bcol 23, bcol 24, bcol 25, bcol 26, bcol 27, bcol 28, bcol 29,
      kc.NUM ,     kc.KP_0,         media.VOLD, thumb 2,    thumb 0, thumb 1, media.PREV, media.PLAY, media.NEXT,
    ] @ combos_base,
    # SYM NUM
    [
      kc.F1, kc.F5, kc.F9,          kc.F9,   kc.F10,  kc.F11,  kc.F12,  XXXX,        ks.PLUS, kc.N7,   kc.N8,  kc.N9,  XXXX,
      kc.F2, kc.F6, kc.F10,         kc.F5,   kc.F6,   kc.F7,   kc.F8 ,  fak.BOOT,       kc.MINS, kc.N4,   kc.N5,  kc.N6,  kc.N0,
      kc.F3, kc.F7, kc.F11,         kc.F1,   kc.F2,   kc.F3,   kc.F4,   XXXX,           XXXX,     kc.N1,   kc.N2,  kc.N3,  kc.DOT,
      kc.F12,    kc.F12,            XXXX,  XXXX,            XXXX,   XXXX,    XXXX, XXXX, XXXX,
    ] @ combos_base,
    # NAV
    [
      XXXX, XXXX, XXXX,             XXXX,    kc.SLSH, kc.EQL,  kc.BSLS, XXXX,          XXXX,    kc.PGDN, kc.UP,   kc.PGUP,  XXXX,
      XXXX, XXXX, XXXX,             ks.AMPR, ks.EXLM, ks.PLUS, ks.UNDS, kc.GRV,        kc.HOME, kc.LEFT, kc.DOWN, kc.RGHT,  kc.END,
      XXXX, XXXX, XXXX,             ks.PIPE, ks.QUES, kc.MINS, ks.ASTR, ks.HASH,       XXXX,    XXXX,    XXXX,  XXXX, XXXX,
      XXXX   , XXXX,             XXXX,    XXXX,   XXXX,              XXXX,           XXXX,            XXXX,   XXXX,    
    ] @ combos_base,
    # ALPHA APTMAK
    let bapt = fun key_idx => (alphas layouts.APTMAK) |> std.array.at key_idx in
    [
      kc.KP_7, kc.KP_8, kc.KP_9,    bapt  0, bapt  1, bapt  2, bapt  3, bapt  4, bapt  5, bapt  6, bapt  7, bapt  8, bapt  9, 
      kc.KP_4, kc.KP_5, kc.KP_6,    bapt 10, bapt 11, bapt 12, bapt 13, bapt 14, bapt 15, bapt 16, bapt 17, bapt 18, bapt 19,
      kc.KP_1, kc.KP_2, kc.KP_3,    bapt 20, bapt 21, bapt 22, bapt 23, bapt 24, bapt 25, bapt 26, bapt 27, bapt 28, bapt 29,
      kc.NUM ,     kc.KP_0,         media.VOLD, thumb 2,    thumb 0, thumb 1, media.PREV, media.PLAY, media.NEXT,    
    ] @ combos_base,
  ]
}