// 3D world rendering

///|
/// Draws the full 3D world including map, towers, enemies, and projectiles.
pub fn draw_world(game : @types.Game) -> Unit {
  let camera = game.build_camera()
  @raylib.begin_mode_3d(camera)
  game.draw_map()
  game.draw_grid_overlay()
  game.draw_path_markers()
  game.draw_towers()
  game.draw_tower_range_indicators()
  game.draw_enemies()
  game.draw_enemy_status_visuals()
  game.draw_projectiles()
  game.draw_chain_lightning_lines()
  game.draw_particles_3d()
  // Draw hover indicator in building mode
  if game.state == Building {
    game.draw_build_cursor()
  }
  // Draw selected tower highlight
  if game.selected_tower_idx >= 0 {
    game.draw_selected_tower_highlight()
  }
  @raylib.end_mode_3d()
}

///|
/// Builds a 3D camera from the current camera angle, pitch, distance, and target position.
fn @types.Game::build_camera(game : @types.Game) -> @raylib.Camera3D {
  let angle_rad = game.camera_angle * @types.pi / 180.0
  let pitch_rad = game.camera_pitch * @types.pi / 180.0
  let cos_a = @math.cosf(angle_rad)
  let sin_a = @math.sinf(angle_rad)
  let cos_p = @math.cosf(pitch_rad)
  let sin_p = @math.sinf(pitch_rad)
  let cam_x = game.camera_target_x + game.camera_dist * sin_a * cos_p
  let cam_y = game.camera_dist * sin_p
  let cam_z = game.camera_target_z + game.camera_dist * cos_a * cos_p
  @raylib.Camera3D::new(
    @raylib.Vector3::new(cam_x, cam_y, cam_z),
    @raylib.Vector3::new(game.camera_target_x, 0.0, game.camera_target_z),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    @types.camera_fovy,
    @raylib.CameraPerspective,
  )
}

///|
/// Draws all map tiles including grass, path, start, end, water, and rock terrain.
fn @types.Game::draw_map(game : @types.Game) -> Unit {
  for gy in 0..<@types.map_h {
    for gx in 0..<@types.map_w {
      let tile = @types.get_tile(game, gx, gy)
      let wx = @types.grid_to_world_x(gx)
      let wz = @types.grid_to_world_z(gy)
      let cs = @types.cell_size
      if tile == Grass {
        // Grass with subtle variation
        let shade_offset = (gx + gy) % 3 * 5
        @raylib.draw_cube(
          @raylib.Vector3::new(wx, -0.05, wz),
          cs,
          0.1,
          cs,
          @raylib.Color::new(
            55 + shade_offset,
            125 + shade_offset,
            45 + shade_offset,
            255,
          ),
        )
      } else if tile == Path || tile == Start || tile == End {
        // Path tiles - darker worn earth color
        @raylib.draw_cube(
          @raylib.Vector3::new(wx, -0.1, wz),
          cs,
          0.1,
          cs,
          @raylib.Color::new(160, 140, 100, 255),
        )
        // Path edge borders
        @raylib.draw_cube_wires(
          @raylib.Vector3::new(wx, -0.08, wz),
          cs,
          0.1,
          cs,
          @raylib.Color::new(130, 110, 80, 100),
        )
        if tile == Start {
          // Start marker - green glowing cube
          let pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.08) *
            0.1 +
            0.3
          @raylib.draw_cube(
            @raylib.Vector3::new(wx, pulse, wz),
            0.6,
            0.3,
            0.6,
            @raylib.Color::new(50, 200, 50, 200),
          )
          @raylib.draw_cube_wires(
            @raylib.Vector3::new(wx, pulse, wz),
            0.65,
            0.35,
            0.65,
            @raylib.Color::new(100, 255, 100, 150),
          )
        }
        if tile == End {
          // End marker - red glowing cube
          let pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.08) *
            0.1 +
            0.3
          @raylib.draw_cube(
            @raylib.Vector3::new(wx, pulse, wz),
            0.6,
            0.3,
            0.6,
            @raylib.Color::new(200, 50, 50, 200),
          )
          @raylib.draw_cube_wires(
            @raylib.Vector3::new(wx, pulse, wz),
            0.65,
            0.35,
            0.65,
            @raylib.Color::new(255, 100, 100, 150),
          )
        }
      } else if tile == Water {
        let water_pulse = @math.sinf(
            Float::from_int(game.frame_counter) * 0.05 + wx + wz,
          ) *
          0.02
        @raylib.draw_cube(
          @raylib.Vector3::new(wx, -0.1 + water_pulse, wz),
          cs,
          0.1,
          cs,
          @raylib.Color::new(40, 100, 200, 200),
        )
        // Water highlight shimmer
        let shimmer = @math.sinf(
            Float::from_int(game.frame_counter) * 0.1 + wx * 2.0,
          ) *
          0.5 +
          0.5
        let shimmer_alpha = (shimmer * 40.0).to_int()
        @raylib.draw_cube(
          @raylib.Vector3::new(wx, -0.05 + water_pulse, wz),
          cs * 0.8,
          0.02,
          cs * 0.8,
          @raylib.Color::new(100, 180, 255, shimmer_alpha),
        )
      } else if tile == Rock {
        @raylib.draw_cube(
          @raylib.Vector3::new(wx, 0.3, wz),
          cs * 0.9,
          0.6,
          cs * 0.9,
          @raylib.Color::new(100, 95, 85, 255),
        )
        // Rock highlight
        @raylib.draw_cube(
          @raylib.Vector3::new(wx, 0.62, wz),
          cs * 0.7,
          0.05,
          cs * 0.7,
          @raylib.Color::new(120, 115, 105, 255),
        )
      }
    }
  }
}

