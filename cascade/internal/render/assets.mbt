///|
let tex_board_backdrop : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_domino_normal : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_domino_heavy : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_domino_splitter : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_domino_delay : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_title_chain : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_tier_chains : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_tier_splits : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_tier_timing : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_ui_panel : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_star_icon : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_starter_glow : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_target_glow : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_hover_glow : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_bad_socket_glow : Ref[@raylib.Texture?] = { val: None, }

///|
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture("cascade/resources/" + file_name)
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
pub fn load_assets() -> Unit {
  tex_board_backdrop.val = Some(load_art_texture("board_backdrop.png"))
  tex_domino_normal.val = Some(load_art_texture("domino_normal.png"))
  tex_domino_heavy.val = Some(load_art_texture("domino_heavy.png"))
  tex_domino_splitter.val = Some(load_art_texture("domino_splitter.png"))
  tex_domino_delay.val = Some(load_art_texture("domino_delay.png"))
  tex_title_chain.val = Some(load_art_texture("title_chain.png"))
  tex_tier_chains.val = Some(load_art_texture("tier_chains.png"))
  tex_tier_splits.val = Some(load_art_texture("tier_splits.png"))
  tex_tier_timing.val = Some(load_art_texture("tier_timing.png"))
  tex_ui_panel.val = Some(load_art_texture("ui_panel.png"))
  tex_star_icon.val = Some(load_art_texture("star_icon.png"))
  tex_starter_glow.val = Some(load_art_texture("starter_glow.png"))
  tex_target_glow.val = Some(load_art_texture("target_glow.png"))
  tex_hover_glow.val = Some(load_art_texture("hover_glow.png"))
  tex_bad_socket_glow.val = Some(load_art_texture("bad_socket_glow.png"))
}

///|
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

  unload(tex_board_backdrop)
  unload(tex_domino_normal)
  unload(tex_domino_heavy)
  unload(tex_domino_splitter)
  unload(tex_domino_delay)
  unload(tex_title_chain)
  unload(tex_tier_chains)
  unload(tex_tier_splits)
  unload(tex_tier_timing)
  unload(tex_ui_panel)
  unload(tex_star_icon)
  unload(tex_starter_glow)
  unload(tex_target_glow)
  unload(tex_hover_glow)
  unload(tex_bad_socket_glow)
}

///|
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
fn draw_board_backdrop_art() -> Bool {
  match tex_board_backdrop.val {
    Some(texture) => {
      draw_art_top_left(texture, 128.0, 24.0, 864.0, 624.0, @raylib.white)
      true
    }
    None => false
  }
}

///|
fn domino_art(kind : @types.DominoKind) -> @raylib.Texture? {
  match kind {
    Normal => tex_domino_normal.val
    Heavy => tex_domino_heavy.val
    Splitter => tex_domino_splitter.val
    Delay => tex_domino_delay.val
  }
}

///|
fn draw_domino_art(
  kind : @types.DominoKind,
  cx : Float,
  cy : Float,
  rotation : Float,
  height_scale : Float,
  tint : @raylib.Color,
) -> Bool {
  match domino_art(kind) {
    Some(texture) => {
      draw_art_centered(
        texture,
        cx,
        cy,
        18.0,
        46.0 * height_scale,
        rotation,
        tint,
      )
      true
    }
    None => false
  }
}

///|
fn draw_title_chain_art() -> Bool {
  match tex_title_chain.val {
    Some(texture) => {
      draw_art_centered(texture, 640.0, 380.0, 780.0, 360.0, 0.0, @raylib.white)
      true
    }
    None => false
  }
}

///|
fn tier_card_texture(tier : @types.Tier) -> @raylib.Texture? {
  match tier {
    Chains => tex_tier_chains.val
    Splits => tex_tier_splits.val
    Timing => tex_tier_timing.val
  }
}

///|
fn draw_tier_card_art(
  tier : @types.Tier,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Bool {
  match tier_card_texture(tier) {
    Some(texture) => {
      draw_art_top_left(
        texture,
        Float::from_int(x),
        Float::from_int(y),
        Float::from_int(width),
        Float::from_int(height),
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
fn draw_ui_panel_art(x : Int, y : Int, width : Int, height : Int) -> Bool {
  match tex_ui_panel.val {
    Some(texture) => {
      draw_art_top_left(
        texture,
        Float::from_int(x),
        Float::from_int(y),
        Float::from_int(width),
        Float::from_int(height),
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
fn draw_glow_centered(
  texture_ref : Ref[@raylib.Texture?],
  cx : Float,
  cy : Float,
  size : Float,
  tint : @raylib.Color,
) -> Bool {
  match texture_ref.val {
    Some(texture) => {
      draw_art_centered(texture, cx, cy, size, size, 0.0, tint)
      true
    }
    None => false
  }
}

///|
fn draw_starter_glow_art(cx : Float, cy : Float, size : Float) -> Bool {
  draw_glow_centered(tex_starter_glow, cx, cy, size, @raylib.white)
}

///|
fn draw_target_glow_art(cx : Float, cy : Float, size : Float) -> Bool {
  draw_glow_centered(tex_target_glow, cx, cy, size, @raylib.white)
}

///|
fn draw_hover_glow_art(cx : Float, cy : Float, size : Float) -> Bool {
  draw_glow_centered(tex_hover_glow, cx, cy, size, @raylib.white)
}

///|
fn draw_bad_socket_glow_art(cx : Float, cy : Float, size : Float) -> Bool {
  draw_glow_centered(tex_bad_socket_glow, cx, cy, size, @raylib.white)
}

///|
fn draw_star_icon_art(
  cx : Float,
  cy : Float,
  size : Float,
  color : @raylib.Color,
) -> Bool {
  match tex_star_icon.val {
    Some(texture) => {
      draw_art_centered(texture, cx, cy, size, size, 0.0, color)
      true
    }
    None => false
  }
}
