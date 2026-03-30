// 3D world rendering

///|
/// Draws the 3D naval battlefield, including ocean, islands, ships, shots, and effects.
pub fn draw_world(game : @types.Game) -> Unit {
  let camera = game.build_camera()
  @raylib.begin_mode_3d(camera)
  game.draw_ocean()
  game.draw_islands()
  game.draw_wakes()
  game.draw_player_ship()
  game.draw_enemy_ships()
  game.draw_fleet_ships()
  game.draw_convoy_ships()
  game.draw_cannonballs()
  game.draw_particles_3d()
  game.draw_wind_indicator()
  @raylib.end_mode_3d()
}

///|
fn @types.Game::build_camera(game : @types.Game) -> @raylib.Camera3D {
  let ship = game.player
  let cam_angle = ship.heading + @types.pi + game.camera_offset_angle
  let cos_a = @math.cosf(cam_angle)
  let sin_a = @math.sinf(cam_angle)
  let cam_x = ship.x + sin_a * game.camera_dist
  let cam_y = @types.camera_height
  let cam_z = ship.z + cos_a * game.camera_dist
  @raylib.Camera3D::new(
    @raylib.Vector3::new(cam_x, cam_y, cam_z),
    @raylib.Vector3::new(ship.x, 1.0, ship.z),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    @types.camera_fovy,
    @raylib.CameraPerspective,
  )
}

///|
fn @types.Game::draw_ocean(game : @types.Game) -> Unit {
  let size = @types.ocean_size
  @raylib.draw_plane(
    @raylib.Vector3::new(0.0, -0.1, 0.0),
    @raylib.Vector2::new(size, size),
    @raylib.Color::new(20, 60, 120, 255),
  )
  let time = Float::from_int(game.frame_counter) * 0.03
  for i in 0..<20 {
    let offset = Float::from_int(i) * 10.0 - 95.0
    let wave_h = @math.sinf(time + Float::from_int(i) * 0.7) * 0.15
    let alpha : Int = 40 +
      (@math.sinf(time + Float::from_int(i) * 0.5) * 20.0).to_int()
    let a = alpha.clamp(min=20, max=80)
    @raylib.draw_cube(
      @raylib.Vector3::new(0.0, wave_h, offset),
      size,
      0.05,
      3.0,
      @raylib.Color::new(60, 120, 180, a),
    )
  }
  for i in 0..<15 {
    let offset = Float::from_int(i) * 13.0 - 91.0
    let wave_h = @math.sinf(time * 0.8 + Float::from_int(i) * 0.9) * 0.1
    @raylib.draw_cube(
      @raylib.Vector3::new(offset, wave_h + 0.02, 0.0),
      3.0,
      0.04,
      size,
      @raylib.Color::new(40, 100, 160, 35),
    )
  }
  // Sun reflection highlight
  let sun_x = @math.sinf(time * 0.1) * 20.0
  let sun_z = @math.cosf(time * 0.1) * 20.0
  for i in 0..<8 {
    let t = Float::from_int(i) / 8.0
    let flicker = @math.sinf(time * 5.0 + Float::from_int(i) * 1.5) * 0.5 + 0.5
    let ref_alpha = (40.0 + flicker.to_double() * 40.0).to_int()
    let rx = game.player.x + sun_x * (0.5 + t * 2.0)
    let rz = game.player.z + sun_z * (0.5 + t * 2.0)
    let ry = @math.sinf(time + Float::from_int(i) * 0.8) * 0.12 + 0.05
    @raylib.draw_cube(
      @raylib.Vector3::new(rx, ry, rz),
      1.5 + t * 2.0,
      0.03,
      1.5 + t * 2.0,
      @raylib.Color::new(255, 255, 200, ref_alpha),
    )
  }
  // Foam around islands
  for i in 0..<game.island_count {
    let island = game.islands[i]
    if !island.active {
      continue
    }
    let foam_r = island.radius * 1.6
    let foam_segments = 12
    for s in 0..<foam_segments {
      let angle = Float::from_int(s) * 6.28318 / Float::from_int(foam_segments)
      let wobble = @math.sinf(time * 2.0 + angle * 3.0) * 0.3
      let fx = island.x + @math.sinf(angle) * (foam_r + wobble)
      let fz = island.z + @math.cosf(angle) * (foam_r + wobble)
      let fy = @math.sinf(time + angle * 2.0) * 0.08 + 0.05
      let fa = (120.0 + @math.sinf(time * 3.0 + angle * 4.0).to_double() * 40.0).to_int()
      @raylib.draw_cube(
        @raylib.Vector3::new(fx, fy, fz),
        1.2,
        0.06,
        1.2,
        @raylib.Color::new(200, 220, 255, fa),
      )
    }
  }
}

