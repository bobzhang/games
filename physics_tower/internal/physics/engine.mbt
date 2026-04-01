///|
/// Advances the physics world by one time step.
pub fn step(world : @types.World, dt : Float) -> Unit {
  apply_gravity(world, dt)
  apply_wind(world, dt)
  if world.quake_timer > 0.0 {
    apply_earthquake(world, dt)
  }
  integrate(world, dt)
  resolve_ground(world)
  resolve_collisions(world)
  enforce_joints(world, dt)
  compute_stress(world)
  check_breaks(world)
  apply_damping(world)
}

///|
fn apply_gravity(world : @types.World, dt : Float) -> Unit {
  for body in world.bodies {
    if body.active && !body.broken && !body.grounded {
      body.vy = body.vy + world.gravity * dt
    }
  }
}

///|
fn apply_wind(world : @types.World, dt : Float) -> Unit {
  if @types.absf(world.wind_force) < 0.01 {
    return
  }
  for body in world.bodies {
    if body.active && !body.broken {
      let area = body.height * 0.01
      let force = world.wind_force * area / body.mass
      body.vx = body.vx + force * dt
      // Wind also applies slight torque
      let torque = world.wind_force * 0.0005 / body.mass
      body.angular_vel = body.angular_vel + torque * dt
    }
  }
}

///|
fn apply_earthquake(world : @types.World, dt : Float) -> Unit {
  world.quake_timer = world.quake_timer - dt
  if world.quake_timer < 0.0 {
    world.quake_timer = 0.0
    world.quake_intensity = 0.0
    return
  }
  for body in world.bodies {
    if body.active && !body.broken && body.grounded {
      let shake_x = @types.randf(-1.0, 1.0) * world.quake_intensity * dt
      let shake_y = @types.randf(-0.5, 0.5) * world.quake_intensity * dt
      body.vx = body.vx + shake_x
      body.vy = body.vy + shake_y
      body.grounded = false
    }
  }
}

///|
fn integrate(world : @types.World, dt : Float) -> Unit {
  for body in world.bodies {
    if body.active && !body.broken {
      body.x = body.x + body.vx * dt
      body.y = body.y + body.vy * dt
      body.angle = body.angle + body.angular_vel * dt
    }
  }
}

///|
fn resolve_ground(world : @types.World) -> Unit {
  for body in world.bodies {
    if !body.active || body.broken {
      continue
    }
    let half_h = body.height * 0.5
    let cos_a = cosf(body.angle)
    let sin_a = sinf(body.angle)
    let abs_cos = @types.absf(cos_a)
    let abs_sin = @types.absf(sin_a)
    let effective_h = body.height * abs_cos + body.width * abs_sin
    let bottom = body.y + effective_h * 0.5
    if bottom > world.ground_y {
      let penetration = bottom - world.ground_y
      body.y = body.y - penetration
      if body.vy > 0.0 {
        // Apply restitution on bounce
        body.vy = -body.vy * @types.restitution
        if @types.absf(body.vy) < 20.0 {
          body.vy = 0.0
          body.grounded = true
        }
        // Friction slows horizontal motion
        body.vx = body.vx *
          (1.0 - @types.friction_coeff * world.friction_mult * 0.5)
        body.angular_vel = body.angular_vel * 0.8
      }
      // Add stress from impact
      let impact = @types.absf(body.vy) * body.mass * 0.01
      body.stress = body.stress + impact
    }
    // Clamp to build area walls
    let half_w = body.width * 0.5
    let eff_w = body.width * abs_cos + body.height * abs_sin
    let left = body.x - eff_w * 0.5
    let right = body.x + eff_w * 0.5
    if left < @types.build_area_left {
      body.x = @types.build_area_left + eff_w * 0.5
      body.vx = @types.absf(body.vx) * @types.restitution
    }
    if right > @types.build_area_right {
      body.x = @types.build_area_right - eff_w * 0.5
      body.vx = -@types.absf(body.vx) * @types.restitution
    }
    ignore(half_h)
    ignore(half_w)
  }
}

