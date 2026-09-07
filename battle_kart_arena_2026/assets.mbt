///|
/// Generated battle kart arena backdrop texture.
let tex_arena_backdrop : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated kart sprite texture.
let tex_kart_sprite : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated ammo pickup sprite texture.
let tex_pickup_ammo : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated boost pickup sprite texture.
let tex_pickup_boost : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated repair pickup sprite texture.
let tex_pickup_repair : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated projectile sprite texture.
let tex_projectile_sprite : Ref[@raylib.Texture?] = { val: None, }

///|
/// Loads one generated battle kart texture.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "battle_kart_arena_2026/resources/" + file_name,
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads generated battle kart render assets.
fn load_assets() -> Unit {
  tex_arena_backdrop.val = Some(load_art_texture("arena_backdrop.png"))
  tex_kart_sprite.val = Some(load_art_texture("kart_sprite.png"))
  tex_pickup_ammo.val = Some(load_art_texture("pickup_ammo.png"))
  tex_pickup_boost.val = Some(load_art_texture("pickup_boost.png"))
  tex_pickup_repair.val = Some(load_art_texture("pickup_repair.png"))
  tex_projectile_sprite.val = Some(load_art_texture("projectile_sprite.png"))
}

///|
/// Unloads generated battle kart render assets.
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

  unload(tex_arena_backdrop)
  unload(tex_kart_sprite)
  unload(tex_pickup_ammo)
  unload(tex_pickup_boost)
  unload(tex_pickup_repair)
  unload(tex_projectile_sprite)
}

///|
/// Draws a texture centered in a destination rectangle.
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
/// Draws a generated sprite scaled to fit a centered box.
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
/// Draws the generated arena backdrop when loaded.
fn draw_arena_art() -> Bool {
  match tex_arena_backdrop.val {
    Some(texture) => {
      @raylib.draw_texture_pro(
        texture,
        @raylib.Rectangle::new(
          0.0,
          0.0,
          Float::from_int(texture.width()),
          Float::from_int(texture.height()),
        ),
        @raylib.Rectangle::new(
          0.0,
          0.0,
          Float::from_int(sw),
          Float::from_int(sh),
        ),
        @raylib.Vector2::new(0.0, 0.0),
        0.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Returns a tint color for a kart index.
fn kart_tint(index : Int) -> @raylib.Color {
  if index == 0 {
    @raylib.Color::new(180, 238, 255, 255)
  } else if index == 1 {
    @raylib.Color::new(255, 178, 170, 255)
  } else if index == 2 {
    @raylib.Color::new(255, 226, 150, 255)
  } else {
    @raylib.Color::new(214, 196, 255, 255)
  }
}

///|
/// Draws a generated kart sprite when available.
fn draw_kart_art(index : Int, x : Float, y : Float, angle : Float) -> Bool {
  match tex_kart_sprite.val {
    Some(texture) => {
      draw_art_fit(texture, x, y, 54.0, 40.0, angle, kart_tint(index))
      true
    }
    None => false
  }
}

///|
/// Returns generated pickup art for a pickup kind.
fn pickup_art(kind : Int) -> @raylib.Texture? {
  if kind == 0 {
    tex_pickup_ammo.val
  } else if kind == 1 {
    tex_pickup_boost.val
  } else {
    tex_pickup_repair.val
  }
}

///|
/// Draws a generated pickup sprite when available.
fn draw_pickup_art(kind : Int, x : Float, y : Float) -> Bool {
  match pickup_art(kind) {
    Some(texture) => {
      let tint = if kind == 0 {
        @raylib.Color::new(190, 238, 255, 255)
      } else if kind == 1 {
        @raylib.Color::new(255, 222, 160, 255)
      } else {
        @raylib.Color::new(190, 255, 204, 255)
      }
      draw_art_fit(texture, x, y, 38.0, 38.0, 0.0, tint)
      true
    }
    None => false
  }
}

///|
/// Draws a generated projectile sprite when available.
fn draw_projectile_art(
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  owner : Int,
) -> Bool {
  match tex_projectile_sprite.val {
    Some(texture) => {
      let angle = Float::from_double(
        @math.atan2(vy.to_double(), vx.to_double()) * 57.29577951308232,
      )
      let tint = if owner == 0 {
        @raylib.Color::new(255, 246, 198, 255)
      } else {
        @raylib.Color::new(255, 172, 172, 255)
      }
      draw_art_fit(texture, x, y, 24.0, 8.0, angle, tint)
      true
    }
    None => false
  }
}
