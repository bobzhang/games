///|
/// Returns a level by global index (0-29).
pub fn get_level(index : Int) -> @types.Level {
  match index {
    0 => level_1()
    1 => level_2()
    2 => level_3()
    3 => level_4()
    4 => level_5()
    5 => level_6()
    6 => level_7()
    7 => level_8()
    8 => level_9()
    9 => level_10()
    10 => level_11()
    11 => level_12()
    12 => level_13()
    13 => level_14()
    14 => level_15()
    15 => level_16()
    16 => level_17()
    17 => level_18()
    18 => level_19()
    19 => level_20()
    20 => level_21()
    21 => level_22()
    22 => level_23()
    23 => level_24()
    24 => level_25()
    25 => level_26()
    26 => level_27()
    27 => level_28()
    28 => level_29()
    29 => level_30()
    _ => level_1()
  }
}

///|
/// World names.
pub fn world_name(world : Int) -> String {
  match world {
    0 => "Lines"
    1 => "Splits"
    2 => "Gates"
    _ => "Unknown"
  }
}

///|
/// Level display name.
pub fn level_name(world : Int, level : Int) -> String {
  let num = level + 1
  match world {
    0 => "\{num}"
    1 => "\{num}"
    2 => "\{num}"
    _ => "\{num}"
  }
}
