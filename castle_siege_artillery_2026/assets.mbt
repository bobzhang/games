///|
/// Texture handle for the full-screen battlefield backdrop.
let tex_battlefield_backdrop : Ref[@raylib.Texture?] = { val: None }

///|
/// Texture handle for the player's blue-gray castle.
let tex_player_castle : Ref[@raylib.Texture?] = { val: None }

///|
/// Texture handle for the enemy's red fortress.
let tex_enemy_castle : Ref[@raylib.Texture?] = { val: None }

///|
/// Texture handle for the central rocky obstacle.
let tex_mountain_obstacle : Ref[@raylib.Texture?] = { val: None }

///|
/// Texture handle for the cannon sprite.
let tex_cannon_sprite : Ref[@raylib.Texture?] = { val: None }

///|
/// Texture handle for the cannonball projectile.
let tex_cannonball : Ref[@raylib.Texture?] = { val: None }

///|
/// Texture handle for the animated explosion sprite.
let tex_explosion : Ref[@raylib.Texture?] = { val: None }

///|
/// Texture handle for the touch-control panel.
let tex_control_panel : Ref[@raylib.Texture?] = { val: None }

///|
/// Loads a texture from the Castle Siege resource directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "castle_siege_artillery_2026/resources/" + file_name,
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads all Castle Siege art textures.
fn load_assets() -> Unit {
  tex_battlefield_backdrop.val = Some(
    load_art_texture("battlefield_backdrop.png"),
  )
  tex_player_castle.val = Some(load_art_texture("player_castle.png"))
  tex_enemy_castle.val = Some(load_art_texture("enemy_castle.png"))
  tex_mountain_obstacle.val = Some(load_art_texture("mountain_obstacle.png"))
  tex_cannon_sprite.val = Some(load_art_texture("cannon_sprite.png"))
  tex_cannonball.val = Some(load_art_texture("cannonball.png"))
  tex_explosion.val = Some(load_art_texture("explosion.png"))
  tex_control_panel.val = Some(load_art_texture("control_panel.png"))
}

///|
/// Unloads all Castle Siege art textures.
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

  unload(tex_battlefield_backdrop)
  unload(tex_player_castle)
  unload(tex_enemy_castle)
  unload(tex_mountain_obstacle)
  unload(tex_cannon_sprite)
  unload(tex_cannonball)
  unload(tex_explosion)
  unload(tex_control_panel)
}

///|
/// Draws a texture stretched from its top-left corner.
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
/// Draws a texture centered around a point, optionally rotated.
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
/// Draws a horizontally mirrored centered texture.
fn draw_art_centered_flipped(
  texture : @raylib.Texture,
  cx : Float,
  cy : Float,
  width : Float,
  height : Float,
  rotation : Float,
  tint : @raylib.Color,
) -> Unit {
  let source_w = Float::from_int(texture.width())
  @raylib.draw_texture_pro(
    texture,
    @raylib.Rectangle::new(
      source_w,
      0.0,
      -source_w,
      Float::from_int(texture.height()),
    ),
    @raylib.Rectangle::new(cx, cy, width, height),
    @raylib.Vector2::new(width * 0.5, height * 0.5),
    rotation,
    tint,
  )
}

///|
/// Draws the full battlefield backdrop.
fn draw_battlefield_art() -> Bool {
  match tex_battlefield_backdrop.val {
    Some(texture) => {
      draw_art_top_left(
        texture,
        0.0,
        0.0,
        Float::from_int(sw),
        Float::from_int(sh),
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Draws either castle sprite.
fn draw_castle_art(
  is_enemy : Bool,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Bool {
  let texture_ref = if is_enemy { tex_enemy_castle } else { tex_player_castle }
  match texture_ref.val {
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
/// Draws the central mountain obstacle sprite.
fn draw_mountain_art(x : Int, y : Int, width : Int, height : Int) -> Bool {
  match tex_mountain_obstacle.val {
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
/// Draws a cannon with its muzzle aligned near the physics launch point.
fn draw_cannon_art(
  muzzle_x : Float,
  muzzle_y : Float,
  from_left : Bool,
  angle : Float,
) -> Bool {
  match tex_cannon_sprite.val {
    Some(texture) => {
      let cs = cosf_deg(angle)
      let sn = sinf_deg(angle)
      let arm : Float = 38.0
      let (cx, cy, rotation) = if from_left {
        (muzzle_x - cs * arm, muzzle_y + sn * arm, -angle)
      } else {
        (muzzle_x + cs * arm, muzzle_y + sn * arm, 180.0F + angle)
      }
      if from_left {
        draw_art_centered(texture, cx, cy, 88.0, 46.0, rotation, @raylib.white)
      } else {
        draw_art_centered_flipped(
          texture, cx, cy, 88.0, 46.0, rotation, @raylib.white,
        )
      }
      true
    }
    None => false
  }
}

///|
/// Draws the active cannonball projectile.
fn draw_cannonball_art(cx : Float, cy : Float) -> Bool {
  match tex_cannonball.val {
    Some(texture) => {
      draw_art_centered(texture, cx, cy, 30.0, 30.0, 0.0, @raylib.white)
      true
    }
    None => false
  }
}

///|
/// Draws a scaled explosion sprite.
fn draw_explosion_art(
  cx : Float,
  cy : Float,
  size : Float,
  alpha : Int,
) -> Bool {
  match tex_explosion.val {
    Some(texture) => {
      draw_art_centered(
        texture,
        cx,
        cy,
        size,
        size,
        0.0,
        @raylib.Color::new(255, 255, 255, alpha),
      )
      true
    }
    None => false
  }
}

///|
/// Draws the decorative touch-control panel.
fn draw_control_panel_art(x : Int, y : Int, width : Int, height : Int) -> Bool {
  match tex_control_panel.val {
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
