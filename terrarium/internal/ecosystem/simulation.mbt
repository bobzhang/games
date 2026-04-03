///|
pub fn check_organism_alive(
  org : @types.OrganismState,
  res : @types.Resources,
) -> Bool {
  let profile = @types.get_profile(org.kind)
  if res.water < profile.min_water {
    return false
  }
  if res.o2 < profile.min_o2 {
    return false
  }
  if res.co2 < profile.min_co2 {
    return false
  }
  if res.nutrients < profile.min_nutrients {
    return false
  }
  true
}

///|
pub fn count_adjacent_plants(
  grid : Array[Array[@types.CellContent]],
  row : Int,
  col : Int,
) -> Int {
  let mut count = 0
  let offsets : Array[(Int, Int)] = [(-1, 0), (1, 0), (0, -1), (0, 1)]
  for i in 0..<offsets.length() {
    let (dr, dc) = offsets[i]
    let nr = row + dr
    let nc = col + dc
    if @types.in_grid(nr, nc) {
      match grid[nr][nc] {
        Organism(Moss) | Organism(Fern) => count += 1
        _ => ()
      }
    }
  }
  count
}

///|
pub fn herbivore_has_food(
  grid : Array[Array[@types.CellContent]],
  row : Int,
  col : Int,
) -> Bool {
  count_adjacent_plants(grid, row, col) > 0
}

///|
pub fn apply_organism_effects(
  organisms : Array[@types.OrganismState],
  resources : @types.Resources,
  grid : Array[Array[@types.CellContent]],
) -> Array[String] {
  let events : Array[String] = []
  for i in 0..<organisms.length() {
    let org = organisms[i]
    if !org.alive {
      continue
    }
    let profile = @types.get_profile(org.kind)
    let mut can_act = true
    match org.kind {
      Beetle | Snail =>
        if !herbivore_has_food(grid, org.row, org.col) {
          can_act = false
          org.health -= 15.0
          events.push(
            profile.name +
            " at (" +
            org.row.to_string() +
            "," +
            org.col.to_string() +
            ") has no food nearby",
          )
          if org.health <= 0.0 {
            org.alive = false
            grid[org.row][org.col] = Empty
            events.push(profile.name + " starved!")
          }
        }
      _ => ()
    }
    if can_act && org.alive {
      resources.o2 += profile.o2_delta
      resources.co2 += profile.co2_delta
      resources.water += profile.water_delta
      resources.nutrients += profile.nutrient_delta
    }
  }
  events
}

///|
pub fn check_resource_deaths(
  organisms : Array[@types.OrganismState],
  resources : @types.Resources,
  grid : Array[Array[@types.CellContent]],
) -> Array[String] {
  let events : Array[String] = []
  for i in 0..<organisms.length() {
    let org = organisms[i]
    if !org.alive {
      continue
    }
    if !check_organism_alive(org, resources) {
      let profile = @types.get_profile(org.kind)
      org.alive = false
      grid[org.row][org.col] = Empty
      let mut reason = ""
      if resources.water < profile.min_water {
        reason = "dehydration"
      } else if resources.o2 < profile.min_o2 {
        reason = "suffocation"
      } else if resources.co2 < profile.min_co2 {
        reason = "no CO2"
      } else {
        reason = "nutrient depletion"
      }
      events.push(profile.name + " died from " + reason)
    }
  }
  events
}

///|
pub fn count_alive(organisms : Array[@types.OrganismState]) -> Int {
  let mut c = 0
  for i in 0..<organisms.length() {
    if organisms[i].alive {
      c += 1
    }
  }
  c
}

///|
pub fn simulate_turn(game : @types.Game) -> @types.SimTurnLog {
  let turn = game.current_turn + 1
  let events : Array[String] = []
  let prod_events = apply_organism_effects(
    game.organisms,
    game.resources,
    game.grid,
  )
  for i in 0..<prod_events.length() {
    events.push(prod_events[i])
  }
  @types.clamp_resources(game.resources)
  let death_events = check_resource_deaths(
    game.organisms,
    game.resources,
    game.grid,
  )
  for i in 0..<death_events.length() {
    events.push(death_events[i])
  }
  @types.clamp_resources(game.resources)
  let alive = count_alive(game.organisms)
  game.current_turn = turn
  {
    turn,
    events,
    resources_after: @types.clone_resources(game.resources),
    organisms_alive: alive,
  }
}

///|
pub fn run_full_simulation(game : @types.Game) -> Unit {
  game.sim_log = []
  game.current_turn = 0
  for _t in 0..<@types.max_turns {
    let log = simulate_turn(game)
    game.sim_log.push(log)
    if log.organisms_alive == 0 {
      break
    }
  }
}

///|
pub fn evaluate_result(game : @types.Game) -> @types.PlayResult {
  let alive = count_alive(game.organisms)
  if alive == 0 {
    return Failure("All organisms died!")
  }
  if game.current_turn < @types.max_turns {
    return Failure(
      "Ecosystem collapsed at turn " + game.current_turn.to_string(),
    )
  }
  Victory
}
