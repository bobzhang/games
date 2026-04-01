///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count += 1
  let dt = @raylib.get_frame_time()
  // Message timer
  if game.message_timer > 0.0 {
    game.message_timer -= dt
  }
  // Animation timer
  if game.anim_timer > 0.0 {
    game.anim_timer -= dt
    if game.anim_timer <= 0.0 {
      game.anim_timer = 0.0
      game.play_state = Selecting
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
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = TierSelect
  }
}

///|
fn update_tier_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
    return
  }
  // Mouse hover detection
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let tier_w = 280
  let tier_h = 180
  let gap = 40
  let total_w = 3 * tier_w + 2 * gap
  let start_x = (@types.screen_width - total_w) / 2
  let tier_y = (@types.screen_height - tier_h) / 2
  game.hover_button = -1
  for i in 0..<3 {
    let bx = start_x + i * (tier_w + gap)
    if mx >= bx && mx < bx + tier_w && my >= tier_y && my < tier_y + tier_h {
      game.hover_button = i
    }
  }
  // Click selection
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) &&
    game.hover_button >= 0 {
    select_tier(game, game.hover_button)
    return
  }
  // Keyboard
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    select_tier(game, 0)
  } else if @raylib.is_key_pressed(@raylib.KeyTwo) {
    select_tier(game, 1)
  } else if @raylib.is_key_pressed(@raylib.KeyThree) {
    select_tier(game, 2)
  }
}

///|
fn select_tier(game : @types.Game, idx : Int) -> Unit {
  let tiers : Array[@types.Tier] = [Folds, Layers, Craft]
  if idx >= 0 && idx < 3 {
    game.current_tier = tiers[idx]
    game.screen = LevelSelect
    game.hover_button = -1
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = TierSelect
    game.hover_button = -1
    return
  }
  let count = @types.tier_level_count(game.current_tier)
  // Mouse hover
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let cols = 5
  let btn_w = 160
  let btn_h = 100
  let gap = 20
  let rows = (count + cols - 1) / cols
  let total_grid_w = cols * btn_w + (cols - 1) * gap
  let total_grid_h = rows * btn_h + (rows - 1) * gap
  let grid_x = (@types.screen_width - total_grid_w) / 2
  let grid_y = (@types.screen_height - total_grid_h) / 2 + 10
  game.hover_button = -1
  for i in 0..<count {
    let row = i / cols
    let col = i % cols
    let bx = grid_x + col * (btn_w + gap)
    let by = grid_y + row * (btn_h + gap)
    if mx >= bx && mx < bx + btn_w && my >= by && my < by + btn_h {
      game.hover_button = i
    }
  }
  // Click
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) &&
    game.hover_button >= 0 {
    start_level(
      game,
      @types.tier_start_index(game.current_tier) + game.hover_button,
    )
    return
  }
  // Keyboard 1-9
  for i in 0..<@types.mini(count, 9) {
    if @raylib.is_key_pressed(@raylib.KeyOne + i) {
      start_level(game, @types.tier_start_index(game.current_tier) + i)
      return
    }
  }
}

///|
fn start_level(game : @types.Game, level_idx : Int) -> Unit {
  let level = @levels.get_level(level_idx)
  game.target = level
  game.current_paper = @types.clone_paper(level.initial_paper)
  game.fold_history = []
  game.current_level_index = level_idx
  game.fold_dir = Left
  game.fold_line = 4
  game.play_state = Selecting
  game.anim_timer = 0.0
  game.screen = Playing
  game.show_target = false
  game.message = ""
  game.message_timer = 0.0
}

///|
fn update_playing(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    game.hover_button = -1
    return
  }
  if game.play_state == Complete {
    update_results(game)
    return
  }
  if game.play_state == Animating {
    return
  }
  // Direction selection with arrow keys
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.fold_dir = Left
  } else if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.fold_dir = Right
  } else if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.fold_dir = Up
  } else if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.fold_dir = Down
  }
  // Fold line adjustment with A/D or mouse wheel
  let wheel = @raylib.get_mouse_wheel_move()
  if wheel > 0.0 {
    adjust_fold_line(game, 1)
  } else if wheel < 0.0 {
    adjust_fold_line(game, -1)
  }
  if @raylib.is_key_pressed(@raylib.KeyA) {
    adjust_fold_line(game, -1)
  }
  if @raylib.is_key_pressed(@raylib.KeyD) {
    adjust_fold_line(game, 1)
  }
  // Toggle target overlay
  if @raylib.is_key_pressed(@raylib.KeyT) {
    game.show_target = !game.show_target
  }
  // Execute fold
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    execute_fold_action(game)
  }
  // Undo
  if @raylib.is_key_pressed(@raylib.KeyZ) {
    undo_fold(game)
  }
  // Restart
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.current_level_index)
  }
  // Click on direction buttons in panel
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    handle_playing_click(game)
  }
}

