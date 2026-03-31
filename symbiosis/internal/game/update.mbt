///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count += 1
  // Decay message timer
  if game.message_timer > 0.0 {
    game.message_timer -= @raylib.get_frame_time()
    if game.message_timer <= 0.0 {
      game.message = ""
    }
  }
  match game.screen {
    Title => update_title(game)
    WorldSelect => update_world_select(game)
    LevelSelect => update_level_select(game)
    Playing => update_playing(game)
    Results => update_results(game)
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.screen = WorldSelect
    game.selected_world = 0
  }
}

///|
fn update_world_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyW) {
    if game.selected_world > 0 {
      game.selected_world -= 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) ||
    @raylib.is_key_pressed(@raylib.KeyS) {
    if game.selected_world < @types.num_worlds - 1 {
      game.selected_world += 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    if @levels.world_unlocked(game.scores, game.selected_world) {
      game.screen = LevelSelect
      game.selected_level = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyW) {
    if game.selected_level > 0 {
      game.selected_level -= 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) ||
    @raylib.is_key_pressed(@raylib.KeyS) {
    if game.selected_level < @types.levels_per_world - 1 {
      game.selected_level += 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    if @levels.level_unlocked(
      game.scores,
      game.selected_world,
      game.selected_level,
    ) {
      start_level(game, game.selected_world, game.selected_level)
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = WorldSelect
  }
}

///|
fn start_level(game : @types.Game, world : Int, level_idx : Int) -> Unit {
  let level = @levels.get_level(world, level_idx)
  @types.init_level(game, level)
  game.screen = Playing
}

///|
fn update_playing(game : @types.Game) -> Unit {
  match game.play_state {
    Active => {
      // Movement inputs
      let mut input : @types.MoveInput? = None
      if @raylib.is_key_pressed(@raylib.KeyUp) ||
        @raylib.is_key_pressed(@raylib.KeyW) {
        input = Some(DirInput(Up))
      } else if @raylib.is_key_pressed(@raylib.KeyDown) ||
        @raylib.is_key_pressed(@raylib.KeyS) {
        input = Some(DirInput(Down))
      } else if @raylib.is_key_pressed(@raylib.KeyLeft) ||
        @raylib.is_key_pressed(@raylib.KeyA) {
        input = Some(DirInput(Left))
      } else if @raylib.is_key_pressed(@raylib.KeyRight) ||
        @raylib.is_key_pressed(@raylib.KeyD) {
        input = Some(DirInput(Right))
      } else if @raylib.is_key_pressed(@raylib.KeySpace) {
        input = Some(Wait)
      }
      match input {
        Some(inp) => @simulation.simulate_move(game, inp)
        None => ()
      }
      // Undo
      if @raylib.is_key_pressed(@raylib.KeyZ) {
        @simulation.undo_move(game)
      }
      // Restart
      if @raylib.is_key_pressed(@raylib.KeyR) {
        @simulation.restart_level(game)
      }
      // Back to level select
      if @raylib.is_key_pressed(@raylib.KeyEscape) {
        game.screen = LevelSelect
      }
    }
    Won => {
      if @raylib.is_key_pressed(@raylib.KeyEnter) {
        game.screen = Results
      }
      if @raylib.is_key_pressed(@raylib.KeyR) {
        @simulation.restart_level(game)
      }
      if @raylib.is_key_pressed(@raylib.KeyEscape) {
        game.screen = LevelSelect
      }
    }
    Failed => {
      if @raylib.is_key_pressed(@raylib.KeyR) {
        @simulation.restart_level(game)
      }
      if @raylib.is_key_pressed(@raylib.KeyZ) {
        @simulation.undo_move(game)
      }
      if @raylib.is_key_pressed(@raylib.KeyEscape) {
        game.screen = LevelSelect
      }
    }
    Paused => {
      if @raylib.is_key_pressed(@raylib.KeyEscape) ||
        @raylib.is_key_pressed(@raylib.KeyP) {
        game.play_state = Active
      }
    }
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    // Next level
    match game.current_level {
      None => game.screen = LevelSelect
      Some(level) => {
        let next_level = level.index + 1
        if next_level < @types.levels_per_world {
          start_level(game, level.world, next_level)
          game.selected_level = next_level
        } else {
          // Next world
          let next_world = level.world + 1
          if next_world < @types.num_worlds &&
            @levels.world_unlocked(game.scores, next_world) {
            game.selected_world = next_world
            game.selected_level = 0
            game.screen = LevelSelect
          } else {
            game.screen = LevelSelect
          }
        }
      }
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    @simulation.restart_level(game)
    game.screen = Playing
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}
