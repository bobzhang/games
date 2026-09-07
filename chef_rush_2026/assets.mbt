///|
/// Generated warm kitchen backdrop texture.
let tex_kitchen_backdrop : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated chef catcher sprite.
let tex_chef_sprite : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated tomato ingredient sprite.
let tex_ingredient_tomato : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated beef ingredient sprite.
let tex_ingredient_beef : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated fish ingredient sprite.
let tex_ingredient_fish : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated lettuce ingredient sprite.
let tex_ingredient_lettuce : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated trash hazard sprite.
let tex_trash_sprite : Ref[@raylib.Texture?] = { val: None, }

///|
/// Loads one bilinear-filtered Chef Rush texture.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture("chef_rush_2026/resources/" + file_name)
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads generated Chef Rush render assets.
fn load_assets() -> Unit {
  tex_kitchen_backdrop.val = Some(load_art_texture("kitchen_backdrop.png"))
  tex_chef_sprite.val = Some(load_art_texture("chef_sprite.png"))
  tex_ingredient_tomato.val = Some(load_art_texture("ingredient_tomato.png"))
  tex_ingredient_beef.val = Some(load_art_texture("ingredient_beef.png"))
  tex_ingredient_fish.val = Some(load_art_texture("ingredient_fish.png"))
  tex_ingredient_lettuce.val = Some(load_art_texture("ingredient_lettuce.png"))
  tex_trash_sprite.val = Some(load_art_texture("trash_sprite.png"))
}

///|
/// Unloads generated Chef Rush render assets.
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

  unload(tex_kitchen_backdrop)
  unload(tex_chef_sprite)
  unload(tex_ingredient_tomato)
  unload(tex_ingredient_beef)
  unload(tex_ingredient_fish)
  unload(tex_ingredient_lettuce)
  unload(tex_trash_sprite)
}

///|
/// Draws a texture into a centered destination rectangle.
fn draw_art_rect(
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
/// Draws a generated sprite scaled to fit within the requested box.
fn draw_art_fit(
  texture : @raylib.Texture,
  center_x : Float,
  center_y : Float,
  max_width : Float,
  max_height : Float,
  rotation : Float,
  tint : @raylib.Color,
) -> Unit {
  let source_w = Float::from_int(texture.width())
  let source_h = Float::from_int(texture.height())
  let source_ratio = source_w / source_h
  let box_ratio = max_width / max_height
  let (width, height) = if source_ratio > box_ratio {
    (max_width, max_width / source_ratio)
  } else {
    (max_height * source_ratio, max_height)
  }
  draw_art_rect(texture, center_x, center_y, width, height, rotation, tint)
}

///|
/// Draws the generated kitchen backdrop if loaded.
fn draw_kitchen_backdrop_art() -> Bool {
  match tex_kitchen_backdrop.val {
    Some(texture) => {
      @raylib.draw_texture_pro(
        texture,
        @raylib.Rectangle::new(
          0.0,
          0.0,
          Float::from_int(texture.width()),
          Float::from_int(texture.height()),
        ),
        @raylib.Rectangle::new(
          0.0,
          0.0,
          Float::from_int(sw),
          Float::from_int(sh),
        ),
        @raylib.Vector2::new(0.0, 0.0),
        0.0,
        @raylib.white,
      )
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(20, 12, 8, 24))
      true
    }
    None => false
  }
}

///|
/// Returns generated ingredient art for a gameplay kind index.
fn ingredient_art(kind : Int) -> @raylib.Texture? {
  if kind == 0 {
    tex_ingredient_tomato.val
  } else if kind == 1 {
    tex_ingredient_beef.val
  } else if kind == 2 {
    tex_ingredient_fish.val
  } else if kind == 3 {
    tex_ingredient_lettuce.val
  } else {
    tex_trash_sprite.val
  }
}

///|
/// Draws a generated falling ingredient or trash hazard sprite if loaded.
fn draw_drop_art(kind : Int, x : Float, y : Float) -> Bool {
  match ingredient_art(kind) {
    Some(texture) => {
      @raylib.draw_ellipse(
        x.to_int(),
        (y + 17.0).to_int(),
        17.0,
        6.0,
        @raylib.Color::new(0, 0, 0, 68),
      )
      let max_w : Float = if kind == 2 { 52.0 } else { 43.0 }
      let max_h : Float = if kind == 2 { 34.0 } else { 43.0 }
      draw_art_fit(texture, x, y, max_w, max_h, 0.0, @raylib.white)
      true
    }
    None => false
  }
}

///|
/// Draws the generated chef catcher sprite if loaded.
fn draw_chef_art(x : Float, y : Float) -> Bool {
  match tex_chef_sprite.val {
    Some(texture) => {
      @raylib.draw_ellipse(
        x.to_int(),
        (y + 50.0).to_int(),
        26.0,
        8.0,
        @raylib.Color::new(0, 0, 0, 76),
      )
      draw_art_fit(texture, x, y + 9.0, 72.0, 112.0, 0.0, @raylib.white)
      true
    }
    None => false
  }
}
