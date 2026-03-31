///|
pub fn update_player_state(game : @types.Game, dt : Float) -> Unit {
  let p = game.player
  if p.dead {
    return
  }
  // Invulnerability timer
  if p.invuln_timer > 0.0 {
    p.invuln_timer -= dt
  }
  // Shield regeneration (disabled by GlassStep pact)
  if p.shield < p.max_shield && !@types.has_pact(p, GlassStep) {
    p.shield_regen_timer -= dt
    if p.shield_regen_timer <= 0.0 {
      p.shield += @types.shield_regen_rate * dt
      if p.shield > p.max_shield {
        p.shield = p.max_shield
      }
    }
  }
}

///|
pub fn update_status_effects(game : @types.Game, dt : Float) -> Unit {
  let p = game.player
  if p.dead {
    return
  }
  let mut i = 0
  while i < p.status_effects.length() {
    let effect = p.status_effects[i]
    match effect {
      Slow(remaining) => {
        let new_t = remaining - dt
        if new_t <= 0.0 {
          ignore(p.status_effects.remove(i))
        } else {
          p.status_effects[i] = Slow(new_t)
          i += 1
        }
      }
      Poison(remaining) => {
        let new_t = remaining - dt
        // Deal 5 DPS: tick 1 damage every 0.2 seconds using integer tick counting
        let old_tick = (remaining * 5.0).to_int()
        let new_tick = (new_t * 5.0).to_int()
        if old_tick != new_tick && new_t > 0.0 {
          p.hp -= 1
          // Poison cannot kill - leave player at 1 HP
          if p.hp <= 0 {
            p.hp = 1
          }
        }
        if new_t <= 0.0 {
          ignore(p.status_effects.remove(i))
        } else {
          p.status_effects[i] = Poison(new_t)
          i += 1
        }
      }
      Shield(remaining) => {
        let new_t = remaining - dt
        if new_t <= 0.0 {
          ignore(p.status_effects.remove(i))
        } else {
          p.status_effects[i] = Shield(new_t)
          i += 1
        }
      }
      Haste(remaining) => {
        let new_t = remaining - dt
        if new_t <= 0.0 {
          ignore(p.status_effects.remove(i))
        } else {
          p.status_effects[i] = Haste(new_t)
          i += 1
        }
      }
    }
  }
}

///|
pub fn has_status_slow(p : @types.Player) -> Bool {
  for i in 0..<p.status_effects.length() {
    match p.status_effects[i] {
      Slow(_) => return true
      _ => ()
    }
  }
  false
}

///|
pub fn has_status_shield(p : @types.Player) -> Bool {
  for i in 0..<p.status_effects.length() {
    match p.status_effects[i] {
      Shield(_) => return true
      _ => ()
    }
  }
  false
}

///|
pub fn has_status_haste(p : @types.Player) -> Bool {
  for i in 0..<p.status_effects.length() {
    match p.status_effects[i] {
      Haste(_) => return true
      _ => ()
    }
  }
  false
}

///|
pub fn damage_player(game : @types.Game, amount : Int) -> Unit {
  let p = game.player
  if p.dead || p.invuln_timer > 0.0 {
    return
  }
  // Fortify synergy: 30% less damage when above 70% HP
  let syn = game.synergies
  let fortified_amount = if syn.fortify {
    let hp_ratio = Float::from_int(p.hp) / Float::from_int(p.max_hp)
    if hp_ratio > 0.7 {
      @types.maxf(Float::from_int(amount) * 0.7, 1.0).to_int()
    } else {
      amount
    }
  } else {
    amount
  }
  // Shield status effect reduces damage by 50%
  let effective_amount = if has_status_shield(p) {
    @types.maxf(Float::from_int(fortified_amount) * 0.5, 1.0).to_int()
  } else {
    fortified_amount
  }
  // CursedStrength pact: take 15% more damage
  let cursed_amount = if @types.has_pact(p, CursedStrength) {
    @types.maxf(Float::from_int(effective_amount) * 1.15, 1.0).to_int()
  } else {
    effective_amount
  }
  let reduced = @types.maxf(Float::from_int(cursed_amount - p.defense), 1.0).to_int()
  // Shield absorbs first
  if p.shield > 0.0 {
    let absorbed = @types.minf(p.shield, Float::from_int(reduced))
    p.shield -= absorbed
    let remaining = reduced - absorbed.to_int()
    if remaining > 0 {
      p.hp -= remaining
    }
  } else {
    p.hp -= reduced
  }
  p.invuln_timer = @types.invuln_duration
  p.shield_regen_timer = @types.shield_regen_delay
  push_event(game, PlayerDamaged(reduced, p.x, p.y))
  shake_camera(game, 6.0, 0.2)
  if p.hp <= 0 {
    p.hp = 0
    p.dead = true
    game.state = GameOver
  }
  // Thorns: reflect damage to nearby enemies
  if p.passives.contains(Thorns) {
    let thorns_dmg = if game.synergies.iron_maiden { 10 } else { 5 }
    for i in 0..<game.enemies.length() {
      let e = game.enemies[i]
      if !e.active {
        continue
      }
      match e.state {
        Dead(_) => continue
        _ => ()
      }
      let d2 = @types.dist2(p.x, p.y, e.x, e.y)
      if d2 < 80.0 * 80.0 {
        e.hp -= thorns_dmg
        e.flash_timer = 0.1
        if e.hp <= 0 {
          handle_enemy_death(game, i)
        }
      }
    }
  }
}
