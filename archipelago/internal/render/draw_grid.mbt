///|
fn draw_playing(game : @types.Game) -> Unit {
  draw_ocean_bg(game)
  draw_grid_lines(game)
  draw_bridges(game)
  draw_bridge_preview(game)
  draw_hint_highlight(game)
  draw_islands(game)
  draw_ui(game)
}

///|
fn draw_ocean_bg(game : @types.Game) -> Unit {
  ignore(draw_ocean_art())
  let time = Float::from_int(game.frame_count) * 0.02
  // Draw subtle wave pattern
  for row in 0..<36 {
    let fy = Float::from_int(row)
    let wave = @types.sinf(time + fy * 0.3) * 4.0
    let y = (fy * 20.0 + wave).to_int()
    let alpha = 15 +
      ((@types.sinf(time * 0.5 + fy * 0.2) + 1.0) * 10.0).to_int()
    let a = if alpha > 40 { 40 } else { alpha }
    @raylib.draw_rectangle(
      0,
      y,
      @types.screen_width,
      10,
      @raylib.Color::new(40, 100, 180, a),
    )
  }
}

///|
fn draw_grid_lines(game : @types.Game) -> Unit {
  let cs = @types.cell_size_for_grid(game.grid_size)
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let gs = game.grid_size
  // Grid panel background
  let pw = gs * cs
  let ph = gs * cs
  @raylib.draw_rectangle(
    ox - 5,
    oy - 5,
    pw + 10,
    ph + 10,
    @raylib.Color::new(15, 35, 65, 200),
  )
  // Grid lines
  for i in 0..<=gs {
    let x = ox + i * cs
    @raylib.draw_line(x, oy, x, oy + gs * cs, @types.color_grid_line)
    let y = oy + i * cs
    @raylib.draw_line(ox, y, ox + gs * cs, y, @types.color_grid_line)
  }
}

