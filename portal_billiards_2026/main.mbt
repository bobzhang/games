///|
/// Screen width in pixels.
let sw : Int = 1280

///|
/// Screen height in pixels.
let sh : Int = 820

///|
/// Left edge of the billiard table in pixels.
let table_x : Int = 90

///|
/// Top edge of the billiard table in pixels.
let table_y : Int = 120

///|
/// Width of the billiard table in pixels.
let table_w : Int = 1100

///|
/// Height of the billiard table in pixels.
let table_h : Int = 620

///|
/// Radius of each billiard ball in pixels.
let ball_r : Float = 15.0

///|
/// Radius of each portal circle in pixels.
let portal_r : Float = 30.0

///|
/// Maximum number of balls in the simulation pool (cue ball + target balls).
let max_balls : Int = 12

///|
/// A billiard ball with position, velocity, active state, identity, and portal cooldown.
struct Ball {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut active : Bool
  id : Int
  mut portal_cd : Float
}

///|
/// Clamps a float to the inclusive `[lo, hi]` range.
fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
/// Returns true if point `(px, py)` lies within the axis-aligned rectangle at `(rx, ry)` with size `(rw, rh)`.
fn inside_rect(
  px : Float,
  py : Float,
  rx : Int,
  ry : Int,
  rw : Int,
  rh : Int,
) -> Bool {
  px >= Float::from_int(rx) &&
  px <= Float::from_int(rx + rw) &&
  py >= Float::from_int(ry) &&
  py <= Float::from_int(ry + rh)
}

///|
/// Writes a new ball entry at index `i` with the given position, active flag, and id; velocities and portal cooldown reset to zero.
fn set_ball(
  balls : Array[Ball],
  i : Int,
  x : Float,
  y : Float,
  active : Bool,
  id : Int,
) -> Unit {
  balls[i] = { x, y, vx: 0.0, vy: 0.0, active, id, portal_cd: 0.0 }
}

///|
/// Deactivates all balls in the pool by resetting each to its default inactive state.
fn clear_balls(balls : Array[Ball]) -> Unit {
  for i in 0..<balls.length() {
    set_ball(balls, i, 0.0, 0.0, false, i)
  }
}

///|
/// Returns the X pixel coordinate where the cue ball spawns at the start of a level.
fn cue_spawn_x() -> Float {
  Float::from_int(table_x + 230)
}

///|
/// Returns the Y pixel coordinate where the cue ball spawns at the start of a level.
fn cue_spawn_y() -> Float {
  Float::from_int(table_y + table_h / 2)
}

///|
/// Clears all balls, places the cue ball, arranges target balls in a triangle rack sized for the given level, and returns the shot allowance.
fn reset_level(level : Int, balls : Array[Ball]) -> Int {
  clear_balls(balls)

  let cx = cue_spawn_x()
  let cy = cue_spawn_y()
  set_ball(balls, 0, cx, cy, true, 0)

  let mut idx = 1
  let base_x = Float::from_int(table_x + table_w - 270)
  let base_y = Float::from_int(table_y + table_h / 2)
  let row_gap = ball_r * 1.95
  let col_gap = ball_r * 1.78

  let rows = if level == 1 { 3 } else if level == 2 { 4 } else { 5 }

  for row in 0..<rows {
    let n = row + 1
    let x = base_x + Float::from_int(row) * col_gap
    let mut y = base_y - Float::from_int(n - 1) * row_gap * 0.5
    for _j in 0..<n {
      if idx < balls.length() {
        set_ball(balls, idx, x, y, true, idx)
        idx = idx + 1
      }
      y = y + row_gap
    }
  }

  if level == 1 {
    9
  } else if level == 2 {
    10
  } else {
    11
  }
}

///|
/// Returns true when every non-cue ball (index 1 onward) has been pocketed.
fn all_targets_cleared(balls : Array[Ball]) -> Bool {
  let mut clear = true
  for i in 1..<balls.length() {
    if balls[i].active {
      clear = false
    }
  }
  clear
}

