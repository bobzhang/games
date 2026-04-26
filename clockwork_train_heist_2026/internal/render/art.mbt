///|
/// Public bundle of generated renderer textures for the train heist.
pub(all) struct GameArt {
  train_backdrop : @raylib.Texture
  floor_panel : @raylib.Texture
  wall_panel : @raylib.Texture
  door_tile : @raylib.Texture
  thief_sprite : @raylib.Texture
  guard_sprite : @raylib.Texture
  loot_blueprint : @raylib.Texture
  loot_keycard : @raylib.Texture
  loot_gold : @raylib.Texture
  exit_cable_lock : @raylib.Texture
}

///|
/// Loads one bilinear-filtered texture from this package's resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "clockwork_train_heist_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads all generated train heist art after the Raylib window is initialized.
pub fn load_game_art() -> GameArt {
  {
    train_backdrop: load_art_texture("train_backdrop.png"),
    floor_panel: load_art_texture("floor_panel.png"),
    wall_panel: load_art_texture("wall_panel.png"),
    door_tile: load_art_texture("door_tile.png"),
    thief_sprite: load_art_texture("thief_sprite.png"),
    guard_sprite: load_art_texture("guard_sprite.png"),
    loot_blueprint: load_art_texture("loot_blueprint.png"),
    loot_keycard: load_art_texture("loot_keycard.png"),
    loot_gold: load_art_texture("loot_gold.png"),
    exit_cable_lock: load_art_texture("exit_cable_lock.png"),
  }
}

///|
/// Releases generated textures before closing the Raylib window.
pub fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.train_backdrop)
  @raylib.unload_texture(art.floor_panel)
  @raylib.unload_texture(art.wall_panel)
  @raylib.unload_texture(art.door_tile)
  @raylib.unload_texture(art.thief_sprite)
  @raylib.unload_texture(art.guard_sprite)
  @raylib.unload_texture(art.loot_blueprint)
  @raylib.unload_texture(art.loot_keycard)
  @raylib.unload_texture(art.loot_gold)
  @raylib.unload_texture(art.exit_cable_lock)
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
/// Draws a texture centered in a max box while preserving its source aspect ratio.
fn draw_texture_fit_centered(
  texture : @raylib.Texture,
  cx : Float,
  cy : Float,
  max_w : Float,
  max_h : Float,
  tint : @raylib.Color,
) -> Unit {
  let source_ratio : Float = Float::from_int(texture.width()) /
    Float::from_int(texture.height())
  let dest_ratio : Float = max_w / max_h
  let (w, h) = if source_ratio > dest_ratio {
    (max_w, max_w / source_ratio)
  } else {
    (max_h * source_ratio, max_h)
  }
  draw_texture_centered(texture, cx, cy, w, h, tint)
}

///|
/// Draws a texture stretched into the destination rectangle.
fn draw_texture_rect(
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
/// Draws the generated train panorama with a mild overlay for gameplay readability.
fn draw_train_backdrop_art(art : GameArt) -> Unit {
  draw_texture_cover(
    art.train_backdrop,
    0.0,
    0.0,
    Float::from_int(@types.screen_w),
    Float::from_int(@types.screen_h),
    @raylib.white,
  )
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(2, 8, 18, 92),
  )
}
