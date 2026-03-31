///|
test "parse simple ASCII level" {
  let ascii : Array[String] = [
    "####################",
    "#S.............#.T.#",
    "#..............#...#",
    "#..~...G.......#...#",
    "#..............####.#",
    "#.................#",
    "#...............#..#",
    "#....G..........#X.#",
    "#...............#..#",
    "#..~..........######",
    "#..............T...#",
    "#....G.............#",
    "#..~...............#",
    "#..................#",
    "####################",
  ]
  let level = @level.parse_level("Test", Corporate, ascii, 30.0)
  inspect(level.name, content="Test")
  inspect(level.tier, content="Corporate")
  inspect(level.par_time == 30.0, content="true")
  // Check start position
  inspect(level.start_x, content="1")
  inspect(level.start_y, content="1")
  // Check walls
  inspect(level.tiles[0][0], content="Wall")
  inspect(level.tiles[1][1], content="Start")
  // Check shadow
  inspect(level.tiles[3][3], content="Shadow")
  // Check terminal count
  inspect(level.terminals.length() > 0, content="true")
  // Check guard count
  inspect(level.guards.length() > 0, content="true")
}

///|
test "load_level returns valid level for each index" {
  for i in 0..<8 {
    let level = @level.load_level(i)
    // Every level should have a start
    inspect(@types.in_bounds(level.start_x, level.start_y), content="true")
    // Every level should have an exit
    inspect(@types.in_bounds(level.exit_x, level.exit_y), content="true")
    // Every level should have guards
    inspect(level.guards.length() > 0, content="true")
    // Every level should have a name
    inspect(level.name.length() > 0, content="true")
  }
}

///|
test "level_name returns names for all levels" {
  for i in 0..<8 {
    let name = @level.level_name(i)
    inspect(name.length() > 0, content="true")
    // Should not be "Unknown"
    inspect(name != "Unknown", content="true")
  }
}

///|
test "level_tier returns correct tier" {
  inspect(@level.level_tier(0), content="Corporate")
  inspect(@level.level_tier(3), content="Corporate")
  inspect(@level.level_tier(4), content="Military")
  inspect(@level.level_tier(7), content="Military")
}

///|
test "parse_level creates terminals from T and H tiles" {
  let ascii : Array[String] = [
    "####################",
    "#S....T....H......X#",
    "#..................#",
    "#..................#",
    "#..................#",
    "#..................#",
    "#..................#",
    "#..................#",
    "#..................#",
    "#..................#",
    "#..................#",
    "#..................#",
    "#..................#",
    "#..................#",
    "####################",
  ]
  let level = @level.parse_level("Term Test", Corporate, ascii, 30.0)
  inspect(level.terminals.length(), content="2")
  // First should be normal, second high security
  inspect(level.terminals[0].high_security, content="false")
  inspect(level.terminals[1].high_security, content="true")
  inspect(level.total_data, content="200")
}

///|
test "parse_level creates doors and lasers" {
  let ascii : Array[String] = [
    "####################",
    "#S....D....L......X#",
    "#..................#",
    "#..................#",
    "#..................#",
    "#..................#",
    "#..................#",
    "#..................#",
    "#..................#",
    "#..................#",
    "#..................#",
    "#..................#",
    "#..................#",
    "#..................#",
    "####################",
  ]
  let level = @level.parse_level("Door Test", Corporate, ascii, 30.0)
  inspect(level.doors.length(), content="1")
  inspect(level.lasers.length(), content="1")
}
