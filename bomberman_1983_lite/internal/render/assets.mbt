///|
/// Generated floor tile texture.
let tex_floor_tile : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated destructible brick tile texture.
let tex_brick_tile : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated indestructible steel tile texture.
let tex_steel_tile : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated water tile texture.
let tex_water_tile : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated bush cover tile texture.
let tex_bush_tile : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated ice tile texture.
let tex_ice_tile : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated intact base tile texture.
let tex_base_tile : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated destroyed base tile texture.
let tex_base_destroyed_tile : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated player one tank texture.
let tex_player1_tank : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated player two tank texture.
let tex_player2_tank : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated basic enemy tank texture.
let tex_enemy_basic_tank : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated fast enemy tank texture.
let tex_enemy_fast_tank : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated heavy enemy tank texture.
let tex_enemy_heavy_tank : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated sniper enemy tank texture.
let tex_enemy_sniper_tank : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated bomb sprite texture.
let tex_bomb_sprite : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated blast sprite texture.
let tex_blast_sprite : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated player bullet sprite texture.
let tex_bullet_player : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated player two bullet sprite texture.
let tex_bullet_player2 : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated enemy bullet sprite texture.
let tex_bullet_enemy : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated shield powerup texture.
let tex_powerup_shield : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated star powerup texture.
let tex_powerup_star : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated grenade powerup texture.
let tex_powerup_grenade : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated clock powerup texture.
let tex_powerup_clock : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated shovel powerup texture.
let tex_powerup_shovel : Ref[@raylib.Texture?] = { val: None }

///|
/// Generated extra-life powerup texture.
let tex_powerup_life : Ref[@raylib.Texture?] = { val: None }

///|
/// Loads one bilinear-filtered Bomberman 1983 texture.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "bomberman_1983_lite/resources/" + file_name,
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads generated Bomberman 1983 render assets.
pub fn load_assets() -> Unit {
  tex_floor_tile.val = Some(load_art_texture("floor_tile.png"))
  tex_brick_tile.val = Some(load_art_texture("brick_tile.png"))
  tex_steel_tile.val = Some(load_art_texture("steel_tile.png"))
  tex_water_tile.val = Some(load_art_texture("water_tile.png"))
  tex_bush_tile.val = Some(load_art_texture("bush_tile.png"))
  tex_ice_tile.val = Some(load_art_texture("ice_tile.png"))
  tex_base_tile.val = Some(load_art_texture("base_tile.png"))
  tex_base_destroyed_tile.val = Some(load_art_texture("base_destroyed_tile.png"))
  tex_player1_tank.val = Some(load_art_texture("player1_tank.png"))
  tex_player2_tank.val = Some(load_art_texture("player2_tank.png"))
  tex_enemy_basic_tank.val = Some(load_art_texture("enemy_basic_tank.png"))
  tex_enemy_fast_tank.val = Some(load_art_texture("enemy_fast_tank.png"))
  tex_enemy_heavy_tank.val = Some(load_art_texture("enemy_heavy_tank.png"))
  tex_enemy_sniper_tank.val = Some(load_art_texture("enemy_sniper_tank.png"))
  tex_bomb_sprite.val = Some(load_art_texture("bomb_sprite.png"))
  tex_blast_sprite.val = Some(load_art_texture("blast_sprite.png"))
  tex_bullet_player.val = Some(load_art_texture("bullet_player.png"))
  tex_bullet_player2.val = Some(load_art_texture("bullet_player2.png"))
  tex_bullet_enemy.val = Some(load_art_texture("bullet_enemy.png"))
  tex_powerup_shield.val = Some(load_art_texture("powerup_shield.png"))
  tex_powerup_star.val = Some(load_art_texture("powerup_star.png"))
  tex_powerup_grenade.val = Some(load_art_texture("powerup_grenade.png"))
  tex_powerup_clock.val = Some(load_art_texture("powerup_clock.png"))
  tex_powerup_shovel.val = Some(load_art_texture("powerup_shovel.png"))
  tex_powerup_life.val = Some(load_art_texture("powerup_life.png"))
}

///|
/// Unloads generated Bomberman 1983 render assets.
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

  unload(tex_floor_tile)
  unload(tex_brick_tile)
  unload(tex_steel_tile)
  unload(tex_water_tile)
  unload(tex_bush_tile)
  unload(tex_ice_tile)
  unload(tex_base_tile)
  unload(tex_base_destroyed_tile)
  unload(tex_player1_tank)
  unload(tex_player2_tank)
  unload(tex_enemy_basic_tank)
  unload(tex_enemy_fast_tank)
  unload(tex_enemy_heavy_tank)
  unload(tex_enemy_sniper_tank)
  unload(tex_bomb_sprite)
  unload(tex_blast_sprite)
  unload(tex_bullet_player)
  unload(tex_bullet_player2)
  unload(tex_bullet_enemy)
  unload(tex_powerup_shield)
  unload(tex_powerup_star)
  unload(tex_powerup_grenade)
  unload(tex_powerup_clock)
  unload(tex_powerup_shovel)
  unload(tex_powerup_life)
}

///|
/// Draws a texture centered at the requested screen position.
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
/// Converts a cardinal tank direction into degrees for upward-facing sprites.
fn dir_rotation(dir : @types.Dir) -> Float {
  match dir {
    Up => 0.0
    Right => 90.0
    Down => 180.0
    Left => -90.0
  }
}