///|
fn draw_bridges(game : @types.Game) -> Unit {
  let time = Float::from_int(game.frame_count) * 0.04
  for br in game.bridges {
    let ia = game.islands[br.island_a]
    let ib = game.islands[br.island_b]
    let ax = Float::from_int(@types.island_screen_x(ia, game.grid_size))
    let ay = Float::from_int(@types.island_screen_y(ia, game.grid_size))
    let bx = Float::from_int(@types.island_screen_x(ib, game.grid_size))
    let by = Float::from_int(@types.island_screen_y(ib, game.grid_size))
    // Check if both endpoints are satisfied for glow effect
    let a_satisfied = @solver.is_island_satisfied(
      game.islands,
      game.bridges,
      br.island_a,
    )
    let b_satisfied = @solver.is_island_satisfied(
      game.islands,
      game.bridges,
      br.island_b,
    )
    let both_satisfied = a_satisfied && b_satisfied
    if br.count == 1 {
      // Single bridge: draw glow underneath if both ends satisfied
      if both_satisfied {
        let glow_pulse = @types.sinf(time + ax * 0.01) * 0.3 + 0.7
        let glow_alpha = (glow_pulse * 60.0).to_int()
        @raylib.draw_line_ex(
          @raylib.Vector2::new(ax, ay),
          @raylib.Vector2::new(bx, by),
          @types.bridge_thickness + 4.0,
          @raylib.Color::new(80, 200, 100, glow_alpha),
        )
      }
      let bridge_color = if both_satisfied {
        @raylib.Color::new(210, 190, 118, 255)
      } else {
        @raylib.white
      }
      if !draw_bridge_art(ax, ay, bx, by, br.direction, bridge_color) {
        @raylib.draw_line_ex(
          @raylib.Vector2::new(ax, ay),
          @raylib.Vector2::new(bx, by),
          @types.bridge_thickness,
          if both_satisfied {
            @raylib.Color::new(160, 130, 60, 255)
          } else {
            @types.color_bridge
          },
        )
      }
    } else {
      // Double bridge - two parallel lines with enhanced gap and glow
      let gap = @types.double_bridge_gap
      match br.direction {
        Horizontal => {
          // Glow for double bridge
          if both_satisfied {
            let glow_pulse = @types.sinf(time + ax * 0.01) * 0.3 + 0.7
            let glow_alpha = (glow_pulse * 50.0).to_int()
            @raylib.draw_line_ex(
              @raylib.Vector2::new(ax, ay - gap),
              @raylib.Vector2::new(bx, by - gap),
              @types.bridge_thickness + 4.0,
              @raylib.Color::new(80, 200, 100, glow_alpha),
            )
            @raylib.draw_line_ex(
              @raylib.Vector2::new(ax, ay + gap),
              @raylib.Vector2::new(bx, by + gap),
              @types.bridge_thickness + 4.0,
              @raylib.Color::new(80, 200, 100, glow_alpha),
            )
          }
          let bridge_color = if both_satisfied {
            @raylib.Color::new(160, 130, 60, 255)
          } else {
            @types.color_bridge
          }
          let bridge_tint = if both_satisfied {
            @raylib.Color::new(210, 190, 118, 255)
          } else {
            @raylib.white
          }
          if !draw_bridge_art(
              ax,
              ay - gap,
              bx,
              by - gap,
              br.direction,
              bridge_tint,
            ) {
            @raylib.draw_line_ex(
              @raylib.Vector2::new(ax, ay - gap),
              @raylib.Vector2::new(bx, by - gap),
              @types.bridge_thickness,
              bridge_color,
            )
          }
          if !draw_bridge_art(
              ax,
              ay + gap,
              bx,
              by + gap,
              br.direction,
              bridge_tint,
            ) {
            @raylib.draw_line_ex(
              @raylib.Vector2::new(ax, ay + gap),
              @raylib.Vector2::new(bx, by + gap),
              @types.bridge_thickness,
              bridge_color,
            )
          }
          // Cross-ties for double horizontal bridges (railroad-style)
          let dist_x = @types.absf(bx - ax)
          let tie_spacing : Float = 20.0
          let tie_count = (dist_x / tie_spacing).to_int()
          if tie_count > 0 {
            let dx = (bx - ax) / Float::from_int(tie_count)
            for t = 1; t < tie_count; t = t + 1 {
              let tx = ax + Float::from_int(t) * dx
              @raylib.draw_line_ex(
                @raylib.Vector2::new(tx, ay - gap - 1.0),
                @raylib.Vector2::new(tx, ay + gap + 1.0),
                1.0,
                @raylib.Color::new(100, 70, 35, 100),
              )
            }
          }
        }
        Vertical => {
          // Glow for double bridge
          if both_satisfied {
            let glow_pulse = @types.sinf(time + ay * 0.01) * 0.3 + 0.7
            let glow_alpha = (glow_pulse * 50.0).to_int()
            @raylib.draw_line_ex(
              @raylib.Vector2::new(ax - gap, ay),
              @raylib.Vector2::new(bx - gap, by),
              @types.bridge_thickness + 4.0,
              @raylib.Color::new(80, 200, 100, glow_alpha),
            )
            @raylib.draw_line_ex(
              @raylib.Vector2::new(ax + gap, ay),
              @raylib.Vector2::new(bx + gap, by),
              @types.bridge_thickness + 4.0,
              @raylib.Color::new(80, 200, 100, glow_alpha),
            )
          }
          let bridge_color = if both_satisfied {
            @raylib.Color::new(160, 130, 60, 255)
          } else {
            @types.color_bridge
          }
          let bridge_tint = if both_satisfied {
            @raylib.Color::new(210, 190, 118, 255)
          } else {
            @raylib.white
          }
          if !draw_bridge_art(
              ax - gap,
              ay,
              bx - gap,
              by,
              br.direction,
              bridge_tint,
            ) {
            @raylib.draw_line_ex(
              @raylib.Vector2::new(ax - gap, ay),
              @raylib.Vector2::new(bx - gap, by),
              @types.bridge_thickness,
              bridge_color,
            )
          }
          if !draw_bridge_art(
              ax + gap,
              ay,
              bx + gap,
              by,
              br.direction,
              bridge_tint,
            ) {
            @raylib.draw_line_ex(
              @raylib.Vector2::new(ax + gap, ay),
              @raylib.Vector2::new(bx + gap, by),
              @types.bridge_thickness,
              bridge_color,
            )
          }
          // Cross-ties for double vertical bridges
          let dist_y = @types.absf(by - ay)
          let tie_spacing : Float = 20.0
          let tie_count = (dist_y / tie_spacing).to_int()
          if tie_count > 0 {
            let dy = (by - ay) / Float::from_int(tie_count)
            for t = 1; t < tie_count; t = t + 1 {
              let ty = ay + Float::from_int(t) * dy
              @raylib.draw_line_ex(
                @raylib.Vector2::new(ax - gap - 1.0, ty),
                @raylib.Vector2::new(ax + gap + 1.0, ty),
                1.0,
                @raylib.Color::new(100, 70, 35, 100),
              )
            }
          }
        }
      }
    }
  }
}

