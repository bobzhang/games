///|
/// Screen width in pixels.
let sw : Int = 1160

///|
/// Screen height in pixels.
let sh : Int = 740

///|
/// Number of runways available for landing.
let runway_count : Int = 3

///|
/// Returns the horizontal screen position of a runway by index.
fn runway_x(idx : Int) -> Float {
  250.0 + Float::from_int(idx) * 330.0
}

///|
/// Represents an in-flight plane with position, velocity, fuel, and runway assignment.
struct Plane {
  mut alive : Bool
  mut runway : Int
  mut x : Float
  mut y : Float
  mut vy : Float
  mut fuel : Float
}

///|
/// Generated texture bundle used by the air traffic control scene.
struct GameArt {
  backdrop : @raylib.Texture
  runway : @raylib.Texture
  airliner : @raylib.Texture
  tower_badge : @raylib.Texture
}

///|
/// Loads one generated art texture from the game resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "air_traffic_control_2026/resources/" + file_name,
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads all generated art textures after the window has been initialized.
fn load_game_art() -> GameArt {
  {
    backdrop: load_art_texture("airport_backdrop.png"),
    runway: load_art_texture("runway_strip_sprite.png"),
    airliner: load_art_texture("airliner_sprite.png"),
    tower_badge: load_art_texture("tower_badge_sprite.png"),
  }
}

///|
/// Unloads generated art textures before closing the window.
fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.backdrop)
  @raylib.unload_texture(art.runway)
  @raylib.unload_texture(art.airliner)
  @raylib.unload_texture(art.tower_badge)
}

