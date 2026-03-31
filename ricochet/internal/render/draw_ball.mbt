///|
/// Draw the aim indicator and preview path.
pub fn draw_aim(game : @types.Game) -> Unit {
  let level = match game.current_level {
    Some(l) => l
    None => return
  }
  let sx = ox + level.start_pos.x
  let sy = oy + level.start_pos.y
  // Draw start position marker
  @raylib.draw_circle(sx.to_int(), sy.to_int(), @types.ball_radius + 2.0, @types.color_ball_glow)
  @raylib.draw_circle(sx.to_int(), sy.to_int(), @types.ball_radius, @types.color_ball)
  // Draw preview path
  let points = game.preview_points
  if points.length() > 1 {
    for i in 0..<(points.length() - 1) {
      let p1 = points[i]
      let p2 = points[i + 1]
      let x1 = ox + p1.pos.x
      let y1 = oy + p1.pos.y
      let x2 = ox + p2.pos.x
      let y2 = oy + p2.pos.y
      // Dashed line effect: draw segments
      let dx = x2 - x1
      let dy = y2 - y1
      let dist = @types.sqrtf(dx * dx + dy * dy)
      let dash_len : Float = 8.0
      let gap_len : Float = 6.0
      let total = dash_len + gap_len
      if dist > 1.0 {
        let nx = dx / dist
        let ny = dy / dist
        let mut pos : Float = 0.0
        while pos < dist {
          let end_pos = @types.minf(pos + dash_len, dist)
          let sx1 = x1 + nx * pos
          let sy1 = y1 + ny * pos
          let sx2 = x1 + nx * end_pos
          let sy2 = y1 + ny * end_pos
          // Fade alpha based on distance in preview
          let alpha_raw : Float = 1.0 - Float::from_int(i) / Float::from_int(
              points.length(),
            )
          let alpha : Int = (alpha_raw * 100.0).to_int()
          let col = @raylib.Color::new(0, 255, 255, alpha)
          @raylib.draw_line_ex(
            @raylib.Vector2::new(sx1, sy1),
            @raylib.Vector2::new(sx2, sy2),
            1.5,
            col,
          )
          pos = pos + total
        }
      }
      // Draw bounce point marker
      if p2.is_bounce {
        @raylib.draw_circle(
          (ox + p2.pos.x).to_int(),
          (oy + p2.pos.y).to_int(),
          3.0,
          @types.color_preview,
        )
      }
    }
  }
  // Draw aim angle indicator arc
  let aim_len : Float = 30.0
  let aim_x = sx + @types.cosf(game.aim_angle) * aim_len
  let aim_y = sy + @types.sinf(game.aim_angle) * aim_len
  @raylib.draw_line_ex(
    @raylib.Vector2::new(sx, sy),
    @raylib.Vector2::new(aim_x, aim_y),
    2.0,
    @types.color_ball,
  )
}

///|
/// Draw active balls with trails.
pub fn draw_balls(game : @types.Game) -> Unit {
  for i in 0..<game.balls.length() {
    let ball = game.balls[i]
    if !(ball.active) {
      continue
    }
    // Draw trail
    for t in 0..<ball.trail.length() {
      let tp = ball.trail[t]
      let alpha_raw : Float = Float::from_int(t) / Float::from_int(
          ball.trail.length(),
        )
      let alpha : Int = (alpha_raw * 150.0).to_int()
      let size : Float = @types.ball_radius * alpha_raw * 0.8
      @raylib.draw_circle(
        (ox + tp.x).to_int(),
        (oy + tp.y).to_int(),
        size,
        @raylib.Color::new(0, 255, 255, alpha),
      )
    }
    // Draw ball glow
    @raylib.draw_circle(
      (ox + ball.pos.x).to_int(),
      (oy + ball.pos.y).to_int(),
      @types.ball_radius + 4.0,
      @types.color_ball_glow,
    )
    // Draw ball
    @raylib.draw_circle(
      (ox + ball.pos.x).to_int(),
      (oy + ball.pos.y).to_int(),
      @types.ball_radius,
      @types.color_ball,
    )
  }
}
