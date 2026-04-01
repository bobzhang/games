///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count = game.frame_count + 1
  let dt = @types.minf(@raylib.get_frame_time(), 0.05)
  // Update message timer
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
    Daily => update_playing(game)
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = TierSelect
  }
  if @raylib.is_key_pressed(@raylib.KeyD) {
    start_daily(game)
  }
}

///|
fn update_tier_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    game.current_tier = Scraps
    game.screen = LevelSelect
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) {
    game.current_tier = Quilting
    game.screen = LevelSelect
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) {
    game.current_tier = Masterwork
    game.screen = LevelSelect
  }
  // Mouse click on tier
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let tiers : Array[@types.Tier] = [Scraps, Quilting, Masterwork]
    for i in 0..<3 {
      let ty = 120 + i * 170
      if mx >= 100 && mx <= 1180 && my >= ty && my <= ty + 150 {
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
  // Number keys
  for i in 0..<@types.mini(count, 9) {
    if @raylib.is_key_pressed(@raylib.KeyOne + i) {
      start_level(game, start + i)
      return
    }
  }
  // Mouse click
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let cols = 5
    let cell_w = 180
    let cell_h = 100
    let gap = 20
    let ox = 100
    let oy = 100
    for i in 0..<count {
      let col = i % cols
      let row = i / cols
      let cx = ox + col * (cell_w + gap)
      let cy = oy + row * (cell_h + gap)
      if mx >= cx && mx <= cx + cell_w && my >= cy && my <= cy + cell_h {
        start_level(game, start + i)
        return
      }
    }
  }
}

///|
fn start_level(game : @types.Game, level_idx : Int) -> Unit {
  let level = @levels.get_level(level_idx)
  game.board = @types.new_board(level.board_size)
  game.current_level = level_idx + 1
  game.current_tier = level.tier
  game.rotations = 0
  game.swaps = 0
  game.selected_tray = -1
  game.selected_board = -1
  game.play_state = Placing
  game.is_daily = false
  // Place pinned patches
  for i in 0..<level.pinned_positions.length() {
    let pos = level.pinned_positions[i]
    let row = pos / level.board_size
    let col = pos % level.board_size
    @types.board_set(game.board, row, col, Some(level.pinned_patches[i]))
  }
  // Build tray: non-pinned patches shuffled
  let tray : Array[@types.Patch] = []
  // Collect patches that aren't pinned (by index in level patches)
  let pinned_set : Array[Bool] = Array::make(level.patches.length(), false)
  for i in 0..<level.pinned_positions.length() {
    let pos = level.pinned_positions[i]
    if pos < pinned_set.length() {
      pinned_set[pos] = true
    }
  }
  for i in 0..<level.patches.length() {
    if !pinned_set[i] {
      tray.push(level.patches[i])
    }
  }
  game.tray = tray
  game.screen = Playing
  @types.set_message(game, "Arrange patches so edges match!", 3.0)
}

///|
fn start_daily(game : @types.Game) -> Unit {
  // Use current date as seed
  let seed = @matching.date_hash(2026, 3, 31)
  let (board, tray) = @matching.generate_daily_board(seed)
  game.board = board
  game.tray = tray
  game.current_level = 1
  game.current_tier = Quilting
  game.rotations = 0
  game.swaps = 0
  game.selected_tray = -1
  game.selected_board = -1
  game.play_state = Placing
  game.is_daily = true
  game.daily_seed = seed
  game.screen = Daily
  @types.set_message(game, "Daily Quilt - Good luck!", 3.0)
}

///|
fn update_playing(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    if game.is_daily {
      game.screen = Title
    } else {
      game.screen = LevelSelect
    }
    return
  }
  // Check for completion
  if game.play_state == Complete {
    return
  }
  // Rotate selected tray patch
  if @raylib.is_key_pressed(@raylib.KeyR) {
    if game.selected_tray >= 0 && game.selected_tray < game.tray.length() {
      game.tray[game.selected_tray] = @types.rotate_patch(
        game.tray[game.selected_tray],
      )
      game.rotations = game.rotations + 1
    }
  }
  let board = game.board
  let cs = @types.cell_size_for(board.size)
  let gx = @types.grid_offset_x
  let gy = @types.grid_offset_y
  // Handle mouse clicks
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    // Check tray click
    let tray_hit = check_tray_click(game, mx, my)
    if tray_hit >= 0 {
      handle_tray_click(game, tray_hit)
    } else {
      // Check grid click
      let grid_col = (mx - gx) / cs
      let grid_row = (my - gy) / cs
      if grid_col >= 0 &&
        grid_col < board.size &&
        grid_row >= 0 &&
        grid_row < board.size &&
        mx >= gx &&
        my >= gy {
        handle_grid_click(game, grid_row, grid_col)
      }
    }
  }
  // Right-click to remove patch from grid
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let grid_col = (mx - gx) / cs
    let grid_row = (my - gy) / cs
    if grid_col >= 0 &&
      grid_col < board.size &&
      grid_row >= 0 &&
      grid_row < board.size &&
      mx >= gx &&
      my >= gy {
      handle_remove(game, grid_row, grid_col)
    }
  }
}

