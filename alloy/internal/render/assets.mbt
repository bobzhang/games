///|
let tex_title : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_crucible : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_iron : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_copper : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_tin : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_gold : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_carbon : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_zinc : Ref[@raylib.Texture?] = { val: None, }

///|
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture("alloy/resources/" + file_name)
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
pub fn load_art() -> Unit {
  tex_title.val = Some(load_art_texture("alloy_title.png"))
  tex_crucible.val = Some(load_art_texture("crucible_sprite.png"))
  tex_iron.val = Some(load_art_texture("iron_sprite.png"))
  tex_copper.val = Some(load_art_texture("copper_sprite.png"))
  tex_tin.val = Some(load_art_texture("tin_sprite.png"))
  tex_gold.val = Some(load_art_texture("gold_sprite.png"))
  tex_carbon.val = Some(load_art_texture("carbon_sprite.png"))
  tex_zinc.val = Some(load_art_texture("zinc_sprite.png"))
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
  unload(tex_crucible)
  unload(tex_iron)
  unload(tex_copper)
  unload(tex_tin)
  unload(tex_gold)
  unload(tex_carbon)
  unload(tex_zinc)
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
fn art_height_for_width(texture : @raylib.Texture, w : Float) -> Float {
  w * Float::from_int(texture.height()) / Float::from_int(texture.width())
}

///|
fn draw_art_width(
  texture : @raylib.Texture,
  x : Float,
  y : Float,
  w : Float,
  rotation : Float,
  tint : @raylib.Color,
) -> Unit {
  draw_centered_art(
    texture,
    x,
    y,
    w,
    art_height_for_width(texture, w),
    rotation,
    tint,
  )
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
fn metal_art(metal : @types.MetalKind) -> @raylib.Texture? {
  match metal {
    Iron => tex_iron.val
    Copper => tex_copper.val
    Tin => tex_tin.val
    Gold => tex_gold.val
    Carbon => tex_carbon.val
    Zinc => tex_zinc.val
  }
}
