///|
/// Get a hint for the given level.
pub fn get_level_hint(index : Int) -> String {
  match index {
    0 => "Place forest next to the ocean to watch it grow."
    1 => "Ocean blocks desert spread. Place water strategically."
    2 => "Create a water barrier between desert and forest."
    3 => "Forests need water neighbors to spread to barren tiles."
    4 => "Surround the desert with ocean to stop its advance."
    5 => "Two water sources let forest spread in both directions."
    6 => "Remember: left and right edges are connected!"
    7 => "The equatorial oceans help forest spread along the band."
    8 => "Break through the desert wall with well-placed oceans."
    9 => "Connect the island chain with forests between the seas."
    10 => "The polar oceans help, but the equatorial desert is tough."
    11 => "Work both sides of the continental divide."
    12 => "This desert needs lots of water to irrigate."
    13 => "The ring of oceans helps forest spread around the world."
    14 => "Locked tiles cannot be changed - work around them."
    15 => "Use the scattered oceans as stepping stones for forest."
    16 => "The diagonal deserts spread fast - contain them early."
    17 => "Balance the existing ecosystem carefully."
    18 => "Stop desert from spreading before it covers everything."
    19 => "Use wrapping to connect forest and ocean across edges."
    20 => "Ocean at poles helps, but the equatorial desert is dense."
    21 => "Both biomes are aggressive - ocean is the peacekeeper."
    22 => "Forest at left edge can reach ocean at right edge via wrap."
    23 => "Every biome ratio must be precisely within range."
    24 => "The ultimate test of all mechanics combined."
    _ => ""
  }
}

///|
/// Get level description text for the level select.
pub fn get_level_description(index : Int) -> String {
  match index {
    0 => "Plant your first forest near water"
    1 => "Create an oasis in the desert"
    2 => "Build a defensive coastline"
    3 => "Chain forests with water sources"
    4 => "Stop the desert expansion"
    5 => "Use twin lakes for dual growth"
    6 => "Master horizontal wrapping"
    7 => "Terraform the equatorial band"
    8 => "Break through the drought line"
    9 => "Connect scattered islands"
    10 => "Balance polar and tropical zones"
    11 => "Work both hemispheres"
    12 => "Irrigate a desert planet"
    13 => "Orbit the ring world"
    14 => "Navigate locked terrain"
    15 => "Island-hop through the archipelago"
    16 => "Tame the crosswind deserts"
    17 => "Manage the supercontinent"
    18 => "Reverse desertification"
    19 => "Master the terraforming arts"
    20 => "Thaw the frozen equator"
    21 => "Mediate the biome war"
    22 => "Exploit planetary wrapping"
    23 => "Achieve perfect equilibrium"
    24 => "Create the perfect world"
    _ => ""
  }
}

