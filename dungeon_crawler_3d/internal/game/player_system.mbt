// Player movement and combat

///|
/// Updates player movement, combat input, spell usage, and interaction checks for one frame.
pub fn update_player(game : @types.Game, dt : Float) -> Unit {
  // Mouse look
  let mouse_delta = @raylib.get_mouse_delta()
  let mouse_dx = mouse_delta.x
  let mouse_dy = mouse_delta.y
  game.camera_yaw -= mouse_dx * 0.003
  game.camera_pitch -= mouse_dy * 0.003
  // Clamp pitch
  game.camera_pitch = @types.clampf(game.camera_pitch, -1.2, 1.2)
  // Movement direction
  let forward_x = @math.sinf(game.camera_yaw)
  let forward_z = @math.cosf(game.camera_yaw)
  let right_x = @math.cosf(game.camera_yaw)
  let right_z = -@math.sinf(game.camera_yaw)
  let mut move_x : Float = 0.0
  let mut move_z : Float = 0.0
  if @raylib.is_key_down(@raylib.KeyW) {
    move_x += forward_x
    move_z += forward_z
  }
  if @raylib.is_key_down(@raylib.KeyS) {
    move_x -= forward_x
    move_z -= forward_z
  }
  if @raylib.is_key_down(@raylib.KeyA) {
    move_x -= right_x
    move_z -= right_z
  }
  if @raylib.is_key_down(@raylib.KeyD) {
    move_x += right_x
    move_z += right_z
  }
  // Sprint
  game.sprinting = @raylib.is_key_down(@raylib.KeyLeftShift)
  // Normalize movement
  let move_len = @math.hypotf(move_x, move_z)
  if move_len > 0.01 {
    move_x = move_x / move_len
    move_z = move_z / move_len
  }
  // Calculate speed with sprint and buffs
  let mut speed_mult : Float = 1.0
  if game.sprinting {
    speed_mult = @types.player_sprint_mult
  }
  // Check for speed buff
  if @types.has_buff(game, @types.buff_speed) {
    speed_mult *= 1.3
  }
  let speed = @types.player_speed * speed_mult * dt
  let new_x = game.player_x + move_x * speed
  let new_z = game.player_z + move_z * speed
  // Collision detection - try X then Z separately for sliding
  let radius : Float = 0.3
  if !@types.is_blocked(game, new_x, game.player_z, radius) {
    game.player_x = new_x
  }
  if !@types.is_blocked(game, game.player_x, new_z, radius) {
    game.player_z = new_z
  }
  // Attack cooldown timer
  if game.attack_cooldown_timer > 0.0 {
    game.attack_cooldown_timer -= dt
    if game.attack_cooldown_timer < 0.0 {
      game.attack_cooldown_timer = 0.0
    }
  }
  // Sword swing animation
  if game.swing_timer > 0.0 {
    game.swing_timer -= dt
    if game.swing_timer <= 0.0 {
      game.swing_timer = 0.0
      game.swing_active = false
    }
  }
  // Weapon attack (LMB / Space)
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.attack_cooldown_timer <= 0.0 {
      if game.player_weapon == Bow {
        game.perform_bow_attack()
      } else {
        game.perform_melee_attack()
      }
      game.attack_cooldown_timer = @types.get_weapon_cooldown(
        game.player_weapon,
      )
      game.swing_active = true
      game.swing_timer = @types.swing_duration
    }
  }
  // Spell casting (RMB or Q)
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) ||
    @raylib.is_key_pressed(@raylib.KeyQ) {
    game.cast_selected_spell()
  }
  // Spell cooldown
  if game.spell_cooldown > 0.0 {
    game.spell_cooldown -= dt
    if game.spell_cooldown < 0.0 {
      game.spell_cooldown = 0.0
    }
  }
  // Cycle weapon with Tab
  if @raylib.is_key_pressed(@raylib.KeyTab) {
    game.player_weapon = @types.next_weapon(game.player_weapon)
    @types.add_message(
      game,
      "Weapon: \{@types.get_weapon_name(game.player_weapon)}",
      200,
      200,
      255,
    )
  }
  // Cycle spells with 1-6 keys
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    game.selected_spell = 0
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) {
    game.selected_spell = 1
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) {
    game.selected_spell = 2
  }
  if @raylib.is_key_pressed(@raylib.KeyFour) {
    game.selected_spell = 3
  }
  if @raylib.is_key_pressed(@raylib.KeyFive) {
    game.selected_spell = 4
  }
  if @raylib.is_key_pressed(@raylib.KeySix) {
    game.selected_spell = 5
  }
  // Mana regeneration (ring of wisdom boosts regen)
  // Uses accumulator to avoid truncating fractional regen each frame
  let ring_mana_bonus : Float = if game.equip_ring_kind == @types.ring_mana_regen {
    Float::from_int(game.equip_ring_bonus) * 0.3
  } else {
    0.0
  }
  game.mana_regen_accum += (@types.mana_regen_rate + ring_mana_bonus) * dt
  if game.mana_regen_accum >= 1.0 {
    let whole = game.mana_regen_accum.to_int()
    game.player_mana = (game.player_mana + whole).min(game.player_max_mana)
    game.mana_regen_accum -= Float::from_int(whole)
  }
  // Pickup loot
  game.check_loot_pickup()
  // Check stairs
  game.check_stairs()
  // Check chest interaction
  if @raylib.is_key_pressed(@raylib.KeyE) {
    game.check_chest_open()
    game.check_door_interact()
    game.check_shop_interact()
    game.check_shrine_interact()
  }
  // Check traps
  game.check_traps(dt)
  // Update buffs
  @types.update_buffs(game, dt)
  // Update messages
  @types.update_messages(game, dt)
  // Update explored tiles
  @types.update_explored(game)
  // Update poison
  if game.poison_remaining > 0.0 {
    game.poison_remaining -= dt
    game.poison_timer += dt
    if game.poison_timer >= 1.0 {
      game.poison_timer -= 1.0
      game.player_hp -= @types.poison_damage_per_sec
      @types.spawn_particles(
        game,
        game.player_x,
        1.0,
        game.player_z,
        3,
        100,
        200,
        50,
      )
    }
    if game.poison_remaining <= 0.0 {
      game.poison_remaining = 0.0
      game.poison_timer = 0.0
    }
  }
  // Update hit flash
  if game.player_hit_flash > 0.0 {
    game.player_hit_flash -= dt
    if game.player_hit_flash < 0.0 {
      game.player_hit_flash = 0.0
    }
  }
  // Update damage flash
  if game.damage_flash > 0.0 {
    game.damage_flash -= dt
    if game.damage_flash < 0.0 {
      game.damage_flash = 0.0
    }
  }
  // Check death
  if game.player_hp <= 0 {
    game.state = StateGameOver
    @raylib.enable_cursor()
  }
  // Check level up
  if game.player_xp >= game.player_xp_next {
    game.level_up()
  }
}

