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
  // Shield regeneration
  if p.shield < p.max_shield {
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
pub fn damage_player(game : @types.Game, amount : Int) -> Unit {
  let p = game.player
  if p.dead || p.invuln_timer > 0.0 {
    return
  }
  let reduced = @types.maxf(Float::from_int(amount - p.defense), 1.0).to_int()
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
}
