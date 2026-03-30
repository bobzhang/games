// Enemy spawning, movement, and special abilities

///|
fn @types.Game::start_wave(game : @types.Game, wave : Int) -> Unit {
  let def = @levels.get_wave_def(wave)
  game.wave_enemy_kind = def.0
  game.enemies_to_spawn = def.1
  game.wave_hp_mult = def.2
  game.wave_speed_mult = def.3
  game.enemies_spawned = 0
  game.spawn_timer = 0.0
  game.enemies_killed_this_wave = 0
  game.wave_active = true
  // Show wave message
  let info = @levels.get_wave_info(wave)
  @types.set_notification(game, info.wave_message, 3.0)
  game.wave_message = info.wave_message
  game.wave_message_timer = 3.0
}

///|
fn @types.Game::update_spawning(game : @types.Game, dt : Float) -> Unit {
  if game.enemies_spawned >= game.enemies_to_spawn {
    return
  }
  game.spawn_timer -= dt
  if game.spawn_timer <= 0.0 {
    game.spawn_enemy()
    // Swarm enemies spawn faster
    let interval : Float = match game.wave_enemy_kind {
      Swarm => @types.fast_spawn_interval
      _ => @types.spawn_interval
    }
    game.spawn_timer = interval
  }
}

///|
fn @types.Game::spawn_enemy(game : @types.Game) -> Unit {
  let idx = @types.alloc_enemy(game)
  if idx < 0 {
    return
  }
  let kind = game.wave_enemy_kind
  let kind_int = @types.enemy_kind_to_int(kind)
  let base_hp = @levels.enemy_base_hp(kind_int)
  let base_speed = @levels.enemy_base_speed(kind_int)
  let diff_hp = @types.difficulty_hp_mult(game.difficulty)
  let diff_speed = @types.difficulty_speed_mult(game.difficulty)
  let enemy = game.enemies[idx]
  enemy.active = true
  enemy.kind = kind
  enemy.hp = base_hp * game.wave_hp_mult * diff_hp
  enemy.max_hp = enemy.hp
  enemy.speed = base_speed * game.wave_speed_mult * diff_speed
  enemy.base_speed = enemy.speed
  enemy.armor = @types.enemy_armor_value(kind)
  enemy.path_index = 0
  enemy.path_progress = 0.0
  enemy.slow_timer = 0.0
  enemy.slow_factor = 1.0
  enemy.burn_timer = 0.0
  enemy.burn_dps = 0.0
  enemy.stun_timer = 0.0
  enemy.armor_break_timer = 0.0
  enemy.armor_break_factor = 1.0
  enemy.armor_broken = false
  enemy.chilled = false
  enemy.chill_timer = 0.0
  enemy.gold_value = @levels.enemy_gold_value(kind_int)
  enemy.score_value = @levels.enemy_score_value(kind_int)
  enemy.flying = @levels.enemy_is_flying(kind_int)
  enemy.is_boss = @levels.enemy_is_boss(kind_int)
  enemy.is_camo = @levels.enemy_is_camo(kind_int)
  enemy.spawn_children = @levels.enemy_spawns_children(kind_int)
  enemy.heal_timer = 0.0
  // Shield setup
  if @levels.enemy_has_shield(kind_int) {
    let shield_hp = @levels.enemy_shield_hp(
      kind_int,
      game.wave_hp_mult * diff_hp,
    )
    enemy.shield_hp = shield_hp
    enemy.shield_max = shield_hp
    enemy.shield_regen_timer = 0.0
  } else {
    enemy.shield_hp = 0.0
    enemy.shield_max = 0.0
    enemy.shield_regen_timer = 0.0
  }
  // Start at first path node
  if game.path_count > 0 {
    enemy.x = game.path_nodes[0].x
    enemy.z = game.path_nodes[0].z
  }
  let fly_height : Float = 3.0
  let ground_height : Float = 0.5
  enemy.y = if enemy.flying { fly_height } else { ground_height }
  game.enemies_spawned += 1
}

