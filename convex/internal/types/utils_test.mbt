///|
test "absf" {
  inspect(@types.absf(-3.5), content="3.5")
  inspect(@types.absf(2.0), content="2")
  inspect(@types.absf(0.0), content="0")
}

///|
test "maxf and minf" {
  inspect(@types.maxf(3.0, 7.0), content="7")
  inspect(@types.maxf(10.0, 2.0), content="10")
  inspect(@types.minf(3.0, 7.0), content="3")
  inspect(@types.minf(10.0, 2.0), content="2")
}

///|
test "clampf" {
  inspect(@types.clampf(5.0, 0.0, 10.0), content="5")
  inspect(@types.clampf(-1.0, 0.0, 10.0), content="0")
  inspect(@types.clampf(15.0, 0.0, 10.0), content="10")
  inspect(@types.clampf(0.0, 0.0, 10.0), content="0")
  inspect(@types.clampf(10.0, 0.0, 10.0), content="10")
}

///|
test "lerpf" {
  inspect(@types.lerpf(0.0, 10.0, 0.5), content="5")
  inspect(@types.lerpf(0.0, 10.0, 0.0), content="0")
  inspect(@types.lerpf(0.0, 10.0, 1.0), content="10")
  inspect(@types.lerpf(2.0, 8.0, 0.25), content="3.5")
}

///|
test "sqrtf" {
  inspect(@types.sqrtf(4.0), content="2")
  inspect(@types.sqrtf(9.0), content="3")
  inspect(@types.sqrtf(0.0), content="0")
}

///|
test "pt constructor" {
  let p = @types.pt(3.5, 7.0)
  inspect(p.x, content="3.5")
  inspect(p.y, content="7")
}

///|
test "point_dist" {
  let a = @types.pt(0.0, 0.0)
  let b = @types.pt(3.0, 4.0)
  inspect(@types.point_dist(a, b), content="5")
  inspect(@types.point_dist(a, a), content="0")
}

///|
test "point_dist_sq" {
  let a = @types.pt(0.0, 0.0)
  let b = @types.pt(3.0, 4.0)
  inspect(@types.point_dist_sq(a, b), content="25")
}

///|
test "cross_product" {
  let o = @types.pt(0.0, 0.0)
  let a = @types.pt(1.0, 0.0)
  let b = @types.pt(0.0, 1.0)
  // Cross product of (1,0)x(0,1) = 1
  inspect(@types.cross_product(o, a, b), content="1")
  // Reversed gives -1
  inspect(@types.cross_product(o, b, a), content="-1")
  // Collinear gives 0
  let c = @types.pt(2.0, 0.0)
  inspect(@types.cross_product(o, a, c), content="0")
}

///|
test "dot_product" {
  let a = @types.pt(0.0, 0.0)
  let b = @types.pt(1.0, 0.0)
  let c = @types.pt(0.0, 0.0)
  let d = @types.pt(0.0, 1.0)
  // Perpendicular vectors: dot = 0
  inspect(@types.dot_product(a, b, c, d), content="0")
  // Parallel vectors: dot = 1
  let e = @types.pt(1.0, 0.0)
  inspect(@types.dot_product(a, b, c, e), content="1")
}

///|
test "snap_to_grid" {
  // grid_snap = 20.0
  inspect(@types.snap_to_grid(0.0), content="0")
  inspect(@types.snap_to_grid(10.0), content="20")
  inspect(@types.snap_to_grid(20.0), content="20")
  inspect(@types.snap_to_grid(25.0), content="20")
  inspect(@types.snap_to_grid(35.0), content="40")
}

///|
test "snap_point" {
  let p = @types.snap_point(@types.pt(15.0, 35.0))
  inspect(p.x, content="20")
  inspect(p.y, content="40")
}

///|
test "point_in_plane" {
  // plane_x=240, plane_y=60, width=800, height=600
  inspect(@types.point_in_plane(@types.pt(240.0, 60.0)), content="true")
  inspect(@types.point_in_plane(@types.pt(640.0, 360.0)), content="true")
  inspect(@types.point_in_plane(@types.pt(1040.0, 660.0)), content="true")
  inspect(@types.point_in_plane(@types.pt(100.0, 60.0)), content="false")
  inspect(@types.point_in_plane(@types.pt(240.0, 10.0)), content="false")
}

