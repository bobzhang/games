///|
/// Holds all generated raster artwork used by Magnet Lab Escape.
struct GameArt {
  lab_backdrop : @raylib.Texture
  title_art : @raylib.Texture
  player_sprite : @raylib.Texture
  drone_sprite : @raylib.Texture
  core_sprite : @raylib.Texture
  crate_sprite : @raylib.Texture
  reactor_sprite : @raylib.Texture
}

///|
/// Loads one bilinear-filtered texture from the package resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "magnet_lab_escape_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads the generated art bundle. Call after window initialization.
fn load_game_art() -> GameArt {
  {
    lab_backdrop: load_art_texture("lab_backdrop.png"),
    title_art: load_art_texture("title_magnet_lab.png"),
    player_sprite: load_art_texture("player_sprite.png"),
    drone_sprite: load_art_texture("drone_sprite.png"),
    core_sprite: load_art_texture("core_sprite.png"),
    crate_sprite: load_art_texture("crate_sprite.png"),
    reactor_sprite: load_art_texture("reactor_sprite.png"),
  }
}

///|
/// Releases generated textures before the Raylib window is closed.
fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.lab_backdrop)
  @raylib.unload_texture(art.title_art)
  @raylib.unload_texture(art.player_sprite)
  @raylib.unload_texture(art.drone_sprite)
  @raylib.unload_texture(art.core_sprite)
  @raylib.unload_texture(art.crate_sprite)
  @raylib.unload_texture(art.reactor_sprite)
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
/// Draws a centered texture and optionally mirrors it horizontally.
fn draw_texture_centered_flip(
  texture : @raylib.Texture,
  cx : Float,
  cy : Float,
  w : Float,
  h : Float,
  flip_x : Bool,
  tint : @raylib.Color,
) -> Unit {
  let source_w : Float = Float::from_int(texture.width())
  let source_h : Float = Float::from_int(texture.height())
  let src_x : Float = if flip_x { source_w } else { 0.0 }
  let src_w : Float = if flip_x { -source_w } else { source_w }
  @raylib.draw_texture_pro(
    texture,
    @raylib.Rectangle::new(src_x, 0.0, src_w, source_h),
    @raylib.Rectangle::new(cx, cy, w, h),
    @raylib.Vector2::new(w * 0.5, h * 0.5),
    0.0,
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