///|
fn @types.Game::perform_melee_attack(game : @types.Game) -> Unit {
  let attack_dir_x = @math.sinf(game.camera_yaw)
  let attack_dir_z = @math.cosf(game.camera_yaw)
  let weapon_range = @types.get_weapon_range(game.player_weapon)
  // Weapon-specific hit cone: axes/maces have wider, daggers narrower
  let cone_dot_threshold : Float = match game.player_weapon {
    Axe => -0.2 // Very wide ~120 degree cone
    Mace => -0.1 // Wide cone
    Dagger => 0.3 // Narrow, precise stab
    Staff => 0.1 // Medium cone
    _ => 0.0 // 90 degree default
  }
  let mut hit_any = false
  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if !e.active {
      continue
    }
    let dist = @types.dist2d(game.player_x, game.player_z, e.x, e.z)
    if dist > weapon_range {
      continue
    }
    let dx = e.x - game.player_x
    let dz = e.z - game.player_z
    let dot = dx * attack_dir_x + dz * attack_dir_z
    if dot < cone_dot_threshold {
      continue
    }
    // Hit! Use equipment-enhanced attack
    let raw_atk = @types.calc_player_attack_with_equip(game)
    let damage = (1).max(raw_atk - e.def)
    // Critical hit chance: dagger bonus + ring of precision
    let base_crit = game.player_dex / 2
    let ring_crit = if game.equip_ring_kind == @types.ring_crit_chance {
      game.equip_ring_bonus
    } else {
      0
    }
    let crit_chance = match game.player_weapon {
      Dagger => base_crit + 15 + ring_crit
      _ => base_crit + ring_crit
    }
    let is_crit = @types.rand_range(game, 0, 99) < crit_chance
    let final_damage = if is_crit { damage * 2 } else { damage }
    e.hp -= final_damage
    e.hit_flash = 0.3
    e.alerted = true
    hit_any = true
    // Life steal ring: heal on hit
    if game.equip_ring_kind == @types.ring_life_steal && game.equip_ring_bonus > 0 {
      let heal = final_damage * game.equip_ring_bonus / 20
      if heal > 0 {
        game.player_hp = (game.player_hp + heal).min(game.player_max_hp)
        @types.spawn_particles(
          game, game.player_x, 1.5, game.player_z, 2, 50, 200, 50,
        )
      }
    }
    // Weapon-specific hit effects
    match game.player_weapon {
      Sword => {
        // Clean slash particles
        @types.spawn_particles(game, e.x, 1.0, e.z, 8, 220, 220, 240)
        @types.trigger_shake(game, 0.04, 0.12)
        @types.apply_knockback(game, e, game.player_x, game.player_z, 0.3)
      }
      Axe => {
        // Heavy impact with ground-shake
        @types.spawn_particles(game, e.x, 0.8, e.z, 12, 180, 140, 100)
        @types.spawn_particles(game, e.x, 0.3, e.z, 6, 140, 100, 60)
        @types.trigger_shake(game, 0.10, 0.25)
        @types.apply_knockback(game, e, game.player_x, game.player_z, 0.8)
        e.stun_timer = 0.3 // Axes stagger enemies briefly
      }
      Mace => {
        // Crushing blow, stun-focused
        @types.spawn_particles(game, e.x, 1.0, e.z, 10, 200, 200, 220)
        @types.trigger_shake(game, 0.08, 0.20)
        @types.apply_knockback(game, e, game.player_x, game.player_z, 0.6)
        e.stun_timer = 0.5 // Maces stun longer
      }
      Dagger => {
        // Quick precise stab, minimal particles, no knockback
        @types.spawn_particles(game, e.x, 1.1, e.z, 4, 255, 50, 50)
        @types.trigger_shake(game, 0.02, 0.06)
      }
      Staff => {
        // Magical impact
        @types.spawn_particles(game, e.x, 1.2, e.z, 8, 150, 100, 255)
        @types.trigger_shake(game, 0.03, 0.10)
        @types.apply_knockback(game, e, game.player_x, game.player_z, 0.4)
      }
      _ => {
        @types.spawn_particles(game, e.x, 1.0, e.z, 8, 255, 50, 50)
        @types.trigger_shake(game, 0.04, 0.12)
      }
    }
    // Floating damage number
    if is_crit {
      @types.spawn_damage_number(
        game, e.x, 2.0, e.z, final_damage, 255, 215, 0, true,
      )
      @types.add_message(
        game,
        "CRITICAL HIT! \{final_damage} damage to \{@types.get_enemy_name(e.kind)}!",
        255,
        215,
        0,
      )
      @types.spawn_particles(game, e.x, 1.5, e.z, 8, 255, 215, 0)
    } else {
      @types.spawn_damage_number(
        game, e.x, 1.8, e.z, final_damage, 255, 200, 80, false,
      )
      @types.add_message(
        game,
        "Hit \{@types.get_enemy_name(e.kind)} for \{final_damage}!",
        255,
        200,
        80,
      )
    }
    if e.hp <= 0 {
      kill_enemy(game, i)
    }
  }
  if hit_any {
    let px = game.player_x + attack_dir_x * 1.5
    let pz = game.player_z + attack_dir_z * 1.5
    @types.spawn_particles(game, px, 1.2, pz, 4, 255, 255, 100)
  }
}

