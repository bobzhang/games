///|
fn draw_playing(game : @types.Game) -> Unit {
  let level = game.levels[game.current_level]
  draw_grid_background()
  draw_filled_tiles(game, level)
  draw_holes(game, level)
  draw_placed_tiles_validation(game, level)
  draw_hover_preview(game, level)
  draw_symmetry_indicator(game, level)
  draw_palette(game)
  draw_game_hud(game, level)
  // Message
  if game.message_timer > 0.0 {
    let w = @types.screen_width
    let tw = @draw.measure_text(game.message, 24)
    @draw.draw_text(
      game.message,
      (w - tw) / 2,
      @types.screen_height - 60,
      24,
      @types.color_title_accent,
    )
  }
}

///|
fn draw_grid_background() -> Unit {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  let gw = @types.grid_cols * cs
  let gh = @types.grid_rows * cs
  // Grid background
  @raylib.draw_rectangle(ox - 4, oy - 4, gw + 8, gh + 8, @types.color_grid_bg)
  // Grid lines
  for i in 0..<=@types.grid_cols {
    let x = ox + i * cs
    @raylib.draw_line(x, oy, x, oy + gh, @types.color_grid_line)
  }
  for i in 0..<=@types.grid_rows {
    let y = oy + i * cs
    @raylib.draw_line(ox, y, ox + gw, y, @types.color_grid_line)
  }
}

///|
fn draw_filled_tiles(game : @types.Game, level : @types.Level) -> Unit {
  let grid = level.grid
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  for y in 0..<grid.height {
    for x in 0..<grid.width {
      if @types.is_hole(grid, @types.vec2i(x, y)) {
        continue
      }
      match @types.get_tile(grid, x, y) {
        Some(tile) => {
          let px = ox + x * cs
          let py = oy + y * cs
          draw_tile_at(tile, px, py, cs, 255)
        }
        None => ()
      }
    }
  }
  // Draw placed tiles
  for i in 0..<game.placed_tiles.length() {
    let (pos, tile) = game.placed_tiles[i]
    let px = ox + pos.x * cs
    let py = oy + pos.y * cs
    draw_tile_at(tile, px, py, cs, 255)
  }
}

///|
fn draw_tile_at(
  tile : @types.Tile,
  px : Int,
  py : Int,
  cs : Int,
  alpha : Int,
) -> Unit {
  let color = @types.tile_color_to_raylib(tile.color)
  let r = color.r.to_int()
  let g = color.g.to_int()
  let b = color.b.to_int()
  let c = @raylib.Color::new(r, g, b, alpha)
  let cx = Float::from_int(px + cs / 2)
  let cy = Float::from_int(py + cs / 2)
  let half = Float::from_int(cs) / 2.0 - 3.0
  match tile.shape {
    Square => @raylib.draw_rectangle(px + 2, py + 2, cs - 4, cs - 4, c)
    Circle => @raylib.draw_circle(cx.to_int(), cy.to_int(), half, c)
    Diamond => {
      // Draw diamond as rotated square using lines/triangles
      let top_x = cx
      let top_y = cy - half
      let right_x = cx + half
      let right_y = cy
      let bottom_x = cx
      let bottom_y = cy + half
      let left_x = cx - half
      let left_y = cy
      @raylib.draw_triangle(
        @raylib.Vector2::new(top_x, top_y),
        @raylib.Vector2::new(left_x, left_y),
        @raylib.Vector2::new(bottom_x, bottom_y),
        c,
      )
      @raylib.draw_triangle(
        @raylib.Vector2::new(top_x, top_y),
        @raylib.Vector2::new(bottom_x, bottom_y),
        @raylib.Vector2::new(right_x, right_y),
        c,
      )
    }
    Cross => {
      let arm = (half * 0.35).to_int()
      let arm_f = Float::from_int(arm)
      // Horizontal bar
      @raylib.draw_rectangle(
        (cx - half).to_int(),
        (cy - arm_f).to_int(),
        (half * 2.0).to_int(),
        arm * 2,
        c,
      )
      // Vertical bar
      @raylib.draw_rectangle(
        (cx - arm_f).to_int(),
        (cy - half).to_int(),
        arm * 2,
        (half * 2.0).to_int(),
        c,
      )
    }
    Triangle => draw_oriented_triangle(cx, cy, half, tile.orientation, c)
    Arrow => draw_oriented_arrow(cx, cy, half, tile.orientation, c)
  }
}

