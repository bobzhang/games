///|
test "vec2_normalize produces unit length" {
  let v = @types.vec2(3.0, 4.0)
  let n = @types.vec2_normalize(v)
  let len = @types.vec2_len(n)
  // Should be approximately 1.0
  assert_true(@types.absf(len - 1.0) < 0.001)
}

///|
test "vec2_normalize of zero returns zero" {
  let v = @types.vec2(0.0, 0.0)
  let n = @types.vec2_normalize(v)
  assert_true(@types.absf(n.x) < 0.001 && @types.absf(n.y) < 0.001)
}

///|
test "vec2_reflect horizontal surface" {
  // Ball moving down-right hits horizontal surface (normal = up)
  let vel = @types.vec2(1.0, 1.0)
  let normal = @types.vec2(0.0, -1.0)
  let reflected = @types.vec2_reflect(vel, normal)
  // x should stay same, y should flip
  assert_true(@types.absf(reflected.x - 1.0) < 0.001)
  assert_true(@types.absf(reflected.y - -1.0) < 0.001)
}

///|
test "vec2_reflect vertical surface" {
  let vel = @types.vec2(1.0, 1.0)
  let normal = @types.vec2(-1.0, 0.0)
  let reflected = @types.vec2_reflect(vel, normal)
  assert_true(@types.absf(reflected.x - -1.0) < 0.001)
  assert_true(@types.absf(reflected.y - 1.0) < 0.001)
}

///|
test "vec2_dot product" {
  let a = @types.vec2(1.0, 0.0)
  let b = @types.vec2(0.0, 1.0)
  let dot = @types.vec2_dot(a, b)
  assert_true(@types.absf(dot) < 0.001)
  let c = @types.vec2(1.0, 0.0)
  let d = @types.vec2(1.0, 0.0)
  let dot2 = @types.vec2_dot(c, d)
  assert_true(@types.absf(dot2 - 1.0) < 0.001)
}

///|
test "point_to_segment_dist basic" {
  let p = @types.vec2(5.0, 5.0)
  let a = @types.vec2(0.0, 0.0)
  let b = @types.vec2(10.0, 0.0)
  let (dist, _t) = @types.point_to_segment_dist(p, a, b)
  assert_true(@types.absf(dist - 5.0) < 0.001)
}

///|
test "point_to_segment_dist endpoint" {
  let p = @types.vec2(-5.0, 0.0)
  let a = @types.vec2(0.0, 0.0)
  let b = @types.vec2(10.0, 0.0)
  let (dist, t) = @types.point_to_segment_dist(p, a, b)
  assert_true(@types.absf(dist - 5.0) < 0.001)
  assert_true(@types.absf(t) < 0.001)
}

///|
test "segment_intersect cross" {
  let p1 = @types.vec2(0.0, 0.0)
  let p2 = @types.vec2(10.0, 10.0)
  let p3 = @types.vec2(10.0, 0.0)
  let p4 = @types.vec2(0.0, 10.0)
  let result = @types.segment_intersect(p1, p2, p3, p4)
  assert_true(result is Some(_))
}

///|
test "segment_intersect parallel no intersection" {
  let p1 = @types.vec2(0.0, 0.0)
  let p2 = @types.vec2(10.0, 0.0)
  let p3 = @types.vec2(0.0, 5.0)
  let p4 = @types.vec2(10.0, 5.0)
  let result = @types.segment_intersect(p1, p2, p3, p4)
  assert_true(result is None)
}

///|
test "all_targets_hit with none hit" {
  let level : @types.Level = {
    walls: [],
    targets: [
      @types.new_target(100.0, 100.0, 15.0),
      @types.new_target(200.0, 200.0, 15.0),
    ],
    splitters: [],
    gates: [],
    bumpers: [],
    pickups: [],
    start_pos: @types.vec2(50.0, 50.0),
    par_bounces: 5,
  }
  assert_true(!@types.all_targets_hit(level))
}

///|
test "all_targets_hit with all hit" {
  let level : @types.Level = {
    walls: [],
    targets: [
      @types.new_target(100.0, 100.0, 15.0),
      @types.new_target(200.0, 200.0, 15.0),
    ],
    splitters: [],
    gates: [],
    bumpers: [],
    pickups: [],
    start_pos: @types.vec2(50.0, 50.0),
    par_bounces: 5,
  }
  level.targets[0].hit = true
  level.targets[1].hit = true
  assert_true(@types.all_targets_hit(level))
}

///|
test "global_level_index" {
  assert_eq(@types.global_level_index(0, 0), 0)
  assert_eq(@types.global_level_index(0, 9), 9)
  assert_eq(@types.global_level_index(1, 0), 10)
  assert_eq(@types.global_level_index(2, 9), 29)
}
