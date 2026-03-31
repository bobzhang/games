///|
fn draw_playing(game : @types.Game) -> Unit {
  draw_grid(game)
  draw_beams(game)
  draw_palette(game)
  draw_playing_ui(game)
}

///|
fn draw_grid(game : @types.Game) -> Unit {
  let grid = game.grid
  let cs = @types.cell_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  for y in 0..<grid.height {
    for x in 0..<grid.width {
      let px = ox + x * cs
      let py = oy + y * cs
      match @types.grid_get(grid, x, y) {
        Some(cell) => {
          // Cell background
          let bg = if cell.locked {
            @types.color_cell_locked
          } else if x == game.hover_x && y == game.hover_y {
            @types.color_cell_hover
          } else {
            @types.color_cell_empty
          }
          @raylib.draw_rectangle(px + 1, py + 1, cs - 2, cs - 2, bg)
          @raylib.draw_rectangle_lines(
            px, py, cs, cs, @types.color_cell_border,
          )
          // Draw component
          match cell.component {
            Some(kind) =>
              draw_component(px, py, cs, kind, cell.direction, cell.filter_color, cell.target_color, cell.received_color, cell.locked)
            None => {
              // Draw socket indicator for empty unlocked cells
              if !(cell.locked) {
                let center_x = px + cs / 2
                let center_y = py + cs / 2
                @raylib.draw_circle(
                  center_x,
                  center_y,
                  3.0,
                  @raylib.Color::new(60, 60, 80, 100),
                )
              }
            }
          }
        }
        None => ()
      }
    }
  }
}

