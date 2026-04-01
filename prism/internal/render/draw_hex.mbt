///|
fn draw_playing(game : @types.Game) -> Unit {
  draw_hex_grid(game)
  draw_beams(game)
  draw_palette(game)
  draw_playing_ui(game)
}

///|
fn draw_hex_grid(game : @types.Game) -> Unit {
  let grid = game.grid
  let coords = @types.grid_all_coords(grid)
  for i in 0..<coords.length() {
    let (q, r) = coords[i]
    let cx = @types.hex_to_pixel_x(q, r)
    let cy = @types.hex_to_pixel_y(q, r)
    match @types.grid_get(grid, q, r) {
      Some(cell) => {
        // Cell background
        let bg = if cell.locked {
          @types.color_cell_locked
        } else if game.hover_valid && q == game.hover_q && r == game.hover_r {
          @types.color_cell_hover
        } else {
          @types.color_cell_empty
        }
        draw_hex_filled(cx, cy, Float::from_int(@types.hex_size) - 2.0, bg)
        draw_hex_outline(
          cx,
          cy,
          Float::from_int(@types.hex_size),
          @types.color_cell_border,
        )
        // Draw component
        match cell.component {
          Some(kind) =>
            draw_component(
              cx,
              cy,
              kind,
              cell.direction,
              cell.filter_color,
              cell.crystal_face,
              cell.target_color,
              cell.received_color,
              cell.locked,
            )
          None =>
            if !cell.locked {
              // Small socket indicator
              @raylib.draw_circle(
                cx.to_int(),
                cy.to_int(),
                2.0,
                @raylib.Color::new(60, 55, 80, 100),
              )
            }
        }
      }
      None => ()
    }
  }
}

///|
fn draw_hex_filled(cx : Float, cy : Float, size : Float, color : @raylib.Color) -> Unit {
  // Flat-top hexagon: vertices at angles 0, 60, 120, 180, 240, 300 degrees
  for i in 0..<6 {
    let a1 = Float::from_int(i) * @types.pi / 3.0
    let a2 = Float::from_int(i + 1) * @types.pi / 3.0
    let x1 = cx + size * @types.cosf(a1)
    let y1 = cy + size * @types.sinf(a1)
    let x2 = cx + size * @types.cosf(a2)
    let y2 = cy + size * @types.sinf(a2)
    @raylib.draw_triangle(
      @raylib.Vector2::new(cx, cy),
      @raylib.Vector2::new(x1, y1),
      @raylib.Vector2::new(x2, y2),
      color,
    )
  }
}

///|
fn draw_hex_outline(
  cx : Float,
  cy : Float,
  size : Float,
  color : @raylib.Color,
) -> Unit {
  for i in 0..<6 {
    let a1 = Float::from_int(i) * @types.pi / 3.0
    let a2 = Float::from_int(i + 1) * @types.pi / 3.0
    let x1 = cx + size * @types.cosf(a1)
    let y1 = cy + size * @types.sinf(a1)
    let x2 = cx + size * @types.cosf(a2)
    let y2 = cy + size * @types.sinf(a2)
    @raylib.draw_line(x1.to_int(), y1.to_int(), x2.to_int(), y2.to_int(), color)
  }
}

