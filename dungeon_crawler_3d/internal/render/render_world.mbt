// 3D world rendering

///|
/// Draws the 3D dungeon world with tiles, actors, projectiles, and particle effects.
pub fn draw_world(game : @types.Game) -> Unit {
  let camera = game.build_camera()
  @raylib.begin_mode_3d(camera)
  game.draw_dungeon()
  game.draw_enemies_3d()
  game.draw_loot_3d()
  game.draw_projectiles_3d()
  game.draw_particles_3d()
  game.draw_damage_numbers_3d()
  game.draw_sword_swing()
  @raylib.end_mode_3d()
}

///|
fn @types.Game::build_camera(game : @types.Game) -> @raylib.Camera3D {
  // Apply screen shake offset
  let shake = @types.get_shake_offset(game)
  let eye_x = game.player_x + shake.0
  let eye_y = @types.player_eye_height + shake.1
  let eye_z = game.player_z
  // Target is in front of player based on yaw and pitch
  let forward_x = @math.sinf(game.camera_yaw) * @math.cosf(game.camera_pitch)
  let forward_y = @math.sinf(game.camera_pitch)
  let forward_z = @math.cosf(game.camera_yaw) * @math.cosf(game.camera_pitch)
  let target_x = eye_x + forward_x * 10.0
  let target_y = eye_y + forward_y * 10.0
  let target_z = eye_z + forward_z * 10.0
  @raylib.Camera3D::new(
    @raylib.Vector3::new(eye_x, eye_y, eye_z),
    @raylib.Vector3::new(target_x, target_y, target_z),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    @types.camera_fovy,
    @raylib.CameraPerspective,
  )
}

///|
fn @types.Game::draw_dungeon(game : @types.Game) -> Unit {
  // Only draw tiles near the player for performance
  let pgx = @types.world_to_grid_x(game.player_x)
  let pgz = @types.world_to_grid_z(game.player_z)
  let draw_radius = 16
  let min_gx = (0).max(pgx - draw_radius)
  let max_gx = (@types.grid_w - 1).min(pgx + draw_radius)
  let min_gz = (0).max(pgz - draw_radius)
  let max_gz = (@types.grid_h - 1).min(pgz + draw_radius)
  for gz in min_gz..<=max_gz {
    for gx in min_gx..<=max_gx {
      let tile = @types.get_tile(game, gx, gz)
      let wx = @types.grid_to_world_x(gx)
      let wz = @types.grid_to_world_z(gz)
      if tile == @types.tile_wall {
        draw_wall(wx, wz, game, gx, gz)
      } else if tile == @types.tile_floor {
        draw_floor_tile(wx, wz)
      } else if tile == @types.tile_door {
        draw_floor_tile(wx, wz)
        draw_door(wx, wz)
      } else if tile == @types.tile_stairs {
        draw_floor_tile(wx, wz)
        draw_stairs(wx, wz, game)
      } else if tile == @types.tile_chest {
        draw_floor_tile(wx, wz)
        draw_chest(wx, wz, game)
      }
    }
  }
}

///|
fn draw_wall(
  wx : Float,
  wz : Float,
  game : @types.Game,
  gx : Int,
  gz : Int,
) -> Unit {
  // Only draw wall faces that are adjacent to walkable tiles for performance
  let has_floor_neighbor = @types.is_walkable(@types.get_tile(game, gx - 1, gz)) ||
    @types.is_walkable(@types.get_tile(game, gx + 1, gz)) ||
    @types.is_walkable(@types.get_tile(game, gx, gz - 1)) ||
    @types.is_walkable(@types.get_tile(game, gx, gz + 1))
  if !has_floor_neighbor {
    return // Interior wall - don't draw
  }
  let cs = @types.cell_size
  let wh = @types.wall_height
  // Dark stone wall
  let base_r = 40 + (gx * 7 + gz * 13) % 15
  let base_g = 35 + (gx * 11 + gz * 3) % 10
  let base_b = 50 + (gx * 5 + gz * 7) % 12
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, wh / 2.0, wz),
    cs,
    wh,
    cs,
    @raylib.Color::new(base_r, base_g, base_b, 255),
  )
  @raylib.draw_cube_wires(
    @raylib.Vector3::new(wx, wh / 2.0, wz),
    cs,
    wh,
    cs,
    @raylib.Color::new(25, 25, 35, 255),
  )
}

///|
fn draw_floor_tile(wx : Float, wz : Float) -> Unit {
  let cs = @types.cell_size
  // Floor
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, -0.05, wz),
    cs,
    0.1,
    cs,
    @raylib.Color::new(55, 50, 65, 255),
  )
  // Ceiling
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, @types.wall_height + 0.05, wz),
    cs,
    0.1,
    cs,
    @raylib.Color::new(30, 28, 38, 255),
  )
}

