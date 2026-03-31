// Enemy AI and projectile updates

///|
/// Updates enemy AI state, movement, attacks, and alert logic for the current frame.
pub fn update_enemies(game : @types.Game, dt : Float) -> Unit {
  for e in game.enemies {
    if !e.active {
      continue
    }
    // Hit flash timer
    if e.hit_flash > 0.0 {
      e.hit_flash -= dt
      if e.hit_flash < 0.0 {
        e.hit_flash = 0.0
      }
    }
    // Stun timer
    if e.stun_timer > 0.0 {
      e.stun_timer -= dt
      if e.stun_timer < 0.0 {
        e.stun_timer = 0.0
      }
      continue
    }
    // Slow timer
    if e.slow_timer > 0.0 {
      e.slow_timer -= dt
      if e.slow_timer < 0.0 {
        e.slow_timer = 0.0
        e.speed_mult = 1.0
      }
    }
    // Ability cooldown
    if e.ability_cooldown > 0.0 {
      e.ability_cooldown -= dt
      if e.ability_cooldown < 0.0 {
        e.ability_cooldown = 0.0
      }
    }
    // Mimic special: don't move until alerted
    if e.kind == Mimic && !e.alerted {
      continue
    }
    // Check if player is in sight range
    let dist = @types.dist2d(e.x, e.z, game.player_x, game.player_z)
    if dist < @types.enemy_sight_range {
      e.alerted = true
    }
    if !e.alerted {
      // Patrol behavior for non-alerted enemies
      game.update_patrol(e, dt)
      continue
    }
    // Attack cooldown
    if e.attack_timer > 0.0 {
      e.attack_timer -= dt
      if e.attack_timer < 0.0 {
        e.attack_timer = 0.0
      }
    }
    // Telegraph timer (wind-up before attack)
    if e.telegraph_timer > 0.0 {
      e.telegraph_timer -= dt
      if e.telegraph_timer <= 0.0 {
        e.telegraph_timer = 0.0
        // Execute the telegraphed attack
        game.execute_telegraphed_attack(e, dist)
      }
      continue
    }
    // Update facing angle toward player
    let dx = game.player_x - e.x
    let dz = game.player_z - e.z
    e.facing_angle = @math.atan2f(dx, dz)
    // Update boss phase
    if e.kind == DragonBoss {
      e.boss_phase = @types.get_boss_phase(e.hp, e.max_hp)
    }
    // Movement and AI based on type
    match e.kind {
      Skeleton => game.update_melee_enemy(e, dt, dist)
      Golem => game.update_golem_enemy(e, dt, dist)
      Wraith => game.update_wraith_enemy(e, dt, dist)
      DragonBoss => game.update_boss_enemy(e, dt, dist)
      Archer => game.update_archer_enemy(e, dt, dist)
      Slime => game.update_slime_enemy(e, dt, dist)
      Bat => game.update_bat_enemy(e, dt, dist)
      Spider => game.update_spider_enemy(e, dt, dist)
      Minotaur => game.update_minotaur_enemy(e, dt, dist)
      Lich => game.update_lich_enemy(e, dt, dist)
      Mimic => game.update_ambush_enemy(e, dt, dist)
      _ => ()
    }
  }
}

///|
fn @types.Game::update_patrol(
  game : @types.Game,
  e : @types.Enemy,
  dt : Float,
) -> Unit {
  e.move_timer += dt
  if e.move_timer > 2.0 {
    e.move_timer = 0.0
    // Pick a new random patrol direction
    e.patrol_x = e.x + @types.rand_rangef(game, -3.0, 3.0)
    e.patrol_z = e.z + @types.rand_rangef(game, -3.0, 3.0)
  }
  // Move toward patrol point slowly
  let ddx = e.patrol_x - e.x
  let ddz = e.patrol_z - e.z
  let dd = @math.hypotf(ddx, ddz)
  if dd > 0.5 {
    let nx = ddx / dd
    let nz = ddz / dd
    let speed : Float = 0.8
    let new_x = e.x + nx * speed * dt
    let new_z = e.z + nz * speed * dt
    let radius : Float = 0.4
    if !@types.is_blocked(game, new_x, e.z, radius) {
      e.x = new_x
    }
    if !@types.is_blocked(game, e.x, new_z, radius) {
      e.z = new_z
    }
  }
}

