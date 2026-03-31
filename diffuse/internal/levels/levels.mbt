///|
fn build_level(
  name : String,
  tier : @types.Tier,
  par : Int,
  cyan_budget : Int,
  magenta_budget : Int,
  yellow_budget : Int,
  layout : Array[(Int, Int, @types.TileKind, @types.InkColor)]
) -> @types.Level {
  let grid = @types.make_grid(@types.grid_width, @types.grid_height)
  for i in 0..<layout.length() {
    let (col, row, kind, target) = layout[i]
    match kind {
      Target => @types.grid_set(grid, col, row, @types.make_target_tile(target))
      Barrier => @types.grid_set(grid, col, row, @types.make_tile(Barrier))
      Paper => () // already paper
    }
  }
  {
    grid,
    budget: { cyan: cyan_budget, magenta: magenta_budget, yellow: yellow_budget },
    par_drops: par,
    tier,
    name,
  }
}

///|
let e : @types.InkColor = { c: false, m: false, y: false }

// ============================================================
// TIER 1: WATERCOLOR (Levels 0-7) - Single colors, learn spreading
// ============================================================

///|
fn level_00() -> @types.Level {
  // "First Drop" - Place 1 cyan drop, spread to hit 1 target
  build_level(
    "First Drop", Watercolor, 1, 1, 0, 0,
    [
      (5, 4, Target, @types.ink_cyan()),
    ],
  )
}

///|
fn level_01() -> @types.Level {
  // "Two Targets" - Cyan drop spreads to hit 2 adjacent targets
  build_level(
    "Two Targets", Watercolor, 1, 1, 0, 0,
    [
      (4, 3, Target, @types.ink_cyan()),
      (6, 3, Target, @types.ink_cyan()),
    ],
  )
}

///|
fn level_02() -> @types.Level {
  // "Magenta Wave" - Use magenta to reach targets
  build_level(
    "Magenta Wave", Watercolor, 1, 0, 1, 0,
    [
      (3, 4, Target, @types.ink_magenta()),
      (7, 4, Target, @types.ink_magenta()),
    ],
  )
}

///|
fn level_03() -> @types.Level {
  // "Yellow Path" - Spread yellow across a line
  build_level(
    "Yellow Path", Watercolor, 1, 0, 0, 1,
    [
      (2, 3, Target, @types.ink_yellow()),
      (4, 3, Target, @types.ink_yellow()),
      (6, 3, Target, @types.ink_yellow()),
    ],
  )
}

///|
fn level_04() -> @types.Level {
  // "Wall Block" - Barrier blocks spread, need to go around
  let b = e // barrier marker
  build_level(
    "Wall Block", Watercolor, 2, 2, 0, 0,
    [
      (5, 2, Barrier, b), (5, 3, Barrier, b), (5, 4, Barrier, b), (5, 5, Barrier, b),
      (3, 3, Target, @types.ink_cyan()),
      (7, 3, Target, @types.ink_cyan()),
    ],
  )
}

///|
fn level_05() -> @types.Level {
  // "Squeeze Through" - Narrow gap in barrier wall
  let b = e
  build_level(
    "Squeeze Through", Watercolor, 1, 1, 0, 0,
    [
      (4, 1, Barrier, b), (4, 2, Barrier, b), (4, 3, Barrier, b),
      (4, 5, Barrier, b), (4, 6, Barrier, b),
      (6, 3, Target, @types.ink_cyan()),
      (7, 4, Target, @types.ink_cyan()),
    ],
  )
}

///|
fn level_06() -> @types.Level {
  // "Two Colors" - First level using 2 different single colors
  build_level(
    "Two Colors", Watercolor, 2, 1, 1, 0,
    [
      (3, 3, Target, @types.ink_cyan()),
      (7, 3, Target, @types.ink_magenta()),
    ],
  )
}

///|
fn level_07() -> @types.Level {
  // "Three Singles" - All three primary inks
  build_level(
    "Three Singles", Watercolor, 3, 1, 1, 1,
    [
      (2, 4, Target, @types.ink_cyan()),
      (5, 4, Target, @types.ink_magenta()),
      (8, 4, Target, @types.ink_yellow()),
    ],
  )
}

