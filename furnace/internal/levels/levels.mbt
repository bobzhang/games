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
pub fn load_level(game : @types.Game, id : Int) -> Unit {
  let level = get_level(id)
  game.current_level = id
  @types.reset_grid(game.grid)
  @types.reset_temperatures(game.grid)
  // Place heat sources
  for i = 0; i < level.sources.length(); i = i + 1 {
    let sr = level.sources[i].0
    let sc = level.sources[i].1
    let heat = level.sources[i].2
    let tile = game.grid.tiles[sr][sc]
    tile.kind = HeatSource(heat)
    tile.material = Metal
    tile.temperature = heat
    tile.locked = true
  }
  // Place targets
  for i = 0; i < level.targets.length(); i = i + 1 {
    let tr = level.targets[i].0
    let tc = level.targets[i].1
    let lo = level.targets[i].2
    let hi = level.targets[i].3
    let tile = game.grid.tiles[tr][tc]
    tile.kind = Target(lo, hi)
  }
  // Place locked tiles
  for i = 0; i < level.locked_tiles.length(); i = i + 1 {
    let lr = level.locked_tiles[i].0
    let lc = level.locked_tiles[i].1
    let mat = level.locked_tiles[i].2
    let tile = game.grid.tiles[lr][lc]
    tile.material = mat
    tile.locked = true
  }
  // Set default tool to first available material
  if level.available_materials.length() > 0 {
    game.tool_mode = Place(level.available_materials[0])
  }
  game.sim_turn = 0
  game.sim_timer = 0.0
  game.sim_running = false
  game.result = @types.new_level_result()
}

// ==================== TIER 1: Metal + Stone (Levels 1-8) ====================

///|
fn level_01() -> @types.LevelDef {
  {
    id: 0,
    name: "First Warmth",
    tier: 1,
    par_materials: 2,
    par_turns: 15,
    sources: [(0, 0, 150.0)],
    targets: [(0, 3, 40.0, 80.0)],
    locked_tiles: [],
    available_materials: [Metal, Stone],
  }
}

///|
fn level_02() -> @types.LevelDef {
  {
    id: 1,
    name: "Bridge the Gap",
    tier: 1,
    par_materials: 3,
    par_turns: 20,
    sources: [(0, 0, 180.0)],
    targets: [(0, 5, 50.0, 90.0)],
    locked_tiles: [],
    available_materials: [Metal, Stone],
  }
}

///|
fn level_03() -> @types.LevelDef {
  {
    id: 2,
    name: "Corner Heat",
    tier: 1,
    par_materials: 4,
    par_turns: 25,
    sources: [(0, 0, 200.0)],
    targets: [(3, 3, 40.0, 70.0)],
    locked_tiles: [],
    available_materials: [Metal, Stone],
  }
}

///|
fn level_04() -> @types.LevelDef {
  {
    id: 3,
    name: "Two Paths",
    tier: 1,
    par_materials: 4,
    par_turns: 20,
    sources: [(0, 3, 160.0)],
    targets: [(4, 3, 45.0, 75.0)],
    locked_tiles: [(2, 2, Stone), (2, 4, Stone)],
    available_materials: [Metal, Stone],
  }
}

///|
fn level_05() -> @types.LevelDef {
  {
    id: 4,
    name: "Stone Wall",
    tier: 1,
    par_materials: 5,
    par_turns: 30,
    sources: [(0, 0, 200.0)],
    targets: [(0, 7, 30.0, 60.0)],
    locked_tiles: [(0, 3, Stone)],
    available_materials: [Metal, Stone],
  }
}

///|
fn level_06() -> @types.LevelDef {
  {
    id: 5,
    name: "Slow Burn",
    tier: 1,
    par_materials: 5,
    par_turns: 25,
    sources: [(3, 0, 180.0)],
    targets: [(3, 6, 35.0, 65.0)],
    locked_tiles: [],
    available_materials: [Metal, Stone],
  }
}

///|
fn level_07() -> @types.LevelDef {
  {
    id: 6,
    name: "L-Shape",
    tier: 1,
    par_materials: 5,
    par_turns: 25,
    sources: [(0, 0, 200.0)],
    targets: [(4, 4, 40.0, 70.0)],
    locked_tiles: [(0, 4, Stone), (4, 0, Stone)],
    available_materials: [Metal, Stone],
  }
}

