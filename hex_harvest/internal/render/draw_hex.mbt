///|
/// Draw a filled hexagon at (cx, cy)
fn draw_hex_filled(
  cx : Float,
  cy : Float,
  size : Float,
  color : @raylib.Color,
) -> Unit {
  let corners = @hex.hex_corners(cx, cy, size)
  // Draw as 4 triangles from center
  for i in 0..<6 {
    let j = (i + 1) % 6
    let (x1, y1) = corners[i]
    let (x2, y2) = corners[j]
    @raylib.draw_triangle(
      @raylib.Vector2::new(cx, cy),
      @raylib.Vector2::new(x1, y1),
      @raylib.Vector2::new(x2, y2),
      color,
    )
  }
}

///|
/// Draw a hex outline
fn draw_hex_outline(
  cx : Float,
  cy : Float,
  size : Float,
  color : @raylib.Color,
) -> Unit {
  let corners = @hex.hex_corners(cx, cy, size)
  for i in 0..<6 {
    let j = (i + 1) % 6
    let (x1, y1) = corners[i]
    let (x2, y2) = corners[j]
    @raylib.draw_line_ex(
      @raylib.Vector2::new(x1, y1),
      @raylib.Vector2::new(x2, y2),
      2.0,
      color,
    )
  }
}

///|
/// Draw the entire hex grid
fn draw_hex_grid(game : @types.Game) -> Unit {
  let grid = game.level.grid
  let size = Float::from_int(@types.hex_size)
  for r in 0..<grid.height {
    for c in 0..<grid.width {
      let tile = grid.tiles[r][c]
      let (cx, cy) = @hex.hex_screen_pos(c, r)
      // Choose base color based on tile kind
      let base_color : @raylib.Color = match tile.kind {
        Dirt => @types.color_dirt
        Rock => @types.color_rock
        WaterSource => @types.color_water_source
        River => @types.color_river
        Goal => @types.color_dirt
      }
      // Apply height shading
      let color = @types.tile_color_with_height(base_color, tile.height)
      // Draw filled hex
      draw_hex_filled(cx, cy, size * 0.95, color)
      // Draw height indicator (small number)
      if tile.kind != Rock {
        let h_str = tile.height.to_string()
        let h_size = 12
        let tw = @draw.measure_text(h_str, h_size)
        @draw.draw_text(
          h_str,
          cx.to_int() - tw / 2,
          cy.to_int() + (size * 0.5).to_int() - h_size,
          h_size,
          @raylib.Color::new(255, 255, 255, 100),
        )
      }
      // Draw outline - thicker for height edges
      let has_height_edge = has_adjacent_height_diff(grid, c, r)
      if has_height_edge {
        draw_hex_outline(
          cx,
          cy,
          size * 0.95,
          @raylib.Color::new(50, 40, 30, 255),
        )
        // Inner contour line for strong depth effect
        draw_hex_outline(
          cx,
          cy,
          size * 0.88,
          @raylib.Color::new(60, 50, 35, 80),
        )
      } else {
        draw_hex_outline(cx, cy, size * 0.95, @types.color_hex_outline)
      }
    }
  }
}

///|
/// Check if a tile has any neighbor with a different height
fn has_adjacent_height_diff(
  grid : @types.HexGrid,
  col : Int,
  row : Int,
) -> Bool {
  let h = grid.tiles[row][col].height
  let neighbors = @hex.valid_neighbors(col, row)
  for i in 0..<neighbors.length() {
    let (nc, nr) = neighbors[i]
    if grid.tiles[nr][nc].height != h {
      return true
    }
  }
  false
}

