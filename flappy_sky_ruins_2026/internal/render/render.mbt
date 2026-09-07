///|

///|
/// Generated full-screen sky ruins background texture.
let tex_sky_ruins_background : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated player bird texture.
let tex_player_bird : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated standard gate pillar texture.
let tex_gate_pillar : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated beam hazard pillar texture.
let tex_beam_pillar : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated spinner hazard texture.
let tex_spinner_core : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated score pickup texture.
let tex_pickup_score : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated boost pickup texture.
let tex_pickup_boost : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated shield pickup texture.
let tex_pickup_shield : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated heart pickup texture.
let tex_pickup_heart : Ref[@raylib.Texture?] = { val: None, }

///|
/// Loads one generated Flappy Sky Ruins texture.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "flappy_sky_ruins_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads generated Flappy Sky Ruins render assets.
pub fn load_assets() -> Unit {
  tex_sky_ruins_background.val = Some(
    load_art_texture("sky_ruins_background.png"),
  )
  tex_player_bird.val = Some(load_art_texture("player_bird.png"))
  tex_gate_pillar.val = Some(load_art_texture("gate_pillar.png"))
  tex_beam_pillar.val = Some(load_art_texture("beam_pillar.png"))
  tex_spinner_core.val = Some(load_art_texture("spinner_core.png"))
  tex_pickup_score.val = Some(load_art_texture("pickup_score.png"))
  tex_pickup_boost.val = Some(load_art_texture("pickup_boost.png"))
  tex_pickup_shield.val = Some(load_art_texture("pickup_shield.png"))
  tex_pickup_heart.val = Some(load_art_texture("pickup_heart.png"))
}

///|
/// Unloads generated Flappy Sky Ruins render assets.
pub fn unload_assets() -> Unit {
  fn unload(texture_ref : Ref[@raylib.Texture?]) -> Unit {
    match texture_ref.val {
      Some(texture) => {
        @raylib.unload_texture(texture)
        texture_ref.val = None
      }
      None => ()
    }
  }

  unload(tex_sky_ruins_background)
  unload(tex_player_bird)
  unload(tex_gate_pillar)
  unload(tex_beam_pillar)
  unload(tex_spinner_core)
  unload(tex_pickup_score)
  unload(tex_pickup_boost)
  unload(tex_pickup_shield)
  unload(tex_pickup_heart)
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
  flip_y : Bool,
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
    @raylib.Rectangle::new(
      src_x,
      if flip_y {
        src_y + src_h
      } else {
        src_y
      },
      src_w,
      if flip_y {
        -src_h
      } else {
        src_h
      },
    ),
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
/// Draws generated full-screen sky ruins background art.
fn draw_sky_ruins_background(tint : @raylib.Color) -> Bool {
  match tex_sky_ruins_background.val {
    Some(texture) => {
      draw_texture_cover(
        texture,
        0.0,
        0.0,
        Float::from_int(@types.screen_w),
        Float::from_int(@types.screen_h),
        tint,
        false,
      )
      true
    }
    None => false
  }
}

///|
/// Returns the generated obstacle pillar texture for a given obstacle kind.
fn obstacle_pillar_texture(kind : @types.ObstacleKind) -> @raylib.Texture? {
  match kind {
    Beam => tex_beam_pillar.val
    Gate | Spinner => tex_gate_pillar.val
  }
}

///|
/// Draws generated obstacle pillar art into a collision rectangle.
fn draw_obstacle_pillar_art(
  kind : @types.ObstacleKind,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  flip_y : Bool,
) -> Bool {
  if h <= 0 {
    return true
  }

  match obstacle_pillar_texture(kind) {
    Some(texture) => {
      let tint = match kind {
        Beam => @raylib.Color::new(255, 214, 190, 246)
        Spinner => @raylib.Color::new(222, 218, 255, 246)
        Gate => @raylib.white
      }
      draw_texture_cover(
        texture,
        Float::from_int(x),
        Float::from_int(y),
        Float::from_int(w),
        Float::from_int(h),
        tint,
        flip_y,
      )
      true
    }
    None => false
  }
}

///|
/// Returns the generated pickup texture for a pickup kind.
fn pickup_texture(kind : @types.PickupKind) -> @raylib.Texture? {
  match kind {
    Score => tex_pickup_score.val
    Boost => tex_pickup_boost.val
    Shield => tex_pickup_shield.val
    Heart => tex_pickup_heart.val
  }
}

///|
/// Returns a sine wave value sampled from `game.ui_t` scaled by `k`, used to animate background elements.
fn @types.Game::bg_wave(game : @types.Game, k : Float) -> Float {
  Float::from_double(@math.sin((game.ui_t * k).to_double()))
}

///|
/// Draws the animated background with pulsing ambient circles and layered horizontal gradient bands.
fn @types.Game::draw_bg(game : @types.Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(8, 12, 22, 255))

  if draw_sky_ruins_background(@raylib.white) {
    @raylib.draw_rectangle(
      0,
      0,
      @types.screen_w,
      @types.screen_h,
      @raylib.Color::new(7, 12, 22, 58),
    )
    return
  }

  let w0 : Float = game.bg_wave(0.66)
  let w1 : Float = game.bg_wave(0.93)

  @raylib.draw_circle(
    220,
    150,
    210.0 + w0 * 18.0,
    @raylib.Color::new(28, 52, 90, 44),
  )
  @raylib.draw_circle(
    @types.screen_w - 260,
    170,
    204.0 - w1 * 16.0,
    @raylib.Color::new(70, 38, 72, 34),
  )

  for i in 0..<16 {
    let y : Int = i * 64
    @raylib.draw_rectangle(
      0,
      y,
      @types.screen_w,
      46,
      @raylib.Color::new(
        12 + i * 7 % 20,
        16 + i * 8 % 20,
        24 + i * 10 % 24,
        14 + i * 8 % 28,
      ),
    )
  }
}

