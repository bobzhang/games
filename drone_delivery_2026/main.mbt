///|
/// Screen width in pixels.
let sw : Int = 1120

///|
/// Screen height in pixels.
let sh : Int = 740

///|
/// Generated city background texture.
let tex_city_background : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated delivery drone sprite.
let tex_drone : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated package pickup pad sprite.
let tex_pickup_pad : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated drop-off pad sprite.
let tex_dropoff_pad : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated shock orb sprite.
let tex_shock_orb : Ref[@raylib.Texture?] = { val: None }

///|
/// Represents a bouncing shock orb that damages the drone on contact.
struct Orb {
  mut alive : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
}

///|
/// Activates an inactive orb slot at the given position with a random velocity.
fn spawn_orb(orbs : Array[Orb], cx : Float, cy : Float) -> Unit {
  for orb in orbs {
    if !orb.alive {
      orb.alive = true
      orb.x = cx
      orb.y = cy
      orb.vx = Float::from_int(@raylib.get_random_value(-180, 180))
      orb.vy = Float::from_int(@raylib.get_random_value(-180, 180))
      break
    }
  }
}

///|
/// Deactivates all orbs, clearing the field of shock hazards.
fn reset_orbs(orbs : Array[Orb]) -> Unit {
  for orb in orbs {
    orb.alive = false
  }
}

///|
/// Returns a random screen coordinate with the given pixel margin from each edge.
fn random_point(margin : Int) -> (Float, Float) {
  (
    Float::from_int(@raylib.get_random_value(margin, sw - margin)),
    Float::from_int(@raylib.get_random_value(margin + 60, sh - margin)),
  )
}

///|
/// Returns the squared Euclidean distance between two points.
fn dist_sq(ax : Float, ay : Float, bx : Float, by : Float) -> Float {
  let dx = ax - bx
  let dy = ay - by
  dx * dx + dy * dy
}

///|
/// Loads one generated Drone Delivery texture.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "drone_delivery_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads generated Drone Delivery render assets.
fn load_assets() -> Unit {
  tex_city_background.val = Some(load_art_texture("city_background.png"))
  tex_drone.val = Some(load_art_texture("drone_sprite.png"))
  tex_pickup_pad.val = Some(load_art_texture("pickup_pad.png"))
  tex_dropoff_pad.val = Some(load_art_texture("dropoff_pad.png"))
  tex_shock_orb.val = Some(load_art_texture("shock_orb.png"))
}

///|
/// Unloads generated Drone Delivery render assets.
fn unload_assets() -> Unit {
  fn unload(texture_ref : Ref[@raylib.Texture?]) -> Unit {
    match texture_ref.val {
      Some(texture) => {
        @raylib.unload_texture(texture)
        texture_ref.val = None
      }
      None => ()
    }
  }

  unload(tex_city_background)
  unload(tex_drone)
  unload(tex_pickup_pad)
  unload(tex_dropoff_pad)
  unload(tex_shock_orb)
}

///|
/// Draws a texture cover-cropped into a destination rectangle.
fn draw_texture_cover(
  texture : @raylib.Texture,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  tint : @raylib.Color,
) -> Unit {
  let source_w : Float = Float::from_int(texture.width())
  let source_h : Float = Float::from_int(texture.height())
  let source_ratio : Float = source_w / source_h
  let dest_ratio : Float = w / h

  let mut src_x : Float = 0.0
  let mut src_y : Float = 0.0
  let mut src_w : Float = source_w
  let mut src_h : Float = source_h

  if source_ratio > dest_ratio {
    src_w = source_h * dest_ratio
    src_x = (source_w - src_w) * 0.5
  } else if source_ratio < dest_ratio {
    src_h = source_w / dest_ratio
    src_y = (source_h - src_h) * 0.5
  }

  @raylib.draw_texture_pro(
    texture,
    @raylib.Rectangle::new(src_x, src_y, src_w, src_h),
    @raylib.Rectangle::new(x, y, w, h),
    @raylib.Vector2::new(0.0, 0.0),
    0.0,
    tint,
  )
}

///|
/// Draws a texture centered on the destination point.
fn draw_texture_centered(
  texture : @raylib.Texture,
  cx : Float,
  cy : Float,
  w : Float,
  h : Float,
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
    @raylib.Rectangle::new(cx, cy, w, h),
    @raylib.Vector2::new(w * 0.5, h * 0.5),
    0.0,
    tint,
  )
}