///|
fn @types.Game::perform_bow_attack(game : @types.Game) -> Unit {
  let idx = @types.alloc_projectile(game)
  if idx < 0 {
    return
  }
  let p = game.projectiles[idx]
  p.active = true
  p.kind = None
  p.x = game.player_x
  p.z = game.player_z
  let dir_x = @math.sinf(game.camera_yaw)
  let dir_z = @math.cosf(game.camera_yaw)
  p.vx = dir_x * @types.projectile_speed * 1.5
  p.vz = dir_z * @types.projectile_speed * 1.5
  let raw_atk = @types.calc_player_attack(game)
  p.damage = raw_atk
  p.lifetime = @types.projectile_lifetime
  p.from_enemy = false
  p.aoe_radius = 0.0
  p.slow_on_hit = false
  @types.spawn_directional_particles(
    game,
    game.player_x,
    1.2,
    game.player_z,
    dir_x,
    dir_z,
    4,
    200,
    180,
    100,
    3.0,
  )
}

///|
fn @types.Game::cast_selected_spell(game : @types.Game) -> Unit {
  if game.selected_spell < 0 || game.selected_spell >= game.spells.length() {
    return
  }
  let slot = game.spells[game.selected_spell]
  if !slot.active {
    @types.add_message(game, "No spell in this slot!", 200, 100, 100)
    return
  }
  if game.spell_cooldown > 0.0 {
    return
  }
  let spell_type = slot.spell_type
  let cost = @types.get_spell_mana_cost(spell_type)
  if game.player_mana < cost {
    @types.add_message(game, "Not enough mana!", 100, 100, 255)
    return
  }
  game.player_mana -= cost
  game.spell_cooldown = 0.5
  match spell_type {
    Fireball => game.cast_fireball()
    IceBolt => game.cast_ice_bolt()
    Heal => game.cast_heal()
    Shield => game.cast_shield()
    Lightning => game.cast_lightning()
    Teleport => game.cast_teleport()
    _ => ()
  }
}

///|
fn @types.Game::cast_fireball(game : @types.Game) -> Unit {
  let idx = @types.alloc_projectile(game)
  if idx < 0 {
    return
  }
  let p = game.projectiles[idx]
  p.active = true
  p.kind = Fireball
  p.x = game.player_x
  p.z = game.player_z
  let dir_x = @math.sinf(game.camera_yaw)
  let dir_z = @math.cosf(game.camera_yaw)
  p.vx = dir_x * 10.0
  p.vz = dir_z * 10.0
  let int_bonus = game.player_int_stat / 2
  p.damage = @types.fireball_damage + int_bonus
  p.lifetime = 2.0
  p.from_enemy = false
  p.aoe_radius = @types.fireball_radius
  p.slow_on_hit = false
  // Fire launch effect: big burst + screen kick
  @types.trigger_shake(game, 0.05, 0.12)
  @types.spawn_directional_particles(
    game,
    game.player_x,
    1.2,
    game.player_z,
    dir_x,
    dir_z,
    12,
    255,
    100,
    30,
    5.0,
  )
  @types.spawn_particles(game, game.player_x, 1.0, game.player_z, 6, 255, 60, 10)
  @types.add_message(game, "Fireball!", 255, 100, 30)
}

///|
fn @types.Game::cast_ice_bolt(game : @types.Game) -> Unit {
  let idx = @types.alloc_projectile(game)
  if idx < 0 {
    return
  }
  let p = game.projectiles[idx]
  p.active = true
  p.kind = IceBolt
  p.x = game.player_x
  p.z = game.player_z
  let dir_x = @math.sinf(game.camera_yaw)
  let dir_z = @math.cosf(game.camera_yaw)
  p.vx = dir_x * 12.0
  p.vz = dir_z * 12.0
  let int_bonus = game.player_int_stat / 3
  p.damage = @types.ice_bolt_damage + int_bonus
  p.lifetime = 2.5
  p.from_enemy = false
  p.aoe_radius = 1.5 // Small frost AOE on impact
  p.slow_on_hit = true
  // Frost crystallization launch effect
  @types.spawn_directional_particles(
    game,
    game.player_x,
    1.2,
    game.player_z,
    dir_x,
    dir_z,
    8,
    100,
    180,
    255,
    4.0,
  )
  @types.spawn_particles(game, game.player_x, 1.3, game.player_z, 4, 200, 240, 255)
  @types.add_message(game, "Ice Bolt!", 100, 180, 255)
}

///|
fn @types.Game::cast_heal(game : @types.Game) -> Unit {
  let int_bonus = game.player_int_stat / 2
  let heal = @types.heal_amount + int_bonus
  game.player_hp = (game.player_hp + heal).min(game.player_max_hp)
  // Green healing aura burst: upward rising particles
  @types.spawn_particles(
    game,
    game.player_x,
    0.5,
    game.player_z,
    20,
    50,
    255,
    80,
  )
  // Secondary golden sparkles
  @types.spawn_particles(
    game,
    game.player_x,
    1.5,
    game.player_z,
    8,
    200,
    255,
    100,
  )
  // Healing damage number (positive)
  @types.spawn_damage_number(
    game, game.player_x, 2.0, game.player_z, heal, 50, 255, 80, false,
  )
  @types.add_message(game, "Healed for \{heal} HP!", 50, 255, 80)
}

///|
fn @types.Game::cast_shield(game : @types.Game) -> Unit {
  let int_bonus = game.player_int_stat / 4
  let bonus = @types.shield_defense_bonus + int_bonus
  @types.add_buff(
    game,
    @types.buff_shield,
    @types.shield_duration,
    bonus,
  )
  // Blue protective aura burst
  @types.spawn_particles(
    game,
    game.player_x,
    0.5,
    game.player_z,
    16,
    80,
    130,
    255,
  )
  @types.spawn_particles(
    game,
    game.player_x,
    1.2,
    game.player_z,
    10,
    120,
    180,
    255,
  )
  // Shield defense indicator
  @types.spawn_damage_number(
    game, game.player_x, 2.0, game.player_z, bonus, 100, 150, 255, false,
  )
  @types.add_message(game, "Shield activated! +\{bonus} DEF", 100, 150, 255)
}

