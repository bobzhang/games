///|
/// Generated art resources used by the Mech Arena Duel renderer.
priv struct GameArt {
  player_mech : @raylib.Texture
  enemy_bot : @raylib.Texture
  plasma_bolt : @raylib.Texture
}

///|
/// Loads one bilinear-filtered texture from the package resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "mech_arena_duel_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads the generated mech, enemy, and projectile artwork.
fn load_game_art() -> GameArt {
  {
    player_mech: load_art_texture("player_mech.png"),
    enemy_bot: load_art_texture("enemy_bot.png"),
    plasma_bolt: load_art_texture("plasma_bolt.png"),
  }
}

///|
/// Releases generated textures before the Raylib window is closed.
fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.player_mech)
  @raylib.unload_texture(art.enemy_bot)
  @raylib.unload_texture(art.plasma_bolt)
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
/// Draws the arena floor with grid, lane markings, and border lighting.
fn draw_arena_floor() -> Unit {
  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    sw,
    sh,
    @raylib.Color::new(16, 19, 27, 255),
    @raylib.Color::new(8, 10, 14, 255),
  )
  @raylib.draw_rectangle(0, 0, sw, 104, @raylib.Color::new(12, 14, 20, 238))
  @raylib.draw_rectangle(
    52,
    110,
    sw - 104,
    sh - 130,
    @raylib.Color::new(23, 27, 36, 255),
  )
  @raylib.draw_rectangle_lines(
    52,
    110,
    sw - 104,
    sh - 130,
    @raylib.Color::new(82, 140, 166, 190),
  )
  @raylib.draw_rectangle_lines(
    68,
    126,
    sw - 136,
    sh - 162,
    @raylib.Color::new(40, 64, 82, 220),
  )

  for y = 130; y < sh - 40; y = y + 40 {
    @raylib.draw_line(68, y, sw - 68, y, @raylib.Color::new(72, 92, 112, 46))
  }
  for x = 88; x < sw - 72; x = x + 40 {
    @raylib.draw_line(x, 126, x, sh - 36, @raylib.Color::new(72, 92, 112, 38))
  }

  for x = 112; x < sw - 96; x = x + 160 {
    @raylib.draw_line(
      x,
      126,
      x + 56,
      126,
      @raylib.Color::new(250, 174, 66, 150),
    )
    @raylib.draw_line(
      x,
      sh - 36,
      x + 56,
      sh - 36,
      @raylib.Color::new(250, 174, 66, 150),
    )
  }
  @raylib.draw_line(
    68,
    sh / 2,
    sw - 68,
    sh / 2,
    @raylib.Color::new(68, 194, 224, 82),
  )
}

///|
/// Draws the player mech sprite with a blue energy footprint.
fn draw_player_mech_art(art : GameArt, x : Float, y : Float) -> Unit {
  @raylib.draw_circle(
    x.to_int(),
    y.to_int() + 10,
    28.0,
    @raylib.Color::new(42, 134, 255, 58),
  )
  @raylib.draw_circle_lines(
    x.to_int(),
    y.to_int() + 2,
    32.0,
    @raylib.Color::new(112, 206, 255, 150),
  )
  draw_texture_centered(art.player_mech, x, y, 66.0, 66.0, @raylib.white)
}

///|
/// Draws an enemy bot sprite with a red threat marker.
fn draw_enemy_bot_art(art : GameArt, x : Float, y : Float) -> Unit {
  @raylib.draw_circle(
    x.to_int(),
    y.to_int() + 9,
    25.0,
    @raylib.Color::new(220, 42, 38, 52),
  )
  @raylib.draw_circle_lines(
    x.to_int(),
    y.to_int() + 1,
    28.0,
    @raylib.Color::new(255, 104, 90, 135),
  )
  draw_texture_centered(art.enemy_bot, x, y, 54.0, 54.0, @raylib.white)
}

///|
/// Draws a plasma bolt with a small glow so shots remain readable at speed.
fn draw_plasma_bolt_art(
  art : GameArt,
  x : Float,
  y : Float,
  from_enemy : Bool,
) -> Unit {
  let tint = if from_enemy {
    @raylib.Color::new(255, 176, 86, 235)
  } else {
    @raylib.Color::new(122, 224, 255, 245)
  }
  let glow = if from_enemy {
    @raylib.Color::new(255, 124, 50, 82)
  } else {
    @raylib.Color::new(70, 196, 255, 90)
  }
  @raylib.draw_circle(x.to_int(), y.to_int(), 8.0, glow)
  draw_texture_centered(art.plasma_bolt, x, y, 22.0, 22.0, tint)
}