///|
fn draw_oriented_triangle(
  cx : Float,
  cy : Float,
  half : Float,
  orient : @types.Orientation,
  color : @raylib.Color,
) -> Unit {
  let (p1, p2, p3) = match orient {
    N =>
      (
        @raylib.Vector2::new(cx, cy - half),
        @raylib.Vector2::new(cx - half, cy + half),
        @raylib.Vector2::new(cx + half, cy + half),
      )
    E =>
      (
        @raylib.Vector2::new(cx + half, cy),
        @raylib.Vector2::new(cx - half, cy - half),
        @raylib.Vector2::new(cx - half, cy + half),
      )
    S =>
      (
        @raylib.Vector2::new(cx, cy + half),
        @raylib.Vector2::new(cx + half, cy - half),
        @raylib.Vector2::new(cx - half, cy - half),
      )
    W =>
      (
        @raylib.Vector2::new(cx - half, cy),
        @raylib.Vector2::new(cx + half, cy + half),
        @raylib.Vector2::new(cx + half, cy - half),
      )
  }
  @raylib.draw_triangle(p1, p2, p3, color)
}

///|
fn draw_oriented_arrow(
  cx : Float,
  cy : Float,
  half : Float,
  orient : @types.Orientation,
  color : @raylib.Color,
) -> Unit {
  let shaft_w = half * 0.3
  match orient {
    N => {
      // Shaft
      @raylib.draw_rectangle(
        (cx - shaft_w).to_int(),
        cy.to_int(),
        (shaft_w * 2.0).to_int(),
        half.to_int(),
        color,
      )
      // Head
      @raylib.draw_triangle(
        @raylib.Vector2::new(cx, cy - half),
        @raylib.Vector2::new(cx - half * 0.7, cy),
        @raylib.Vector2::new(cx + half * 0.7, cy),
        color,
      )
    }
    E => {
      @raylib.draw_rectangle(
        (cx - half).to_int(),
        (cy - shaft_w).to_int(),
        half.to_int(),
        (shaft_w * 2.0).to_int(),
        color,
      )
      @raylib.draw_triangle(
        @raylib.Vector2::new(cx + half, cy),
        @raylib.Vector2::new(cx, cy + half * 0.7),
        @raylib.Vector2::new(cx, cy - half * 0.7),
        color,
      )
    }
    S => {
      @raylib.draw_rectangle(
        (cx - shaft_w).to_int(),
        (cy - half).to_int(),
        (shaft_w * 2.0).to_int(),
        half.to_int(),
        color,
      )
      @raylib.draw_triangle(
        @raylib.Vector2::new(cx, cy + half),
        @raylib.Vector2::new(cx + half * 0.7, cy),
        @raylib.Vector2::new(cx - half * 0.7, cy),
        color,
      )
    }
    W => {
      @raylib.draw_rectangle(
        cx.to_int(),
        (cy - shaft_w).to_int(),
        half.to_int(),
        (shaft_w * 2.0).to_int(),
        color,
      )
      @raylib.draw_triangle(
        @raylib.Vector2::new(cx - half, cy),
        @raylib.Vector2::new(cx, cy - half * 0.7),
        @raylib.Vector2::new(cx, cy + half * 0.7),
        color,
      )
    }
  }
}

///|
fn draw_holes(game : @types.Game, level : @types.Level) -> Unit {
  let grid = level.grid
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  for i in 0..<grid.holes.length() {
    let h = grid.holes[i]
    // Check if already filled by player
    let mut filled = false
    for j in 0..<game.placed_tiles.length() {
      let (pos, _) = game.placed_tiles[j]
      if @types.vec2i_eq(pos, h) {
        filled = true
        break
      }
    }
    if !filled {
      let px = ox + h.x * cs
      let py = oy + h.y * cs
      @raylib.draw_rectangle(px + 1, py + 1, cs - 2, cs - 2, @types.color_hole)
      @raylib.draw_rectangle_lines(
        px + 1,
        py + 1,
        cs - 2,
        cs - 2,
        @types.color_hole_border,
      )
      // Question mark
      let qw = @draw.measure_text("?", 20)
      @draw.draw_text(
        "?",
        px + (cs - qw) / 2,
        py + cs / 2 - 10,
        20,
        @types.color_hole_border,
      )
    }
  }
  ignore(game)
}

