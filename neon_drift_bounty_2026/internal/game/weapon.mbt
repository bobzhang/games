///|
/// Applies a weapon upgrade pickup to the player's weapon state.
fn @types.Game::apply_weapon_upgrade(
  game : @types.Game,
  upgrade : @types.WeaponUpgrade,
) -> Unit {
  match game.weapon {
    Some(current) =>
      if current == upgrade {
        game.weapon_level = (game.weapon_level + 1).clamp(min=0, max=3)
      } else {
        game.weapon = Some(upgrade)
        game.weapon_level = 1
      }
    None => {
      game.weapon = Some(upgrade)
      game.weapon_level = 1
    }
  }
  game.burst(game.hero.x, game.hero.y, 14, 2)
  game.spawn_ring(game.hero.x, game.hero.y, 12.0, 0.6, 2)
  game.add_score(100)
}

///|
/// Fires player bullets modified by the current weapon upgrade.
fn @types.Game::shoot_upgraded_bullet(game : @types.Game) -> Unit {
  let base_spread : Float = if game.boost_t > 0.0 { 16.0 } else { 8.0 }
  let y_off = game.hero.y - game.hero.h * 0.44
  let spd = @types.bullet_speed
  let life = @types.bullet_life
  match game.weapon {
    Some(Spread) => {
      // Spread: wider shot pattern, more bullets at higher levels
      let angle = @types.spread_angle * (1.0 + Float::from_int(game.weapon_level) * 0.3)
      let rad = angle * 3.14159 / 180.0
      // Center bullet
      game.spawn_bullet(
        true,
        game.hero.x,
        y_off,
        @types.randf(-base_spread, base_spread),
        -spd,
        life,
        7.0,
        0,
      )
      // Left spread
      game.spawn_bullet(
        true,
        game.hero.x - 12.0,
        y_off,
        -@math.sinf(rad) * spd * 0.4,
        -spd * 0.92,
        life,
        6.0,
        0,
      )
      // Right spread
      game.spawn_bullet(
        true,
        game.hero.x + 12.0,
        y_off,
        @math.sinf(rad) * spd * 0.4,
        -spd * 0.92,
        life,
        6.0,
        0,
      )
      // Extra bullets at level 2+
      if game.weapon_level >= 2 {
        game.spawn_bullet(
          true,
          game.hero.x - 20.0,
          y_off,
          -@math.sinf(rad * 1.6) * spd * 0.5,
          -spd * 0.85,
          life,
          5.0,
          0,
        )
        game.spawn_bullet(
          true,
          game.hero.x + 20.0,
          y_off,
          @math.sinf(rad * 1.6) * spd * 0.5,
          -spd * 0.85,
          life,
          5.0,
          0,
        )
      }
    }
    Some(Piercing) => {
      // Piercing: bullets pass through enemies (marked with kind=2)
      let dmg : Float = 10.0 + Float::from_int(game.weapon_level) * 2.0
      game.spawn_bullet(
        true,
        game.hero.x - 10.0,
        y_off,
        @types.randf(-base_spread * 0.5, base_spread * 0.5),
        -spd * 1.1,
        life * 1.3,
        dmg,
        2,
      )
      game.spawn_bullet(
        true,
        game.hero.x + 10.0,
        y_off,
        @types.randf(-base_spread * 0.5, base_spread * 0.5),
        -spd * 1.1,
        life * 1.3,
        dmg,
        2,
      )
    }
    Some(Homing) => {
      // Homing: bullets aim toward nearest enemy
      let target = find_nearest_enemy(game)
      let (tvx, tvy) = match target {
        Some((tx, ty)) => {
          let dx = tx - game.hero.x
          let dy = ty - y_off
          let n2 = @types.maxf(dx * dx + dy * dy, 1.0)
          let inv : Float = Float::from_int(1) / n2.sqrt()
          (dx * inv * spd * 0.9, dy * inv * spd * 0.9)
        }
        None => (0.0, -spd)
      }
      game.spawn_bullet(
        true,
        game.hero.x,
        y_off,
        tvx,
        tvy,
        life,
        8.0 + Float::from_int(game.weapon_level),
        1,
      )
      // Second bullet at level 2+
      if game.weapon_level >= 2 {
        game.spawn_bullet(
          true,
          game.hero.x + @types.randf(-8.0, 8.0),
          y_off - 6.0,
          tvx * 0.95,
          tvy * 0.95,
          life,
          7.0,
          1,
        )
      }
    }
    None => {
      // No upgrade: default dual bullets
      game.spawn_bullet(
        true,
        game.hero.x - 10.0,
        y_off,
        @types.randf(-base_spread, base_spread),
        -spd,
        life,
        8.0,
        0,
      )
      game.spawn_bullet(
        true,
        game.hero.x + 10.0,
        y_off,
        @types.randf(-base_spread, base_spread),
        -spd,
        life,
        8.0,
        0,
      )
      // Stage 4+ bonus center bullet
      if game.stage >= 4 && @types.chance(28) {
        game.spawn_bullet(
          true,
          game.hero.x,
          game.hero.y - game.hero.h * 0.54,
          @types.randf(-6.0, 6.0),
          -spd * 1.08,
          life,
          6.0,
          1,
        )
      }
    }
  }
  game.hero.muzzle_t = 0.12
}

///|
/// Finds the nearest active hostile enemy to the player. Returns its (x, y).
fn find_nearest_enemy(game : @types.Game) -> (Float, Float)? {
  let mut best_d2 : Float = 999999.0
  let mut best : (Float, Float)? = None
  for entity in game.entities {
    if !entity.active || !@types.entity_is_hostile(entity.kind) {
      continue
    }
    let d2 = @types.dist2(game.hero.x, game.hero.y, entity.x, entity.y)
    if d2 < best_d2 {
      best_d2 = d2
      best = Some((entity.x, entity.y))
    }
  }
  best
}

///|
/// Attempts to drop a weapon module from an elite enemy kill.
fn @types.Game::try_drop_weapon(
  game : @types.Game,
  x : Float,
  y : Float,
) -> Unit {
  if @types.chance(@types.elite_drop_chance) {
    let roll = @types.randi(0, 2)
    let upgrade : @types.WeaponUpgrade = match roll {
      0 => Spread
      1 => Piercing
      _ => Homing
    }
    game.apply_weapon_upgrade(upgrade)
    // Visual feedback
    game.burst(x, y, 12, 2)
    game.spawn_ring(x, y, 14.0, 0.7, 2)
  }
}

///|
/// Returns fire rate multiplier when boost interacts with weapon upgrades.
fn weapon_boost_fire_mult(weapon : @types.WeaponUpgrade?, level : Int) -> Float {
  match weapon {
    Some(Spread) => 0.55 - Float::from_int(level) * 0.03
    Some(Piercing) => 0.7
    Some(Homing) => 0.5
    None => 0.62
  }
}

///|
/// Returns hack pulse damage bonus from weapon upgrades.
pub fn weapon_hack_bonus(weapon : @types.WeaponUpgrade?, level : Int) -> Float {
  match weapon {
    Some(Spread) => Float::from_int(level) * 10.0
    Some(Piercing) => Float::from_int(level) * 18.0
    Some(Homing) => Float::from_int(level) * 8.0
    None => 0.0
  }
}