///|
fn draw_bridge_preview(game : @types.Game) -> Unit {
  if game.selected_island < 0 {
    return
  }
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let target = @types.find_connectable_island_at(
    game.islands,
    game.bridges,
    game.selected_island,
    game.grid_size,
    mx,
    my,
  )
  if target < 0 {
    return
  }
  let ia = game.islands[game.selected_island]
  let ib = game.islands[target]
  let ax = Float::from_int(@types.island_screen_x(ia, game.grid_size))
  let ay = Float::from_int(@types.island_screen_y(ia, game.grid_size))
  let bx = Float::from_int(@types.island_screen_x(ib, game.grid_size))
  let by = Float::from_int(@types.island_screen_y(ib, game.grid_size))
  @raylib.draw_line_ex(
    @raylib.Vector2::new(ax, ay),
    @raylib.Vector2::new(bx, by),
    2.0,
    @types.color_bridge_preview,
  )
}

///|
fn draw_hint_highlight(game : @types.Game) -> Unit {
  if game.hint_island_a < 0 || game.hint_timer <= 0.0 {
    return
  }
  let pulse = @types.sinf(Float::from_int(game.frame_count) * 0.15) * 0.3 + 0.7
  let alpha = (pulse * 200.0).to_int()
  let color = @raylib.Color::new(100, 255, 200, alpha)
  let r = @types.island_radius_for_grid(game.grid_size) + 8.0
  let ia = game.islands[game.hint_island_a]
  let ax = @types.island_screen_x(ia, game.grid_size)
  let ay = @types.island_screen_y(ia, game.grid_size)
  @raylib.draw_circle_lines(ax, ay, r, color)
  if game.hint_island_b >= 0 {
    let ib = game.islands[game.hint_island_b]
    let bx = @types.island_screen_x(ib, game.grid_size)
    let by = @types.island_screen_y(ib, game.grid_size)
    @raylib.draw_circle_lines(bx, by, r, color)
    // Draw line hint
    @raylib.draw_line_ex(
      @raylib.Vector2::new(Float::from_int(ax), Float::from_int(ay)),
      @raylib.Vector2::new(Float::from_int(bx), Float::from_int(by)),
      2.0,
      @raylib.Color::new(100, 255, 200, alpha / 2),
    )
  }
}

