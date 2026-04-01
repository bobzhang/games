///|
fn space_offset_x() -> Float {
  (Float::from_int(@types.screen_width) - @types.space_width) / 2.0
}

///|
fn space_offset_y() -> Float {
  (Float::from_int(@types.screen_height) - @types.space_height) / 2.0
}

///|
fn to_screen_x(x : Float) -> Int {
  (x + space_offset_x()).to_int()
}

///|
fn to_screen_y(y : Float) -> Int {
  (y + space_offset_y()).to_int()
}

///|
fn draw_starfield(game : @types.Game) -> Unit {
  for i in 0..<game.stars.length() {
    let s = game.stars[i]
    let b = s.brightness
    let twinkle = @types.sinf(
        Float::from_int(game.frame_count) * 0.03 + Float::from_int(i) * 1.7,
      ) *
      20.0
    let bright = @types.clampf(Float::from_int(b) + twinkle, 20.0, 255.0).to_int()
    @raylib.draw_circle(
      s.x.to_int(),
      s.y.to_int(),
      s.size,
      @raylib.Color::new(bright, bright, bright + 30, 200),
    )
  }
}

///|
fn draw_space_border() -> Unit {
  let ox = space_offset_x().to_int()
  let oy = space_offset_y().to_int()
  let w = @types.space_width.to_int()
  let h = @types.space_height.to_int()
  @raylib.draw_rectangle_lines(
    ox - 1,
    oy - 1,
    w + 2,
    h + 2,
    @raylib.Color::new(40, 50, 70, 150),
  )
}

///|
fn draw_planets(level : @types.Level, frame : Int) -> Unit {
  for i in 0..<level.planets.length() {
    let p = level.planets[i]
    let sx = to_screen_x(p.pos.x)
    let sy = to_screen_y(p.pos.y)
    // Gravity influence rings
    let pulse = @types.sinf(Float::from_int(frame) * 0.02 + Float::from_int(i)) *
      5.0
    let ring1 = p.radius * 2.5 + pulse
    let ring2 = p.radius * 4.0 + pulse * 1.5
    @raylib.draw_circle_lines(
      sx,
      sy,
      ring2,
      @raylib.Color::new(220, 180, 60, 20),
    )
    @raylib.draw_circle_lines(
      sx,
      sy,
      ring1,
      @raylib.Color::new(220, 180, 60, 35),
    )
    // Planet body glow
    @raylib.draw_circle(
      sx,
      sy,
      p.radius + 4.0,
      @raylib.Color::new(220, 180, 60, 30),
    )
    // Planet body
    @raylib.draw_circle(sx, sy, p.radius, @types.color_planet)
    // Inner highlight
    @raylib.draw_circle(
      sx - (p.radius * 0.25).to_int(),
      sy - (p.radius * 0.25).to_int(),
      p.radius * 0.4,
      @raylib.Color::new(255, 230, 120, 100),
    )
  }
}

///|
fn draw_station(station : @types.Station, frame : Int) -> Unit {
  let sx = to_screen_x(station.pos.x)
  let sy = to_screen_y(station.pos.y)
  // Pulsing glow
  let pulse = @types.sinf(Float::from_int(frame) * 0.05) * 5.0
  @raylib.draw_circle(
    sx,
    sy,
    station.radius + 8.0 + pulse,
    @types.color_station_glow,
  )
  // Diamond shape using lines
  let r = station.radius.to_int()
  @raylib.draw_line(sx, sy - r, sx + r, sy, @types.color_station)
  @raylib.draw_line(sx + r, sy, sx, sy + r, @types.color_station)
  @raylib.draw_line(sx, sy + r, sx - r, sy, @types.color_station)
  @raylib.draw_line(sx - r, sy, sx, sy - r, @types.color_station)
  // Inner diamond
  let ri = r / 2
  @raylib.draw_line(sx, sy - ri, sx + ri, sy, @types.color_station)
  @raylib.draw_line(sx + ri, sy, sx, sy + ri, @types.color_station)
  @raylib.draw_line(sx, sy + ri, sx - ri, sy, @types.color_station)
  @raylib.draw_line(sx - ri, sy, sx, sy - ri, @types.color_station)
  // Label
  let label = "TARGET"
  let lw = @draw.measure_text(label, 10)
  @draw.draw_text(label, sx - lw / 2, sy + r + 5, 10, @types.color_station)
}

///|
fn draw_waypoints(waypoints : Array[@types.Waypoint], frame : Int) -> Unit {
  for i in 0..<waypoints.length() {
    let wp = waypoints[i]
    let sx = to_screen_x(wp.pos.x)
    let sy = to_screen_y(wp.pos.y)
    if wp.collected {
      @raylib.draw_circle_lines(
        sx,
        sy,
        wp.radius,
        @types.color_waypoint_collected,
      )
      let check = "OK"
      let cw = @draw.measure_text(check, 10)
      @draw.draw_text(
        check,
        sx - cw / 2,
        sy - 5,
        10,
        @types.color_waypoint_collected,
      )
    } else {
      let pulse = @types.sinf(
          Float::from_int(frame) * 0.06 + Float::from_int(i) * 2.0,
        ) *
        3.0
      @raylib.draw_circle(
        sx,
        sy,
        wp.radius + pulse,
        @raylib.Color::new(255, 200, 60, 30),
      )
      @raylib.draw_circle_lines(sx, sy, wp.radius, @types.color_waypoint)
      // Star icon in center
      let star_txt = "*"
      let sw = @draw.measure_text(star_txt, 14)
      @draw.draw_text(star_txt, sx - sw / 2, sy - 7, 14, @types.color_waypoint)
    }
  }
}