///|
/// Draws a subtle grid overlay on buildable grass tiles when in building mode.
fn @types.Game::draw_grid_overlay(game : @types.Game) -> Unit {
  // Draw subtle grid lines when in building mode
  if game.state != Building {
    return
  }
  for gy in 0..<@types.map_h {
    for gx in 0..<@types.map_w {
      let tile = @types.get_tile(game, gx, gy)
      if tile == Grass {
        let wx = @types.grid_to_world_x(gx)
        let wz = @types.grid_to_world_z(gy)
        @raylib.draw_cube_wires(
          @raylib.Vector3::new(wx, 0.01, wz),
          @types.cell_size,
          0.02,
          @types.cell_size,
          @raylib.Color::new(100, 150, 100, 60),
        )
      }
    }
  }
}

///|
/// Draws directional arrow markers along the enemy path to indicate movement direction.
fn @types.Game::draw_path_markers(game : @types.Game) -> Unit {
  // Draw subtle path direction indicators
  for i in 0..<(game.path_count - 1) {
    let p0 = game.path_nodes[i]
    let p1 = game.path_nodes[i + 1]
    let mx = (p0.x + p1.x) / 2.0
    let mz = (p0.z + p1.z) / 2.0
    // Direction arrow-like markers
    let dx = p1.x - p0.x
    let dz = p1.z - p0.z
    let len = @types.distance2d(p0.x, p0.z, p1.x, p1.z)
    if len > 0.1 {
      let nx = dx / len * 0.2
      let nz = dz / len * 0.2
      @raylib.draw_cube(
        @raylib.Vector3::new(mx + nx, 0.01, mz + nz),
        0.15,
        0.02,
        0.15,
        @raylib.Color::new(200, 180, 120, 150),
      )
      // Second smaller marker showing direction
      @raylib.draw_cube(
        @raylib.Vector3::new(mx + nx * 2.0, 0.01, mz + nz * 2.0),
        0.1,
        0.02,
        0.1,
        @raylib.Color::new(220, 200, 140, 120),
      )
    }
  }
}

///|
/// Draws all active towers with type-specific models, level indicators, and buff auras.
fn @types.Game::draw_towers(game : @types.Game) -> Unit {
  for tower in game.towers {
    if not(tower.active) {
      continue
    }
    let wx = @types.grid_to_world_x(tower.gx)
    let wz = @types.grid_to_world_z(tower.gy)
    let color = tower_color(tower.kind)
    // Draw tower based on type
    match tower.kind {
      Arrow => draw_arrow_tower(wx, wz, tower.level, color, game)
      Cannon => draw_cannon_tower(wx, wz, tower.level, tower.angle, color, game)
      Frost => draw_frost_tower(wx, wz, tower.level, color, game)
      Lightning => draw_lightning_tower(wx, wz, tower.level, color, game)
      Flame => draw_flame_tower(wx, wz, tower.level, color, game)
      Sniper => draw_sniper_tower(wx, wz, tower.level, tower.angle, color, game)
      Splash => draw_splash_tower(wx, wz, tower.level, color, game)
      Buff => draw_buff_tower(wx, wz, tower.level, color, game)
    }
    // Draw level indicators (rings around base)
    draw_level_indicators(wx, wz, tower.level, color)
    // Draw buff indicator if tower is buffed
    if tower.buff_damage > 0.0 ||
      tower.buff_range > 0.0 ||
      tower.buff_rate > 0.0 {
      let pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.1) * 0.1 +
        0.5
      @raylib.draw_cube(
        @raylib.Vector3::new(wx, pulse, wz),
        1.4,
        0.05,
        1.4,
        @raylib.Color::new(200, 150, 255, 60),
      )
    }
  }
}

///|
/// Draws an arrow tower with tall body, pointed cap, and arrow slit detail.
fn draw_arrow_tower(
  wx : Float,
  wz : Float,
  level : Int,
  color : @raylib.Color,
  game : @types.Game,
) -> Unit {
  ignore(game)
  // Base platform
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.25, wz),
    1.2,
    0.5,
    1.2,
    @raylib.Color::new(80, 80, 90, 255),
  )
  // Tall cylindrical tower body (approximated with narrow cube)
  let height : Float = 1.2 + Float::from_int(level - 1) * 0.2
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.5 + height / 2.0, wz),
    0.5,
    height,
    0.5,
    color,
  )
  // Pointed top (triangular cap - simulated with smaller cube rotated)
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.5 + height + 0.15, wz),
    0.3,
    0.3,
    0.3,
    @raylib.Color::new(
      (color.r.to_int() + 30).clamp(min=0, max=255),
      (color.g.to_int() + 30).clamp(min=0, max=255),
      (color.b.to_int() + 30).clamp(min=0, max=255),
      255,
    ),
  )
  // Arrow slit (dark rectangle)
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.5 + height * 0.6, wz + 0.26),
    0.08,
    0.3,
    0.02,
    @raylib.Color::new(20, 20, 30, 255),
  )
}

///|
/// Draws a cannon tower with heavy base, turret body, and rotating barrel.
fn draw_cannon_tower(
  wx : Float,
  wz : Float,
  level : Int,
  angle : Float,
  color : @raylib.Color,
  game : @types.Game,
) -> Unit {
  ignore(game)
  // Squat heavy base
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.3, wz),
    1.4,
    0.6,
    1.4,
    @raylib.Color::new(70, 70, 80, 255),
  )
  // Turret body (wider, shorter)
  let height : Float = 0.8 + Float::from_int(level - 1) * 0.15
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.6 + height / 2.0, wz),
    0.8,
    height,
    0.8,
    color,
  )
  // Barrel (extends from turret in direction of angle)
  let barrel_len : Float = 0.8 + Float::from_int(level - 1) * 0.1
  let angle_rad = angle * @types.pi / 180.0
  let bx = wx + @math.sinf(angle_rad) * barrel_len * 0.5
  let bz = wz + @math.cosf(angle_rad) * barrel_len * 0.5
  @raylib.draw_cube(
    @raylib.Vector3::new(bx, 0.6 + height, bz),
    0.2,
    0.2,
    barrel_len,
    @raylib.Color::new(60, 60, 70, 255),
  )
}