///|
/// Draws the world boundary rectangle with layered horizontal stripes and an animated horizon line.
fn @types.Game::draw_world_back(game : @types.Game) -> Unit {
  match tex_sky_ruins_background.val {
    Some(texture) => {
      draw_texture_cover(
        texture,
        Float::from_int(@types.world_x0),
        Float::from_int(@types.world_y0),
        Float::from_int(@types.world_w),
        Float::from_int(@types.world_h),
        @raylib.white,
        false,
      )
      @raylib.draw_rectangle(
        @types.world_x0,
        @types.world_y0,
        @types.world_w,
        @types.world_h,
        @raylib.Color::new(12, 22, 38, 82),
      )
    }
    None =>
      @raylib.draw_rectangle(
        @types.world_x0,
        @types.world_y0,
        @types.world_w,
        @types.world_h,
        @raylib.Color::new(20, 30, 48, 228),
      )
  }

  @raylib.draw_rectangle_lines(
    @types.world_x0,
    @types.world_y0,
    @types.world_w,
    @types.world_h,
    @raylib.Color::new(150, 192, 226, 210),
  )

  let wave : Float = game.bg_wave(1.5)
  if tex_sky_ruins_background.val is None {
    for i in 0..<20 {
      let y : Int = @types.world_y0 + i * 48
      @raylib.draw_rectangle(
        @types.world_x0 + 6,
        y,
        @types.world_w - 12,
        20,
        @raylib.Color::new(
          28 + i * 4 % 18,
          42 + i * 6 % 22,
          64 + i * 7 % 28,
          26 + i * 4 % 22,
        ),
      )
    }
  }

  @raylib.draw_line(
    @types.world_x0,
    @types.world_y0 + 120 + (wave * 6.0).to_int(),
    @types.world_x0 + @types.world_w,
    @types.world_y0 + 120 - (wave * 6.0).to_int(),
    @raylib.Color::new(154, 202, 236, 62),
  )
}

