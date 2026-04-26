///|
/// Generated festival backdrop texture.
let tex_festival_backdrop : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated river surface texture.
let tex_river_surface : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated player dragon boat sprite.
let tex_player_boat : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated rival dragon boat sprite.
let tex_rival_boat : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated floating debris sprite.
let tex_debris_log : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated wave ring sprite.
let tex_wave_ring : Ref[@raylib.Texture?] = { val: None }

///|
/// Loads one generated dragon boat texture.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "dragon_boat_sprint_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads generated dragon boat render assets.
pub fn load_assets() -> Unit {
  tex_festival_backdrop.val = Some(load_art_texture("festival_backdrop.png"))
  tex_river_surface.val = Some(load_art_texture("river_surface.png"))
  tex_player_boat.val = Some(load_art_texture("player_boat.png"))
  tex_rival_boat.val = Some(load_art_texture("rival_boat.png"))
  tex_debris_log.val = Some(load_art_texture("debris_log.png"))
  tex_wave_ring.val = Some(load_art_texture("wave_ring.png"))
}

///|
/// Unloads generated dragon boat render assets.
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

  unload(tex_festival_backdrop)
  unload(tex_river_surface)
  unload(tex_player_boat)
  unload(tex_rival_boat)
  unload(tex_debris_log)
  unload(tex_wave_ring)
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
/// Draws a texture cover-cropped into a destination rectangle.
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
/// Draws a generated sprite scaled to fit a centered box.
fn draw_texture_fit(
  texture : @raylib.Texture,
  x : Float,
  y : Float,
  max_w : Float,
  max_h : Float,
  tint : @raylib.Color,
) -> Unit {
  let source_w : Float = Float::from_int(texture.width())
  let source_h : Float = Float::from_int(texture.height())
  let source_ratio : Float = source_w / source_h
  let box_ratio : Float = max_w / max_h
  let mut w : Float = max_w
  let mut h : Float = max_h
  if source_ratio > box_ratio {
    h = max_w / source_ratio
  } else {
    w = max_h * source_ratio
  }
  draw_texture_centered(texture, x, y, w, h, tint)
}

///|
/// Draws the generated festival background when it is loaded.
fn draw_background_art(_game : @types.Game) -> Bool {
  match tex_festival_backdrop.val {
    Some(texture) => {
      draw_texture_cover(
        texture,
        0.0,
        0.0,
        Float::from_int(@types.screen_w),
        Float::from_int(@types.screen_h),
        @raylib.white,
      )
      @raylib.draw_rectangle(
        0,
        0,
        @types.screen_w,
        @types.screen_h,
        @raylib.Color::new(6, 16, 22, 42),
      )
      true
    }
    None => false
  }
}

///|
/// Draws the generated river surface inside the playfield.
fn draw_river_surface_art(_game : @types.Game) -> Bool {
  match tex_river_surface.val {
    Some(texture) => {
      draw_texture_cover(
        texture,
        Float::from_int(@types.river_x),
        Float::from_int(@types.river_y),
        Float::from_int(@types.river_w),
        Float::from_int(@types.river_h),
        @raylib.white,
      )
      @raylib.draw_rectangle(
        @types.river_x,
        @types.river_y,
        @types.river_w,
        @types.river_h,
        @raylib.Color::new(8, 54, 74, 48),
      )
      true
    }
    None => false
  }
}

///|
/// Returns true when generated player boat art is available.
fn has_player_boat_art() -> Bool {
  match tex_player_boat.val {
    Some(_) => true
    None => false
  }
}

///|
/// Draws a generated player or rival boat when available.
fn draw_boat_art(
  x : Int,
  y : Int,
  scale : Float,
  hull : @raylib.Color,
  show_flag : Bool,
) -> Bool {
  let texture_opt = if show_flag { tex_player_boat.val } else { tex_rival_boat.val }
  match texture_opt {
    Some(texture) => {
      @raylib.draw_ellipse(
        x,
        y + (scale * 14.0).to_int(),
        scale * 82.0,
        scale * 16.0,
        @raylib.Color::new(4, 8, 10, 86),
      )
      @raylib.draw_ellipse(
        x,
        y + (scale * 18.0).to_int(),
        scale * 68.0,
        scale * 8.0,
        @raylib.Color::new(
          hull.r.to_int(),
          hull.g.to_int(),
          hull.b.to_int(),
          if show_flag { 70 } else { 104 },
        ),
      )
      draw_texture_fit(
        texture,
        Float::from_int(x),
        Float::from_int(y),
        scale * 174.0,
        scale * 78.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Draws generated debris log art when available.
fn draw_debris_art(x : Int, y : Int, w : Int, h : Int) -> Bool {
  match tex_debris_log.val {
    Some(texture) => {
      draw_texture_fit(
        texture,
        Float::from_int(x),
        Float::from_int(y),
        Float::from_int(w) * 1.18,
        Float::from_int(h) * 1.42,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Draws generated wave-ring art when available.
fn draw_wave_art(x : Int, y : Int, r : Float) -> Bool {
  match tex_wave_ring.val {
    Some(texture) => {
      draw_texture_fit(
        texture,
        Float::from_int(x),
        Float::from_int(y),
        r * 2.28,
        r * 2.28,
        @raylib.Color::new(226, 246, 255, 220),
      )
      true
    }
    None => false
  }
}
