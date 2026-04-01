///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count = game.frame_count + 1
  let dt_raw = @raylib.get_frame_time()
  let dt = @types.minf(dt_raw, 0.05)
  // Update screen shake
  @physics.update_shake(game.shake)
  // Update message timer
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - dt
  }
  // Clear sound queue
  game.sound_queue = []
  match game.screen {
    Title => update_title(game)
    Playing => update_playing(game, dt)
    Paused => update_paused(game)
    SectorMap => update_sector_map(game)
    Shop => update_shop(game)
    GameOver => update_game_over(game)
    RunSummary => update_run_summary(game)
    WeaponSelect => update_weapon_select(game)
    BossIntro => update_boss_intro(game, dt)
    Victory => update_victory(game)
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = WeaponSelect
    @types.push_sound(game, MenuSelect)
  }
}

///|
fn update_weapon_select(game : @types.Game) -> Unit {
  let weapons : Array[@types.WeaponKind] = [
    Laser, Shotgun, Missile, Railgun, Flak, Beam,
  ]
  for i in 0..<weapons.length() {
    if @raylib.is_key_pressed(@raylib.KeyOne + i) {
      start_new_run(game, weapons[i])
      return
    }
  }
}

///|
fn start_new_run(game : @types.Game, weapon : @types.WeaponKind) -> Unit {
  // Reset ship
  let ship = game.ship
  ship.pos = @types.vec2(
    @types.arena_default_width / 2.0,
    @types.arena_default_height / 2.0,
  )
  ship.vel = @types.vec2_zero()
  ship.hp = @types.ship_base_hp
  ship.max_hp = @types.ship_base_hp
  ship.shield = @types.ship_base_shield
  ship.max_shield = @types.ship_base_shield
  ship.heat = 0.0
  ship.dash_cooldown = 0.0
  ship.dash_timer = 0.0
  ship.invincible_timer = 0.0
  ship.credits = 0
  ship.kills = 0
  ship.sectors_cleared = 0
  ship.primary_mod = None
  ship.utility_mod = None
  ship.secondary = None
  // Set weapon
  let w = @types.new_weapon(weapon)
  ship.weapon.kind = w.kind
  ship.weapon.damage = w.damage
  ship.weapon.fire_rate = w.fire_rate
  ship.weapon.fire_timer = 0.0
  ship.weapon.projectile_speed = w.projectile_speed
  ship.weapon.spread = w.spread
  ship.weapon.projectile_count = w.projectile_count
  ship.weapon.range = w.range
  ship.weapon.heat_cost = w.heat_cost
  // Reset stats
  let s = game.stats
  s.score = 0
  s.kills = 0
  s.max_combo = 0
  s.combo = 0
  s.sectors_cleared = 0
  s.credits_earned = 0
  s.damage_dealt = 0
  s.damage_taken = 0
  s.shots_fired = 0
  s.shots_hit = 0
  s.time_played = 0.0
  s.bosses_defeated = 0
  s.mods_collected = 0
  // Clear pools
  for i in 0..<game.projectiles.length() {
    game.projectiles[i].active = false
  }
  for i in 0..<game.enemies.length() {
    game.enemies[i].active = false
  }
  for i in 0..<game.particles.length() {
    game.particles[i].active = false
  }
  for i in 0..<game.asteroids.length() {
    game.asteroids[i].active = false
  }
  for i in 0..<game.pickups.length() {
    game.pickups[i].active = false
  }
  for i in 0..<game.damage_numbers.length() {
    game.damage_numbers[i].active = false
  }
  game.boss = None
  game.hazards = []
  // Generate sector map
  game.sector_map = Some(@sectors.generate_sector_map(0))
  game.screen = SectorMap
  @types.set_message(game, "CHOOSE YOUR PATH", 2.0)
  game.meta.total_runs += 1
}

