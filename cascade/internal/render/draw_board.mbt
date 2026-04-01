///|
fn draw_board(game : @types.Game) -> Unit {
  // Draw socket grid
  draw_grid()
  // Draw dominoes
  let display_tick = if game.replay_mode {
    game.replay_tick
  } else {
    game.current_tick
  }
  for i in 0..<game.dominoes.length() {
    draw_domino(game.dominoes[i], display_tick)
  }
  // Draw chain reaction sequence numbers during Running/Complete/Stepping
  if game.play_state != Editing {
    draw_topple_sequence(game, display_tick)
  }
  // Draw hover preview in edit mode
  if game.play_state == Editing && game.show_hover {
    draw_hover_preview(game)
  }
}

///|
fn draw_topple_sequence(game : @types.Game, display_tick : Int) -> Unit {
  // Show numbered sequence badges next to each domino that has toppled,
  // indicating the order in which they fell.
  let events = game.events
  if events.length() == 0 {
    return
  }
  let mut order = 0
  for i in 0..<events.length() {
    let evt = events[i]
    // Only show events up to the current display tick
    if evt.tick > display_tick {
      continue
    }
    order += 1
    let sx = @types.socket_to_screen_x(evt.pos.x)
    let sy = @types.socket_to_screen_y(evt.pos.y)
    // Position the badge offset from the domino center
    let badge_x = sx + 14
    let badge_y = sy - 16
    // Background circle for the badge
    let alpha = if evt.tick == display_tick { 240 } else { 180 }
    @raylib.draw_circle(badge_x, badge_y, 9.0, @raylib.Color::new(20, 20, 40, alpha))
    @raylib.draw_circle_lines(badge_x, badge_y, 9.0, @raylib.Color::new(100, 180, 255, alpha))
    // Draw the sequence number
    let num_text = order.to_string()
    let font_size = if order < 10 { 12 } else { 10 }
    let text_w = @raylib.measure_text(num_text, font_size)
    @draw.draw_text(
      num_text,
      badge_x - text_w / 2,
      badge_y - font_size / 2,
      font_size,
      @raylib.Color::new(100, 200, 255, alpha),
    )
  }
}

///|
fn draw_grid() -> Unit {
  for gy in 0..<@types.grid_rows {
    for gx in 0..<@types.grid_cols {
      let sx = @types.socket_to_screen_x(gx)
      let sy = @types.socket_to_screen_y(gy)
      @raylib.draw_circle(sx, sy, 3.0, @types.color_grid_dot)
    }
  }
}

///|
fn ease_out_bounce(t : Float) -> Float {
  // Smooth ease-out with slight bounce at the end
  if t < 0.7 {
    let normalized = t / 0.7
    normalized * normalized * (3.0 - 2.0 * normalized)
  } else if t < 0.9 {
    let normalized = (t - 0.7) / 0.2
    1.0 - (1.0 - normalized) * 0.08
  } else {
    1.0
  }
}