///|
fn @types.Game::cast_lightning(game : @types.Game) -> Unit {
  // Hit nearest enemy in front of player
  let attack_dir_x = @math.sinf(game.camera_yaw)
  let attack_dir_z = @math.cosf(game.camera_yaw)
  let int_bonus = game.player_int_stat / 2
  let damage = @types.lightning_damage + int_bonus
  let hit_idx = for
    i in 0..<game.enemies.length()
    hit_idx = -1, best_dist = 15.0F {
    let e = game.enemies[i]
    if !e.active {
      continue
    }
    let dist = @types.dist2d(game.player_x, game.player_z, e.x, e.z)
    if dist > 12.0 {
      continue
    }
    let dx = e.x - game.player_x
    let dz = e.z - game.player_z
    let dot = dx * attack_dir_x + dz * attack_dir_z
    if dot > 0.0 && dist < best_dist {
      continue i, dist
    }
  } nobreak {
    hit_idx
  }
  if hit_idx >= 0 {
    let e = game.enemies[hit_idx]
    let dmg = (1).max(damage - e.def)
    e.hp -= dmg
    e.hit_flash = 0.4
    e.alerted = true
    e.stun_timer = 0.7 // Lightning has longer stun
    // Intense electric burst
    @types.trigger_shake(game, 0.15, 0.20)
    @types.spawn_particles(game, e.x, 1.5, e.z, 16, 255, 255, 100)
    @types.spawn_particles(game, e.x, 1.0, e.z, 8, 200, 200, 255)
    @types.spawn_damage_number(
      game, e.x, 2.0, e.z, dmg, 255, 255, 100, true,
    )
    @types.add_message(
      game,
      "Lightning hits \{@types.get_enemy_name(e.kind)} for \{dmg}!",
      255,
      255,
      100,
    )
    if e.hp <= 0 {
      kill_enemy(game, hit_idx)
    }
    // Chain to nearby enemies
    let chain_x = e.x
    let chain_z = e.z
    for j in 0..<game.enemies.length() {
      if j == hit_idx {
        continue
      }
      let e2 = game.enemies[j]
      if !e2.active {
        continue
      }
      let chain_dist = @types.dist2d(chain_x, chain_z, e2.x, e2.z)
      if chain_dist < @types.lightning_chain_range {
        let chain_dmg = (1).max(damage / 2 - e2.def)
        e2.hp -= chain_dmg
        e2.hit_flash = 0.4
        e2.alerted = true
        e2.stun_timer = 0.3 // Chain targets get shorter stun
        @types.spawn_particles(game, e2.x, 1.5, e2.z, 10, 255, 255, 100)
        @types.spawn_particles(game, e2.x, 1.0, e2.z, 4, 200, 200, 255)
        @types.spawn_damage_number(
          game, e2.x, 1.8, e2.z, chain_dmg, 255, 255, 150, false,
        )
        @types.add_message(
          game,
          "Chain lightning hits \{@types.get_enemy_name(e2.kind)} for \{chain_dmg}!",
          200,
          255,
          150,
        )
        if e2.hp <= 0 {
          kill_enemy(game, j)
        }
      }
    }
  } else {
    // Cast spark even on miss
    @types.spawn_particles(
      game,
      game.player_x + attack_dir_x * 3.0,
      1.5,
      game.player_z + attack_dir_z * 3.0,
      8,
      255,
      255,
      100,
    )
    @types.add_message(game, "Lightning finds no target!", 200, 200, 100)
  }
}

///|
fn @types.Game::cast_teleport(game : @types.Game) -> Unit {
  // Teleport forward in facing direction
  let dir_x = @math.sinf(game.camera_yaw)
  let dir_z = @math.cosf(game.camera_yaw)
  let tp_dist : Float = 8.0
  let mut dest_x = game.player_x + dir_x * tp_dist
  let mut dest_z = game.player_z + dir_z * tp_dist
  let radius : Float = 0.3
  // Find furthest walkable position
  let mut found = false
  for step = 8; step >= 1; step = step - 1 {
    let test_x = game.player_x + dir_x * Float::from_int(step)
    let test_z = game.player_z + dir_z * Float::from_int(step)
    if !@types.is_blocked(game, test_x, test_z, radius) {
      dest_x = test_x
      dest_z = test_z
      found = true
      break
    }
    ignore(step)
  }
  if found {
    @types.spawn_particles(
      game,
      game.player_x,
      1.0,
      game.player_z,
      12,
      150,
      100,
      255,
    )
    game.player_x = dest_x
    game.player_z = dest_z
    @types.spawn_particles(
      game,
      game.player_x,
      1.0,
      game.player_z,
      12,
      150,
      100,
      255,
    )
    @types.add_message(game, "Teleported!", 150, 100, 255)
  } else {
    @types.add_message(game, "Cannot teleport there!", 200, 100, 100)
    // Refund mana
    game.player_mana = (game.player_mana + @types.teleport_mana_cost).min(
      game.player_max_mana,
    )
  }
}

