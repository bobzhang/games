///|
test "new_resources_creates_correct_values" {
  let r = @types.new_resources(10.0, 20.0, 30.0, 40.0)
  inspect(r.o2.to_double(), content="10")
  inspect(r.co2.to_double(), content="20")
  inspect(r.water.to_double(), content="30")
  inspect(r.nutrients.to_double(), content="40")
}

///|
test "clone_resources_creates_independent_copy" {
  let r = @types.new_resources(50.0, 60.0, 70.0, 80.0)
  let c = @types.clone_resources(r)
  c.o2 = 0.0
  inspect(r.o2.to_double(), content="50")
  inspect(c.o2.to_double(), content="0")
}

///|
test "clamp_resources_upper_bound" {
  let r = @types.new_resources(150.0, 200.0, 110.0, 999.0)
  @types.clamp_resources(r)
  inspect(r.o2.to_double(), content="100")
  inspect(r.co2.to_double(), content="100")
  inspect(r.water.to_double(), content="100")
  inspect(r.nutrients.to_double(), content="100")
}

///|
test "clamp_resources_lower_bound" {
  let r = @types.new_resources(-10.0, -5.0, -1.0, -100.0)
  @types.clamp_resources(r)
  inspect(r.o2.to_double(), content="0")
  inspect(r.co2.to_double(), content="0")
  inspect(r.water.to_double(), content="0")
  inspect(r.nutrients.to_double(), content="0")
}

///|
test "clamp_float_within_bounds" {
  inspect(@types.clamp_float(5.0, 0.0, 10.0).to_double(), content="5")
  inspect(@types.clamp_float(0.0, 0.0, 10.0).to_double(), content="0")
  inspect(@types.clamp_float(10.0, 0.0, 10.0).to_double(), content="10")
}

///|
test "clamp_float_outside_bounds" {
  inspect(@types.clamp_float(-5.0, 0.0, 10.0).to_double(), content="0")
  inspect(@types.clamp_float(15.0, 0.0, 10.0).to_double(), content="10")
}

///|
test "new_game_creates_empty_grid" {
  let game = @types.new_game()
  for r in 0..<@types.grid_size {
    for c in 0..<@types.grid_size {
      assert_eq(game.grid[r][c], Empty)
    }
  }
}

///|
test "new_game_creates_scores_for_all_levels" {
  let game = @types.new_game()
  assert_eq(game.scores.length(), @types.total_levels)
}

///|
test "new_game_initial_screen_is_title" {
  let game = @types.new_game()
  assert_eq(game.screen, Title)
}

///|
test "clear_grid_resets_all_cells" {
  let game = @types.new_game()
  game.grid[0][0] = Organism(Moss)
  game.grid[2][3] = Organism(Beetle)
  game.organisms.push({
    kind: Moss,
    row: 0,
    col: 0,
    alive: true,
    health: 100.0,
  })
  game.organisms_placed[0] = 1
  @types.clear_grid(game)
  assert_eq(game.grid[0][0], Empty)
  assert_eq(game.grid[2][3], Empty)
  assert_eq(game.organisms.length(), 0)
  assert_eq(game.organisms_placed[0], 0)
}

///|
test "in_grid_valid" {
  assert_true(@types.in_grid(0, 0))
  assert_true(@types.in_grid(5, 5))
  assert_true(@types.in_grid(3, 2))
}

///|
test "in_grid_invalid" {
  assert_false(@types.in_grid(-1, 0))
  assert_false(@types.in_grid(0, -1))
  assert_false(@types.in_grid(6, 0))
  assert_false(@types.in_grid(0, 6))
}

///|
test "organism_index_roundtrip" {
  let kinds : Array[@types.OrganismKind] = [Moss, Fern, Beetle, Snail, Fungus, Worm]
  for i in 0..<kinds.length() {
    let idx = @types.organism_index(kinds[i])
    assert_eq(@types.organism_from_index(idx), kinds[i])
  }
}

///|
test "get_profile_moss" {
  let p = @types.get_profile(Moss)
  assert_eq(p.name, "Moss")
  assert_eq(p.category, "Plant")
  assert_true(p.o2_delta > 0.0)
}

///|
test "get_profile_beetle" {
  let p = @types.get_profile(Beetle)
  assert_eq(p.name, "Beetle")
  assert_eq(p.category, "Herbivore")
  assert_true(p.o2_delta < 0.0)
  assert_true(p.co2_delta > 0.0)
}

///|
test "get_profile_fungus" {
  let p = @types.get_profile(Fungus)
  assert_eq(p.name, "Fungus")
  assert_eq(p.category, "Decomposer")
  assert_true(p.nutrient_delta > 0.0)
}

///|
test "get_profile_worm" {
  let p = @types.get_profile(Worm)
  assert_eq(p.name, "Worm")
  assert_eq(p.category, "Decomposer")
  assert_true(p.water_delta > 0.0)
}

///|
test "organism_symbol_unique" {
  let kinds : Array[@types.OrganismKind] = [Moss, Fern, Beetle, Snail, Fungus, Worm]
  let syms : Array[String] = []
  for i in 0..<kinds.length() {
    let sym = @types.organism_symbol(kinds[i])
    assert_false(syms.contains(sym))
    syms.push(sym)
  }
}

///|
test "resource_name_all" {
  assert_eq(@types.resource_name(O2), "O2")
  assert_eq(@types.resource_name(CO2), "CO2")
  assert_eq(@types.resource_name(Water), "Water")
  assert_eq(@types.resource_name(Nutrients), "Nutrients")
}

