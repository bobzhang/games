///|
fn draw_grid(game : @types.Game) -> Unit {
  let grid = game.grid
  let ts : Float = Float::from_int(@types.tile_size)
  let frame_f : Float = Float::from_int(game.frame_count)
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
      // Animated wave amplitude visualization with ripple effect
      if tile.amplitude > 0.01 {
        let base_color = @types.phase_color(tile.phase)
        // Phase color cycling: subtle hue shift over time
        let cycle : Float = @types.sinf(
          frame_f * 0.04 + Float::from_int(tile.phase) * 1.57,
        )
        let r_shift : Int = (cycle * 15.0).to_int()
        let g_shift : Int = (cycle * 10.0).to_int()
        let adj_r = @types.mini(
          @types.maxi(base_color.r.to_int() + r_shift, 0),
          255,
        )
        let adj_g = @types.mini(
          @types.maxi(base_color.g.to_int() + g_shift, 0),
          255,
        )
        let alpha_val : Int = (tile.amplitude * 180.0).to_int()
        let alpha = @types.mini(alpha_val, 255)
        let wave_color = @raylib.Color::new(
          adj_r,
          adj_g,
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
        // Animated ripple rings when simulating
        let is_sim = game.play_state == Simulating ||
          game.play_state == Stepping
        if is_sim && tile.amplitude > 0.1 {
          let cx = sx + ts / 2.0
          let cy = sy + ts / 2.0
          let ripple_phase : Float = frame_f * 0.08 +
            Float::from_int(x + y) * 0.5
          let ripple_r : Float = (ts / 2.0 - 4.0) *
            @types.absf(@types.sinf(ripple_phase))
          if ripple_r > 2.0 {
            let ripple_alpha : Int = (tile.amplitude *
            100.0 *
            @types.absf(@types.cosf(ripple_phase))).to_int()
            let ra = @types.mini(@types.maxi(ripple_alpha, 0), 255)
            let ripple_col = @raylib.Color::new(
              base_color.r.to_int(),
              base_color.g.to_int(),
              base_color.b.to_int(),
              ra,
            )
            @raylib.draw_circle_lines(
              cx.to_int(),
              cy.to_int(),
              ripple_r,
              ripple_col,
            )
          }
        }
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
  frame : Int,
) -> Unit {
  let cx = sx + ts / 2.0
  let cy = sy + ts / 2.0
  let r : Float = ts / 2.0 - 4.0
  match tile.object {
    Wall =>
      @raylib.draw_rectangle(
        (sx + 2.0).to_int(),
        (sy + 2.0).to_int(),
        @types.tile_size - 4,
        @types.tile_size - 4,
        @types.color_wall,
      )
    Target => {
      // Ring shape with pulsing animation for unsatisfied
      let col = if tile.target_satisfied {
        @types.color_target_ring_sat
      } else {
        @types.color_target_ring_unsat
      }
      let pulse_offset : Float = if tile.target_satisfied {
        0.0
      } else {
        @types.sinf(Float::from_int(frame) * 0.08) * 2.0
      }
      @raylib.draw_circle_lines(cx.to_int(), cy.to_int(), r + pulse_offset, col)
      @raylib.draw_circle_lines(
        cx.to_int(),
        cy.to_int(),
        r - 3.0 + pulse_offset,
        col,
      )
      // Amplitude bar at bottom of tile
      let bar_x = sx + 4.0
      let bar_y = sy + ts - 8.0
      let bar_w : Float = ts - 8.0
      let bar_h : Float = 4.0
      // Bar background
      @raylib.draw_rectangle(
        bar_x.to_int(),
        bar_y.to_int(),
        bar_w.to_int(),
        bar_h.to_int(),
        @types.color_target_amp_bar_bg,
      )
      // Valid range indicator
      let range_x = bar_x + tile.target_min * bar_w
      let range_w : Float = (tile.target_max - tile.target_min) * bar_w
      @raylib.draw_rectangle(
        range_x.to_int(),
        bar_y.to_int(),
        @types.maxi(range_w.to_int(), 1),
        bar_h.to_int(),
        @types.color_target_amp_bar_range,
      )
      // Current amplitude marker
      let amp_x : Float = bar_x +
        @types.clampf(tile.amplitude, 0.0, 1.0) * bar_w
      let marker_col = if tile.target_satisfied {
        @types.color_target_ring_sat
      } else {
        @types.color_target_amp_bar_fill
      }
      @raylib.draw_rectangle(
        (amp_x - 1.0).to_int(),
        (bar_y - 1.0).to_int(),
        3,
        (bar_h + 2.0).to_int(),
        marker_col,
      )
      // Show required phase indicator if specific
      if tile.target_phase >= 0 {
        let pcol = @types.phase_color(tile.target_phase)
        // Phase match: filled circle if matching, ring if not
        let phase_ok = tile.target_phase == tile.phase
        if phase_ok && tile.amplitude > 0.01 {
          @raylib.draw_circle(cx.to_int(), cy.to_int(), 5.0, pcol)
        } else {
          @raylib.draw_circle_lines(cx.to_int(), cy.to_int(), 5.0, pcol)
        }
      }
      // Checkmark overlay when satisfied
      if tile.target_satisfied {
        let check_col = @raylib.Color::new(50, 255, 100, 180)
        // Simple checkmark drawn as two lines
        @raylib.draw_line(
          (cx - 6.0).to_int(),
          cy.to_int(),
          (cx - 2.0).to_int(),
          (cy + 5.0).to_int(),
          check_col,
        )
        @raylib.draw_line(
          (cx - 2.0).to_int(),
          (cy + 5.0).to_int(),
          (cx + 7.0).to_int(),
          (cy - 5.0).to_int(),
          check_col,
        )
      }
    }
    Emitter(phase) => {
      // Pulsing circle
      let pulse : Float = @types.sinf(Float::from_int(frame) * 0.1) * 3.0
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