///|
fn draw_placed_tiles_validation(
  game : @types.Game,
  level : @types.Level,
) -> Unit {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  let total = game.placed_tiles.length()
  for i in 0..<total {
    let (pos, tile) = game.placed_tiles[i]
    let valid = @symmetry.validate_placement(
      level.grid,
      pos,
      tile,
      level.symmetry,
    )
    let glow_color = if valid {
      @types.color_correct_glow
    } else {
      @types.color_wrong_glow
    }
    let px = ox + pos.x * cs
    let py = oy + pos.y * cs
    // Placement animation: recently placed tiles have a scale-in effect
    // The last placed tile gets the strongest animation
    let is_newest = i == total - 1
    if is_newest {
      // Animated glow ring that expands and fades
      let anim_t = game.anim_timer * 4.0
      let floored : Float = Float::from_double(@math.floor(anim_t.to_double()))
      let ring_phase = anim_t - floored
      if ring_phase < 1.0 {
        let ring_size = Float::from_int(cs) * (0.5 + ring_phase * 0.8)
        let one : Float = 1.0
        let ring_alpha = ((one - ring_phase) * 200.0).to_int()
        let r = glow_color.r.to_int()
        let g = glow_color.g.to_int()
        let b = glow_color.b.to_int()
        let ring_c = @raylib.Color::new(r, g, b, ring_alpha)
        let center_x = Float::from_int(px + cs / 2)
        let center_y = Float::from_int(py + cs / 2)
        @raylib.draw_ring(
          @raylib.Vector2::new(center_x, center_y),
          ring_size - 2.0,
          ring_size + 2.0,
          0.0,
          360.0,
          24,
          ring_c,
        )
      }
    }
    // Standard validation border
    @raylib.draw_rectangle_lines(px, py, cs, cs, glow_color)
    @raylib.draw_rectangle_lines(px + 1, py + 1, cs - 2, cs - 2, glow_color)
    // For correct placements, add a subtle checkmark indicator
    if valid {
      let check_alpha = if is_newest { 255 } else { 180 }
      let check_color = @raylib.Color::new(50, 255, 120, check_alpha)
      // Small check in top-right corner
      @raylib.draw_line(px + cs - 14, py + 6, px + cs - 9, py + 11, check_color)
      @raylib.draw_line(px + cs - 9, py + 11, px + cs - 3, py + 3, check_color)
    } else {
      // X mark for incorrect
      let x_color = @raylib.Color::new(255, 60, 60, 200)
      @raylib.draw_line(px + cs - 14, py + 3, px + cs - 3, py + 12, x_color)
      @raylib.draw_line(px + cs - 3, py + 3, px + cs - 14, py + 12, x_color)
    }
  }
}

///|
fn draw_hover_preview(game : @types.Game, level : @types.Level) -> Unit {
  match game.hover_cell {
    None => ()
    Some(cell) => {
      // Check it's a hole and not filled
      if !@types.is_hole(level.grid, cell) {
        return
      }
      let mut already_filled = false
      for i in 0..<game.placed_tiles.length() {
        let (pos, _) = game.placed_tiles[i]
        if @types.vec2i_eq(pos, cell) {
          already_filled = true
          break
        }
      }
      if already_filled {
        return
      }
      let ox = @types.grid_offset_x
      let oy = @types.grid_offset_y
      let cs = @types.cell_size
      let px = ox + cell.x * cs
      let py = oy + cell.y * cs
      // Pulsing preview with bounce effect
      let t = Float::from_int(game.frame_count) * 0.1
      let pulse = sinf(t) * 20.0 + 110.0
      let alpha = pulse.to_int()
      let preview = @types.new_tile(
        game.selected_color,
        game.selected_shape,
        game.selected_orientation,
      )
      // Draw with slight scale animation (shrink/grow)
      let scale_pulse = sinf(t * 2.0) * 0.06 + 1.0
      let scaled_cs = (Float::from_int(cs) * scale_pulse).to_int()
      let offset = (cs - scaled_cs) / 2
      draw_tile_at(preview, px + offset, py + offset, scaled_cs, alpha)
      // Animated border
      let border_alpha = (sinf(t * 3.0) * 60.0 + 160.0).to_int()
      let border_color = @raylib.Color::new(255, 255, 255, border_alpha)
      @raylib.draw_rectangle_lines(
        px + offset,
        py + offset,
        scaled_cs,
        scaled_cs,
        border_color,
      )
      // Corner markers for emphasis
      let corner_size = 6
      let cc = @raylib.Color::new(255, 255, 200, border_alpha)
      @raylib.draw_rectangle(px, py, corner_size, 2, cc)
      @raylib.draw_rectangle(px, py, 2, corner_size, cc)
      @raylib.draw_rectangle(px + cs - corner_size, py, corner_size, 2, cc)
      @raylib.draw_rectangle(px + cs - 2, py, 2, corner_size, cc)
      @raylib.draw_rectangle(px, py + cs - 2, corner_size, 2, cc)
      @raylib.draw_rectangle(px, py + cs - corner_size, 2, corner_size, cc)
      @raylib.draw_rectangle(
        px + cs - corner_size,
        py + cs - 2,
        corner_size,
        2,
        cc,
      )
      @raylib.draw_rectangle(
        px + cs - 2,
        py + cs - corner_size,
        2,
        corner_size,
        cc,
      )
    }
  }
}

