///|
fn make_grid_from(w : Int, h : Int, data : Array[Int]) -> @types.Grid {
  let tiles : Array[@types.TileKind] = Array(capacity=w * h)
  for i in 0..<data.length() {
    let t : @types.TileKind = match data[i] {
      0 => Empty
      1 => House(0)
      2 => House(1)
      3 => House(2)
      4 => House(3)
      5 => House(4)
      6 => House(5)
      7 => House(6)
      8 => House(7)
      9 => Road
      10 => Water
      _ => Empty
    }
    tiles.push(t)
  }
  @types.make_grid(w, h, tiles)
}

///|
fn mk_house(x : Int, y : Int, cid : Int, area : Int) -> @types.House {
  @types.make_house(x, y, cid, area)
}

///|
fn mk_level(
  grid : @types.Grid,
  houses : Array[@types.House],
  rect : Bool,
  no_water : Bool,
  par_f : Int,
  par_l : Int,
  tier : @types.Tier,
  name : String,
) -> @types.LevelDef {
  @types.make_level(
    grid,
    houses,
    @types.make_constraint(rect, no_water),
    par_f,
    par_l,
    tier,
    name,
  )
}

// ==== TIER 1: PLOTS (8 levels) ====

///|
fn level_01() -> @types.LevelDef {
  // Simple 2-house split. 4x4 used area, rest empty.
  // Houses at (1,1) color 0 area=8, (2,5) color 1 area=8
  // Just need one horizontal fence line across middle
  let grid = make_grid_from(8, 8, [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  ])
  let houses = [mk_house(1, 1, 0, 32), mk_house(2, 5, 1, 32)]
  mk_level(grid, houses, false, false, 8, 6, Plots, "First Fence")
}

///|
fn level_02() -> @types.LevelDef {
  let grid = make_grid_from(8, 8, [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  ])
  let houses = [mk_house(2, 1, 0, 24), mk_house(6, 4, 1, 40)]
  mk_level(grid, houses, false, false, 6, 5, Plots, "Two Plots")
}

///|
fn level_03() -> @types.LevelDef {
  let grid = make_grid_from(8, 8, [
    0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  ])
  let houses = [
    mk_house(1, 0, 0, 16),
    mk_house(5, 2, 1, 24),
    mk_house(6, 5, 2, 24),
  ]
  mk_level(grid, houses, false, false, 10, 8, Plots, "Three Parcels")
}

///|
fn level_04() -> @types.LevelDef {
  let grid = make_grid_from(8, 8, [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 2, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  ])
  let houses = [mk_house(2, 2, 0, 32), mk_house(5, 2, 1, 32)]
  mk_level(grid, houses, false, false, 8, 6, Plots, "Side by Side")
}

///|
fn level_05() -> @types.LevelDef {
  let grid = make_grid_from(8, 8, [
    0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  ])
  let houses = [mk_house(0, 1, 0, 32), mk_house(7, 5, 1, 32)]
  mk_level(grid, houses, false, false, 8, 6, Plots, "Corners")
}

///|
fn level_06() -> @types.LevelDef {
  let grid = make_grid_from(8, 8, [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  ])
  let houses = [
    mk_house(1, 1, 0, 20),
    mk_house(5, 1, 1, 20),
    mk_house(3, 5, 2, 24),
  ]
  mk_level(grid, houses, false, false, 12, 9, Plots, "Triangle")
}

///|
fn level_07() -> @types.LevelDef {
  let grid = make_grid_from(8, 8, [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  ])
  let houses = [mk_house(1, 2, 0, 32), mk_house(5, 2, 1, 32)]
  mk_level(grid, houses, false, false, 8, 6, Plots, "Half and Half")
}

///|
fn level_08() -> @types.LevelDef {
  let grid = make_grid_from(8, 8, [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  ])
  let houses = [
    mk_house(1, 1, 0, 20),
    mk_house(6, 2, 1, 22),
    mk_house(5, 5, 2, 22),
  ]
  mk_level(grid, houses, false, false, 12, 9, Plots, "Uneven Split")
}

// ==== TIER 2: DISTRICTS (9 levels) ====

