///|
/// Compute intersection point of two line segments.
/// Segment 1: p1 to p2, Segment 2: p3 to p4.
/// Returns Some(point) if they cross, None if parallel or non-crossing.
pub fn segment_intersection(
  p1 : @types.Vec2f,
  p2 : @types.Vec2f,
  p3 : @types.Vec2f,
  p4 : @types.Vec2f,
) -> @types.Vec2f? {
  let x1 = p1.x
  let y1 = p1.y
  let x2 = p2.x
  let y2 = p2.y
  let x3 = p3.x
  let y3 = p3.y
  let x4 = p4.x
  let y4 = p4.y
  let denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
  // Parallel check
  if @types.absf(denom) < 0.0001 {
    return None
  }
  let t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denom
  let u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / denom
  // Check that intersection is within both segments
  if t >= 0.0 && t <= 1.0 && u >= 0.0 && u <= 1.0 {
    let ix = x1 + t * (x2 - x1)
    let iy = y1 + t * (y2 - y1)
    Some(@types.vec2f(ix, iy))
  } else {
    None
  }
}

///|
/// Compute all intersection points from a set of strings on the peg frame.
pub fn compute_all_intersections(
  strings : Array[@types.StringLine],
  pegs : Array[@types.Peg],
) -> Array[@types.Intersection] {
  let result : Array[@types.Intersection] = []
  for i in 0..<strings.length() {
    let s1 = strings[i]
    let p1 = pegs[s1.peg_a].pos
    let p2 = pegs[s1.peg_b].pos
    for j = i + 1; j < strings.length(); j = j + 1 {
      let s2 = strings[j]
      let p3 = pegs[s2.peg_a].pos
      let p4 = pegs[s2.peg_b].pos
      match segment_intersection(p1, p2, p3, p4) {
        Some(pt) => result.push({ pos: pt, matched_target: -1 })
        None => ()
      }
    }
  }
  result
}

///|
/// Match intersections to target dots. Returns how many targets were hit.
pub fn match_intersections_to_targets(
  intersections : Array[@types.Intersection],
  targets : Array[@types.TargetDot],
) -> Int {
  // Reset all
  for i in 0..<targets.length() {
    targets[i].hit = false
  }
  for i in 0..<intersections.length() {
    intersections[i].matched_target = -1
  }
  let mut hit_count = 0
  // Greedy matching: for each target, find the closest unmatched intersection
  for t in 0..<targets.length() {
    let mut best_dist : Float = @types.tolerance + 1.0
    let mut best_idx = -1
    for i in 0..<intersections.length() {
      if intersections[i].matched_target == -1 {
        let d = @types.vec2f_dist(intersections[i].pos, targets[t].pos)
        if d < best_dist {
          best_dist = d
          best_idx = i
        }
      }
    }
    if best_idx >= 0 && best_dist <= @types.tolerance {
      targets[t].hit = true
      intersections[best_idx].matched_target = t
      hit_count = hit_count + 1
    }
  }
  hit_count
}