///|
fn draw_symmetry_indicator(game : @types.Game, level : @types.Level) -> Unit {
  if !game.show_symmetry_hint {
    return
  }
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  let gw = @types.grid_cols * cs
  let gh = @types.grid_rows * cs
  let time = Float::from_int(game.frame_count) * 0.08
  let pulse = sinf(time)
  let alpha_f : Float = 160.0 + pulse * 50.0
  let alpha = alpha_f.to_int()
  let indicator_color = @raylib.Color::new(255, 255, 100, alpha)
  let glow_color = @raylib.Color::new(255, 255, 100, alpha / 3)
  let dash_phase = game.frame_count / 8 % 16
  match level.symmetry {
    MirrorH => {
      // Horizontal axis with glow band and dashed line
      let cy = oy + gh / 2
      let cy_f = Float::from_int(cy)
      // Glow band
      @raylib.draw_rectangle(ox, cy - 4, gw, 8, glow_color)
      // Main line
      @raylib.draw_line_ex(
        @raylib.Vector2::new(Float::from_int(ox - 12), cy_f),
        @raylib.Vector2::new(Float::from_int(ox + gw + 12), cy_f),
        3.0,
        indicator_color,
      )
      // Arrow caps at both ends
      draw_axis_arrow(ox - 12, cy, 0, indicator_color)
      draw_axis_arrow(ox + gw + 12, cy, 2, indicator_color)
      // Label
      @draw.draw_text("H", ox + gw + 18, cy - 8, 16, indicator_color)
      // Reflection hint lines (dashed perpendicular ticks)
      for i in 0..<@types.grid_cols {
        let tx = ox + i * cs + cs / 2
        if (i + dash_phase) % 3 == 0 {
          @raylib.draw_line(tx, cy - 10, tx, cy + 10, glow_color)
        }
      }
    }
    MirrorV => {
      // Vertical axis with glow band
      let cx = ox + gw / 2
      let cx_f = Float::from_int(cx)
      @raylib.draw_rectangle(cx - 4, oy, 8, gh, glow_color)
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx_f, Float::from_int(oy - 12)),
        @raylib.Vector2::new(cx_f, Float::from_int(oy + gh + 12)),
        3.0,
        indicator_color,
      )
      draw_axis_arrow(cx, oy - 12, 1, indicator_color)
      draw_axis_arrow(cx, oy + gh + 12, 3, indicator_color)
      @draw.draw_text("V", cx - 4, oy + gh + 18, 16, indicator_color)
      for i in 0..<@types.grid_rows {
        let ty = oy + i * cs + cs / 2
        if (i + dash_phase) % 3 == 0 {
          @raylib.draw_line(cx - 10, ty, cx + 10, ty, glow_color)
        }
      }
    }
    MirrorD => {
      // Diagonal axis with glow and decorative markers
      let ox_f = Float::from_int(ox)
      let oy_f = Float::from_int(oy)
      let gw_f = Float::from_int(gw)
      let gh_f = Float::from_int(gh)
      // Glow along the diagonal
      for i in 0..<8 {
        let t_val = Float::from_int(i) / 7.0
        let dx = (ox_f + t_val * gw_f).to_int()
        let dy = (oy_f + t_val * gh_f).to_int()
        @raylib.draw_circle(dx, dy, 6.0, glow_color)
      }
      @raylib.draw_line_ex(
        @raylib.Vector2::new(ox_f - 8.0, oy_f - 8.0),
        @raylib.Vector2::new(ox_f + gw_f + 8.0, oy_f + gh_f + 8.0),
        3.0,
        indicator_color,
      )
      @draw.draw_text("D", ox + gw + 12, oy + gh + 4, 16, indicator_color)
      // Diamond markers along diagonal
      for i in 0..<=@types.grid_cols {
        let t_val = Float::from_int(i) / Float::from_int(@types.grid_cols)
        let dx = ox_f + t_val * gw_f
        let dy = oy_f + t_val * gh_f
        if (i + dash_phase) % 2 == 0 {
          draw_diamond_marker(dx.to_int(), dy.to_int(), 4, indicator_color)
        }
      }
    }
    Rotate2 => {
      // 180-degree rotation: center point with rotation arc
      let cx = Float::from_int(ox + gw / 2)
      let cy = Float::from_int(oy + gh / 2)
      // Glow circle
      @raylib.draw_circle(cx.to_int(), cy.to_int(), 20.0, glow_color)
      // Center dot
      @raylib.draw_circle(cx.to_int(), cy.to_int(), 6.0, indicator_color)
      // Rotation arc (180 degrees)
      let arc_start = Float::from_int(game.frame_count) * 1.5
      @raylib.draw_ring(
        @raylib.Vector2::new(cx, cy),
        22.0,
        26.0,
        arc_start,
        arc_start + 180.0,
        24,
        indicator_color,
      )
      // Second arc (opposite half, dimmer)
      let dim_color = @raylib.Color::new(255, 255, 100, alpha / 2)
      @raylib.draw_ring(
        @raylib.Vector2::new(cx, cy),
        22.0,
        26.0,
        arc_start + 180.0,
        arc_start + 360.0,
        24,
        dim_color,
      )
      @draw.draw_text(
        "180",
        (cx - 12.0).to_int(),
        (cy + 30.0).to_int(),
        14,
        indicator_color,
      )
    }
    Rotate4 => {
      // 90-degree rotation: center point with 4 arcs
      let cx = Float::from_int(ox + gw / 2)
      let cy = Float::from_int(oy + gh / 2)
      @raylib.draw_circle(cx.to_int(), cy.to_int(), 22.0, glow_color)
      @raylib.draw_circle(cx.to_int(), cy.to_int(), 6.0, indicator_color)
      // Four 90-degree arc segments, rotating
      let arc_start = Float::from_int(game.frame_count) * 2.0
      let colors = [
        @raylib.Color::new(255, 255, 100, alpha),
        @raylib.Color::new(100, 255, 200, alpha),
        @raylib.Color::new(255, 150, 100, alpha),
        @raylib.Color::new(180, 100, 255, alpha),
      ]
      for i in 0..<4 {
        let start_angle = arc_start + Float::from_int(i) * 90.0
        @raylib.draw_ring(
          @raylib.Vector2::new(cx, cy),
          22.0,
          28.0,
          start_angle,
          start_angle + 80.0,
          16,
          colors[i],
        )
      }
      // Cross lines through center
      let cross_len : Float = 16.0
      @raylib.draw_line(
        (cx - cross_len).to_int(),
        cy.to_int(),
        (cx + cross_len).to_int(),
        cy.to_int(),
        glow_color,
      )
      @raylib.draw_line(
        cx.to_int(),
        (cy - cross_len).to_int(),
        cx.to_int(),
        (cy + cross_len).to_int(),
        glow_color,
      )
      @draw.draw_text(
        "90",
        (cx - 8.0).to_int(),
        (cy + 32.0).to_int(),
        14,
        indicator_color,
      )
    }
    Glide => {
      // Glide reflection: horizontal line with animated shift arrows
      let cy = oy + gh / 2
      let cy_f = Float::from_int(cy)
      @raylib.draw_rectangle(ox, cy - 3, gw, 6, glow_color)
      // Dashed main line to show the glide nature
      let dash_len = 12
      let gap_len = 8
      let mut dx = ox
      while dx < ox + gw {
        let end_x = @types.clamp_int(dx + dash_len, 0, ox + gw)
        @raylib.draw_line_ex(
          @raylib.Vector2::new(Float::from_int(dx), cy_f),
          @raylib.Vector2::new(Float::from_int(end_x), cy_f),
          3.0,
          indicator_color,
        )
        dx += dash_len + gap_len
      }
      // Animated shift arrows that slide along
      let shift_offset = Float::from_int(game.frame_count % 120) /
        120.0 *
        Float::from_int(cs * 2)
      for i in 0..<5 {
        let ax = Float::from_int(ox) +
          Float::from_int(i) * Float::from_int(cs * 2) +
          shift_offset
        if ax.to_int() >= ox && ax.to_int() <= ox + gw - 10 {
          // Upper arrow pointing right
          draw_shift_arrow(ax.to_int(), cy - 14, true, indicator_color)
          // Lower arrow pointing right (shifted by half period)
          let lower_x = ax + Float::from_int(cs)
          if lower_x.to_int() >= ox && lower_x.to_int() <= ox + gw - 10 {
            draw_shift_arrow(lower_x.to_int(), cy + 8, true, indicator_color)
          }
        }
      }
      // Mirror flip indicators
      let flip_color = @raylib.Color::new(255, 200, 100, alpha / 2)
      @raylib.draw_line(ox + gw / 4, cy - 16, ox + gw / 4, cy + 16, flip_color)
      @raylib.draw_line(
        ox + gw * 3 / 4,
        cy - 16,
        ox + gw * 3 / 4,
        cy + 16,
        flip_color,
      )
      @draw.draw_text("Glide", ox + gw + 12, cy - 8, 14, indicator_color)
    }
  }
}

