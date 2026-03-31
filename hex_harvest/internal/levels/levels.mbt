///|
/// Load a level by global index (0-23)
pub fn load_level(index : Int) -> @types.Level {
  let world = index / @types.levels_per_world
  let level_in_world = index % @types.levels_per_world
  match world {
    0 => load_valley_level(level_in_world)
    1 => load_hills_level(level_in_world)
    2 => load_peaks_level(level_in_world)
    _ => @types.new_empty_level()
  }
}

///|
/// Helper: build a level from compact tile data
fn build_level(
  name : String,
  world : Int,
  tile_data : Array[(Int, Int, @types.TileKind, Int)],
  water_sources : Array[(Int, Int)],
  goals : Array[(Int, Int)],
  turn_budget : Int,
  target_yield : Int,
  par_turns : Int
) -> @types.Level {
  let grid = @types.new_grid(@types.grid_cols, @types.grid_rows)
  // Apply tile data
  for i in 0..<tile_data.length() {
    let (col, row, kind, height) = tile_data[i]
    if @types.hex_in_bounds(col, row) {
      let tile = grid.tiles[row][col]
      tile.kind = kind
      tile.height = height
      match kind {
        WaterSource | River => tile.watered = true
        _ => ()
      }
      match kind {
        River => tile.has_channel = true
        _ => ()
      }
    }
  }
  // Build water source list
  let ws : Array[@types.WaterSource] = []
  for i in 0..<water_sources.length() {
    let (c, r) = water_sources[i]
    ws.push({ col: c, row: r })
  }
  // Build goal list
  let gl : Array[@types.GoalPos] = []
  for i in 0..<goals.length() {
    let (c, r) = goals[i]
    gl.push({ col: c, row: r })
  }
  {
    grid,
    water_sources: ws,
    turn_budget,
    target_yield,
    goals: gl,
    par_turns,
    name,
    world,
  }
}

// ============================================================
// World 1: Valley - Flat terrain, basic water, learn crops
// ============================================================

///|
fn load_valley_level(idx : Int) -> @types.Level {
  match idx {
    0 => valley_01()
    1 => valley_02()
    2 => valley_03()
    3 => valley_04()
    4 => valley_05()
    5 => valley_06()
    6 => valley_07()
    7 => valley_08()
    _ => @types.new_empty_level()
  }
}

///|
fn valley_01() -> @types.Level {
  // "First Sprout" - Simple intro: one water source, plant wheat
  let data : Array[(Int, Int, @types.TileKind, Int)] = [
    (0, 0, Dirt, 1), (1, 0, Dirt, 1), (2, 0, Dirt, 1), (3, 0, Dirt, 0),
    (4, 0, Dirt, 0), (5, 0, Dirt, 0), (6, 0, Rock, 0), (7, 0, Rock, 0),
    (0, 1, Dirt, 1), (1, 1, WaterSource, 2), (2, 1, Dirt, 1), (3, 1, Dirt, 0),
    (4, 1, Dirt, 0), (5, 1, Dirt, 0), (6, 1, Rock, 0), (7, 1, Rock, 0),
    (0, 2, Dirt, 1), (1, 2, Dirt, 1), (2, 2, Dirt, 0), (3, 2, Dirt, 0),
    (4, 2, Dirt, 0), (5, 2, Rock, 0), (6, 2, Rock, 0), (7, 2, Rock, 0),
    (0, 3, Dirt, 0), (1, 3, Dirt, 0), (2, 3, Dirt, 0), (3, 3, Dirt, 0),
    (4, 3, Rock, 0), (5, 3, Rock, 0), (6, 3, Rock, 0), (7, 3, Rock, 0),
    (0, 4, Rock, 0), (1, 4, Dirt, 0), (2, 4, Dirt, 0), (3, 4, Rock, 0),
    (4, 4, Rock, 0), (5, 4, Rock, 0), (6, 4, Rock, 0), (7, 4, Rock, 0),
    (0, 5, Rock, 0), (1, 5, Rock, 0), (2, 5, Rock, 0), (3, 5, Rock, 0),
    (4, 5, Rock, 0), (5, 5, Rock, 0), (6, 5, Rock, 0), (7, 5, Rock, 0),
  ]
  build_level(
    "First Sprout", 0, data, [(1, 1)], [], 8, 3, 5,
  )
}

///|
fn valley_02() -> @types.Level {
  // "Flowing Fields" - Water flows downhill to reach crops
  let data : Array[(Int, Int, @types.TileKind, Int)] = [
    (0, 0, Rock, 0), (1, 0, Rock, 0), (2, 0, Dirt, 2), (3, 0, Dirt, 2),
    (4, 0, Dirt, 1), (5, 0, Dirt, 1), (6, 0, Dirt, 0), (7, 0, Dirt, 0),
    (0, 1, Rock, 0), (1, 1, Dirt, 2), (2, 1, WaterSource, 3), (3, 1, Dirt, 2),
    (4, 1, Dirt, 1), (5, 1, Dirt, 1), (6, 1, Dirt, 0), (7, 1, Dirt, 0),
    (0, 2, Rock, 0), (1, 2, Dirt, 2), (2, 2, Dirt, 2), (3, 2, Dirt, 1),
    (4, 2, Dirt, 1), (5, 2, Dirt, 0), (6, 2, Dirt, 0), (7, 2, Rock, 0),
    (0, 3, Rock, 0), (1, 3, Dirt, 1), (2, 3, Dirt, 1), (3, 3, Dirt, 1),
    (4, 3, Dirt, 0), (5, 3, Dirt, 0), (6, 3, Rock, 0), (7, 3, Rock, 0),
    (0, 4, Rock, 0), (1, 4, Dirt, 1), (2, 4, Dirt, 0), (3, 4, Dirt, 0),
    (4, 4, Dirt, 0), (5, 4, Rock, 0), (6, 4, Rock, 0), (7, 4, Rock, 0),
    (0, 5, Rock, 0), (1, 5, Rock, 0), (2, 5, Rock, 0), (3, 5, Rock, 0),
    (4, 5, Rock, 0), (5, 5, Rock, 0), (6, 5, Rock, 0), (7, 5, Rock, 0),
  ]
  build_level(
    "Flowing Fields", 0, data, [(2, 1)], [], 10, 5, 7,
  )
}

