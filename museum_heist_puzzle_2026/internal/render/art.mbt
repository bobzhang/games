///|
/// Public bundle of generated renderer textures.
pub(all) struct GameArt {
  museum_backdrop : @raylib.Texture
  floor_tile : @raylib.Texture
  wall_tile : @raylib.Texture
  panel_skin : @raylib.Texture
  sprite_sheet : @raylib.Texture
}

///|
/// Loads one bilinear-filtered texture from the package resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "museum_heist_puzzle_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads all generated artwork after window initialization.
pub fn load_game_art() -> GameArt {
  {
    museum_backdrop: load_art_texture("museum_backdrop.png"),
    floor_tile: load_art_texture("museum_floor_tile.png"),
    wall_tile: load_art_texture("museum_wall_tile.png"),
    panel_skin: load_art_texture("museum_panel.png"),
    sprite_sheet: load_art_texture("museum_sprites.png"),
  }
}

///|
/// Releases generated textures before the Raylib window is closed.
pub fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.museum_backdrop)
  @raylib.unload_texture(art.floor_tile)
  @raylib.unload_texture(art.wall_tile)
  @raylib.unload_texture(art.panel_skin)
  @raylib.unload_texture(art.sprite_sheet)
}

///|
/// Draws a texture stretched into the full destination rectangle.
fn draw_texture_rect(
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
/// Draws one 3x2 sprite sheet cell centered on the destination point.
fn draw_sprite_cell(
  art : GameArt,
  index : Int,
  cx : Float,
  cy : Float,
  w : Float,
  h : Float,
  tint : @raylib.Color,
) -> Unit {
  let cell_w = Float::from_int(art.sprite_sheet.width()) / 3.0
  let cell_h = Float::from_int(art.sprite_sheet.height()) / 2.0
  let col = index % 3
  let row = index / 3
  @raylib.draw_texture_pro(
    art.sprite_sheet,
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