///|
fn @types.Game::draw_islands(game : @types.Game) -> Unit {
  for i in 0..<game.island_count {
    let island = game.islands[i]
    if !island.active {
      continue
    }
    let base_color = @raylib.Color::new(100, 85, 60, 255)
    let green_color = @raylib.Color::new(50, 120, 40, 255)
    let dark_color = @raylib.Color::new(70, 60, 45, 255)
    @raylib.draw_cube(
      @raylib.Vector3::new(island.x, island.height * 0.5, island.z),
      island.radius * 1.2,
      island.height,
      island.radius * 1.2,
      base_color,
    )
    for b in 0..<island.blocks {
      let angle = Float::from_int(b) * 6.28318 / Float::from_int(island.blocks)
      let bx = island.x + @math.sinf(angle) * island.radius * 0.5
      let bz = island.z + @math.cosf(angle) * island.radius * 0.5
      let bh = island.height * 0.6
      let bw = island.radius * 0.6
      @raylib.draw_cube(
        @raylib.Vector3::new(bx, bh * 0.5, bz),
        bw,
        bh,
        bw,
        dark_color,
      )
    }
    @raylib.draw_cube(
      @raylib.Vector3::new(island.x, island.height + 0.2, island.z),
      island.radius * 1.0,
      0.4,
      island.radius * 1.0,
      green_color,
    )
    @raylib.draw_cylinder(
      @raylib.Vector3::new(island.x, 0.05, island.z),
      island.radius * 1.4,
      island.radius * 1.5,
      0.1,
      16,
      @raylib.Color::new(200, 180, 130, 200),
    )
  }
}

