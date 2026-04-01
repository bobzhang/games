///|
fn draw_circle_frame(game : @types.Game) -> Unit {
  let cx = @types.frame_center_x.to_int()
  let cy = @types.frame_center_y.to_int()
  let r = @types.frame_radius
  // Draw frame circle outline - multiple rings for glow effect
  @raylib.draw_circle_lines(
    cx,
    cy,
    r + 2.0,
    @raylib.Color::new(60, 60, 80, 100),
  )
  @raylib.draw_circle_lines(
    cx,
    cy,
    r + 1.0,
    @raylib.Color::new(80, 80, 110, 150),
  )
  @raylib.draw_circle_lines(cx, cy, r, @types.color_frame)
  // Draw pegs
  let mouse_x = Float::from_int(@raylib.get_mouse_x())
  let mouse_y = Float::from_int(@raylib.get_mouse_y())
  for i in 0..<game.pegs.length() {
    let peg = game.pegs[i]
    let px = peg.pos.x
    let py = peg.pos.y
    let dist = @types.vec2f_dist(
      @types.vec2f(mouse_x, mouse_y),
      @types.vec2f(px, py),
    )
    let is_hovered = dist < 20.0
    let is_selected = game.selected_peg == i
    let color = if is_selected {
      @types.color_peg_selected
    } else if is_hovered {
      @types.color_peg_hover
    } else {
      @types.color_peg
    }
    let radius : Float = if is_selected {
      8.0
    } else if is_hovered {
      7.0
    } else {
      5.0
    }
    // Glow for selected/hovered
    if is_selected || is_hovered {
      @raylib.draw_circle(
        px.to_int(),
        py.to_int(),
        radius + 4.0,
        @raylib.Color::new(
          color.r.to_int(),
          color.g.to_int(),
          color.b.to_int(),
          60,
        ),
      )
    }
    @raylib.draw_circle(px.to_int(), py.to_int(), radius, color)
    // Peg number (small, subtle)
    if is_hovered {
      let num = i.to_string()
      @draw.draw_text(
        num,
        px.to_int() + 12,
        py.to_int() - 6,
        14,
        @types.color_dim_text,
      )
    }
  }
}

///|
fn draw_strings(game : @types.Game) -> Unit {
  for i in 0..<game.strings.length() {
    let s = game.strings[i]
    let p1 = game.pegs[s.peg_a].pos
    let p2 = game.pegs[s.peg_b].pos
    // Glow
    @raylib.draw_line_ex(
      @raylib.Vector2::new(p1.x, p1.y),
      @raylib.Vector2::new(p2.x, p2.y),
      4.0,
      @raylib.Color::new(0, 220, 255, 40),
    )
    // Main line
    @raylib.draw_line_ex(
      @raylib.Vector2::new(p1.x, p1.y),
      @raylib.Vector2::new(p2.x, p2.y),
      2.0,
      @types.color_string,
    )
  }
  // Preview string if peg selected
  if game.selected_peg >= 0 && game.play_state == Placing {
    let p1 = game.pegs[game.selected_peg].pos
    let mx = Float::from_int(@raylib.get_mouse_x())
    let my = Float::from_int(@raylib.get_mouse_y())
    @raylib.draw_line_ex(
      @raylib.Vector2::new(p1.x, p1.y),
      @raylib.Vector2::new(mx, my),
      2.0,
      @types.color_string_preview,
    )
  }
}

///|
fn draw_targets(game : @types.Game) -> Unit {
  let time = Float::from_int(game.frame_count) * 0.05
  for i in 0..<game.targets.length() {
    let target = game.targets[i]
    let px = target.pos.x.to_int()
    let py = target.pos.y.to_int()
    if target.hit {
      // Green hit marker
      @raylib.draw_circle(px, py, 8.0, @raylib.Color::new(60, 255, 100, 60))
      @raylib.draw_circle(px, py, 5.0, @types.color_target_hit)
      @draw.draw_text("OK", px + 8, py - 8, 12, @types.color_target_hit)
    } else {
      // Pulsing red target
      let pulse : Float = @types.sinf(time + Float::from_int(i) * 1.5) * 0.3 +
        0.7
      let radius : Float = 6.0 + pulse * 3.0
      let alpha = (pulse * 255.0).to_int()
      @raylib.draw_circle(
        px,
        py,
        radius + 4.0,
        @raylib.Color::new(255, 60, 60, alpha / 3),
      )
      @raylib.draw_circle(
        px,
        py,
        radius,
        @raylib.Color::new(255, 60, 60, alpha),
      )
      // Inner dot
      @raylib.draw_circle(px, py, 2.0, @raylib.Color::new(255, 200, 200, 255))
    }
  }
}

///|
fn draw_intersections(game : @types.Game) -> Unit {
  for i in 0..<game.intersections.length() {
    let ix = game.intersections[i]
    let px = ix.pos.x.to_int()
    let py = ix.pos.y.to_int()
    let matched = ix.matched_target >= 0
    let color = if matched {
      @raylib.Color::new(100, 255, 150, 255)
    } else {
      @types.color_intersection
    }
    // Outer glow
    @raylib.draw_circle(
      px,
      py,
      6.0,
      @raylib.Color::new(
        color.r.to_int(),
        color.g.to_int(),
        color.b.to_int(),
        60,
      ),
    )
    // Inner dot
    @raylib.draw_circle(px, py, 3.0, color)
  }
}

///|
fn draw_playing(game : @types.Game) -> Unit {
  draw_circle_frame(game)
  draw_strings(game)
  draw_intersections(game)
  draw_targets(game)
  draw_playing_ui(game)
  // Message display
  if game.message_timer > 0.0 {
    let alpha : Float = @types.minf(game.message_timer * 3.0, 1.0)
    let a = (alpha * 255.0).to_int()
    let tw = @draw.measure_text(game.message, 28)
    @draw.draw_text(
      game.message,
      (@types.screen_width - tw) / 2,
      @types.screen_height - 60,
      28,
      @raylib.Color::new(255, 255, 255, a),
    )
  }
}