///|
/// Draws the generated floor tile when loaded.
fn draw_floor_art(sx : Int, sy : Int) -> Bool {
  match tex_floor_tile.val {
    Some(texture) => {
      draw_art_centered(
        texture,
        Float::from_int(sx + @types.tile_size / 2),
        Float::from_int(sy + @types.tile_size / 2),
        Float::from_int(@types.tile_size),
        Float::from_int(@types.tile_size),
        0.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Returns the generated texture for a tile.
fn tile_art(tile : @types.TileKind, base_alive : Bool) -> @raylib.Texture? {
  match tile {
    Brick => tex_brick_tile.val
    Steel => tex_steel_tile.val
    Water => tex_water_tile.val
    Bush => tex_bush_tile.val
    Ice => tex_ice_tile.val
    Base =>
      if base_alive {
        tex_base_tile.val
      } else {
        tex_base_destroyed_tile.val
      }
    Empty => None
  }
}

///|
/// Draws the generated tile sprite when loaded.
fn draw_tile_art(
  tile : @types.TileKind,
  base_alive : Bool,
  sx : Int,
  sy : Int,
) -> Bool {
  match tile_art(tile, base_alive) {
    Some(texture) => {
      draw_art_centered(
        texture,
        Float::from_int(sx + @types.tile_size / 2),
        Float::from_int(sy + @types.tile_size / 2),
        Float::from_int(@types.tile_size),
        Float::from_int(@types.tile_size),
        0.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Returns the generated tank texture for a player slot.
fn player_tank_art(index : Int) -> @raylib.Texture? {
  if index == 0 {
    tex_player1_tank.val
  } else {
    tex_player2_tank.val
  }
}

///|
/// Returns the generated tank texture for an enemy kind.
fn enemy_tank_art(kind : @types.EnemyKind) -> @raylib.Texture? {
  match kind {
    Fast => tex_enemy_fast_tank.val
    Heavy => tex_enemy_heavy_tank.val
    Sniper => tex_enemy_sniper_tank.val
    Basic => tex_enemy_basic_tank.val
  }
}

///|
/// Draws a generated tank sprite when loaded.
fn draw_tank_art(
  texture : @raylib.Texture,
  tank : @types.Tank,
  shake_x : Float,
  shake_y : Float,
  tint : @raylib.Color,
) -> Unit {
  draw_art_centered(
    texture,
    Float::from_int(@types.world_to_screen_x(tank.x, shake_x)),
    Float::from_int(@types.world_to_screen_y(tank.y, shake_y)),
    @types.tank_size + 7.0,
    @types.tank_size + 7.0,
    dir_rotation(tank.dir),
    tint,
  )
}

///|
/// Draws a generated player tank sprite when loaded.
fn draw_player_tank_art(
  index : Int,
  tank : @types.Tank,
  shake_x : Float,
  shake_y : Float,
) -> Bool {
  match player_tank_art(index) {
    Some(texture) => {
      draw_tank_art(texture, tank, shake_x, shake_y, @raylib.white)
      true
    }
    None => false
  }
}

///|
/// Draws a generated enemy tank sprite when loaded.
fn draw_enemy_tank_art(
  tank : @types.Tank,
  shake_x : Float,
  shake_y : Float,
  tint : @raylib.Color,
) -> Bool {
  match enemy_tank_art(tank.enemy_kind) {
    Some(texture) => {
      draw_tank_art(texture, tank, shake_x, shake_y, tint)
      true
    }
    None => false
  }
}

///|
/// Draws a generated bomb sprite when loaded.
fn draw_bomb_art(
  center_x : Int,
  center_y : Int,
  pulse : Float,
) -> Bool {
  match tex_bomb_sprite.val {
    Some(texture) => {
      let size = 20.0F + pulse * 2.0F
      draw_art_centered(
        texture,
        Float::from_int(center_x),
        Float::from_int(center_y),
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
/// Draws a generated blast cell when loaded.
fn draw_blast_art(sx : Int, sy : Int, alpha : Float) -> Bool {
  match tex_blast_sprite.val {
    Some(texture) => {
      draw_art_centered(
        texture,
        Float::from_int(sx + @types.tile_size / 2),
        Float::from_int(sy + @types.tile_size / 2),
        Float::from_int(@types.tile_size + 4),
        Float::from_int(@types.tile_size + 4),
        0.0,
        @raylib.color_alpha(@raylib.white, 0.65F + alpha * 0.35F),
      )
      true
    }
    None => false
  }
}

///|
/// Draws a generated bullet sprite when loaded.
fn draw_bullet_art(
  bullet : @types.Bullet,
  shake_x : Float,
  shake_y : Float,
) -> Bool {
  let texture = match bullet.owner_team {
    Enemy => tex_bullet_enemy.val
    Player2 => tex_bullet_player2.val
    _ => tex_bullet_player.val
  }
  match texture {
    Some(texture) => {
      let angle = Float::from_double(
        @math.atan2(bullet.vy.to_double(), bullet.vx.to_double()) *
        57.29577951308232,
      )
      draw_art_centered(
        texture,
        Float::from_int(@types.world_to_screen_x(bullet.x, shake_x)),
        Float::from_int(@types.world_to_screen_y(bullet.y, shake_y)),
        17.0,
        7.0,
        angle,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Returns the generated sprite for a powerup kind.
fn powerup_art(kind : @types.PowerupKind) -> @raylib.Texture? {
  match kind {
    Shield => tex_powerup_shield.val
    Star => tex_powerup_star.val
    Grenade => tex_powerup_grenade.val
    Clock => tex_powerup_clock.val
    Shovel => tex_powerup_shovel.val
    ExtraLife => tex_powerup_life.val
  }
}

///|
/// Draws a generated powerup sprite when loaded.
fn draw_powerup_art(kind : @types.PowerupKind, sx : Int, sy : Int, pulse : Float) -> Bool {
  match powerup_art(kind) {
    Some(texture) => {
      let size = powerup_radius(kind) * 2.0F + pulse * 2.5F
      draw_art_centered(
        texture,
        Float::from_int(sx),
        Float::from_int(sy),
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