///|
/// Draw water overlay on watered tiles
fn draw_water_overlays(game : @types.Game) -> Unit {
  let grid = game.level.grid
  let size = Float::from_int(@types.hex_size)
  for r in 0..<grid.height {
    for c in 0..<grid.width {
      let tile = grid.tiles[r][c]
      if tile.watered {
        match tile.kind {
          WaterSource | River => () // Already colored as water
          _ => {
            let (cx, cy) = @hex.hex_screen_pos(c, r)
            // Animate newly watered tiles
            let mut alpha = 120
            for i in 0..<game.newly_watered.length() {
              if game.newly_watered[i].col == c &&
                game.newly_watered[i].row == r {
                let t = game.water_anim_timer
                alpha = (t * 200.0).to_int()
                alpha = @types.clampi(alpha, 40, 120)
              }
            }
            draw_hex_filled(
              cx,
              cy,
              size * 0.85,
              @raylib.Color::new(80, 150, 220, alpha),
            )
          }
        }
      }
    }
  }
}

///|
/// Draw channel indicators - distinct grooved trough appearance
fn draw_channels(game : @types.Game) -> Unit {
  let grid = game.level.grid
  let size = Float::from_int(@types.hex_size)
  for r in 0..<grid.height {
    for c in 0..<grid.width {
      let tile = grid.tiles[r][c]
      if tile.has_channel {
        match tile.kind {
          River => () // Already drawn as river
          _ => {
            let (cx, cy) = @hex.hex_screen_pos(c, r)
            // Draw trough background (darker inner hex)
            draw_hex_filled(
              cx,
              cy,
              size * 0.35,
              @raylib.Color::new(60, 110, 170, 100),
            )
            // Draw channel border ring
            draw_hex_outline(
              cx,
              cy,
              size * 0.38,
              @raylib.Color::new(80, 140, 200, 200),
            )
            // Draw wavy water lines across the channel
            let line_len = size * 0.25
            let wave = @types.sinf(Float::from_int(game.frame_count) * 0.06) *
              2.0
            @raylib.draw_line_ex(
              @raylib.Vector2::new(cx - line_len, cy + wave),
              @raylib.Vector2::new(cx + line_len, cy + wave),
              2.5,
              @raylib.Color::new(100, 170, 240, 200),
            )
            @raylib.draw_line_ex(
              @raylib.Vector2::new(
                cx - line_len * 0.6,
                cy - line_len * 0.4 - wave * 0.5,
              ),
              @raylib.Vector2::new(
                cx + line_len * 0.6,
                cy - line_len * 0.4 - wave * 0.5,
              ),
              2.0,
              @raylib.Color::new(100, 170, 240, 150),
            )
          }
        }
      }
    }
  }
}

///|
/// Draw goal markers
fn draw_goals(game : @types.Game) -> Unit {
  let grid = game.level.grid
  let size = Float::from_int(@types.hex_size)
  for r in 0..<grid.height {
    for c in 0..<grid.width {
      if grid.tiles[r][c].kind == Goal {
        let (cx, cy) = @hex.hex_screen_pos(c, r)
        // Pulsing glow
        let pulse = @types.sinf(Float::from_int(game.frame_count) * 0.05)
        let glow_size = size * (0.7 + pulse * 0.1)
        draw_hex_filled(cx, cy, glow_size, @types.color_goal_glow)
        // Star shape for goal
        draw_star(cx, cy, size * 0.25, @types.color_goal)
      }
    }
  }
}

///|
/// Draw a simple 4-point star
fn draw_star(
  cx : Float,
  cy : Float,
  size : Float,
  color : @raylib.Color,
) -> Unit {
  // Vertical diamond
  @raylib.draw_triangle(
    @raylib.Vector2::new(cx, cy - size),
    @raylib.Vector2::new(cx - size * 0.3, cy),
    @raylib.Vector2::new(cx + size * 0.3, cy),
    color,
  )
  @raylib.draw_triangle(
    @raylib.Vector2::new(cx, cy + size),
    @raylib.Vector2::new(cx + size * 0.3, cy),
    @raylib.Vector2::new(cx - size * 0.3, cy),
    color,
  )
  // Horizontal diamond
  @raylib.draw_triangle(
    @raylib.Vector2::new(cx - size, cy),
    @raylib.Vector2::new(cx, cy + size * 0.3),
    @raylib.Vector2::new(cx, cy - size * 0.3),
    color,
  )
  @raylib.draw_triangle(
    @raylib.Vector2::new(cx + size, cy),
    @raylib.Vector2::new(cx, cy - size * 0.3),
    @raylib.Vector2::new(cx, cy + size * 0.3),
    color,
  )
}

