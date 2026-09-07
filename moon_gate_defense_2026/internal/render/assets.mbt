///|
/// Generated lunar battlefield backdrop texture.
let tex_lunar_battlefield_backdrop : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated moon gate portal texture.
let tex_moon_gate_core : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated level 1 guardian node texture.
let tex_guardian_node_l1 : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated level 2 guardian node texture.
let tex_guardian_node_l2 : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated level 3 guardian node texture.
let tex_guardian_node_l3 : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated skitter enemy texture.
let tex_skitter_enemy : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated carapace enemy texture.
let tex_carapace_enemy : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated wraith enemy texture.
let tex_wraith_enemy : Ref[@raylib.Texture?] = { val: None, }

///|
/// Loads one generated Moon Gate Defense texture.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "moon_gate_defense_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads generated render assets after the Raylib window has been initialized.
pub fn load_assets() -> Unit {
  tex_lunar_battlefield_backdrop.val = Some(
    load_art_texture("lunar_battlefield_backdrop.png"),
  )
  tex_moon_gate_core.val = Some(load_art_texture("moon_gate_core.png"))
  tex_guardian_node_l1.val = Some(load_art_texture("guardian_node_l1.png"))
  tex_guardian_node_l2.val = Some(load_art_texture("guardian_node_l2.png"))
  tex_guardian_node_l3.val = Some(load_art_texture("guardian_node_l3.png"))
  tex_skitter_enemy.val = Some(load_art_texture("skitter_enemy.png"))
  tex_carapace_enemy.val = Some(load_art_texture("carapace_enemy.png"))
  tex_wraith_enemy.val = Some(load_art_texture("wraith_enemy.png"))
}

///|
/// Unloads generated render assets before the Raylib window is closed.
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

  unload(tex_lunar_battlefield_backdrop)
  unload(tex_moon_gate_core)
  unload(tex_guardian_node_l1)
  unload(tex_guardian_node_l2)
  unload(tex_guardian_node_l3)
  unload(tex_skitter_enemy)
  unload(tex_carapace_enemy)
  unload(tex_wraith_enemy)
}

///|
/// Draws a texture centered on the destination point with rotation.
fn draw_art_centered_rotated(
  texture : @raylib.Texture,
  cx : Float,
  cy : Float,
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
    @raylib.Rectangle::new(cx, cy, w, h),
    @raylib.Vector2::new(w * 0.5, h * 0.5),
    rotation,
    tint,
  )
}

///|
/// Draws a texture centered on the destination point.
fn draw_art_centered(
  texture : @raylib.Texture,
  cx : Float,
  cy : Float,
  w : Float,
  h : Float,
  tint : @raylib.Color,
) -> Unit {
  draw_art_centered_rotated(texture, cx, cy, w, h, 0.0, tint)
}

///|
/// Draws a texture cover-cropped into the destination rectangle.
fn draw_art_cover(
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
/// Draws the generated lunar battlefield backdrop when loaded.
fn draw_lunar_battlefield_backdrop() -> Bool {
  match tex_lunar_battlefield_backdrop.val {
    Some(texture) => {
      draw_art_cover(
        texture,
        0.0,
        0.0,
        Float::from_int(@types.screen_w),
        Float::from_int(@types.screen_h),
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Draws the generated moon gate portal when loaded.
fn draw_moon_gate_asset(x : Float, y : Float, pulse : Float) -> Unit {
  match tex_moon_gate_core.val {
    Some(texture) => {
      @raylib.draw_circle_v(
        @raylib.Vector2::new(x, y),
        54.0 + pulse.abs(),
        @raylib.Color::new(112, 168, 255, 42),
      )
      draw_art_centered(texture, x, y + 5.0, 116.0, 116.0, @raylib.white)
    }
    None => ()
  }
}

///|
/// Returns the generated texture ref for a guardian node level.
fn node_texture_ref(level : Int) -> Ref[@raylib.Texture?] {
  if level <= 1 {
    tex_guardian_node_l1
  } else if level == 2 {
    tex_guardian_node_l2
  } else {
    tex_guardian_node_l3
  }
}

///|
/// Returns sprite rotation in degrees for a direction, using down as the asset baseline.
fn dir_rotation_degrees(dir : @types.Dir) -> Float {
  match dir {
    Down => 0.0
    Left => 90.0
    Up => 180.0
    Right => 270.0
  }
}

///|
/// Draws a generated guardian node sprite for a given level and facing direction.
fn draw_guardian_node_asset(
  level : Int,
  facing : @types.Dir,
  x : Float,
  y : Float,
  size : Float,
) -> Unit {
  match node_texture_ref(level).val {
    Some(texture) =>
      draw_art_centered_rotated(
        texture,
        x,
        y + size * 0.04,
        size,
        size,
        dir_rotation_degrees(facing),
        @raylib.white,
      )
    None => ()
  }
}

///|
/// Returns the generated texture ref for an enemy kind.
fn enemy_texture_ref(kind : @types.EnemyKind) -> Ref[@raylib.Texture?] {
  match kind {
    Carapace => tex_carapace_enemy
    Wraith => tex_wraith_enemy
    Skitter => tex_skitter_enemy
  }
}

///|
/// Draws a generated enemy sprite scaled to its gameplay collision radius.
fn draw_enemy_asset(enemy : @types.Enemy, x : Float, y : Float) -> Unit {
  match enemy_texture_ref(enemy.kind).val {
    Some(texture) => {
      let size = if enemy.kind == Carapace {
        enemy.radius * 3.25
      } else if enemy.kind == Wraith {
        enemy.radius * 3.1
      } else {
        enemy.radius * 3.0
      }
      let aspect : Float = if enemy.kind == Skitter { 1.34 } else { 1.0 }
      draw_art_centered(texture, x, y, size * aspect, size, @raylib.white)
    }
    None => ()
  }
}