///|
/// Draws a generated sprite scaled to fit a centered box.
fn draw_texture_fit(
  texture : @raylib.Texture,
  x : Float,
  y : Float,
  max_w : Float,
  max_h : Float,
  tint : @raylib.Color,
) -> Unit {
  let source_w : Float = Float::from_int(texture.width())
  let source_h : Float = Float::from_int(texture.height())
  let source_ratio : Float = source_w / source_h
  let box_ratio : Float = max_w / max_h
  let mut w : Float = max_w
  let mut h : Float = max_h
  if source_ratio > box_ratio {
    h = max_w / source_ratio
  } else {
    w = max_h * source_ratio
  }
  draw_texture_centered(texture, x, y, w, h, tint)
}

///|
/// Draws the generated fixed city background.
fn draw_city_background_art() -> Bool {
  match tex_city_background.val {
    Some(texture) => {
      draw_texture_cover(
        texture,
        0.0,
        0.0,
        Float::from_int(sw),
        Float::from_int(sh),
        @raylib.white,
      )
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(6, 10, 18, 32))
      true
    }
    None => false
  }
}

///|
/// Draws the generated pickup pad art.
fn draw_pickup_art(x : Int, y : Int) -> Bool {
  match tex_pickup_pad.val {
    Some(texture) => {
      draw_texture_fit(
        texture,
        Float::from_int(x),
        Float::from_int(y),
        58.0,
        72.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Draws the generated drop-off pad art.
fn draw_dropoff_art(x : Int, y : Int) -> Bool {
  match tex_dropoff_pad.val {
    Some(texture) => {
      draw_texture_fit(
        texture,
        Float::from_int(x),
        Float::from_int(y),
        68.0,
        76.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Draws the generated shock orb art.
fn draw_shock_orb_art(x : Int, y : Int) -> Bool {
  match tex_shock_orb.val {
    Some(texture) => {
      draw_texture_fit(
        texture,
        Float::from_int(x),
        Float::from_int(y),
        34.0,
        34.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Draws the generated drone art.
fn draw_drone_art(x : Int, y : Int, has_package : Bool, turbo : Bool) -> Bool {
  match tex_drone.val {
    Some(texture) => {
      @raylib.draw_ellipse(
        x,
        y + 14,
        34.0,
        10.0,
        @raylib.Color::new(0, 8, 16, 104),
      )
      if turbo {
        @raylib.draw_circle(x, y, 34.0, @raylib.Color::new(96, 224, 255, 52))
      }
      draw_texture_fit(
        texture,
        Float::from_int(x),
        Float::from_int(y),
        76.0,
        60.0,
        if has_package {
          @raylib.Color::new(255, 232, 154, 255)
        } else {
          @raylib.white
        },
      )
      true
    }
    None => false
  }
}

///|
/// Initializes the window and runs the drone delivery game loop.
fn main {
  @raylib.init_window(sw, sh, "Drone Delivery 2026")
  defer @raylib.close_window()
  @raylib.set_target_fps(60)
  @draw.init_font()
  defer @draw.cleanup()
  load_assets()
  defer unload_assets()

  let orbs : Array[Orb] = Array::makei(110, fn(_i) {
    { alive: false, x: 0.0, y: 0.0, vx: 0.0, vy: 0.0 }
  })

  let mut drone_x : Float = Float::from_int(sw / 2)
  let mut drone_y : Float = Float::from_int(sh / 2)
  let mut battery : Float = 100.0
  let mut heat : Float = 0.0

  let mut has_package = false
  let mut pick_x : Float = 0.0
  let mut pick_y : Float = 0.0
  let mut drop_x : Float = 0.0
  let mut drop_y : Float = 0.0

  let mut timer : Float = 90.0
  let mut score = 0
  let mut deliveries = 0
  let mut combo = 0
  let mut over = false
  let mut msg = "WASD/Arrows move, avoid shock orbs, pick P and deliver D"

  let (px0, py0) = random_point(120)
  pick_x = px0
  pick_y = py0
  let (dx0, dy0) = random_point(120)
  drop_x = dx0
  drop_y = dy0

  let mut orb_spawn_tick : Float = 0.0

  while !@raylib.window_should_close() {
    let frame_dt = @raylib.get_frame_time()
    let dt = if frame_dt > 0.05F { 0.05F } else { frame_dt }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      drone_x = Float::from_int(sw / 2)
      drone_y = Float::from_int(sh / 2)
      battery = 100.0
      heat = 0.0
      has_package = false
      let (p1x, p1y) = random_point(120)
      pick_x = p1x
      pick_y = p1y
      let (d1x, d1y) = random_point(120)
      drop_x = d1x
      drop_y = d1y
      timer = 90.0
      score = 0
      deliveries = 0
      combo = 0
      over = false
      msg = "Route reset."
      reset_orbs(orbs)
      orb_spawn_tick = 0.0
    }

    if !over {
      timer = timer - dt
      if timer <= 0.0 {
        timer = 0.0
        over = true
        msg = "Shift ended."
      }

      let mut mx : Float = (0.0 : Float)
      let mut my : Float = (0.0 : Float)
      if @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft) {
        mx = mx - (1.0 : Float)
      }
      if @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight) {
        mx = mx + (1.0 : Float)
      }
      if @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp) {
        my = my - (1.0 : Float)
      }
      if @raylib.is_key_down(@raylib.KeyS) ||
        @raylib.is_key_down(@raylib.KeyDown) {
        my = my + (1.0 : Float)
      }

      let turbo = @raylib.is_key_down(@raylib.KeySpace) ||
        @raylib.is_key_down(@raylib.KeyJ)
      let spd : Float = if turbo { (370.0 : Float) } else { (250.0 : Float) }
      drone_x = drone_x + mx * spd * dt
      drone_y = drone_y + my * spd * dt

      if drone_x < 40.0 {
        drone_x = 40.0
      }
      if drone_x > Float::from_int(sw - 40) {
        drone_x = Float::from_int(sw - 40)
      }
      if drone_y < 80.0 {
        drone_y = 80.0
      }
      if drone_y > Float::from_int(sh - 40) {
        drone_y = Float::from_int(sh - 40)
      }

      let drain : Float = if turbo { (17.0 : Float) } else { (8.0 : Float) }
      battery = battery - dt * drain
      let heat_gain : Float = if turbo { (18.0 : Float) } else { (7.5 : Float) }
      heat = heat + dt * heat_gain
      heat = heat - dt * (9.0 : Float)
      if heat < 0.0 {
        heat = 0.0
      }

      if battery <= 0.0 {
        battery = 0.0
        over = true
        msg = "Battery depleted."
      }
      if heat >= 100.0 {
        heat = 100.0
        over = true
        msg = "Drone overheated."
      }

      orb_spawn_tick = orb_spawn_tick + dt
      if orb_spawn_tick >= 0.55 {
        orb_spawn_tick = orb_spawn_tick - 0.55
        let ox = Float::from_int(@raylib.get_random_value(80, sw - 80))
        let oy = Float::from_int(@raylib.get_random_value(100, sh - 80))
        spawn_orb(orbs, ox, oy)
      }

      for orb in orbs {
        if !orb.alive {
          continue
        }

        orb.x = orb.x + orb.vx * dt
        orb.y = orb.y + orb.vy * dt

        if orb.x < 20.0 || orb.x > Float::from_int(sw - 20) {
          orb.vx = -orb.vx
        }
        if orb.y < 70.0 || orb.y > Float::from_int(sh - 20) {
          orb.vy = -orb.vy
        }

        if dist_sq(drone_x, drone_y, orb.x, orb.y) < 26.0 * 26.0 {
          orb.alive = false
          combo = 0
          score = score - 40
          battery = battery - 9.0
          heat = heat + 20.0
          msg = "Shock hit!"
        }
      }

      if !has_package {
        if dist_sq(drone_x, drone_y, pick_x, pick_y) < 28.0 * 28.0 {
          has_package = true
          timer = timer + 7.0
          if timer > 99.0 {
            timer = 99.0
          }
          msg = "Package picked. Deliver to D."
        }
      } else if dist_sq(drone_x, drone_y, drop_x, drop_y) < 28.0 * 28.0 {
        has_package = false
        deliveries = deliveries + 1
        combo = combo + 1
        let gain = 120 + combo * 20
        score = score + gain
        timer = timer + 4.0
        if timer > 99.0 {
          timer = 99.0
        }
        msg = "Delivery complete +\{gain}."

        let (pnx, pny) = random_point(120)
        pick_x = pnx
        pick_y = pny
        let (dnx, dny) = random_point(120)
        drop_x = dnx
        drop_y = dny
      }

      // Passive score over distance flown
      score = score + (spd * dt * (0.02 : Float)).to_int()
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(18, 21, 32, 255))

    if !draw_city_background_art() {
      // City blocks
      for gx in 0..<7 {
        for gy in 0..<4 {
          let bx = 42 + gx * 155
          let by = 90 + gy * 155
          @raylib.draw_rectangle(
            bx,
            by,
            110,
            110,
            @raylib.Color::new(33, 38, 50, 255),
          )
          @raylib.draw_rectangle_lines(
            bx,
            by,
            110,
            110,
            @raylib.Color::new(55, 63, 83, 255),
          )
        }
      }
    }

    if !has_package {
      if !draw_pickup_art(pick_x.to_int(), pick_y.to_int()) {
        @raylib.draw_circle(
          pick_x.to_int(),
          pick_y.to_int(),
          16.0,
          @raylib.lime,
        )
        @draw.draw_text(
          "P",
          (pick_x - 6.0).to_int(),
          (pick_y - 11.0).to_int(),
          24,
          @raylib.black,
        )
      }
    } else if !draw_dropoff_art(drop_x.to_int(), drop_y.to_int()) {
      @raylib.draw_circle(
        drop_x.to_int(),
        drop_y.to_int(),
        16.0,
        @raylib.orange,
      )
      @draw.draw_text(
        "D",
        (drop_x - 7.0).to_int(),
        (drop_y - 11.0).to_int(),
        24,
        @raylib.black,
      )
    }

    for orb in orbs {
      if orb.alive {
        if !draw_shock_orb_art(orb.x.to_int(), orb.y.to_int()) {
          @raylib.draw_circle(
            orb.x.to_int(),
            orb.y.to_int(),
            11.0,
            @raylib.skyblue,
          )
          @raylib.draw_circle_lines(
            orb.x.to_int(),
            orb.y.to_int(),
            11.0,
            @raylib.white,
          )
        }
      }
    }

    let turbo_vis = !over &&
      (
        @raylib.is_key_down(@raylib.KeySpace) ||
        @raylib.is_key_down(@raylib.KeyJ)
      )
    let body = if has_package { @raylib.gold } else { @raylib.raywhite }
    if !draw_drone_art(
        drone_x.to_int(),
        drone_y.to_int(),
        has_package,
        turbo_vis,
      ) {
      @raylib.draw_circle(drone_x.to_int(), drone_y.to_int(), 14.0, body)
      @raylib.draw_line(
        (drone_x - 22.0).to_int(),
        drone_y.to_int(),
        (drone_x + 22.0).to_int(),
        drone_y.to_int(),
        @raylib.gray,
      )
      @raylib.draw_line(
        drone_x.to_int(),
        (drone_y - 22.0).to_int(),
        drone_x.to_int(),
        (drone_y + 22.0).to_int(),
        @raylib.gray,
      )
    }

    @raylib.draw_rectangle(0, 0, sw, 144, @raylib.Color::new(8, 10, 16, 166))
    @draw.draw_text("DRONE DELIVERY 2026", 20, 16, 40, @raylib.skyblue)
    @draw.draw_text("Score \{score}", 20, 64, 30, @raylib.white)
    @draw.draw_text("Deliveries \{deliveries}", 220, 64, 30, @raylib.lime)
    @draw.draw_text("Combo x\{combo}", 460, 64, 30, @raylib.yellow)

    let t = timer.to_int()
    @draw.draw_text(
      "Time \{t}s",
      660,
      64,
      30,
      if t < 20 {
        @raylib.red
      } else {
        @raylib.orange
      },
    )

    @draw.draw_text("Battery", 20, 104, 24, @raylib.green)
    @raylib.draw_rectangle(
      110,
      110,
      230,
      14,
      @raylib.Color::new(20, 38, 24, 255),
    )
    @raylib.draw_rectangle(
      110,
      110,
      (battery * 2.3).to_int(),
      14,
      @raylib.green,
    )

    @draw.draw_text("Heat", 360, 104, 24, @raylib.red)
    @raylib.draw_rectangle(
      430,
      110,
      230,
      14,
      @raylib.Color::new(45, 20, 20, 255),
    )
    @raylib.draw_rectangle(430, 110, (heat * 2.3).to_int(), 14, @raylib.red)

    @raylib.draw_rectangle(
      20,
      694,
      sw - 40,
      30,
      @raylib.Color::new(8, 10, 16, 220),
    )
    @draw.draw_text(msg, 28, 699, 20, @raylib.raywhite)

    if over {
      @raylib.draw_rectangle(
        290,
        250,
        540,
        180,
        @raylib.fade(@raylib.black, 0.82),
      )
      @draw.draw_text("SHIFT OVER", 430, 308, 50, @raylib.orange)
      @draw.draw_text("Press R to restart", 430, 366, 34, @raylib.white)
    }

    @fps.draw()
    @raylib.end_drawing()
  }
}