// Draw an arrow cap for axis endpoints

///|
fn draw_axis_arrow(
  x : Int,
  y : Int,
  direction : Int,
  color : @raylib.Color,
) -> Unit {
  let s : Float = 8.0
  let cx = Float::from_int(x)
  let cy = Float::from_int(y)
  match direction {
    0 =>
      // Left arrow
      @raylib.draw_triangle(
        @raylib.Vector2::new(cx - s, cy),
        @raylib.Vector2::new(cx + 2.0, cy + s * 0.6),
        @raylib.Vector2::new(cx + 2.0, cy - s * 0.6),
        color,
      )
    1 =>
      // Up arrow
      @raylib.draw_triangle(
        @raylib.Vector2::new(cx, cy - s),
        @raylib.Vector2::new(cx - s * 0.6, cy + 2.0),
        @raylib.Vector2::new(cx + s * 0.6, cy + 2.0),
        color,
      )
    2 =>
      // Right arrow
      @raylib.draw_triangle(
        @raylib.Vector2::new(cx + s, cy),
        @raylib.Vector2::new(cx - 2.0, cy - s * 0.6),
        @raylib.Vector2::new(cx - 2.0, cy + s * 0.6),
        color,
      )
    _ =>
      // Down arrow
      @raylib.draw_triangle(
        @raylib.Vector2::new(cx, cy + s),
        @raylib.Vector2::new(cx + s * 0.6, cy - 2.0),
        @raylib.Vector2::new(cx - s * 0.6, cy - 2.0),
        color,
      )
  }
}

