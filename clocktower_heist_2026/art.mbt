///|
/// Generated art resources used by the Clocktower Heist renderer.
priv struct GameArt {
  clocktower_backdrop : @raylib.Texture
  floor_panel : @raylib.Texture
  wall_panel : @raylib.Texture
  thief_sprite : @raylib.Texture
  guard_sprite : @raylib.Texture
  keycard_sprite : @raylib.Texture
  vault_console : @raylib.Texture
  exit_hatch : @raylib.Texture
}

///|
/// Loads one bilinear-filtered texture from the package resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "clocktower_heist_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads generated backdrop, environment, and character art.
fn load_game_art() -> GameArt {
  {
    clocktower_backdrop: load_art_texture("clocktower_backdrop.png"),
    floor_panel: load_art_texture("floor_panel.png"),
    wall_panel: load_art_texture("wall_panel.png"),
    thief_sprite: load_art_texture("thief_sprite.png"),
    guard_sprite: load_art_texture("guard_sprite.png"),
    keycard_sprite: load_art_texture("keycard_sprite.png"),
    vault_console: load_art_texture("vault_console.png"),
    exit_hatch: load_art_texture("exit_hatch.png"),
  }
}

///|
/// Releases generated textures before the Raylib window is closed.
fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.clocktower_backdrop)
  @raylib.unload_texture(art.floor_panel)
  @raylib.unload_texture(art.wall_panel)
  @raylib.unload_texture(art.thief_sprite)
  @raylib.unload_texture(art.guard_sprite)
  @raylib.unload_texture(art.keycard_sprite)
  @raylib.unload_texture(art.vault_console)
  @raylib.unload_texture(art.exit_hatch)
}