///|
/// Returns true if any active ball has speed squared above 64, indicating the table is still in motion.
fn moving_any(balls : Array[Ball]) -> Bool {
  let mut moving = false
  for ball in balls {
    if ball.active {
      let s2 = ball.vx * ball.vx + ball.vy * ball.vy
      if s2 > 64.0 {
        moving = true
      }
    }
  }
  moving
}

///|
/// Returns the X pixel coordinate of pocket `i` (0-2 top row, 3-5 bottom row).
fn pocket_x(i : Int) -> Float {
  if i == 0 {
    Float::from_int(table_x + 8)
  } else if i == 1 {
    Float::from_int(table_x + table_w / 2)
  } else if i == 2 {
    Float::from_int(table_x + table_w - 8)
  } else if i == 3 {
    Float::from_int(table_x + 8)
  } else if i == 4 {
    Float::from_int(table_x + table_w / 2)
  } else {
    Float::from_int(table_x + table_w - 8)
  }
}

///|
/// Returns the Y pixel coordinate of pocket `i` (top rail for 0-2, bottom rail for 3-5).
fn pocket_y(i : Int) -> Float {
  if i <= 2 {
    Float::from_int(table_y + 8)
  } else {
    Float::from_int(table_y + table_h - 8)
  }
}

///|
/// Returns true if the ball at `(x, y)` overlaps any of the six pockets within their 24-pixel capture radius.
fn ball_in_pocket(x : Float, y : Float) -> Bool {
  let mut p = false
  for i in 0..<6 {
    let dx = x - pocket_x(i)
    let dy = y - pocket_y(i)
    if dx * dx + dy * dy <= 24.0 * 24.0 {
      p = true
    }
  }
  p
}

///|
/// Returns the top Y coordinate of the goal opening on the left wall.
fn goal_top() -> Float {
  Float::from_int(table_y + (table_h - 220) / 2)
}

///|
/// Returns the bottom Y coordinate of the goal opening on the left wall.
fn goal_bottom() -> Float {
  goal_top() + 220.0
}

///|
/// Returns true if Y position `y` falls within the left-wall goal opening, allowing balls to pass through.
fn goal_opening(y : Float) -> Bool {
  y >= goal_top() && y <= goal_bottom()
}

///|
/// Returns the paired portal index for the given portal (0↔1 and 2↔3).
fn portal_pair(idx : Int) -> Int {
  if idx == 0 {
    1
  } else if idx == 1 {
    0
  } else if idx == 2 {
    3
  } else {
    2
  }
}

///|
/// Returns the current pixel position `(x, y)` of portal `idx` using sinusoidal drift driven by time `t`.
fn portal_pos(t : Float, idx : Int) -> (Float, Float) {
  let left = Float::from_int(table_x)
  let top = Float::from_int(table_y)
  let right = Float::from_int(table_x + table_w)
  let bottom = Float::from_int(table_y + table_h)
  let cx = Float::from_int(table_x + table_w / 2)

  if idx == 0 {
    (
      left + 250.0 + @math.sinf(t * 0.9) * 120.0,
      top + 130.0 + @math.cosf(t * 1.2) * 44.0,
    )
  } else if idx == 1 {
    (
      right - 250.0 + @math.cosf(t * 0.8) * 120.0,
      bottom - 130.0 + @math.sinf(t * 1.1) * 44.0,
    )
  } else if idx == 2 {
    (cx + @math.sinf(t * 1.1) * 190.0, top + 180.0 + @math.cosf(t * 0.7) * 32.0)
  } else {
    (
      cx + @math.cosf(t * 1.0) * 190.0,
      bottom - 180.0 + @math.sinf(t * 0.75) * 32.0,
    )
  }
}