///|
fn valley_03() -> @types.Level {
  // "Wheat Cluster" - Learn adjacency: plant wheat near wheat
  let data : Array[(Int, Int, @types.TileKind, Int)] = [
    (0, 0, Dirt, 1), (1, 0, Dirt, 1), (2, 0, Dirt, 1), (3, 0, Dirt, 1),
    (4, 0, Dirt, 0), (5, 0, Dirt, 0), (6, 0, Rock, 0), (7, 0, Rock, 0),
    (0, 1, Dirt, 1), (1, 1, WaterSource, 2), (2, 1, Dirt, 1), (3, 1, Dirt, 1),
    (4, 1, Dirt, 0), (5, 1, Dirt, 0), (6, 1, Rock, 0), (7, 1, Rock, 0),
    (0, 2, Dirt, 1), (1, 2, Dirt, 1), (2, 2, Dirt, 1), (3, 2, Dirt, 0),
    (4, 2, Dirt, 0), (5, 2, Dirt, 0), (6, 2, Rock, 0), (7, 2, Rock, 0),
    (0, 3, Dirt, 0), (1, 3, Dirt, 0), (2, 3, Dirt, 0), (3, 3, Dirt, 0),
    (4, 3, Dirt, 0), (5, 3, Rock, 0), (6, 3, Rock, 0), (7, 3, Rock, 0),
    (0, 4, Dirt, 0), (1, 4, Dirt, 0), (2, 4, Dirt, 0), (3, 4, Rock, 0),
    (4, 4, Rock, 0), (5, 4, Rock, 0), (6, 4, Rock, 0), (7, 4, Rock, 0),
    (0, 5, Rock, 0), (1, 5, Rock, 0), (2, 5, Rock, 0), (3, 5, Rock, 0),
    (4, 5, Rock, 0), (5, 5, Rock, 0), (6, 5, Rock, 0), (7, 5, Rock, 0),
  ]
  build_level(
    "Wheat Cluster", 0, data, [(1, 1)], [], 10, 8, 7,
  )
}

///|
fn valley_04() -> @types.Level {
  // "Corn Valley" - Introduction of corn (higher yield, longer grow)
  let data : Array[(Int, Int, @types.TileKind, Int)] = [
    (0, 0, Dirt, 1), (1, 0, Dirt, 1), (2, 0, Dirt, 1), (3, 0, Dirt, 1),
    (4, 0, Dirt, 1), (5, 0, Dirt, 0), (6, 0, Rock, 0), (7, 0, Rock, 0),
    (0, 1, WaterSource, 2), (1, 1, Dirt, 1), (2, 1, Dirt, 1), (3, 1, Dirt, 1),
    (4, 1, Dirt, 0), (5, 1, Dirt, 0), (6, 1, Rock, 0), (7, 1, Rock, 0),
    (0, 2, Dirt, 1), (1, 2, Dirt, 1), (2, 2, Dirt, 0), (3, 2, Dirt, 0),
    (4, 2, Dirt, 0), (5, 2, Dirt, 0), (6, 2, Rock, 0), (7, 2, Rock, 0),
    (0, 3, Dirt, 0), (1, 3, Dirt, 0), (2, 3, Dirt, 0), (3, 3, Dirt, 0),
    (4, 3, Dirt, 0), (5, 3, Dirt, 0), (6, 3, Rock, 0), (7, 3, Rock, 0),
    (0, 4, Dirt, 0), (1, 4, Dirt, 0), (2, 4, Dirt, 0), (3, 4, Dirt, 0),
    (4, 4, Rock, 0), (5, 4, Rock, 0), (6, 4, Rock, 0), (7, 4, Rock, 0),
    (0, 5, Rock, 0), (1, 5, Rock, 0), (2, 5, Rock, 0), (3, 5, Rock, 0),
    (4, 5, Rock, 0), (5, 5, Rock, 0), (6, 5, Rock, 0), (7, 5, Rock, 0),
  ]
  build_level(
    "Corn Valley", 0, data, [(0, 1)], [], 12, 10, 9,
  )
}

///|
fn valley_05() -> @types.Level {
  // "Flower Power" - Intro flowers as adjacency specialists
  let data : Array[(Int, Int, @types.TileKind, Int)] = [
    (0, 0, Rock, 0), (1, 0, Dirt, 1), (2, 0, Dirt, 1), (3, 0, Dirt, 1),
    (4, 0, Dirt, 1), (5, 0, Rock, 0), (6, 0, Rock, 0), (7, 0, Rock, 0),
    (0, 1, Dirt, 1), (1, 1, Dirt, 1), (2, 1, WaterSource, 2), (3, 1, Dirt, 1),
    (4, 1, Dirt, 1), (5, 1, Dirt, 0), (6, 1, Rock, 0), (7, 1, Rock, 0),
    (0, 2, Dirt, 1), (1, 2, Dirt, 1), (2, 2, Dirt, 1), (3, 2, Dirt, 1),
    (4, 2, Dirt, 0), (5, 2, Dirt, 0), (6, 2, Rock, 0), (7, 2, Rock, 0),
    (0, 3, Dirt, 0), (1, 3, Dirt, 0), (2, 3, Dirt, 0), (3, 3, Dirt, 0),
    (4, 3, Dirt, 0), (5, 3, Rock, 0), (6, 3, Rock, 0), (7, 3, Rock, 0),
    (0, 4, Rock, 0), (1, 4, Dirt, 0), (2, 4, Dirt, 0), (3, 4, Rock, 0),
    (4, 4, Rock, 0), (5, 4, Rock, 0), (6, 4, Rock, 0), (7, 4, Rock, 0),
    (0, 5, Rock, 0), (1, 5, Rock, 0), (2, 5, Rock, 0), (3, 5, Rock, 0),
    (4, 5, Rock, 0), (5, 5, Rock, 0), (6, 5, Rock, 0), (7, 5, Rock, 0),
  ]
  build_level(
    "Flower Power", 0, data, [(2, 1)], [], 10, 8, 7,
  )
}