///|
fn draw_islands(game : @types.Game) -> Unit {
  let r = @types.island_radius_for_grid(game.grid_size)
  for i, isl in game.islands {
    let sx = @types.island_screen_x(isl, game.grid_size)
    let sy = @types.island_screen_y(isl, game.grid_size)
    let satisfied = @solver.is_island_satisfied(game.islands, game.bridges, i)
    let over = @solver.is_island_over(game.islands, game.bridges, i)
    let selected = i == game.selected_island
    // Satisfaction pulse animation (expanding green ring)
    let pulse_timer = if i < game.satisfaction_timers.length() {
      game.satisfaction_timers[i]
    } else {
      0.0
    }
    if pulse_timer > 0.0 {
      let progress : Float = 1.0 - pulse_timer // 0 -> 1 over time
      let ring_r : Float = r + 5.0 + progress * 25.0
      let ring_alpha = ((1.0 : Float) - progress) * 200.0
      @raylib.draw_circle_lines(
        sx,
        sy,
        ring_r,
        @raylib.Color::new(80, 255, 120, ring_alpha.to_int()),
      )
      // Second ring, slightly delayed
      if progress > 0.2 {
        let p2 : Float = progress - 0.2
        let r2 : Float = r + 5.0 + p2 * 25.0
        let a2 : Float = ((1.0 : Float) - p2) * 120.0
        @raylib.draw_circle_lines(
          sx,
          sy,
          r2,
          @raylib.Color::new(80, 255, 120, a2.to_int()),
        )
      }
    }
    // Island circle - border
    let border_color = if selected {
      @types.color_island_selected
    } else if over {
      @types.color_island_over
    } else if satisfied {
      @types.color_island_satisfied
    } else {
      @types.color_island_border
    }
    @raylib.draw_circle(sx, sy, r + 3.0, border_color)
    // Island circle - fill with subtle glow when satisfied
    let fill_color = if over {
      @raylib.Color::new(180, 50, 50, 255)
    } else if satisfied {
      let sat_pulse = @types.sinf(
          Float::from_int(game.frame_count) * 0.05 + Float::from_int(i) * 0.7,
        ) *
        15.0
      let g = 160 + sat_pulse.to_int()
      @raylib.Color::new(60, g, 80, 255)
    } else {
      @types.color_island
    }
    let island_tint = if over {
      @raylib.Color::new(255, 160, 160, 255)
    } else if satisfied {
      @raylib.Color::new(198, 255, 198, 255)
    } else {
      @raylib.white
    }
    if !draw_island_art(sx, sy, r, island_tint) {
      @raylib.draw_circle(sx, sy, r, fill_color)
    }
    // Inner highlight for satisfied (subtle light spot)
    if satisfied && !over {
      @raylib.draw_circle(
        sx - (r * 0.25).to_int(),
        sy - (r * 0.25).to_int(),
        r * 0.35,
        @raylib.Color::new(120, 255, 140, 40),
      )
    }
    // Selection glow
    if selected {
      let sel_pulse = @types.sinf(Float::from_int(game.frame_count) * 0.1) * 0.3 +
        0.7
      let glow_alpha = (sel_pulse * 100.0).to_int()
      @raylib.draw_circle(
        sx,
        sy,
        r + 8.0,
        @raylib.Color::new(255, 220, 100, glow_alpha),
      )
    }
    // Number
    let num = isl.required_count.to_string()
    let font_size = if game.grid_size <= 5 {
      28
    } else if game.grid_size <= 7 {
      22
    } else {
      18
    }
    let nw = @draw.measure_text(num, font_size)
    let text_color = if over {
      @raylib.Color::new(255, 200, 200, 255)
    } else {
      @types.color_number
    }
    @draw.draw_text(num, sx - nw / 2, sy - font_size / 2, font_size, text_color)
    // Bridge count indicator below number (small)
    if !satisfied && !over {
      let current = @types.count_bridges_for_island(game.bridges, i)
      if current > 0 {
        let count_txt = current.to_string() +
          "/" +
          isl.required_count.to_string()
        let cw = @draw.measure_text(count_txt, 9)
        @draw.draw_text(
          count_txt,
          sx - cw / 2,
          sy + (r * 0.6).to_int(),
          9,
          @raylib.Color::new(200, 200, 200, 150),
        )
      }
    }
  }
}
