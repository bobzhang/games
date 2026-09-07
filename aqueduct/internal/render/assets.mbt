///|
let tex_title : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_spring : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_fountain : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_aqueduct : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_reservoir : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_dam : Ref[@raylib.Texture?] = { val: None, }

///|
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture("aqueduct/resources/" + file_name)
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
pub fn load_art() -> Unit {
  tex_title.val = Some(load_art_texture("aqueduct_title.png"))
  tex_spring.val = Some(load_art_texture("spring_sprite.png"))
  tex_fountain.val = Some(load_art_texture("fountain_sprite.png"))
  tex_aqueduct.val = Some(load_art_texture("aqueduct_tile_sprite.png"))
  tex_reservoir.val = Some(load_art_texture("reservoir_sprite.png"))
  tex_dam.val = Some(load_art_texture("dam_sprite.png"))
}

///|
pub fn unload_art() -> Unit {
  fn unload(texture_ref : Ref[@raylib.Texture?]) -> Unit {
    match texture_ref.val {
      Some(texture) => {
        @raylib.unload_texture(texture)
        texture_ref.val = None
      }
      None => ()
    }
  }

  unload(tex_title)
  unload(tex_spring)
  unload(tex_fountain)
  unload(tex_aqueduct)
  unload(tex_reservoir)
  unload(tex_dam)
}

///|
fn draw_centered_art(
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
  draw_centered_art(texture, x, y, w, h, rotation, tint)
}

///|
fn draw_cover_art(texture : @raylib.Texture, sw : Int, sh : Int) -> Unit {
  let source_w : Float = Float::from_int(texture.width())
  let source_h : Float = Float::from_int(texture.height())
  let screen_w : Float = Float::from_int(sw)
  let screen_h : Float = Float::from_int(sh)
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
fn tool_art(kind : @types.TileKind) -> @raylib.Texture? {
  match kind {
    Spring => tex_spring.val
    Fountain => tex_fountain.val
    Aqueduct => tex_aqueduct.val
    Reservoir => tex_reservoir.val
    Dam => tex_dam.val
    Empty => None
  }
}
