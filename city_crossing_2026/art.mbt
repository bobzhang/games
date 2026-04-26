///|
/// Generated art resources used by the City Crossing renderer.
priv struct GameArt {
  lane_grass : @raylib.Texture
  lane_river : @raylib.Texture
  lane_road : @raylib.Texture
  log_platform : @raylib.Texture
  vehicle_red : @raylib.Texture
  vehicle_blue : @raylib.Texture
  vehicle_yellow : @raylib.Texture
  vehicle_truck : @raylib.Texture
  player_frog : @raylib.Texture
  home_slot : @raylib.Texture
}

///|
/// Loads one bilinear-filtered texture from the package resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "city_crossing_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads generated lane, traffic, river, and player art.
fn load_game_art() -> GameArt {
  {
    lane_grass: load_art_texture("lane_grass.png"),
    lane_river: load_art_texture("lane_river.png"),
    lane_road: load_art_texture("lane_road.png"),
    log_platform: load_art_texture("log_platform.png"),
    vehicle_red: load_art_texture("vehicle_red.png"),
    vehicle_blue: load_art_texture("vehicle_blue.png"),
    vehicle_yellow: load_art_texture("vehicle_yellow.png"),
    vehicle_truck: load_art_texture("vehicle_truck.png"),
    player_frog: load_art_texture("player_frog.png"),
    home_slot: load_art_texture("home_slot.png"),
  }
}

///|
/// Releases generated textures before the Raylib window is closed.
fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.lane_grass)
  @raylib.unload_texture(art.lane_river)
  @raylib.unload_texture(art.lane_road)
  @raylib.unload_texture(art.log_platform)
  @raylib.unload_texture(art.vehicle_red)
  @raylib.unload_texture(art.vehicle_blue)
  @raylib.unload_texture(art.vehicle_yellow)
  @raylib.unload_texture(art.vehicle_truck)
  @raylib.unload_texture(art.player_frog)
  @raylib.unload_texture(art.home_slot)
}

///|
/// Draws a texture stretched into a rectangle, optionally flipped horizontally.
fn draw_texture_rect_flipped(
  texture : @raylib.Texture,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  flip_x : Bool,
  tint : @raylib.Color,
) -> Unit {
  let source_w : Float = Float::from_int(texture.width())
  let source_x : Float = if flip_x { source_w } else { 0.0 }
  let draw_w : Float = if flip_x { -source_w } else { source_w }
  @raylib.draw_texture_pro(
    texture,
    @raylib.Rectangle::new(
      source_x,
      0.0,
      draw_w,
      Float::from_int(texture.height()),
    ),
    @raylib.Rectangle::new(x, y, w, h),
    @raylib.Vector2::new(0.0, 0.0),
    0.0,
    tint,
  )
}

///|
/// Draws a texture stretched into a rectangle.
fn draw_texture_rect(
  texture : @raylib.Texture,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  tint : @raylib.Color,
) -> Unit {
  draw_texture_rect_flipped(texture, x, y, w, h, false, tint)
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
/// Draws a texture cover-cropped into a rectangle.
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
/// Draws the generated background art for one crossing row.
fn draw_lane_art(art : GameArt, row : Int) -> Unit {
  let y = oy + row * cell
  let texture = if is_river_row(row) {
    art.lane_river
  } else if is_road_row(row) {
    art.lane_road
  } else {
    art.lane_grass
  }
  draw_texture_cover(
    texture,
    Float::from_int(ox),
    Float::from_int(y),
    Float::from_int(cols * cell),
    Float::from_int(cell),
    @raylib.white,
  )
}

///|
/// Draws one generated home-slot dock, with a small frog marker when filled.
fn draw_home_slot_art(art : GameArt, slot : Int, filled : Bool) -> Unit {
  let cx = slot_center_x(slot)
  let cy = Float::from_int(oy + cell / 2)
  let tint = if filled {
    @raylib.Color::new(255, 238, 128, 255)
  } else {
    @raylib.white
  }
  draw_texture_centered(
    art.home_slot,
    cx,
    cy,
    Float::from_int(cell + 2),
    Float::from_int(cell + 2),
    tint,
  )
  if filled {
    draw_texture_centered(art.player_frog, cx, cy, 28.0, 28.0, @raylib.white)
  }
}

///|
/// Draws one generated floating log platform.
fn draw_log_art(art : GameArt, log : Log) -> Unit {
  draw_texture_rect(
    art.log_platform,
    log.x,
    Float::from_int(oy + log.row * cell + 4),
    Float::from_int(log.w * cell),
    Float::from_int(cell - 8),
    @raylib.white,
  )
}

///|
/// Selects the generated vehicle texture for a car lane obstacle.
fn vehicle_texture(art : GameArt, car : Car) -> @raylib.Texture {
  if car.w >= 3 {
    art.vehicle_truck
  } else if car.color == 0 {
    art.vehicle_red
  } else if car.color == 1 {
    art.vehicle_blue
  } else {
    art.vehicle_yellow
  }
}

///|
/// Draws one generated traffic vehicle sprite.
fn draw_car_art(art : GameArt, car : Car) -> Unit {
  draw_texture_rect_flipped(
    vehicle_texture(art, car),
    car.x,
    Float::from_int(oy + car.row * cell + 4),
    Float::from_int(car.w * cell),
    Float::from_int(cell - 8),
    car.speed < 0.0,
    @raylib.white,
  )
}

///|
/// Draws the generated player frog centered on the current player position.
fn draw_player_art(art : GameArt, px : Float, py : Float) -> Unit {
  draw_texture_centered(art.player_frog, px, py, 52.0, 52.0, @raylib.white)
}
