///|
test "crossing segments produce intersection" {
  // Horizontal line (0,0)-(10,0) crossed by vertical (5,-5)-(5,5)
  let p1 = @types.vec2f(0.0, 0.0)
  let p2 = @types.vec2f(10.0, 0.0)
  let p3 = @types.vec2f(5.0, -5.0)
  let p4 = @types.vec2f(5.0, 5.0)
  match @geometry.segment_intersection(p1, p2, p3, p4) {
    Some(pt) => {
      inspect(@types.absf(pt.x - 5.0) < 0.01, content="true")
      inspect(@types.absf(pt.y - 0.0) < 0.01, content="true")
    }
    None => inspect(false, content="true")
  }
}

///|
test "parallel segments return None" {
  let p1 = @types.vec2f(0.0, 0.0)
  let p2 = @types.vec2f(10.0, 0.0)
  let p3 = @types.vec2f(0.0, 5.0)
  let p4 = @types.vec2f(10.0, 5.0)
  match @geometry.segment_intersection(p1, p2, p3, p4) {
    Some(_) => inspect(false, content="true")
    None => inspect(true, content="true")
  }
}

///|
test "non-crossing segments return None" {
  // Two segments that don't reach each other
  let p1 = @types.vec2f(0.0, 0.0)
  let p2 = @types.vec2f(2.0, 0.0)
  let p3 = @types.vec2f(5.0, -5.0)
  let p4 = @types.vec2f(5.0, 5.0)
  match @geometry.segment_intersection(p1, p2, p3, p4) {
    Some(_) => inspect(false, content="true")
    None => inspect(true, content="true")
  }
}

///|
test "compute_all_intersections with two crossing strings" {
  let pegs = @types.make_pegs()
  // String from peg 0 to peg 12 (top to bottom) and peg 6 to peg 18 (right to left)
  let strings : Array[@types.StringLine] = [
    { peg_a: 0, peg_b: 12, },
    { peg_a: 6, peg_b: 18, },
  ]
  let intersections = @geometry.compute_all_intersections(strings, pegs)
  // These should cross near the center
  inspect(intersections.length(), content="1")
  let pt = intersections[0].pos
  let dx = @types.absf(pt.x - @types.frame_center_x)
  let dy = @types.absf(pt.y - @types.frame_center_y)
  inspect(dx < 2.0, content="true")
  inspect(dy < 2.0, content="true")
}

///|
test "match_intersections_to_targets within tolerance" {
  let intersections : Array[@types.Intersection] = [
    { pos: @types.vec2f(100.0, 100.0), matched_target: -1, },
  ]
  let targets : Array[@types.TargetDot] = [
    { pos: @types.vec2f(105.0, 100.0), hit: false, },
  ]
  let hit_count = @geometry.match_intersections_to_targets(
    intersections, targets,
  )
  inspect(hit_count, content="1")
  inspect(targets[0].hit, content="true")
  inspect(intersections[0].matched_target, content="0")
}

///|
test "match_intersections_to_targets outside tolerance" {
  let intersections : Array[@types.Intersection] = [
    { pos: @types.vec2f(100.0, 100.0), matched_target: -1, },
  ]
  let targets : Array[@types.TargetDot] = [
    { pos: @types.vec2f(200.0, 200.0), hit: false, },
  ]
  let hit_count = @geometry.match_intersections_to_targets(
    intersections, targets,
  )
  inspect(hit_count, content="0")
  inspect(targets[0].hit, content="false")
}

///|
test "compute_all_intersections with no crossing strings" {
  let pegs = @types.make_pegs()
  // Two adjacent strings that won't cross
  let strings : Array[@types.StringLine] = [
    { peg_a: 0, peg_b: 1, },
    { peg_a: 2, peg_b: 3, },
  ]
  let intersections = @geometry.compute_all_intersections(strings, pegs)
  inspect(intersections.length(), content="0")
}

///|
test "multiple intersections from multiple strings" {
  let pegs = @types.make_pegs()
  // 3 strings through center should give 3 intersections
  let strings : Array[@types.StringLine] = [
    { peg_a: 0, peg_b: 12, },
    { peg_a: 4, peg_b: 16, },
    { peg_a: 8, peg_b: 20, },
  ]
  let intersections = @geometry.compute_all_intersections(strings, pegs)
  inspect(intersections.length(), content="3")
}