///|
fn level_08() -> @types.LevelDef {
  {
    id: 7,
    name: "Twin Sources",
    tier: 1,
    par_materials: 4,
    par_turns: 20,
    sources: [(0, 0, 120.0), (0, 7, 120.0)],
    targets: [(0, 3, 50.0, 80.0)],
    locked_tiles: [],
    available_materials: [Metal, Stone],
  }
}

// ==================== TIER 2: Wood + Insulator (Levels 9-17) ====================

///|
fn level_09() -> @types.LevelDef {
  {
    id: 8,
    name: "Firewall",
    tier: 2,
    par_materials: 6,
    par_turns: 25,
    sources: [(0, 0, 200.0)],
    targets: [(0, 4, 55.0, 75.0), (4, 0, 30.0, 50.0)],
    locked_tiles: [],
    available_materials: [Metal, Stone, Wood, Insulator],
  }
}

///|
fn level_10() -> @types.LevelDef {
  {
    id: 9,
    name: "Heat Maze",
    tier: 2,
    par_materials: 7,
    par_turns: 30,
    sources: [(0, 0, 250.0)],
    targets: [(0, 7, 60.0, 90.0), (7, 0, 30.0, 50.0)],
    locked_tiles: [(2, 0, Insulator), (2, 1, Insulator), (2, 2, Insulator)],
    available_materials: [Metal, Stone, Wood, Insulator],
  }
}

///|
fn level_11() -> @types.LevelDef {
  {
    id: 10,
    name: "Warm and Cool",
    tier: 2,
    par_materials: 6,
    par_turns: 25,
    sources: [(3, 0, 200.0)],
    targets: [(3, 3, 70.0, 100.0), (3, 6, 30.0, 50.0)],
    locked_tiles: [],
    available_materials: [Metal, Stone, Wood, Insulator],
  }
}

///|
fn level_12() -> @types.LevelDef {
  {
    id: 11,
    name: "Insulation Test",
    tier: 2,
    par_materials: 8,
    par_turns: 30,
    sources: [(0, 3, 200.0), (7, 3, 200.0)],
    targets: [(3, 3, 25.0, 40.0)],
    locked_tiles: [],
    available_materials: [Metal, Stone, Wood, Insulator],
  }
}

///|
fn level_13() -> @types.LevelDef {
  {
    id: 12,
    name: "Three Zones",
    tier: 2,
    par_materials: 8,
    par_turns: 30,
    sources: [(0, 0, 250.0)],
    targets: [(2, 2, 80.0, 110.0), (4, 4, 40.0, 60.0), (6, 6, 25.0, 40.0)],
    locked_tiles: [],
    available_materials: [Metal, Stone, Wood, Insulator],
  }
}

///|
fn level_14() -> @types.LevelDef {
  {
    id: 13,
    name: "Blocked Path",
    tier: 2,
    par_materials: 7,
    par_turns: 25,
    sources: [(0, 0, 180.0)],
    targets: [(0, 7, 50.0, 70.0), (7, 7, 30.0, 50.0)],
    locked_tiles: [
      (3, 0, Insulator),
      (3, 1, Insulator),
      (3, 2, Insulator),
      (3, 3, Insulator),
      (3, 4, Insulator),
    ],
    available_materials: [Metal, Stone, Wood, Insulator],
  }
}

///|
fn level_15() -> @types.LevelDef {
  {
    id: 14,
    name: "Heat Splitter",
    tier: 2,
    par_materials: 8,
    par_turns: 30,
    sources: [(3, 0, 200.0)],
    targets: [(0, 4, 45.0, 65.0), (6, 4, 45.0, 65.0)],
    locked_tiles: [],
    available_materials: [Metal, Stone, Wood, Insulator],
  }
}

///|
fn level_16() -> @types.LevelDef {
  {
    id: 15,
    name: "Wood Bridge",
    tier: 2,
    par_materials: 7,
    par_turns: 35,
    sources: [(0, 0, 200.0)],
    targets: [(4, 4, 30.0, 50.0), (7, 7, 25.0, 40.0)],
    locked_tiles: [(2, 2, Insulator), (2, 3, Insulator)],
    available_materials: [Metal, Stone, Wood, Insulator],
  }
}

///|
fn level_17() -> @types.LevelDef {
  {
    id: 16,
    name: "Dual Furnace",
    tier: 2,
    par_materials: 8,
    par_turns: 25,
    sources: [(0, 0, 150.0), (7, 7, 150.0)],
    targets: [(3, 3, 55.0, 75.0), (4, 4, 55.0, 75.0)],
    locked_tiles: [],
    available_materials: [Metal, Stone, Wood, Insulator],
  }
}

