///|
/// Create a level definition from compact data.
/// Grid strings: W=Wall, .=Floor, _=Gap, E=Exit, S=Switch, P=Platform, G=Gem, space=Empty
fn make_level(
  tier : @types.Tier,
  index : Int,
  name : String,
  par : Int,
  px : Int,
  py : Int,
  pl : @types.Layer,
  fg_str : String,
  bg_str : String,
) -> @types.LevelDef {
  let fg = parse_grid(fg_str)
  let bg = parse_grid(bg_str)
  {
    tier,
    index,
    name,
    par_swaps: par,
    fg,
    bg,
    player_start_x: px,
    player_start_y: py,
    player_start_layer: pl,
  }
}

///|
fn parse_grid(s : String) -> Array[@types.Tile] {
  let tiles : Array[@types.Tile] = Array::make(
    @types.grid_cols * @types.grid_rows,
    Empty,
  )
  let mut idx = 0
  for i in 0..<s.length() {
    if idx >= tiles.length() {
      break
    }
    let c = s[i]
    let tile : @types.Tile = match c {
      'W' => Wall
      '.' => Floor
      '_' => Gap
      'E' => Exit
      'S' => Switch(0)
      'T' => Switch(1)
      'P' => Platform
      'G' => Gem
      _ => Empty
    }
    tiles[idx] = tile
    idx = idx + 1
  }
  tiles
}

///|
pub fn get_level(index : Int) -> @types.LevelDef {
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
    _ => level_20()
  }
}

// ===== Tier 1: Reflection (levels 1-7) =====
// Simple layer swaps, learn alignment

///|
fn level_01() -> @types.LevelDef {
  //  12 cols x 8 rows
  make_level(
    Reflection,
    0,
    "First Steps",
    0,
    1,
    6,
    Foreground,
    // Foreground: simple path left to right
    "WWWWWWWWWWWW" +
    "W..........W" +
    "W..........W" +
    "W..........W" +
    "W..........W" +
    "W..........W" +
    "W..........E" +
    "WWWWWWWWWWWW",
    // Background: all walls (not needed yet)
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW",
  )
}

///|
fn level_02() -> @types.LevelDef {
  make_level(
    Reflection,
    1,
    "Two Worlds",
    1,
    1,
    6,
    Foreground,
    "WWWWWWWWWWWW" +
    "W..........W" +
    "W..........W" +
    "W..........W" +
    "W.....WWWWWW" +
    "W.....WWWWWW" +
    "W.....WWWWWW" +
    "WWWWWWWWWWWW",
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWW.....E" +
    "WWWWWW.....W" +
    "WWWWWW.....W" +
    "WWWWWWWWWWWW",
  )
}

///|
fn level_03() -> @types.LevelDef {
  make_level(
    Reflection,
    2,
    "The Gap",
    2,
    1,
    6,
    Foreground,
    "WWWWWWWWWWWW" +
    "W..........W" +
    "W..........W" +
    "W....__....W" +
    "W....__....W" +
    "W..........W" +
    "W..........E" +
    "WWWWWWWWWWWW",
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWW....WWWW" +
    "WWWW....WWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW",
  )
}

///|
fn level_04() -> @types.LevelDef {
  make_level(
    Reflection,
    3,
    "Mirror Path",
    2,
    1,
    1,
    Foreground,
    "WWWWWWWWWWWW" +
    "W....WWWWWWW" +
    "W....WWWWWWW" +
    "W....WWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW",
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWW.....W" +
    "WWWWWW.....W" +
    "WWWWWW.....E" +
    "WWWWWWWWWWWW",
  )
}

///|
fn level_05() -> @types.LevelDef {
  make_level(
    Reflection,
    4,
    "Zig Zag",
    3,
    1,
    1,
    Foreground,
    "WWWWWWWWWWWW" +
    "W....WWWWWWW" +
    "W....WWWWWWW" +
    "W....WWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW",
    "WWWWWWWWWWWW" +
    "WWWWWW....WW" +
    "WWWWWW....WW" +
    "WWWWWW....WW" +
    "WWWWWW....WW" +
    "WW....WWWWWW" +
    "WW....WWWWEW" +
    "WWWWWWWWWWWW",
  )
}

///|
fn level_06() -> @types.LevelDef {
  make_level(
    Reflection,
    5,
    "Gem Hunt",
    2,
    1,
    6,
    Foreground,
    "WWWWWWWWWWWW" +
    "W..........W" +
    "W..........W" +
    "W..WWWWWW..W" +
    "W..WWWWWW..W" +
    "W..........W" +
    "W..........E" +
    "WWWWWWWWWWWW",
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWW......WWW" +
    "WWW..G...WWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW",
  )
}

