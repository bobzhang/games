///|
test "player moves to walkable tile" {
  let level = @maze.get_level(0, 0).unwrap()
  let maze = @maze.parse_maze(level)
  let ms = @types.new_maze_state(maze)
  let player = @types.new_player(maze.start)
  let start_x = player.pos.x
  // Move east (right)
  let moved = @simulation.try_move_player(maze, ms, player, East)
  inspect(moved, content="true")
  inspect(player.pos.x == start_x + 1, content="true")
}

///|
test "player blocked by wall" {
  let level = @maze.get_level(0, 0).unwrap()
  let maze = @maze.parse_maze(level)
  let ms = @types.new_maze_state(maze)
  let player = @types.new_player(maze.start)
  // Move north into wall (row 0 is always wall)
  let moved = @simulation.try_move_player(maze, ms, player, North)
  inspect(moved, content="false")
}

///|
test "button opens linked door" {
  // Level 1-2 "One Button" has button_id 0 -> door_id 0
  let level = @maze.get_level(0, 1).unwrap()
  let maze = @maze.parse_maze(level)
  let ms = @types.new_maze_state(maze)
  let player = @types.new_player(maze.start)
  let ghosts : Array[@types.Ghost] = []
  // Door should start closed
  inspect(@simulation.is_door_open(ms, 0), content="false")
  // Find the button position
  let mut btn_pos = @types.vec2i(0, 0)
  for y in 0..<maze.height {
    for x in 0..<maze.width {
      match maze.tiles[y][x].kind {
        Button(0) => btn_pos = @types.vec2i(x, y)
        _ => ()
      }
    }
  }
  // Move player to button position
  player.pos = btn_pos
  @simulation.update_buttons(maze, ms, player, ghosts)
  @simulation.update_doors(maze, ms)
  // Door should now be open
  inspect(@simulation.is_door_open(ms, 0), content="true")
}

///|
test "ghost replays recorded moves" {
  let level = @maze.get_level(0, 0).unwrap()
  let maze = @maze.parse_maze(level)
  let ms = @types.new_maze_state(maze)
  // Level 1-1 ASCII: "#########\n#S......#\n#.######.#\n#.......X#\n##########"
  // Start at (1,1). East moves along row 1 which is all floor.
  let recording : Array[@types.Direction?] = [
    Some(East),
    Some(East),
    Some(East),
  ]
  let ghost = @types.new_ghost(recording, Green, maze.start)
  let start_pos = ghost.pos
  // Tick 0: move east
  @simulation.advance_ghost(ghost, maze, ms, 0)
  inspect(ghost.pos.x == start_pos.x + 1, content="true")
  // Tick 1: move east again
  @simulation.advance_ghost(ghost, maze, ms, 1)
  inspect(ghost.pos.x == start_pos.x + 2, content="true")
  // Tick 2: move east again
  @simulation.advance_ghost(ghost, maze, ms, 2)
  inspect(ghost.pos.x == start_pos.x + 3, content="true")
}

///|
test "guard advances along patrol" {
  let patrol = [
    @types.vec2i(3, 3),
    @types.vec2i(4, 3),
    @types.vec2i(5, 3),
    @types.vec2i(6, 3),
  ]
  let guard_def : @types.GuardDef = { patrol, patrol_index: 0, forward: true }
  let guard_state : @types.GuardState = {
    pos: patrol[0],
    patrol_index: 0,
    forward: true,
    alert: Idle,
    alert_timer: 0.0,
  }
  // Advance forward
  @simulation.advance_guard(guard_def, guard_state)
  inspect(guard_state.patrol_index, content="1")
  inspect(@types.vec2i_eq(guard_state.pos, @types.vec2i(4, 3)), content="true")
  // Advance to end
  @simulation.advance_guard(guard_def, guard_state)
  inspect(guard_state.patrol_index, content="2")
  @simulation.advance_guard(guard_def, guard_state)
  inspect(guard_state.patrol_index, content="3")
  // Should reverse
  @simulation.advance_guard(guard_def, guard_state)
  inspect(guard_state.forward, content="false")
}

