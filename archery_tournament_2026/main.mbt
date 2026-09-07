///|
/// Screen width in pixels.
let sw : Int = 1200

///|
/// Screen height in pixels.
let sh : Int = 740

///|
/// Y coordinate of the ground line separating sky from grass.
let ground_y : Float = 640.0

///|
/// Represents a fired arrow with position, velocity, and alive state.
struct Arrow {
  mut alive : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
}

///|
/// Represents a moving archery target with position, radius, velocity, and point value.
struct Target {
  mut alive : Bool
  mut x : Float
  y : Float
  r : Float
  mut vx : Float
  points : Int
}

///|
/// Generated archery range backdrop texture.
let tex_archery_backdrop : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated archer sprite texture.
let tex_archer : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated target sprite texture.
let tex_target : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated arrow sprite texture.
let tex_arrow : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated wind pennant sprite texture.
let tex_wind_pennant : Ref[@raylib.Texture?] = { val: None, }

///|
/// Loads one generated archery art texture.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "archery_tournament_2026/resources/" + file_name,
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads generated archery tournament art textures.
fn load_archery_art() -> Unit {
  tex_archery_backdrop.val = Some(
    load_art_texture("archery_range_backdrop.png"),
  )
  tex_archer.val = Some(load_art_texture("archer_sprite.png"))
  tex_target.val = Some(load_art_texture("target_sprite.png"))
  tex_arrow.val = Some(load_art_texture("arrow_sprite.png"))
  tex_wind_pennant.val = Some(load_art_texture("wind_pennant_sprite.png"))
}

///|
/// Unloads generated archery tournament art textures.
fn unload_archery_art() -> Unit {
  fn unload(texture_ref : Ref[@raylib.Texture?]) -> Unit {
    match texture_ref.val {
      Some(texture) => {
        @raylib.unload_texture(texture)
        texture_ref.val = None
      }
      None => ()
    }
  }

  unload(tex_archery_backdrop)
  unload(tex_archer)
  unload(tex_target)
  unload(tex_arrow)
  unload(tex_wind_pennant)
}

///|
/// Draws a generated sprite centered in a destination rectangle.
fn draw_art_rect(
  texture : @raylib.Texture,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  rotation : Float,
  tint : @raylib.Color,
) -> Unit {
  @raylib.draw_texture_pro(
    texture,
    @raylib.Rectangle::new(
      0.0,
      0.0,
      Float::from_int(texture.width()),
      Float::from_int(texture.height()),
    ),
    @raylib.Rectangle::new(x, y, w, h),
    @raylib.Vector2::new(w * 0.5, h * 0.5),
    rotation,
    tint,
  )
}

///|
/// Draws a generated sprite scaled to fit a centered box.
fn draw_art_fit(
  texture : @raylib.Texture,
  x : Float,
  y : Float,
  max_w : Float,
  max_h : Float,
  rotation : Float,
  tint : @raylib.Color,
) -> Unit {
  let source_w = Float::from_int(texture.width())
  let source_h = Float::from_int(texture.height())
  let source_ratio = source_w / source_h
  let box_ratio = max_w / max_h
  let (w, h) = if source_ratio > box_ratio {
    (max_w, max_w / source_ratio)
  } else {
    (max_h * source_ratio, max_h)
  }
  draw_art_rect(texture, x, y, w, h, rotation, tint)
}

