///|
let tex_title : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_hero : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_slime : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_skeleton : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_archer : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_bat : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_spider : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_golem : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_broodmother : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_lich_king : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_health_potion : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_gold : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_weapon_pickup : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_passive_relic : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_rift_stairs : Ref[@raylib.Texture?] = { val: None, }

///|
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture("abyssal_rift/resources/" + file_name)
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
pub fn load_art() -> Unit {
  tex_title.val = Some(load_art_texture("abyssal_title.png"))
  tex_hero.val = Some(load_art_texture("hero_sprite.png"))
  tex_slime.val = Some(load_art_texture("slime_sprite.png"))
  tex_skeleton.val = Some(load_art_texture("skeleton_sprite.png"))
  tex_archer.val = Some(load_art_texture("archer_sprite.png"))
  tex_bat.val = Some(load_art_texture("bat_sprite.png"))
  tex_spider.val = Some(load_art_texture("spider_sprite.png"))
  tex_golem.val = Some(load_art_texture("golem_sprite.png"))
  tex_broodmother.val = Some(load_art_texture("broodmother_sprite.png"))
  tex_lich_king.val = Some(load_art_texture("lich_king_sprite.png"))
  tex_health_potion.val = Some(load_art_texture("health_potion_sprite.png"))
  tex_gold.val = Some(load_art_texture("gold_sprite.png"))
  tex_weapon_pickup.val = Some(load_art_texture("weapon_pickup_sprite.png"))
  tex_passive_relic.val = Some(load_art_texture("passive_relic_sprite.png"))
  tex_rift_stairs.val = Some(load_art_texture("rift_stairs_sprite.png"))
}

///|
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
  unload(tex_hero)
  unload(tex_slime)
  unload(tex_skeleton)
  unload(tex_archer)
  unload(tex_bat)
  unload(tex_spider)
  unload(tex_golem)
  unload(tex_broodmother)
  unload(tex_lich_king)
  unload(tex_health_potion)
  unload(tex_gold)
  unload(tex_weapon_pickup)
  unload(tex_passive_relic)
  unload(tex_rift_stairs)
}

///|
fn white_alpha(alpha : Int) -> @raylib.Color {
  @raylib.Color::new(255, 255, 255, @types.clampi(alpha, 0, 255))
}

///|
fn draw_centered_art(
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
fn art_height_for_width(texture : @raylib.Texture, w : Float) -> Float {
  w * Float::from_int(texture.height()) / Float::from_int(texture.width())
}

///|
fn draw_art_width(
  texture : @raylib.Texture,
  x : Float,
  y : Float,
  w : Float,
  rotation : Float,
  tint : @raylib.Color,
) -> Unit {
  draw_centered_art(
    texture,
    x,
    y,
    w,
    art_height_for_width(texture, w),
    rotation,
    tint,
  )
}

///|
fn draw_title_art(title_art : @raylib.Texture, tint : @raylib.Color) -> Unit {
  let source_w : Float = Float::from_int(title_art.width())
  let source_h : Float = Float::from_int(title_art.height())
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
    title_art,
    @raylib.Rectangle::new(src_x, src_y, src_w, src_h),
    @raylib.Rectangle::new(0.0, 0.0, screen_w, screen_h),
    @raylib.Vector2::new(0.0, 0.0),
    0.0,
    tint,
  )
}

///|
fn enemy_art(kind : @types.EnemyKind) -> @raylib.Texture? {
  match kind {
    Slime | SlimeSmall => tex_slime.val
    Skeleton => tex_skeleton.val
    Archer => tex_archer.val
    Bat => tex_bat.val
    Spider => tex_spider.val
    Golem => tex_golem.val
    BroodMother => tex_broodmother.val
    LichKing => tex_lich_king.val
  }
}

///|
fn enemy_art_width(kind : @types.EnemyKind, radius : Float) -> Float {
  match kind {
    Slime => radius * 3.0
    SlimeSmall => radius * 2.8
    Skeleton => radius * 3.2
    Archer => radius * 3.35
    Bat => radius * 4.2
    Spider => radius * 3.35
    Golem => radius * 3.1
    BroodMother => radius * 3.25
    LichKing => radius * 3.0
  }
}

///|
fn draw_item_art(
  kind : @types.ItemKind,
  x : Float,
  y : Float,
  size : Float,
  alpha : Int,
) -> Bool {
  match kind {
    Gold(_) =>
      match tex_gold.val {
        Some(texture) => {
          draw_art_width(texture, x, y, size * 1.45, 0.0, white_alpha(alpha))
          true
        }
        None => false
      }
    HealthPotion =>
      match tex_health_potion.val {
        Some(texture) => {
          draw_art_width(texture, x, y, size * 0.92, 0.0, white_alpha(alpha))
          true
        }
        None => false
      }
    WeaponPickup(_) =>
      match tex_weapon_pickup.val {
        Some(texture) => {
          draw_art_width(texture, x, y, size * 1.45, 0.0, white_alpha(alpha))
          true
        }
        None => false
      }
    PassiveItem(_) =>
      match tex_passive_relic.val {
        Some(texture) => {
          draw_art_width(texture, x, y, size * 1.35, 0.0, white_alpha(alpha))
          true
        }
        None => false
      }
  }
}
