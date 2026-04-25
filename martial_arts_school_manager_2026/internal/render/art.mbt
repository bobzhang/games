///|
/// Public bundle of generated renderer textures.
pub(all) struct GameArt {
  dojo_backdrop : @raylib.Texture
  title_art : @raylib.Texture
  student_portrait : @raylib.Texture
  rest_icon : @raylib.Texture
  train_icon : @raylib.Texture
  sparring_icon : @raylib.Texture
  defense_icon : @raylib.Texture
}

///|
/// Loads one bilinear-filtered texture from the package resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "martial_arts_school_manager_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads all generated artwork after window initialization.
pub fn load_game_art() -> GameArt {
  {
    dojo_backdrop: load_art_texture("dojo_backdrop.png"),
    title_art: load_art_texture("title_dojo.png"),
    student_portrait: load_art_texture("student_portrait.png"),
    rest_icon: load_art_texture("rest_icon.png"),
    train_icon: load_art_texture("train_icon.png"),
    sparring_icon: load_art_texture("sparring_icon.png"),
    defense_icon: load_art_texture("defense_icon.png"),
  }
}

///|
/// Releases generated textures before the Raylib window is closed.
pub fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.dojo_backdrop)
  @raylib.unload_texture(art.title_art)
  @raylib.unload_texture(art.student_portrait)
  @raylib.unload_texture(art.rest_icon)
  @raylib.unload_texture(art.train_icon)
  @raylib.unload_texture(art.sparring_icon)
  @raylib.unload_texture(art.defense_icon)
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
/// Returns the generated icon associated with a room.
fn room_icon(art : GameArt, room : @types.Room) -> @raylib.Texture {
  match room {
    Rest => art.rest_icon
    Train => art.train_icon
    Sparring => art.sparring_icon
    Defense => art.defense_icon
  }
}
