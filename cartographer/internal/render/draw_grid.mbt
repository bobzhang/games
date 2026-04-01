///|
fn fi(v : Int) -> Float {
  Float::from_int(v)
}

///|
fn vec2(x : Int, y : Int) -> @raylib.Vector2 {
  @raylib.Vector2::new(fi(x), fi(y))
}

///|
fn draw_playing(game : @types.Game) -> Unit {
  let level = game.levels[game.current_level]
  let gw = @types.grid_size * @types.cell_size + 20
  let gh = @types.grid_size * @types.cell_size + 20
  let gx = @types.grid_offset_x - 10
  let gy = @types.grid_offset_y - 10
  // Parchment background with layered texture effect
  @raylib.draw_rectangle(gx, gy, gw, gh, @types.color_parchment)
  // Parchment texture: subtle stipple dots
  draw_parchment_texture(gx, gy, gw, gh, game.parchment_seed)
  // Dark border with double-line for aged map feel
  @raylib.draw_rectangle_lines(gx, gy, gw, gh, @types.color_compass_ring)
  @raylib.draw_rectangle_lines(gx + 2, gy + 2, gw - 4, gh - 4, @types.color_parchment_border)
  // Corner decorations
  draw_corner_flourish(gx, gy)
  draw_corner_flourish(gx + gw, gy)
  draw_corner_flourish(gx, gy + gh)
  draw_corner_flourish(gx + gw, gy + gh)
  // Draw grid lines
  for i in 0..=@types.grid_size {
    let x = @types.grid_offset_x + i * @types.cell_size
    let y = @types.grid_offset_y + i * @types.cell_size
    @raylib.draw_line(
      x,
      @types.grid_offset_y,
      x,
      @types.grid_offset_y + @types.grid_size * @types.cell_size,
      @types.color_grid_line,
    )
    @raylib.draw_line(
      @types.grid_offset_x,
      y,
      @types.grid_offset_x + @types.grid_size * @types.cell_size,
      y,
      @types.color_grid_line,
    )
  }
  // Draw row/column labels
  for i in 0..<@types.grid_size {
    let label_col = (i + 1).to_string()
    let label_row = (i + 1).to_string()
    @draw.draw_text(
      label_col,
      @types.grid_offset_x + i * @types.cell_size + @types.cell_size / 2 - 4,
      @types.grid_offset_y - 20,
      16,
      @types.color_text_light,
    )
    @draw.draw_text(
      label_row,
      @types.grid_offset_x - 20,
      @types.grid_offset_y + i * @types.cell_size + @types.cell_size / 2 - 8,
      16,
      @types.color_text_light,
    )
  }
  // Draw empty cell dots and placed features
  for row in 0..<@types.grid_size {
    for col in 0..<@types.grid_size {
      let idx = row * @types.grid_size + col
      let cx = @types.grid_offset_x + col * @types.cell_size + @types.cell_size / 2
      let cy = @types.grid_offset_y + row * @types.cell_size + @types.cell_size / 2
      match game.grid[idx] {
        None => @raylib.draw_circle(cx, cy, 2.0, @types.color_grid_dot)
        Some(feature) => draw_feature(cx, cy, feature, @types.cell_size - 12)
      }
    }
  }
  // Draw clue-referenced cell highlights (when hovering a clue)
  for i in 0..<game.highlighted_cells.length() {
    let h = game.highlighted_cells[i]
    if h.x >= 0 && h.x < @types.grid_size && h.y >= 0 && h.y < @types.grid_size {
      @raylib.draw_rectangle(
        @types.grid_offset_x + h.x * @types.cell_size + 1,
        @types.grid_offset_y + h.y * @types.cell_size + 1,
        @types.cell_size - 2,
        @types.cell_size - 2,
        @types.color_clue_highlight,
      )
    }
  }
  // Draw graduated hint highlights
  if game.show_hints {
    match game.hint_level {
      Narrow =>
        // Show all possible cells with a subtle highlight
        for i in 0..<game.hint_narrow_cells.length() {
          let h = game.hint_narrow_cells[i]
          @raylib.draw_rectangle(
            @types.grid_offset_x + h.x * @types.cell_size + 2,
            @types.grid_offset_y + h.y * @types.cell_size + 2,
            @types.cell_size - 4,
            @types.cell_size - 4,
            @types.color_hint_narrow,
          )
        }
      Reveal | Answer =>
        // Show the specific revealed cell with bright highlight
        match game.hint_reveal_cell {
          Some(h) => {
            // Pulsing effect via triangle wave
            let time_f = Float::from_double(@raylib.get_time()) * 4.0
            let wave = time_f.to_int() % 2
            let alpha = if wave == 0 { 120 } else { 80 }
            let reveal_color = @raylib.Color::new(100, 255, 100, alpha)
            @raylib.draw_rectangle(
              @types.grid_offset_x + h.x * @types.cell_size + 2,
              @types.grid_offset_y + h.y * @types.cell_size + 2,
              @types.cell_size - 4,
              @types.cell_size - 4,
              reveal_color,
            )
            // Draw the feature name below
            match game.hint_feature {
              Some(f) => {
                let name = @types.feature_name(f)
                let tx = @types.grid_offset_x +
                  h.x * @types.cell_size +
                  @types.cell_size / 2 -
                  @draw.measure_text(name, 12) / 2
                let ty = @types.grid_offset_y +
                  h.y * @types.cell_size +
                  @types.cell_size -
                  4
                @draw.draw_text(name, tx, ty, 12, @types.color_clue_satisfied)
              }
              None => ()
            }
          }
          None => ()
        }
      None =>
        // Legacy: show forced cells
        for i in 0..<game.hint_cells.length() {
          let h = game.hint_cells[i]
          @raylib.draw_rectangle(
            @types.grid_offset_x + h.x * @types.cell_size + 2,
            @types.grid_offset_y + h.y * @types.cell_size + 2,
            @types.cell_size - 4,
            @types.cell_size - 4,
            @types.color_hint,
          )
        }
    }
  }
  // Draw flash feedback (placement confirmation or error)
  if game.flash_timer > 0.0 {
    match game.flash_cell {
      Some(fc) => {
        let flash_alpha_f = game.flash_timer / 0.5 * 150.0
        let flash_alpha = flash_alpha_f.to_int()
        let flash_color = if game.flash_is_error {
          @raylib.Color::new(255, 50, 50, flash_alpha)
        } else {
          @raylib.Color::new(50, 200, 50, flash_alpha)
        }
        @raylib.draw_rectangle(
          @types.grid_offset_x + fc.x * @types.cell_size,
          @types.grid_offset_y + fc.y * @types.cell_size,
          @types.cell_size,
          @types.cell_size,
          flash_color,
        )
      }
      None => ()
    }
  }
  // Draw hover highlight
  match game.hover_cell {
    Some(hc) =>
      if hc.x >= 0 &&
        hc.x < @types.grid_size &&
        hc.y >= 0 &&
        hc.y < @types.grid_size {
        @raylib.draw_rectangle(
          @types.grid_offset_x + hc.x * @types.cell_size + 1,
          @types.grid_offset_y + hc.y * @types.cell_size + 1,
          @types.cell_size - 2,
          @types.cell_size - 2,
          @types.color_hover,
        )
        // Draw preview of selected feature
        match game.selected_feature {
          Some(feat) => {
            let preview_cx = @types.grid_offset_x +
              hc.x * @types.cell_size +
              @types.cell_size / 2
            let preview_cy = @types.grid_offset_y +
              hc.y * @types.cell_size +
              @types.cell_size / 2
            let color = @types.feature_color(feat)
            let preview_color = @raylib.Color::new(
              color.r.to_int(), color.g.to_int(), color.b.to_int(), 120,
            )
            draw_feature_with_color(
              preview_cx, preview_cy, feat, @types.cell_size - 16, preview_color,
            )
          }
          None => ()
        }
      }
    None => ()
  }
  // Draw compass rose (top-right of grid)
  draw_compass_rose(
    @types.grid_offset_x + @types.grid_size * @types.cell_size + 30,
    @types.grid_offset_y + 30,
  )
  // Draw level name
  @draw.draw_text(
    level.name,
    @types.grid_offset_x,
    @types.grid_offset_y - 50,
    24,
    @types.color_text,
  )
  // Draw clues panel
  draw_clues_panel(game)
  // Draw feature palette
  draw_palette(game)
  // Draw placement counter
  draw_placement_info(game)
  // Draw message if any
  if game.message_timer > 0.0 {
    let msg_w = @draw.measure_text(game.message, 24)
    @draw.draw_text(
      game.message,
      @types.screen_width / 2 - msg_w / 2,
      @types.screen_height / 2 - 12,
      24,
      @types.color_town,
    )
  }
  // Draw controls help with hint level indicator
  let hint_text = match game.hint_level {
    None => "H:Hint(1/3)"
    Narrow => "H:Hint(2/3)"
    Reveal => "H:Hint(3/3)"
    Answer => "H:Reset Hints"
  }
  @draw.draw_text(
    "\{hint_text}  R:Restart  Esc:Back  Right-click:Remove",
    @types.grid_offset_x,
    @types.screen_height - 30,
    16,
    @types.color_text_light,
  )
}