///|
/// Executes the attack after a telegraph wind-up completes.
fn @types.Game::execute_telegraphed_attack(
  game : @types.Game,
  e : @types.Enemy,
  dist : Float,
) -> Unit {
  match e.telegraph_kind {
    0 => {
      // Standard melee attack
      let melee_range : Float = 3.0
      if dist < melee_range {
        damage_player(game, e.atk)
        @types.spawn_particles(
          game,
          game.player_x,
          1.0,
          game.player_z,
          6,
          255,
          80,
          80,
        )
        @types.add_message(
          game,
          "\{@types.get_enemy_name(e.kind)} attacks for \{(1).max(e.atk - @types.calc_player_defense(game))} damage!",
          255,
          100,
          80,
        )
      }
    }
    1 => {
      // Golem heavy melee - more damage, small AoE shake
      let melee_range : Float = 3.5
      if dist < melee_range {
        let heavy_dmg = e.atk + e.atk / 3
        damage_player(game, heavy_dmg)
        @types.spawn_particles(
          game,
          game.player_x,
          0.5,
          game.player_z,
          10,
          180,
          120,
          60,
        )
        @types.trigger_shake(game, 0.18, 0.3)
        @types.trigger_hitstop(game, 0.05)
        @types.add_message(
          game,
          "Golem smashes for \{(1).max(heavy_dmg - @types.calc_player_defense(game))} damage!",
          180,
          120,
          60,
        )
      }
    }
    2 =>
      // Archer ranged shot
      game.shoot_projectile(e)
    3 =>
      // Lich bolt
      game.shoot_lich_bolt(e)
    4 => {
      // Boss melee with heavy screen effects
      let melee_range : Float = 4.0
      if dist < melee_range {
        let phase = e.boss_phase
        let mult : Float = if phase == 1 {
          1.0
        } else if phase == 2 {
          1.3
        } else {
          1.7
        }
        let dmg = (Float::from_int(e.atk) * mult).to_int()
        damage_player(game, dmg)
        @types.spawn_particles(
          game,
          game.player_x,
          1.0,
          game.player_z,
          10,
          255,
          80,
          80,
        )
        @types.trigger_shake(game, 0.25, 0.4)
        @types.trigger_hitstop(game, 0.06)
        @types.add_message(
          game,
          "Dragon strikes for \{(1).max(dmg - @types.calc_player_defense(game))}!",
          255,
          80,
          40,
        )
      }
    }
    5 => {
      // Boss fire breath cone
      let phase = e.boss_phase
      let spread = if phase == 1 { 2 } else if phase == 2 { 3 } else { 4 }
      let base_angle = @math.atan2f(game.player_x - e.x, game.player_z - e.z)
      for j in -spread..<=spread {
        let angle = base_angle + Float::from_int(j) * 0.18
        let pidx = @types.alloc_projectile(game)
        if pidx >= 0 {
          let p = game.projectiles[pidx]
          p.active = true
          p.kind = Fireball
          p.x = e.x
          p.z = e.z
          let speed : Float = if phase >= 3 { 8.0 } else { 6.0 }
          p.vx = @math.sinf(angle) * speed
          p.vz = @math.cosf(angle) * speed
          let dmg_mult : Float = if phase == 1 {
            0.5
          } else if phase == 2 {
            0.7
          } else {
            1.0
          }
          p.damage = (Float::from_int(e.atk) * dmg_mult).to_int()
          p.lifetime = 2.5
          p.from_enemy = true
          p.aoe_radius = 0.0
          p.slow_on_hit = false
        }
      }
      @types.spawn_particles(game, e.x, 1.5, e.z, 16, 255, 100, 30)
      @types.trigger_shake(game, 0.20, 0.35)
      @types.trigger_hitstop(game, 0.05)
      @types.add_message(game, "Dragon breathes fire!", 255, 100, 30)
    }
    _ => ()
  }
}

///|
fn @types.Game::update_melee_enemy(
  game : @types.Game,
  e : @types.Enemy,
  dt : Float,
  dist : Float,
) -> Unit {
  // Skeleton: standard melee with attack telegraph
  let move_speed = @types.enemy_move_speed * e.speed_mult
  let melee_range = @types.enemy_melee_range
  if dist > melee_range {
    let dir = @types.pathfind_step(game, e.x, e.z, game.player_x, game.player_z)
    let nx = dir.0
    let nz = dir.1
    let new_x = e.x + nx * move_speed * dt
    let new_z = e.z + nz * move_speed * dt
    let radius : Float = 0.4
    if !@types.is_blocked(game, new_x, e.z, radius) {
      e.x = new_x
    }
    if !@types.is_blocked(game, e.x, new_z, radius) {
      e.z = new_z
    }
  } else if e.attack_timer <= 0.0 {
    // Start telegraph instead of instant attack
    e.telegraph_timer = @types.enemy_telegraph_duration
    e.telegraph_kind = 0 // melee telegraph
    e.attack_timer = @types.enemy_attack_cooldown
    // Visual warning: color flash
    @types.spawn_particles(game, e.x, 1.2, e.z, 3, 255, 50, 50)
  }
}

///|
/// Golem: slow tanky brute with heavy telegraphed attacks
fn @types.Game::update_golem_enemy(
  game : @types.Game,
  e : @types.Enemy,
  dt : Float,
  dist : Float,
) -> Unit {
  let move_speed = @types.golem_move_speed * e.speed_mult
  let melee_range : Float = 2.5
  if dist > melee_range {
    let dir = @types.pathfind_step(game, e.x, e.z, game.player_x, game.player_z)
    let new_x = e.x + dir.0 * move_speed * dt
    let new_z = e.z + dir.1 * move_speed * dt
    let radius : Float = 0.5
    if !@types.is_blocked(game, new_x, e.z, radius) {
      e.x = new_x
    }
    if !@types.is_blocked(game, e.x, new_z, radius) {
      e.z = new_z
    }
  } else if e.attack_timer <= 0.0 {
    // Golem has longer telegraph (heavier attack)
    e.telegraph_timer = @types.enemy_telegraph_duration + 0.3
    e.telegraph_kind = 1 // heavy melee telegraph
    e.attack_timer = 2.0 // slow attack rate
    // Ground pound warning
    @types.spawn_particles(game, e.x, 0.3, e.z, 6, 180, 120, 60)
    @types.add_message(game, "Golem winds up!", 180, 120, 60)
  }
}

