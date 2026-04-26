///|
/// Screen width in pixels.
let sw : Int = 1100

///|
/// Screen height in pixels.
let sh : Int = 720

///|
/// Generated lake background texture.
let tex_lake_background : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated boat sprite texture.
let tex_boat : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated common fish texture.
let tex_fish_common : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated silver fish texture.
let tex_fish_silver : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated golden fish texture.
let tex_fish_golden : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated hook sprite texture.
let tex_hook : Ref[@raylib.Texture?] = { val: None }

///|
/// Represents a fish with position, velocity, kind, size, and alive state.
struct Fish {
  mut alive : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut kind : Int // 0 common, 1 silver, 2 golden
  mut size : Float
}

///|
/// Loads one generated Fishing Tycoon texture.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "fishing_tycoon_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads generated Fishing Tycoon render assets.
fn load_assets() -> Unit {
  tex_lake_background.val = Some(load_art_texture("lake_background.png"))
  tex_boat.val = Some(load_art_texture("boat_sprite.png"))
  tex_fish_common.val = Some(load_art_texture("fish_common.png"))
  tex_fish_silver.val = Some(load_art_texture("fish_silver.png"))
  tex_fish_golden.val = Some(load_art_texture("fish_golden.png"))
  tex_hook.val = Some(load_art_texture("hook_sprite.png"))
}

