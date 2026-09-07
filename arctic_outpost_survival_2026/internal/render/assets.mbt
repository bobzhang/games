///|
/// Generated arctic outpost backdrop texture.
let tex_outpost_backdrop : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated snowfield world texture.
let tex_snowfield_texture : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated thermal core sprite texture.
let tex_core_sprite : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated player defender sprite texture.
let tex_player_sprite : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated wolf enemy sprite texture.
let tex_enemy_wolf : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated brute enemy sprite texture.
let tex_enemy_brute : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated shard enemy sprite texture.
let tex_enemy_shard : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated fuel pickup sprite texture.
let tex_pickup_fuel : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated medkit pickup sprite texture.
let tex_pickup_medkit : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated ammo pickup sprite texture.
let tex_pickup_ammo : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated overdrive pickup sprite texture.
let tex_pickup_overdrive : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated projectile sprite texture.
let tex_projectile_sprite : Ref[@raylib.Texture?] = { val: None, }

///|
/// Loads one generated arctic outpost texture.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "arctic_outpost_survival_2026/resources/" + file_name,
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads generated arctic outpost render assets.
pub fn load_assets() -> Unit {
  tex_outpost_backdrop.val = Some(load_art_texture("outpost_backdrop.png"))
  tex_snowfield_texture.val = Some(load_art_texture("snowfield_texture.png"))
  tex_core_sprite.val = Some(load_art_texture("core_sprite.png"))
  tex_player_sprite.val = Some(load_art_texture("player_sprite.png"))
  tex_enemy_wolf.val = Some(load_art_texture("enemy_wolf.png"))
  tex_enemy_brute.val = Some(load_art_texture("enemy_brute.png"))
  tex_enemy_shard.val = Some(load_art_texture("enemy_shard.png"))
  tex_pickup_fuel.val = Some(load_art_texture("pickup_fuel.png"))
  tex_pickup_medkit.val = Some(load_art_texture("pickup_medkit.png"))
  tex_pickup_ammo.val = Some(load_art_texture("pickup_ammo.png"))
  tex_pickup_overdrive.val = Some(load_art_texture("pickup_overdrive.png"))
  tex_projectile_sprite.val = Some(load_art_texture("projectile_sprite.png"))
}

///|
/// Unloads generated arctic outpost render assets.
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

  unload(tex_outpost_backdrop)
  unload(tex_snowfield_texture)
  unload(tex_core_sprite)
  unload(tex_player_sprite)
  unload(tex_enemy_wolf)
  unload(tex_enemy_brute)
  unload(tex_enemy_shard)
  unload(tex_pickup_fuel)
  unload(tex_pickup_medkit)
  unload(tex_pickup_ammo)
  unload(tex_pickup_overdrive)
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
/// Draws a texture stretched into an axis-aligned screen rectangle.
fn draw_art_stretched(
  texture : @raylib.Texture,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
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
    @raylib.Rectangle::new(
      Float::from_int(x),
      Float::from_int(y),
      Float::from_int(w),
      Float::from_int(h),
    ),
    @raylib.Vector2::new(0.0, 0.0),
    0.0,
    tint,
  )
}

///|
/// Draws a generated image as full-screen cover art.
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
/// Draws the generated arctic outpost backdrop when loaded.
fn draw_backdrop_art() -> Bool {
  match tex_outpost_backdrop.val {
    Some(texture) => {
      draw_cover_art(texture)
      true
    }
    None => false
  }
}

///|
/// Draws the generated snowfield texture into the play area when loaded.
fn draw_snowfield_art(ox : Int, oy : Int) -> Bool {
  match tex_snowfield_texture.val {
    Some(texture) => {
      draw_art_stretched(
        texture,
        @types.world_x0 + ox,
        @types.world_y0 + oy,
        @types.world_w,
        @types.world_h,
        @raylib.Color::new(210, 232, 246, 255),
      )
      true
    }
    None => false
  }
}

///|
/// Returns generated enemy art for supported enemy kinds.
fn enemy_art(kind : @types.EnemyKind) -> @raylib.Texture? {
  match kind {
    Wolf => tex_enemy_wolf.val
    Brute => tex_enemy_brute.val
    Shard => tex_enemy_shard.val
  }
}

///|
/// Returns generated pickup art for a supply kind.
fn pickup_art(kind : @types.PickupKind) -> @raylib.Texture? {
  match kind {
    Fuel => tex_pickup_fuel.val
    Medkit => tex_pickup_medkit.val
    Ammo => tex_pickup_ammo.val
    Overdrive => tex_pickup_overdrive.val
  }
}

///|
/// Returns generated projectile art when available.
fn projectile_art() -> @raylib.Texture? {
  tex_projectile_sprite.val
}
