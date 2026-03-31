///|
pub fn create_all_levels() -> Array[@types.Level] {
  let levels : Array[@types.Level] = []
  // Tier 1: Oasis Trail (8 levels) - gentle introduction
  levels.push(level_01())
  levels.push(level_02())
  levels.push(level_03())
  levels.push(level_04())
  levels.push(level_05())
  levels.push(level_06())
  levels.push(level_07())
  levels.push(level_08())
  // Tier 2: Dune Sea (9 levels) - more complex routing
  levels.push(level_09())
  levels.push(level_10())
  levels.push(level_11())
  levels.push(level_12())
  levels.push(level_13())
  levels.push(level_14())
  levels.push(level_15())
  levels.push(level_16())
  levels.push(level_17())
  // Tier 3: Lost City (8 levels) - advanced puzzles
  levels.push(level_18())
  levels.push(level_19())
  levels.push(level_20())
  levels.push(level_21())
  levels.push(level_22())
  levels.push(level_23())
  levels.push(level_24())
  levels.push(level_25())
  levels
}

///|
fn build_level(
  name : String,
  tier : @types.Tier,
  start_col : Int,
  start_row : Int,
  dest_col : Int,
  dest_row : Int,
  starting_water : Int,
  gold_target : Int,
  total_artifacts : Int,
  tile_data : Array[(Int, Int, @types.TileKind)]
) -> @types.Level {
  let map = @types.new_hex_map(@types.map_width, @types.map_height)
  for i in 0..<tile_data.length() {
    let (col, row, kind) = tile_data[i]
    if col >= 0 &&
      col < @types.map_width &&
      row >= 0 &&
      row < @types.map_height {
      map.tiles[row][col] = { kind, }
    }
  }
  // Mark destination tile
  if dest_col >= 0 &&
    dest_col < @types.map_width &&
    dest_row >= 0 &&
    dest_row < @types.map_height {
    map.tiles[dest_row][dest_col] = { kind: Destination }
  }
  {
    map,
    start: { col: start_col, row: start_row },
    destination: { col: dest_col, row: dest_row },
    starting_water,
    gold_target,
    total_artifacts,
    tier,
    name,
  }
}

// ===== TIER 1: OASIS TRAIL =====

///|
fn level_01() -> @types.Level {
  build_level(
    "First Crossing",
    OasisTrail,
    0,
    0,
    4,
    0,
    8,
    0,
    0,
    [(2, 0, Oasis)],
  )
}

///|
fn level_02() -> @types.Level {
  build_level(
    "Oasis Path",
    OasisTrail,
    0,
    1,
    5,
    1,
    6,
    0,
    0,
    [(2, 1, Oasis), (4, 1, Oasis)],
  )
}

///|
fn level_03() -> @types.Level {
  build_level(
    "Trader's Road",
    OasisTrail,
    0,
    2,
    6,
    2,
    8,
    5,
    0,
    [(2, 2, Oasis), (4, 2, TradePost)],
  )
}

///|
fn level_04() -> @types.Level {
  build_level(
    "Dune Detour",
    OasisTrail,
    0,
    0,
    5,
    3,
    10,
    0,
    0,
    [
      (1, 0, Dunes),
      (2, 0, Dunes),
      (3, 0, Dunes),
      (1, 1, Oasis),
      (3, 2, Oasis),
    ],
  )
}

///|
fn level_05() -> @types.Level {
  build_level(
    "Desert Treasure",
    OasisTrail,
    0,
    3,
    7,
    3,
    12,
    0,
    1,
    [(2, 3, Oasis), (4, 3, Ruins), (5, 3, Oasis)],
  )
}

///|
fn level_06() -> @types.Level {
  build_level(
    "Sand Corridor",
    OasisTrail,
    0,
    0,
    6,
    4,
    10,
    5,
    0,
    [
      (1, 1, Dunes),
      (2, 1, Sandstorm),
      (3, 1, Oasis),
      (4, 2, TradePost),
      (5, 3, Oasis),
    ],
  )
}

///|
fn level_07() -> @types.Level {
  build_level(
    "Merchant Route",
    OasisTrail,
    0,
    1,
    8,
    1,
    14,
    15,
    0,
    [
      (2, 1, Oasis),
      (4, 0, TradePost),
      (5, 1, Oasis),
      (7, 0, TradePost),
      (3, 2, Dunes),
      (6, 2, Dunes),
    ],
  )
}

///|
fn level_08() -> @types.Level {
  build_level(
    "Ruin Raider",
    OasisTrail,
    0,
    0,
    7,
    4,
    16,
    10,
    2,
    [
      (1, 1, Oasis),
      (3, 1, Ruins),
      (2, 3, Oasis),
      (4, 3, TradePost),
      (5, 2, Ruins),
      (6, 3, Oasis),
      (3, 0, Dunes),
      (4, 0, Dunes),
    ],
  )
}

// ===== TIER 2: DUNE SEA =====