// Draw a small diamond marker

///|
fn draw_diamond_marker(
  x : Int,
  y : Int,
  size : Int,
  color : @raylib.Color,
) -> Unit {
  let cx = Float::from_int(x)
  let cy = Float::from_int(y)
  let s = Float::from_int(size)
  @raylib.draw_triangle(
    @raylib.Vector2::new(cx, cy - s),
    @raylib.Vector2::new(cx - s, cy),
    @raylib.Vector2::new(cx, cy + s),
    color,
  )
  @raylib.draw_triangle(
    @raylib.Vector2::new(cx, cy - s),
    @raylib.Vector2::new(cx, cy + s),
    @raylib.Vector2::new(cx + s, cy),
    color,
  )
}

// Draw an animated shift arrow for glide reflection

///|
fn draw_shift_arrow(
  x : Int,
  y : Int,
  _right : Bool,
  color : @raylib.Color,
) -> Unit {
  let cx = Float::from_int(x)
  let cy = Float::from_int(y)
  // Arrow shaft
  @raylib.draw_rectangle(x - 6, y + 1, 12, 4, color)
  // Arrow head
  @raylib.draw_triangle(
    @raylib.Vector2::new(cx + 10.0, cy + 3.0),
    @raylib.Vector2::new(cx + 4.0, cy - 2.0),
    @raylib.Vector2::new(cx + 4.0, cy + 8.0),
    color,
  )
}