///|
fn resolve_collisions(world : @types.World) -> Unit {
  let n = world.bodies.length()
  for i in 0..<n {
    let a = world.bodies[i]
    if !a.active || a.broken {
      continue
    }
    for j = i + 1; j < n; j = j + 1 {
      let b = world.bodies[j]
      if !b.active || b.broken {
        continue
      }
      resolve_pair(a, b, world.friction_mult)
    }
  }
}

///|
fn resolve_pair(
  a : @types.Body,
  b : @types.Body,
  friction_mult : Float,
) -> Unit {
  // Use OBB approximation: compute axis-aligned bounding boxes of rotated rects
  let (a_half_w, a_half_h) = obb_half_extents(a)
  let (b_half_w, b_half_h) = obb_half_extents(b)
  let dx = b.x - a.x
  let dy = b.y - a.y
  let overlap_x = a_half_w + b_half_w - @types.absf(dx)
  let overlap_y = a_half_h + b_half_h - @types.absf(dy)
  if overlap_x <= 0.0 || overlap_y <= 0.0 {
    return
  }
  // Push apart along axis of minimum overlap
  let total_mass = a.mass + b.mass
  if total_mass < 0.001 {
    return
  }
  let a_ratio = b.mass / total_mass
  let b_ratio = a.mass / total_mass
  if overlap_x < overlap_y {
    // Separate along x
    let sign : Float = if dx > 0.0 { 1.0 } else { -1.0 }
    let sep = overlap_x * 0.5
    a.x = a.x - sign * sep * a_ratio
    b.x = b.x + sign * sep * b_ratio
    // Exchange velocity component
    let rel_vx = a.vx - b.vx
    let impulse = rel_vx * (1.0 + @types.restitution) * 0.5
    a.vx = a.vx - impulse * a_ratio
    b.vx = b.vx + impulse * b_ratio
    // Friction on perpendicular axis
    let fric = @types.friction_coeff * friction_mult * @types.absf(impulse)
    let rel_vy = a.vy - b.vy
    if @types.absf(rel_vy) > 0.1 {
      let sign_y : Float = if rel_vy > 0.0 { 1.0 } else { -1.0 }
      let fy = @types.minf(fric, @types.absf(rel_vy) * 0.5)
      a.vy = a.vy - sign_y * fy * a_ratio
      b.vy = b.vy + sign_y * fy * b_ratio
    }
    // Stress from collision
    let stress_val = @types.absf(impulse) * 0.5
    a.stress = a.stress + stress_val
    b.stress = b.stress + stress_val
  } else {
    // Separate along y
    let sign : Float = if dy > 0.0 { 1.0 } else { -1.0 }
    let sep = overlap_y * 0.5
    a.y = a.y - sign * sep * a_ratio
    b.y = b.y + sign * sep * b_ratio
    // Exchange velocity component
    let rel_vy = a.vy - b.vy
    let impulse = rel_vy * (1.0 + @types.restitution) * 0.5
    a.vy = a.vy - impulse * a_ratio
    b.vy = b.vy + impulse * b_ratio
    // If b is on top of a (dy < 0) then a supports b
    if dy < 0.0 {
      // b rests on a
      if @types.absf(b.vy) < 30.0 {
        b.grounded = true
      }
    } else if @types.absf(a.vy) < 30.0 {
      a.grounded = true
    }
    // Friction on perpendicular axis
    let fric = @types.friction_coeff * friction_mult * @types.absf(impulse)
    let rel_vx = a.vx - b.vx
    if @types.absf(rel_vx) > 0.1 {
      let sign_x : Float = if rel_vx > 0.0 { 1.0 } else { -1.0 }
      let fx = @types.minf(fric, @types.absf(rel_vx) * 0.5)
      a.vx = a.vx - sign_x * fx * a_ratio
      b.vx = b.vx + sign_x * fx * b_ratio
    }
    let stress_val = @types.absf(impulse) * 0.5
    a.stress = a.stress + stress_val
    b.stress = b.stress + stress_val
  }
}

