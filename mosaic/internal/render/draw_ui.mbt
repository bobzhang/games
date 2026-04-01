///|
fn draw_palette(game : @types.Game) -> Unit {
  let px = @types.palette_x
  let py = @types.palette_y
  let ss = @types.swatch_size
  // Title
  @draw.draw_text("PALETTE", px, py - 30, 18, @types.color_hud_text)
  // Color swatches
  @draw.draw_text("Color:", px, py, 14, @types.color_hud_dim)
  let colors = @types.all_colors()
  for i in 0..<colors.length() {
    let sx = px + i * (ss + 6)
    let sy = py + 20
    let c = @types.tile_color_to_raylib(colors[i])
    @raylib.draw_rectangle(sx, sy, ss, ss, c)
    if colors[i] == game.selected_color {
      @raylib.draw_rectangle_lines(
        sx - 2,
        sy - 2,
        ss + 4,
        ss + 4,
        @types.color_selected,
      )
      @raylib.draw_rectangle_lines(
        sx - 3,
        sy - 3,
        ss + 6,
        ss + 6,
        @types.color_selected,
      )
    }
    // Key hint
    let key_str = (i + 1).to_string()
    @draw.draw_text(
      key_str,
      sx + ss / 2 - 4,
      sy + ss + 2,
      12,
      @types.color_hud_dim,
    )
  }
  // Shape swatches
  let shape_y = py + 100
  @draw.draw_text("Shape:", px, shape_y, 14, @types.color_hud_dim)
  let shapes = @types.all_shapes()
  for i in 0..<shapes.length() {
    let sx = px + i * (ss + 6)
    let sy = shape_y + 20
    let bg = @raylib.Color::new(50, 45, 65, 255)
    @raylib.draw_rectangle(sx, sy, ss, ss, bg)
    // Draw shape preview in white
    let preview = @types.new_tile(White, shapes[i], N)
    draw_tile_at(preview, sx, sy, ss, 220)
    if shapes[i] == game.selected_shape {
      @raylib.draw_rectangle_lines(
        sx - 2,
        sy - 2,
        ss + 4,
        ss + 4,
        @types.color_selected,
      )
      @raylib.draw_rectangle_lines(
        sx - 3,
        sy - 3,
        ss + 6,
        ss + 6,
        @types.color_selected,
      )
    }
    // Key hint - Q W E R T Y
    let keys = ["Q", "W", "E", "R", "T", "Y"]
    if i < keys.length() {
      @draw.draw_text(
        keys[i],
        sx + ss / 2 - 4,
        sy + ss + 2,
        12,
        @types.color_hud_dim,
      )
    }
  }
  // Orientation
  let orient_y = py + 200
  @draw.draw_text("Orientation:", px, orient_y, 14, @types.color_hud_dim)
  let orients = @types.all_orientations()
  let orient_labels = ["N", "E", "S", "W"]
  for i in 0..<orients.length() {
    let sx = px + i * (ss + 6)
    let sy = orient_y + 20
    let bg = @raylib.Color::new(50, 45, 65, 255)
    @raylib.draw_rectangle(sx, sy, ss, ss, bg)
    // Draw arrow in this orientation
    let preview = @types.new_tile(White, Arrow, orients[i])
    draw_tile_at(preview, sx, sy, ss, 220)
    if orients[i] == game.selected_orientation {
      @raylib.draw_rectangle_lines(
        sx - 2,
        sy - 2,
        ss + 4,
        ss + 4,
        @types.color_selected,
      )
      @raylib.draw_rectangle_lines(
        sx - 3,
        sy - 3,
        ss + 6,
        ss + 6,
        @types.color_selected,
      )
    }
    @draw.draw_text(
      orient_labels[i],
      sx + ss / 2 - 4,
      sy + ss + 2,
      12,
      @types.color_hud_dim,
    )
  }
  // Preview
  let prev_y = orient_y + 110
  @draw.draw_text("Preview:", px, prev_y, 14, @types.color_hud_dim)
  let prev_size = 80
  let bg = @raylib.Color::new(50, 45, 65, 255)
  @raylib.draw_rectangle(px, prev_y + 20, prev_size, prev_size, bg)
  let preview_tile = @types.new_tile(
    game.selected_color,
    game.selected_shape,
    game.selected_orientation,
  )
  draw_tile_at(preview_tile, px, prev_y + 20, prev_size, 255)
  @raylib.draw_rectangle_lines(
    px - 1,
    prev_y + 19,
    prev_size + 2,
    prev_size + 2,
    @types.color_grid_line,
  )
  // Symmetry guess buttons
  if game.play_state == GuessSymmetry {
    draw_symmetry_guess_ui(game)
  }
  // Controls help
  let help_y = @types.screen_height - 80
  @draw.draw_text(
    "LMB: Place tile   Z: Undo   R: Restart   H: Toggle hint", px, help_y, 13, @types.color_hud_dim,
  )
  @draw.draw_text(
    "1-6: Color   QWERTY: Shape   Arrow keys: Rotate",
    px,
    help_y + 18,
    13,
    @types.color_hud_dim,
  )
}

