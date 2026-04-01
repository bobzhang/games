///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count = game.frame_count + 1
  let dt = @raylib.get_frame_time()
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - dt
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
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let w = @types.screen_width
    for i in 0..<3 {
      let bx = w / 2 - 200
      let by = 160 + i * 160
      let bw = 400
      let bh = 120
      if mx >= bx && mx < bx + bw && my >= by && my < by + bh {
        game.current_tier = @types.tier_from_index(i)
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
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let w = @types.screen_width
    let cols = 5
    let cell_w = 160
    let cell_h = 100
    let gap = 20
    let start_x = (w - cols * (cell_w + gap) + gap) / 2
    let start_y = 120
    for i in 0..<@types.levels_per_tier {
      let row = i / cols
      let col = i % cols
      let bx = start_x + col * (cell_w + gap)
      let by = start_y + row * (cell_h + gap)
      if mx >= bx && mx < bx + cell_w && my >= by && my < by + cell_h {
        game.current_level = i
        start_level(game)
        return
      }
    }
  }
}

///|
fn start_level(game : @types.Game) -> Unit {
  @types.reset_level(game)
  game.screen = Playing
}

///|
fn update_playing(game : @types.Game, dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  match game.play_state {
    Placing => {
      game.timer = game.timer + dt
      let level_idx = @types.level_index(game.current_tier, game.current_level)
      let level = @levels.get_level(level_idx)
      // Update hover position
      let mx = @raylib.get_mouse_x()
      let my = @raylib.get_mouse_y()
      let ox = @types.grid_offset_x
      let oy = @types.grid_offset_y
      let cs = @types.cell_size
      let gx = (mx - ox) / cs
      let gy = (my - oy) / cs
      if gx >= 0 && gx < @types.grid_cols && gy >= 0 && gy < @types.grid_rows {
        game.hover_x = gx
        game.hover_y = gy
      } else {
        game.hover_x = -1
        game.hover_y = -1
      }
      // Piece selection via number keys or palette click
      update_piece_selection(game, level)
      // Rotate piece
      if @raylib.is_key_pressed(@raylib.KeyR) {
        game.rotation = (game.rotation + 1) % 4
        game.rotation_count = game.rotation_count + 1
      }
      // Flip piece
      if @raylib.is_key_pressed(@raylib.KeyF) {
        game.flipped = !game.flipped
        game.rotation_count = game.rotation_count + 1
      }
      // Clear all placed pieces
      if @raylib.is_key_pressed(@raylib.KeyC) {
        game.placed_pieces = []
        game.grid = @types.new_grid()
        game.message = "Board cleared"
        game.message_timer = 1.0
      }
      // Place piece with left click
      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) &&
        game.hover_x >= 0 &&
        game.hover_y >= 0 {
        try_place_piece(game, level)
      }
      // Remove piece with right click
      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) &&
        game.hover_x >= 0 &&
        game.hover_y >= 0 {
        try_remove_piece(game)
      }
      // Check completion
      if @packing.is_region_complete(level.region, game.grid) {
        game.play_state = Completed
        let time_s = game.timer.to_int()
        let stars = @packing.calculate_stars(
          time_s,
          game.rotation_count,
          level.par_time,
          level.par_rotations,
        )
        let score = game.level_scores[level_idx]
        score.completed = true
        if stars > score.stars {
          score.stars = stars
        }
        if time_s < score.best_time {
          score.best_time = time_s
        }
        if game.rotation_count < score.best_rotations {
          score.best_rotations = game.rotation_count
        }
        game.screen = Results
      }
    }
    Completed => ()
  }
}

///|
fn update_piece_selection(game : @types.Game, level : @types.Level) -> Unit {
  // Number keys 1-9 for piece selection
  for i in 0..<9 {
    if i < level.pieces.length() && @raylib.is_key_pressed(@raylib.KeyOne + i) {
      if !@packing.is_piece_used(game.placed_pieces, i) {
        game.selected_piece = i
        game.rotation = 0
        game.flipped = false
        return
      }
    }
  }
  // Click on palette to select
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let px = @types.palette_x
    let py = @types.palette_y
    for i in 0..<level.pieces.length() {
      let row = i / @types.palette_cols
      let col = i % @types.palette_cols
      let bx = px + col * 120
      let by = py + row * 110
      if mx >= bx && mx < bx + 110 && my >= by && my < by + 100 {
        if !@packing.is_piece_used(game.placed_pieces, i) {
          game.selected_piece = i
          game.rotation = 0
          game.flipped = false
        }
        return
      }
    }
  }
}

///|
fn try_place_piece(game : @types.Game, level : @types.Level) -> Unit {
  if game.selected_piece < 0 || game.selected_piece >= level.pieces.length() {
    return
  }
  if @packing.is_piece_used(game.placed_pieces, game.selected_piece) {
    return
  }
  let piece = level.pieces[game.selected_piece]
  let cells = @types.transform_cells(piece.cells, game.rotation, game.flipped)
  let pos = @types.vec2i(game.hover_x, game.hover_y)
  if @packing.can_place_piece(level.region, game.grid, cells, pos) {
    let placed_id = game.placed_pieces.length()
    @packing.place_piece(game.grid, cells, pos, placed_id)
    game.placed_pieces.push({
      piece_index: game.selected_piece,
      position: pos,
      rotation: game.rotation,
      flipped: game.flipped,
    })
    game.selected_piece = -1
    game.rotation = 0
    game.flipped = false
  } else {
    game.message = "Cannot place here!"
    game.message_timer = 1.0
  }
}

///|
fn try_remove_piece(game : @types.Game) -> Unit {
  let cell_val = game.grid[game.hover_y][game.hover_x]
  if cell_val < 0 {
    return
  }
  // Remove this placed piece
  @packing.remove_piece(game.grid, cell_val)
  // Rebuild placed_pieces array and reassign grid ids
  let old_placed = game.placed_pieces
  game.placed_pieces = []
  game.grid = @types.new_grid()
  for i in 0..<old_placed.length() {
    if i != cell_val {
      let pp = old_placed[i]
      let level_idx = @types.level_index(game.current_tier, game.current_level)
      let level = @levels.get_level(level_idx)
      let piece = level.pieces[pp.piece_index]
      let cells = @types.transform_cells(piece.cells, pp.rotation, pp.flipped)
      let new_id = game.placed_pieces.length()
      @packing.place_piece(game.grid, cells, pp.position, new_id)
      game.placed_pieces.push(pp)
    }
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game)
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    // Next level
    let next = game.current_level + 1
    if next < @types.levels_per_tier {
      game.current_level = next
      start_level(game)
    } else {
      // Go back to level select
      game.screen = LevelSelect
    }
  }
}