///|
/// Draws a frost tower with crystal spire, glowing tip, and orbiting ice shards.
fn draw_frost_tower(
  wx : Float,
  wz : Float,
  level : Int,
  color : @raylib.Color,
  game : @types.Game,
) -> Unit {
  // Blue crystal spire base
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.2, wz),
    1.0,
    0.4,
    1.0,
    @raylib.Color::new(60, 80, 100, 255),
  )
  // Crystal body - tall and narrow
  let height : Float = 1.5 + Float::from_int(level - 1) * 0.3
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.4 + height / 2.0, wz),
    0.4,
    height,
    0.4,
    color,
  )
  // Crystal tip
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.4 + height + 0.2, wz),
    0.2,
    0.4,
    0.2,
    @raylib.Color::new(150, 220, 255, 220),
  )
  // Floating ice shards around crystal
  let shard_angle = Float::from_int(game.frame_counter) * 0.03
  let shard_r : Float = 0.5
  for s in 0..<(level + 1) {
    let sa = shard_angle + Float::from_int(s) * 2.1
    let sx = wx + @math.cosf(sa) * shard_r
    let sz = wz + @math.sinf(sa) * shard_r
    let sy : Float = 0.8 +
      @math.sinf(shard_angle * 2.0 + Float::from_int(s)) * 0.2
    @raylib.draw_cube(
      @raylib.Vector3::new(sx, sy, sz),
      0.12,
      0.12,
      0.12,
      @raylib.Color::new(180, 220, 255, 180),
    )
    ignore(s)
  }
}

///|
/// Draws a lightning tower with metal rod, pulsing sphere tip, and flickering electric arcs.
fn draw_lightning_tower(
  wx : Float,
  wz : Float,
  level : Int,
  color : @raylib.Color,
  game : @types.Game,
) -> Unit {
  // Metal base
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.25, wz),
    1.1,
    0.5,
    1.1,
    @raylib.Color::new(90, 90, 100, 255),
  )
  // Metal rod body
  let height : Float = 1.6 + Float::from_int(level - 1) * 0.25
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.5 + height / 2.0, wz),
    0.3,
    height,
    0.3,
    color,
  )
  // Sphere tip (approximated with small cube)
  let pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.15) * 0.05 +
    0.25
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx, 0.5 + height + pulse, wz),
    0.2 + Float::from_int(level - 1) * 0.05,
    @raylib.Color::new(255, 255, 100, 220),
  )
  // Electric arcs (small cubes flickering around tip)
  if game.frame_counter % 4 < 2 {
    let arc_offset = @math.sinf(Float::from_int(game.frame_counter) * 0.5) * 0.3
    @raylib.draw_cube(
      @raylib.Vector3::new(wx + arc_offset, 0.5 + height, wz),
      0.05,
      0.3,
      0.05,
      @raylib.Color::new(255, 255, 50, 150),
    )
  }
}

///|
/// Draws a flame tower with stone brazier, animated fire effect, and level-3 fire aura ring.
fn draw_flame_tower(
  wx : Float,
  wz : Float,
  level : Int,
  color : @raylib.Color,
  game : @types.Game,
) -> Unit {
  // Stone brazier base
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.3, wz),
    1.2,
    0.6,
    1.2,
    @raylib.Color::new(80, 70, 60, 255),
  )
  // Brazier bowl (wider top)
  @raylib.draw_cube(@raylib.Vector3::new(wx, 0.7, wz), 0.9, 0.3, 0.9, color)
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.9, wz),
    1.0,
    0.1,
    1.0,
    @raylib.Color::new(100, 80, 60, 255),
  )
  // Flame effect (animated cubes)
  let flame_height : Float = 0.5 + Float::from_int(level - 1) * 0.2
  let flicker = @math.sinf(Float::from_int(game.frame_counter) * 0.2)
  let flame_y : Float = 1.0 + flame_height * 0.5 + flicker * 0.1
  // Core flame
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, flame_y, wz),
    0.3,
    flame_height,
    0.3,
    @raylib.Color::new(255, 200, 50, 200),
  )
  // Outer flame
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, flame_y - 0.1, wz),
    0.5,
    flame_height * 0.7,
    0.5,
    @raylib.Color::new(255, 100, 30, 150),
  )
  // Level 3: fire aura ring
  if level >= 3 {
    let aura_pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.08) *
      0.3 +
      0.7
    let aura_alpha = (aura_pulse * 50.0).to_int()
    @raylib.draw_circle_3d(
      @raylib.Vector3::new(wx, 0.1, wz),
      @types.range_flame * 0.6,
      @raylib.Vector3::new(1.0, 0.0, 0.0),
      90.0,
      @raylib.Color::new(255, 100, 30, aura_alpha),
    )
  }
}

