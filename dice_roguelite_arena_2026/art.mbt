///|
/// Generated art resources used by Dice Roguelite Arena 2026.
priv struct GameArt {
  arena_backdrop : @raylib.Texture
  pilot_avatar : @raylib.Texture
  scrap_berserker : @raylib.Texture
  aegis_sentinel : @raylib.Texture
  venom_archivist : @raylib.Texture
  null_reaper : @raylib.Texture
  dice_tile : @raylib.Texture
  reward_card : @raylib.Texture
}

///|
/// Loads one bilinear-filtered texture from the package resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "dice_roguelite_arena_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads all generated arena textures after the Raylib window is initialized.
fn load_game_art() -> GameArt {
  {
    arena_backdrop: load_art_texture("arena_backdrop.png"),
    pilot_avatar: load_art_texture("pilot_avatar.png"),
    scrap_berserker: load_art_texture("scrap_berserker.png"),
    aegis_sentinel: load_art_texture("aegis_sentinel.png"),
    venom_archivist: load_art_texture("venom_archivist.png"),
    null_reaper: load_art_texture("null_reaper.png"),
    dice_tile: load_art_texture("dice_tile.png"),
    reward_card: load_art_texture("reward_card.png"),
  }
}

///|
/// Releases generated textures before closing the Raylib window.
fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.arena_backdrop)
  @raylib.unload_texture(art.pilot_avatar)
  @raylib.unload_texture(art.scrap_berserker)
  @raylib.unload_texture(art.aegis_sentinel)
  @raylib.unload_texture(art.venom_archivist)
  @raylib.unload_texture(art.null_reaper)
  @raylib.unload_texture(art.dice_tile)
  @raylib.unload_texture(art.reward_card)
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
/// Draws the generated cyberpunk arena backdrop with subtle animated scan lights.
fn draw_arena_backdrop_art(art : GameArt, bg_t : Float) -> Unit {
  draw_texture_cover(
    art.arena_backdrop,
    0.0,
    0.0,
    Float::from_int(sw),
    Float::from_int(sh),
    @raylib.white,
  )
  @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(4, 8, 16, 76))
  for i in 0..<12 {
    let x = (Float::from_int(i) * 132.0 + bg_t * 44.0).to_int() % (sw + 180) -
      90
    let y = 174 + i % 4 * 36
    @raylib.draw_rectangle(x, y, 160, 8, @raylib.Color::new(92, 170, 250, 54))
  }
}

///|
/// Draws the generated player avatar at arena scale.
fn draw_player_avatar_art(art : GameArt, cx : Int, cy : Int) -> Unit {
  draw_texture_centered(
    art.pilot_avatar,
    Float::from_int(cx),
    Float::from_int(cy),
    92.0,
    212.0,
    @raylib.Color::new(4, 8, 12, 118),
  )
  draw_texture_centered(
    art.pilot_avatar,
    Float::from_int(cx),
    Float::from_int(cy),
    78.0,
    196.0,
    @raylib.white,
  )
}

///|
/// Draws the generated enemy sprite selected by enemy kind.
fn draw_enemy_art(art : GameArt, kind : Int, cx : Int, cy : Int) -> Unit {
  let texture = if kind == 0 {
    art.scrap_berserker
  } else if kind == 1 {
    art.aegis_sentinel
  } else if kind == 2 {
    art.venom_archivist
  } else {
    art.null_reaper
  }
  let mut w : Float = 188.0
  let mut h : Float = 154.0
  if kind == 0 {
    w = 178.0
    h = 150.0
  } else if kind == 1 {
    w = 144.0
    h = 174.0
  } else if kind == 2 {
    w = 128.0
    h = 198.0
  }
  draw_texture_centered(
    texture,
    Float::from_int(cx),
    Float::from_int(cy),
    w + 14.0,
    h + 14.0,
    @raylib.Color::new(4, 4, 8, 124),
  )
  draw_texture_centered(
    texture,
    Float::from_int(cx),
    Float::from_int(cy),
    w,
    h,
    @raylib.white,
  )
}

///|
/// Draws the generated dice tile frame with state tinting.
fn draw_dice_tile_art(
  art : GameArt,
  x : Int,
  y : Int,
  size : Int,
  used : Bool,
  hover : Bool,
  pulse_t : Float,
) -> Unit {
  let tint = if used {
    @raylib.Color::new(122, 132, 158, 210)
  } else if pulse_t > 0.0 {
    let glow = (pulse_t * 330.0).to_int().clamp(min=0, max=82)
    @raylib.Color::new(220, 232, 255, 236 + glow / 5)
  } else if hover {
    @raylib.Color::new(210, 228, 255, 252)
  } else {
    @raylib.Color::new(184, 206, 248, 238)
  }
  @raylib.draw_texture_pro(
    art.dice_tile,
    @raylib.Rectangle::new(
      0.0,
      0.0,
      Float::from_int(art.dice_tile.width()),
      Float::from_int(art.dice_tile.height()),
    ),
    @raylib.Rectangle::new(
      Float::from_int(x),
      Float::from_int(y),
      Float::from_int(size),
      Float::from_int(size),
    ),
    @raylib.Vector2::new(0.0, 0.0),
    0.0,
    tint,
  )
}

///|
/// Draws the generated reward card frame.
fn draw_reward_card_art(
  art : GameArt,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  hover : Bool,
) -> Unit {
  let tint = if hover {
    @raylib.Color::new(230, 238, 255, 255)
  } else {
    @raylib.Color::new(196, 212, 250, 246)
  }
  @raylib.draw_texture_pro(
    art.reward_card,
    @raylib.Rectangle::new(
      0.0,
      0.0,
      Float::from_int(art.reward_card.width()),
      Float::from_int(art.reward_card.height()),
    ),
    @raylib.Rectangle::new(
      Float::from_int(x),
      Float::from_int(y),
      Float::from_int(w),
      Float::from_int(h),
    ),
    @raylib.Vector2::new(0.0, 0.0),
    0.0,
    tint,
  )
}
