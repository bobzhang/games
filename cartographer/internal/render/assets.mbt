///|
let tex_map_board_backdrop : Ref[@raylib.Texture?] = { val: None }

///|
let tex_title_atlas : Ref[@raylib.Texture?] = { val: None }

///|
let tex_compass_rose : Ref[@raylib.Texture?] = { val: None }

///|
let tex_feature_mountain : Ref[@raylib.Texture?] = { val: None }

///|
let tex_feature_river : Ref[@raylib.Texture?] = { val: None }

///|
let tex_feature_forest : Ref[@raylib.Texture?] = { val: None }

///|
let tex_feature_town : Ref[@raylib.Texture?] = { val: None }

///|
let tex_feature_lake : Ref[@raylib.Texture?] = { val: None }

///|
let tex_feature_desert : Ref[@raylib.Texture?] = { val: None }

///|
let tex_feature_road : Ref[@raylib.Texture?] = { val: None }

///|
let tex_star_icon : Ref[@raylib.Texture?] = { val: None }

///|
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture("cartographer/resources/" + file_name)
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
pub fn load_assets() -> Unit {
  tex_map_board_backdrop.val = Some(load_art_texture("map_board_backdrop.png"))
  tex_title_atlas.val = Some(load_art_texture("title_atlas.png"))
  tex_compass_rose.val = Some(load_art_texture("compass_rose.png"))
  tex_feature_mountain.val = Some(load_art_texture("feature_mountain.png"))
  tex_feature_river.val = Some(load_art_texture("feature_river.png"))
  tex_feature_forest.val = Some(load_art_texture("feature_forest.png"))
  tex_feature_town.val = Some(load_art_texture("feature_town.png"))
  tex_feature_lake.val = Some(load_art_texture("feature_lake.png"))
  tex_feature_desert.val = Some(load_art_texture("feature_desert.png"))
  tex_feature_road.val = Some(load_art_texture("feature_road.png"))
  tex_star_icon.val = Some(load_art_texture("star_icon.png"))
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

  unload(tex_map_board_backdrop)
  unload(tex_title_atlas)
  unload(tex_compass_rose)
  unload(tex_feature_mountain)
  unload(tex_feature_river)
  unload(tex_feature_forest)
  unload(tex_feature_town)
  unload(tex_feature_lake)
  unload(tex_feature_desert)
  unload(tex_feature_road)
  unload(tex_star_icon)
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
fn draw_map_board_art(x : Int, y : Int, width : Int, height : Int) -> Bool {
  match tex_map_board_backdrop.val {
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
fn draw_title_atlas_art(cx : Int, cy : Int) -> Bool {
  match tex_title_atlas.val {
    Some(texture) => {
      @raylib.draw_ellipse(
        cx,
        cy + 78,
        190.0,
        22.0,
        @raylib.Color::new(20, 12, 6, 80),
      )
      draw_art_centered(
        texture,
        Float::from_int(cx),
        Float::from_int(cy),
        430.0,
        245.0,
        0.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
fn feature_art(feature : @types.FeatureKind) -> @raylib.Texture? {
  match feature {
    Mountain => tex_feature_mountain.val
    River => tex_feature_river.val
    Forest => tex_feature_forest.val
    Town => tex_feature_town.val
    Lake => tex_feature_lake.val
    Desert => tex_feature_desert.val
    Road => tex_feature_road.val
  }
}

///|
fn draw_feature_art(
  cx : Int,
  cy : Int,
  feature : @types.FeatureKind,
  size : Int,
  alpha : Int,
) -> Bool {
  match feature_art(feature) {
    Some(texture) => {
      draw_art_centered(
        texture,
        Float::from_int(cx),
        Float::from_int(cy),
        Float::from_int(size),
        Float::from_int(size),
        0.0,
        @raylib.Color::new(255, 255, 255, alpha),
      )
      true
    }
    None => false
  }
}

///|
fn draw_compass_rose_art(cx : Int, cy : Int, size : Int) -> Bool {
  match tex_compass_rose.val {
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

///|
fn draw_star_art(
  cx : Int,
  cy : Int,
  size : Int,
  color : @raylib.Color,
) -> Bool {
  match tex_star_icon.val {
    Some(texture) => {
      draw_art_centered(
        texture,
        Float::from_int(cx),
        Float::from_int(cy),
        Float::from_int(size),
        Float::from_int(size),
        0.0,
        color,
      )
      true
    }
    None => false
  }
}