///|
fn draw_door(wx : Float, wz : Float) -> Unit {
  // Door frame
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, @types.wall_height / 2.0, wz),
    0.3,
    @types.wall_height,
    @types.cell_size,
    @raylib.Color::new(90, 60, 30, 255),
  )
  // Door arch
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, @types.wall_height - 0.3, wz),
    @types.cell_size,
    0.3,
    0.3,
    @raylib.Color::new(90, 60, 30, 255),
  )
}

///|
fn draw_stairs(wx : Float, wz : Float, game : @types.Game) -> Unit {
  // Glowing stairs indicator
  let pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.06) * 0.2 + 0.8
  let g_float : Float = 200.0 * pulse
  let g_val = g_float.to_int()
  let b_float : Float = 255.0 * pulse
  let b_val = b_float.to_int()
  // Step blocks
  @raylib.draw_cube(
    @raylib.Vector3::new(wx - 0.4, 0.15, wz),
    0.4,
    0.3,
    1.2,
    @raylib.Color::new(80, 80, 100, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.35, wz),
    0.4,
    0.3,
    1.2,
    @raylib.Color::new(80, 80, 100, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(wx + 0.4, 0.55, wz),
    0.4,
    0.3,
    1.2,
    @raylib.Color::new(80, 80, 100, 255),
  )
  // Glow orb above stairs
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx, 1.8, wz),
    0.25,
    @raylib.Color::new(50, g_val, b_val, 200),
  )
}

///|
fn draw_chest(wx : Float, wz : Float, game : @types.Game) -> Unit {
  ignore(game)
  // Chest body
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.3, wz),
    0.8,
    0.5,
    0.6,
    @raylib.Color::new(120, 80, 30, 255),
  )
  // Chest lid
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.6, wz),
    0.85,
    0.15,
    0.65,
    @raylib.Color::new(140, 90, 35, 255),
  )
  // Lock
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.4, wz + 0.31),
    0.15,
    0.15,
    0.05,
    @raylib.Color::new(220, 200, 50, 255),
  )
}

///|
fn @types.Game::draw_enemies_3d(game : @types.Game) -> Unit {
  for e in game.enemies {
    if !e.active {
      continue
    }
    // Distance check - don't draw far enemies
    let dist = @types.dist2d(game.player_x, game.player_z, e.x, e.z)
    if dist > 30.0 {
      continue
    }
    let flash = e.hit_flash > 0.0
    match e.kind {
      Skeleton => draw_skeleton(e.x, e.z, flash, game)
      Archer => draw_archer(e.x, e.z, flash, game)
      Golem => draw_golem(e.x, e.z, flash, game)
      Wraith => draw_wraith(e.x, e.z, flash, game)
      DragonBoss => draw_dragon(e.x, e.z, flash, game)
      Slime => draw_slime(e.x, e.z, flash, game)
      Bat => draw_bat(e.x, e.z, flash, game)
      Spider => draw_spider(e.x, e.z, flash, game)
      Minotaur => draw_minotaur(e.x, e.z, flash, game)
      Lich => draw_lich(e.x, e.z, flash, game)
      Mimic => draw_mimic(e.x, e.z, flash, game)
      _ => ()
    }
    // Slow visual indicator: blue tint around slowed enemies
    if e.slow_timer > 0.0 {
      @raylib.draw_sphere(
        @raylib.Vector3::new(e.x, 0.5, e.z),
        0.6,
        @raylib.Color::new(100, 180, 255, 40),
      )
    }
    // Stun visual indicator: spinning stars
    if e.stun_timer > 0.0 {
      let star_angle = Float::from_int(game.frame_counter) * 0.15
      let star_x = e.x + @math.sinf(star_angle) * 0.4
      let star_z = e.z + @math.cosf(star_angle) * 0.4
      @raylib.draw_sphere(
        @raylib.Vector3::new(star_x, 2.0, star_z),
        0.06,
        @raylib.Color::new(255, 255, 100, 200),
      )
      let star_x2 = e.x + @math.sinf(star_angle + 2.1) * 0.4
      let star_z2 = e.z + @math.cosf(star_angle + 2.1) * 0.4
      @raylib.draw_sphere(
        @raylib.Vector3::new(star_x2, 2.0, star_z2),
        0.06,
        @raylib.Color::new(255, 255, 100, 200),
      )
    }
    // Attack telegraph visual: pulsing glow and size increase
    if e.telegraph_timer > 0.0 {
      let pulse = @math.sinf(
        Float::from_int(game.frame_counter) * 0.5,
      )
      let pulse_abs = if pulse > 0.0 { pulse } else { -pulse }
      let glow_size : Float = 0.5 + pulse_abs * 0.3
      // Red warning glow
      let glow_alpha = (pulse_abs * 200.0).to_int().clamp(min=60, max=200)
      @raylib.draw_sphere(
        @raylib.Vector3::new(e.x, 1.0, e.z),
        glow_size,
        @raylib.Color::new(255, 60, 30, glow_alpha),
      )
      // Directional indicator for ranged attacks
      if e.telegraph_kind == 2 || e.telegraph_kind == 3 || e.telegraph_kind == 5 {
        let dir_x = @math.sinf(e.facing_angle)
        let dir_z = @math.cosf(e.facing_angle)
        @raylib.draw_cube(
          @raylib.Vector3::new(
            e.x + dir_x * 1.5, 1.0, e.z + dir_z * 1.5,
          ),
          0.15,
          0.15,
          0.15,
          @raylib.Color::new(255, 200, 50, glow_alpha),
        )
        @raylib.draw_cube(
          @raylib.Vector3::new(
            e.x + dir_x * 2.5, 1.0, e.z + dir_z * 2.5,
          ),
          0.1,
          0.1,
          0.1,
          @raylib.Color::new(255, 200, 50, glow_alpha / 2),
        )
      }
      // Boss AoE ground marker
      if e.telegraph_kind == 4 {
        @raylib.draw_cube(
          @raylib.Vector3::new(game.player_x, 0.05, game.player_z),
          3.0,
          0.05,
          3.0,
          @raylib.Color::new(255, 50, 30, glow_alpha / 3),
        )
      }
    }
    // Health bar above enemy
    if e.hp < e.max_hp {
      draw_enemy_health_bar(e, game)
    }
  }
}