///|
fn valley_06() -> @types.Level {
  // "Berry Patch" - Berries: high yield, slow grow
  let data : Array[(Int, Int, @types.TileKind, Int)] = [
    (0, 0, Dirt, 1), (1, 0, Dirt, 1), (2, 0, Dirt, 2), (3, 0, Dirt, 2),
    (4, 0, Dirt, 1), (5, 0, Dirt, 1), (6, 0, Rock, 0), (7, 0, Rock, 0),
    (0, 1, Dirt, 1), (1, 1, WaterSource, 3), (2, 1, Dirt, 2), (3, 1, Dirt, 2),
    (4, 1, Dirt, 1), (5, 1, Dirt, 1), (6, 1, Dirt, 0), (7, 1, Rock, 0),
    (0, 2, Dirt, 1), (1, 2, Dirt, 2), (2, 2, Dirt, 1), (3, 2, Dirt, 1),
    (4, 2, Dirt, 0), (5, 2, Dirt, 0), (6, 2, Dirt, 0), (7, 2, Rock, 0),
    (0, 3, Dirt, 0), (1, 3, Dirt, 1), (2, 3, Dirt, 1), (3, 3, Dirt, 0),
    (4, 3, Dirt, 0), (5, 3, Dirt, 0), (6, 3, Rock, 0), (7, 3, Rock, 0),
    (0, 4, Dirt, 0), (1, 4, Dirt, 0), (2, 4, Dirt, 0), (3, 4, Dirt, 0),
    (4, 4, Rock, 0), (5, 4, Rock, 0), (6, 4, Rock, 0), (7, 4, Rock, 0),
    (0, 5, Rock, 0), (1, 5, Rock, 0), (2, 5, Rock, 0), (3, 5, Rock, 0),
    (4, 5, Rock, 0), (5, 5, Rock, 0), (6, 5, Rock, 0), (7, 5, Rock, 0),
  ]
  build_level(
    "Berry Patch", 0, data, [(1, 1)], [], 14, 12, 10,
  )
}

///|
fn valley_07() -> @types.Level {
  // "Combo Garden" - Wheat+Corn combo bonus
  let data : Array[(Int, Int, @types.TileKind, Int)] = [
    (0, 0, Dirt, 1), (1, 0, Dirt, 1), (2, 0, Dirt, 1), (3, 0, Dirt, 1),
    (4, 0, Dirt, 1), (5, 0, Dirt, 1), (6, 0, Rock, 0), (7, 0, Rock, 0),
    (0, 1, Dirt, 1), (1, 1, Dirt, 1), (2, 1, WaterSource, 2), (3, 1, Dirt, 1),
    (4, 1, Dirt, 1), (5, 1, Dirt, 1), (6, 1, Rock, 0), (7, 1, Rock, 0),
    (0, 2, Dirt, 1), (1, 2, Dirt, 1), (2, 2, Dirt, 1), (3, 2, Dirt, 1),
    (4, 2, Dirt, 0), (5, 2, Dirt, 0), (6, 2, Rock, 0), (7, 2, Rock, 0),
    (0, 3, Dirt, 0), (1, 3, Dirt, 0), (2, 3, Dirt, 0), (3, 3, Dirt, 0),
    (4, 3, Dirt, 0), (5, 3, Rock, 0), (6, 3, Rock, 0), (7, 3, Rock, 0),
    (0, 4, Dirt, 0), (1, 4, Dirt, 0), (2, 4, Rock, 0), (3, 4, Rock, 0),
    (4, 4, Rock, 0), (5, 4, Rock, 0), (6, 4, Rock, 0), (7, 4, Rock, 0),
    (0, 5, Rock, 0), (1, 5, Rock, 0), (2, 5, Rock, 0), (3, 5, Rock, 0),
    (4, 5, Rock, 0), (5, 5, Rock, 0), (6, 5, Rock, 0), (7, 5, Rock, 0),
  ]
  build_level(
    "Combo Garden", 0, data, [(2, 1)], [], 12, 14, 9,
  )
}

///|
fn valley_08() -> @types.Level {
  // "Valley Harvest" - Goal tiles, full Valley mechanics
  let data : Array[(Int, Int, @types.TileKind, Int)] = [
    (0, 0, Dirt, 2), (1, 0, Dirt, 2), (2, 0, Dirt, 2), (3, 0, Dirt, 1),
    (4, 0, Dirt, 1), (5, 0, Dirt, 1), (6, 0, Dirt, 0), (7, 0, Rock, 0),
    (0, 1, Dirt, 2), (1, 1, WaterSource, 3), (2, 1, Dirt, 2), (3, 1, Dirt, 1),
    (4, 1, Dirt, 1), (5, 1, Goal, 1), (6, 1, Dirt, 0), (7, 1, Rock, 0),
    (0, 2, Dirt, 2), (1, 2, Dirt, 2), (2, 2, Dirt, 1), (3, 2, Dirt, 1),
    (4, 2, Dirt, 0), (5, 2, Dirt, 0), (6, 2, Dirt, 0), (7, 2, Rock, 0),
    (0, 3, Dirt, 1), (1, 3, Dirt, 1), (2, 3, Dirt, 1), (3, 3, Dirt, 0),
    (4, 3, Dirt, 0), (5, 3, Goal, 0), (6, 3, Rock, 0), (7, 3, Rock, 0),
    (0, 4, Dirt, 0), (1, 4, Dirt, 0), (2, 4, Dirt, 0), (3, 4, Dirt, 0),
    (4, 4, Rock, 0), (5, 4, Rock, 0), (6, 4, Rock, 0), (7, 4, Rock, 0),
    (0, 5, Rock, 0), (1, 5, Rock, 0), (2, 5, Rock, 0), (3, 5, Rock, 0),
    (4, 5, Rock, 0), (5, 5, Rock, 0), (6, 5, Rock, 0), (7, 5, Rock, 0),
  ]
  build_level(
    "Valley Harvest", 0, data, [(1, 1)], [(5, 1), (5, 3)], 15, 18, 11,
  )
}

// ============================================================
// World 2: Hills - Height variation, channels, water routing
// ============================================================

///|
fn load_hills_level(idx : Int) -> @types.Level {
  match idx {
    0 => hills_01()
    1 => hills_02()
    2 => hills_03()
    3 => hills_04()
    4 => hills_05()
    5 => hills_06()
    6 => hills_07()
    7 => hills_08()
    _ => @types.new_empty_level()
  }
}

