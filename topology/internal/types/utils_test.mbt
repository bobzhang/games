///|
test "vec2i constructor" {
  let v = @types.vec2i(3, 7)
  inspect(v.x, content="3")
  inspect(v.y, content="7")
}

///|
test "new_shape creates shape with given cells" {
  let s = @types.new_shape([@types.vec2i(1, 2), @types.vec2i(3, 4)])
  inspect(s.cells.length(), content="2")
  inspect(s.cells[0].x, content="1")
  inspect(s.cells[1].y, content="4")
}

///|
test "new_shape empty" {
  let s = @types.new_shape([])
  inspect(s.cells.length(), content="0")
}

///|
test "shape_clone produces independent copy" {
  let s = @types.new_shape([@types.vec2i(1, 1), @types.vec2i(2, 2)])
  let c = @types.shape_clone(s)
  inspect(c.cells.length(), content="2")
  // Mutating clone should not affect original
  c.cells[0] = @types.vec2i(9, 9)
  inspect(s.cells[0].x, content="1")
  inspect(c.cells[0].x, content="9")
}

///|
test "shape_contains finds present cell" {
  let s = @types.new_shape([@types.vec2i(3, 4), @types.vec2i(5, 6)])
  inspect(@types.shape_contains(s, @types.vec2i(3, 4)), content="true")
  inspect(@types.shape_contains(s, @types.vec2i(5, 6)), content="true")
}

///|
test "shape_contains returns false for absent cell" {
  let s = @types.new_shape([@types.vec2i(3, 4)])
  inspect(@types.shape_contains(s, @types.vec2i(0, 0)), content="false")
  inspect(@types.shape_contains(s, @types.vec2i(3, 5)), content="false")
}

///|
test "shape_center_x and shape_center_y" {
  let s = @types.new_shape([@types.vec2i(0, 0), @types.vec2i(2, 4)])
  // center_x = (0+2)/2 = 1.0, center_y = (0+4)/2 = 2.0
  inspect(@types.shape_center_x(s), content="1")
  inspect(@types.shape_center_y(s), content="2")
}

///|
test "shape_center_x empty shape returns zero" {
  let s = @types.new_shape([])
  inspect(@types.shape_center_x(s), content="0")
  inspect(@types.shape_center_y(s), content="0")
}

///|
test "shape_min_x and shape_max_x" {
  let s = @types.new_shape([@types.vec2i(2, 5), @types.vec2i(7, 1), @types.vec2i(4, 3)])
  inspect(@types.shape_min_x(s), content="2")
  inspect(@types.shape_max_x(s), content="7")
}

///|
test "shape_min_y and shape_max_y" {
  let s = @types.new_shape([@types.vec2i(2, 5), @types.vec2i(7, 1), @types.vec2i(4, 3)])
  inspect(@types.shape_min_y(s), content="1")
  inspect(@types.shape_max_y(s), content="5")
}

///|
test "shape_normalize shifts to origin and sorts" {
  let s = @types.new_shape([@types.vec2i(5, 5), @types.vec2i(3, 3), @types.vec2i(4, 3)])
  let n = @types.shape_normalize(s)
  // min_x=3, min_y=3, so shifted by (-3,-3)
  // cells become: (2,2), (0,0), (1,0) -> sorted: (0,0), (1,0), (2,2)
  inspect(n.cells[0].x, content="0")
  inspect(n.cells[0].y, content="0")
  inspect(n.cells[1].x, content="1")
  inspect(n.cells[1].y, content="0")
  inspect(n.cells[2].x, content="2")
  inspect(n.cells[2].y, content="2")
}

///|
test "shape_normalize empty" {
  let s = @types.new_shape([])
  let n = @types.shape_normalize(s)
  inspect(n.cells.length(), content="0")
}

///|
test "shape_equals ignores position" {
  let a = @types.new_shape([@types.vec2i(0, 0), @types.vec2i(1, 0)])
  let b = @types.new_shape([@types.vec2i(5, 5), @types.vec2i(6, 5)])
  inspect(@types.shape_equals(a, b), content="true")
}

///|
test "shape_equals different shapes" {
  let a = @types.new_shape([@types.vec2i(0, 0), @types.vec2i(1, 0)])
  let b = @types.new_shape([@types.vec2i(0, 0), @types.vec2i(0, 1)])
  inspect(@types.shape_equals(a, b), content="false")
}

///|
test "shape_exact_match order independent" {
  let a = @types.new_shape([@types.vec2i(1, 2), @types.vec2i(3, 4)])
  let b = @types.new_shape([@types.vec2i(3, 4), @types.vec2i(1, 2)])
  inspect(@types.shape_exact_match(a, b), content="true")
}

