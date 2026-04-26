///|
/// Generated art resources used by Desert Train Robbery 2026.
priv struct GameArt {
  desert_backdrop : @raylib.Texture
  wagon_car : @raylib.Texture
  outlaw_sprite : @raylib.Texture
  sheriff_sprite : @raylib.Texture
  loot_crate : @raylib.Texture
}

///|
/// Loads one bilinear-filtered texture from the package resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "desert_train_robbery_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads all generated train robbery art after the Raylib window is initialized.
fn load_game_art() -> GameArt {
  {
    desert_backdrop: load_art_texture("desert_backdrop.png"),
    wagon_car: load_art_texture("wagon_car.png"),
    outlaw_sprite: load_art_texture("outlaw_sprite.png"),
    sheriff_sprite: load_art_texture("sheriff_sprite.png"),
    loot_crate: load_art_texture("loot_crate.png"),
  }
}

///|
/// Releases generated textures before closing the Raylib window.
fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.desert_backdrop)
  @raylib.unload_texture(art.wagon_car)
  @raylib.unload_texture(art.outlaw_sprite)
  @raylib.unload_texture(art.sheriff_sprite)
  @raylib.unload_texture(art.loot_crate)
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
/// Draws the generated desert panorama and fast-moving railroad foreground.
fn draw_desert_backdrop_art(
  art : GameArt,
  wave_t : Float,
  flash_t : Float,
) -> Unit {
  draw_texture_cover(
    art.desert_backdrop,
    0.0,
    0.0,
    Float::from_int(sw),
    Float::from_int(sh),
    @raylib.white,
  )
  if flash_t > 0.0 {
    @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(64, 12, 16, 72))
  } else {
    @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(20, 16, 24, 28))
  }

  @raylib.draw_rectangle(
    0,
    ground_y.to_int(),
    sw,
    sh - ground_y.to_int(),
    @raylib.Color::new(118, 74, 48, 178),
  )
  @raylib.draw_line(0, 736, sw, 736, @raylib.Color::new(58, 46, 40, 255))
  @raylib.draw_line(0, 752, sw, 752, @raylib.Color::new(58, 46, 40, 255))

  for s in 0..<54 {
    let x = (s * 44 + (wave_t * 200.0).to_int()) % (sw + 80) - 40
    @raylib.draw_rectangle(x, 730, 24, 28, @raylib.Color::new(82, 58, 42, 232))
  }
}

///|
/// Draws a generated freight wagon with roof and wheel anchors aligned to physics.
fn draw_wagon_art(art : GameArt, wagon : Wagon, shake_x : Float) -> Unit {
  let wx = wagon.x + shake_x
  let wy = wagon.roof_y
  let len = wagon.len
  draw_texture_centered(
    art.wagon_car,
    wx + len * 0.5,
    wy - 18.0,
    len,
    82.0,
    @raylib.white,
  )
  @raylib.draw_line(
    wx.to_int(),
    wy.to_int(),
    (wx + len).to_int(),
    wy.to_int(),
    @raylib.Color::new(238, 232, 226, 246),
  )
  @raylib.draw_circle(
    (wx + 28.0).to_int(),
    (wy + 8.0).to_int(),
    12.0,
    @raylib.Color::new(28, 22, 20, 230),
  )
  @raylib.draw_circle(
    (wx + len - 28.0).to_int(),
    (wy + 8.0).to_int(),
    12.0,
    @raylib.Color::new(28, 22, 20, 230),
  )
}

///|
/// Draws generated loot cargo and the remaining-loot count.
fn draw_loot_art(art : GameArt, x : Float, y : Float, loot : Int) -> Unit {
  draw_texture_centered(art.loot_crate, x, y, 38.0, 28.0, @raylib.white)
  @draw.draw_text(
    "\{loot}",
    (x - 5.0).to_int(),
    (y - 12.0).to_int(),
    18,
    @raylib.Color::new(246, 230, 186, 255),
  )
}

///|
/// Draws a generated sheriff enemy sprite.
fn draw_sheriff_art(art : GameArt, sx : Int, sy : Int, hit : Bool) -> Unit {
  let tint = if hit {
    @raylib.Color::new(255, 238, 148, 255)
  } else {
    @raylib.white
  }
  draw_texture_centered(
    art.sheriff_sprite,
    Float::from_int(sx),
    Float::from_int(sy),
    48.0,
    70.0,
    @raylib.Color::new(10, 8, 8, 112),
  )
  draw_texture_centered(
    art.sheriff_sprite,
    Float::from_int(sx),
    Float::from_int(sy),
    42.0,
    64.0,
    tint,
  )
}

///|
/// Draws the generated outlaw player sprite with dash trails and hit tint.
fn draw_player_art(
  art : GameArt,
  player : Rider,
  px : Int,
  py : Int,
  dash_active : Bool,
) -> Unit {
  if dash_active {
    @raylib.draw_line(
      px - 46,
      py - 40,
      px - 12,
      py - 40,
      @raylib.Color::new(250, 226, 124, 255),
    )
    @raylib.draw_line(
      px - 54,
      py - 27,
      px - 20,
      py - 27,
      @raylib.Color::new(250, 226, 124, 255),
    )
    @raylib.draw_line(
      px - 46,
      py - 14,
      px - 12,
      py - 14,
      @raylib.Color::new(250, 226, 124, 255),
    )
  }

  let tint = if player.flash_t > 0.0 {
    @raylib.Color::new(255, 238, 148, 255)
  } else {
    @raylib.white
  }
  draw_texture_centered(
    art.outlaw_sprite,
    Float::from_int(px),
    Float::from_int(py) - 30.0,
    66.0,
    80.0,
    @raylib.Color::new(10, 8, 8, 120),
  )
  draw_texture_centered(
    art.outlaw_sprite,
    Float::from_int(px),
    Float::from_int(py) - 30.0,
    58.0,
    72.0,
    tint,
  )
}
