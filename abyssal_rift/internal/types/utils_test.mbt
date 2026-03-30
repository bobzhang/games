///|
test "rng_next produces deterministic sequence" {
  let (s1, v1) = @types.rng_next(12345U)
  let (s2, v2) = @types.rng_next(s1)
  let (s3, v3) = @types.rng_next(s2)
  inspect(
    (v1, v2, v3),
    content=(
      #|(0.6330000162124634, 0.3806999921798706, 0.19040000438690186)
    ),
  )
  inspect(
    (s1, s2, s3),
    content=(
      #|(3336926330, 1697253807, 2816511904)
    ),
  )
}

///|
test "rng_range produces values in range" {
  let (_, v) = @types.rng_range(12345U, 10.0, 20.0)
  inspect(
    v >= 10.0 && v < 20.0,
    content=(
      #|true
    ),
  )
}

///|
test "rng_int produces values in range" {
  let (_, v) = @types.rng_int(12345U, 0, 5)
  inspect(
    v >= 0 && v <= 5,
    content=(
      #|true
    ),
  )
}

///|
test "rng_int deterministic value" {
  let (_, v) = @types.rng_int(12345U, 0, 100)
  inspect(
    v,
    content=(
      #|63
    ),
  )
}

///|
test "lerpf interpolation" {
  inspect(
    @types.lerpf(0.0, 10.0, 0.5),
    content=(
      #|5
    ),
  )
  inspect(
    @types.lerpf(0.0, 10.0, 0.0),
    content=(
      #|0
    ),
  )
  inspect(
    @types.lerpf(0.0, 10.0, 1.0),
    content=(
      #|10
    ),
  )
}

///|
test "lerpf negative range" {
  inspect(
    @types.lerpf(-10.0, 10.0, 0.5),
    content=(
      #|0
    ),
  )
}

///|
test "clampf boundaries" {
  inspect(
    @types.clampf(-5.0, 0.0, 10.0),
    content=(
      #|0
    ),
  )
  inspect(
    @types.clampf(15.0, 0.0, 10.0),
    content=(
      #|10
    ),
  )
  inspect(
    @types.clampf(5.0, 0.0, 10.0),
    content=(
      #|5
    ),
  )
}

///|
test "clampi boundaries" {
  inspect(
    @types.clampi(-3, 0, 10),
    content=(
      #|0
    ),
  )
  inspect(
    @types.clampi(15, 0, 10),
    content=(
      #|10
    ),
  )
  inspect(
    @types.clampi(5, 0, 10),
    content=(
      #|5
    ),
  )
}

///|
test "mini and maxi" {
  inspect(
    @types.mini(3, 7),
    content=(
      #|3
    ),
  )
  inspect(
    @types.maxi(3, 7),
    content=(
      #|7
    ),
  )
  inspect(
    @types.mini(-1, 1),
    content=(
      #|-1
    ),
  )
  inspect(
    @types.maxi(-1, 1),
    content=(
      #|1
    ),
  )
}

///|
test "minf and maxf" {
  inspect(
    @types.minf(3.0, 7.0),
    content=(
      #|3
    ),
  )
  inspect(
    @types.maxf(3.0, 7.0),
    content=(
      #|7
    ),
  )
}

///|
test "absf" {
  inspect(
    @types.absf(-5.0),
    content=(
      #|5
    ),
  )
  inspect(
    @types.absf(5.0),
    content=(
      #|5
    ),
  )
  inspect(
    @types.absf(0.0),
    content=(
      #|0
    ),
  )
}

///|
test "normalize unit vector" {
  let (x, y) = @types.normalize(3.0, 4.0)
  // Should be (0.6, 0.8)
  inspect(
    (x, y),
    content=(
      #|(0.6000000238418579, 0.800000011920929)
    ),
  )
}

///|
test "normalize zero vector" {
  let (x, y) = @types.normalize(0.0, 0.0)
  inspect(
    (x, y),
    content=(
      #|(0, 0)
    ),
  )
}

///|
test "dist2 squared distance" {
  inspect(
    @types.dist2(0.0, 0.0, 3.0, 4.0),
    content=(
      #|25
    ),
  )
}

///|
test "dist2 same point" {
  inspect(
    @types.dist2(5.0, 5.0, 5.0, 5.0),
    content=(
      #|0
    ),
  )
}

///|
test "dist euclidean distance" {
  inspect(
    @types.dist(0.0, 0.0, 3.0, 4.0),
    content=(
      #|5
    ),
  )
}

///|
test "ease_out at boundaries" {
  inspect(
    @types.ease_out(0.0),
    content=(
      #|0
    ),
  )
  inspect(
    @types.ease_out(1.0),
    content=(
      #|1
    ),
  )
  inspect(
    @types.ease_out(0.5),
    content=(
      #|0.75
    ),
  )
}

///|
test "ease_in_out at boundaries" {
  inspect(
    @types.ease_in_out(0.0),
    content=(
      #|0
    ),
  )
  inspect(
    @types.ease_in_out(1.0),
    content=(
      #|1
    ),
  )
  inspect(
    @types.ease_in_out(0.5),
    content=(
      #|0.5
    ),
  )
}

///|
test "Player::new defaults" {
  let p = @types.Player::new()
  inspect(
    p.hp,
    content=(
      #|100
    ),
  )
  inspect(
    p.max_hp,
    content=(
      #|100
    ),
  )
  inspect(
    p.weapon,
    content=(
      #|Sword
    ),
  )
  inspect(
    p.speed,
    content=(
      #|1
    ),
  )
  inspect(
    p.crit_chance,
    content=(
      #|0.05000000074505806
    ),
  )
  inspect(
    p.gold,
    content=(
      #|0
    ),
  )
  inspect(
    p.dead,
    content=(
      #|false
    ),
  )
}

///|
test "SynergyBonuses::new all false" {
  let s = @types.SynergyBonuses::new()
  inspect(
    s.cleave,
    content=(
      #|false
    ),
  )
  inspect(
    s.multishot,
    content=(
      #|false
    ),
  )
  inspect(
    s.execute,
    content=(
      #|false
    ),
  )
  inspect(
    s.vampiric,
    content=(
      #|false
    ),
  )
  inspect(
    s.bleed_on_crit,
    content=(
      #|false
    ),
  )
}

///|
test "alloc_particle finds first inactive" {
  let p : @types.Particle = {
    active: true,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    life: 1.0,
    max_life: 1.0,
    size: 1.0,
    r: 255,
    g: 255,
    b: 255,
  }
  let particles = Array::make(4, p)
  particles[2] = { ..p, active: false, life: 0.0 }
  inspect(
    @types.alloc_particle(particles),
    content=(
      #|2
    ),
  )
}

///|
test "alloc_particle evicts shortest-lived when all active" {
  let p : @types.Particle = {
    active: true,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    life: 5.0,
    max_life: 5.0,
    size: 1.0,
    r: 255,
    g: 255,
    b: 255,
  }
  let particles = Array::make(3, p)
  particles[1] = { ..p, life: 0.5 }
  inspect(
    @types.alloc_particle(particles),
    content=(
      #|1
    ),
  )
}
