///|
/// Screen width in pixels.
let sw : Int = 1200

///|
/// Screen height in pixels.
let sh : Int = 760

///|
/// Represents a gravitational well with position, gravitational mass, and collision radius.
struct Well {
  x : Float
  y : Float
  mass : Float
  r : Float
}

///|
/// Sets the well at index i to the specified position, mass, and radius.
fn set_well(
  wells : Array[Well],
  i : Int,
  x : Float,
  y : Float,
  mass : Float,
  r : Float,
) -> Unit {
  wells[i] = { x, y, mass, r, }
}

///|
/// Clears all wells in the array by resetting their mass to zero.
fn clear_wells(wells : Array[Well]) -> Unit {
  for i in 0..<wells.length() {
    set_well(wells, i, 0.0, 0.0, 0.0, 0.0)
  }
}

///|
/// Configures gravity wells for the given level and returns the ball start position, hole position, and shot count.
fn setup_level(
  level : Int,
  wells : Array[Well],
) -> (Float, Float, Float, Float, Int) {
  clear_wells(wells)
  if level == 1 {
    set_well(wells, 0, 520.0, 360.0, 56000.0, 34.0)
    set_well(wells, 1, 860.0, 260.0, 46000.0, 28.0)
    (130.0, 620.0, 1060.0, 210.0, 8)
  } else if level == 2 {
    set_well(wells, 0, 430.0, 260.0, 62000.0, 32.0)
    set_well(wells, 1, 660.0, 460.0, 78000.0, 42.0)
    set_well(wells, 2, 930.0, 300.0, 54000.0, 30.0)
    (120.0, 160.0, 1040.0, 640.0, 9)
  } else {
    set_well(wells, 0, 360.0, 330.0, 70000.0, 34.0)
    set_well(wells, 1, 610.0, 210.0, 64000.0, 31.0)
    set_well(wells, 2, 810.0, 510.0, 76000.0, 39.0)
    set_well(wells, 3, 1000.0, 270.0, 61000.0, 30.0)
    (140.0, 680.0, 1090.0, 130.0, 10)
  }
}