///|
/// Wraith: fast, erratic, phases through enemies
fn @types.Game::update_wraith_enemy(
  game : @types.Game,
  e : @types.Enemy,
  dt : Float,
  dist : Float,
) -> Unit {
  let move_speed = @types.wraith_move_speed * e.speed_mult
  let melee_range : Float = 2.0
  // Wraiths strafe erratically while closing in
  e.move_timer += dt
  let strafe_offset = @math.sinf(e.move_timer * 4.0) * 2.0
  if dist > melee_range {
    let dx = game.player_x - e.x
    let dz = game.player_z - e.z
    let d = @math.hypotf(dx, dz)
    if d > 0.1 {
      let nx = dx / d
      let nz = dz / d
      // Add perpendicular strafe component
      let sx = -nz * strafe_offset * 0.3
      let sz = nx * strafe_offset * 0.3
      let new_x = e.x + (nx + sx) * move_speed * dt
      let new_z = e.z + (nz + sz) * move_speed * dt
      let radius : Float = 0.3
      if !@types.is_blocked(game, new_x, e.z, radius) {
        e.x = new_x
      }
      if !@types.is_blocked(game, e.x, new_z, radius) {
        e.z = new_z
      }
    }
  } else if e.attack_timer <= 0.0 {
    e.telegraph_timer = 0.25 // Quick telegraph for fast wraith
    e.telegraph_kind = 0
    e.attack_timer = 0.9
    @types.spawn_particles(game, e.x, 1.0, e.z, 4, 120, 50, 200)
  }
}

///|
/// Ambush enemy (mimic): waits near walls, then burst-attacks
fn @types.Game::update_ambush_enemy(
  game : @types.Game,
  e : @types.Enemy,
  dt : Float,
  dist : Float,
) -> Unit {
  let melee_range : Float = 2.0
  if e.ai_state == @types.ai_ambush || e.ai_state == @types.ai_idle {
    // Lurk until player is very close
    if dist < 3.5 {
      e.ai_state = @types.ai_chase
      e.speed_mult = 2.0 // Burst of speed
      @types.spawn_particles(game, e.x, 0.5, e.z, 10, 255, 50, 50)
      @types.add_message(game, "MIMIC ambush!", 255, 50, 50)
    }
    return
  }
  // After burst, slow down over time
  if e.speed_mult > 1.0 {
    e.speed_mult -= dt * 0.5
    if e.speed_mult < 1.0 {
      e.speed_mult = 1.0
    }
  }
  let move_speed = @types.enemy_move_speed * 1.5 * e.speed_mult
  if dist > melee_range {
    let dir = @types.pathfind_step(game, e.x, e.z, game.player_x, game.player_z)
    let new_x = e.x + dir.0 * move_speed * dt
    let new_z = e.z + dir.1 * move_speed * dt
    let radius : Float = 0.4
    if !@types.is_blocked(game, new_x, e.z, radius) {
      e.x = new_x
    }
    if !@types.is_blocked(game, e.x, new_z, radius) {
      e.z = new_z
    }
  } else if e.attack_timer <= 0.0 {
    e.telegraph_timer = 0.3
    e.telegraph_kind = 0
    e.attack_timer = @types.enemy_attack_cooldown
  }
  ignore(dt)
}

///|
fn @types.Game::update_archer_enemy(
  game : @types.Game,
  e : @types.Enemy,
  dt : Float,
  dist : Float,
) -> Unit {
  // Archers keep distance, strafe sideways, and require LOS
  let preferred_dist : Float = 8.0
  let move_speed = @types.enemy_move_speed * e.speed_mult
  let has_los = @types.has_line_of_sight(
    game,
    e.x,
    e.z,
    game.player_x,
    game.player_z,
  )
  if dist < 4.0 {
    // Retreat when too close
    let dx = e.x - game.player_x
    let dz = e.z - game.player_z
    let d = @math.hypotf(dx, dz)
    if d > 0.1 {
      let nx = dx / d
      let nz = dz / d
      // Also strafe sideways while retreating
      let strafe_x = -nz * e.strafe_dir * 0.5
      let strafe_z = nx * e.strafe_dir * 0.5
      let new_x = e.x + (nx + strafe_x) * move_speed * 1.3 * dt
      let new_z = e.z + (nz + strafe_z) * move_speed * 1.3 * dt
      let radius : Float = 0.4
      if !@types.is_blocked(game, new_x, e.z, radius) {
        e.x = new_x
      } else {
        e.strafe_dir = -e.strafe_dir // Flip strafe on wall hit
      }
      if !@types.is_blocked(game, e.x, new_z, radius) {
        e.z = new_z
      } else {
        e.strafe_dir = -e.strafe_dir
      }
    }
  } else if dist > preferred_dist + 2.0 {
    // Move closer
    let dir = @types.pathfind_step(game, e.x, e.z, game.player_x, game.player_z)
    let new_x = e.x + dir.0 * move_speed * dt
    let new_z = e.z + dir.1 * move_speed * dt
    let radius : Float = 0.4
    if !@types.is_blocked(game, new_x, e.z, radius) {
      e.x = new_x
    }
    if !@types.is_blocked(game, e.x, new_z, radius) {
      e.z = new_z
    }
  } else {
    // At preferred distance: strafe sideways
    let dx = game.player_x - e.x
    let dz = game.player_z - e.z
    let d = @math.hypotf(dx, dz)
    if d > 0.1 {
      let nx = dx / d
      let nz = dz / d
      let strafe_x = -nz * e.strafe_dir
      let strafe_z = nx * e.strafe_dir
      let new_x = e.x + strafe_x * move_speed * 0.8 * dt
      let new_z = e.z + strafe_z * move_speed * 0.8 * dt
      let radius : Float = 0.4
      if !@types.is_blocked(game, new_x, e.z, radius) {
        e.x = new_x
      } else {
        e.strafe_dir = -e.strafe_dir
      }
      if !@types.is_blocked(game, e.x, new_z, radius) {
        e.z = new_z
      } else {
        e.strafe_dir = -e.strafe_dir
      }
    }
    // Periodically change strafe direction
    e.move_timer += dt
    if e.move_timer > 2.5 {
      e.move_timer = 0.0
      e.strafe_dir = -e.strafe_dir
    }
  }
  // Shoot at player only with clear line of sight
  if dist < @types.archer_range && e.attack_timer <= 0.0 && has_los {
    // Telegraph the shot
    e.telegraph_timer = 0.35
    e.telegraph_kind = 2 // ranged telegraph
    e.attack_timer = @types.archer_shoot_cooldown
    @types.spawn_particles(game, e.x, 1.3, e.z, 3, 80, 180, 60)
  }
}

