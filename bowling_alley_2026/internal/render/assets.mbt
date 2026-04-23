///|
/// Generated neon bowling alley backdrop.
let tex_alley_backdrop : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated polished lane wood texture.
let tex_lane_wood : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated glossy bowling ball sprite.
let tex_ball_sprite : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated bowling pin sprite.
let tex_pin_sprite : Ref[@raylib.Texture?] = { val: None }

///|
/// Loads a bilinear-filtered Bowling Alley texture.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture("bowling_alley_2026/resources/" + file_name)
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads all generated Bowling Alley render assets.
pub fn load_assets() -> Unit {
  tex_alley_backdrop.val = Some(load_art_texture("alley_backdrop.png"))
  tex_lane_wood.val = Some(load_art_texture("lane_wood.png"))
  tex_ball_sprite.val = Some(load_art_texture("ball_sprite.png"))
  tex_pin_sprite.val = Some(load_art_texture("pin_sprite.png"))
}

///|
/// Unloads all generated Bowling Alley render assets.
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

  unload(tex_alley_backdrop)
  unload(tex_lane_wood)
  unload(tex_ball_sprite)
  unload(tex_pin_sprite)
}

///|
/// Draws a texture centered at a screen position.
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
/// Draws a texture from a top-left destination rectangle.
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
/// Draws a cover-fitted texture over the full game screen.
fn draw_cover_art(texture : @raylib.Texture) -> Unit {
  let source_w : Float = Float::from_int(texture.width())
  let source_h : Float = Float::from_int(texture.height())
  let screen_w : Float = Float::from_int(@types.screen_w)
  let screen_h : Float = Float::from_int(@types.screen_h)
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
/// Draws the generated alley backdrop if loaded.
fn draw_alley_backdrop_art() -> Bool {
  match tex_alley_backdrop.val {
    Some(texture) => {
      draw_cover_art(texture)
      @raylib.draw_rectangle(
        0,
        0,
        @types.screen_w,
        @types.screen_h,
        @raylib.Color::new(2, 6, 14, 86),
      )
      true
    }
    None => false
  }
}

///|
/// Draws the generated lane surface if loaded.
fn draw_lane_art(sx : Int, sy : Int) -> Bool {
  match tex_lane_wood.val {
    Some(texture) => {
      draw_art_top_left(
        texture,
        Float::from_int(@types.lane_x + sx),
        Float::from_int(@types.lane_y + sy),
        Float::from_int(@types.lane_w),
        Float::from_int(@types.lane_h),
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Draws the generated bowling ball sprite if loaded.
fn draw_ball_art(x : Int, y : Int) -> Bool {
  match tex_ball_sprite.val {
    Some(texture) => {
      @raylib.draw_ellipse(
        x,
        y + 14,
        @types.ball_radius * 1.05,
        @types.ball_radius * 0.35,
        @raylib.Color::new(0, 0, 0, 92),
      )
      draw_art_centered(
        texture,
        Float::from_int(x),
        Float::from_int(y),
        @types.ball_radius * 2.55,
        @types.ball_radius * 2.55,
        0.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Returns a display rotation for a fallen pin.
fn fallen_pin_rotation(pin : @types.Pin) -> Float {
  let speed2 = pin.vx * pin.vx + pin.vy * pin.vy
  if speed2 > 1.0 {
    @math.atan2f(pin.vy, pin.vx) * 57.29577951308232 + 90.0
  } else {
    pin.ang * 57.29577951308232 + 90.0
  }
}

///|
/// Draws the generated bowling pin sprite if loaded.
fn draw_pin_art(pin : @types.Pin, sx : Int, sy : Int) -> Bool {
  match tex_pin_sprite.val {
    Some(texture) => {
      let px : Int = pin.x.to_int() + sx
      let py : Int = pin.y.to_int() + sy
      @raylib.draw_ellipse(
        px,
        py + 14,
        @types.pin_radius * 0.95,
        @types.pin_radius * 0.28,
        @raylib.Color::new(0, 0, 0, 80),
      )
      let rotation : Float = if pin.standing { 0.0 } else { fallen_pin_rotation(pin) }
      let scale_w : Float = if pin.standing { 31.0 } else { 28.0 }
      let scale_h : Float = if pin.standing { 58.0 } else { 64.0 }
      draw_art_centered(
        texture,
        Float::from_int(px),
        Float::from_int(py),
        scale_w,
        scale_h,
        rotation,
        if pin.standing {
          @raylib.white
        } else {
          @raylib.Color::new(232, 238, 244, 232)
        },
      )
      true
    }
    None => false
  }
}
