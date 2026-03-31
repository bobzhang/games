///|
test "check_player_caught requires alert and adjacent" {
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
  // Guard alert but far away
  let g1 = @types.new_guard(10, 10, Patrol, [])
  g1.alert_state = Alert
  game.level.guards = [g1]
  game.player.gx = 3
  game.player.gy = 3
  inspect(@stealth.check_player_caught(game), content="false")
  // Guard alert and adjacent
  g1.gx = 4
  g1.gy = 3
  inspect(@stealth.check_player_caught(game), content="true")
  // Guard suspicious and adjacent (not caught)
  g1.alert_state = Suspicious
  inspect(@stealth.check_player_caught(game), content="false")
}

///|
test "max_detection_meter finds highest" {
  let game = @types.new_game()
  let g1 = @types.new_guard(5, 5, Patrol, [])
  g1.detection_meter = 0.3
  let g2 = @types.new_guard(8, 8, Sentinel, [])
  g2.detection_meter = 0.7
  let g3 = @types.new_guard(2, 2, Hunter, [])
  g3.detection_meter = 0.1
  game.level.guards = [g1, g2, g3]
  let max_d = @stealth.max_detection_meter(game)
  inspect(max_d == 0.7, content="true")
}

///|
test "count_alert_guards categorizes correctly" {
  let game = @types.new_game()
  let g1 = @types.new_guard(5, 5, Patrol, [])
  g1.alert_state = Patrolling
  let g2 = @types.new_guard(8, 8, Sentinel, [])
  g2.alert_state = Suspicious
  let g3 = @types.new_guard(2, 2, Hunter, [])
  g3.alert_state = Alert
  let g4 = @types.new_guard(12, 12, Patrol, [])
  g4.alert_state = Suspicious
  game.level.guards = [g1, g2, g3, g4]
  let (patrolling, suspicious, alert) = @stealth.count_alert_guards(game)
  inspect(patrolling, content="1")
  inspect(suspicious, content="2")
  inspect(alert, content="1")
}