///|
fn update_sector_map(game : @types.Game) -> Unit {
  match game.sector_map {
    None => game.screen = Title
    Some(map) => {
      // Number keys or mouse to select connected nodes
      let current = map.nodes[map.current]
      for i in 0..<current.connections.length() {
        let target_idx = current.connections[i]
        if @raylib.is_key_pressed(@raylib.KeyOne + i) {
          @sectors.enter_sector(game, target_idx)
          return
        }
      }
      // Mouse click on nodes
      let mx = @raylib.get_mouse_x()
      let my = @raylib.get_mouse_y()
      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        for i in 0..<current.connections.length() {
          let target_idx = current.connections[i]
          let node = map.nodes[target_idx]
          let nx = 200 + node.x * 220
          let ny = 200 + node.y * 150
          let dx = mx - nx
          let dy = my - ny
          if dx * dx + dy * dy < 900 {
            @sectors.enter_sector(game, target_idx)
            return
          }
        }
      }
    }
  }
}

///|
fn update_playing(game : @types.Game, dt : Float) -> Unit {
  game.stats.time_played = game.stats.time_played + dt
  // Pause
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Paused
    return
  }
  // Player input
  update_player_input(game, dt)
  // Weapon timer
  @weapons.update_weapon_timer(game.ship.weapon, dt)
  match game.ship.secondary {
    Some(w) => @weapons.update_weapon_timer(w, dt)
    None => ()
  }
  // Ship physics
  @physics.update_ship_physics(game.ship, dt)
  @physics.clamp_to_arena(
    game.ship.pos, 12.0, game.arena_width, game.arena_height,
  )
  @physics.update_heat(game.ship, dt)
  @physics.update_shield_regen(game.ship, dt)
  // Update camera to follow ship
  game.camera_x = game.ship.pos.x - Float::from_int(@types.screen_width) / 2.0
  game.camera_y = game.ship.pos.y - Float::from_int(@types.screen_height) / 2.0
  // Clamp camera
  game.camera_x = @types.clampf(
    game.camera_x,
    0.0,
    game.arena_width - Float::from_int(@types.screen_width),
  )
  game.camera_y = @types.clampf(
    game.camera_y,
    0.0,
    game.arena_height - Float::from_int(@types.screen_height),
  )
  // Update projectiles
  for i in 0..<game.projectiles.length() {
    if game.projectiles[i].active {
      @physics.update_projectile_physics(game.projectiles[i], dt)
      @physics.apply_homing(game.projectiles[i], game.enemies, dt)
      // Bounds check
      let p = game.projectiles[i]
      if p.pos.x < -50.0 ||
        p.pos.x > game.arena_width + 50.0 ||
        p.pos.y < -50.0 ||
        p.pos.y > game.arena_height + 50.0 {
        if p.bounces > 0 {
          p.bounces -= 1
          if p.pos.x < 0.0 || p.pos.x > game.arena_width {
            p.vel.x = -p.vel.x
          }
          if p.pos.y < 0.0 || p.pos.y > game.arena_height {
            p.vel.y = -p.vel.y
          }
        } else {
          p.active = false
        }
      }
    }
  }
  // Update enemies
  for i in 0..<game.enemies.length() {
    if game.enemies[i].active {
      @enemies.update_enemy_ai(game, game.enemies[i], dt)
      @physics.update_enemy_physics(game.enemies[i], dt)
      @physics.clamp_to_arena(
        game.enemies[i].pos,
        game.enemies[i].radius,
        game.arena_width,
        game.arena_height,
      )
    }
  }
  // Post-AI death pass (handles bomber suicide, etc.)
  for i in 0..<game.enemies.length() {
    if game.enemies[i].active && game.enemies[i].hp <= 0 {
      // Bomber explodes on self-destruct
      if game.enemies[i].kind == Bomber {
        apply_explosion(
          game,
          game.enemies[i].pos.x,
          game.enemies[i].pos.y,
          80.0,
          game.enemies[i].damage,
        )
      }
      kill_enemy(game, i)
    }
  }
  // Update boss
  @bosses.update_boss(game, dt)
  // Update asteroids
  for i in 0..<game.asteroids.length() {
    @physics.update_asteroid_physics(game.asteroids[i], dt)
  }
  // Update pickups
  for i in 0..<game.pickups.length() {
    if game.pickups[i].active {
      game.pickups[i].lifetime = game.pickups[i].lifetime - dt
      game.pickups[i].pulse_timer = game.pickups[i].pulse_timer + dt
      if game.pickups[i].lifetime <= 0.0 {
        game.pickups[i].active = false
      }
    }
  }
  // Update particles
  update_particles(game, dt)
  // Update damage numbers
  update_damage_numbers(game, dt)
  // Collision detection
  resolve_collisions(game)
  // Wave spawning (not in boss arenas - boss handles its own spawns)
  if !(game.sector_cleared) && game.current_sector_kind != BossArena {
    // Get target enemy count from sector node
    let target_count = match game.sector_map {
      Some(map) => map.nodes[map.current].enemy_count
      None => 10
    }
    // Only spawn more waves if we haven't reached the target
    if game.sector_enemies_total < target_count {
      game.wave_timer = game.wave_timer - dt
      if game.wave_timer <= 0.0 {
        game.wave_timer = @types.wave_interval
        game.wave_count += 1
        @enemies.spawn_wave(game, game.wave_count, game.current_sector_kind)
      }
    }
    // Check if sector cleared (spawned enough AND killed them all)
    if game.sector_enemies_total >= target_count &&
      game.sector_enemies_killed >= game.sector_enemies_total &&
      @types.count_active_enemies(game.enemies) == 0 {
      game.sector_cleared = true
      match game.sector_map {
        Some(map) => {
          map.nodes[map.current].cleared = true
          game.ship.sectors_cleared += 1
          game.stats.sectors_cleared += 1
          game.meta.sectors_explored += 1
          // Check if shop
          if map.nodes[map.current].has_shop {
            @sectors.generate_shop_items(game)
            game.screen = Shop
          } else if map.current == map.boss_node {
            // Boss defeated - new depth
            game.stats.bosses_defeated += 1
            game.meta.bosses_defeated += 1
            @types.set_message(game, "SECTOR COMPLETE!", 2.0)
            // Generate next sector map
            game.sector_map = Some(
              @sectors.generate_sector_map(map.depth + 1),
            )
            game.screen = SectorMap
          } else {
            @types.set_message(game, "SECTOR CLEARED!", 2.0)
            game.screen = SectorMap
          }
        }
        None => ()
      }
    }
  }
  // Spawn engine trail particles
  spawn_engine_trail(game)
  // Check player death
  if game.ship.hp <= 0 {
    game.screen = GameOver
    @types.push_sound(game, PlayerDeath)
    // Record run
    game.meta.total_kills += game.stats.kills
    if game.stats.score > game.meta.best_score {
      game.meta.best_score = game.stats.score
    }
    if game.stats.kills > game.meta.highest_kills {
      game.meta.highest_kills = game.stats.kills
    }
    game.meta.run_history.push(
      {
        score: game.stats.score,
        kills: game.stats.kills,
        sectors: game.stats.sectors_cleared,
        weapon: game.ship.weapon.kind,
      },
    )
  }
}

