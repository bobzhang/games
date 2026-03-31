///|
test "mirror_h_pos" {
  let pos = @types.vec2i(3, 1)
  let result = @symmetry.mirror_h_pos(pos, 8)
  inspect(result.x, content="3")
  inspect(result.y, content="6")
}

///|
test "mirror_h_pos center" {
  let pos = @types.vec2i(4, 3)
  let result = @symmetry.mirror_h_pos(pos, 8)
  inspect(result.x, content="4")
  inspect(result.y, content="4")
}

///|
test "mirror_v_pos" {
  let pos = @types.vec2i(2, 3)
  let result = @symmetry.mirror_v_pos(pos, 8)
  inspect(result.x, content="5")
  inspect(result.y, content="3")
}

///|
test "mirror_v_pos symmetric" {
  let pos = @types.vec2i(1, 5)
  let mirrored = @symmetry.mirror_v_pos(pos, 8)
  let back = @symmetry.mirror_v_pos(mirrored, 8)
  inspect(back.x == pos.x, content="true")
  inspect(back.y == pos.y, content="true")
}

///|
test "mirror_d_pos" {
  let pos = @types.vec2i(2, 5)
  let result = @symmetry.mirror_d_pos(pos)
  inspect(result.x, content="5")
  inspect(result.y, content="2")
}

///|
test "mirror_d_pos self-inverse" {
  let pos = @types.vec2i(3, 7)
  let mirrored = @symmetry.mirror_d_pos(pos)
  let back = @symmetry.mirror_d_pos(mirrored)
  inspect(back.x == pos.x, content="true")
  inspect(back.y == pos.y, content="true")
}

///|
test "rotate2_pos" {
  let pos = @types.vec2i(1, 2)
  let result = @symmetry.rotate2_pos(pos, 8, 8)
  inspect(result.x, content="6")
  inspect(result.y, content="5")
}

///|
test "rotate2_pos self-inverse" {
  let pos = @types.vec2i(2, 3)
  let r1 = @symmetry.rotate2_pos(pos, 8, 8)
  let r2 = @symmetry.rotate2_pos(r1, 8, 8)
  inspect(r2.x == pos.x, content="true")
  inspect(r2.y == pos.y, content="true")
}

///|
test "rotate4_pos_90 then 90 then 90 then 90 = identity" {
  let pos = @types.vec2i(2, 1)
  let r90 = @symmetry.rotate4_pos_90(pos, 8, 8)
  let r180 = @symmetry.rotate4_pos_90(r90, 8, 8)
  let r270 = @symmetry.rotate4_pos_90(r180, 8, 8)
  let r360 = @symmetry.rotate4_pos_90(r270, 8, 8)
  inspect(r360.x == pos.x, content="true")
  inspect(r360.y == pos.y, content="true")
}

///|
test "rotate4 positions" {
  let pos = @types.vec2i(2, 1)
  let r90 = @symmetry.rotate4_pos_90(pos, 8, 8)
  inspect(r90.x, content="6")
  inspect(r90.y, content="2")
  let r180 = @symmetry.rotate4_pos_180(pos, 8, 8)
  inspect(r180.x, content="5")
  inspect(r180.y, content="6")
  let r270 = @symmetry.rotate4_pos_270(pos, 8, 8)
  inspect(r270.x, content="1")
  inspect(r270.y, content="5")
}

///|
test "glide_pos" {
  let pos = @types.vec2i(1, 2)
  let result = @symmetry.glide_pos(pos, 8)
  inspect(result.x, content="5")
  inspect(result.y, content="5")
}

///|
test "transform_tile mirror_h" {
  let tile = @types.new_tile(Red, Arrow, N)
  let result = @symmetry.transform_tile(tile, MirrorH)
  inspect(result.color, content="Red")
  inspect(result.shape, content="Arrow")
  inspect(result.orientation, content="S")
}

