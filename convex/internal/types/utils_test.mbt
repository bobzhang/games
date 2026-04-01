///|
test "absf" {
  inspect(absf(-3.5), content="3.5")
  inspect(absf(2.0), content="2")
  inspect(absf(0.0), content="0")
}

///|
test "maxf and minf" {
  inspect(maxf(3.0, 7.0), content="7")
  inspect(maxf(10.0, 2.0), content="10")
  inspect(minf(3.0, 7.0), content="3")
  inspect(minf(10.0, 2.0), content="2")
}

///|
test "clampf" {
  inspect(clampf(5.0, 0.0, 10.0), content="5")
  inspect(clampf(-1.0, 0.0, 10.0), content="0")
  inspect(clampf(15.0, 0.0, 10.0), content="10")
  inspect(clampf(0.0, 0.0, 10.0), content="0")
  inspect(clampf(10.0, 0.0, 10.0), content="10")
}

///|
test "lerpf" {
  inspect(lerpf(0.0, 10.0, 0.5), content="5")
  inspect(lerpf(0.0, 10.0, 0.0), content="0")
  inspect(lerpf(0.0, 10.0, 1.0), content="10")
  inspect(lerpf(2.0, 8.0, 0.25), content="3.5")
}

///|
test "sqrtf" {
  inspect(sqrtf(4.0), content="2")
  inspect(sqrtf(9.0), content="3")
  inspect(sqrtf(0.0), content="0")
}

///|
test "pt constructor" {
  let p = pt(3.5, 7.0)
  inspect(p.x, content="3.5")
  inspect(p.y, content="7")
}

///|
test "point_dist" {
  let a = pt(0.0, 0.0)
  let b = pt(3.0, 4.0)
  inspect(point_dist(a, b), content="5")
  inspect(point_dist(a, a), content="0")
}

///|
test "point_dist_sq" {
  let a = pt(0.0, 0.0)
  let b = pt(3.0, 4.0)
  inspect(point_dist_sq(a, b), content="25")
}

///|
test "cross_product" {
  let o = pt(0.0, 0.0)
  let a = pt(1.0, 0.0)
  let b = pt(0.0, 1.0)
  // Cross product of (1,0)x(0,1) = 1
  inspect(cross_product(o, a, b), content="1")
  // Reversed gives -1
  inspect(cross_product(o, b, a), content="-1")
  // Collinear gives 0
  let c = pt(2.0, 0.0)
  inspect(cross_product(o, a, c), content="0")
}

///|
test "dot_product" {
  let a = pt(0.0, 0.0)
  let b = pt(1.0, 0.0)
  let c = pt(0.0, 0.0)
  let d = pt(0.0, 1.0)
  // Perpendicular vectors: dot = 0
  inspect(dot_product(a, b, c, d), content="0")
  // Parallel vectors: dot = 1
  let e = pt(1.0, 0.0)
  inspect(dot_product(a, b, c, e), content="1")
}

///|
test "snap_to_grid" {
  // grid_snap = 20.0
  inspect(snap_to_grid(0.0), content="0")
  inspect(snap_to_grid(10.0), content="20")
  inspect(snap_to_grid(20.0), content="20")
  inspect(snap_to_grid(25.0), content="20")
  inspect(snap_to_grid(35.0), content="40")
}

///|
test "snap_point" {
  let p = snap_point(pt(15.0, 35.0))
  inspect(p.x, content="20")
  inspect(p.y, content="40")
}

///|
test "point_in_plane" {
  // plane_x=240, plane_y=60, width=800, height=600
  inspect(point_in_plane(pt(240.0, 60.0)), content="true")
  inspect(point_in_plane(pt(640.0, 360.0)), content="true")
  inspect(point_in_plane(pt(1040.0, 660.0)), content="true")
  inspect(point_in_plane(pt(100.0, 60.0)), content="false")
  inspect(point_in_plane(pt(240.0, 10.0)), content="false")
}

