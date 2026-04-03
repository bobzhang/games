///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count = game.frame_count + 1
  let dt = @types.minf(@raylib.get_frame_time(), 0.05)
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - dt
  }
  game.anim_timer = game.anim_timer + dt
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
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    game.current_tier = Apprentice
    game.screen = LevelSelect
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) {
    game.current_tier = Journeyman
    game.screen = LevelSelect
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) {
    game.current_tier = Master
    game.screen = LevelSelect
  }
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let tiers : Array[@types.Tier] = [Apprentice, Journeyman, Master]
    for i in 0..<3 {
      let ty = 180 + i * 140
      if mx >= 340 && mx <= 940 && my >= ty && my <= ty + 110 {
        game.current_tier = tiers[i]
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
  let (start, count) = @types.tier_levels(game.current_tier)
  for i in 0..<@types.mini(count, 9) {
    if @raylib.is_key_pressed(@raylib.KeyOne + i) {
      start_level(game, start + i)
      return
    }
  }
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let cols = 4
    let cw = 200
    let ch = 80
    let gap = 20
    let ox = 200
    let oy = 140
    for i in 0..<count {
      let col = i % cols
      let row = i / cols
      let cx = ox + col * (cw + gap)
      let cy = oy + row * (ch + gap)
      if mx >= cx && mx <= cx + cw && my >= cy && my <= cy + ch {
        start_level(game, start + i)
        return
      }
    }
  }
}

///|
fn start_level(game : @types.Game, level_idx : Int) -> Unit {
  let level = @levels.get_level(level_idx)
  game.current_level = level_idx + 1
  game.current_tier = level.tier
  game.target = level.target
  game.warp_colors = level.warp_colors
  game.weft_colors = level.weft_colors
  game.heddle_changes = 0
  game.selected_row = 0
  game.play_state = Weaving
  game.show_comparison = false
  game.has_guessed_type = false
  game.weave_type_guess = Plain
  game.show_hint = false
  // Reset heddles to all down
  let heddles : Array[@types.HeddleRow] = []
  for _i in 0..<@types.grid_rows {
    heddles.push(@types.new_heddle_row(@types.grid_cols))
  }
  game.heddles = heddles
  game.screen = Playing
  @types.set_message(game, "Set heddles to match the target pattern!", 3.0)
}

///|
fn update_playing(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  if game.play_state == Complete {
    if @raylib.is_key_pressed(@raylib.KeyEnter) {
      game.screen = Results
    }
    return
  }
  // Navigate rows with up/down
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    if game.selected_row > 0 {
      game.selected_row = game.selected_row - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    if game.selected_row < @types.grid_rows - 1 {
      game.selected_row = game.selected_row + 1
    }
  }
  // Toggle individual warps with number keys 1-8
  for i in 0..<8 {
    if @raylib.is_key_pressed(@raylib.KeyOne + i) {
      toggle_heddle(game, game.selected_row, i)
    }
  }
  // Toggle all warps in current row (A key = alternate pattern)
  if @raylib.is_key_pressed(@raylib.KeyA) {
    apply_alternate_pattern(game, game.selected_row)
  }
  // Copy heddle from previous row
  if @raylib.is_key_pressed(@raylib.KeyC) {
    if game.selected_row > 0 {
      copy_heddle_row(game, game.selected_row - 1, game.selected_row)
    }
  }
  // Invert current row
  if @raylib.is_key_pressed(@raylib.KeyI) {
    invert_heddle_row(game, game.selected_row)
  }
  // Shift current row pattern right
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    shift_heddle_row(game, game.selected_row, 1)
  }
  // Shift current row pattern left
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    shift_heddle_row(game, game.selected_row, -1)
  }
  // Toggle comparison view
  if @raylib.is_key_pressed(@raylib.KeyTab) {
    game.show_comparison = !game.show_comparison
  }
  // Show hint
  if @raylib.is_key_pressed(@raylib.KeyH) {
    game.show_hint = !game.show_hint
  }
  // Submit / check pattern
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    check_pattern(game)
  }
  // Mouse click on grid cells to toggle heddles
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    handle_grid_click(game)
  }
  // Mouse click on row labels to select row
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
    handle_row_select(game)
  }
}

