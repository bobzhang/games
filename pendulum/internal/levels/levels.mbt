///|
fn build_level(
  id : Int,
  tier : @types.Tier,
  name : String,
  anchor : @types.Vec2i,
  goal : @types.Vec2i,
  pegs : Array[@types.Vec2i],
  walls : Array[@types.Vec2i],
  collectibles : Array[@types.Vec2i],
  par_ticks : Int,
  rope_length : Int,
) -> @types.Level {
  let grid = @types.new_empty_grid()
  grid[anchor.y][anchor.x] = Anchor
  grid[goal.y][goal.x] = Goal
  for i = 0; i < pegs.length(); i = i + 1 {
    grid[pegs[i].y][pegs[i].x] = Peg
  }
  for i = 0; i < walls.length(); i = i + 1 {
    grid[walls[i].y][walls[i].x] = Wall
  }
  for i = 0; i < collectibles.length(); i = i + 1 {
    grid[collectibles[i].y][collectibles[i].x] = Collectible
  }
  {
    id,
    tier,
    name,
    grid,
    anchor_pos: anchor,
    goal_pos: goal,
    pegs,
    walls,
    collectibles,
    par_ticks,
    rope_length,
  }
}

///|
fn p(x : Int, y : Int) -> @types.Vec2i {
  @types.vec2i(x, y)
}

// ============================================================
// TIER 1: SWING (8 levels) - Simple pendulum, no pegs
// ============================================================

///|
fn level_1_1() -> @types.Level {
  build_level(0, Swing, "First Swing", p(8, 1), p(12, 6), [], [], [], 15, 5)
}

///|
fn level_1_2() -> @types.Level {
  build_level(
    1,
    Swing,
    "Reach Right",
    p(6, 1),
    p(13, 7),
    [],
    [],
    [p(10, 5)],
    18,
    6,
  )
}

///|
fn level_1_3() -> @types.Level {
  build_level(
    2,
    Swing,
    "Reach Left",
    p(10, 1),
    p(3, 7),
    [],
    [],
    [p(6, 5)],
    18,
    6,
  )
}

///|
fn level_1_4() -> @types.Level {
  build_level(3, Swing, "Long Drop", p(8, 0), p(14, 9), [], [], [], 25, 8)
}

///|
fn level_1_5() -> @types.Level {
  build_level(4, Swing, "Cut Launch", p(8, 2), p(15, 2), [], [], [], 12, 5)
}

///|
fn level_1_6() -> @types.Level {
  build_level(5, Swing, "High Arc", p(4, 1), p(12, 4), [], [], [p(8, 6)], 20, 7)
}

///|
fn level_1_7() -> @types.Level {
  build_level(
    6,
    Swing,
    "Wall Gap",
    p(8, 1),
    p(14, 8),
    [],
    [p(11, 4), p(11, 5), p(11, 6), p(11, 7), p(11, 8)],
    [],
    16,
    6,
  )
}

///|
fn level_1_8() -> @types.Level {
  build_level(
    7,
    Swing,
    "Precision Cut",
    p(5, 0),
    p(13, 0),
    [],
    [p(9, 2), p(10, 2), p(11, 2)],
    [p(8, 4)],
    14,
    6,
  )
}

// ============================================================
// TIER 2: WRAP (9 levels) - Pegs that wrap rope
// ============================================================

///|
fn level_2_1() -> @types.Level {
  build_level(8, Wrap, "First Peg", p(4, 1), p(10, 6), [p(7, 4)], [], [], 18, 6)
}

///|
fn level_2_2() -> @types.Level {
  build_level(
    9,
    Wrap,
    "Double Peg",
    p(3, 1),
    p(13, 8),
    [p(6, 4), p(10, 6)],
    [],
    [],
    22,
    7,
  )
}

///|
fn level_2_3() -> @types.Level {
  build_level(
    10,
    Wrap,
    "Tight Wrap",
    p(8, 1),
    p(12, 4),
    [p(10, 3)],
    [],
    [p(6, 5)],
    16,
    5,
  )
}

///|
fn level_2_4() -> @types.Level {
  build_level(
    11,
    Wrap,
    "Zigzag",
    p(3, 0),
    p(14, 10),
    [p(6, 3), p(10, 6), p(13, 8)],
    [],
    [],
    28,
    7,
  )
}

///|
fn level_2_5() -> @types.Level {
  build_level(
    12,
    Wrap,
    "Wrap Around",
    p(8, 0),
    p(5, 3),
    [p(6, 4), p(8, 5)],
    [p(3, 5), p(3, 6), p(3, 7)],
    [p(10, 7)],
    20,
    6,
  )
}

///|
fn level_2_6() -> @types.Level {
  build_level(
    13,
    Wrap,
    "Peg Cascade",
    p(2, 1),
    p(14, 9),
    [p(5, 3), p(8, 5), p(11, 7)],
    [],
    [p(7, 4), p(10, 6)],
    26,
    6,
  )
}

