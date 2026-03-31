///|
test "normalize_angle wraps correctly" {
  let pi = @types.pi
  // Already in range
  inspect(@guard.normalize_angle(0.0) == 0.0, content="true")
  // Positive overflow
  let a1 = @guard.normalize_angle(3.0 * pi)
  inspect(@types.absf(a1 - pi) < 0.01, content="true")
  // Negative overflow
  let a2 = @guard.normalize_angle(-3.0 * pi)
  inspect(@types.absf(a2 - -pi) < 0.01, content="true")
}

///|
test "point_in_vision_cone detects target in front" {
  let tiles : Array[Array[@types.TileKind]] = Array::new(
    capacity=@types.grid_height,
  )
  for _y in 0..<@types.grid_height {
    let row : Array[@types.TileKind] = Array::new(capacity=@types.grid_width)
    for _x in 0..<@types.grid_width {
      row.push(Floor)
    }
    tiles.push(row)
  }
  // Guard at (5,5) facing right (angle=0)
  let grd = @types.new_guard(5, 5, Patrol, [{ x: 5, y: 5 }])
  grd.facing_angle = 0.0 // facing right
  grd.vision_range = 5.0
  grd.vision_cone = @types.pi / 3.0
  // Target directly in front at (8,5) - should be visible
  inspect(@guard.point_in_vision_cone(grd, 8, 5, tiles), content="true")
  // Target behind at (2,5) - should not be visible
  inspect(@guard.point_in_vision_cone(grd, 2, 5, tiles), content="false")
  // Target too far at (15,5) - should not be visible
  inspect(@guard.point_in_vision_cone(grd, 15, 5, tiles), content="false")
}

///|
test "vision blocked by wall" {
  let tiles : Array[Array[@types.TileKind]] = Array::new(
    capacity=@types.grid_height,
  )
  for _y in 0..<@types.grid_height {
    let row : Array[@types.TileKind] = Array::new(capacity=@types.grid_width)
    for _x in 0..<@types.grid_width {
      row.push(Floor)
    }
    tiles.push(row)
  }
  // Place wall between guard and target
  tiles[5][7] = Wall
  let grd = @types.new_guard(5, 5, Patrol, [{ x: 5, y: 5 }])
  grd.facing_angle = 0.0
  grd.vision_range = 5.0
  grd.vision_cone = @types.pi / 3.0
  // Target behind wall
  inspect(@guard.point_in_vision_cone(grd, 9, 5, tiles), content="false")
  // Target before wall
  inspect(@guard.point_in_vision_cone(grd, 6, 5, tiles), content="true")
}

///|
test "shadow reduces vision range" {
  let tiles : Array[Array[@types.TileKind]] = Array::new(
    capacity=@types.grid_height,
  )
  for _y in 0..<@types.grid_height {
    let row : Array[@types.TileKind] = Array::new(capacity=@types.grid_width)
    for _x in 0..<@types.grid_width {
      row.push(Floor)
    }
    tiles.push(row)
  }
  let grd = @types.new_guard(5, 5, Patrol, [{ x: 5, y: 5 }])
  grd.facing_angle = 0.0
  grd.vision_range = 5.0
  grd.vision_cone = @types.pi / 3.0
  // Target at range 4 in light - visible
  inspect(@guard.point_in_vision_cone(grd, 9, 5, tiles), content="true")
  // Make target tile shadow - range halved to 2.5, so 4 is out
  tiles[5][9] = Shadow
  inspect(@guard.point_in_vision_cone(grd, 9, 5, tiles), content="false")
  // Close shadow tile still visible
  tiles[5][6] = Shadow
  inspect(@guard.point_in_vision_cone(grd, 6, 5, tiles), content="true")
}

///|
test "guard state transitions" {
  // Create a minimal game for testing
  let game = @types.new_game()
  let tiles : Array[Array[@types.TileKind]] = Array::new(
    capacity=@types.grid_height,
  )
  for _y in 0..<@types.grid_height {
    let row : Array[@types.TileKind] = Array::new(capacity=@types.grid_width)
    for _x in 0..<@types.grid_width {
      row.push(Floor)
    }
    tiles.push(row)
  }
  game.level.tiles = tiles
  let grd = @types.new_guard(5, 5, Patrol, [{ x: 5, y: 5 }, { x: 8, y: 5 }])
  game.level.guards = [grd]
  // Initially patrolling
  inspect(grd.alert_state, content="Patrolling")
  // Guards hear noise
  @guard.guards_hear_noise(game, 6, 5, 2)
  inspect(grd.alert_state, content="Suspicious")
  inspect(grd.investigate_x, content="6")
}

///|
test "detection_speed_at varies by tile" {
  let tiles : Array[Array[@types.TileKind]] = Array::new(
    capacity=@types.grid_height,
  )
  for _y in 0..<@types.grid_height {
    let row : Array[@types.TileKind] = Array::new(capacity=@types.grid_width)
    for _x in 0..<@types.grid_width {
      row.push(Floor)
    }
    tiles.push(row)
  }
  tiles[3][3] = Shadow
  inspect(
    @guard.detection_speed_at(tiles, 5, 5) == @types.detection_rate_light,
    content="true",
  )
  inspect(
    @guard.detection_speed_at(tiles, 3, 3) == @types.detection_rate_shadow,
    content="true",
  )
}