///|
/// Returns the index of the first portal whose center is within `portal_r` of `(x, y)`, or -1 if none.
fn nearest_portal_idx(t : Float, x : Float, y : Float) -> Int {
  let mut result = -1
  for i in 0..<4 {
    let (px, py) = portal_pos(t, i)
    let dx = x - px
    let dy = y - py
    if dx * dx + dy * dy <= portal_r * portal_r {
      result = i
      break
    }
  }
  result
}

///|
/// Returns the render color for ball `i` (0=white cue, 1-5 cycling through gold/cyan/red/green/pink, 6=yellow).
fn color_for_id(i : Int) -> @raylib.Color {
  if i == 0 {
    @raylib.Color::new(246, 246, 250, 255)
  } else if i % 6 == 1 {
    @raylib.Color::new(244, 184, 74, 255)
  } else if i % 6 == 2 {
    @raylib.Color::new(88, 206, 238, 255)
  } else if i % 6 == 3 {
    @raylib.Color::new(236, 92, 92, 255)
  } else if i % 6 == 4 {
    @raylib.Color::new(120, 224, 130, 255)
  } else if i % 6 == 5 {
    @raylib.Color::new(236, 126, 212, 255)
  } else {
    @raylib.Color::new(246, 220, 110, 255)
  }
}