///|
fn draw_skeleton(
  wx : Float,
  wz : Float,
  flash : Bool,
  game : @types.Game,
) -> Unit {
  ignore(game)
  let body_color = if flash {
    @raylib.Color::new(255, 255, 255, 255)
  } else {
    @raylib.Color::new(200, 190, 170, 255)
  }
  // Body
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.7, wz),
    0.4,
    0.8,
    0.3,
    body_color,
  )
  // Head (skull)
  @raylib.draw_sphere(@raylib.Vector3::new(wx, 1.3, wz), 0.2, body_color)
  // Arms
  @raylib.draw_cube(
    @raylib.Vector3::new(wx - 0.35, 0.7, wz),
    0.1,
    0.6,
    0.1,
    body_color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(wx + 0.35, 0.7, wz),
    0.1,
    0.6,
    0.1,
    body_color,
  )
}

///|
fn draw_archer(
  wx : Float,
  wz : Float,
  flash : Bool,
  game : @types.Game,
) -> Unit {
  ignore(game)
  let body_color = if flash {
    @raylib.Color::new(255, 255, 255, 255)
  } else {
    @raylib.Color::new(80, 120, 60, 255)
  }
  // Body
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.7, wz),
    0.4,
    0.8,
    0.3,
    body_color,
  )
  // Head with hood
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx, 1.3, wz),
    0.22,
    @raylib.Color::new(60, 90, 40, 255),
  )
  // Bow
  @raylib.draw_cube(
    @raylib.Vector3::new(wx + 0.4, 0.8, wz),
    0.05,
    0.7,
    0.05,
    @raylib.Color::new(140, 100, 40, 255),
  )
}

///|
fn draw_golem(wx : Float, wz : Float, flash : Bool, game : @types.Game) -> Unit {
  ignore(game)
  let body_color = if flash {
    @raylib.Color::new(255, 255, 255, 255)
  } else {
    @raylib.Color::new(100, 90, 80, 255)
  }
  // Large body
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.9, wz),
    0.9,
    1.4,
    0.7,
    body_color,
  )
  // Head
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 1.8, wz),
    0.5,
    0.4,
    0.4,
    body_color,
  )
  // Eyes (glowing)
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx - 0.12, 1.85, wz + 0.2),
    0.06,
    @raylib.Color::new(255, 150, 0, 255),
  )
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx + 0.12, 1.85, wz + 0.2),
    0.06,
    @raylib.Color::new(255, 150, 0, 255),
  )
  // Arms
  @raylib.draw_cube(
    @raylib.Vector3::new(wx - 0.6, 0.8, wz),
    0.3,
    1.0,
    0.3,
    body_color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(wx + 0.6, 0.8, wz),
    0.3,
    1.0,
    0.3,
    body_color,
  )
}

///|
fn draw_wraith(
  wx : Float,
  wz : Float,
  flash : Bool,
  game : @types.Game,
) -> Unit {
  let bob = @math.sinf(Float::from_int(game.frame_counter) * 0.08) * 0.15
  let body_color = if flash {
    @raylib.Color::new(255, 255, 255, 200)
  } else {
    @raylib.Color::new(80, 50, 120, 180)
  }
  // Ghostly body
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.8 + bob, wz),
    0.5,
    1.0,
    0.4,
    body_color,
  )
  // Head
  @raylib.draw_sphere(@raylib.Vector3::new(wx, 1.5 + bob, wz), 0.25, body_color)
  // Eyes
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx - 0.08, 1.55 + bob, wz + 0.2),
    0.05,
    @raylib.Color::new(200, 50, 255, 255),
  )
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx + 0.08, 1.55 + bob, wz + 0.2),
    0.05,
    @raylib.Color::new(200, 50, 255, 255),
  )
}

