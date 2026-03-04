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
