///|
test "hex_neighbors wrapping: col 0 neighbors col 13" {
  // On a 14-wide grid with wrapping, column 0 should neighbor column 13
  let neighbors = @types.hex_neighbors(0, 3, 14, 8, true)
  // Check that col 13 appears as a neighbor
  let mut found_13 = false
  for i in 0..<neighbors.length() {
    let (c, _r) = neighbors[i]
    if c == 13 {
      found_13 = true
    }
  }
  inspect(found_13, content="true")
}

///|
test "hex_neighbors wrapping: col 13 neighbors col 0" {
  let neighbors = @types.hex_neighbors(13, 4, 14, 8, true)
  let mut found_0 = false
  for i in 0..<neighbors.length() {
    let (c, _r) = neighbors[i]
    if c == 0 {
      found_0 = true
    }
  }
  inspect(found_0, content="true")
}

///|
test "hex_neighbors no wrapping: col 0 does not neighbor col 13" {
  let neighbors = @types.hex_neighbors(0, 3, 14, 8, false)
  let mut found_13 = false
  for i in 0..<neighbors.length() {
    let (c, _r) = neighbors[i]
    if c == 13 {
      found_13 = true
    }
  }
  inspect(found_13, content="false")
}

///|
test "hex_neighbors count: interior hex has 6 neighbors" {
  let neighbors = @types.hex_neighbors(5, 3, 14, 8, true)
  inspect(neighbors.length(), content="6")
}

///|
test "hex_neighbors: top row has fewer neighbors" {
  let neighbors = @types.hex_neighbors(5, 0, 14, 8, true)
  // Top row can't have up-neighbors, so only 3-4
  inspect(neighbors.length() <= 4, content="true")
}

///|
test "new_grid creates correct size" {
  let grid = @types.new_grid(14, 8, true)
  inspect(grid.tiles.length(), content="112")
  inspect(grid.width, content="14")
  inspect(grid.height, content="8")
  inspect(grid.wraps_horizontal, content="true")
}

///|
test "set_biome and get_tile" {
  let grid = @types.new_grid(4, 4, true)
  @types.set_biome(grid, 2, 1, Forest)
  let tile = @types.get_tile(grid, 2, 1)
  inspect(tile.biome, content="Forest")
}

///|
test "count_biome" {
  let grid = @types.new_grid(4, 4, true)
  inspect(@types.count_biome(grid, Barren), content="16")
  inspect(@types.count_biome(grid, Forest), content="0")
  @types.set_biome(grid, 0, 0, Forest)
  @types.set_biome(grid, 1, 1, Forest)
  @types.set_biome(grid, 2, 2, Ocean)
  inspect(@types.count_biome(grid, Forest), content="2")
  inspect(@types.count_biome(grid, Ocean), content="1")
  inspect(@types.count_biome(grid, Barren), content="13")
}

///|
test "biome_ratio" {
  let grid = @types.new_grid(10, 1, false)
  // All barren
  inspect(@types.biome_ratio(grid, Barren), content="1")
  inspect(@types.biome_ratio(grid, Forest), content="0")
  // Set 3 forest
  @types.set_biome(grid, 0, 0, Forest)
  @types.set_biome(grid, 1, 0, Forest)
  @types.set_biome(grid, 2, 0, Forest)
  // 3/10 = 0.3
  let r = @types.biome_ratio(grid, Forest)
  inspect(r > 0.29 && r < 0.31, content="true")
}

///|
test "count_neighbor_biome" {
  let grid = @types.new_grid(5, 5, false)
  @types.set_biome(grid, 1, 1, Ocean)
  @types.set_biome(grid, 2, 1, Ocean)
  // Count ocean neighbors of (1, 2)
  let count = @types.count_neighbor_biome(grid, 1, 2, Ocean)
  inspect(count >= 1, content="true")
}

///|
test "budget operations" {
  let budget = @types.new_budget(5, 3, 2)
  inspect(@types.budget_remaining(budget, Forest), content="5")
  inspect(@types.budget_remaining(budget, Ocean), content="3")
  inspect(@types.total_budget(budget), content="10")
  @types.deduct_budget(budget, Forest)
  inspect(budget.forest, content="4")
  @types.add_budget(budget, Forest)
  inspect(budget.forest, content="5")
}

///|
test "clone_grid creates independent copy" {
  let grid = @types.new_grid(4, 4, true)
  @types.set_biome(grid, 0, 0, Forest)
  let clone = @types.clone_grid(grid)
  @types.set_biome(clone, 0, 0, Ocean)
  inspect(@types.get_tile(grid, 0, 0).biome, content="Forest")
  inspect(@types.get_tile(clone, 0, 0).biome, content="Ocean")
}

///|
test "snapshot_biomes" {
  let grid = @types.new_grid(3, 3, false)
  @types.set_biome(grid, 0, 0, Forest)
  @types.set_biome(grid, 1, 1, Ocean)
  let snap = @types.snapshot_biomes(grid)
  inspect(snap[0], content="Forest")
  inspect(snap[4], content="Ocean")
  inspect(snap[1], content="Barren")
}

///|
test "sinf and cosf" {
  inspect(@types.cosf(0.0), content="1")
  inspect(@types.sinf(0.0), content="0")
}