///|
fn hills_01() -> @types.Level {
  // "Rolling Start" - Gentle hills, learn height differences
  let data : Array[(Int, Int, @types.TileKind, Int)] = [
    (0, 0, Dirt, 3), (1, 0, Dirt, 3), (2, 0, Dirt, 2), (3, 0, Dirt, 2),
    (4, 0, Dirt, 1), (5, 0, Dirt, 1), (6, 0, Dirt, 0), (7, 0, Dirt, 0),
    (0, 1, WaterSource, 3), (1, 1, Dirt, 3), (2, 1, Dirt, 2), (3, 1, Dirt, 2),
    (4, 1, Dirt, 1), (5, 1, Dirt, 1), (6, 1, Dirt, 0), (7, 1, Dirt, 0),
    (0, 2, Dirt, 2), (1, 2, Dirt, 2), (2, 2, Dirt, 2), (3, 2, Dirt, 1),
    (4, 2, Dirt, 1), (5, 2, Dirt, 0), (6, 2, Dirt, 0), (7, 2, Rock, 0),
    (0, 3, Dirt, 1), (1, 3, Dirt, 1), (2, 3, Dirt, 1), (3, 3, Dirt, 1),
    (4, 3, Dirt, 0), (5, 3, Dirt, 0), (6, 3, Rock, 0), (7, 3, Rock, 0),
    (0, 4, Dirt, 0), (1, 4, Dirt, 0), (2, 4, Dirt, 0), (3, 4, Dirt, 0),
    (4, 4, Dirt, 0), (5, 4, Rock, 0), (6, 4, Rock, 0), (7, 4, Rock, 0),
    (0, 5, Rock, 0), (1, 5, Dirt, 0), (2, 5, Dirt, 0), (3, 5, Rock, 0),
    (4, 5, Rock, 0), (5, 5, Rock, 0), (6, 5, Rock, 0), (7, 5, Rock, 0),
  ]
  build_level(
    "Rolling Start", 1, data, [(0, 1)], [], 12, 8, 9,
  )
}

///|
fn hills_02() -> @types.Level {
  // "Channel Basics" - First channel placement
  let data : Array[(Int, Int, @types.TileKind, Int)] = [
    (0, 0, Rock, 0), (1, 0, Dirt, 2), (2, 0, Dirt, 2), (3, 0, Dirt, 2),
    (4, 0, Dirt, 2), (5, 0, Rock, 0), (6, 0, Rock, 0), (7, 0, Rock, 0),
    (0, 1, Dirt, 2), (1, 1, WaterSource, 3), (2, 1, Dirt, 2), (3, 1, Rock, 2),
    (4, 1, Dirt, 2), (5, 1, Dirt, 1), (6, 1, Rock, 0), (7, 1, Rock, 0),
    (0, 2, Dirt, 2), (1, 2, Dirt, 2), (2, 2, Dirt, 2), (3, 2, Dirt, 2),
    (4, 2, Dirt, 1), (5, 2, Dirt, 1), (6, 2, Rock, 0), (7, 2, Rock, 0),
    (0, 3, Dirt, 1), (1, 3, Dirt, 1), (2, 3, Dirt, 1), (3, 3, Dirt, 1),
    (4, 3, Dirt, 0), (5, 3, Dirt, 0), (6, 3, Rock, 0), (7, 3, Rock, 0),
    (0, 4, Dirt, 0), (1, 4, Dirt, 0), (2, 4, Dirt, 0), (3, 4, Dirt, 0),
    (4, 4, Rock, 0), (5, 4, Rock, 0), (6, 4, Rock, 0), (7, 4, Rock, 0),
    (0, 5, Rock, 0), (1, 5, Rock, 0), (2, 5, Rock, 0), (3, 5, Rock, 0),
    (4, 5, Rock, 0), (5, 5, Rock, 0), (6, 5, Rock, 0), (7, 5, Rock, 0),
  ]
  build_level(
    "Channel Basics", 1, data, [(1, 1)], [], 12, 10, 9,
  )
}

///|
fn hills_03() -> @types.Level {
  // "Terraced Fields" - Step terrain with multiple heights
  let data : Array[(Int, Int, @types.TileKind, Int)] = [
    (0, 0, WaterSource, 3), (1, 0, Dirt, 3), (2, 0, Dirt, 2), (3, 0, Dirt, 2),
    (4, 0, Dirt, 1), (5, 0, Dirt, 1), (6, 0, Dirt, 0), (7, 0, Dirt, 0),
    (0, 1, Dirt, 3), (1, 1, Dirt, 3), (2, 1, Rock, 2), (3, 1, Dirt, 2),
    (4, 1, Dirt, 1), (5, 1, Dirt, 1), (6, 1, Dirt, 0), (7, 1, Dirt, 0),
    (0, 2, Dirt, 2), (1, 2, Dirt, 2), (2, 2, Dirt, 2), (3, 2, Rock, 1),
    (4, 2, Dirt, 1), (5, 2, Dirt, 0), (6, 2, Dirt, 0), (7, 2, Rock, 0),
    (0, 3, Dirt, 1), (1, 3, Dirt, 1), (2, 3, Dirt, 1), (3, 3, Dirt, 1),
    (4, 3, Rock, 0), (5, 3, Dirt, 0), (6, 3, Rock, 0), (7, 3, Rock, 0),
    (0, 4, Dirt, 0), (1, 4, Dirt, 0), (2, 4, Dirt, 0), (3, 4, Dirt, 0),
    (4, 4, Dirt, 0), (5, 4, Rock, 0), (6, 4, Rock, 0), (7, 4, Rock, 0),
    (0, 5, Rock, 0), (1, 5, Dirt, 0), (2, 5, Dirt, 0), (3, 5, Rock, 0),
    (4, 5, Rock, 0), (5, 5, Rock, 0), (6, 5, Rock, 0), (7, 5, Rock, 0),
  ]
  build_level(
    "Terraced Fields", 1, data, [(0, 0)], [], 14, 12, 10,
  )
}

