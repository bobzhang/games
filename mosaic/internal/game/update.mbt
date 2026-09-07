///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count = game.frame_count + 1
  let dt = @raylib.get_frame_time()
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
  let tiers : Array[@types.Tier] = [Repair, Restore, Master]
  for i in 0..<3 {
    if @raylib.is_key_pressed(@raylib.KeyOne + i) {
      game.current_tier = tiers[i]
      game.screen = LevelSelect
      return
    }
  }
  // Mouse click on tier cards
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let w = @types.screen_width
    let card_w = 320
    let card_h = 350
    let gap = 40
    let total_w = 3 * card_w + 2 * gap
    let start_x = (w - total_w) / 2
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    for i in 0..<3 {
      let cx = start_x + i * (card_w + gap)
      let cy = 120
      if mx >= cx && mx < cx + card_w && my >= cy && my < cy + card_h {
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
  let level_indices = @types.levels_for_tier(game, game.current_tier)
  // Number keys
  for i in 0..<level_indices.length() {
    if i < 9 && @raylib.is_key_pressed(@raylib.KeyOne + i) {
      start_level(game, level_indices[i])
      return
    }
  }
  // Mouse click
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let w = @types.screen_width
    let card_w = 120
    let card_h = 100
    let gap = 16
    let cols = 5
    let total_cols = if level_indices.length() < cols {
      level_indices.length()
    } else {
      cols
    }
    let total_w = total_cols * card_w + (total_cols - 1) * gap
    let start_x = (w - total_w) / 2
    let start_y = 100
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    for i in 0..<level_indices.length() {
      let col = i % cols
      let row = i / cols
      let cx = start_x + col * (card_w + gap)
      let cy = start_y + row * (card_h + gap)
      if mx >= cx && mx < cx + card_w && my >= cy && my < cy + card_h {
        start_level(game, level_indices[i])
        return
      }
    }
  }
}

///|
fn start_level(game : @types.Game, level_index : Int) -> Unit {
  game.current_level = level_index
  game.screen = Playing
  game.play_state = Placing
  game.errors = 0
  game.no_errors = true
  game.guessed_symmetry = false
  game.symmetry_guess = None
  game.placed_tiles = []
  game.undo_stack = []
  game.show_symmetry_hint = false
  game.selected_color = Red
  game.selected_shape = Square
  game.selected_orientation = N
  game.message = ""
  game.message_timer = 0.0
  // Reset holes - clear placed tiles from grid
  let level = game.levels[level_index]
  for i in 0..<level.grid.holes.length() {
    let h = level.grid.holes[i]
    @types.set_tile(level.grid, h.x, h.y, None)
  }
}

///|
fn update_playing(game : @types.Game) -> Unit {
  match game.play_state {
    Complete => {
      if @raylib.is_key_pressed(@raylib.KeyEnter) ||
        @raylib.is_key_pressed(@raylib.KeySpace) {
        // Move to results
        game.screen = Results
      }
      return
    }
    _ => ()
  }
  // Restart
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.current_level)
    return
  }
  // Back to level select
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  // Toggle symmetry hint
  if @raylib.is_key_pressed(@raylib.KeyH) {
    game.show_symmetry_hint = !game.show_symmetry_hint
  }
  // Color selection (1-6)
  let colors = @types.all_colors()
  for i in 0..<colors.length() {
    if @raylib.is_key_pressed(@raylib.KeyOne + i) {
      game.selected_color = colors[i]
    }
  }
  // Shape selection (Q W E R T Y)
  let shape_keys = [
    @raylib.KeyQ,
    @raylib.KeyW,
    @raylib.KeyE,
    @raylib.KeyR,
    @raylib.KeyT,
    @raylib.KeyY,
  ]
  let shapes = @types.all_shapes()
  for i in 0..<shape_keys.length() {
    if @raylib.is_key_pressed(shape_keys[i]) {
      game.selected_shape = shapes[i]
    }
  }
  // Orientation (arrow keys)
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.selected_orientation = N
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.selected_orientation = E
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.selected_orientation = S
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.selected_orientation = W
  }
  // Undo
  if @raylib.is_key_pressed(@raylib.KeyZ) {
    undo_placement(game)
  }
  // Update hover cell
  update_hover(game)
  // Handle click to place tile
  if game.play_state == Placing {
    handle_tile_placement(game)
  }
  // Handle symmetry guess UI
  if game.play_state == GuessSymmetry {
    handle_symmetry_guess(game)
  }
}

///|
fn update_hover(game : @types.Game) -> Unit {
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  let gx = (mx - ox) / cs
  let gy = (my - oy) / cs
  if gx >= 0 && gx < @types.grid_cols && gy >= 0 && gy < @types.grid_rows {
    game.hover_cell = Some(@types.vec2i(gx, gy))
  } else {
    game.hover_cell = None
  }
}