///|
fn draw_dragon(
  wx : Float,
  wz : Float,
  flash : Bool,
  game : @types.Game,
) -> Unit {
  ignore(game)
  let body_color = if flash {
    @raylib.Color::new(255, 255, 255, 255)
  } else {
    @raylib.Color::new(150, 30, 30, 255)
  }
  // Large body
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 1.2, wz),
    1.4,
    1.8,
    1.0,
    body_color,
  )
  // Head
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 2.3, wz + 0.6),
    0.6,
    0.5,
    0.8,
    body_color,
  )
  // Eyes
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx - 0.2, 2.4, wz + 1.0),
    0.1,
    @raylib.Color::new(255, 200, 0, 255),
  )
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx + 0.2, 2.4, wz + 1.0),
    0.1,
    @raylib.Color::new(255, 200, 0, 255),
  )
  // Wings
  @raylib.draw_cube(
    @raylib.Vector3::new(wx - 1.2, 1.8, wz),
    1.0,
    0.1,
    0.8,
    @raylib.Color::new(120, 20, 20, 200),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(wx + 1.2, 1.8, wz),
    1.0,
    0.1,
    0.8,
    @raylib.Color::new(120, 20, 20, 200),
  )
  // Tail
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.8, wz - 1.0),
    0.3,
    0.3,
    1.2,
    body_color,
  )
}

///|
fn draw_slime(
  wx : Float,
  wz : Float,
  flash : Bool,
  game : @types.Game,
) -> Unit {
  let sin_val = @math.sinf(Float::from_int(game.frame_counter) * 0.1)
  let bounce = (if sin_val < 0.0 { -sin_val } else { sin_val }) * 0.15
  let body_color = if flash {
    @raylib.Color::new(255, 255, 255, 220)
  } else {
    @raylib.Color::new(50, 200, 50, 220)
  }
  // Blobby body
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx, 0.35 + bounce, wz),
    0.4 - bounce * 0.3,
    body_color,
  )
  // Eyes
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx - 0.1, 0.5 + bounce, wz + 0.25),
    0.06,
    @raylib.Color::new(20, 20, 20, 255),
  )
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx + 0.1, 0.5 + bounce, wz + 0.25),
    0.06,
    @raylib.Color::new(20, 20, 20, 255),
  )
}

///|
fn draw_bat(
  wx : Float,
  wz : Float,
  flash : Bool,
  game : @types.Game,
) -> Unit {
  let wing_flap = @math.sinf(Float::from_int(game.frame_counter) * 0.3) * 0.3
  let body_color = if flash {
    @raylib.Color::new(255, 255, 255, 255)
  } else {
    @raylib.Color::new(80, 60, 40, 255)
  }
  // Small body
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx, 1.6, wz),
    0.15,
    body_color,
  )
  // Wings
  @raylib.draw_cube(
    @raylib.Vector3::new(wx - 0.35, 1.6 + wing_flap, wz),
    0.4,
    0.05,
    0.2,
    @raylib.Color::new(60, 40, 30, 200),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(wx + 0.35, 1.6 - wing_flap, wz),
    0.4,
    0.05,
    0.2,
    @raylib.Color::new(60, 40, 30, 200),
  )
  // Eyes
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx - 0.05, 1.65, wz + 0.1),
    0.03,
    @raylib.Color::new(255, 50, 50, 255),
  )
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx + 0.05, 1.65, wz + 0.1),
    0.03,
    @raylib.Color::new(255, 50, 50, 255),
  )
}

///|
fn draw_spider(
  wx : Float,
  wz : Float,
  flash : Bool,
  game : @types.Game,
) -> Unit {
  ignore(game)
  let body_color = if flash {
    @raylib.Color::new(255, 255, 255, 255)
  } else {
    @raylib.Color::new(60, 50, 40, 255)
  }
  // Abdomen
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx, 0.4, wz - 0.15),
    0.25,
    body_color,
  )
  // Thorax
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx, 0.45, wz + 0.15),
    0.18,
    body_color,
  )
  // Legs (4 pairs)
  for i in 0..<4 {
    let angle = Float::from_int(i) * 0.8 - 1.2
    let lx = @math.sinf(angle) * 0.35
    let lz = @math.cosf(angle) * 0.15
    @raylib.draw_cube(
      @raylib.Vector3::new(wx + lx, 0.25, wz + lz),
      0.04,
      0.3,
      0.04,
      body_color,
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(wx - lx, 0.25, wz + lz),
      0.04,
      0.3,
      0.04,
      body_color,
    )
  }
  // Eyes (multiple small red dots)
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx - 0.06, 0.5, wz + 0.28),
    0.03,
    @raylib.Color::new(200, 30, 30, 255),
  )
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx + 0.06, 0.5, wz + 0.28),
    0.03,
    @raylib.Color::new(200, 30, 30, 255),
  )
}