///|
fn hills_04() -> @types.Level {
  // "River Bend" - Pre-placed river tiles
  let data : Array[(Int, Int, @types.TileKind, Int)] = [
    (0, 0, Dirt, 2), (1, 0, Dirt, 2), (2, 0, Dirt, 1), (3, 0, Dirt, 1),
    (4, 0, Dirt, 0), (5, 0, Dirt, 0), (6, 0, Dirt, 0), (7, 0, Rock, 0),
    (0, 1, WaterSource, 3), (1, 1, River, 2), (2, 1, River, 1), (3, 1, Dirt, 1),
    (4, 1, Dirt, 0), (5, 1, Dirt, 0), (6, 1, Dirt, 0), (7, 1, Rock, 0),
    (0, 2, Dirt, 2), (1, 2, Dirt, 2), (2, 2, River, 1), (3, 2, River, 0),
    (4, 2, Dirt, 0), (5, 2, Dirt, 0), (6, 2, Rock, 0), (7, 2, Rock, 0),
    (0, 3, Dirt, 1), (1, 3, Dirt, 1), (2, 3, Dirt, 1), (3, 3, Dirt, 0),
    (4, 3, Dirt, 0), (5, 3, Rock, 0), (6, 3, Rock, 0), (7, 3, Rock, 0),
    (0, 4, Dirt, 0), (1, 4, Dirt, 0), (2, 4, Dirt, 0), (3, 4, Dirt, 0),
    (4, 4, Rock, 0), (5, 4, Rock, 0), (6, 4, Rock, 0), (7, 4, Rock, 0),
    (0, 5, Rock, 0), (1, 5, Rock, 0), (2, 5, Rock, 0), (3, 5, Rock, 0),
    (4, 5, Rock, 0), (5, 5, Rock, 0), (6, 5, Rock, 0), (7, 5, Rock, 0),
  ]
  build_level(
    "River Bend", 1, data, [(0, 1)], [], 14, 14, 10,
  )
}

///|
fn hills_05() -> @types.Level {
  // "Split Stream" - Water source splits into two paths
  let data : Array[(Int, Int, @types.TileKind, Int)] = [
    (0, 0, Dirt, 1), (1, 0, Dirt, 2), (2, 0, Dirt, 3), (3, 0, Dirt, 3),
    (4, 0, Dirt, 2), (5, 0, Dirt, 1), (6, 0, Dirt, 0), (7, 0, Rock, 0),
    (0, 1, Dirt, 1), (1, 1, Dirt, 2), (2, 1, WaterSource, 3), (3, 1, Dirt, 3),
    (4, 1, Dirt, 2), (5, 1, Dirt, 1), (6, 1, Dirt, 0), (7, 1, Rock, 0),
    (0, 2, Dirt, 1), (1, 2, Dirt, 2), (2, 2, Rock, 3), (3, 2, Dirt, 2),
    (4, 2, Dirt, 1), (5, 2, Dirt, 0), (6, 2, Dirt, 0), (7, 2, Rock, 0),
    (0, 3, Dirt, 0), (1, 3, Dirt, 1), (2, 3, Dirt, 1), (3, 3, Dirt, 1),
    (4, 3, Dirt, 0), (5, 3, Dirt, 0), (6, 3, Rock, 0), (7, 3, Rock, 0),
    (0, 4, Dirt, 0), (1, 4, Dirt, 0), (2, 4, Dirt, 0), (3, 4, Dirt, 0),
    (4, 4, Dirt, 0), (5, 4, Rock, 0), (6, 4, Rock, 0), (7, 4, Rock, 0),
    (0, 5, Rock, 0), (1, 5, Dirt, 0), (2, 5, Dirt, 0), (3, 5, Dirt, 0),
    (4, 5, Rock, 0), (5, 5, Rock, 0), (6, 5, Rock, 0), (7, 5, Rock, 0),
  ]
  build_level(
    "Split Stream", 1, data, [(2, 1)], [], 14, 14, 10,
  )
}

///|
fn hills_06() -> @types.Level {
  // "Highland Goals" - Goal tiles on hills
  let data : Array[(Int, Int, @types.TileKind, Int)] = [
    (0, 0, Dirt, 3), (1, 0, Dirt, 3), (2, 0, Dirt, 2), (3, 0, Dirt, 2),
    (4, 0, Dirt, 1), (5, 0, Dirt, 1), (6, 0, Dirt, 0), (7, 0, Rock, 0),
    (0, 1, WaterSource, 3), (1, 1, Dirt, 3), (2, 1, Goal, 2), (3, 1, Dirt, 2),
    (4, 1, Dirt, 1), (5, 1, Dirt, 1), (6, 1, Dirt, 0), (7, 1, Rock, 0),
    (0, 2, Dirt, 2), (1, 2, Dirt, 2), (2, 2, Dirt, 2), (3, 2, Dirt, 1),
    (4, 2, Dirt, 1), (5, 2, Dirt, 0), (6, 2, Dirt, 0), (7, 2, Rock, 0),
    (0, 3, Dirt, 1), (1, 3, Dirt, 1), (2, 3, Dirt, 1), (3, 3, Goal, 1),
    (4, 3, Dirt, 0), (5, 3, Dirt, 0), (6, 3, Rock, 0), (7, 3, Rock, 0),
    (0, 4, Dirt, 0), (1, 4, Dirt, 0), (2, 4, Dirt, 0), (3, 4, Dirt, 0),
    (4, 4, Dirt, 0), (5, 4, Goal, 0), (6, 4, Rock, 0), (7, 4, Rock, 0),
    (0, 5, Rock, 0), (1, 5, Dirt, 0), (2, 5, Dirt, 0), (3, 5, Rock, 0),
    (4, 5, Rock, 0), (5, 5, Rock, 0), (6, 5, Rock, 0), (7, 5, Rock, 0),
  ]
  build_level(
    "Highland Goals", 1, data, [(0, 1)], [(2, 1), (3, 3), (5, 4)], 16, 16, 12,
  )
}

///|
fn hills_07() -> @types.Level {
  // "Cascade" - Long cascading water path
  let data : Array[(Int, Int, @types.TileKind, Int)] = [
    (0, 0, WaterSource, 3), (1, 0, Dirt, 3), (2, 0, Rock, 3), (3, 0, Dirt, 2),
    (4, 0, Dirt, 2), (5, 0, Rock, 1), (6, 0, Dirt, 1), (7, 0, Dirt, 0),
    (0, 1, Dirt, 3), (1, 1, Dirt, 2), (2, 1, Dirt, 2), (3, 1, Rock, 2),
    (4, 1, Dirt, 1), (5, 1, Dirt, 1), (6, 1, Dirt, 0), (7, 1, Dirt, 0),
    (0, 2, Dirt, 2), (1, 2, Rock, 2), (2, 2, Dirt, 2), (3, 2, Dirt, 1),
    (4, 2, Rock, 1), (5, 2, Dirt, 0), (6, 2, Dirt, 0), (7, 2, Dirt, 0),
    (0, 3, Dirt, 1), (1, 3, Dirt, 1), (2, 3, Dirt, 1), (3, 3, Dirt, 1),
    (4, 3, Dirt, 0), (5, 3, Rock, 0), (6, 3, Dirt, 0), (7, 3, Rock, 0),
    (0, 4, Dirt, 0), (1, 4, Dirt, 0), (2, 4, Dirt, 0), (3, 4, Dirt, 0),
    (4, 4, Dirt, 0), (5, 4, Dirt, 0), (6, 4, Rock, 0), (7, 4, Rock, 0),
    (0, 5, Rock, 0), (1, 5, Dirt, 0), (2, 5, Dirt, 0), (3, 5, Dirt, 0),
    (4, 5, Rock, 0), (5, 5, Rock, 0), (6, 5, Rock, 0), (7, 5, Rock, 0),
  ]
  build_level(
    "Cascade", 1, data, [(0, 0)], [], 16, 18, 12,
  )
}