///|
/// Get level definition by index (0-24).
pub fn get_level(index : Int) -> @types.Level {
  match index {
    0 => level_0()
    1 => level_1()
    2 => level_2()
    3 => level_3()
    4 => level_4()
    5 => level_5()
    6 => level_6()
    7 => level_7()
    8 => level_8()
    9 => level_9()
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
/// Initialize a grid from a level definition.
pub fn init_grid_from_level(level : @types.Level) -> @types.HexGrid {
  let grid = @types.new_grid(level.width, level.height, true)
  for i in 0..<level.starting_tiles.length() {
    let (col, row, biome, locked) = level.starting_tiles[i]
    let idx = @types.grid_index(col, row, level.width)
    grid.tiles[idx].biome = biome
    // locked field is immutable so we need to replace the tile
    if locked {
      grid.tiles[idx] = { biome, locked: true }
    }
  }
  grid
}

// ============================================================
// Tier 1: "Seeds" - 8 levels (indices 0-7)
// Small grids, learn biome rules, generous targets
// ============================================================

///|
fn level_0() -> @types.Level {
  // "First Growth" - Learn to place forest near ocean
  {
    tier: Seeds,
    tier_index: 0,
    width: 8,
    height: 5,
    starting_tiles: [
      (3, 2, Ocean, true),
    ],
    budget: @types.new_budget(4, 2, 0),
    targets: @types.new_targets(0.15, 0.50, 0.05, 0.40, 0.0, 0.20),
    par_turns: 8,
  }
}

///|
fn level_1() -> @types.Level {
  // "Oasis" - Place ocean to enable forest growth
  {
    tier: Seeds,
    tier_index: 1,
    width: 8,
    height: 5,
    starting_tiles: [
      (2, 1, Desert, false),
      (3, 1, Desert, false),
      (4, 2, Desert, false),
    ],
    budget: @types.new_budget(3, 3, 0),
    targets: @types.new_targets(0.10, 0.50, 0.10, 0.40, 0.0, 0.15),
    par_turns: 10,
  }
}

///|
fn level_2() -> @types.Level {
  // "Coastline" - Ocean blocks desert spread
  {
    tier: Seeds,
    tier_index: 2,
    width: 10,
    height: 5,
    starting_tiles: [
      (0, 2, Desert, false),
      (1, 2, Desert, false),
      (8, 2, Forest, false),
      (9, 2, Forest, false),
    ],
    budget: @types.new_budget(2, 4, 0),
    targets: @types.new_targets(0.10, 0.40, 0.10, 0.35, 0.0, 0.15),
    par_turns: 10,
  }
}

///|
fn level_3() -> @types.Level {
  // "Green Belt" - Forest chain needs water
  {
    tier: Seeds,
    tier_index: 3,
    width: 10,
    height: 6,
    starting_tiles: [
      (4, 0, Ocean, true),
      (5, 5, Ocean, true),
    ],
    budget: @types.new_budget(5, 2, 0),
    targets: @types.new_targets(0.20, 0.50, 0.05, 0.30, 0.0, 0.10),
    par_turns: 10,
  }
}

///|
fn level_4() -> @types.Level {
  // "Desert Halt" - Stop desert from taking over
  {
    tier: Seeds,
    tier_index: 4,
    width: 10,
    height: 6,
    starting_tiles: [
      (0, 3, Desert, false),
      (1, 3, Desert, false),
      (2, 3, Desert, false),
      (0, 2, Desert, false),
    ],
    budget: @types.new_budget(3, 4, 0),
    targets: @types.new_targets(0.10, 0.40, 0.10, 0.35, 0.0, 0.10),
    par_turns: 12,
  }
}

///|
fn level_5() -> @types.Level {
  // "Twin Lakes" - Two water sources
  {
    tier: Seeds,
    tier_index: 5,
    width: 10,
    height: 6,
    starting_tiles: [
      (2, 2, Ocean, true),
      (7, 4, Ocean, true),
    ],
    budget: @types.new_budget(5, 1, 1),
    targets: @types.new_targets(0.15, 0.45, 0.05, 0.25, 0.02, 0.15),
    par_turns: 10,
  }
}

///|
fn level_6() -> @types.Level {
  // "Wrap Around" - Uses horizontal wrapping
  {
    tier: Seeds,
    tier_index: 6,
    width: 12,
    height: 6,
    starting_tiles: [
      (0, 3, Forest, false),
      (11, 3, Ocean, true),
    ],
    budget: @types.new_budget(4, 2, 1),
    targets: @types.new_targets(0.10, 0.40, 0.05, 0.25, 0.02, 0.15),
    par_turns: 12,
  }
}

///|
fn level_7() -> @types.Level {
  // "Equator" - Band across the middle
  {
    tier: Seeds,
    tier_index: 7,
    width: 12,
    height: 6,
    starting_tiles: [
      (3, 3, Ocean, true),
      (6, 3, Ocean, true),
      (9, 3, Ocean, true),
      (0, 3, Desert, false),
      (11, 3, Desert, false),
    ],
    budget: @types.new_budget(5, 1, 1),
    targets: @types.new_targets(0.15, 0.40, 0.08, 0.25, 0.0, 0.10),
    par_turns: 12,
  }
}

// ============================================================
// Tier 2: "Balance" - 9 levels (indices 8-16)
// Tighter targets, more starting obstacles, limited budget
// ============================================================

///|
fn level_8() -> @types.Level {
  // "Drought Line" - Desert wall to overcome
  {
    tier: Balance,
    tier_index: 0,
    width: 14,
    height: 8,
    starting_tiles: [
      (3, 0, Desert, false), (3, 1, Desert, false), (3, 2, Desert, false),
      (3, 3, Desert, false), (3, 4, Desert, false), (3, 5, Desert, false),
      (3, 6, Desert, false), (3, 7, Desert, false),
    ],
    budget: @types.new_budget(4, 5, 1),
    targets: @types.new_targets(0.10, 0.30, 0.08, 0.25, 0.02, 0.15),
    par_turns: 15,
  }
}

///|
fn level_9() -> @types.Level {
  // "Island Chain"
  {
    tier: Balance,
    tier_index: 1,
    width: 14,
    height: 8,
    starting_tiles: [
      (2, 2, Ocean, true), (6, 4, Ocean, true), (10, 2, Ocean, true),
      (4, 6, Ocean, true),
    ],
    budget: @types.new_budget(6, 2, 2),
    targets: @types.new_targets(0.12, 0.30, 0.05, 0.20, 0.03, 0.15),
    par_turns: 14,
  }
}

///|
fn level_10() -> @types.Level {
  // "Polar Caps"
  {
    tier: Balance,
    tier_index: 2,
    width: 14,
    height: 8,
    starting_tiles: [
      (3, 0, Ocean, true), (7, 0, Ocean, true), (10, 0, Ocean, true),
      (3, 7, Ocean, true), (7, 7, Ocean, true), (10, 7, Ocean, true),
      (6, 3, Desert, false), (7, 3, Desert, false), (8, 4, Desert, false),
    ],
    budget: @types.new_budget(5, 2, 2),
    targets: @types.new_targets(0.12, 0.28, 0.08, 0.22, 0.03, 0.12),
    par_turns: 14,
  }
}

///|
fn level_11() -> @types.Level {
  // "Continental Divide"
  {
    tier: Balance,
    tier_index: 3,
    width: 14,
    height: 8,
    starting_tiles: [
      (7, 0, Ocean, true), (7, 1, Ocean, true), (7, 2, Ocean, true),
      (7, 3, Ocean, true), (7, 4, Ocean, true), (7, 5, Ocean, true),
      (7, 6, Ocean, true), (7, 7, Ocean, true),
      (2, 3, Desert, false), (3, 4, Desert, false),
      (11, 3, Desert, false), (10, 4, Desert, false),
    ],
    budget: @types.new_budget(5, 1, 2),
    targets: @types.new_targets(0.12, 0.28, 0.08, 0.22, 0.03, 0.12),
    par_turns: 14,
  }
}

///|
fn level_12() -> @types.Level {
  // "Desert Planet" - Much desert to tame
  {
    tier: Balance,
    tier_index: 4,
    width: 14,
    height: 8,
    starting_tiles: [
      (2, 2, Desert, false), (3, 2, Desert, false), (4, 3, Desert, false),
      (5, 3, Desert, false), (6, 4, Desert, false), (7, 4, Desert, false),
      (8, 3, Desert, false), (9, 3, Desert, false), (10, 2, Desert, false),
      (11, 2, Desert, false),
    ],
    budget: @types.new_budget(4, 6, 0),
    targets: @types.new_targets(0.10, 0.28, 0.10, 0.28, 0.0, 0.10),
    par_turns: 16,
  }
}

///|
fn level_13() -> @types.Level {
  // "Ring World"
  {
    tier: Balance,
    tier_index: 5,
    width: 14,
    height: 8,
    starting_tiles: [
      (0, 4, Ocean, true), (3, 4, Ocean, true), (7, 4, Ocean, true),
      (10, 4, Ocean, true), (13, 4, Ocean, true),
      (1, 1, Desert, false), (5, 1, Desert, false),
      (9, 1, Desert, false), (12, 1, Desert, false),
    ],
    budget: @types.new_budget(5, 2, 2),
    targets: @types.new_targets(0.12, 0.28, 0.06, 0.22, 0.03, 0.12),
    par_turns: 14,
  }
}

///|
fn level_14() -> @types.Level {
  // "Locked Shores"
  {
    tier: Balance,
    tier_index: 6,
    width: 14,
    height: 8,
    starting_tiles: [
      (0, 0, Ocean, true), (1, 0, Ocean, true), (13, 0, Ocean, true),
      (0, 7, Ocean, true), (1, 7, Ocean, true), (13, 7, Ocean, true),
      (5, 3, Desert, true), (6, 3, Desert, true), (7, 4, Desert, true),
      (8, 4, Desert, true),
    ],
    budget: @types.new_budget(5, 3, 1),
    targets: @types.new_targets(0.12, 0.28, 0.08, 0.22, 0.05, 0.15),
    par_turns: 15,
  }
}

///|
fn level_15() -> @types.Level {
  // "Archipelago"
  {
    tier: Balance,
    tier_index: 7,
    width: 14,
    height: 8,
    starting_tiles: [
      (1, 1, Ocean, true), (4, 3, Ocean, true), (8, 1, Ocean, true),
      (11, 5, Ocean, true), (2, 6, Ocean, true), (12, 2, Ocean, true),
      (6, 5, Desert, false), (7, 2, Desert, false),
    ],
    budget: @types.new_budget(5, 2, 2),
    targets: @types.new_targets(0.12, 0.28, 0.08, 0.22, 0.03, 0.12),
    par_turns: 14,
  }
}

///|
fn level_16() -> @types.Level {
  // "Crosswinds"
  {
    tier: Balance,
    tier_index: 8,
    width: 14,
    height: 8,
    starting_tiles: [
      (0, 0, Desert, false), (1, 1, Desert, false), (2, 2, Desert, false),
      (13, 7, Desert, false), (12, 6, Desert, false), (11, 5, Desert, false),
      (7, 0, Ocean, true), (7, 7, Ocean, true),
    ],
    budget: @types.new_budget(5, 4, 1),
    targets: @types.new_targets(0.12, 0.28, 0.08, 0.22, 0.02, 0.10),
    par_turns: 15,
  }
}

// ============================================================
// Tier 3: "Harmony" - 8 levels (indices 17-24)
// Complex starting states, tight ratios, all mechanics
// ============================================================

///|
fn level_17() -> @types.Level {
  // "Pangaea" - One massive landmass to manage
  {
    tier: Harmony,
    tier_index: 0,
    width: 14,
    height: 8,
    starting_tiles: [
      (4, 2, Desert, false), (5, 2, Desert, false), (6, 2, Forest, false),
      (7, 2, Forest, false), (8, 2, Desert, false), (9, 2, Desert, false),
      (4, 3, Desert, false), (5, 3, Forest, false), (6, 3, Forest, false),
      (7, 3, Forest, false), (8, 3, Forest, false), (9, 3, Desert, false),
      (5, 4, Desert, false), (6, 4, Forest, false), (7, 4, Forest, false),
      (8, 4, Desert, false),
      (3, 5, Ocean, true), (10, 5, Ocean, true),
    ],
    budget: @types.new_budget(3, 4, 2),
    targets: @types.new_targets(0.14, 0.24, 0.10, 0.20, 0.04, 0.12),
    par_turns: 14,
  }
}

///|
fn level_18() -> @types.Level {
  // "Desertification" - Stop the spread
  {
    tier: Harmony,
    tier_index: 1,
    width: 14,
    height: 8,
    starting_tiles: [
      (0, 0, Desert, false), (1, 0, Desert, false), (2, 0, Desert, false),
      (0, 1, Desert, false), (1, 1, Desert, false),
      (12, 6, Desert, false), (13, 6, Desert, false),
      (12, 7, Desert, false), (13, 7, Desert, false), (11, 7, Desert, false),
      (6, 3, Ocean, true), (7, 4, Ocean, true),
      (3, 3, Forest, false), (4, 4, Forest, false),
    ],
    budget: @types.new_budget(4, 5, 1),
    targets: @types.new_targets(0.12, 0.22, 0.10, 0.20, 0.0, 0.08),
    par_turns: 16,
  }
}

///|
fn level_19() -> @types.Level {
  // "Terraformer" - Complex ecosystem puzzle
  {
    tier: Harmony,
    tier_index: 2,
    width: 14,
    height: 8,
    starting_tiles: [
      (0, 4, Ocean, true), (13, 4, Ocean, true),
      (3, 1, Desert, true), (10, 1, Desert, true),
      (3, 6, Desert, true), (10, 6, Desert, true),
      (6, 0, Forest, false), (7, 0, Forest, false),
      (6, 7, Forest, false), (7, 7, Forest, false),
    ],
    budget: @types.new_budget(4, 4, 2),
    targets: @types.new_targets(0.14, 0.24, 0.10, 0.20, 0.04, 0.12),
    par_turns: 15,
  }
}

///|
fn level_20() -> @types.Level {
  // "Frozen World" - Locked ocean poles, desert equator
  {
    tier: Harmony,
    tier_index: 3,
    width: 14,
    height: 8,
    starting_tiles: [
      (2, 0, Ocean, true), (5, 0, Ocean, true), (8, 0, Ocean, true),
      (11, 0, Ocean, true),
      (2, 7, Ocean, true), (5, 7, Ocean, true), (8, 7, Ocean, true),
      (11, 7, Ocean, true),
      (3, 3, Desert, false), (4, 3, Desert, false), (5, 4, Desert, false),
      (6, 3, Desert, false), (7, 4, Desert, false), (8, 3, Desert, false),
      (9, 4, Desert, false), (10, 3, Desert, false),
    ],
    budget: @types.new_budget(5, 3, 1),
    targets: @types.new_targets(0.14, 0.24, 0.10, 0.20, 0.03, 0.10),
    par_turns: 16,
  }
}

///|
fn level_21() -> @types.Level {
  // "Biome War" - Forest vs Desert
  {
    tier: Harmony,
    tier_index: 4,
    width: 14,
    height: 8,
    starting_tiles: [
      (0, 0, Forest, false), (1, 0, Forest, false), (0, 1, Forest, false),
      (1, 1, Forest, false), (0, 2, Forest, false),
      (12, 5, Desert, false), (13, 5, Desert, false), (12, 6, Desert, false),
      (13, 6, Desert, false), (13, 7, Desert, false),
      (6, 3, Ocean, true), (7, 4, Ocean, true),
    ],
    budget: @types.new_budget(3, 4, 2),
    targets: @types.new_targets(0.14, 0.22, 0.10, 0.20, 0.04, 0.12),
    par_turns: 15,
  }
}

///|
fn level_22() -> @types.Level {
  // "Planet Wrap" - Wrapping is essential
  {
    tier: Harmony,
    tier_index: 5,
    width: 14,
    height: 8,
    starting_tiles: [
      (0, 3, Forest, false), (0, 4, Forest, false),
      (13, 3, Ocean, true), (13, 4, Ocean, true),
      (6, 1, Desert, true), (7, 1, Desert, true),
      (6, 6, Desert, true), (7, 6, Desert, true),
      (3, 3, Desert, false), (10, 4, Desert, false),
    ],
    budget: @types.new_budget(4, 4, 2),
    targets: @types.new_targets(0.14, 0.22, 0.10, 0.20, 0.05, 0.12),
    par_turns: 14,
  }
}

///|
fn level_23() -> @types.Level {
  // "Equilibrium" - Precise balance required
  {
    tier: Harmony,
    tier_index: 6,
    width: 14,
    height: 8,
    starting_tiles: [
      (2, 2, Ocean, true), (11, 2, Ocean, true),
      (2, 5, Ocean, true), (11, 5, Ocean, true),
      (0, 0, Desert, false), (13, 0, Desert, false),
      (0, 7, Desert, false), (13, 7, Desert, false),
      (6, 3, Forest, false), (7, 3, Forest, false),
      (6, 4, Forest, false), (7, 4, Forest, false),
    ],
    budget: @types.new_budget(3, 3, 3),
    targets: @types.new_targets(0.15, 0.22, 0.10, 0.18, 0.05, 0.12),
    par_turns: 14,
  }
}

///|
fn level_24() -> @types.Level {
  // "Perfect World" - The ultimate challenge
  {
    tier: Harmony,
    tier_index: 7,
    width: 14,
    height: 8,
    starting_tiles: [
      (0, 0, Desert, true), (13, 0, Desert, true),
      (0, 7, Desert, true), (13, 7, Desert, true),
      (3, 0, Ocean, true), (10, 0, Ocean, true),
      (3, 7, Ocean, true), (10, 7, Ocean, true),
      (6, 0, Forest, true), (7, 0, Forest, true),
      (5, 3, Desert, false), (6, 3, Desert, false),
      (7, 4, Desert, false), (8, 4, Desert, false),
      (4, 2, Forest, false), (9, 5, Forest, false),
      (2, 4, Ocean, true), (11, 3, Ocean, true),
    ],
    budget: @types.new_budget(4, 4, 3),
    targets: @types.new_targets(0.14, 0.20, 0.10, 0.18, 0.04, 0.10),
    par_turns: 16,
  }
}