///|
fn update_player_input(game : @types.Game, dt : Float) -> Unit {
  let ship = game.ship
  // Movement - WASD
  let mut mx : Float = 0.0
  let mut my : Float = 0.0
  if @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp) {
    my = my - 1.0
  }
  if @raylib.is_key_down(@raylib.KeyS) || @raylib.is_key_down(@raylib.KeyDown) {
    my = my + 1.0
  }
  if @raylib.is_key_down(@raylib.KeyA) || @raylib.is_key_down(@raylib.KeyLeft) {
    mx = mx - 1.0
  }
  if @raylib.is_key_down(@raylib.KeyD) || @raylib.is_key_down(
    @raylib.KeyRight,
  ) {
    mx = mx + 1.0
  }
  // Normalize
  let move_dir = @types.vec2_normalize(@types.vec2(mx, my))
  // Boost
  let speed = if @raylib.is_key_down(@raylib.KeyLeftShift) {
    let boost_heat = @types.ship_boost_heat * dt
    if ship.heat + boost_heat <= ship.max_heat {
      ship.heat = ship.heat + boost_heat
      ship.speed * ship.boost_mult
    } else {
      ship.speed
    }
  } else {
    ship.speed
  }
  // Accelerator utility mod
  let final_speed = match ship.utility_mod {
    Some(Accelerator) => speed * 1.2
    _ => speed
  }
  ship.vel.x = ship.vel.x + move_dir.x * final_speed * dt * 8.0
  ship.vel.y = ship.vel.y + move_dir.y * final_speed * dt * 8.0
  // Dash
  if (@raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight)) &&
    ship.dash_cooldown <= 0.0 {
    ship.dash_cooldown = @types.dash_cooldown
    ship.dash_timer = @types.dash_duration
    ship.invincible_timer = @types.dash_duration
    let dash_dir = if @types.vec2_len(move_dir) > 0.1 {
      move_dir
    } else {
      @types.vec2(@types.cosf(ship.angle), @types.sinf(ship.angle))
    }
    ship.vel.x = dash_dir.x * @types.dash_speed
    ship.vel.y = dash_dir.y * @types.dash_speed
    @types.push_sound(game, PlayerDash)
    // Dash trail particles
    for _i in 0..<8 {
      spawn_particle(
        game,
        ship.pos.x,
        ship.pos.y,
        @types.rng_range(-50.0, 50.0),
        @types.rng_range(-50.0, 50.0),
        0.4,
        4.0,
        @types.color_player_shield,
      )
    }
  }
  // Aim toward mouse (in screen coords, offset by camera)
  let mouse_x = Float::from_int(@raylib.get_mouse_x()) + game.camera_x
  let mouse_y = Float::from_int(@raylib.get_mouse_y()) + game.camera_y
  ship.angle = @types.angle_to(ship.pos, @types.vec2(mouse_x, mouse_y))
  // Fire primary weapon (with primary mod)
  if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) {
    @weapons.fire_weapon(
      game, ship.weapon, ship.pos, ship.angle, mod_kind=ship.primary_mod,
    )
  }
  // Fire secondary weapon (Q key, no mod)
  if @raylib.is_key_down(@raylib.KeyQ) {
    match ship.secondary {
      Some(w) => @weapons.fire_weapon(game, w, ship.pos, ship.angle)
      None => ()
    }
  }
}