///|
fn level_07() -> @types.LevelDef {
  make_level(
    Reflection,
    6,
    "Crossroads",
    4,
    1,
    1,
    Foreground,
    "WWWWWWWWWWWW" +
    "W..WWWWWW..W" +
    "W..WWWWWW..W" +
    "W..........W" +
    "W..........W" +
    "W..WWWWWW..W" +
    "W..WWWWWW..W" +
    "WWWWWWWWWWWW",
    "WWWWWWWWWWWW" +
    "WWWW....WWWW" +
    "WWWW....WWWW" +
    "WWWW....WWWW" +
    "WWWW....WWWW" +
    "WWWW....WWWW" +
    "WWWW....EWWW" +
    "WWWWWWWWWWWW",
  )
}

// ===== Tier 2: Overlap (levels 8-14) =====
// Merge mechanic, switches

///|
fn level_08() -> @types.LevelDef {
  make_level(
    Overlap,
    7,
    "First Merge",
    2,
    1,
    6,
    Foreground,
    "WWWWWWWWWWWW" +
    "W..........W" +
    "W..........W" +
    "W.....__...W" +
    "W.....__...W" +
    "W..........W" +
    "W..........W" +
    "WWWWWWWWWWWW",
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWW..EWWWW" +
    "WWWWW..WWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW",
  )
}

///|
fn level_09() -> @types.LevelDef {
  make_level(
    Overlap,
    8,
    "Switch It",
    3,
    1,
    6,
    Foreground,
    "WWWWWWWWWWWW" +
    "W..........W" +
    "W..........W" +
    "W...SWWWWW.W" +
    "W....WWWWW.W" +
    "W..........W" +
    "W..........W" +
    "WWWWWWWWWWWW",
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWP.....EW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW",
  )
}

///|
fn level_10() -> @types.LevelDef {
  make_level(
    Overlap,
    9,
    "Bridge Builder",
    3,
    1,
    1,
    Foreground,
    "WWWWWWWWWWWW" +
    "W....______W" +
    "W....______W" +
    "W....______W" +
    "W..........W" +
    "W..........W" +
    "W..........W" +
    "WWWWWWWWWWWW",
    "WWWWWWWWWWWW" +
    "WWWWW......E" +
    "WWWWW......W" +
    "WWWWW......W" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW",
  )
}

///|
fn level_11() -> @types.LevelDef {
  make_level(
    Overlap,
    10,
    "Twin Switches",
    4,
    1,
    6,
    Foreground,
    "WWWWWWWWWWWW" +
    "W..........W" +
    "W..S.......W" +
    "W..WWWWWWW.W" +
    "W..........W" +
    "W.......T..W" +
    "W..........W" +
    "WWWWWWWWWWWW",
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWW.P.P..EWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW",
  )
}

///|
fn level_12() -> @types.LevelDef {
  make_level(
    Overlap,
    11,
    "Layer Maze",
    4,
    1,
    1,
    Foreground,
    "WWWWWWWWWWWW" +
    "W...WW.....W" +
    "W...WW.....W" +
    "W..........W" +
    "W..........W" +
    "W.....WW...W" +
    "W.....WW...W" +
    "WWWWWWWWWWWW",
    "WWWWWWWWWWWW" +
    "W.....WW...W" +
    "W.....WW...W" +
    "W..........W" +
    "W..........W" +
    "W...WW.....W" +
    "W...WW....EW" +
    "WWWWWWWWWWWW",
  )
}

///|
fn level_13() -> @types.LevelDef {
  make_level(
    Overlap,
    12,
    "Gem Bridge",
    4,
    1,
    6,
    Foreground,
    "WWWWWWWWWWWW" +
    "W..........W" +
    "W..........W" +
    "W..___WW...W" +
    "W..___WW...W" +
    "W..........W" +
    "W..........W" +
    "WWWWWWWWWWWW",
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWW...GW..EW" +
    "WWW....WWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW",
  )
}

///|
fn level_14() -> @types.LevelDef {
  make_level(
    Overlap,
    13,
    "Overlap Master",
    5,
    1,
    1,
    Foreground,
    "WWWWWWWWWWWW" +
    "W....______W" +
    "W....______W" +
    "W..S.______W" +
    "WWWWWW.....W" +
    "W..........W" +
    "W..........W" +
    "WWWWWWWWWWWW",
    "WWWWWWWWWWWW" +
    "WWWWWP....EW" +
    "WWWWWP.....W" +
    "WWWWWP.....W" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW",
  )
}

