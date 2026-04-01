///|
fn set_blocked(
  grid : Array[Array[@types.TileInfo]],
  positions : Array[@types.Vec2i],
) -> Unit {
  for i in 0..<positions.length() {
    let p = positions[i]
    if p.y >= 0 && p.y < grid.length() && p.x >= 0 && p.x < grid[0].length() {
      grid[p.y][p.x] = @types.new_tile(Blocked)
    }
  }
}

///|
fn set_town(
  grid : Array[Array[@types.TileInfo]],
  positions : Array[@types.Vec2i],
) -> Array[@types.Vec2i] {
  let towns : Array[@types.Vec2i] = []
  for i in 0..<positions.length() {
    let p = positions[i]
    if p.y >= 0 && p.y < grid.length() && p.x >= 0 && p.x < grid[0].length() {
      grid[p.y][p.x] = @types.new_tile(Town)
      towns.push(p)
    }
  }
  towns
}

///|
fn set_noisy(
  grid : Array[Array[@types.TileInfo]],
  positions : Array[@types.Vec2i],
) -> Unit {
  for i in 0..<positions.length() {
    let p = positions[i]
    if p.y >= 0 && p.y < grid.length() && p.x >= 0 && p.x < grid[0].length() {
      grid[p.y][p.x] = @types.new_tile(Noisy)
    }
  }
}

///|
pub fn get_level(index : Int) -> @types.Level {
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
    _ => level_25()
  }
}

// ========== Tier 1: Detection (levels 1-8) ==========
// Single quake, broad sensors only, generous budget

///|
fn level_01() -> @types.Level {
  let grid = @types.make_grid(@types.grid_rows, @types.grid_cols)
  {
    grid,
    epicenters: [@types.new_epicenter(6, 5)],
    sensor_budget: 6,
    par_budget: 3,
    par_guesses: 1,
    tier: Detection,
    towns: [],
    level_index: 0,
    name: "First Tremor",
  }
}

///|
fn level_02() -> @types.Level {
  let grid = @types.make_grid(@types.grid_rows, @types.grid_cols)
  {
    grid,
    epicenters: [@types.new_epicenter(3, 7)],
    sensor_budget: 6,
    par_budget: 3,
    par_guesses: 1,
    tier: Detection,
    towns: [],
    level_index: 1,
    name: "Distant Signal",
  }
}

///|
fn level_03() -> @types.Level {
  let grid = @types.make_grid(@types.grid_rows, @types.grid_cols)
  {
    grid,
    epicenters: [@types.new_epicenter(9, 2)],
    sensor_budget: 5,
    par_budget: 3,
    par_guesses: 1,
    tier: Detection,
    towns: [],
    level_index: 2,
    name: "Corner Case",
  }
}

///|
fn level_04() -> @types.Level {
  let grid = @types.make_grid(@types.grid_rows, @types.grid_cols)
  set_blocked(grid, [@types.vec2i(5, 4), @types.vec2i(5, 5), @types.vec2i(6, 4)])
  {
    grid,
    epicenters: [@types.new_epicenter(8, 6)],
    sensor_budget: 6,
    par_budget: 3,
    par_guesses: 1,
    tier: Detection,
    towns: [],
    level_index: 3,
    name: "Obstacle",
  }
}

///|
fn level_05() -> @types.Level {
  let grid = @types.make_grid(@types.grid_rows, @types.grid_cols)
  {
    grid,
    epicenters: [@types.new_epicenter(1, 1)],
    sensor_budget: 5,
    par_budget: 3,
    par_guesses: 1,
    tier: Detection,
    towns: [],
    level_index: 4,
    name: "Edge Detection",
  }
}

///|
fn level_06() -> @types.Level {
  let grid = @types.make_grid(@types.grid_rows, @types.grid_cols)
  set_blocked(grid, [
    @types.vec2i(3, 3),
    @types.vec2i(4, 3),
    @types.vec2i(3, 4),
    @types.vec2i(8, 7),
    @types.vec2i(9, 7),
  ])
  {
    grid,
    epicenters: [@types.new_epicenter(6, 8)],
    sensor_budget: 5,
    par_budget: 3,
    par_guesses: 1,
    tier: Detection,
    towns: [],
    level_index: 5,
    name: "Around the Block",
  }
}

///|
fn level_07() -> @types.Level {
  let grid = @types.make_grid(@types.grid_rows, @types.grid_cols)
  {
    grid,
    epicenters: [@types.new_epicenter(10, 8)],
    sensor_budget: 5,
    par_budget: 3,
    par_guesses: 1,
    tier: Detection,
    towns: [],
    level_index: 6,
    name: "Far Corner",
  }
}

