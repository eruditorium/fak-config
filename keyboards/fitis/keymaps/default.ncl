let { tap, hold, td, combo, .. } = import "fak/keycode.ncl" in
let util = import "fak/util_functions.ncl" in

let kc = tap.reg.kc in
let ks = tap.reg.ks in
let md = hold.reg.mod in
let tm = tap.reg.mod in
let me = tap.custom.media in
let XXXX = tap.none & hold.none in

let ki = {
  hp = { decision = 'hold, trigger_on = 'press },
  tp = { decision = 'tap, trigger_on = 'press },
  hr = { decision = 'hold, trigger_on = 'release },
  tr = { decision = 'tap, trigger_on = 'release },
  xx = { decision = 'none },
} in

let cto = 200 in
let combos = [
	# LEFT
	[kc.TAB,   0,  1],
	[kc.ESC,  19, 20],
	[ks.LCBR,  0,  9],
	[kc.LBRC,  1, 10],
	[ks.LPRN,  2, 11],
	[kc.V   , 20, 21], 
	[kc.Q   ,  1,  2], 
	# RIGHT
	[kc.BSPC,  6,  7],
	[ks.RPRN,  5, 14],
	[kc.RBRC,  6, 15],
	[ks.RCBR,  7, 16]
	] in
	
let sub_layers = {
  SYM = [
             kc.SLSH, kc.EQL,  kc.BSLS, kc.GRV,         ks.PLUS, kc.N7,   kc.N8,  kc.N9,
    ks.AMPR, ks.EXLM, ks.PLUS, ks.UNDS, ks.HASH,        kc.MINS, kc.N4,   kc.N5,  kc.N6,  kc.N0,
    ks.PIPE, ks.QUES, kc.MINS, ks.ASTR,                          kc.N1,   kc.N2,  kc.N3,  kc.DOT,
                               XXXX,    XXXX,           XXXX, 
  ],
  NAV = [
             kc.F9,   kc.F10,  kc.F11,  kc.F12,         XXXX,    kc.PGDN, kc.UP,   kc.PGUP,
    kc.F5,   kc.F6,   kc.F7,   kc.F8 ,  XXXX,           kc.HOME, kc.LEFT, kc.DOWN, kc.RGHT,  kc.END,
    kc.F1,   kc.F2,   kc.F3,   kc.F4,                            XXXX,    XXXX,    XXXX,  XXXX,
                              XXXX,    XXXX,            XXXX, 
  ],
  NUM = [
            kc.N9,   kc.N8,   kc.N7,   ks.ASTR,     ks.PLUS, kc.N7,   kc.N8,   kc.N9,
    XXXX,   kc.N6,   kc.N5,   kc.N4,   kc.SLSH,     kc.MINS, kc.N4,   kc.N5,   kc.N6,  XXXX,
   kc.N0,   kc.N3,   kc.N2,   kc.N1,                         kc.N1,   kc.N2,   kc.N3,   kc.DOT,
                              XXXX,    XXXX,        kc.E, 
  ],
} in

let layouts = {
  APTMAK = "WFPKJLUYRSTHBXNAIOZCGDM,.;",
  BIRD =   "CLFPJYOURSNTBKHEIAXWMGD,.;",
  thumbs = [kc.QUOT, kc.SPC, kc.E],
  layers = { NAV = sub_layers.NAV, NUM = sub_layers.NUM, SYM = sub_layers.SYM },
} in

let virtual_keys' =
  combos |> std.array.map (fun c =>
    combo.make cto (std.array.split_at 1 c).right)
in

let physical_key_count = 29 in
let virtual_key_count = std.array.length virtual_keys' in
let key_count = physical_key_count + virtual_key_count in

let rec get_side_of_key_idx = fun key_idx =>
  if key_idx < physical_key_count then
    let right_indices = [4, 5, 6, 7, 13, 14, 15, 16, 17, 22, 23, 24, 25, 28] in
    if std.array.elem key_idx right_indices then 'right else 'left
  else
    let c = std.array.at (key_idx - physical_key_count) combos in
    let unique_sides = (std.array.split_at 1 c).right
      |> std.array.map get_side_of_key_idx
      |> util.array.unique in
    if std.array.length unique_sides > 1 then
      'both
    else
      std.array.first unique_sides
in

let make_hrm = fun key_idx =>
  let hrm_mods =
    let md = hold.reg.mod
  in [
    md.lsft, md.lgui, md.lalt, md.lctl, md.ralt,
    md.ralt, md.rctl, md.lalt, md.rgui, md.rsft,
  ] in

  let hrm_key_indices = [
     8,  9, 10, 11, 12,
    13, 14, 15, 16, 17,
  ] in

  let htb_hrm_base = {
    timeout_ms = 200,
    quick_tap_ms = 150,
    quick_tap_interrupt_ms = 500,
    global_quick_tap_ms = 100,
  } in

  let htb_hrm = fun side => htb_hrm_base & {
    key_interrupts =
      let hrm_key_indices_on_side = hrm_key_indices |>
        std.array.filter (fun i => get_side_of_key_idx i == side) in

      std.array.generate (fun key_idx =>
        let side_of_key_idx = get_side_of_key_idx key_idx in
        if side_of_key_idx == 'both then
          ki.xx
        else if side_of_key_idx != side then
          ki.hr
        else if std.array.elem key_idx hrm_key_indices_on_side then
          ki.tr
        else
          ki.tp
      ) key_count
  } in

  if std.array.elem key_idx hrm_key_indices then
    let mod_idx = util.array.index_of key_idx hrm_key_indices in
    let mod = std.array.at mod_idx hrm_mods in
    let side = get_side_of_key_idx key_idx in
    mod & hold.reg.behavior (htb_hrm side)
  else
    {}
in

let virtual_base = combos |> std.array.map std.array.first in
let virtual_filler = combos |> std.array.map (fun c => XXXX) in

let layer_default =
  let base_keycodes = layouts.APTMAK
    |> std.string.characters
    |> util.array.enumerate
    |> std.array.map (fun { index, value } => tap.reg.kc."%{value}" & make_hrm index)
  in
  
  let thumb_keycodes =
    let htb_thumb = {
      timeout_ms = 200,
      quick_tap_ms = 150,
      quick_tap_interrupt_ms = 500,
      key_interrupts = std.array.replicate key_count ki.hr,
    } in

    layouts.thumbs
    |> util.array.enumerate
    |> std.array.map (fun { index, value } =>
        value 
        & hold.reg.layer (index + 1)
        & hold.reg.behavior htb_thumb)
  in

  base_keycodes @ thumb_keycodes @ virtual_base
in

{
  virtual_keys = virtual_keys',
  layers = [layer_default] @ (
    ["NAV", "SYM", "SYM"]
    |> std.array.map (fun name => layouts.layers."%{name}")
    |> std.array.map (fun layer => layer @ virtual_filler)
  )
}