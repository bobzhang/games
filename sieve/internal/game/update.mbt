///|
pub fn update(game : @types.Game) -> Unit {
  let dt : Float = @raylib.get_frame_time()
  game.frame_count += 1
  game.anim_timer += dt
  if game.message_timer > 0.0 {
    game.message_timer -= dt
    if game.message_timer < 0.0 {
      game.message_timer = 0.0
    }
  }
  match game.screen {
    Title => update_title(game)
    TierSelect => update_tier_select(game)
    LevelSelect => update_level_select(game)
    Playing => update_playing(game, dt)
    Results => update_results(game)
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let w = @types.screen_width
    let h = @types.screen_height
    // Play button
    if mx >= w / 2 - 120 &&
      mx <= w / 2 + 120 &&
      my >= h / 2 + 30 &&
      my <= h / 2 + 90 {
      game.screen = TierSelect
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.screen = TierSelect
  }
}

///|
fn update_tier_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
    return
  }
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let w = @types.screen_width
    let tiers : Array[@types.Tier] = [Primes, Factors, Theorem]
    let card_w = 300
    let card_h = 200
    let gap = 40
    let total_w = 3 * card_w + 2 * gap
    let start_x = (w - total_w) / 2
    let start_y = 140
    for i in 0..<3 {
      let x = start_x + i * (card_w + gap)
      let y = start_y
      if mx >= x && mx <= x + card_w && my >= y && my <= y + card_h {
        game.current_tier = tiers[i]
        game.screen = LevelSelect
        return
      }
    }
    // Back button
    if mx >= w / 2 - 80 && mx <= w / 2 + 80 && my >= 500 && my <= 545 {
      game.screen = Title
    }
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = TierSelect
    return
  }
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let w = @types.screen_width
    let count = @types.tier_level_count(game.current_tier)
    let start = @types.tier_start_index(game.current_tier)
    let btn_w = 100
    let btn_h = 80
    let cols = 5
    let gap = 20
    let total_w = cols * btn_w + (cols - 1) * gap
    let start_x = (w - total_w) / 2
    let start_y = 100
    for i in 0..<count {
      let col = i % cols
      let row = i / cols
      let x = start_x + col * (btn_w + gap)
      let y = start_y + row * (btn_h + gap)
      if mx >= x && mx <= x + btn_w && my >= y && my <= y + btn_h {
        start_level(game, start + i)
        return
      }
    }
    // Back button
    if mx >= w / 2 - 80 && mx <= w / 2 + 80 && my >= 550 && my <= 595 {
      game.screen = TierSelect
    }
  }
}

///|
fn start_level(game : @types.Game, index : Int) -> Unit {
  let level = @levels.get_level(index)
  game.current_level = Some(level)
  game.current_level_index = index
  game.screen = Playing
  game.play_state = Editing
  game.selected_row = -1
  game.selected_col = -1
  game.timer = 0.0
  game.incorrect_placements = 0
  game.undo_stack = []
  game.message = ""
  game.message_timer = 0.0
  game.checking_timer = 0.0
}

///|
fn update_playing(game : @types.Game, dt : Float) -> Unit {
  match game.current_level {
    None => ()
    Some(level) => {
      // Timer
      if game.play_state == Editing {
        game.timer += dt
      }
      // Escape to go back
      if @raylib.is_key_pressed(@raylib.KeyEscape) {
        game.screen = LevelSelect
        return
      }
      // Check if solved and pressing enter for results
      if game.play_state == Solved {
        if @raylib.is_key_pressed(@raylib.KeyEnter) {
          game.screen = Results
        }
        return
      }
      // Checking animation
      if game.play_state == Checking {
        game.checking_timer -= dt
        if game.checking_timer <= 0.0 {
          let all_sat = @constraints.validate_all(level.grid, level.constraints)
          if all_sat {
            game.play_state = Solved
            // Calculate stars
            let mut stars = 1
            if game.timer <= level.par_time {
              stars = 2
              if game.incorrect_placements == 0 {
                stars = 3
              }
            }
            let score = game.scores[game.current_level_index]
            score.completed = true
            if stars > score.stars {
              score.stars = stars
            }
            if score.best_time == 0.0 || game.timer < score.best_time {
              score.best_time = game.timer
            }
          } else {
            game.play_state = Failed
            game.message = "Some constraints not met!"
            game.message_timer = 2.0
          }
        }
        return
      }
      // Failed state - continue editing
      if game.play_state == Failed {
        game.play_state = Editing
      }
      // R to restart
      if @raylib.is_key_pressed(@raylib.KeyR) {
        restart_level(game, level)
        return
      }
      // Z to undo
      if @raylib.is_key_pressed(@raylib.KeyZ) {
        undo_move(game, level)
        return
      }
      // Enter to check
      if @raylib.is_key_pressed(@raylib.KeyEnter) {
        if @types.grid_is_full(level.grid) {
          game.play_state = Checking
          game.checking_timer = 0.5
        } else {
          game.message = "Fill all cells first!"
          game.message_timer = 1.5
        }
        return
      }
      // Mouse click to select cell
      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        let mx = @raylib.get_mouse_x()
        let my = @raylib.get_mouse_y()
        handle_grid_click(game, level, mx, my)
        handle_palette_click(game, level, mx, my)
      }
      // Number keys
      handle_number_keys(game, level)
    }
  }
}

