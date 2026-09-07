///|
/// Public bundle of generated renderer textures.
pub(all) struct GameArt {
  city_backdrop : @raylib.Texture
  road_surface : @raylib.Texture
  player_car : @raylib.Texture
  scout_enemy : @raylib.Texture
  spinner_enemy : @raylib.Texture
  tank_enemy : @raylib.Texture
  gear_wall : @raylib.Texture
  coin_pickup : @raylib.Texture
  coolant_pickup : @raylib.Texture
  emp_cell_pickup : @raylib.Texture
}

///|
/// Loads one bilinear-filtered texture from the package resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "clockwork_city_chase_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads all generated clockwork city chase art after window initialization.
pub fn load_game_art() -> GameArt {
  {
    city_backdrop: load_art_texture("city_backdrop.png"),
    road_surface: load_art_texture("road_surface.png"),
    player_car: load_art_texture("player_car.png"),
    scout_enemy: load_art_texture("scout_enemy.png"),
    spinner_enemy: load_art_texture("spinner_enemy.png"),
    tank_enemy: load_art_texture("tank_enemy.png"),
    gear_wall: load_art_texture("gear_wall.png"),
    coin_pickup: load_art_texture("coin_pickup.png"),
    coolant_pickup: load_art_texture("coolant_pickup.png"),
    emp_cell_pickup: load_art_texture("emp_cell_pickup.png"),
  }
}

///|
/// Releases generated textures before the Raylib window is closed.
pub fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.city_backdrop)
  @raylib.unload_texture(art.road_surface)
  @raylib.unload_texture(art.player_car)
  @raylib.unload_texture(art.scout_enemy)
  @raylib.unload_texture(art.spinner_enemy)
  @raylib.unload_texture(art.tank_enemy)
  @raylib.unload_texture(art.gear_wall)
  @raylib.unload_texture(art.coin_pickup)
  @raylib.unload_texture(art.coolant_pickup)
  @raylib.unload_texture(art.emp_cell_pickup)
}