///|
/// Handles enemy death rewards, drop generation, and related kill-side effects.
pub fn kill_enemy(game : @types.Game, idx : Int) -> Unit {
  let e = game.enemies[idx]
  // Award XP
  game.player_xp += e.xp_value
  game.player_kills += 1
  game.total_enemies_killed += 1
  // Death explosion: scaled by enemy importance
  let is_boss = e.kind == DragonBoss
  let is_elite = e.kind == Lich || e.kind == Minotaur || e.kind == Golem
  let particle_count = if is_boss {
    32
  } else if is_elite {
    20
  } else {
    12
  }
  // Enemy-type-colored death particles
  let death_colors : (Int, Int, Int) = match e.kind {
    Skeleton => (200, 190, 170)
    Archer => (80, 120, 60)
    Golem => (140, 120, 100)
    Wraith => (120, 80, 180)
    DragonBoss => (255, 80, 30)
    Slime => (50, 200, 50)
    Bat => (100, 80, 60)
    Spider => (120, 100, 80)
    Minotaur => (180, 120, 60)
    Lich => (180, 50, 200)
    Mimic => (180, 140, 60)
    _ => (180, 80, 40)
  }
  @types.spawn_particles(
    game, e.x, 1.0, e.z, particle_count,
    death_colors.0, death_colors.1, death_colors.2,
  )
  // Secondary white flash burst
  @types.spawn_particles(game, e.x, 1.2, e.z, particle_count / 2, 255, 255, 255)
  // Screen shake on death (bigger for bosses/elites)
  if is_boss {
    @types.trigger_shake(game, 0.25, 0.5)
  } else if is_elite {
    @types.trigger_shake(game, 0.10, 0.25)
  } else {
    @types.trigger_shake(game, 0.03, 0.10)
  }
  // XP damage number
  @types.spawn_damage_number(
    game, e.x, 2.0, e.z, e.xp_value, 80, 255, 80, is_boss,
  )
  @types.add_message(
    game,
    "\{@types.get_enemy_name(e.kind)} defeated! +\{e.xp_value} XP",
    80,
    255,
    80,
  )
  // Drop loot (40% base + bonus for rarer enemies)
  let drop_chance = if e.kind == DragonBoss {
    100
  } else if e.kind == Lich || e.kind == Minotaur {
    60
  } else if e.kind == Golem {
    50
  } else {
    40
  }
  if @types.rand_range(game, 0, 99) < drop_chance {
    let loot_idx = @types.alloc_loot(game)
    if loot_idx >= 0 {
      let l = game.loot[loot_idx]
      l.active = true
      // Roll loot type - expanded with equipment drops
      let roll = @types.rand_range(game, 0, 10)
      if roll == 0 {
        l.kind = @types.loot_health_potion
      } else if roll == 1 {
        l.kind = @types.loot_damage_boost
      } else if roll == 2 {
        l.kind = @types.loot_armor
      } else if roll == 3 {
        l.kind = @types.loot_mana_potion
      } else if roll == 4 {
        l.kind = @types.loot_gold_pile
        l.value = @types.rand_range(game, 5, 30)
      } else if roll == 5 {
        l.kind = @types.loot_speed_potion
      } else if roll == 6 {
        l.kind = @types.loot_strength_potion
      } else if roll == 7 {
        l.kind = @types.loot_gold_pile
        l.value = @types.rand_range(game, 10, 40)
      } else if roll == 8 {
        // Equipment: weapon drop
        l.kind = @types.loot_equip_weapon
        l.value = @types.rand_range(game, 2, 5 + game.current_floor)
      } else if roll == 9 {
        // Equipment: armor drop
        l.kind = @types.loot_equip_armor
        l.value = @types.rand_range(game, 2, 4 + game.current_floor)
      } else {
        // Equipment: ring drop
        l.kind = @types.loot_equip_ring
        l.value = @types.rand_range(game, 0, 4) // ring kind
      }
      // Boss drops boss key instead
      if e.kind == DragonBoss {
        l.kind = @types.loot_boss_key
      }
      l.x = e.x
      l.z = e.z
      l.bob_phase = @types.rand_rangef(game, 0.0, 6.28)
      // Higher rarity from stronger enemies
      let rarity_weights : Array[Int] = [
        @levels.get_rarity_weight_common(game.current_floor),
        @levels.get_rarity_weight_uncommon(game.current_floor),
        @levels.get_rarity_weight_rare(game.current_floor),
        @levels.get_rarity_weight_epic(game.current_floor),
        @levels.get_rarity_weight_legendary(game.current_floor),
      ]
      l.rarity = @types.rand_weighted(game, rarity_weights)
      // Elite/boss enemies boost rarity
      if is_elite && l.rarity < 3 {
        l.rarity += 1
      }
      if is_boss {
        l.rarity = (3).max(l.rarity)
      }
    }
  }
  // Gold always drops - ring of fortune gives bonus
  let gold_base = @types.rand_range(game, 3, 15 + game.current_floor * 3)
  let gold_amount = if game.equip_ring_kind == @types.ring_gold_find {
    gold_base + gold_base * game.equip_ring_bonus / 10
  } else {
    gold_base
  }
  game.player_gold += gold_amount
  game.player_total_gold += gold_amount
  e.active = false
  game.floor_info[game.current_floor].enemies_killed += 1
}

