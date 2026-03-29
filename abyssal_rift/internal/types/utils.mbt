///|
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
pub fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn minf(a : Float, b : Float) -> Float {
  if a < b { a } else { b }
}

///|
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b { a } else { b }
}

///|
pub fn absf(v : Float) -> Float {
  if v < 0.0 { -v } else { v }
}

///|
pub fn dist2(x1 : Float, y1 : Float, x2 : Float, y2 : Float) -> Float {
  let dx = x2 - x1
  let dy = y2 - y1
  dx * dx + dy * dy
}

///|
pub fn dist(x1 : Float, y1 : Float, x2 : Float, y2 : Float) -> Float {
  dist2(x1, y1, x2, y2) |> sqrt_f
}

///|
fn sqrt_f(v : Float) -> Float {
  if v <= 0.0 {
    0.0
  } else {
    let mut guess = v / 2.0
    for _i in 0..<10 {
      guess = (guess + v / guess) / 2.0
    }
    guess
  }
}

///|
pub fn normalize(x : Float, y : Float) -> (Float, Float) {
  let len = sqrt_f(x * x + y * y)
  if len < 0.0001 {
    (0.0, 0.0)
  } else {
    (x / len, y / len)
  }
}

///|
/// Simple xorshift RNG
pub fn rng_next(state : UInt) -> (UInt, Float) {
  let mut s = state
  s = s ^ (s << 13)
  s = s ^ (s >> 17)
  s = s ^ (s << 5)
  let f = Float::from_int((s % 10000U).reinterpret_as_int()) / 10000.0
  (s, f)
}

///|
/// Random float in range [lo, hi)
pub fn rng_range(state : UInt, lo : Float, hi : Float) -> (UInt, Float) {
  let (s, f) = rng_next(state)
  (s, lo + f * (hi - lo))
}

///|
/// Random int in range [lo, hi]
pub fn rng_int(state : UInt, lo : Int, hi : Int) -> (UInt, Int) {
  let (s, f) = rng_next(state)
  let range = hi - lo + 1
  let v = lo + (f * Float::from_int(range)).to_int()
  (s, clampi(v, lo, hi))
}

///|
/// Allocate from pool: find first inactive slot, or evict shortest-lived
pub fn alloc_particle(particles : Array[Particle]) -> Int {
  for i, p in particles {
    if !p.active {
      return i
    }
  }
  // Evict shortest-lived
  let mut best = 0
  let mut best_life = particles[0].life
  for i in 1..<particles.length() {
    if particles[i].life < best_life {
      best = i
      best_life = particles[i].life
    }
  }
  best
}

///|
pub fn alloc_enemy(enemies : Array[Enemy]) -> Int {
  for i, e in enemies {
    if !e.active {
      return i
    }
  }
  let mut best = 0
  let mut best_hp = enemies[0].hp
  for i in 1..<enemies.length() {
    if enemies[i].hp < best_hp {
      best = i
      best_hp = enemies[i].hp
    }
  }
  best
}

///|
pub fn alloc_projectile(projectiles : Array[Projectile]) -> Int {
  for i, p in projectiles {
    if !p.active {
      return i
    }
  }
  let mut best = 0
  let mut best_life = projectiles[0].lifetime
  for i in 1..<projectiles.length() {
    if projectiles[i].lifetime < best_life {
      best = i
      best_life = projectiles[i].lifetime
    }
  }
  best
}

///|
pub fn alloc_item(items : Array[Item]) -> Int {
  for i, it in items {
    if !it.active {
      return i
    }
  }
  // Pool full - evict first Gold item (lowest priority)
  for i, it in items {
    match it.kind {
      Gold(_) => return i
      _ => ()
    }
  }
  0 // Last resort
}

///|
pub fn alloc_damage_num(nums : Array[DamageNumber]) -> Int {
  for i, d in nums {
    if !d.active {
      return i
    }
  }
  let mut best = 0
  let mut best_life = nums[0].life
  for i in 1..<nums.length() {
    if nums[i].life < best_life {
      best = i
      best_life = nums[i].life
    }
  }
  best
}

///|
/// Ease out quad
pub fn ease_out(t : Float) -> Float {
  1.0 - (1.0 - t) * (1.0 - t)
}

///|
/// Ease in out quad
pub fn ease_in_out(t : Float) -> Float {
  if t < 0.5 {
    2.0 * t * t
  } else {
    1.0 - (-2.0 * t + 2.0) * (-2.0 * t + 2.0) / 2.0
  }
}