///|
fn @types.Game::update_slime_enemy(
  game : @types.Game,
  e : @types.Enemy,
  dt : Float,
  dist : Float,
) -> Unit {
  // Slimes are slow but bounce toward player
  let move_speed = @types.slime_move_speed * e.speed_mult
  let melee_range = @types.enemy_melee_range
  if dist > melee_range {
    // Bounce movement - hop every second
    e.move_timer += dt
    if e.move_timer > 0.8 {
      e.move_timer = 0.0
      let dir = @types.pathfind_step(
        game,
        e.x,
        e.z,
        game.player_x,
        game.player_z,
      )
      let hop_dist = move_speed * 0.5
      let new_x = e.x + dir.0 * hop_dist
      let new_z = e.z + dir.1 * hop_dist
      let radius : Float = 0.4
      if !@types.is_blocked(game, new_x, e.z, radius) {
        e.x = new_x
      }
      if !@types.is_blocked(game, e.x, new_z, radius) {
        e.z = new_z
      }
      // Spawn slime trail particles
      @types.spawn_particles(game, e.x, 0.2, e.z, 2, 50, 200, 50)
    }
    // Attack with telegraph
  } else if e.attack_timer <= 0.0 {
    e.telegraph_timer = 0.3
    e.telegraph_kind = 0
    e.attack_timer = @types.enemy_attack_cooldown
    @types.spawn_particles(game, e.x, 0.3, e.z, 3, 50, 200, 50)
  }
}

///|
fn @types.Game::update_bat_enemy(
  game : @types.Game,
  e : @types.Enemy,
  dt : Float,
  dist : Float,
) -> Unit {
  // Bats have fast erratic movement
  let move_speed = @types.bat_move_speed * e.speed_mult
  let melee_range : Float = 1.8
  // Add erratic movement offset
  e.move_timer += dt * 5.0
  let erratic_x = @math.sinf(e.move_timer * 3.0) * 1.5
  let erratic_z = @math.cosf(e.move_timer * 2.5) * 1.5
  if dist > melee_range {
    let dx = game.player_x + erratic_x - e.x
    let dz = game.player_z + erratic_z - e.z
    let d = @math.hypotf(dx, dz)
    if d > 0.1 {
      let nx = dx / d
      let nz = dz / d
      let new_x = e.x + nx * move_speed * dt
      let new_z = e.z + nz * move_speed * dt
      let radius : Float = 0.3
      if !@types.is_blocked(game, new_x, e.z, radius) {
        e.x = new_x
      }
      if !@types.is_blocked(game, e.x, new_z, radius) {
        e.z = new_z
      }
    }
    // Swooping attack with telegraph
  } else if e.attack_timer <= 0.0 {
    e.telegraph_timer = 0.25
    e.telegraph_kind = 0
    e.attack_timer = 0.8
    @types.spawn_particles(game, e.x, 1.5, e.z, 3, 80, 60, 40)
  }
}

///|
fn @types.Game::update_spider_enemy(
  game : @types.Game,
  e : @types.Enemy,
  dt : Float,
  dist : Float,
) -> Unit {
  // Spiders are medium speed, can slow player with web
  let move_speed = @types.spider_move_speed * e.speed_mult
  let melee_range = @types.enemy_melee_range
  if dist > melee_range {
    let dir = @types.pathfind_step(game, e.x, e.z, game.player_x, game.player_z)
    let new_x = e.x + dir.0 * move_speed * dt
    let new_z = e.z + dir.1 * move_speed * dt
    let radius : Float = 0.4
    if !@types.is_blocked(game, new_x, e.z, radius) {
      e.x = new_x
    }
    if !@types.is_blocked(game, e.x, new_z, radius) {
      e.z = new_z
    }
    // Web attack at range
    if dist < 6.0 && e.ability_cooldown <= 0.0 {
      // Shoot web projectile
      game.shoot_web(e)
      e.ability_cooldown = 4.0
    }
    // Melee attack with telegraph
  } else if e.attack_timer <= 0.0 {
    e.telegraph_timer = 0.3
    e.telegraph_kind = 0
    e.attack_timer = @types.enemy_attack_cooldown
    @types.spawn_particles(game, e.x, 0.5, e.z, 3, 120, 100, 80)
  }
}