///|
fn level_09() -> @types.Level {
  build_level(
    "Storm Wall",
    DuneSea,
    0,
    3,
    9,
    3,
    14,
    5,
    0,
    [
      (3, 2, Sandstorm),
      (3, 3, Sandstorm),
      (3, 4, Sandstorm),
      (2, 3, Oasis),
      (4, 1, Oasis),
      (6, 3, TradePost),
      (8, 3, Oasis),
    ],
  )
}

///|
fn level_10() -> @types.Level {
  build_level(
    "Winding Dunes",
    DuneSea,
    0,
    0,
    8,
    6,
    16,
    0,
    1,
    [
      (1, 0, Dunes),
      (2, 1, Dunes),
      (3, 2, Oasis),
      (4, 3, Dunes),
      (5, 3, Ruins),
      (5, 4, Oasis),
      (6, 5, Dunes),
      (7, 6, Oasis),
    ],
  )
}

///|
fn level_11() -> @types.Level {
  build_level(
    "Oasis Chain",
    DuneSea,
    0,
    4,
    9,
    4,
    10,
    10,
    0,
    [
      (2, 4, Oasis),
      (4, 3, Oasis),
      (5, 4, TradePost),
      (6, 3, Oasis),
      (8, 4, Oasis),
      (1, 3, Dunes),
      (3, 5, Dunes),
      (7, 5, Dunes),
    ],
  )
}

///|
fn level_12() -> @types.Level {
  build_level(
    "Twin Storms",
    DuneSea,
    0,
    0,
    9,
    7,
    18,
    5,
    1,
    [
      (2, 1, Sandstorm),
      (2, 2, Sandstorm),
      (6, 4, Sandstorm),
      (6, 5, Sandstorm),
      (1, 1, Oasis),
      (3, 3, Oasis),
      (4, 3, Ruins),
      (5, 4, Oasis),
      (7, 6, Oasis),
      (8, 6, TradePost),
    ],
  )
}

///|
fn level_13() -> @types.Level {
  build_level(
    "Artifact Alley",
    DuneSea,
    0,
    2,
    9,
    2,
    16,
    15,
    3,
    [
      (2, 2, Oasis),
      (3, 1, Ruins),
      (4, 2, Oasis),
      (5, 1, Ruins),
      (6, 2, TradePost),
      (7, 1, Ruins),
      (8, 2, Oasis),
      (1, 3, Dunes),
      (5, 3, Dunes),
    ],
  )
}

///|
fn level_14() -> @types.Level {
  build_level(
    "Dune Maze",
    DuneSea,
    0,
    0,
    9,
    0,
    20,
    10,
    0,
    [
      (2, 0, Dunes),
      (3, 0, Dunes),
      (5, 0, Dunes),
      (7, 0, Dunes),
      (1, 1, Oasis),
      (4, 1, Oasis),
      (6, 1, TradePost),
      (8, 1, Oasis),
      (2, 2, Dunes),
      (5, 2, Dunes),
      (3, 1, TradePost),
    ],
  )
}

///|
fn level_15() -> @types.Level {
  build_level(
    "Storm Corridor",
    DuneSea,
    0,
    3,
    9,
    3,
    18,
    10,
    2,
    [
      (2, 2, Sandstorm),
      (2, 4, Sandstorm),
      (5, 2, Sandstorm),
      (5, 4, Sandstorm),
      (1, 3, Oasis),
      (3, 3, Ruins),
      (4, 3, Oasis),
      (6, 3, Ruins),
      (7, 3, Oasis),
      (8, 3, TradePost),
    ],
  )
}

///|
fn level_16() -> @types.Level {
  build_level(
    "Serpent Path",
    DuneSea,
    0,
    0,
    9,
    6,
    20,
    15,
    2,
    [
      (1, 1, Oasis),
      (2, 2, Ruins),
      (3, 1, TradePost),
      (4, 2, Oasis),
      (5, 3, Dunes),
      (5, 4, Oasis),
      (6, 5, Ruins),
      (7, 5, TradePost),
      (8, 6, Oasis),
      (3, 3, Sandstorm),
      (6, 3, Sandstorm),
    ],
  )
}

///|
fn level_17() -> @types.Level {
  build_level(
    "Desert Gauntlet",
    DuneSea,
    0,
    4,
    9,
    4,
    22,
    20,
    3,
    [
      (1, 3, Dunes),
      (1, 5, Sandstorm),
      (2, 4, Oasis),
      (3, 3, Ruins),
      (4, 4, TradePost),
      (5, 3, Oasis),
      (5, 5, Sandstorm),
      (6, 4, Ruins),
      (7, 3, Oasis),
      (7, 5, Dunes),
      (8, 4, Ruins),
      (8, 3, TradePost),
    ],
  )
}

// ===== TIER 3: LOST CITY =====

///|
fn level_18() -> @types.Level {
  build_level(
    "Storm Fortress",
    LostCity,
    0,
    0,
    9,
    7,
    24,
    10,
    2,
    [
      (2, 1, Sandstorm),
      (3, 2, Sandstorm),
      (4, 3, Sandstorm),
      (6, 5, Sandstorm),
      (7, 6, Sandstorm),
      (1, 1, Oasis),
      (2, 3, Oasis),
      (4, 4, Ruins),
      (5, 5, Oasis),
      (6, 4, Ruins),
      (7, 5, TradePost),
      (8, 7, Oasis),
    ],
  )
}