///|
fn level_08() -> @types.Level {
  let grid = @types.make_grid(@types.grid_rows, @types.grid_cols)
  set_blocked(grid, [
    @types.vec2i(0, 0),
    @types.vec2i(1, 0),
    @types.vec2i(11, 0),
    @types.vec2i(10, 0),
    @types.vec2i(0, 9),
    @types.vec2i(1, 9),
    @types.vec2i(10, 9),
    @types.vec2i(11, 9),
  ])
  {
    grid,
    epicenters: [@types.new_epicenter(5, 4)],
    sensor_budget: 4,
    par_budget: 3,
    par_guesses: 1,
    tier: Detection,
    towns: [],
    level_index: 7,
    name: "Tight Budget",
  }
}

// ========== Tier 2: Precision (levels 9-17) ==========
// Precise + directional sensors, tighter budgets, blocked zones

///|
fn level_09() -> @types.Level {
  let grid = @types.make_grid(@types.grid_rows, @types.grid_cols)
  {
    grid,
    epicenters: [@types.new_epicenter(7, 4)],
    sensor_budget: 6,
    par_budget: 4,
    par_guesses: 1,
    tier: Precision,
    towns: [],
    level_index: 8,
    name: "Precise Entry",
  }
}

///|
fn level_10() -> @types.Level {
  let grid = @types.make_grid(@types.grid_rows, @types.grid_cols)
  set_blocked(grid, [
    @types.vec2i(4, 3),
    @types.vec2i(5, 3),
    @types.vec2i(6, 3),
    @types.vec2i(4, 6),
    @types.vec2i(5, 6),
    @types.vec2i(6, 6),
  ])
  {
    grid,
    epicenters: [@types.new_epicenter(5, 5)],
    sensor_budget: 6,
    par_budget: 4,
    par_guesses: 1,
    tier: Precision,
    towns: [],
    level_index: 9,
    name: "Walled In",
  }
}

///|
fn level_11() -> @types.Level {
  let grid = @types.make_grid(@types.grid_rows, @types.grid_cols)
  {
    grid,
    epicenters: [@types.new_epicenter(2, 8)],
    sensor_budget: 7,
    par_budget: 4,
    par_guesses: 1,
    tier: Precision,
    towns: [],
    level_index: 10,
    name: "Directional Sweep",
  }
}

///|
fn level_12() -> @types.Level {
  let grid = @types.make_grid(@types.grid_rows, @types.grid_cols)
  set_blocked(grid, [
    @types.vec2i(2, 2),
    @types.vec2i(3, 2),
    @types.vec2i(2, 3),
    @types.vec2i(3, 3),
    @types.vec2i(8, 6),
    @types.vec2i(9, 6),
    @types.vec2i(8, 7),
    @types.vec2i(9, 7),
  ])
  {
    grid,
    epicenters: [@types.new_epicenter(6, 3)],
    sensor_budget: 6,
    par_budget: 4,
    par_guesses: 1,
    tier: Precision,
    towns: [],
    level_index: 11,
    name: "Double Block",
  }
}

///|
fn level_13() -> @types.Level {
  let grid = @types.make_grid(@types.grid_rows, @types.grid_cols)
  let towns = set_town(grid, [@types.vec2i(3, 2), @types.vec2i(8, 7)])
  {
    grid,
    epicenters: [@types.new_epicenter(5, 5)],
    sensor_budget: 6,
    par_budget: 4,
    par_guesses: 1,
    tier: Precision,
    towns,
    level_index: 12,
    name: "Town Watch",
  }
}

///|
fn level_14() -> @types.Level {
  let grid = @types.make_grid(@types.grid_rows, @types.grid_cols)
  set_noisy(grid, [
    @types.vec2i(4, 4),
    @types.vec2i(5, 4),
    @types.vec2i(4, 5),
    @types.vec2i(5, 5),
    @types.vec2i(6, 4),
    @types.vec2i(6, 5),
  ])
  {
    grid,
    epicenters: [@types.new_epicenter(8, 3)],
    sensor_budget: 7,
    par_budget: 4,
    par_guesses: 1,
    tier: Precision,
    towns: [],
    level_index: 13,
    name: "Noisy Ground",
  }
}

///|
fn level_15() -> @types.Level {
  let grid = @types.make_grid(@types.grid_rows, @types.grid_cols)
  set_blocked(grid, [
    @types.vec2i(1, 4),
    @types.vec2i(2, 4),
    @types.vec2i(3, 4),
    @types.vec2i(4, 4),
    @types.vec2i(7, 4),
    @types.vec2i(8, 4),
    @types.vec2i(9, 4),
    @types.vec2i(10, 4),
  ])
  {
    grid,
    epicenters: [@types.new_epicenter(4, 7)],
    sensor_budget: 6,
    par_budget: 4,
    par_guesses: 1,
    tier: Precision,
    towns: [],
    level_index: 14,
    name: "The Wall",
  }
}