// Spawn child enemies from splitters

///|
fn @types.Game::spawn_splitter_children(
  game : @types.Game,
  parent : @types.Enemy,
) -> Unit {
  let child_count = @types.splitter_children
  for i in 0..<child_count {
    let idx = @types.alloc_enemy(game)
    if idx < 0 {
      return
    }
    let child = game.enemies[idx]
    child.active = true
    child.kind = Swarm
    child.hp = parent.max_hp * @types.splitter_child_hp_pct
    child.max_hp = child.hp
    child.speed = parent.base_speed * 1.3
    child.base_speed = child.speed
    child.armor = 0.0
    child.path_index = parent.path_index
    child.path_progress = parent.path_progress
    child.slow_timer = 0.0
    child.slow_factor = 1.0
    child.burn_timer = 0.0
    child.burn_dps = 0.0
    child.stun_timer = 0.0
    child.armor_break_timer = 0.0
    child.armor_break_factor = 1.0
    child.armor_broken = false
    child.chilled = false
    child.chill_timer = 0.0
    child.gold_value = 3
    child.score_value = 5
    child.flying = false
    child.is_boss = false
    child.is_camo = false
    child.spawn_children = false
    child.heal_timer = 0.0
    child.shield_hp = 0.0
    child.shield_max = 0.0
    child.shield_regen_timer = 0.0
    // Offset position slightly
    let offset_x = @types.rand_rangef(game, -0.5, 0.5)
    let offset_z = @types.rand_rangef(game, -0.5, 0.5)
    child.x = parent.x + offset_x
    child.y = 0.5
    child.z = parent.z + offset_z
    ignore(i)
  }
}

///|
fn @types.Game::update_enemies(game : @types.Game, dt : Float) -> Unit {
  // Update all enemies
  for i in 0..<game.enemies.length() {
    let enemy = game.enemies[i]
    if !enemy.active {
      continue
    }
    // Update status effects
    game.update_enemy_status_effects(enemy, dt)
    // Update healer ability
    if enemy.kind == Healer {
      game.update_healer(i, dt)
    }
    // Update shield regeneration
    if enemy.shield_max > 0.0 {
      update_enemy_shield(enemy, dt)
    }
    // Stun check - stunned enemies don't move
    if enemy.stun_timer > 0.0 {
      continue
    }
    // Move along path
    let effective_speed : Float = enemy.speed * enemy.slow_factor
    let speed = effective_speed * dt
    game.move_enemy_along_path(i, speed)
    // Check if reached end
    if enemy.path_index >= game.path_count - 1 && enemy.path_progress >= 1.0 {
      enemy.active = false
      let lives_lost : Int = if enemy.is_boss { 5 } else { 1 }
      game.lives -= lives_lost
    }
  }
}

///|
fn @types.Game::update_enemy_status_effects(
  game : @types.Game,
  enemy : @types.Enemy,
  dt : Float,
) -> Unit {
  // Update slow
  if enemy.slow_timer > 0.0 {
    enemy.slow_timer -= dt
    if enemy.slow_timer <= 0.0 {
      enemy.slow_factor = 1.0
    }
  }
  // Update burn (DOT damage)
  if enemy.burn_timer > 0.0 {
    enemy.burn_timer -= dt
    let burn_dmg = enemy.burn_dps * dt
    enemy.hp -= burn_dmg
    // Spawn fire particles occasionally
    if @types.rand_range(game, 0, 10) < 2 {
      @types.spawn_fire_particles(game, enemy.x, enemy.y, enemy.z)
    }
    if enemy.burn_timer <= 0.0 {
      enemy.burn_dps = 0.0
    }
  }
  // Update stun
  if enemy.stun_timer > 0.0 {
    enemy.stun_timer -= dt
  }
  // Update armor break
  if enemy.armor_break_timer > 0.0 {
    enemy.armor_break_timer -= dt
    if enemy.armor_break_timer <= 0.0 {
      enemy.armor_break_factor = 1.0
      enemy.armor_broken = false
    }
  }
  // Update chill (synergy tracking)
  if enemy.chill_timer > 0.0 {
    enemy.chill_timer -= dt
    if enemy.chill_timer <= 0.0 {
      enemy.chilled = false
    }
  }
  // Check death from burn
  if enemy.hp <= 0.0 && enemy.active {
    game.kill_enemy(enemy)
  }
}

