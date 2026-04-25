///|
/// Generated cyberpunk operations backdrop texture.
let tex_neon_ops_backdrop : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated covered-cell board tile texture.
let tex_covered_cell : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated cyber mine icon texture.
let tex_cyber_mine : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated flag marker icon texture.
let tex_flag_marker : Ref[@raylib.Texture?] = { val: None }

///|
/// Loads one generated Minesweeper Neon Ops texture.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "minesweeper_neon_ops_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads generated render assets after the window has been initialized.
pub fn load_assets() -> Unit {
  tex_neon_ops_backdrop.val = Some(load_art_texture("neon_ops_backdrop.png"))
  tex_covered_cell.val = Some(load_art_texture("covered_cell.png"))
  tex_cyber_mine.val = Some(load_art_texture("cyber_mine.png"))
  tex_flag_marker.val = Some(load_art_texture("flag_marker.png"))
}

///|
/// Unloads generated render assets before the Raylib window is closed.
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

  unload(tex_neon_ops_backdrop)
  unload(tex_covered_cell)
  unload(tex_cyber_mine)
  unload(tex_flag_marker)
}

///|
/// Draws a texture centered on the destination point.
fn draw_art_centered(
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
fn draw_art_cover(
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