///|
/// Draws a texture centered on the destination point with optional rotation.
fn draw_texture_centered_rotated(
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
/// Draws a texture centered on the destination point.
fn draw_texture_centered(
  texture : @raylib.Texture,
  cx : Float,
  cy : Float,
  w : Float,
  h : Float,
  tint : @raylib.Color,
) -> Unit {
  draw_texture_centered_rotated(texture, cx, cy, w, h, 0.0, tint)
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
/// Draws the generated night skyline behind the heist floor.
fn draw_clocktower_backdrop(art : GameArt, flash_t : Float, glow : Int) -> Unit {
  draw_texture_cover(
    art.clocktower_backdrop,
    0.0,
    0.0,
    Float::from_int(sw),
    Float::from_int(sh),
    @raylib.white,
  )

  let full_shade = if flash_t > 0.0 {
    @raylib.Color::new(38, 8, 24, 92)
  } else {
    @raylib.Color::new(4, 8, 18, 68)
  }
  @raylib.draw_rectangle(0, 0, sw, sh, full_shade)
  @raylib.draw_rectangle(
    0,
    0,
    sw,
    250,
    @raylib.Color::new(9, 18 + glow / 14, 42 + glow / 8, 82),
  )
}

///|
/// Draws the generated clockwork floor panel in the playable area.
fn draw_floor_art(art : GameArt) -> Unit {
  @raylib.draw_rectangle(
    20,
    132,
    sw - 40,
    sh - 162,
    @raylib.Color::new(30, 28, 34, 255),
  )
  draw_texture_cover(
    art.floor_panel,
    28.0,
    140.0,
    Float::from_int(sw - 56),
    Float::from_int(sh - 178),
    @raylib.Color::new(255, 255, 255, 224),
  )
  @raylib.draw_rectangle(
    28,
    140,
    sw - 56,
    sh - 178,
    @raylib.Color::new(12, 10, 18, 54),
  )
}

///|
/// Draws one generated stone-and-brass wall segment.
fn draw_wall_art(art : GameArt, x : Int, y : Int, w : Int, h : Int) -> Unit {
  @raylib.draw_rectangle(
    x - 2,
    y - 2,
    w + 4,
    h + 4,
    @raylib.Color::new(28, 24, 28, 255),
  )
  draw_texture_cover(
    art.wall_panel,
    Float::from_int(x),
    Float::from_int(y),
    Float::from_int(w),
    Float::from_int(h),
    @raylib.Color::new(255, 255, 255, 232),
  )
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(206, 170, 96, 120),
  )
}

///|
/// Draws the generated vault console with state tinting.
fn draw_vault_art(
  art : GameArt,
  collected : Int,
  target_cards : Int,
  vault_open : Bool,
) -> Unit {
  let glow = if collected >= target_cards {
    if vault_open {
      @raylib.Color::new(112, 226, 144, 116)
    } else {
      @raylib.Color::new(236, 192, 82, 108)
    }
  } else {
    @raylib.Color::new(78, 116, 156, 82)
  }
  @raylib.draw_rectangle(974, 174, 242, 186, @raylib.Color::new(8, 12, 20, 188))
  @raylib.draw_rectangle(986, 186, 218, 162, glow)
  draw_texture_cover(
    art.vault_console,
    986.0,
    186.0,
    218.0,
    162.0,
    @raylib.Color::new(255, 255, 255, 232),
  )
}

///|
/// Draws the generated extraction hatch.
fn draw_exit_art(art : GameArt, vault_open : Bool) -> Unit {
  let tint = if vault_open {
    @raylib.white
  } else {
    @raylib.Color::new(162, 176, 194, 166)
  }
  @raylib.draw_rectangle(28, 646, 176, 146, @raylib.Color::new(4, 10, 16, 188))
  draw_texture_cover(art.exit_hatch, 36.0, 654.0, 160.0, 130.0, tint)
  if vault_open {
    @raylib.draw_rectangle_lines(
      36,
      654,
      160,
      130,
      @raylib.Color::new(132, 238, 160, 196),
    )
  }
}

///|
/// Returns the accent color for a keycard type.
fn keycard_color(kind : Int) -> @raylib.Color {
  if kind == 0 {
    @raylib.Color::new(246, 212, 124, 255)
  } else if kind == 1 {
    @raylib.Color::new(126, 218, 248, 255)
  } else {
    @raylib.Color::new(224, 156, 252, 255)
  }
}

///|
/// Draws a generated keycard sprite with a readable pickup glow.
fn draw_keycard_art(art : GameArt, card : Keycard, shake_x : Float) -> Unit {
  let cx = card.x + shake_x
  let cy = card.y
  let col = keycard_color(card.kind)
  @raylib.draw_circle(
    cx.to_int(),
    cy.to_int(),
    17.0,
    @raylib.Color::new(col.r.to_int(), col.g.to_int(), col.b.to_int(), 76),
  )
  draw_texture_centered(art.keycard_sprite, cx, cy, 25.0, 40.0, @raylib.white)
}

///|
/// Draws a generated guard sprite over the existing detection cone.
fn draw_guard_art(
  art : GameArt,
  guard_val : Guard,
  gx : Float,
  gy : Float,
) -> Unit {
  if guard_val.stun_t > 0.0 {
    @raylib.draw_circle(
      gx.to_int(),
      gy.to_int(),
      26.0,
      @raylib.Color::new(92, 224, 248, 54),
    )
  }
  let tint = if guard_val.stun_t > 0.0 {
    @raylib.Color::new(196, 244, 255, 255)
  } else {
    @raylib.white
  }
  draw_texture_centered(art.guard_sprite, gx, gy + 6.0, 45.0, 58.0, tint)
}

///|
/// Draws the generated thief sprite with cloak and hit feedback.
fn draw_player_art(art : GameArt, player : Thief, shake_x : Float) -> Unit {
  let px = player.x + shake_x
  let py = player.y
  let tint = if player.flash_t > 0.0 {
    @raylib.Color::new(255, 240, 154, 255)
  } else if player.cloak_t > 0.0 {
    @raylib.Color::new(190, 172, 255, 224)
  } else {
    @raylib.white
  }
  if player.cloak_t > 0.0 {
    @raylib.draw_circle(
      px.to_int(),
      py.to_int(),
      32.0,
      @raylib.Color::new(128, 104, 242, 54),
    )
  }
  draw_texture_centered(art.thief_sprite, px, py + 8.0, 54.0, 58.0, tint)
}