///|
/// Draws an obstacle's top and bottom pillars with color based on kind, and adds a rotating arm for spinner obstacles.
fn draw_obstacle(ob : @types.Obstacle) -> Unit {
  if !ob.active {
    return
  }

  let gy : Float = @types.obstacle_gap_mid(ob)
  let gh : Float = ob.gap_h

  let top_h : Int = (gy - gh / 2.0 - @types.world_top()).to_int()
  let bot_y : Int = (gy + gh / 2.0).to_int()
  let bot_h : Int = (@types.world_bottom() - gy - gh / 2.0).to_int()

  let x : Int = ob.x.to_int()
  let w : Int = ob.w.to_int()

  let c0 : @raylib.Color = match ob.kind {
    Beam => @raylib.Color::new(170, 104, 96, 244)
    Spinner => @raylib.Color::new(118, 100, 156, 244)
    Gate => @raylib.Color::new(98, 136, 182, 244)
  }

  if !draw_obstacle_pillar_art(ob.kind, x, @types.world_y0, w, top_h, false) {
    @raylib.draw_rectangle(x, @types.world_y0, w, top_h, c0)
  }
  if !draw_obstacle_pillar_art(ob.kind, x, bot_y, w, bot_h, true) {
    @raylib.draw_rectangle(x, bot_y, w, bot_h, c0)
  }

  if top_h > 0 {
    @raylib.draw_rectangle_lines(
      x,
      @types.world_y0,
      w,
      top_h,
      @raylib.Color::new(208, 220, 238, 186),
    )
  }
  if bot_h > 0 {
    @raylib.draw_rectangle_lines(
      x,
      bot_y,
      w,
      bot_h,
      @raylib.Color::new(208, 220, 238, 186),
    )
  }

  match ob.kind {
    Spinner => {
      let cx : Int = x + w / 2
      let cy : Int = gy.to_int()
      let arm : Int = (gh * 0.40).to_int()

      match tex_spinner_core.val {
        Some(texture) =>
          draw_texture_fit(
            texture,
            Float::from_int(cx),
            Float::from_int(cy),
            98.0,
            98.0,
            ob.phase * 57.2958,
            @raylib.white,
          )
        None => {
          let ang : Float = ob.phase
          let ax : Int = (Float::from_int(cx) +
          @math.cosf(ang) * Float::from_int(arm)).to_int()
          let ay : Int = (Float::from_int(cy) +
          @math.sinf(ang) * Float::from_int(arm)).to_int()

          @raylib.draw_line(
            cx,
            cy,
            ax,
            ay,
            @raylib.Color::new(238, 212, 146, 236),
          )
          @raylib.draw_circle(
            cx,
            cy,
            7.0,
            @raylib.Color::new(255, 226, 164, 236),
          )
          @raylib.draw_circle(
            ax,
            ay,
            8.0,
            @raylib.Color::new(255, 174, 122, 236),
          )
        }
      }
    }
    Gate | Beam => ()
  }
}

///|
/// Returns the display color for a pickup based on its kind (score/boost/shield/heart).
fn pickup_color(kind : @types.PickupKind) -> @raylib.Color {
  match kind {
    Score => @raylib.Color::new(120, 218, 255, 250)
    Boost => @raylib.Color::new(255, 200, 122, 250)
    Shield => @raylib.Color::new(172, 206, 255, 250)
    Heart => @raylib.Color::new(255, 130, 152, 250)
  }
}