///|
fn level_2_7() -> @types.Level {
  build_level(
    14,
    Wrap,
    "Walled Wrap",
    p(8, 1),
    p(14, 8),
    [p(10, 4)],
    [p(12, 3), p(12, 4), p(12, 5), p(12, 6)],
    [],
    20,
    6,
  )
}

///|
fn level_2_8() -> @types.Level {
  build_level(
    15,
    Wrap,
    "Three Peg Climb",
    p(12, 1),
    p(3, 9),
    [p(9, 3), p(6, 5), p(4, 7)],
    [],
    [p(10, 5)],
    24,
    6,
  )
}

///|
fn level_2_9() -> @types.Level {
  build_level(
    16,
    Wrap,
    "Spiral Down",
    p(8, 0),
    p(8, 10),
    [p(6, 3), p(10, 5), p(7, 7)],
    [],
    [p(11, 4), p(5, 6)],
    30,
    6,
  )
}

// ============================================================
// TIER 3: LAUNCH (8 levels) - Complex peg + precise cut
// ============================================================

///|
fn level_3_1() -> @types.Level {
  build_level(
    17,
    Launch,
    "Launch Pad",
    p(4, 1),
    p(15, 1),
    [p(7, 4)],
    [p(10, 2), p(10, 3)],
    [],
    16,
    6,
  )
}

///|
fn level_3_2() -> @types.Level {
  build_level(
    18,
    Launch,
    "Over the Wall",
    p(3, 1),
    p(14, 5),
    [p(6, 3), p(9, 4)],
    [p(11, 2), p(11, 3), p(11, 4), p(11, 5), p(11, 6)],
    [],
    20,
    6,
  )
}

///|
fn level_3_3() -> @types.Level {
  build_level(
    19,
    Launch,
    "Thread Needle",
    p(4, 0),
    p(14, 8),
    [p(7, 3)],
    [p(10, 4), p(10, 5), p(10, 7), p(10, 8), p(10, 9)],
    [p(8, 5)],
    18,
    5,
  )
}

///|
fn level_3_4() -> @types.Level {
  build_level(
    20,
    Launch,
    "Ricochet Path",
    p(8, 0),
    p(2, 10),
    [p(6, 3), p(10, 5)],
    [p(4, 6), p(4, 7), p(4, 8), p(13, 4), p(13, 5), p(13, 6)],
    [p(12, 3), p(5, 9)],
    24,
    6,
  )
}

///|
fn level_3_5() -> @types.Level {
  build_level(
    21,
    Launch,
    "Double Launch",
    p(3, 1),
    p(15, 9),
    [p(6, 3), p(10, 5), p(13, 7)],
    [p(8, 1), p(8, 2), p(8, 3)],
    [p(7, 4)],
    22,
    6,
  )
}

///|
fn level_3_6() -> @types.Level {
  build_level(
    22,
    Launch,
    "Gauntlet",
    p(2, 0),
    p(14, 10),
    [p(5, 3), p(8, 5), p(11, 7)],
    [p(7, 2), p(7, 3), p(10, 4), p(10, 5), p(13, 6), p(13, 7)],
    [p(6, 4), p(9, 6), p(12, 8)],
    28,
    6,
  )
}

///|
fn level_3_7() -> @types.Level {
  build_level(
    23,
    Launch,
    "Sky Hook",
    p(8, 0),
    p(1, 10),
    [p(5, 2), p(10, 4), p(6, 6), p(3, 8)],
    [p(8, 8), p(8, 9), p(8, 10)],
    [p(11, 3), p(4, 7)],
    30,
    5,
  )
}

///|
fn level_3_8() -> @types.Level {
  build_level(
    24,
    Launch,
    "Grand Finale",
    p(1, 0),
    p(15, 11),
    [p(4, 2), p(7, 4), p(10, 6), p(13, 8)],
    [
      p(6, 1),
      p(6, 2),
      p(9, 3),
      p(9, 4),
      p(12, 5),
      p(12, 6),
      p(14, 10),
      p(15, 10),
    ],
    [p(5, 3), p(8, 5), p(11, 7), p(14, 9)],
    35,
    6,
  )
}

///|
pub fn get_level(id : Int) -> @types.Level {
  match id {
    0 => level_1_1()
    1 => level_1_2()
    2 => level_1_3()
    3 => level_1_4()
    4 => level_1_5()
    5 => level_1_6()
    6 => level_1_7()
    7 => level_1_8()
    8 => level_2_1()
    9 => level_2_2()
    10 => level_2_3()
    11 => level_2_4()
    12 => level_2_5()
    13 => level_2_6()
    14 => level_2_7()
    15 => level_2_8()
    16 => level_2_9()
    17 => level_3_1()
    18 => level_3_2()
    19 => level_3_3()
    20 => level_3_4()
    21 => level_3_5()
    22 => level_3_6()
    23 => level_3_7()
    24 => level_3_8()
    _ => level_1_1()
  }
}

///|
pub fn get_all_levels() -> Array[@types.Level] {
  let levels : Array[@types.Level] = []
  for i = 0; i < @types.total_levels; i = i + 1 {
    levels.push(get_level(i))
  }
  levels
}