///|
fn check_tray_click(game : @types.Game, mx : Int, my : Int) -> Int {
  let tx = @types.tray_x
  let ty = @types.tray_y
  let ps = @types.tray_patch_size
  let gap = @types.tray_gap
  let cols = @types.tray_cols
  for i in 0..<game.tray.length() {
    let col = i % cols
    let row = i / cols
    let px = tx + col * (ps + gap)
    let py = ty + row * (ps + gap)
    if mx >= px && mx <= px + ps && my >= py && my <= py + ps {
      return i
    }
  }
  -1
}

///|
fn handle_tray_click(game : @types.Game, idx : Int) -> Unit {
  match game.play_state {
    Placing => {
      game.selected_tray = idx
      game.selected_board = -1
    }
    Selecting | Swapping => {
      // Cancel swap, select tray patch instead
      game.play_state = Placing
      game.selected_tray = idx
      game.selected_board = -1
    }
    Complete => ()
  }
}

///|
fn handle_grid_click(game : @types.Game, row : Int, col : Int) -> Unit {
  let board = game.board
  let idx = row * board.size + col
  match game.play_state {
    Placing =>
      // If we have a tray selection and cell is empty, place it
      if game.selected_tray >= 0 && game.selected_tray < game.tray.length() {
        match @types.board_get(board, row, col) {
          None => {
            let patch = game.tray[game.selected_tray]
            @types.board_set(board, row, col, Some(patch))
            // Remove from tray
            let new_tray : Array[@types.Patch] = []
            for i in 0..<game.tray.length() {
              if i != game.selected_tray {
                new_tray.push(game.tray[i])
              }
            }
            game.tray = new_tray
            game.selected_tray = -1
            check_completion(game)
          }
          Some(existing) =>
            // Cell occupied - if not pinned, select for potential swap
            if !existing.pinned {
              game.selected_board = idx
              game.play_state = Selecting
            }
        }
      } else {
        // No tray selection, click on board cell to select for swap
        match @types.board_get(board, row, col) {
          Some(existing) =>
            if !existing.pinned {
              game.selected_board = idx
              game.play_state = Selecting
            }
          None => ()
        }
      }
    Selecting =>
      // Click on second patch to swap
      match @types.board_get(board, row, col) {
        Some(existing) =>
          if idx == game.selected_board {
            // Deselect
            game.selected_board = -1
            game.play_state = Placing
          } else if !existing.pinned {
            // Swap the two patches
            let sel_row = game.selected_board / board.size
            let sel_col = game.selected_board % board.size
            let patch_a = @types.board_get(board, sel_row, sel_col)
            let patch_b = @types.board_get(board, row, col)
            @types.board_set(board, sel_row, sel_col, patch_b)
            @types.board_set(board, row, col, patch_a)
            game.swaps = game.swaps + 1
            game.selected_board = -1
            game.play_state = Placing
            check_completion(game)
          }
        None => {
          // Move selected patch to empty cell
          let sel_row = game.selected_board / board.size
          let sel_col = game.selected_board % board.size
          let patch_a = @types.board_get(board, sel_row, sel_col)
          @types.board_set(board, sel_row, sel_col, None)
          @types.board_set(board, row, col, patch_a)
          game.swaps = game.swaps + 1
          game.selected_board = -1
          game.play_state = Placing
          check_completion(game)
        }
      }
    Swapping => {
      game.play_state = Placing
      game.selected_board = -1
    }
    Complete => ()
  }
}

///|
fn handle_remove(game : @types.Game, row : Int, col : Int) -> Unit {
  let board = game.board
  match @types.board_get(board, row, col) {
    Some(patch) =>
      if !patch.pinned {
        @types.board_set(board, row, col, None)
        game.tray.push(patch)
        game.selected_board = -1
        game.play_state = Placing
      }
    None => ()
  }
}

///|
fn check_completion(game : @types.Game) -> Unit {
  if @matching.is_board_complete(game.board) {
    game.play_state = Complete
    let level_idx = game.current_level - 1
    let level = @levels.get_level(level_idx)
    let stars = @matching.compute_stars(level, game.rotations, game.swaps)
    if game.is_daily {
      game.daily_score.completed = true
      game.daily_score.stars = stars
      game.daily_score.best_rotations = game.rotations
      game.daily_score.best_swaps = game.swaps
    } else if level_idx < game.level_scores.length() {
      let score = game.level_scores[level_idx]
      score.completed = true
      if stars > score.stars {
        score.stars = stars
      }
      if game.rotations < score.best_rotations {
        score.best_rotations = game.rotations
      }
      if game.swaps < score.best_swaps {
        score.best_swaps = game.swaps
      }
    }
    @types.set_message(game, "Congratulations! All edges matched!", 2.0)
    // Delay showing results
    game.screen = Results
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    if game.is_daily {
      game.screen = Title
    } else {
      game.screen = LevelSelect
    }
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    if !game.is_daily {
      // Next level
      let next_idx = game.current_level
      if next_idx < @types.total_levels {
        start_level(game, next_idx)
      } else {
        game.screen = LevelSelect
      }
    } else {
      game.screen = Title
    }
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    if !game.is_daily {
      start_level(game, game.current_level - 1)
    }
  }
}