///|
fn level_16() -> @types.Level {
  let grid = @types.make_grid(@types.grid_rows, @types.grid_cols)
  set_noisy(grid, [
    @types.vec2i(0, 0),
    @types.vec2i(1, 0),
    @types.vec2i(0, 1),
    @types.vec2i(1, 1),
    @types.vec2i(10, 8),
    @types.vec2i(11, 8),
    @types.vec2i(10, 9),
    @types.vec2i(11, 9),
  ])
  set_blocked(grid, [@types.vec2i(5, 5), @types.vec2i(6, 5)])
  {
    grid,
    epicenters: [@types.new_epicenter(9, 2)],
    sensor_budget: 7,
    par_budget: 5,
    par_guesses: 1,
    tier: Precision,
    towns: [],
    level_index: 15,
    name: "Mixed Terrain",
  }
}

///|
fn level_17() -> @types.Level {
  let grid = @types.make_grid(@types.grid_rows, @types.grid_cols)
  set_blocked(grid, [
    @types.vec2i(3, 1),
    @types.vec2i(4, 1),
    @types.vec2i(5, 1),
    @types.vec2i(3, 8),
    @types.vec2i(4, 8),
    @types.vec2i(5, 8),
    @types.vec2i(7, 3),
    @types.vec2i(8, 3),
    @types.vec2i(7, 6),
    @types.vec2i(8, 6),
  ])
  let towns = set_town(grid, [@types.vec2i(1, 5)])
  {
    grid,
    epicenters: [@types.new_epicenter(10, 5)],
    sensor_budget: 7,
    par_budget: 5,
    par_guesses: 1,
    tier: Precision,
    towns,
    level_index: 16,
    name: "Complex Terrain",
  }
}

// ========== Tier 3: Crisis (levels 18-25) ==========
// Dual quakes, noisy zones, town evacuation priority, all sensor types

///|
fn level_18() -> @types.Level {
  let grid = @types.make_grid(@types.grid_rows, @types.grid_cols)
  {
    grid,
    epicenters: [@types.new_epicenter(3, 3), @types.new_epicenter(9, 7)],
    sensor_budget: 10,
    par_budget: 6,
    par_guesses: 2,
    tier: Crisis,
    towns: [],
    level_index: 17,
    name: "Double Trouble",
  }
}

///|
fn level_19() -> @types.Level {
  let grid = @types.make_grid(@types.grid_rows, @types.grid_cols)
  set_blocked(grid, [
    @types.vec2i(5, 3),
    @types.vec2i(6, 3),
    @types.vec2i(5, 6),
    @types.vec2i(6, 6),
  ])
  let towns = set_town(grid, [@types.vec2i(1, 1), @types.vec2i(10, 8)])
  {
    grid,
    epicenters: [@types.new_epicenter(2, 4), @types.new_epicenter(9, 5)],
    sensor_budget: 10,
    par_budget: 7,
    par_guesses: 2,
    tier: Crisis,
    towns,
    level_index: 18,
    name: "Town Evacuation",
  }
}

///|
fn level_20() -> @types.Level {
  let grid = @types.make_grid(@types.grid_rows, @types.grid_cols)
  set_noisy(grid, [
    @types.vec2i(3, 3),
    @types.vec2i(4, 3),
    @types.vec2i(5, 3),
    @types.vec2i(3, 4),
    @types.vec2i(4, 4),
    @types.vec2i(5, 4),
    @types.vec2i(3, 5),
    @types.vec2i(4, 5),
    @types.vec2i(5, 5),
  ])
  {
    grid,
    epicenters: [@types.new_epicenter(2, 2), @types.new_epicenter(10, 7)],
    sensor_budget: 10,
    par_budget: 7,
    par_guesses: 2,
    tier: Crisis,
    towns: [],
    level_index: 19,
    name: "Noisy Crisis",
  }
}

///|
fn level_21() -> @types.Level {
  let grid = @types.make_grid(@types.grid_rows, @types.grid_cols)
  set_blocked(grid, [
    @types.vec2i(0, 4),
    @types.vec2i(1, 4),
    @types.vec2i(2, 4),
    @types.vec2i(9, 4),
    @types.vec2i(10, 4),
    @types.vec2i(11, 4),
  ])
  let towns = set_town(grid, [@types.vec2i(6, 2), @types.vec2i(6, 7)])
  {
    grid,
    epicenters: [@types.new_epicenter(3, 1), @types.new_epicenter(8, 8)],
    sensor_budget: 10,
    par_budget: 7,
    par_guesses: 2,
    tier: Crisis,
    towns,
    level_index: 20,
    name: "Divided City",
  }
}