///|
/// Draws a generated image as full-screen cover art.
fn draw_cover_art(texture : @raylib.Texture) -> Unit {
  let source_w : Float = Float::from_int(texture.width())
  let source_h : Float = Float::from_int(texture.height())
  let screen_w : Float = Float::from_int(sw)
  let screen_h : Float = Float::from_int(sh)
  let source_ratio : Float = source_w / source_h
  let screen_ratio : Float = screen_w / screen_h

  let mut src_x : Float = 0.0
  let mut src_y : Float = 0.0
  let mut src_w : Float = source_w
  let mut src_h : Float = source_h

  if source_ratio > screen_ratio {
    src_w = source_h * screen_ratio
    src_x = (source_w - src_w) * 0.5
  } else if source_ratio < screen_ratio {
    src_h = source_w / screen_ratio
    src_y = (source_h - src_h) * 0.5
  }

  @raylib.draw_texture_pro(
    texture,
    @raylib.Rectangle::new(src_x, src_y, src_w, src_h),
    @raylib.Rectangle::new(0.0, 0.0, screen_w, screen_h),
    @raylib.Vector2::new(0.0, 0.0),
    0.0,
    @raylib.white,
  )
}

///|
/// Resets all targets to their initial positions, sizes, velocities, and point values.
fn reset_targets(ts : Array[Target]) -> Unit {
  ts[0] = { alive: true, x: 920.0, y: 430.0, r: 34.0, vx: 90.0, points: 30, }
  ts[1] = { alive: true, x: 1040.0, y: 360.0, r: 26.0, vx: -120.0, points: 45, }
  ts[2] = { alive: true, x: 860.0, y: 300.0, r: 20.0, vx: 70.0, points: 60, }
  ts[3] = { alive: true, x: 980.0, y: 250.0, r: 16.0, vx: -95.0, points: 75, }
}

