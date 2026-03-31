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
  // Draw parchment background for grid
  @raylib.draw_rectangle(
    @types.grid_offset_x - 10,
    @types.grid_offset_y - 10,
    @types.grid_size * @types.cell_size + 20,
    @types.grid_size * @types.cell_size + 20,
    @types.color_parchment,
  )
  @raylib.draw_rectangle_lines(
    @types.grid_offset_x - 10,
    @types.grid_offset_y - 10,
    @types.grid_size * @types.cell_size + 20,
    @types.grid_size * @types.cell_size + 20,
    @types.color_mountain,
  )
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
  // Draw hint highlights
  if game.show_hints {
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
  // Draw controls help
  @draw.draw_text(
    "H:Hint  R:Restart  Esc:Back",
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
      let v1 = vec2(cx, cy - half)
      let v2 = vec2(cx - half, cy + half)
      let v3 = vec2(cx + half, cy + half)
      @raylib.draw_triangle(v1, v2, v3, color)
    }
    River => {
      @raylib.draw_line_ex(
        vec2(cx - half, cy - half / 2),
        vec2(cx, cy + half / 2),
        3.0,
        color,
      )
      @raylib.draw_line_ex(
        vec2(cx, cy + half / 2),
        vec2(cx + half, cy - half / 2),
        3.0,
        color,
      )
    }
    Forest => {
      @raylib.draw_circle(cx, cy, fi(half), color)
      let inner = @raylib.Color::new(20, 100, 20, 255)
      @raylib.draw_circle(cx, cy - 4, fi(half - 8), inner)
    }
    Town => {
      @raylib.draw_rectangle(cx - half, cy - half, size, size, color)
      let win_color = @raylib.Color::new(255, 200, 150, 255)
      @raylib.draw_rectangle(
        cx - half / 3,
        cy - half / 3,
        half * 2 / 3,
        half * 2 / 3,
        win_color,
      )
    }
    Lake => {
      @raylib.draw_ellipse(cx, cy, fi(half), fi(half * 2 / 3), color)
    }
    Desert => {
      let v1 = vec2(cx, cy - half)
      let v2 = vec2(cx - half, cy)
      let v3 = vec2(cx + half, cy)
      let v4 = vec2(cx, cy + half)
      @raylib.draw_triangle(v1, v2, v3, color)
      @raylib.draw_triangle(v2, v4, v3, color)
    }
    Road => {
      @raylib.draw_line_ex(vec2(cx - half, cy), vec2(cx + half, cy), 4.0, color)
      @raylib.draw_circle(cx - half / 2, cy, 3.0, color)
      @raylib.draw_circle(cx + half / 2, cy, 3.0, color)
    }
  }
}

///|
fn draw_compass_rose(cx : Int, cy : Int) -> Unit {
  let size = 20
  let color = @types.color_mountain
  @raylib.draw_line(cx, cy - size, cx, cy + size, color)
  @raylib.draw_line(cx - size, cy, cx + size, cy, color)
  @draw.draw_text("N", cx - 4, cy - size - 16, 14, color)
  @draw.draw_text("S", cx - 4, cy + size + 4, 14, color)
  @draw.draw_text("W", cx - size - 14, cy - 6, 14, color)
  @draw.draw_text("E", cx + size + 4, cy - 6, 14, color)
}
