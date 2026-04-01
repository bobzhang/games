///|
test "vec2i constructor" {
  let v = vec2i(3, 7)
  inspect(v.x, content="3")
  inspect(v.y, content="7")
}

///|
test "new_shape creates shape with given cells" {
  let s = new_shape([vec2i(1, 2), vec2i(3, 4)])
  inspect(s.cells.length(), content="2")
  inspect(s.cells[0].x, content="1")
  inspect(s.cells[1].y, content="4")
}

///|
test "new_shape empty" {
  let s = new_shape([])
  inspect(s.cells.length(), content="0")
}

///|
test "shape_clone produces independent copy" {
  let s = new_shape([vec2i(1, 1), vec2i(2, 2)])
  let c = shape_clone(s)
  inspect(c.cells.length(), content="2")
  // Mutating clone should not affect original
  c.cells[0] = vec2i(9, 9)
  inspect(s.cells[0].x, content="1")
  inspect(c.cells[0].x, content="9")
}

///|
test "shape_contains finds present cell" {
  let s = new_shape([vec2i(3, 4), vec2i(5, 6)])
  inspect(shape_contains(s, vec2i(3, 4)), content="true")
  inspect(shape_contains(s, vec2i(5, 6)), content="true")
}

///|
test "shape_contains returns false for absent cell" {
  let s = new_shape([vec2i(3, 4)])
  inspect(shape_contains(s, vec2i(0, 0)), content="false")
  inspect(shape_contains(s, vec2i(3, 5)), content="false")
}

///|
test "shape_center_x and shape_center_y" {
  let s = new_shape([vec2i(0, 0), vec2i(2, 4)])
  // center_x = (0+2)/2 = 1.0, center_y = (0+4)/2 = 2.0
  inspect(shape_center_x(s), content="1")
  inspect(shape_center_y(s), content="2")
}

///|
test "shape_center_x empty shape returns zero" {
  let s = new_shape([])
  inspect(shape_center_x(s), content="0")
  inspect(shape_center_y(s), content="0")
}

///|
test "shape_min_x and shape_max_x" {
  let s = new_shape([vec2i(2, 5), vec2i(7, 1), vec2i(4, 3)])
  inspect(shape_min_x(s), content="2")
  inspect(shape_max_x(s), content="7")
}

///|
test "shape_min_y and shape_max_y" {
  let s = new_shape([vec2i(2, 5), vec2i(7, 1), vec2i(4, 3)])
  inspect(shape_min_y(s), content="1")
  inspect(shape_max_y(s), content="5")
}

///|
test "shape_normalize shifts to origin and sorts" {
  let s = new_shape([vec2i(5, 5), vec2i(3, 3), vec2i(4, 3)])
  let n = shape_normalize(s)
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
  let s = new_shape([])
  let n = shape_normalize(s)
  inspect(n.cells.length(), content="0")
}

///|
test "shape_equals ignores position" {
  let a = new_shape([vec2i(0, 0), vec2i(1, 0)])
  let b = new_shape([vec2i(5, 5), vec2i(6, 5)])
  inspect(shape_equals(a, b), content="true")
}

///|
test "shape_equals different shapes" {
  let a = new_shape([vec2i(0, 0), vec2i(1, 0)])
  let b = new_shape([vec2i(0, 0), vec2i(0, 1)])
  inspect(shape_equals(a, b), content="false")
}

///|
test "shape_exact_match order independent" {
  let a = new_shape([vec2i(1, 2), vec2i(3, 4)])
  let b = new_shape([vec2i(3, 4), vec2i(1, 2)])
  inspect(shape_exact_match(a, b), content="true")
}

///|
test "shape_exact_match fails for different positions" {
  let a = new_shape([vec2i(1, 2)])
  let b = new_shape([vec2i(3, 4)])
  inspect(shape_exact_match(a, b), content="false")
}

///|
test "shape_exact_match fails for different sizes" {
  let a = new_shape([vec2i(1, 2)])
  let b = new_shape([vec2i(1, 2), vec2i(3, 4)])
  inspect(shape_exact_match(a, b), content="false")
}

///|
test "shape_match_count" {
  let current = new_shape([vec2i(1, 1), vec2i(2, 2), vec2i(3, 3)])
  let target = new_shape([vec2i(2, 2), vec2i(3, 3), vec2i(4, 4)])
  inspect(shape_match_count(current, target), content="2")
}

///|
test "shape_edge_cells" {
  // 2x2 block: all cells are edge cells (each has at least one empty neighbor)
  let s = new_shape([vec2i(3, 3), vec2i(4, 3), vec2i(3, 4), vec2i(4, 4)])
  let edges = shape_edge_cells(s)
  inspect(edges.length(), content="4")
}

///|
test "shape_edge_cells single cell returns empty" {
  // Single cell: length=1, function returns empty for single-cell shapes
  let s = new_shape([vec2i(3, 3)])
  let edges = shape_edge_cells(s)
  inspect(edges.length(), content="0")
}

///|
test "shape_adjacent_empty" {
  let s = new_shape([vec2i(3, 3)])
  let adj = shape_adjacent_empty(s)
  // Should have 4 neighbors: (2,3), (4,3), (3,2), (3,4)
  inspect(adj.length(), content="4")
}

///|
test "op_cost values" {
  inspect(op_cost(Shift), content="1")
  inspect(op_cost(Rotate), content="2")
  inspect(op_cost(Flip), content="2")
  inspect(op_cost(Grow), content="3")
  inspect(op_cost(Shrink), content="3")
}

///|
test "op_name values" {
  inspect(op_name(Shift), content="Shift")
  inspect(op_name(Rotate), content="Rotate")
  inspect(op_name(Flip), content="Flip")
  inspect(op_name(Grow), content="Grow")
  inspect(op_name(Shrink), content="Shrink")
}

///|
test "tier_name values" {
  inspect(tier_name(Morph), content="Morph")
  inspect(tier_name(Sculpt), content="Sculpt")
  inspect(tier_name(Transform), content="Transform")
}

///|
test "star_count values" {
  inspect(star_count(Zero), content="0")
  inspect(star_count(One), content="1")
  inspect(star_count(Two), content="2")
  inspect(star_count(Three), content="3")
}

///|
test "tier_start_index values" {
  inspect(tier_start_index(Morph), content="0")
  inspect(tier_start_index(Sculpt), content="8")
  inspect(tier_start_index(Transform), content="17")
}

///|
test "tier_level_count values" {
  inspect(tier_level_count(Morph), content="8")
  inspect(tier_level_count(Sculpt), content="9")
  inspect(tier_level_count(Transform), content="8")
}

///|
test "new_level_score defaults" {
  let s = new_level_score()
  inspect(s.completed, content="false")
  inspect(s.best_cost, content="9999")
  inspect(s.stars, content="Zero")
}

///|
test "mini and maxi" {
  inspect(mini(3, 7), content="3")
  inspect(mini(7, 3), content="3")
  inspect(maxi(3, 7), content="7")
  inspect(maxi(7, 3), content="7")
}

///|
test "absi" {
  inspect(absi(-5), content="5")
  inspect(absi(5), content="5")
  inspect(absi(0), content="0")
}

///|
test "new_game initializes properly" {
  let g = new_game()
  inspect(g.screen, content="Title")
  inspect(g.total_cost, content="0")
  inspect(g.current_tier, content="Morph")
  inspect(g.level_scores.length(), content="25")
  inspect(g.current_level_idx, content="0")
  inspect(g.frame_count, content="0")
}