///|
/// Draws a sniper tower with tall thin body, rotating barrel, and scope lens.
fn draw_sniper_tower(
  wx : Float,
  wz : Float,
  level : Int,
  angle : Float,
  color : @raylib.Color,
  game : @types.Game,
) -> Unit {
  ignore(game)
  // Tall thin base
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.2, wz),
    0.9,
    0.4,
    0.9,
    @raylib.Color::new(70, 70, 80, 255),
  )
  // Very tall body
  let height : Float = 2.0 + Float::from_int(level - 1) * 0.3
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.4 + height / 2.0, wz),
    0.35,
    height,
    0.35,
    color,
  )
  // Scope / barrel on top
  let barrel_len : Float = 0.9
  let angle_rad = angle * @types.pi / 180.0
  let bx = wx + @math.sinf(angle_rad) * barrel_len * 0.5
  let bz = wz + @math.cosf(angle_rad) * barrel_len * 0.5
  let barrel_y : Float = 0.4 + height
  @raylib.draw_cube(
    @raylib.Vector3::new(bx, barrel_y, bz),
    0.1,
    0.1,
    barrel_len,
    @raylib.Color::new(50, 50, 60, 255),
  )
  // Scope lens
  let lens_x = wx + @math.sinf(angle_rad) * barrel_len
  let lens_z = wz + @math.cosf(angle_rad) * barrel_len
  @raylib.draw_cube(
    @raylib.Vector3::new(lens_x, barrel_y, lens_z),
    0.15,
    0.15,
    0.05,
    @raylib.Color::new(200, 50, 50, 200),
  )
}

///|
/// Draws a splash tower with wide base, central body, and multiple outward-facing barrels.
fn draw_splash_tower(
  wx : Float,
  wz : Float,
  level : Int,
  color : @raylib.Color,
  game : @types.Game,
) -> Unit {
  ignore(game)
  // Wide base
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.25, wz),
    1.4,
    0.5,
    1.4,
    @raylib.Color::new(75, 75, 85, 255),
  )
  // Central body
  let height : Float = 1.0 + Float::from_int(level - 1) * 0.2
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.5 + height / 2.0, wz),
    0.7,
    height,
    0.7,
    color,
  )
  // Multiple barrels pointing outward
  let barrel_count : Int = 3 + level
  for b in 0..<barrel_count {
    let ba = Float::from_int(b) * 6.28 / Float::from_int(barrel_count)
    let bx = wx + @math.cosf(ba) * 0.5
    let bz = wz + @math.sinf(ba) * 0.5
    @raylib.draw_cube(
      @raylib.Vector3::new(bx, 0.5 + height, bz),
      0.12,
      0.15,
      0.12,
      @raylib.Color::new(60, 60, 70, 255),
    )
    ignore(b)
  }
  // Top cap
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.5 + height + 0.1, wz),
    0.9,
    0.1,
    0.9,
    @raylib.Color::new(
      (color.r.to_int() - 20).clamp(min=0, max=255),
      (color.g.to_int() - 20).clamp(min=0, max=255),
      (color.b.to_int() - 20).clamp(min=0, max=255),
      255,
    ),
  )
}

///|
/// Draws a buff tower with aura pillar, glowing orb, rotating rings, and buff range indicator.
fn draw_buff_tower(
  wx : Float,
  wz : Float,
  level : Int,
  color : @raylib.Color,
  game : @types.Game,
) -> Unit {
  // Glowing aura pillar base
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.2, wz),
    1.0,
    0.4,
    1.0,
    @raylib.Color::new(80, 60, 90, 255),
  )
  // Pillar
  let height : Float = 1.3 + Float::from_int(level - 1) * 0.25
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.4 + height / 2.0, wz),
    0.4,
    height,
    0.4,
    color,
  )
  // Glowing orb on top
  let pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.1) * 0.05 +
    0.25
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx, 0.4 + height + pulse, wz),
    0.2,
    @raylib.Color::new(200, 150, 255, 200),
  )
  // Rotating aura rings
  let ring_angle = Float::from_int(game.frame_counter) * 0.5
  let ring_alpha = ((
    @math.sinf(Float::from_int(game.frame_counter) * 0.08) * 0.3 + 0.5
  ) *
  80.0).to_int()
  @raylib.draw_circle_3d(
    @raylib.Vector3::new(wx, 0.4 + height * 0.5, wz),
    0.6,
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    ring_angle,
    @raylib.Color::new(200, 150, 255, ring_alpha),
  )
  // Buff range indicator
  let range = @types.tower_effective_range(game.towers[0])
  // Find this tower to get actual range
  for t in game.towers {
    if t.active && t.kind == Buff {
      let tx = @types.grid_to_world_x(t.gx)
      let tz = @types.grid_to_world_z(t.gy)
      if (tx - wx).abs() < 0.1 && (tz - wz).abs() < 0.1 {
        let actual_range = @types.tower_effective_range(t)
        @raylib.draw_circle_3d(
          @raylib.Vector3::new(wx, 0.05, wz),
          actual_range,
          @raylib.Vector3::new(1.0, 0.0, 0.0),
          90.0,
          @raylib.Color::new(200, 150, 255, 40),
        )
        break
      }
    }
  }
  ignore(range)
  ignore(level)
}

///|
/// Draws silver and gold base rings to indicate tower upgrade level.
fn draw_level_indicators(
  wx : Float,
  wz : Float,
  level : Int,
  color : @raylib.Color,
) -> Unit {
  if level >= 2 {
    // Silver ring at base
    @raylib.draw_cube(
      @raylib.Vector3::new(wx, 0.02, wz),
      1.4,
      0.04,
      1.4,
      @raylib.Color::new(200, 200, 210, 180),
    )
  }
  if level >= 3 {
    // Gold ring at base (slightly larger)
    @raylib.draw_cube(
      @raylib.Vector3::new(wx, 0.05, wz),
      1.5,
      0.04,
      1.5,
      @raylib.Color::new(255, 215, 0, 180),
    )
  }
  ignore(color)
}

///|
/// Draws range circles around all active towers when range display is enabled.
fn @types.Game::draw_tower_range_indicators(game : @types.Game) -> Unit {
  if not(game.show_ranges) {
    return
  }
  for i in 0..<game.towers.length() {
    let tower = game.towers[i]
    if not(tower.active) {
      continue
    }
    let wx = @types.grid_to_world_x(tower.gx)
    let wz = @types.grid_to_world_z(tower.gy)
    let range = @types.tower_effective_range(tower)
    let color = tower_color(tower.kind)
    let alpha : Int = if i == game.selected_tower_idx { 100 } else { 50 }
    @raylib.draw_circle_3d(
      @raylib.Vector3::new(wx, 0.1, wz),
      range,
      @raylib.Vector3::new(1.0, 0.0, 0.0),
      90.0,
      @raylib.Color::new(
        color.r.to_int(),
        color.g.to_int(),
        color.b.to_int(),
        alpha,
      ),
    )
  }
}

