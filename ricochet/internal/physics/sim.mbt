///|
/// Check ball collision with a wall segment. Returns (hit, normal, contact_point).
pub fn check_wall_collision(
  ball_pos : @types.Vec2,
  ball_radius : Float,
  wall : @types.Wall
) -> (Bool, @types.Vec2, @types.Vec2) {
  let (dist, t) = @types.point_to_segment_dist(ball_pos, wall.p1, wall.p2)
  if dist < ball_radius {
    let seg = @types.vec2_sub(wall.p2, wall.p1)
    let contact = @types.vec2_add(wall.p1, @types.vec2_scale(seg, t))
    let normal = @types.segment_normal(wall.p1, wall.p2)
    // Make sure normal points toward ball
    let to_ball = @types.vec2_sub(ball_pos, contact)
    let dot = @types.vec2_dot(to_ball, normal)
    if dot < 0.0 {
      (true, @types.vec2_neg(normal), contact)
    } else {
      (true, normal, contact)
    }
  } else {
    (false, @types.vec2_zero(), @types.vec2_zero())
  }
}

///|
/// Check if ball hits a circular object. Returns true if overlapping.
pub fn check_circle_collision(
  ball_pos : @types.Vec2,
  ball_radius : Float,
  obj_pos : @types.Vec2,
  obj_radius : Float
) -> Bool {
  let dist = @types.vec2_dist(ball_pos, obj_pos)
  dist < ball_radius + obj_radius
}

///|
/// Check one-way gate: does the ball pass through in the allowed direction?
/// Returns (intersects_segment, correct_direction).
pub fn check_gate(
  ball_pos : @types.Vec2,
  ball_vel : @types.Vec2,
  ball_radius : Float,
  gate : @types.Gate
) -> (Bool, Bool) {
  let (dist, _t) = @types.point_to_segment_dist(ball_pos, gate.p1, gate.p2)
  if dist < ball_radius {
    let vel_dir = @types.vec2_normalize(ball_vel)
    let dot = @types.vec2_dot(vel_dir, gate.direction)
    (true, dot > 0.0)
  } else {
    (false, false)
  }
}