///|
fn @types.Game::draw_player_ship(game : @types.Game) -> Unit {
  let ship = game.player
  let sin_h = @math.sinf(ship.heading)
  let cos_h = @math.cosf(ship.heading)
  let bob_y = @math.sinf(ship.bob_phase) * 0.15
  let hp_ratio = ship.hull_hp / ship.max_hp
  let damage_list : Float = (1.0 - hp_ratio) * 0.1
  let roll_tilt = ship.roll_angle + damage_list
  let base_y : Float = 0.5 + bob_y
  let hull_color = @raylib.Color::new(120, 80, 40, 255)
  @raylib.draw_cube(
    @raylib.Vector3::new(ship.x, base_y, ship.z),
    1.8,
    1.0,
    4.0,
    hull_color,
  )
  let bow_x = ship.x + sin_h * 2.5
  let bow_z = ship.z + cos_h * 2.5
  @raylib.draw_cube(
    @raylib.Vector3::new(bow_x, base_y, bow_z),
    1.0,
    0.8,
    1.5,
    @raylib.Color::new(100, 70, 35, 255),
  )
  let stern_x = ship.x - sin_h * 2.2
  let stern_z = ship.z - cos_h * 2.2
  @raylib.draw_cube(
    @raylib.Vector3::new(stern_x, base_y + 0.2, stern_z),
    1.6,
    1.2,
    1.2,
    @raylib.Color::new(110, 75, 40, 255),
  )
  let mast_lean_x = @math.cosf(ship.heading) * roll_tilt * 3.0
  let mast_lean_z = -@math.sinf(ship.heading) * roll_tilt * 3.0
  @raylib.draw_cylinder(
    @raylib.Vector3::new(ship.x, base_y + 0.5, ship.z),
    0.1,
    0.1,
    4.0,
    6,
    @raylib.Color::new(80, 60, 30, 255),
  )
  if ship.sail_hp > 0.0 {
    let sail_alpha : Int = (ship.sail_hp / ship.max_hp * 200.0).to_int() + 55
    let sa = sail_alpha.clamp(min=55, max=255)
    @raylib.draw_cube(
      @raylib.Vector3::new(
        ship.x + mast_lean_x * 0.5,
        base_y + 2.5,
        ship.z + mast_lean_z * 0.5,
      ),
      2.5 * ship.sail_amount,
      2.0,
      0.1,
      @raylib.Color::new(240, 230, 200, sa),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(
        ship.x + mast_lean_x * 0.8,
        base_y + 4.0,
        ship.z + mast_lean_z * 0.8,
      ),
      1.8 * ship.sail_amount,
      1.0,
      0.1,
      @raylib.Color::new(240, 230, 200, sa),
    )
  }
  let left_x = ship.x + @math.cosf(ship.heading) * 1.2
  let left_z = ship.z - @math.sinf(ship.heading) * 1.2
  let right_x = ship.x - @math.cosf(ship.heading) * 1.2
  let right_z = ship.z + @math.sinf(ship.heading) * 1.2
  let cannon_color = @raylib.Color::new(50, 50, 55, 255)
  @raylib.draw_cube(
    @raylib.Vector3::new(left_x, base_y + 0.1, left_z),
    0.3,
    0.3,
    0.5,
    cannon_color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(right_x, base_y + 0.1, right_z),
    0.3,
    0.3,
    0.5,
    cannon_color,
  )
  // Cannon fire flash - port
  if ship.reload_left > ship.reload_time * 0.85 {
    let flash_perp_x = @math.cosf(ship.heading)
    let flash_perp_z = -@math.sinf(ship.heading)
    for fi in 0..<3 {
      let foffset = (Float::from_int(fi) - 1.0) * 1.5
      let fx = ship.x + flash_perp_x * 1.5 + sin_h * foffset
      let fz = ship.z + flash_perp_z * 1.5 + cos_h * foffset
      @raylib.draw_cube(
        @raylib.Vector3::new(fx, base_y + 0.3, fz),
        0.5,
        0.4,
        0.5,
        @raylib.Color::new(255, 200, 50, 200),
      )
    }
  }
  // Cannon fire flash - starboard
  if ship.reload_right > ship.reload_time * 0.85 {
    let flash_perp_x = -@math.cosf(ship.heading)
    let flash_perp_z = @math.sinf(ship.heading)
    for fi in 0..<3 {
      let foffset = (Float::from_int(fi) - 1.0) * 1.5
      let fx = ship.x + flash_perp_x * 1.5 + sin_h * foffset
      let fz = ship.z + flash_perp_z * 1.5 + cos_h * foffset
      @raylib.draw_cube(
        @raylib.Vector3::new(fx, base_y + 0.3, fz),
        0.5,
        0.4,
        0.5,
        @raylib.Color::new(255, 200, 50, 200),
      )
    }
  }
  if ship.reload_left > 0.0 {
    @raylib.draw_cube(
      @raylib.Vector3::new(left_x, base_y + 0.7, left_z),
      0.2,
      0.2,
      0.2,
      @raylib.Color::new(255, 100, 100, 200),
    )
  }
  if ship.reload_right > 0.0 {
    @raylib.draw_cube(
      @raylib.Vector3::new(right_x, base_y + 0.7, right_z),
      0.2,
      0.2,
      0.2,
      @raylib.Color::new(255, 100, 100, 200),
    )
  }
  // Damage smoke below 50% HP
  if hp_ratio < 0.5 {
    let smoke_intensity : Float = (1.0 - hp_ratio * 2.0) * 0.6
    let ptime = Float::from_int(game.frame_counter) * 0.05
    for si in 0..<3 {
      let so = Float::from_int(si) * 1.2
      let sy = base_y + 1.5 + @math.sinf(ptime + so) * 0.5
      let sa = (smoke_intensity * 120.0).to_int()
      @raylib.draw_cube(
        @raylib.Vector3::new(
          ship.x + @math.sinf(ptime * 0.7 + so) * 0.4,
          sy,
          ship.z + @math.cosf(ptime * 0.9 + so) * 0.4,
        ),
        0.6 + so * 0.2,
        0.5,
        0.6 + so * 0.2,
        @raylib.Color::new(80, 80, 90, sa),
      )
    }
  }
  // Fire below 25% HP
  if hp_ratio < 0.25 {
    let ftime = Float::from_int(game.frame_counter) * 0.08
    for fi in 0..<2 {
      let fo = Float::from_int(fi) * 2.1
      let fy = base_y + 0.8 + @math.sinf(ftime * 3.0 + fo) * 0.3
      let fa = (180.0 + @math.sinf(ftime * 5.0 + fo).to_double() * 75.0).to_int()
      @raylib.draw_cube(
        @raylib.Vector3::new(
          ship.x + @math.sinf(ftime + fo) * 0.6,
          fy,
          ship.z + @math.cosf(ftime * 1.3 + fo) * 0.6,
        ),
        0.35,
        0.4,
        0.35,
        @raylib.Color::new(255, 150, 30, fa),
      )
    }
  }
  @raylib.draw_cube(
    @raylib.Vector3::new(
      ship.x + mast_lean_x,
      base_y + 4.7,
      ship.z + mast_lean_z,
    ),
    0.6,
    0.3,
    0.05,
    @raylib.Color::new(200, 50, 50, 255),
  )
  ignore(sin_h)
  ignore(cos_h)
}

