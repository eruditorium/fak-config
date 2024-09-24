let { ColToRowKey, RowToColKey, .. } = import "fak/keyboard.ncl" in
let { CH552T, .. } = import "fak/mcus.ncl" in

{
  mcu = CH552T,
  matrix = {
    cols = [35, 13, 12, 10, 11, 31, 30 ],
    rows = [33, 34, 15, 16]
  },
  usb_dev = {
    vendor_id = 43962, # 0xABBA
    product_id = 5665,
    product_ver = 1.0, # 0x0100
  },
  keys =
    let C = ColToRowKey in
    let R = RowToColKey in
    [
      C 0 0, C 1 0, R 1 0,   C 2 0, R 2 0, C 3 0, R 3 0, C 4 0, R 4 0, C 5 0, R 5 0, C 6 0, R 6 0,
      C 0 1, C 1 1, R 1 1,   C 2 1, R 2 1, C 3 1, R 3 1, C 4 1, R 4 1, C 5 1, R 5 1, C 6 1, R 6 1,
      C 0 2, C 1 2, R 1 2,   C 2 2, R 2 2, C 3 2, R 3 2, C 4 2, R 4 2, C 5 2, R 5 2, C 6 2, R 6 2,
      #C 0 3, R 0 3, C 1 3,   C 2 3, R 2 3, C 3 3, R 3 3, C 4 3, R 4 3, C 5 3, R 5 3, C 6 3, R 6 3,
      C 0 3,    R 1 3,       C 2 3, R 2 3,    R 3 3,     R 4 3,            R 5 3,   C 6 3,  R 6 3,
    ]
}