///|
/// Draws a texture centered at a position with the requested destination size.
fn draw_centered_art(
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
/// Draws a texture full-screen without distorting its source aspect ratio.
fn draw_cover_art(texture : @raylib.Texture, sw : Int, sh : Int) -> Unit {
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
/// Spawns a new plane into the first inactive slot in the planes array.
fn spawn_plane(planes : Array[Plane]) -> Unit {
  for plane in planes {
    if !plane.alive {
      let r = @raylib.get_random_value(0, runway_count - 1)
      plane.alive = true
      plane.runway = r
      plane.x = runway_x(r) + Float::from_int(@raylib.get_random_value(-24, 24))
      plane.y = -40.0
      plane.vy = Float::from_int(@raylib.get_random_value(65, 110))
      plane.fuel = Float::from_int(@raylib.get_random_value(16, 26))
      break
    }
  }
}

///|
/// Deactivates all planes in the array, resetting the game state.
fn reset_planes(planes : Array[Plane]) -> Unit {
  for plane in planes {
    plane.alive = false
  }
}

///|
/// Initializes the window and runs the main air traffic control game loop.
fn main {
  @raylib.init_window(sw, sh, "Air Traffic Control 2026")
  @raylib.set_target_fps(60)
  @draw.init_font()
  let art = load_game_art()

  let planes : Array[Plane] = Array::makei(100, fn(_i) {
    { alive: false, runway: 0, x: 0.0, y: 0.0, vy: 80.0, fuel: 20.0 }
  })

  let mut runway_open : Array[Bool] = [true, true, true]
  let mut runway_busy : Array[Float] = [0.0, 0.0, 0.0]

  let mut spawn_tick : Float = 0.0
  let mut score = 0
  let mut landed = 0
  let mut missed = 0
  let mut lives = 5
  let mut stress : Float = 0.0
  let mut over = false
  let mut msg = "1/2/3 toggle runway open/close, keep landings safe"

  while !@raylib.window_should_close() {
    let frame_dt = @raylib.get_frame_time()
    let dt = if frame_dt > 0.05F { 0.05F } else { frame_dt }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      runway_open = [true, true, true]
      runway_busy = [0.0, 0.0, 0.0]
      spawn_tick = 0.0
      score = 0
      landed = 0
      missed = 0
      lives = 5
      stress = 0.0
      over = false
      msg = "Tower shift restarted."
      reset_planes(planes)
    }

    if !over {
      if @raylib.is_key_pressed(@raylib.KeyOne) {
        runway_open[0] = !runway_open[0]
      }
      if @raylib.is_key_pressed(@raylib.KeyTwo) {
        runway_open[1] = !runway_open[1]
      }
      if @raylib.is_key_pressed(@raylib.KeyThree) {
        runway_open[2] = !runway_open[2]
      }

      for r in 0..<runway_count {
        runway_busy[r] = runway_busy[r] - dt
        if runway_busy[r] < 0.0 {
          runway_busy[r] = 0.0
        }
      }

      spawn_tick = spawn_tick + dt
      if spawn_tick >= 0.70 {
        spawn_tick = spawn_tick - 0.70
        spawn_plane(planes)
      }

      stress = stress - dt * 4.0
      if stress < 0.0 {
        stress = 0.0
      }

      for plane in planes {
        if !plane.alive {
          continue
        }

        plane.y = plane.y + plane.vy * dt
        plane.fuel = plane.fuel - dt

        if plane.fuel <= 0.0 {
          plane.alive = false
          lives = lives - 1
          missed = missed + 1
          stress = stress + 22.0
          msg = "Plane ran out of fuel."
          continue
        }

        let r = plane.runway
        if plane.y >= 560.0 {
          if runway_open[r] && runway_busy[r] <= 0.0 {
            plane.alive = false
            runway_busy[r] = 2.0
            landed = landed + 1
            score = score + 70 + plane.fuel.to_int()
            stress = stress + 4.0
            msg = "Runway \{r + 1}: safe landing."
          } else if plane.y >= 650.0 {
            plane.alive = false
            lives = lives - 1
            missed = missed + 1
            score = score - 45
            stress = stress + 25.0
            msg = "Runway \{r + 1}: crash on approach."
          }
        }
      }

      // Near-collision warning between planes on same runway
      for i in 0..<planes.length() {
        if !planes[i].alive {
          continue
        }
        for j in (i + 1)..<planes.length() {
          if !planes[j].alive {
            continue
          }
          if planes[i].runway == planes[j].runway {
            let dy = (planes[i].y - planes[j].y).abs()
            if dy < 48.0 {
              stress = stress + dt * 22.0
            }
          }
        }
      }

      if stress >= 100.0 {
        stress = 100.0
        lives = lives - 1
        msg = "Controller overload penalty."
      }

      if lives <= 0 {
        lives = 0
        over = true
        msg = "Tower closed due to failures."
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(120, 178, 230, 255))
    draw_cover_art(art.backdrop, sw, sh)

    @raylib.draw_rectangle(
      0,
      140,
      sw,
      sh - 140,
      @raylib.Color::new(42, 84, 52, 78),
    )

    for r in 0..<runway_count {
      let x = runway_x(r)
      let state_c = if runway_open[r] { @raylib.lime } else { @raylib.red }

      draw_centered_art(
        art.runway,
        x,
        430.0,
        108.0,
        520.0,
        0.0,
        if runway_open[r] {
          @raylib.Color::new(255, 255, 255, 242)
        } else {
          @raylib.Color::new(255, 188, 188, 228)
        },
      )
      @raylib.draw_rectangle_lines(
        (x - 54.0).to_int(),
        170,
        108,
        520,
        @raylib.Color::new(210, 226, 236, 90),
      )
      @draw.draw_text(
        "RWY \{r + 1}",
        (x - 42.0).to_int(),
        184,
        24,
        @raylib.white,
      )
      @raylib.draw_circle((x + 44.0).to_int(), 184, 8.0, state_c)

      if runway_busy[r] > 0.0 {
        @raylib.draw_rectangle(
          (x - 54.0).to_int(),
          620,
          108,
          70,
          @raylib.fade(@raylib.orange, 0.6),
        )
      }
    }

    for plane in planes {
      if plane.alive {
        draw_centered_art(
          art.airliner,
          plane.x,
          plane.y,
          34.0,
          42.0,
          0.0,
          if plane.fuel < 6.0 {
            @raylib.Color::new(255, 126, 126, 255)
          } else {
            @raylib.white
          },
        )
        @draw.draw_text(
          "\{plane.fuel.to_int()}",
          (plane.x + 14.0).to_int(),
          (plane.y - 12.0).to_int(),
          18,
          @raylib.black,
        )
      }
    }

    @raylib.draw_rectangle(
      16,
      14,
      600,
      110,
      @raylib.Color::new(12, 18, 30, 220),
    )
    draw_centered_art(
      art.tower_badge,
      560.0,
      70.0,
      72.0,
      92.0,
      0.0,
      @raylib.white,
    )
    @draw.draw_text("AIR TRAFFIC CONTROL 2026", 26, 22, 36, @raylib.skyblue)
    @draw.draw_text(
      "Score \{score}  Landed \{landed}  Missed \{missed}  Lives \{lives}",
      28,
      66,
      28,
      @raylib.raywhite,
    )

    @draw.draw_text("Stress", 670, 30, 28, @raylib.darkblue)
    @raylib.draw_rectangle(
      760,
      36,
      300,
      20,
      @raylib.Color::new(40, 20, 20, 255),
    )
    @raylib.draw_rectangle(760, 36, (stress * 3.0).to_int(), 20, @raylib.red)

    @raylib.draw_rectangle(
      20,
      694,
      sw - 40,
      30,
      @raylib.Color::new(12, 18, 30, 220),
    )
    @draw.draw_text(msg, 28, 699, 20, @raylib.raywhite)

    if over {
      @raylib.draw_rectangle(
        300,
        250,
        540,
        180,
        @raylib.fade(@raylib.black, 0.82),
      )
      @draw.draw_text("SHIFT FAILED", 420, 310, 52, @raylib.red)
      @draw.draw_text("Press R to restart", 430, 370, 34, @raylib.white)
    }

    @fps.draw()
    @raylib.end_drawing()
  }

  unload_game_art(art)
  @draw.cleanup()
  @raylib.close_window()
}
