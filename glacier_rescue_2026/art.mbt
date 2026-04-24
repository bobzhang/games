///|
/// Holds all generated raster artwork used by the Glacier Rescue renderer.
struct GameArt {
  title_art : @raylib.Texture
  world_backdrop : @raylib.Texture
  helicopter_sprite : @raylib.Texture
  survivor_sprite : @raylib.Texture
  ice_hazard_sprite : @raylib.Texture
  rock_hazard_sprite : @raylib.Texture
  rescue_base_sprite : @raylib.Texture
}

///|
/// Loads one bilinear-filtered texture from the package resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "glacier_rescue_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads the generated art bundle. Call after window initialization.
fn load_game_art() -> GameArt {
  {
    title_art: load_art_texture("title_glacier_rescue.png"),
    world_backdrop: load_art_texture("glacier_world_backdrop.png"),
    helicopter_sprite: load_art_texture("rescue_helicopter_sprite.png"),
    survivor_sprite: load_art_texture("survivor_sprite.png"),
    ice_hazard_sprite: load_art_texture("ice_hazard_sprite.png"),
    rock_hazard_sprite: load_art_texture("rock_hazard_sprite.png"),
    rescue_base_sprite: load_art_texture("rescue_base_sprite.png"),
  }
}

///|
/// Releases the generated art bundle before closing the window.
fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.title_art)
  @raylib.unload_texture(art.world_backdrop)
  @raylib.unload_texture(art.helicopter_sprite)
  @raylib.unload_texture(art.survivor_sprite)
  @raylib.unload_texture(art.ice_hazard_sprite)
  @raylib.unload_texture(art.rock_hazard_sprite)
  @raylib.unload_texture(art.rescue_base_sprite)
}

///|
/// Draws a texture stretched to fill the destination rectangle.
fn draw_texture_stretch(
  texture : @raylib.Texture,
  x : Float,
  y : Float,
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
/// Returns the generated hazard texture associated with the gameplay hazard kind.
fn hazard_texture(art : GameArt, kind : Int) -> @raylib.Texture {
  if kind == 0 {
    art.ice_hazard_sprite
  } else {
    art.rock_hazard_sprite
  }
}

///|
/// Converts a velocity vector into degrees for a sprite that faces downward by default.
fn velocity_rotation(vx : Float, vy : Float) -> Float {
  let speed2 = vx * vx + vy * vy
  if speed2 < 36.0 {
    0.0
  } else {
    @math.atan2f(vy, vx) * 57.29577951308232 - 90.0
  }
}