// ============================================================
// TIER 2: PIGMENT (Levels 8-16) - 2-color mixing
// ============================================================

///|
fn level_08() -> @types.Level {
  // "Make Blue" - Mix cyan + magenta on target
  build_level(
    "Make Blue", Pigment, 2, 1, 1, 0,
    [
      (5, 4, Target, @types.ink_blue()),
    ],
  )
}

///|
fn level_09() -> @types.Level {
  // "Make Green" - Mix cyan + yellow
  build_level(
    "Make Green", Pigment, 2, 1, 0, 1,
    [
      (5, 4, Target, @types.ink_green()),
    ],
  )
}

///|
fn level_10() -> @types.Level {
  // "Make Red" - Mix magenta + yellow
  build_level(
    "Make Red", Pigment, 2, 0, 1, 1,
    [
      (5, 4, Target, @types.ink_red()),
    ],
  )
}

///|
fn level_11() -> @types.Level {
  // "Blue and Cyan" - One target needs blue, another needs cyan
  let b = e
  build_level(
    "Blue and Cyan", Pigment, 3, 2, 1, 0,
    [
      (5, 2, Barrier, b), (5, 3, Barrier, b), (5, 4, Barrier, b),
      (5, 5, Barrier, b), (5, 6, Barrier, b),
      (3, 4, Target, @types.ink_cyan()),
      (7, 4, Target, @types.ink_blue()),
    ],
  )
}

///|
fn level_12() -> @types.Level {
  // "Color Corridor" - Narrow corridor, place inks carefully
  let b = e
  build_level(
    "Color Corridor", Pigment, 2, 1, 1, 0,
    [
      (3, 2, Barrier, b), (4, 2, Barrier, b), (5, 2, Barrier, b),
      (6, 2, Barrier, b), (7, 2, Barrier, b),
      (3, 5, Barrier, b), (4, 5, Barrier, b), (5, 5, Barrier, b),
      (6, 5, Barrier, b), (7, 5, Barrier, b),
      (5, 3, Target, @types.ink_blue()),
      (5, 4, Target, @types.ink_blue()),
    ],
  )
}

///|
fn level_13() -> @types.Level {
  // "Split Colors" - Two targets need different mixed colors
  let b = e
  build_level(
    "Split Colors", Pigment, 4, 1, 1, 1,
    [
      (5, 1, Barrier, b), (5, 2, Barrier, b), (5, 3, Barrier, b),
      (5, 4, Barrier, b), (5, 5, Barrier, b), (5, 6, Barrier, b),
      (3, 3, Target, @types.ink_green()),
      (7, 3, Target, @types.ink_red()),
    ],
  )
}

///|
fn level_14() -> @types.Level {
  // "Precision Drop" - Tight space, can't waste drops
  let b = e
  build_level(
    "Precision Drop", Pigment, 2, 1, 1, 0,
    [
      (3, 2, Barrier, b), (4, 2, Barrier, b), (6, 2, Barrier, b), (7, 2, Barrier, b),
      (3, 6, Barrier, b), (4, 6, Barrier, b), (6, 6, Barrier, b), (7, 6, Barrier, b),
      (3, 3, Barrier, b), (3, 4, Barrier, b), (3, 5, Barrier, b),
      (7, 3, Barrier, b), (7, 4, Barrier, b), (7, 5, Barrier, b),
      (5, 4, Target, @types.ink_blue()),
    ],
  )
}

///|
fn level_15() -> @types.Level {
  // "Island Targets" - Targets surrounded by barriers with single openings
  let b = e
  build_level(
    "Island Targets", Pigment, 3, 1, 1, 1,
    [
      // Left island
      (1, 2, Barrier, b), (2, 2, Barrier, b), (3, 2, Barrier, b),
      (1, 4, Barrier, b), (2, 4, Barrier, b), (3, 4, Barrier, b),
      (1, 3, Barrier, b),
      (2, 3, Target, @types.ink_green()),
      // Right island
      (6, 2, Barrier, b), (7, 2, Barrier, b), (8, 2, Barrier, b),
      (6, 4, Barrier, b), (7, 4, Barrier, b), (8, 4, Barrier, b),
      (8, 3, Barrier, b),
      (7, 3, Target, @types.ink_red()),
    ],
  )
}

