///|
test "vec2 basic operations" {
  let a = @types.vec2(3.0, 4.0)
  let b = @types.vec2(1.0, 2.0)
  let sum = @types.vec2_add(a, b)
  inspect(sum.x, content="4")
  inspect(sum.y, content="6")
  let diff = @types.vec2_sub(a, b)
  inspect(diff.x, content="2")
  inspect(diff.y, content="2")
  let scaled = @types.vec2_scale(a, 2.0)
  inspect(scaled.x, content="6")
  inspect(scaled.y, content="8")
}

///|
test "vec2_len" {
  let v = @types.vec2(3.0, 4.0)
  inspect(@types.vec2_len(v), content="5")
}

///|
test "vec2_normalize" {
  let v = @types.vec2(0.0, 5.0)
  let n = @types.vec2_normalize(v)
  inspect(n.x, content="0")
  inspect(n.y, content="1")
  // Zero vector
  let z = @types.vec2_normalize(@types.vec2_zero())
  inspect(z.x, content="0")
  inspect(z.y, content="0")
}

///|
test "vec2_dist" {
  let a = @types.vec2(0.0, 0.0)
  let b = @types.vec2(3.0, 4.0)
  inspect(@types.vec2_dist(a, b), content="5")
}

///|
test "clampf" {
  inspect(@types.clampf(0.5, 0.0, 1.0), content="0.5")
  inspect(@types.clampf(-1.0, 0.0, 1.0), content="0")
  inspect(@types.clampf(2.0, 0.0, 1.0), content="1")
}

///|
test "absf" {
  inspect(@types.absf(5.0), content="5")
  inspect(@types.absf(-5.0), content="5")
  inspect(@types.absf(0.0), content="0")
}

///|
test "maxf and minf" {
  inspect(@types.maxf(3.0, 7.0), content="7")
  inspect(@types.minf(3.0, 7.0), content="3")
}

///|
test "lerpf" {
  inspect(@types.lerpf(0.0, 10.0, 0.0), content="0")
  inspect(@types.lerpf(0.0, 10.0, 1.0), content="10")
  inspect(@types.lerpf(0.0, 10.0, 0.5), content="5")
}

///|
test "rng produces values in range" {
  @types.seed_rng(42)
  for _i in 0..<100 {
    let v = @types.rng_int(10)
    inspect(v >= 0 && v < 10, content="true")
  }
}

///|
test "rng_float in 0..1" {
  @types.seed_rng(123)
  for _i in 0..<100 {
    let v = @types.rng_float()
    inspect(v >= 0.0 && v < 1.0, content="true")
  }
}

///|
test "rng_range respects bounds" {
  @types.seed_rng(99)
  for _i in 0..<50 {
    let v = @types.rng_range(5.0, 10.0)
    inspect(v >= 5.0 && v <= 10.0, content="true")
  }
}

///|
test "new_weapon creates correct stats" {
  let laser = @types.new_weapon(Laser)
  inspect(laser.kind, content="Laser")
  inspect(laser.damage, content="2")
  inspect(laser.projectile_count, content="1")
  let shotgun = @types.new_weapon(Shotgun)
  inspect(shotgun.kind, content="Shotgun")
  inspect(shotgun.damage, content="1")
  inspect(shotgun.projectile_count, content="5")
  let railgun = @types.new_weapon(Railgun)
  inspect(railgun.damage, content="8")
}

///|
test "new_ship default state" {
  let ship = @types.new_ship(Laser)
  inspect(ship.hp, content="5")
  inspect(ship.shield, content="3")
  inspect(ship.heat, content="0")
  inspect(ship.weapon.kind, content="Laser")
  inspect(ship.primary_mod, content="None")
  inspect(ship.utility_mod, content="None")
  inspect(ship.credits, content="0")
}

///|
test "new_game initializes pools" {
  let game = @types.new_game()
  inspect(game.screen, content="Title")
  inspect(game.projectiles.length(), content="256")
  inspect(game.enemies.length(), content="64")
  inspect(game.particles.length(), content="512")
  inspect(game.asteroids.length(), content="32")
  inspect(game.stats.score, content="0")
  inspect(game.stats.kills, content="0")
}

///|
test "alloc_projectile finds inactive slot" {
  let pool : Array[@types.Projectile] = []
  for _i in 0..<5 {
    pool.push(@types.new_projectile())
  }
  let idx = @types.alloc_projectile(pool)
  inspect(idx, content="0")
  pool[0].active = true
  let idx2 = @types.alloc_projectile(pool)
  inspect(idx2, content="1")
}

///|
test "alloc_projectile returns -1 when full" {
  let pool : Array[@types.Projectile] = []
  for _i in 0..<3 {
    let p = @types.new_projectile()
    p.active = true
    pool.push(p)
  }
  let idx = @types.alloc_projectile(pool)
  inspect(idx, content="-1")
}

///|
test "count_active_enemies" {
  let pool : Array[@types.Enemy] = []
  for _i in 0..<5 {
    pool.push(@types.new_enemy())
  }
  inspect(@types.count_active_enemies(pool), content="0")
  pool[0].active = true
  pool[2].active = true
  inspect(@types.count_active_enemies(pool), content="2")
}

///|
test "weapon_color returns correct colors" {
  let c = @types.weapon_color(Laser)
  inspect(c == @types.color_laser, content="true")
  let c2 = @types.weapon_color(Shotgun)
  inspect(c2 == @types.color_shotgun, content="true")
}

///|
test "enemy_color returns correct colors" {
  let c = @types.enemy_color(Drone)
  inspect(c == @types.color_enemy_drone, content="true")
}

///|
test "add_shake increases intensity" {
  let shake = @types.new_shake()
  inspect(shake.intensity, content="0")
  @types.add_shake(shake, 5.0)
  inspect(shake.intensity, content="5")
  // Max of current and new
  @types.add_shake(shake, 3.0)
  inspect(shake.intensity, content="5")
  @types.add_shake(shake, 8.0)
  inspect(shake.intensity, content="8")
}

///|
test "cosf and sinf" {
  // cos(0) = 1, sin(0) = 0
  inspect(@types.cosf(0.0), content="1")
  inspect(@types.sinf(0.0), content="0")
}

///|
test "new_run_stats zeroed" {
  let s = @types.new_run_stats()
  inspect(s.score, content="0")
  inspect(s.kills, content="0")
  inspect(s.max_combo, content="0")
  inspect(s.time_played, content="0")
}

///|
test "new_meta initial state" {
  let m = @types.new_meta()
  inspect(m.total_runs, content="0")
  inspect(m.best_score, content="0")
  inspect(m.unlocked_weapons.length(), content="1")
  inspect(m.unlocked_weapons[0], content="Laser")
}
