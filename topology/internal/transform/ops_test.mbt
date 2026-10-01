///|
test "shift north" {
  let shape = @types.new_shape([
    @types.vec2i(3, 3),
    @types.vec2i(4, 3),
    @types.vec2i(3, 4),
  ])
  let result = @transform.shift(shape, N)
  assert_true(result.cells.length() == 3)
  assert_true(@types.shape_contains(result, @types.vec2i(3, 2)))
  assert_true(@types.shape_contains(result, @types.vec2i(4, 2)))
  assert_true(@types.shape_contains(result, @types.vec2i(3, 3)))
}

///|
test "shift east" {
  let shape = @types.new_shape([@types.vec2i(3, 3), @types.vec2i(4, 3)])
  let result = @transform.shift(shape, E)
  assert_true(@types.shape_contains(result, @types.vec2i(4, 3)))
  assert_true(@types.shape_contains(result, @types.vec2i(5, 3)))
}

///|
test "shift south" {
  let shape = @types.new_shape([@types.vec2i(3, 3), @types.vec2i(4, 3)])
  let result = @transform.shift(shape, S)
  assert_true(@types.shape_contains(result, @types.vec2i(3, 4)))
  assert_true(@types.shape_contains(result, @types.vec2i(4, 4)))
}

///|
test "shift west" {
  let shape = @types.new_shape([@types.vec2i(3, 3), @types.vec2i(4, 3)])
  let result = @transform.shift(shape, W)
  assert_true(@types.shape_contains(result, @types.vec2i(2, 3)))
  assert_true(@types.shape_contains(result, @types.vec2i(3, 3)))
}

///|
test "shift blocked at boundary returns original" {
  let shape = @types.new_shape([@types.vec2i(0, 0), @types.vec2i(1, 0)])
  let result = @transform.shift(shape, N)
  // Should return original because cells at y=0 can't go north
  assert_true(@types.shape_exact_match(result, shape))
}

///|
test "rotate 4 times equals original" {
  let shape = @types.new_shape([
    @types.vec2i(3, 3),
    @types.vec2i(4, 3),
    @types.vec2i(4, 4),
  ])
  let r1 = @transform.rotate_cw(shape)
  let r2 = @transform.rotate_cw(r1)
  let r3 = @transform.rotate_cw(r2)
  let r4 = @transform.rotate_cw(r3)
  assert_true(@types.shape_equals(shape, r4))
}

///|
test "rotate changes shape" {
  let shape = @types.new_shape([
    @types.vec2i(3, 3),
    @types.vec2i(4, 3),
    @types.vec2i(5, 3),
  ])
  let rotated = @transform.rotate_cw(shape)
  // Horizontal bar should become vertical
  assert_true(rotated.cells.length() == 3)
  // After rotation, all cells should have same x
  let x0 = rotated.cells[0].x
  let mut same_x = true
  for i in 1..<rotated.cells.length() {
    if rotated.cells[i].x != x0 {
      same_x = false
    }
  }
  assert_true(same_x)
}

///|
test "flip horizontal double flip equals original" {
  let shape = @types.new_shape([
    @types.vec2i(2, 3),
    @types.vec2i(3, 3),
    @types.vec2i(3, 4),
  ])
  let flipped = @transform.flip_h(shape)
  let double_flipped = @transform.flip_h(flipped)
  assert_true(@types.shape_equals(shape, double_flipped))
}

///|
test "flip vertical double flip equals original" {
  let shape = @types.new_shape([
    @types.vec2i(3, 2),
    @types.vec2i(3, 3),
    @types.vec2i(4, 3),
  ])
  let flipped = @transform.flip_v(shape)
  let double_flipped = @transform.flip_v(flipped)
  assert_true(@types.shape_equals(shape, double_flipped))
}

///|
test "grow adds cell" {
  let shape = @types.new_shape([@types.vec2i(3, 3), @types.vec2i(4, 3)])
  let grown = @transform.grow(shape, @types.vec2i(3, 4))
  assert_true(grown.cells.length() == 3)
  assert_true(@types.shape_contains(grown, @types.vec2i(3, 4)))
}

///|
test "grow non-adjacent returns original" {
  let shape = @types.new_shape([@types.vec2i(3, 3), @types.vec2i(4, 3)])
  let grown = @transform.grow(shape, @types.vec2i(6, 6))
  assert_true(grown.cells.length() == 2)
}

///|
test "shrink removes cell" {
  let shape = @types.new_shape([
    @types.vec2i(3, 3),
    @types.vec2i(4, 3),
    @types.vec2i(5, 3),
  ])
  let shrunk = @transform.shrink(shape, @types.vec2i(5, 3))
  assert_true(shrunk.cells.length() == 2)
  assert_true(!@types.shape_contains(shrunk, @types.vec2i(5, 3)))
}

///|
test "shrink rejects disconnecting removal" {
  // Shape: (3,3) - (4,3) - (5,3)
  // Removing (4,3) would disconnect
  let shape = @types.new_shape([
    @types.vec2i(3, 3),
    @types.vec2i(4, 3),
    @types.vec2i(5, 3),
  ])
  let shrunk = @transform.shrink(shape, @types.vec2i(4, 3))
  // Should return original since removal disconnects
  assert_true(shrunk.cells.length() == 3)
}

///|
test "shape matching exact" {
  let a = @types.new_shape([@types.vec2i(3, 3), @types.vec2i(4, 3)])
  let b = @types.new_shape([@types.vec2i(4, 3), @types.vec2i(3, 3)])
  assert_true(@types.shape_exact_match(a, b))
}

///|
test "shape matching different" {
  let a = @types.new_shape([@types.vec2i(3, 3), @types.vec2i(4, 3)])
  let b = @types.new_shape([@types.vec2i(5, 3), @types.vec2i(6, 3)])
  assert_true(!@types.shape_exact_match(a, b))
}

///|
test "check_match works" {
  let a = @types.new_shape([@types.vec2i(3, 3), @types.vec2i(4, 3)])
  let b = @types.new_shape([@types.vec2i(3, 3), @types.vec2i(4, 3)])
  assert_true(@transform.check_match(a, b))
}

///|
test "calculate_stars" {
  let three = @transform.calculate_stars(5, 8, 5)
  assert_true(three == Three)
  let two = @transform.calculate_stars(7, 8, 5)
  assert_true(two == Two)
  let one = @transform.calculate_stars(10, 8, 5)
  assert_true(one == One)
}
