///|
test "distance calculation" {
  let a = @types.vec2i(0, 0)
  let b = @types.vec2i(3, 4)
  let d = @types.dist_i(a, b)
  assert_true(d > 4.99 && d < 5.01)
}

///|
test "distance same point" {
  let a = @types.vec2i(5, 5)
  let d = @types.dist_i(a, a)
  assert_true(d < 0.01)
}

///|
test "broad sensor ring computation" {
  let sensor : @types.Sensor = {
    pos: @types.vec2i(5, 5),
    kind: Broad,
    direction: North,
  }
  let epicenter = @types.vec2i(8, 5)
  let tile = @types.new_tile(Empty)
  match compute_reading(sensor, epicenter, tile.kind) {
    Some(r) => {
      // distance is 3, uncertainty ±2
      assert_true(r.min_dist > 0.99 && r.min_dist < 1.01)
      assert_true(r.max_dist > 4.99 && r.max_dist < 5.01)
      assert_true(r.angle > 359.0)
    }
    None => assert_true(false)
  }
}

///|
test "precise sensor narrower band" {
  let sensor : @types.Sensor = {
    pos: @types.vec2i(5, 5),
    kind: Precise,
    direction: North,
  }
  let epicenter = @types.vec2i(8, 5)
  let tile = @types.new_tile(Empty)
  match compute_reading(sensor, epicenter, tile.kind) {
    Some(r) => {
      // distance is 3, uncertainty ±1
      assert_true(r.min_dist > 1.99 && r.min_dist < 2.01)
      assert_true(r.max_dist > 3.99 && r.max_dist < 4.01)
    }
    None => assert_true(false)
  }
}

///|
test "directional wedge contains check" {
  let reading : @types.SensorReading = {
    center: @types.vec2i(5, 5),
    min_dist: 0.0,
    max_dist: 6.0,
    direction: East,
    angle: 90.0,
    kind: Directional,
  }
  // Point due east should be in wedge
  assert_true(point_in_ring(reading, @types.vec2i(8, 5)))
  // Point due west should NOT be in wedge
  assert_true(!point_in_ring(reading, @types.vec2i(2, 5)))
  // Point due north should NOT be in wedge (outside 90 degree cone)
  assert_true(!point_in_ring(reading, @types.vec2i(5, 2)))
}

///|
test "multi-sensor overlap narrows region" {
  let r1 : @types.SensorReading = {
    center: @types.vec2i(2, 5),
    min_dist: 3.0,
    max_dist: 7.0,
    direction: North,
    angle: 360.0,
    kind: Broad,
  }
  let r2 : @types.SensorReading = {
    center: @types.vec2i(9, 5),
    min_dist: 1.0,
    max_dist: 5.0,
    direction: North,
    angle: 360.0,
    kind: Broad,
  }
  let overlap1 = compute_overlap_tiles([r1])
  let overlap2 = compute_overlap_tiles([r1, r2])
  // Two readings should narrow the overlap
  assert_true(overlap2.length() <= overlap1.length())
  assert_true(overlap2.length() > 0)
}

///|
test "tolerance check for guess accuracy" {
  assert_true(check_guess(@types.vec2i(5, 5), @types.vec2i(5, 5), 2.0))
  assert_true(check_guess(@types.vec2i(6, 5), @types.vec2i(5, 5), 2.0))
  assert_true(!check_guess(@types.vec2i(10, 5), @types.vec2i(5, 5), 2.0))
}

///|
test "out of range sensor gives no reading" {
  let sensor : @types.Sensor = {
    pos: @types.vec2i(0, 0),
    kind: Broad,
    direction: North,
  }
  let epicenter = @types.vec2i(11, 9)
  let tile = @types.new_tile(Empty)
  let result = compute_reading(sensor, epicenter, tile.kind)
  assert_true(result.is_empty())
}

///|
test "noisy tile extra uncertainty" {
  let sensor : @types.Sensor = {
    pos: @types.vec2i(5, 5),
    kind: Precise,
    direction: North,
  }
  let epicenter = @types.vec2i(8, 5)
  let reading_clean = compute_reading(sensor, epicenter, Empty)
  let reading_noisy = compute_reading(sensor, epicenter, Noisy)
  match (reading_clean, reading_noisy) {
    (Some(rc), Some(rn)) =>
      // Noisy should have wider band
      assert_true(rn.max_dist - rn.min_dist > rc.max_dist - rc.min_dist)
    _ => assert_true(false)
  }
}

///|
test "budget validation" {
  let game = @types.new_game()
  let grid = @types.make_grid(@types.grid_rows, @types.grid_cols)
  let level : @types.Level = {
    grid,
    epicenters: [@types.new_epicenter(5, 5)],
    sensor_budget: 3,
    par_budget: 2,
    par_guesses: 1,
    tier: Detection,
    towns: [],
    level_index: 0,
    name: "Test",
  }
  game.level = Some(level)
  game.selected_sensor = Broad
  // Should be able to place (cost 1, budget 3)
  assert_true(can_place_sensor(game, @types.vec2i(2, 2)))
  // Simulate using up budget
  game.budget_used = 3
  assert_true(!can_place_sensor(game, @types.vec2i(3, 3)))
}

///|
test "dual epicenter detection" {
  let e1 = @types.vec2i(3, 3)
  let e2 = @types.vec2i(8, 7)
  let epicenters = [
    @types.new_epicenter(e1.x, e1.y),
    @types.new_epicenter(e2.x, e2.y),
  ]
  // Find first
  let idx1 = check_all_epicenters(@types.vec2i(3, 3), epicenters, 2.0)
  assert_true(idx1 == 0)
  epicenters[0].found = true
  // Find second
  let idx2 = check_all_epicenters(@types.vec2i(8, 7), epicenters, 2.0)
  assert_true(idx2 == 1)
  epicenters[1].found = true
  assert_true(all_epicenters_found(epicenters))
}