///|
/// Initialises the window, runs the main game loop, and handles all update and draw logic.
fn main {
  @raylib.init_window(sw, sh, "Gravity Golf 2026")
  @raylib.set_target_fps(60)
  @draw.init_font()
  defer @draw.cleanup()

  let art = load_game_art()
  defer unload_game_art(art)
  defer @raylib.close_window()

  let wells : Array[Well] = Array::makei(4, fn(_i) {
    { x: 0.0, y: 0.0, mass: 0.0, r: 0.0, }
  })

  let mut level = 1
  let mut sx : Float = 0.0
  let mut sy : Float = 0.0
  let mut hx : Float = 0.0
  let mut hy : Float = 0.0
  let mut shots_left = 0

  let (isx, isy, ihx, ihy, ishots) = setup_level(level, wells)
  sx = isx
  sy = isy
  hx = ihx
  hy = ihy
  shots_left = ishots

  let mut bx = sx
  let mut by = sy
  let mut bvx : Float = 0.0
  let mut bvy : Float = 0.0
  let mut moving = false
  let mut shot_time : Float = 0.0

  let mut power : Float = 500.0
  let mut score = 0
  let mut over = false
  let mut msg = "Mouse aim, W/S power, Space shoot, R restart"

  while !@raylib.window_should_close() {
    let frame_dt = @raylib.get_frame_time()
    let dt = if frame_dt > 0.05F { 0.05F } else { frame_dt }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      level = 1
      let (rsx, rsy, rhx, rhy, rshots) = setup_level(level, wells)
      sx = rsx
      sy = rsy
      hx = rhx
      hy = rhy
      shots_left = rshots
      bx = sx
      by = sy
      bvx = 0.0
      bvy = 0.0
      moving = false
      shot_time = 0.0
      power = 500.0
      score = 0
      over = false
      msg = "Course restarted."
    }

    if !over {
      if @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp) {
        power = power + 260.0 * dt
      }
      if @raylib.is_key_down(@raylib.KeyS) ||
        @raylib.is_key_down(@raylib.KeyDown) {
        power = power - 260.0 * dt
      }
      if power < 220.0 {
        power = 220.0
      }
      if power > 760.0 {
        power = 760.0
      }

      if @raylib.is_key_pressed(@raylib.KeySpace) && !moving && shots_left > 0 {
        let m = @raylib.get_mouse_position()
        let mut dx = m.x - bx
        let mut dy = m.y - by
        let d = @math.hypotf(dx, dy)
        if d > 0.001 {
          dx = dx / d
          dy = dy / d
          bvx = dx * power
          bvy = dy * power
          shots_left = shots_left - 1
          moving = true
          shot_time = 0.0
        }
      }

      if moving {
        shot_time = shot_time + dt

        for i in 0..<wells.length() {
          if wells[i].mass <= 0.0 {
            continue
          }
          let dx = wells[i].x - bx
          let dy = wells[i].y - by
          let d2 = dx * dx + dy * dy
          let crash_r = wells[i].r + 8.0
          if d2 <= crash_r * crash_r {
            moving = false
            bx = sx
            by = sy
            bvx = 0.0
            bvy = 0.0
            msg = "Ball collapsed into gravity well."
            break
          }
          if d2 > 36.0 {
            let d = d2.sqrt()
            let a = wells[i].mass / d2
            bvx = bvx + dx / d * a * dt
            bvy = bvy + dy / d * a * dt
          }
        }

        if moving {
          bx = bx + bvx * dt
          by = by + bvy * dt

          if bx < 20.0 {
            bx = 20.0
            bvx = -bvx * 0.72
          }
          if bx > Float::from_int(sw - 20) {
            bx = Float::from_int(sw - 20)
            bvx = -bvx * 0.72
          }
          if by < 90.0 {
            by = 90.0
            bvy = -bvy * 0.72
          }
          if by > Float::from_int(sh - 20) {
            by = Float::from_int(sh - 20)
            bvy = -bvy * 0.72
          }

          let spd = @math.hypotf(bvx, bvy)
          if shot_time > 0.9 && spd < 36.0 {
            moving = false
            bvx = 0.0
            bvy = 0.0
            msg = "Ball settled. Re-aim your shot."
          }

          let hdx = hx - bx
          let hdy = hy - by
          if hdx * hdx + hdy * hdy <= 18.0 * 18.0 {
            moving = false
            score = score + shots_left * 20 + 120
            if level < 3 {
              level = level + 1
              let (nsx, nsy, nhx, nhy, nshots) = setup_level(level, wells)
              sx = nsx
              sy = nsy
              hx = nhx
              hy = nhy
              shots_left = nshots
              bx = sx
              by = sy
              bvx = 0.0
              bvy = 0.0
              msg = "Hole cleared. Level \{level}."
            } else {
              over = true
              msg = "Course completed."
            }
          }

          if shots_left <= 0 && !moving {
            over = true
            msg = "Out of shots."
          }
        }
      }
    }

    @raylib.begin_drawing()
    let swf = Float::from_int(sw)
    let shf = Float::from_int(sh)
    draw_texture_cover(
      art.course_backdrop,
      0.0,
      0.0,
      swf,
      shf,
      if over {
        @raylib.Color::new(255, 255, 255, 198)
      } else {
        @raylib.Color::new(255, 255, 255, 236)
      },
    )
    @raylib.draw_rectangle(
      0,
      0,
      sw,
      sh,
      if over {
        @raylib.Color::new(4, 8, 18, 132)
      } else {
        @raylib.Color::new(4, 8, 18, 110)
      },
    )
    @raylib.draw_rectangle(
      20,
      90,
      sw - 40,
      sh - 110,
      @raylib.Color::new(4, 8, 18, 40),
    )
    @raylib.draw_rectangle_lines(
      20,
      90,
      sw - 40,
      sh - 110,
      @raylib.Color::new(100, 138, 188, 180),
    )

    draw_texture_centered(
      art.tee_marker_sprite,
      sx,
      sy,
      42.0,
      42.0,
      0.0,
      @raylib.Color::new(255, 255, 255, 208),
    )

    for well in wells {
      if well.mass > 0.0 {
        let well_size : Float = (well.r + 34.0) * 2.0
        draw_texture_centered(
          art.gravity_well_sprite,
          well.x,
          well.y,
          well_size,
          well_size,
          0.0,
          @raylib.Color::new(255, 255, 255, 240),
        )
        @raylib.draw_circle_lines(
          well.x.to_int(),
          well.y.to_int(),
          well.r + 8.0,
          @raylib.Color::new(180, 214, 255, 110),
        )
      }
    }

    draw_texture_centered(
      art.hole_target_sprite,
      hx,
      hy,
      62.0,
      62.0,
      0.0,
      @raylib.Color::new(255, 255, 255, 246),
    )
    @raylib.draw_circle_lines(
      hx.to_int(),
      hy.to_int(),
      18.0,
      @raylib.Color::new(142, 255, 210, 170),
    )

    let m = @raylib.get_mouse_position()
    if !moving && !over {
      @raylib.draw_line_ex(
        @raylib.Vector2::new(bx, by),
        @raylib.Vector2::new(m.x, m.y),
        2.5,
        @raylib.Color::new(255, 234, 136, 232),
      )
      @raylib.draw_circle_lines(
        m.x.to_int(),
        m.y.to_int(),
        9.0,
        @raylib.Color::new(255, 234, 136, 160),
      )
    }

    if moving {
      let speed = @math.hypotf(bvx, bvy)
      if speed > 0.001 {
        let trail_bonus : Float = if shot_time < 0.4 {
          shot_time * 30.0
        } else {
          12.0
        }
        let trail_len : Float = 28.0 + trail_bonus
        let tx = bx - bvx / speed * trail_len
        let ty = by - bvy / speed * trail_len
        @raylib.draw_line_ex(
          @raylib.Vector2::new(bx, by),
          @raylib.Vector2::new(tx, ty),
          4.0,
          @raylib.Color::new(170, 220, 255, 120),
        )
      }
    }

    draw_texture_centered(
      art.golf_ball_sprite,
      bx,
      by,
      20.0,
      20.0,
      0.0,
      @raylib.Color::new(255, 255, 255, 255),
    )
    @raylib.draw_circle_lines(
      bx.to_int(),
      by.to_int(),
      10.0,
      @raylib.Color::new(220, 240, 255, 140),
    )

    @raylib.draw_rectangle(0, 0, sw, 84, @raylib.Color::new(4, 8, 18, 226))
    draw_texture_cover(
      art.title_art,
      12.0,
      8.0,
      420.0,
      64.0,
      @raylib.Color::new(255, 255, 255, 148),
    )
    @raylib.draw_rectangle(12, 8, 420, 64, @raylib.Color::new(6, 10, 18, 152))
    @draw.draw_text("GRAVITY GOLF 2026", 24, 18, 38, @raylib.skyblue)
    @draw.draw_text("Level \{level}/3", 20, 62, 28, @raylib.white)
    @draw.draw_text("Shots \{shots_left}", 180, 62, 28, @raylib.orange)
    @draw.draw_text("Power \{power.to_int()}", 330, 62, 28, @raylib.raywhite)
    @draw.draw_text("Score \{score}", 540, 62, 28, @raylib.lime)

    @raylib.draw_rectangle(
      20,
      688,
      sw - 40,
      32,
      @raylib.Color::new(6, 10, 18, 196),
    )
    @draw.draw_text(
      "Aim with mouse. W/S adjust power. Space launches ball.", 20, 694, 24, @raylib.lightgray,
    )
    @raylib.draw_rectangle(
      20,
      726,
      sw - 40,
      24,
      @raylib.Color::new(8, 10, 14, 220),
    )
    @draw.draw_text(msg, 26, 729, 18, @raylib.raywhite)

    if over {
      draw_texture_cover(
        art.title_art,
        300.0,
        250.0,
        560.0,
        190.0,
        @raylib.Color::new(255, 255, 255, 224),
      )
      @raylib.draw_rectangle(
        300,
        250,
        560,
        190,
        @raylib.Color::new(4, 8, 16, 176),
      )
      @draw.draw_text("ROUND OVER", 430, 320, 56, @raylib.orange)
      @draw.draw_text("Press R to restart", 450, 386, 34, @raylib.white)
    }

    @fps.draw()
    @raylib.end_drawing()
  }
}