///|
test "point_in_polygon triangle" {
  let triangle : Array[Point] = [pt(0.0, 0.0), pt(10.0, 0.0), pt(5.0, 10.0)]
  inspect(point_in_polygon(pt(5.0, 3.0), triangle), content="true")
  inspect(point_in_polygon(pt(-5.0, 0.0), triangle), content="false")
  inspect(point_in_polygon(pt(20.0, 20.0), triangle), content="false")
}

///|
test "point_in_polygon needs at least 3 vertices" {
  let empty : Array[Point] = []
  inspect(point_in_polygon(pt(0.0, 0.0), empty), content="false")
  let line : Array[Point] = [pt(0.0, 0.0), pt(1.0, 1.0)]
  inspect(point_in_polygon(pt(0.5, 0.5), line), content="false")
}

///|
test "point_to_segment_dist" {
  let a = pt(0.0, 0.0)
  let b = pt(10.0, 0.0)
  // Point directly above midpoint
  inspect(point_to_segment_dist(pt(5.0, 3.0), a, b), content="3")
  // Point at endpoint
  inspect(point_to_segment_dist(pt(0.0, 0.0), a, b), content="0")
  // Point beyond endpoint (closest to b)
  inspect(point_to_segment_dist(pt(13.0, 4.0), a, b), content="5")
}

///|
test "point_to_segment_dist degenerate segment" {
  let a = pt(5.0, 5.0)
  // When segment is a single point
  inspect(point_to_segment_dist(pt(8.0, 9.0), a, a), content="5")
}

///|
test "make_polygon" {
  let verts : Array[Point] = [pt(0.0, 0.0), pt(1.0, 0.0), pt(0.0, 1.0)]
  let poly = make_polygon(verts)
  inspect(poly.vertices.length(), content="3")
}

///|
test "new_level_score" {
  let s = new_level_score()
  inspect(s.completed, content="false")
  inspect(s.stars, content="0")
  inspect(s.points_used, content="0")
}

///|
test "clone_points is independent" {
  let pts : Array[Point] = [pt(1.0, 2.0), pt(3.0, 4.0)]
  let pts2 = clone_points(pts)
  pts[0].x = 99.0
  inspect(pts2[0].x, content="1")
}

///|
test "push_undo and pop_undo" {
  let game = new_game()
  game.placed_points = [pt(1.0, 2.0)]
  push_undo(game)
  game.placed_points = [pt(5.0, 6.0)]
  inspect(game.placed_points[0].x, content="5")
  let ok = pop_undo(game)
  inspect(ok, content="true")
  inspect(game.placed_points[0].x, content="1")
}

///|
test "pop_undo empty stack" {
  let game = new_game()
  inspect(pop_undo(game), content="false")
}

///|
test "tier_name" {
  inspect(tier_name(Vertices), content="VERTICES")
  inspect(tier_name(Edges), content="EDGES")
  inspect(tier_name(Sculpt), content="SCULPT")
}

///|
test "tier_start_index" {
  inspect(tier_start_index(Vertices), content="0")
  inspect(tier_start_index(Edges), content="8")
  inspect(tier_start_index(Sculpt), content="17")
}

///|
test "tier_level_count" {
  inspect(tier_level_count(Vertices), content="8")
  inspect(tier_level_count(Edges), content="9")
  inspect(tier_level_count(Sculpt), content="8")
}

///|
test "set_message" {
  let game = new_game()
  set_message(game, "Hello", 1.5)
  inspect(game.message, content="Hello")
  inspect(game.message_timer, content="1.5")
}

///|
test "floorf" {
  inspect(floorf(3.7), content="3")
  inspect(floorf(3.0), content="3")
  inspect(floorf(-1.5), content="-2")
  inspect(floorf(0.0), content="0")
}

///|
test "new_game initial state" {
  let game = new_game()
  inspect(game.screen, content="Title")
  inspect(game.play_state, content="Placing")
  inspect(game.placed_points.length(), content="0")
  inspect(game.scores.length(), content="25")
  inspect(game.undo_stack.length(), content="0")
}

///|
test "sinf and cosf basic" {
  inspect(sinf(0.0), content="0")
  inspect(cosf(0.0), content="1")
}
