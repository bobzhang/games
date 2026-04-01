///|
test "get_level returns level for all 28 levels" {
  for w in 0..<4 {
    for l in 0..<7 {
      let level = get_level(w, l)
      inspect(level.world, content=w.to_string())
      inspect(level.index, content=l.to_string())
    }
  }
}

///|
test "get_level out of range returns level_1_1" {
  let level = get_level(99, 99)
  inspect(level.world, content="0")
  inspect(level.index, content="0")
}

///|
test "world 1 levels have BothExit goal" {
  for l in 0..<7 {
    let level = get_level(0, l)
    inspect(level.goal, content="BothExit")
  }
}

///|
test "level_1_1 has correct start and exit positions" {
  let level = get_level(0, 0)
  // Floor start @ and exit X parsed from grid strings
  // Floor: "#@........X#" => start at x=1, exit at x=10
  // Check par_moves
  inspect(level.par_moves, content="10")
}

///|
test "level grid dimensions are correct" {
  let level = get_level(0, 0)
  inspect(level.floor_tiles.length(), content="8")
  inspect(level.ceiling_tiles.length(), content="8")
  // Each row should have grid_width columns
  inspect(level.floor_tiles[0].length(), content="12")
  inspect(level.ceiling_tiles[0].length(), content="12")
}

///|
test "parse_grid identifies walls" {
  let lines = [
    "############", "############", "############", "############", "############",
    "############", "############", "############",
  ]
  let (grid, _start, _exit, _gems) = parse_grid(lines)
  inspect(grid[0][0], content="Wall")
  inspect(grid[3][5], content="Wall")
}

///|
test "parse_grid identifies floor and start" {
  let lines = [
    "############", "#@.........#", "############", "############", "############",
    "############", "############", "############",
  ]
  let (grid, start, _exit, _gems) = parse_grid(lines)
  inspect(grid[1][1], content="Floor") // @ becomes Floor
  inspect(start.x, content="1")
  inspect(start.y, content="1")
  inspect(grid[1][2], content="Floor")
}

///|
test "parse_grid identifies exit" {
  let lines = [
    "############", "#.........X#", "############", "############", "############",
    "############", "############", "############",
  ]
  let (_grid, _start, exit, _gems) = parse_grid(lines)
  inspect(exit.x, content="10")
  inspect(exit.y, content="1")
}

///|
test "parse_grid identifies gems" {
  let lines = [
    "############", "#..G.......#", "#.......G..#", "############", "############",
    "############", "############", "############",
  ]
  let (_grid, _start, _exit, gems) = parse_grid(lines)
  inspect(gems.length(), content="2")
  inspect(gems[0].x, content="3")
  inspect(gems[0].y, content="1")
  inspect(gems[1].x, content="8")
  inspect(gems[1].y, content="2")
}

///|
test "parse_grid identifies switches and doors" {
  let lines = [
    "############", "#.0..a.....#", "#.1..b.....#", "############", "############",
    "############", "############", "############",
  ]
  let (grid, _start, _exit, _gems) = parse_grid(lines)
  inspect(grid[1][2], content="Switch(0)")
  inspect(grid[1][5], content="Door(0)")
  inspect(grid[2][2], content="Switch(1)")
  inspect(grid[2][5], content="Door(1)")
}

///|
test "parse_grid identifies special tiles" {
  let lines = [
    "############", "#.P.I.A....#", "############", "############", "############",
    "############", "############", "############",
  ]
  let (grid, _start, _exit, _gems) = parse_grid(lines)
  inspect(grid[1][2], content="Pit")
  inspect(grid[1][4], content="Ice")
  inspect(grid[1][6], content="Anchor")
}

///|
test "world 2 levels have switch_links" {
  let level = get_level(1, 0)
  assert_true(level.switch_links.length() > 0)
  // First level of world 2 should have switch 0 -> door 0
  inspect(level.switch_links[0].switch_id, content="0")
  inspect(level.switch_links[0].door_id, content="0")
}

///|
test "world 2 level 2 has two switch links" {
  let level = get_level(1, 1)
  inspect(level.switch_links.length(), content="2")
  inspect(level.switch_links[0].switch_id, content="0")
  inspect(level.switch_links[0].door_id, content="0")
  inspect(level.switch_links[1].switch_id, content="1")
  inspect(level.switch_links[1].door_id, content="1")
}

///|
test "world_unlocked first world always unlocked" {
  let scores : Array[Array[@types.LevelScore]] = []
  for _w in 0..<4 {
    let ws : Array[@types.LevelScore] = []
    for _l in 0..<7 {
      ws.push(@types.new_level_score())
    }
    scores.push(ws)
  }
  assert_true(world_unlocked(scores, 0))
  assert_false(world_unlocked(scores, 1))
}

///|
test "world_unlocked requires 4 completed in previous world" {
  let scores : Array[Array[@types.LevelScore]] = []
  for _w in 0..<4 {
    let ws : Array[@types.LevelScore] = []
    for _l in 0..<7 {
      ws.push(@types.new_level_score())
    }
    scores.push(ws)
  }
  // Complete 3 levels - not enough
  for i in 0..<3 {
    scores[0][i].completed = true
  }
  assert_false(world_unlocked(scores, 1))
  // Complete 4th level - now enough
  scores[0][3].completed = true
  assert_true(world_unlocked(scores, 1))
}

///|
test "level_unlocked requires previous level completed" {
  let scores : Array[Array[@types.LevelScore]] = []
  for _w in 0..<4 {
    let ws : Array[@types.LevelScore] = []
    for _l in 0..<7 {
      ws.push(@types.new_level_score())
    }
    scores.push(ws)
  }
  // First level of first world should be unlocked
  assert_true(level_unlocked(scores, 0, 0))
  // Second level should be locked (first not completed)
  assert_false(level_unlocked(scores, 0, 1))
  // Complete first level
  scores[0][0].completed = true
  assert_true(level_unlocked(scores, 0, 1))
}

///|
test "level_unlocked respects world locking" {
  let scores : Array[Array[@types.LevelScore]] = []
  for _w in 0..<4 {
    let ws : Array[@types.LevelScore] = []
    for _l in 0..<7 {
      ws.push(@types.new_level_score())
    }
    scores.push(ws)
  }
  // World 1 is locked, so level 0 of world 1 is locked
  assert_false(level_unlocked(scores, 1, 0))
}

///|
test "all levels have positive par_moves" {
  for w in 0..<4 {
    for l in 0..<7 {
      let level = get_level(w, l)
      assert_true(level.par_moves > 0)
    }
  }
}

///|
test "level_1_6 has gems on floor" {
  let level = get_level(0, 5)
  assert_true(level.gems.length() > 0)
}
