///|
test "Grid::new creates correct dimensions" {
  let grid = @types.Grid::new(10, 8)
  inspect(grid.cols, content="10")
  inspect(grid.rows, content="8")
  inspect(grid.cells.length(), content="8")
  inspect(grid.cells[0].length(), content="10")
}

///|
test "Grid::get returns None for out of bounds" {
  let grid = @types.Grid::new(3, 3)
  debug_inspect(grid.get(-1, 0), content="None")
  debug_inspect(grid.get(0, -1), content="None")
  debug_inspect(grid.get(3, 0), content="None")
  debug_inspect(grid.get(0, 3), content="None")
}

///|
test "Grid::get returns cell for valid coords" {
  let grid = @types.Grid::new(3, 3)
  let cell = grid.get(1, 1)
  guard cell is Some(_) else { fail("expected Some") }
}

///|
test "Grid::set_terrain and get" {
  let grid = @types.Grid::new(3, 3)
  grid.set_terrain(1, 1, Some(Grass))
  match grid.get(1, 1) {
    Some(c) => debug_inspect(c.terrain, content="Some(Grass)")
    None => fail("expected cell")
  }
}

///|
test "Grid::set_animal" {
  let grid = @types.Grid::new(3, 3)
  grid.set_animal(0, 0, Some(Lion))
  match grid.get(0, 0) {
    Some(c) => debug_inspect(c.animal, content="Some(Lion)")
    None => fail("expected cell")
  }
}

///|
test "Grid::set_fence_top and set_fence_left" {
  let grid = @types.Grid::new(3, 3)
  grid.set_fence_top(1, 1, true)
  grid.set_fence_left(2, 0, true)
  match grid.get(1, 1) {
    Some(c) => inspect(c.fence_top, content="true")
    None => fail("expected cell")
  }
  match grid.get(2, 0) {
    Some(c) => inspect(c.fence_left, content="true")
    None => fail("expected cell")
  }
}

///|
test "Grid::clear resets all cells" {
  let grid = @types.Grid::new(3, 3)
  grid.set_terrain(0, 0, Some(Water))
  grid.set_animal(1, 1, Some(Snake))
  grid.set_fence_top(2, 2, true)
  grid.clear()
  match grid.get(0, 0) {
    Some(c) => debug_inspect(c.terrain, content="None")
    None => fail("expected cell")
  }
  match grid.get(1, 1) {
    Some(c) => debug_inspect(c.animal, content="None")
    None => fail("expected cell")
  }
  match grid.get(2, 2) {
    Some(c) => inspect(c.fence_top, content="false")
    None => fail("expected cell")
  }
}

///|
test "species_needs returns correct data for Lion" {
  let needs = @types.species_needs(Lion)
  inspect(needs.name, content="Lion")
  inspect(needs.terrain_primary, content="Grass")
  inspect(needs.terrain_primary_count, content="4")
  inspect(needs.min_space, content="6")
  inspect(needs.is_predator, content="true")
  inspect(needs.water_adjacent, content="true")
}

///|
test "species_needs returns correct data for Penguin" {
  let needs = @types.species_needs(Penguin)
  inspect(needs.name, content="Penguin")
  inspect(needs.terrain_primary, content="Water")
  inspect(needs.terrain_primary_count, content="3")
  inspect(needs.fears_predators, content="true")
  debug_inspect(needs.terrain_secondary, content="Some(Rock)")
}

///|
test "species_needs for all species" {
  let all : Array[@types.Species] = [
    Lion,
    Penguin,
    Elephant,
    Snake,
    Monkey,
    Bear,
  ]
  for sp in all {
    let needs = @types.species_needs(sp)
    assert_true(needs.min_space > 0)
    assert_true(needs.terrain_primary_count > 0)
  }
}

///|
test "new_game initializes correctly" {
  let game = @types.new_game()
  inspect(game.screen, content="Title")
  inspect(game.current_level, content="0")
  inspect(game.total_stars, content="0")
  inspect(game.level_results.length(), content="20")
  inspect(game.stars_earned.length(), content="20")
}

///|
test "terrain_color returns distinct colors" {
  let grass_c = @types.terrain_color(Grass)
  let water_c = @types.terrain_color(Water)
  assert_true(
    grass_c.r != water_c.r || grass_c.g != water_c.g || grass_c.b != water_c.b,
  )
}

///|
test "species_icon returns single char strings" {
  let icons : Array[String] = [
    @types.species_icon(Lion),
    @types.species_icon(Penguin),
    @types.species_icon(Elephant),
    @types.species_icon(Snake),
    @types.species_icon(Monkey),
    @types.species_icon(Bear),
  ]
  for icon in icons {
    inspect(icon.length(), content="1")
  }
}

///|
test "build_tool_slots has terrain tools plus fence and eraser" {
  let slots = @types.build_tool_slots()
  inspect(slots.length(), content="7")
}

///|
test "set_message sets message and timer" {
  let game = @types.new_game()
  @types.set_message(game, "Hello")
  inspect(game.message, content="Hello")
  assert_true(game.message_timer > 0.0)
}

///|
test "Game::is_level_unlocked level 0 always unlocked" {
  let game = @types.new_game()
  inspect(game.is_level_unlocked(0), content="true")
}

///|
test "Game::is_level_unlocked locked until previous completed" {
  let game = @types.new_game()
  inspect(game.is_level_unlocked(1), content="false")
  game.stars_earned[0] = 1
  inspect(game.is_level_unlocked(1), content="true")
}

///|
test "Game::is_level_unlocked chain" {
  let game = @types.new_game()
  inspect(game.is_level_unlocked(3), content="false")
  game.stars_earned[2] = 2
  inspect(game.is_level_unlocked(3), content="true")
  // Level 2 still locked since level 1 not completed
  inspect(game.is_level_unlocked(2), content="false")
}

///|
test "tier_label returns correct roman numerals" {
  inspect(@types.tier_label(1), content="I")
  inspect(@types.tier_label(2), content="II")
  inspect(@types.tier_label(3), content="III")
  inspect(@types.tier_label(0), content="?")
  inspect(@types.tier_label(99), content="?")
}
