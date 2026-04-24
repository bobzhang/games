///|
/// Holds all generated raster artwork used by the Food Truck Frenzy renderer.
struct GameArt {
  title_art : @raylib.Texture
  kitchen_backdrop : @raylib.Texture
  chef_sprite : @raylib.Texture
  supply_crate_sprite : @raylib.Texture
  station_bun_module : @raylib.Texture
  station_meat_module : @raylib.Texture
  station_veg_module : @raylib.Texture
  station_sauce_module : @raylib.Texture
  station_noodle_module : @raylib.Texture
  station_stove_module : @raylib.Texture
  station_window_module : @raylib.Texture
  station_sink_module : @raylib.Texture
  station_fan_module : @raylib.Texture
}

///|
/// Loads one bilinear-filtered texture from the package resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "food_truck_frenzy_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads the generated art bundle. Call after window initialization.
fn load_game_art() -> GameArt {
  {
    title_art: load_art_texture("food_truck_title.png"),
    kitchen_backdrop: load_art_texture("kitchen_floor_backdrop.png"),
    chef_sprite: load_art_texture("chef_sprite.png"),
    supply_crate_sprite: load_art_texture("supply_crate_sprite.png"),
    station_bun_module: load_art_texture("station_bun_module.png"),
    station_meat_module: load_art_texture("station_meat_module.png"),
    station_veg_module: load_art_texture("station_veg_module.png"),
    station_sauce_module: load_art_texture("station_sauce_module.png"),
    station_noodle_module: load_art_texture("station_noodle_module.png"),
    station_stove_module: load_art_texture("station_stove_module.png"),
    station_window_module: load_art_texture("station_window_module.png"),
    station_sink_module: load_art_texture("station_sink_module.png"),
    station_fan_module: load_art_texture("station_fan_module.png"),
  }
}

///|
/// Releases the generated art bundle before closing the window.
fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.title_art)
  @raylib.unload_texture(art.kitchen_backdrop)
  @raylib.unload_texture(art.chef_sprite)
  @raylib.unload_texture(art.supply_crate_sprite)
  @raylib.unload_texture(art.station_bun_module)
  @raylib.unload_texture(art.station_meat_module)
  @raylib.unload_texture(art.station_veg_module)
  @raylib.unload_texture(art.station_sauce_module)
  @raylib.unload_texture(art.station_noodle_module)
  @raylib.unload_texture(art.station_stove_module)
  @raylib.unload_texture(art.station_window_module)
  @raylib.unload_texture(art.station_sink_module)
  @raylib.unload_texture(art.station_fan_module)
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
/// Returns the generated station texture associated with the gameplay station kind.
fn station_texture(art : GameArt, kind : Int) -> @raylib.Texture {
  match kind {
    0 => art.station_bun_module
    1 => art.station_meat_module
    2 => art.station_veg_module
    3 => art.station_sauce_module
    4 => art.station_noodle_module
    5 => art.station_stove_module
    6 => art.station_window_module
    7 => art.station_sink_module
    _ => art.station_fan_module
  }
}