///|
fn @types.Game::update_minotaur_enemy(
  game : @types.Game,
  e : @types.Enemy,
  dt : Float,
  dist : Float,
) -> Unit {
  // Minotaur: charges in straight line
  let melee_range : Float = 2.5
  if e.ai_state == @types.ai_special {
    // Charging!
    let charge_speed = @types.minotaur_charge_speed * e.speed_mult
    let dx = @math.sinf(e.facing_angle)
    let dz = @math.cosf(e.facing_angle)
    let new_x = e.x + dx * charge_speed * dt
    let new_z = e.z + dz * charge_speed * dt
    let radius : Float = 0.5
    if @types.is_blocked(game, new_x, new_z, radius) {
      // Hit wall, stop charge
      e.ai_state = @types.ai_chase
      e.stun_timer = 1.0
      @types.spawn_particles(game, e.x, 1.0, e.z, 12, 150, 100, 50)
    } else {
      e.x = new_x
      e.z = new_z
      // Check if hit player during charge
      let charge_dist = @types.dist2d(e.x, e.z, game.player_x, game.player_z)
      if charge_dist < 1.5 {
        damage_player(game, e.atk * 2)
        e.ai_state = @types.ai_chase
        @types.spawn_particles(
          game,
          game.player_x,
          1.0,
          game.player_z,
          10,
          255,
          80,
          40,
        )
        @types.add_message(game, "Minotaur charge hits!", 255, 80, 40)
      }
    }
    // Charge has a max duration
    e.move_timer -= dt
    if e.move_timer <= 0.0 {
      e.ai_state = @types.ai_chase
    }
  } else if dist > melee_range && dist < 10.0 && e.ability_cooldown <= 0.0 {
    // Start charge if player is in line of sight
    e.ai_state = @types.ai_special
    e.move_timer = 1.5
    e.ability_cooldown = 5.0
    e.facing_angle = @math.atan2f(game.player_x - e.x, game.player_z - e.z)
    @types.spawn_particles(game, e.x, 0.5, e.z, 8, 200, 100, 50)
    @types.add_message(game, "Minotaur charges!", 200, 100, 50)
  } else {
    // Normal chase
    let move_speed : Float = 2.5 * e.speed_mult
    if dist > melee_range {
      let dir = @types.pathfind_step(
        game,
        e.x,
        e.z,
        game.player_x,
        game.player_z,
      )
      let new_x = e.x + dir.0 * move_speed * dt
      let new_z = e.z + dir.1 * move_speed * dt
      let radius : Float = 0.5
      if !@types.is_blocked(game, new_x, e.z, radius) {
        e.x = new_x
      }
      if !@types.is_blocked(game, e.x, new_z, radius) {
        e.z = new_z
      }
    } else if e.attack_timer <= 0.0 {
      e.telegraph_timer = 0.4
      e.telegraph_kind = 1 // heavy melee
      e.attack_timer = 1.5
      @types.spawn_particles(game, e.x, 0.8, e.z, 4, 200, 100, 50)
    }
  }
}

///|
fn @types.Game::update_lich_enemy(
  game : @types.Game,
  e : @types.Enemy,
  dt : Float,
  dist : Float,
) -> Unit {
  // Lich: ranged caster, keeps distance, strafes, requires LOS, summons
  let move_speed : Float = 1.8 * e.speed_mult
  let has_los = @types.has_line_of_sight(
    game,
    e.x,
    e.z,
    game.player_x,
    game.player_z,
  )
  if dist < 5.0 {
    // Retreat and strafe
    let dx = e.x - game.player_x
    let dz = e.z - game.player_z
    let d = @math.hypotf(dx, dz)
    if d > 0.1 {
      let nx = dx / d
      let nz = dz / d
      let strafe_x = -nz * e.strafe_dir * 0.4
      let strafe_z = nx * e.strafe_dir * 0.4
      let new_x = e.x + (nx + strafe_x) * move_speed * dt
      let new_z = e.z + (nz + strafe_z) * move_speed * dt
      let radius : Float = 0.4
      if !@types.is_blocked(game, new_x, e.z, radius) {
        e.x = new_x
      } else {
        e.strafe_dir = -e.strafe_dir
      }
      if !@types.is_blocked(game, e.x, new_z, radius) {
        e.z = new_z
      } else {
        e.strafe_dir = -e.strafe_dir
      }
    }
  } else if dist > 10.0 {
    let dir = @types.pathfind_step(game, e.x, e.z, game.player_x, game.player_z)
    let new_x = e.x + dir.0 * move_speed * dt
    let new_z = e.z + dir.1 * move_speed * dt
    let radius : Float = 0.4
    if !@types.is_blocked(game, new_x, e.z, radius) {
      e.x = new_x
    }
    if !@types.is_blocked(game, e.x, new_z, radius) {
      e.z = new_z
    }
  } else {
    // Strafe at preferred range
    let dx = game.player_x - e.x
    let dz = game.player_z - e.z
    let d = @math.hypotf(dx, dz)
    if d > 0.1 {
      let nx = dx / d
      let nz = dz / d
      let strafe_x = -nz * e.strafe_dir
      let strafe_z = nx * e.strafe_dir
      let new_x = e.x + strafe_x * move_speed * 0.7 * dt
      let new_z = e.z + strafe_z * move_speed * 0.7 * dt
      let radius : Float = 0.4
      if !@types.is_blocked(game, new_x, e.z, radius) {
        e.x = new_x
      } else {
        e.strafe_dir = -e.strafe_dir
      }
      if !@types.is_blocked(game, e.x, new_z, radius) {
        e.z = new_z
      } else {
        e.strafe_dir = -e.strafe_dir
      }
    }
    e.move_timer += dt
    if e.move_timer > 3.0 {
      e.move_timer = 0.0
      e.strafe_dir = -e.strafe_dir
    }
  }
  // Spell attacks - only with LOS
  if dist < @types.archer_range && e.attack_timer <= 0.0 && has_los {
    e.telegraph_timer = 0.5
    e.telegraph_kind = 3 // lich bolt telegraph
    e.attack_timer = 1.5
    @types.spawn_particles(game, e.x, 1.5, e.z, 4, 180, 50, 255)
  }
  // Summon skeleton ability
  if e.ability_cooldown <= 0.0 && dist < 12.0 {
    game.summon_skeleton(e)
    e.ability_cooldown = 8.0
    @types.add_message(game, "Lich summons a skeleton!", 180, 50, 200)
  }
}