///|
/// Draws a pulsing selection highlight and range circle around the currently selected tower.
fn @types.Game::draw_selected_tower_highlight(game : @types.Game) -> Unit {
  if game.selected_tower_idx < 0 {
    return
  }
  let tower = game.towers[game.selected_tower_idx]
  if not(tower.active) {
    return
  }
  let wx = @types.grid_to_world_x(tower.gx)
  let wz = @types.grid_to_world_z(tower.gy)
  let range = @types.tower_effective_range(tower)
  let color = tower_color(tower.kind)
  // Pulsing selection ring
  let pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.1) * 0.3 + 0.7
  let alpha = (pulse * 120.0).to_int()
  @raylib.draw_circle_3d(
    @raylib.Vector3::new(wx, 0.1, wz),
    range,
    @raylib.Vector3::new(1.0, 0.0, 0.0),
    90.0,
    @raylib.Color::new(
      color.r.to_int(),
      color.g.to_int(),
      color.b.to_int(),
      alpha,
    ),
  )
  // Base highlight
  @raylib.draw_cube_wires(
    @raylib.Vector3::new(wx, 0.5, wz),
    1.5,
    1.0,
    1.5,
    @raylib.Color::new(255, 255, 255, (pulse * 80.0).to_int()),
  )
}

///|
/// Returns the display color for the given tower type `kind`.
fn tower_color(kind : @types.TowerKind) -> @raylib.Color {
  match kind {
    Arrow => @raylib.Color::new(150, 100, 50, 255)
    Cannon => @raylib.Color::new(100, 100, 100, 255)
    Frost => @raylib.Color::new(100, 180, 240, 255)
    Lightning => @raylib.Color::new(200, 200, 50, 255)
    Flame => @raylib.Color::new(220, 100, 30, 255)
    Sniper => @raylib.Color::new(150, 50, 50, 255)
    Splash => @raylib.Color::new(100, 150, 100, 255)
    Buff => @raylib.Color::new(160, 100, 200, 255)
  }
}

///|
/// Draws all active enemies with type-specific models, health bars, and shield bars.
fn @types.Game::draw_enemies(game : @types.Game) -> Unit {
  for enemy in game.enemies {
    if not(enemy.active) {
      continue
    }
    let color = enemy_color(enemy.kind)
    // Draw enemy based on type
    match enemy.kind {
      Basic => draw_basic_enemy(enemy, color)
      Fast => draw_fast_enemy(enemy, color)
      Tank => draw_tank_enemy(enemy, color)
      Flying => draw_flying_enemy(enemy, color, game)
      Boss => draw_boss_enemy(enemy, color, game)
      Healer => draw_healer_enemy(enemy, color, game)
      Swarm => draw_swarm_enemy(enemy, color)
      Shield => draw_shield_enemy(enemy, color)
      Camo => draw_camo_enemy(enemy, color)
      Splitter => draw_splitter_enemy(enemy, color)
    }
    // Health bar
    draw_enemy_health_bar(enemy)
    // Shield bar (if applicable)
    if enemy.shield_max > 0.0 {
      draw_enemy_shield_bar(enemy)
    }
  }
}

///|
/// Draws a basic enemy as a simple cube with wireframe outline.
fn draw_basic_enemy(enemy : @types.Enemy, color : @raylib.Color) -> Unit {
  let size : Float = 0.6
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, enemy.y, enemy.z),
    size,
    size,
    size,
    color,
  )
  @raylib.draw_cube_wires(
    @raylib.Vector3::new(enemy.x, enemy.y, enemy.z),
    size + 0.02,
    size + 0.02,
    size + 0.02,
    @raylib.Color::new(
      (color.r.to_int() - 40).clamp(min=0, max=255),
      (color.g.to_int() - 40).clamp(min=0, max=255),
      (color.b.to_int() - 40).clamp(min=0, max=255),
      255,
    ),
  )
}

///|
/// Draws a fast enemy as a small elongated shape with a speed trail.
fn draw_fast_enemy(enemy : @types.Enemy, color : @raylib.Color) -> Unit {
  // Small elongated shape
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, enemy.y, enemy.z),
    0.3,
    0.4,
    0.7,
    color,
  )
  // Speed trail
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, enemy.y - 0.1, enemy.z),
    0.15,
    0.15,
    0.4,
    @raylib.Color::new(
      color.r.to_int(),
      color.g.to_int(),
      color.b.to_int(),
      120,
    ),
  )
}

///|
/// Draws a tank enemy as a large heavy body with top and side armor plates.
fn draw_tank_enemy(enemy : @types.Enemy, color : @raylib.Color) -> Unit {
  let size : Float = 0.9
  // Heavy body
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, enemy.y, enemy.z),
    size,
    size * 0.8,
    size,
    color,
  )
  // Armor plates on top
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, enemy.y + size * 0.4, enemy.z),
    size * 0.8,
    0.15,
    size * 0.8,
    @raylib.Color::new(140, 130, 120, 255),
  )
  // Side armor
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x + size * 0.4, enemy.y, enemy.z),
    0.1,
    size * 0.6,
    size * 0.8,
    @raylib.Color::new(130, 120, 110, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x - size * 0.4, enemy.y, enemy.z),
    0.1,
    size * 0.6,
    size * 0.8,
    @raylib.Color::new(130, 120, 110, 255),
  )
}

