///|
test "mirror_direction_left_becomes_right" {
  assert_eq(mirror_direction(Left), Right)
}

///|
test "mirror_direction_right_becomes_left" {
  assert_eq(mirror_direction(Right), Left)
}

///|
test "mirror_direction_up_stays_up" {
  assert_eq(mirror_direction(Up), Up)
}

///|
test "mirror_direction_down_stays_down" {
  assert_eq(mirror_direction(Down), Down)
}

///|
test "direction_delta_up" {
  let d = direction_delta(Up)
  assert_eq(d.x, 0)
  assert_eq(d.y, -1)
}

///|
test "direction_delta_right" {
  let d = direction_delta(Right)
  assert_eq(d.x, 1)
  assert_eq(d.y, 0)
}

///|
test "in_bounds_valid" {
  assert_true(in_bounds({ x: 0, y: 0, }))
  assert_true(in_bounds({ x: 11, y: 7, }))
}

///|
test "in_bounds_invalid" {
  assert_false(in_bounds({ x: -1, y: 0, }))
  assert_false(in_bounds({ x: 12, y: 0, }))
  assert_false(in_bounds({ x: 0, y: 8, }))
}

///|
test "vec2i_add" {
  let a : Vec2i = { x: 3, y: 4, }
  let b : Vec2i = { x: 1, y: -2, }
  let c = vec2i_add(a, b)
  assert_eq(c.x, 4)
  assert_eq(c.y, 2)
}

///|
test "is_walkable_floor" {
  assert_true(is_walkable(Floor, []))
}

///|
test "is_walkable_wall" {
  assert_false(is_walkable(Wall, []))
}

///|
test "is_walkable_door_closed" {
  assert_false(is_walkable(Door(0), [false]))
}

///|
test "is_walkable_door_open" {
  assert_true(is_walkable(Door(0), [true]))
}

///|
test "new_game_creates_scores" {
  let game = new_game()
  assert_eq(game.scores.length(), num_worlds)
  assert_eq(game.scores[0].length(), levels_per_world)
}

///|
test "compute_stars_no_level" {
  let game = new_game()
  assert_eq(compute_stars(game), 0)
}

///|
test "world_name" {
  assert_eq(world_name(0), "Mirror")
  assert_eq(world_name(1), "Switches")
  assert_eq(world_name(2), "Anchors")
  assert_eq(world_name(3), "Mastery")
}