///|
fn toggle_heddle(game : @types.Game, row : Int, col : Int) -> Unit {
  if row >= 0 && row < @types.grid_rows && col >= 0 && col < @types.grid_cols {
    let h = game.heddles[row]
    h.raised[col] = !h.raised[col]
    game.heddle_changes = game.heddle_changes + 1
  }
}

///|
fn apply_alternate_pattern(game : @types.Game, row : Int) -> Unit {
  let h = game.heddles[row]
  let offset = row % 2
  for col in 0..<@types.grid_cols {
    h.raised[col] = (col + offset) % 2 == 0
  }
  game.heddle_changes = game.heddle_changes + 1
}

///|
fn copy_heddle_row(game : @types.Game, src : Int, dst : Int) -> Unit {
  let s = game.heddles[src]
  let d = game.heddles[dst]
  for col in 0..<@types.grid_cols {
    d.raised[col] = s.raised[col]
  }
  game.heddle_changes = game.heddle_changes + 1
}

///|
fn invert_heddle_row(game : @types.Game, row : Int) -> Unit {
  let h = game.heddles[row]
  for col in 0..<@types.grid_cols {
    h.raised[col] = !h.raised[col]
  }
  game.heddle_changes = game.heddle_changes + 1
}

///|
fn shift_heddle_row(game : @types.Game, row : Int, dir : Int) -> Unit {
  let h = game.heddles[row]
  let cols = @types.grid_cols
  let old : Array[Bool] = Array::make(cols, false)
  for i in 0..<cols {
    old[i] = h.raised[i]
  }
  for i in 0..<cols {
    let src = ((i - dir) % cols + cols) % cols
    h.raised[i] = old[src]
  }
  game.heddle_changes = game.heddle_changes + 1
}

///|
fn handle_grid_click(game : @types.Game) -> Unit {
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let gx = @types.grid_offset_x
  let gy = @types.grid_offset_y
  let cs = @types.cell_size
  let col = (mx - gx) / cs
  let row = (my - gy) / cs
  if col >= 0 &&
    col < @types.grid_cols &&
    row >= 0 &&
    row < @types.grid_rows &&
    mx >= gx &&
    my >= gy {
    game.selected_row = row
    toggle_heddle(game, row, col)
  }
}

///|
fn handle_row_select(game : @types.Game) -> Unit {
  let my = @raylib.get_mouse_y()
  let gy = @types.grid_offset_y
  let cs = @types.cell_size
  let row = (my - gy) / cs
  if row >= 0 && row < @types.grid_rows && my >= gy {
    game.selected_row = row
  }
}

///|
fn check_pattern(game : @types.Game) -> Unit {
  let player = @types.build_player_fabric(game)
  if @types.patterns_match(player, game.target) {
    game.play_state = Complete
    let level_idx = game.current_level - 1
    let level = @levels.get_level(level_idx)
    // Check if type guess was correct
    let correct_type = game.has_guessed_type &&
      game.weave_type_guess == level.weave_type
    let stars = @levels.compute_stars(level, game.heddle_changes, correct_type)
    if level_idx < game.level_scores.length() {
      let score = game.level_scores[level_idx]
      score.completed = true
      if stars > score.stars {
        score.stars = stars
      }
      if game.heddle_changes < score.best_changes {
        score.best_changes = game.heddle_changes
      }
    }
    @types.set_message(game, "Pattern matched! Press Enter for results.", 5.0)
  } else {
    let matches = @types.count_matches(player, game.target)
    let total = @types.grid_rows * @types.grid_cols
    game.show_comparison = true
    @types.set_message(
      game,
      matches.to_string() + "/" + total.to_string() + " cells correct",
      2.0,
    )
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    let next_idx = game.current_level
    if next_idx < @types.total_levels {
      start_level(game, next_idx)
    } else {
      game.screen = LevelSelect
    }
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.current_level - 1)
  }
  // Cycle weave type guess with T key
  if @raylib.is_key_pressed(@raylib.KeyT) {
    game.has_guessed_type = true
    game.weave_type_guess = next_weave_type(game.weave_type_guess)
  }
}

///|
fn next_weave_type(wt : @types.WeaveType) -> @types.WeaveType {
  match wt {
    Plain => Twill
    Twill => Satin
    Satin => Herringbone
    Herringbone => Diamond
    Diamond => Custom
    Custom => Plain
  }
}