///|
fn draw_feature(cx : Int, cy : Int, feature : @types.FeatureKind, size : Int) -> Unit {
  let color = @types.feature_color(feature)
  draw_feature_with_color(cx, cy, feature, size, color)
}

///|
fn draw_feature_with_color(
  cx : Int,
  cy : Int,
  feature : @types.FeatureKind,
  size : Int,
  color : @raylib.Color
) -> Unit {
  let half = size / 2
  match feature {
    Mountain => {
      // Main peak
      let v1 = vec2(cx, cy - half)
      let v2 = vec2(cx - half, cy + half)
      let v3 = vec2(cx + half, cy + half)
      @raylib.draw_triangle(v1, v2, v3, color)
      // Snow cap
      let cap_h = half / 3
      let cap_w = half / 3
      let white_color = @raylib.Color::new(
        240, 240, 255, color.a.to_int(),
      )
      @raylib.draw_triangle(
        vec2(cx, cy - half),
        vec2(cx - cap_w, cy - half + cap_h),
        vec2(cx + cap_w, cy - half + cap_h),
        white_color,
      )
      // Secondary smaller peak
      if size > 20 {
        let sx = cx + half / 3
        let sy = cy + half / 4
        let small_h = half / 3
        let darker = @raylib.Color::new(
          120, 75, 35, color.a.to_int(),
        )
        @raylib.draw_triangle(
          vec2(sx, sy - small_h),
          vec2(sx - small_h, sy + small_h),
          vec2(sx + small_h, sy + small_h),
          darker,
        )
      }
    }
    River => {
      // Wavy river with 3 curves
      let seg = half * 2 / 3
      @raylib.draw_line_ex(
        vec2(cx - half, cy - seg / 2),
        vec2(cx - half / 3, cy + seg / 3),
        3.0,
        color,
      )
      @raylib.draw_line_ex(
        vec2(cx - half / 3, cy + seg / 3),
        vec2(cx + half / 3, cy - seg / 3),
        3.0,
        color,
      )
      @raylib.draw_line_ex(
        vec2(cx + half / 3, cy - seg / 3),
        vec2(cx + half, cy + seg / 2),
        3.0,
        color,
      )
      // Water shine dots
      if size > 20 {
        let shine = @raylib.Color::new(
          150, 200, 255, color.a.to_int(),
        )
        @raylib.draw_circle(cx - half / 4, cy + 1, 2.0, shine)
        @raylib.draw_circle(cx + half / 4, cy - 2, 2.0, shine)
      }
    }
    Forest => {
      // Tree trunk
      let trunk = @raylib.Color::new(
        100, 60, 30, color.a.to_int(),
      )
      @raylib.draw_rectangle(cx - 2, cy + half / 3, 4, half / 2, trunk)
      // Main canopy (layered circles for fullness)
      @raylib.draw_circle(cx, cy - half / 6, fi(half * 2 / 3), color)
      let inner = @raylib.Color::new(
        20, 100, 20, color.a.to_int(),
      )
      @raylib.draw_circle(
        cx - half / 4, cy - half / 3, fi(half / 3), inner,
      )
      @raylib.draw_circle(
        cx + half / 4, cy - half / 3, fi(half / 3), inner,
      )
      // Highlight
      if size > 20 {
        let light = @raylib.Color::new(
          60, 170, 60, color.a.to_int(),
        )
        @raylib.draw_circle(cx, cy - half / 2, fi(half / 4), light)
      }
    }
    Town => {
      // Main building
      @raylib.draw_rectangle(
        cx - half * 2 / 3, cy - half / 3, half * 4 / 3, half * 4 / 3, color,
      )
      // Roof (triangle)
      let roof_color = @raylib.Color::new(
        150, 25, 25, color.a.to_int(),
      )
      @raylib.draw_triangle(
        vec2(cx, cy - half),
        vec2(cx - half * 2 / 3, cy - half / 3),
        vec2(cx + half * 2 / 3, cy - half / 3),
        roof_color,
      )
      // Windows
      let win_color = @raylib.Color::new(
        255, 220, 150, color.a.to_int(),
      )
      let ww = half / 4
      @raylib.draw_rectangle(cx - ww - 2, cy, ww, ww, win_color)
      @raylib.draw_rectangle(cx + 2, cy, ww, ww, win_color)
      // Door
      let door_color = @raylib.Color::new(
        100, 60, 30, color.a.to_int(),
      )
      @raylib.draw_rectangle(
        cx - ww / 2,
        cy + half / 3,
        ww,
        half * 2 / 3 - half / 3,
        door_color,
      )
    }
    Lake => {
      // Water body
      @raylib.draw_ellipse(cx, cy, fi(half), fi(half * 2 / 3), color)
      // Shore highlight
      let shore = @raylib.Color::new(
        100, 170, 230, color.a.to_int(),
      )
      @raylib.draw_ellipse(
        cx - 2, cy - 2, fi(half * 2 / 3), fi(half / 2), shore,
      )
      // Water sparkle
      if size > 20 {
        let sparkle = @raylib.Color::new(
          200, 230, 255, color.a.to_int(),
        )
        @raylib.draw_circle(cx - half / 4, cy - half / 6, 2.0, sparkle)
      }
    }
    Desert => {
      // Sand dune shape
      let v1 = vec2(cx, cy - half)
      let v2 = vec2(cx - half, cy)
      let v3 = vec2(cx + half, cy)
      let v4 = vec2(cx, cy + half)
      @raylib.draw_triangle(v1, v2, v3, color)
      @raylib.draw_triangle(v2, v4, v3, color)
      // Dune ripple lines
      if size > 20 {
        let ripple = @raylib.Color::new(
          200, 170, 80, color.a.to_int(),
        )
        @raylib.draw_line(
          cx - half / 2, cy - half / 4, cx + half / 2, cy - half / 4, ripple,
        )
        @raylib.draw_line(
          cx - half / 3, cy + half / 4, cx + half / 3, cy + half / 4, ripple,
        )
      }
      // Cactus hint
      if size > 24 {
        let green = @raylib.Color::new(
          60, 130, 40, color.a.to_int(),
        )
        @raylib.draw_line_ex(
          vec2(cx + half / 3, cy - 2),
          vec2(cx + half / 3, cy + half / 3),
          2.0,
          green,
        )
      }
    }
    Road => {
      // Road path
      @raylib.draw_line_ex(
        vec2(cx - half, cy), vec2(cx + half, cy), 5.0, color,
      )
      // Road edges (lighter)
      let edge = @raylib.Color::new(
        180, 180, 180, color.a.to_int(),
      )
      @raylib.draw_line(cx - half, cy - 3, cx + half, cy - 3, edge)
      @raylib.draw_line(cx - half, cy + 3, cx + half, cy + 3, edge)
      // Center dashes
      let dash = @raylib.Color::new(
        220, 220, 200, color.a.to_int(),
      )
      @raylib.draw_line(cx - half / 2, cy, cx - half / 4, cy, dash)
      @raylib.draw_line(cx + half / 4, cy, cx + half / 2, cy, dash)
    }
  }
}