///|
fn draw_launch_indicator(
  launch_pos : @types.Vec2f,
  angle : Float,
  frame : Int,
) -> Unit {
  let sx = to_screen_x(launch_pos.x)
  let sy = to_screen_y(launch_pos.y)
  // Launch position circle
  @raylib.draw_circle(sx, sy, 6.0, @types.color_probe)
  @raylib.draw_circle_lines(sx, sy, 10.0, @types.color_probe_glow)
  // Direction arrow
  let arrow_len : Float = 40.0
  let cos_a = @types.cosf(angle)
  let sin_a = @types.sinf(angle)
  let ex = (launch_pos.x + cos_a * arrow_len + space_offset_x()).to_int()
  let ey = (launch_pos.y + sin_a * arrow_len + space_offset_y()).to_int()
  // Pulsing arrow
  let base : Float = 180.0
  let sin_val : Float = @types.sinf(Float::from_int(frame) * 0.1) * 75.0
  let pulse_alpha : Int = (base + sin_val).to_int()
  let arrow_color = @raylib.Color::new(255, 100, 60, pulse_alpha)
  @raylib.draw_line(sx, sy, ex, ey, arrow_color)
  // Arrowhead
  let head_len : Float = 10.0
  let head_angle : Float = 0.4
  let hx1 = (Float::from_int(ex) - @types.cosf(angle - head_angle) * head_len).to_int()
  let hy1 = (Float::from_int(ey) - @types.sinf(angle - head_angle) * head_len).to_int()
  let hx2 = (Float::from_int(ex) - @types.cosf(angle + head_angle) * head_len).to_int()
  let hy2 = (Float::from_int(ey) - @types.sinf(angle + head_angle) * head_len).to_int()
  @raylib.draw_line(ex, ey, hx1, hy1, arrow_color)
  @raylib.draw_line(ex, ey, hx2, hy2, arrow_color)
}

///|
fn draw_preview(preview : Array[@types.Vec2f]) -> Unit {
  for i in 0..<preview.length() {
    if i % 3 == 0 {
      let p = preview[i]
      let sx = to_screen_x(p.x)
      let sy = to_screen_y(p.y)
      let alpha = 50 - i * 50 / preview.length()
      let alpha_clamped = if alpha < 10 { 10 } else { alpha }
      @raylib.draw_circle(
        sx,
        sy,
        2.0,
        @raylib.Color::new(80, 220, 255, alpha_clamped),
      )
    }
  }
}

///|
fn draw_probe(probe : @types.Probe, frame : Int) -> Unit {
  if !probe.active {
    return
  }
  let sx = to_screen_x(probe.pos.x)
  let sy = to_screen_y(probe.pos.y)
  // Glow
  let pulse = @types.sinf(Float::from_int(frame) * 0.15) * 3.0
  @raylib.draw_circle(sx, sy, 10.0 + pulse, @types.color_probe_glow)
  // Probe body
  @raylib.draw_circle(sx, sy, 4.0, @types.color_probe)
  // Bright center
  @raylib.draw_circle(sx, sy, 2.0, @raylib.white)
}

///|
fn draw_trail(trail : Array[@types.Vec2f]) -> Unit {
  let len = trail.length()
  if len < 2 {
    return
  }
  for i in 1..<len {
    let p0 = trail[i - 1]
    let p1 = trail[i]
    let alpha = i * 120 / len
    let alpha_clamped = if alpha < 5 { 5 } else { alpha }
    let sx0 = to_screen_x(p0.x)
    let sy0 = to_screen_y(p0.y)
    let sx1 = to_screen_x(p1.x)
    let sy1 = to_screen_y(p1.y)
    @raylib.draw_line(
      sx0,
      sy0,
      sx1,
      sy1,
      @raylib.Color::new(80, 220, 255, alpha_clamped),
    )
  }
}

///|
fn draw_playing(game : @types.Game) -> Unit {
  let level = @levels.get_level(game.current_level)
  // Background
  draw_starfield(game)
  draw_space_border()
  // Space objects
  draw_planets(level, game.frame_count)
  draw_waypoints(level.waypoints, game.frame_count)
  draw_station(level.station, game.frame_count)
  // Preview (aiming mode only)
  match game.play_state {
    Aiming => {
      draw_preview(game.preview)
      draw_launch_indicator(
        level.launch_pos,
        game.launch_angle,
        game.frame_count,
      )
    }
    _ => ()
  }
  // Trail and probe
  draw_trail(game.trail)
  draw_probe(game.probe, game.frame_count)
  // HUD
  draw_play_hud(game, level)
  // Messages
  if game.message_timer > 0.0 {
    let msg_w = @draw.measure_text(game.message, 28)
    let alpha = @types.minf(game.message_timer * 255.0, 255.0).to_int()
    @draw.draw_text(
      game.message,
      (@types.screen_width - msg_w) / 2,
      @types.screen_height / 2 - 60,
      28,
      @raylib.Color::new(255, 255, 255, alpha),
    )
  }
}
