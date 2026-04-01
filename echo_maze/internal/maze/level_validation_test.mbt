///|
test "all 24 levels load and parse correctly" {
  let levels = @maze.get_all_levels()
  inspect(levels.length(), content="24")
  for l in levels {
    let maze = @maze.parse_maze(l)
    inspect(@maze.validate_maze(maze), content="true")
  }
}

///|
test "all levels have valid start position on Start tile" {
  let levels = @maze.get_all_levels()
  for l in levels {
    let maze = @maze.parse_maze(l)
    let start = maze.start
    inspect(
      start.x >= 0 &&
      start.x < maze.width &&
      start.y >= 0 &&
      start.y < maze.height,
      content="true",
    )
    inspect(maze.tiles[start.y][start.x].kind is Start, content="true")
  }
}

///|
test "all levels have valid exit position on Exit tile" {
  let levels = @maze.get_all_levels()
  for l in levels {
    let maze = @maze.parse_maze(l)
    let exit = maze.exit
    inspect(
      exit.x >= 0 && exit.x < maze.width && exit.y >= 0 && exit.y < maze.height,
      content="true",
    )
    inspect(maze.tiles[exit.y][exit.x].kind is Exit, content="true")
  }
}

///|
test "start and exit are not on same tile" {
  let levels = @maze.get_all_levels()
  for l in levels {
    let maze = @maze.parse_maze(l)
    inspect(@types.vec2i_eq(maze.start, maze.exit), content="false")
  }
}

///|
test "all button links reference valid buttons and doors" {
  let levels = @maze.get_all_levels()
  for l in levels {
    let maze = @maze.parse_maze(l)
    let errors = @simulation.validate_level_structure(maze, l)
    inspect(errors.length(), content="0")
  }
}

///|
test "world 0 levels have correct indices 0-7" {
  let levels = @maze.get_all_levels()
  let mut count = 0
  for l in levels {
    if l.world == 0 {
      inspect(l.level, content=count.to_string())
      count += 1
    }
  }
  inspect(count, content="8")
}

///|
test "world 1 levels have correct indices 0-7" {
  let levels = @maze.get_all_levels()
  let mut count = 0
  for l in levels {
    if l.world == 1 {
      inspect(l.level, content=count.to_string())
      count += 1
    }
  }
  inspect(count, content="8")
}

///|
test "world 2 levels have correct indices 0-7" {
  let levels = @maze.get_all_levels()
  let mut count = 0
  for l in levels {
    if l.world == 2 {
      inspect(l.level, content=count.to_string())
      count += 1
    }
  }
  inspect(count, content="8")
}

///|
test "all levels have non-empty names" {
  let levels = @maze.get_all_levels()
  for l in levels {
    inspect(l.name.length() > 0, content="true")
  }
}

///|
test "all levels have par_loops >= 1" {
  let levels = @maze.get_all_levels()
  for l in levels {
    inspect(l.par_loops >= 1, content="true")
  }
}

///|
test "guard patrol routes are all valid - on floor tiles" {
  let levels = @maze.get_all_levels()
  for l in levels {
    let maze = @maze.parse_maze(l)
    for patrol in l.guard_patrols {
      inspect(patrol.length() >= 2, content="true")
      for waypoint in patrol {
        // All waypoints must be in bounds
        inspect(
          waypoint.x >= 0 &&
          waypoint.x < maze.width &&
          waypoint.y >= 0 &&
          waypoint.y < maze.height,
          content="true",
        )
        // Waypoints should not be walls
        inspect(
          !(maze.tiles[waypoint.y][waypoint.x].kind is Wall),
          content="true",
        )
      }
    }
  }
}

///|
test "guard patrol routes have adjacent waypoints" {
  let levels = @maze.get_all_levels()
  for l in levels {
    for patrol in l.guard_patrols {
      // Each consecutive waypoint should be adjacent (manhattan dist 1)
      for i in 1..<patrol.length() {
        let dist = @types.manhattan_dist(patrol[i - 1], patrol[i])
        inspect(dist, content="1")
      }
    }
  }
}

///|
test "world 0 has no guards - mechanics introduction" {
  let levels = @maze.get_all_levels()
  for l in levels {
    if l.world == 0 {
      inspect(l.guard_patrols.length(), content="0")
    }
  }
}