///|
fn @types.Game::check_loot_pickup(game : @types.Game) -> Unit {
  for l in game.loot {
    if !l.active {
      continue
    }
    let dist = @types.dist2d(game.player_x, game.player_z, l.x, l.z)
    if dist < 1.2 {
      // Pick up
      if l.kind == @types.loot_health_potion {
        game.player_hp = (game.player_hp + @types.health_potion_heal).min(
          game.player_max_hp,
        )
        @types.add_message(
          game,
          "+\{@types.health_potion_heal} HP",
          50,
          255,
          50,
        )
        @types.spawn_particles(game, l.x, 0.5, l.z, 8, 50, 255, 50)
      } else if l.kind == @types.loot_mana_potion {
        game.player_mana = (game.player_mana + @types.mana_potion_restore).min(
          game.player_max_mana,
        )
        @types.add_message(
          game,
          "+\{@types.mana_potion_restore} Mana",
          80,
          100,
          255,
        )
        @types.spawn_particles(game, l.x, 0.5, l.z, 8, 80, 100, 255)
      } else if l.kind == @types.loot_damage_boost {
        game.player_atk += @types.damage_boost_amount
        @types.add_message(
          game,
          "+\{@types.damage_boost_amount} ATK",
          255,
          100,
          50,
        )
        @types.spawn_particles(game, l.x, 0.5, l.z, 8, 255, 100, 50)
      } else if l.kind == @types.loot_armor {
        game.player_def += @types.armor_boost_amount
        @types.add_message(
          game,
          "+\{@types.armor_boost_amount} DEF",
          100,
          100,
          255,
        )
        @types.spawn_particles(game, l.x, 0.5, l.z, 8, 100, 100, 255)
      } else if l.kind == @types.loot_speed_potion {
        @types.add_buff(
          game, @types.buff_speed, @types.speed_potion_duration, 1,
        )
        @types.add_message(game, "Speed boost!", 255, 255, 80)
        @types.spawn_particles(game, l.x, 0.5, l.z, 8, 255, 255, 80)
      } else if l.kind == @types.loot_strength_potion {
        @types.add_buff(
          game, @types.buff_strength, @types.strength_potion_duration, @types.strength_potion_bonus,
        )
        @types.add_message(game, "Strength boost!", 255, 80, 80)
        @types.spawn_particles(game, l.x, 0.5, l.z, 8, 255, 80, 80)
      } else if l.kind == @types.loot_gold_pile {
        let amount = if l.value > 0 {
          l.value
        } else {
          @types.rand_range(game, 10, 30)
        }
        game.player_gold += amount
        game.player_total_gold += amount
        @types.add_message(game, "+\{amount} Gold", 255, 215, 0)
        @types.spawn_particles(game, l.x, 0.5, l.z, 8, 255, 215, 0)
      } else if l.kind == @types.loot_key {
        game.player_keys += 1
        @types.add_message(game, "Got a Key!", 200, 200, 50)
        @types.spawn_particles(game, l.x, 0.5, l.z, 8, 200, 200, 50)
      } else if l.kind == @types.loot_boss_key {
        game.player_boss_keys += 1
        @types.add_message(game, "Got a Boss Key!", 255, 100, 100)
        @types.spawn_particles(game, l.x, 0.5, l.z, 10, 255, 100, 100)
      } else if l.kind == @types.loot_equip_weapon {
        // Equipment weapon: upgrade if better
        let bonus = l.value + l.rarity * 2
        let rarity_name = @types.get_rarity_name(l.rarity)
        if bonus > game.equip_weapon_bonus {
          game.equip_weapon_bonus = bonus
          game.equip_weapon_rarity = l.rarity
          let cr = @types.get_rarity_color_r(l.rarity)
          let cg = @types.get_rarity_color_g(l.rarity)
          let cb = @types.get_rarity_color_b(l.rarity)
          @types.add_message(
            game,
            "Equipped \{rarity_name} Weapon +\{bonus}!",
            cr,
            cg,
            cb,
          )
          @types.spawn_particles(game, l.x, 0.5, l.z, 12, cr, cg, cb)
        } else {
          // Sell for gold instead
          let gold = 10 + l.rarity * 15
          game.player_gold += gold
          game.player_total_gold += gold
          @types.add_message(
            game,
            "Sold weapon for \{gold} gold",
            255,
            215,
            0,
          )
        }
      } else if l.kind == @types.loot_equip_armor {
        let bonus = l.value + l.rarity * 2
        let rarity_name = @types.get_rarity_name(l.rarity)
        if bonus > game.equip_armor_bonus {
          game.equip_armor_bonus = bonus
          game.equip_armor_rarity = l.rarity
          let cr = @types.get_rarity_color_r(l.rarity)
          let cg = @types.get_rarity_color_g(l.rarity)
          let cb = @types.get_rarity_color_b(l.rarity)
          @types.add_message(
            game,
            "Equipped \{rarity_name} Armor +\{bonus}!",
            cr,
            cg,
            cb,
          )
          @types.spawn_particles(game, l.x, 0.5, l.z, 12, cr, cg, cb)
        } else {
          let gold = 10 + l.rarity * 15
          game.player_gold += gold
          game.player_total_gold += gold
          @types.add_message(
            game,
            "Sold armor for \{gold} gold",
            255,
            215,
            0,
          )
        }
      } else if l.kind == @types.loot_equip_ring {
        let ring_kind = l.value.clamp(min=0, max=4)
        let bonus = 2 + l.rarity * 2
        let rarity_name = @types.get_rarity_name(l.rarity)
        let ring_name = @types.get_ring_name(ring_kind)
        if game.equip_ring_kind < 0 || bonus > game.equip_ring_bonus {
          game.equip_ring_kind = ring_kind
          game.equip_ring_rarity = l.rarity
          game.equip_ring_bonus = bonus
          let cr = @types.get_rarity_color_r(l.rarity)
          let cg = @types.get_rarity_color_g(l.rarity)
          let cb = @types.get_rarity_color_b(l.rarity)
          @types.add_message(
            game,
            "Equipped \{rarity_name} \{ring_name}!",
            cr,
            cg,
            cb,
          )
          @types.spawn_particles(game, l.x, 0.5, l.z, 12, cr, cg, cb)
        } else {
          let gold = 15 + l.rarity * 20
          game.player_gold += gold
          game.player_total_gold += gold
          @types.add_message(
            game,
            "Sold ring for \{gold} gold",
            255,
            215,
            0,
          )
        }
      }
      l.active = false
      game.message_text = @types.get_loot_name(l.kind)
      game.message_timer = 2.0
    }
  }
}

///|
fn @types.Game::check_stairs(game : @types.Game) -> Unit {
  let stairs_wx = @types.grid_to_world_x(game.stairs_x)
  let stairs_wz = @types.grid_to_world_z(game.stairs_z)
  let dist = @types.dist2d(game.player_x, game.player_z, stairs_wx, stairs_wz)
  if dist < 1.5 {
    let alive = @types.count_active_enemies(game)
    if alive == 0 {
      game.floor_info[game.current_floor].cleared = true
      game.floors_cleared += 1
      if game.current_floor < @types.max_floors - 1 {
        game.state = StateFloorComplete
        @raylib.enable_cursor()
      } else {
        game.state = StateFloorComplete
        @raylib.enable_cursor()
      }
    } else {
      game.message_text = "Defeat all enemies to descend"
      game.message_timer = 1.0
    }
  }
}

