///|
/// Updates destruction effects: particles, slow motion, camera shake.
pub fn update_destruction(game : @types.Game, dt : Float) -> Unit {
  let dest = game.destruction
  // Update particles
  update_particles(dest, dt)
  // Update slow motion
  if dest.slow_motion > 0.0 {
    dest.slow_motion = dest.slow_motion - dt
    if dest.slow_motion < 0.0 {
      dest.slow_motion = 0.0
    }
  }
  // Update camera shake
  if dest.camera_shake > 0.0 {
    dest.shake_x = @types.randf(-1.0, 1.0) * dest.camera_shake
    dest.shake_y = @types.randf(-1.0, 1.0) * dest.camera_shake
    dest.camera_shake = dest.camera_shake -
      dt * @types.camera_shake_decay
    if dest.camera_shake < 0.0 {
      dest.camera_shake = 0.0
      dest.shake_x = 0.0
      dest.shake_y = 0.0
    }
  }
  // Update replay timer
  if dest.replay_active {
    dest.replay_timer = dest.replay_timer - dt
    if dest.replay_timer <= 0.0 {
      dest.replay_active = false
      dest.replay_timer = 0.0
    }
  }
}

///|
/// Updates all active particles, removing dead ones.
fn update_particles(dest : @types.DestructionState, dt : Float) -> Unit {
  let mut i = 0
  while i < dest.particles.length() {
    let p = dest.particles[i]
    p.life = p.life - dt
    if p.life <= 0.0 {
      // Remove by swapping with last
      let last_idx = dest.particles.length() - 1
      if i < last_idx {
        dest.particles[i] = dest.particles[last_idx]
      }
      ignore(dest.particles.pop())
      continue
    }
    // Apply gravity to particles
    p.vy = p.vy + 400.0 * dt
    p.x = p.x + p.vx * dt
    p.y = p.y + p.vy * dt
    // Shrink over lifetime
    let t = p.life / p.max_life
    p.size = p.size * (0.99 + t * 0.01)
    i = i + 1
  }
}

///|
/// Spawns debris particles at a body's position when it breaks.
pub fn spawn_debris(dest : @types.DestructionState, body : @types.Body) -> Unit {
  let count = @types.debris_per_break
  for _i in 0..<count {
    if dest.particles.length() >= @types.max_particles {
      break
    }
    let (r, g, b) = debris_color(body.material)
    let vx = @types.randf(-200.0, 200.0)
    let vy = @types.randf(-300.0, -50.0)
    let life = @types.randf(0.5, @types.particle_life)
    let size = @types.randf(2.0, 6.0)
    let px = body.x + @types.randf(-body.width * 0.3, body.width * 0.3)
    let py = body.y + @types.randf(-body.height * 0.3, body.height * 0.3)
    let p = @types.new_particle(px, py, vx, vy, life, size, r, g, b)
    dest.particles.push(p)
  }
}

///|
/// Spawns dust particles from the ground during earthquakes.
pub fn spawn_dust(dest : @types.DestructionState, ground_y : Float) -> Unit {
  let count = 4
  for _i in 0..<count {
    if dest.particles.length() >= @types.max_particles {
      break
    }
    let px = @types.randf(@types.build_area_left, @types.build_area_right)
    let py = ground_y - @types.randf(0.0, 10.0)
    let vx = @types.randf(-50.0, 50.0)
    let vy = @types.randf(-100.0, -20.0)
    let life = @types.randf(0.3, 1.0)
    let size = @types.randf(1.0, 4.0)
    let p = @types.new_particle(px, py, vx, vy, life, size, 120, 110, 80)
    dest.particles.push(p)
  }
}

///|
/// Spawns wind visualization particles.
pub fn spawn_wind_particles(
  dest : @types.DestructionState,
  wind_force : Float
) -> Unit {
  if dest.particles.length() >= @types.max_particles - 4 {
    return
  }
  let dir : Float = if wind_force > 0.0 { 1.0 } else { -1.0 }
  let speed = @types.absf(wind_force) * 2.0
  let start_x : Float = if dir > 0.0 {
    @types.build_area_left
  } else {
    @types.build_area_right
  }
  let py = @types.randf(200.0, @types.ground_y - 50.0)
  let vx = dir * speed
  let life = @types.randf(0.5, 1.5)
  let p = @types.new_particle(
    start_x,
    py,
    vx,
    @types.randf(-20.0, 20.0),
    life,
    2.0,
    100,
    180,
    255,
  )
  dest.particles.push(p)
}

///|
/// Spawns impact trail particles.
pub fn spawn_impact_trail(
  dest : @types.DestructionState,
  x : Float,
  y : Float
) -> Unit {
  let count = 12
  for _i in 0..<count {
    if dest.particles.length() >= @types.max_particles {
      break
    }
    let vx = @types.randf(-250.0, 250.0)
    let vy = @types.randf(-250.0, 250.0)
    let life = @types.randf(0.3, 0.8)
    let size = @types.randf(3.0, 8.0)
    let p = @types.new_particle(x, y, vx, vy, life, size, 255, 200, 60)
    dest.particles.push(p)
  }
}