///|
fn draw_minotaur(
  wx : Float,
  wz : Float,
  flash : Bool,
  game : @types.Game,
) -> Unit {
  ignore(game)
  let body_color = if flash {
    @raylib.Color::new(255, 255, 255, 255)
  } else {
    @raylib.Color::new(140, 90, 50, 255)
  }
  // Large muscular body
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 1.0, wz),
    0.8,
    1.4,
    0.6,
    body_color,
  )
  // Head
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 1.9, wz),
    0.45,
    0.4,
    0.35,
    body_color,
  )
  // Horns
  @raylib.draw_cube(
    @raylib.Vector3::new(wx - 0.35, 2.15, wz),
    0.08,
    0.3,
    0.08,
    @raylib.Color::new(200, 180, 140, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(wx + 0.35, 2.15, wz),
    0.08,
    0.3,
    0.08,
    @raylib.Color::new(200, 180, 140, 255),
  )
  // Eyes (angry red)
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx - 0.1, 1.95, wz + 0.18),
    0.05,
    @raylib.Color::new(255, 50, 30, 255),
  )
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx + 0.1, 1.95, wz + 0.18),
    0.05,
    @raylib.Color::new(255, 50, 30, 255),
  )
}

///|
fn draw_lich(
  wx : Float,
  wz : Float,
  flash : Bool,
  game : @types.Game,
) -> Unit {
  let bob = @math.sinf(Float::from_int(game.frame_counter) * 0.06) * 0.1
  let body_color = if flash {
    @raylib.Color::new(255, 255, 255, 240)
  } else {
    @raylib.Color::new(60, 30, 80, 240)
  }
  // Robed body
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.8 + bob, wz),
    0.5,
    1.2,
    0.4,
    body_color,
  )
  // Skull head
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx, 1.6 + bob, wz),
    0.22,
    @raylib.Color::new(200, 190, 170, 255),
  )
  // Crown/circlet
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 1.8 + bob, wz),
    0.3,
    0.06,
    0.3,
    @raylib.Color::new(180, 50, 200, 255),
  )
  // Glowing eyes
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx - 0.07, 1.65 + bob, wz + 0.18),
    0.04,
    @raylib.Color::new(200, 50, 255, 255),
  )
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx + 0.07, 1.65 + bob, wz + 0.18),
    0.04,
    @raylib.Color::new(200, 50, 255, 255),
  )
  // Magical aura
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx, 1.2 + bob, wz),
    0.6,
    @raylib.Color::new(120, 50, 180, 30),
  )
}

///|
fn draw_mimic(
  wx : Float,
  wz : Float,
  flash : Bool,
  game : @types.Game,
) -> Unit {
  ignore(game)
  let body_color = if flash {
    @raylib.Color::new(255, 255, 255, 255)
  } else {
    @raylib.Color::new(140, 100, 40, 255)
  }
  // Chest body (looks like a chest)
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.3, wz),
    0.8,
    0.5,
    0.6,
    body_color,
  )
  // Open lid with teeth
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.65, wz - 0.1),
    0.85,
    0.15,
    0.5,
    @raylib.Color::new(160, 110, 50, 255),
  )
  // Teeth
  @raylib.draw_cube(
    @raylib.Vector3::new(wx - 0.2, 0.5, wz + 0.3),
    0.08,
    0.15,
    0.06,
    @raylib.Color::new(240, 240, 220, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(wx + 0.2, 0.5, wz + 0.3),
    0.08,
    0.15,
    0.06,
    @raylib.Color::new(240, 240, 220, 255),
  )
  // Eye
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx, 0.55, wz + 0.25),
    0.08,
    @raylib.Color::new(255, 200, 50, 255),
  )
}

///|
fn draw_enemy_health_bar(e : @types.Enemy, game : @types.Game) -> Unit {
  ignore(game)
  // Draw a simple health bar as cubes above the enemy
  let bar_y : Float = match e.kind {
    DragonBoss => 3.0
    Golem => 2.3
    _ => 1.8
  }
  let bar_width : Float = 0.8
  let hp_frac = Float::from_int(e.hp) / Float::from_int(e.max_hp)
  // Background (red)
  @raylib.draw_cube(
    @raylib.Vector3::new(e.x, bar_y, e.z),
    bar_width,
    0.08,
    0.08,
    @raylib.Color::new(180, 30, 30, 200),
  )
  // Foreground (green)
  let filled = bar_width * hp_frac
  let offset = (bar_width - filled) / 2.0
  @raylib.draw_cube(
    @raylib.Vector3::new(e.x - offset, bar_y, e.z),
    filled,
    0.08,
    0.08,
    @raylib.Color::new(30, 200, 30, 220),
  )
}

