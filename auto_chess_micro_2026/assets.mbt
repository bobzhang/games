///|
/// Generated auto-chess arena backdrop texture.
let tex_auto_chess_arena : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated tank unit sprite texture.
let tex_unit_tank : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated archer unit sprite texture.
let tex_unit_archer : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated blade unit sprite texture.
let tex_unit_blade : Ref[@raylib.Texture?] = { val: None }

///|
/// Loads one generated auto-chess texture.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "auto_chess_micro_2026/resources/" + file_name,
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads generated auto-chess render assets.
fn load_assets() -> Unit {
  tex_auto_chess_arena.val = Some(load_art_texture("auto_chess_arena.png"))
  tex_unit_tank.val = Some(load_art_texture("unit_tank.png"))
  tex_unit_archer.val = Some(load_art_texture("unit_archer.png"))
  tex_unit_blade.val = Some(load_art_texture("unit_blade.png"))
}

///|
/// Unloads generated auto-chess render assets.
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

  unload(tex_auto_chess_arena)
  unload(tex_unit_tank)
  unload(tex_unit_archer)
  unload(tex_unit_blade)
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
  match tex_auto_chess_arena.val {
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
/// Returns generated unit art for a role.
fn role_art(role : Int) -> @raylib.Texture? {
  match role {
    0 => tex_unit_tank.val
    1 => tex_unit_archer.val
    _ => tex_unit_blade.val
  }
}

///|
/// Returns sprite tint for a unit based on team and role.
fn unit_tint(team : Int, role : Int) -> @raylib.Color {
  if team == 0 {
    match role {
      0 => @raylib.Color::new(214, 232, 255, 255)
      1 => @raylib.Color::new(222, 255, 226, 255)
      _ => @raylib.Color::new(255, 226, 198, 255)
    }
  } else {
    match role {
      0 => @raylib.Color::new(255, 196, 196, 255)
      1 => @raylib.Color::new(255, 178, 178, 255)
      _ => @raylib.Color::new(255, 202, 168, 255)
    }
  }
}

///|
/// Draws a generated unit sprite for a role and team when available.
fn draw_unit_art(
  role : Int,
  team : Int,
  px : Int,
  py : Int,
  pulse : Float,
) -> Bool {
  match role_art(role) {
    Some(texture) => {
      let cx = Float::from_int(px + tile / 2)
      let cy = Float::from_int(py + tile / 2 + 2)
      let size = Float::from_int(tile - 8) + pulse
      @raylib.draw_circle(
        px + tile / 2,
        py + tile / 2 + 8,
        31.0,
        if team == 0 {
          @raylib.Color::new(54, 116, 176, 84)
        } else {
          @raylib.Color::new(176, 58, 68, 86)
        },
      )
      draw_art_fit(texture, cx, cy, size, size, 0.0, unit_tint(team, role))
      true
    }
    None => false
  }
}