// ==================== TIER 3: Glass + All (Levels 18-25) ====================

///|
fn level_18() -> @types.LevelDef {
  {
    id: 17,
    name: "Glass Intro",
    tier: 3,
    par_materials: 5,
    par_turns: 25,
    sources: [(0, 0, 180.0)],
    targets: [(0, 5, 40.0, 60.0)],
    locked_tiles: [(0, 2, Glass)],
    available_materials: [Metal, Stone, Wood, Insulator, Glass],
  }
}

///|
fn level_19() -> @types.LevelDef {
  {
    id: 18,
    name: "Glass Corridor",
    tier: 3,
    par_materials: 6,
    par_turns: 30,
    sources: [(3, 0, 200.0)],
    targets: [(3, 7, 45.0, 65.0), (0, 3, 30.0, 50.0)],
    locked_tiles: [],
    available_materials: [Metal, Stone, Wood, Insulator, Glass],
  }
}

///|
fn level_20() -> @types.LevelDef {
  {
    id: 19,
    name: "Precision Heat",
    tier: 3,
    par_materials: 7,
    par_turns: 30,
    sources: [(0, 0, 250.0)],
    targets: [(3, 3, 55.0, 65.0)],
    locked_tiles: [(1, 1, Insulator), (1, 2, Insulator)],
    available_materials: [Metal, Stone, Wood, Insulator, Glass],
  }
}

///|
fn level_21() -> @types.LevelDef {
  {
    id: 20,
    name: "Glass Maze",
    tier: 3,
    par_materials: 8,
    par_turns: 35,
    sources: [(0, 0, 220.0)],
    targets: [(0, 7, 50.0, 70.0), (7, 0, 35.0, 55.0), (7, 7, 25.0, 40.0)],
    locked_tiles: [
      (3, 3, Glass),
      (3, 4, Glass),
      (4, 3, Insulator),
      (4, 4, Insulator),
    ],
    available_materials: [Metal, Stone, Wood, Insulator, Glass],
  }
}

///|
fn level_22() -> @types.LevelDef {
  {
    id: 21,
    name: "Temperature Ladder",
    tier: 3,
    par_materials: 9,
    par_turns: 35,
    sources: [(0, 0, 300.0)],
    targets: [(2, 2, 90.0, 110.0), (4, 4, 50.0, 70.0), (6, 6, 30.0, 45.0)],
    locked_tiles: [],
    available_materials: [Metal, Stone, Wood, Insulator, Glass],
  }
}

///|
fn level_23() -> @types.LevelDef {
  {
    id: 22,
    name: "Cross Flow",
    tier: 3,
    par_materials: 10,
    par_turns: 35,
    sources: [(0, 3, 200.0), (7, 3, 150.0)],
    targets: [(3, 0, 55.0, 75.0), (3, 7, 40.0, 60.0)],
    locked_tiles: [(3, 3, Glass), (4, 3, Glass)],
    available_materials: [Metal, Stone, Wood, Insulator, Glass],
  }
}

///|
fn level_24() -> @types.LevelDef {
  {
    id: 23,
    name: "The Crucible",
    tier: 3,
    par_materials: 10,
    par_turns: 40,
    sources: [(0, 0, 300.0), (0, 7, 200.0)],
    targets: [
      (3, 3, 70.0, 85.0),
      (3, 5, 50.0, 65.0),
      (5, 3, 40.0, 55.0),
      (5, 5, 30.0, 45.0),
    ],
    locked_tiles: [(1, 3, Glass), (1, 5, Glass)],
    available_materials: [Metal, Stone, Wood, Insulator, Glass],
  }
}

///|
fn level_25() -> @types.LevelDef {
  {
    id: 24,
    name: "Master Forge",
    tier: 3,
    par_materials: 12,
    par_turns: 45,
    sources: [(0, 0, 350.0), (0, 7, 250.0), (7, 3, 180.0)],
    targets: [
      (2, 2, 80.0, 95.0),
      (2, 5, 60.0, 75.0),
      (5, 2, 45.0, 60.0),
      (5, 5, 30.0, 42.0),
    ],
    locked_tiles: [
      (1, 3, Insulator),
      (1, 4, Insulator),
      (3, 1, Glass),
      (3, 6, Glass),
      (6, 3, Stone),
    ],
    available_materials: [Metal, Stone, Wood, Insulator, Glass],
  }
}