///|
fn @types.Game::draw_loot_3d(game : @types.Game) -> Unit {
  for l in game.loot {
    if !l.active {
      continue
    }
    let bob = @math.sinf(l.bob_phase) * 0.1
    let pos = @raylib.Vector3::new(l.x, 0.4 + bob, l.z)
    if l.kind == @types.loot_health_potion {
      // Green potion
      @raylib.draw_sphere(pos, 0.2, @raylib.Color::new(50, 220, 80, 220))
      @raylib.draw_cube(
        @raylib.Vector3::new(l.x, 0.6 + bob, l.z),
        0.1,
        0.1,
        0.1,
        @raylib.Color::new(80, 80, 80, 255),
      )
    } else if l.kind == @types.loot_damage_boost {
      // Red sword boost
      @raylib.draw_cube(
        pos,
        0.15,
        0.4,
        0.08,
        @raylib.Color::new(255, 80, 50, 240),
      )
      @raylib.draw_cube(
        @raylib.Vector3::new(l.x, 0.22 + bob, l.z),
        0.3,
        0.08,
        0.08,
        @raylib.Color::new(200, 60, 40, 255),
      )
    } else if l.kind == @types.loot_armor {
      // Blue shield
      @raylib.draw_cube(
        pos,
        0.3,
        0.35,
        0.08,
        @raylib.Color::new(60, 100, 220, 240),
      )
      @raylib.draw_cube(
        @raylib.Vector3::new(l.x, 0.4 + bob, l.z + 0.05),
        0.15,
        0.15,
        0.05,
        @raylib.Color::new(200, 200, 50, 255),
      )
    } else if l.kind == @types.loot_mana_potion {
      // Blue potion
      @raylib.draw_sphere(pos, 0.18, @raylib.Color::new(80, 100, 255, 220))
      @raylib.draw_cube(
        @raylib.Vector3::new(l.x, 0.58 + bob, l.z),
        0.08,
        0.08,
        0.08,
        @raylib.Color::new(80, 80, 80, 255),
      )
    } else if l.kind == @types.loot_gold_pile {
      // Gold coins
      @raylib.draw_cube(
        pos, 0.25, 0.12, 0.25, @raylib.Color::new(255, 215, 0, 240),
      )
      @raylib.draw_cube(
        @raylib.Vector3::new(l.x + 0.08, 0.48 + bob, l.z - 0.06),
        0.15,
        0.1,
        0.15,
        @raylib.Color::new(230, 195, 0, 220),
      )
    } else if l.kind == @types.loot_equip_weapon || l.kind == @types.loot_equip_armor || l.kind == @types.loot_equip_ring {
      // Equipment drops: rarity-colored glow
      let rr = @types.get_rarity_color_r(l.rarity)
      let rg = @types.get_rarity_color_g(l.rarity)
      let rb = @types.get_rarity_color_b(l.rarity)
      // Rarity glow aura
      let glow_pulse = @math.sinf(l.bob_phase * 2.0)
      let glow_abs : Float = if glow_pulse > 0.0 { glow_pulse } else { -glow_pulse }
      let glow_size : Float = 0.35 + glow_abs * 0.1
      @raylib.draw_sphere(
        pos,
        glow_size,
        @raylib.Color::new(rr, rg, rb, 60),
      )
      if l.kind == @types.loot_equip_weapon {
        // Weapon: small sword shape
        @raylib.draw_cube(
          pos,
          0.08,
          0.4,
          0.05,
          @raylib.Color::new(rr, rg, rb, 240),
        )
        @raylib.draw_cube(
          @raylib.Vector3::new(l.x, 0.25 + bob, l.z),
          0.2,
          0.06,
          0.06,
          @raylib.Color::new(rr, rg, rb, 200),
        )
      } else if l.kind == @types.loot_equip_armor {
        // Armor: chest piece shape
        @raylib.draw_cube(
          pos,
          0.25,
          0.3,
          0.15,
          @raylib.Color::new(rr, rg, rb, 240),
        )
      } else {
        // Ring: small torus approximation
        @raylib.draw_sphere(
          pos,
          0.15,
          @raylib.Color::new(rr, rg, rb, 240),
        )
        @raylib.draw_sphere(
          pos,
          0.08,
          @raylib.Color::new(20, 20, 20, 200),
        )
      }
    } else {
      // Generic pickup (key, potions, etc.)
      @raylib.draw_sphere(pos, 0.15, @raylib.Color::new(200, 200, 100, 200))
    }
  }
}