///|
fn level_16() -> @types.Level {
  // "Triple Mix" - Three targets, each a different 2-color mix
  let b = e
  build_level(
    "Triple Mix", Pigment, 4, 1, 1, 1,
    [
      (3, 1, Barrier, b), (3, 2, Barrier, b), (3, 3, Barrier, b),
      (3, 4, Barrier, b), (3, 5, Barrier, b), (3, 6, Barrier, b),
      (7, 1, Barrier, b), (7, 2, Barrier, b), (7, 3, Barrier, b),
      (7, 4, Barrier, b), (7, 5, Barrier, b), (7, 6, Barrier, b),
      (1, 4, Target, @types.ink_blue()),
      (5, 4, Target, @types.ink_green()),
      (9, 4, Target, @types.ink_red()),
    ],
  )
}

// ============================================================
// TIER 3: PALETTE (Levels 17-24) - 3-color mixing, complex
// ============================================================

///|
fn level_17() -> @types.Level {
  // "Make Black" - All 3 inks on one target
  build_level(
    "Make Black", Palette, 3, 1, 1, 1,
    [
      (5, 4, Target, @types.ink_black()),
    ],
  )
}

///|
fn level_18() -> @types.Level {
  // "Black and Primary" - Need black + a primary on separate targets
  let b = e
  build_level(
    "Black and Primary", Palette, 4, 2, 1, 1,
    [
      (5, 1, Barrier, b), (5, 2, Barrier, b), (5, 3, Barrier, b),
      (5, 5, Barrier, b), (5, 6, Barrier, b),
      (3, 4, Target, @types.ink_black()),
      (7, 4, Target, @types.ink_cyan()),
    ],
  )
}

///|
fn level_19() -> @types.Level {
  // "Spectrum Line" - Targets in a row need: C, G, Y
  build_level(
    "Spectrum Line", Palette, 3, 1, 0, 1,
    [
      (3, 4, Target, @types.ink_cyan()),
      (5, 4, Target, @types.ink_green()),
      (7, 4, Target, @types.ink_yellow()),
    ],
  )
}

///|
fn level_20() -> @types.Level {
  // "Four Corners" - 4 corners need 4 different colors
  let b = e
  build_level(
    "Four Corners", Palette, 5, 2, 2, 1,
    [
      (4, 2, Barrier, b), (5, 2, Barrier, b), (6, 2, Barrier, b),
      (4, 5, Barrier, b), (5, 5, Barrier, b), (6, 5, Barrier, b),
      (4, 3, Barrier, b), (4, 4, Barrier, b),
      (6, 3, Barrier, b), (6, 4, Barrier, b),
      (2, 2, Target, @types.ink_cyan()),
      (8, 2, Target, @types.ink_blue()),
      (2, 5, Target, @types.ink_green()),
      (8, 5, Target, @types.ink_red()),
    ],
  )
}

///|
fn level_21() -> @types.Level {
  // "Maze Mix" - Navigate colors through maze barriers
  let b = e
  build_level(
    "Maze Mix", Palette, 4, 1, 1, 1,
    [
      (2, 1, Barrier, b), (2, 2, Barrier, b), (2, 3, Barrier, b),
      (4, 3, Barrier, b), (4, 4, Barrier, b), (4, 5, Barrier, b),
      (6, 1, Barrier, b), (6, 2, Barrier, b), (6, 3, Barrier, b),
      (8, 3, Barrier, b), (8, 4, Barrier, b), (8, 5, Barrier, b),
      (3, 5, Target, @types.ink_blue()),
      (5, 2, Target, @types.ink_green()),
      (7, 5, Target, @types.ink_black()),
    ],
  )
}