///|
/// Draws a flying enemy as a sphere with animated flapping wings and a ground shadow.
fn draw_flying_enemy(
  enemy : @types.Enemy,
  color : @raylib.Color,
  game : @types.Game,
) -> Unit {
  // Main body (sphere)
  @raylib.draw_sphere(
    @raylib.Vector3::new(enemy.x, enemy.y, enemy.z),
    0.3,
    color,
  )
  // Wings (flapping)
  let flap = @math.sinf(Float::from_int(game.frame_counter) * 0.3) * 0.2
  // Left wing
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x - 0.4, enemy.y + flap, enemy.z),
    0.5,
    0.05,
    0.3,
    @raylib.Color::new(
      color.r.to_int(),
      color.g.to_int(),
      color.b.to_int(),
      200,
    ),
  )
  // Right wing
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x + 0.4, enemy.y + flap, enemy.z),
    0.5,
    0.05,
    0.3,
    @raylib.Color::new(
      color.r.to_int(),
      color.g.to_int(),
      color.b.to_int(),
      200,
    ),
  )
  // Shadow on ground
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, 0.01, enemy.z),
    0.4,
    0.02,
    0.4,
    @raylib.Color::new(0, 0, 0, 60),
  )
}

///|
/// Draws a boss enemy as a large cube with crown, crown points, and menacing aura.
fn draw_boss_enemy(
  enemy : @types.Enemy,
  color : @raylib.Color,
  game : @types.Game,
) -> Unit {
  let size : Float = 1.2
  // Large body
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, enemy.y, enemy.z),
    size,
    size,
    size,
    color,
  )
  @raylib.draw_cube_wires(
    @raylib.Vector3::new(enemy.x, enemy.y, enemy.z),
    size + 0.04,
    size + 0.04,
    size + 0.04,
    @raylib.Color::new(255, 200, 50, 200),
  )
  // Crown on top
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, enemy.y + size * 0.6, enemy.z),
    size * 0.5,
    0.15,
    size * 0.5,
    @raylib.Color::new(255, 215, 0, 255),
  )
  // Crown points
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x - 0.2, enemy.y + size * 0.7, enemy.z),
    0.08,
    0.15,
    0.08,
    @raylib.Color::new(255, 215, 0, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x + 0.2, enemy.y + size * 0.7, enemy.z),
    0.08,
    0.15,
    0.08,
    @raylib.Color::new(255, 215, 0, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, enemy.y + size * 0.75, enemy.z),
    0.08,
    0.2,
    0.08,
    @raylib.Color::new(255, 50, 50, 255),
  )
  // Menacing aura
  let aura = @math.sinf(Float::from_int(game.frame_counter) * 0.1) * 0.1 + 0.3
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, enemy.y, enemy.z),
    size + aura,
    size + aura,
    size + aura,
    @raylib.Color::new(200, 50, 200, 30),
  )
}

///|
/// Draws a healer enemy with a green cross symbol and pulsing healing aura.
fn draw_healer_enemy(
  enemy : @types.Enemy,
  color : @raylib.Color,
  game : @types.Game,
) -> Unit {
  let size : Float = 0.6
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, enemy.y, enemy.z),
    size,
    size,
    size,
    color,
  )
  // Cross symbol on top (green)
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, enemy.y + size * 0.35, enemy.z),
    0.3,
    0.05,
    0.08,
    @raylib.Color::new(50, 255, 50, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, enemy.y + size * 0.35, enemy.z),
    0.08,
    0.05,
    0.3,
    @raylib.Color::new(50, 255, 50, 255),
  )
  // Healing aura pulse
  let pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.12) * 0.5 + 0.5
  let aura_alpha = (pulse * 40.0).to_int()
  @raylib.draw_circle_3d(
    @raylib.Vector3::new(enemy.x, enemy.y, enemy.z),
    @types.healer_range * 0.3,
    @raylib.Vector3::new(1.0, 0.0, 0.0),
    90.0,
    @raylib.Color::new(50, 255, 50, aura_alpha),
  )
}

///|
/// Draws a swarm enemy as a very small cube.
fn draw_swarm_enemy(enemy : @types.Enemy, color : @raylib.Color) -> Unit {
  // Very small cube
  let size : Float = 0.3
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, enemy.y, enemy.z),
    size,
    size,
    size,
    color,
  )
}

///|
/// Draws a shield enemy with a body cube and a translucent shield bubble when shields are active.
fn draw_shield_enemy(enemy : @types.Enemy, color : @raylib.Color) -> Unit {
  let size : Float = 0.7
  // Body
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, enemy.y, enemy.z),
    size,
    size,
    size,
    color,
  )
  // Shield bubble
  if enemy.shield_hp > 0.0 {
    let shield_pct = enemy.shield_hp / enemy.shield_max
    let shield_alpha = (shield_pct * 100.0).to_int()
    @raylib.draw_sphere(
      @raylib.Vector3::new(enemy.x, enemy.y, enemy.z),
      size * 0.7,
      @raylib.Color::new(100, 150, 255, shield_alpha),
    )
  }
}

///|
/// Draws a camo enemy as a semi-transparent cube with a stealth shimmer wireframe.
fn draw_camo_enemy(enemy : @types.Enemy, color : @raylib.Color) -> Unit {
  let size : Float = 0.5
  // Semi-transparent body
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, enemy.y, enemy.z),
    size,
    size,
    size,
    @raylib.Color::new(
      color.r.to_int(),
      color.g.to_int(),
      color.b.to_int(),
      140,
    ),
  )
  // Stealth shimmer
  @raylib.draw_cube_wires(
    @raylib.Vector3::new(enemy.x, enemy.y, enemy.z),
    size + 0.05,
    size + 0.05,
    size + 0.05,
    @raylib.Color::new(200, 200, 200, 80),
  )
}

