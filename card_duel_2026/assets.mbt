///|
/// Generated full-screen duel arena backdrop texture.
let tex_duel_backdrop : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated player duelist portrait texture.
let tex_player_portrait : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated rival duelist portrait texture.
let tex_rival_portrait : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated card frame texture.
let tex_card_frame : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated Strike card icon texture.
let tex_icon_strike : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated Guard card icon texture.
let tex_icon_guard : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated Burst card icon texture.
let tex_icon_burst : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated Sap card icon texture.
let tex_icon_sap : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated Repair card icon texture.
let tex_icon_repair : Ref[@raylib.Texture?] = { val: None, }

///|
/// Loads a bilinear-filtered Card Duel 2026 texture.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture("card_duel_2026/resources/" + file_name)
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads all generated Card Duel 2026 art assets.
fn load_assets() -> Unit {
  tex_duel_backdrop.val = Some(load_art_texture("duel_backdrop.png"))
  tex_player_portrait.val = Some(load_art_texture("player_portrait.png"))
  tex_rival_portrait.val = Some(load_art_texture("rival_portrait.png"))
  tex_card_frame.val = Some(load_art_texture("card_frame.png"))
  tex_icon_strike.val = Some(load_art_texture("icon_strike.png"))
  tex_icon_guard.val = Some(load_art_texture("icon_guard.png"))
  tex_icon_burst.val = Some(load_art_texture("icon_burst.png"))
  tex_icon_sap.val = Some(load_art_texture("icon_sap.png"))
  tex_icon_repair.val = Some(load_art_texture("icon_repair.png"))
}

///|
/// Unloads all generated Card Duel 2026 art assets.
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

  unload(tex_duel_backdrop)
  unload(tex_player_portrait)
  unload(tex_rival_portrait)
  unload(tex_card_frame)
  unload(tex_icon_strike)
  unload(tex_icon_guard)
  unload(tex_icon_burst)
  unload(tex_icon_sap)
  unload(tex_icon_repair)
}

///|
/// Draws a texture into a top-left anchored rectangle.
fn draw_art_top_left(
  texture : @raylib.Texture,
  x : Float,
  y : Float,
  width : Float,
  height : Float,
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
    @raylib.Rectangle::new(x, y, width, height),
    @raylib.Vector2::new(0.0, 0.0),
    0.0,
    tint,
  )
}

///|
/// Draws a texture centered at the requested point.
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
/// Draws the generated full-screen duel backdrop if it is loaded.
fn draw_backdrop_art() -> Bool {
  match tex_duel_backdrop.val {
    Some(texture) => {
      draw_art_top_left(
        texture,
        0.0,
        0.0,
        Float::from_int(sw),
        Float::from_int(sh),
        @raylib.white,
      )
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(6, 8, 14, 58))
      true
    }
    None => false
  }
}

///|
/// Draws the generated duelist portrait if it is loaded.
fn draw_portrait_art(
  is_player : Bool,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  let texture_ref = if is_player {
    tex_player_portrait.val
  } else {
    tex_rival_portrait.val
  }
  match texture_ref {
    Some(texture) => {
      draw_art_top_left(
        texture,
        Float::from_int(x),
        Float::from_int(y),
        Float::from_int(w),
        Float::from_int(h),
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Returns the generated card icon texture for the given card index.
fn card_icon(card : Int) -> @raylib.Texture? {
  match card {
    0 => tex_icon_strike.val
    1 => tex_icon_guard.val
    2 => tex_icon_burst.val
    3 => tex_icon_sap.val
    _ => tex_icon_repair.val
  }
}

///|
/// Draws the generated card frame if it is loaded.
fn draw_card_frame_art(x : Int, y : Int, w : Int, h : Int) -> Bool {
  match tex_card_frame.val {
    Some(texture) => {
      draw_art_top_left(
        texture,
        Float::from_int(x),
        Float::from_int(y),
        Float::from_int(w),
        Float::from_int(h),
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Draws the generated icon for the given card index if it is loaded.
fn draw_card_icon_art(card : Int, cx : Int, cy : Int, size : Int) -> Bool {
  match card_icon(card) {
    Some(texture) => {
      draw_art_centered(
        texture,
        Float::from_int(cx),
        Float::from_int(cy),
        Float::from_int(size),
        Float::from_int(size),
        0.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}