///|
/// Unloads generated Fishing Tycoon render assets.
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

  unload(tex_lake_background)
  unload(tex_boat)
  unload(tex_fish_common)
  unload(tex_fish_silver)
  unload(tex_fish_golden)
  unload(tex_hook)
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
/// Draws a texture centered on a destination point with optional horizontal flip.
fn draw_texture_centered(
  texture : @raylib.Texture,
  cx : Float,
  cy : Float,
  w : Float,
  h : Float,
  rotation : Float,
  tint : @raylib.Color,
  flip_x : Bool,
) -> Unit {
  let source_w : Float = Float::from_int(texture.width())
  let source_x : Float = if flip_x { source_w } else { 0.0 }
  let src_w : Float = if flip_x { -source_w } else { source_w }
  @raylib.draw_texture_pro(
    texture,
    @raylib.Rectangle::new(
      source_x,
      0.0,
      src_w,
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
  flip_x : Bool,
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
  draw_texture_centered(texture, cx, cy, w, h, rotation, tint, flip_x)
}

///|
/// Draws the generated lake background.
fn draw_lake_background() -> Bool {
  match tex_lake_background.val {
    Some(texture) => {
      draw_texture_cover(
        texture,
        0.0,
        0.0,
        Float::from_int(sw),
        Float::from_int(sh),
        @raylib.white,
      )
      @raylib.draw_rectangle(
        0,
        boat_waterline(),
        sw,
        sh - boat_waterline(),
        @raylib.Color::new(7, 45, 78, 44),
      )
      true
    }
    None => false
  }
}

///|
/// Returns the waterline used for subtle background tinting and fallback water.
fn boat_waterline() -> Int {
  180
}

///|
/// Draws the generated fishing boat.
fn draw_boat_art(boat_x : Float, boat_y : Float) -> Bool {
  match tex_boat.val {
    Some(texture) => {
      @raylib.draw_ellipse(
        boat_x.to_int(),
        (boat_y + 26.0).to_int(),
        68.0,
        12.0,
        @raylib.Color::new(0, 0, 0, 78),
      )
      draw_texture_fit(
        texture,
        boat_x,
        boat_y - 25.0,
        154.0,
        108.0,
        0.0,
        @raylib.white,
        false,
      )
      true
    }
    None => false
  }
}

///|
/// Draws the generated hook art.
fn draw_hook_art(hook_x : Float, hook_y : Float) -> Bool {
  match tex_hook.val {
    Some(texture) => {
      draw_texture_fit(
        texture,
        hook_x,
        hook_y + 14.0,
        28.0,
        56.0,
        0.0,
        @raylib.white,
        false,
      )
      true
    }
    None => false
  }
}

///|
/// Returns the generated fish texture for the given fish kind.
fn fish_texture(kind : Int) -> @raylib.Texture? {
  if kind == 0 {
    tex_fish_common.val
  } else if kind == 1 {
    tex_fish_silver.val
  } else {
    tex_fish_golden.val
  }
}

///|
/// Draws generated fish art, flipped to face the swim direction.
fn draw_fish_art(fish : Fish) -> Bool {
  match fish_texture(fish.kind) {
    Some(texture) => {
      draw_texture_fit(
        texture,
        fish.x,
        fish.y,
        fish.size * 3.8,
        fish.size * 2.35,
        0.0,
        @raylib.white,
        fish.vx > 0.0,
      )
      true
    }
    None => false
  }
}

///|
/// Returns the display color for a fish based on its kind (0 common, 1 silver, 2 golden).
fn fish_color(kind : Int) -> @raylib.Color {
  if kind == 0 {
    @raylib.lime
  } else if kind == 1 {
    @raylib.skyblue
  } else {
    @raylib.gold
  }
}

///|
/// Returns the coin value earned when selling a caught fish of the given kind.
fn fish_value(kind : Int) -> Int {
  if kind == 0 {
    18
  } else if kind == 1 {
    42
  } else {
    88
  }
}

///|
/// Spawns a new fish in the first available slot, choosing rarity based on rare_bonus.
fn spawn_fish(fishes : Array[Fish], rare_bonus : Int) -> Unit {
  for fish in fishes {
    if !fish.alive {
      let roll = @raylib.get_random_value(0, 99)
      let kind = if roll < 62 - rare_bonus {
        0
      } else if roll < 92 {
        1
      } else {
        2
      }

      let from_left = @raylib.get_random_value(0, 1) == 0
      fish.alive = true
      fish.kind = kind
      fish.size = if kind == 0 { 16.0 } else if kind == 1 { 22.0 } else { 28.0 }
      fish.x = if from_left { -40.0 } else { Float::from_int(sw + 40) }
      fish.y = Float::from_int(@raylib.get_random_value(220, sh - 70))
      let speed = Float::from_int(@raylib.get_random_value(60, 130))
      fish.vx = if from_left { speed } else { -speed }
      break
    }
  }
}

///|
/// Deactivates all fish in the pool, clearing the water for a new fishing session.
fn reset_fishes(fishes : Array[Fish]) -> Unit {
  for fish in fishes {
    fish.alive = false
  }
}

///|
/// Initializes and runs the Fishing Tycoon 2026 game loop.
fn main {
  @raylib.init_window(sw, sh, "Fishing Tycoon 2026")
  defer @raylib.close_window()
  defer @draw.cleanup()
  @raylib.set_target_fps(60)
  @draw.init_font()
  load_assets()
  defer unload_assets()

  let fishes : Array[Fish] = Array::makei(90, fn(_i) {
    { alive: false, x: 0.0, y: 0.0, vx: 0.0, kind: 0, size: 16.0 }
  })

  let boat_y : Float = 150.0
  let mut boat_x : Float = Float::from_int(sw / 2)

  let mut hook_x : Float = boat_x
  let mut hook_y : Float = boat_y + 20.0
  let mut hook_state = 0 // 0 idle, 1 dropping, 2 rising
  let mut max_depth : Float = 560.0
  let mut reel_speed : Float = 280.0
  let mut drop_speed : Float = 240.0

  let mut captured_idx = -1
  let mut spawn_tick : Float = 0.0
  let mut day_timer : Float = 180.0

  let mut money = 120
  let mut total_catch = 0
  let mut total_gold = 0

  let mut rare_bonus = 0
  let mut over = false
  let mut msg = "A/D move boat, Space/J cast hook, 1/2/3 buy upgrades"

  while !@raylib.window_should_close() {
    let frame_dt = @raylib.get_frame_time()
    let dt = if frame_dt > 0.05F { 0.05F } else { frame_dt }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      boat_x = Float::from_int(sw / 2)
      hook_x = boat_x
      hook_y = boat_y + 20.0
      hook_state = 0
      max_depth = 560.0
      reel_speed = 280.0
      drop_speed = 240.0
      captured_idx = -1
      reset_fishes(fishes)
      spawn_tick = 0.0
      day_timer = 180.0
      money = 120
      total_catch = 0
      total_gold = 0
      rare_bonus = 0
      over = false
      msg = "New fishing day started."
    }

    if !over {
      day_timer = day_timer - dt
      if day_timer <= 0.0 {
        day_timer = 0.0
        over = true
        msg = "Market closed for the day."
      }

      if @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft) {
        boat_x = boat_x - 260.0 * dt
      }
      if @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight) {
        boat_x = boat_x + 260.0 * dt
      }

      if boat_x < 80.0 {
        boat_x = 80.0
      }
      if boat_x > Float::from_int(sw - 80) {
        boat_x = Float::from_int(sw - 80)
      }

      if hook_state == 0 {
        hook_x = boat_x
        hook_y = boat_y + 20.0
        if @raylib.is_key_pressed(@raylib.KeySpace) ||
          @raylib.is_key_pressed(@raylib.KeyJ) {
          hook_state = 1
          captured_idx = -1
          msg = "Line cast."
        }
      }

      if hook_state == 1 {
        hook_y = hook_y + drop_speed * dt
        if hook_y >= max_depth {
          hook_state = 2
        }
      }

      if hook_state == 2 {
        hook_y = hook_y - reel_speed * dt
        if hook_y <= boat_y + 20.0 {
          hook_y = boat_y + 20.0
          hook_state = 0
          if captured_idx >= 0 {
            let gain = fish_value(fishes[captured_idx].kind)
            money = money + gain
            total_gold = total_gold + gain
            total_catch = total_catch + 1
            msg = "Sold catch for \{gain} coins."
            fishes[captured_idx].alive = false
            captured_idx = -1
          }
        }
      }

      if @raylib.is_key_pressed(@raylib.KeyOne) {
        let cost = 90
        if money >= cost {
          money = money - cost
          reel_speed = reel_speed + 45.0
          msg = "Upgrade bought: faster reel."
        }
      }
      if @raylib.is_key_pressed(@raylib.KeyTwo) {
        let cost = 120
        if money >= cost {
          money = money - cost
          max_depth = max_depth + 48.0
          if max_depth > Float::from_int(sh - 30) {
            max_depth = Float::from_int(sh - 30)
          }
          msg = "Upgrade bought: deeper line."
        }
      }
      if @raylib.is_key_pressed(@raylib.KeyThree) {
        let cost = 160
        if money >= cost {
          money = money - cost
          rare_bonus = rare_bonus + 8
          if rare_bonus > 34 {
            rare_bonus = 34
          }
          msg = "Upgrade bought: better bait."
        }
      }

      spawn_tick = spawn_tick + dt
      if spawn_tick >= 0.42 {
        spawn_tick = spawn_tick - 0.42
        spawn_fish(fishes, rare_bonus)
      }

      for i in 0..<fishes.length() {
        if !fishes[i].alive {
          continue
        }

        if captured_idx == i {
          fishes[i].x = hook_x
          fishes[i].y = hook_y + 10.0
          continue
        }

        fishes[i].x = fishes[i].x + fishes[i].vx * dt

        if fishes[i].x < -60.0 || fishes[i].x > Float::from_int(sw + 60) {
          fishes[i].alive = false
        }

        if captured_idx < 0 && hook_state != 0 {
          let dx = fishes[i].x - hook_x
          let dy = fishes[i].y - hook_y
          let r = fishes[i].size * 0.8
          if dx * dx + dy * dy <= r * r {
            captured_idx = i
            hook_state = 2
            msg = "Fish hooked! Reel it in."
          }
        }
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(14, 24, 42, 255))

    if !draw_lake_background() {
      @raylib.draw_rectangle(
        0,
        0,
        sw,
        boat_y.to_int() + 30,
        @raylib.Color::new(35, 78, 122, 255),
      )
      @raylib.draw_rectangle(
        0,
        boat_y.to_int() + 30,
        sw,
        sh - (boat_y.to_int() + 30),
        @raylib.Color::new(18, 92, 148, 255),
      )
    }

    if !draw_boat_art(boat_x, boat_y) {
      @raylib.draw_rectangle(
        (boat_x - 48.0).to_int(),
        (boat_y - 14.0).to_int(),
        96,
        24,
        @raylib.brown,
      )
      @raylib.draw_triangle(
        @raylib.Vector2::new(boat_x - 10.0, boat_y - 16.0),
        @raylib.Vector2::new(boat_x - 10.0, boat_y - 70.0),
        @raylib.Vector2::new(boat_x + 24.0, boat_y - 40.0),
        @raylib.white,
      )
    }

    @raylib.draw_line_ex(
      @raylib.Vector2::new(boat_x + 36.0, boat_y - 44.0),
      @raylib.Vector2::new(hook_x, hook_y),
      2.0,
      @raylib.lightgray,
    )
    if !draw_hook_art(hook_x, hook_y) {
      @raylib.draw_circle(hook_x.to_int(), hook_y.to_int(), 5.0, @raylib.white)
    }

    for fish in fishes {
      if fish.alive {
        if !draw_fish_art(fish) {
          let c = fish_color(fish.kind)
          @raylib.draw_ellipse(
            fish.x.to_int(),
            fish.y.to_int(),
            fish.size,
            fish.size * 0.62,
            c,
          )
          @raylib.draw_triangle(
            @raylib.Vector2::new(fish.x - fish.size, fish.y),
            @raylib.Vector2::new(fish.x - fish.size - 11.0, fish.y - 8.0),
            @raylib.Vector2::new(fish.x - fish.size - 11.0, fish.y + 8.0),
            c,
          )
          @raylib.draw_circle(
            (fish.x + fish.size * 0.35).to_int(),
            (fish.y - 2.0).to_int(),
            2.5,
            @raylib.black,
          )
        }
      }
    }

    @raylib.draw_rectangle(12, 10, 760, 96, @raylib.Color::new(7, 15, 24, 150))
    @draw.draw_text("FISHING TYCOON 2026", 20, 18, 42, @raylib.skyblue)
    @draw.draw_text("Money \{money}", 20, 66, 30, @raylib.gold)
    @draw.draw_text("Catch \{total_catch}", 220, 66, 30, @raylib.white)
    @draw.draw_text("Sales \{total_gold}", 380, 66, 30, @raylib.white)

    let tsec = day_timer.to_int()
    @draw.draw_text(
      "Time \{tsec}s",
      560,
      66,
      30,
      if tsec < 30 {
        @raylib.red
      } else {
        @raylib.lime
      },
    )

    @raylib.draw_rectangle(12, 607, 680, 66, @raylib.Color::new(7, 15, 24, 145))
    @draw.draw_text(
      "1 Reel+ (90)  2 Depth+ (120)  3 Bait+ (160)", 20, 618, 28, @raylib.raywhite,
    )
    @draw.draw_text(
      "Reel \{reel_speed.to_int()}  Depth \{max_depth.to_int()}  Bait bonus \{rare_bonus}",
      20,
      650,
      26,
      @raylib.lightgray,
    )

    @raylib.draw_rectangle(
      20,
      678,
      sw - 40,
      30,
      @raylib.Color::new(8, 12, 18, 220),
    )
    @draw.draw_text(msg, 28, 684, 20, @raylib.white)

    if over {
      @raylib.draw_rectangle(
        290,
        250,
        520,
        170,
        @raylib.fade(@raylib.black, 0.82),
      )
      @draw.draw_text("DAY OVER", 455, 298, 52, @raylib.orange)
      @draw.draw_text("Press R for next day", 430, 360, 32, @raylib.white)
    }

    @fps.draw()
    @raylib.end_drawing()
  }
}
