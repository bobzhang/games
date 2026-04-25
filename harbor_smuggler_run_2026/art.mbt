///|
/// Holds all generated raster artwork used by the Harbor Smuggler Run renderer.
struct GameArt {
  title_art : @raylib.Texture
  night_harbor_backdrop : @raylib.Texture
  smuggler_boat_sprite : @raylib.Texture
  patrol_light_sprite : @raylib.Texture
  patrol_interceptor_sprite : @raylib.Texture
  patrol_cutter_sprite : @raylib.Texture
  cargo_crate_sprite : @raylib.Texture
}

///|
/// Loads one bilinear-filtered texture from the package resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "harbor_smuggler_run_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads the generated art bundle. Call after window initialization.
fn load_game_art() -> GameArt {
  {
    title_art: load_art_texture("title_smuggler_run.png"),
    night_harbor_backdrop: load_art_texture("night_harbor_backdrop.png"),
    smuggler_boat_sprite: load_art_texture("smuggler_boat_sprite.png"),
    patrol_light_sprite: load_art_texture("patrol_light_sprite.png"),
    patrol_interceptor_sprite: load_art_texture("patrol_interceptor_sprite.png"),
    patrol_cutter_sprite: load_art_texture("patrol_cutter_sprite.png"),
    cargo_crate_sprite: load_art_texture("cargo_crate_sprite.png"),
  }
}

///|
/// Releases the generated art bundle before closing the window.
fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.title_art)
  @raylib.unload_texture(art.night_harbor_backdrop)
  @raylib.unload_texture(art.smuggler_boat_sprite)
  @raylib.unload_texture(art.patrol_light_sprite)
  @raylib.unload_texture(art.patrol_interceptor_sprite)
  @raylib.unload_texture(art.patrol_cutter_sprite)
  @raylib.unload_texture(art.cargo_crate_sprite)
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
/// Returns the generated patrol texture associated with the gameplay patrol kind.
fn patrol_texture(art : GameArt, kind : Int) -> @raylib.Texture {
  match kind {
    1 => art.patrol_interceptor_sprite
    2 => art.patrol_cutter_sprite
    _ => art.patrol_light_sprite
  }
}
