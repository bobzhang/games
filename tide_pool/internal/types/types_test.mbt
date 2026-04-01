///|
test "clamp_float_within_bounds" {
  inspect(clamp_float(5.0, 0.0, 10.0).to_double(), content="5")
  inspect(clamp_float(0.0, 0.0, 10.0).to_double(), content="0")
  inspect(clamp_float(10.0, 0.0, 10.0).to_double(), content="10")
}

///|
test "clamp_float_outside_bounds" {
  inspect(clamp_float(-5.0, 0.0, 10.0).to_double(), content="0")
  inspect(clamp_float(15.0, 0.0, 10.0).to_double(), content="10")
}

///|
test "abs_float" {
  inspect(abs_float(5.0).to_double(), content="5")
  inspect(abs_float(-5.0).to_double(), content="5")
  inspect(abs_float(0.0).to_double(), content="0")
}

///|
test "new_game_creates_empty_grid" {
  let game = new_game()
  for r in 0..<grid_rows {
    for c in 0..<grid_cols {
      assert_eq(game.grid[r][c], Empty)
    }
  }
}

///|
test "new_game_creates_scores_for_all_levels" {
  let game = new_game()
  assert_eq(game.scores.length(), total_levels)
}

///|
test "new_game_initial_screen_is_title" {
  let game = new_game()
  assert_eq(game.screen, Title)
}

///|
test "clear_grid_resets_all_cells" {
  let game = new_game()
  game.grid[0][0] = Organism(Barnacle)
  game.grid[2][3] = Organism(Crab)
  game.organisms.push(
    { kind: Barnacle, row: 0, col: 0, alive: true, health: 100.0, submerged: false },
  )
  game.organisms_placed[0] = 1
  clear_grid(game)
  assert_eq(game.grid[0][0], Empty)
  assert_eq(game.grid[2][3], Empty)
  assert_eq(game.organisms.length(), 0)
  assert_eq(game.organisms_placed[0], 0)
}

///|
test "in_grid_valid" {
  assert_true(in_grid(0, 0))
  assert_true(in_grid(5, 7))
  assert_true(in_grid(3, 4))
}

///|
test "in_grid_invalid" {
  assert_false(in_grid(-1, 0))
  assert_false(in_grid(0, -1))
  assert_false(in_grid(6, 0))
  assert_false(in_grid(0, 8))
}

///|
test "organism_index_roundtrip" {
  let kinds : Array[OrganismKind] = [
    Barnacle, Anemone, Crab, Starfish, Algae, Urchin,
  ]
  for i in 0..<kinds.length() {
    let idx = organism_index(kinds[i])
    assert_eq(organism_from_index(idx), kinds[i])
  }
}

///|
test "get_profile_barnacle" {
  let p = get_profile(Barnacle)
  assert_eq(p.name, "Barnacle")
  assert_true(p.needs_submersion)
  assert_false(p.is_mobile)
}

///|
test "get_profile_crab" {
  let p = get_profile(Crab)
  assert_eq(p.name, "Crab")
  assert_true(p.is_mobile)
  assert_eq(p.prey, Some(Algae))
}

///|
test "get_profile_starfish" {
  let p = get_profile(Starfish)
  assert_eq(p.name, "Starfish")
  assert_true(p.is_predator)
  assert_eq(p.prey, Some(Barnacle))
}

///|
test "get_profile_anemone" {
  let p = get_profile(Anemone)
  assert_eq(p.name, "Anemone")
  assert_true(p.needs_submersion)
  assert_true(p.health_decay_exposed > 0.0)
}

///|
test "get_profile_algae" {
  let p = get_profile(Algae)
  assert_eq(p.name, "Algae")
  assert_true(p.needs_exposure)
  assert_true(p.health_decay_submerged > 0.0)
}

///|
test "get_profile_urchin" {
  let p = get_profile(Urchin)
  assert_eq(p.name, "Urchin")
  assert_true(p.is_mobile)
  assert_eq(p.prey, Some(Algae))
}

///|
test "get_tide_for_turn_cycle" {
  let (t0, p0) = get_tide_for_turn(0)
  assert_eq(t0, 1)
  assert_eq(p0, Low)
  let (t1, p1) = get_tide_for_turn(1)
  assert_eq(t1, 2)
  assert_eq(p1, Mid)
  let (t2, p2) = get_tide_for_turn(2)
  assert_eq(t2, 4)
  assert_eq(p2, High)
  let (t3, p3) = get_tide_for_turn(3)
  assert_eq(t3, 2)
  assert_eq(p3, Mid)
  let (t4, p4) = get_tide_for_turn(4)
  assert_eq(t4, 1)
  assert_eq(p4, Low)
}

