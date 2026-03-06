///|
/// Finds and returns the index of the first inactive particle slot, or -1 if all slots are full.
fn @types.Game::alloc_particle(game : @types.Game) -> Int {
  for i, slot in game.particles {
    if !slot.active {
      break i
    }
  } nobreak {
    -1
  }
}

///|
/// Spawns a single particle with the given position, velocity, lifetime, size, and color.
pub fn spawn_particle(
  game : @types.Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  color : @raylib.Color,
) -> Unit {
  let idx = game.alloc_particle()
  if idx < 0 {
    return
  }
  game.particles[idx].active = true
  game.particles[idx].x = x
  game.particles[idx].y = y
  game.particles[idx].vx = vx
  game.particles[idx].vy = vy
  game.particles[idx].life = life
  game.particles[idx].max_life = life
  game.particles[idx].size = size
  game.particles[idx].rot = @types.rand_rangef(game, 0.0, 6.28318)
  game.particles[idx].spin = @types.rand_rangef(game, -5.2, 5.2)
  game.particles[idx].fade = @types.rand_rangef(game, 0.7, 1.5)
  game.particles[idx].color = color
}

///|
/// Spawns a burst of gold sparks radiating outward from `(x, y)`.
pub fn spawn_spark_burst(
  game : @types.Game,
  x : Float,
  y : Float,
  count : Int,
) -> Unit {
  for _i in 0..<count {
    let angle = @types.rand_rangef(game, 0.0, 6.28318)
    let speed = @types.rand_rangef(game, 65.0, 210.0)
    let vx = @math.cosf(angle) * speed
    let vy = @math.sinf(angle) * speed
    let life = @types.rand_rangef(game, 0.18, 0.55)
    spawn_particle(
      game,
      x,
      y,
      vx,
      vy,
      life,
      @types.rand_rangef(game, 1.2, 2.8),
      @raylib.gold,
    )
  }
}

///|
/// Spawns a full explosion with sparks and smoke puffs scaled by `strength`.
pub fn spawn_explosion(
  game : @types.Game,
  x : Float,
  y : Float,
  strength : Float,
) -> Unit {
  let sparks = (strength * 20.0).to_int().clamp(min=10, max=70)
  for i in 0..<sparks {
    let angle = @types.rand_rangef(game, 0.0, 6.28318)
    let speed = @types.rand_rangef(game, 40.0, 160.0) * strength
    let vx = @math.cosf(angle) * speed
    let vy = @math.sinf(angle) * speed
    let life = @types.rand_rangef(game, 0.25, 0.95)
    let size = @types.rand_rangef(game, 1.4, 4.0)
    let color = if i % 5 == 0 {
      @raylib.white
    } else if i % 3 == 0 {
      @raylib.yellow
    } else {
      @raylib.orange
    }
    spawn_particle(game, x, y, vx, vy, life, size, color)
  }

  // Smoke puffs.
  for _i in 0..<(strength * 10.0).to_int().clamp(min=4, max=20) {
    let angle = @types.rand_rangef(game, 0.0, 6.28318)
    let speed = @types.rand_rangef(game, 12.0, 58.0)
    let vx = @math.cosf(angle) * speed
    let vy = @math.sinf(angle) * speed
    let life = @types.rand_rangef(game, 0.65, 1.8)
    spawn_particle(
      game,
      x,
      y,
      vx,
      vy,
      life,
      @types.rand_rangef(game, 3.0, 7.5),
      @raylib.darkgray,
    )
  }

  @types.push_camera_shake(game, strength * 1.8)
}

///|
/// Spawns a circular ring of particles at a tank respawn location.
pub fn spawn_respawn_burst(game : @types.Game, x : Float, y : Float) -> Unit {
  for i in 0..<24 {
    let angle = Float::from_int(i) / Float::from_int(24) * 6.28318
    let speed = Float::from_int(35 + i % 3 * 15)
    let vx = @math.cosf(angle) * speed
    let vy = @math.sinf(angle) * speed
    spawn_particle(
      game,
      x,
      y,
      vx,
      vy,
      @types.rand_rangef(game, 0.4, 0.95),
      2.4,
      @raylib.skyblue,
    )
  }
}

///|
/// Updates all active particles by advancing position, applying drag and gravity, and removing expired ones.
pub fn update_particles(game : @types.Game, dt : Float) -> Unit {
  for p in game.particles {
    if not(p.active) {
      continue
    }
    p.life -= dt * p.fade
    if p.life <= 0.0 {
      p.active = false
      continue
    }
    p.x += p.vx * dt
    p.y += p.vy * dt
    p.vx *= 1.0 - 0.8 * dt
    p.vy *= 1.0 - 0.8 * dt
    p.vy += 22.0 * dt
    p.rot += p.spin * dt
  }
}
