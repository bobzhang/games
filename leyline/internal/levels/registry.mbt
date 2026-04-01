///|
pub fn get_level(id : Int) -> @types.LevelDef? {
  match id {
    0 => Some(level_0())
    1 => Some(level_1())
    2 => Some(level_2())
    3 => Some(level_3())
    4 => Some(level_4())
    5 => Some(level_5())
    6 => Some(level_6())
    7 => Some(level_7())
    8 => Some(level_8())
    9 => Some(level_9())
    10 => Some(level_10())
    11 => Some(level_11())
    12 => Some(level_12())
    13 => Some(level_13())
    14 => Some(level_14())
    15 => Some(level_15())
    16 => Some(level_16())
    17 => Some(level_17())
    18 => Some(level_18())
    19 => Some(level_19())
    _ => None
  }
}

///|
pub fn level_name(id : Int) -> String {
  match get_level(id) {
    Some(def) => def.name
    None => "Unknown"
  }
}

///|
pub fn all_level_defs() -> Array[@types.LevelDef] {
  let defs : Array[@types.LevelDef] = []
  for i in 0..<@types.total_levels {
    match get_level(i) {
      Some(def) => defs.push(def)
      None => ()
    }
  }
  defs
}