///|
/// Runs the main game loop for Archery Tournament 2026, handling input, physics, collision, and rendering.
fn main {
  @raylib.init_window(sw, sh, "Archery Tournament 2026")
  @raylib.set_target_fps(60)
  @draw.init_font()
  load_archery_art()

  let arrow : Arrow = { alive: false, x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, }

  let targets : Array[Target] = Array::makei(4, fn(_i) {
    { alive: true, x: 0.0, y: 0.0, r: 20.0, vx: 0.0, points: 20, }
  })
  reset_targets(targets)

  let archer_x : Float = 110.0
  let archer_y : Float = ground_y

  let mut arc_power : Float = 500.0
  let mut arc_lift : Float = 280.0
  let mut wind : Float = 0.0
  let mut wind_tick : Float = 0.0

  let mut arrows_left = 18
  let mut score = 0
  let mut combo = 0
  let mut best_hit = 0
  let mut msg = "A/D power  W/S arc  Space shoot  R restart"
  let mut over = false

  while !@raylib.window_should_close() {
    let frame_dt = @raylib.get_frame_time()
    let dt = if frame_dt > 0.05F { 0.05F } else { frame_dt }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      arrow.alive = false
      reset_targets(targets)
      arc_power = 500.0
      arc_lift = 280.0
      wind = 0.0
      wind_tick = 0.0
      arrows_left = 18
      score = 0
      combo = 0
      best_hit = 0
      over = false
      msg = "Tournament restarted."
    }

    if !over {
      if @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft) {
        arc_power = arc_power - 220.0 * dt
      }
      if @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight) {
        arc_power = arc_power + 220.0 * dt
      }
      if arc_power < 260.0 {
        arc_power = 260.0
      }
      if arc_power > 760.0 {
        arc_power = 760.0
      }

      if @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp) {
        arc_lift = arc_lift + 180.0 * dt
      }
      if @raylib.is_key_down(@raylib.KeyS) ||
        @raylib.is_key_down(@raylib.KeyDown) {
        arc_lift = arc_lift - 180.0 * dt
      }
      if arc_lift < 120.0 {
        arc_lift = 120.0
      }
      if arc_lift > 460.0 {
        arc_lift = 460.0
      }

      wind_tick = wind_tick + dt
      if wind_tick >= 2.8 {
        wind_tick = wind_tick - 2.8
        wind = Float::from_int(@raylib.get_random_value(-90, 90))
      }

      if @raylib.is_key_pressed(@raylib.KeySpace) &&
        !arrow.alive &&
        arrows_left > 0 {
        arrow.alive = true
        arrow.x = archer_x + 26.0
        arrow.y = archer_y - 32.0
        arrow.vx = arc_power
        arrow.vy = -arc_lift
        arrows_left = arrows_left - 1
      }

      for target in targets {
        if target.alive {
          target.x = target.x + target.vx * dt
          if target.x < 760.0 {
            target.x = 760.0
            target.vx = target.vx.abs()
          }
          if target.x > Float::from_int(sw - 80) {
            target.x = Float::from_int(sw - 80)
            target.vx = -target.vx.abs()
          }
        }
      }

      if arrow.alive {
        arrow.vx = arrow.vx + wind * dt * 0.28
        arrow.vy = arrow.vy + 620.0 * dt
        arrow.x = arrow.x + arrow.vx * dt
        arrow.y = arrow.y + arrow.vy * dt

        for target in targets {
          if !target.alive {
            continue
          }
          let dx = target.x - arrow.x
          let dy = target.y - arrow.y
          if dx * dx + dy * dy <= target.r * target.r {
            let gain = target.points + combo * 6
            score = score + gain
            combo = combo + 1
            if gain > best_hit {
              best_hit = gain
            }
            target.alive = false
            arrow.alive = false
            msg = "Bullseye +\{gain}!"
            break
          }
        }

        if arrow.x > Float::from_int(sw + 20) ||
          arrow.y > ground_y ||
          arrow.y < 40.0 {
          arrow.alive = false
          combo = 0
          if arrows_left > 0 {
            msg = "Missed shot."
          }
        }
      }

      let mut alive_count = 0
      for target in targets {
        if target.alive {
          alive_count = alive_count + 1
        }
      }
      if alive_count == 0 {
        reset_targets(targets)
        score = score + 50
        msg = "Wave cleared +50."
      }

      if arrows_left <= 0 && !arrow.alive {
        over = true
        msg = "Tournament ended."
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(196, 228, 255, 255))

    match tex_archery_backdrop.val {
      Some(texture) => {
        draw_cover_art(texture)
        @raylib.draw_rectangle(
          0,
          0,
          sw,
          146,
          @raylib.Color::new(255, 255, 255, 42),
        )
      }
      None =>
        @raylib.draw_rectangle(
          0,
          ground_y.to_int(),
          sw,
          sh - ground_y.to_int(),
          @raylib.Color::new(88, 138, 82, 255),
        )
    }

    // Archer
    match tex_archer.val {
      Some(texture) =>
        draw_art_fit(
          texture,
          archer_x + 26.0,
          archer_y - 56.0,
          128.0,
          150.0,
          0.0,
          @raylib.white,
        )
      None => {
        @raylib.draw_circle(
          archer_x.to_int(),
          (archer_y - 52.0).to_int(),
          16.0,
          @raylib.orange,
        )
        @raylib.draw_rectangle(
          (archer_x - 12.0).to_int(),
          (archer_y - 36.0).to_int(),
          24,
          34,
          @raylib.darkbrown,
        )
        @raylib.draw_line(
          (archer_x + 12.0).to_int(),
          (archer_y - 28.0).to_int(),
          (archer_x + 34.0).to_int(),
          (archer_y - 28.0).to_int(),
          @raylib.brown,
        )
        @raylib.draw_circle_lines(
          (archer_x + 40.0).to_int(),
          (archer_y - 28.0).to_int(),
          14.0,
          @raylib.darkbrown,
        )
      }
    }

    for target in targets {
      if target.alive {
        match tex_target.val {
          Some(texture) =>
            draw_art_fit(
              texture,
              target.x,
              target.y + target.r * 0.48,
              target.r * 2.85,
              target.r * 3.35,
              0.0,
              @raylib.white,
            )
          None => {
            @raylib.draw_circle(
              target.x.to_int(),
              target.y.to_int(),
              target.r,
              @raylib.red,
            )
            @raylib.draw_circle(
              target.x.to_int(),
              target.y.to_int(),
              target.r * 0.68,
              @raylib.white,
            )
            @raylib.draw_circle(
              target.x.to_int(),
              target.y.to_int(),
              target.r * 0.36,
              @raylib.blue,
            )
          }
        }
        @draw.draw_text(
          "\{target.points}",
          (target.x - 14.0).to_int(),
          (target.y - 10.0).to_int(),
          18,
          @raylib.black,
        )
      }
    }

    if arrow.alive {
      match tex_arrow.val {
        Some(texture) =>
          draw_art_fit(
            texture,
            arrow.x,
            arrow.y,
            72.0,
            12.0,
            0.0,
            @raylib.white,
          )
        None => {
          @raylib.draw_line(
            (arrow.x - 18.0).to_int(),
            arrow.y.to_int(),
            (arrow.x + 18.0).to_int(),
            arrow.y.to_int(),
            @raylib.darkbrown,
          )
          @raylib.draw_triangle(
            @raylib.Vector2::new(arrow.x + 18.0, arrow.y),
            @raylib.Vector2::new(arrow.x + 10.0, arrow.y - 4.0),
            @raylib.Vector2::new(arrow.x + 10.0, arrow.y + 4.0),
            @raylib.gray,
          )
        }
      }
    }

    @draw.draw_text("ARCHERY TOURNAMENT 2026", 20, 18, 40, @raylib.darkblue)
    @draw.draw_text("Score \{score}", 20, 66, 30, @raylib.black)
    @draw.draw_text("Arrows \{arrows_left}", 220, 66, 30, @raylib.maroon)
    @draw.draw_text("Combo x\{combo}", 430, 66, 30, @raylib.orange)
    @draw.draw_text("Best Hit \{best_hit}", 620, 66, 30, @raylib.lime)

    @draw.draw_text(
      "Power \{arc_power.to_int()}",
      20,
      108,
      26,
      @raylib.raywhite,
    )
    @raylib.draw_rectangle(
      160,
      114,
      220,
      14,
      @raylib.Color::new(40, 40, 40, 255),
    )
    @raylib.draw_rectangle(
      160,
      114,
      ((arc_power - 260.0) * 0.44).to_int(),
      14,
      @raylib.blue,
    )

    @draw.draw_text("Arc \{arc_lift.to_int()}", 410, 108, 26, @raylib.raywhite)
    @raylib.draw_rectangle(
      510,
      114,
      220,
      14,
      @raylib.Color::new(40, 40, 40, 255),
    )
    @raylib.draw_rectangle(
      510,
      114,
      ((arc_lift - 120.0) * 0.64).to_int(),
      14,
      @raylib.green,
    )

    @draw.draw_text(
      "Wind \{wind.to_int()}",
      760,
      108,
      26,
      if wind > 0.0 {
        @raylib.red
      } else if wind < 0.0 {
        @raylib.blue
      } else {
        @raylib.gray
      },
    )
    match tex_wind_pennant.val {
      Some(texture) => {
        let tint = if wind > 0.0 {
          @raylib.Color::new(255, 220, 204, 255)
        } else if wind < 0.0 {
          @raylib.Color::new(204, 226, 255, 255)
        } else {
          @raylib.white
        }
        draw_art_fit(texture, 978.0, 118.0, 92.0, 58.0, 0.0, tint)
      }
      None => ()
    }

    @raylib.draw_rectangle(
      20,
      694,
      sw - 40,
      30,
      @raylib.Color::new(18, 24, 30, 220),
    )
    @draw.draw_text(msg, 28, 699, 20, @raylib.raywhite)

    if over {
      @raylib.draw_rectangle(
        300,
        250,
        560,
        190,
        @raylib.fade(@raylib.black, 0.82),
      )
      @draw.draw_text("TOURNAMENT OVER", 360, 320, 56, @raylib.orange)
      @draw.draw_text("Press R to restart", 450, 384, 34, @raylib.white)
    }

    @fps.draw()
    @raylib.end_drawing()
  }

  unload_archery_art()
  @draw.cleanup()
  @raylib.close_window()
}