///|
fn hills_08() -> @types.Level {
  // "Hill Master" - All hills mechanics combined
  let data : Array[(Int, Int, @types.TileKind, Int)] = [
    (0, 0, Dirt, 3), (1, 0, Dirt, 3), (2, 0, Dirt, 2), (3, 0, Dirt, 2),
    (4, 0, Dirt, 2), (5, 0, Dirt, 1), (6, 0, Dirt, 1), (7, 0, Dirt, 0),
    (0, 1, WaterSource, 3), (1, 1, Dirt, 3), (2, 1, River, 2), (3, 1, Goal, 2),
    (4, 1, Dirt, 1), (5, 1, Dirt, 1), (6, 1, Dirt, 0), (7, 1, Dirt, 0),
    (0, 2, Dirt, 2), (1, 2, Dirt, 2), (2, 2, River, 1), (3, 2, Dirt, 1),
    (4, 2, Dirt, 1), (5, 2, Goal, 0), (6, 2, Dirt, 0), (7, 2, Rock, 0),
    (0, 3, Dirt, 1), (1, 3, Dirt, 1), (2, 3, Dirt, 1), (3, 3, Dirt, 0),
    (4, 3, Dirt, 0), (5, 3, Dirt, 0), (6, 3, Rock, 0), (7, 3, Rock, 0),
    (0, 4, Dirt, 0), (1, 4, Dirt, 0), (2, 4, Goal, 0), (3, 4, Dirt, 0),
    (4, 4, Dirt, 0), (5, 4, Rock, 0), (6, 4, Rock, 0), (7, 4, Rock, 0),
    (0, 5, Rock, 0), (1, 5, Dirt, 0), (2, 5, Dirt, 0), (3, 5, Dirt, 0),
    (4, 5, Rock, 0), (5, 5, Rock, 0), (6, 5, Rock, 0), (7, 5, Rock, 0),
  ]
  build_level(
    "Hill Master", 1, data,
    [(0, 1)], [(3, 1), (5, 2), (2, 4)], 18, 22, 14,
  )
}

// ============================================================
// World 3: Peaks - Complex terrain, limited water, all mechanics
// ============================================================

///|
fn load_peaks_level(idx : Int) -> @types.Level {
  match idx {
    0 => peaks_01()
    1 => peaks_02()
    2 => peaks_03()
    3 => peaks_04()
    4 => peaks_05()
    5 => peaks_06()
    6 => peaks_07()
    7 => peaks_08()
    _ => @types.new_empty_level()
  }
}

///|
fn peaks_01() -> @types.Level {
  // "Mountain Spring" - High peak with single water source
  let data : Array[(Int, Int, @types.TileKind, Int)] = [
    (0, 0, Rock, 0), (1, 0, Rock, 0), (2, 0, Dirt, 3), (3, 0, Dirt, 3),
    (4, 0, Dirt, 3), (5, 0, Rock, 0), (6, 0, Rock, 0), (7, 0, Rock, 0),
    (0, 1, Rock, 0), (1, 1, Dirt, 3), (2, 1, Dirt, 3), (3, 1, WaterSource, 3),
    (4, 1, Dirt, 3), (5, 1, Dirt, 2), (6, 1, Rock, 0), (7, 1, Rock, 0),
    (0, 2, Dirt, 2), (1, 2, Dirt, 2), (2, 2, Dirt, 2), (3, 2, Dirt, 2),
    (4, 2, Dirt, 2), (5, 2, Dirt, 1), (6, 2, Dirt, 1), (7, 2, Rock, 0),
    (0, 3, Dirt, 1), (1, 3, Dirt, 1), (2, 3, Dirt, 1), (3, 3, Dirt, 1),
    (4, 3, Dirt, 1), (5, 3, Dirt, 0), (6, 3, Dirt, 0), (7, 3, Rock, 0),
    (0, 4, Dirt, 0), (1, 4, Dirt, 0), (2, 4, Dirt, 0), (3, 4, Dirt, 0),
    (4, 4, Dirt, 0), (5, 4, Dirt, 0), (6, 4, Rock, 0), (7, 4, Rock, 0),
    (0, 5, Rock, 0), (1, 5, Dirt, 0), (2, 5, Dirt, 0), (3, 5, Dirt, 0),
    (4, 5, Rock, 0), (5, 5, Rock, 0), (6, 5, Rock, 0), (7, 5, Rock, 0),
  ]
  build_level(
    "Mountain Spring", 2, data, [(3, 1)], [], 14, 12, 10,
  )
}

///|
fn peaks_02() -> @types.Level {
  // "Narrow Path" - Water must navigate through gaps
  let data : Array[(Int, Int, @types.TileKind, Int)] = [
    (0, 0, WaterSource, 3), (1, 0, Dirt, 3), (2, 0, Rock, 3), (3, 0, Dirt, 2),
    (4, 0, Rock, 2), (5, 0, Dirt, 1), (6, 0, Rock, 1), (7, 0, Dirt, 0),
    (0, 1, Dirt, 3), (1, 1, Rock, 3), (2, 1, Dirt, 2), (3, 1, Rock, 2),
    (4, 1, Dirt, 1), (5, 1, Rock, 1), (6, 1, Dirt, 0), (7, 1, Dirt, 0),
    (0, 2, Dirt, 2), (1, 2, Dirt, 2), (2, 2, Rock, 2), (3, 2, Dirt, 1),
    (4, 2, Dirt, 1), (5, 2, Dirt, 0), (6, 2, Dirt, 0), (7, 2, Rock, 0),
    (0, 3, Dirt, 1), (1, 3, Rock, 1), (2, 3, Dirt, 1), (3, 3, Rock, 0),
    (4, 3, Dirt, 0), (5, 3, Dirt, 0), (6, 3, Rock, 0), (7, 3, Rock, 0),
    (0, 4, Dirt, 0), (1, 4, Dirt, 0), (2, 4, Rock, 0), (3, 4, Dirt, 0),
    (4, 4, Dirt, 0), (5, 4, Rock, 0), (6, 4, Rock, 0), (7, 4, Rock, 0),
    (0, 5, Rock, 0), (1, 5, Dirt, 0), (2, 5, Dirt, 0), (3, 5, Rock, 0),
    (4, 5, Rock, 0), (5, 5, Rock, 0), (6, 5, Rock, 0), (7, 5, Rock, 0),
  ]
  build_level(
    "Narrow Path", 2, data, [(0, 0)], [], 16, 12, 12,
  )
}