///|
/// Draws a pickup as a pulsing colored circle with an outer glow ring.
fn draw_pickup(pk : @types.Pickup) -> Unit {
  if !pk.active {
    return
  }

  let pulse : Float = @math.sinf(pk.phase)
  let base_r : Float = match pk.kind {
    Score => 14.0
    Boost | Shield | Heart => 18.0
  }
  let r : Float = base_r + pulse * 2.0

  let c : @raylib.Color = pickup_color(pk.kind)

  match pickup_texture(pk.kind) {
    Some(texture) =>
      draw_texture_fit(
        texture,
        pk.x,
        pk.y,
        r * 2.6,
        r * 2.6,
        pulse * 4.0,
        @raylib.white,
      )
    None => @raylib.draw_circle(pk.x.to_int(), pk.y.to_int(), r, c)
  }
  @raylib.draw_circle_lines(
    pk.x.to_int(),
    pk.y.to_int(),
    r + 3.0,
    @raylib.Color::new(246, 250, 255, 206),
  )
}

///|
/// Draws the player bird with a tilt-based wing triangle, eye dot, and an optional shield ring when the shield is active.
fn @types.Game::draw_player(game : @types.Game) -> Unit {
  let tilt : Float = @types.clampf(game.vy * 0.0014, -0.35, 0.45)

  if game.boost_on {
    @raylib.draw_circle(
      (game.px - 38.0).to_int(),
      game.py.to_int(),
      18.0,
      @raylib.Color::new(255, 186, 94, 92),
    )
    @raylib.draw_circle(
      (game.px - 58.0).to_int(),
      (game.py + 4.0).to_int(),
      12.0,
      @raylib.Color::new(104, 202, 255, 72),
    )
  }

  match tex_player_bird.val {
    Some(texture) =>
      draw_texture_fit(
        texture,
        game.px,
        game.py,
        88.0,
        78.0,
        tilt * 57.2958,
        @raylib.white,
      )
    None => {
      @raylib.draw_circle(
        game.px.to_int(),
        game.py.to_int(),
        @types.player_r,
        @raylib.Color::new(104, 228, 170, 252),
      )
      @raylib.draw_circle(
        game.px.to_int() - 6,
        game.py.to_int() - 7,
        @types.player_r * 0.36,
        @raylib.Color::new(210, 252, 230, 186),
      )

      let wing_y : Int = (game.py + tilt * 26.0).to_int()
      @raylib.draw_triangle(
        @raylib.Vector2::new(game.px - 6.0, Float::from_int(wing_y)),
        @raylib.Vector2::new(game.px - 30.0, Float::from_int(wing_y - 12)),
        @raylib.Vector2::new(game.px - 26.0, Float::from_int(wing_y + 14)),
        @raylib.Color::new(92, 194, 146, 246),
      )

      @raylib.draw_circle(
        game.px.to_int() + 7,
        game.py.to_int() - 6,
        4.0,
        @raylib.Color::new(22, 32, 30, 236),
      )
    }
  }

  if game.shield_t > 0.0 {
    let pulse : Float = Float::from_double(
      @math.sin((game.ui_t * 8.0).to_double()),
    )
    @raylib.draw_circle_lines(
      game.px.to_int(),
      game.py.to_int(),
      @types.player_r + 8.0 + pulse * 2.0,
      @raylib.Color::new(176, 220, 255, 238),
    )
  }
}

///|
/// Draws a pulsing golden ring at the hint target y position in the center of the world when a hint is active.
fn @types.Game::draw_hint(game : @types.Game) -> Unit {
  if game.hint_t <= 0.0 {
    return
  }

  let x : Int = @types.world_x0 + @types.world_w / 2
  let y : Int = game.hint_y.to_int()
  let pulse : Float = Float::from_double(
    @math.sin((game.ui_t * 9.0).to_double()),
  )

  @raylib.draw_circle_lines(
    x,
    y,
    30.0 + pulse * 4.0,
    @raylib.Color::new(255, 232, 130, 242),
  )
}

