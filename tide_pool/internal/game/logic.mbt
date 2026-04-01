///|
pub fn update_simulation(game : @types.Game) -> Unit {
  let dt = @raylib.get_frame_time()
  game.sim_speed_timer = game.sim_speed_timer + dt
  let sim_interval : Float = 0.8
  if game.sim_speed_timer < sim_interval {
    return
  }
  game.sim_speed_timer = 0.0
  if game.current_turn >= @types.max_turns {
    finalize_simulation(game)
    return
  }
  let result = @ecology.check_victory(game)
  match result {
    Failure(_) => {
      game.play_result = result
      finalize_simulation(game)
      return
    }
    Victory => {
      game.play_result = result
      finalize_simulation(game)
      return
    }
    None => ()
  }
  let log = @ecology.simulate_turn(game)
  game.sim_log.push(log)
  let post_result = @ecology.check_victory(game)
  match post_result {
    Failure(_) => {
      game.play_result = post_result
      finalize_simulation(game)
    }
    Victory => {
      game.play_result = post_result
      finalize_simulation(game)
    }
    None => ()
  }
}

///|
fn finalize_simulation(game : @types.Game) -> Unit {
  game.screen = Results
  match game.current_level {
    None => ()
    Some(_level) => {
      let level_id = game.selected_level
      if level_id >= 0 && level_id < game.scores.length() {
        let score = game.scores[level_id]
        if game.current_cycle > score.best_cycles_survived {
          score.best_cycles_survived = game.current_cycle
        }
        if game.play_result == Victory {
          score.completed = true
          let total_placed = game.organisms.length()
          let stars = @types.compute_stars(game.current_cycle, total_placed)
          if stars > score.stars {
            score.stars = stars
          }
        }
      }
    }
  }
}
