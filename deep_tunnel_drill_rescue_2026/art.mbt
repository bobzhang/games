///|
/// Generated art resources used by Deep Tunnel Drill Rescue 2026.
priv struct GameArt {
  tunnel_backdrop : @raylib.Texture
  empty_tunnel_tile : @raylib.Texture
  dirt_tile : @raylib.Texture
  rock_tile : @raylib.Texture
  gas_tile : @raylib.Texture
  crystal_tile : @raylib.Texture
  miner_tile : @raylib.Texture
  base_tile : @raylib.Texture
  drill_vehicle : @raylib.Texture
}

///|
/// Loads one bilinear-filtered texture from the package resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "deep_tunnel_drill_rescue_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads all generated drill rescue art after the Raylib window is initialized.
fn load_game_art() -> GameArt {
  {
    tunnel_backdrop: load_art_texture("tunnel_backdrop.png"),
    empty_tunnel_tile: load_art_texture("empty_tunnel_tile.png"),
    dirt_tile: load_art_texture("dirt_tile.png"),
    rock_tile: load_art_texture("rock_tile.png"),
    gas_tile: load_art_texture("gas_tile.png"),
    crystal_tile: load_art_texture("crystal_tile.png"),
    miner_tile: load_art_texture("miner_tile.png"),
    base_tile: load_art_texture("base_tile.png"),
    drill_vehicle: load_art_texture("drill_vehicle.png"),
  }
}

///|
/// Releases generated textures before closing the Raylib window.
fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.tunnel_backdrop)
  @raylib.unload_texture(art.empty_tunnel_tile)
  @raylib.unload_texture(art.dirt_tile)
  @raylib.unload_texture(art.rock_tile)
  @raylib.unload_texture(art.gas_tile)
  @raylib.unload_texture(art.crystal_tile)
  @raylib.unload_texture(art.miner_tile)
  @raylib.unload_texture(art.base_tile)
  @raylib.unload_texture(art.drill_vehicle)
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
/// Draws a texture cover-cropped into a destination rectangle.
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
/// Returns the generated texture for a tile kind.
fn texture_for_tile(art : GameArt, tile : Int) -> @raylib.Texture {
  if tile == tile_empty {
    art.empty_tunnel_tile
  } else if tile == tile_dirt {
    art.dirt_tile
  } else if tile == tile_rock {
    art.rock_tile
  } else if tile == tile_gas {
    art.gas_tile
  } else if tile == tile_crystal {
    art.crystal_tile
  } else if tile == tile_miner {
    art.miner_tile
  } else {
    art.base_tile
  }
}

///|
/// Draws the generated mine backdrop beneath the playable tile field.
fn draw_world_bg(art : GameArt, t : Float) -> Unit {
  draw_texture_cover(
    art.tunnel_backdrop,
    0.0,
    0.0,
    Float::from_int(sw),
    Float::from_int(sh),
    @raylib.white,
  )
  @raylib.draw_rectangle(
    world_x - 12,
    world_y - 12,
    world_w + 24,
    world_h + 24,
    @raylib.Color::new(8, 12, 22, 174),
  )
  @raylib.draw_rectangle_lines(
    world_x - 12,
    world_y - 12,
    world_w + 24,
    world_h + 24,
    @raylib.Color::new(128, 158, 206, 188),
  )

  for i in 0..<28 {
    let fi : Float = Float::from_int(i)
    let x : Int = (fi * 72.0 + t * (14.0 + Float::from_int(i % 5) * 4.0)).to_int() %
      world_w +
      world_x
    let y : Int = (fi * 133.0 + t * 18.0).to_int() % world_h + world_y
    @raylib.draw_circle(
      x,
      y,
      1.0 + Float::from_int(i % 3),
      @raylib.Color::new(132, 168, 224, 96),
    )
  }
}

///|
/// Draws one generated tile and its gameplay-state glow.
fn draw_tile_art(
  art : GameArt,
  tile : Int,
  tx : Int,
  ty : Int,
  gx : Int,
  gy : Int,
  t : Float,
) -> Unit {
  let tint = if tile == tile_empty {
    @raylib.Color::new(210, 220, 238, 226)
  } else {
    @raylib.white
  }
  draw_texture_rect(
    texture_for_tile(art, tile),
    Float::from_int(tx),
    Float::from_int(ty),
    Float::from_int(tile_sz),
    Float::from_int(tile_sz),
    tint,
  )

  if tile == tile_gas {
    let pulse : Float = 0.45 +
      @math.sinf(t * 4.0 + Float::from_int(gx + gy)) * 0.18
    @raylib.draw_circle(
      tx + tile_sz / 2,
      ty + tile_sz / 2,
      8.0,
      @raylib.fade(@raylib.lime, pulse),
    )
  } else if tile == tile_crystal {
    @raylib.draw_circle(
      tx + tile_sz / 2,
      ty + tile_sz / 2,
      11.0,
      @raylib.Color::new(108, 226, 255, 92),
    )
  } else if tile == tile_miner {
    @raylib.draw_rectangle(
      tx + 2,
      ty + 2,
      tile_sz - 4,
      tile_sz - 4,
      @raylib.Color::new(246, 222, 118, 40),
    )
  } else if tile == tile_base {
    @raylib.draw_rectangle(
      tx + 2,
      ty + 2,
      tile_sz - 4,
      tile_sz - 4,
      @raylib.Color::new(132, 226, 255, 42),
    )
  }

  @raylib.draw_rectangle_lines(
    tx,
    ty,
    tile_sz,
    tile_sz,
    @raylib.Color::new(8, 14, 24, 150),
  )
}

///|
/// Draws the generated rescue drill vehicle with a bobbing animation and carry marker.
fn draw_player_art(art : GameArt, player : Player, t : Float) -> Unit {
  let bob : Float = @math.sinf(t * 8.0 + player.wobble) * 2.0
  let x : Float = player.x
  let y : Float = player.y + bob
  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    18.0,
    @raylib.Color::new(248, 204, 102, 54),
  )
  draw_texture_centered(
    art.drill_vehicle,
    x + 5.0,
    y,
    42.0,
    27.5,
    @raylib.white,
  )

  if player.carried > 0 {
    @raylib.draw_circle(
      (x + 21.0).to_int(),
      (y - 12.0).to_int(),
      10.0,
      @raylib.Color::new(18, 26, 42, 230),
    )
    @draw.draw_text(
      "\{player.carried}",
      (x + 16.0).to_int(),
      (y - 20.0).to_int(),
      18,
      @raylib.Color::new(248, 246, 236, 252),
    )
  }
}