///|
fn resolve_collisions(game : @types.Game) -> Unit {
  let ship = game.ship
  // Friendly projectiles vs enemies
  for i in 0..<game.projectiles.length() {
    let p = game.projectiles[i]
    if !(p.active) || !(p.friendly) {
      continue
    }
    // vs enemies
    for j in 0..<game.enemies.length() {
      let e = game.enemies[j]
      if !(e.active) {
        continue
      }
      if @physics.circles_overlap(
        p.pos.x, p.pos.y, p.radius, e.pos.x, e.pos.y, e.radius,
      ) {
        game.stats.shots_hit += 1
        // Apply damage
        if e.shield > 0 {
          e.shield = e.shield - 1
        } else {
          e.hp = e.hp - p.damage
          game.stats.damage_dealt += p.damage
        }
        @types.spawn_damage_number(
          game,
          e.pos.x,
          e.pos.y,
          p.damage,
          @types.weapon_color(p.weapon_kind),
        )
        @types.push_sound(game, EnemyHit)
        // Hit particles
        spawn_hit_particles(game, p.pos.x, p.pos.y, @types.weapon_color(p.weapon_kind))
        // Freezing
        if p.freezing {
          e.frozen_timer = 2.0
        }
        // Explosion
        if p.explosive_radius > 0.0 {
          apply_explosion(game, p.pos.x, p.pos.y, p.explosive_radius, p.damage)
        }
        // Vampire utility
        match ship.utility_mod {
          Some(Vampire) =>
            if ship.hp < ship.max_hp && @types.rng_int(100) < 10 {
              ship.hp = ship.hp + 1
            }
          _ => ()
        }
        // Shield drain utility
        match ship.utility_mod {
          Some(ShieldDrain) =>
            if ship.shield < ship.max_shield && @types.rng_int(100) < 15 {
              ship.shield = ship.shield + 1
            }
          _ => ()
        }
        // Combo
        game.stats.combo += 1
        if game.stats.combo > game.stats.max_combo {
          game.stats.max_combo = game.stats.combo
        }
        // Check enemy death
        if e.hp <= 0 {
          kill_enemy(game, j)
        }
        // Chain: spawn new projectile toward nearest other enemy
        if p.chain_count > 0 {
          let mut nearest_dist : Float = 999999.0
          let mut nearest_idx = -1
          for k in 0..<game.enemies.length() {
            if game.enemies[k].active && k != j {
              let d = @types.vec2_dist_sq(p.pos, game.enemies[k].pos)
              if d < nearest_dist {
                nearest_dist = d
                nearest_idx = k
              }
            }
          }
          if nearest_idx >= 0 {
            let chain_idx = @types.alloc_projectile(game.projectiles)
            if chain_idx >= 0 {
              let cp = game.projectiles[chain_idx]
              cp.active = true
              cp.pos = @types.vec2(p.pos.x, p.pos.y)
              let target = game.enemies[nearest_idx]
              let dir = @types.vec2_normalize(
                @types.vec2_sub(target.pos, p.pos),
              )
              cp.vel = @types.vec2(
                dir.x * @types.vec2_len(p.vel),
                dir.y * @types.vec2_len(p.vel),
              )
              cp.damage = p.damage
              cp.lifetime = 1.0
              cp.radius = p.radius
              cp.friendly = true
              cp.piercing = false
              cp.homing_strength = 0.0
              cp.chain_count = p.chain_count - 1
              cp.explosive_radius = 0.0
              cp.freezing = p.freezing
              cp.bounces = 0
              cp.weapon_kind = p.weapon_kind
            }
          }
        }
        if !(p.piercing) {
          p.active = false
        }
        break
      }
    }
    // vs boss
    match game.boss {
      Some(boss) =>
        if boss.active &&
          p.active &&
          @physics.circles_overlap(
            p.pos.x, p.pos.y, p.radius, boss.pos.x, boss.pos.y, boss.radius,
          ) {
          game.stats.shots_hit += 1
          if boss.shield > 0 {
            boss.shield = boss.shield - 1
          } else {
            boss.hp = boss.hp - p.damage
            game.stats.damage_dealt += p.damage
          }
          @types.spawn_damage_number(
            game,
            boss.pos.x,
            boss.pos.y - boss.radius,
            p.damage,
            @types.color_boss,
          )
          @types.add_shake(game.shake, @types.shake_hit)
          spawn_hit_particles(game, p.pos.x, p.pos.y, @types.color_boss)
          if boss.hp <= 0 {
            boss.active = false
            game.stats.score += boss.score_value
            game.sector_enemies_killed = game.sector_enemies_total // Force clear
            @types.push_sound(game, EnemyDeath)
            // Death explosion
            for _k in 0..<30 {
              spawn_particle(
                game,
                boss.pos.x + @types.rng_range(-30.0, 30.0),
                boss.pos.y + @types.rng_range(-30.0, 30.0),
                @types.rng_range(-200.0, 200.0),
                @types.rng_range(-200.0, 200.0),
                1.2,
                @types.rng_range(4.0, 10.0),
                @types.color_boss,
              )
            }
            @types.add_shake(game.shake, @types.shake_explosion)
          }
          if !(p.piercing) {
            p.active = false
          }
        }
      None => ()
    }
    // vs asteroids
    for j in 0..<game.asteroids.length() {
      let ast = game.asteroids[j]
      if !(ast.active) || !(p.active) {
        continue
      }
      if @physics.circles_overlap(
        p.pos.x, p.pos.y, p.radius, ast.pos.x, ast.pos.y, ast.radius,
      ) {
        ast.hp = ast.hp - p.damage
        if ast.hp <= 0 {
          ast.active = false
          // Spawn debris particles
          for _k in 0..<6 {
            spawn_particle(
              game,
              ast.pos.x,
              ast.pos.y,
              @types.rng_range(-100.0, 100.0),
              @types.rng_range(-100.0, 100.0),
              0.6,
              3.0,
              @types.color_asteroid,
            )
          }
          // Chance to drop pickup
          if @types.rng_int(100) < 20 {
            spawn_random_pickup(game, ast.pos.x, ast.pos.y)
          }
        }
        if !(p.piercing) {
          p.active = false
        }
        break
      }
    }
  }
  // Enemy projectiles vs player
  if ship.invincible_timer <= 0.0 {
    for i in 0..<game.projectiles.length() {
      let p = game.projectiles[i]
      if !(p.active) || p.friendly {
        continue
      }
      if @physics.circles_overlap(
        p.pos.x, p.pos.y, p.radius, ship.pos.x, ship.pos.y, 12.0,
      ) {
        damage_player(game, p.damage)
        p.active = false
        ship.invincible_timer = @types.invincible_duration
        break // Only take one hit per frame
      }
    }
    // Contact damage from enemies
    for i in 0..<game.enemies.length() {
      let e = game.enemies[i]
      if !(e.active) {
        continue
      }
      if @physics.circles_overlap(
        e.pos.x, e.pos.y, e.radius, ship.pos.x, ship.pos.y, 12.0,
      ) {
        damage_player(game, e.damage)
        ship.invincible_timer = @types.invincible_duration
      }
    }
    // Boss contact
    match game.boss {
      Some(boss) =>
        if boss.active &&
          @physics.circles_overlap(
            boss.pos.x, boss.pos.y, boss.radius, ship.pos.x, ship.pos.y, 12.0,
          ) {
          damage_player(game, 3)
          ship.invincible_timer = @types.invincible_duration
        }
      None => ()
    }
  }
  // Player vs pickups
  for i in 0..<game.pickups.length() {
    let pk = game.pickups[i]
    if !(pk.active) {
      continue
    }
    if @physics.circles_overlap(
      pk.pos.x, pk.pos.y, pk.radius, ship.pos.x, ship.pos.y, 16.0,
    ) {
      apply_pickup(game, pk.kind)
      pk.active = false
      @types.push_sound(game, Pickup)
    }
  }
}