///|
fn @types.Game::check_chest_open(game : @types.Game) -> Unit {
  let check_x = game.player_x + @math.sinf(game.camera_yaw) * 1.5
  let check_z = game.player_z + @math.cosf(game.camera_yaw) * 1.5
  let gx = @types.world_to_grid_x(check_x)
  let gz = @types.world_to_grid_z(check_z)
  if @types.get_tile(game, gx, gz) == @types.tile_chest {
    // Check for mimic
    for e in game.enemies {
      if e.active && e.kind == Mimic {
        let egx = @types.world_to_grid_x(e.x)
        let egz = @types.world_to_grid_z(e.z)
        if egx == gx && egz == gz {
          // It's a mimic!
          e.alerted = true
          e.ai_state = @types.ai_chase
          @types.set_tile(game, gx, gz, @types.tile_floor)
          @types.add_message(game, "MIMIC! It's alive!", 255, 50, 50)
          @types.spawn_particles(
            game,
            @types.grid_to_world_x(gx),
            0.5,
            @types.grid_to_world_z(gz),
            12,
            255,
            50,
            50,
          )
          return
        }
      }
    }
    @types.set_tile(game, gx, gz, @types.tile_floor)
    // Give random reward
    let roll = @types.rand_range(game, 0, 4)
    if roll == 0 {
      let heal = @types.health_potion_heal + 20
      game.player_hp = (game.player_hp + heal).min(game.player_max_hp)
      game.message_text = "Chest: +\{heal} HP!"
      @types.add_message(game, "Chest: +\{heal} HP!", 50, 255, 50)
    } else if roll == 1 {
      let dmg = @types.damage_boost_amount + 2
      game.player_atk += dmg
      game.message_text = "Chest: +\{dmg} ATK!"
      @types.add_message(game, "Chest: +\{dmg} ATK!", 255, 100, 50)
    } else if roll == 2 {
      let armor = @types.armor_boost_amount + 2
      game.player_def += armor
      game.message_text = "Chest: +\{armor} DEF!"
      @types.add_message(game, "Chest: +\{armor} DEF!", 100, 100, 255)
    } else if roll == 3 {
      let gold = @types.rand_range(game, 20, 60)
      game.player_gold += gold
      game.player_total_gold += gold
      game.message_text = "Chest: +\{gold} Gold!"
      @types.add_message(game, "Chest: +\{gold} Gold!", 255, 215, 0)
    } else {
      // Spell scroll
      let spell_roll = @types.rand_range(game, 1, 6)
      let spell = @types.spell_from_int(spell_roll)
      let added = game.add_spell_to_player(spell)
      if added {
        game.message_text = "Chest: \{@types.get_spell_name(spell)} spell!"
        @types.add_message(
          game,
          "Learned \{@types.get_spell_name(spell)}!",
          200,
          100,
          255,
        )
      } else {
        let gold = @types.rand_range(game, 30, 50)
        game.player_gold += gold
        game.player_total_gold += gold
        game.message_text = "Chest: +\{gold} Gold!"
        @types.add_message(game, "+\{gold} Gold!", 255, 215, 0)
      }
    }
    game.message_timer = 2.5
    let wx = @types.grid_to_world_x(gx)
    let wz = @types.grid_to_world_z(gz)
    @types.spawn_particles(game, wx, 0.5, wz, 16, 255, 215, 0)
  }
}

///|
fn @types.Game::check_door_interact(game : @types.Game) -> Unit {
  let check_x = game.player_x + @math.sinf(game.camera_yaw) * 1.5
  let check_z = game.player_z + @math.cosf(game.camera_yaw) * 1.5
  let gx = @types.world_to_grid_x(check_x)
  let gz = @types.world_to_grid_z(check_z)
  let tile = @types.get_tile(game, gx, gz)
  if tile == @types.tile_locked_door {
    if game.player_keys > 0 {
      game.player_keys -= 1
      @types.set_tile(game, gx, gz, @types.tile_floor)
      @types.add_message(game, "Door unlocked!", 200, 200, 50)
      @types.spawn_particles(
        game,
        @types.grid_to_world_x(gx),
        1.5,
        @types.grid_to_world_z(gz),
        8,
        200,
        200,
        50,
      )
    } else {
      @types.add_message(game, "Need a key!", 200, 100, 100)
    }
  } else if tile == @types.tile_boss_door {
    if game.player_boss_keys > 0 {
      game.player_boss_keys -= 1
      @types.set_tile(game, gx, gz, @types.tile_floor)
      @types.add_message(game, "Boss door unlocked!", 255, 100, 100)
    } else {
      @types.add_message(game, "Need a Boss Key!", 255, 80, 80)
    }
  }
}

///|
fn @types.Game::check_shop_interact(game : @types.Game) -> Unit {
  let check_x = game.player_x + @math.sinf(game.camera_yaw) * 1.5
  let check_z = game.player_z + @math.cosf(game.camera_yaw) * 1.5
  let gx = @types.world_to_grid_x(check_x)
  let gz = @types.world_to_grid_z(check_z)
  if @types.get_tile(game, gx, gz) == @types.tile_shop {
    game.prev_state = game.state
    game.state = StateShop
    game.shop_cursor = 0
    @raylib.enable_cursor()
  }
}

///|
fn @types.Game::check_shrine_interact(game : @types.Game) -> Unit {
  let check_x = game.player_x + @math.sinf(game.camera_yaw) * 1.5
  let check_z = game.player_z + @math.cosf(game.camera_yaw) * 1.5
  let gx = @types.world_to_grid_x(check_x)
  let gz = @types.world_to_grid_z(check_z)
  if @types.get_tile(game, gx, gz) == @types.tile_shrine {
    if game.shrine_used {
      @types.add_message(game, "Shrine already used.", 150, 150, 150)
    } else {
      game.prev_state = game.state
      game.state = StateShrine
      game.shrine_cursor = 0
      @raylib.enable_cursor()
    }
  }
}

