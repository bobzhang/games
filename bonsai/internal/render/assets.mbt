///|
let tex_board_backdrop : Ref[@raylib.Texture?] = { val: None }

///|
let tex_trunk_sprite : Ref[@raylib.Texture?] = { val: None }

///|
let tex_branch_sprite : Ref[@raylib.Texture?] = { val: None }

///|
let tex_leaf_pine : Ref[@raylib.Texture?] = { val: None }

///|
let tex_leaf_maple : Ref[@raylib.Texture?] = { val: None }

///|
let tex_leaf_cherry : Ref[@raylib.Texture?] = { val: None }

///|
let tex_pruned_stump : Ref[@raylib.Texture?] = { val: None }

///|
let tex_title_bonsai : Ref[@raylib.Texture?] = { val: None }

///|
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture("bonsai/resources/" + file_name)
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
pub fn load_assets() -> Unit {
  tex_board_backdrop.val = Some(load_art_texture("board_backdrop.png"))
  tex_trunk_sprite.val = Some(load_art_texture("trunk_sprite.png"))
  tex_branch_sprite.val = Some(load_art_texture("branch_sprite.png"))
  tex_leaf_pine.val = Some(load_art_texture("leaf_pine.png"))
  tex_leaf_maple.val = Some(load_art_texture("leaf_maple.png"))
  tex_leaf_cherry.val = Some(load_art_texture("leaf_cherry.png"))
  tex_pruned_stump.val = Some(load_art_texture("pruned_stump.png"))
  tex_title_bonsai.val = Some(load_art_texture("title_bonsai.png"))
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
  unload(tex_trunk_sprite)
  unload(tex_branch_sprite)
  unload(tex_leaf_pine)
  unload(tex_leaf_maple)
  unload(tex_leaf_cherry)
  unload(tex_pruned_stump)
  unload(tex_title_bonsai)
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
fn branch_rotation(dir : @types.GrowthDir) -> Float {
  match dir {
    Up => -55.0
    UpLeft => -95.0
    UpRight => 0.0
    Left => 180.0
    Right => 35.0
  }
}

///|
fn leaf_art(species : @types.Species) -> @raylib.Texture? {
  match species {
    Pine => tex_leaf_pine.val
    Maple => tex_leaf_maple.val
    Cherry => tex_leaf_cherry.val
  }
}

///|
fn draw_board_art() -> Bool {
  match tex_board_backdrop.val {
    Some(texture) => {
      let cs = @types.cell_render_size
      draw_art_top_left(
        texture,
        Float::from_int(@types.grid_offset_x),
        Float::from_int(@types.grid_offset_y),
        Float::from_int(@types.grid_width * cs),
        Float::from_int(@types.grid_height * cs),
        @raylib.white,
      )
      @raylib.draw_rectangle(
        @types.grid_offset_x,
        @types.grid_offset_y,
        @types.grid_width * cs,
        @types.grid_height * cs,
        @raylib.Color::new(24, 22, 18, 82),
      )
      true
    }
    None => false
  }
}

///|
fn draw_trunk_art(sx : Int, sy : Int) -> Bool {
  match tex_trunk_sprite.val {
    Some(texture) => {
      let cs = Float::from_int(@types.cell_render_size)
      draw_art_centered(
        texture,
        Float::from_int(sx) + cs * 0.5,
        Float::from_int(sy) + cs * 0.5,
        cs * 1.08,
        cs * 1.18,
        0.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
fn draw_branch_art(sx : Int, sy : Int, dir : @types.GrowthDir) -> Bool {
  match tex_branch_sprite.val {
    Some(texture) => {
      let cs = Float::from_int(@types.cell_render_size)
      draw_art_centered(
        texture,
        Float::from_int(sx) + cs * 0.5,
        Float::from_int(sy) + cs * 0.5,
        cs * 1.5,
        cs * 1.5,
        branch_rotation(dir),
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
fn draw_leaf_art(sx : Int, sy : Int, species : @types.Species) -> Bool {
  match leaf_art(species) {
    Some(texture) => {
      let cs = Float::from_int(@types.cell_render_size)
      draw_art_centered(
        texture,
        Float::from_int(sx) + cs * 0.5,
        Float::from_int(sy) + cs * 0.5,
        cs * 1.22,
        cs * 1.22,
        0.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
fn draw_pruned_art(sx : Int, sy : Int) -> Bool {
  match tex_pruned_stump.val {
    Some(texture) => {
      let cs = Float::from_int(@types.cell_render_size)
      draw_art_centered(
        texture,
        Float::from_int(sx) + cs * 0.5,
        Float::from_int(sy) + cs * 0.5,
        cs * 0.98,
        cs * 0.98,
        0.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
fn draw_title_bonsai_art(cx : Int, cy : Int, time : Float) -> Bool {
  match tex_title_bonsai.val {
    Some(texture) => {
      let pulse = @types.sinf(time * 1.1) * 5.0
      @raylib.draw_ellipse(
        cx,
        cy + 185,
        125.0,
        18.0,
        @raylib.Color::new(0, 0, 0, 78),
      )
      draw_art_centered(
        texture,
        Float::from_int(cx),
        Float::from_int(cy) + pulse,
        315.0,
        375.0,
        0.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}
