///|
/// Generated art resources used by the Mine Cart Mayhem renderer.
priv struct GameArt {
  mine_tunnel_backdrop : @raylib.Texture
  mine_cart : @raylib.Texture
  low_rock : @raylib.Texture
  high_wall : @raylib.Texture
  gold_coin : @raylib.Texture
}

///|
/// Loads one bilinear-filtered texture from the package resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "mine_cart_mayhem_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads the generated mine backdrop, cart, obstacle, and coin artwork.
fn load_game_art() -> GameArt {
  {
    mine_tunnel_backdrop: load_art_texture("mine_tunnel_backdrop.png"),
    mine_cart: load_art_texture("mine_cart.png"),
    low_rock: load_art_texture("low_rock.png"),
    high_wall: load_art_texture("high_wall.png"),
    gold_coin: load_art_texture("gold_coin.png"),
  }
}

///|
/// Releases generated textures before the Raylib window is closed.
fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.mine_tunnel_backdrop)
  @raylib.unload_texture(art.mine_cart)
  @raylib.unload_texture(art.low_rock)
  @raylib.unload_texture(art.high_wall)
  @raylib.unload_texture(art.gold_coin)
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
/// Draws the generated tunnel backdrop with subtle dark overlays for HUD readability.
fn draw_mine_backdrop(art : GameArt) -> Unit {
  draw_texture_cover(
    art.mine_tunnel_backdrop,
    0.0,
    0.0,
    Float::from_int(sw),
    Float::from_int(sh),
    @raylib.white,
  )
  @raylib.draw_rectangle(0, 0, sw, 118, @raylib.Color::new(8, 7, 6, 146))
  @raylib.draw_rectangle(0, 606, sw, 114, @raylib.Color::new(8, 7, 6, 132))
}

///|
/// Draws one code-native rail lane above the generated mine backdrop.
fn draw_track_lane(lane : Int, scroll : Int) -> Unit {
  let y = lane_y(lane).to_int()
  @raylib.draw_rectangle(0, y - 30, sw, 32, @raylib.Color::new(34, 26, 20, 190))
  for i in 0..<24 {
    let x = i * 58 - scroll
    @raylib.draw_rectangle(
      x,
      y - 24,
      34,
      18,
      @raylib.Color::new(92, 62, 38, 230),
    )
    @raylib.draw_rectangle(
      x + 4,
      y - 21,
      26,
      4,
      @raylib.Color::new(132, 92, 58, 210),
    )
  }
  @raylib.draw_line(
    24,
    y - 14,
    sw - 16,
    y - 14,
    @raylib.Color::new(42, 44, 48, 255),
  )
  @raylib.draw_line(
    24,
    y + 3,
    sw - 16,
    y + 3,
    @raylib.Color::new(58, 62, 66, 255),
  )
  @raylib.draw_line(
    24,
    y - 16,
    sw - 16,
    y - 16,
    @raylib.Color::new(202, 174, 132, 210),
  )
  @raylib.draw_line(
    24,
    y + 1,
    sw - 16,
    y + 1,
    @raylib.Color::new(160, 136, 100, 200),
  )
}

///|
/// Draws a generated mine cart aligned to the lane rail baseline.
fn draw_mine_cart_art(art : GameArt, x : Float, y : Float) -> Unit {
  @raylib.draw_rectangle(
    (x - 42.0).to_int(),
    y.to_int() + 2,
    84,
    7,
    @raylib.Color::new(0, 0, 0, 120),
  )
  draw_texture_centered(art.mine_cart, x, y - 24.0, 94.0, 62.0, @raylib.white)
}

///|
/// Draws a low rock obstacle with its collision-readable footprint.
fn draw_low_rock_art(art : GameArt, x : Float, lane_y : Float) -> Unit {
  @raylib.draw_rectangle(
    (x - 24.0).to_int(),
    (lane_y - 5.0).to_int(),
    48,
    5,
    @raylib.Color::new(0, 0, 0, 116),
  )
  draw_texture_centered(
    art.low_rock,
    x,
    lane_y - 16.0,
    62.0,
    34.0,
    @raylib.white,
  )
}

///|
/// Draws a high wall obstacle scaled to remain legible as an unjumped threat.
fn draw_high_wall_art(art : GameArt, x : Float, lane_y : Float) -> Unit {
  @raylib.draw_rectangle(
    (x - 24.0).to_int(),
    lane_y.to_int() - 5,
    48,
    7,
    @raylib.Color::new(0, 0, 0, 118),
  )
  draw_texture_centered(
    art.high_wall,
    x,
    lane_y - 42.0,
    56.0,
    88.0,
    @raylib.white,
  )
}

///|
/// Draws a generated coin pickup with a warm glow.
fn draw_gold_coin_art(art : GameArt, x : Float, y : Float) -> Unit {
  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    16.0,
    @raylib.Color::new(252, 198, 58, 58),
  )
  draw_texture_centered(art.gold_coin, x, y, 34.0, 34.0, @raylib.white)
}
