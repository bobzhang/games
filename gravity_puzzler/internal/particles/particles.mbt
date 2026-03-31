///|
pub fn spawn_gravity_trail(
  game : @types.Game,
  x : Float,
  y : Float,
  dir : @types.GravityDir
) -> Unit {
  let (dx, dy) = @types.gravity_vector(dir)
  let fdx = Float::from_int(dx)
  let fdy = Float::from_int(dy)
  for i in 0..<4 {
    let fi = Float::from_int(i)
    let vx = -fdx * 40.0 + rand_float(game) * 20.0 - 10.0
    let vy = -fdy * 40.0 + rand_float(game) * 20.0 - 10.0
    let p = @types.Particle::new(
      x + fi * 2.0, y + fi * 2.0, vx, vy,
      0.5 + rand_float(game) * 0.3, 3.0 + rand_float(game) * 2.0,
      200, 200, 255, 0,
    )
    add_particle(game, p)
  }
}

///|
pub fn spawn_gem_sparkle(game : @types.Game, x : Float, y : Float) -> Unit {
  for _i in 0..<12 {
    let angle : Float = rand_float(game) * 6.283
    let speed : Float = rand_float(game) * 60.0 + 30.0
    let vx : Float = cos_f(angle) * speed
    let vy : Float = sin_f(angle) * speed
    let p = @types.Particle::new(
      x, y, vx, vy, 0.6 + rand_float(game) * 0.4,
      2.0 + rand_float(game) * 3.0, 100, 255, 100, 1,
    )
    add_particle(game, p)
  }
}

///|
pub fn spawn_key_ring(game : @types.Game, x : Float, y : Float) -> Unit {
  for i in 0..<16 {
    let angle : Float = Float::from_int(i) * 6.283 / 16.0
    let speed : Float = 50.0
    let vx : Float = cos_f(angle) * speed
    let vy : Float = sin_f(angle) * speed
    let p = @types.Particle::new(
      x, y, vx, vy, 0.8, 4.0, 255, 220, 40, 2,
    )
    add_particle(game, p)
  }
}

///|
pub fn spawn_spike_death(game : @types.Game, x : Float, y : Float) -> Unit {
  for _i in 0..<20 {
    let angle : Float = rand_float(game) * 6.283
    let speed : Float = rand_float(game) * 80.0 + 40.0
    let vx : Float = cos_f(angle) * speed
    let vy : Float = sin_f(angle) * speed
    let p = @types.Particle::new(
      x, y, vx, vy, 0.8 + rand_float(game) * 0.4,
      3.0 + rand_float(game) * 4.0, 255, 60, 60, 3,
    )
    add_particle(game, p)
  }
}

///|
pub fn spawn_portal_swirl(
  game : @types.Game,
  x : Float,
  y : Float,
  portal_id : Int
) -> Unit {
  let (r, g, b) = match portal_id {
    1 => (200, 100, 255)
    2 => (100, 200, 255)
    _ => (255, 200, 100)
  }
  for i in 0..<10 {
    let angle : Float = Float::from_int(i) * 6.283 / 10.0
    let rad : Float = 20.0
    let px : Float = x + cos_f(angle) * rad
    let py : Float = y + sin_f(angle) * rad
    let vx : Float = cos_f(angle + 1.57) * 30.0
    let vy : Float = sin_f(angle + 1.57) * 30.0
    let p = @types.Particle::new(
      px, py, vx, vy, 0.6, 3.0, r, g, b, 4,
    )
    add_particle(game, p)
  }
}

///|
pub fn spawn_crumble_debris(game : @types.Game, x : Float, y : Float) -> Unit {
  for _i in 0..<8 {
    let vx : Float = rand_float(game) * 40.0 - 20.0
    let vy : Float = rand_float(game) * 40.0 + 20.0
    let p = @types.Particle::new(
      x + rand_float(game) * 30.0, y + rand_float(game) * 10.0,
      vx, vy,
      0.8 + rand_float(game) * 0.5, 4.0 + rand_float(game) * 3.0,
      160, 140, 100, 5,
    )
    add_particle(game, p)
  }
}

