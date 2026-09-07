///|
let tex_title : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_player : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_relic : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_spike_trap : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_dart_trap : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_lava_hazard : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_pressure_plate : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_stone_door : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_exit_gate : Ref[@raylib.Texture?] = { val: None, }

///|
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "ancient_temple_trap_run_2026/resources/" + file_name,
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Load all generated temple art textures used by the render package.
pub fn load_art() -> Unit {
  tex_title.val = Some(load_art_texture("temple_title.png"))
  tex_player.val = Some(load_art_texture("player_sprite.png"))
  tex_relic.val = Some(load_art_texture("relic_sprite.png"))
  tex_spike_trap.val = Some(load_art_texture("spike_trap_sprite.png"))
  tex_dart_trap.val = Some(load_art_texture("dart_trap_sprite.png"))
  tex_lava_hazard.val = Some(load_art_texture("lava_hazard_sprite.png"))
  tex_pressure_plate.val = Some(load_art_texture("pressure_plate_sprite.png"))
  tex_stone_door.val = Some(load_art_texture("stone_door_sprite.png"))
  tex_exit_gate.val = Some(load_art_texture("exit_gate_sprite.png"))
}

///|
/// Unload generated temple art textures and clear their cached references.
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
  unload(tex_player)
  unload(tex_relic)
  unload(tex_spike_trap)
  unload(tex_dart_trap)
  unload(tex_lava_hazard)
  unload(tex_pressure_plate)
  unload(tex_stone_door)
  unload(tex_exit_gate)
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
  cx : Float,
  cy : Float,
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
  draw_art_rect(texture, cx, cy, w, h, rotation, tint)
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
