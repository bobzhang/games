///|
/// Generated celestial festival backdrop texture.
let tex_backdrop : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated player kite sprite texture.
let tex_kite : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated lantern collectible sprite texture.
let tex_lantern : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated hostile bird sprite texture.
let tex_bird : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated storm cloud hazard sprite texture.
let tex_storm_cloud : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated energy orb collectible sprite texture.
let tex_energy_orb : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated celestial koi collectible sprite texture.
let tex_koi : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated wind ribbon VFX texture.
let tex_wind_ribbon : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated cloud wisp atmosphere texture.
let tex_cloud_wisp : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated burst halo VFX texture.
let tex_burst_halo : Ref[@raylib.Texture?] = { val: None, }

///|
/// Loads one generated celestial kite festival texture.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "celestial_kite_festival_2026/resources/" + file_name,
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads generated celestial kite festival render assets.
pub fn load_assets() -> Unit {
  tex_backdrop.val = Some(load_art_texture("festival_sky_backdrop.png"))
  tex_kite.val = Some(load_art_texture("kite_sprite.png"))
  tex_lantern.val = Some(load_art_texture("lantern_sprite.png"))
  tex_bird.val = Some(load_art_texture("bird_sprite.png"))
  tex_storm_cloud.val = Some(load_art_texture("storm_cloud_sprite.png"))
  tex_energy_orb.val = Some(load_art_texture("energy_orb_sprite.png"))
  tex_koi.val = Some(load_art_texture("koi_sprite.png"))
  tex_wind_ribbon.val = Some(load_art_texture("wind_ribbon_sprite.png"))
  tex_cloud_wisp.val = Some(load_art_texture("cloud_wisp_sprite.png"))
  tex_burst_halo.val = Some(load_art_texture("burst_halo_sprite.png"))
}

///|
/// Unloads generated celestial kite festival render assets.
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

  unload(tex_backdrop)
  unload(tex_kite)
  unload(tex_lantern)
  unload(tex_bird)
  unload(tex_storm_cloud)
  unload(tex_energy_orb)
  unload(tex_koi)
  unload(tex_wind_ribbon)
  unload(tex_cloud_wisp)
  unload(tex_burst_halo)
}

///|
/// Draws a generated texture centered on a destination rectangle.
fn draw_art_centered(
  texture : @raylib.Texture,
  cx : Float,
  cy : Float,
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
    @raylib.Rectangle::new(cx, cy, width, height),
    @raylib.Vector2::new(width * 0.5, height * 0.5),
    rotation,
    tint,
  )
}

///|
/// Draws a generated texture centered on a destination rectangle, optionally flipped horizontally.
fn draw_art_centered_flip_x(
  texture : @raylib.Texture,
  cx : Float,
  cy : Float,
  width : Float,
  height : Float,
  rotation : Float,
  flip_x : Bool,
  tint : @raylib.Color,
) -> Unit {
  let source_w = Float::from_int(texture.width())
  let (source_x, source_width) = if flip_x {
    (source_w, -source_w)
  } else {
    (0.0, source_w)
  }

  @raylib.draw_texture_pro(
    texture,
    @raylib.Rectangle::new(
      source_x,
      0.0,
      source_width,
      Float::from_int(texture.height()),
    ),
    @raylib.Rectangle::new(cx, cy, width, height),
    @raylib.Vector2::new(width * 0.5, height * 0.5),
    rotation,
    tint,
  )
}