///|
fn update_enemy_shield(enemy : @types.Enemy, dt : Float) -> Unit {
  if enemy.shield_hp < enemy.shield_max {
    enemy.shield_regen_timer += dt
    if enemy.shield_regen_timer >= @types.shield_regen_delay {
      enemy.shield_hp += @types.shield_regen_rate * dt
      if enemy.shield_hp > enemy.shield_max {
        enemy.shield_hp = enemy.shield_max
      }
    }
  }
}

///|
fn @types.Game::update_healer(
  game : @types.Game,
  healer_idx : Int,
  dt : Float,
) -> Unit {
  let healer = game.enemies[healer_idx]
  healer.heal_timer += dt
  if healer.heal_timer < @types.healer_heal_interval {
    return
  }
  healer.heal_timer = 0.0
  // Heal nearby allies
  for j in 0..<game.enemies.length() {
    if j == healer_idx {
      continue
    }
    let other = game.enemies[j]
    if !other.active {
      continue
    }
    let dist = @types.distance2d(healer.x, healer.z, other.x, other.z)
    if dist <= @types.healer_range {
      let heal_amount = @types.healer_heal_rate
      other.hp += heal_amount
      if other.hp > other.max_hp {
        other.hp = other.max_hp
      }
      // Visual feedback
      @types.spawn_particles_typed(
        game,
        other.x,
        other.y + 0.5,
        other.z,
        2,
        50,
        255,
        50,
        @types.particle_normal,
      )
    }
  }
}

///|
fn @types.Game::kill_enemy(game : @types.Game, enemy : @types.Enemy) -> Unit {
  enemy.active = false
  game.gold += enemy.gold_value
  game.score += enemy.score_value
  game.total_gold_earned += enemy.gold_value
  game.total_kills += 1
  game.enemies_killed_this_wave += 1
  // Spawn death particles
  @types.spawn_particles(game, enemy.x, enemy.y, enemy.z, 10, 255, 100, 50)
  @types.spawn_gold_particles(game, enemy.x, enemy.y + 0.5, enemy.z)
  // Floating gold text
  @types.spawn_floating_text(
    game,
    enemy.x,
    enemy.y + 1.2,
    enemy.z,
    enemy.gold_value,
    255,
    215,
    0,
    true,
  )
  // Splitter: spawn children
  if enemy.spawn_children {
    game.spawn_splitter_children(enemy)
  }
}

///|
fn @types.Game::move_enemy_along_path(
  game : @types.Game,
  idx : Int,
  speed : Float,
) -> Unit {
  let enemy = game.enemies[idx]
  if enemy.path_index >= game.path_count - 1 {
    enemy.path_progress = 1.0
    return
  }
  let p0 = game.path_nodes[enemy.path_index]
  let next_idx = enemy.path_index + 1
  if next_idx >= game.path_count {
    return
  }
  let p1 = game.path_nodes[next_idx]
  let seg_dx = p1.x - p0.x
  let seg_dz = p1.z - p0.z
  let seg_len = @types.distance2d(p0.x, p0.z, p1.x, p1.z)
  if seg_len < 0.01 {
    enemy.path_index += 1
    enemy.path_progress = 0.0
    return
  }
  let progress_add = speed / seg_len
  enemy.path_progress += progress_add
  if enemy.path_progress >= 1.0 {
    enemy.path_index += 1
    enemy.path_progress = 0.0
    if enemy.path_index < game.path_count {
      enemy.x = game.path_nodes[enemy.path_index].x
      enemy.z = game.path_nodes[enemy.path_index].z
    }
  } else {
    enemy.x = p0.x + seg_dx * enemy.path_progress
    enemy.z = p0.z + seg_dz * enemy.path_progress
  }
  ignore(seg_len)
}