///|
test "clampf" {
  inspect(@types.clampf(0.5, 0.0, 1.0), content="0.5")
  inspect(@types.clampf(-1.0, 0.0, 1.0), content="0")
  inspect(@types.clampf(2.0, 0.0, 1.0), content="1")
}

///|
test "absf" {
  inspect(@types.absf(5.0), content="5")
  inspect(@types.absf(-5.0), content="5")
}

///|
test "tier_level_range" {
  let (s0, e0) = @types.tier_level_range(Seeds)
  inspect(s0, content="0")
  inspect(e0, content="8")
  let (s1, e1) = @types.tier_level_range(Balance)
  inspect(s1, content="8")
  inspect(e1, content="17")
  let (s2, e2) = @types.tier_level_range(Harmony)
  inspect(s2, content="17")
  inspect(e2, content="25")
}

///|
test "new_game initializes correctly" {
  let game = @types.new_game()
  inspect(game.screen, content="Title")
  inspect(game.play_state, content="Painting")
  inspect(game.level_scores.length(), content="25")
  inspect(game.current_turn, content="0")
}

///|
test "hex_neighbors: even row center tile" {
  let neighbors = @types.hex_neighbors(3, 2, 8, 5, false)
  inspect(neighbors.length(), content="6")
  // Even row (2): neighbors should be
  // (2,1),(3,1),(2,2),(4,2),(2,3),(3,3)
  // Check they're all valid
  for i in 0..<neighbors.length() {
    let (c, r) = neighbors[i]
    inspect(c >= 0 && c < 8, content="true")
    inspect(r >= 0 && r < 5, content="true")
  }
}

///|
test "hex_neighbors: odd row center tile" {
  let neighbors = @types.hex_neighbors(3, 3, 8, 5, false)
  inspect(neighbors.length(), content="6")
  for i in 0..<neighbors.length() {
    let (c, r) = neighbors[i]
    inspect(c >= 0 && c < 8, content="true")
    inspect(r >= 0 && r < 5, content="true")
  }
}

///|
test "hex_neighbors: bottom row has fewer" {
  let neighbors = @types.hex_neighbors(3, 4, 8, 5, false)
  // Bottom row: no down neighbors
  inspect(neighbors.length() <= 4, content="true")
}

///|
test "grid_index round trip" {
  for row in 0..<8 {
    for col in 0..<14 {
      let idx = @types.grid_index(col, row, 14)
      let row_back = idx / 14
      let col_back = idx % 14
      inspect(row_back == row, content="true")
      inspect(col_back == col, content="true")
    }
  }
}

///|
test "level_name returns names" {
  inspect(@types.level_name(0), content="First Growth")
  inspect(@types.level_name(24), content="Perfect World")
  inspect(@types.level_name(99), content="Unknown")
}

///|
test "biome_name" {
  inspect(@types.biome_name(Barren), content="Barren")
  inspect(@types.biome_name(Forest), content="Forest")
  inspect(@types.biome_name(Ocean), content="Ocean")
  inspect(@types.biome_name(Desert), content="Desert")
}

///|
test "tier_name" {
  inspect(@types.tier_name(Seeds), content="Seeds")
  inspect(@types.tier_name(Balance), content="Balance")
  inspect(@types.tier_name(Harmony), content="Harmony")
}

///|
test "new_targets" {
  let t = @types.new_targets(0.1, 0.3, 0.2, 0.4, 0.05, 0.15)
  inspect(t.forest_min, content="0.10000000149011612")
  inspect(t.ocean_max, content="0.4000000059604645")
}

///|
test "maxf and minf" {
  inspect(@types.maxf(3.0, 7.0), content="7")
  inspect(@types.minf(3.0, 7.0), content="3")
  inspect(@types.maxf(-1.0, -5.0), content="-1")
  inspect(@types.minf(-1.0, -5.0), content="-5")
}

///|
test "lerpf" {
  inspect(@types.lerpf(0.0, 10.0, 0.5), content="5")
  inspect(@types.lerpf(0.0, 10.0, 0.0), content="0")
  inspect(@types.lerpf(0.0, 10.0, 1.0), content="10")
}

///|
test "maxi and mini" {
  inspect(@types.maxi(3, 7), content="7")
  inspect(@types.mini(3, 7), content="3")
}

///|
test "sqrtf" {
  inspect(@types.sqrtf(4.0), content="2")
  inspect(@types.sqrtf(9.0), content="3")
}

///|
test "hex_to_pixel and back consistency" {
  // For a tile in the grid, converting to pixel and back should give same coords
  for row in 1..<7 {
    for col in 1..<13 {
      let (px, py) = @types.hex_to_pixel(col, row)
      let (bc, br) = @types.pixel_to_hex(px, py, 14, 8)
      inspect(bc == col, content="true")
      inspect(br == row, content="true")
    }
  }
}

///|
test "budget_remaining for Barren returns 999" {
  let budget = @types.new_budget(1, 2, 3)
  inspect(@types.budget_remaining(budget, Barren), content="999")
}

///|
test "deduct and add budget symmetry" {
  let budget = @types.new_budget(5, 5, 5)
  @types.deduct_budget(budget, Forest)
  @types.deduct_budget(budget, Ocean)
  @types.deduct_budget(budget, Desert)
  inspect(@types.total_budget(budget), content="12")
  @types.add_budget(budget, Forest)
  @types.add_budget(budget, Ocean)
  @types.add_budget(budget, Desert)
  inspect(@types.total_budget(budget), content="15")
}