///|
fn level_09() -> @types.LevelDef {
  // 4 houses, road runs along row 4
  let grid = make_grid_from(8, 8, [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 9, 9, 9, 9, 9, 9, 9, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0,
    0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  ])
  let houses = [
    mk_house(1, 1, 0, 12),
    mk_house(5, 1, 1, 12),
    mk_house(1, 6, 2, 12),
    mk_house(5, 6, 3, 12),
  ]
  mk_level(grid, houses, false, false, 14, 11, Districts, "Road Access")
}

///|
fn level_10() -> @types.LevelDef {
  let grid = make_grid_from(8, 8, [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 9,
    9, 9, 9, 9, 9, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 3, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 5, 0,
  ])
  let houses = [
    mk_house(3, 1, 0, 16),
    mk_house(2, 5, 1, 10),
    mk_house(5, 5, 2, 10),
    mk_house(1, 7, 3, 12),
    mk_house(6, 7, 4, 8),
  ]
  mk_level(grid, houses, false, false, 16, 13, Districts, "Five Lots")
}

///|
fn level_11() -> @types.LevelDef {
  let grid = make_grid_from(8, 8, [
    0, 0, 0, 9, 0, 0, 0, 0, 0, 1, 0, 9, 0, 2, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0,
    0, 9, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 3, 0, 9, 0, 4, 0, 0, 0, 0, 0, 9,
    0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0,
  ])
  let houses = [
    mk_house(1, 1, 0, 12),
    mk_house(5, 1, 1, 12),
    mk_house(1, 5, 2, 12),
    mk_house(5, 5, 3, 12),
  ]
  mk_level(grid, houses, false, false, 10, 8, Districts, "Road Divide")
}

///|
fn level_12() -> @types.LevelDef {
  let grid = make_grid_from(8, 8, [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 2, 0, 9, 9, 9, 9, 9, 9, 9, 9, 0, 0,
    0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 5, 0, 0, 9, 9, 9, 9,
    9, 9, 9, 9, 0, 0, 0, 0, 0, 0, 0, 0,
  ])
  let houses = [
    mk_house(1, 1, 0, 8),
    mk_house(6, 1, 1, 8),
    mk_house(3, 3, 2, 16),
    mk_house(1, 5, 3, 8),
    mk_house(5, 5, 4, 8),
  ]
  mk_level(grid, houses, false, false, 14, 11, Districts, "Double Road")
}

///|
fn level_13() -> @types.LevelDef {
  let grid = make_grid_from(8, 8, [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 2, 0, 0, 0, 0, 0,
    0, 9, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 3, 0, 4, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  ])
  let houses = [
    mk_house(2, 2, 0, 16),
    mk_house(4, 2, 1, 16),
    mk_house(2, 5, 2, 16),
    mk_house(4, 5, 3, 16),
  ]
  mk_level(grid, houses, false, false, 14, 11, Districts, "Quad Block")
}

///|
fn level_14() -> @types.LevelDef {
  let grid = make_grid_from(8, 8, [
    0, 0, 0, 9, 0, 0, 0, 0, 1, 0, 0, 9, 0, 0, 2, 0, 0, 0, 0, 9, 0, 0, 0, 0, 9, 9,
    9, 9, 9, 9, 9, 9, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 5, 0, 0, 6, 0, 0,
  ])
  let houses = [
    mk_house(0, 1, 0, 9),
    mk_house(6, 1, 1, 9),
    mk_house(0, 5, 2, 10),
    mk_house(6, 5, 3, 10),
    mk_house(2, 7, 4, 10),
    mk_house(5, 7, 5, 10),
  ]
  mk_level(grid, houses, false, false, 18, 14, Districts, "Six Pack")
}

///|
fn level_15() -> @types.LevelDef {
  let grid = make_grid_from(8, 8, [
    9, 0, 0, 0, 0, 0, 0, 9, 9, 0, 1, 0, 0, 2, 0, 9, 9, 0, 0, 0, 0, 0, 0, 9, 9, 0,
    0, 0, 0, 0, 0, 9, 9, 0, 0, 0, 0, 0, 0, 9, 9, 0, 3, 0, 0, 4, 0, 9, 9, 0, 0, 0,
    0, 0, 0, 9, 9, 0, 0, 0, 0, 0, 0, 9,
  ])
  let houses = [
    mk_house(2, 1, 0, 9),
    mk_house(5, 1, 1, 9),
    mk_house(2, 5, 2, 9),
    mk_house(5, 5, 3, 9),
  ]
  mk_level(grid, houses, false, false, 10, 8, Districts, "Walled Garden")
}

