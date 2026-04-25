///|
/// Generated art resources used by the Metro Repair Dispatch renderer.
priv struct GameArt {
  metro_map_backdrop : @raylib.Texture
  maintenance_drone : @raylib.Texture
  metro_train : @raylib.Texture
  station_node : @raylib.Texture
  repair_depot : @raylib.Texture
}

///|
/// Loads one bilinear-filtered texture from the package resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "metro_repair_dispatch_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads the generated metro map backdrop and gameplay sprites.
fn load_game_art() -> GameArt {
  {
    metro_map_backdrop: load_art_texture("metro_map_backdrop.png"),
    maintenance_drone: load_art_texture("maintenance_drone.png"),
    metro_train: load_art_texture("metro_train.png"),
    station_node: load_art_texture("station_node.png"),
    repair_depot: load_art_texture("repair_depot.png"),
  }
}

///|
/// Releases generated textures before the Raylib window is closed.
fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.metro_map_backdrop)
  @raylib.unload_texture(art.maintenance_drone)
  @raylib.unload_texture(art.metro_train)
  @raylib.unload_texture(art.station_node)
  @raylib.unload_texture(art.repair_depot)
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
/// Draws a generated station node under the code-rendered station labels.
fn draw_station_node_art(
  art : GameArt,
  station : Station,
  radius : Float,
  color : @raylib.Color,
) -> Unit {
  @raylib.draw_circle(
    station.x.to_int(),
    station.y.to_int(),
    radius + 5.0,
    @raylib.Color::new(color.r.to_int(), color.g.to_int(), color.b.to_int(), 62),
  )
  draw_texture_centered(
    art.station_node,
    station.x,
    station.y,
    radius * 2.9,
    radius * 2.9,
    @raylib.white,
  )
}

///|
/// Draws a generated metro train sprite with a small line-colour underglow.
fn draw_train_art(
  art : GameArt,
  x : Float,
  y : Float,
  color : @raylib.Color,
) -> Unit {
  @raylib.draw_rectangle(
    (x - 19.0).to_int(),
    (y + 9.0).to_int(),
    38,
    4,
    @raylib.Color::new(
      color.r.to_int(),
      color.g.to_int(),
      color.b.to_int(),
      178,
    ),
  )
  draw_texture_centered(art.metro_train, x, y, 42.0, 24.0, @raylib.white)
}

///|
/// Draws the generated maintenance drone with a service-light glow.
fn draw_drone_art(art : GameArt, x : Float, y : Float) -> Unit {
  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    24.0,
    @raylib.Color::new(244, 220, 88, 58),
  )
  draw_texture_centered(art.maintenance_drone, x, y, 58.0, 58.0, @raylib.white)
}