///|
/// Draws all active particles as small circles with color and opacity based on their kind and remaining life.
fn @types.Game::draw_particles(game : @types.Game) -> Unit {
  for particle in game.particles {
    if !particle.active {
      continue
    }

    let a : Int = if particle.life > 0.7 {
      236
    } else if particle.life > 0.4 {
      196
    } else {
      132
    }

    let c : @raylib.Color = if particle.kind == 2 {
      @raylib.Color::new(255, 170, 122, a)
    } else if particle.kind == 1 {
      @raylib.Color::new(255, 224, 138, a)
    } else {
      @raylib.Color::new(138, 232, 180, a)
    }

    @raylib.draw_circle(
      particle.x.to_int(),
      particle.y.to_int(),
      1.0 + particle.size,
      c,
    )
  }
}

///|
/// Draws a touch button rectangle at `rect` with `label` centered inside, using `tint` when `active` and a default dark fill otherwise.
fn draw_touch_button(
  label : String,
  rect : (Int, Int, Int, Int),
  active : Bool,
  tint : @raylib.Color,
) -> Unit {
  @raylib.draw_rectangle(
    rect.0,
    rect.1,
    rect.2,
    rect.3,
    if active {
      tint
    } else {
      @raylib.Color::new(42, 60, 86, 206)
    },
  )
  @raylib.draw_rectangle_lines(
    rect.0,
    rect.1,
    rect.2,
    rect.3,
    @raylib.Color::new(184, 216, 242, 218),
  )

  @draw.draw_text(
    label,
    rect.0 + rect.2 / 2 - @draw.measure_text(label, 30) / 2,
    rect.1 + rect.3 / 2 - 15,
    30,
    @raylib.Color::new(246, 252, 255, 248),
  )
}

///|
/// Draws the on-screen FLAP, BOOST, RESTART, and HINT touch buttons in the side panel area during active play.
fn @types.Game::draw_controls(game : @types.Game) -> Unit {
  match game.state {
    Play => ()
    Title | Result => return
  }

  let flap = @types.btn_flap_rect()
  let boost = @types.btn_boost_rect()
  let rs = @types.btn_restart_rect()
  let hint = @types.btn_hint_rect()

  let flap_on : Bool = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    flap.0,
    flap.1,
    flap.2,
    flap.3,
  )
  let boost_on : Bool = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    boost.0,
    boost.1,
    boost.2,
    boost.3,
  )
  let rs_on : Bool = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    rs.0,
    rs.1,
    rs.2,
    rs.3,
  )
  let hint_on : Bool = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    hint.0,
    hint.1,
    hint.2,
    hint.3,
  )

  draw_touch_button(
    "FLAP",
    flap,
    flap_on,
    @raylib.Color::new(92, 150, 206, 230),
  )
  draw_touch_button(
    if game.boost_meter > 0.08 {
      "BOOST"
    } else {
      "BOOST 0"
    },
    boost,
    boost_on || game.boost_on,
    @raylib.Color::new(194, 140, 92, 230),
  )
  draw_touch_button("RESTART", rs, rs_on, @raylib.Color::new(134, 96, 106, 230))
  draw_touch_button(
    "HINT \{game.hint_left}",
    hint,
    hint_on,
    @raylib.Color::new(166, 134, 84, 230),
  )
}