///|
fn level_16() -> @types.LevelDef {
  let grid = make_grid_from(8, 8, [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 9,
    9, 9, 0, 0, 0, 0, 0, 0, 0, 0, 9, 9, 9, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  ])
  let houses = [mk_house(1, 1, 0, 32), mk_house(6, 6, 1, 24)]
  mk_level(grid, houses, false, false, 8, 6, Districts, "Zigzag Road")
}

///|
fn level_17() -> @types.LevelDef {
  let grid = make_grid_from(8, 8, [
    0, 0, 0, 0, 9, 0, 0, 0, 0, 1, 0, 0, 9, 0, 2, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0,
    0, 0, 9, 0, 0, 0, 0, 0, 3, 0, 9, 0, 4, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0,
    9, 0, 5, 0, 0, 0, 0, 0, 9, 0, 0, 0,
  ])
  let houses = [
    mk_house(1, 1, 0, 12),
    mk_house(6, 1, 1, 6),
    mk_house(2, 4, 2, 8),
    mk_house(6, 4, 3, 6),
    mk_house(6, 6, 4, 6),
  ]
  mk_level(grid, houses, false, false, 14, 11, Districts, "East Side")
}

// ==== TIER 3: ZONING (8 levels) ====

///|
fn level_18() -> @types.LevelDef {
  // Rectangular constraint
  let grid = make_grid_from(8, 8, [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 9,
    9, 9, 9, 9, 9, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 4, 0, 0, 0, 0, 0, 5,
    0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  ])
  let houses = [
    mk_house(1, 1, 0, 8),
    mk_house(5, 1, 1, 8),
    mk_house(1, 5, 2, 8),
    mk_house(5, 5, 3, 8),
    mk_house(3, 6, 4, 8),
    mk_house(6, 6, 5, 8),
  ]
  mk_level(grid, houses, true, false, 20, 16, Zoning, "Rectangles Only")
}

///|
fn level_19() -> @types.LevelDef {
  // Water obstacles
  let grid = make_grid_from(8, 8, [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 10, 10, 0, 0, 0, 0, 0, 0, 10, 10, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 9, 9, 9, 9, 9, 9, 9, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0,
    0, 10, 10, 3, 0, 0, 0, 0, 0, 10, 10, 0, 0,
  ])
  let houses = [
    mk_house(1, 1, 0, 12),
    mk_house(1, 6, 1, 10),
    mk_house(6, 6, 2, 6),
  ]
  mk_level(grid, houses, false, true, 12, 9, Zoning, "Water Hazard")
}

///|
fn level_20() -> @types.LevelDef {
  let grid = make_grid_from(8, 8, [
    0, 0, 0, 9, 0, 0, 0, 0, 0, 1, 0, 9, 0, 2, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0,
    0, 9, 0, 0, 3, 0, 10, 10, 0, 9, 0, 0, 0, 0, 10, 10, 0, 9, 0, 0, 0, 0, 0, 0, 4,
    9, 0, 5, 0, 0, 0, 0, 0, 9, 0, 0, 6, 0,
  ])
  let houses = [
    mk_house(1, 1, 0, 6),
    mk_house(5, 1, 1, 8),
    mk_house(6, 3, 2, 6),
    mk_house(2, 6, 3, 6),
    mk_house(5, 6, 4, 8),
    mk_house(6, 7, 5, 6),
  ]
  mk_level(grid, houses, false, true, 18, 14, Zoning, "Lake District")
}

///|
fn level_21() -> @types.LevelDef {
  let grid = make_grid_from(8, 8, [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 2, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 9,
    9, 9, 9, 9, 9, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 5, 0, 6, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  ])
  let houses = [
    mk_house(1, 1, 0, 8),
    mk_house(3, 1, 1, 8),
    mk_house(5, 1, 2, 8),
    mk_house(1, 5, 3, 8),
    mk_house(3, 5, 4, 8),
    mk_house(5, 5, 5, 8),
  ]
  mk_level(grid, houses, true, false, 18, 14, Zoning, "Grid Lock")
}

