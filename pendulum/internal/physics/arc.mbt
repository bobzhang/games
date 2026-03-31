///|
pub fn compute_arc(
  anchor : @types.Vec2i,
  length : Int
) -> Array[@types.ArcPoint] {
  @types.compute_arc_points(anchor, length)
}

///|
pub fn find_bottom_index(arc : Array[@types.ArcPoint]) -> Int {
  // Find the arc point that is most directly below the anchor (angle closest to PI/2)
  let target : Float = @types.pi / 2.0
  let mut best = 0
  let mut best_diff : Float = 99999.0
  for i = 0; i < arc.length(); i = i + 1 {
    let diff = @types.absf(arc[i].angle - target)
    if diff < best_diff {
      best_diff = diff
      best = i
    }
  }
  best
}

///|
pub fn compute_swing_extent(
  arc : Array[@types.ArcPoint],
  bottom_index : Int
) -> (Int, Int) {
  // Returns (left_limit, right_limit) indices
  // Gravity effect: weight swings less far up.
  // Simple model: can swing up to 70% of the arc each side from bottom
  let total = arc.length()
  if total == 0 {
    return (0, 0)
  }
  let left_extent = total * 7 / 10
  let right_extent = total * 7 / 10
  let left_limit = @types.maxi(0, bottom_index - left_extent)
  let right_limit = @types.mini(total - 1, bottom_index + right_extent)
  (left_limit, right_limit)
}

///|
pub fn check_peg_wrap(
  rope_anchor : @types.Vec2i,
  weight_pos : @types.Vec2i,
  pegs : Array[@types.Vec2i],
  wrapped : Array[@types.Vec2i]
) -> @types.Vec2i? {
  // Check if the rope line from anchor to weight passes near a peg
  // If so, the rope wraps around that peg
  let ax = Float::from_int(rope_anchor.x)
  let ay = Float::from_int(rope_anchor.y)
  let wx = Float::from_int(weight_pos.x)
  let wy = Float::from_int(weight_pos.y)
  let dx = wx - ax
  let dy = wy - ay
  let line_len = @types.sqrtf(dx * dx + dy * dy)
  if line_len < 1.0 {
    return None
  }
  let mut best_peg : @types.Vec2i? = None
  let mut best_dist : Float = 99999.0
  for i = 0; i < pegs.length(); i = i + 1 {
    let peg = pegs[i]
    // Skip if already wrapped
    let mut already = false
    for j = 0; j < wrapped.length(); j = j + 1 {
      if wrapped[j].x == peg.x && wrapped[j].y == peg.y {
        already = true
        break
      }
    }
    if already {
      continue
    }
    // Skip if peg is the anchor
    if peg.x == rope_anchor.x && peg.y == rope_anchor.y {
      continue
    }
    let px = Float::from_int(peg.x)
    let py = Float::from_int(peg.y)
    // Point-to-line-segment distance
    let t = ((px - ax) * dx + (py - ay) * dy) / (line_len * line_len)
    if t > 0.1 && t < 0.9 {
      let proj_x = ax + t * dx
      let proj_y = ay + t * dy
      let d = @types.sqrtf(
        (px - proj_x) * (px - proj_x) + (py - proj_y) * (py - proj_y),
      )
      // Wrap if rope passes within 0.8 cells of peg
      if d < 0.8 && d < best_dist {
        best_dist = d
        best_peg = Some(peg)
      }
    }
  }
  best_peg
}

///|
pub fn compute_new_rope_length(
  new_anchor : @types.Vec2i,
  weight_pos : @types.Vec2i
) -> Int {
  let dx = @types.absi(weight_pos.x - new_anchor.x)
  let dy = @types.absi(weight_pos.y - new_anchor.y)
  let dist = @types.sqrtf(
    Float::from_int(dx * dx + dy * dy),
  )
  let len = @types.roundf(dist)
  @types.maxi(1, len)
}