///|
fn damage_player(game : @types.Game, amount : Int) -> Unit {
  let ship = game.ship
  if ship.shield > 0 {
    let absorbed = @types.mini(ship.shield, amount)
    ship.shield = ship.shield - absorbed
    let remaining = amount - absorbed
    if remaining > 0 {
      ship.hp = ship.hp - remaining
      game.stats.damage_taken += remaining
    }
    ship.shield_regen_timer = 0.0
    if ship.shield <= 0 {
      @types.push_sound(game, ShieldBreak)
    }
  } else {
    ship.hp = ship.hp - amount
    game.stats.damage_taken += amount
  }
  @types.push_sound(game, PlayerHit)
  @types.add_shake(game.shake, @types.shake_hit)
  game.stats.combo = 0
  // Hit particles
  for _i in 0..<8 {
    spawn_particle(
      game,
      ship.pos.x,
      ship.pos.y,
      @types.rng_range(-100.0, 100.0),
      @types.rng_range(-100.0, 100.0),
      0.5,
      3.0,
      @raylib.red,
    )
  }
}

///|
fn kill_enemy(game : @types.Game, idx : Int) -> Unit {
  let e = game.enemies[idx]
  e.active = false
  game.stats.kills += 1
  game.stats.score += e.score_value
  game.sector_enemies_killed += 1
  game.ship.kills += 1
  @types.push_sound(game, EnemyDeath)
  // Death burst particles
  let color = @types.enemy_color(e.kind)
  for _i in 0..<12 {
    spawn_particle(
      game,
      e.pos.x,
      e.pos.y,
      @types.rng_range(-150.0, 150.0),
      @types.rng_range(-150.0, 150.0),
      0.6,
      @types.rng_range(2.0, 6.0),
      color,
    )
  }
  // Drop pickup chance
  if @types.rng_int(100) < 25 {
    spawn_random_pickup(game, e.pos.x, e.pos.y)
  }
  // Credits
  let credit_value = e.score_value / 2
  game.ship.credits += credit_value
  game.stats.credits_earned += credit_value
}

