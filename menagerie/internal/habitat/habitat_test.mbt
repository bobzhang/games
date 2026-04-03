///|
test "find_enclosures: no fences yields one enclosure" {
  let grid = @types.Grid::new(3, 3)
  let encs = @habitat.find_enclosures(grid)
  inspect(encs.length(), content="1")
  inspect(encs[0].cells.length(), content="9")
}

///|
test "find_enclosures: horizontal fence splits grid" {
  let grid = @types.Grid::new(4, 4)
  // Place fence_top on row 2 across all columns
  for c in 0..<4 {
    grid.set_fence_top(c, 2, true)
  }
  let encs = @habitat.find_enclosures(grid)
  inspect(encs.length(), content="2")
  // Top section: rows 0-1 = 8 cells
  // Bottom section: rows 2-3 = 8 cells
  let sizes = encs.map(fn(e) { e.cells.length() })
  assert_true(sizes.contains(8))
}

///|
test "find_enclosures: vertical fence splits grid" {
  let grid = @types.Grid::new(4, 4)
  // Place fence_left on col 2 across all rows
  for r in 0..<4 {
    grid.set_fence_left(2, r, true)
  }
  let encs = @habitat.find_enclosures(grid)
  inspect(encs.length(), content="2")
}

///|
test "assign_animals_to_enclosures" {
  let grid = @types.Grid::new(4, 4)
  for c in 0..<4 {
    grid.set_fence_top(c, 2, true)
  }
  grid.set_animal(0, 0, Some(Lion))
  grid.set_animal(0, 3, Some(Snake))
  let encs = @habitat.find_enclosures(grid)
  @habitat.assign_animals_to_enclosures(grid, encs)
  let mut lion_found = false
  let mut snake_found = false
  for enc in encs {
    match enc.species {
      Some(Lion) => lion_found = true
      Some(Snake) => snake_found = true
      _ => ()
    }
  }
  assert_true(lion_found)
  assert_true(snake_found)
}

///|
test "count_terrain_in_enclosure" {
  let grid = @types.Grid::new(3, 3)
  grid.set_terrain(0, 0, Some(Grass))
  grid.set_terrain(1, 0, Some(Grass))
  grid.set_terrain(2, 0, Some(Water))
  let encs = @habitat.find_enclosures(grid)
  let grass_count = @habitat.count_terrain_in_enclosure(grid, encs[0], Grass)
  inspect(grass_count, content="2")
  let water_count = @habitat.count_terrain_in_enclosure(grid, encs[0], Water)
  inspect(water_count, content="1")
}

///|
test "count_water_adjacent" {
  let grid = @types.Grid::new(3, 3)
  grid.set_terrain(1, 1, Some(Water))
  grid.set_terrain(0, 0, Some(Grass))
  grid.set_terrain(0, 1, Some(Grass))
  let encs = @habitat.find_enclosures(grid)
  let count = @habitat.count_water_adjacent(grid, encs[0])
  // Cells adjacent to (1,1) water: (0,1), (2,1), (1,0), (1,2)
  // But only non-water cells count, so those 4 neighbors are grass/empty
  inspect(count, content="4")
}

///|
test "count_tiles_used" {
  let grid = @types.Grid::new(3, 3)
  grid.set_terrain(0, 0, Some(Grass))
  grid.set_terrain(1, 1, Some(Water))
  inspect(@habitat.count_tiles_used(grid), content="2")
}

///|
test "count_fences_used" {
  let grid = @types.Grid::new(3, 3)
  grid.set_fence_top(0, 1, true)
  grid.set_fence_left(1, 0, true)
  grid.set_fence_top(2, 2, true)
  inspect(@habitat.count_fences_used(grid), content="3")
}

///|
test "validate_enclosure: lion needs met" {
  let grid = @types.Grid::new(4, 4)
  // Fill enclosure with grass and adjacent water
  for c in 0..<4 {
    for r in 0..<4 {
      grid.set_terrain(c, r, Some(Grass))
    }
  }
  grid.set_terrain(3, 3, Some(Water))
  grid.set_animal(0, 0, Some(Lion))
  let encs = @habitat.find_enclosures(grid)
  @habitat.assign_animals_to_enclosures(grid, encs)
  let msgs = @habitat.validate_enclosure(grid, encs[0], encs)
  inspect(msgs.length(), content="0")
}

///|
test "validate_enclosure: lion needs not met - no water" {
  let grid = @types.Grid::new(3, 3)
  for c in 0..<3 {
    for r in 0..<3 {
      grid.set_terrain(c, r, Some(Grass))
    }
  }
  grid.set_animal(0, 0, Some(Lion))
  let encs = @habitat.find_enclosures(grid)
  @habitat.assign_animals_to_enclosures(grid, encs)
  let msgs = @habitat.validate_enclosure(grid, encs[0], encs)
  assert_true(msgs.length() > 0)
}