///|
/// Draw crops on tiles
fn draw_crops(game : @types.Game) -> Unit {
  let grid = game.level.grid
  let size = Float::from_int(@types.hex_size)
  for r in 0..<grid.height {
    for c in 0..<grid.width {
      let tile = grid.tiles[r][c]
      match tile.crop {
        Some(kind) => {
          let (cx, cy) = @hex.hex_screen_pos(c, r)
          match tile.crop_state {
            Seed => draw_crop_seed(cx, cy, size, kind)
            Growing =>
              draw_crop_growing(
                cx,
                cy,
                size,
                kind,
                tile.crop_turns,
                game.frame_count,
              )
            Mature => draw_crop_mature(cx, cy, size, kind, game.frame_count)
            Harvested => draw_crop_harvested(cx, cy, size, kind)
          }
        }
        None => ()
      }
    }
  }
}

///|
fn draw_crop_seed(
  cx : Float,
  cy : Float,
  hex_size : Float,
  kind : @types.CropKind,
) -> Unit {
  let color = @types.crop_seed_color(kind)
  let s = hex_size * 0.15
  // Seed dot with tiny sprout indicator
  @raylib.draw_circle(cx.to_int(), cy.to_int(), s, color)
  // Small upward tick to distinguish from empty
  @raylib.draw_line_ex(
    @raylib.Vector2::new(cx, cy - s * 0.3),
    @raylib.Vector2::new(cx, cy - s * 1.2),
    1.5,
    @raylib.Color::new(80, 140, 60, 120),
  )
}

///|
fn draw_crop_growing(
  cx : Float,
  cy : Float,
  hex_size : Float,
  kind : @types.CropKind,
  turns : Int,
  _frame : Int,
) -> Unit {
  let color = @types.crop_color(kind)
  let grow_time = @types.crop_grow_time(kind)
  let progress = Float::from_int(turns) / Float::from_int(grow_time)
  let s = hex_size * (0.15 + progress * 0.25)
  match kind {
    Wheat => {
      // Growing wheat stalk
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx, cy + s),
        @raylib.Vector2::new(cx, cy - s),
        2.0,
        color,
      )
      @raylib.draw_circle(cx.to_int(), (cy - s).to_int(), s * 0.4, color)
    }
    Corn => {
      // Growing corn stalk
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx, cy + s),
        @raylib.Vector2::new(cx, cy - s * 0.8),
        3.0,
        color,
      )
      // Leaves
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx, cy),
        @raylib.Vector2::new(cx + s * 0.6, cy - s * 0.3),
        2.0,
        color,
      )
    }
    Berry => {
      // Growing berry bush - distinct rounded multi-lobe shape
      @raylib.draw_circle(cx.to_int(), cy.to_int(), s * 0.5, color)
      // Small leaf buds at sides
      @raylib.draw_circle(
        (cx - s * 0.35).to_int(),
        (cy - s * 0.1).to_int(),
        s * 0.2,
        @raylib.Color::new(100, 160, 80, 180),
      )
      @raylib.draw_circle(
        (cx + s * 0.35).to_int(),
        (cy - s * 0.1).to_int(),
        s * 0.2,
        @raylib.Color::new(100, 160, 80, 180),
      )
    }
    Flower => {
      // Growing flower stem
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx, cy + s * 0.5),
        @raylib.Vector2::new(cx, cy - s * 0.5),
        2.0,
        @raylib.Color::new(80, 160, 60, 255),
      )
      @raylib.draw_circle(cx.to_int(), (cy - s * 0.5).to_int(), s * 0.3, color)
    }
  }
}

