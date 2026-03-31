///|
pub fn update(game : @types.Game) -> Unit {
  let dt = @raylib.get_frame_time()
  game.frame_count += 1
  game.anim_timer += dt
  // Update message timer
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
  // Keyboard selection
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    game.selected_tier = Melody
    game.screen = LevelSelect
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) {
    game.selected_tier = Harmony
    game.screen = LevelSelect
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) {
    game.selected_tier = Counterpoint
    game.screen = LevelSelect
    return
  }
  // Mouse click on tier buttons
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let bx = (@types.screen_width - 500) / 2
    let bw = 500
    let bh = 120
    let tiers : Array[@types.Tier] = [Melody, Harmony, Counterpoint]
    for i in 0..<tiers.length() {
      let by = 170 + i * 150
      if mx >= bx && mx < bx + bw && my >= by && my < by + bh {
        game.selected_tier = tiers[i]
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
  let (lo, hi) = @types.tier_level_range(game.selected_tier)
  let count = hi - lo + 1
  // Mouse click on level buttons
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let cols = 4
    let btn_w = 240
    let btn_h = 100
    let gap_x = 30
    let gap_y = 25
    let total_w = cols * btn_w + (cols - 1) * gap_x
    let start_x = (@types.screen_width - total_w) / 2
    let start_y = 110
    for i in 0..<count {
      let col = i % cols
      let row = i / cols
      let bx = start_x + col * (btn_w + gap_x)
      let by = start_y + row * (btn_h + gap_y)
      if mx >= bx && mx < bx + btn_w && my >= by && my < by + btn_h {
        game.selected_level = lo + i
        start_level(game, lo + i)
        return
      }
    }
  }
}

///|
fn start_level(game : @types.Game, level_id : Int) -> Unit {
  let level = @levels.get_level(level_id)
  game.current_level = level
  game.grid = @types.new_grid(level.grid_cols, level.grid_rows)
  // Place target notes as locked
  for i in 0..<level.targets.length() {
    let t = level.targets[i]
    if t.col < game.grid.cols && t.row < game.grid.rows {
      let cell = game.grid.cells[t.col][t.row]
      cell.has_note = true
      cell.is_target = true
      cell.is_locked = true
    }
  }
  game.playback_col = 0
  game.play_state = Idle
  game.play_timer = 0.0
  game.harmony_score = 0
  game.notes_placed = 0
  game.targets_matched = 0
  game.stars = 0
  game.undo_stack = []
  game.message = ""
  game.message_timer = 0.0
  game.screen = Playing
}

///|
fn update_playing(game : @types.Game, dt : Float) -> Unit {
  // Escape to go back
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.play_state = Idle
    game.screen = LevelSelect
    return
  }
  // Restart
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.current_level.id)
    return
  }
  // Undo
  if @raylib.is_key_pressed(@raylib.KeyZ) {
    undo_last(game)
    return
  }
  // Play/stop
  if @raylib.is_key_pressed(@raylib.KeySpace) {
    match game.play_state {
      Idle => {
        game.play_state = Playing
        game.playback_col = 0
        game.play_timer = 0.0
      }
      Playing => {
        game.play_state = Idle
        game.playback_col = 0
      }
      Finished => {
        game.play_state = Idle
        game.playback_col = 0
      }
    }
    return
  }
  // Submit (Enter)
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    submit_level(game)
    return
  }
  // Update playback
  if game.play_state == Playing {
    game.play_timer += dt
    if game.play_timer >= @types.playback_speed {
      game.play_timer -= @types.playback_speed
      game.playback_col += 1
      if game.playback_col >= game.grid.cols {
        game.play_state = Finished
        game.playback_col = game.grid.cols - 1
      }
    }
  }
  // Click to toggle note
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    handle_grid_click(game)
  }
}

///|
fn handle_grid_click(game : @types.Game) -> Unit {
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cw = @types.cell_width
  let ch = @types.cell_height
  let grid = game.grid
  if mx >= ox && mx < ox + cw * grid.cols && my >= oy && my < oy + ch * grid.rows {
    let col = (mx - ox) / cw
    let row = (my - oy) / ch
    if col >= 0 && col < grid.cols && row >= 0 && row < grid.rows {
      let cell = grid.cells[col][row]
      // Cannot modify locked cells
      if cell.is_locked {
        game.message = "Target notes are locked"
        game.message_timer = 1.0
        return
      }
      if cell.has_note {
        // Remove note
        cell.has_note = false
        game.undo_stack.push({ col, row, was_note: true })
      } else {
        // Check budget
        let used = @types.count_notes_in_grid(grid)
        if used >= game.current_level.note_budget {
          game.message = "Note budget reached!"
          game.message_timer = 1.5
          return
        }
        // Place note
        cell.has_note = true
        game.undo_stack.push({ col, row, was_note: false })
      }
      // Update harmony score
      game.harmony_score = @harmony.compute_total_harmony(grid)
    }
  }
}

///|
fn undo_last(game : @types.Game) -> Unit {
  if game.undo_stack.length() == 0 {
    return
  }
  let entry = game.undo_stack.pop()
  match entry {
    Some(e) => {
      let cell = game.grid.cells[e.col][e.row]
      if e.was_note {
        // Was a removal, so restore the note
        cell.has_note = true
      } else {
        // Was a placement, so remove the note
        cell.has_note = false
      }
      game.harmony_score = @harmony.compute_total_harmony(game.grid)
    }
    None => ()
  }
}

///|
fn submit_level(game : @types.Game) -> Unit {
  let level = game.current_level
  let stars = @harmony.compute_stars(game.grid, level)
  game.stars = stars
  game.harmony_score = @harmony.compute_total_harmony(game.grid)
  game.targets_matched = @harmony.count_matched(game.grid, level.targets)
  // Update level score
  if level.id < game.level_scores.length() {
    let score = game.level_scores[level.id]
    if stars > score.stars {
      score.stars = stars
    }
    score.harmony_score = game.harmony_score
    score.targets_matched = game.targets_matched
    score.total_targets = level.targets.length()
    if stars > 0 {
      score.completed = true
    }
  }
  game.screen = Results
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.current_level.id)
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    // Go to next level
    let next_id = game.current_level.id + 1
    if next_id < @types.total_levels {
      start_level(game, next_id)
    } else {
      game.screen = LevelSelect
    }
    return
  }
}