///|
fn @types.Game::update_boss_enemy(
  game : @types.Game,
  e : @types.Enemy,
  dt : Float,
  dist : Float,
) -> Unit {
  // Dragon boss: multi-phase with telegraphed attacks
  // Phase determines speed, attack patterns, and cooldowns
  let phase = e.boss_phase
  let speed_mult : Float = if phase == 1 {
    1.0
  } else if phase == 2 {
    1.4
  } else {
    1.8
  }
  let base_speed = @types.golem_move_speed * e.speed_mult * speed_mult
  let melee_range : Float = 3.0
  let ability_cd : Float = if phase == 1 {
    4.0
  } else if phase == 2 {
    2.5
  } else {
    1.5
  }
  let atk_mult : Float = if phase == 1 {
    1.0
  } else if phase == 2 {
    1.3
  } else {
    1.7
  }
  if dist > melee_range {
    let dir = @types.pathfind_step(game, e.x, e.z, game.player_x, game.player_z)
    let new_x = e.x + dir.0 * base_speed * dt
    let new_z = e.z + dir.1 * base_speed * dt
    let radius : Float = 0.6
    if !@types.is_blocked(game, new_x, e.z, radius) {
      e.x = new_x
    }
    if !@types.is_blocked(game, e.x, new_z, radius) {
      e.z = new_z
    }
  } else if e.attack_timer <= 0.0 {
    // Telegraphed melee attack
    e.telegraph_timer = @types.boss_telegraph_duration
    e.telegraph_kind = 4 // boss melee telegraph
    let cd : Float = if phase == 1 {
      @types.enemy_attack_cooldown
    } else if phase == 2 {
      0.9
    } else {
      0.6
    }
    e.attack_timer = cd
    // Ground AoE warning indicator
    @types.spawn_particles(
      game,
      game.player_x,
      0.2,
      game.player_z,
      8,
      255,
      80,
      30,
    )
  }
  // Fire breath special attack (telegraphed)
  if e.ability_cooldown <= 0.0 && dist < 10.0 {
    e.telegraph_timer = @types.boss_telegraph_duration + 0.2
    e.telegraph_kind = 5 // fire breath telegraph
    e.ability_cooldown = ability_cd
    // Warning particles at mouth
    @types.spawn_particles(game, e.x, 2.2, e.z, 6, 255, 150, 30)
    @types.add_message(game, "Dragon readies fire breath!", 255, 150, 30)
  }
  // Phase 2+: tail sweep at close range
  if phase >= 2 && dist < 4.0 && e.move_timer <= 0.0 {
    // Tail sweep: damage nearby
    let sweep_dmg = (Float::from_int(e.atk) * atk_mult * 0.6).to_int()
    let sweep_dist = @types.dist2d(e.x, e.z, game.player_x, game.player_z)
    if sweep_dist < 4.0 {
      damage_player(game, sweep_dmg)
      @types.spawn_particles(
        game,
        game.player_x,
        0.5,
        game.player_z,
        6,
        200,
        80,
        40,
      )
      @types.add_message(game, "Dragon tail sweep!", 200, 80, 40)
    }
    e.move_timer = if phase == 2 { 5.0 } else { 3.0 }
  }
  if e.move_timer > 0.0 {
    e.move_timer -= dt
    if e.move_timer < 0.0 {
      e.move_timer = 0.0
    }
  }
  // Phase 3: enrage aura - periodic damage to nearby player
  if phase >= 3 && dist < 4.0 {
    e.aura_timer += dt
    if e.aura_timer >= 0.5 {
      e.aura_timer = 0.0
      damage_player(game, 2)
      @types.spawn_particles(
        game,
        game.player_x,
        1.0,
        game.player_z,
        4,
        255,
        40,
        40,
      )
      @types.add_message(game, "Dragon aura burns!", 255, 40, 40)
    }
  }
  ignore(atk_mult)
}

///|
fn @types.Game::shoot_projectile(game : @types.Game, e : @types.Enemy) -> Unit {
  let idx = @types.alloc_projectile(game)
  if idx < 0 {
    return
  }
  let p = game.projectiles[idx]
  p.active = true
  p.kind = None
  p.x = e.x
  p.z = e.z
  // Direction toward player
  let dx = game.player_x - e.x
  let dz = game.player_z - e.z
  let d = @math.hypotf(dx, dz)
  if d > 0.1 {
    p.vx = dx / d * @types.projectile_speed
    p.vz = dz / d * @types.projectile_speed
  } else {
    p.vx = 0.0
    p.vz = @types.projectile_speed
  }
  p.damage = e.atk
  p.lifetime = @types.projectile_lifetime
  p.from_enemy = true
  p.aoe_radius = 0.0
  p.slow_on_hit = false
}

///|
fn @types.Game::shoot_web(game : @types.Game, e : @types.Enemy) -> Unit {
  let idx = @types.alloc_projectile(game)
  if idx < 0 {
    return
  }
  let p = game.projectiles[idx]
  p.active = true
  p.kind = IceBolt // Reuse ice_bolt visual
  p.x = e.x
  p.z = e.z
  let dx = game.player_x - e.x
  let dz = game.player_z - e.z
  let d = @math.hypotf(dx, dz)
  if d > 0.1 {
    p.vx = dx / d * 5.0
    p.vz = dz / d * 5.0
  } else {
    p.vx = 0.0
    p.vz = 5.0
  }
  p.damage = 2
  p.lifetime = 2.0
  p.from_enemy = true
  p.aoe_radius = 0.0
  p.slow_on_hit = true
}

