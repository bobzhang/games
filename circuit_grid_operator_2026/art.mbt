///|
/// Generated art resources used by the Circuit Grid Operator renderer.
priv struct GameArt {
  operator_room_backdrop : @raylib.Texture
  circuit_tile_base : @raylib.Texture
  source_node : @raylib.Texture
  sink_node : @raylib.Texture
  fault_marker : @raylib.Texture
}

///|
/// Loads one bilinear-filtered texture from the package resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "circuit_grid_operator_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads the generated operator-room backdrop and grid node sprites.
fn load_game_art() -> GameArt {
  {
    operator_room_backdrop: load_art_texture("operator_room_backdrop.png"),
    circuit_tile_base: load_art_texture("circuit_tile_base.png"),
    source_node: load_art_texture("source_node.png"),
    sink_node: load_art_texture("sink_node.png"),
    fault_marker: load_art_texture("fault_marker.png"),
  }
}

///|
/// Releases generated textures before the Raylib window is closed.
fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.operator_room_backdrop)
  @raylib.unload_texture(art.circuit_tile_base)
  @raylib.unload_texture(art.source_node)
  @raylib.unload_texture(art.sink_node)
  @raylib.unload_texture(art.fault_marker)
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
/// Draws the generated operator room backdrop under the interactive UI.
fn draw_operator_room_backdrop(art : GameArt, state : Int) -> Unit {
  draw_texture_cover(
    art.operator_room_backdrop,
    0.0,
    0.0,
    Float::from_int(sw),
    Float::from_int(sh),
    @raylib.white,
  )

  let shade_alpha = if state == 3 { 92 } else if state == 2 { 42 } else { 58 }
  @raylib.draw_rectangle(
    0,
    0,
    sw,
    sh,
    @raylib.Color::new(0, 4, 12, shade_alpha),
  )
}

///|
/// Draws the generated tile shell for a grid cell.
fn draw_cell_shell_art(
  art : GameArt,
  gx : Int,
  gy : Int,
  base : @raylib.Color,
) -> Unit {
  @raylib.draw_rectangle(gx + 1, gy + 1, cell_sz - 2, cell_sz - 2, base)
  draw_texture_centered(
    art.circuit_tile_base,
    Float::from_int(gx + cell_sz / 2),
    Float::from_int(gy + cell_sz / 2),
    Float::from_int(cell_sz - 2),
    Float::from_int(cell_sz - 2),
    @raylib.Color::new(255, 255, 255, 196),
  )
}

///|
/// Draws a generated source or sink device on top of the wire glyph.
fn draw_terminal_node_art(
  art : GameArt,
  kind : Int,
  cx : Float,
  cy : Float,
) -> Unit {
  if kind == 5 {
    draw_texture_centered(art.source_node, cx, cy, 60.0, 60.0, @raylib.white)
  } else if kind == 6 {
    draw_texture_centered(art.sink_node, cx, cy, 62.0, 62.0, @raylib.white)
  }
}

///|
/// Draws the generated fault marker over a damaged cell.
fn draw_fault_marker_art(
  art : GameArt,
  cx : Float,
  cy : Float,
  flash : Float,
) -> Unit {
  let alpha : Int = 170 + (flash * 70.0).to_int()
  draw_texture_centered(
    art.fault_marker,
    cx,
    cy,
    66.0,
    66.0,
    @raylib.Color::new(255, 255, 255, alpha),
  )
}
