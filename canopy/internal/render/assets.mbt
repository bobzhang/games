///|
let tex_forest_board_backdrop : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_title_tree : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_trunk_sprite : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_branch_sprite : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_leaf_cluster : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_shadow_overlay : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_ground_water_strip : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_target_marker : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_tier_seedling : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_tier_grove : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_tier_forest : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_star_icon : Ref[@raylib.Texture?] = { val: None, }

///|
let tex_prune_shears : Ref[@raylib.Texture?] = { val: None, }

///|
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture("canopy/resources/" + file_name)
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
pub fn load_assets() -> Unit {
  tex_forest_board_backdrop.val = Some(
    load_art_texture("forest_board_backdrop.png"),
  )
  tex_title_tree.val = Some(load_art_texture("title_tree.png"))
  tex_trunk_sprite.val = Some(load_art_texture("trunk_sprite.png"))
  tex_branch_sprite.val = Some(load_art_texture("branch_sprite.png"))
  tex_leaf_cluster.val = Some(load_art_texture("leaf_cluster.png"))
  tex_shadow_overlay.val = Some(load_art_texture("shadow_overlay.png"))
  tex_ground_water_strip.val = Some(load_art_texture("ground_water_strip.png"))
  tex_target_marker.val = Some(load_art_texture("target_marker.png"))
  tex_tier_seedling.val = Some(load_art_texture("tier_seedling.png"))
  tex_tier_grove.val = Some(load_art_texture("tier_grove.png"))
  tex_tier_forest.val = Some(load_art_texture("tier_forest.png"))
  tex_star_icon.val = Some(load_art_texture("star_icon.png"))
  tex_prune_shears.val = Some(load_art_texture("prune_shears.png"))
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

  unload(tex_forest_board_backdrop)
  unload(tex_title_tree)
  unload(tex_trunk_sprite)
  unload(tex_branch_sprite)
  unload(tex_leaf_cluster)
  unload(tex_shadow_overlay)
  unload(tex_ground_water_strip)
  unload(tex_target_marker)
  unload(tex_tier_seedling)
  unload(tex_tier_grove)
  unload(tex_tier_forest)
  unload(tex_star_icon)
  unload(tex_prune_shears)
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
fn draw_forest_board_art(_game : @types.Game) -> Bool {
  match tex_forest_board_backdrop.val {
    Some(texture) => {
      let gx = @types.grid_offset_x - 10
      let gy = @types.grid_offset_y - 10
      let gw = @types.grid_cols * @types.cell_size + 20
      let gh = @types.grid_rows * @types.cell_size + 20
      draw_art_top_left(
        texture,
        Float::from_int(gx),
        Float::from_int(gy),
        Float::from_int(gw),
        Float::from_int(gh),
        @raylib.white,
      )
      @raylib.draw_rectangle(gx, gy, gw, gh, @raylib.Color::new(20, 42, 34, 30))
      true
    }
    None => false
  }
}

///|
fn draw_title_tree_art(cx : Int, base_y : Int, time : Float) -> Bool {
  match tex_title_tree.val {
    Some(texture) => {
      let pulse = sinf(time * 1.4) * 5.0
      @raylib.draw_ellipse(
        cx,
        base_y + 6,
        120.0,
        18.0,
        @raylib.Color::new(20, 30, 20, 80),
      )
      draw_art_centered(
        texture,
        Float::from_int(cx),
        Float::from_int(base_y - 170) + pulse,
        265.0,
        340.0,
        sinf(time * 0.6) * 1.5,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
fn draw_trunk_art(x : Int, y : Int) -> Bool {
  match tex_trunk_sprite.val {
    Some(texture) => {
      let cs = Float::from_int(@types.cell_size)
      draw_art_centered(
        texture,
        Float::from_int(x) + cs * 0.5,
        Float::from_int(y) + cs * 0.5,
        cs * 1.02,
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
fn draw_branch_art(x : Int, y : Int, pulse : Float) -> Bool {
  match tex_branch_sprite.val {
    Some(texture) => {
      let cs = Float::from_int(@types.cell_size)
      draw_art_centered(
        texture,
        Float::from_int(x) + cs * 0.5,
        Float::from_int(y) + cs * 0.5 + pulse * 0.25,
        cs * 1.26,
        cs * 1.02,
        0.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
fn draw_leaf_art(x : Int, y : Int, pulse : Float) -> Bool {
  match tex_leaf_cluster.val {
    Some(texture) => {
      let cs = Float::from_int(@types.cell_size)
      draw_art_centered(
        texture,
        Float::from_int(x) + cs * 0.5,
        Float::from_int(y) + cs * 0.5 + pulse,
        cs * 1.16,
        cs * 1.16,
        sinf(pulse * 0.4) * 1.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
fn draw_shadow_art(x : Int, y : Int) -> Bool {
  match tex_shadow_overlay.val {
    Some(texture) => {
      draw_art_centered(
        texture,
        Float::from_int(x + @types.cell_size / 2),
        Float::from_int(y + @types.cell_size / 2),
        Float::from_int(@types.cell_size),
        Float::from_int(@types.cell_size),
        0.0,
        @raylib.Color::new(255, 255, 255, 185),
      )
      true
    }
    None => false
  }
}

///|
fn draw_ground_art(x : Int, y : Int, width : Int, height : Int) -> Bool {
  match tex_ground_water_strip.val {
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
fn draw_target_marker_art(cx : Int, cy : Int, met : Bool) -> Bool {
  match tex_target_marker.val {
    Some(texture) => {
      let tint = if met {
        @raylib.Color::new(180, 255, 180, 255)
      } else {
        @raylib.white
      }
      draw_art_centered(
        texture,
        Float::from_int(cx),
        Float::from_int(cy),
        34.0,
        34.0,
        0.0,
        tint,
      )
      true
    }
    None => false
  }
}

///|
fn tier_icon_art(index : Int) -> @raylib.Texture? {
  if index == 0 {
    tex_tier_seedling.val
  } else if index == 1 {
    tex_tier_grove.val
  } else {
    tex_tier_forest.val
  }
}

///|
fn draw_tier_icon_art(index : Int, cx : Int, cy : Int, size : Int) -> Bool {
  match tier_icon_art(index) {
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
fn draw_star_art(cx : Int, cy : Int, filled : Bool, size : Int) -> Bool {
  match tex_star_icon.val {
    Some(texture) => {
      let tint = if filled {
        @raylib.white
      } else {
        @raylib.Color::new(120, 125, 120, 150)
      }
      draw_art_centered(
        texture,
        Float::from_int(cx),
        Float::from_int(cy),
        Float::from_int(size),
        Float::from_int(size),
        0.0,
        tint,
      )
      true
    }
    None => false
  }
}

///|
fn draw_prune_shears_art(cx : Int, cy : Int) -> Bool {
  match tex_prune_shears.val {
    Some(texture) => {
      draw_art_centered(
        texture,
        Float::from_int(cx),
        Float::from_int(cy),
        30.0,
        30.0,
        -12.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}
