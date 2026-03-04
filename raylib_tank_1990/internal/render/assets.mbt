///|
priv struct RenderAssets {
  ui_font : @raylib.Font?
  explosion_frames : Array[@raylib.Texture]
  smoke_frames : Array[@raylib.Texture]
}

///|
fn RenderAssets::new() -> RenderAssets {
  { ui_font: None, explosion_frames: [], smoke_frames: [] }
}

///|
let assets : RenderAssets = RenderAssets::new()

///|
fn pick_texture(
  textures : Array[@raylib.Texture],
  seed : Int,
) -> @raylib.Texture? {
  let len = textures.length()
  if len == 0 {
    return None
  }
  let idx = if seed >= 0 { seed % len } else { -seed % len }
  Some(textures[idx])
}

///|
/// Returns the explosion animation frame at `index`.
pub fn explosion_frame(index : Int) -> @raylib.Texture? {
  pick_texture(assets.explosion_frames, index)
}

///|
/// Returns the smoke animation frame at `index`.
pub fn smoke_frame(index : Int) -> @raylib.Texture? {
  pick_texture(assets.smoke_frames, index)
}

///|
/// Returns the loaded UI font, if available.
pub fn ui_font() -> @raylib.Font? {
  assets.ui_font
}

///|
/// Draws a texture centered at `(center_x, center_y)` with the given dimensions and rotation.
pub fn draw_texture_centered(
  texture : @raylib.Texture,
  center_x : Float,
  center_y : Float,
  width : Float,
  height : Float,
  rotation : Float,
  tint : @raylib.Color,
) -> Unit {
  let src = @raylib.Rectangle::new(
    0.0,
    0.0,
    Float::from_int(@raylib.get_texture_width(texture)),
    Float::from_int(@raylib.get_texture_height(texture)),
  )
  let dst = @raylib.Rectangle::new(
    center_x - width * 0.5,
    center_y - height * 0.5,
    width,
    height,
  )
  @raylib.draw_texture_pro(
    texture,
    src,
    dst,
    @raylib.Vector2::new(width * 0.5, height * 0.5),
    rotation,
    tint,
  )
}