///|
/// Simulate one frame of physics for all active balls.
pub fn simulate_step(game : @types.Game, dt : Float) -> Unit {
  let level = match game.current_level {
    Some(l) => l
    None => return
  }
  // Track new balls to add from splitters
  let new_balls : Array[@types.Ball] = []
  for i in 0..<game.balls.length() {
    let ball = game.balls[i]
    if !(ball.active) {
      continue
    }
    // Store trail
    ball.trail.push(@types.vec2(ball.pos.x, ball.pos.y))
    if ball.trail.length() > @types.trail_length {
      ball.trail.remove(0) |> ignore
    }
    // Advance position
    ball.pos.x = ball.pos.x + ball.vel.x * dt
    ball.pos.y = ball.pos.y + ball.vel.y * dt
    // Check arena boundary collisions (4 walls of the arena)
    let ax : Float = 0.0
    let ay : Float = 0.0
    let aw = @types.arena_width
    let ah = @types.arena_height
    let br = @types.ball_radius
    if ball.pos.x - br < ax {
      ball.pos.x = ax + br
      ball.vel.x = -ball.vel.x
      ball.bounce_count += 1
      game.total_bounces += 1
    }
    if ball.pos.x + br > ax + aw {
      ball.pos.x = ax + aw - br
      ball.vel.x = -ball.vel.x
      ball.bounce_count += 1
      game.total_bounces += 1
    }
    if ball.pos.y - br < ay {
      ball.pos.y = ay + br
      ball.vel.y = -ball.vel.y
      ball.bounce_count += 1
      game.total_bounces += 1
    }
    if ball.pos.y + br > ay + ah {
      ball.pos.y = ay + ah - br
      ball.vel.y = -ball.vel.y
      ball.bounce_count += 1
      game.total_bounces += 1
    }
    // Check wall collisions
    for w in 0..<level.walls.length() {
      let (hit, normal, _contact) = check_wall_collision(
        ball.pos, br, level.walls[w],
      )
      if hit {
        let reflected = @types.vec2_reflect(ball.vel, normal)
        ball.vel.x = reflected.x
        ball.vel.y = reflected.y
        // Push ball away from wall
        ball.pos.x = ball.pos.x + normal.x * 1.0
        ball.pos.y = ball.pos.y + normal.y * 1.0
        ball.bounce_count += 1
        game.total_bounces += 1
      }
    }
    // Check target collisions
    for t in 0..<level.targets.length() {
      let target = level.targets[t]
      if !(target.hit) &&
        check_circle_collision(ball.pos, br, target.pos, target.radius) {
        target.hit = true
        target.hit_timer = 1.0
      }
    }
    // Check splitter collisions
    for s in 0..<level.splitters.length() {
      let sp = level.splitters[s]
      if check_circle_collision(ball.pos, br, sp.pos, sp.radius) {
        sp.pulse_timer = 0.5
        // Split: deactivate current, create 2 new balls
        if game.balls.length() + new_balls.length() + 2 <= @types.max_balls {
          ball.active = false
          let speed = @types.vec2_len(ball.vel)
          let vel_dir = @types.vec2_normalize(ball.vel)
          let dir1 = @types.vec2_rotate(vel_dir, @types.splitter_angle)
          let dir2 = @types.vec2_rotate(vel_dir, -@types.splitter_angle)
          let push = @types.vec2_scale(
            @types.vec2_normalize(@types.vec2_sub(ball.pos, sp.pos)),
            sp.radius + br + 2.0,
          )
          let spawn_pos = @types.vec2_add(sp.pos, push)
          let b1 = @types.new_ball(
            spawn_pos,
            @types.vec2_scale(dir1, speed),
          )
          b1.bounce_count = ball.bounce_count
          let b2 = @types.new_ball(
            spawn_pos,
            @types.vec2_scale(dir2, speed),
          )
          b2.bounce_count = ball.bounce_count
          new_balls.push(b1)
          new_balls.push(b2)
        }
      }
    }
    // Check bumper collisions
    for b in 0..<level.bumpers.length() {
      let bump = level.bumpers[b]
      if check_circle_collision(ball.pos, br, bump.pos, bump.radius) {
        bump.hit_timer = 0.3
        // Amplified bounce: reflect away from bumper center with speed boost
        let away = @types.vec2_normalize(
          @types.vec2_sub(ball.pos, bump.pos),
        )
        let speed : Float = @types.vec2_len(ball.vel) * 1.2
        let clamped : Float = @types.minf(speed, @types.ball_speed * 1.5)
        ball.vel.x = away.x * clamped
        ball.vel.y = away.y * clamped
        // Push out
        let push_dist : Float = bump.radius + br + 2.0
        ball.pos.x = bump.pos.x + away.x * push_dist
        ball.pos.y = bump.pos.y + away.y * push_dist
        ball.bounce_count += 1
        game.total_bounces += 1
      }
    }
    // Check gate collisions
    for g in 0..<level.gates.length() {
      let gate = level.gates[g]
      let (intersects, correct) = check_gate(ball.pos, ball.vel, br, gate)
      if intersects && !correct {
        // Block: reflect off the gate like a wall
        let normal = @types.segment_normal(gate.p1, gate.p2)
        let to_ball = @types.vec2_sub(ball.pos, gate.p1)
        let dot = @types.vec2_dot(to_ball, normal)
        let n = if dot < 0.0 { @types.vec2_neg(normal) } else { normal }
        let reflected = @types.vec2_reflect(ball.vel, n)
        ball.vel.x = reflected.x
        ball.vel.y = reflected.y
        ball.pos.x = ball.pos.x + n.x * 2.0
        ball.pos.y = ball.pos.y + n.y * 2.0
        ball.bounce_count += 1
        game.total_bounces += 1
      }
    }
    // Check pickup collisions
    for p in 0..<level.pickups.length() {
      let pk = level.pickups[p]
      if !(pk.collected) &&
        check_circle_collision(ball.pos, br, pk.pos, pk.radius) {
        pk.collected = true
      }
    }
    // Deactivate if too many bounces
    if ball.bounce_count > @types.max_bounces {
      ball.active = false
    }
  }
  // Add split balls
  for b in new_balls {
    game.balls.push(b)
  }
}

///|
/// Update animation timers for level objects.
pub fn update_timers(game : @types.Game, dt : Float) -> Unit {
  let level = match game.current_level {
    Some(l) => l
    None => return
  }
  for i in 0..<level.targets.length() {
    if level.targets[i].hit_timer > 0.0 {
      level.targets[i].hit_timer = level.targets[i].hit_timer - dt
    }
  }
  for i in 0..<level.splitters.length() {
    if level.splitters[i].pulse_timer > 0.0 {
      level.splitters[i].pulse_timer = level.splitters[i].pulse_timer - dt
    }
  }
  for i in 0..<level.bumpers.length() {
    if level.bumpers[i].hit_timer > 0.0 {
      level.bumpers[i].hit_timer = level.bumpers[i].hit_timer - dt
    }
  }
}
