///|
/// Scale factor: 16px source sprites → 48px game tiles.
let sprite_scale : Float = 3.0

///|
let white : @raylib.Color = @raylib.Color::new(255, 255, 255, 255)

///|
/// Draw a sprite from a texture atlas at a screen position with 3x scale.
fn draw_sprite(
  tex : @raylib.Texture,
  src_x : Float,
  src_y : Float,
  src_w : Float,
  src_h : Float,
  dst_x : Int,
  dst_y : Int,
  tint : @raylib.Color
) -> Unit {
  let src = @raylib.Rectangle::new(src_x, src_y, src_w, src_h)
  let dst = @raylib.Rectangle::new(
    Float::from_int(dst_x),
    Float::from_int(dst_y),
    src_w * sprite_scale,
    src_h * sprite_scale,
  )
  @raylib.draw_texture_pro(
    tex,
    src,
    dst,
    @raylib.Vector2::new(0.0, 0.0),
    0.0,
    tint,
  )
}

///|
/// Draw a sprite with animated frames (frames laid out horizontally in the sheet).
fn draw_sprite_anim(
  tex : @raylib.Texture,
  src_x : Float,
  src_y : Float,
  frame_w : Float,
  frame_h : Float,
  frame : Int,
  dst_x : Int,
  dst_y : Int,
  tint : @raylib.Color
) -> Unit {
  draw_sprite(
    tex,
    src_x + Float::from_int(frame) * frame_w,
    src_y,
    frame_w,
    frame_h,
    dst_x,
    dst_y,
    tint,
  )
}
