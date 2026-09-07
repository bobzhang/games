///|
/// Generated bamboo forest backdrop texture.
let tex_bamboo_backdrop : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated corridor ground texture.
let tex_corridor_texture : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated sentinel player sprite texture.
let tex_sentinel_sprite : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated shrine beacon sprite texture.
let tex_beacon_sprite : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated bamboo trap sprite texture.
let tex_trap_sprite : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated standard infiltrator sprite texture.
let tex_enemy_standard : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated swift infiltrator sprite texture.
let tex_enemy_swift : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated heavy infiltrator sprite texture.
let tex_enemy_heavy : Ref[@raylib.Texture?] = { val: None, }

///|
/// Loads one generated bamboo forest texture.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "bamboo_forest_sentinel_2026/resources/" + file_name,
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads generated bamboo forest render assets.
pub fn load_assets() -> Unit {
  tex_bamboo_backdrop.val = Some(load_art_texture("bamboo_backdrop.png"))
  tex_corridor_texture.val = Some(load_art_texture("corridor_texture.png"))
  tex_sentinel_sprite.val = Some(load_art_texture("sentinel_sprite.png"))
  tex_beacon_sprite.val = Some(load_art_texture("beacon_sprite.png"))
  tex_trap_sprite.val = Some(load_art_texture("trap_sprite.png"))
  tex_enemy_standard.val = Some(load_art_texture("enemy_standard.png"))
  tex_enemy_swift.val = Some(load_art_texture("enemy_swift.png"))
  tex_enemy_heavy.val = Some(load_art_texture("enemy_heavy.png"))
}

///|
/// Unloads generated bamboo forest render assets.
pub fn unload_assets() -> Unit {
  fn unload(texture_ref : Ref[@raylib.Texture?]) -> Unit {
    match texture_ref.val {
      Some(texture) => {
        @raylib.unload_texture(texture)
        texture_ref.val = None
      }
      None => ()
    }
  }

  unload(tex_bamboo_backdrop)
  unload(tex_corridor_texture)
  unload(tex_sentinel_sprite)
  unload(tex_beacon_sprite)
  unload(tex_trap_sprite)
  unload(tex_enemy_standard)
  unload(tex_enemy_swift)
  unload(tex_enemy_heavy)
}

///|
/// Draws a texture centered in a destination rectangle.
fn draw_art_rect(
  texture : @raylib.Texture,
  x : Float,
  y : Float,
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
    @raylib.Rectangle::new(x, y, w, h),
    @raylib.Vector2::new(w * 0.5, h * 0.5),
    rotation,
    tint,
  )
}

///|
/// Draws a generated sprite scaled to fit a centered box.
fn draw_art_fit(
  texture : @raylib.Texture,
  x : Float,
  y : Float,
  max_w : Float,
  max_h : Float,
  rotation : Float,
  tint : @raylib.Color,
) -> Unit {
  let source_w = Float::from_int(texture.width())
  let source_h = Float::from_int(texture.height())
  let source_ratio = source_w / source_h
  let box_ratio = max_w / max_h
  let (w, h) = if source_ratio > box_ratio {
    (max_w, max_w / source_ratio)
  } else {
    (max_h * source_ratio, max_h)
  }
  draw_art_rect(texture, x, y, w, h, rotation, tint)
}

///|
/// Draws a generated texture stretched into a screen rectangle.
fn draw_art_stretched(
  texture : @raylib.Texture,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
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

///|
/// Draws the generated bamboo forest backdrop when loaded.
fn draw_backdrop_art() -> Bool {
  match tex_bamboo_backdrop.val {
    Some(texture) => {
      draw_art_stretched(
        texture, 0, 0, @types.screen_w, @types.screen_h, @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Draws the generated corridor ground texture when loaded.
fn draw_corridor_art() -> Bool {
  match tex_corridor_texture.val {
    Some(texture) => {
      draw_art_stretched(
        texture,
        @types.world_x,
        @types.world_y,
        @types.world_w,
        @types.world_h,
        @raylib.Color::new(210, 234, 202, 255),
      )
      true
    }
    None => false
  }
}

///|
/// Returns generated enemy art for an enemy kind.
fn enemy_art(kind : Int) -> @raylib.Texture? {
  match kind {
    1 => tex_enemy_swift.val
    2 => tex_enemy_heavy.val
    _ => tex_enemy_standard.val
  }
}