///|
fn draw_component(
  cx : Float,
  cy : Float,
  kind : @types.ComponentKind,
  dir : @types.HexDir,
  filter_color : @types.FilterColor?,
  crystal_face : @types.CrystalFace?,
  target_color : @types.BeamColor?,
  received_color : @types.BeamColor?,
  locked : Bool,
) -> Unit {
  let icx = cx.to_int()
  let icy = cy.to_int()
  let half = Float::from_int(@types.hex_size) * 0.6
  match kind {
    Source => {
      let sc = match target_color {
        Some(c) => @types.beam_color_to_raylib(c)
        None => @types.color_source_star
      }
      @raylib.draw_circle(icx, icy, half * 0.5, sc)
      draw_hex_direction_arrow(cx, cy, half, dir, sc)
      if locked {
        @raylib.draw_circle(
          icx,
          icy,
          half * 0.25,
          @raylib.Color::new(255, 255, 200, 200),
        )
      }
    }
    Crystal => {
      let color = @types.color_crystal
      // Diamond/rhombus shape for crystal
      let d = half * 0.7
      let angle = hex_dir_to_angle(dir)
      let dx1 = @types.cosf(angle) * d
      let dy1 = @types.sinf(angle) * d
      let dx2 = @types.cosf(angle + @types.pi / 2.0) * d * 0.4
      let dy2 = @types.sinf(angle + @types.pi / 2.0) * d * 0.4
      @raylib.draw_line(
        (cx + dx1).to_int(),
        (cy + dy1).to_int(),
        (cx + dx2).to_int(),
        (cy + dy2).to_int(),
        color,
      )
      @raylib.draw_line(
        (cx + dx2).to_int(),
        (cy + dy2).to_int(),
        (cx - dx1).to_int(),
        (cy - dy1).to_int(),
        color,
      )
      @raylib.draw_line(
        (cx - dx1).to_int(),
        (cy - dy1).to_int(),
        (cx - dx2).to_int(),
        (cy - dy2).to_int(),
        color,
      )
      @raylib.draw_line(
        (cx - dx2).to_int(),
        (cy - dy2).to_int(),
        (cx + dx1).to_int(),
        (cy + dy1).to_int(),
        color,
      )
      // Face indicator
      match crystal_face {
        Some(Left60) =>
          @draw.draw_text("L", icx - 4, icy - 5, 10, fade_color(color, 180))
        Some(Right60) =>
          @draw.draw_text("R", icx - 4, icy - 5, 10, fade_color(color, 180))
        None => ()
      }
      if !locked {
        @draw.draw_text(
          "R",
          icx - Float::from_int(@types.hex_size * 2 / 5).to_int(),
          icy - Float::from_int(@types.hex_size * 2 / 5).to_int(),
          9,
          @raylib.Color::new(80, 70, 110, 100),
        )
      }
    }
    Filter => {
      let fc = match filter_color {
        Some(Red) => @types.color_beam_red
        Some(Green) => @types.color_beam_green
        Some(Blue) => @types.color_beam_blue
        None => @types.color_text_dim
      }
      // Circular filter with color tint
      @raylib.draw_circle_lines(icx, icy, half * 0.6, fc)
      @raylib.draw_circle(icx, icy, half * 0.35, fade_color(fc, 80))
      // Label
      let label = match filter_color {
        Some(f) => @types.filter_color_name(f)
        None => "?"
      }
      let lw = @draw.measure_text(label, 10)
      @draw.draw_text(
        label,
        icx - lw / 2,
        icy + (half * 0.45).to_int(),
        10,
        fade_color(fc, 200),
      )
    }
    Mirror => {
      let color = @types.color_mirror
      // Line across the hex perpendicular to facing direction
      let angle = hex_dir_to_angle(dir)
      let perp = angle + @types.pi / 2.0
      let len = half * 0.8
      let x1 = cx + @types.cosf(perp) * len
      let y1 = cy + @types.sinf(perp) * len
      let x2 = cx - @types.cosf(perp) * len
      let y2 = cy - @types.sinf(perp) * len
      @raylib.draw_line(x1.to_int(), y1.to_int(), x2.to_int(), y2.to_int(), color)
      @raylib.draw_line(
        (x1 + 1.0).to_int(),
        y1.to_int(),
        (x2 + 1.0).to_int(),
        y2.to_int(),
        color,
      )
      // Normal arrow
      let na = half * 0.35
      let nx = cx + @types.cosf(angle) * na
      let ny = cy + @types.sinf(angle) * na
      @raylib.draw_line(icx, icy, nx.to_int(), ny.to_int(), fade_color(color, 150))
      if !locked {
        @draw.draw_text(
          "R",
          icx - Float::from_int(@types.hex_size * 2 / 5).to_int(),
          icy - Float::from_int(@types.hex_size * 2 / 5).to_int(),
          9,
          @raylib.Color::new(80, 70, 110, 100),
        )
      }
    }
    Target => {
      let tc = match target_color {
        Some(c) => @types.beam_color_to_raylib(c)
        None => @types.color_target_gold
      }
      // Concentric rings
      @raylib.draw_circle_lines(icx, icy, half * 0.7, tc)
      @raylib.draw_circle_lines(icx, icy, half * 0.45, fade_color(tc, 160))
      @raylib.draw_circle(icx, icy, half * 0.2, fade_color(tc, 90))
      // Satisfaction indicator
      match (target_color, received_color) {
        (Some(target), Some(received)) =>
          if target == received {
            let sx = icx + (half * 0.6).to_int()
            let sy = icy - (half * 0.6).to_int()
            @raylib.draw_circle(sx, sy, 5.0, @types.color_success)
          } else {
            let sx = icx + (half * 0.6).to_int()
            let sy = icy - (half * 0.6).to_int()
            @raylib.draw_circle(sx, sy, 5.0, @types.color_failure)
          }
        (Some(_), None) => {
          let sx = icx + (half * 0.6).to_int()
          let sy = icy - (half * 0.6).to_int()
          @raylib.draw_circle(sx, sy, 5.0, @types.color_star_empty)
        }
        _ => ()
      }
      // Target color label
      match target_color {
        Some(tc2) => {
          let name = @types.beam_color_display_name(tc2)
          let nw = @draw.measure_text(name, 9)
          @draw.draw_text(
            name,
            icx - nw / 2,
            icy + (half * 0.5).to_int(),
            9,
            fade_color(tc, 200),
          )
        }
        None => ()
      }
    }
  }
}

///|
fn draw_hex_direction_arrow(
  cx : Float,
  cy : Float,
  half : Float,
  dir : @types.HexDir,
  color : @raylib.Color,
) -> Unit {
  let angle = hex_dir_to_angle(dir)
  let tip_x = cx + @types.cosf(angle) * half * 0.85
  let tip_y = cy + @types.sinf(angle) * half * 0.85
  @raylib.draw_line(
    cx.to_int(),
    cy.to_int(),
    tip_x.to_int(),
    tip_y.to_int(),
    color,
  )
  // Arrowhead
  let a1 = angle + 2.6
  let a2 = angle - 2.6
  let head_len = half * 0.3
  let h1x = tip_x + @types.cosf(a1) * head_len
  let h1y = tip_y + @types.sinf(a1) * head_len
  let h2x = tip_x + @types.cosf(a2) * head_len
  let h2y = tip_y + @types.sinf(a2) * head_len
  @raylib.draw_line(
    tip_x.to_int(),
    tip_y.to_int(),
    h1x.to_int(),
    h1y.to_int(),
    color,
  )
  @raylib.draw_line(
    tip_x.to_int(),
    tip_y.to_int(),
    h2x.to_int(),
    h2y.to_int(),
    color,
  )
}

///|
fn hex_dir_to_angle(dir : @types.HexDir) -> Float {
  match dir {
    E => 0.0
    NE => -@types.pi / 3.0
    NW => -2.0 * @types.pi / 3.0
    W => @types.pi
    SW => 2.0 * @types.pi / 3.0
    SE => @types.pi / 3.0
  }
}

///|
fn fade_color(c : @raylib.Color, alpha : Int) -> @raylib.Color {
  @raylib.Color::new(c.r.to_int(), c.g.to_int(), c.b.to_int(), alpha)
}