///|
fn obb_half_extents(body : @types.Body) -> (Float, Float) {
  let cos_a = @types.absf(cosf(body.angle))
  let sin_a = @types.absf(sinf(body.angle))
  let hw = (body.width * cos_a + body.height * sin_a) * 0.5
  let hh = (body.width * sin_a + body.height * cos_a) * 0.5
  (hw, hh)
}

///|
fn enforce_joints(world : @types.World, dt : Float) -> Unit {
  for joint in world.joints {
    if !joint.active || joint.broken {
      continue
    }
    let body_a = find_body(world, joint.body_a)
    let body_b = find_body(world, joint.body_b)
    match (body_a, body_b) {
      (Some(a), Some(b)) => {
        if !a.active || a.broken || !b.active || b.broken {
          joint.active = false
          continue
        }
        // World positions of attachment points
        let (ax, ay) = local_to_world(a, joint.local_x_a, joint.local_y_a)
        let (bx, by) = local_to_world(b, joint.local_x_b, joint.local_y_b)
        let dx = bx - ax
        let dy = by - ay
        let dist_sq = dx * dx + dy * dy
        if dist_sq < 0.01 {
          continue
        }
        let dist = sqrtf(dist_sq)
        let stiffness = match joint.kind {
          Fixed => @types.joint_stiffness
          Hinge => @types.joint_stiffness * 0.6
          Spring => @types.joint_stiffness * 0.3
        }
        // Pull bodies toward each other
        let correction = dist * stiffness * 0.5
        let nx = dx / dist
        let ny = dy / dist
        let total_mass = a.mass + b.mass
        if total_mass < 0.001 {
          continue
        }
        let a_frac = b.mass / total_mass
        let b_frac = a.mass / total_mass
        a.x = a.x + nx * correction * a_frac
        a.y = a.y + ny * correction * a_frac
        b.x = b.x - nx * correction * b_frac
        b.y = b.y - ny * correction * b_frac
        // Also adjust velocities to reduce separation rate
        let rel_vn = (a.vx - b.vx) * nx + (a.vy - b.vy) * ny
        let damping_force = rel_vn * stiffness * 0.3
        a.vx = a.vx - nx * damping_force * a_frac
        a.vy = a.vy - ny * damping_force * a_frac
        b.vx = b.vx + nx * damping_force * b_frac
        b.vy = b.vy + ny * damping_force * b_frac
        // Accumulate joint stress
        let force_mag = dist * stiffness * @types.maxf(a.mass, b.mass)
        joint.stress = joint.stress + force_mag * dt
      }
      _ => joint.active = false
    }
  }
}

///|
fn compute_stress(world : @types.World) -> Unit {
  // Each frame, decay existing body stress slightly (so transient forces fade)
  for body in world.bodies {
    if body.active && !body.broken {
      body.stress = body.stress * 0.99
    }
  }
  // Bodies supporting weight from above accumulate stress
  let n = world.bodies.length()
  for i in 0..<n {
    let a = world.bodies[i]
    if !a.active || a.broken {
      continue
    }
    for j = i + 1; j < n; j = j + 1 {
      let b = world.bodies[j]
      if !b.active || b.broken {
        continue
      }
      // Check if they overlap horizontally and one is above the other
      let (ahw, _) = obb_half_extents(a)
      let (bhw, _) = obb_half_extents(b)
      let dx = @types.absf(a.x - b.x)
      if dx < ahw + bhw {
        // The lower body receives weight stress from the upper
        if a.y > b.y {
          // a is lower, receives weight from b
          a.stress = a.stress + b.mass * world.gravity * 0.0001
        } else {
          b.stress = b.stress + a.mass * world.gravity * 0.0001
        }
      }
    }
  }
}