///|
fn handle_grid_click(
  game : @types.Game,
  level : @types.Level,
  mx : Int,
  my : Int,
) -> Unit {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  let gs = @types.grid_size
  if mx >= ox && mx < ox + gs * cs && my >= oy && my < oy + gs * cs {
    let col = (mx - ox) / cs
    let row = (my - oy) / cs
    if !@types.grid_is_locked(level.grid, row, col) {
      game.selected_row = row
      game.selected_col = col
    }
  }
}

///|
fn handle_palette_click(
  game : @types.Game,
  level : @types.Level,
  mx : Int,
  my : Int,
) -> Unit {
  let px = @types.palette_x
  let py = @types.palette_y
  let pc = @types.palette_cell
  if game.selected_row < 0 || game.selected_col < 0 {
    return
  }
  // Numbers 1-9
  for i in 0..<9 {
    let x = px + i * (pc + 4)
    if mx >= x && mx <= x + pc && my >= py && my <= py + pc {
      place_number(game, level, i + 1)
      return
    }
  }
  // Clear button
  let cx = px + 9 * (pc + 4)
  if mx >= cx && mx <= cx + pc && my >= py && my <= py + pc {
    place_number(game, level, 0)
  }
}

///|
fn handle_number_keys(game : @types.Game, level : @types.Level) -> Unit {
  if game.selected_row < 0 || game.selected_col < 0 {
    return
  }
  for i in 0..<9 {
    if @raylib.is_key_pressed(@raylib.KeyOne + i) {
      place_number(game, level, i + 1)
      return
    }
  }
  // 0 or delete/backspace to clear
  if @raylib.is_key_pressed(@raylib.KeyZero) ||
    @raylib.is_key_pressed(@raylib.KeyBackspace) ||
    @raylib.is_key_pressed(@raylib.KeyDelete) {
    place_number(game, level, 0)
  }
}

///|
fn place_number(game : @types.Game, level : @types.Level, num : Int) -> Unit {
  let row = game.selected_row
  let col = game.selected_col
  if row < 0 || col < 0 {
    return
  }
  if @types.grid_is_locked(level.grid, row, col) {
    return
  }
  let old_val = @types.grid_get(level.grid, row, col)
  if old_val == num {
    return
  }
  // Push undo
  game.undo_stack.push({ row, col, old_value: old_val })
  @types.grid_set(level.grid, row, col, num)
  // Check for conflicts (incremental)
  if num > 0 &&
    @constraints.check_cell_conflicts(level.grid, row, col, level.constraints) {
    game.incorrect_placements += 1
    game.message = "Conflict detected!"
    game.message_timer = 1.0
  }
}

///|
fn undo_move(game : @types.Game, level : @types.Level) -> Unit {
  if game.undo_stack.length() == 0 {
    return
  }
  let entry = game.undo_stack.pop()
  match entry {
    Some(e) => {
      @types.grid_set(level.grid, e.row, e.col, e.old_value)
      game.selected_row = e.row
      game.selected_col = e.col
    }
    None => ()
  }
}

///|
fn restart_level(game : @types.Game, level : @types.Level) -> Unit {
  // Reset non-locked cells
  for row in 0..<level.grid.size {
    for col in 0..<level.grid.size {
      if !@types.grid_is_locked(level.grid, row, col) {
        @types.grid_set(level.grid, row, col, 0)
      }
    }
  }
  // Reset constraints
  for i in 0..<level.constraints.length() {
    level.constraints[i].satisfied = false
  }
  game.play_state = Editing
  game.timer = 0.0
  game.incorrect_placements = 0
  game.undo_stack = []
  game.selected_row = -1
  game.selected_col = -1
  game.message = "Level restarted"
  game.message_timer = 1.0
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let w = @types.screen_width
    let h = @types.screen_height
    let ph = 400
    let py = (h - ph) / 2
    // Next level button
    let btn_y = py + ph - 70
    let next_x = (w - 200) / 2 - 120
    if mx >= next_x && mx <= next_x + 200 && my >= btn_y && my <= btn_y + 50 {
      let next_idx = game.current_level_index + 1
      if next_idx < @types.total_levels {
        start_level(game, next_idx)
      } else {
        game.screen = LevelSelect
      }
      return
    }
    // Level select button
    let sel_x = (w - 200) / 2 + 120
    if mx >= sel_x && mx <= sel_x + 200 && my >= btn_y && my <= btn_y + 50 {
      game.screen = LevelSelect
      return
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    let next_idx = game.current_level_index + 1
    if next_idx < @types.total_levels {
      start_level(game, next_idx)
    } else {
      game.screen = LevelSelect
    }
  }
}