///|
test "guard collision kills player" {
  let player : @types.Player = {
    pos: @types.vec2i(5, 3),
    dir: South,
    alive: true,
  }
  let ms : @types.MazeState = {
    door_states: [],
    button_pressed: [],
    guard_states: [
      {
        pos: @types.vec2i(5, 3),
        patrol_index: 0,
        forward: true,
        alert: Idle,
        alert_timer: 0.0,
      },
    ],
    collectibles_collected: [],
  }
  inspect(@simulation.check_guard_collision(player, ms), content="true")
}

///|
test "guard adjacent collision" {
  let player : @types.Player = {
    pos: @types.vec2i(5, 3),
    dir: South,
    alive: true,
  }
  let ms : @types.MazeState = {
    door_states: [],
    button_pressed: [],
    guard_states: [
      {
        pos: @types.vec2i(5, 4),
        patrol_index: 0,
        forward: true,
        alert: Idle,
        alert_timer: 0.0,
      },
    ],
    collectibles_collected: [],
  }
  // Guard is directly south - should detect
  inspect(@simulation.check_guard_collision(player, ms), content="true")
}

///|
test "player reaches exit" {
  let level = @maze.get_level(0, 0).unwrap()
  let maze = @maze.parse_maze(level)
  let player = @types.new_player(maze.exit)
  inspect(@simulation.check_exit(player, maze), content="true")
}

///|
test "collectible pickup" {
  let level = @maze.get_level(0, 6).unwrap() // "The Collector" has collectibles
  let maze = @maze.parse_maze(level)
  let ms = @types.new_maze_state(maze)
  inspect(maze.collectible_positions.length() > 0, content="true")
  // Place player on first collectible
  let player = @types.new_player(maze.collectible_positions[0])
  let count = @simulation.check_collectibles(player, maze, ms)
  inspect(count > 0, content="true")
  inspect(ms.collectibles_collected[0], content="true")
}

///|
test "star calculation" {
  // Complete within par, all collectibles -> 3 stars
  inspect(@simulation.calculate_stars(2, 2, 3, 3), content="3")
  // Complete within par, no collectibles to get -> 3 stars
  inspect(@simulation.calculate_stars(1, 2, 0, 0), content="3")
  // Complete within par, missing collectible -> 2 stars
  inspect(@simulation.calculate_stars(2, 2, 1, 3), content="2")
  // Over par -> 1 star
  inspect(@simulation.calculate_stars(4, 2, 3, 3), content="1")
}

///|
test "timed door cycles" {
  let level = @maze.get_level(1, 0).unwrap() // "Tick Tock" has timed door
  let maze = @maze.parse_maze(level)
  let ms = @types.new_maze_state(maze)
  // Find the timed door id
  let mut timed_id = -1
  let mut duration = 0
  for y in 0..<maze.height {
    for x in 0..<maze.width {
      match maze.tiles[y][x].kind {
        TimedDoor(id, dur) => {
          timed_id = id
          duration = dur
        }
        _ => ()
      }
    }
  }
  guard timed_id >= 0 else { return }
  // At tick 0, should be open (phase 0 < duration)
  @simulation.update_timed_doors(maze, ms, 0)
  inspect(@simulation.is_door_open(ms, timed_id), content="true")
  // At tick = duration, should be closed
  @simulation.update_timed_doors(maze, ms, duration)
  inspect(@simulation.is_door_open(ms, timed_id), content="false")
  // At tick = duration * 2, should be open again (new cycle)
  @simulation.update_timed_doors(maze, ms, duration * 2)
  inspect(@simulation.is_door_open(ms, timed_id), content="true")
}

///|
test "full tick simulation" {
  let level = @maze.get_level(0, 0).unwrap()
  let maze = @maze.parse_maze(level)
  let ms = @types.new_maze_state(maze)
  let player = @types.new_player(maze.start)
  let ghosts : Array[@types.Ghost] = []
  // Run a tick with east movement
  let result = @simulation.run_tick(maze, ms, player, ghosts, 0, Some(East))
  inspect(result is Continue(_), content="true")
}