///|
fn check_breaks(world : @types.World) -> Unit {
  // Check joints
  for joint in world.joints {
    if joint.active && !joint.broken {
      if joint.stress > joint.strength {
        joint.broken = true
        joint.active = false
      }
    }
  }
  // Check bodies
  for body in world.bodies {
    if body.active && !body.broken {
      let threshold = @types.material_strength(body.material)
      if body.stress > threshold {
        body.broken = true
        // Broken bodies get a burst of velocity (dramatic effect)
        body.vx = body.vx + @types.randf(-100.0, 100.0)
        body.vy = body.vy + @types.randf(-200.0, -50.0)
        body.angular_vel = body.angular_vel + @types.randf(-3.0, 3.0)
      }
    }
  }
}

///|
fn apply_damping(world : @types.World) -> Unit {
  for body in world.bodies {
    if body.active && !body.broken {
      body.vx = body.vx * @types.damping
      body.vy = body.vy * @types.damping
      body.angular_vel = body.angular_vel * @types.angular_damping
      // Clamp tiny velocities to zero for stability
      if @types.absf(body.vx) < 0.5 {
        body.vx = 0.0
      }
      if @types.absf(body.vy) < 0.5 && body.grounded {
        body.vy = 0.0
      }
      if @types.absf(body.angular_vel) < 0.001 {
        body.angular_vel = 0.0
      }
    }
  }
}

///|
/// Fires a projectile impact at a specific body.
pub fn apply_impact(
  body : @types.Body,
  force_x : Float,
  force_y : Float,
) -> Unit {
  if !body.active || body.broken {
    return
  }
  body.vx = body.vx + force_x / body.mass
  body.vy = body.vy + force_y / body.mass
  body.grounded = false
  body.stress = body.stress + @types.absf(force_x + force_y) * 0.1
}

///|
/// Starts a wind test on the world.
pub fn start_wind(world : @types.World, force : Float) -> Unit {
  world.wind_force = force
}

///|
/// Stops wind.
pub fn stop_wind(world : @types.World) -> Unit {
  world.wind_force = 0.0
}

///|
/// Starts an earthquake test.
pub fn start_earthquake(
  world : @types.World,
  duration : Float,
  intensity : Float,
) -> Unit {
  world.quake_timer = duration
  world.quake_intensity = intensity
}

///|
/// Fires an impact projectile at the rightmost body in the tower.
pub fn fire_impact(world : @types.World, force : Float) -> Unit {
  let mut best_x : Float = -1.0
  let mut best_idx : Int = -1
  for i, body in world.bodies {
    if body.active && !body.broken {
      // Find the tallest body (lowest y means highest)
      if best_idx < 0 || body.y < world.bodies[best_idx].y {
        best_x = body.x
        best_idx = i
      }
    }
  }
  ignore(best_x)
  if best_idx >= 0 {
    apply_impact(world.bodies[best_idx], force, force * 0.3)
  }
}

///|
/// Computes the current tower height (from ground to highest active body).
pub fn measure_tower_height(world : @types.World) -> Float {
  let mut min_y = world.ground_y
  for body in world.bodies {
    if body.active && !body.broken {
      let (_, hh) = obb_half_extents(body)
      let top = body.y - hh
      if top < min_y {
        min_y = top
      }
    }
  }
  world.ground_y - min_y
}

///|
/// Counts how many active, non-broken bodies remain.
pub fn count_active_bodies(world : @types.World) -> Int {
  let mut count = 0
  for body in world.bodies {
    if body.active && !body.broken {
      count = count + 1
    }
  }
  count
}

///|
/// Counts how many broken bodies exist.
pub fn count_broken_bodies(world : @types.World) -> Int {
  let mut count = 0
  for body in world.bodies {
    if body.broken {
      count = count + 1
    }
  }
  count
}

