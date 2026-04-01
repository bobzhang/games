///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count += 1
  // Decay message timer
  if game.message_timer > 0.0 {
    game.message_timer -= 1.0 / Float::from_int(@types.target_fps)
    if game.message_timer <= 0.0 {
      game.message = ""
      game.message_timer = 0.0
    }
  }
  match game.screen {
    Title => update_title(game)
    TierSelect => update_tier_select(game)
    LevelSelect => update_level_select(game)
    Playing => update_playing(game)
    Results => update_results(game)
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
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
  // Mouse click on tier buttons
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let sw = @types.screen_width
    for i in 0..<3 {
      let bx = sw / 2 - 160
      let by = 150 + i * 140
      let bw = 320
      let bh = 110
      if mx >= bx && mx < bx + bw && my >= by && my < by + bh {
        game.selected_tier = i
        game.screen = LevelSelect
        return
      }
    }
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = TierSelect
    return
  }
  // Mouse click on level buttons
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let sw = @types.screen_width
    let tier : @types.Tier = match game.selected_tier {
      0 => Seedling
      1 => Grove
      _ => Forest
    }
    let start = @levels.tier_start_level(tier)
    let count = @levels.tier_level_count(tier)
    let cols = 4
    let bw = 140
    let bh = 100
    let gap = 20
    let total_w = cols * bw + (cols - 1) * gap
    let base_x = (sw - total_w) / 2
    let base_y = 100
    for i in 0..<count {
      let col = i % cols
      let row = i / cols
      let bx = base_x + col * (bw + gap)
      let by = base_y + row * (bh + gap)
      if mx >= bx && mx < bx + bw && my >= by && my < by + bh {
        let level_idx = start + i
        @levels.load_level(game, level_idx)
        game.screen = Playing
        return
      }
    }
  }
}

///|
fn update_playing(game : @types.Game) -> Unit {
  // Update hover position
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let gx = @types.grid_offset_x
  let gy = @types.grid_offset_y
  let cs = @types.cell_size
  game.hover_col = (mx - gx) / cs
  game.hover_row = (my - gy) / cs
  if game.hover_col < 0 || game.hover_col >= @types.grid_cols {
    game.hover_col = -1
  }
  if game.hover_row < 0 || game.hover_row >= @types.grid_rows {
    game.hover_row = -1
  }
  match game.play_state {
    Idle => {
      // ESC: back to level select
      if @raylib.is_key_pressed(@raylib.KeyEscape) {
        game.screen = LevelSelect
        return
      }
      // Space: advance turn
      if @raylib.is_key_pressed(@raylib.KeySpace) {
        @growth.simulate_turn(game)
        @growth.check_win_or_lose(game)
        if game.play_state == Won {
          // Record score
          let stars = @growth.calculate_stars(game)
          if game.current_level < game.level_scores.length() {
            let score = game.level_scores[game.current_level]
            if stars > score.stars {
              score.stars = stars
            }
            score.completed = true
            score.turns_used = game.turn
            score.prunes_used = game.prunes_used
          }
        }
        return
      }
      // R: restart level
      if @raylib.is_key_pressed(@raylib.KeyR) {
        @levels.load_level(game, game.current_level)
        return
      }
      // Z: undo
      if @raylib.is_key_pressed(@raylib.KeyZ) {
        if @types.restore_undo(game) {
          game.message = "Undo!"
          game.message_timer = 1.0
        }
        return
      }
      // Mouse click: prune branch
      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        if game.hover_col >= 0 && game.hover_row >= 0 {
          let cell = game.grid.cells[game.hover_row][game.hover_col]
          if cell == Branch {
            let result = @growth.find_branch_at(
              game,
              game.hover_col,
              game.hover_row,
            )
            let ti = result.0
            let bi = result.1
            if ti >= 0 && bi >= 0 {
              if @growth.prune_branch(game, ti, bi) {
                game.message = "Pruned!"
                game.message_timer = 1.0
              } else if game.prunes_used >= game.prune_budget {
                game.message = "No prunes left!"
                game.message_timer = 1.5
              }
            }
          }
        }
        return
      }
    }
    Won =>
      if @raylib.is_key_pressed(@raylib.KeyEnter) {
        game.screen = Results
        return
      }
    Lost => {
      if @raylib.is_key_pressed(@raylib.KeyR) {
        @levels.load_level(game, game.current_level)
        return
      }
      if @raylib.is_key_pressed(@raylib.KeyEscape) {
        game.screen = LevelSelect
        return
      }
    }
    Animating => ()
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    @levels.load_level(game, game.current_level)
    game.screen = Playing
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    let stars = if game.current_level < game.level_scores.length() {
      game.level_scores[game.current_level].stars
    } else {
      0
    }
    if stars > 0 && game.current_level < @types.total_levels - 1 {
      @levels.load_level(game, game.current_level + 1)
      game.screen = Playing
    } else {
      game.screen = LevelSelect
    }
  }
}