///|
fn draw_compass_rose(cx : Int, cy : Int) -> Unit {
  let size = 28
  let ring = @types.color_compass_ring
  let body = @types.color_compass_body
  let north_color = @types.color_compass_n
  // Outer ring - double circle
  @raylib.draw_circle_lines(cx, cy, fi(size + 6), ring)
  @raylib.draw_circle_lines(cx, cy, fi(size + 4), ring)
  // Inner circle background
  @raylib.draw_circle(cx, cy, fi(size + 2), @types.color_parchment)
  @raylib.draw_circle_lines(cx, cy, fi(size + 2), ring)
  // Cardinal direction lines (thicker)
  @raylib.draw_line_ex(
    vec2(cx, cy - size), vec2(cx, cy + size), 2.0, body,
  )
  @raylib.draw_line_ex(
    vec2(cx - size, cy), vec2(cx + size, cy), 2.0, body,
  )
  // Diagonal lines (thinner)
  let diag = size * 7 / 10
  @raylib.draw_line(cx - diag, cy - diag, cx + diag, cy + diag, body)
  @raylib.draw_line(cx + diag, cy - diag, cx - diag, cy + diag, body)
  // North arrow (red triangle pointing up)
  let arrow_w = 6
  @raylib.draw_triangle(
    vec2(cx, cy - size),
    vec2(cx - arrow_w, cy - 4),
    vec2(cx, cy),
    north_color,
  )
  @raylib.draw_triangle(
    vec2(cx, cy - size),
    vec2(cx, cy),
    vec2(cx + arrow_w, cy - 4),
    north_color,
  )
  // South arrow (brown)
  @raylib.draw_triangle(
    vec2(cx, cy + size),
    vec2(cx, cy),
    vec2(cx - arrow_w, cy + 4),
    body,
  )
  @raylib.draw_triangle(
    vec2(cx, cy + size),
    vec2(cx + arrow_w, cy + 4),
    vec2(cx, cy),
    body,
  )
  // Center dot
  @raylib.draw_circle(cx, cy, 3.0, ring)
  // Cardinal labels
  @draw.draw_text("N", cx - 5, cy - size - 20, 16, north_color)
  @draw.draw_text("S", cx - 4, cy + size + 8, 14, body)
  @draw.draw_text("W", cx - size - 16, cy - 6, 14, body)
  @draw.draw_text("E", cx + size + 6, cy - 6, 14, body)
  // Intercardinal labels (smaller)
  let ic_off = size * 6 / 10
  @draw.draw_text("NW", cx - ic_off - 16, cy - ic_off - 10, 10, ring)
  @draw.draw_text("NE", cx + ic_off + 4, cy - ic_off - 10, 10, ring)
  @draw.draw_text("SW", cx - ic_off - 16, cy + ic_off + 2, 10, ring)
  @draw.draw_text("SE", cx + ic_off + 4, cy + ic_off + 2, 10, ring)
}
