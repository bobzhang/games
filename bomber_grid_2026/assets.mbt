///|
/// Generated floor tile texture.
let tex_floor_tile : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated permanent wall block texture.
let tex_wall_block : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated breakable crate block texture.
let tex_crate_block : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated player sprite texture.
let tex_player_sprite : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated enemy sprite texture.
let tex_enemy_sprite : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated bomb sprite texture.
let tex_bomb_sprite : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated explosion fire sprite texture.
let tex_fire_sprite : Ref[@raylib.Texture?] = { val: None }

///|
/// Loads one bilinear-filtered bomber grid texture.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture("bomber_grid_2026/resources/" + file_name)
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads generated bomber grid render assets.
fn load_assets() -> Unit {
  tex_floor_tile.val = Some(load_art_texture("floor_tile.png"))
  tex_wall_block.val = Some(load_art_texture("wall_block.png"))
  tex_crate_block.val = Some(load_art_texture("crate_block.png"))
  tex_player_sprite.val = Some(load_art_texture("player_sprite.png"))
  tex_enemy_sprite.val = Some(load_art_texture("enemy_sprite.png"))
  tex_bomb_sprite.val = Some(load_art_texture("bomb_sprite.png"))
  tex_fire_sprite.val = Some(load_art_texture("fire_sprite.png"))
}

///|
/// Unloads generated bomber grid render assets.
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

  unload(tex_floor_tile)
  unload(tex_wall_block)
  unload(tex_crate_block)
  unload(tex_player_sprite)
  unload(tex_enemy_sprite)
  unload(tex_bomb_sprite)
  unload(tex_fire_sprite)
}

///|
/// Draws a texture inside one grid tile with the requested inset padding.
fn draw_art_cell(
  texture : @raylib.Texture,
  px : Int,
  py : Int,
  inset : Int,
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
    @raylib.Rectangle::new(
      Float::from_int(px + inset),
      Float::from_int(py + inset),
      Float::from_int(tile - inset * 2),
      Float::from_int(tile - inset * 2),
    ),
    @raylib.Vector2::new(0.0, 0.0),
    0.0,
    tint,
  )
}

///|
/// Draws the generated floor tile when loaded.
fn draw_floor_art(px : Int, py : Int) -> Bool {
  match tex_floor_tile.val {
    Some(texture) => {
      draw_art_cell(texture, px, py, 0, @raylib.white)
      true
    }
    None => false
  }
}

///|
/// Draws the generated permanent wall block when loaded.
fn draw_wall_art(px : Int, py : Int) -> Bool {
  match tex_wall_block.val {
    Some(texture) => {
      draw_art_cell(texture, px, py, 1, @raylib.white)
      true
    }
    None => false
  }
}

///|
/// Draws the generated breakable crate block when loaded.
fn draw_crate_art(px : Int, py : Int) -> Bool {
  match tex_crate_block.val {
    Some(texture) => {
      draw_art_cell(texture, px, py, 3, @raylib.white)
      true
    }
    None => false
  }
}

///|
/// Draws the generated player sprite when loaded.
fn draw_player_art(px : Int, py : Int) -> Bool {
  match tex_player_sprite.val {
    Some(texture) => {
      draw_art_cell(texture, px, py, 5, @raylib.white)
      true
    }
    None => false
  }
}

///|
/// Draws the generated enemy sprite when loaded.
fn draw_enemy_art(px : Int, py : Int) -> Bool {
  match tex_enemy_sprite.val {
    Some(texture) => {
      draw_art_cell(texture, px, py, 4, @raylib.white)
      true
    }
    None => false
  }
}

///|
/// Draws the generated bomb sprite when loaded.
fn draw_bomb_art(px : Int, py : Int) -> Bool {
  match tex_bomb_sprite.val {
    Some(texture) => {
      draw_art_cell(texture, px, py, 7, @raylib.white)
      true
    }
    None => false
  }
}

///|
/// Draws the generated explosion fire sprite when loaded.
fn draw_fire_art(px : Int, py : Int) -> Bool {
  match tex_fire_sprite.val {
    Some(texture) => {
      draw_art_cell(texture, px, py, 1, @raylib.white)
      true
    }
    None => false
  }
}
