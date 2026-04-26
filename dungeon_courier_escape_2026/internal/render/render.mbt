///|
/// Draws `text` horizontally centered on the screen at vertical position `y` with the given font size and color.
fn draw_center_text(
  text : String,
  y : Int,
  size : Int,
  color : @raylib.Color,
) -> Unit {
  let tw = @draw.measure_text(text, size)
  @draw.draw_text(text, @types.screen_w / 2 - tw / 2, y, size, color)
}

///|
/// Draws a labeled horizontal progress bar at `(x, y)` sized `w×h`, filled proportionally to `ratio` in `fill` color.
fn draw_meter(
  label : String,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  ratio : Float,
  fill : @raylib.Color,
) -> Unit {
  let r = @types.clampf(ratio, 0.0, 1.0)

  @draw.draw_text(label, x, y - 22, 20, @raylib.Color::new(210, 226, 244, 245))

  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(22, 28, 40, 230))
  @raylib.draw_rectangle(x, y, (Float::from_int(w) * r).to_int(), h, fill)
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(124, 146, 170, 210),
  )
}

///|
/// Generated dungeon floor background texture.
let tex_floor : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated courier character texture.
let tex_courier : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated guard character texture.
let tex_guard : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated parcel pickup texture.
let tex_parcel : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated exit marker texture.
let tex_exit : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated trap rune texture.
let tex_trap : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated smoke cloud texture.
let tex_smoke : Ref[@raylib.Texture?] = { val: None }

///|
/// Loads one generated Dungeon Courier Escape texture.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "dungeon_courier_escape_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads generated Dungeon Courier Escape render assets.
pub fn load_assets() -> Unit {
  tex_floor.val = Some(load_art_texture("dungeon_floor_background.png"))
  tex_courier.val = Some(load_art_texture("courier_sprite.png"))
  tex_guard.val = Some(load_art_texture("guard_sprite.png"))
  tex_parcel.val = Some(load_art_texture("parcel_sprite.png"))
  tex_exit.val = Some(load_art_texture("exit_marker.png"))
  tex_trap.val = Some(load_art_texture("trap_rune.png"))
  tex_smoke.val = Some(load_art_texture("smoke_cloud.png"))
}

///|
/// Unloads generated Dungeon Courier Escape render assets.
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

  unload(tex_floor)
  unload(tex_courier)
  unload(tex_guard)
  unload(tex_parcel)
  unload(tex_exit)
  unload(tex_trap)
  unload(tex_smoke)
}