///|
fn @types.Game::check_traps(game : @types.Game, dt : Float) -> Unit {
  let pgx = @types.world_to_grid_x(game.player_x)
  let pgz = @types.world_to_grid_z(game.player_z)
  for trap in game.traps {
    if !trap.active {
      continue
    }
    // Update cooldown
    if trap.cooldown > 0.0 {
      trap.cooldown -= dt
      if trap.cooldown < 0.0 {
        trap.cooldown = 0.0
        trap.armed = true
      }
    }
    // Check if player is on trap
    if pgx == trap.gx && pgz == trap.gz && trap.armed {
      trap.armed = false
      trap.cooldown = @types.trap_cooldown
      trap.triggered = true
      trap.visible = true
      let wx = @types.grid_to_world_x(trap.gx)
      let wz = @types.grid_to_world_z(trap.gz)
      match trap.kind {
        Spike => {
          damage_player(game, @types.spike_damage)
          @types.add_message(game, "Stepped on spikes!", 255, 80, 80)
          @types.spawn_particles(game, wx, 0.3, wz, 8, 200, 50, 50)
        }
        Arrow => {
          damage_player(game, @types.arrow_trap_damage)
          @types.add_message(game, "Arrow trap!", 255, 100, 50)
          @types.spawn_particles(game, wx, 1.0, wz, 6, 200, 150, 50)
        }
        Flame => {
          damage_player(game, @types.flame_damage)
          @types.add_message(game, "Flame trap!", 255, 100, 30)
          @types.spawn_particles(game, wx, 1.0, wz, 12, 255, 100, 30)
        }
        Poison => {
          game.poison_remaining = @types.poison_duration
          game.poison_timer = 0.0
          @types.add_message(game, "Poison gas!", 100, 200, 50)
          @types.spawn_particles(game, wx, 0.5, wz, 10, 100, 200, 50)
        }
        Pitfall => {
          damage_player(game, @types.pitfall_damage)
          @types.add_message(game, "Pitfall trap!", 200, 100, 50)
          @types.spawn_particles(game, wx, 0.1, wz, 8, 150, 100, 50)
        }
      }
    }
    // Nearby traps become visible (perception)
    if !trap.visible {
      let trap_dist_sq = @types.dist2d_sq(
        game.player_x,
        game.player_z,
        @types.grid_to_world_x(trap.gx),
        @types.grid_to_world_z(trap.gz),
      )
      let perception : Float = Float::from_int(game.player_dex) * 0.5
      if trap_dist_sq < perception * perception {
        trap.visible = true
        @types.add_message(game, "Trap spotted!", 255, 200, 80)
      }
    }
  }
}

///|
fn @types.Game::add_spell_to_player(
  game : @types.Game,
  spell_type : @types.Spell,
) -> Bool {
  // Check if already have this spell
  for spell in game.spells {
    if spell.active && spell.spell_type == spell_type {
      return false
    }
  }
  // Find empty slot
  for spell in game.spells {
    if !spell.active {
      spell.active = true
      spell.spell_type = spell_type
      return true
    }
  }
  false
}

///|
fn @types.Game::level_up(game : @types.Game) -> Unit {
  game.player_xp -= game.player_xp_next
  game.player_level += 1
  game.player_xp_next = @levels.get_xp_for_level(game.player_level)
  game.player_max_hp += @types.hp_per_level
  game.player_max_mana += @types.mana_per_level
  game.player_hp = game.player_max_hp // Full heal on level up
  game.player_mana = game.player_max_mana // Full mana restore
  game.player_atk += @types.atk_per_level
  game.player_def += @types.def_per_level
  // Stat bonuses based on class
  match game.player_class {
    Warrior => {
      game.player_str += 2
      game.player_max_hp += 5
      game.player_hp += 5
    }
    Rogue => {
      game.player_dex += 2
      game.player_atk += 1
    }
    Mage => {
      game.player_int_stat += 2
      game.player_max_mana += 5
      game.player_mana += 5
    }
  }
  game.level_up_timer = 3.0
  game.message_text = "LEVEL UP! Lv.\{game.player_level}"
  game.message_timer = 3.0
  @types.add_message(
    game,
    "Level Up! Lv.\{game.player_level} | HP:\{game.player_max_hp} ATK:\{game.player_atk} DEF:\{game.player_def}",
    255,
    215,
    0,
  )
  @types.spawn_particles(
    game,
    game.player_x,
    1.0,
    game.player_z,
    24,
    255,
    255,
    50,
  )
}

///|
/// Applies incoming damage after defense (including equipment), updates hit feedback, and clamps HP at zero.
pub fn damage_player(game : @types.Game, raw_damage : Int) -> Unit {
  let total_def = @types.calc_player_defense_with_equip(game)
  let damage = (1).max(raw_damage - total_def)
  game.player_hp -= damage
  game.player_hit_flash = 0.3
  game.damage_flash = 0.2
  // Screen shake proportional to damage taken
  let shake_intensity = @types.clampf(
    Float::from_int(damage) * 0.005, 0.03, 0.20,
  )
  @types.trigger_shake(game, shake_intensity, 0.15)
  // Floating damage number on player
  @types.spawn_damage_number(
    game, game.player_x, 2.0, game.player_z, damage, 255, 60, 60, damage > 20,
  )
  // Thorns ring: reflect damage back
  if game.equip_ring_kind == @types.ring_thorns && game.equip_ring_bonus > 0 {
    // Find nearest enemy
    let mut nearest_dist : Float = 5.0
    let mut nearest_idx = -1
    for i in 0..<game.enemies.length() {
      let e = game.enemies[i]
      if !e.active {
        continue
      }
      let d = @types.dist2d(game.player_x, game.player_z, e.x, e.z)
      if d < nearest_dist {
        nearest_dist = d
        nearest_idx = i
      }
    }
    if nearest_idx >= 0 {
      let reflect = game.equip_ring_bonus
      game.enemies[nearest_idx].hp -= reflect
      game.enemies[nearest_idx].hit_flash = 0.15
      @types.spawn_particles(
        game,
        game.enemies[nearest_idx].x,
        1.0,
        game.enemies[nearest_idx].z,
        4,
        200,
        100,
        255,
      )
      if game.enemies[nearest_idx].hp <= 0 {
        kill_enemy(game, nearest_idx)
      }
    }
  }
  if game.player_hp < 0 {
    game.player_hp = 0
  }
}