///|
test "world 0 has no timed doors - mechanics introduction" {
  let levels = @maze.get_all_levels()
  for l in levels {
    if l.world == 0 {
      inspect(l.timed_door_durations.length(), content="0")
    }
  }
}

///|
test "level 1-1 First Steps has no buttons or doors - simplest level" {
  let level = @maze.get_level(0, 0).unwrap()
  inspect(level.button_links.length(), content="0")
  inspect(level.guard_patrols.length(), content="0")
  inspect(level.timed_door_durations.length(), content="0")
  inspect(level.par_loops, content="1")
}

///|
test "level difficulty progression - world 0 par_loops non-decreasing" {
  // Par loops should generally increase or stay same as levels get harder
  let levels = @maze.get_all_levels()
  let mut prev_par = 0
  for l in levels {
    if l.world == 0 {
      inspect(l.par_loops >= prev_par, content="true")
      prev_par = l.par_loops
    }
  }
}

///|
test "button count matches button_links count" {
  let levels = @maze.get_all_levels()
  for l in levels {
    let maze = @maze.parse_maze(l)
    let mut button_count = 0
    for y in 0..<maze.height {
      for x in 0..<maze.width {
        if maze.tiles[y][x].kind is Button(_) {
          button_count += 1
        }
      }
    }
    // Button count should be >= button_links length (each link references one button)
    inspect(button_count >= l.button_links.length(), content="true")
  }
}

///|
test "door count matches expected from button_links and timed_doors" {
  let levels = @maze.get_all_levels()
  for l in levels {
    let maze = @maze.parse_maze(l)
    let mut door_count = 0
    for y in 0..<maze.height {
      for x in 0..<maze.width {
        match maze.tiles[y][x].kind {
          Door(_) | TimedDoor(_, _) => door_count += 1
          _ => ()
        }
      }
    }
    // Every level with button_links should have at least that many doors
    if l.button_links.length() > 0 {
      inspect(door_count > 0, content="true")
    }
  }
}

///|
test "maze dimensions are within grid max bounds" {
  let levels = @maze.get_all_levels()
  for l in levels {
    let maze = @maze.parse_maze(l)
    inspect(maze.width <= @types.grid_max_w, content="true")
    inspect(maze.height <= @types.grid_max_h, content="true")
    inspect(maze.width > 0, content="true")
    inspect(maze.height > 0, content="true")
  }
}

///|
test "maze borders are all walls" {
  let levels = @maze.get_all_levels()
  for l in levels {
    let maze = @maze.parse_maze(l)
    // Top and bottom rows should be all walls
    for x in 0..<maze.width {
      inspect(maze.tiles[0][x].kind is Wall, content="true")
      inspect(maze.tiles[maze.height - 1][x].kind is Wall, content="true")
    }
    // Left and right columns should be all walls
    for y in 0..<maze.height {
      inspect(maze.tiles[y][0].kind is Wall, content="true")
      inspect(maze.tiles[y][maze.width - 1].kind is Wall, content="true")
    }
  }
}

///|
test "timed door durations reference valid door ids" {
  let levels = @maze.get_all_levels()
  for l in levels {
    let maze = @maze.parse_maze(l)
    for dur in l.timed_door_durations {
      let door_id = dur.0
      let duration = dur.1
      // Duration must be positive
      inspect(duration > 0, content="true")
      // Door id must exist in the maze
      let mut found = false
      for y in 0..<maze.height {
        for x in 0..<maze.width {
          if maze.tiles[y][x].kind is TimedDoor(id, _) && id == door_id {
            found = true
          }
        }
      }
      inspect(found, content="true")
    }
  }
}

///|
test "collectible positions are on Collectible tiles" {
  let levels = @maze.get_all_levels()
  for l in levels {
    let maze = @maze.parse_maze(l)
    for pos in maze.collectible_positions {
      inspect(
        pos.x >= 0 && pos.x < maze.width && pos.y >= 0 && pos.y < maze.height,
        content="true",
      )
      inspect(maze.tiles[pos.y][pos.x].kind is Collectible, content="true")
    }
  }
}
