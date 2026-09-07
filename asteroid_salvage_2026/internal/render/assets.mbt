///|
/// Generated deep-space salvage backdrop texture.
let tex_salvage_backdrop : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated player ship sprite texture.
let tex_ship_sprite : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated large asteroid sprite texture.
let tex_asteroid_large : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated medium asteroid sprite texture.
let tex_asteroid_medium : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated small asteroid sprite texture.
let tex_asteroid_small : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated projectile sprite texture.
let tex_projectile_sprite : Ref[@raylib.Texture?] = { val: None, }

///|
/// Loads one generated asteroid salvage texture.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "asteroid_salvage_2026/resources/" + file_name,
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads generated asteroid salvage render assets.
pub fn load_assets() -> Unit {
  tex_salvage_backdrop.val = Some(load_art_texture("salvage_backdrop.png"))
  tex_ship_sprite.val = Some(load_art_texture("ship_sprite.png"))
  tex_asteroid_large.val = Some(load_art_texture("asteroid_large.png"))
  tex_asteroid_medium.val = Some(load_art_texture("asteroid_medium.png"))
  tex_asteroid_small.val = Some(load_art_texture("asteroid_small.png"))
  tex_projectile_sprite.val = Some(load_art_texture("projectile_sprite.png"))
}

///|
/// Unloads generated asteroid salvage render assets.
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

  unload(tex_salvage_backdrop)
  unload(tex_ship_sprite)
  unload(tex_asteroid_large)
  unload(tex_asteroid_medium)
  unload(tex_asteroid_small)
  unload(tex_projectile_sprite)
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
/// Draws the generated full-screen backdrop when loaded.
fn draw_backdrop_art() -> Bool {
  match tex_salvage_backdrop.val {
    Some(texture) => {
      @raylib.draw_texture_pro(
        texture,
        @raylib.Rectangle::new(
          0.0,
          0.0,
          Float::from_int(texture.width()),
          Float::from_int(texture.height()),
        ),
        @raylib.Rectangle::new(
          0.0,
          0.0,
          Float::from_int(@types.screen_width),
          Float::from_int(@types.screen_height),
        ),
        @raylib.Vector2::new(0.0, 0.0),
        0.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Returns generated asteroid art for a size tier.
fn asteroid_art(size : Int) -> @raylib.Texture? {
  match size {
    2 => tex_asteroid_large.val
    1 => tex_asteroid_medium.val
    _ => tex_asteroid_small.val
  }
}