///|
/// Draws the side panel with title, score, best score, lives, level, time, distance, combo, boost bar, shield status, control reference, and the transient message box.
fn @types.Game::draw_panel(game : @types.Game) -> Unit {
  let px : Int = @types.panel_x0
  let py : Int = 20
  let pw : Int = @types.panel_w
  let ph : Int = @types.screen_h - 40

  @raylib.draw_rectangle(px, py, pw, ph, @raylib.Color::new(14, 22, 36, 244))
  @raylib.draw_rectangle_lines(
    px,
    py,
    pw,
    ph,
    @raylib.Color::new(126, 170, 206, 220),
  )

  @draw.draw_text(
    "Flappy Sky Ruins",
    px + 20,
    py + 20,
    42,
    @raylib.Color::new(236, 246, 255, 248),
  )
  @draw.draw_text(
    "2026 Expedition",
    px + 20,
    py + 66,
    28,
    @raylib.Color::new(196, 220, 246, 238),
  )

  @draw.draw_text(
    "Score \{game.score}",
    px + 20,
    py + 110,
    36,
    @raylib.Color::new(226, 242, 255, 246),
  )
  @draw.draw_text(
    "Best \{game.best_score}",
    px + 252,
    py + 110,
    34,
    @raylib.Color::new(206, 228, 248, 240),
  )

  @draw.draw_text(
    "Lives \{game.lives}",
    px + 20,
    py + 154,
    30,
    @raylib.Color::new(212, 232, 252, 242),
  )
  @draw.draw_text(
    "Level \{game.level}",
    px + 176,
    py + 154,
    30,
    @raylib.Color::new(212, 232, 252, 242),
  )
  @draw.draw_text(
    "Time \{game.game_t.to_int()}s",
    px + 320,
    py + 154,
    30,
    @raylib.Color::new(212, 232, 252, 242),
  )

  @draw.draw_text(
    "Distance \{game.distance}",
    px + 20,
    py + 194,
    30,
    @raylib.Color::new(212, 232, 252, 242),
  )
  @draw.draw_text(
    "Combo x\{game.combo}",
    px + 240,
    py + 194,
    30,
    if game.combo > 1 {
      @raylib.Color::new(255, 224, 136, 248)
    } else {
      @raylib.Color::new(212, 232, 252, 242)
    },
  )

  @draw.draw_text(
    "Boost",
    px + 20,
    py + 236,
    30,
    @raylib.Color::new(220, 236, 252, 242),
  )
  @raylib.draw_rectangle(
    px + 20,
    py + 272,
    pw - 40,
    30,
    @raylib.Color::new(30, 42, 60, 220),
  )
  @raylib.draw_rectangle(
    px + 20,
    py + 272,
    ((pw - 40).to_double() * game.boost_meter.to_double()).to_int(),
    30,
    @raylib.Color::new(94, 164, 220, 236),
  )
  @raylib.draw_rectangle_lines(
    px + 20,
    py + 272,
    pw - 40,
    30,
    @raylib.Color::new(184, 214, 236, 230),
  )

  let shield_text : String = if game.shield_t > 0.0 { "ON" } else { "OFF" }
  @draw.draw_text(
    "Shield \{shield_text}",
    px + 20,
    py + 314,
    28,
    @raylib.Color::new(212, 232, 252, 242),
  )

  @draw.draw_text(
    "Controls",
    px + 20,
    py + 360,
    28,
    @raylib.Color::new(228, 242, 255, 246),
  )
  @draw.draw_text(
    "Flap: Space / Tap",
    px + 20,
    py + 392,
    24,
    @raylib.Color::new(194, 218, 242, 236),
  )
  @draw.draw_text(
    "Boost: Shift / J",
    px + 20,
    py + 418,
    24,
    @raylib.Color::new(194, 218, 242, 236),
  )
  @draw.draw_text(
    "Hint: H",
    px + 20,
    py + 444,
    24,
    @raylib.Color::new(194, 218, 242, 236),
  )
  @draw.draw_text(
    "Restart: R",
    px + 20,
    py + 470,
    24,
    @raylib.Color::new(194, 218, 242, 236),
  )

  if game.msg_t > 0.0 {
    @raylib.draw_rectangle(
      px + 20,
      py + 560,
      pw - 40,
      56,
      @raylib.Color::new(40, 58, 82, 224),
    )
    @raylib.draw_rectangle_lines(
      px + 20,
      py + 560,
      pw - 40,
      56,
      @raylib.Color::new(176, 208, 236, 230),
    )
    @draw.draw_text(
      game.msg,
      px + 30,
      py + 578,
      28,
      @raylib.Color::new(246, 252, 255, 248),
    )
  }
}