///|
pub fn spawn_celebration(game : @types.Game, x : Float, y : Float) -> Unit {
  for _i in 0..<30 {
    let angle : Float = rand_float(game) * 6.283
    let speed : Float = rand_float(game) * 100.0 + 60.0
    let vx : Float = cos_f(angle) * speed
    let vy : Float = sin_f(angle) * speed - 40.0
    let r = 128 + (rand_float(game) * 127.0).to_int()
    let g = 128 + (rand_float(game) * 127.0).to_int()
    let b = 128 + (rand_float(game) * 127.0).to_int()
    let p = @types.Particle::new(
      x, y, vx, vy, 1.0 + rand_float(game) * 0.5,
      3.0 + rand_float(game) * 4.0, r, g, b, 6,
    )
    add_particle(game, p)
  }
}

///|
pub fn update_particles(game : @types.Game, dt : Float) -> Unit {
  let particles = game.particles
  let mut i = 0
  while i < particles.length() {
    let p = particles[i]
    p.life = p.life - dt
    if p.life <= 0.0 {
      let last = particles.length() - 1
      if i < last {
        particles[i] = particles[last]
      }
      ignore(particles.pop())
      continue
    }
    p.x = p.x + p.vx * dt
    p.y = p.y + p.vy * dt
    if p.kind == 5 {
      p.vy = p.vy + 120.0 * dt
    }
    if p.kind == 6 {
      p.vy = p.vy + 60.0 * dt
    }
    // Enemy crush particles fade and shrink faster
    if p.kind == 7 {
      p.vy = p.vy + 80.0 * dt
    }
    // Achievement sparkles float upward
    if p.kind == 8 {
      p.vy = p.vy - 20.0 * dt
    }
    i = i + 1
  }
}

///|
pub fn draw_particles(game : @types.Game) -> Unit {
  let particles = game.particles
  for i in 0..<particles.length() {
    let p = particles[i]
    let alpha_f = p.life / p.max_life
    let alpha = (alpha_f * 255.0).to_int()
    let a = if alpha > 255 { 255 } else if alpha < 0 { 0 } else { alpha }
    let color = @raylib.Color::new(p.r, p.g, p.b, a)
    let size = p.size * alpha_f
    @raylib.draw_circle(p.x.to_int(), p.y.to_int(), size, color)
  }
}

///|
pub fn spawn_enemy_crush(game : @types.Game, x : Float, y : Float) -> Unit {
  for _i in 0..<15 {
    let angle : Float = rand_float(game) * 6.283
    let speed : Float = rand_float(game) * 60.0 + 30.0
    let vx : Float = cos_f(angle) * speed
    let vy : Float = sin_f(angle) * speed
    let p = @types.Particle::new(
      x, y, vx, vy, 0.7 + rand_float(game) * 0.3,
      3.0 + rand_float(game) * 3.0, 220, 50, 50, 7,
    )
    add_particle(game, p)
  }
}

///|
pub fn spawn_achievement_sparkle(game : @types.Game) -> Unit {
  let cx = Float::from_int(@types.screen_w / 2)
  let cy : Float = 40.0
  for _i in 0..<8 {
    let angle : Float = rand_float(game) * 6.283
    let speed : Float = rand_float(game) * 40.0 + 20.0
    let vx : Float = cos_f(angle) * speed
    let vy : Float = sin_f(angle) * speed
    let p = @types.Particle::new(
      cx + rand_float(game) * 100.0 - 50.0, cy,
      vx, vy, 0.8 + rand_float(game) * 0.3,
      2.0 + rand_float(game) * 2.0, 255, 215, 0, 8,
    )
    add_particle(game, p)
  }
}

///|
fn add_particle(game : @types.Game, p : @types.Particle) -> Unit {
  if game.particles.length() < @types.max_particles {
    game.particles.push(p)
  }
}

///|
fn rand_float(game : @types.Game) -> Float {
  let v = @types.rand_next(game)
  Float::from_double((v % 10000U).to_double() / 10000.0)
}

///|
fn cos_f(angle : Float) -> Float {
  Float::from_double(@math.cos(angle.to_double()))
}

///|
fn sin_f(angle : Float) -> Float {
  Float::from_double(@math.sin(angle.to_double()))
}
