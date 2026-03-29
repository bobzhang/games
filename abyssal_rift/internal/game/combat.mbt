///|
pub fn apply_damage_to_enemy(
  game : @types.Game,
  enemy_idx : Int,
  damage : Int,
  is_crit : Bool,
  knockback : Float
) -> Unit {
  let e = game.enemies[enemy_idx]
  let p = game.player
  let syn = game.synergies
  // Execute synergy: multiply damage against low-HP enemies
  let mut final_damage = damage
  if syn.execute && e.max_hp > 0 {
    let hp_ratio = Float::from_int(e.hp) / Float::from_int(e.max_hp)
    if hp_ratio < syn.execute_threshold {
      final_damage = (Float::from_int(damage) * syn.execute_mult).to_int()
    }
  }
  // Momentum synergy: scale damage with player movement speed
  if syn.momentum {
    let vel = @types.dist(0.0, 0.0, p.vx, p.vy)
    let max_spd = @types.player_base_speed * p.speed
    let speed_ratio = vel / max_spd
    let bonus : Float = (1.0 : Float) + speed_ratio * (0.5 : Float)
    final_damage = (Float::from_int(final_damage) * bonus).to_int()
  }
  // Elite Armored affix: reduce damage by 40%
  if e.is_elite && e.affix == Armored {
    final_damage = (Float::from_int(final_damage) * 0.6).to_int()
    if final_damage < 1 {
      final_damage = 1
    }
  }
  e.hp -= final_damage
  e.flash_timer = 0.1
  // Bleed on crit synergy: apply 2-second DOT
  if is_crit && syn.bleed_on_crit {
    e.bleed_timer = 2.0
  }
  // Knockback
  let (dx, dy) = @types.normalize(e.x - p.x, e.y - p.y)
  e.vx = dx * knockback
  e.vy = dy * knockback
  e.knockback_timer = @types.knockback_duration
  // Hit pause (scale with crit)
  game.hit_pause_timer = if is_crit {
    @types.hit_pause_duration * 2.5
  } else {
    @types.hit_pause_duration
  }
  // Events
  push_event(game, Hit(e.x, e.y, final_damage, is_crit))
  shake_camera(game, if is_crit { 4.0 } else { 2.0 }, 0.1)
  // Spawn damage number
  let idx = @types.alloc_damage_num(game.damage_numbers)
  let dn = game.damage_numbers[idx]
  dn.active = true
  dn.x = e.x
  dn.y = e.y - 20.0
  dn.vy = -80.0
  dn.life = 0.8
  dn.value = final_damage
  dn.is_crit = is_crit
  // LifeSteal: heal 10% of damage dealt
  if p.passives.contains(LifeSteal) {
    let heal_pct : Float = if p.passives.contains(Berserker) {
      let hp_ratio = Float::from_int(p.hp) / Float::from_int(p.max_hp)
      if hp_ratio < 0.3 { 0.2 } else { 0.1 } // Blood Rage synergy: doubled lifesteal
    } else {
      0.1
    }
    let heal = (Float::from_int(final_damage) * heal_pct).to_int()
    if heal > 0 {
      p.hp = @types.clampi(p.hp + heal, 0, p.max_hp)
    }
  }
  // Enemy hurt recoil
  if e.hp > 0 {
    e.state = Hurt(0.08)
  }
  // Chain Lightning synergy: also chains on non-lethal hits (30% chance)
  if e.hp > 0 && syn.chain_projectile {
    let (s, roll) = @types.rng_next(game.rng_state)
    game.rng_state = s
    if roll < 0.3 {
      spawn_chain_projectile(game, e.x, e.y, final_damage / 2)
    }
  }
  // Check death
  if e.hp <= 0 {
    e.state = Dead(0.5)
    game.enemies_killed += 1
    // Vampiric passive: kills heal 5 HP
    if p.passives.contains(Vampiric) {
      p.hp = @types.clampi(p.hp + 5, 0, p.max_hp)
    }
    // Vampiric synergy (PickupRange + MaxHpUp): heal 1 HP per kill
    if syn.vampiric {
      p.hp = @types.clampi(p.hp + 1, 0, p.max_hp)
    }
    // Chain projectile synergy: spawn projectile toward nearest living enemy
    if syn.chain_projectile {
      spawn_chain_projectile(game, e.x, e.y, final_damage)
    }
    // Elite Splitting affix: spawn 2 regular copies on death
    if e.is_elite && e.affix == Splitting {
      for _split in 0..<2 {
        let (s_sx, sx_off) = @types.rng_range(game.rng_state, -20.0, 20.0)
        let (s_sy, sy_off) = @types.rng_range(s_sx, -20.0, 20.0)
        game.rng_state = s_sy
        spawn_enemy(game, e.kind, e.x + sx_off, e.y + sy_off)
      }
    }
    // Elite Explosive affix: AoE damage to player if within range
    if e.is_elite && e.affix == Explosive {
      let explode_radius : Float = 80.0
      let explode_d2 = @types.dist2(e.x, e.y, p.x, p.y)
      if explode_d2 < explode_radius * explode_radius {
        let explode_dmg = @data.get_enemy_stats(e.kind, game.floor_num).damage
        damage_player(game, explode_dmg)
      }
      // Big particle burst for explosion
      spawn_particles_burst(game, e.x, e.y, 20, 255, 150, 30)
      shake_camera(game, 6.0, 0.2)
    }
    // Slime splits immediately so small slimes count before room-clear check
    if e.kind == Slime {
      spawn_small_slimes(game, e.x, e.y)
    }
    let stats = @data.get_enemy_stats(e.kind, game.floor_num)
    push_event(game, Kill(e.kind, e.x, e.y))
    // Drop gold (elites drop double)
    let gold_reward = if e.is_elite {
      stats.reward_gold * 2
    } else {
      stats.reward_gold
    }
    let item_idx = @types.alloc_item(game.items)
    let item = game.items[item_idx]
    item.active = true
    item.kind = Gold(gold_reward)
    item.x = e.x
    item.y = e.y
    item.bob_timer = 0.0
    // Elite guaranteed premium drop (build-directed)
    if e.is_elite {
      let (drop_kind, s_drop) = get_on_build_drop(p, game.rng_state)
      game.rng_state = s_drop
      let drop_idx = @types.alloc_item(game.items)
      let drop_item = game.items[drop_idx]
      drop_item.active = true
      drop_item.bob_timer = 0.0
      drop_item.kind = drop_kind
      drop_item.x = e.x
      drop_item.y = e.y - 15.0
    }
  }
  // ChainLightning: 20% chance to arc to nearby enemy
  if p.passives.contains(ChainLightning) {
    let (s, roll) = @types.rng_next(game.rng_state)
    game.rng_state = s
    if roll < 0.2 {
      let mut nearest_idx = -1
      let mut nearest_d2 : Float = 120.0 * 120.0
      for j in 0..<game.enemies.length() {
        if j == enemy_idx {
          continue
        }
        let other = game.enemies[j]
        if !other.active {
          continue
        }
        match other.state {
          Dead(_) => continue
          _ => ()
        }
        let d2 = @types.dist2(e.x, e.y, other.x, other.y)
        if d2 < nearest_d2 {
          nearest_d2 = d2
          nearest_idx = j
        }
      }
      if nearest_idx >= 0 {
        let chain_dmg = final_damage / 2
        let chain_e = game.enemies[nearest_idx]
        chain_e.hp -= chain_dmg
        chain_e.flash_timer = 0.1
        push_event(game, Hit(chain_e.x, chain_e.y, chain_dmg, false))
        // Spawn lightning visual
        spawn_particles_burst(game, chain_e.x, chain_e.y, 4, 150, 200, 255)
        if chain_e.hp <= 0 {
          chain_e.state = Dead(0.5)
          game.enemies_killed += 1
          push_event(game, Kill(chain_e.kind, chain_e.x, chain_e.y))
          // Vampiric also procs on chain kills
          if p.passives.contains(Vampiric) {
            p.hp = @types.clampi(p.hp + 5, 0, p.max_hp)
          }
        }
      }
    }
  }
}

