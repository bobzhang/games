///|
pub fn update(game : @types.GameState) -> Unit {
  game.frame_count += 1
  game.anim_timer += @raylib.get_frame_time()
  match game.phase {
    Menu => update_menu(game)
    LevelSelect => update_level_select(game)
    Playing => update_playing(game)
    LevelComplete => update_level_complete(game)
    GameOver => update_game_over(game)
  }
}

///|
fn update_menu(game : @types.GameState) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    start_level(game, game.current_level)
  } else if @raylib.is_key_pressed(@raylib.KeyL) {
    game.phase = LevelSelect
  }
}

///|
fn update_level_select(game : @types.GameState) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.phase = Menu
    return
  }
  // Number keys 1-9 select levels
  for i in 0..<9 {
    if @raylib.is_key_pressed(@raylib.KeyOne + i) {
      start_level(game, i)
      return
    }
  }
  // 0 for level 10
  if @raylib.is_key_pressed(@raylib.KeyZero) {
    start_level(game, 9)
    return
  }
  // Arrow keys to navigate
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.current_level = (game.current_level + 1) % @types.total_levels
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.current_level = (game.current_level + @types.total_levels - 1) %
      @types.total_levels
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    start_level(game, game.current_level)
  }
}

///|
fn update_playing(game : @types.GameState) -> Unit {
  match game.level_state {
    Some(state) => {
      // Tick message timer
      if state.message_timer > 0.0 {
        state.message_timer -= @raylib.get_frame_time()
      }
      // Handle input
      if @raylib.is_key_pressed(@raylib.KeyW) ||
        @raylib.is_key_pressed(@raylib.KeyUp) {
        @navigation.try_move(state, North)
      } else if @raylib.is_key_pressed(@raylib.KeyS) ||
        @raylib.is_key_pressed(@raylib.KeyDown) {
        @navigation.try_move(state, South)
      } else if @raylib.is_key_pressed(@raylib.KeyA) ||
        @raylib.is_key_pressed(@raylib.KeyLeft) {
        @navigation.try_move(state, West)
      } else if @raylib.is_key_pressed(@raylib.KeyD) ||
        @raylib.is_key_pressed(@raylib.KeyRight) {
        @navigation.try_move(state, East)
      } else if @raylib.is_key_pressed(@raylib.KeyR) {
        start_level(game, game.current_level)
      } else if @raylib.is_key_pressed(@raylib.KeyEscape) {
        game.phase = Menu
        game.level_state = None
      }
      // Sync phase from level state
      if state.phase is LevelComplete {
        game.phase = LevelComplete
      }
      if state.phase is GameOver {
        game.phase = GameOver
      }
    }
    None => game.phase = Menu
  }
}

///|
fn update_level_complete(game : @types.GameState) -> Unit {
  match game.level_state {
    Some(state) => {
      // Record star rating
      let rating = @navigation.compute_star_rating(state)
      let current = game.stars[game.current_level]
      if @types.star_rating_value(rating) > @types.star_rating_value(current) {
        game.stars[game.current_level] = rating
      }
      if @raylib.is_key_pressed(@raylib.KeyEnter) {
        // Next level
        let next = game.current_level + 1
        if next < @types.total_levels {
          start_level(game, next)
        } else {
          game.phase = Menu
          game.level_state = None
        }
      } else if @raylib.is_key_pressed(@raylib.KeyEscape) {
        game.phase = LevelSelect
        game.level_state = None
      }
    }
    None => game.phase = Menu
  }
}

///|
fn update_game_over(game : @types.GameState) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.current_level)
  } else if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.phase = Menu
    game.level_state = None
  }
}

///|
fn start_level(game : @types.GameState, level : Int) -> Unit {
  let lvl = if level >= 0 && level < @types.total_levels { level } else { 0 }
  game.current_level = lvl
  game.level_state = Some(@levels.init_level(lvl))
  game.phase = Playing
}