///|
test "is_submerged" {
  assert_true(is_submerged(4, 0, 2))
  assert_false(is_submerged(1, 0, 0))
  assert_true(is_submerged(4, 2, 0))
}

///|
test "tier_name_all" {
  assert_eq(tier_name(Shallow), "Shallow")
  assert_eq(tier_name(Middle), "Middle")
  assert_eq(tier_name(Deep), "Deep")
}

///|
test "compute_stars_victory_few" {
  assert_eq(compute_stars(3, 2), 3)
}

///|
test "compute_stars_victory_medium" {
  assert_eq(compute_stars(3, 4), 2)
}

///|
test "compute_stars_victory_many" {
  assert_eq(compute_stars(3, 7), 1)
}

///|
test "compute_stars_failure" {
  assert_eq(compute_stars(2, 3), 0)
}

///|
test "total_stars_mixed" {
  let scores : Array[LevelScore] = [
    { completed: true, best_cycles_survived: 3, stars: 3 },
    { completed: true, best_cycles_survived: 3, stars: 2 },
    { completed: false, best_cycles_survived: 1, stars: 0 },
  ]
  assert_eq(total_stars(scores), 5)
}

///|
test "levels_completed_count" {
  let scores : Array[LevelScore] = [
    { completed: true, best_cycles_survived: 3, stars: 3 },
    { completed: false, best_cycles_survived: 0, stars: 0 },
    { completed: true, best_cycles_survived: 3, stars: 1 },
  ]
  assert_eq(levels_completed(scores), 2)
}

///|
test "is_level_unlocked_first" {
  let game = new_game()
  assert_true(is_level_unlocked(game.scores, 0))
}

///|
test "is_level_unlocked_second_requires_first" {
  let game = new_game()
  assert_false(is_level_unlocked(game.scores, 1))
  game.scores[0].completed = true
  assert_true(is_level_unlocked(game.scores, 1))
}

///|
test "is_level_unlocked_tier2_requires_4" {
  let game = new_game()
  assert_false(is_level_unlocked(game.scores, 7))
  for i in 0..<4 {
    game.scores[i].completed = true
  }
  assert_true(is_level_unlocked(game.scores, 7))
}

///|
test "is_level_unlocked_tier3_requires_10" {
  let game = new_game()
  assert_false(is_level_unlocked(game.scores, 14))
  for i in 0..<10 {
    game.scores[i].completed = true
  }
  assert_true(is_level_unlocked(game.scores, 14))
}

///|
test "count_organism_on_grid" {
  let game = new_game()
  game.grid[0][0] = Organism(Barnacle)
  game.grid[1][1] = Organism(Barnacle)
  game.grid[2][2] = Organism(Crab)
  assert_eq(count_organism_on_grid(game, Barnacle), 2)
  assert_eq(count_organism_on_grid(game, Crab), 1)
  assert_eq(count_organism_on_grid(game, Algae), 0)
}

///|
test "get_available_count_no_level" {
  let game = new_game()
  assert_eq(get_available_count(game, Barnacle), 0)
}

///|
test "get_available_count_with_level" {
  let game = new_game()
  game.current_level = Some(
    {
      id: 0,
      name: "Test",
      tier: Shallow,
      description: "Test",
      depth_profile: [0, 0, 1, 1, 2, 2, 3, 3],
      available_organisms: [Barnacle, Crab],
      organism_counts: [3, 1],
      target_species: [Barnacle],
      rock_cells: [],
    },
  )
  assert_eq(get_available_count(game, Barnacle), 3)
  assert_eq(get_available_count(game, Crab), 1)
  assert_eq(get_available_count(game, Algae), 0)
  game.organisms_placed[0] = 2
  assert_eq(get_available_count(game, Barnacle), 1)
}

///|
test "is_cell_rock" {
  let level : LevelDef = {
    id: 0,
    name: "Test",
    tier: Shallow,
    description: "Test",
    depth_profile: [0, 0, 1, 1, 2, 2, 3, 3],
    available_organisms: [],
    organism_counts: [],
    target_species: [],
    rock_cells: [(0, 0), (2, 3)],
  }
  assert_true(is_cell_rock(level, 0, 0))
  assert_true(is_cell_rock(level, 2, 3))
  assert_false(is_cell_rock(level, 1, 1))
}

///|
test "zone_name" {
  assert_eq(zone_name(HighZone), "High")
  assert_eq(zone_name(MidZone), "Mid")
  assert_eq(zone_name(LowZone), "Low")
}
