///|
/// Screen width in pixels.
let sw : Int = 1120

///|
/// Screen height in pixels.
let sh : Int = 740

///|
/// Number of grid columns in the city zone layout.
let cols : Int = 5

///|
/// Number of grid rows in the city zone layout.
let rows : Int = 3

///|
/// Generated city grid background texture.
let tex_city_background : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated intact house texture.
let tex_house_intact : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated burned house texture.
let tex_house_burned : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated fire truck texture.
let tex_fire_truck : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated flame texture.
let tex_flame : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated water spray texture.
let tex_water_spray : Ref[@raylib.Texture?] = { val: None, }

///|
/// Returns the pixel X coordinate for the center of grid column c.
fn cell_x(c : Int) -> Float {
  150.0 + Float::from_int(c) * 180.0
}

///|
/// Returns the pixel Y coordinate for the center of grid row r.
fn cell_y(r : Int) -> Float {
  200.0 + Float::from_int(r) * 170.0
}

///|
/// Represents a city zone with a fire intensity level and whether its building is intact.
struct Zone {
  mut fire : Float
  mut has_house : Bool
}

///|
/// Loads one generated Firefighting Command texture.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "firefighting_command_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads generated Firefighting Command render assets.
fn load_assets() -> Unit {
  tex_city_background.val = Some(load_art_texture("city_grid_background.png"))
  tex_house_intact.val = Some(load_art_texture("house_intact.png"))
  tex_house_burned.val = Some(load_art_texture("house_burned.png"))
  tex_fire_truck.val = Some(load_art_texture("fire_truck.png"))
  tex_flame.val = Some(load_art_texture("flame.png"))
  tex_water_spray.val = Some(load_art_texture("water_spray.png"))
}

///|
/// Unloads generated Firefighting Command render assets.
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
  unload(tex_house_intact)
  unload(tex_house_burned)
  unload(tex_fire_truck)
  unload(tex_flame)
  unload(tex_water_spray)
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
/// Draws a texture centered on a destination point.
fn draw_texture_centered(
  texture : @raylib.Texture,
  cx : Float,
  cy : Float,
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
    @raylib.Rectangle::new(cx, cy, w, h),
    @raylib.Vector2::new(w * 0.5, h * 0.5),
    rotation,
    tint,
  )
}

///|
/// Draws a generated texture scaled to fit a centered box.
fn draw_texture_fit(
  texture : @raylib.Texture,
  cx : Float,
  cy : Float,
  max_w : Float,
  max_h : Float,
  rotation : Float,
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
  draw_texture_centered(texture, cx, cy, w, h, rotation, tint)
}

///|
/// Draws the generated city map background.
fn draw_city_background() -> Bool {
  match tex_city_background.val {
    Some(texture) => {
      draw_texture_cover(
        texture,
        0.0,
        110.0,
        Float::from_int(sw),
        Float::from_int(sh - 170),
        @raylib.white,
      )
      @raylib.draw_rectangle(
        0,
        110,
        sw,
        sh - 170,
        @raylib.Color::new(18, 24, 32, 42),
      )
      true
    }
    None => false
  }
}

///|
/// Draws generated house art for a grid zone.
fn draw_house_art(x : Float, y : Float, standing : Bool) -> Bool {
  let texture_ref = if standing { tex_house_intact } else { tex_house_burned }
  match texture_ref.val {
    Some(texture) => {
      let tint = if standing {
        @raylib.white
      } else {
        @raylib.Color::new(210, 210, 210, 255)
      }
      draw_texture_fit(texture, x, y - 4.0, 142.0, 122.0, 0.0, tint)
      true
    }
    None => false
  }
}

