///|
pub fn simulate_turn(game : @types.Game) -> @types.TurnLog {
  let events : Array[String] = []
  advance_tide(game)
  update_submersion(game)
  let (tide, phase) = @types.get_tide_for_turn(game.current_turn)
  events.push("Turn \{game.current_turn + 1}: Tide \{phase} (level \{tide})")
  apply_health_effects(game, events)
  apply_predation(game, events)
  apply_algae_growth(game, events)
  check_deaths(game, events)
  let mut alive_count = 0
  for i in 0..<game.organisms.length() {
    if game.organisms[i].alive {
      alive_count += 1
    }
  }
  let log : @types.TurnLog = {
    turn: game.current_turn,
    tide_level: game.tide_level,
    phase: game.tide_phase,
    events,
    organisms_alive: alive_count,
  }
  game.current_turn += 1
  if game.current_turn % @types.cycle_length == 0 {
    game.current_cycle += 1
  }
  log
}

///|
pub fn check_victory(game : @types.Game) -> @types.PlayResult {
  match game.current_level {
    None => None
    Some(level) => {
      let mut all_targets_alive = true
      for i in 0..<level.target_species.length() {
        let target = level.target_species[i]
        let mut found = false
        for j in 0..<game.organisms.length() {
          if game.organisms[j].alive && game.organisms[j].kind == target {
            found = true
            break
          }
        }
        if !found {
          all_targets_alive = false
          break
        }
      }
      if !all_targets_alive {
        let target_names : Array[String] = []
        for i in 0..<level.target_species.length() {
          let p = @types.get_profile(level.target_species[i])
          target_names.push(p.name)
        }
        return Failure("Target species died: \{target_names.join(", ")}")
      }
      if game.current_cycle >= @types.total_cycles {
        return Victory
      }
      None
    }
  }
}

///|
pub fn count_alive(game : @types.Game) -> Int {
  let mut count = 0
  for i in 0..<game.organisms.length() {
    if game.organisms[i].alive {
      count += 1
    }
  }
  count
}