///|
/// Returns true when the generated dungeon floor art is loaded.
fn has_floor_art() -> Bool {
  match tex_floor.val {
    Some(_) => true
    None => false
  }
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
/// Draws the generated dungeon floor inside the playable world.
fn draw_floor_art() -> Bool {
  match tex_floor.val {
    Some(texture) => {
      draw_texture_cover(
        texture,
        @types.world_left,
        @types.world_top,
        @types.world_w(),
        @types.world_h(),
        @raylib.white,
      )
      @raylib.draw_rectangle(
        @types.world_left.to_int(),
        @types.world_top.to_int(),
        @types.world_w().to_int(),
        @types.world_h().to_int(),
        @raylib.Color::new(4, 8, 14, 34),
      )
      true
    }
    None => false
  }
}

///|
/// Draws the generated exit marker art.
fn draw_exit_art(exit : @types.ExitMarker, radius : Float) -> Bool {
  match tex_exit.val {
    Some(texture) => {
      draw_texture_fit(
        texture,
        exit.x,
        exit.y,
        radius * 2.75,
        radius * 2.75,
        0.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Draws the generated trap rune art.
fn draw_trap_art(trap : @types.Trap, alpha : Int) -> Bool {
  match tex_trap.val {
    Some(texture) => {
      draw_texture_fit(
        texture,
        trap.x,
        trap.y,
        trap.radius * 3.15,
        trap.radius * 3.15,
        trap.blink_t * 16.0,
        @raylib.Color::new(255, 196, 236, alpha.clamp(min=70, max=255)),
      )
      true
    }
    None => false
  }
}

///|
/// Draws the generated parcel pickup art.
fn draw_parcel_art(x : Float, y : Float, size : Float) -> Bool {
  match tex_parcel.val {
    Some(texture) => {
      draw_texture_fit(texture, x, y, size, size, 0.0, @raylib.white)
      true
    }
    None => false
  }
}

///|
/// Draws the generated smoke cloud art.
fn draw_smoke_art(smoke : @types.Smoke, life_ratio : Float) -> Bool {
  match tex_smoke.val {
    Some(texture) => {
      draw_texture_fit(
        texture,
        smoke.x,
        smoke.y,
        smoke.radius * 2.08,
        smoke.radius * 2.08,
        smoke.life * 8.0,
        @raylib.Color::new(
          218,
          226,
          238,
          ((86.0 : Float) * life_ratio).to_int(),
        ),
      )
      true
    }
    None => false
  }
}

///|
/// Draws the generated guard art.
fn draw_guard_art(g : @types.Guard, alert_boost : Float) -> Bool {
  match tex_guard.val {
    Some(texture) => {
      @raylib.draw_circle(
        g.x.to_int(),
        g.y.to_int(),
        20.0 + alert_boost * 5.0,
        @raylib.Color::new(255, 90, 104, 44),
      )
      draw_texture_fit(
        texture,
        g.x,
        g.y - 4.0,
        38.0,
        52.0,
        g.dir_deg - 135.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Draws the generated courier art.
fn draw_courier_art(game : @types.Game) -> Bool {
  match tex_courier.val {
    Some(texture) => {
      @raylib.draw_circle(
        game.player.x.to_int(),
        game.player.y.to_int(),
        @types.player_radius + 12.0,
        @raylib.Color::new(70, 172, 140, 48),
      )
      draw_texture_fit(
        texture,
        game.player.x,
        game.player.y - 5.0,
        42.0,
        56.0,
        game.player.facing_deg + 45.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Draws the dungeon floor with a scrolling grid, border walls, and decorative pillars.
fn @types.Game::draw_background(game : @types.Game) -> Unit {
  @raylib.clear_background(@types.col_bg_bottom())

  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @types.col_bg_top(),
    @types.col_bg_bottom(),
  )

  if !draw_floor_art() {
    @raylib.draw_rectangle(
      @types.world_left.to_int(),
      @types.world_top.to_int(),
      @types.world_w().to_int(),
      @types.world_h().to_int(),
      @types.col_floor(),
    )
  }

  let grid_step = 48
  let shift = (game.wave_clock * 26.0).to_int() % grid_step

  for x = @types.world_left.to_int() - grid_step
      x <= @types.world_right.to_int() + grid_step
      x = x + grid_step {
    @raylib.draw_line(
      x - shift,
      @types.world_top.to_int(),
      x - shift,
      @types.world_bottom.to_int(),
      @types.col_floor_grid(),
    )
  }

  for y = @types.world_top.to_int() - grid_step
      y <= @types.world_bottom.to_int() + grid_step
      y = y + grid_step {
    @raylib.draw_line(
      @types.world_left.to_int(),
      y - shift,
      @types.world_right.to_int(),
      y - shift,
      @types.col_floor_grid(),
    )
  }

  @raylib.draw_rectangle_lines(
    @types.world_left.to_int(),
    @types.world_top.to_int(),
    @types.world_w().to_int(),
    @types.world_h().to_int(),
    @raylib.Color::new(130, 148, 168, 240),
  )

  if !has_floor_art() {
    // Decorative dungeon pillars.
    for i in 0..<8 {
      let px = @types.world_left + 90.0 + Float::from_int(i % 4) * 320.0
      let py = @types.world_top + 120.0 + Float::from_int(i / 4) * 380.0
      @raylib.draw_rectangle(
        (px - 24.0).to_int(),
        (py - 24.0).to_int(),
        48,
        48,
        @types.col_wall(),
      )
      @raylib.draw_rectangle_lines(
        (px - 24.0).to_int(),
        (py - 24.0).to_int(),
        48,
        48,
        @raylib.Color::new(150, 172, 192, 180),
      )
    }
  }
}

///|
/// Draws each active exit as a pulsing blue ring with an "EXIT" label.
fn @types.Game::draw_exits(game : @types.Game) -> Unit {
  for i in 0..<game.exits.length() {
    if !game.exits[i].active {
      continue
    }

    let pulse : Float = (0.5 : Float) +
      (0.5 : Float) * @math.sinf(game.wave_clock * 2.3 + Float::from_int(i))
    let r : Float = game.exits[i].radius + pulse * (6.0 : Float)

    @raylib.draw_circle(
      game.exits[i].x.to_int(),
      game.exits[i].y.to_int(),
      r + 10.0,
      @raylib.Color::new(90, 136, 232, 58),
    )
    if !draw_exit_art(game.exits[i], r) {
      @raylib.draw_circle(
        game.exits[i].x.to_int(),
        game.exits[i].y.to_int(),
        r,
        @raylib.Color::new(50, 90, 178, 130),
      )
      @raylib.draw_circle_lines(
        game.exits[i].x.to_int(),
        game.exits[i].y.to_int(),
        r,
        @types.col_exit(),
      )
    }

    @draw.draw_text(
      "EXIT",
      game.exits[i].x.to_int() - 24,
      game.exits[i].y.to_int() - 8,
      18,
      @raylib.Color::new(224, 236, 255, 240),
    )
  }
}

///|
/// Draws each active trap as a blinking pink circle with a small center dot.
fn @types.Game::draw_traps(game : @types.Game) -> Unit {
  for trap in game.traps {
    if !trap.active {
      continue
    }

    let blink : Float = (0.5 : Float) +
      (0.5 : Float) * @math.sinf(trap.blink_t * 5.2)
    let alpha = 70 + (blink * 120.0).to_int()

    @raylib.draw_circle(
      trap.x.to_int(),
      trap.y.to_int(),
      trap.radius + 8.0,
      @raylib.Color::new(230, 76, 124, alpha / 3),
    )

    if !draw_trap_art(trap, alpha) {
      @raylib.draw_circle_lines(
        trap.x.to_int(),
        trap.y.to_int(),
        trap.radius,
        @raylib.Color::new(250, 98, 146, alpha),
      )

      @raylib.draw_circle(
        trap.x.to_int(),
        trap.y.to_int(),
        4.0,
        @types.col_trap(),
      )
    }
  }
}

///|
/// Draws each active, undelivered parcel as a pulsing yellow box with a crossbar.
fn @types.Game::draw_parcels(game : @types.Game) -> Unit {
  for parcel in game.parcels {
    if !parcel.active || parcel.delivered {
      continue
    }

    let pulse : Float = (0.5 : Float) + (0.5 : Float) * @math.sinf(parcel.pulse)

    @raylib.draw_circle(
      parcel.x.to_int(),
      parcel.y.to_int(),
      (18.0 : Float) + pulse * (4.0 : Float),
      @raylib.Color::new(250, 214, 108, 58),
    )

    if !draw_parcel_art(parcel.x, parcel.y, 30.0 + pulse * 4.0) {
      @raylib.draw_rectangle(
        (parcel.x - 10.0).to_int(),
        (parcel.y - 8.0).to_int(),
        20,
        16,
        @types.col_parcel(),
      )

      @raylib.draw_line(
        parcel.x.to_int(),
        (parcel.y - 8.0).to_int(),
        parcel.x.to_int(),
        (parcel.y + 8.0).to_int(),
        @raylib.Color::new(180, 134, 64, 220),
      )
    }
  }
}

///|
/// Draws each active smoke cloud as a translucent grey circle whose opacity fades with remaining life.
fn @types.Game::draw_smokes(game : @types.Game) -> Unit {
  for smoke in game.smokes {
    if !smoke.active {
      continue
    }

    let life_ratio = @types.clampf(
      smoke.life / @types.smoke_life_secs,
      0.0,
      1.0,
    )

    if !draw_smoke_art(smoke, life_ratio) {
      @raylib.draw_circle(
        smoke.x.to_int(),
        smoke.y.to_int(),
        smoke.radius,
        @raylib.Color::new(154, 162, 176, ((56.0 : Float) * life_ratio).to_int()),
      )
      @raylib.draw_circle_lines(
        smoke.x.to_int(),
        smoke.y.to_int(),
        smoke.radius,
        @raylib.Color::new(212, 220, 236, ((136.0 : Float) * life_ratio).to_int()),
      )
    }
  }
}

///|
/// Draws a single guard with its vision cone sector, body circle, facing line, and an alert ring when alerted.
fn draw_guard(g : @types.Guard) -> Unit {
  let alert_boost = @types.clampf(g.alert_t / @types.guard_alert_hold, 0.0, 1.0)
  let cone_alpha = 44 + (alert_boost * 98.0).to_int()

  @raylib.draw_circle_sector(
    @raylib.Vector2::new(g.x, g.y),
    g.cone_range,
    g.dir_deg - g.cone_half_angle,
    g.dir_deg + g.cone_half_angle,
    28,
    @raylib.Color::new(255, 86, 112, cone_alpha),
  )

  @raylib.draw_circle_sector_lines(
    @raylib.Vector2::new(g.x, g.y),
    g.cone_range,
    g.dir_deg - g.cone_half_angle,
    g.dir_deg + g.cone_half_angle,
    20,
    @raylib.Color::new(255, 146, 166, 120),
  )

  if !draw_guard_art(g, alert_boost) {
    @raylib.draw_circle(g.x.to_int(), g.y.to_int(), 12.0, @types.col_guard())
    @raylib.draw_circle(
      g.x.to_int(),
      g.y.to_int(),
      6.0,
      @raylib.Color::new(46, 22, 32, 220),
    )
  }

  let dir_x = g.x + @math.cosf(g.dir_deg * @types.deg_to_rad) * 22.0
  let dir_y = g.y + @math.sinf(g.dir_deg * @types.deg_to_rad) * 22.0

  @raylib.draw_line_ex(
    @raylib.Vector2::new(g.x, g.y),
    @raylib.Vector2::new(dir_x, dir_y),
    3.0,
    @raylib.Color::new(255, 210, 210, 220),
  )

  if g.alert_t > 0.0 {
    @raylib.draw_circle_lines(
      g.x.to_int(),
      g.y.to_int(),
      18.0 + alert_boost * 7.0,
      @raylib.Color::new(255, 170, 180, 220),
    )
  }
}

///|
/// Draws all active guards by calling `draw_guard` for each.
fn @types.Game::draw_guards(game : @types.Game) -> Unit {
  for guard_val in game.guards {
    if guard_val.active {
      draw_guard(guard_val)
    }
  }
}

///|
/// Draws the player circle with facing line, an optional carried-parcel indicator above the sprite, and a danger ring when stealth is critically low.
fn @types.Game::draw_player(game : @types.Game) -> Unit {
  if !draw_courier_art(game) {
    @raylib.draw_circle(
      game.player.x.to_int(),
      game.player.y.to_int(),
      @types.player_radius + 10.0,
      @raylib.Color::new(70, 172, 140, 56),
    )
    @raylib.draw_circle(
      game.player.x.to_int(),
      game.player.y.to_int(),
      @types.player_radius,
      @types.col_player(),
    )
    @raylib.draw_circle(
      game.player.x.to_int(),
      game.player.y.to_int(),
      @types.player_radius * 0.45,
      @raylib.Color::new(28, 62, 58, 210),
    )
  }

  let fx = game.player.x +
    @math.cosf(game.player.facing_deg * @types.deg_to_rad) * 20.0
  let fy = game.player.y +
    @math.sinf(game.player.facing_deg * @types.deg_to_rad) * 20.0

  @raylib.draw_line_ex(
    @raylib.Vector2::new(game.player.x, game.player.y),
    @raylib.Vector2::new(fx, fy),
    3.0,
    @raylib.Color::new(220, 255, 244, 220),
  )

  if game.player.carrying_parcel >= 0 {
    if !draw_parcel_art(game.player.x, game.player.y - 28.0, 18.0) {
      @raylib.draw_rectangle(
        (game.player.x - 6.0).to_int(),
        (game.player.y - 24.0).to_int(),
        12,
        10,
        @types.col_parcel(),
      )
    }
  }

  if game.player.stealth < 25.0 {
    @raylib.draw_circle_lines(
      game.player.x.to_int(),
      game.player.y.to_int(),
      @types.player_radius + 6.0,
      @raylib.Color::new(255, 110, 122, 226),
    )
  }
}

///|
/// Draws the HUD bar with wave, delivery progress, score, smoke stock, countdown timer, health and stealth meters, control legend, and the transient hint banner.
fn @types.Game::draw_hud(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.hud_h.to_int(),
    @raylib.Color::new(8, 12, 20, 234),
  )

  @draw.draw_text(
    "Dungeon Courier Escape 2026",
    26,
    14,
    32,
    @raylib.Color::new(230, 238, 252, 244),
  )

  @draw.draw_text(
    "Wave \{game.wave}",
    30,
    54,
    26,
    @raylib.Color::new(190, 210, 236, 242),
  )

  @draw.draw_text(
    "Delivered \{game.delivered_wave}/\{game.target_deliveries}",
    190,
    54,
    26,
    @raylib.Color::new(200, 220, 244, 242),
  )

  @draw.draw_text(
    "Score \{game.score}",
    520,
    54,
    26,
    @raylib.Color::new(216, 228, 246, 242),
  )

  @draw.draw_text(
    "Smoke \{game.smoke_stock}",
    700,
    54,
    26,
    @raylib.Color::new(214, 226, 246, 242),
  )

  @draw.draw_text(
    "Time \{@types.maxf(game.time_left, 0.0).to_int()}s",
    860,
    54,
    26,
    if game.time_left < 12.0 {
      @raylib.Color::new(255, 132, 132, 248)
    } else {
      @raylib.Color::new(214, 226, 246, 242)
    },
  )

  draw_meter(
    "Health",
    1030,
    22,
    170,
    18,
    game.player.health / @types.player_health_max,
    @types.col_health(),
  )
  draw_meter(
    "Stealth",
    1230,
    22,
    170,
    18,
    game.player.stealth / @types.player_stealth_max,
    @types.col_stealth(),
  )

  @draw.draw_text(
    "Move WASD/Arrows | J pickup/drop/deliver | K smoke | Space sprint",
    26,
    @types.screen_h - 34,
    22,
    @raylib.Color::new(196, 212, 232, 230),
  )

  if game.info_t > 0.0 {
    let alpha = (@types.clampf(game.info_t / 2.4, 0.0, 1.0) * 230.0).to_int()
    let box_w = @draw.measure_text(game.hint, 28) + 44
    let box_x = @types.screen_w / 2 - box_w / 2

    @raylib.draw_rectangle(
      box_x,
      @types.screen_h - 80,
      box_w,
      44,
      @raylib.Color::new(18, 28, 40, alpha),
    )
    @raylib.draw_rectangle_lines(
      box_x,
      @types.screen_h - 80,
      box_w,
      44,
      @raylib.Color::new(152, 180, 208, alpha),
    )
    @draw.draw_text(
      game.hint,
      box_x + 20,
      @types.screen_h - 52,
      28,
      @raylib.Color::new(236, 246, 255, alpha),
    )
  }
}

///|
/// Draws a red tint over the play area whose opacity tracks `game.alarm_flash`.
fn @types.Game::draw_alarm_overlay(game : @types.Game) -> Unit {
  if game.alarm_flash <= 0.0 {
    return
  }

  let alpha = (@types.clampf(game.alarm_flash, 0.0, 1.0) * 110.0).to_int()
  @raylib.draw_rectangle(
    @types.world_left.to_int(),
    @types.world_top.to_int(),
    @types.world_w().to_int(),
    @types.world_h().to_int(),
    @raylib.Color::new(255, 60, 82, alpha),
  )
}

///|
/// Draws the title screen overlay with game title, mission summary, control reference, and a start prompt.
fn draw_title_overlay() -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(6, 10, 18, 158),
  )

  let panel_w = 930
  let panel_h = 520
  let panel_x = @types.screen_w / 2 - panel_w / 2
  let panel_y = @types.screen_h / 2 - panel_h / 2

  @raylib.draw_rectangle(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(12, 18, 30, 244),
  )
  @raylib.draw_rectangle_lines(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(134, 166, 202, 230),
  )

  draw_center_text(
    "Dungeon Courier Escape",
    panel_y + 42,
    56,
    @raylib.Color::new(230, 240, 255, 248),
  )
  draw_center_text(
    "Collect parcels and deliver them before guards lock the floor.",
    panel_y + 116,
    30,
    @raylib.Color::new(188, 212, 236, 236),
  )

  @draw.draw_text(
    "Mission",
    panel_x + 46,
    panel_y + 188,
    34,
    @raylib.Color::new(224, 236, 252, 245),
  )
  @draw.draw_text(
    "1. Pick up parcels with J",
    panel_x + 58,
    panel_y + 236,
    28,
    @raylib.Color::new(204, 222, 244, 238),
  )
  @draw.draw_text(
    "2. Deliver to glowing EXIT rings",
    panel_x + 58,
    panel_y + 274,
    28,
    @raylib.Color::new(204, 222, 244, 238),
  )
  @draw.draw_text(
    "3. Avoid guard cones and floor traps",
    panel_x + 58,
    panel_y + 312,
    28,
    @raylib.Color::new(204, 222, 244, 238),
  )

  @draw.draw_text(
    "Controls",
    panel_x + 490,
    panel_y + 188,
    34,
    @raylib.Color::new(224, 236, 252, 245),
  )
  @draw.draw_text(
    "Move: Arrows / WASD",
    panel_x + 504,
    panel_y + 236,
    28,
    @raylib.Color::new(204, 222, 244, 238),
  )
  @draw.draw_text(
    "Interact: J",
    panel_x + 504,
    panel_y + 274,
    28,
    @raylib.Color::new(204, 222, 244, 238),
  )
  @draw.draw_text(
    "Smoke Decoy: K",
    panel_x + 504,
    panel_y + 312,
    28,
    @raylib.Color::new(204, 222, 244, 238),
  )
  @draw.draw_text(
    "Sprint: Space (louder)",
    panel_x + 504,
    panel_y + 350,
    28,
    @raylib.Color::new(204, 222, 244, 238),
  )

  @raylib.draw_rectangle(
    panel_x + 220,
    panel_y + panel_h - 110,
    490,
    70,
    @raylib.Color::new(34, 62, 108, 240),
  )
  @raylib.draw_rectangle_lines(
    panel_x + 220,
    panel_y + panel_h - 110,
    490,
    70,
    @raylib.Color::new(164, 198, 244, 236),
  )
  draw_center_text(
    "Press Enter / Space / J to start",
    panel_y + panel_h - 89,
    34,
    @raylib.Color::new(236, 246, 255, 250),
  )
}

///|
/// Draws the retry overlay with the failure reason, wave reached, best wave, final score, delivery count, and a retry prompt.
fn @types.Game::draw_retry_overlay(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(10, 8, 10, 176),
  )

  let panel_w = 760
  let panel_h = 360
  let panel_x = @types.screen_w / 2 - panel_w / 2
  let panel_y = @types.screen_h / 2 - panel_h / 2

  @raylib.draw_rectangle(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(28, 12, 18, 244),
  )
  @raylib.draw_rectangle_lines(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(236, 124, 142, 236),
  )

  draw_center_text(
    "Courier Run Failed",
    panel_y + 36,
    54,
    @raylib.Color::new(255, 210, 218, 248),
  )

  draw_center_text(
    game.fail_reason,
    panel_y + 114,
    30,
    @raylib.Color::new(238, 196, 204, 238),
  )

  draw_center_text(
    "Wave reached: \{game.wave}    Best wave: \{game.best_wave}",
    panel_y + 178,
    34,
    @raylib.Color::new(248, 216, 222, 240),
  )
  draw_center_text(
    "Score: \{game.score}    Delivered: \{game.delivered_total}",
    panel_y + 222,
    34,
    @raylib.Color::new(248, 216, 222, 240),
  )

  @raylib.draw_rectangle(
    panel_x + 160,
    panel_y + panel_h - 98,
    440,
    62,
    @raylib.Color::new(118, 44, 60, 242),
  )
  @raylib.draw_rectangle_lines(
    panel_x + 160,
    panel_y + panel_h - 98,
    440,
    62,
    @raylib.Color::new(255, 170, 186, 244),
  )
  draw_center_text(
    "Press R / Enter / Space to retry",
    panel_y + panel_h - 78,
    32,
    @raylib.Color::new(255, 232, 238, 248),
  )
}

///|
/// Renders the full frame for the current game state.
pub fn draw_frame(game : @types.Game) -> Unit {
  game.draw_background()
  game.draw_exits()
  game.draw_traps()
  game.draw_parcels()
  game.draw_smokes()
  game.draw_guards()
  game.draw_player()
  game.draw_alarm_overlay()
  game.draw_hud()

  match game.state {
    Title => draw_title_overlay()
    Retry => game.draw_retry_overlay()
    Play => ()
  }
}