///|
fn level_19() -> @types.Level {
  build_level(
    "Treasure Vault",
    LostCity,
    0,
    3,
    9,
    3,
    20,
    25,
    4,
    [
      (1, 2, Ruins),
      (2, 3, Oasis),
      (3, 2, Ruins),
      (4, 3, TradePost),
      (5, 2, Ruins),
      (6, 3, Oasis),
      (7, 2, Ruins),
      (8, 3, TradePost),
      (3, 4, Dunes),
      (6, 4, Dunes),
    ],
  )
}

///|
fn level_20() -> @types.Level {
  build_level(
    "Labyrinth",
    LostCity,
    0,
    0,
    9,
    7,
    26,
    15,
    2,
    [
      (1, 0, Sandstorm),
      (3, 1, Sandstorm),
      (5, 2, Sandstorm),
      (7, 3, Sandstorm),
      (2, 5, Sandstorm),
      (4, 6, Sandstorm),
      (1, 1, Oasis),
      (2, 2, Oasis),
      (4, 3, Oasis),
      (6, 4, Oasis),
      (8, 5, Oasis),
      (3, 2, Ruins),
      (5, 4, Ruins),
      (7, 5, TradePost),
      (8, 6, TradePost),
    ],
  )
}

///|
fn level_21() -> @types.Level {
  build_level(
    "Mirage Run",
    LostCity,
    0,
    4,
    9,
    4,
    18,
    20,
    3,
    [
      (1, 3, Dunes),
      (1, 5, Dunes),
      (2, 4, Oasis),
      (3, 3, Ruins),
      (3, 5, Sandstorm),
      (4, 4, Oasis),
      (5, 3, TradePost),
      (5, 5, Sandstorm),
      (6, 4, Ruins),
      (7, 3, Oasis),
      (7, 5, Dunes),
      (8, 4, Ruins),
      (8, 3, TradePost),
    ],
  )
}

///|
fn level_22() -> @types.Level {
  build_level(
    "Scarab Passage",
    LostCity,
    0,
    0,
    9,
    6,
    22,
    20,
    4,
    [
      (1, 0, Dunes),
      (2, 1, Oasis),
      (3, 1, Ruins),
      (3, 2, Sandstorm),
      (4, 2, Oasis),
      (5, 3, Ruins),
      (5, 4, TradePost),
      (6, 4, Oasis),
      (6, 5, Sandstorm),
      (7, 5, Ruins),
      (8, 5, Oasis),
      (8, 6, Ruins),
      (7, 6, TradePost),
    ],
  )
}

///|
fn level_23() -> @types.Level {
  build_level(
    "Pharaoh's Way",
    LostCity,
    0,
    7,
    9,
    0,
    28,
    25,
    3,
    [
      (1, 6, Oasis),
      (2, 5, Ruins),
      (2, 6, Sandstorm),
      (3, 4, Oasis),
      (4, 3, TradePost),
      (4, 4, Sandstorm),
      (5, 2, Oasis),
      (6, 1, Ruins),
      (6, 2, Sandstorm),
      (7, 1, Oasis),
      (8, 0, Ruins),
      (8, 1, TradePost),
      (3, 5, Dunes),
      (5, 3, Dunes),
      (7, 2, Dunes),
    ],
  )
}

///|
fn level_24() -> @types.Level {
  build_level(
    "Eye of the Storm",
    LostCity,
    0,
    3,
    9,
    4,
    24,
    25,
    4,
    [
      (1, 2, Sandstorm),
      (1, 4, Sandstorm),
      (3, 1, Sandstorm),
      (3, 5, Sandstorm),
      (5, 1, Sandstorm),
      (5, 5, Sandstorm),
      (7, 2, Sandstorm),
      (7, 4, Sandstorm),
      (2, 3, Oasis),
      (4, 2, Ruins),
      (4, 3, TradePost),
      (4, 4, Ruins),
      (6, 3, Oasis),
      (6, 2, Ruins),
      (6, 4, Ruins),
      (8, 3, Oasis),
      (8, 4, TradePost),
    ],
  )
}

///|
fn level_25() -> @types.Level {
  build_level(
    "Lost City",
    LostCity,
    0,
    0,
    9,
    7,
    30,
    30,
    5,
    [
      (1, 1, Oasis),
      (2, 0, Sandstorm),
      (2, 2, Ruins),
      (3, 1, TradePost),
      (3, 3, Sandstorm),
      (4, 2, Oasis),
      (4, 4, Ruins),
      (5, 3, Sandstorm),
      (5, 5, Oasis),
      (6, 4, Ruins),
      (6, 6, TradePost),
      (7, 5, Ruins),
      (7, 6, Sandstorm),
      (8, 6, Oasis),
      (8, 5, Ruins),
      (1, 3, Dunes),
      (3, 5, Dunes),
      (5, 7, Dunes),
      (7, 7, TradePost),
    ],
  )
}