///|
fn @types.Game::update_projectiles(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.projectiles.length() {
    let proj = game.projectiles[i]
    if !proj.active {
      continue
    }
    // Check if target still valid
    if proj.target_idx < 0 || !game.enemies[proj.target_idx].active {
      // Find nearest enemy as fallback
      for j, enemy in game.enemies; best = -1, best_dist = 999.0F {
        if !enemy.active {
          continue
        }
        let d = @types.distance3d(
          proj.x,
          proj.y,
          proj.z,
          enemy.x,
          enemy.y,
          enemy.z,
        )
        if d < best_dist {
          continue j, d
        }
      } nobreak {
        if best < 0 {
          proj.active = false
          continue
        }
        proj.target_idx = best
      }
    }
    let target = game.enemies[proj.target_idx]
    let dx = target.x - proj.x
    let dy = target.y - proj.y
    let dz = target.z - proj.z
    let dist = @types.distance3d(
      proj.x,
      proj.y,
      proj.z,
      target.x,
      target.y,
      target.z,
    )
    if dist < 0.5 {
      // Hit!
      game.apply_projectile_hit(i)
      proj.active = false
      continue
    }
    // Move towards target
    let move_dist = proj.speed * dt
    if dist > 0.01 {
      proj.x += dx / dist * move_dist
      proj.y += dy / dist * move_dist
      proj.z += dz / dist * move_dist
    }
    ignore(dy)
  }
}

