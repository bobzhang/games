///|
/// Holds all generated raster artwork used by the Harbor Defense renderer.
struct GameArt {
  title_art : @raylib.Texture
  harbor_backdrop : @raylib.Texture
  cannon_battery_sprite : @raylib.Texture
  enemy_raider_sprite : @raylib.Texture
  enemy_frigate_sprite : @raylib.Texture
  enemy_dreadnought_sprite : @raylib.Texture
  civilian_boat_sprite : @raylib.Texture
  pickup_crate_sprite : @raylib.Texture
}

///|
/// Loads one bilinear-filtered texture from the package resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "harbor_defense_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads the generated art bundle. Call after window initialization.
fn load_game_art() -> GameArt {
  {
    title_art: load_art_texture("title_harbor_defense.png"),
    harbor_backdrop: load_art_texture("harbor_backdrop.png"),
    cannon_battery_sprite: load_art_texture("cannon_battery_sprite.png"),
    enemy_raider_sprite: load_art_texture("enemy_raider_sprite.png"),
    enemy_frigate_sprite: load_art_texture("enemy_frigate_sprite.png"),
    enemy_dreadnought_sprite: load_art_texture("enemy_dreadnought_sprite.png"),
    civilian_boat_sprite: load_art_texture("civilian_boat_sprite.png"),
    pickup_crate_sprite: load_art_texture("pickup_crate_sprite.png"),
  }
}

///|
/// Releases the generated art bundle before closing the window.
fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.title_art)
  @raylib.unload_texture(art.harbor_backdrop)
  @raylib.unload_texture(art.cannon_battery_sprite)
  @raylib.unload_texture(art.enemy_raider_sprite)
  @raylib.unload_texture(art.enemy_frigate_sprite)
  @raylib.unload_texture(art.enemy_dreadnought_sprite)
  @raylib.unload_texture(art.civilian_boat_sprite)
  @raylib.unload_texture(art.pickup_crate_sprite)
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
/// Returns the generated enemy texture associated with the gameplay ship kind.
fn enemy_texture(art : GameArt, kind : Int) -> @raylib.Texture {
  match kind {
    1 => art.enemy_frigate_sprite
    2 => art.enemy_dreadnought_sprite
    _ => art.enemy_raider_sprite
  }
}