///|
/// Draws a splitter enemy as a cube with visible crack lines indicating it will split on death.
fn draw_splitter_enemy(enemy : @types.Enemy, color : @raylib.Color) -> Unit {
  let size : Float = 0.7
  // Cracked body
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, enemy.y, enemy.z),
    size,
    size,
    size,
    color,
  )
  // Crack lines
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, enemy.y, enemy.z),
    size * 0.02,
    size * 1.05,
    size * 1.05,
    @raylib.Color::new(30, 30, 30, 200),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, enemy.y, enemy.z),
    size * 1.05,
    size * 0.02,
    size * 1.05,
    @raylib.Color::new(30, 30, 30, 200),
  )
}

///|
/// Draws a color-coded health bar above the enemy that changes from green to yellow to red.
fn draw_enemy_health_bar(enemy : @types.Enemy) -> Unit {
  let size : Float = if enemy.is_boss {
    1.2
  } else if enemy.kind == Tank {
    0.9
  } else if enemy.kind == Swarm {
    0.3
  } else {
    0.6
  }
  let hp_pct = enemy.hp / enemy.max_hp
  let bar_w = size * @types.health_bar_width
  let bar_y = enemy.y + size * 0.8
  // Background
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, bar_y, enemy.z),
    bar_w,
    @types.health_bar_height,
    0.15,
    @raylib.Color::new(80, 0, 0, 200),
  )
  // Health fill
  let bar_color = if hp_pct > 0.6 {
    @raylib.Color::new(0, 200, 0, 200)
  } else if hp_pct > 0.3 {
    @raylib.Color::new(255, 200, 0, 200)
  } else {
    @raylib.Color::new(255, 50, 0, 200)
  }
  if hp_pct > 0.0 {
    @raylib.draw_cube(
      @raylib.Vector3::new(
        enemy.x - bar_w * (1.0 - hp_pct) / 2.0,
        bar_y,
        enemy.z,
      ),
      bar_w * hp_pct,
      @types.health_bar_height + 0.02,
      0.15,
      bar_color,
    )
  }
}

///|
/// Draws a blue shield bar above the enemy health bar when shields are present.
fn draw_enemy_shield_bar(enemy : @types.Enemy) -> Unit {
  if enemy.shield_max <= 0.0 {
    return
  }
  let size : Float = 0.7
  let shield_pct = enemy.shield_hp / enemy.shield_max
  let bar_w = size * @types.health_bar_width
  let bar_y = enemy.y + size * 0.95
  if shield_pct > 0.0 {
    @raylib.draw_cube(
      @raylib.Vector3::new(
        enemy.x - bar_w * (1.0 - shield_pct) / 2.0,
        bar_y,
        enemy.z,
      ),
      bar_w * shield_pct,
      0.05,
      0.12,
      @raylib.Color::new(100, 150, 255, 200),
    )
  }
}

///|
/// Draws visual indicators for active status effects including slow, burn, stun, and armor break.
fn @types.Game::draw_enemy_status_visuals(game : @types.Game) -> Unit {
  for enemy in game.enemies {
    if not(enemy.active) {
      continue
    }
    let size : Float = if enemy.is_boss {
      1.2
    } else if enemy.kind == Tank {
      0.9
    } else {
      0.6
    }
    // Slow indicator (ice crystals)
    if enemy.slow_timer > 0.0 {
      @raylib.draw_cube(
        @raylib.Vector3::new(enemy.x, enemy.y + size * 0.5, enemy.z),
        size * 0.3,
        size * 0.3,
        size * 0.3,
        @raylib.Color::new(100, 180, 255, 150),
      )
      // Additional ice crystals
      @raylib.draw_cube(
        @raylib.Vector3::new(
          enemy.x + size * 0.3,
          enemy.y + size * 0.2,
          enemy.z,
        ),
        0.1,
        0.15,
        0.1,
        @raylib.Color::new(150, 210, 255, 130),
      )
    }
    // Burn indicator (fire particles around)
    if enemy.burn_timer > 0.0 {
      let flicker = @math.sinf(Float::from_int(game.frame_counter) * 0.3)
      @raylib.draw_cube(
        @raylib.Vector3::new(
          enemy.x,
          enemy.y + size * 0.3 + flicker * 0.1,
          enemy.z,
        ),
        size * 0.4,
        size * 0.4,
        size * 0.4,
        @raylib.Color::new(255, 100, 30, 100),
      )
    }
    // Stun indicator (stars)
    if enemy.stun_timer > 0.0 {
      let star_angle = Float::from_int(game.frame_counter) * 0.1
      for s in 0..<3 {
        let sa = star_angle + Float::from_int(s) * 2.1
        let sx = enemy.x + @math.cosf(sa) * 0.4
        let sz = enemy.z + @math.sinf(sa) * 0.4
        @raylib.draw_cube(
          @raylib.Vector3::new(sx, enemy.y + size * 0.6, sz),
          0.1,
          0.1,
          0.1,
          @raylib.Color::new(255, 255, 0, 200),
        )
        ignore(s)
      }
    }
    // Armor break indicator
    if enemy.armor_break_timer > 0.0 {
      @raylib.draw_cube_wires(
        @raylib.Vector3::new(enemy.x, enemy.y, enemy.z),
        size + 0.1,
        size + 0.1,
        size + 0.1,
        @raylib.Color::new(255, 100, 0, 150),
      )
    }
  }
}

///|
/// Returns the display color for the given enemy type `kind`.
fn enemy_color(kind : @types.EnemyKind) -> @raylib.Color {
  match kind {
    Basic => @raylib.Color::new(180, 60, 60, 255)
    Fast => @raylib.Color::new(60, 180, 60, 255)
    Tank => @raylib.Color::new(100, 80, 150, 255)
    Flying => @raylib.Color::new(180, 180, 60, 255)
    Boss => @raylib.Color::new(200, 50, 200, 255)
    Healer => @raylib.Color::new(50, 180, 50, 255)
    Swarm => @raylib.Color::new(180, 140, 60, 255)
    Shield => @raylib.Color::new(60, 100, 200, 255)
    Camo => @raylib.Color::new(140, 140, 140, 255)
    Splitter => @raylib.Color::new(160, 80, 120, 255)
  }
}

