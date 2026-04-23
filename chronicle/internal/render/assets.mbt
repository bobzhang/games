///|
/// Generated noir investigation desk backdrop for the title screen.
let tex_title_backdrop : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated parchment texture for event cards.
let tex_card_texture : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated case-board texture for the clue panel.
let tex_clue_panel : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated recessed texture for empty timeline slots.
let tex_timeline_slot : Ref[@raylib.Texture?] = { val: None }

///|
/// Loads one bilinear-filtered Chronicle texture.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture("chronicle/resources/" + file_name)
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads generated Chronicle render assets.
pub fn load_assets() -> Unit {
  tex_title_backdrop.val = Some(load_art_texture("title_backdrop.png"))
  tex_card_texture.val = Some(load_art_texture("card_texture.png"))
  tex_clue_panel.val = Some(load_art_texture("clue_panel.png"))
  tex_timeline_slot.val = Some(load_art_texture("timeline_slot.png"))
}

///|
/// Unloads generated Chronicle render assets.
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

  unload(tex_title_backdrop)
  unload(tex_card_texture)
  unload(tex_clue_panel)
  unload(tex_timeline_slot)
}

///|
/// Draws a texture into a destination rectangle.
fn draw_art_rect(
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
/// Draws the generated title backdrop if loaded.
fn draw_title_backdrop_art() -> Bool {
  match tex_title_backdrop.val {
    Some(texture) => {
      draw_art_rect(
        texture,
        0.0,
        0.0,
        Float::from_int(@types.screen_width),
        Float::from_int(@types.screen_height),
        @raylib.white,
      )
      @raylib.draw_rectangle(
        0,
        0,
        @types.screen_width,
        @types.screen_height,
        @raylib.Color::new(8, 6, 5, 36),
      )
      true
    }
    None => false
  }
}

///|
/// Draws the generated event-card texture if loaded.
fn draw_card_art(
  x : Float,
  y : Float,
  width : Float,
  height : Float,
  tint : @raylib.Color,
) -> Bool {
  match tex_card_texture.val {
    Some(texture) => {
      draw_art_rect(texture, x, y, width, height, tint)
      true
    }
    None => false
  }
}

///|
/// Draws the generated clue-panel texture if loaded.
fn draw_clue_panel_art(x : Float, y : Float, width : Float, height : Float) -> Bool {
  match tex_clue_panel.val {
    Some(texture) => {
      draw_art_rect(texture, x, y, width, height, @raylib.white)
      true
    }
    None => false
  }
}

///|
/// Draws the generated timeline slot texture if loaded.
fn draw_timeline_slot_art(
  x : Float,
  y : Float,
  width : Float,
  height : Float,
) -> Bool {
  match tex_timeline_slot.val {
    Some(texture) => {
      draw_art_rect(texture, x, y, width, height, @raylib.white)
      true
    }
    None => false
  }
}