// ===== Tier 3: Illusion (levels 15-20) =====
// Complex multi-swap puzzles

///|
fn level_15() -> @types.LevelDef {
  make_level(
    Illusion,
    14,
    "Perspective",
    5,
    1,
    6,
    Foreground,
    "WWWWWWWWWWWW" +
    "W..WWWW....W" +
    "W..WWWW....W" +
    "W..........W" +
    "W..........W" +
    "W....WWWW..W" +
    "W....WWWW..W" +
    "WWWWWWWWWWWW",
    "WWWWWWWWWWWW" +
    "W....WWWW..W" +
    "W....WWWW..W" +
    "W..........W" +
    "W..........W" +
    "W..WWWW....W" +
    "W..WWWW...EW" +
    "WWWWWWWWWWWW",
  )
}

///|
fn level_16() -> @types.LevelDef {
  make_level(
    Illusion,
    15,
    "Double Cross",
    6,
    1,
    1,
    Foreground,
    "WWWWWWWWWWWW" +
    "W...__..WW.W" +
    "W...__..WW.W" +
    "W.....S....W" +
    "W..........W" +
    "W..WW..__..W" +
    "W..WW..__..W" +
    "WWWWWWWWWWWW",
    "WWWWWWWWWWWW" +
    "W...PP..WW.W" +
    "W...PP..WW.W" +
    "W..........W" +
    "W..........W" +
    "W..WW..PP.EW" +
    "W..WW..PP..W" +
    "WWWWWWWWWWWW",
  )
}

///|
fn level_17() -> @types.LevelDef {
  make_level(
    Illusion,
    16,
    "Spiral",
    6,
    1,
    1,
    Foreground,
    "WWWWWWWWWWWW" +
    "W..........W" +
    "W.WWWWWWWW.W" +
    "W.W......W.W" +
    "W.W.WWWW.W.W" +
    "W.W......W.W" +
    "W.WWWW_WEW.W" +
    "WWWWWWWWWWWW",
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWG.WWWWW" +
    "WWWWWWWWWWWW" +
    "WWWWWWWWWWWW",
  )
}

///|
fn level_18() -> @types.LevelDef {
  make_level(
    Illusion,
    17,
    "Mirage",
    7,
    1,
    1,
    Foreground,
    "WWWWWWWWWWWW" +
    "W....WW....W" +
    "W.S..WW..T.W" +
    "W....__..__W" +
    "W__..__..__W" +
    "W__........W" +
    "W..........W" +
    "WWWWWWWWWWWW",
    "WWWWWWWWWWWW" +
    "W....WW....W" +
    "W....WW....W" +
    "W..PP..PP..W" +
    "WPP..PP....W" +
    "WPP........W" +
    "W.........EW" +
    "WWWWWWWWWWWW",
  )
}

///|
fn level_19() -> @types.LevelDef {
  make_level(
    Illusion,
    18,
    "Labyrinth",
    8,
    1,
    1,
    Foreground,
    "WWWWWWWWWWWW" +
    "W..WW__WW..W" +
    "W..WW__WW..W" +
    "W...S......W" +
    "W......T...W" +
    "W..WW__WW..W" +
    "W..WW__WW..W" +
    "WWWWWWWWWWWW",
    "WWWWWWWWWWWW" +
    "W..WWPPWW..W" +
    "W..WWPPWW..W" +
    "W..........W" +
    "W..........W" +
    "W..WWPPWW.EW" +
    "W..WWPPWW..W" +
    "WWWWWWWWWWWW",
  )
}

///|
fn level_20() -> @types.LevelDef {
  make_level(
    Illusion,
    19,
    "Final Illusion",
    10,
    1,
    6,
    Foreground,
    "WWWWWWWWWWWW" +
    "W..WW__WW..W" +
    "W..WW__WW..W" +
    "W..S.......W" +
    "W.......T..W" +
    "W..WW__WW..W" +
    "W..WW__WW..W" +
    "WWWWWWWWWWWW",
    "WWWWWWWWWWWW" +
    "W..WWPPWWG.W" +
    "W..WWPPWW..W" +
    "W..........W" +
    "W..........W" +
    "W..WWPPWW..W" +
    "W..WWPPWW.EW" +
    "WWWWWWWWWWWW",
  )
}
