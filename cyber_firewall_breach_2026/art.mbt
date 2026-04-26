///|
/// Generated art resources used by Cyber Firewall Breach 2026.
priv struct GameArt {
  network_backdrop : @raylib.Texture
  arena_panel : @raylib.Texture
  core_node : @raylib.Texture
  turret_sprite : @raylib.Texture
  shot_sprite : @raylib.Texture
  enemy_scout : @raylib.Texture
  enemy_trojan : @raylib.Texture
  enemy_brute : @raylib.Texture
}

///|
/// Loads one bilinear-filtered texture from the package resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "cyber_firewall_breach_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads all generated cyber firewall art after the window is initialized.
fn load_game_art() -> GameArt {
  {
    network_backdrop: load_art_texture("network_backdrop.png"),
    arena_panel: load_art_texture("arena_panel.png"),
    core_node: load_art_texture("core_node.png"),
    turret_sprite: load_art_texture("turret_sprite.png"),
    shot_sprite: load_art_texture("shot_sprite.png"),
    enemy_scout: load_art_texture("enemy_scout.png"),
    enemy_trojan: load_art_texture("enemy_trojan.png"),
    enemy_brute: load_art_texture("enemy_brute.png"),
  }
}

///|
/// Releases generated art textures before closing the window.
fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.network_backdrop)
  @raylib.unload_texture(art.arena_panel)
  @raylib.unload_texture(art.core_node)
  @raylib.unload_texture(art.turret_sprite)
  @raylib.unload_texture(art.shot_sprite)
  @raylib.unload_texture(art.enemy_scout)
  @raylib.unload_texture(art.enemy_trojan)
  @raylib.unload_texture(art.enemy_brute)
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
/// Draws a texture centered inside a max box while preserving source aspect ratio.
fn draw_texture_fit_centered(
  texture : @raylib.Texture,
  cx : Float,
  cy : Float,
  max_w : Float,
  max_h : Float,
  tint : @raylib.Color,
) -> Unit {
  let source_ratio : Float = Float::from_int(texture.width()) /
    Float::from_int(texture.height())
  let dest_ratio : Float = max_w / max_h
  let (w, h) = if source_ratio > dest_ratio {
    (max_w, max_w / source_ratio)
  } else {
    (max_h * source_ratio, max_h)
  }
  draw_texture_centered(texture, cx, cy, w, h, tint)
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
/// Draws the generated network backdrop with gameplay readability overlays.
fn draw_network_backdrop_art(art : GameArt, flash_t : Float) -> Unit {
  draw_texture_cover(
    art.network_backdrop,
    0.0,
    0.0,
    Float::from_int(sw),
    Float::from_int(sh),
    @raylib.white,
  )
  @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(2, 8, 18, 66))
  if flash_t > 0.0 {
    @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(72, 12, 18, 74))
  }
}