///|
fn level_22() -> @types.Level {
  let grid = @types.make_grid(@types.grid_rows, @types.grid_cols)
  set_noisy(grid, [
    @types.vec2i(0, 0),
    @types.vec2i(1, 0),
    @types.vec2i(2, 0),
    @types.vec2i(0, 1),
    @types.vec2i(1, 1),
    @types.vec2i(2, 1),
    @types.vec2i(9, 8),
    @types.vec2i(10, 8),
    @types.vec2i(11, 8),
    @types.vec2i(9, 9),
    @types.vec2i(10, 9),
    @types.vec2i(11, 9),
  ])
  set_blocked(grid, [
    @types.vec2i(5, 4),
    @types.vec2i(6, 4),
    @types.vec2i(5, 5),
    @types.vec2i(6, 5),
  ])
  {
    grid,
    epicenters: [@types.new_epicenter(1, 8), @types.new_epicenter(10, 2)],
    sensor_budget: 11,
    par_budget: 7,
    par_guesses: 2,
    tier: Crisis,
    towns: [],
    level_index: 21,
    name: "Interference",
  }
}

///|
fn level_23() -> @types.Level {
  let grid = @types.make_grid(@types.grid_rows, @types.grid_cols)
  set_blocked(grid, [
    @types.vec2i(3, 2),
    @types.vec2i(4, 2),
    @types.vec2i(3, 3),
    @types.vec2i(7, 6),
    @types.vec2i(8, 6),
    @types.vec2i(8, 7),
  ])
  let towns = set_town(grid, [
    @types.vec2i(1, 5),
    @types.vec2i(10, 4),
    @types.vec2i(6, 9),
  ])
  {
    grid,
    epicenters: [@types.new_epicenter(4, 7), @types.new_epicenter(9, 2)],
    sensor_budget: 11,
    par_budget: 8,
    par_guesses: 2,
    tier: Crisis,
    towns,
    level_index: 22,
    name: "Triple Town",
  }
}

///|
fn level_24() -> @types.Level {
  let grid = @types.make_grid(@types.grid_rows, @types.grid_cols)
  set_noisy(grid, [
    @types.vec2i(5, 3),
    @types.vec2i(6, 3),
    @types.vec2i(7, 3),
    @types.vec2i(5, 4),
    @types.vec2i(6, 4),
    @types.vec2i(7, 4),
    @types.vec2i(5, 5),
    @types.vec2i(6, 5),
    @types.vec2i(7, 5),
    @types.vec2i(5, 6),
    @types.vec2i(6, 6),
    @types.vec2i(7, 6),
  ])
  set_blocked(grid, [@types.vec2i(2, 1), @types.vec2i(9, 8)])
  let towns = set_town(grid, [@types.vec2i(0, 5), @types.vec2i(11, 5)])
  {
    grid,
    epicenters: [@types.new_epicenter(3, 7), @types.new_epicenter(10, 2)],
    sensor_budget: 12,
    par_budget: 8,
    par_guesses: 2,
    tier: Crisis,
    towns,
    level_index: 23,
    name: "Seismic Storm",
  }
}

///|
fn level_25() -> @types.Level {
  let grid = @types.make_grid(@types.grid_rows, @types.grid_cols)
  set_noisy(grid, [
    @types.vec2i(4, 3),
    @types.vec2i(5, 3),
    @types.vec2i(6, 3),
    @types.vec2i(7, 3),
    @types.vec2i(4, 4),
    @types.vec2i(5, 4),
    @types.vec2i(6, 4),
    @types.vec2i(7, 4),
    @types.vec2i(4, 5),
    @types.vec2i(5, 5),
    @types.vec2i(6, 5),
    @types.vec2i(7, 5),
    @types.vec2i(4, 6),
    @types.vec2i(5, 6),
    @types.vec2i(6, 6),
    @types.vec2i(7, 6),
  ])
  set_blocked(grid, [
    @types.vec2i(0, 0),
    @types.vec2i(11, 0),
    @types.vec2i(0, 9),
    @types.vec2i(11, 9),
    @types.vec2i(2, 2),
    @types.vec2i(9, 7),
  ])
  let towns = set_town(grid, [
    @types.vec2i(1, 1),
    @types.vec2i(10, 1),
    @types.vec2i(1, 8),
    @types.vec2i(10, 8),
  ])
  {
    grid,
    epicenters: [@types.new_epicenter(3, 8), @types.new_epicenter(8, 1)],
    sensor_budget: 12,
    par_budget: 8,
    par_guesses: 2,
    tier: Crisis,
    towns,
    level_index: 24,
    name: "The Big One",
  }
}