///|
/// Draws the title screen with game name, description lines, and a hoverable start button.
fn @types.Game::draw_title(game : @types.Game) -> Unit {
  @draw.draw_text(
    "Flappy Sky Ruins 2026",
    @types.screen_w / 2 - @draw.measure_text("Flappy Sky Ruins 2026", 86) / 2,
    110,
    86,
    @raylib.Color::new(238, 248, 255, 248),
  )

  @draw.draw_text(
    "Flap through collapsing ruins, collect relics, and survive for 3 minutes.",
    @types.screen_w / 2 -
    @draw.measure_text(
      "Flap through collapsing ruins, collect relics, and survive for 3 minutes.",
      34,
    ) /
    2,
    252,
    34,
    @raylib.Color::new(196, 220, 244, 238),
  )
  @draw.draw_text(
    "Mobile touch controls are built in.",
    @types.screen_w / 2 -
    @draw.measure_text("Mobile touch controls are built in.", 34) / 2,
    294,
    34,
    @raylib.Color::new(196, 220, 244, 238),
  )

  let r = @types.start_button_rect()
  let hov : Bool = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    r.0,
    r.1,
    r.2,
    r.3,
  )

  draw_touch_button("Start Run", r, hov, @raylib.Color::new(92, 150, 206, 230))
}

///|
/// Draws the result overlay panel with win/fail heading, final score, distance, level, time, and a hoverable retry button.
fn @types.Game::draw_result_overlay(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(6, 10, 16, 170),
  )

  let pw : Int = 840
  let ph : Int = 500
  let px : Int = @types.screen_w / 2 - pw / 2
  let py : Int = @types.screen_h / 2 - ph / 2

  @raylib.draw_rectangle(px, py, pw, ph, @raylib.Color::new(16, 24, 36, 246))
  @raylib.draw_rectangle_lines(
    px,
    py,
    pw,
    ph,
    @raylib.Color::new(172, 206, 236, 236),
  )

  let title : String = if game.win { "Run Complete" } else { "Run Failed" }

  @draw.draw_text(
    title,
    px + pw / 2 - @draw.measure_text(title, 64) / 2,
    py + 34,
    64,
    @raylib.Color::new(244, 250, 255, 250),
  )

  @draw.draw_text(
    "Score \{game.score}",
    px + 100,
    py + 132,
    44,
    @raylib.Color::new(226, 242, 255, 246),
  )
  @draw.draw_text(
    "Distance \{game.distance}",
    px + 100,
    py + 182,
    40,
    @raylib.Color::new(214, 232, 252, 244),
  )
  @draw.draw_text(
    "Level \{game.level}",
    px + 100,
    py + 228,
    40,
    @raylib.Color::new(214, 232, 252, 244),
  )
  @draw.draw_text(
    "Time \{game.game_t.to_int()}s",
    px + 100,
    py + 274,
    36,
    @raylib.Color::new(206, 228, 248, 238),
  )

  let r = @types.retry_button_rect()
  let hov : Bool = @types.pointer_on_rect(
    game.mouse_x,
    game.mouse_y,
    game.mouse_hold,
    game.touch_count,
    r.0,
    r.1,
    r.2,
    r.3,
  )
  draw_touch_button("Play Again", r, hov, @raylib.Color::new(96, 154, 210, 230))
}

///|
/// Draws the world background, all obstacles and pickups, the hint ring, and the player.
fn @types.Game::draw_world(game : @types.Game) -> Unit {
  game.draw_world_back()

  for obstacle in game.obstacles {
    draw_obstacle(obstacle)
  }

  for pickup in game.pickups {
    draw_pickup(pickup)
  }

  game.draw_hint()
  game.draw_player()
}

///|
/// Renders the complete frame for the current game state.
pub fn draw_frame(game : @types.Game) -> Unit {
  game.draw_bg()
  match game.state {
    Title => game.draw_title()
    Play => {
      game.draw_world()
      game.draw_particles()
      game.draw_panel()
      game.draw_controls()
    }
    Result => {
      game.draw_world()
      game.draw_particles()
      game.draw_panel()
      game.draw_controls()
      game.draw_result_overlay()
    }
  }
}
