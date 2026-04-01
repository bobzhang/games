///|
/// Get level data by 0-based index
pub fn get_level(index : Int) -> @types.LevelData {
  match index {
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
    19 => level_20()
    20 => level_21()
    21 => level_22()
    22 => level_23()
    23 => level_24()
    24 => level_25()
    _ => level_01()
  }
}

///|
/// Get tier name for display
pub fn tier_name(tier : Int) -> String {
  match tier {
    1 => "Basics"
    2 => "Mountains"
    3 => "Expert"
    _ => "Unknown"
  }
}

///|
/// Get number of levels in a tier
pub fn tier_level_count(tier : Int) -> Int {
  match tier {
    1 => @types.tier1_count
    2 => @types.tier2_count
    3 => @types.tier3_count
    _ => 0
  }
}

///|
/// Get the starting index (0-based) for a tier
pub fn tier_start_index(tier : Int) -> Int {
  match tier {
    1 => 0
    2 => @types.tier1_count
    3 => @types.tier1_count + @types.tier2_count
    _ => 0
  }
}
