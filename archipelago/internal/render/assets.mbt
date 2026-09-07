///|
let tex_archipelago_title : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_ocean_texture : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_island_sprite : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_bridge_segment : Ref[@raylib.Texture?] = { val: None, }

///|
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture("archipelago/resources/" + file_name)
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
pub fn load_assets() -> Unit {
  tex_archipelago_title.val = Some(load_art_texture("archipelago_title.png"))
  tex_ocean_texture.val = Some(load_art_texture("ocean_texture.png"))
  tex_island_sprite.val = Some(load_art_texture("island_sprite.png"))
  tex_bridge_segment.val = Some(load_art_texture("bridge_segment.png"))
}

///|
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

  unload(tex_archipelago_title)
  unload(tex_ocean_texture)
  unload(tex_island_sprite)
  unload(tex_bridge_segment)
}

///|
fn draw_art_rect(
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
  draw_art_rect(texture, x, y, w, h, rotation, tint)
}

///|
fn draw_cover_art(texture : @raylib.Texture) -> Unit {
  let source_w : Float = Float::from_int(texture.width())
  let source_h : Float = Float::from_int(texture.height())
  let screen_w : Float = Float::from_int(@types.screen_width)
  let screen_h : Float = Float::from_int(@types.screen_height)
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
fn draw_title_art() -> Bool {
  match tex_archipelago_title.val {
    Some(texture) => {
      draw_cover_art(texture)
      true
    }
    None => false
  }
}

///|
fn draw_ocean_art() -> Bool {
  match tex_ocean_texture.val {
    Some(texture) => {
      draw_cover_art(texture)
      @raylib.draw_rectangle(
        0,
        0,
        @types.screen_width,
        @types.screen_height,
        @raylib.Color::new(10, 44, 82, 68),
      )
      true
    }
    None => false
  }
}

///|
fn draw_island_art(
  x : Int,
  y : Int,
  radius : Float,
  tint : @raylib.Color,
) -> Bool {
  match tex_island_sprite.val {
    Some(texture) => {
      let size = radius * 2.35
      draw_art_fit(
        texture,
        Float::from_int(x),
        Float::from_int(y),
        size,
        size,
        0.0,
        tint,
      )
      true
    }
    None => false
  }
}

///|
fn draw_bridge_art(
  ax : Float,
  ay : Float,
  bx : Float,
  by : Float,
  direction : @types.BridgeDir,
  tint : @raylib.Color,
) -> Bool {
  match tex_bridge_segment.val {
    Some(texture) => {
      let cx = (ax + bx) * 0.5
      let cy = (ay + by) * 0.5
      let length : Float = match direction {
        Horizontal => @types.absf(bx - ax)
        Vertical => @types.absf(by - ay)
      }
      let rotation : Float = match direction {
        Horizontal => 0.0
        Vertical => 90.0
      }
      draw_art_rect(texture, cx, cy, length, 18.0, rotation, tint)
      true
    }
    None => false
  }
}