///|
fn handle_tile_placement(game : @types.Game) -> Unit {
  if !@raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    return
  }
  match game.hover_cell {
    None => ()
    Some(cell) => {
      let level = game.levels[game.current_level]
      // Must be a hole
      if !@types.is_hole(level.grid, cell) {
        return
      }
      // Check if already filled by player
      for i in 0..<game.placed_tiles.length() {
        let (pos, _) = game.placed_tiles[i]
        if @types.vec2i_eq(pos, cell) {
          // Replace existing placement
          let (_, old_tile) = game.placed_tiles[i]
          let undo : @types.UndoEntry = {
            pos: cell,
            prev_tile: Some(old_tile),
          }
          game.undo_stack.push(undo)
          let new_tile = @types.new_tile(
            game.selected_color,
            game.selected_shape,
            game.selected_orientation,
          )
          game.placed_tiles[i] = (cell, @types.copy_tile(new_tile))
          @types.set_tile(
            level.grid,
            cell.x,
            cell.y,
            Some(@types.copy_tile(new_tile)),
          )
          // Validate
          let valid = @symmetry.validate_placement(
            level.grid,
            cell,
            new_tile,
            level.symmetry,
          )
          if !valid {
            game.errors = game.errors + 1
            game.no_errors = false
            @types.set_message(game, "Incorrect! Check symmetry.", 1.5)
          } else {
            @types.set_message(game, "Correct!", 0.8)
          }
          check_completion(game)
          return
        }
      }
      // New placement
      let undo : @types.UndoEntry = { pos: cell, prev_tile: None, }
      game.undo_stack.push(undo)
      let new_tile = @types.new_tile(
        game.selected_color,
        game.selected_shape,
        game.selected_orientation,
      )
      game.placed_tiles.push((cell, @types.copy_tile(new_tile)))
      @types.set_tile(
        level.grid,
        cell.x,
        cell.y,
        Some(@types.copy_tile(new_tile)),
      )
      // Validate
      let valid = @symmetry.validate_placement(
        level.grid,
        cell,
        new_tile,
        level.symmetry,
      )
      if !valid {
        game.errors = game.errors + 1
        game.no_errors = false
        @types.set_message(game, "Incorrect! Check symmetry.", 1.5)
      } else {
        @types.set_message(game, "Correct!", 0.8)
      }
      check_completion(game)
    }
  }
}

///|
fn check_completion(game : @types.Game) -> Unit {
  let level = game.levels[game.current_level]
  if @symmetry.check_all_holes_filled(level.grid) {
    let all_correct = @symmetry.check_all_correct(
      level.grid,
      game.placed_tiles,
      level.symmetry,
    )
    if all_correct {
      game.play_state = GuessSymmetry
      @types.set_message(
        game, "All tiles placed! Now guess the symmetry type.", 2.0,
      )
    }
  }
}

///|
fn handle_symmetry_guess(game : @types.Game) -> Unit {
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let px = @types.palette_x
    let by = @types.palette_y + 440
    let btn_w = 140
    let btn_h = 30
    // Check symmetry type buttons
    for i in 0..<6 {
      let col = i % 2
      let row = i / 2
      let bx = px + col * (btn_w + 10)
      let by2 = by + 24 + row * (btn_h + 6)
      let mx = @raylib.get_mouse_x()
      let my = @raylib.get_mouse_y()
      if mx >= bx && mx < bx + btn_w && my >= by2 && my < by2 + btn_h {
        game.symmetry_guess = Some(@types.index_to_symmetry(i))
        return
      }
    }
    // Check confirm button
    let confirm_y = by + 24 + 3 * (btn_h + 6) + 6
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    if mx >= px &&
      mx < px + btn_w * 2 + 10 &&
      my >= confirm_y &&
      my < confirm_y + btn_h {
      // Confirm guess
      match game.symmetry_guess {
        None => @types.set_message(game, "Select a symmetry type first!", 1.5)
        Some(guess) => {
          let level = game.levels[game.current_level]
          game.guessed_symmetry = guess == level.symmetry
          complete_level(game)
        }
      }
    }
  }
}

///|
fn complete_level(game : @types.Game) -> Unit {
  game.play_state = Complete
  let score = game.scores[game.current_level]
  score.completed = true
  score.errors = game.errors
  score.guessed_symmetry = game.guessed_symmetry
  // Calculate stars
  let mut stars = 1 // Completed
  if game.no_errors {
    stars = 2
  }
  if game.no_errors && game.guessed_symmetry {
    stars = 3
  }
  if stars > score.stars {
    score.stars = stars
  }
  let suffix = if stars > 1 { "s" } else { "" }
  let star_msg = stars.to_string() +
    " Star" +
    suffix +
    "! Press ENTER for results."
  @types.set_message(game, star_msg, 3.0)
}

///|
fn undo_placement(game : @types.Game) -> Unit {
  if game.undo_stack.length() == 0 {
    return
  }
  if game.play_state != Placing {
    return
  }
  let entry = game.undo_stack.pop()
  match entry {
    Some(undo) => {
      let level = game.levels[game.current_level]
      // Remove from placed_tiles
      let new_placed : Array[(@types.Vec2i, @types.Tile)] = []
      let mut found = false
      // Find the last entry for this position
      let mut last_idx = -1
      for i in 0..<game.placed_tiles.length() {
        let (pos, _) = game.placed_tiles[i]
        if @types.vec2i_eq(pos, undo.pos) {
          last_idx = i
        }
      }
      for i in 0..<game.placed_tiles.length() {
        if i == last_idx && !found {
          found = true
          // Either restore previous tile or remove
          match undo.prev_tile {
            Some(prev) => new_placed.push((undo.pos, prev))
            None => () // remove entirely
          }
        } else {
          new_placed.push(game.placed_tiles[i])
        }
      }
      game.placed_tiles = new_placed
      // Update grid
      match undo.prev_tile {
        Some(prev) =>
          @types.set_tile(level.grid, undo.pos.x, undo.pos.y, Some(prev))
        None => @types.set_tile(level.grid, undo.pos.x, undo.pos.y, None)
      }
      @types.set_message(game, "Undo", 0.5)
    }
    None => ()
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.current_level)
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    // Go to next level
    let level_indices = @types.levels_for_tier(
      game,
      game.levels[game.current_level].tier,
    )
    let mut next = -1
    for i in 0..<level_indices.length() {
      if level_indices[i] == game.current_level {
        if i + 1 < level_indices.length() {
          next = level_indices[i + 1]
        }
        break
      }
    }
    if next >= 0 {
      start_level(game, next)
    } else {
      game.screen = LevelSelect
    }
  }
}