///|
/// Draws all active projectiles with type-specific shapes and visual effects.
fn @types.Game::draw_projectiles(game : @types.Game) -> Unit {
  for proj in game.projectiles {
    if not(proj.active) {
      continue
    }
    match proj.kind {
      Arrow =>
        // Small fast bullet
        @raylib.draw_cube(
          @raylib.Vector3::new(proj.x, proj.y, proj.z),
          0.08,
          0.08,
          0.2,
          @raylib.Color::new(200, 180, 100, 255),
        )
      Cannon =>
        // Cannonball
        @raylib.draw_sphere(
          @raylib.Vector3::new(proj.x, proj.y, proj.z),
          0.18,
          @raylib.Color::new(50, 50, 50, 255),
        )
      Frost =>
        // Ice shard
        @raylib.draw_cube(
          @raylib.Vector3::new(proj.x, proj.y, proj.z),
          0.12,
          0.2,
          0.12,
          @raylib.Color::new(150, 220, 255, 230),
        )
      Lightning => {
        // Lightning bolt (bright yellow)
        @raylib.draw_cube(
          @raylib.Vector3::new(proj.x, proj.y, proj.z),
          0.06,
          0.3,
          0.06,
          @raylib.Color::new(255, 255, 100, 250),
        )
        // Glow
        @raylib.draw_cube(
          @raylib.Vector3::new(proj.x, proj.y, proj.z),
          0.15,
          0.15,
          0.15,
          @raylib.Color::new(255, 255, 50, 80),
        )
      }
      Flame => {
        // Fireball
        @raylib.draw_sphere(
          @raylib.Vector3::new(proj.x, proj.y, proj.z),
          0.12,
          @raylib.Color::new(255, 150, 30, 240),
        )
        // Fire trail
        @raylib.draw_sphere(
          @raylib.Vector3::new(proj.x, proj.y + 0.05, proj.z),
          0.08,
          @raylib.Color::new(255, 80, 10, 180),
        )
      }
      Sniper => {
        // Sniper round (thin and fast)
        let color = if proj.is_crit {
          @raylib.Color::new(255, 50, 50, 255)
        } else {
          @raylib.Color::new(200, 200, 50, 255)
        }
        @raylib.draw_cube(
          @raylib.Vector3::new(proj.x, proj.y, proj.z),
          0.05,
          0.05,
          0.25,
          color,
        )
      }
      Splash =>
        // Splash bomb
        @raylib.draw_sphere(
          @raylib.Vector3::new(proj.x, proj.y, proj.z),
          0.15,
          @raylib.Color::new(100, 180, 100, 255),
        )
      _ => {
        // Default
        let color = tower_color(proj.kind)
        @raylib.draw_sphere(
          @raylib.Vector3::new(proj.x, proj.y, proj.z),
          0.15,
          color,
        )
      }
    }
  }
}

///|
/// Draws chain lightning visual lines as interpolated cube segments between source and target.
fn @types.Game::draw_chain_lightning_lines(game : @types.Game) -> Unit {
  for cl in game.chain_lines {
    if not(cl.active) {
      continue
    }
    let alpha = (cl.life / 0.3 * 255.0).to_int()
    let a = alpha.clamp(min=0, max=255)
    // Draw lightning line as series of small cubes
    let steps = 5
    for s in 0..<steps {
      let t = Float::from_int(s) / Float::from_int(steps)
      let lx = @types.lerpf(cl.x1, cl.x2, t)
      let ly = @types.lerpf(cl.y1, cl.y2, t)
      let lz = @types.lerpf(cl.z1, cl.z2, t)
      @raylib.draw_cube(
        @raylib.Vector3::new(lx, ly, lz),
        0.06,
        0.06,
        0.06,
        @raylib.Color::new(255, 255, 100, a),
      )
      ignore(s)
    }
  }
}

///|
/// Draws all active 3D particles as small cubes with lifetime-based alpha fade.
fn @types.Game::draw_particles_3d(game : @types.Game) -> Unit {
  for p in game.particles {
    if not(p.active) {
      continue
    }
    let alpha = (p.life / p.max_life * 255.0).to_int()
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
/// Draws the pulsing build cursor at the hovered grid cell with validity color and range preview.
fn @types.Game::draw_build_cursor(game : @types.Game) -> Unit {
  let wx = @types.grid_to_world_x(game.hover_gx)
  let wz = @types.grid_to_world_z(game.hover_gy)
  let pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.1) * 0.15 +
    0.85
  let alpha_f : Float = 120.0 * pulse
  let alpha = alpha_f.to_int()
  let color = if game.hover_valid {
    @raylib.Color::new(0, 200, 0, alpha)
  } else {
    @raylib.Color::new(200, 0, 0, alpha)
  }
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.5, wz),
    @types.cell_size * 0.9,
    1.0,
    @types.cell_size * 0.9,
    color,
  )
  @raylib.draw_cube_wires(
    @raylib.Vector3::new(wx, 0.5, wz),
    @types.cell_size * 0.92,
    1.02,
    @types.cell_size * 0.92,
    @raylib.Color::new(255, 255, 255, 100),
  )
  // Show range circle
  let range = @types.tower_range(game.selected_tower_type)
  @raylib.draw_circle_3d(
    @raylib.Vector3::new(wx, 0.1, wz),
    range,
    @raylib.Vector3::new(1.0, 0.0, 0.0),
    90.0,
    @raylib.Color::new(200, 200, 0, 100),
  )
}