///|
fn @types.Game::apply_projectile_hit(
  game : @types.Game,
  proj_idx : Int,
) -> Unit {
  let proj = game.projectiles[proj_idx]
  // Determine tower kind for resistance calculation
  let tower_kind = proj.kind
  // Compute splash radius with buff amplification
  let mut effective_splash = proj.splash_radius
  if effective_splash > 0.0 &&
    proj.tower_idx >= 0 &&
    proj.tower_idx < game.towers.length() {
    let src_tower = game.towers[proj.tower_idx]
    if src_tower.active &&
      (src_tower.kind == Cannon || src_tower.kind == Splash) {
      let buff_level = @types.find_nearby_buff_level(
        game,
        src_tower.gx,
        src_tower.gy,
      )
      if buff_level > 0 {
        effective_splash = effective_splash *
          (
            1.0 +
            Float::from_int(buff_level) *
            (@types.buff_amplify_splash_radius - 1.0) /
            3.0
          )
      }
    }
  }
  if effective_splash > 0.0 {
    // Splash damage
    for i in 0..<game.enemies.length() {
      let enemy = game.enemies[i]
      if !enemy.active {
        continue
      }
      let dist = @types.distance2d(proj.x, proj.z, enemy.x, enemy.z)
      if dist <= effective_splash {
        let dmg_factor : Float = 1.0 - dist / effective_splash
        let raw_damage = proj.damage * dmg_factor
        // Synergy: Sniper armor-break + Splash/Cannon bonus (applied post-armor)
        let synergy_mult : Float = if enemy.armor_broken {
          @types.synergy_armor_break_splash_mult
        } else {
          1.0
        }
        let actual_damage = @types.calc_damage(raw_damage, tower_kind, enemy) *
          synergy_mult
        game.damage_enemy(i, actual_damage, proj.tower_idx)
        // Apply splash status effects
        game.apply_projectile_effects(proj, i)
        // Show armor-break synergy combo indicator
        if enemy.armor_broken && synergy_mult > 1.0 {
          game.show_synergy_combo(
            proj.tower_idx,
            enemy,
            "ARMOR BREAK!",
            255,
            140,
            0,
          )
        }
      }
    }
    @types.spawn_explosion_particles(game, proj.x, proj.y, proj.z, 12)
  } else if proj.chain_count > 0 {
    // Chain lightning (synergy applied inside apply_chain_lightning)
    game.apply_chain_lightning(proj)
    // Single target
  } else if proj.target_idx >= 0 && game.enemies[proj.target_idx].active {
    let enemy = game.enemies[proj.target_idx]
    let raw_damage : Float = if proj.is_crit {
      proj.damage * @types.sniper_crit_mult
    } else {
      proj.damage
    }
    // Synergy multipliers applied post-armor so they scale correctly
    let mut synergy_mult : Float = 1.0
    // Synergy: Frost + Lightning -- chilled enemies take extra lightning damage
    if tower_kind == Lightning && enemy.chilled {
      synergy_mult = @types.synergy_frost_lightning_mult
    }
    // Synergy: Sniper armor-break + Splash/Cannon bonus (for non-splash single target cannon)
    if (tower_kind == Cannon || tower_kind == Splash) && enemy.armor_broken {
      synergy_mult = @types.synergy_armor_break_splash_mult
    }
    let actual_damage = @types.calc_damage(raw_damage, tower_kind, enemy) *
      synergy_mult
    game.damage_enemy(proj.target_idx, actual_damage, proj.tower_idx)
    // Apply status effects
    game.apply_projectile_effects(proj, proj.target_idx)
    // Show synergy combo indicator
    if tower_kind == Lightning && enemy.chilled && synergy_mult > 1.0 {
      game.show_synergy_combo(
        proj.tower_idx,
        enemy,
        "FROST+ZAP!",
        100,
        200,
        255,
      )
    }
    if (tower_kind == Cannon || tower_kind == Splash) &&
      enemy.armor_broken &&
      synergy_mult > 1.0 {
      game.show_synergy_combo(
        proj.tower_idx,
        enemy,
        "ARMOR BREAK!",
        255,
        140,
        0,
      )
    }
    // Crit visual
    if proj.is_crit {
      @types.spawn_particles(
        game,
        enemy.x,
        enemy.y + 1.0,
        enemy.z,
        8,
        255,
        50,
        50,
      )
    }
  }
}