///|
fn draw_domino(d : @types.Domino, display_tick : Int) -> Unit {
  let sx = Float::from_int(@types.socket_to_screen_x(d.pos.x))
  let sy = Float::from_int(@types.socket_to_screen_y(d.pos.y))
  let angle = @types.orientation_angle(d.orientation)
  // Determine color based on kind and state
  let base_color = if d.is_starter {
    @types.color_starter
  } else {
    @types.kind_color(d.kind)
  }
  let color = match d.state {
    Standing => base_color
    Toppling => {
      if d.topple_tick <= display_tick {
        // Blend from base color toward toppling color based on progress
        let t = @types.clampf(d.anim_progress, 0.0, 1.0)
        let r = @types.lerpf(
          Float::from_int(base_color.r.to_int()),
          Float::from_int(@types.color_toppling.r.to_int()),
          t,
        )
        let g = @types.lerpf(
          Float::from_int(base_color.g.to_int()),
          Float::from_int(@types.color_toppling.g.to_int()),
          t,
        )
        let b = @types.lerpf(
          Float::from_int(base_color.b.to_int()),
          Float::from_int(@types.color_toppling.b.to_int()),
          t,
        )
        @raylib.Color::new(r.to_int(), g.to_int(), b.to_int(), 255)
      } else {
        base_color
      }
    }
    Fallen => @types.color_fallen
  }
  // Calculate tilt with smooth easing and slight height compression
  let tilt : Float = match d.state {
    Standing => 0.0
    Toppling => {
      if d.topple_tick <= display_tick {
        let t = @types.clampf(d.anim_progress, 0.0, 1.0)
        let eased = ease_out_bounce(t)
        eased * 85.0
      } else {
        0.0
      }
    }
    Fallen => 85.0
  }
  let final_angle = angle + tilt
  // Compute height scale for perspective effect during topple
  let height_scale : Float = match d.state {
    Standing => 1.0
    Toppling => {
      if d.topple_tick <= display_tick {
        let t = @types.clampf(d.anim_progress, 0.0, 1.0)
        // Shrink height slightly as domino falls (perspective)
        1.0 - t * 0.15
      } else {
        1.0
      }
    }
    Fallen => 0.85
  }
  // Draw target glow - pulsing ring
  if d.is_target {
    if d.state == Fallen {
      // Success glow
      @raylib.draw_circle_v(
        @raylib.Vector2::new(sx, sy),
        18.0,
        @raylib.Color::new(40, 220, 80, 50),
      )
      @raylib.draw_circle_v(
        @raylib.Vector2::new(sx, sy),
        12.0,
        @raylib.Color::new(40, 220, 80, 40),
      )
    } else {
      // Pulsing target ring
      let pulse_v = Float::from_int(display_tick % 60)
      let pulse : Float = @types.absf(pulse_v / 30.0 - 1.0)
      let glow_r : Float = 16.0 + pulse * 6.0
      let glow_a_f : Float = 60.0 + pulse * 60.0
      @raylib.draw_circle_v(
        @raylib.Vector2::new(sx, sy),
        glow_r,
        @raylib.Color::new(40, 220, 80, glow_a_f.to_int()),
      )
    }
  }
  // Draw starter highlight
  if d.is_starter {
    let pulse_v = Float::from_int(display_tick % 60)
    let pulse : Float = @types.absf(pulse_v / 30.0 - 1.0)
    let pa : Float = 40.0 + pulse * 60.0
    let starter_glow = @raylib.Color::new(255, 180, 0, pa.to_int())
    @raylib.draw_circle_v(
      @raylib.Vector2::new(sx, sy),
      22.0,
      starter_glow,
    )
  }
  // Draw shadow beneath domino (offset by tilt)
  if d.state != Standing {
    let shadow_offset_x : Float = tilt * 0.08
    let shadow_offset_y : Float = tilt * 0.05
    let shadow_hw = @types.domino_width / 2.0
    let shadow_hh = @types.domino_height * height_scale / 2.0
    let shadow_rec = @raylib.Rectangle::new(
      sx - shadow_hw + shadow_offset_x,
      sy - shadow_hh + shadow_offset_y + 2.0,
      @types.domino_width,
      @types.domino_height * height_scale,
    )
    @raylib.draw_rectangle_pro(
      shadow_rec,
      @raylib.Vector2::new(shadow_hw, shadow_hh),
      final_angle,
      @raylib.Color::new(0, 0, 0, 40),
    )
  }
  // Draw domino body as rotated rectangle with height scale
  let hw = @types.domino_width / 2.0
  let hh = @types.domino_height * height_scale / 2.0
  let rec = @raylib.Rectangle::new(
    sx - hw, sy - hh, @types.domino_width, @types.domino_height * height_scale,
  )
  @raylib.draw_rectangle_pro(
    rec,
    @raylib.Vector2::new(hw, hh),
    final_angle,
    color,
  )
  // Draw direction indicator for standing dominoes
  if d.state == Standing {
    let dx = Float::from_int(@types.orientation_dx(d.orientation))
    let dy = Float::from_int(@types.orientation_dy(d.orientation))
    let arrow_len : Float = 12.0
    let ax = sx + dx * arrow_len
    let ay = sy + dy * arrow_len
    // Arrowhead triangle
    @raylib.draw_circle_v(
      @raylib.Vector2::new(ax, ay),
      3.5,
      @raylib.Color::new(0, 0, 0, 160),
    )
    @raylib.draw_circle_v(
      @raylib.Vector2::new(ax, ay),
      2.5,
      @raylib.Color::new(255, 255, 255, 120),
    )
  }
  // Draw kind indicator (larger, clearer)
  match d.kind {
    Heavy => {
      // Solid filled circle with ring
      @raylib.draw_circle_v(
        @raylib.Vector2::new(sx, sy),
        5.0,
        @raylib.Color::new(0, 0, 0, 100),
      )
      @raylib.draw_circle_v(
        @raylib.Vector2::new(sx, sy),
        3.5,
        @raylib.Color::new(0, 0, 0, 160),
      )
    }
    Splitter => {
      // Perpendicular split indicator (two arrows)
      @raylib.draw_line(
        sx.to_int() - 5,
        sy.to_int(),
        sx.to_int() + 5,
        sy.to_int(),
        @raylib.Color::new(0, 0, 0, 200),
      )
      @raylib.draw_line(
        sx.to_int() - 5,
        sy.to_int() - 1,
        sx.to_int() + 5,
        sy.to_int() - 1,
        @raylib.Color::new(0, 0, 0, 120),
      )
    }
    Delay => {
      // Clock-like indicator
      @raylib.draw_circle_lines(
        sx.to_int(),
        sy.to_int(),
        5.0,
        @raylib.Color::new(0, 0, 0, 200),
      )
      // Clock hands
      @raylib.draw_line(
        sx.to_int(),
        sy.to_int(),
        sx.to_int(),
        sy.to_int() - 3,
        @raylib.Color::new(0, 0, 0, 200),
      )
      @raylib.draw_line(
        sx.to_int(),
        sy.to_int(),
        sx.to_int() + 2,
        sy.to_int(),
        @raylib.Color::new(0, 0, 0, 200),
      )
    }
    _ => ()
  }
}