///|
fn @types.Game::draw_projectiles_3d(game : @types.Game) -> Unit {
  for p in game.projectiles {
    if !p.active {
      continue
    }
    let pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.2) * 0.03
    match p.kind {
      Fireball => {
        // Fireball: large fiery orb with ember trail
        @raylib.draw_sphere(
          @raylib.Vector3::new(p.x, 1.0, p.z),
          0.22 + pulse,
          @raylib.Color::new(255, 100, 20, 240),
        )
        @raylib.draw_sphere(
          @raylib.Vector3::new(p.x, 1.0, p.z),
          0.30 + pulse,
          @raylib.Color::new(255, 180, 40, 100),
        )
        // Ember trail
        @raylib.draw_sphere(
          @raylib.Vector3::new(p.x - p.vx * 0.02, 1.0, p.z - p.vz * 0.02),
          0.14,
          @raylib.Color::new(255, 60, 10, 160),
        )
        @raylib.draw_sphere(
          @raylib.Vector3::new(p.x - p.vx * 0.05, 1.05, p.z - p.vz * 0.05),
          0.08,
          @raylib.Color::new(255, 200, 60, 120),
        )
      }
      IceBolt => {
        // Ice bolt: angular crystal shard with cold trail
        @raylib.draw_cube(
          @raylib.Vector3::new(p.x, 1.0, p.z),
          0.12,
          0.25,
          0.12,
          @raylib.Color::new(150, 220, 255, 240),
        )
        @raylib.draw_cube(
          @raylib.Vector3::new(p.x, 1.0, p.z),
          0.20,
          0.15,
          0.20,
          @raylib.Color::new(100, 180, 255, 120),
        )
        // Frost trail
        @raylib.draw_sphere(
          @raylib.Vector3::new(
            p.x - p.vx * 0.03, 1.0, p.z - p.vz * 0.03,
          ),
          0.06,
          @raylib.Color::new(200, 240, 255, 140),
        )
      }
      Lightning => {
        // Lightning bolt: bright jagged spark
        @raylib.draw_sphere(
          @raylib.Vector3::new(p.x, 1.0, p.z),
          0.14 + pulse * 2.0,
          @raylib.Color::new(255, 255, 100, 255),
        )
        @raylib.draw_sphere(
          @raylib.Vector3::new(p.x, 1.0, p.z),
          0.24 + pulse * 3.0,
          @raylib.Color::new(200, 200, 255, 80),
        )
        // Electric arc segments
        let jitter = @math.sinf(Float::from_int(game.frame_counter) * 1.2)
        @raylib.draw_cube(
          @raylib.Vector3::new(
            p.x - p.vx * 0.015 + jitter * 0.08,
            1.0 + jitter * 0.05,
            p.z - p.vz * 0.015,
          ),
          0.04,
          0.18,
          0.04,
          @raylib.Color::new(255, 255, 200, 200),
        )
      }
      _ => {
        // Generic arrow/projectile: small fast dart
        let is_enemy = p.from_enemy
        let color = if is_enemy {
          @raylib.Color::new(255, 80, 60, 255)
        } else {
          @raylib.Color::new(220, 200, 140, 255)
        }
        @raylib.draw_sphere(
          @raylib.Vector3::new(p.x, 1.0, p.z), 0.10, color,
        )
        let trail_color = if is_enemy {
          @raylib.Color::new(255, 50, 30, 140)
        } else {
          @raylib.Color::new(200, 180, 100, 140)
        }
        @raylib.draw_sphere(
          @raylib.Vector3::new(
            p.x - p.vx * 0.02, 1.0, p.z - p.vz * 0.02,
          ),
          0.06,
          trail_color,
        )
      }
    }
  }
}

///|
fn @types.Game::draw_particles_3d(game : @types.Game) -> Unit {
  for p in game.particles {
    if !p.active {
      continue
    }
    let alpha_f = p.life / p.max_life
    let alpha = (alpha_f * 255.0).to_int()
    let a = alpha.clamp(min=0, max=255)
    @raylib.draw_cube(
      @raylib.Vector3::new(p.x, p.y, p.z),
      p.size,
      p.size,
      p.size,
      @raylib.Color::new(p.r, p.g, p.b, a),
    )
  }
}

///|
fn @types.Game::draw_damage_numbers_3d(game : @types.Game) -> Unit {
  for dn in game.damage_numbers {
    if !dn.active {
      continue
    }
    // Render as a small colored cube that rises (billboard text not available in raylib primitives)
    let max_timer : Float = if dn.is_crit { 1.5 } else { 1.0 }
    let alpha_f = dn.timer / max_timer
    let a = (alpha_f * 255.0).to_int().clamp(min=0, max=255)
    let size : Float = if dn.is_crit { 0.18 } else { 0.12 }
    // Main number indicator
    @raylib.draw_cube(
      @raylib.Vector3::new(dn.x, dn.y, dn.z),
      size,
      size,
      size,
      @raylib.Color::new(dn.r, dn.g, dn.b, a),
    )
    // Outline for crits
    if dn.is_crit {
      @raylib.draw_cube_wires(
        @raylib.Vector3::new(dn.x, dn.y, dn.z),
        size + 0.04,
        size + 0.04,
        size + 0.04,
        @raylib.Color::new(255, 255, 255, a / 2),
      )
    }
  }
}