///|
fn level_22() -> @types.LevelDef {
  let grid = make_grid_from(8, 8, [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 10, 10, 0, 0, 0, 0,
    0, 0, 10, 10, 0, 0, 0, 9, 9, 9, 9, 9, 9, 9, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3,
    0, 0, 0, 0, 4, 0, 0, 0, 5, 0, 0, 6, 0, 0,
  ])
  let houses = [
    mk_house(1, 1, 0, 8),
    mk_house(6, 1, 1, 8),
    mk_house(1, 6, 2, 8),
    mk_house(6, 6, 3, 8),
    mk_house(2, 7, 4, 8),
    mk_house(5, 7, 5, 8),
  ]
  mk_level(grid, houses, false, true, 20, 16, Zoning, "Pond Zones")
}

///|
fn level_23() -> @types.LevelDef {
  let grid = make_grid_from(8, 8, [
    0, 0, 9, 0, 0, 9, 0, 0, 1, 0, 9, 0, 2, 9, 0, 3, 0, 0, 9, 0, 0, 9, 0, 0, 0, 0,
    9, 0, 0, 9, 0, 0, 0, 0, 9, 0, 0, 9, 0, 0, 4, 0, 9, 0, 5, 9, 0, 6, 0, 0, 9, 0,
    0, 9, 0, 0, 0, 0, 9, 7, 0, 9, 8, 0,
  ])
  let houses = [
    mk_house(0, 1, 0, 8),
    mk_house(4, 1, 1, 8),
    mk_house(7, 1, 2, 8),
    mk_house(0, 5, 3, 8),
    mk_house(4, 5, 4, 8),
    mk_house(7, 5, 5, 8),
    mk_house(3, 7, 6, 4),
    mk_house(6, 7, 7, 4),
  ]
  mk_level(grid, houses, false, false, 22, 18, Zoning, "Eight Districts")
}

///|
fn level_24() -> @types.LevelDef {
  let grid = make_grid_from(8, 8, [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 10, 10,
    0, 0, 0, 0, 0, 0, 10, 10, 0, 9, 9, 0, 0, 0, 0, 0, 0, 9, 9, 0, 0, 0, 0, 4, 0,
    0, 0, 0, 5, 0, 0, 0, 0, 6, 0, 7, 0, 0,
  ])
  let houses = [
    mk_house(1, 1, 0, 6),
    mk_house(3, 1, 1, 6),
    mk_house(5, 2, 2, 8),
    mk_house(1, 6, 3, 8),
    mk_house(6, 6, 4, 6),
    mk_house(3, 7, 5, 8),
    mk_house(5, 7, 6, 6),
  ]
  mk_level(grid, houses, true, true, 22, 18, Zoning, "Full Zoning")
}

///|
fn level_25() -> @types.LevelDef {
  let grid = make_grid_from(8, 8, [
    0, 0, 0, 9, 0, 0, 0, 0, 1, 0, 0, 9, 0, 0, 2, 0, 0, 0, 0, 9, 0, 0, 0, 0, 10, 0,
    0, 9, 0, 0, 10, 0, 10, 0, 3, 9, 4, 0, 10, 0, 0, 0, 0, 9, 0, 0, 0, 0, 5, 0, 0,
    9, 0, 0, 6, 0, 0, 0, 7, 9, 8, 0, 0, 0,
  ])
  let houses = [
    mk_house(0, 1, 0, 5),
    mk_house(6, 1, 1, 5),
    mk_house(2, 4, 2, 6),
    mk_house(4, 4, 3, 6),
    mk_house(0, 6, 4, 5),
    mk_house(6, 6, 5, 5),
    mk_house(2, 7, 6, 5),
    mk_house(4, 7, 7, 5),
  ]
  mk_level(grid, houses, true, true, 26, 20, Zoning, "Master Surveyor")
}

///|
pub fn get_all_levels() -> Array[@types.LevelDef] {
  [
    level_01(),
    level_02(),
    level_03(),
    level_04(),
    level_05(),
    level_06(),
    level_07(),
    level_08(),
    level_09(),
    level_10(),
    level_11(),
    level_12(),
    level_13(),
    level_14(),
    level_15(),
    level_16(),
    level_17(),
    level_18(),
    level_19(),
    level_20(),
    level_21(),
    level_22(),
    level_23(),
    level_24(),
    level_25(),
  ]
}

///|
pub fn get_level(idx : Int) -> @types.LevelDef {
  let all = get_all_levels()
  if idx >= 0 && idx < all.length() {
    all[idx]
  } else {
    all[0]
  }
}