///|
fn @types.Game::apply_projectile_effects(
  game : @types.Game,
  proj : @types.Projectile,
  enemy_idx : Int,
) -> Unit {
  let enemy = game.enemies[enemy_idx]
  // Slow effect - take strongest slow, don't blindly overwrite
  if proj.slow_amount > 0.0 {
    // Boss enemies are more resistant to slow
    let slow_effectiveness : Float = if enemy.is_boss { 0.5 } else { 1.0 }
    let slow_amt = proj.slow_amount * slow_effectiveness
    let new_factor : Float = 1.0 - slow_amt
    // Only apply if this slow is stronger (lower factor) or current slow expired
    if new_factor < enemy.slow_factor || enemy.slow_timer <= 0.0 {
      enemy.slow_factor = new_factor
    }
    // Buff tower amplification: nearby buff tower extends slow duration
    let mut slow_dur = proj.slow_duration
    if proj.tower_idx >= 0 && proj.tower_idx < game.towers.length() {
      let src_tower = game.towers[proj.tower_idx]
      if src_tower.active {
        let buff_level = @types.find_nearby_buff_level(
          game,
          src_tower.gx,
          src_tower.gy,
        )
        if buff_level > 0 {
          slow_dur = slow_dur *
            (
              1.0 +
              Float::from_int(buff_level) *
              (@types.buff_amplify_slow_duration - 1.0) /
              3.0
            )
        }
      }
    }
    // Always refresh duration
    enemy.slow_timer = @types.maxf(enemy.slow_timer, slow_dur)
    @types.spawn_ice_particles(game, enemy.x, enemy.y, enemy.z)
    // Frost tower: mark enemy as chilled for synergy
    if proj.kind == Frost {
      enemy.chilled = true
      enemy.chill_timer = @types.chill_duration
    }
  }
  // Burn effect
  if proj.burn_damage > 0.0 {
    enemy.burn_dps = proj.burn_damage
    enemy.burn_timer = proj.burn_duration
    @types.spawn_fire_particles(game, enemy.x, enemy.y, enemy.z)
  }
  // Stun effect
  if proj.stun_chance > 0.0 {
    if @types.rand_bool(game, proj.stun_chance) {
      // Bosses can't be stunned
      if !enemy.is_boss {
        enemy.stun_timer = proj.stun_duration
        @types.spawn_particles(
          game,
          enemy.x,
          enemy.y + 1.0,
          enemy.z,
          5,
          255,
          255,
          0,
        )
      }
    }
  }
  // Sniper: armor break effect for synergy with splash/cannon
  if proj.kind == Sniper {
    // All snipers apply armor break for synergy tracking
    enemy.armor_broken = true
    enemy.armor_break_timer = @types.synergy_armor_break_duration
    // Level 3 snipers apply a stronger armor reduction factor
    if proj.tower_idx >= 0 && proj.tower_idx < game.towers.length() {
      let sniper_tower = game.towers[proj.tower_idx]
      if sniper_tower.active && sniper_tower.level >= 3 {
        enemy.armor_break_factor = 0.4
        // Lower levels get a weaker armor break
      } else if enemy.armor_break_factor > 0.7 {
        enemy.armor_break_factor = 0.7
      }
    } else if enemy.armor_break_factor > 0.7 {
      enemy.armor_break_factor = 0.7
    }
    @types.spawn_particles(
      game,
      enemy.x,
      enemy.y + 0.5,
      enemy.z,
      4,
      255,
      140,
      0,
    )
    @types.spawn_break_flash(game, enemy.x, enemy.y, enemy.z, 255, 140, 0)
  }
  ignore(game)
}

///|
fn @types.Game::apply_chain_lightning(
  game : @types.Game,
  proj : @types.Projectile,
) -> Unit {
  let mut current_target = proj.target_idx
  let mut current_damage = proj.damage
  let chains = proj.chain_count
  let mut prev_x = proj.x
  let mut prev_y = proj.y
  let mut prev_z = proj.z
  // Hit initial target
  if current_target >= 0 && game.enemies[current_target].active {
    let enemy = game.enemies[current_target]
    // Frost+Lightning synergy: bonus damage to chilled enemies (applied post-armor)
    let synergy_mult = chain_synergy_mult(enemy)
    let actual_damage = @types.calc_damage(current_damage, Lightning, enemy) *
      synergy_mult
    game.damage_enemy(current_target, actual_damage, proj.tower_idx)
    if enemy.chilled {
      game.show_synergy_combo(
        proj.tower_idx,
        enemy,
        "FROST+ZAP!",
        100,
        200,
        255,
      )
    }
    @types.spawn_lightning_particles(game, enemy.x, enemy.y, enemy.z)
    // Add chain line visual
    @types.add_chain_line(
      game,
      prev_x,
      prev_y,
      prev_z,
      enemy.x,
      enemy.y,
      enemy.z,
    )
    prev_x = enemy.x
    prev_y = enemy.y
    prev_z = enemy.z
  }
  // Chain to nearby enemies
  let visited = Array::make(game.enemies.length(), false)
  if current_target >= 0 {
    visited[current_target] = true
  }
  for c in 0..<chains {
    current_damage = current_damage * @types.chain_damage_decay
    // Find nearest unvisited enemy within chain range
    for
      j, enemy in game.enemies
      best = -1, best_dist = @types.chain_range + 1.0F {
      if !enemy.active {
        continue
      }
      if visited[j] {
        continue
      }
      let dist = @types.distance2d(prev_x, prev_z, enemy.x, enemy.z)
      if dist <= @types.chain_range && dist < best_dist {
        continue j, dist
      }
    } nobreak {
      if best < 0 {
        // No more targets to chain to
        ignore(c)
        return
      }
      visited[best] = true
      let enemy = game.enemies[best]
      // Frost+Lightning synergy on chain bounces too (applied post-armor)
      let synergy_chain_mult = chain_synergy_mult(enemy)
      let actual_damage = @types.calc_damage(current_damage, Lightning, enemy) *
        synergy_chain_mult
      game.damage_enemy(best, actual_damage, proj.tower_idx)
      if enemy.chilled {
        game.show_synergy_combo(
          proj.tower_idx,
          enemy,
          "FROST+ZAP!",
          100,
          200,
          255,
        )
      }
      @types.spawn_lightning_particles(game, enemy.x, enemy.y, enemy.z)
      @types.add_chain_line(
        game,
        prev_x,
        prev_y,
        prev_z,
        enemy.x,
        enemy.y,
        enemy.z,
      )
      prev_x = enemy.x
      prev_y = enemy.y
      prev_z = enemy.z
      current_target = best
      ignore(c)
    }
  }
}

