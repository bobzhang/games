///|
/// Generated heist planning backdrop for the title screen.
let tex_title_backdrop : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated dark facility floor tile.
let tex_floor_tile : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated reinforced vault wall tile.
let tex_wall_tile : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated thief operative sprite.
let tex_player_sprite : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated time-loop ghost sprite.
let tex_ghost_sprite : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated guard sprite.
let tex_guard_sprite : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated vault objective sprite.
let tex_vault_sprite : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated extraction exit sprite.
let tex_exit_sprite : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated key collectible sprite.
let tex_key_sprite : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated breach door sprite.
let tex_door_sprite : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated pressure plate sprite.
let tex_pressure_plate_sprite : Ref[@raylib.Texture?] = { val: None }

///|
/// Loads one bilinear-filtered Chrono Heist texture.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "chrono_heist_blueprint_2026/resources/" + file_name,
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads generated Chrono Heist render assets.
fn load_assets() -> Unit {
  tex_title_backdrop.val = Some(load_art_texture("title_backdrop.png"))
  tex_floor_tile.val = Some(load_art_texture("floor_tile.png"))
  tex_wall_tile.val = Some(load_art_texture("wall_tile.png"))
  tex_player_sprite.val = Some(load_art_texture("player_sprite.png"))
  tex_ghost_sprite.val = Some(load_art_texture("ghost_sprite.png"))
  tex_guard_sprite.val = Some(load_art_texture("guard_sprite.png"))
  tex_vault_sprite.val = Some(load_art_texture("vault_sprite.png"))
  tex_exit_sprite.val = Some(load_art_texture("exit_sprite.png"))
  tex_key_sprite.val = Some(load_art_texture("key_sprite.png"))
  tex_door_sprite.val = Some(load_art_texture("door_sprite.png"))
  tex_pressure_plate_sprite.val = Some(
    load_art_texture("pressure_plate_sprite.png"),
  )
}

///|
/// Unloads generated Chrono Heist render assets.
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

  unload(tex_title_backdrop)
  unload(tex_floor_tile)
  unload(tex_wall_tile)
  unload(tex_player_sprite)
  unload(tex_ghost_sprite)
  unload(tex_guard_sprite)
  unload(tex_vault_sprite)
  unload(tex_exit_sprite)
  unload(tex_key_sprite)
  unload(tex_door_sprite)
  unload(tex_pressure_plate_sprite)
}

///|
/// Draws a texture into a top-left destination rectangle.
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
/// Draws a texture centered within a fit box while preserving aspect ratio.
fn draw_art_fit(
  texture : @raylib.Texture,
  center_x : Float,
  center_y : Float,
  max_width : Float,
  max_height : Float,
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
  @raylib.draw_texture_pro(
    texture,
    @raylib.Rectangle::new(0.0, 0.0, source_w, source_h),
    @raylib.Rectangle::new(center_x, center_y, width, height),
    @raylib.Vector2::new(width * 0.5, height * 0.5),
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
        Float::from_int(screen_w),
        Float::from_int(screen_h),
        @raylib.white,
      )
      @raylib.draw_rectangle(
        0,
        0,
        screen_w,
        screen_h,
        @raylib.Color::new(0, 6, 12, 58),
      )
      true
    }
    None => false
  }
}

///|
/// Draws a generated board tile if the texture is loaded.
fn draw_cell_texture(
  texture : @raylib.Texture,
  x : Int,
  y : Int,
  tint : @raylib.Color,
) -> Unit {
  let (rx, ry, rw, rh) = cell_rect(x, y)
  draw_art_rect(
    texture,
    Float::from_int(rx + 2),
    Float::from_int(ry + 2),
    Float::from_int(rw - 4),
    Float::from_int(rh - 4),
    tint,
  )
}

///|
/// Draws the generated floor tile if loaded.
fn draw_floor_art(x : Int, y : Int) -> Bool {
  match tex_floor_tile.val {
    Some(texture) => {
      draw_cell_texture(texture, x, y, @raylib.white)
      true
    }
    None => false
  }
}

///|
/// Draws the generated wall tile if loaded.
fn draw_wall_art(x : Int, y : Int) -> Bool {
  match tex_wall_tile.val {
    Some(texture) => {
      draw_cell_texture(texture, x, y, @raylib.white)
      true
    }
    None => false
  }
}

///|
/// Draws a generated centered object sprite if loaded.
fn draw_cell_object_art(
  texture_opt : @raylib.Texture?,
  x : Int,
  y : Int,
  size : Float,
  tint : @raylib.Color,
) -> Bool {
  match texture_opt {
    Some(texture) => {
      draw_art_fit(
        texture,
        Float::from_int(screen_center_x(x)),
        Float::from_int(screen_center_y(y)),
        size,
        size,
        tint,
      )
      true
    }
    None => false
  }
}

///|
fn draw_vault_art(x : Int, y : Int) -> Bool {
  draw_cell_object_art(tex_vault_sprite.val, x, y, 64.0, @raylib.white)
}

///|
fn draw_exit_art(x : Int, y : Int) -> Bool {
  draw_cell_object_art(tex_exit_sprite.val, x, y, 64.0, @raylib.white)
}

///|
fn draw_key_art(x : Int, y : Int) -> Bool {
  draw_cell_object_art(tex_key_sprite.val, x, y, 48.0, @raylib.white)
}

///|
fn draw_door_art(x : Int, y : Int, open : Bool) -> Bool {
  let tint = if open {
    @raylib.Color::new(175, 255, 198, 255)
  } else {
    @raylib.white
  }
  draw_cell_object_art(tex_door_sprite.val, x, y, 66.0, tint)
}

///|
fn draw_pressure_plate_art(x : Int, y : Int) -> Bool {
  draw_cell_object_art(tex_pressure_plate_sprite.val, x, y, 62.0, @raylib.white)
}

///|
fn draw_player_art(x : Int, y : Int) -> Bool {
  draw_cell_object_art(tex_player_sprite.val, x, y, 54.0, @raylib.white)
}

///|
fn draw_ghost_art(x : Int, y : Int) -> Bool {
  draw_cell_object_art(
    tex_ghost_sprite.val,
    x,
    y,
    54.0,
    @raylib.Color::new(190, 238, 255, 185),
  )
}

///|
fn draw_guard_art(x : Int, y : Int) -> Bool {
  draw_cell_object_art(tex_guard_sprite.val, x, y, 64.0, @raylib.white)
}