///|
fn level_22() -> @types.Level {
  // "Color Wheel" - Targets arranged in circle need different colors
  let b = e
  build_level(
    "Color Wheel", Palette, 5, 2, 2, 2,
    [
      (5, 3, Barrier, b), (5, 4, Barrier, b),
      (4, 1, Target, @types.ink_cyan()),
      (7, 2, Target, @types.ink_blue()),
      (8, 4, Target, @types.ink_magenta()),
      (6, 6, Target, @types.ink_red()),
      (3, 6, Target, @types.ink_yellow()),
      (2, 3, Target, @types.ink_green()),
    ],
  )
}

///|
fn level_23() -> @types.Level {
  // "Fortress" - Central target surrounded by barriers, tight approaches
  let b = e
  build_level(
    "Fortress", Palette, 4, 1, 1, 1,
    [
      (3, 2, Barrier, b), (4, 2, Barrier, b), (5, 2, Barrier, b),
      (6, 2, Barrier, b), (7, 2, Barrier, b),
      (3, 6, Barrier, b), (4, 6, Barrier, b), (5, 6, Barrier, b),
      (6, 6, Barrier, b), (7, 6, Barrier, b),
      (3, 3, Barrier, b), (3, 4, Barrier, b), (3, 5, Barrier, b),
      (7, 3, Barrier, b), (7, 4, Barrier, b), (7, 5, Barrier, b),
      (5, 4, Target, @types.ink_black()),
      (4, 4, Target, @types.ink_blue()),
      (6, 4, Target, @types.ink_red()),
    ],
  )
}

///|
fn level_24() -> @types.Level {
  // "Grand Palette" - Final challenge: many targets, mixed colors, complex barriers
  let b = e
  build_level(
    "Grand Palette", Palette, 6, 2, 2, 2,
    [
      // Barrier cross
      (5, 0, Barrier, b), (5, 1, Barrier, b),
      (5, 6, Barrier, b), (5, 7, Barrier, b),
      (0, 4, Barrier, b), (1, 4, Barrier, b),
      (8, 4, Barrier, b), (9, 4, Barrier, b),
      // Inner walls
      (3, 2, Barrier, b), (3, 3, Barrier, b),
      (7, 2, Barrier, b), (7, 3, Barrier, b),
      (3, 5, Barrier, b), (3, 6, Barrier, b),
      (7, 5, Barrier, b), (7, 6, Barrier, b),
      // Targets - all 7 colors!
      (2, 1, Target, @types.ink_cyan()),
      (8, 1, Target, @types.ink_magenta()),
      (2, 6, Target, @types.ink_yellow()),
      (8, 6, Target, @types.ink_blue()),
      (1, 3, Target, @types.ink_green()),
      (9, 3, Target, @types.ink_red()),
      (5, 4, Target, @types.ink_black()),
    ],
  )
}

///|
pub fn get_level(index : Int) -> @types.Level {
  match index {
    0 => level_00()
    1 => level_01()
    2 => level_02()
    3 => level_03()
    4 => level_04()
    5 => level_05()
    6 => level_06()
    7 => level_07()
    8 => level_08()
    9 => level_09()
    10 => level_10()
    11 => level_11()
    12 => level_12()
    13 => level_13()
    14 => level_14()
    15 => level_15()
    16 => level_16()
    17 => level_17()
    18 => level_18()
    19 => level_19()
    20 => level_20()
    21 => level_21()
    22 => level_22()
    23 => level_23()
    _ => level_24()
  }
}

///|
pub fn load_level_into_game(game : @types.Game, index : Int) -> Unit {
  let level = get_level(index)
  // Deep copy the grid
  let new_tiles = @types.clone_tiles(level.grid.tiles)
  game.grid = {
    width: level.grid.width,
    height: level.grid.height,
    tiles: new_tiles,
  }
  game.budget = @types.clone_budget(level.budget)
  game.par_drops = level.par_drops
  game.drops_used = 0
  game.turn = 0
  game.play_state = Placing
  game.level_name = level.name
  game.history.clear()
  game.spread_timer = 0.0
  game.show_preview = true
}
