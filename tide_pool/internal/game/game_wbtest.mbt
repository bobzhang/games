///|
test "start_simulation_requires_organisms" {
  let game = @types.new_game()
  @levels.setup_level(game, 0)
  game.screen = Playing
  start_simulation(game)
  assert_eq(game.screen, Playing)
}

///|
test "start_simulation_with_organisms" {
  let game = @types.new_game()
  @levels.setup_level(game, 0)
  game.organisms.push({
    kind: Barnacle,
    row: 5,
    col: 7,
    alive: true,
    health: 100.0,
    submerged: false,
  })
  game.grid[5][7] = Organism(Barnacle)
  game.screen = Playing
  start_simulation(game)
  assert_eq(game.screen, Simulating)
  assert_eq(game.current_turn, 0)
  assert_eq(game.current_cycle, 0)
}

///|
test "place_organism_on_empty_cell" {
  let game = @types.new_game()
  @levels.setup_level(game, 0)
  game.selected_organism = Some(Barnacle)
  place_organism(game, Barnacle, 5, 7)
  assert_eq(game.grid[5][7], Organism(Barnacle))
  assert_eq(game.organisms.length(), 1)
  assert_eq(game.organisms_placed[0], 1)
}

///|
test "place_organism_on_occupied_cell" {
  let game = @types.new_game()
  @levels.setup_level(game, 0)
  game.grid[3][3] = Organism(Barnacle)
  place_organism(game, Barnacle, 3, 3)
  assert_true(game.message.length() > 0)
}

///|
test "place_organism_on_rock" {
  let game = @types.new_game()
  @levels.setup_level(game, 4)
  let level = @levels.get_level(4)
  if level.rock_cells.length() > 0 {
    let (r, c) = level.rock_cells[0]
    place_organism(game, Barnacle, r, c)
    assert_true(game.message.length() > 0)
  }
}

///|
test "remove_organism" {
  let game = @types.new_game()
  @levels.setup_level(game, 0)
  place_organism(game, Barnacle, 5, 7)
  assert_eq(game.grid[5][7], Organism(Barnacle))
  remove_organism(game, 5, 7)
  assert_eq(game.grid[5][7], Empty)
  assert_eq(game.organisms.length(), 0)
  assert_eq(game.organisms_placed[0], 0)
}

///|
test "remove_organism_empty_cell" {
  let game = @types.new_game()
  @levels.setup_level(game, 0)
  remove_organism(game, 3, 3)
  assert_eq(game.organisms.length(), 0)
}

///|
test "set_message" {
  let game = @types.new_game()
  set_message(game, "Hello")
  assert_eq(game.message, "Hello")
  assert_true(game.message_timer > 0.0)
}

///|
test "finalize_simulation_updates_score_on_victory" {
  let game = @types.new_game()
  @levels.setup_level(game, 0)
  game.organisms.push({
    kind: Barnacle,
    row: 5,
    col: 7,
    alive: true,
    health: 100.0,
    submerged: true,
  })
  game.current_cycle = 3
  game.play_result = Victory
  finalize_simulation(game)
  assert_eq(game.screen, Results)
  assert_true(game.scores[0].completed)
  assert_true(game.scores[0].stars > 0)
}

///|
test "finalize_simulation_failure_does_not_complete" {
  let game = @types.new_game()
  @levels.setup_level(game, 0)
  game.organisms.push({
    kind: Barnacle,
    row: 5,
    col: 7,
    alive: false,
    health: 0.0,
    submerged: false,
  })
  game.current_cycle = 1
  game.play_result = Failure("target died")
  finalize_simulation(game)
  assert_eq(game.screen, Results)
  assert_false(game.scores[0].completed)
}

///|
test "place_organism_no_more_available" {
  let game = @types.new_game()
  @levels.setup_level(game, 0)
  let level = @levels.get_level(0)
  let max_count = level.organism_counts[0]
  for i in 0..<max_count {
    place_organism(game, Barnacle, 5, i)
  }
  place_organism(game, Barnacle, 4, 0)
  assert_eq(game.grid[4][0], Empty)
}

///|
test "place_organism_out_of_grid" {
  let game = @types.new_game()
  @levels.setup_level(game, 0)
  place_organism(game, Barnacle, -1, 0)
  assert_eq(game.organisms.length(), 0)
  place_organism(game, Barnacle, 6, 0)
  assert_eq(game.organisms.length(), 0)
}
