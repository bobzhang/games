///|
test "arc computation produces points" {
  let anchor = vec2i(8, 1)
  let arc = compute_arc_points(anchor, 5)
  // Should have some arc points below the anchor
  assert_true(arc.length() > 0)
  // All points should be roughly distance 5 from anchor
  for i = 0; i < arc.length(); i = i + 1 {
    let dx = arc[i].gx - anchor.x
    let dy = arc[i].gy - anchor.y
    let dist_sq = dx * dx + dy * dy
    // Should be within tolerance of 5^2 = 25
    assert_true(absi(dist_sq - 25) <= 5)
  }
}

///|
test "arc points are below anchor" {
  let anchor = vec2i(8, 1)
  let arc = compute_arc_points(anchor, 4)
  // All arc points should be at or below anchor y
  for i = 0; i < arc.length(); i = i + 1 {
    assert_true(arc[i].gy >= anchor.y)
  }
}

///|
test "arc points sorted by angle" {
  let anchor = vec2i(8, 2)
  let arc = compute_arc_points(anchor, 5)
  for i = 1; i < arc.length(); i = i + 1 {
    assert_true(arc[i].angle >= arc[i - 1].angle)
  }
}

///|
test "launch velocity perpendicular to rope" {
  let anchor = vec2i(8, 0)
  let weight = vec2i(8, 5) // directly below
  let vel = compute_launch_velocity(anchor, weight, Right)
  // Tangent to straight-down rope should be horizontal
  // Right swing: tangent should be (-dy/len, dx/len) = (-1, 0) approximately
  assert_true(absf(vel.y) < 0.1)
}

///|
test "grid to screen conversion" {
  let sx = grid_to_screen_x(0)
  let expected = Float::from_int(grid_offset_x + cell_size / 2)
  assert_true(absf(sx - expected) < 0.01)
}

///|
test "history save and restore" {
  let w = new_weight()
  w.pos = vec2i(5, 3)
  w.state = Swinging
  w.swing_dir = Left
  w.arc_index = 7
  let r = new_rope()
  r.anchor = vec2i(5, 0)
  r.length = 3
  let collected : Array[Bool] = [true, false, true]
  let entry = new_history_entry(w, r, 10, collected)
  // Modify weight
  w.pos = vec2i(9, 9)
  w.state = Launched
  w.arc_index = 0
  let tick = restore_from_history(entry, w, r, collected)
  assert_eq(tick, 10)
  assert_eq(w.pos.x, 5)
  assert_eq(w.pos.y, 3)
  assert_eq(w.state, Swinging)
  assert_eq(w.swing_dir, Left)
  assert_eq(w.arc_index, 7)
}

///|
test "empty grid has correct dimensions" {
  let grid = new_empty_grid()
  assert_eq(grid.length(), grid_rows)
  assert_eq(grid[0].length(), grid_cols)
  for row = 0; row < grid_rows; row = row + 1 {
    for col = 0; col < grid_cols; col = col + 1 {
      assert_eq(grid[row][col], Empty)
    }
  }
}

///|
test "find_arc_index_for_pos exact match" {
  let arc : Array[ArcPoint] = [
    { gx: 5, gy: 3, angle: 0.5, },
    { gx: 6, gy: 4, angle: 1.0, },
    { gx: 7, gy: 5, angle: 1.5, },
  ]
  let idx = find_arc_index_for_pos(arc, vec2i(6, 4))
  assert_eq(idx, 1)
}

///|
test "tier properties" {
  assert_eq(tier_level_count(Swing), tier1_count)
  assert_eq(tier_level_count(Wrap), tier2_count)
  assert_eq(tier_level_count(Launch), tier3_count)
  assert_eq(tier_level_offset(Swing), 0)
  assert_eq(tier_level_offset(Wrap), tier1_count)
  assert_eq(tier_level_offset(Launch), tier1_count + tier2_count)
}