///|
/// Draws generated flame art over a burning house.
fn draw_flame_art(x : Float, y : Float, fire : Float) -> Bool {
  match tex_flame.val {
    Some(texture) => {
      let size : Float = 44.0 + fire * 0.38
      draw_texture_fit(
        texture,
        x + 8.0,
        y - 20.0,
        size,
        size * 1.18,
        0.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Draws the generated fire truck art.
fn draw_truck_art(x : Float, y : Float) -> Bool {
  match tex_fire_truck.val {
    Some(texture) => {
      @raylib.draw_ellipse(
        x.to_int(),
        (y + 84.0).to_int(),
        34.0,
        8.0,
        @raylib.Color::new(0, 0, 0, 82),
      )
      draw_texture_fit(texture, x, y + 64.0, 70.0, 74.0, 0.0, @raylib.white)
      true
    }
    None => false
  }
}

///|
/// Draws generated water spray from the truck toward the current zone.
fn draw_water_spray_art(x : Float, y : Float) -> Bool {
  match tex_water_spray.val {
    Some(texture) => {
      draw_texture_fit(
        texture,
        x + 4.0,
        y + 18.0,
        126.0,
        70.0,
        -66.0,
        @raylib.Color::new(214, 236, 255, 184),
      )
      true
    }
    None => false
  }
}

///|
/// Returns the flat array index for grid cell at column c and row r.
fn idx(c : Int, r : Int) -> Int {
  r * cols + c
}

///|
/// Resets all zones to their initial state with intact buildings and seeds random fires.
fn reset_zones(zones : Array[Zone]) -> Unit {
  for r in 0..<rows {
    for c in 0..<cols {
      let i = idx(c, r)
      zones[i].fire = 0.0
      zones[i].has_house = true
    }
  }

  for _k in 0..<2 {
    let c = @raylib.get_random_value(0, cols - 1)
    let r = @raylib.get_random_value(0, rows - 1)
    zones[idx(c, r)].fire = Float::from_int(@raylib.get_random_value(28, 46))
  }
}

///|
/// Returns the number of zones currently on fire.
fn active_fire_count(zones : Array[Zone]) -> Int {
  let mut n = 0
  for zone in zones {
    if zone.fire > 0.0 {
      n = n + 1
    }
  }
  n
}

///|
/// Initializes and runs the Firefighting Command 2026 game loop.
fn main {
  @raylib.init_window(sw, sh, "Firefighting Command 2026")
  defer @raylib.close_window()
  defer @draw.cleanup()
  @raylib.set_target_fps(60)
  @draw.init_font()
  load_assets()
  defer unload_assets()

  let zones : Array[Zone] = Array::makei(cols * rows, fn(_i) {
    { fire: 0.0, has_house: true, }
  })
  reset_zones(zones)

  let mut truck_c = 2
  let mut truck_r = 1
  let mut truck_x : Float = cell_x(truck_c)
  let mut truck_y : Float = cell_y(truck_r)

  let mut water : Float = 100.0
  let mut spread_tick : Float = 0.0
  let mut spawn_tick : Float = 0.0
  let mut budget = 0
  let mut saved = 0
  let mut lost = 0
  let mut lives = 4
  let mut over = false
  let mut msg = "WASD/Arrows move, Space spray, R restart"

  while !@raylib.window_should_close() {
    let frame_dt = @raylib.get_frame_time()
    let dt = if frame_dt > 0.05F { 0.05F } else { frame_dt }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      reset_zones(zones)
      truck_c = 2
      truck_r = 1
      truck_x = cell_x(truck_c)
      truck_y = cell_y(truck_r)
      water = 100.0
      spread_tick = 0.0
      spawn_tick = 0.0
      budget = 0
      saved = 0
      lost = 0
      lives = 4
      over = false
      msg = "City response restarted."
    }

    if !over {
      if @raylib.is_key_pressed(@raylib.KeyA) ||
        @raylib.is_key_pressed(@raylib.KeyLeft) {
        if truck_c > 0 {
          truck_c = truck_c - 1
        }
      }
      if @raylib.is_key_pressed(@raylib.KeyD) ||
        @raylib.is_key_pressed(@raylib.KeyRight) {
        if truck_c < cols - 1 {
          truck_c = truck_c + 1
        }
      }
      if @raylib.is_key_pressed(@raylib.KeyW) ||
        @raylib.is_key_pressed(@raylib.KeyUp) {
        if truck_r > 0 {
          truck_r = truck_r - 1
        }
      }
      if @raylib.is_key_pressed(@raylib.KeyS) ||
        @raylib.is_key_pressed(@raylib.KeyDown) {
        if truck_r < rows - 1 {
          truck_r = truck_r + 1
        }
      }
      truck_x = cell_x(truck_c)
      truck_y = cell_y(truck_r)

      let at = idx(truck_c, truck_r)
      if zones[at].fire <= 0.0 {
        water = water + dt * 14.0
      }
      if water > 100.0 {
        water = 100.0
      }

      if (
          @raylib.is_key_down(@raylib.KeySpace) ||
          @raylib.is_key_down(@raylib.KeyJ)
        ) &&
        water > 0.0 {
        if zones[at].fire > 0.0 {
          zones[at].fire = zones[at].fire - dt * 48.0
          water = water - dt * 24.0
          if zones[at].fire <= 0.0 {
            zones[at].fire = 0.0
            saved = saved + 1
            budget = budget + 30
            msg = "Fire extinguished."
          }
        }
      }

      spread_tick = spread_tick + dt
      if spread_tick >= 1.0 {
        spread_tick = spread_tick - 1.0

        for r in 0..<rows {
          for c in 0..<cols {
            let i = idx(c, r)
            if zones[i].fire > 0.0 {
              zones[i].fire = zones[i].fire + 7.0

              if zones[i].fire >= 100.0 {
                zones[i].fire = 0.0
                zones[i].has_house = false
                lives = lives - 1
                lost = lost + 1
                msg = "A building burned down."
              } else {
                let mut target = -1
                let mut tries = 0
                while tries < 6 && target < 0 {
                  let dir = @raylib.get_random_value(0, 3)
                  let nc = if dir == 0 {
                    c + 1
                  } else if dir == 1 {
                    c - 1
                  } else {
                    c
                  }
                  let nr = if dir == 2 {
                    r + 1
                  } else if dir == 3 {
                    r - 1
                  } else {
                    r
                  }
                  if nc >= 0 && nc < cols && nr >= 0 && nr < rows {
                    let ni = idx(nc, nr)
                    if zones[ni].has_house && zones[ni].fire <= 0.0 {
                      target = ni
                    }
                  }
                  tries = tries + 1
                }
                if target >= 0 {
                  zones[target].fire = zones[target].fire + 18.0
                }
              }
            }
          }
        }
      }

      spawn_tick = spawn_tick + dt
      if spawn_tick >= 4.6 {
        spawn_tick = spawn_tick - 4.6
        let c = @raylib.get_random_value(0, cols - 1)
        let r = @raylib.get_random_value(0, rows - 1)
        let i = idx(c, r)
        if zones[i].has_house && zones[i].fire <= 0.0 {
          zones[i].fire = Float::from_int(@raylib.get_random_value(24, 42))
          msg = "New fire reported."
        }
      }

      if lives <= 0 {
        lives = 0
        over = true
        msg = "City overwhelmed."
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(28, 34, 42, 255))

    ignore(draw_city_background())

    @raylib.draw_rectangle(0, 0, sw, 130, @raylib.Color::new(42, 52, 66, 255))

    for r in 0..<rows {
      for c in 0..<cols {
        let i = idx(c, r)
        let x = cell_x(c)
        let y = cell_y(r)
        let house_color = if zones[i].has_house {
          @raylib.Color::new(196, 210, 224, 255)
        } else {
          @raylib.Color::new(66, 66, 66, 255)
        }
        if !draw_house_art(x, y, zones[i].has_house) {
          @raylib.draw_rectangle(
            (x - 64.0).to_int(),
            (y - 56.0).to_int(),
            128,
            108,
            house_color,
          )
          @raylib.draw_rectangle_lines(
            (x - 64.0).to_int(),
            (y - 56.0).to_int(),
            128,
            108,
            @raylib.darkgray,
          )
        }

        if zones[i].fire > 0.0 {
          let f = zones[i].fire
          if !draw_flame_art(x, y, f) {
            @raylib.draw_circle(
              (x - 20.0).to_int(),
              (y - 18.0).to_int(),
              12.0 + f * 0.09,
              @raylib.orange,
            )
            @raylib.draw_circle(
              (x + 16.0).to_int(),
              (y - 6.0).to_int(),
              10.0 + f * 0.08,
              @raylib.red,
            )
          }
          @draw.draw_text(
            "\{f.to_int()}%",
            (x - 22.0).to_int(),
            (y + 30.0).to_int(),
            18,
            @raylib.black,
          )
        }
      }
    }

    let current_zone = idx(truck_c, truck_r)
    let spraying = !over &&
      (
        @raylib.is_key_down(@raylib.KeySpace) ||
        @raylib.is_key_down(@raylib.KeyJ)
      ) &&
      water > 0.0 &&
      zones[current_zone].fire > 0.0
    if spraying {
      if !draw_water_spray_art(truck_x, truck_y) {
        @raylib.draw_line_ex(
          @raylib.Vector2::new(truck_x, truck_y + 56.0),
          @raylib.Vector2::new(truck_x, truck_y - 16.0),
          6.0,
          @raylib.skyblue,
        )
      }
    }

    if !draw_truck_art(truck_x, truck_y) {
      @raylib.draw_rectangle(
        (truck_x - 30.0).to_int(),
        (truck_y + 58.0).to_int(),
        60,
        26,
        @raylib.red,
      )
      @raylib.draw_rectangle(
        (truck_x - 18.0).to_int(),
        (truck_y + 45.0).to_int(),
        36,
        13,
        @raylib.white,
      )
      @raylib.draw_circle(
        (truck_x - 18.0).to_int(),
        (truck_y + 85.0).to_int(),
        6.0,
        @raylib.black,
      )
      @raylib.draw_circle(
        (truck_x + 18.0).to_int(),
        (truck_y + 85.0).to_int(),
        6.0,
        @raylib.black,
      )
    }

    @draw.draw_text("FIREFIGHTING COMMAND 2026", 20, 18, 38, @raylib.skyblue)
    @draw.draw_text("Budget \{budget}", 20, 64, 28, @raylib.white)
    @draw.draw_text("Saved \{saved}", 220, 64, 28, @raylib.lime)
    @draw.draw_text("Lost \{lost}", 380, 64, 28, @raylib.orange)
    @draw.draw_text(
      "Lives \{lives}",
      520,
      64,
      28,
      if lives <= 1 {
        @raylib.red
      } else {
        @raylib.yellow
      },
    )

    @draw.draw_text("Water", 740, 60, 24, @raylib.skyblue)
    @raylib.draw_rectangle(
      810,
      64,
      250,
      16,
      @raylib.Color::new(30, 40, 58, 255),
    )
    @raylib.draw_rectangle(810, 64, (water * 2.5).to_int(), 16, @raylib.skyblue)

    let active = active_fire_count(zones)
    @draw.draw_text("Active Fires: \{active}", 20, 650, 24, @raylib.raywhite)
    @raylib.draw_rectangle(
      20,
      688,
      sw - 40,
      30,
      @raylib.Color::new(12, 17, 24, 220),
    )
    @draw.draw_text(msg, 28, 693, 20, @raylib.raywhite)

    if over {
      @raylib.draw_rectangle(
        300,
        250,
        520,
        180,
        @raylib.fade(@raylib.black, 0.82),
      )
      @draw.draw_text("CITY LOST", 455, 312, 52, @raylib.red)
      @draw.draw_text("Press R to restart", 430, 370, 34, @raylib.white)
    }

    @fps.draw()
    @raylib.end_drawing()
  }
}