///|
fn draw_symmetry_guess_ui(game : @types.Game) -> Unit {
  let px = @types.palette_x
  let by = @types.palette_y + 440
  @draw.draw_text(
    "Identify the symmetry type:", px, by, 16, @types.color_title_accent,
  )
  let sym_names = [
    "Mirror H", "Mirror V", "Mirror D", "Rotate 180", "Rotate 90", "Glide",
  ]
  let btn_w = 140
  let btn_h = 30
  for i in 0..<sym_names.length() {
    let col = i % 2
    let row = i / 2
    let bx = px + col * (btn_w + 10)
    let by2 = by + 24 + row * (btn_h + 6)
    let hovered = is_mouse_in_rect(bx, by2, btn_w, btn_h)
    let bg = if hovered {
      @raylib.Color::new(80, 70, 110, 255)
    } else {
      @raylib.Color::new(55, 50, 75, 255)
    }
    let selected = match game.symmetry_guess {
      Some(sg) => @types.symmetry_index(sg) == i
      None => false
    }
    if selected {
      @raylib.draw_rectangle(bx, by2, btn_w, btn_h, @types.color_title_accent)
    } else {
      @raylib.draw_rectangle(bx, by2, btn_w, btn_h, bg)
    }
    @raylib.draw_rectangle_lines(bx, by2, btn_w, btn_h, @types.color_grid_line)
    let tw = @draw.measure_text(sym_names[i], 14)
    @draw.draw_text(
      sym_names[i],
      bx + (btn_w - tw) / 2,
      by2 + 8,
      14,
      @types.color_hud_text,
    )
  }
  // Confirm button
  let confirm_y = by + 24 + 3 * (btn_h + 6) + 6
  let confirm_hovered = is_mouse_in_rect(px, confirm_y, btn_w * 2 + 10, btn_h)
  let confirm_bg = if confirm_hovered {
    @raylib.Color::new(50, 200, 120, 255)
  } else {
    @raylib.Color::new(40, 150, 90, 255)
  }
  @raylib.draw_rectangle(px, confirm_y, btn_w * 2 + 10, btn_h, confirm_bg)
  let ctw = @draw.measure_text("CONFIRM GUESS", 16)
  @draw.draw_text(
    "CONFIRM GUESS",
    px + (btn_w * 2 + 10 - ctw) / 2,
    confirm_y + 7,
    16,
    @types.color_hud_text,
  )
}

///|
fn draw_game_hud(game : @types.Game, level : @types.Level) -> Unit {
  let ox = @types.grid_offset_x
  // Level name
  @draw.draw_text(level.name, ox, 15, 28, @types.color_title_accent)
  // Tier
  @draw.draw_text(
    @types.tier_name(level.tier),
    ox + 300,
    22,
    16,
    @types.tier_color(level.tier),
  )
  // Symmetry type (shown after guess or if hint)
  if game.guessed_symmetry || game.show_symmetry_hint {
    @draw.draw_text(
      @types.symmetry_name(level.symmetry),
      ox + 400,
      22,
      16,
      @raylib.Color::new(255, 255, 100, 200),
    )
  }
  // Error count
  let errors_str = "Errors: " + game.errors.to_string()
  let err_color = if game.errors > 0 {
    @types.color_wrong_glow
  } else {
    @types.color_hud_dim
  }
  @draw.draw_text(errors_str, ox, 50, 16, err_color)
  // Remaining holes
  let remaining = @types.count_remaining_holes(game)
  @draw.draw_text(
    "Remaining: " + remaining.to_string(),
    ox + 150,
    50,
    16,
    @types.color_hud_dim,
  )
  // Play state
  let state_str = match game.play_state {
    Placing => "PLACING TILES"
    GuessSymmetry => "GUESS SYMMETRY"
    Complete => "COMPLETE!"
  }
  let state_color = match game.play_state {
    Complete => @types.color_correct_glow
    GuessSymmetry => @types.color_title_accent
    _ => @types.color_hud_dim
  }
  @draw.draw_text(state_str, ox + 320, 50, 16, state_color)
}

///|
pub fn is_mouse_in_rect(x : Int, y : Int, w : Int, h : Int) -> Bool {
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  mx >= x && mx < x + w && my >= y && my < y + h
}
