///|
/// Generated art resources used by the City Builder Mini renderer.
priv struct GameArt {
  terrain_grass : @raylib.Texture
  terrain_rock : @raylib.Texture
  zone_road : @raylib.Texture
  zone_residential : @raylib.Texture
  zone_commercial : @raylib.Texture
  zone_industrial : @raylib.Texture
}

///|
/// Loads one bilinear-filtered texture from the package resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "city_builder_mini_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads generated terrain and zone tile art.
fn load_game_art() -> GameArt {
  {
    terrain_grass: load_art_texture("terrain_grass.png"),
    terrain_rock: load_art_texture("terrain_rock.png"),
    zone_road: load_art_texture("zone_road.png"),
    zone_residential: load_art_texture("zone_residential.png"),
    zone_commercial: load_art_texture("zone_commercial.png"),
    zone_industrial: load_art_texture("zone_industrial.png"),
  }
}

///|
/// Releases generated textures before the Raylib window is closed.
fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.terrain_grass)
  @raylib.unload_texture(art.terrain_rock)
  @raylib.unload_texture(art.zone_road)
  @raylib.unload_texture(art.zone_residential)
  @raylib.unload_texture(art.zone_commercial)
  @raylib.unload_texture(art.zone_industrial)
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
/// Draws the generated terrain texture for a grid cell.
fn draw_terrain_tile_art(
  art : GameArt,
  terrain : Int,
  px : Int,
  py : Int,
) -> Unit {
  @raylib.draw_rectangle(px, py, cell, cell, terrain_color(terrain))
  let texture = if terrain == 1 { art.terrain_rock } else { art.terrain_grass }
  let alpha = if terrain == 1 { 248 } else { 226 }
  draw_texture_rect(
    texture,
    Float::from_int(px),
    Float::from_int(py),
    Float::from_int(cell),
    Float::from_int(cell),
    @raylib.Color::new(255, 255, 255, alpha),
  )
}

///|
/// Draws the generated art for a placed zone tile.
fn draw_zone_tile_art(art : GameArt, zone : Int, px : Int, py : Int) -> Unit {
  if zone == 1 {
    draw_texture_rect(
      art.zone_road,
      Float::from_int(px),
      Float::from_int(py),
      Float::from_int(cell),
      Float::from_int(cell),
      @raylib.white,
    )
  } else if zone != 0 {
    let underlay = @raylib.fade(zone_color(zone), 0.36)
    @raylib.draw_rectangle(px + 4, py + 4, cell - 8, cell - 8, underlay)
    let texture = match zone {
      2 => art.zone_residential
      3 => art.zone_commercial
      4 => art.zone_industrial
      _ => art.zone_residential
    }
    draw_texture_rect(
      texture,
      Float::from_int(px + 2),
      Float::from_int(py + 2),
      Float::from_int(cell - 4),
      Float::from_int(cell - 4),
      @raylib.white,
    )
  }
}
