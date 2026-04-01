///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count = game.frame_count + 1
  let dt = @types.minf(@raylib.get_frame_time(), 0.05)
  // Update message timer
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - dt
    if game.message_timer <= 0.0 {
      game.message = ""
    }
  }
  match game.screen {
    Title => update_title(game)
    TierSelect => update_tier_select(game)
    LevelSelect => update_level_select(game)
    Playing => update_playing(game)
    Firing => update_firing(game, dt)
    Results => update_results(game)
  }
}

///|
fn set_message(game : @types.Game, msg : String) -> Unit {
  game.message = msg
  game.message_timer = 2.0
}

///|
fn update_title(game : @types.Game) -> Unit {
  game.title_anim_timer = game.title_anim_timer + @raylib.get_frame_time()
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = TierSelect
  }
}

///|
fn update_tier_select(game : @types.Game) -> Unit {
  let idx = @types.tier_index(game.selected_tier)
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    if idx < 2 {
      game.selected_tier = @types.tier_from_index(idx + 1)
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    if idx > 0 {
      game.selected_tier = @types.tier_from_index(idx - 1)
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    let (lo, _hi) = @types.tier_level_range(game.selected_tier)
    game.selected_level = lo
    game.screen = LevelSelect
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  let (lo, hi) = @types.tier_level_range(game.selected_tier)
  let count = hi - lo
  let cols = if count <= 4 { count } else { 4 }
  let local_idx = game.selected_level - lo
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    if game.selected_level < hi - 1 {
      game.selected_level = game.selected_level + 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    if game.selected_level > lo {
      game.selected_level = game.selected_level - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    let next = local_idx + cols
    if next < count {
      game.selected_level = lo + next
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    let prev = local_idx - cols
    if prev >= 0 {
      game.selected_level = lo + prev
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    start_level(game, game.selected_level)
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = TierSelect
  }
}

///|
fn start_level(game : @types.Game, index : Int) -> Unit {
  let level = @levels.get_level(index)
  game.current_level = Some(level)
  game.target_grid = level.target
  game.max_moves = level.max_moves
  game.moves_used = 0
  game.play_state = Placing
  game.undo_stack = []
  game.score = None
  game.message = ""
  game.message_timer = 0.0
  game.fire_timer = 0.0
  game.fire_phase = 0
  game.allowed_glazes = level.allowed_glazes
  if level.allowed_glazes.length() > 0 {
    game.selected_glaze = level.allowed_glazes[0]
  }
  @types.clear_grid(game.grid)
  game.screen = Playing
}

///|
fn update_playing(game : @types.Game) -> Unit {
  // Update hover from mouse
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  game.hover_row = -1
  game.hover_col = -1
  let gx = @types.grid_offset_x
  let gy = @types.grid_offset_y
  let cs = @types.cell_size
  let gap = @types.cell_gap
  for row in 0..<@types.grid_rows {
    for col in 0..<@types.grid_cols {
      let cx = gx + col * (cs + gap)
      let cy = gy + row * (cs + gap)
      if mx >= cx && mx < cx + cs && my >= cy && my < cy + cs {
        game.hover_row = row
        game.hover_col = col
      }
    }
  }
  // Glaze selection: number keys 1-6
  for i in 0..<game.allowed_glazes.length() {
    let key = @raylib.KeyOne + i
    if @raylib.is_key_pressed(key) {
      game.selected_glaze = game.allowed_glazes[i]
    }
  }
  // Cycle glaze with Tab
  if @raylib.is_key_pressed(@raylib.KeyTab) {
    let cur_idx = find_glaze_in_allowed(game)
    if game.allowed_glazes.length() > 0 {
      let next = (cur_idx + 1) % game.allowed_glazes.length()
      game.selected_glaze = game.allowed_glazes[next]
    }
  }
  // Place glaze on click
  if game.play_state is Placing {
    if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
      if game.hover_row >= 0 && game.hover_col >= 0 {
        place_glaze(game, game.hover_row, game.hover_col)
      }
    }
    // Right click to erase
    if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
      if game.hover_row >= 0 && game.hover_col >= 0 {
        erase_glaze(game, game.hover_row, game.hover_col)
      }
    }
  }
  // Undo with Z
  if @raylib.is_key_pressed(@raylib.KeyZ) {
    undo_last(game)
  }
  // Clear all with C
  if @raylib.is_key_pressed(@raylib.KeyC) {
    clear_all(game)
  }
  // Fire with F or Enter
  if @raylib.is_key_pressed(@raylib.KeyF) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) {
    begin_firing(game)
  }
  // Escape: back to level select
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}

///|
fn find_glaze_in_allowed(game : @types.Game) -> Int {
  for i in 0..<game.allowed_glazes.length() {
    if game.allowed_glazes[i] == game.selected_glaze {
      return i
    }
  }
  0
}

///|
fn place_glaze(game : @types.Game, row : Int, col : Int) -> Unit {
  if game.moves_used >= game.max_moves {
    set_message(game, "No moves left! Fire or undo.")
    return
  }
  let cell = @types.get_cell(game.grid, row, col)
  let prev = cell.glaze
  // Save undo entry
  game.undo_stack.push({ row, col, prev_glaze: prev })
  cell.glaze = game.selected_glaze
  if prev is Empty {
    game.moves_used = game.moves_used + 1
  }
}

///|
fn erase_glaze(game : @types.Game, row : Int, col : Int) -> Unit {
  let cell = @types.get_cell(game.grid, row, col)
  if cell.glaze is Empty {
    return
  }
  let prev = cell.glaze
  game.undo_stack.push({ row, col, prev_glaze: prev })
  cell.glaze = Empty
  game.moves_used = @types.maxi(0, game.moves_used - 1)
}

///|
fn undo_last(game : @types.Game) -> Unit {
  if game.undo_stack.length() == 0 {
    set_message(game, "Nothing to undo")
    return
  }
  let entry = game.undo_stack.pop()
  guard entry is Some(ent) else { return }
  let cell = @types.get_cell(game.grid, ent.row, ent.col)
  let was_empty = ent.prev_glaze is Empty
  let is_now_empty = cell.glaze is Empty
  cell.glaze = ent.prev_glaze
  // Adjust move count
  if was_empty && !is_now_empty {
    // We placed something; undoing it means one fewer move
    game.moves_used = @types.maxi(0, game.moves_used - 1)
  } else if !was_empty && is_now_empty {
    // We erased something; undoing restores it (costs a move back)
    game.moves_used = game.moves_used + 1
  }
}

///|
fn clear_all(game : @types.Game) -> Unit {
  @types.clear_grid(game.grid)
  game.moves_used = 0
  game.undo_stack = []
  set_message(game, "Grid cleared")
}

///|
fn begin_firing(game : @types.Game) -> Unit {
  game.screen = Firing
  game.fire_timer = 0.0
  game.fire_phase = 0
}

///|
fn update_firing(game : @types.Game, dt : Float) -> Unit {
  game.fire_timer = game.fire_timer + dt
  // Firing animation: 3 phases of 0.6s each
  let phase_duration : Float = 0.6
  let total_duration : Float = 1.8
  game.fire_phase = @types.mini(
    (game.fire_timer / phase_duration).to_int(),
    2,
  )
  if game.fire_timer >= total_duration {
    // Actually fire the grid
    @kiln.fire_grid(game.grid)
    // Calculate score
    guard game.current_level is Some(level) else { return }
    let score = @kiln.calculate_score(
      game.grid,
      game.target_grid,
      game.moves_used,
      level.par_moves,
    )
    game.score = Some(score)
    // Update best score
    if score.stars > game.level_scores[game.selected_level] {
      game.level_scores[game.selected_level] = score.stars
    }
    game.screen = Results
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  // R to retry
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.selected_level)
  }
  // N for next level
  if @raylib.is_key_pressed(@raylib.KeyN) {
    if game.selected_level < 19 {
      start_level(game, game.selected_level + 1)
    }
  }
  // Enter or Space to continue to level select
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = LevelSelect
  }
  // Escape: back to level select
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}