///|
fn @types.Game::damage_enemy(
  game : @types.Game,
  idx : Int,
  damage : Float,
  tower_idx : Int,
) -> Unit {
  let enemy = game.enemies[idx]
  // Determine if this is a crit for floating text color
  let is_crit = tower_idx >= 0 &&
    tower_idx < game.towers.length() &&
    game.towers[tower_idx].active &&
    game.towers[tower_idx].kind == Sniper &&
    damage > @types.tower_effective_damage(game.towers[tower_idx]) * 1.5
  // Spawn floating damage number (white=normal, gold=crit)
  let ft_r = if is_crit { 255 } else { 255 }
  let ft_g = if is_crit { 215 } else { 255 }
  let ft_b = if is_crit { 0 } else { 255 }
  @types.spawn_floating_text(
    game,
    enemy.x,
    enemy.y + 0.8,
    enemy.z,
    damage.to_int(),
    ft_r,
    ft_g,
    ft_b,
    false,
  )
  // Apply damage to shield first
  let mut remaining_damage = damage
  let had_shield = enemy.shield_hp > 0.0
  if enemy.shield_hp > 0.0 {
    if remaining_damage <= enemy.shield_hp {
      enemy.shield_hp -= remaining_damage
      enemy.shield_regen_timer = 0.0
      // Shield absorbed all damage
      @types.spawn_particles(
        game,
        enemy.x,
        enemy.y + 0.3,
        enemy.z,
        3,
        100,
        150,
        255,
      )
      // Track damage on tower
      if tower_idx >= 0 &&
        tower_idx < game.towers.length() &&
        game.towers[tower_idx].active {
        game.towers[tower_idx].total_damage += damage
        game.damage_dealt += damage
      }
      return
    }
    remaining_damage -= enemy.shield_hp
    enemy.shield_hp = 0.0
    enemy.shield_regen_timer = 0.0
  }
  // Shield break flash: blue flash when shield fully depletes
  if had_shield && enemy.shield_hp <= 0.0 {
    @types.spawn_break_flash(game, enemy.x, enemy.y, enemy.z, 100, 150, 255)
  }
  enemy.hp -= remaining_damage
  // Track damage on tower
  if tower_idx >= 0 &&
    tower_idx < game.towers.length() &&
    game.towers[tower_idx].active {
    game.towers[tower_idx].total_damage += damage
    game.damage_dealt += damage
  }
  if enemy.hp <= 0.0 {
    // Track kill on tower
    if tower_idx >= 0 &&
      tower_idx < game.towers.length() &&
      game.towers[tower_idx].active {
      game.towers[tower_idx].kills += 1
    }
    game.kill_enemy(enemy)
  }
}
