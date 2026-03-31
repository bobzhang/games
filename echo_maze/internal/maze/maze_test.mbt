///|
test "get_all_levels returns 24 levels" {
  let levels = @maze.get_all_levels()
  inspect(levels.length(), content="24")
}

///|
test "each world has 8 levels" {
  let levels = @maze.get_all_levels()
  let mut w0 = 0
  let mut w1 = 0
  let mut w2 = 0
  for l in levels {
    match l.world {
      0 => w0 += 1
      1 => w1 += 1
      2 => w2 += 1
      _ => ()
    }
  }
  inspect(w0, content="8")
  inspect(w1, content="8")
  inspect(w2, content="8")
}

///|
test "get_level returns correct level" {
  let level = @maze.get_level(0, 0)
  inspect(level is Some(_), content="true")
  let ld = level.unwrap()
  inspect(ld.name, content="First Steps")
  inspect(ld.world, content="0")
  inspect(ld.level, content="0")
}

///|
test "get_level returns None for invalid" {
  let level = @maze.get_level(5, 5)
  inspect(level is None, content="true")
}

///|
test "parse_maze creates valid maze" {
  let level = @maze.get_level(0, 0).unwrap()
  let maze = @maze.parse_maze(level)
  inspect(maze.width > 0, content="true")
  inspect(maze.height > 0, content="true")
  inspect(@maze.validate_maze(maze), content="true")
}

///|
test "all levels parse successfully" {
  let levels = @maze.get_all_levels()
  for l in levels {
    let maze = @maze.parse_maze(l)
    inspect(@maze.validate_maze(maze), content="true")
  }
}

///|
test "level 1-2 has button and door" {
  let level = @maze.get_level(0, 1).unwrap()
  let maze = @maze.parse_maze(level)
  inspect(maze.button_links.length(), content="1")
  // Check that button and door tiles exist
  let mut has_button = false
  let mut has_door = false
  for y in 0..<maze.height {
    for x in 0..<maze.width {
      match maze.tiles[y][x].kind {
        Button(_) => has_button = true
        Door(_) => has_door = true
        _ => ()
      }
    }
  }
  inspect(has_button, content="true")
  inspect(has_door, content="true")
}

///|
test "level 2-1 has timed door" {
  let level = @maze.get_level(1, 0).unwrap()
  let maze = @maze.parse_maze(level)
  let mut has_timed = false
  for y in 0..<maze.height {
    for x in 0..<maze.width {
      if maze.tiles[y][x].kind is TimedDoor(_, _) {
        has_timed = true
      }
    }
  }
  inspect(has_timed, content="true")
}

///|
test "level 2-2 has guard" {
  let level = @maze.get_level(1, 1).unwrap()
  let maze = @maze.parse_maze(level)
  inspect(maze.guard_defs.length() > 0, content="true")
}

///|
test "level 1-7 has collectibles" {
  let level = @maze.get_level(0, 6).unwrap()
  let maze = @maze.parse_maze(level)
  inspect(maze.collectible_positions.length() > 0, content="true")
}

///|
test "new_maze_state initializes correctly" {
  let level = @maze.get_level(0, 3).unwrap() // "Two Doors"
  let maze = @maze.parse_maze(level)
  let ms = @types.new_maze_state(maze)
  // Should have door states for each unique door
  inspect(ms.door_states.length() > 0, content="true")
  // All doors should start closed
  for ds in ms.door_states {
    inspect(ds.open, content="false")
  }
  // Button pressed should be initialized
  inspect(ms.button_pressed.length(), content="2")
}