///|
fn apply_explosion(
  game : @types.Game,
  x : Float,
  y : Float,
  radius : Float,
  damage : Int
) -> Unit {
  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if !(e.active) {
      continue
    }
    if @types.vec2_dist(@types.vec2(x, y), e.pos) < radius {
      e.hp = e.hp - damage
      if e.hp <= 0 {
        kill_enemy(game, i)
      }
    }
  }
  // Explosion particles
  for _i in 0..<16 {
    spawn_particle(
      game,
      x,
      y,
      @types.rng_range(-180.0, 180.0),
      @types.rng_range(-180.0, 180.0),
      0.8,
      @types.rng_range(3.0, 8.0),
      @types.color_missile,
    )
  }
  @types.add_shake(game.shake, @types.shake_explosion)
  @types.push_sound(game, Explosion)
}

///|
fn apply_pickup(game : @types.Game, kind : @types.PickupKind) -> Unit {
  let ship = game.ship
  match kind {
    HealthPack => {
      ship.hp = @types.mini(ship.hp + 2, ship.max_hp)
      @types.set_message(game, "+2 HP", 1.0)
    }
    ShieldRecharge => {
      ship.shield = @types.mini(ship.shield + 2, ship.max_shield)
      @types.set_message(game, "+2 SHIELD", 1.0)
    }
    WeaponMod(mod_kind) => {
      ship.primary_mod = Some(mod_kind)
      game.stats.mods_collected += 1
      @types.set_message(game, @weapons.mod_name(mod_kind) + " MOD", 1.5)
    }
    UtilityPickup(util) => {
      ship.utility_mod = Some(util)
      @types.set_message(game, @weapons.utility_name(util), 1.5)
    }
    Credits(amount) => {
      ship.credits += amount
      game.stats.credits_earned += amount
    }
    HeatVent => {
      ship.heat = 0.0
      @types.set_message(game, "HEAT VENTED", 1.0)
    }
    WeaponDrop(wpn) => {
      ship.secondary = Some(@types.new_weapon(wpn))
      @types.set_message(
        game, "SECONDARY: " + @weapons.weapon_name(wpn), 1.5,
      )
    }
  }
}

