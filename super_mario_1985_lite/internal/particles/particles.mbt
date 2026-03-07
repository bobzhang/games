///|
/// Deactivates all particle slots.
pub fn clear_particles(game : @types.Game) -> Unit {
  for i in 0..<game.particles.length() {
    game.particles[i] = @types.Particle::inactive()
  }
}

///|
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
fn @types.Game::spawn_particle(
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
  let p = game.particles[idx]
  p.active = true
  p.x = x
  p.y = y
  p.vx = vx
  p.vy = vy
  p.life = life
  p.max_life = life
  p.size = size
  p.color = color
}

///|
/// Spawns a golden burst used when collecting a coin.
pub fn spawn_coin_burst(game : @types.Game, x : Float, y : Float) -> Unit {
  for _ in 0..<10 {
    let a = @types.randf(0.0, 6.28)
    let s = @types.randf(45.0, 160.0)
    game.spawn_particle(
      x,
      y,
      @math.cosf(a) * s,
      @math.sinf(a) * s - 40.0,
      @types.randf(0.25, 0.5),
      @types.randf(1.5, 3.5),
      @raylib.gold,
    )
  }
}

///|
/// Spawns debris burst particles for a block impact.
pub fn spawn_block_burst(
  game : @types.Game,
  x : Float,
  y : Float,
  color : @raylib.Color,
) -> Unit {
  for _ in 0..<12 {
    let a = @types.randf(0.0, 6.28)
    let s = @types.randf(60.0, 220.0)
    game.spawn_particle(
      x,
      y,
      @math.cosf(a) * s,
      @math.sinf(a) * s,
      @types.randf(0.28, 0.62),
      @types.randf(1.8, 4.6),
      color,
    )
  }
}

///|
/// Spawns a brown impact burst for enemy stomps.
pub fn spawn_stomp_burst(game : @types.Game, x : Float, y : Float) -> Unit {
  for _ in 0..<15 {
    let a = @types.randf(0.0, 6.28)
    let s = @types.randf(55.0, 200.0)
    game.spawn_particle(
      x,
      y,
      @math.cosf(a) * s,
      @math.sinf(a) * s - 30.0,
      @types.randf(0.35, 0.75),
      @types.randf(2.0, 4.0),
      @raylib.brown,
    )
  }
}

///|
/// Spawns a red burst to signal player damage.
pub fn spawn_hurt_burst(game : @types.Game, x : Float, y : Float) -> Unit {
  for _ in 0..<18 {
    let a = @types.randf(0.0, 6.28)
    let s = @types.randf(80.0, 260.0)
    game.spawn_particle(
      x,
      y,
      @math.cosf(a) * s,
      @math.sinf(a) * s - 30.0,
      @types.randf(0.3, 0.9),
      @types.randf(2.0, 4.8),
      @raylib.red,
    )
  }
}

///|
/// Advances active particle motion and lifetime.
pub fn update_particles(game : @types.Game, dt : Float) -> Unit {
  for p in game.particles {
    if !p.active {
      continue
    }
    p.life = p.life - dt
    if p.life <= 0.0 {
      p.active = false
      continue
    }
    p.vy = p.vy + 420.0 * dt
    p.x = p.x + p.vx * dt
    p.y = p.y + p.vy * dt
  }
}
