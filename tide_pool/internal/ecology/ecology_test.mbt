///|
test "advance_tide_sets_correct_level" {
  let game = @types.new_game()
  game.current_turn = 0
  advance_tide(game)
  assert_eq(game.tide_level, 1)
  assert_eq(game.tide_phase, Low)
  game.current_turn = 2
  advance_tide(game)
  assert_eq(game.tide_level, 4)
  assert_eq(game.tide_phase, High)
}

///|
test "update_submersion_marks_organisms" {
  let game = @types.new_game()
  game.current_level = Some({
    id: 0,
    name: "Test",
    tier: Shallow,
    description: "",
    depth_profile: [0, 0, 1, 1, 2, 2, 3, 3],
    available_organisms: [],
    organism_counts: [],
    target_species: [],
    rock_cells: [],
  })
  game.organisms = [
    {
      kind: Barnacle,
      row: 5,
      col: 0,
      alive: true,
      health: 100.0,
      submerged: false,
    },
    {
      kind: Anemone,
      row: 0,
      col: 0,
      alive: true,
      health: 100.0,
      submerged: false,
    },
  ]
  game.tide_level = 4
  update_submersion(game)
  assert_true(game.organisms[0].submerged)
  assert_false(game.organisms[1].submerged)
}

///|
test "apply_health_effects_submersion_heals_barnacle" {
  let game = @types.new_game()
  let org : @types.OrganismState = {
    kind: Barnacle,
    row: 5,
    col: 0,
    alive: true,
    health: 50.0,
    submerged: true,
  }
  game.organisms = [org]
  let events : Array[String] = []
  apply_health_effects(game, events)
  assert_true(org.health > 50.0)
}

///|
test "apply_health_effects_exposure_damages_anemone" {
  let game = @types.new_game()
  let org : @types.OrganismState = {
    kind: Anemone,
    row: 0,
    col: 0,
    alive: true,
    health: 80.0,
    submerged: false,
  }
  game.organisms = [org]
  let events : Array[String] = []
  apply_health_effects(game, events)
  assert_true(org.health < 80.0)
}

///|
test "apply_health_effects_algae_thrives_exposed" {
  let game = @types.new_game()
  let org : @types.OrganismState = {
    kind: Algae,
    row: 0,
    col: 0,
    alive: true,
    health: 50.0,
    submerged: false,
  }
  game.organisms = [org]
  let events : Array[String] = []
  apply_health_effects(game, events)
  assert_true(org.health > 50.0)
}

///|
test "apply_health_effects_algae_decays_submerged" {
  let game = @types.new_game()
  let org : @types.OrganismState = {
    kind: Algae,
    row: 5,
    col: 0,
    alive: true,
    health: 50.0,
    submerged: true,
  }
  game.organisms = [org]
  let events : Array[String] = []
  apply_health_effects(game, events)
  assert_true(org.health < 50.0)
}

///|
test "check_deaths_kills_zero_health" {
  let game = @types.new_game()
  let org : @types.OrganismState = {
    kind: Barnacle,
    row: 2,
    col: 3,
    alive: true,
    health: 0.0,
    submerged: false,
  }
  game.organisms = [org]
  game.grid[2][3] = Organism(Barnacle)
  let events : Array[String] = []
  check_deaths(game, events)
  assert_false(org.alive)
  assert_eq(game.grid[2][3], Empty)
}

///|
test "apply_predation_starfish_attacks_barnacle" {
  let game = @types.new_game()
  let starfish : @types.OrganismState = {
    kind: Starfish,
    row: 3,
    col: 3,
    alive: true,
    health: 60.0,
    submerged: true,
  }
  let barnacle : @types.OrganismState = {
    kind: Barnacle,
    row: 3,
    col: 4,
    alive: true,
    health: 80.0,
    submerged: true,
  }
  game.organisms = [starfish, barnacle]
  let events : Array[String] = []
  apply_predation(game, events)
  assert_true(barnacle.health < 80.0)
  assert_true(starfish.health > 60.0)
}

///|
test "apply_predation_hungry_predator_loses_health" {
  let game = @types.new_game()
  let starfish : @types.OrganismState = {
    kind: Starfish,
    row: 0,
    col: 0,
    alive: true,
    health: 60.0,
    submerged: true,
  }
  game.organisms = [starfish]
  let events : Array[String] = []
  apply_predation(game, events)
  assert_true(starfish.health < 60.0)
}