///|
fn adjust_fold_line(game : @types.Game, delta : Int) -> Unit {
  let max_line = match game.fold_dir {
    Left | Right => game.current_paper.width - 1
    Up | Down => game.current_paper.height - 1
  }
  game.fold_line = @types.clamp_int(game.fold_line + delta, 1, max_line)
}

///|
fn execute_fold_action(game : @types.Game) -> Unit {
  if !@fold.is_valid_fold(game.current_paper, game.fold_dir, game.fold_line) {
    game.message = "Invalid fold - no paper on that side!"
    game.message_timer = 1.5
    return
  }
  // Save state for undo
  let saved = @types.clone_paper(game.current_paper)
  let action : @types.FoldAction = {
    dir: game.fold_dir,
    line_pos: game.fold_line,
    paper_before: saved,
  }
  game.fold_history.push(action)
  // Execute fold
  let new_paper = @fold.execute_fold(
    game.current_paper,
    game.fold_dir,
    game.fold_line,
  )
  // Copy result
  for i in 0..<new_paper.cells.length() {
    game.current_paper.cells[i].has_paper = new_paper.cells[i].has_paper
    game.current_paper.cells[i].layers = new_paper.cells[i].layers
  }
  // Brief animation
  game.play_state = Animating
  game.anim_timer = @types.anim_duration
  // Check completion
  let result = @fold.check_completion(game.current_paper, game.target)
  if result.silhouette_match {
    // Show results screen after animation
    game.play_state = Complete
    game.screen = Results
    // Save score
    let stars = @fold.compute_stars(
      result,
      game.fold_history.length(),
      game.target.par_folds,
    )
    let score = game.scores[game.current_level_index]
    score.completed = true
    score.folds_used = game.fold_history.length()
    // Only upgrade stars
    if star_val(stars) > star_val(score.stars) {
      score.stars = stars
    }
  }
}

///|
fn star_val(s : @types.StarRating) -> Int {
  match s {
    Zero => 0
    One => 1
    Two => 2
    Three => 3
  }
}

///|
fn undo_fold(game : @types.Game) -> Unit {
  if game.fold_history.length() == 0 {
    game.message = "Nothing to undo"
    game.message_timer = 1.0
    return
  }
  let action = game.fold_history.pop()
  match action {
    Some(act) =>
      // Restore paper
      for i in 0..<act.paper_before.cells.length() {
        game.current_paper.cells[i].has_paper = act.paper_before.cells[i].has_paper
        game.current_paper.cells[i].layers = act.paper_before.cells[i].layers
      }
    None => ()
  }
}

///|
fn handle_playing_click(game : @types.Game) -> Unit {
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  // Check direction buttons
  let w = @types.screen_width
  let panel_x = w / 2 - 120
  let panel_y = 10
  let btn_y = panel_y + 50
  let btn_size = 40
  let btn_gap = 8
  let panel_w = 240
  let total_btn_w = 4 * btn_size + 3 * btn_gap
  let btn_start_x = panel_x + (panel_w - total_btn_w) / 2
  let dirs : Array[@types.FoldDir] = [Left, Up, Down, Right]
  for i in 0..<4 {
    let bx = btn_start_x + i * (btn_size + btn_gap)
    if mx >= bx && mx < bx + btn_size && my >= btn_y && my < btn_y + btn_size {
      game.fold_dir = dirs[i]
      // Reset fold line to center for new direction
      match game.fold_dir {
        Left | Right =>
          game.fold_line = @types.clamp_int(
            game.fold_line,
            1,
            game.current_paper.width - 1,
          )
        Up | Down =>
          game.fold_line = @types.clamp_int(
            game.fold_line,
            1,
            game.current_paper.height - 1,
          )
      }
      return
    }
  }
  // Check click on paper grid to set fold line
  let ox = 100 // paper_origin_x
  let oy = (@types.screen_height - @types.grid_size * @types.cell_size) / 2
  let cs = @types.cell_size
  let gs = @types.grid_size
  if mx >= ox && mx < ox + gs * cs && my >= oy && my < oy + gs * cs {
    match game.fold_dir {
      Left | Right => {
        let col = (mx - ox) / cs + 1
        game.fold_line = @types.clamp_int(col, 1, gs - 1)
      }
      Up | Down => {
        let row = (my - oy) / cs + 1
        game.fold_line = @types.clamp_int(row, 1, gs - 1)
      }
    }
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  // Restart
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.current_level_index)
    return
  }
  // Next level
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    let next = game.current_level_index + 1
    if next < @types.total_levels {
      start_level(game, next)
    } else {
      game.screen = LevelSelect
      game.hover_button = -1
    }
    return
  }
  // Back to level select
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    game.hover_button = -1
  }
}
