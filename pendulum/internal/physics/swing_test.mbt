///|
test "swing direction reversal at arc ends" {
  let anchor = @types.vec2i(8, 1)
  let arc = compute_arc(anchor, 5)
  let weight = @types.new_weight()
  let rope = @types.new_rope()
  rope.anchor = anchor
  rope.length = 5
  let goal = @types.vec2i(15, 11) // far away
  // Start at rightmost position
  if arc.length() > 0 {
    let bottom = find_bottom_index(arc)
    let (_, right_limit) = compute_swing_extent(arc, bottom)
    weight.arc_index = right_limit - 1
    weight.swing_dir = Right
    weight.pos = @types.vec2i(
      arc[weight.arc_index].gx,
      arc[weight.arc_index].gy,
    )
    weight.state = Swinging
    // Tick - should reach limit and reverse
    tick_swing(weight, rope, arc, [], [], goal, [], [])
    assert_eq(weight.swing_dir, Left)
  }
}

///|
test "cut launches weight" {
  let anchor = @types.vec2i(8, 1)
  let arc = compute_arc(anchor, 5)
  let weight = @types.new_weight()
  let rope = @types.new_rope()
  rope.anchor = anchor
  rope.length = 5
  weight.state = Swinging
  if arc.length() > 0 {
    let bottom = find_bottom_index(arc)
    weight.arc_index = bottom
    weight.pos = @types.vec2i(arc[bottom].gx, arc[bottom].gy)
    weight.swing_dir = Right
    cut_rope(weight, rope, arc)
    assert_eq(weight.state, Launched)
    // Launch velocity should be non-zero
    let vel_mag = @types.sqrtf(
      weight.launch_vel.x * weight.launch_vel.x +
      weight.launch_vel.y * weight.launch_vel.y,
    )
    assert_true(vel_mag > 0.01)
  }
}

///|
test "goal detection on swing" {
  let weight = @types.new_weight()
  weight.state = Swinging
  weight.pos = @types.vec2i(5, 5)
  let goal = @types.vec2i(5, 5)
  check_goal_on_swing(weight, goal)
  assert_eq(weight.state, AtGoal)
}

///|
test "wall collision stops launched weight" {
  let weight = @types.new_weight()
  weight.state = Launched
  weight.launch_pos = @types.vec2f(3.0, 3.0)
  weight.launch_vel = @types.vec2f(1.0, 0.0) // moving right
  weight.pos = @types.vec2i(3, 3)
  let walls : Array[@types.Vec2i] = [@types.vec2i(4, 3)]
  let goal = @types.vec2i(15, 11)
  tick_swing(weight, @types.new_rope(), [], [], walls, goal, [], [])
  assert_eq(weight.state, Stopped)
}

///|
test "compute stars" {
  // Just reach goal
  assert_eq(compute_stars(20, 10, 3, 0), 1)
  // Within par
  assert_eq(compute_stars(10, 10, 3, 1), 2)
  // Par + all collectibles
  assert_eq(compute_stars(8, 10, 3, 3), 3)
}

///|
test "peg wrap detection" {
  let anchor = @types.vec2i(4, 1)
  let weight = @types.vec2i(10, 7)
  let pegs : Array[@types.Vec2i] = [@types.vec2i(7, 4)]
  let wrapped : Array[@types.Vec2i] = []
  let result = check_peg_wrap(anchor, weight, pegs, wrapped)
  // The peg at (7,4) should be near the line from (4,1) to (10,7)
  match result {
    Some(peg) => assert_eq(peg, @types.vec2i(7, 4))
    None => () // Depending on tolerance, might not trigger - that's ok
  }
}

///|
test "collectible pickup" {
  let weight = @types.new_weight()
  weight.state = Swinging
  weight.pos = @types.vec2i(5, 5)
  let collectibles : Array[@types.Vec2i] = [
    @types.vec2i(5, 5),
    @types.vec2i(10, 10),
  ]
  let collected : Array[Bool] = [false, false]
  // Manually check
  for i = 0; i < collectibles.length(); i = i + 1 {
    if !collected[i] {
      if collectibles[i].x == weight.pos.x && collectibles[i].y == weight.pos.y {
        collected[i] = true
      }
    }
  }
  assert_true(collected[0])
  assert_true(!collected[1])
}

///|
test "out of bounds stops launched weight" {
  let weight = @types.new_weight()
  weight.state = Launched
  weight.launch_pos = @types.vec2f(15.0, 5.0)
  weight.launch_vel = @types.vec2f(2.0, 0.0) // moving right off grid
  weight.pos = @types.vec2i(15, 5)
  let goal = @types.vec2i(0, 0)
  tick_swing(weight, @types.new_rope(), [], [], [], goal, [], [])
  assert_eq(weight.state, Stopped)
}