///|
fn spawn_random_pickup(game : @types.Game, x : Float, y : Float) -> Unit {
  for i in 0..<game.pickups.length() {
    if !(game.pickups[i].active) {
      let pk = game.pickups[i]
      pk.active = true
      pk.pos = @types.vec2(x, y)
      pk.radius = @types.pickup_radius
      pk.lifetime = @types.pickup_lifetime
      pk.pulse_timer = 0.0
      let roll = @types.rng_int(100)
      pk.kind = if roll < 20 {
        HealthPack
      } else if roll < 35 {
        ShieldRecharge
      } else if roll < 55 {
        Credits(10 + @types.rng_int(20))
      } else if roll < 65 {
        HeatVent
      } else if roll < 80 {
        let mods : Array[@types.ModKind] = [
          Piercing, Homing, Split, Chain, Explosive, Freezing, Bouncing,
          Overcharge,
        ]
        WeaponMod(mods[@types.rng_int(mods.length())])
      } else {
        let utils : Array[@types.UtilityMod] = [
          ShieldDrain, Vampire, HeatSink, Accelerator,
        ]
        UtilityPickup(utils[@types.rng_int(utils.length())])
      }
      return
    }
  }
}

///|
fn spawn_particle(
  game : @types.Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  color : @raylib.Color
) -> Unit {
  let idx = @types.alloc_particle(game.particles)
  let p = game.particles[idx]
  p.active = true
  p.pos = @types.vec2(x, y)
  p.vel = @types.vec2(vx, vy)
  p.life = life
  p.max_life = life
  p.size = size
  p.color = color
  p.shrink = true
}