///|
fn draw_crop_mature(
  cx : Float,
  cy : Float,
  hex_size : Float,
  kind : @types.CropKind,
  frame : Int,
) -> Unit {
  let color = @types.crop_color(kind)
  let s = hex_size * 0.4
  let bob = @types.sinf(Float::from_int(frame) * 0.08) * 2.0
  match kind {
    Wheat => {
      // Full wheat with grain head
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx, cy + s * 0.5),
        @raylib.Vector2::new(cx, cy - s + bob),
        2.0,
        color,
      )
      // Grain head
      @raylib.draw_circle(cx.to_int(), (cy - s + bob).to_int(), s * 0.35, color)
      @raylib.draw_circle(
        (cx - s * 0.15).to_int(),
        (cy - s * 0.7 + bob).to_int(),
        s * 0.2,
        color,
      )
      @raylib.draw_circle(
        (cx + s * 0.15).to_int(),
        (cy - s * 0.7 + bob).to_int(),
        s * 0.2,
        color,
      )
    }
    Corn => {
      // Full corn with cob
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx, cy + s * 0.5),
        @raylib.Vector2::new(cx, cy - s + bob),
        3.0,
        color,
      )
      // Corn cob
      @raylib.draw_rectangle(
        (cx - s * 0.15).to_int(),
        (cy - s * 0.5 + bob).to_int(),
        (s * 0.3).to_int(),
        (s * 0.6).to_int(),
        @raylib.Color::new(240, 220, 60, 255),
      )
      // Leaves
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx, cy - s * 0.3 + bob),
        @raylib.Vector2::new(cx + s * 0.6, cy - s * 0.6 + bob),
        2.0,
        color,
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx, cy + bob),
        @raylib.Vector2::new(cx - s * 0.6, cy - s * 0.3 + bob),
        2.0,
        color,
      )
    }
    Berry => {
      // Berry bush with berries
      @raylib.draw_circle(cx.to_int(), cy.to_int(), s * 0.5, color)
      // Individual berries
      @raylib.draw_circle(
        (cx - s * 0.2).to_int(),
        (cy - s * 0.2 + bob * 0.5).to_int(),
        s * 0.15,
        @raylib.Color::new(200, 60, 160, 255),
      )
      @raylib.draw_circle(
        (cx + s * 0.2).to_int(),
        (cy + bob * 0.5).to_int(),
        s * 0.15,
        @raylib.Color::new(200, 60, 160, 255),
      )
      @raylib.draw_circle(
        cx.to_int(),
        (cy + s * 0.2 + bob * 0.5).to_int(),
        s * 0.15,
        @raylib.Color::new(200, 60, 160, 255),
      )
    }
    Flower => {
      // Full flower with petals
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx, cy + s * 0.5),
        @raylib.Vector2::new(cx, cy - s * 0.3 + bob),
        2.0,
        @raylib.Color::new(80, 160, 60, 255),
      )
      // Petals (5 circles around center)
      let petal_r = s * 0.18
      for i in 0..<5 {
        let angle = Float::from_int(i) * @types.pi * 2.0 / 5.0
        let px = cx + @types.cosf(angle) * s * 0.25
        let py = cy - s * 0.3 + bob + @types.sinf(angle) * s * 0.25
        @raylib.draw_circle(px.to_int(), py.to_int(), petal_r, color)
      }
      // Center
      @raylib.draw_circle(
        cx.to_int(),
        (cy - s * 0.3 + bob).to_int(),
        s * 0.12,
        @raylib.Color::new(255, 220, 50, 255),
      )
    }
  }
}

///|
fn draw_crop_harvested(
  cx : Float,
  cy : Float,
  hex_size : Float,
  _kind : @types.CropKind,
) -> Unit {
  let s = hex_size * 0.2
  // Just a stub remaining
  @raylib.draw_line_ex(
    @raylib.Vector2::new(cx, cy + s * 0.3),
    @raylib.Vector2::new(cx, cy - s * 0.3),
    2.0,
    @raylib.Color::new(120, 100, 60, 150),
  )
}