///|
test "apply_algae_growth_bloom_without_grazers" {
  let game = @types.new_game()
  let algae1 : @types.OrganismState = {
    kind: Algae,
    row: 0,
    col: 0,
    alive: true,
    health: 50.0,
    submerged: false,
  }
  let algae2 : @types.OrganismState = {
    kind: Algae,
    row: 0,
    col: 1,
    alive: true,
    health: 50.0,
    submerged: false,
  }
  let algae3 : @types.OrganismState = {
    kind: Algae,
    row: 0,
    col: 2,
    alive: true,
    health: 50.0,
    submerged: false,
  }
  game.organisms = [algae1, algae2, algae3]
  let events : Array[String] = []
  apply_algae_growth(game, events)
  assert_true(algae1.health > 50.0)
  assert_true(events.length() > 0)
}

///|
test "apply_algae_growth_controlled_by_urchin" {
  let game = @types.new_game()
  let algae : @types.OrganismState = {
    kind: Algae,
    row: 0,
    col: 0,
    alive: true,
    health: 50.0,
    submerged: false,
  }
  let urchin : @types.OrganismState = {
    kind: Urchin,
    row: 1,
    col: 0,
    alive: true,
    health: 80.0,
    submerged: true,
  }
  game.organisms = [algae, urchin]
  let events : Array[String] = []
  apply_algae_growth(game, events)
  inspect(algae.health.to_double(), content="50")
}

///|
test "simulate_turn_advances_state" {
  let game = @types.new_game()
  game.current_level = Some({
    id: 0,
    name: "Test",
    tier: Shallow,
    description: "",
    depth_profile: [0, 0, 1, 1, 2, 2, 3, 3],
    available_organisms: [Barnacle],
    organism_counts: [2],
    target_species: [Barnacle],
    rock_cells: [],
  })
  game.organisms = [
    {
      kind: Barnacle,
      row: 5,
      col: 7,
      alive: true,
      health: 100.0,
      submerged: false,
    },
  ]
  game.grid[5][7] = Organism(Barnacle)
  let log = simulate_turn(game)
  assert_eq(game.current_turn, 1)
  assert_true(log.events.length() > 0)
}

///|
test "check_victory_all_targets_alive_after_3_cycles" {
  let game = @types.new_game()
  game.current_level = Some({
    id: 0,
    name: "Test",
    tier: Shallow,
    description: "",
    depth_profile: [0, 0, 1, 1, 2, 2, 3, 3],
    available_organisms: [Barnacle],
    organism_counts: [1],
    target_species: [Barnacle],
    rock_cells: [],
  })
  game.organisms = [
    {
      kind: Barnacle,
      row: 5,
      col: 0,
      alive: true,
      health: 80.0,
      submerged: true,
    },
  ]
  game.current_cycle = 3
  let result = check_victory(game)
  assert_eq(result, Victory)
}

///|
test "check_victory_target_died" {
  let game = @types.new_game()
  game.current_level = Some({
    id: 0,
    name: "Test",
    tier: Shallow,
    description: "",
    depth_profile: [0, 0, 1, 1, 2, 2, 3, 3],
    available_organisms: [Barnacle],
    organism_counts: [1],
    target_species: [Barnacle],
    rock_cells: [],
  })
  game.organisms = [
    {
      kind: Barnacle,
      row: 5,
      col: 0,
      alive: false,
      health: 0.0,
      submerged: false,
    },
  ]
  game.current_cycle = 1
  let result = check_victory(game)
  guard result is Failure(_)
}

///|
test "count_alive" {
  let game = @types.new_game()
  game.organisms = [
    {
      kind: Barnacle,
      row: 0,
      col: 0,
      alive: true,
      health: 80.0,
      submerged: false,
    },
    { kind: Crab, row: 1, col: 1, alive: false, health: 0.0, submerged: false },
    { kind: Algae, row: 2, col: 2, alive: true, health: 50.0, submerged: false },
  ]
  assert_eq(count_alive(game), 2)
}

///|
test "get_water_row" {
  assert_eq(get_water_row(4, 0), 2)
  assert_eq(get_water_row(1, 0), 5)
  assert_eq(get_water_row(2, 1), 3)
  assert_eq(get_water_row(4, 3), -1)
}
