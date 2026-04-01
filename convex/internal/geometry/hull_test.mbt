///|
test "cross product sign" {
  let o = @types.pt(0.0, 0.0)
  let a = @types.pt(1.0, 0.0)
  let b = @types.pt(0.0, 1.0)
  // Counter-clockwise turn -> positive
  let cp = @types.cross_product(o, a, b)
  inspect(cp > 0.0, content="true")
  // Clockwise turn -> negative
  let cp2 = @types.cross_product(o, b, a)
  inspect(cp2 < 0.0, content="true")
  // Collinear -> zero
  let c = @types.pt(2.0, 0.0)
  let cp3 = @types.cross_product(o, a, c)
  inspect(@types.absf(cp3) < 0.001, content="true")
}

///|
test "graham scan triangle" {
  let pts : Array[@types.Point] = [
    @types.pt(0.0, 0.0),
    @types.pt(10.0, 0.0),
    @types.pt(5.0, 10.0),
  ]
  let hull = compute_hull(pts)
  inspect(hull.length(), content="3")
}

///|
test "graham scan square" {
  let pts : Array[@types.Point] = [
    @types.pt(0.0, 0.0),
    @types.pt(10.0, 0.0),
    @types.pt(10.0, 10.0),
    @types.pt(0.0, 10.0),
  ]
  let hull = compute_hull(pts)
  inspect(hull.length(), content="4")
}

///|
test "graham scan pentagon" {
  let pts : Array[@types.Point] = []
  for i in 0..<5 {
    let angle = Float::from_int(i) * 2.0 * @types.pi / 5.0
    pts.push(
      @types.pt(
        100.0 + 50.0 * @types.cosf(angle),
        100.0 + 50.0 * @types.sinf(angle),
      ),
    )
  }
  let hull = compute_hull(pts)
  inspect(hull.length(), content="5")
}

///|
test "collinear point handling" {
  // Three points on a line + one off
  let pts : Array[@types.Point] = [
    @types.pt(0.0, 0.0),
    @types.pt(5.0, 0.0),
    @types.pt(10.0, 0.0),
    @types.pt(5.0, 5.0),
  ]
  let hull = compute_hull(pts)
  // Should be a triangle: (0,0), (10,0), (5,5) - collinear middle removed
  inspect(hull.length(), content="3")
}

///|
test "interior point exclusion" {
  let pts : Array[@types.Point] = [
    @types.pt(0.0, 0.0),
    @types.pt(10.0, 0.0),
    @types.pt(10.0, 10.0),
    @types.pt(0.0, 10.0),
    @types.pt(5.0, 5.0), // Interior point
  ]
  let hull = compute_hull(pts)
  inspect(hull.length(), content="4")
}

///|
test "hull match with tolerance" {
  // Create a square target
  let target = @types.make_polygon([
    @types.pt(100.0, 100.0),
    @types.pt(200.0, 100.0),
    @types.pt(200.0, 200.0),
    @types.pt(100.0, 200.0),
  ])
  // Exact hull
  let hull : Array[@types.Point] = [
    @types.pt(100.0, 100.0),
    @types.pt(200.0, 100.0),
    @types.pt(200.0, 200.0),
    @types.pt(100.0, 200.0),
  ]
  let pct = match_hull_to_target(hull, target)
  inspect(pct >= 99.9, content="true")
  inspect(hull_matches_target(hull, target), content="true")
}

///|
test "hull partial match" {
  let target = @types.make_polygon([
    @types.pt(100.0, 100.0),
    @types.pt(200.0, 100.0),
    @types.pt(200.0, 200.0),
    @types.pt(100.0, 200.0),
  ])
  // Hull is a triangle - only some edges match
  let hull : Array[@types.Point] = [
    @types.pt(100.0, 100.0),
    @types.pt(200.0, 100.0),
    @types.pt(200.0, 200.0),
  ]
  let pct = match_hull_to_target(hull, target)
  inspect(pct < 99.9, content="true")
  inspect(hull_matches_target(hull, target), content="false")
}

///|
test "point in polygon" {
  let poly : Array[@types.Point] = [
    @types.pt(0.0, 0.0),
    @types.pt(10.0, 0.0),
    @types.pt(10.0, 10.0),
    @types.pt(0.0, 10.0),
  ]
  inspect(@types.point_in_polygon(@types.pt(5.0, 5.0), poly), content="true")
  inspect(@types.point_in_polygon(@types.pt(15.0, 5.0), poly), content="false")
  inspect(@types.point_in_polygon(@types.pt(-1.0, -1.0), poly), content="false")
}

///|
test "is point on hull" {
  let hull : Array[@types.Point] = [
    @types.pt(0.0, 0.0),
    @types.pt(100.0, 0.0),
    @types.pt(100.0, 100.0),
    @types.pt(0.0, 100.0),
  ]
  // Vertex is on hull
  inspect(is_point_on_hull(@types.pt(0.0, 0.0), hull), content="true")
  // Midpoint of edge is on hull
  inspect(is_point_on_hull(@types.pt(50.0, 0.0), hull), content="true")
  // Interior is not on hull
  inspect(is_point_on_hull(@types.pt(50.0, 50.0), hull), content="false")
}

///|
test "empty and small inputs" {
  let empty : Array[@types.Point] = []
  let hull0 = compute_hull(empty)
  inspect(hull0.length(), content="0")
  let one : Array[@types.Point] = [@types.pt(5.0, 5.0)]
  let hull1 = compute_hull(one)
  inspect(hull1.length(), content="1")
  let two : Array[@types.Point] = [@types.pt(0.0, 0.0), @types.pt(10.0, 0.0)]
  let hull2 = compute_hull(two)
  inspect(hull2.length(), content="2")
}