///|
/// Entry point: initializes the window, creates game state, and runs the portal billiards frame loop.
fn main {
  @raylib.init_window(sw, sh, "Portal Billiards 2026")
  @raylib.set_target_fps(60)
  @draw.init_font()

  let balls : Array[Ball] = Array::makei(max_balls, fn(i) {
    { x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, active: false, id: i, portal_cd: 0.0 }
  })

  let mut level = 1
  let mut shots_left = reset_level(level, balls)
  let mut score = 0
  let mut power : Float = 540.0

  let mut portal_t : Float = 0.0

  let mut aim_x = cue_spawn_x() + 120.0
  let mut aim_y = cue_spawn_y()

  let mut over = false
  let mut won = false
  let mut msg = "Aim with mouse/touch. W/S power. Space shoot."

  while !@raylib.window_should_close() {
    let frame_dt = @raylib.get_frame_time()
    let dt = if frame_dt > 0.05F { 0.05F } else { frame_dt }

    portal_t = portal_t + dt

    if @raylib.is_key_pressed(@raylib.KeyR) {
      level = 1
      shots_left = reset_level(level, balls)
      score = 0
      power = 540.0
      portal_t = 0.0
      aim_x = cue_spawn_x() + 120.0
      aim_y = cue_spawn_y()
      over = false
      won = false
      msg = "Table reset."
    }

    if !over {
      if @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp) {
        power = power + 220.0 * dt
      }
      if @raylib.is_key_down(@raylib.KeyS) ||
        @raylib.is_key_down(@raylib.KeyDown) {
        power = power - 220.0 * dt
      }
      power = clampf(power, 260.0, 820.0)

      let mouse = @raylib.get_mouse_position()
      if inside_rect(mouse.x, mouse.y, table_x, table_y, table_w, table_h) {
        aim_x = mouse.x
        aim_y = mouse.y
      }

      let ctl_x = 24
      let ctl_y = sh - 178
      let fire_x = sw - 204
      let fire_y = sh - 152
      let mut fire = @raylib.is_key_pressed(@raylib.KeySpace) ||
        @raylib.is_key_pressed(@raylib.KeyJ)

      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        if inside_rect(mouse.x, mouse.y, ctl_x, ctl_y, 74, 54) {
          power = power - 22.0
        } else if inside_rect(mouse.x, mouse.y, ctl_x + 84, ctl_y, 74, 54) {
          power = power + 22.0
        } else if inside_rect(mouse.x, mouse.y, fire_x, fire_y, 170, 116) {
          fire = true
        } else if inside_rect(
            mouse.x,
            mouse.y,
            table_x,
            table_y,
            table_w,
            table_h,
          ) {
          aim_x = mouse.x
          aim_y = mouse.y
        }
      }
      power = clampf(power, 260.0, 820.0)

      let moving = moving_any(balls)

      if fire && !moving && shots_left > 0 && balls[0].active {
        let dx = aim_x - balls[0].x
        let dy = aim_y - balls[0].y
        let d = @math.hypotf(dx, dy)
        if d > 0.001 {
          balls[0].vx = dx / d * power
          balls[0].vy = dy / d * power
          shots_left = shots_left - 1
          msg = "Shot taken."
        }
      }

      for ball in balls {
        if !ball.active {
          continue
        }

        if ball.portal_cd > 0.0 {
          ball.portal_cd = ball.portal_cd - dt
          if ball.portal_cd < 0.0 {
            ball.portal_cd = 0.0
          }
        }

        ball.x = ball.x + ball.vx * dt
        ball.y = ball.y + ball.vy * dt

        let friction = Float::from_int(1) - dt * 0.84
        ball.vx = ball.vx * friction
        ball.vy = ball.vy * friction

        if ball.vx.abs() < 6.0 {
          ball.vx = 0.0
        }
        if ball.vy.abs() < 6.0 {
          ball.vy = 0.0
        }

        if ball_in_pocket(ball.x, ball.y) {
          if ball.id == 0 {
            ball.x = cue_spawn_x()
            ball.y = cue_spawn_y()
            ball.vx = 0.0
            ball.vy = 0.0
            ball.portal_cd = 0.5
            if shots_left > 0 {
              shots_left = shots_left - 1
            }
            msg = "Cue scratch: -1 shot."
          } else {
            ball.active = false
            score = score + 60
            msg = "Ball pocketed +60."
          }
          continue
        }

        let left = Float::from_int(table_x) + ball_r
        let right = Float::from_int(table_x + table_w) - ball_r
        let top = Float::from_int(table_y) + ball_r
        let bottom = Float::from_int(table_y + table_h) - ball_r

        if ball.x <= left {
          if !goal_opening(ball.y) {
            ball.x = left
            ball.vx = ball.vx.abs() * 0.94
          }
        }
        if ball.x >= right {
          if !goal_opening(ball.y) {
            ball.x = right
            ball.vx = -ball.vx.abs() * 0.94
          }
        }
        if ball.y <= top {
          ball.y = top
          ball.vy = ball.vy.abs() * 0.94
        }
        if ball.y >= bottom {
          ball.y = bottom
          ball.vy = -ball.vy.abs() * 0.94
        }

        if ball.portal_cd <= 0.0 {
          let from = nearest_portal_idx(portal_t, ball.x, ball.y)
          if from >= 0 {
            let to = portal_pair(from)
            let (tx, ty) = portal_pos(portal_t, to)

            let sp = (ball.vx * ball.vx + ball.vy * ball.vy).sqrt()
            if sp > 1.0 {
              let nx = ball.vx / sp
              let ny = ball.vy / sp
              ball.x = tx + nx * (portal_r + ball_r + 2.0)
              ball.y = ty + ny * (portal_r + ball_r + 2.0)
            } else {
              ball.x = tx
              ball.y = ty
            }

            ball.vx = ball.vx * 1.05
            ball.vy = ball.vy * 1.05
            ball.portal_cd = 0.45
            if ball.id == 0 {
              msg = "Cue teleported."
            }
          }
        }
      }

      for i in 0..<balls.length() {
        if !balls[i].active {
          continue
        }
        for j in (i + 1)..<balls.length() {
          if !balls[j].active {
            continue
          }

          let dx = balls[j].x - balls[i].x
          let dy = balls[j].y - balls[i].y
          let d2 = dx * dx + dy * dy
          let min_d = ball_r * 2.0
          if d2 <= min_d * min_d && d2 > 0.0001 {
            let d = d2.sqrt()
            let nx = dx / d
            let ny = dy / d
            let overlap = min_d - d

            balls[i].x = balls[i].x - nx * overlap * 0.5
            balls[i].y = balls[i].y - ny * overlap * 0.5
            balls[j].x = balls[j].x + nx * overlap * 0.5
            balls[j].y = balls[j].y + ny * overlap * 0.5

            let rvx = balls[i].vx - balls[j].vx
            let rvy = balls[i].vy - balls[j].vy
            let rel = rvx * nx + rvy * ny
            if rel > 0.0 {
              let imp = rel * 0.98
              balls[i].vx = balls[i].vx - nx * imp
              balls[i].vy = balls[i].vy - ny * imp
              balls[j].vx = balls[j].vx + nx * imp
              balls[j].vy = balls[j].vy + ny * imp
            }
          }
        }
      }

      let still_moving = moving_any(balls)
      if !still_moving && shots_left <= 0 && !all_targets_cleared(balls) {
        over = true
        won = false
        msg = "Out of shots. Press R to retry."
      }

      if all_targets_cleared(balls) {
        score = score + shots_left * 30 + 180
        if level < 3 {
          level = level + 1
          shots_left = reset_level(level, balls)
          power = power + 40.0
          power = clampf(power, 260.0, 820.0)
          msg = "Level \{level}. New rack loaded."
        } else {
          over = true
          won = true
          msg = "All portal racks cleared."
        }
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(12, 18, 28, 255))

    @raylib.draw_rectangle(0, 0, sw, 104, @raylib.Color::new(8, 14, 22, 230))
    @draw.draw_text(
      "PORTAL BILLIARDS 2026",
      18,
      24,
      36,
      @raylib.Color::new(236, 244, 252, 255),
    )
    @draw.draw_text(
      "Level \{level}/3",
      460,
      34,
      30,
      @raylib.Color::new(248, 226, 134, 255),
    )
    @draw.draw_text(
      "Shots \{shots_left}",
      650,
      34,
      30,
      @raylib.Color::new(220, 236, 250, 255),
    )
    @draw.draw_text(
      "Score \{score}",
      846,
      34,
      30,
      @raylib.Color::new(196, 226, 252, 255),
    )

    @raylib.draw_rectangle(
      table_x - 24,
      table_y - 24,
      table_w + 48,
      table_h + 48,
      @raylib.Color::new(62, 44, 30, 255),
    )
    @raylib.draw_rectangle(
      table_x,
      table_y,
      table_w,
      table_h,
      @raylib.Color::new(26, 92, 62, 255),
    )
    @raylib.draw_rectangle_lines(
      table_x,
      table_y,
      table_w,
      table_h,
      @raylib.Color::new(176, 144, 90, 255),
    )

    for i in 0..<6 {
      @raylib.draw_circle(
        pocket_x(i).to_int(),
        pocket_y(i).to_int(),
        24.0,
        @raylib.Color::new(18, 18, 20, 255),
      )
    }

    for i in 0..<4 {
      let (px, py) = portal_pos(portal_t, i)
      let c = if i < 2 {
        @raylib.Color::new(98, 208, 254, 170)
      } else {
        @raylib.Color::new(252, 162, 98, 170)
      }
      @raylib.draw_circle(px.to_int(), py.to_int(), portal_r + 4.0, c)
      @raylib.draw_circle(
        px.to_int(),
        py.to_int(),
        portal_r - 6.0,
        @raylib.Color::new(12, 22, 30, 220),
      )
      @raylib.draw_circle_lines(
        px.to_int(),
        py.to_int(),
        portal_r + 2.0,
        @raylib.Color::new(240, 246, 254, 220),
      )
    }

    for ball in balls {
      if !ball.active {
        continue
      }
      let x = ball.x.to_int()
      let y = ball.y.to_int()
      let c = color_for_id(ball.id)
      @raylib.draw_circle(x, y, ball_r, c)
      @raylib.draw_circle(
        x - 4,
        y - 5,
        ball_r * 0.40,
        @raylib.Color::new(250, 250, 252, 210),
      )
      @raylib.draw_circle_lines(
        x,
        y,
        ball_r,
        @raylib.Color::new(24, 24, 30, 180),
      )
    }

    if balls[0].active && !moving_any(balls) && !over {
      let dx = aim_x - balls[0].x
      let dy = aim_y - balls[0].y
      let d = @math.hypotf(dx, dy)
      if d > 0.001 {
        let nx = dx / d
        let ny = dy / d
        let len = clampf(d, 40.0, 190.0)
        let sx = balls[0].x - nx * 22.0
        let sy = balls[0].y - ny * 22.0
        let ex = sx - nx * len
        let ey = sy - ny * len
        @raylib.draw_line_ex(
          @raylib.Vector2::new(sx, sy),
          @raylib.Vector2::new(ex, ey),
          5.0,
          @raylib.Color::new(230, 238, 246, 180),
        )
      }
    }

    @raylib.draw_rectangle(
      22,
      112,
      250,
      14,
      @raylib.Color::new(22, 30, 40, 255),
    )
    @raylib.draw_rectangle(
      22,
      112,
      ((power - 260.0) / (820.0 - 260.0) * 250.0).to_int(),
      14,
      @raylib.Color::new(88, 204, 252, 255),
    )
    @draw.draw_text(
      "Power \{power.to_int()}",
      282,
      106,
      22,
      @raylib.Color::new(220, 238, 250, 255),
    )

    let ctl_x = 24
    let ctl_y = sh - 178
    @raylib.draw_rectangle(
      10,
      sh - 192,
      160,
      170,
      @raylib.Color::new(10, 16, 26, 220),
    )
    @draw.draw_text("Touch", 60, sh - 188, 20, @raylib.white)

    @raylib.draw_rectangle(
      ctl_x,
      ctl_y,
      74,
      54,
      @raylib.Color::new(44, 62, 88, 255),
    )
    @draw.draw_text("POW-", ctl_x + 10, ctl_y + 18, 22, @raylib.white)
    @raylib.draw_rectangle(
      ctl_x + 84,
      ctl_y,
      74,
      54,
      @raylib.Color::new(44, 62, 88, 255),
    )
    @draw.draw_text("POW+", ctl_x + 93, ctl_y + 18, 22, @raylib.white)

    let fire_x = sw - 204
    let fire_y = sh - 152
    @raylib.draw_rectangle(
      fire_x,
      fire_y,
      170,
      116,
      @raylib.Color::new(182, 82, 78, 255),
    )
    @draw.draw_text("SHOOT", fire_x + 34, fire_y + 44, 34, @raylib.white)

    @raylib.draw_rectangle(
      178,
      sh - 52,
      sw - 392,
      36,
      @raylib.Color::new(10, 16, 24, 220),
    )
    @draw.draw_text(
      msg,
      188,
      sh - 46,
      22,
      @raylib.Color::new(224, 236, 246, 255),
    )

    if over {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 120))
      @raylib.draw_rectangle(
        sw / 2 - 320,
        sh / 2 - 100,
        640,
        200,
        @raylib.Color::new(16, 24, 40, 242),
      )
      @draw.draw_text(
        if won {
          "TABLE MASTER"
        } else {
          "GAME OVER"
        },
        sw / 2 - 180,
        sh / 2 - 34,
        56,
        if won {
          @raylib.Color::new(248, 234, 142, 255)
        } else {
          @raylib.Color::new(250, 132, 132, 255)
        },
      )
      @draw.draw_text(
        "Press R to restart",
        sw / 2 - 124,
        sh / 2 + 40,
        32,
        @raylib.Color::new(226, 238, 252, 255),
      )
    }

    @fps.draw()
    @raylib.end_drawing()
  }

  @draw.cleanup()
  @raylib.close_window()
}
