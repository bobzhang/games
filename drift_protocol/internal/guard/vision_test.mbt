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
  let tiles : Array[Array[@types.TileKind]] = Array(capacity=@types.grid_height)
  for _y in 0..<@types.grid_height {
    let row : Array[@types.TileKind] = Array(capacity=@types.grid_width)
    for _x in 0..<@types.grid_width {
      row.push(Floor)
    }
    tiles.push(row)
  }
  // Guard at (5,5) facing right (angle=0)
  let grd = @types.new_guard(5, 5, Patrol, [{ x: 5, y: 5, }])
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
  let tiles : Array[Array[@types.TileKind]] = Array(capacity=@types.grid_height)
  for _y in 0..<@types.grid_height {
    let row : Array[@types.TileKind] = Array(capacity=@types.grid_width)
    for _x in 0..<@types.grid_width {
      row.push(Floor)
    }
    tiles.push(row)
  }
  // Place wall between guard and target
  tiles[5][7] = Wall
  let grd = @types.new_guard(5, 5, Patrol, [{ x: 5, y: 5, }])
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
  let tiles : Array[Array[@types.TileKind]] = Array(capacity=@types.grid_height)
  for _y in 0..<@types.grid_height {
    let row : Array[@types.TileKind] = Array(capacity=@types.grid_width)
    for _x in 0..<@types.grid_width {
      row.push(Floor)
    }
    tiles.push(row)
  }
  let grd = @types.new_guard(5, 5, Patrol, [{ x: 5, y: 5, }])
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
  let tiles : Array[Array[@types.TileKind]] = Array(capacity=@types.grid_height)
  for _y in 0..<@types.grid_height {
    let row : Array[@types.TileKind] = Array(capacity=@types.grid_width)
    for _x in 0..<@types.grid_width {
      row.push(Floor)
    }
    tiles.push(row)
  }
  game.level.tiles = tiles
  let grd = @types.new_guard(5, 5, Patrol, [{ x: 5, y: 5, }, { x: 8, y: 5, }])
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
  let tiles : Array[Array[@types.TileKind]] = Array(capacity=@types.grid_height)
  for _y in 0..<@types.grid_height {
    let row : Array[@types.TileKind] = Array(capacity=@types.grid_width)
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

///|
test "alert_nearby_guards propagates to nearby patrolling guards" {
  let game = @types.new_game()
  let tiles : Array[Array[@types.TileKind]] = Array(capacity=@types.grid_height)
  for _y in 0..<@types.grid_height {
    let row : Array[@types.TileKind] = Array(capacity=@types.grid_width)
    for _x in 0..<@types.grid_width {
      row.push(Floor)
    }
    tiles.push(row)
  }
  game.level.tiles = tiles
  // g1 is within radio range (<=8), g2 is out of range, g3 is already suspicious
  let g1 = @types.new_guard(3, 3, Patrol, [{ x: 3, y: 3, }])
  let g2 = @types.new_guard(15, 15, Patrol, [{ x: 15, y: 15, }])
  let g3 = @types.new_guard(4, 4, Patrol, [{ x: 4, y: 4, }])
  g3.alert_state = Suspicious
  game.level.guards = [g1, g2, g3]
  // Alert at position (5,5)
  @guard.alert_nearby_guards(game, 5, 5)
  // g1 is 4 manhattan distance away - should become suspicious
  inspect(g1.alert_state, content="Suspicious")
  inspect(g1.investigate_x, content="5")
  inspect(g1.investigate_y, content="5")
  // g2 is far away - should remain patrolling
  inspect(g2.alert_state, content="Patrolling")
  // g3 was already suspicious - alert_nearby_guards only affects Patrolling
  inspect(g3.alert_state, content="Suspicious")
}

///|
test "alert_nearby_guards does not affect alert guards" {
  let game = @types.new_game()
  let tiles : Array[Array[@types.TileKind]] = Array(capacity=@types.grid_height)
  for _y in 0..<@types.grid_height {
    let row : Array[@types.TileKind] = Array(capacity=@types.grid_width)
    for _x in 0..<@types.grid_width {
      row.push(Floor)
    }
    tiles.push(row)
  }
  game.level.tiles = tiles
  let g1 = @types.new_guard(3, 3, Patrol, [{ x: 3, y: 3, }])
  g1.alert_state = Alert
  g1.investigate_x = 10
  g1.investigate_y = 10
  game.level.guards = [g1]
  @guard.alert_nearby_guards(game, 5, 5)
  // Already alert - investigate position should NOT change
  inspect(g1.alert_state, content="Alert")
  inspect(g1.investigate_x, content="10")
}

///|
test "guards_hear_noise updates suspicious guard investigate target" {
  let game = @types.new_game()
  let tiles : Array[Array[@types.TileKind]] = Array(capacity=@types.grid_height)
  for _y in 0..<@types.grid_height {
    let row : Array[@types.TileKind] = Array(capacity=@types.grid_width)
    for _x in 0..<@types.grid_width {
      row.push(Floor)
    }
    tiles.push(row)
  }
  game.level.tiles = tiles
  let g1 = @types.new_guard(5, 5, Patrol, [{ x: 5, y: 5, }])
  g1.alert_state = Suspicious
  g1.investigate_x = 3
  g1.investigate_y = 3
  g1.suspicious_timer = 1.0
  game.level.guards = [g1]
  // Noise at new position within radius
  @guard.guards_hear_noise(game, 7, 7, 4)
  // Should update investigate target and reset timer
  inspect(g1.investigate_x, content="7")
  inspect(g1.investigate_y, content="7")
  inspect(g1.suspicious_timer == @types.suspicious_duration, content="true")
}

///|
test "guards_hear_noise updates alert guard investigate target" {
  let game = @types.new_game()
  let tiles : Array[Array[@types.TileKind]] = Array(capacity=@types.grid_height)
  for _y in 0..<@types.grid_height {
    let row : Array[@types.TileKind] = Array(capacity=@types.grid_width)
    for _x in 0..<@types.grid_width {
      row.push(Floor)
    }
    tiles.push(row)
  }
  game.level.tiles = tiles
  let g1 = @types.new_guard(5, 5, Patrol, [{ x: 5, y: 5, }])
  g1.alert_state = Alert
  g1.investigate_x = 1
  g1.investigate_y = 1
  game.level.guards = [g1]
  @guard.guards_hear_noise(game, 6, 6, 3)
  // Alert guards get their investigate target updated
  inspect(g1.investigate_x, content="6")
  inspect(g1.investigate_y, content="6")
}

///|
test "guards_hear_noise ignores inactive guards" {
  let game = @types.new_game()
  let tiles : Array[Array[@types.TileKind]] = Array(capacity=@types.grid_height)
  for _y in 0..<@types.grid_height {
    let row : Array[@types.TileKind] = Array(capacity=@types.grid_width)
    for _x in 0..<@types.grid_width {
      row.push(Floor)
    }
    tiles.push(row)
  }
  game.level.tiles = tiles
  let g1 = @types.new_guard(5, 5, Patrol, [{ x: 5, y: 5, }])
  g1.active = false
  game.level.guards = [g1]
  @guard.guards_hear_noise(game, 5, 5, 3)
  inspect(g1.alert_state, content="Patrolling")
}

///|
test "guards_hear_noise only reaches guards within radius" {
  let game = @types.new_game()
  let tiles : Array[Array[@types.TileKind]] = Array(capacity=@types.grid_height)
  for _y in 0..<@types.grid_height {
    let row : Array[@types.TileKind] = Array(capacity=@types.grid_width)
    for _x in 0..<@types.grid_width {
      row.push(Floor)
    }
    tiles.push(row)
  }
  game.level.tiles = tiles
  let g_near = @types.new_guard(5, 5, Patrol, [{ x: 5, y: 5, }])
  let g_far = @types.new_guard(12, 12, Patrol, [{ x: 12, y: 12, }])
  game.level.guards = [g_near, g_far]
  // Noise at (4,4) with radius 3
  @guard.guards_hear_noise(game, 4, 4, 3)
  inspect(g_near.alert_state, content="Suspicious")
  inspect(g_far.alert_state, content="Patrolling")
}

///|
test "point_in_camera_vision checks powered state" {
  let tiles : Array[Array[@types.TileKind]] = Array(capacity=@types.grid_height)
  for _y in 0..<@types.grid_height {
    let row : Array[@types.TileKind] = Array(capacity=@types.grid_width)
    for _x in 0..<@types.grid_width {
      row.push(Floor)
    }
    tiles.push(row)
  }
  let cam = @types.new_camera(5, 5)
  cam.facing_angle = 0.0
  // Camera powered - should see target in front
  inspect(@guard.point_in_camera_vision(cam, 7, 5, tiles), content="true")
  // Disable camera power
  cam.powered = false
  inspect(@guard.point_in_camera_vision(cam, 7, 5, tiles), content="false")
}