///|
test "tier_name_all" {
  assert_eq(@types.tier_name(Beginner), "Beginner")
  assert_eq(@types.tier_name(Intermediate), "Intermediate")
  assert_eq(@types.tier_name(Advanced), "Advanced")
}

///|
test "compute_stars_victory_few_organisms" {
  let stars = @types.compute_stars(10, 3)
  assert_eq(stars, 3)
}

///|
test "compute_stars_victory_medium" {
  let stars = @types.compute_stars(10, 5)
  assert_eq(stars, 2)
}

///|
test "compute_stars_victory_many" {
  let stars = @types.compute_stars(10, 8)
  assert_eq(stars, 1)
}

///|
test "compute_stars_failure" {
  let stars = @types.compute_stars(5, 3)
  assert_eq(stars, 0)
}

///|
test "total_stars_empty" {
  let scores : Array[@types.LevelScore] = []
  assert_eq(@types.total_stars(scores), 0)
}

///|
test "total_stars_mixed" {
  let scores : Array[@types.LevelScore] = [
    { completed: true, best_turns_survived: 10, stars: 3, },
    { completed: true, best_turns_survived: 10, stars: 2, },
    { completed: false, best_turns_survived: 5, stars: 0, },
  ]
  assert_eq(@types.total_stars(scores), 5)
}

///|
test "levels_completed_count" {
  let scores : Array[@types.LevelScore] = [
    { completed: true, best_turns_survived: 10, stars: 3, },
    { completed: false, best_turns_survived: 0, stars: 0, },
    { completed: true, best_turns_survived: 10, stars: 1, },
  ]
  assert_eq(@types.levels_completed(scores), 2)
}

///|
test "is_level_unlocked_first_level" {
  let game = @types.new_game()
  assert_true(@types.is_level_unlocked(game.scores, 0))
}

///|
test "is_level_unlocked_second_requires_first" {
  let game = @types.new_game()
  assert_false(@types.is_level_unlocked(game.scores, 1))
  game.scores[0].completed = true
  assert_true(@types.is_level_unlocked(game.scores, 1))
}

///|
test "is_level_unlocked_tier2_requires_4_completed" {
  let game = @types.new_game()
  assert_false(@types.is_level_unlocked(game.scores, 7))
  for i in 0..<4 {
    game.scores[i].completed = true
  }
  assert_true(@types.is_level_unlocked(game.scores, 7))
}

///|
test "is_level_unlocked_tier3_requires_10_completed" {
  let game = @types.new_game()
  assert_false(@types.is_level_unlocked(game.scores, 14))
  for i in 0..<10 {
    game.scores[i].completed = true
  }
  assert_true(@types.is_level_unlocked(game.scores, 14))
}

///|
test "is_cell_locked_empty_list" {
  let level : @types.LevelDef = {
    id: 0,
    name: "Test",
    tier: Beginner,
    description: "Test",
    initial_resources: @types.new_resources(50.0, 50.0, 50.0, 50.0),
    available_organisms: [Moss],
    organism_counts: [2],
    par_turns: 10,
    locked_cells: [],
  }
  assert_false(@types.is_cell_locked(level, 0, 0))
  assert_false(@types.is_cell_locked(level, 3, 3))
}

///|
test "is_cell_locked_with_locked_cells" {
  let level : @types.LevelDef = {
    id: 0,
    name: "Test",
    tier: Beginner,
    description: "Test",
    initial_resources: @types.new_resources(50.0, 50.0, 50.0, 50.0),
    available_organisms: [Moss],
    organism_counts: [2],
    par_turns: 10,
    locked_cells: [(0, 0), (2, 3)],
  }
  assert_true(@types.is_cell_locked(level, 0, 0))
  assert_true(@types.is_cell_locked(level, 2, 3))
  assert_false(@types.is_cell_locked(level, 1, 1))
}

///|
test "count_organism_on_grid" {
  let game = @types.new_game()
  game.grid[0][0] = Organism(Moss)
  game.grid[1][1] = Organism(Moss)
  game.grid[2][2] = Organism(Beetle)
  assert_eq(@types.count_organism_on_grid(game, Moss), 2)
  assert_eq(@types.count_organism_on_grid(game, Beetle), 1)
  assert_eq(@types.count_organism_on_grid(game, Fern), 0)
}

///|
test "abs_float" {
  inspect(@types.abs_float(5.0).to_double(), content="5")
  inspect(@types.abs_float(-5.0).to_double(), content="5")
  inspect(@types.abs_float(0.0).to_double(), content="0")
}

///|
test "get_available_count_no_level" {
  let game = @types.new_game()
  assert_eq(@types.get_available_count(game, Moss), 0)
}

///|
test "get_available_count_with_level" {
  let game = @types.new_game()
  game.current_level = Some({
    id: 0,
    name: "Test",
    tier: Beginner,
    description: "Test",
    initial_resources: @types.new_resources(50.0, 50.0, 50.0, 50.0),
    available_organisms: [Moss, Beetle],
    organism_counts: [3, 1],
    par_turns: 10,
    locked_cells: [],
  })
  assert_eq(@types.get_available_count(game, Moss), 3)
  assert_eq(@types.get_available_count(game, Beetle), 1)
  assert_eq(@types.get_available_count(game, Fern), 0)
  game.organisms_placed[0] = 2
  assert_eq(@types.get_available_count(game, Moss), 1)
}
