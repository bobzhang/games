///|
/// Generated art resources used by the Meteor Miner Convoy renderer.
priv struct GameArt {
  space_mining_backdrop : @raylib.Texture
  command_ship : @raylib.Texture
  convoy_truck : @raylib.Texture
  meteor_rock : @raylib.Texture
  ore_crystal : @raylib.Texture
  refinery : @raylib.Texture
}

///|
/// Loads one bilinear-filtered texture from the package resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "meteor_miner_convoy_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads the generated backdrop and gameplay sprites.
fn load_game_art() -> GameArt {
  {
    space_mining_backdrop: load_art_texture("space_mining_backdrop.png"),
    command_ship: load_art_texture("command_ship.png"),
    convoy_truck: load_art_texture("convoy_truck.png"),
    meteor_rock: load_art_texture("meteor_rock.png"),
    ore_crystal: load_art_texture("ore_crystal.png"),
    refinery: load_art_texture("refinery.png"),
  }
}

///|
/// Releases generated textures before the Raylib window is closed.
fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.space_mining_backdrop)
  @raylib.unload_texture(art.command_ship)
  @raylib.unload_texture(art.convoy_truck)
  @raylib.unload_texture(art.meteor_rock)
  @raylib.unload_texture(art.ore_crystal)
  @raylib.unload_texture(art.refinery)
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
/// Draws the generated command ship with thruster glow.
fn draw_command_ship_art(art : GameArt, x : Float, y : Float) -> Unit {
  @raylib.draw_circle(
    (x - 36.0).to_int(),
    y.to_int(),
    12.0,
    @raylib.Color::new(64, 226, 242, 78),
  )
  draw_texture_centered(art.command_ship, x, y, 96.0, 54.0, @raylib.white)
}

///|
/// Draws a generated convoy truck sprite and its cargo label.
fn draw_convoy_truck_art(
  art : GameArt,
  truck : Truck,
  tx : Int,
  ty : Int,
) -> Unit {
  @raylib.draw_rectangle(
    tx - 52,
    ty + 14,
    104,
    8,
    @raylib.Color::new(4, 6, 10, 108),
  )
  draw_texture_centered(
    art.convoy_truck,
    Float::from_int(tx),
    Float::from_int(ty - 4),
    112.0,
    64.0,
    @raylib.white,
  )
  @draw.draw_text(
    "\{truck.cargo}",
    tx - 8,
    ty - 18,
    20,
    @raylib.Color::new(236, 250, 255, 255),
  )
}

///|
/// Draws a generated meteor sprite scaled to the current collision radius.
fn draw_meteor_art(art : GameArt, meteor : Meteor, mx : Int, my : Int) -> Unit {
  let size = meteor.r * 2.55
  @raylib.draw_circle(
    mx,
    my,
    meteor.r + 6.0,
    @raylib.Color::new(255, 92, 36, 36),
  )
  draw_texture_centered(
    art.meteor_rock,
    meteor.x,
    meteor.y,
    size,
    size,
    @raylib.white,
  )
}

///|
/// Draws a generated ore pickup sprite with a cyan pickup glow.
fn draw_ore_art(art : GameArt, ore : Ore, ox : Int, oy : Int) -> Unit {
  @raylib.draw_circle(ox, oy + 2, 14.0, @raylib.Color::new(70, 232, 226, 58))
  draw_texture_centered(
    art.ore_crystal,
    ore.x,
    ore.y,
    32.0,
    32.0,
    @raylib.white,
  )
}