///|
fn draw_component(
  px : Int,
  py : Int,
  cs : Int,
  kind : @types.ComponentKind,
  dir : @types.Direction,
  filter_color : @types.FilterColor?,
  target_color : @types.BeamColor?,
  received_color : @types.BeamColor?,
  locked : Bool
) -> Unit {
  let cx = px + cs / 2
  let cy = py + cs / 2
  let half = cs / 2 - 6
  let fhalf = Float::from_int(half)
  match kind {
    Source => {
      // Star shape - bright center with rays
      let sc = match target_color {
        Some(c) => @types.beam_color_to_raylib(c)
        None => @types.color_source_star
      }
      @raylib.draw_circle(cx, cy, fhalf * 0.6, sc)
      // Direction arrow
      draw_direction_arrow(cx, cy, half, dir, sc)
      if locked {
        @raylib.draw_circle(
          cx, cy, fhalf * 0.3, @raylib.Color::new(255, 255, 200, 200),
        )
      }
    }
    Mirror => {
      // Diagonal line indicating reflection surface
      let color = @types.color_mirror
      match dir {
        N | S => {
          // "/" slash mirror
          @raylib.draw_line(
            px + 8, py + cs - 8, px + cs - 8, py + 8, color,
          )
          @raylib.draw_line(
            px + 9, py + cs - 8, px + cs - 7, py + 8, color,
          )
        }
        E | W => {
          // "\" backslash mirror
          @raylib.draw_line(
            px + 8, py + 8, px + cs - 8, py + cs - 8, color,
          )
          @raylib.draw_line(
            px + 9, py + 8, px + cs - 7, py + cs - 8, color,
          )
        }
      }
      // Small rotation indicator
      if !(locked) {
        @draw.draw_text("R", px + 2, py + 2, 10, @raylib.Color::new(80, 80, 100, 120))
      }
    }
    Prism => {
      // Triangle shape
      let color = @types.color_prism
      let top_x = cx
      let top_y = py + 8
      let bl_x = px + 8
      let bl_y = py + cs - 8
      let br_x = px + cs - 8
      let br_y = py + cs - 8
      @raylib.draw_triangle_lines(
        @raylib.Vector2::new(Float::from_int(top_x), Float::from_int(top_y)),
        @raylib.Vector2::new(Float::from_int(bl_x), Float::from_int(bl_y)),
        @raylib.Vector2::new(Float::from_int(br_x), Float::from_int(br_y)),
        color,
      )
      // Inner highlight
      @raylib.draw_circle(
        cx, cy + 4, 4.0, fade_color(color, 100),
      )
    }
    Filter => {
      // Colored X shape indicating which channel is blocked
      let fc = match filter_color {
        Some(Red) => @types.color_beam_red
        Some(Green) => @types.color_beam_green
        Some(Blue) => @types.color_beam_blue
        None => @types.color_text_dim
      }
      // X shape
      @raylib.draw_line(
        px + 10, py + 10, px + cs - 10, py + cs - 10, fc,
      )
      @raylib.draw_line(
        px + cs - 10, py + 10, px + 10, py + cs - 10, fc,
      )
      @raylib.draw_line(
        px + 11, py + 10, px + cs - 9, py + cs - 10, fc,
      )
      @raylib.draw_line(
        px + cs - 9, py + 10, px + 11, py + cs - 10, fc,
      )
      // Label
      let label = match filter_color {
        Some(f) => @types.filter_color_name(f)
        None => "?"
      }
      let lw = @draw.measure_text(label, 10)
      @draw.draw_text(
        label, cx - lw / 2, py + cs - 14, 10, fade_color(fc, 180),
      )
    }
    Combiner => {
      // Circle with arrows pointing inward
      let color = @types.color_combiner
      @raylib.draw_circle_lines(cx, cy, fhalf * 0.7, color)
      @raylib.draw_circle(cx, cy, fhalf * 0.3, fade_color(color, 120))
      // Direction arrow showing output
      draw_direction_arrow(cx, cy, half - 2, dir, color)
    }
    Receiver => {
      // Target ring with target color
      let tc = match target_color {
        Some(c) => @types.beam_color_to_raylib(c)
        None => @types.color_receiver_gold
      }
      @raylib.draw_circle_lines(cx, cy, fhalf * 0.8, tc)
      @raylib.draw_circle_lines(cx, cy, fhalf * 0.5, fade_color(tc, 150))
      @raylib.draw_circle(cx, cy, fhalf * 0.25, fade_color(tc, 80))
      // Satisfaction indicator
      match (target_color, received_color) {
        (Some(target), Some(received)) =>
          if target == received {
            // Green check
            @raylib.draw_circle(
              px + cs - 10, py + 6, 6.0, @types.color_success,
            )
            @draw.draw_text(
              "ok", px + cs - 16, py + 1, 10, @raylib.Color::new(0, 0, 0, 255),
            )
          } else {
            // Red X
            @raylib.draw_circle(
              px + cs - 10, py + 6, 6.0, @types.color_failure,
            )
          }
        (Some(_), None) =>
          // No light yet
          @raylib.draw_circle(
            px + cs - 10, py + 6, 6.0, @types.color_star_empty,
          )
        _ => ()
      }
      // Target color label
      match target_color {
        Some(tc2) => {
          let name = @types.beam_color_display_name(tc2)
          let nw = @draw.measure_text(name, 9)
          @draw.draw_text(
            name, cx - nw / 2, py + cs - 12, 9, fade_color(tc, 200),
          )
        }
        None => ()
      }
    }
  }
}

///|
fn draw_direction_arrow(
  cx : Int,
  cy : Int,
  half : Int,
  dir : @types.Direction,
  color : @raylib.Color
) -> Unit {
  let h = half - 2
  match dir {
    N => {
      @raylib.draw_line(cx, cy, cx, cy - h, color)
      @raylib.draw_line(cx, cy - h, cx - 4, cy - h + 6, color)
      @raylib.draw_line(cx, cy - h, cx + 4, cy - h + 6, color)
    }
    E => {
      @raylib.draw_line(cx, cy, cx + h, cy, color)
      @raylib.draw_line(cx + h, cy, cx + h - 6, cy - 4, color)
      @raylib.draw_line(cx + h, cy, cx + h - 6, cy + 4, color)
    }
    S => {
      @raylib.draw_line(cx, cy, cx, cy + h, color)
      @raylib.draw_line(cx, cy + h, cx - 4, cy + h - 6, color)
      @raylib.draw_line(cx, cy + h, cx + 4, cy + h - 6, color)
    }
    W => {
      @raylib.draw_line(cx, cy, cx - h, cy, color)
      @raylib.draw_line(cx - h, cy, cx - h + 6, cy - 4, color)
      @raylib.draw_line(cx - h, cy, cx - h + 6, cy + 4, color)
    }
  }
}
