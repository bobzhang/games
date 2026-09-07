///|
/// Generated candy fantasy backdrop texture.
let tex_candy_backdrop : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated glossy 8x8 board panel texture.
let tex_board_panel : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated red candy texture.
let tex_candy_red : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated orange candy texture.
let tex_candy_orange : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated yellow candy texture.
let tex_candy_yellow : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated green candy texture.
let tex_candy_green : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated blue candy texture.
let tex_candy_blue : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated purple candy texture.
let tex_candy_purple : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated jelly tile overlay texture.
let tex_jelly_overlay : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated row-clear special overlay texture.
let tex_special_row : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated column-clear special overlay texture.
let tex_special_col : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated bomb special overlay texture.
let tex_special_bomb : Ref[@raylib.Texture?] = { val: None, }

///|
/// Loads one bilinear-filtered Candy Crush 2026 texture.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture("candy_crush_2026/resources/" + file_name)
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads generated Candy Crush 2026 render assets.
pub fn load_assets() -> Unit {
  tex_candy_backdrop.val = Some(load_art_texture("candy_backdrop.png"))
  tex_board_panel.val = Some(load_art_texture("board_panel.png"))
  tex_candy_red.val = Some(load_art_texture("candy_red.png"))
  tex_candy_orange.val = Some(load_art_texture("candy_orange.png"))
  tex_candy_yellow.val = Some(load_art_texture("candy_yellow.png"))
  tex_candy_green.val = Some(load_art_texture("candy_green.png"))
  tex_candy_blue.val = Some(load_art_texture("candy_blue.png"))
  tex_candy_purple.val = Some(load_art_texture("candy_purple.png"))
  tex_jelly_overlay.val = Some(load_art_texture("jelly_overlay.png"))
  tex_special_row.val = Some(load_art_texture("special_row.png"))
  tex_special_col.val = Some(load_art_texture("special_col.png"))
  tex_special_bomb.val = Some(load_art_texture("special_bomb.png"))
}

///|
/// Unloads generated Candy Crush 2026 render assets.
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

  unload(tex_candy_backdrop)
  unload(tex_board_panel)
  unload(tex_candy_red)
  unload(tex_candy_orange)
  unload(tex_candy_yellow)
  unload(tex_candy_green)
  unload(tex_candy_blue)
  unload(tex_candy_purple)
  unload(tex_jelly_overlay)
  unload(tex_special_row)
  unload(tex_special_col)
  unload(tex_special_bomb)
}

///|
/// Draws a texture centered at the requested destination.
fn draw_art_centered(
  texture : @raylib.Texture,
  center_x : Float,
  center_y : Float,
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
    @raylib.Rectangle::new(center_x, center_y, width, height),
    @raylib.Vector2::new(width * 0.5, height * 0.5),
    rotation,
    tint,
  )
}

///|
/// Draws a texture from a top-left destination rectangle.
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
/// Draws the generated full-screen candy backdrop if loaded.
fn draw_background_art() -> Bool {
  match tex_candy_backdrop.val {
    Some(texture) => {
      draw_art_top_left(
        texture,
        0.0,
        0.0,
        Float::from_int(@types.screen_w),
        Float::from_int(@types.screen_h),
        @raylib.white,
      )
      @raylib.draw_rectangle(
        0,
        0,
        @types.screen_w,
        @types.screen_h,
        @raylib.Color::new(18, 8, 38, 46),
      )
      true
    }
    None => false
  }
}

///|
/// Draws the generated board panel if loaded.
fn draw_board_panel_art() -> Bool {
  match tex_board_panel.val {
    Some(texture) => {
      let bx = @types.board_x() - @types.board_pad
      let by = @types.board_y() - @types.board_pad
      let size = @types.board_pixel_w() + @types.board_pad * 2
      draw_art_top_left(
        texture,
        Float::from_int(bx),
        Float::from_int(by),
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
/// Returns generated candy art for a kind id.
fn candy_art(kind : Int) -> @raylib.Texture? {
  if kind == 0 {
    tex_candy_red.val
  } else if kind == 1 {
    tex_candy_orange.val
  } else if kind == 2 {
    tex_candy_yellow.val
  } else if kind == 3 {
    tex_candy_green.val
  } else if kind == 4 {
    tex_candy_blue.val
  } else {
    tex_candy_purple.val
  }
}

///|
/// Draws a generated candy sprite if loaded.
fn draw_candy_art(cx : Int, cy : Int, kind : Int) -> Bool {
  match candy_art(kind) {
    Some(texture) => {
      let size = Float::from_int(@types.cell_px) * 0.82
      draw_art_centered(
        texture,
        Float::from_int(cx),
        Float::from_int(cy),
        size,
        size,
        0.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Draws the generated jelly overlay if loaded.
fn draw_jelly_art(left : Int, top : Int) -> Bool {
  match tex_jelly_overlay.val {
    Some(texture) => {
      draw_art_centered(
        texture,
        Float::from_int(left + @types.cell_px / 2),
        Float::from_int(top + @types.cell_px / 2),
        Float::from_int(@types.cell_px - 8),
        Float::from_int(@types.cell_px - 8),
        0.0,
        @raylib.Color::new(255, 255, 255, 170),
      )
      true
    }
    None => false
  }
}

///|
/// Returns the generated overlay texture for a special candy.
fn special_art(sp : @types.Special) -> @raylib.Texture? {
  match sp {
    Row => tex_special_row.val
    Col => tex_special_col.val
    Bomb => tex_special_bomb.val
    None => None
  }
}

///|
/// Draws a generated special-candy overlay if loaded.
fn draw_special_art(cx : Int, cy : Int, sp : @types.Special) -> Bool {
  match special_art(sp) {
    Some(texture) => {
      draw_art_centered(
        texture,
        Float::from_int(cx),
        Float::from_int(cy),
        Float::from_int(@types.cell_px) * 0.78,
        Float::from_int(@types.cell_px) * 0.78,
        0.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}
