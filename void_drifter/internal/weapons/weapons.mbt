///|
pub fn fire_weapon(
  game : @types.Game,
  weapon : @types.Weapon,
  origin : @types.Vec2,
  aim_angle : Float,
  mod_kind~ : @types.ModKind? = None
) -> Unit {
  if weapon.fire_timer > 0.0 {
    return
  }
  if game.ship.heat + weapon.heat_cost > game.ship.max_heat {
    return // Overheated
  }
  weapon.fire_timer = weapon.fire_rate
  game.ship.heat = game.ship.heat + weapon.heat_cost
  game.stats.shots_fired += weapon.projectile_count
  @types.push_sound(game, PlayerShoot)
  for i in 0..<weapon.projectile_count {
    let idx = @types.alloc_projectile(game.projectiles)
    if idx < 0 {
      continue
    }
    let p = game.projectiles[idx]
    p.active = true
    p.pos = @types.vec2(origin.x, origin.y)
    p.damage = weapon.damage
    p.lifetime = weapon.range / weapon.projectile_speed
    p.radius = @types.default_projectile_radius
    p.friendly = true
    p.piercing = false
    p.homing_strength = 0.0
    p.chain_count = 0
    p.explosive_radius = 0.0
    p.freezing = false
    p.bounces = 0
    // Calculate spread angle
    let spread_offset = if weapon.projectile_count > 1 {
      let t = Float::from_int(i) / Float::from_int(weapon.projectile_count - 1)
      (t - 0.5) * weapon.spread * 2.0
    } else {
      @types.rng_range(-weapon.spread, weapon.spread)
    }
    let angle = aim_angle + spread_offset
    p.vel = @types.vec2(
      @types.cosf(angle) * weapon.projectile_speed,
      @types.sinf(angle) * weapon.projectile_speed,
    )
    // Apply weapon mod (only primary gets the primary mod)
    apply_mod(p, mod_kind)
  }
}

///|
fn apply_mod(proj : @types.Projectile, mod_kind : @types.ModKind?) -> Unit {
  match mod_kind {
    None => ()
    Some(Piercing) => proj.piercing = true
    Some(Homing) => proj.homing_strength = 3.0
    Some(Split) => {
      // Split handled on hit
      proj.chain_count = 2
    }
    Some(Chain) => proj.chain_count = 3
    Some(Explosive) => proj.explosive_radius = 60.0
    Some(Freezing) => proj.freezing = true
    Some(Bouncing) => proj.bounces = 3
    Some(Overcharge) => {
      proj.damage = proj.damage + proj.damage / 2
      proj.radius = proj.radius * 1.5
    }
  }
}

///|
pub fn update_weapon_timer(weapon : @types.Weapon, dt : Float) -> Unit {
  if weapon.fire_timer > 0.0 {
    weapon.fire_timer = weapon.fire_timer - dt
  }
}

///|
pub fn fire_enemy_projectile(
  game : @types.Game,
  origin : @types.Vec2,
  target : @types.Vec2,
  speed : Float,
  damage : Int
) -> Unit {
  let idx = @types.alloc_projectile(game.projectiles)
  if idx < 0 {
    return
  }
  let p = game.projectiles[idx]
  p.active = true
  p.pos = @types.vec2(origin.x, origin.y)
  let dir = @types.vec2_normalize(@types.vec2_sub(target, origin))
  p.vel = @types.vec2(dir.x * speed, dir.y * speed)
  p.damage = damage
  p.lifetime = 3.0
  p.radius = 5.0
  p.friendly = false
  p.piercing = false
  p.homing_strength = 0.0
  p.chain_count = 0
  p.explosive_radius = 0.0
  p.freezing = false
  p.bounces = 0
}

///|
pub fn weapon_name(kind : @types.WeaponKind) -> String {
  match kind {
    Laser => "LASER"
    Shotgun => "SHOTGUN"
    Missile => "MISSILE"
    Railgun => "RAILGUN"
    Flak => "FLAK"
    Beam => "BEAM"
  }
}

///|
pub fn mod_name(kind : @types.ModKind) -> String {
  match kind {
    Piercing => "PIERCING"
    Homing => "HOMING"
    Split => "SPLIT"
    Chain => "CHAIN"
    Explosive => "EXPLOSIVE"
    Freezing => "FREEZING"
    Bouncing => "BOUNCING"
    Overcharge => "OVERCHARGE"
  }
}

///|
pub fn utility_name(kind : @types.UtilityMod) -> String {
  match kind {
    ShieldDrain => "SHIELD DRAIN"
    Vampire => "VAMPIRE"
    HeatSink => "HEAT SINK"
    Accelerator => "ACCELERATOR"
  }
}
