///|
/// Generated relay backdrop texture.
let tex_relay_backdrop : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated icefield world texture.
let tex_icefield_texture : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated rover sprite texture.
let tex_rover_sprite : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated relay tower sprite texture.
let tex_tower_sprite : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated depot sprite texture.
let tex_depot_sprite : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated power-cell sprite texture.
let tex_power_cell_sprite : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated storm vortex sprite texture.
let tex_storm_sprite : Ref[@raylib.Texture?] = { val: None }

///|
/// Loads one generated arctic signal relay texture.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "arctic_signal_relay_2026/resources/" + file_name,
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads generated arctic signal relay render assets.
pub fn load_assets() -> Unit {
  tex_relay_backdrop.val = Some(load_art_texture("relay_backdrop.png"))
  tex_icefield_texture.val = Some(load_art_texture("icefield_texture.png"))
  tex_rover_sprite.val = Some(load_art_texture("rover_sprite.png"))
  tex_tower_sprite.val = Some(load_art_texture("tower_sprite.png"))
  tex_depot_sprite.val = Some(load_art_texture("depot_sprite.png"))
  tex_power_cell_sprite.val = Some(load_art_texture("power_cell_sprite.png"))
  tex_storm_sprite.val = Some(load_art_texture("storm_sprite.png"))
}

///|
/// Unloads generated arctic signal relay render assets.
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

  unload(tex_relay_backdrop)
  unload(tex_icefield_texture)
  unload(tex_rover_sprite)
  unload(tex_tower_sprite)
  unload(tex_depot_sprite)
  unload(tex_power_cell_sprite)
  unload(tex_storm_sprite)
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
/// Draws a texture stretched into an axis-aligned screen rectangle.
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
/// Draws a generated image as full-screen cover art.
fn draw_cover_art(texture : @raylib.Texture) -> Unit {
  let source_w : Float = Float::from_int(texture.width())
  let source_h : Float = Float::from_int(texture.height())
  let screen_w : Float = Float::from_int(@types.screen_w)
  let screen_h : Float = Float::from_int(@types.screen_h)
  let source_ratio : Float = source_w / source_h
  let screen_ratio : Float = screen_w / screen_h

  let mut src_x : Float = 0.0
  let mut src_y : Float = 0.0
  let mut src_w : Float = source_w
  let mut src_h : Float = source_h

  if source_ratio > screen_ratio {
    src_w = source_h * screen_ratio
    src_x = (source_w - src_w) * 0.5
  } else if source_ratio < screen_ratio {
    src_h = source_w / screen_ratio
    src_y = (source_h - src_h) * 0.5
  }

  @raylib.draw_texture_pro(
    texture,
    @raylib.Rectangle::new(src_x, src_y, src_w, src_h),
    @raylib.Rectangle::new(0.0, 0.0, screen_w, screen_h),
    @raylib.Vector2::new(0.0, 0.0),
    0.0,
    @raylib.white,
  )
}

///|
/// Draws the generated relay backdrop when loaded.
fn draw_backdrop_art() -> Bool {
  match tex_relay_backdrop.val {
    Some(texture) => {
      draw_cover_art(texture)
      true
    }
    None => false
  }
}

///|
/// Draws the generated icefield texture into the play area when loaded.
fn draw_icefield_art() -> Bool {
  match tex_icefield_texture.val {
    Some(texture) => {
      draw_art_stretched(
        texture,
        @types.world_x0,
        @types.world_y0,
        @types.world_w,
        @types.world_h,
        @raylib.Color::new(210, 232, 246, 255),
      )
      true
    }
    None => false
  }
}