///|
fn spawn_hit_particles(
  game : @types.Game,
  x : Float,
  y : Float,
  color : @raylib.Color
) -> Unit {
  for _i in 0..<5 {
    spawn_particle(
      game,
      x,
      y,
      @types.rng_range(-80.0, 80.0),
      @types.rng_range(-80.0, 80.0),
      0.3,
      2.0,
      color,
    )
  }
}

///|
fn spawn_engine_trail(game : @types.Game) -> Unit {
  let ship = game.ship
  let speed = @types.vec2_len(ship.vel)
  if speed > 50.0 {
    let behind_x = ship.pos.x - @types.cosf(ship.angle) * 14.0
    let behind_y = ship.pos.y - @types.sinf(ship.angle) * 14.0
    spawn_particle(
      game,
      behind_x + @types.rng_range(-3.0, 3.0),
      behind_y + @types.rng_range(-3.0, 3.0),
      -ship.vel.x * 0.3 + @types.rng_range(-20.0, 20.0),
      -ship.vel.y * 0.3 + @types.rng_range(-20.0, 20.0),
      0.3,
      @types.rng_range(1.5, 3.0),
      @types.color_player,
    )
  }
}

///|
fn update_particles(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.particles.length() {
    let p = game.particles[i]
    if !(p.active) {
      continue
    }
    p.pos.x = p.pos.x + p.vel.x * dt
    p.pos.y = p.pos.y + p.vel.y * dt
    p.vel.x = p.vel.x * 0.95
    p.vel.y = p.vel.y * 0.95
    p.life = p.life - dt
    if p.life <= 0.0 {
      p.active = false
    }
  }
}

///|
fn update_damage_numbers(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.damage_numbers.length() {
    let dn = game.damage_numbers[i]
    if !(dn.active) {
      continue
    }
    dn.pos.x = dn.pos.x + dn.vel.x * dt
    dn.pos.y = dn.pos.y + dn.vel.y * dt
    dn.life = dn.life - dt
    if dn.life <= 0.0 {
      dn.active = false
    }
  }
}

///|
fn update_paused(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyP) {
    game.screen = Playing
  }
  if @raylib.is_key_pressed(@raylib.KeyQ) {
    game.screen = Title
  }
}

///|
fn update_shop(game : @types.Game) -> Unit {
  for i in 0..<game.shop_items.length() {
    if @raylib.is_key_pressed(@raylib.KeyOne + i) {
      let item = game.shop_items[i]
      if !(item.purchased) && game.ship.credits >= item.cost {
        game.ship.credits = game.ship.credits - item.cost
        item.purchased = true
        apply_pickup(game, item.effect)
        @types.push_sound(game, ShopBuy)
      }
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.screen = SectorMap
  }
}

///|
fn update_game_over(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = RunSummary
  }
}

///|
fn update_run_summary(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = Title
  }
}

///|
fn update_boss_intro(game : @types.Game, dt : Float) -> Unit {
  game.boss_intro_timer = game.boss_intro_timer - dt
  if game.boss_intro_timer <= 0.0 {
    // Spawn boss
    match game.sector_map {
      Some(map) => {
        let boss_kind = @bosses.boss_for_depth(map.depth)
        @bosses.spawn_boss(game, boss_kind)
      }
      None => ()
    }
    game.screen = Playing
  }
}

///|
fn update_victory(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.screen = Title
  }
}