///|
fn @types.Game::shoot_lich_bolt(game : @types.Game, e : @types.Enemy) -> Unit {
  let idx = @types.alloc_projectile(game)
  if idx < 0 {
    return
  }
  let p = game.projectiles[idx]
  p.active = true
  p.kind = Lightning
  p.x = e.x
  p.z = e.z
  let dx = game.player_x - e.x
  let dz = game.player_z - e.z
  let d = @math.hypotf(dx, dz)
  if d > 0.1 {
    p.vx = dx / d * 7.0
    p.vz = dz / d * 7.0
  } else {
    p.vx = 0.0
    p.vz = 7.0
  }
  p.damage = e.atk
  p.lifetime = 2.5
  p.from_enemy = true
  p.aoe_radius = 0.0
  p.slow_on_hit = false
  @types.spawn_particles(game, e.x, 1.5, e.z, 6, 180, 50, 255)
}

///|
fn @types.Game::summon_skeleton(game : @types.Game, e : @types.Enemy) -> Unit {
  let idx = @types.alloc_enemy(game)
  if idx < 0 {
    return
  }
  let se = game.enemies[idx]
  se.active = true
  se.kind = Skeleton
  // Spawn near the lich
  se.x = e.x + @types.rand_rangef(game, -2.0, 2.0)
  se.z = e.z + @types.rand_rangef(game, -2.0, 2.0)
  let hp_s = @levels.get_enemy_hp_scale(game.current_floor)
  let atk_s = @levels.get_enemy_atk_scale(game.current_floor)
  let def_s = @levels.get_enemy_def_scale(game.current_floor)
  se.hp = 15 + hp_s / 2
  se.max_hp = se.hp
  se.atk = 4 + atk_s / 2
  se.def = 1 + def_s / 2
  se.attack_timer = 0.0
  se.move_timer = 0.0
  se.alerted = true
  se.hit_flash = 0.0
  se.ai_state = @types.ai_chase
  se.xp_value = @types.xp_per_skeleton / 2
  se.speed_mult = 1.0
  se.stun_timer = 0.0
  se.slow_timer = 0.0
  se.ability_cooldown = 0.0
  se.facing_angle = 0.0
  se.patrol_x = se.x
  se.patrol_z = se.z
  se.telegraph_timer = 0.0
  se.telegraph_kind = 0
  se.boss_phase = 1
  se.strafe_dir = 1.0
  @types.spawn_particles(game, se.x, 1.0, se.z, 10, 180, 50, 200)
  game.floor_info[game.current_floor].enemies_total += 1
}

///|
/// Simulates projectile movement and resolves projectile collisions with walls, player, and enemies.
pub fn update_projectiles(game : @types.Game, dt : Float) -> Unit {
  for p in game.projectiles {
    if !p.active {
      continue
    }
    p.lifetime -= dt
    if p.lifetime <= 0.0 {
      p.active = false
      continue
    }
    // Move
    let new_x = p.x + p.vx * dt
    let new_z = p.z + p.vz * dt
    // Check wall collision
    let gx = @types.world_to_grid_x(new_x)
    let gz = @types.world_to_grid_z(new_z)
    if !@types.is_walkable(@types.get_tile(game, gx, gz)) {
      p.active = false
      // Hit wall particles
      @types.spawn_particles(game, new_x, 1.0, new_z, 4, 200, 200, 50)
      continue
    }
    p.x = new_x
    p.z = new_z
    // Check hit player (enemy projectiles)
    if p.from_enemy {
      let dist = @types.dist2d(p.x, p.z, game.player_x, game.player_z)
      if dist < 0.8 {
        damage_player(game, p.damage)
        if p.slow_on_hit {
          @types.add_buff(game, @types.buff_speed, 2.0, -3)
          @types.add_message(game, "Slowed by web!", 200, 200, 200)
        }
        p.active = false
        @types.spawn_particles(
          game,
          game.player_x,
          1.0,
          game.player_z,
          6,
          255,
          100,
          50,
        )
      }
    } else {
      // Player projectile: check hit enemies
      for j in 0..<game.enemies.length() {
        let enemy = game.enemies[j]
        if !enemy.active {
          continue
        }
        let edist = @types.dist2d(p.x, p.z, enemy.x, enemy.z)
        if edist < 0.8 {
          // Use the projectile's stored damage instead of recalculating
          let damage = (1).max(p.damage - enemy.def)
          enemy.hp -= damage
          enemy.hit_flash = 0.3
          enemy.alerted = true
          // Spell-specific hit effects
          let spell_colors = get_spell_hit_colors(p.kind)
          match p.kind {
            Fireball => {
              // Fireball: screen shake, knockback, explosion particles
              @types.trigger_shake(game, 0.12, 0.25)
              @types.apply_knockback(game, enemy, p.x, p.z, 1.2)
              @types.spawn_particles(
                game,
                enemy.x,
                1.0,
                enemy.z,
                14,
                255,
                120,
                30,
              )
              @types.spawn_particles(
                game,
                enemy.x,
                0.5,
                enemy.z,
                8,
                255,
                60,
                10,
              )
              enemy.stun_timer = 0.2
            }
            IceBolt => {
              // Ice bolt: slow enemy, ice crystal particles
              enemy.slow_timer = @types.ice_bolt_slow_duration
              enemy.speed_mult = 0.4
              @types.spawn_particles(
                game,
                enemy.x,
                1.2,
                enemy.z,
                10,
                150,
                220,
                255,
              )
              @types.spawn_particles(
                game,
                enemy.x,
                0.6,
                enemy.z,
                6,
                200,
                240,
                255,
              )
            }
            Lightning => {
              // Lightning: stun, bright electric sparks
              enemy.stun_timer = 0.5
              @types.trigger_shake(game, 0.06, 0.15)
              @types.spawn_particles(
                game,
                enemy.x,
                1.5,
                enemy.z,
                12,
                255,
                255,
                100,
              )
              @types.spawn_particles(
                game,
                enemy.x,
                1.0,
                enemy.z,
                6,
                200,
                200,
                255,
              )
            }
            _ =>
              // Generic projectile (arrows etc)
              @types.spawn_particles(
                game,
                enemy.x,
                1.0,
                enemy.z,
                8,
                spell_colors.0,
                spell_colors.1,
                spell_colors.2,
              )
          }
          // Stagger: enemy pauses on projectile hit
          if enemy.stun_timer < 0.15 {
            enemy.stun_timer = 0.15
          }
          // Hitstop on spell impact
          @types.trigger_hitstop(game, 0.04)
          // Apply slow from ice bolt (kept for backward compat with p.slow_on_hit)
          if p.slow_on_hit && p.kind != IceBolt {
            enemy.slow_timer = @types.ice_bolt_slow_duration
            enemy.speed_mult = 0.4
          }
          // Spawn floating damage number
          @types.spawn_damage_number(
            game,
            enemy.x,
            1.8,
            enemy.z,
            damage,
            spell_colors.0,
            spell_colors.1,
            spell_colors.2,
            false,
          )
          @types.add_message(
            game,
            "Hit \{@types.get_enemy_name(enemy.kind)} for \{damage}!",
            spell_colors.0,
            spell_colors.1,
            spell_colors.2,
          )
          // AOE: damage nearby enemies if aoe_radius > 0
          if p.aoe_radius > 0.0 {
            game.apply_aoe_damage(p.x, p.z, p.aoe_radius, p.damage, p.kind, j)
          }
          p.active = false
          if enemy.hp <= 0 {
            kill_enemy(game, j)
          }
          break
        }
      }
    }
  }
}