///|
fn peaks_03() -> @types.Level {
  // "Twin Peaks" - Two water sources, separate valleys
  let data : Array[(Int, Int, @types.TileKind, Int)] = [
    (0, 0, WaterSource, 3), (1, 0, Dirt, 2), (2, 0, Rock, 3), (3, 0, Rock, 3),
    (4, 0, Rock, 3), (5, 0, Dirt, 2), (6, 0, WaterSource, 3), (7, 0, Rock, 0),
    (0, 1, Dirt, 2), (1, 1, Dirt, 2), (2, 1, Rock, 3), (3, 1, Dirt, 1),
    (4, 1, Rock, 3), (5, 1, Dirt, 2), (6, 1, Dirt, 2), (7, 1, Rock, 0),
    (0, 2, Dirt, 1), (1, 2, Dirt, 1), (2, 2, Dirt, 1), (3, 2, Dirt, 1),
    (4, 2, Dirt, 1), (5, 2, Dirt, 1), (6, 2, Dirt, 1), (7, 2, Rock, 0),
    (0, 3, Dirt, 0), (1, 3, Dirt, 0), (2, 3, Dirt, 0), (3, 3, Goal, 0),
    (4, 3, Dirt, 0), (5, 3, Dirt, 0), (6, 3, Dirt, 0), (7, 3, Rock, 0),
    (0, 4, Dirt, 0), (1, 4, Dirt, 0), (2, 4, Rock, 0), (3, 4, Dirt, 0),
    (4, 4, Rock, 0), (5, 4, Dirt, 0), (6, 4, Dirt, 0), (7, 4, Rock, 0),
    (0, 5, Rock, 0), (1, 5, Rock, 0), (2, 5, Rock, 0), (3, 5, Rock, 0),
    (4, 5, Rock, 0), (5, 5, Rock, 0), (6, 5, Rock, 0), (7, 5, Rock, 0),
  ]
  build_level(
    "Twin Peaks", 2, data, [(0, 0), (6, 0)], [(3, 3)], 16, 16, 12,
  )
}

///|
fn peaks_04() -> @types.Level {
  // "Aqueduct" - Long channel puzzle
  let data : Array[(Int, Int, @types.TileKind, Int)] = [
    (0, 0, WaterSource, 3), (1, 0, Dirt, 3), (2, 0, Rock, 0), (3, 0, Rock, 0),
    (4, 0, Rock, 0), (5, 0, Dirt, 2), (6, 0, Dirt, 2), (7, 0, Dirt, 1),
    (0, 1, Dirt, 3), (1, 1, Dirt, 3), (2, 1, Dirt, 3), (3, 1, Dirt, 3),
    (4, 1, Dirt, 3), (5, 1, Dirt, 2), (6, 1, Dirt, 1), (7, 1, Dirt, 1),
    (0, 2, Rock, 0), (1, 2, Rock, 0), (2, 2, Rock, 0), (3, 2, Rock, 0),
    (4, 2, Dirt, 2), (5, 2, Dirt, 2), (6, 2, Dirt, 1), (7, 2, Dirt, 0),
    (0, 3, Dirt, 1), (1, 3, Dirt, 1), (2, 3, Dirt, 1), (3, 3, Dirt, 1),
    (4, 3, Dirt, 1), (5, 3, Dirt, 1), (6, 3, Dirt, 0), (7, 3, Dirt, 0),
    (0, 4, Dirt, 0), (1, 4, Dirt, 0), (2, 4, Dirt, 0), (3, 4, Dirt, 0),
    (4, 4, Dirt, 0), (5, 4, Dirt, 0), (6, 4, Rock, 0), (7, 4, Rock, 0),
    (0, 5, Rock, 0), (1, 5, Dirt, 0), (2, 5, Dirt, 0), (3, 5, Dirt, 0),
    (4, 5, Rock, 0), (5, 5, Rock, 0), (6, 5, Rock, 0), (7, 5, Rock, 0),
  ]
  build_level(
    "Aqueduct", 2, data, [(0, 0)], [], 18, 16, 14,
  )
}

///|
fn peaks_05() -> @types.Level {
  // "Cliff Garden" - Steep drops, limited planting space
  let data : Array[(Int, Int, @types.TileKind, Int)] = [
    (0, 0, Rock, 3), (1, 0, Rock, 3), (2, 0, WaterSource, 3), (3, 0, Rock, 3),
    (4, 0, Rock, 3), (5, 0, Rock, 0), (6, 0, Rock, 0), (7, 0, Rock, 0),
    (0, 1, Rock, 3), (1, 1, Dirt, 2), (2, 1, Dirt, 2), (3, 1, Dirt, 2),
    (4, 1, Rock, 3), (5, 1, Rock, 0), (6, 1, Rock, 0), (7, 1, Rock, 0),
    (0, 2, Dirt, 1), (1, 2, Dirt, 1), (2, 2, Dirt, 1), (3, 2, Dirt, 1),
    (4, 2, Dirt, 1), (5, 2, Rock, 0), (6, 2, Rock, 0), (7, 2, Rock, 0),
    (0, 3, Rock, 0), (1, 3, Dirt, 0), (2, 3, Dirt, 0), (3, 3, Dirt, 0),
    (4, 3, Rock, 0), (5, 3, Rock, 0), (6, 3, Rock, 0), (7, 3, Rock, 0),
    (0, 4, Rock, 0), (1, 4, Dirt, 0), (2, 4, Goal, 0), (3, 4, Dirt, 0),
    (4, 4, Rock, 0), (5, 4, Rock, 0), (6, 4, Rock, 0), (7, 4, Rock, 0),
    (0, 5, Rock, 0), (1, 5, Rock, 0), (2, 5, Rock, 0), (3, 5, Rock, 0),
    (4, 5, Rock, 0), (5, 5, Rock, 0), (6, 5, Rock, 0), (7, 5, Rock, 0),
  ]
  build_level(
    "Cliff Garden", 2, data, [(2, 0)], [(2, 4)], 14, 14, 10,
  )
}

