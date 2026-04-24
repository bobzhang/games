///|
/// Holds all generated raster artwork used by the Ghost Mansion Investigation renderer.
struct GameArt {
  title_art : @raylib.Texture
  mansion_backdrop : @raylib.Texture
  investigator_sprite : @raylib.Texture
  ghost_wisp_sprite : @raylib.Texture
  ghost_banshee_sprite : @raylib.Texture
  ghost_brute_sprite : @raylib.Texture
  clue_note_sprite : @raylib.Texture
  clue_relic_sprite : @raylib.Texture
  clue_doll_sprite : @raylib.Texture
}

///|
/// Loads one bilinear-filtered texture from the package resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "ghost_mansion_investigation_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads the generated art bundle. Call after window initialization.
fn load_game_art() -> GameArt {
  {
    title_art: load_art_texture("title_ghost_mansion.png"),
    mansion_backdrop: load_art_texture("mansion_floor_backdrop.png"),
    investigator_sprite: load_art_texture("investigator_sprite.png"),
    ghost_wisp_sprite: load_art_texture("ghost_wisp_sprite.png"),
    ghost_banshee_sprite: load_art_texture("ghost_banshee_sprite.png"),
    ghost_brute_sprite: load_art_texture("ghost_brute_sprite.png"),
    clue_note_sprite: load_art_texture("clue_note_sprite.png"),
    clue_relic_sprite: load_art_texture("clue_relic_sprite.png"),
    clue_doll_sprite: load_art_texture("clue_doll_sprite.png"),
  }
}

///|
/// Releases the generated art bundle before closing the window.
fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.title_art)
  @raylib.unload_texture(art.mansion_backdrop)
  @raylib.unload_texture(art.investigator_sprite)
  @raylib.unload_texture(art.ghost_wisp_sprite)
  @raylib.unload_texture(art.ghost_banshee_sprite)
  @raylib.unload_texture(art.ghost_brute_sprite)
  @raylib.unload_texture(art.clue_note_sprite)
  @raylib.unload_texture(art.clue_relic_sprite)
  @raylib.unload_texture(art.clue_doll_sprite)
}

///|
/// Draws a texture centered on the destination point.
fn draw_texture_centered(
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
/// Returns the ghost texture associated with the gameplay ghost kind.
fn ghost_texture(art : GameArt, kind : Int) -> @raylib.Texture {
  match kind {
    1 => art.ghost_banshee_sprite
    2 => art.ghost_brute_sprite
    _ => art.ghost_wisp_sprite
  }
}

///|
/// Returns the clue texture associated with the gameplay clue kind.
fn clue_texture(art : GameArt, kind : Int) -> @raylib.Texture {
  match kind {
    1 => art.clue_relic_sprite
    2 => art.clue_doll_sprite
    _ => art.clue_note_sprite
  }
}

///|
/// Converts a gameplay facing vector into degrees for a sprite that faces downward by default.
fn facing_rotation(fx : Float, fy : Float) -> Float {
  if fx == 0.0 && fy == 0.0 {
    0.0
  } else {
    @math.atan2f(fy, fx) * 57.29577951308232 - 90.0
  }
}