///|
fn check_projectile_wall_collision(game : @types.Game, proj : @types.Projectile) -> Bool {
  match game.floor {
    None => false
    Some(floor) => {
      let tile = @dungeon.get_tile_at(floor, proj.x, proj.y)
      @dungeon.is_wall(tile)
    }
  }
}

///|
pub fn update_projectiles(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.projectiles.length() {
    let proj = game.projectiles[i]
    if !proj.active {
      continue
    }
    proj.lifetime -= dt
    if proj.lifetime <= 0.0 {
      proj.active = false
      continue
    }
    proj.x += proj.vx * dt
    proj.y += proj.vy * dt
    if check_projectile_wall_collision(game, proj) {
      proj.active = false
      continue
    }
    if proj.is_player {
      // Check collision with enemies
      for j in 0..<game.enemies.length() {
        let e = game.enemies[j]
        if !e.active {
          continue
        }
        match e.state {
          Dead(_) => continue
          _ => ()
        }
        let e_radius = @data.get_enemy_stats(e.kind, game.floor_num).radius
        let d2 = @types.dist2(proj.x, proj.y, e.x, e.y)
        let hit_r = proj.radius + e_radius
        if d2 <= hit_r * hit_r {
          apply_damage_to_enemy(game, j, proj.damage, proj.is_crit, 100.0)
          if !proj.piercing {
            proj.active = false
            break
          }
        }
      }
    } else {
      // Enemy projectile - check collision with player
      let p = game.player
      let d2 = @types.dist2(proj.x, proj.y, p.x, p.y)
      let hit_r = proj.radius + @types.player_radius
      if d2 <= hit_r * hit_r {
        damage_player(game, proj.damage)
        // Apply Poison only from projectiles tagged with poison_on_hit
        if proj.poison_on_hit {
          apply_status_effect(p, Poison(3.0))
        }
        proj.active = false
      }
    }
  }
}