///|
test "point_in_polygon triangle" {
  let triangle : Array[@types.Point] = [
    @types.pt(0.0, 0.0),
    @types.pt(10.0, 0.0),
    @types.pt(5.0, 10.0),
  ]
  inspect(
    @types.point_in_polygon(@types.pt(5.0, 3.0), triangle),
    content="true",
  )
  inspect(
    @types.point_in_polygon(@types.pt(-5.0, 0.0), triangle),
    content="false",
  )
  inspect(
    @types.point_in_polygon(@types.pt(20.0, 20.0), triangle),
    content="false",
  )
}

///|
test "point_in_polygon needs at least 3 vertices" {
  let empty : Array[@types.Point] = []
  inspect(@types.point_in_polygon(@types.pt(0.0, 0.0), empty), content="false")
  let line : Array[@types.Point] = [@types.pt(0.0, 0.0), @types.pt(1.0, 1.0)]
  inspect(@types.point_in_polygon(@types.pt(0.5, 0.5), line), content="false")
}

///|
test "point_to_segment_dist" {
  let a = @types.pt(0.0, 0.0)
  let b = @types.pt(10.0, 0.0)
  // Point directly above midpoint
  inspect(@types.point_to_segment_dist(@types.pt(5.0, 3.0), a, b), content="3")
  // Point at endpoint
  inspect(@types.point_to_segment_dist(@types.pt(0.0, 0.0), a, b), content="0")
  // Point beyond endpoint (closest to b)
  inspect(@types.point_to_segment_dist(@types.pt(13.0, 4.0), a, b), content="5")
}

///|
test "point_to_segment_dist degenerate segment" {
  let a = @types.pt(5.0, 5.0)
  // When segment is a single point
  inspect(@types.point_to_segment_dist(@types.pt(8.0, 9.0), a, a), content="5")
}

///|
test "make_polygon" {
  let verts : Array[@types.Point] = [
    @types.pt(0.0, 0.0),
    @types.pt(1.0, 0.0),
    @types.pt(0.0, 1.0),
  ]
  let poly = @types.make_polygon(verts)
  inspect(poly.vertices.length(), content="3")
}

///|
test "new_level_score" {
  let s = @types.new_level_score()
  inspect(s.completed, content="false")
  inspect(s.stars, content="0")
  inspect(s.points_used, content="0")
}

///|
test "clone_points is independent" {
  let pts : Array[@types.Point] = [@types.pt(1.0, 2.0), @types.pt(3.0, 4.0)]
  let pts2 = @types.clone_points(pts)
  pts[0].x = 99.0
  inspect(pts2[0].x, content="1")
}

///|
test "push_undo and pop_undo" {
  let game = @types.new_game()
  game.placed_points = [@types.pt(1.0, 2.0)]
  @types.push_undo(game)
  game.placed_points = [@types.pt(5.0, 6.0)]
  inspect(game.placed_points[0].x, content="5")
  let ok = @types.pop_undo(game)
  inspect(ok, content="true")
  inspect(game.placed_points[0].x, content="1")
}

///|
test "pop_undo empty stack" {
  let game = @types.new_game()
  inspect(@types.pop_undo(game), content="false")
}

///|
test "tier_name" {
  inspect(@types.tier_name(Vertices), content="VERTICES")
  inspect(@types.tier_name(Edges), content="EDGES")
  inspect(@types.tier_name(Sculpt), content="SCULPT")
}

///|
test "tier_start_index" {
  inspect(@types.tier_start_index(Vertices), content="0")
  inspect(@types.tier_start_index(Edges), content="8")
  inspect(@types.tier_start_index(Sculpt), content="17")
}

///|
test "tier_level_count" {
  inspect(@types.tier_level_count(Vertices), content="8")
  inspect(@types.tier_level_count(Edges), content="9")
  inspect(@types.tier_level_count(Sculpt), content="8")
}

///|
test "set_message" {
  let game = @types.new_game()
  @types.set_message(game, "Hello", 1.5)
  inspect(game.message, content="Hello")
  inspect(game.message_timer, content="1.5")
}

///|
test "floorf" {
  inspect(@types.floorf(3.7), content="3")
  inspect(@types.floorf(3.0), content="3")
  inspect(@types.floorf(-1.5), content="-2")
  inspect(@types.floorf(0.0), content="0")
}

///|
test "new_game initial state" {
  let game = @types.new_game()
  inspect(game.screen, content="Title")
  inspect(game.play_state, content="Placing")
  inspect(game.placed_points.length(), content="0")
  inspect(game.scores.length(), content="25")
  inspect(game.undo_stack.length(), content="0")
}

///|
test "sinf and cosf basic" {
  inspect(@types.sinf(0.0), content="0")
  inspect(@types.cosf(0.0), content="1")
}