///|
/// Advances particle lifetimes and kinematics for combat and ambient effects.
pub fn update_particles(game : @types.Game, dt : Float) -> Unit {
  for p in game.particles {
    if !p.active {
      continue
    }
    p.life -= dt
    if p.life <= 0.0 {
      p.active = false
      continue
    }
    p.x += p.vx * dt
    p.y += p.vy * dt
    p.z += p.vz * dt
    // Gravity
    p.vy -= 6.0 * dt
    // Drag
    p.vx *= 0.98
    p.vz *= 0.98
  }
}

///|
/// Returns RGB color tuple for spell hit effects.
fn get_spell_hit_colors(kind : @types.Spell) -> (Int, Int, Int) {
  match kind {
    Fireball => (255, 120, 30)
    IceBolt => (150, 220, 255)
    Lightning => (255, 255, 100)
    _ => (255, 200, 80)
  }
}

///|
/// Applies AOE damage to enemies within radius of an impact point.
fn @types.Game::apply_aoe_damage(
  game : @types.Game,
  cx : Float,
  cz : Float,
  radius : Float,
  base_damage : Int,
  kind : @types.Spell,
  skip_idx : Int,
) -> Unit {
  let colors = get_spell_hit_colors(kind)
  for j in 0..<game.enemies.length() {
    if j == skip_idx {
      continue
    }
    let e = game.enemies[j]
    if !e.active {
      continue
    }
    let dist = @types.dist2d(cx, cz, e.x, e.z)
    if dist < radius {
      // Damage falls off with distance
      let falloff : Float = 1.0 - dist / radius
      let dmg_f = Float::from_int(base_damage) * falloff * 0.6
      let dmg = (1).max(dmg_f.to_int() - e.def)
      e.hp -= dmg
      e.hit_flash = 0.3
      e.alerted = true
      // AOE knockback
      @types.apply_knockback(game, e, cx, cz, (radius - dist) * 0.5)
      // AOE particles
      @types.spawn_particles(
        game,
        e.x,
        1.0,
        e.z,
        6,
        colors.0,
        colors.1,
        colors.2,
      )
      // AOE damage number
      @types.spawn_damage_number(
        game,
        e.x,
        1.8,
        e.z,
        dmg,
        colors.0,
        colors.1,
        colors.2,
        false,
      )
      @types.add_message(
        game,
        "AOE hits \{@types.get_enemy_name(e.kind)} for \{dmg}!",
        colors.0,
        colors.1,
        colors.2,
      )
      if e.hp <= 0 {
        kill_enemy(game, j)
      }
    }
  }
  // AOE visual: large burst of particles at center
  if kind == Fireball {
    @types.spawn_particles(game, cx, 0.5, cz, 20, 255, 80, 20)
    @types.spawn_particles(game, cx, 1.5, cz, 12, 255, 200, 60)
    @types.trigger_shake(game, 0.2, 0.35)
  }
}

///|
/// Updates loot bobbing phase timers used by pickup idle animation.
pub fn update_loot_bob(game : @types.Game, dt : Float) -> Unit {
  for l in game.loot {
    if !l.active {
      continue
    }
    l.bob_phase += dt * 3.0
  }
}
