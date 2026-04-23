///|
/// Generated laboratory arena backdrop texture.
let tex_lab_backdrop : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated heavy three-hit brick texture.
let tex_brick_hp3 : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated medium two-hit brick texture.
let tex_brick_hp2 : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated light one-hit brick texture.
let tex_brick_hp1 : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated plasma ball texture.
let tex_ball_sprite : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated normal paddle texture.
let tex_paddle_sprite : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated wide power paddle texture.
let tex_paddle_wide : Ref[@raylib.Texture?] = { val: None }

///|
/// Loads one bilinear-filtered Breakout Lab texture.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture("breakout_lab_2026/resources/" + file_name)
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads generated Breakout Lab render assets.
fn load_assets() -> Unit {
  tex_lab_backdrop.val = Some(load_art_texture("lab_backdrop.png"))
  tex_brick_hp3.val = Some(load_art_texture("brick_hp3.png"))
  tex_brick_hp2.val = Some(load_art_texture("brick_hp2.png"))
  tex_brick_hp1.val = Some(load_art_texture("brick_hp1.png"))
  tex_ball_sprite.val = Some(load_art_texture("ball_sprite.png"))
  tex_paddle_sprite.val = Some(load_art_texture("paddle_sprite.png"))
  tex_paddle_wide.val = Some(load_art_texture("paddle_wide.png"))
}

///|
/// Unloads generated Breakout Lab render assets.
fn unload_assets() -> Unit {
  fn unload(texture_ref : Ref[@raylib.Texture?]) -> Unit {
    match texture_ref.val {
      Some(texture) => {
        @raylib.unload_texture(texture)
        texture_ref.val = None
      }
      None => ()
    }
  }

  unload(tex_lab_backdrop)
  unload(tex_brick_hp3)
  unload(tex_brick_hp2)
  unload(tex_brick_hp1)
  unload(tex_ball_sprite)
  unload(tex_paddle_sprite)
  unload(tex_paddle_wide)
}

///|
/// Draws a texture centered at the requested destination.
fn draw_art_centered(
  texture : @raylib.Texture,
  center_x : Float,
  center_y : Float,
  width : Float,
  height : Float,
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
    @raylib.Rectangle::new(center_x, center_y, width, height),
    @raylib.Vector2::new(width * 0.5, height * 0.5),
    rotation,
    tint,
  )
}

///|
/// Draws a texture to the requested top-left destination rectangle.
fn draw_art_top_left(
  texture : @raylib.Texture,
  x : Float,
  y : Float,
  width : Float,
  height : Float,
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
    @raylib.Rectangle::new(x, y, width, height),
    @raylib.Vector2::new(0.0, 0.0),
    0.0,
    tint,
  )
}

///|
/// Draws the generated full-screen laboratory backdrop if loaded.
fn draw_backdrop_art() -> Bool {
  match tex_lab_backdrop.val {
    Some(texture) => {
      draw_art_top_left(
        texture,
        0.0,
        0.0,
        Float::from_int(arena_w),
        Float::from_int(arena_h),
        @raylib.white,
      )
      @raylib.draw_rectangle(
        0,
        0,
        arena_w,
        arena_h,
        @raylib.Color::new(2, 4, 12, 76),
      )
      true
    }
    None => false
  }
}

///|
/// Returns generated brick art for a hit-point tier.
fn brick_art(hp : Int) -> @raylib.Texture? {
  match hp {
    3 => tex_brick_hp3.val
    2 => tex_brick_hp2.val
    _ => tex_brick_hp1.val
  }
}

///|
/// Draws a generated brick sprite if loaded.
fn draw_brick_art(brick : Brick) -> Bool {
  match brick_art(brick.hp) {
    Some(texture) => {
      @raylib.draw_rectangle(
        brick.x + 3,
        brick.y + 5,
        brick_w - 6,
        brick_h - 2,
        @raylib.Color::new(0, 0, 0, 72),
      )
      draw_art_centered(
        texture,
        Float::from_int(brick.x + brick_w / 2),
        Float::from_int(brick.y + brick_h / 2),
        Float::from_int(brick_w + 4),
        Float::from_int(brick_h + 2),
        0.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Draws a generated paddle sprite if loaded.
fn draw_paddle_art(
  x : Float,
  y : Float,
  width : Float,
  height : Float,
  wide : Bool,
) -> Bool {
  let texture = if wide { tex_paddle_wide.val } else { tex_paddle_sprite.val }
  match texture {
    Some(texture) => {
      @raylib.draw_ellipse(
        (x + width * 0.5).to_int(),
        (y + height * 1.15).to_int(),
        width * 0.45,
        height * 0.48,
        @raylib.Color::new(0, 0, 0, 78),
      )
      draw_art_centered(
        texture,
        x + width * 0.5,
        y + height * 0.5,
        width + 16.0,
        height * 2.0,
        0.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Draws a generated ball sprite if loaded.
fn draw_ball_art(x : Float, y : Float, radius : Float) -> Bool {
  match tex_ball_sprite.val {
    Some(texture) => {
      @raylib.draw_circle(
        x.to_int(),
        y.to_int(),
        radius * 1.7,
        @raylib.Color::new(86, 224, 255, 42),
      )
      draw_art_centered(
        texture,
        x,
        y,
        radius * 3.15,
        radius * 3.15,
        0.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}
