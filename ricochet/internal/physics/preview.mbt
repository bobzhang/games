///|
/// Compute preview path: trace a ray from start_pos at aim_angle,
/// bouncing off walls, to produce bounce points for the preview line.
pub fn compute_preview(
  level : @types.Level,
  start_pos : @types.Vec2,
  aim_angle : Float,
  max_preview_bounces : Int
) -> Array[@types.PreviewPoint] {
  let points : Array[@types.PreviewPoint] = []
  let mut px = start_pos.x
  let mut py = start_pos.y
  let mut dx = @types.cosf(aim_angle)
  let mut dy = @types.sinf(aim_angle)
  points.push({ pos: @types.vec2(px, py), is_bounce: false })
  let step_dist : Float = 2.0
  let max_steps = 3000
  let mut bounces = 0
  let br = @types.ball_radius
  for _step in 0..<max_steps {
    if bounces >= max_preview_bounces {
      break
    }
    let nx = px + dx * step_dist
    let ny = py + dy * step_dist
    let mut bounced = false
    // Check arena boundaries
    if nx - br < 0.0 {
      dx = -dx
      bounced = true
    } else if nx + br > @types.arena_width {
      dx = -dx
      bounced = true
    }
    if ny - br < 0.0 {
      dy = -dy
      bounced = true
    } else if ny + br > @types.arena_height {
      dy = -dy
      bounced = true
    }
    // Check wall collisions
    for w in 0..<level.walls.length() {
      let wall = level.walls[w]
      let ball_pos = @types.vec2(nx, ny)
      let (dist, t) = @types.point_to_segment_dist(ball_pos, wall.p1, wall.p2)
      if dist < br {
        let seg = @types.vec2_sub(wall.p2, wall.p1)
        let _contact = @types.vec2_add(
          wall.p1, @types.vec2_scale(seg, t),
        )
        let normal = @types.segment_normal(wall.p1, wall.p2)
        let vel = @types.vec2(dx, dy)
        let to_ball = @types.vec2_sub(ball_pos, _contact)
        let dot = @types.vec2_dot(to_ball, normal)
        let n = if dot < 0.0 { @types.vec2_neg(normal) } else { normal }
        let reflected = @types.vec2_reflect(vel, n)
        dx = reflected.x
        dy = reflected.y
        bounced = true
        break
      }
    }
    // Check bumper collisions for preview
    for b in 0..<level.bumpers.length() {
      let bump = level.bumpers[b]
      let ball_pos = @types.vec2(nx, ny)
      let dist = @types.vec2_dist(ball_pos, bump.pos)
      if dist < br + bump.radius {
        let away = @types.vec2_normalize(@types.vec2_sub(ball_pos, bump.pos))
        dx = away.x
        dy = away.y
        bounced = true
        break
      }
    }
    // Check gate collisions for preview
    for g in 0..<level.gates.length() {
      let gate = level.gates[g]
      let ball_pos = @types.vec2(nx, ny)
      let (dist, _t) = @types.point_to_segment_dist(
        ball_pos, gate.p1, gate.p2,
      )
      if dist < br {
        let vel_dir = @types.vec2_normalize(@types.vec2(dx, dy))
        let dot = @types.vec2_dot(vel_dir, gate.direction)
        if dot <= 0.0 {
          // Blocked: reflect
          let normal = @types.segment_normal(gate.p1, gate.p2)
          let vel = @types.vec2(dx, dy)
          let to_ball = @types.vec2_sub(ball_pos, gate.p1)
          let d = @types.vec2_dot(to_ball, normal)
          let n = if d < 0.0 {
            @types.vec2_neg(normal)
          } else {
            normal
          }
          let reflected = @types.vec2_reflect(vel, n)
          dx = reflected.x
          dy = reflected.y
          bounced = true
        }
        break
      }
    }
    px = px + dx * step_dist
    py = py + dy * step_dist
    // Clamp to arena
    px = @types.clampf(px, br, @types.arena_width - br)
    py = @types.clampf(py, br, @types.arena_height - br)
    if bounced {
      bounces += 1
      points.push({ pos: @types.vec2(px, py), is_bounce: true })
    }
  }
  // Add final position
  points.push({ pos: @types.vec2(px, py), is_bounce: false })
  points
}
