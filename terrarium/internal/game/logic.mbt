///|
pub fn start_level(game : @types.Game, level_id : Int) -> Unit {
  let level = @levels.get_level(level_id)
  game.current_level = Some(level)
  game.selected_level = level_id
  game.resources = @types.clone_resources(level.initial_resources)
  @types.clear_grid(game)
  game.current_turn = 0
  game.play_result = None
  game.selected_organism = None
  game.hover_row = -1
  game.hover_col = -1
  game.sim_log = []
  game.sim_speed_timer = 0.0
  game.message = level.description
  game.message_timer = 3.0
  game.anim_timer = 0.0
  game.screen = Playing
}

///|
pub fn start_simulation(game : @types.Game) -> Unit {
  game.screen = Simulating
  game.current_turn = 0
  game.sim_log = []
  game.sim_speed_timer = 0.0
  match game.current_level {
    Some(level) =>
      game.resources = @types.clone_resources(level.initial_resources)
    _ => ()
  }
  for i in 0..<game.organisms.length() {
    game.organisms[i].alive = true
    game.organisms[i].health = 100.0
    game.grid[game.organisms[i].row][game.organisms[i].col] = Organism(
      game.organisms[i].kind,
    )
  }
}

///|
pub fn update_simulation(game : @types.Game) -> Unit {
  game.sim_speed_timer += @raylib.get_frame_time()
  let sim_interval : Float = 0.4
  if game.sim_speed_timer >= sim_interval {
    game.sim_speed_timer -= sim_interval
    if game.current_turn < @types.max_turns {
      let log = @ecosystem.simulate_turn(game)
      game.sim_log.push(log)
      if log.organisms_alive == 0 {
        finish_simulation(game)
      }
    } else {
      finish_simulation(game)
    }
  }
}

///|
pub fn finish_simulation(game : @types.Game) -> Unit {
  game.play_result = @ecosystem.evaluate_result(game)
  match game.current_level {
    Some(level) => {
      let score = game.scores[level.id]
      match game.play_result {
        Victory => {
          score.completed = true
          if game.current_turn > score.best_turns_survived {
            score.best_turns_survived = game.current_turn
          }
          let total_placed = count_total_placed(game)
          let stars = @types.compute_stars(game.current_turn, total_placed)
          if stars > score.stars {
            score.stars = stars
          }
        }
        _ =>
          if game.current_turn > score.best_turns_survived {
            score.best_turns_survived = game.current_turn
          }
      }
    }
    _ => ()
  }
  game.screen = Results
}

///|
fn count_total_placed(game : @types.Game) -> Int {
  let mut total = 0
  for i in 0..<@types.num_organisms {
    total += game.organisms_placed[i]
  }
  total
}
