///|
pub fn compute_hull(points : Array[@types.Point]) -> Array[@types.Point] {
  let n = points.length()
  if n < 3 {
    let result : Array[@types.Point] = Array::new(capacity=n)
    for i in 0..<n {
      result.push(points[i])
    }
    return result
  }
  // Find the lowest point (highest y in screen coords, but we use lowest y for math)
  let mut lowest = 0
  for i in 1..<n {
    if points[i].y < points[lowest].y ||
      (points[i].y == points[lowest].y && points[i].x < points[lowest].x) {
      lowest = i
    }
  }
  // Create sorted copy
  let sorted : Array[@types.Point] = Array::new(capacity=n)
  // Put pivot first
  sorted.push(points[lowest])
  for i in 0..<n {
    if i != lowest {
      sorted.push(points[i])
    }
  }
  let pivot = sorted[0]
  // Sort by polar angle relative to pivot
  // Simple insertion sort to avoid needing complex sort
  for i in 2..<sorted.length() {
    let key = sorted[i]
    let mut j = i - 1
    while j >= 1 && compare_angle(pivot, sorted[j], key) > 0 {
      sorted[j + 1] = sorted[j]
      j -= 1
    }
    sorted[j + 1] = key
  }
  // Remove collinear points (keep farthest)
  let filtered : Array[@types.Point] = Array::new(capacity=n)
  filtered.push(sorted[0])
  let mut i = 1
  while i < sorted.length() {
    // Skip points with same angle, keeping the farthest
    let mut j = i
    while j + 1 < sorted.length() &&
      @types.absf(@types.cross_product(pivot, sorted[j], sorted[j + 1])) <
        0.001 {
      j += 1
    }
    filtered.push(sorted[j])
    i = j + 1
  }
  if filtered.length() < 3 {
    return filtered
  }
  // Graham scan
  let stack : Array[@types.Point] = Array::new(capacity=filtered.length())
  stack.push(filtered[0])
  stack.push(filtered[1])
  for k in 2..<filtered.length() {
    while stack.length() > 1 {
      let top = stack[stack.length() - 1]
      let next_to_top = stack[stack.length() - 2]
      let cross = @types.cross_product(next_to_top, top, filtered[k])
      if cross > 0.0 {
        break
      }
      // Remove top
      let new_stack_len = stack.length() - 1
      let _ = stack.pop()
      let _ = new_stack_len
    }
    stack.push(filtered[k])
  }
  stack
}

///|
fn compare_angle(
  pivot : @types.Point,
  a : @types.Point,
  b : @types.Point
) -> Int {
  let cross = @types.cross_product(pivot, a, b)
  if @types.absf(cross) < 0.001 {
    // Collinear - closer one first
    let da = @types.point_dist_sq(pivot, a)
    let db = @types.point_dist_sq(pivot, b)
    if da < db {
      -1
    } else if da > db {
      1
    } else {
      0
    }
  } else if cross > 0.0 {
    -1
  } else {
    1
  }
}

///|
pub fn hull_edge_count(hull : Array[@types.Point]) -> Int {
  hull.length()
}

///|
pub fn is_point_on_hull(
  p : @types.Point,
  hull : Array[@types.Point]
) -> Bool {
  let n = hull.length()
  if n < 2 {
    return false
  }
  for i in 0..<n {
    let a = hull[i]
    let b = hull[(i + 1) % n]
    let d = @types.point_to_segment_dist(p, a, b)
    if d < @types.tolerance {
      return true
    }
  }
  false
}
