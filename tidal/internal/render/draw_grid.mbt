///|
fn draw_grid(game : @types.Game) -> Unit {
  let grid = game.grid
  let ts : Float = Float::from_int(@types.tile_size)
  // Draw tile backgrounds
  for y in 0..<grid.height {
    for x in 0..<grid.width {
      let sx = @types.tile_screen_x(x)
      let sy = @types.tile_screen_y(y)
      let tile = @types.grid_get(grid, x, y)
      // Base tile background
      @raylib.draw_rectangle(
        sx.to_int(),
        sy.to_int(),
        @types.tile_size,
        @types.tile_size,
        @types.color_grid_bg,
      )
      // Wave amplitude visualization
      if tile.amplitude > 0.01 {
        let base_color = @types.phase_color(tile.phase)
        let alpha_val : Int = (tile.amplitude * 180.0).to_int()
        let alpha = @types.mini(alpha_val, 255)
        let wave_color = @raylib.Color::new(
          base_color.r.to_int(),
          base_color.g.to_int(),
          base_color.b.to_int(),
          alpha,
        )
        @raylib.draw_rectangle(
          sx.to_int() + 1,
          sy.to_int() + 1,
          @types.tile_size - 2,
          @types.tile_size - 2,
          wave_color,
        )
      }
      // Draw objects
      draw_tile_object(tile, sx, sy, ts, game.frame_count)
      // Grid lines
      @raylib.draw_rectangle_lines(
        sx.to_int(),
        sy.to_int(),
        @types.tile_size,
        @types.tile_size,
        @types.color_grid_line,
      )
    }
  }
}

///|
fn draw_tile_object(
  tile : @types.WaveTile,
  sx : Float,
  sy : Float,
  ts : Float,
  frame : Int
) -> Unit {
  let cx = sx + ts / 2.0
  let cy = sy + ts / 2.0
  let r : Float = ts / 2.0 - 4.0
  match tile.object {
    Wall => {
      @raylib.draw_rectangle(
        (sx + 2.0).to_int(),
        (sy + 2.0).to_int(),
        @types.tile_size - 4,
        @types.tile_size - 4,
        @types.color_wall,
      )
    }
    Target => {
      // Ring shape - green when satisfied, red when not
      let col = if tile.target_satisfied {
        @types.color_target_ok
      } else {
        @types.color_target_fail
      }
      @raylib.draw_circle_lines(cx.to_int(), cy.to_int(), r, col)
      @raylib.draw_circle_lines(cx.to_int(), cy.to_int(), r - 3.0, col)
      // Show required phase indicator if specific
      if tile.target_phase >= 0 {
        let pcol = @types.phase_color(tile.target_phase)
        @raylib.draw_circle(cx.to_int(), cy.to_int(), 4.0, pcol)
      }
    }
    Emitter(phase) => {
      // Pulsing circle
      let pulse : Float = @types.sinf(
          Float::from_int(frame) * 0.1,
        ) *
        3.0
      let ecol = @types.phase_color(phase)
      @raylib.draw_circle(cx.to_int(), cy.to_int(), r - 2.0 + pulse, ecol)
      // Inner circle darker
      let inner_col = @raylib.Color::new(
        ecol.r.to_int() / 2,
        ecol.g.to_int() / 2,
        ecol.b.to_int() / 2,
        255,
      )
      @raylib.draw_circle(cx.to_int(), cy.to_int(), r / 2.0, inner_col)
      // Phase number
      let pstr = phase.to_string()
      @draw.draw_text(
        pstr,
        (cx - 4.0).to_int(),
        (cy - 6.0).to_int(),
        14,
        @raylib.white,
      )
    }
    Reflector => {
      // Chevron shape (two lines forming a V)
      let col = @types.color_reflector
      // Draw as diamond
      @raylib.draw_line(
        (cx - r).to_int(),
        cy.to_int(),
        cx.to_int(),
        (cy - r).to_int(),
        col,
      )
      @raylib.draw_line(
        cx.to_int(),
        (cy - r).to_int(),
        (cx + r).to_int(),
        cy.to_int(),
        col,
      )
      @raylib.draw_line(
        (cx + r).to_int(),
        cy.to_int(),
        cx.to_int(),
        (cy + r).to_int(),
        col,
      )
      @raylib.draw_line(
        cx.to_int(),
        (cy + r).to_int(),
        (cx - r).to_int(),
        cy.to_int(),
        col,
      )
      // Fill
      @raylib.draw_circle(cx.to_int(), cy.to_int(), r / 2.0, col)
    }
    PhaseShifter => {
      // Rotating arrow
      let col = @types.color_phase_shifter
      let angle : Float = Float::from_int(frame) * 0.05
      let ax1 = cx + @types.cosf(angle) * r
      let ay1 = cy + @types.sinf(angle) * r
      let ax2 = cx - @types.cosf(angle) * r
      let ay2 = cy - @types.sinf(angle) * r
      @raylib.draw_line(
        ax1.to_int(),
        ay1.to_int(),
        ax2.to_int(),
        ay2.to_int(),
        col,
      )
      // Arrowhead
      let arrow_angle : Float = angle + 2.5
      let arx = ax1 + @types.cosf(arrow_angle) * 8.0
      let ary = ay1 + @types.sinf(arrow_angle) * 8.0
      @raylib.draw_line(
        ax1.to_int(),
        ay1.to_int(),
        arx.to_int(),
        ary.to_int(),
        col,
      )
      @raylib.draw_circle(cx.to_int(), cy.to_int(), 5.0, col)
    }
    Absorber => {
      // X mark
      let col = @types.color_absorber
      @raylib.draw_rectangle(
        (sx + 2.0).to_int(),
        (sy + 2.0).to_int(),
        @types.tile_size - 4,
        @types.tile_size - 4,
        col,
      )
      let dark = @raylib.Color::new(30, 30, 35, 255)
      let offset : Float = 8.0
      @raylib.draw_line(
        (sx + offset).to_int(),
        (sy + offset).to_int(),
        (sx + ts - offset).to_int(),
        (sy + ts - offset).to_int(),
        dark,
      )
      @raylib.draw_line(
        (sx + ts - offset).to_int(),
        (sy + offset).to_int(),
        (sx + offset).to_int(),
        (sy + ts - offset).to_int(),
        dark,
      )
    }
    Empty => ()
  }
}
