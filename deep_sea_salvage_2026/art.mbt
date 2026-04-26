///|
/// Generated art resources used by Deep Sea Salvage 2026.
priv struct GameArt {
  ocean_backdrop : @raylib.Texture
  submarine_sprite : @raylib.Texture
  relic_sprite : @raylib.Texture
  mine_sprite : @raylib.Texture
}

///|
/// Loads one bilinear-filtered texture from the package resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "deep_sea_salvage_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads all generated salvage art after the Raylib window is initialized.
fn load_game_art() -> GameArt {
  {
    ocean_backdrop: load_art_texture("ocean_backdrop.png"),
    submarine_sprite: load_art_texture("submarine_sprite.png"),
    relic_sprite: load_art_texture("relic_sprite.png"),
    mine_sprite: load_art_texture("mine_sprite.png"),
  }
}

///|
/// Releases generated textures before closing the Raylib window.
fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.ocean_backdrop)
  @raylib.unload_texture(art.submarine_sprite)
  @raylib.unload_texture(art.relic_sprite)
  @raylib.unload_texture(art.mine_sprite)
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
/// Draws the generated ocean salvage backdrop with gameplay readability overlays.
fn draw_ocean_backdrop_art(art : GameArt) -> Unit {
  draw_texture_cover(
    art.ocean_backdrop,
    0.0,
    0.0,
    Float::from_int(sw),
    Float::from_int(sh),
    @raylib.white,
  )
  @raylib.draw_rectangle(
    0,
    0,
    sw,
    surface_y.to_int(),
    @raylib.Color::new(68, 178, 224, 64),
  )
  @raylib.draw_rectangle(
    0,
    surface_y.to_int(),
    sw,
    sh - surface_y.to_int(),
    @raylib.Color::new(4, 18, 38, 74),
  )
  @raylib.draw_line(
    0,
    surface_y.to_int(),
    sw,
    surface_y.to_int(),
    @raylib.Color::new(166, 236, 255, 210),
  )
  for y = surface_y.to_int() + 30; y < sh; y = y + 60 {
    @raylib.draw_line(0, y, sw, y, @raylib.fade(@raylib.skyblue, 0.16))
  }
}

///|
/// Draws a generated relic pickup at the active pool item's position.
fn draw_relic_art(art : GameArt, relic : Relic) -> Unit {
  let glow = if relic.value >= 70 { 0.34F } else { 0.22F }
  @raylib.draw_circle(
    relic.x.to_int(),
    relic.y.to_int(),
    relic.size * 1.45,
    @raylib.fade(@raylib.gold, glow),
  )
  draw_texture_centered(
    art.relic_sprite,
    relic.x,
    relic.y,
    relic.size * 3.05,
    relic.size * 3.3,
    @raylib.white,
  )
}

///|
/// Draws a generated mine hazard at the active pool item's position.
fn draw_mine_art(art : GameArt, mine : Mine) -> Unit {
  @raylib.draw_circle(
    mine.x.to_int(),
    mine.y.to_int(),
    mine.r * 1.45,
    @raylib.fade(@raylib.red, 0.20),
  )
  draw_texture_centered_rotated(
    art.mine_sprite,
    mine.x,
    mine.y,
    mine.r * 2.95,
    mine.r * 3.5,
    mine.x * 0.025,
    @raylib.white,
  )
}

///|
/// Draws the player submarine sprite with a subtle oxygen-safe highlight at the surface.
fn draw_submarine_art(art : GameArt, px : Float, py : Float) -> Unit {
  if py <= surface_y + 20.0 {
    @raylib.draw_circle(
      px.to_int(),
      py.to_int(),
      36.0,
      @raylib.fade(@raylib.skyblue, 0.20),
    )
  }
  draw_texture_centered(art.submarine_sprite, px, py, 84.0, 53.0, @raylib.white)
}
