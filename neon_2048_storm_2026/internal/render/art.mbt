///|
/// Public bundle of generated renderer textures.
pub(all) struct GameArt {
  storm_backdrop : @raylib.Texture
  tile_overlay : @raylib.Texture
  icon_sheet : @raylib.Texture
}

///|
/// Loads one bilinear-filtered texture from the package resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "neon_2048_storm_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads all generated artwork after window initialization.
pub fn load_game_art() -> GameArt {
  {
    storm_backdrop: load_art_texture("neon_storm_backdrop.png"),
    tile_overlay: load_art_texture("tile_energy_overlay.png"),
    icon_sheet: load_art_texture("storm_icons.png"),
  }
}

///|
/// Releases generated textures before the Raylib window is closed.
pub fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.storm_backdrop)
  @raylib.unload_texture(art.tile_overlay)
  @raylib.unload_texture(art.icon_sheet)
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
/// Draws the generated numbered-tile overlay cropped to its visible frame.
fn draw_tile_overlay(
  art : GameArt,
  x : Int,
  y : Int,
  size : Int,
  tint : @raylib.Color,
) -> Unit {
  let source_w : Float = Float::from_int(art.tile_overlay.width())
  let crop : Float = source_w * 0.82
  let offset : Float = (source_w - crop) * 0.5
  @raylib.draw_texture_pro(
    art.tile_overlay,
    @raylib.Rectangle::new(offset, offset, crop, crop),
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
/// Draws one 2x2 generated icon sheet cell centered on the destination point.
fn draw_icon_cell(
  art : GameArt,
  index : Int,
  cx : Float,
  cy : Float,
  w : Float,
  h : Float,
  tint : @raylib.Color,
) -> Unit {
  let cell_w = Float::from_int(art.icon_sheet.width()) / 2.0
  let cell_h = Float::from_int(art.icon_sheet.height()) / 2.0
  let col = index % 2
  let row = index / 2
  @raylib.draw_texture_pro(
    art.icon_sheet,
    @raylib.Rectangle::new(
      Float::from_int(col) * cell_w,
      Float::from_int(row) * cell_h,
      cell_w,
      cell_h,
    ),
    @raylib.Rectangle::new(cx, cy, w, h),
    @raylib.Vector2::new(w * 0.5, h * 0.5),
    0.0,
    tint,
  )
}