///|
fn draw_hover_preview(game : @types.Game) -> Unit {
  let gx = game.hover_pos.x
  let gy = game.hover_pos.y
  if !@types.in_grid(gx, gy) {
    return
  }
  let sx = Float::from_int(@types.socket_to_screen_x(gx))
  let sy = Float::from_int(@types.socket_to_screen_y(gy))
  // Check if socket is occupied
  let occupied = @types.find_domino_at(game.dominoes, game.hover_pos) >= 0
  if occupied {
    @raylib.draw_circle_v(
      @raylib.Vector2::new(sx, sy),
      16.0,
      @raylib.Color::new(255, 48, 48, 64),
    )
    return
  }
  // Ghost preview of domino to be placed
  let base_color = @types.kind_color(game.selected_kind)
  let ghost_color = @raylib.Color::new(
    base_color.r.to_int(),
    base_color.g.to_int(),
    base_color.b.to_int(),
    96,
  )
  let angle = @types.orientation_angle(game.hover_orientation)
  let hw = @types.domino_width / 2.0
  let hh = @types.domino_height / 2.0
  let rec = @raylib.Rectangle::new(
    sx - hw, sy - hh, @types.domino_width, @types.domino_height,
  )
  @raylib.draw_rectangle_pro(
    rec,
    @raylib.Vector2::new(hw, hh),
    angle,
    ghost_color,
  )
  // Socket highlight
  @raylib.draw_circle_v(
    @raylib.Vector2::new(sx, sy),
    16.0,
    @types.color_socket_hover,
  )
}