///|
fn @types.Game::draw_sword_swing(game : @types.Game) -> Unit {
  if !game.swing_active {
    return
  }
  let t : Float = 1.0 - game.swing_timer / @types.swing_duration
  let fade : Float = 1.0 - t
  let alpha = (fade * 255.0).to_int()
  let a = alpha.clamp(min=0, max=255)
  match game.player_weapon {
    Sword => {
      // Sword: wide horizontal arc slash
      let t_offset : Float = t - 0.5
      let swing_angle : Float = game.camera_yaw + t_offset * 1.8
      let dist : Float = 1.2
      let sx = game.player_x + @math.sinf(swing_angle) * dist
      let sz = game.player_z + @math.cosf(swing_angle) * dist
      @raylib.draw_cube(
        @raylib.Vector3::new(sx, 1.2, sz),
        0.06,
        0.7,
        0.06,
        @raylib.Color::new(200, 210, 230, a),
      )
      @raylib.draw_cube(
        @raylib.Vector3::new(sx, 1.2, sz),
        0.02,
        0.9,
        0.02,
        @raylib.Color::new(255, 255, 180, a / 2),
      )
    }
    Axe => {
      // Axe: heavy overhead chop
      let chop_y : Float = 1.8 - t * 1.4
      let dist : Float = 1.0 + t * 0.3
      let sx = game.player_x + @math.sinf(game.camera_yaw) * dist
      let sz = game.player_z + @math.cosf(game.camera_yaw) * dist
      @raylib.draw_cube(
        @raylib.Vector3::new(sx, chop_y, sz),
        0.15,
        0.5,
        0.08,
        @raylib.Color::new(160, 140, 120, a),
      )
      // Axe head
      @raylib.draw_cube(
        @raylib.Vector3::new(sx, chop_y + 0.25, sz),
        0.25,
        0.15,
        0.08,
        @raylib.Color::new(180, 180, 190, a),
      )
      // Impact trail
      if t > 0.6 {
        @raylib.draw_cube(
          @raylib.Vector3::new(sx, 0.3, sz),
          0.4,
          0.05,
          0.4,
          @raylib.Color::new(200, 150, 80, a / 3),
        )
      }
    }
    Mace => {
      // Mace: spinning thrust
      let t_offset : Float = t - 0.5
      let swing_angle : Float = game.camera_yaw + t_offset * 2.2
      let dist : Float = 1.0
      let sx = game.player_x + @math.sinf(swing_angle) * dist
      let sz = game.player_z + @math.cosf(swing_angle) * dist
      @raylib.draw_cube(
        @raylib.Vector3::new(sx, 1.1, sz),
        0.08,
        0.55,
        0.08,
        @raylib.Color::new(140, 130, 120, a),
      )
      // Mace head
      @raylib.draw_sphere(
        @raylib.Vector3::new(sx, 1.5, sz),
        0.12,
        @raylib.Color::new(180, 180, 200, a),
      )
    }
    Dagger => {
      // Dagger: quick forward stab
      let stab_dist : Float = 0.5 + t * 0.8
      let sx = game.player_x + @math.sinf(game.camera_yaw) * stab_dist
      let sz = game.player_z + @math.cosf(game.camera_yaw) * stab_dist
      @raylib.draw_cube(
        @raylib.Vector3::new(sx, 1.1, sz),
        0.04,
        0.30,
        0.04,
        @raylib.Color::new(220, 220, 240, a),
      )
      // Speed lines
      let trail_dist = stab_dist - 0.3
      let tx = game.player_x + @math.sinf(game.camera_yaw) * trail_dist
      let tz = game.player_z + @math.cosf(game.camera_yaw) * trail_dist
      @raylib.draw_cube(
        @raylib.Vector3::new(tx, 1.1, tz),
        0.01,
        0.15,
        0.01,
        @raylib.Color::new(255, 255, 200, a / 3),
      )
    }
    Staff => {
      // Staff: circular magical sweep
      let t_offset : Float = t - 0.5
      let swing_angle : Float = game.camera_yaw + t_offset * 1.2
      let dist : Float = 1.4
      let sx = game.player_x + @math.sinf(swing_angle) * dist
      let sz = game.player_z + @math.cosf(swing_angle) * dist
      @raylib.draw_cube(
        @raylib.Vector3::new(sx, 0.8, sz),
        0.06,
        1.4,
        0.06,
        @raylib.Color::new(120, 80, 40, a),
      )
      // Magical orb at tip
      @raylib.draw_sphere(
        @raylib.Vector3::new(sx, 1.6, sz),
        0.1,
        @raylib.Color::new(150, 100, 255, a),
      )
    }
    Bow => {
      // Bow: draw string pullback animation
      let pull : Float = 1.0 - t
      let dist : Float = 0.8
      let sx = game.player_x + @math.sinf(game.camera_yaw) * dist
      let sz = game.player_z + @math.cosf(game.camera_yaw) * dist
      @raylib.draw_cube(
        @raylib.Vector3::new(sx, 1.1, sz),
        0.04,
        0.7,
        0.04,
        @raylib.Color::new(140, 100, 40, a),
      )
      // String
      let string_offset = pull * 0.15
      let bx = sx - @math.sinf(game.camera_yaw) * string_offset
      let bz = sz - @math.cosf(game.camera_yaw) * string_offset
      @raylib.draw_cube(
        @raylib.Vector3::new(bx, 1.1, bz),
        0.01,
        0.5,
        0.01,
        @raylib.Color::new(200, 200, 200, a),
      )
    }
  }
}