///|
fn peaks_06() -> @types.Level {
  // "Summit Relay" - Chain of channels across peaks
  let data : Array[(Int, Int, @types.TileKind, Int)] = [
    (0, 0, WaterSource, 3), (1, 0, Dirt, 3), (2, 0, Rock, 2), (3, 0, Dirt, 3),
    (4, 0, Dirt, 3), (5, 0, Rock, 2), (6, 0, Dirt, 2), (7, 0, Dirt, 1),
    (0, 1, Dirt, 3), (1, 1, Rock, 2), (2, 1, Dirt, 2), (3, 1, Rock, 2),
    (4, 1, Dirt, 3), (5, 1, Dirt, 2), (6, 1, Dirt, 1), (7, 1, Dirt, 1),
    (0, 2, Dirt, 2), (1, 2, Dirt, 2), (2, 2, Rock, 1), (3, 2, Dirt, 2),
    (4, 2, Rock, 1), (5, 2, Dirt, 1), (6, 2, Dirt, 0), (7, 2, Rock, 0),
    (0, 3, Dirt, 1), (1, 3, Rock, 1), (2, 3, Dirt, 1), (3, 3, Rock, 1),
    (4, 3, Dirt, 0), (5, 3, Dirt, 0), (6, 3, Rock, 0), (7, 3, Rock, 0),
    (0, 4, Dirt, 0), (1, 4, Dirt, 0), (2, 4, Rock, 0), (3, 4, Dirt, 0),
    (4, 4, Dirt, 0), (5, 4, Rock, 0), (6, 4, Rock, 0), (7, 4, Rock, 0),
    (0, 5, Rock, 0), (1, 5, Rock, 0), (2, 5, Dirt, 0), (3, 5, Dirt, 0),
    (4, 5, Rock, 0), (5, 5, Rock, 0), (6, 5, Rock, 0), (7, 5, Rock, 0),
  ]
  build_level(
    "Summit Relay", 2, data, [(0, 0)], [], 18, 18, 14,
  )
}

///|
fn peaks_07() -> @types.Level {
  // "Grand Harvest" - Large playable area, multiple goals
  let data : Array[(Int, Int, @types.TileKind, Int)] = [
    (0, 0, Dirt, 3), (1, 0, Dirt, 3), (2, 0, WaterSource, 3), (3, 0, Dirt, 3),
    (4, 0, Dirt, 2), (5, 0, Dirt, 2), (6, 0, Dirt, 1), (7, 0, Dirt, 1),
    (0, 1, Dirt, 2), (1, 1, Dirt, 2), (2, 1, Dirt, 2), (3, 1, Dirt, 2),
    (4, 1, Goal, 2), (5, 1, Dirt, 1), (6, 1, Dirt, 1), (7, 1, Dirt, 0),
    (0, 2, Dirt, 1), (1, 2, Dirt, 1), (2, 2, Dirt, 1), (3, 2, Dirt, 1),
    (4, 2, Dirt, 1), (5, 2, Dirt, 0), (6, 2, Goal, 0), (7, 2, Dirt, 0),
    (0, 3, Dirt, 0), (1, 3, Dirt, 0), (2, 3, Dirt, 0), (3, 3, Dirt, 0),
    (4, 3, Dirt, 0), (5, 3, Dirt, 0), (6, 3, Dirt, 0), (7, 3, Rock, 0),
    (0, 4, Dirt, 0), (1, 4, Goal, 0), (2, 4, Dirt, 0), (3, 4, Dirt, 0),
    (4, 4, Dirt, 0), (5, 4, Rock, 0), (6, 4, Rock, 0), (7, 4, Rock, 0),
    (0, 5, Rock, 0), (1, 5, Dirt, 0), (2, 5, Dirt, 0), (3, 5, Dirt, 0),
    (4, 5, Rock, 0), (5, 5, Rock, 0), (6, 5, Rock, 0), (7, 5, Rock, 0),
  ]
  build_level(
    "Grand Harvest", 2, data,
    [(2, 0)], [(4, 1), (6, 2), (1, 4)], 20, 24, 16,
  )
}

///|
fn peaks_08() -> @types.Level {
  // "Peak Mastery" - Final challenge, all mechanics
  let data : Array[(Int, Int, @types.TileKind, Int)] = [
    (0, 0, WaterSource, 3), (1, 0, Rock, 3), (2, 0, Dirt, 2), (3, 0, Rock, 3),
    (4, 0, Dirt, 3), (5, 0, Rock, 3), (6, 0, WaterSource, 3), (7, 0, Rock, 0),
    (0, 1, Dirt, 2), (1, 1, Dirt, 2), (2, 1, Dirt, 2), (3, 1, Dirt, 2),
    (4, 1, Dirt, 2), (5, 1, Dirt, 2), (6, 1, Dirt, 2), (7, 1, Dirt, 1),
    (0, 2, Dirt, 1), (1, 2, Rock, 1), (2, 2, Dirt, 1), (3, 2, Goal, 1),
    (4, 2, Dirt, 1), (5, 2, Rock, 1), (6, 2, Dirt, 1), (7, 2, Dirt, 0),
    (0, 3, Dirt, 0), (1, 3, Dirt, 0), (2, 3, Dirt, 0), (3, 3, Dirt, 0),
    (4, 3, Dirt, 0), (5, 3, Dirt, 0), (6, 3, Dirt, 0), (7, 3, Dirt, 0),
    (0, 4, Goal, 0), (1, 4, Dirt, 0), (2, 4, Rock, 0), (3, 4, Dirt, 0),
    (4, 4, Rock, 0), (5, 4, Dirt, 0), (6, 4, Goal, 0), (7, 4, Rock, 0),
    (0, 5, Rock, 0), (1, 5, Dirt, 0), (2, 5, Dirt, 0), (3, 5, Dirt, 0),
    (4, 5, Dirt, 0), (5, 5, Dirt, 0), (6, 5, Rock, 0), (7, 5, Rock, 0),
  ]
  build_level(
    "Peak Mastery", 2, data,
    [(0, 0), (6, 0)], [(3, 2), (0, 4), (6, 4)], 20, 30, 15,
  )
}