///|
/// Draws a full-screen cover crop for the generated festival backdrop.
fn draw_cover_art(texture : @raylib.Texture) -> Unit {
  let source_w : Float = Float::from_int(texture.width())
  let source_h : Float = Float::from_int(texture.height())
  let screen_w : Float = Float::from_int(@types.screen_w)
  let screen_h : Float = Float::from_int(@types.screen_h)
  let source_ratio = source_w / source_h
  let screen_ratio = screen_w / screen_h

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
/// Draws the generated festival sky backdrop when loaded.
fn draw_backdrop_art() -> Bool {
  match tex_backdrop.val {
    Some(texture) => {
      draw_cover_art(texture)
      true
    }
    None => false
  }
}

///|
/// Draws the generated cloud wisp atmosphere sprite when loaded.
fn draw_cloud_wisp_art(
  cx : Float,
  cy : Float,
  width : Float,
  height : Float,
  tint : @raylib.Color,
) -> Bool {
  match tex_cloud_wisp.val {
    Some(texture) => {
      draw_art_centered(texture, cx, cy, width, height, 0.0, tint)
      true
    }
    None => false
  }
}

///|
/// Draws the generated wind ribbon sprite when loaded.
fn draw_wind_ribbon_art(
  cx : Float,
  cy : Float,
  width : Float,
  height : Float,
  rotation : Float,
  tint : @raylib.Color,
) -> Bool {
  match tex_wind_ribbon.val {
    Some(texture) => {
      draw_art_centered(texture, cx, cy, width, height, rotation, tint)
      true
    }
    None => false
  }
}

///|
/// Draws the generated player kite sprite when loaded.
fn draw_kite_art(
  cx : Float,
  cy : Float,
  width : Float,
  height : Float,
  rotation : Float,
  tint : @raylib.Color,
) -> Bool {
  match tex_kite.val {
    Some(texture) => {
      draw_art_centered(texture, cx, cy, width, height, rotation, tint)
      true
    }
    None => false
  }
}

///|
/// Draws the generated lantern collectible sprite when loaded.
fn draw_lantern_art(
  cx : Float,
  cy : Float,
  width : Float,
  height : Float,
  tint : @raylib.Color,
) -> Bool {
  match tex_lantern.val {
    Some(texture) => {
      draw_art_centered(texture, cx, cy, width, height, 0.0, tint)
      true
    }
    None => false
  }
}

///|
/// Draws the generated hostile bird sprite when loaded.
fn draw_bird_art(
  cx : Float,
  cy : Float,
  width : Float,
  height : Float,
  rotation : Float,
  tint : @raylib.Color,
) -> Bool {
  match tex_bird.val {
    Some(texture) => {
      draw_art_centered(texture, cx, cy, width, height, rotation, tint)
      true
    }
    None => false
  }
}

///|
/// Draws the generated storm cloud hazard sprite when loaded.
fn draw_storm_cloud_art(
  cx : Float,
  cy : Float,
  width : Float,
  height : Float,
  tint : @raylib.Color,
) -> Bool {
  match tex_storm_cloud.val {
    Some(texture) => {
      draw_art_centered(texture, cx, cy, width, height, 0.0, tint)
      true
    }
    None => false
  }
}

///|
/// Draws the generated energy orb collectible sprite when loaded.
fn draw_energy_orb_art(
  cx : Float,
  cy : Float,
  size : Float,
  tint : @raylib.Color,
) -> Bool {
  match tex_energy_orb.val {
    Some(texture) => {
      draw_art_centered(texture, cx, cy, size, size, 0.0, tint)
      true
    }
    None => false
  }
}

///|
/// Draws the generated celestial koi collectible sprite when loaded.
fn draw_koi_art(
  cx : Float,
  cy : Float,
  width : Float,
  height : Float,
  flip_x : Bool,
  tint : @raylib.Color,
) -> Bool {
  match tex_koi.val {
    Some(texture) => {
      draw_art_centered_flip_x(
        texture, cx, cy, width, height, 0.0, flip_x, tint,
      )
      true
    }
    None => false
  }
}

///|
/// Draws the generated burst halo sprite when loaded.
fn draw_burst_halo_art(
  cx : Float,
  cy : Float,
  size : Float,
  tint : @raylib.Color,
) -> Bool {
  match tex_burst_halo.val {
    Some(texture) => {
      draw_art_centered(texture, cx, cy, size, size, 0.0, tint)
      true
    }
    None => false
  }
}