///|
/// Spawn a chain projectile from a kill location toward the nearest living enemy.
fn spawn_chain_projectile(
  game : @types.Game,
  ox : Float,
  oy : Float,
  base_damage : Int
) -> Unit {
  let mut best_d2 : Float = 999999.0
  let mut best_idx : Int = -1
  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if !e.active {
      continue
    }
    match e.state {
      Dead(_) => continue
      _ => ()
    }
    let d2 = @types.dist2(ox, oy, e.x, e.y)
    if d2 < best_d2 {
      best_d2 = d2
      best_idx = i
    }
  }
  if best_idx < 0 {
    return
  }
  let target = game.enemies[best_idx]
  let (ndx, ndy) = @types.normalize(target.x - ox, target.y - oy)
  let proj_speed : Float = 400.0
  let pidx = @types.alloc_projectile(game.projectiles)
  let proj = game.projectiles[pidx]
  proj.active = true
  proj.x = ox
  proj.y = oy
  proj.vx = ndx * proj_speed
  proj.vy = ndy * proj_speed
  proj.damage = (Float::from_int(base_damage) * 0.5).to_int()
  proj.is_player = true
  proj.is_crit = false
  proj.piercing = false
  proj.homing = false
  proj.lifetime = 1.0
  proj.radius = 6.0
  proj.poison_on_hit = false
  spawn_particles_burst(game, ox, oy, 4, 150, 200, 255)
}

///|
pub fn update_damage_numbers(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.damage_numbers.length() {
    let dn = game.damage_numbers[i]
    if !dn.active {
      continue
    }
    dn.life -= dt
    if dn.life <= 0.0 {
      dn.active = false
      continue
    }
    dn.y += dn.vy * dt
    dn.vy *= 0.95
  }
}