///|
/// Checks if the tower is settled (all velocities near zero).
pub fn is_settled(world : @types.World) -> Bool {
  for body in world.bodies {
    if body.active && !body.broken {
      if @types.absf(body.vx) > 2.0 || @types.absf(body.vy) > 2.0 {
        return false
      }
    }
  }
  true
}

///|
/// Resets all body velocities and stress (used when transitioning to test).
pub fn reset_velocities(world : @types.World) -> Unit {
  for body in world.bodies {
    body.vx = 0.0
    body.vy = 0.0
    body.angular_vel = 0.0
    body.stress = 0.0
    body.grounded = false
  }
  for joint in world.joints {
    joint.stress = 0.0
  }
  world.wind_force = 0.0
  world.quake_timer = 0.0
  world.quake_intensity = 0.0
}

///|
/// Removes all bodies and joints from the world.
pub fn clear_world(world : @types.World) -> Unit {
  world.bodies.clear()
  world.joints.clear()
  world.wind_force = 0.0
  world.quake_timer = 0.0
  world.quake_intensity = 0.0
}

///|
/// Adds a body to the world, returns its id.
pub fn add_body(
  world : @types.World,
  kind : @types.PieceKind,
  material : @types.Material,
  x : Float,
  y : Float,
  angle : Float,
) -> Int {
  let id = world.bodies.length()
  let body = @types.new_body(id, kind, material, x, y, angle)
  world.bodies.push(body)
  id
}

///|
/// Tries to auto-create joints between the new body and nearby bodies.
pub fn auto_join(world : @types.World, new_id : Int) -> Unit {
  let new_body = world.bodies[new_id]
  let radius = @types.auto_joint_radius
  for body in world.bodies {
    if body.id == new_id || !body.active || body.broken {
      continue
    }
    let dx = new_body.x - body.x
    let dy = new_body.y - body.y
    let dist = sqrtf(dx * dx + dy * dy)
    let threshold = radius +
      (new_body.width + new_body.height + body.width + body.height) * 0.15
    if dist < threshold {
      // Create a fixed joint between them
      let strength = @types.minf(
        @types.material_strength(new_body.material),
        @types.material_strength(body.material),
      )
      let joint = @types.new_joint(
        Fixed,
        body.id,
        new_id,
        dx * 0.5,
        dy * 0.5,
        -dx * 0.5,
        -dy * 0.5,
        strength,
      )
      world.joints.push(joint)
    }
  }
}

///|
/// Finds a body by id.
pub fn find_body(world : @types.World, id : Int) -> @types.Body? {
  for body in world.bodies {
    if body.id == id {
      return Some(body)
    }
  }
  None
}

///|
/// Finds the body closest to a point (for clicking).
pub fn find_body_at(
  world : @types.World,
  px : Float,
  py : Float,
) -> @types.Body? {
  let mut best : @types.Body? = None
  let mut best_dist : Float = 999999.0
  for body in world.bodies {
    if !body.active || body.broken {
      continue
    }
    let dx = px - body.x
    let dy = py - body.y
    let dist = dx * dx + dy * dy
    let (hw, hh) = obb_half_extents(body)
    let threshold = (hw + hh) * (hw + hh)
    if dist < threshold && dist < best_dist {
      best = Some(body)
      best_dist = dist
    }
  }
  best
}

///|
fn sinf(angle : Float) -> Float {
  Float::from_double(@math.sin(angle.to_double()))
}

///|
fn cosf(angle : Float) -> Float {
  Float::from_double(@math.cos(angle.to_double()))
}

///|
fn sqrtf(v : Float) -> Float {
  if v <= 0.0 {
    0.0
  } else {
    v.sqrt()
  }
}

///|
/// Transforms a local-space offset to world space given body position and angle.
pub fn local_to_world(
  body : @types.Body,
  lx : Float,
  ly : Float,
) -> (Float, Float) {
  let c = cosf(body.angle)
  let s = sinf(body.angle)
  let wx = body.x + lx * c - ly * s
  let wy = body.y + lx * s + ly * c
  (wx, wy)
}