///|
test "transform_tile mirror_v" {
  let tile = @types.new_tile(Blue, Triangle, E)
  let result = @symmetry.transform_tile(tile, MirrorV)
  inspect(result.color, content="Blue")
  inspect(result.shape, content="Triangle")
  inspect(result.orientation, content="W")
}

///|
test "transform_tile mirror_d" {
  let tile = @types.new_tile(Green, Arrow, N)
  let result = @symmetry.transform_tile(tile, MirrorD)
  inspect(result.orientation, content="E")
}

///|
test "transform_tile rotate2" {
  let tile = @types.new_tile(Gold, Triangle, N)
  let result = @symmetry.transform_tile(tile, Rotate2)
  inspect(result.orientation, content="S")
}

///|
test "transform_tile rotate4" {
  let tile = @types.new_tile(Purple, Arrow, N)
  let result = @symmetry.transform_tile(tile, Rotate4)
  inspect(result.orientation, content="E")
}

///|
test "transform_tile symmetric shape ignores orientation" {
  let tile = @types.new_tile(Red, Square, N)
  let result = @symmetry.transform_tile(tile, MirrorH)
  inspect(result.orientation, content="N")
  let tile2 = @types.new_tile(Red, Circle, E)
  let result2 = @symmetry.transform_tile(tile2, Rotate4)
  inspect(result2.orientation, content="E")
}

///|
test "validate_placement with mirror_v" {
  let grid = @types.new_grid(8, 8)
  // Place a tile at (1, 3)
  @types.set_tile(grid, 1, 3, Some(@types.new_tile(Red, Triangle, E)))
  // The mirror of (6, 3) should be (1, 3) reflected
  // For MirrorV: the expected tile at (6, 3) should have orientation W
  let test_tile = @types.new_tile(Red, Triangle, W)
  let pos = @types.vec2i(6, 3)
  let valid = @symmetry.validate_placement(grid, pos, test_tile, MirrorV)
  inspect(valid, content="true")
  // Wrong orientation should fail
  let wrong = @types.new_tile(Red, Triangle, E)
  let invalid = @symmetry.validate_placement(grid, pos, wrong, MirrorV)
  inspect(invalid, content="false")
}

///|
test "validate_placement with mirror_h" {
  let grid = @types.new_grid(8, 8)
  @types.set_tile(grid, 3, 1, Some(@types.new_tile(Blue, Arrow, N)))
  // Mirror H of (3, 1) in 8x8 grid = (3, 6)
  // Expected: orientation S (mirror_orient_h(N) = S)
  let test_tile = @types.new_tile(Blue, Arrow, S)
  let valid = @symmetry.validate_placement(
    grid, @types.vec2i(3, 6), test_tile, MirrorH,
  )
  inspect(valid, content="true")
}

///|
test "validate_placement with rotate2" {
  let grid = @types.new_grid(8, 8)
  @types.set_tile(grid, 1, 1, Some(@types.new_tile(Gold, Arrow, N)))
  // Rotate2 of (1,1) in 8x8 = (6,6), expected orient: S (180 flip of N)
  let test_tile = @types.new_tile(Gold, Arrow, S)
  let valid = @symmetry.validate_placement(
    grid, @types.vec2i(6, 6), test_tile, Rotate2,
  )
  inspect(valid, content="true")
}

///|
test "check_all_holes_filled" {
  let grid : @types.MosaicGrid = {
    width: 4,
    height: 4,
    tiles: Array::make(16, None),
    holes: [@types.vec2i(0, 0), @types.vec2i(1, 1)],
  }
  inspect(@symmetry.check_all_holes_filled(grid), content="false")
  @types.set_tile(grid, 0, 0, Some(@types.new_tile(Red, Square, N)))
  inspect(@symmetry.check_all_holes_filled(grid), content="false")
  @types.set_tile(grid, 1, 1, Some(@types.new_tile(Blue, Square, N)))
  inspect(@symmetry.check_all_holes_filled(grid), content="true")
}
