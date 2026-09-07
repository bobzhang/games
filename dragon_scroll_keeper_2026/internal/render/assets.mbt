///|
/// Generated Ember Archive chamber background.
let tex_room_ember : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated Vault Core chamber background.
let tex_room_core : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated Ink Seal chamber background.
let tex_room_ink : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated keeper sprite.
let tex_keeper : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated raider sprite.
let tex_raider : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated breach portal sprite.
let tex_breach : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated flame sprite.
let tex_flame : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated dragon scroll core sprite.
let tex_scroll_core : Ref[@raylib.Texture?] = { val: None, }

///|
/// Loads one generated Dragon Scroll Keeper texture.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "dragon_scroll_keeper_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads generated Dragon Scroll Keeper render assets.
pub fn load_assets() -> Unit {
  tex_room_ember.val = Some(load_art_texture("room_ember_archive.png"))
  tex_room_core.val = Some(load_art_texture("room_vault_core.png"))
  tex_room_ink.val = Some(load_art_texture("room_ink_seal.png"))
  tex_keeper.val = Some(load_art_texture("keeper_sprite.png"))
  tex_raider.val = Some(load_art_texture("raider_sprite.png"))
  tex_breach.val = Some(load_art_texture("breach_portal.png"))
  tex_flame.val = Some(load_art_texture("flame_sprite.png"))
  tex_scroll_core.val = Some(load_art_texture("scroll_core.png"))
}

///|
/// Unloads generated Dragon Scroll Keeper render assets.
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

  unload(tex_room_ember)
  unload(tex_room_core)
  unload(tex_room_ink)
  unload(tex_keeper)
  unload(tex_raider)
  unload(tex_breach)
  unload(tex_flame)
  unload(tex_scroll_core)
}

///|
/// Returns the generated chamber texture for the room index.
fn room_texture(room : Int) -> @raylib.Texture? {
  if room == 0 {
    tex_room_ember.val
  } else if room == 1 {
    tex_room_core.val
  } else {
    tex_room_ink.val
  }
}

///|
/// Returns a soft readability overlay colour for the room art.
fn room_art_overlay(room : Int, alpha : Int) -> @raylib.Color {
  if room == 0 {
    @raylib.Color::new(54, 28, 18, alpha)
  } else if room == 1 {
    @raylib.Color::new(12, 34, 48, alpha)
  } else {
    @raylib.Color::new(24, 18, 48, alpha)
  }
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
/// Draws generated room art across the full screen as an ambient backdrop.
fn draw_background_art(game : @types.Game) -> Bool {
  match room_texture(game.keeper.room) {
    Some(texture) => {
      draw_texture_cover(
        texture,
        0.0,
        0.0,
        Float::from_int(@types.screen_w),
        Float::from_int(@types.screen_h),
        @raylib.Color::new(116, 132, 148, 255),
      )
      @raylib.draw_rectangle(
        0,
        0,
        @types.screen_w,
        @types.screen_h,
        @raylib.Color::new(4, 8, 14, 168),
      )
      true
    }
    None => false
  }
}

///|
/// Draws generated art inside the active chamber viewport.
fn draw_chamber_art(room : Int) -> Bool {
  match room_texture(room) {
    Some(texture) => {
      draw_texture_cover(
        texture, @types.chamber_left, @types.chamber_top, @types.chamber_w, @types.chamber_h,
        @raylib.white,
      )
      @raylib.draw_rectangle(
        @types.chamber_left.to_int(),
        @types.chamber_top.to_int(),
        @types.chamber_w.to_int(),
        @types.chamber_h.to_int(),
        room_art_overlay(room, 34),
      )
      true
    }
    None => false
  }
}

///|
/// Draws the generated dragon scroll core art.
fn draw_scroll_core_art(x : Int, y : Int, pulse : Float) -> Bool {
  match tex_scroll_core.val {
    Some(texture) => {
      draw_texture_fit(
        texture,
        Float::from_int(x),
        Float::from_int(y),
        96.0 + pulse * 1.4,
        120.0 + pulse * 1.6,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Draws the generated breach portal art.
fn draw_breach_art(x : Int, y : Int, ratio : Float) -> Bool {
  match tex_breach.val {
    Some(texture) => {
      let size : Float = 76.0 + ratio * 74.0
      draw_texture_fit(
        texture,
        Float::from_int(x),
        Float::from_int(y),
        size,
        size,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Draws the generated flame art.
fn draw_flame_art(x : Int, y : Int, heat : Float) -> Bool {
  match tex_flame.val {
    Some(texture) => {
      draw_texture_fit(
        texture,
        Float::from_int(x),
        Float::from_int(y),
        34.0 + heat * 44.0,
        50.0 + heat * 58.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Draws the generated raider art.
fn draw_raider_art(x : Int, y : Int, panicked : Bool) -> Bool {
  match tex_raider.val {
    Some(texture) => {
      @raylib.draw_ellipse(
        x,
        y + 12,
        22.0,
        8.0,
        @raylib.Color::new(2, 6, 8, 104),
      )
      draw_texture_fit(
        texture,
        Float::from_int(x),
        Float::from_int(y - 4),
        52.0,
        58.0,
        if panicked {
          @raylib.Color::new(255, 212, 216, 255)
        } else {
          @raylib.white
        },
      )
      true
    }
    None => false
  }
}

///|
/// Draws the generated keeper art.
fn draw_keeper_art(x : Int, y : Int, extinguisher_mode : Bool) -> Bool {
  match tex_keeper.val {
    Some(texture) => {
      @raylib.draw_ellipse(
        x,
        y + 15,
        26.0,
        9.0,
        @raylib.Color::new(2, 8, 10, 108),
      )
      draw_texture_fit(
        texture,
        Float::from_int(x),
        Float::from_int(y - 6),
        64.0,
        72.0,
        if extinguisher_mode {
          @raylib.Color::new(206, 255, 238, 255)
        } else {
          @raylib.white
        },
      )
      true
    }
    None => false
  }
}