///|
/// Processes chain reaction: falling/broken pieces damage nearby joints.
pub fn process_chain_reaction(world : @types.World, dest : @types.DestructionState) -> Unit {
  dest.chain_breaks = 0
  let mut any_break = false
  for body in world.bodies {
    if body.broken && body.active {
      // Check if this broken body is near joints that could break
      for joint in world.joints {
        if !(joint.active) || joint.broken {
          continue
        }
        // Find the joint's connected bodies
        let a_opt = @physics.find_body(world, joint.body_a)
        let b_opt = @physics.find_body(world, joint.body_b)
        match (a_opt, b_opt) {
          (Some(a), Some(b)) => {
            let (ax, ay) = @physics.local_to_world(a, joint.local_x_a, joint.local_y_a)
            let (bx, by) = @physics.local_to_world(b, joint.local_x_b, joint.local_y_b)
            let mid_x = (ax + bx) * 0.5
            let mid_y = (ay + by) * 0.5
            let dx = body.x - mid_x
            let dy = body.y - mid_y
            let dist_sq = dx * dx + dy * dy
            let radius = @types.chain_break_radius
            if dist_sq < radius * radius {
              // Apply stress from nearby broken body
              let stress_add = body.mass *
                @types.absf(body.vx + body.vy) *
                0.02
              joint.stress = joint.stress + stress_add
              if joint.stress > joint.strength {
                joint.broken = true
                joint.active = false
                dest.chain_breaks = dest.chain_breaks + 1
                any_break = true
              }
            }
          }
          _ => ()
        }
      }
    }
  }
  // Trigger slow motion and camera shake on dramatic chain reactions
  if any_break && dest.chain_breaks >= 2 {
    dest.slow_motion = @types.slow_motion_duration
    dest.camera_shake = @types.maxf(
      dest.camera_shake,
      Float::from_int(dest.chain_breaks) * 3.0,
    )
  }
}

///|
/// Triggers camera shake with given intensity.
pub fn trigger_camera_shake(dest : @types.DestructionState, intensity : Float) -> Unit {
  dest.camera_shake = @types.maxf(dest.camera_shake, intensity)
}

///|
/// Triggers slow-motion effect.
pub fn trigger_slow_motion(dest : @types.DestructionState, duration : Float) -> Unit {
  dest.slow_motion = @types.maxf(dest.slow_motion, duration)
}

///|
/// Returns the effective dt, accounting for slow-motion.
pub fn effective_dt(dest : @types.DestructionState, dt : Float) -> Float {
  if dest.slow_motion > 0.0 {
    dt * 0.25
  } else {
    dt
  }
}

///|
/// Starts a collapse replay.
pub fn start_replay(dest : @types.DestructionState, duration : Float) -> Unit {
  dest.replay_active = true
  dest.replay_timer = duration
}

///|
/// Checks if the replay is currently active.
pub fn is_replay_active(dest : @types.DestructionState) -> Bool {
  dest.replay_active
}

///|
/// Clears all destruction state (particles, effects).
pub fn clear_destruction(dest : @types.DestructionState) -> Unit {
  dest.particles.clear()
  dest.slow_motion = 0.0
  dest.camera_shake = 0.0
  dest.shake_x = 0.0
  dest.shake_y = 0.0
  dest.chain_breaks = 0
  dest.replay_active = false
  dest.replay_timer = 0.0
}

///|
/// Returns color for debris particles based on material.
fn debris_color(mat : @types.Material) -> (Int, Int, Int) {
  match mat {
    Wood => (180, 140, 60)
    Stone => (160, 160, 170)
    Steel => (120, 160, 220)
  }
}

///|
/// Counts the number of active particles.
pub fn particle_count(dest : @types.DestructionState) -> Int {
  dest.particles.length()
}

///|
/// Detects new breaks in the world and spawns appropriate effects.
pub fn detect_breaks_and_spawn(
  world : @types.World,
  dest : @types.DestructionState
) -> Unit {
  let mut total_break_mass : Float = 0.0
  for body in world.bodies {
    if body.broken && body.active {
      // Check if body is newly broken (still has significant velocity from break burst)
      let speed = @types.absf(body.vx) + @types.absf(body.vy)
      if speed > 50.0 {
        spawn_debris(dest, body)
        total_break_mass = total_break_mass + body.mass
      }
    }
  }
  if total_break_mass > 5.0 {
    trigger_camera_shake(dest, total_break_mass * 0.5)
    if total_break_mass > 15.0 {
      trigger_slow_motion(dest, @types.slow_motion_duration)
    }
  }
}
