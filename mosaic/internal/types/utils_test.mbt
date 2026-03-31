///|
test "rotate_orientation basic" {
  inspect(@types.rotate_orientation(N, 1), content="E")
  inspect(@types.rotate_orientation(E, 1), content="S")
  inspect(@types.rotate_orientation(S, 1), content="W")
  inspect(@types.rotate_orientation(W, 1), content="N")
}

///|
test "rotate_orientation ccw" {
  inspect(@types.orientation_ccw(N), content="W")
  inspect(@types.orientation_ccw(E), content="N")
  inspect(@types.orientation_ccw(S), content="E")
  inspect(@types.orientation_ccw(W), content="S")
}

///|
test "orientation_flip" {
  inspect(@types.orientation_flip(N), content="S")
  inspect(@types.orientation_flip(E), content="W")
  inspect(@types.orientation_flip(S), content="N")
  inspect(@types.orientation_flip(W), content="E")
}

///|
test "is_symmetric_shape" {
  inspect(@types.is_symmetric_shape(Square), content="true")
  inspect(@types.is_symmetric_shape(Circle), content="true")
  inspect(@types.is_symmetric_shape(Triangle), content="false")
  inspect(@types.is_symmetric_shape(Arrow), content="false")
  inspect(@types.is_symmetric_shape(Diamond), content="false")
  inspect(@types.is_symmetric_shape(Cross), content="false")
}

///|
test "tile_eq symmetric shapes ignore orientation" {
  let a = @types.new_tile(Red, Square, N)
  let b = @types.new_tile(Red, Square, E)
  inspect(@types.tile_eq(a, b), content="true")
  let c = @types.new_tile(Red, Circle, S)
  let d = @types.new_tile(Red, Circle, W)
  inspect(@types.tile_eq(c, d), content="true")
}

///|
test "tile_eq non-symmetric shapes check orientation" {
  let a = @types.new_tile(Red, Triangle, N)
  let b = @types.new_tile(Red, Triangle, E)
  inspect(@types.tile_eq(a, b), content="false")
  let c = @types.new_tile(Red, Triangle, N)
  let d = @types.new_tile(Red, Triangle, N)
  inspect(@types.tile_eq(c, d), content="true")
}

///|
test "tile_eq different colors" {
  let a = @types.new_tile(Red, Square, N)
  let b = @types.new_tile(Blue, Square, N)
  inspect(@types.tile_eq(a, b), content="false")
}

///|
test "vec2i_eq" {
  let a = @types.vec2i(3, 4)
  let b = @types.vec2i(3, 4)
  let c = @types.vec2i(3, 5)
  inspect(@types.vec2i_eq(a, b), content="true")
  inspect(@types.vec2i_eq(a, c), content="false")
}

///|
test "grid_index" {
  inspect(@types.grid_index(0, 0, 8), content="0")
  inspect(@types.grid_index(7, 0, 8), content="7")
  inspect(@types.grid_index(0, 1, 8), content="8")
  inspect(@types.grid_index(3, 2, 8), content="19")
}

///|
test "mirror_orient_h" {
  inspect(@types.mirror_orient_h(N), content="S")
  inspect(@types.mirror_orient_h(S), content="N")
  inspect(@types.mirror_orient_h(E), content="E")
  inspect(@types.mirror_orient_h(W), content="W")
}

///|
test "mirror_orient_v" {
  inspect(@types.mirror_orient_v(N), content="N")
  inspect(@types.mirror_orient_v(S), content="S")
  inspect(@types.mirror_orient_v(E), content="W")
  inspect(@types.mirror_orient_v(W), content="E")
}

///|
test "mirror_orient_d" {
  inspect(@types.mirror_orient_d(N), content="E")
  inspect(@types.mirror_orient_d(E), content="N")
  inspect(@types.mirror_orient_d(S), content="W")
  inspect(@types.mirror_orient_d(W), content="S")
}

///|
test "color conversions roundtrip" {
  for i in 0..<6 {
    let c = @types.index_to_tile_color(i)
    inspect(@types.tile_color_index(c) == i, content="true")
  }
}

///|
test "shape conversions roundtrip" {
  for i in 0..<6 {
    let s = @types.index_to_tile_shape(i)
    inspect(@types.tile_shape_index(s) == i, content="true")
  }
}

///|
test "orientation conversions roundtrip" {
  for i in 0..<4 {
    let o = @types.index_to_orientation(i)
    inspect(@types.orientation_index(o) == i, content="true")
  }
}

///|
test "symmetry conversions roundtrip" {
  for i in 0..<6 {
    let s = @types.index_to_symmetry(i)
    inspect(@types.symmetry_index(s) == i, content="true")
  }
}

///|
test "clamp_int" {
  inspect(@types.clamp_int(5, 0, 10), content="5")
  inspect(@types.clamp_int(-1, 0, 10), content="0")
  inspect(@types.clamp_int(15, 0, 10), content="10")
}

///|
test "new_grid creates empty grid" {
  let grid = @types.new_grid(8, 8)
  inspect(grid.width, content="8")
  inspect(grid.height, content="8")
  inspect(grid.tiles.length(), content="64")
  inspect(grid.holes.length(), content="0")
}

///|
test "get_tile and set_tile" {
  let grid = @types.new_grid(8, 8)
  inspect(@types.get_tile(grid, 0, 0), content="None")
  let tile = @types.new_tile(Red, Square, N)
  @types.set_tile(grid, 3, 4, Some(tile))
  match @types.get_tile(grid, 3, 4) {
    Some(t) => {
      inspect(t.color, content="Red")
      inspect(t.shape, content="Square")
    }
    None => inspect(false, content="true")
  }
}

///|
test "get_tile out of bounds" {
  let grid = @types.new_grid(8, 8)
  inspect(@types.get_tile(grid, -1, 0), content="None")
  inspect(@types.get_tile(grid, 8, 0), content="None")
  inspect(@types.get_tile(grid, 0, -1), content="None")
  inspect(@types.get_tile(grid, 0, 8), content="None")
}
