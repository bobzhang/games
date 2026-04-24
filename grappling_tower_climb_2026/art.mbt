///|
/// Holds all generated raster artwork used by the Grappling Tower Climb renderer.
struct GameArt {
  title_art : @raylib.Texture
  tower_shaft_backdrop : @raylib.Texture
  pilot_sprite : @raylib.Texture
  platform_sprite : @raylib.Texture
  anchor_sprite : @raylib.Texture
  crystal_sprite : @raylib.Texture
  drone_scout_sprite : @raylib.Texture
  drone_hunter_sprite : @raylib.Texture
  drone_brute_sprite : @raylib.Texture
}

///|
/// Loads one bilinear-filtered texture from the package resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "grappling_tower_climb_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads the generated art bundle. Call after window initialization.
fn load_game_art() -> GameArt {
  {
    title_art: load_art_texture("title_tower_climb.png"),
    tower_shaft_backdrop: load_art_texture("tower_shaft_backdrop.png"),
    pilot_sprite: load_art_texture("pilot_sprite.png"),
    platform_sprite: load_art_texture("platform_sprite.png"),
    anchor_sprite: load_art_texture("anchor_sprite.png"),
    crystal_sprite: load_art_texture("crystal_sprite.png"),
    drone_scout_sprite: load_art_texture("drone_scout_sprite.png"),
    drone_hunter_sprite: load_art_texture("drone_hunter_sprite.png"),
    drone_brute_sprite: load_art_texture("drone_brute_sprite.png"),
  }
}

///|
/// Releases the generated art bundle before closing the window.
fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.title_art)
  @raylib.unload_texture(art.tower_shaft_backdrop)
  @raylib.unload_texture(art.pilot_sprite)
  @raylib.unload_texture(art.platform_sprite)
  @raylib.unload_texture(art.anchor_sprite)
  @raylib.unload_texture(art.crystal_sprite)
  @raylib.unload_texture(art.drone_scout_sprite)
  @raylib.unload_texture(art.drone_hunter_sprite)
  @raylib.unload_texture(art.drone_brute_sprite)
}

///|
/// Draws a texture stretched to fill the destination rectangle.
fn draw_texture_fill(
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
/// Draws a texture centered on the destination point and optionally flips it horizontally.
fn draw_texture_centered_facing(
  texture : @raylib.Texture,
  cx : Float,
  cy : Float,
  w : Float,
  h : Float,
  rotation : Float,
  facing : Int,
  tint : @raylib.Color,
) -> Unit {
  let source_w = Float::from_int(texture.width())
  let src_x = if facing < 0 { source_w } else { 0.0 }
  let src_w = if facing < 0 { -source_w } else { source_w }

  @raylib.draw_texture_pro(
    texture,
    @raylib.Rectangle::new(src_x, 0.0, src_w, Float::from_int(texture.height())),
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
/// Returns the generated drone texture associated with the gameplay drone kind.
fn drone_texture(art : GameArt, kind : Int) -> @raylib.Texture {
  match kind {
    1 => art.drone_hunter_sprite
    2 => art.drone_brute_sprite
    _ => art.drone_scout_sprite
  }
}