///|
fn @types.Game::draw_enemy_ships(game : @types.Game) -> Unit {
  for enemy in game.enemies {
    if !enemy.active {
      continue
    }
    let sin_h = @math.sinf(enemy.heading)
    let cos_h = @math.cosf(enemy.heading)
    let bob_y = @math.sinf(enemy.bob_phase) * @types.bob_amplitude
    let roll_lean = enemy.roll_angle
    let ehp_ratio = enemy.hull_hp / enemy.max_hp
    let damage_lean : Float = (1.0 - ehp_ratio) * 0.12
    let base_y : Float = 0.4 + bob_y
    let hull_color = @raylib.Color::new(60, 50, 45, 255)
    @raylib.draw_cube(
      @raylib.Vector3::new(enemy.x, base_y, enemy.z),
      1.5,
      0.8,
      3.5,
      hull_color,
    )
    let bow_x = enemy.x + sin_h * 2.0
    let bow_z = enemy.z + cos_h * 2.0
    @raylib.draw_cube(
      @raylib.Vector3::new(bow_x, base_y, bow_z),
      0.8,
      0.7,
      1.2,
      @raylib.Color::new(50, 40, 35, 255),
    )
    let mast_lean_x = @math.cosf(enemy.heading) *
      (roll_lean + damage_lean) *
      2.5
    let mast_lean_z = -@math.sinf(enemy.heading) *
      (roll_lean + damage_lean) *
      2.5
    @raylib.draw_cylinder(
      @raylib.Vector3::new(enemy.x, base_y + 0.4, enemy.z),
      0.08,
      0.08,
      3.0,
      6,
      @raylib.Color::new(70, 55, 30, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(
        enemy.x + mast_lean_x * 0.5,
        base_y + 2.1,
        enemy.z + mast_lean_z * 0.5,
      ),
      2.0,
      1.5,
      0.08,
      @raylib.Color::new(40, 40, 45, 230),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(
        enemy.x + mast_lean_x,
        base_y + 3.6,
        enemy.z + mast_lean_z,
      ),
      0.5,
      0.3,
      0.04,
      @raylib.Color::new(30, 30, 30, 255),
    )
    // Cannon fire flash
    if enemy.broadside_cooldown > enemy.fire_rate * 0.8 {
      let flash_side_x = @math.cosf(enemy.heading)
      let flash_side_z = -@math.sinf(enemy.heading)
      for fi in 0..<2 {
        let foffset = (Float::from_int(fi) - 0.5) * 1.5
        let fx = enemy.x + flash_side_x * 1.4 + sin_h * foffset
        let fz = enemy.z + flash_side_z * 1.4 + cos_h * foffset
        @raylib.draw_cube(
          @raylib.Vector3::new(fx, base_y + 0.2, fz),
          0.4,
          0.35,
          0.4,
          @raylib.Color::new(255, 180, 40, 180),
        )
      }
    }
    // Damage smoke below 50% HP
    if ehp_ratio < 0.5 {
      let etime = Float::from_int(game.frame_counter) * 0.05
      let smoke_int : Float = (1.0 - ehp_ratio * 2.0) * 0.5
      for si in 0..<2 {
        let so = Float::from_int(si) * 1.5
        let sy = base_y + 1.5 + @math.sinf(etime + so) * 0.4
        let sa = (smoke_int * 100.0).to_int()
        @raylib.draw_cube(
          @raylib.Vector3::new(
            enemy.x + @math.sinf(etime * 0.6 + so) * 0.3,
            sy,
            enemy.z + @math.cosf(etime * 0.8 + so) * 0.3,
          ),
          0.5 + so * 0.15,
          0.4,
          0.5 + so * 0.15,
          @raylib.Color::new(70, 70, 80, sa),
        )
      }
    }
    // Fire below 25% HP
    if ehp_ratio < 0.25 {
      let etime = Float::from_int(game.frame_counter) * 0.08
      let fy = base_y + 0.7 + @math.sinf(etime * 4.0) * 0.25
      let fa = (160.0 + @math.sinf(etime * 6.0).to_double() * 60.0).to_int()
      @raylib.draw_cube(
        @raylib.Vector3::new(
          enemy.x + @math.sinf(etime * 1.5) * 0.4,
          fy,
          enemy.z + @math.cosf(etime * 1.8) * 0.4,
        ),
        0.3,
        0.35,
        0.3,
        @raylib.Color::new(255, 130, 20, fa),
      )
    }
    let hp_pct = ehp_ratio
    let bar_w : Float = 2.5
    let bar_y : Float = base_y + 4.4
    @raylib.draw_cube(
      @raylib.Vector3::new(enemy.x, bar_y, enemy.z),
      bar_w,
      0.1,
      0.2,
      @raylib.Color::new(80, 0, 0, 200),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(
        enemy.x - bar_w * (1.0 - hp_pct) / 2.0,
        bar_y + 0.01,
        enemy.z,
      ),
      bar_w * hp_pct,
      0.12,
      0.2,
      @raylib.Color::new(0, 200, 0, 220),
    )
    let indicator_color = match enemy.ai_state {
      Patrol => @raylib.Color::new(100, 100, 255, 150)
      Chase => @raylib.Color::new(255, 255, 100, 150)
      _ => @raylib.Color::new(255, 100, 100, 150)
    }
    @raylib.draw_sphere(
      @raylib.Vector3::new(enemy.x, bar_y + 0.4, enemy.z),
      0.15,
      indicator_color,
    )
    ignore(sin_h)
    ignore(cos_h)
  }
}

///|
fn @types.Game::draw_cannonballs(game : @types.Game) -> Unit {
  for cb in game.cannonballs {
    if !cb.active {
      continue
    }
    let color = if cb.from_player {
      @raylib.Color::new(40, 40, 40, 255)
    } else {
      @raylib.Color::new(80, 20, 20, 255)
    }
    @raylib.draw_sphere(@raylib.Vector3::new(cb.x, cb.y, cb.z), 0.2, color)
    @raylib.draw_sphere(
      @raylib.Vector3::new(
        cb.x - cb.vx * 0.02,
        cb.y - cb.vy * 0.02,
        cb.z - cb.vz * 0.02,
      ),
      0.1,
      @raylib.Color::new(100, 100, 100, 120),
    )
  }
}

///|
fn @types.Game::draw_particles_3d(game : @types.Game) -> Unit {
  for p in game.particles {
    if !p.active {
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
/// Draws wake trails behind moving ships as fading V-shapes on the water.
fn @types.Game::draw_wakes(game : @types.Game) -> Unit {
  for w in game.wakes {
    if !w.active {
      continue
    }
    let age_ratio = w.age / w.max_age
    let wake_fade : Float = (1.0 - age_ratio) * 160.0
    let a = wake_fade.to_int().clamp(min=0, max=160)
    let half_w = w.width * 0.5
    let sin_h = @math.sinf(w.heading)
    let cos_h = @math.cosf(w.heading)
    let cx = w.x
    let cz = w.z
    let perp_x = @math.cosf(w.heading)
    let perp_z = -@math.sinf(w.heading)
    let tail_x = cx - sin_h * (half_w * 1.5 + age_ratio * 1.0)
    let tail_z = cz - cos_h * (half_w * 1.5 + age_ratio * 1.0)
    let left_x = cx + perp_x * half_w
    let left_z = cz + perp_z * half_w
    let right_x = cx - perp_x * half_w
    let right_z = cz - perp_z * half_w
    let wake_y : Float = 0.02
    let wake_color = @raylib.Color::new(180, 210, 240, a)
    @raylib.draw_triangle_3d(
      @raylib.Vector3::new(left_x, wake_y, left_z),
      @raylib.Vector3::new(tail_x, wake_y, tail_z),
      @raylib.Vector3::new(right_x, wake_y, right_z),
      wake_color,
    )
    @raylib.draw_triangle_3d(
      @raylib.Vector3::new(right_x, wake_y, right_z),
      @raylib.Vector3::new(tail_x, wake_y, tail_z),
      @raylib.Vector3::new(left_x, wake_y, left_z),
      wake_color,
    )
  }
}

///|
/// Draws allied fleet ships with blue/green color and flag marker.
fn @types.Game::draw_fleet_ships(game : @types.Game) -> Unit {
  for fs in game.fleet_ships {
    if !fs.active {
      continue
    }
    let sin_h = @math.sinf(fs.heading)
    let cos_h = @math.cosf(fs.heading)
    let bob_y = @math.sinf(fs.bob_phase) * @types.bob_amplitude
    let base_y : Float = 0.4 + bob_y
    @raylib.draw_cube(
      @raylib.Vector3::new(fs.x, base_y, fs.z),
      fs.ship_width,
      0.8,
      fs.ship_length,
      @raylib.Color::new(40, 80, 100, 255),
    )
    let bow_x = fs.x + sin_h * fs.ship_length * 0.6
    let bow_z = fs.z + cos_h * fs.ship_length * 0.6
    @raylib.draw_cube(
      @raylib.Vector3::new(bow_x, base_y, bow_z),
      fs.ship_width * 0.6,
      0.7,
      fs.ship_length * 0.3,
      @raylib.Color::new(30, 70, 90, 255),
    )
    @raylib.draw_cylinder(
      @raylib.Vector3::new(fs.x, base_y + 0.4, fs.z),
      0.08,
      0.08,
      2.8,
      6,
      @raylib.Color::new(70, 55, 30, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(fs.x, base_y + 2.0, fs.z),
      1.8 * fs.sail_amount,
      1.3,
      0.08,
      @raylib.Color::new(230, 230, 220, 230),
    )
    // Allied blue flag
    @raylib.draw_cube(
      @raylib.Vector3::new(fs.x, base_y + 3.5, fs.z),
      0.5,
      0.3,
      0.04,
      @raylib.Color::new(30, 80, 200, 255),
    )
    // Green diamond marker
    @raylib.draw_sphere(
      @raylib.Vector3::new(fs.x, base_y + 4.2, fs.z),
      0.2,
      @raylib.Color::new(50, 200, 80, 200),
    )
    let fhp_pct = if fs.max_hp > 0.0 { fs.hull_hp / fs.max_hp } else { 0.0 }
    let fbar_y = base_y + 4.6
    @raylib.draw_cube(
      @raylib.Vector3::new(fs.x, fbar_y, fs.z),
      2.0,
      0.08,
      0.15,
      @raylib.Color::new(0, 40, 80, 180),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(
        fs.x - 2.0 * (1.0 - fhp_pct) / 2.0,
        fbar_y + 0.01,
        fs.z,
      ),
      2.0 * fhp_pct,
      0.1,
      0.15,
      @raylib.Color::new(50, 180, 255, 220),
    )
    ignore(sin_h)
    ignore(cos_h)
  }
}

///|
/// Draws convoy merchant ships with white/brown coloring and flag marker.
fn @types.Game::draw_convoy_ships(game : @types.Game) -> Unit {
  let time = Float::from_int(game.frame_counter) * 0.03
  for i, cs in game.convoy_ships {
    if !cs.active {
      continue
    }
    if cs.arrived {
      continue
    }
    let sin_h = @math.sinf(cs.heading)
    let cos_h = @math.cosf(cs.heading)
    let bob_y = @math.sinf(time * 2.0 + Float::from_int(i) * 1.2) *
      @types.bob_amplitude
    let base_y : Float = 0.35 + bob_y
    @raylib.draw_cube(
      @raylib.Vector3::new(cs.x, base_y, cs.z),
      1.6,
      0.9,
      4.0,
      @raylib.Color::new(140, 110, 70, 255),
    )
    let bow_x = cs.x + sin_h * 2.3
    let bow_z = cs.z + cos_h * 2.3
    @raylib.draw_cube(
      @raylib.Vector3::new(bow_x, base_y, bow_z),
      0.9,
      0.7,
      1.3,
      @raylib.Color::new(120, 95, 60, 255),
    )
    let stern_x = cs.x - sin_h * 2.0
    let stern_z = cs.z - cos_h * 2.0
    @raylib.draw_cube(
      @raylib.Vector3::new(stern_x, base_y + 0.3, stern_z),
      1.5,
      1.3,
      1.2,
      @raylib.Color::new(130, 100, 65, 255),
    )
    @raylib.draw_cylinder(
      @raylib.Vector3::new(cs.x, base_y + 0.4, cs.z),
      0.08,
      0.08,
      3.0,
      6,
      @raylib.Color::new(80, 60, 30, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(cs.x, base_y + 2.2, cs.z),
      2.2,
      1.6,
      0.08,
      @raylib.Color::new(240, 235, 220, 240),
    )
    // Gold flag
    @raylib.draw_cube(
      @raylib.Vector3::new(cs.x, base_y + 3.6, cs.z),
      0.5,
      0.3,
      0.04,
      @raylib.Color::new(220, 200, 100, 255),
    )
    // White diamond marker
    @raylib.draw_sphere(
      @raylib.Vector3::new(cs.x, base_y + 4.2, cs.z),
      0.18,
      @raylib.Color::new(255, 255, 200, 200),
    )
    let chp_pct = if cs.max_hp > 0.0 { cs.hull_hp / cs.max_hp } else { 0.0 }
    let cbar_y = base_y + 4.6
    @raylib.draw_cube(
      @raylib.Vector3::new(cs.x, cbar_y, cs.z),
      2.0,
      0.08,
      0.15,
      @raylib.Color::new(60, 40, 20, 180),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(
        cs.x - 2.0 * (1.0 - chp_pct) / 2.0,
        cbar_y + 0.01,
        cs.z,
      ),
      2.0 * chp_pct,
      0.1,
      0.15,
      @raylib.Color::new(220, 200, 120, 220),
    )
    ignore(sin_h)
    ignore(cos_h)
  }
}

///|
fn @types.Game::draw_wind_indicator(game : @types.Game) -> Unit {
  let ship = game.player
  let arrow_base_x = ship.x + 5.0
  let arrow_base_z = ship.z + 5.0
  let arrow_y : Float = 6.0
  let wind_dx = @math.sinf(game.wind_angle) * 3.0
  let wind_dz = @math.cosf(game.wind_angle) * 3.0
  @raylib.draw_line_3d(
    @raylib.Vector3::new(arrow_base_x, arrow_y, arrow_base_z),
    @raylib.Vector3::new(
      arrow_base_x + wind_dx,
      arrow_y,
      arrow_base_z + wind_dz,
    ),
    @raylib.Color::new(200, 200, 255, 200),
  )
  @raylib.draw_sphere(
    @raylib.Vector3::new(
      arrow_base_x + wind_dx,
      arrow_y,
      arrow_base_z + wind_dz,
    ),
    0.3,
    @raylib.Color::new(200, 200, 255, 200),
  )
}