///|
test "validate_level: all species placed and met" {
  let grid = @types.Grid::new(10, 8)
  // Build a simple level with Lion and Snake
  // Lion section: top half
  for c in 0..<10 {
    grid.set_fence_top(c, 4, true)
  }
  // Grass for lion
  for c in 0..<6 {
    for r in 0..<4 {
      grid.set_terrain(c, r, Some(Grass))
    }
  }
  grid.set_terrain(6, 0, Some(Water))
  grid.set_animal(0, 0, Some(Lion))
  // Sand and rock for snake
  for c in 0..<4 {
    grid.set_terrain(c, 4, Some(Sand))
  }
  grid.set_terrain(4, 4, Some(Rock))
  grid.set_animal(0, 4, Some(Snake))
  let level : @types.LevelDef = {
    id: 0,
    tier: 1,
    species: [Lion, Snake],
    par_tiles: 60,
    bonus_space: 2,
    description: "Test",
    preset_terrain: [],
    preset_fences: [],
  }
  let encs = @habitat.find_enclosures(grid)
  @habitat.assign_animals_to_enclosures(grid, encs)
  let result = @habitat.validate_level(grid, level, encs)
  inspect(result.all_needs_met, content="true")
  assert_true(@habitat.star_count(result.stars) >= 1)
}

///|
test "validate_level: missing species" {
  let grid = @types.Grid::new(10, 8)
  grid.set_animal(0, 0, Some(Lion))
  for c in 0..<6 {
    for r in 0..<4 {
      grid.set_terrain(c, r, Some(Grass))
    }
  }
  grid.set_terrain(6, 0, Some(Water))
  let level : @types.LevelDef = {
    id: 0,
    tier: 1,
    species: [Lion, Snake],
    par_tiles: 60,
    bonus_space: 2,
    description: "Test",
    preset_terrain: [],
    preset_fences: [],
  }
  let encs = @habitat.find_enclosures(grid)
  @habitat.assign_animals_to_enclosures(grid, encs)
  let result = @habitat.validate_level(grid, level, encs)
  inspect(result.all_needs_met, content="false")
  assert_true(result.messages.length() > 0)
}

///|
test "star_count" {
  inspect(@habitat.star_count(Zero), content="0")
  inspect(@habitat.star_count(One), content="1")
  inspect(@habitat.star_count(Two), content="2")
  inspect(@habitat.star_count(Three), content="3")
}

///|
test "find_enclosure_at" {
  let grid = @types.Grid::new(3, 3)
  let encs = @habitat.find_enclosures(grid)
  let found = @habitat.find_enclosure_at(encs, 1, 1)
  assert_true(found is Some(_))
  let not_found = @habitat.find_enclosure_at(encs, 10, 10)
  assert_true(not_found is None)
}

///|
test "penguin fears predators: predator proximity check" {
  let grid = @types.Grid::new(6, 3)
  // Fence at col 3
  for r in 0..<3 {
    grid.set_fence_left(3, r, true)
  }
  // Left side: penguin habitat (water + rock)
  grid.set_terrain(0, 0, Some(Water))
  grid.set_terrain(1, 0, Some(Water))
  grid.set_terrain(2, 0, Some(Water))
  grid.set_terrain(0, 1, Some(Rock))
  grid.set_terrain(1, 1, Some(Rock))
  grid.set_animal(0, 0, Some(Penguin))
  // Right side: lion habitat (grass + water)
  for c in 3..<6 {
    for r in 0..<3 {
      grid.set_terrain(c, r, Some(Grass))
    }
  }
  grid.set_terrain(5, 2, Some(Water))
  grid.set_animal(3, 0, Some(Lion))
  let encs = @habitat.find_enclosures(grid)
  @habitat.assign_animals_to_enclosures(grid, encs)
  // Find the penguin enclosure
  let mut penguin_enc : @types.Enclosure? = None
  for enc in encs {
    match enc.species {
      Some(Penguin) => penguin_enc = Some(enc)
      _ => ()
    }
  }
  match penguin_enc {
    Some(enc) => {
      let msgs = @habitat.validate_enclosure(grid, enc, encs)
      // The lion is at distance 1 from the fence, penguin needs 3+ distance
      let has_predator_warning = msgs
        .iter()
        .any(fn(m) { m.contains("predator") })
      inspect(has_predator_warning, content="true")
    }
    None => fail("penguin enclosure not found")
  }
}
