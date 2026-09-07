///|
let tex_tablet_surface : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_title_cartouche : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_tier_fragments : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_tier_scrolls : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_tier_monuments : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_decoder_panel : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_glyph_backplate : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_star_icon : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_selection_glow : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_hint_glow : Ref[@raylib.Texture?] = { val: None, }

///|
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture("cartouche/resources/" + file_name)
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
pub fn load_assets() -> Unit {
  tex_tablet_surface.val = Some(load_art_texture("tablet_surface.png"))
  tex_title_cartouche.val = Some(load_art_texture("title_cartouche.png"))
  tex_tier_fragments.val = Some(load_art_texture("tier_fragments.png"))
  tex_tier_scrolls.val = Some(load_art_texture("tier_scrolls.png"))
  tex_tier_monuments.val = Some(load_art_texture("tier_monuments.png"))
  tex_decoder_panel.val = Some(load_art_texture("decoder_panel.png"))
  tex_glyph_backplate.val = Some(load_art_texture("glyph_backplate.png"))
  tex_star_icon.val = Some(load_art_texture("star_icon.png"))
  tex_selection_glow.val = Some(load_art_texture("selection_glow.png"))
  tex_hint_glow.val = Some(load_art_texture("hint_glow.png"))
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

  unload(tex_tablet_surface)
  unload(tex_title_cartouche)
  unload(tex_tier_fragments)
  unload(tex_tier_scrolls)
  unload(tex_tier_monuments)
  unload(tex_decoder_panel)
  unload(tex_glyph_backplate)
  unload(tex_star_icon)
  unload(tex_selection_glow)
  unload(tex_hint_glow)
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
fn draw_tablet_surface_art(x : Int, y : Int, width : Int, height : Int) -> Bool {
  match tex_tablet_surface.val {
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
fn draw_title_cartouche_art(
  cx : Int,
  cy : Int,
  width : Int,
  height : Int,
) -> Bool {
  match tex_title_cartouche.val {
    Some(texture) => {
      draw_art_centered(
        texture,
        Float::from_int(cx),
        Float::from_int(cy),
        Float::from_int(width),
        Float::from_int(height),
        0.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
fn tier_texture(tier : @types.Tier) -> @raylib.Texture? {
  match tier {
    Fragments => tex_tier_fragments.val
    Scrolls => tex_tier_scrolls.val
    Monuments => tex_tier_monuments.val
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
  match tier_texture(tier) {
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
fn draw_decoder_panel_art(x : Int, y : Int, width : Int, height : Int) -> Bool {
  match tex_decoder_panel.val {
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
fn draw_glyph_backplate_art(
  x : Int,
  y : Int,
  size : Int,
  tint : @raylib.Color,
) -> Bool {
  match tex_glyph_backplate.val {
    Some(texture) => {
      draw_art_top_left(
        texture,
        Float::from_int(x),
        Float::from_int(y),
        Float::from_int(size),
        Float::from_int(size),
        tint,
      )
      true
    }
    None => false
  }
}

///|
fn draw_selection_glow_art(x : Int, y : Int, size : Int) -> Bool {
  match tex_selection_glow.val {
    Some(texture) => {
      draw_art_top_left(
        texture,
        Float::from_int(x),
        Float::from_int(y),
        Float::from_int(size),
        Float::from_int(size),
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
fn draw_hint_glow_art(x : Int, y : Int, size : Int) -> Bool {
  match tex_hint_glow.val {
    Some(texture) => {
      draw_art_top_left(
        texture,
        Float::from_int(x),
        Float::from_int(y),
        Float::from_int(size),
        Float::from_int(size),
        @raylib.white,
      )
      true
    }
    None => false
  }
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