///|
test "shape_exact_match fails for different positions" {
  let a = @types.new_shape([@types.vec2i(1, 2)])
  let b = @types.new_shape([@types.vec2i(3, 4)])
  inspect(@types.shape_exact_match(a, b), content="false")
}

///|
test "shape_exact_match fails for different sizes" {
  let a = @types.new_shape([@types.vec2i(1, 2)])
  let b = @types.new_shape([@types.vec2i(1, 2), @types.vec2i(3, 4)])
  inspect(@types.shape_exact_match(a, b), content="false")
}

///|
test "shape_match_count" {
  let current = @types.new_shape([@types.vec2i(1, 1), @types.vec2i(2, 2), @types.vec2i(3, 3)])
  let target = @types.new_shape([@types.vec2i(2, 2), @types.vec2i(3, 3), @types.vec2i(4, 4)])
  inspect(@types.shape_match_count(current, target), content="2")
}

///|
test "shape_edge_cells" {
  // 2x2 block: all cells are edge cells (each has at least one empty neighbor)
  let s = @types.new_shape([@types.vec2i(3, 3), @types.vec2i(4, 3), @types.vec2i(3, 4), @types.vec2i(4, 4)])
  let edges = @types.shape_edge_cells(s)
  inspect(edges.length(), content="4")
}

///|
test "shape_edge_cells single cell returns empty" {
  // Single cell: length=1, function returns empty for single-cell shapes
  let s = @types.new_shape([@types.vec2i(3, 3)])
  let edges = @types.shape_edge_cells(s)
  inspect(edges.length(), content="0")
}

///|
test "shape_adjacent_empty" {
  let s = @types.new_shape([@types.vec2i(3, 3)])
  let adj = @types.shape_adjacent_empty(s)
  // Should have 4 neighbors: (2,3), (4,3), (3,2), (3,4)
  inspect(adj.length(), content="4")
}

///|
test "op_cost values" {
  inspect(@types.op_cost(Shift), content="1")
  inspect(@types.op_cost(Rotate), content="2")
  inspect(@types.op_cost(Flip), content="2")
  inspect(@types.op_cost(Grow), content="3")
  inspect(@types.op_cost(Shrink), content="3")
}

///|
test "op_name values" {
  inspect(@types.op_name(Shift), content="Shift")
  inspect(@types.op_name(Rotate), content="Rotate")
  inspect(@types.op_name(Flip), content="Flip")
  inspect(@types.op_name(Grow), content="Grow")
  inspect(@types.op_name(Shrink), content="Shrink")
}

///|
test "tier_name values" {
  inspect(@types.tier_name(Morph), content="Morph")
  inspect(@types.tier_name(Sculpt), content="Sculpt")
  inspect(@types.tier_name(Transform), content="Transform")
}

///|
test "star_count values" {
  inspect(@types.star_count(Zero), content="0")
  inspect(@types.star_count(One), content="1")
  inspect(@types.star_count(Two), content="2")
  inspect(@types.star_count(Three), content="3")
}

///|
test "tier_start_index values" {
  inspect(@types.tier_start_index(Morph), content="0")
  inspect(@types.tier_start_index(Sculpt), content="8")
  inspect(@types.tier_start_index(Transform), content="17")
}

///|
test "tier_level_count values" {
  inspect(@types.tier_level_count(Morph), content="8")
  inspect(@types.tier_level_count(Sculpt), content="9")
  inspect(@types.tier_level_count(Transform), content="8")
}

///|
test "new_level_score defaults" {
  let s = @types.new_level_score()
  inspect(s.completed, content="false")
  inspect(s.best_cost, content="9999")
  inspect(s.stars, content="Zero")
}

///|
test "mini and maxi" {
  inspect(@types.mini(3, 7), content="3")
  inspect(@types.mini(7, 3), content="3")
  inspect(@types.maxi(3, 7), content="7")
  inspect(@types.maxi(7, 3), content="7")
}

///|
test "absi" {
  inspect(@types.absi(-5), content="5")
  inspect(@types.absi(5), content="5")
  inspect(@types.absi(0), content="0")
}

///|
test "new_game initializes properly" {
  let g = @types.new_game()
  inspect(g.screen, content="Title")
  inspect(g.total_cost, content="0")
  inspect(g.current_tier, content="Morph")
  inspect(g.level_scores.length(), content="25")
  inspect(g.current_level_idx, content="0")
  inspect(g.frame_count, content="0")
}
