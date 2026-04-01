///|
pub fn get_level(id : Int) -> @types.LevelDef {
  match id {
    0 => level_01()
    1 => level_02()
    2 => level_03()
    3 => level_04()
    4 => level_05()
    5 => level_06()
    6 => level_07()
    7 => level_08()
    8 => level_09()
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
    _ => level_20()
  }
}

///|
pub fn get_tier_for_level(id : Int) -> @types.Tier {
  if id < 7 {
    Beginner
  } else if id < 14 {
    Intermediate
  } else {
    Advanced
  }
}

///|
pub fn get_tier_start(tier : Int) -> Int {
  match tier {
    0 => 0
    1 => 7
    _ => 14
  }
}

///|
pub fn get_tier_count(tier : Int) -> Int {
  match tier {
    0 => 7
    1 => 7
    _ => 6
  }
}