///|
/// Draws a texture centered on the destination point with optional rotation.
fn draw_texture_centered_rotated(
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
/// Draws a texture centered on the destination point.
fn draw_texture_centered(
  texture : @raylib.Texture,
  cx : Float,
  cy : Float,
  w : Float,
  h : Float,
  tint : @raylib.Color,
) -> Unit {
  draw_texture_centered_rotated(texture, cx, cy, w, h, 0.0, tint)
}

///|
/// Draws a texture cover-cropped into the destination rectangle.
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
/// Draws the generated clockwork city background under the procedural effects.
fn draw_city_backdrop_art(art : GameArt, flash_t : Float) -> Unit {
  draw_texture_cover(
    art.city_backdrop,
    0.0,
    0.0,
    Float::from_int(@types.screen_w),
    Float::from_int(@types.screen_h),
    @raylib.white,
  )
  let shade = if flash_t > 0.0 {
    @raylib.Color::new(32, 8, 18, 82)
  } else {
    @raylib.Color::new(2, 8, 18, 72)
  }
  @raylib.draw_rectangle(0, 0, @types.screen_w, @types.screen_h, shade)
}

///|
/// Draws one clipped road strip using the generated surface texture.
fn draw_road_strip_art(
  art : GameArt,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  tint : @raylib.Color,
) -> Unit {
  @raylib.draw_rectangle(x, y, w, h, tint)
  draw_texture_cover(
    art.road_surface,
    Float::from_int(x),
    Float::from_int(y),
    Float::from_int(w),
    Float::from_int(h),
    @raylib.Color::new(255, 255, 255, 150),
  )
}

///|
/// Returns a white sprite tint preserving only the desired alpha.
fn sprite_alpha_tint(col : @raylib.Color) -> @raylib.Color {
  @raylib.Color::new(255, 255, 255, col.a.to_int())
}

///|
/// Draws one generated enemy or pickup sprite for an active object.
fn draw_obj_sprite_art(
  art : GameArt,
  o : @types.Obj,
  col : @raylib.Color,
  cam_x : Float,
  cam_y : Float,
) -> Unit {
  let x = o.x + cam_x
  let y = o.y + cam_y
  let tint = sprite_alpha_tint(col)

  match o.kind {
    Scout =>
      draw_texture_centered(art.scout_enemy, x, y, o.w * 1.16, o.h * 1.16, tint)
    Spinner => {
      @raylib.draw_circle(
        x.to_int(),
        y.to_int(),
        o.w * 0.58,
        @types.alpha_color(col, 72),
      )
      draw_texture_centered_rotated(
        art.spinner_enemy,
        x,
        y,
        o.w * 1.28,
        o.h * 1.28,
        o.spin * 58.0,
        tint,
      )
    }
    Tank =>
      draw_texture_centered(art.tank_enemy, x, y, o.w * 1.08, o.h * 1.08, tint)
    GearWall =>
      draw_texture_centered(
        art.gear_wall,
        x,
        y,
        o.w * 1.14,
        @types.maxf(30.0, o.h * 2.2),
        tint,
      )
    Coin => {
      @raylib.draw_circle(
        x.to_int(),
        y.to_int(),
        o.w * 0.58,
        @types.alpha_color(col, 82),
      )
      draw_texture_centered(art.coin_pickup, x, y, o.w * 1.05, o.h * 1.05, tint)
    }
    Coolant => {
      @raylib.draw_circle(
        x.to_int(),
        y.to_int(),
        o.w * 0.58,
        @types.alpha_color(col, 82),
      )
      draw_texture_centered(
        art.coolant_pickup,
        x,
        y,
        o.w * 0.78,
        o.h * 1.18,
        tint,
      )
    }
    EmpCell => {
      @raylib.draw_circle(
        x.to_int(),
        y.to_int(),
        o.w * 0.58,
        @types.alpha_color(col, 82),
      )
      draw_texture_centered(
        art.emp_cell_pickup,
        x,
        y,
        o.w * 0.9,
        o.h * 1.22,
        tint,
      )
    }
  }
}

///|
/// Draws the generated player car plus existing gameplay feedback effects.
fn draw_player_car_art(
  art : GameArt,
  game : @types.Game,
  cam_x : Float,
  cam_y : Float,
) -> Unit {
  let x = game.hero.x + cam_x
  let y = game.hero.y + cam_y

  let lean = @types.clampf(game.hero.vx / @types.max_speed_x, -1.0, 1.0)
  let rot = lean * 18.0
  let pulse : Float = 0.5 + 0.5 * @math.sinf(game.hero.engine_t * 8.2)

  @raylib.draw_triangle(
    @raylib.Vector2::new(x - game.hero.w * 0.4, y + game.hero.h * 0.48),
    @raylib.Vector2::new(x - game.hero.w * 0.8, y + game.hero.h * 0.66),
    @raylib.Vector2::new(x - game.hero.w * 0.1, y + game.hero.h * 0.58),
    @raylib.Color::new(106, 206, 242, 170 + (pulse * 55.0).to_int()),
  )
  @raylib.draw_triangle(
    @raylib.Vector2::new(x + game.hero.w * 0.4, y + game.hero.h * 0.48),
    @raylib.Vector2::new(x + game.hero.w * 0.8, y + game.hero.h * 0.66),
    @raylib.Vector2::new(x + game.hero.w * 0.1, y + game.hero.h * 0.58),
    @raylib.Color::new(106, 206, 242, 170 + (pulse * 55.0).to_int()),
  )

  let tint = if game.hero.hurt_t > 0.0 {
    @raylib.Color::new(255, 206, 216, 255)
  } else {
    @raylib.white
  }
  draw_texture_centered_rotated(
    art.player_car,
    x,
    y,
    game.hero.w * 1.22,
    game.hero.h * 1.18,
    rot,
    tint,
  )

  if game.hero.muzzle_t > 0.0 {
    let a = (game.hero.muzzle_t * 255.0).to_int().clamp(min=0, max=255)
    @raylib.draw_circle(
      (x - 10.0).to_int(),
      (y - game.hero.h * 0.53).to_int(),
      5.2,
      @raylib.Color::new(255, 236, 180, a),
    )
    @raylib.draw_circle(
      (x + 10.0).to_int(),
      (y - game.hero.h * 0.53).to_int(),
      5.2,
      @raylib.Color::new(255, 236, 180, a),
    )
  }

  if game.dash_t > 0.0 {
    @raylib.draw_circle_lines(
      x.to_int(),
      y.to_int(),
      @types.maxf(game.hero.w, game.hero.h) * 0.65 + game.dash_t * 40.0,
      @raylib.Color::new(120, 248, 255, 210),
    )
  }

  if game.hero.invuln > 0.0 {
    let flicker = Float::from_int(80) +
      @math.sinf(game.time_s * 14.0) * 70.0 +
      70.0
    let aa = flicker.to_int().clamp(min=30, max=220)
    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      @types.maxf(game.hero.w, game.hero.h) * 0.6,
      @raylib.Color::new(246, 252, 255, aa),
    )
  }
}
