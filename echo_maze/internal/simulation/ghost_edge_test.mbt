///|
test "ghost with empty recording stays in place" {
  let level = @maze.get_level(0, 0).unwrap()
  let maze = @maze.parse_maze(level)
  let ms = @types.new_maze_state(maze)
  let recording : Array[@types.Direction?] = []
  let ghost = @types.new_ghost(recording, Green, maze.start)
  let start_pos = ghost.pos
  // Advancing beyond recording length should not crash or move
  @simulation.advance_ghost(ghost, maze, ms, 0)
  inspect(@types.vec2i_eq(ghost.pos, start_pos), content="true")
  @simulation.advance_ghost(ghost, maze, ms, 5)
  inspect(@types.vec2i_eq(ghost.pos, start_pos), content="true")
}

///|
test "ghost with all None moves stays in place" {
  let level = @maze.get_level(0, 0).unwrap()
  let maze = @maze.parse_maze(level)
  let ms = @types.new_maze_state(maze)
  let recording : Array[@types.Direction?] = [None, None, None, None, None]
  let ghost = @types.new_ghost(recording, Yellow, maze.start)
  let start_pos = ghost.pos
  for tick in 0..<5 {
    @simulation.advance_ghost(ghost, maze, ms, tick)
  }
  inspect(@types.vec2i_eq(ghost.pos, start_pos), content="true")
}

///|
test "ghost blocked by wall records trail but stays" {
  let level = @maze.get_level(0, 0).unwrap()
  let maze = @maze.parse_maze(level)
  let ms = @types.new_maze_state(maze)
  // Start is (1,1), North leads to wall at (1,0)
  let recording : Array[@types.Direction?] = [Some(North), Some(North)]
  let ghost = @types.new_ghost(recording, Green, maze.start)
  @simulation.advance_ghost(ghost, maze, ms, 0)
  // Ghost should not have moved (wall)
  inspect(@types.vec2i_eq(ghost.pos, maze.start), content="true")
  // But trail should have recorded position
  inspect(ghost.trail_positions.length() > 1, content="true")
}

///|
test "ghost deactivated by guard stops moving" {
  let level = @maze.get_level(1, 1).unwrap() // "On Patrol" has guards
  let maze = @maze.parse_maze(level)
  let ms = @types.new_maze_state(maze)
  // Create a ghost at the guard's position to get deactivated
  let guard_pos = ms.guard_states[0].pos
  let recording : Array[@types.Direction?] = [Some(East), Some(East)]
  let ghost = @types.new_ghost(recording, Green, guard_pos)
  // Check collision deactivates ghost
  let ghosts : Array[@types.Ghost] = [ghost]
  @simulation.check_ghost_guard_collision(ghosts, ms)
  inspect(ghost.active, content="false")
  // Advancing deactivated ghost should be no-op
  let pos_before = ghost.pos
  @simulation.advance_ghost(ghost, maze, ms, 0)
  inspect(@types.vec2i_eq(ghost.pos, pos_before), content="true")
}

///|
test "ghost recording past max ticks is ignored" {
  let level = @maze.get_level(0, 0).unwrap()
  let maze = @maze.parse_maze(level)
  let ms = @types.new_maze_state(maze)
  let recording : Array[@types.Direction?] = [Some(East), Some(East)]
  let ghost = @types.new_ghost(recording, Orange, maze.start)
  // Tick beyond recording length
  @simulation.advance_ghost(ghost, maze, ms, 100)
  // Should stay where it was (start position)
  inspect(@types.vec2i_eq(ghost.pos, maze.start), content="true")
}

///|
test "ghost trail accumulates positions" {
  let level = @maze.get_level(0, 0).unwrap()
  let maze = @maze.parse_maze(level)
  let ms = @types.new_maze_state(maze)
  let recording : Array[@types.Direction?] = [
    Some(East),
    Some(East),
    Some(East),
  ]
  let ghost = @types.new_ghost(recording, Green, maze.start)
  // Initial trail has start position
  inspect(ghost.trail_positions.length(), content="1")
  for tick in 0..<3 {
    @simulation.advance_ghost(ghost, maze, ms, tick)
  }
  // Trail should have start + 3 moves = 4 positions
  inspect(ghost.trail_positions.length(), content="4")
}

///|
test "multiple ghosts can press same button" {
  let level = @maze.get_level(0, 1).unwrap() // "One Button"
  let maze = @maze.parse_maze(level)
  let ms = @types.new_maze_state(maze)
  // Find button position
  let mut btn_pos = @types.vec2i(0, 0)
  for y in 0..<maze.height {
    for x in 0..<maze.width {
      if maze.tiles[y][x].kind is Button(0) {
        btn_pos = @types.vec2i(x, y)
      }
    }
  }
  let player = @types.new_player(maze.start)
  let g1 = @types.new_ghost([], Green, btn_pos)
  let g2 = @types.new_ghost([], Yellow, btn_pos)
  let ghosts : Array[@types.Ghost] = [g1, g2]
  @simulation.update_buttons(maze, ms, player, ghosts)
  inspect(ms.button_pressed[0], content="true")
}

///|
test "ghost button press detection" {
  let level = @maze.get_level(0, 1).unwrap()
  let maze = @maze.parse_maze(level)
  // Find button position
  let mut btn_pos = @types.vec2i(0, 0)
  for y in 0..<maze.height {
    for x in 0..<maze.width {
      if maze.tiles[y][x].kind is Button(0) {
        btn_pos = @types.vec2i(x, y)
      }
    }
  }
  let g1 = @types.new_ghost([], Green, btn_pos)
  let ghosts : Array[@types.Ghost] = [g1]
  let presses = @simulation.detect_ghost_button_presses(maze, ghosts)
  inspect(presses.length(), content="1")
  inspect(presses[0].0, content="0") // ghost index 0
  inspect(presses[0].1, content="0") // button id 0
}

///|
test "ghost-guard collision preview" {
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
  let ghost = @types.new_ghost([], Green, @types.vec2i(5, 3))
  let ghosts : Array[@types.Ghost] = [ghost]
  let collisions = @simulation.preview_ghost_guard_collisions(ghosts, ms)
  inspect(collisions.length(), content="1")
  inspect(collisions[0].0, content="0") // ghost 0
  inspect(collisions[0].1, content="0") // guard 0
}

///|
test "guard alert state transitions" {
  let player : @types.Player = {
    pos: @types.vec2i(5, 3),
    dir: South,
    alive: true,
  }
  let gs : @types.GuardState = {
    pos: @types.vec2i(8, 3),
    patrol_index: 0,
    forward: true,
    alert: Idle,
    alert_timer: 0.0,
  }
  let ms : @types.MazeState = {
    door_states: [],
    button_pressed: [],
    guard_states: [gs],
    collectibles_collected: [],
  }
  // Player is 3 tiles away - should trigger alert
  let caught = @simulation.check_guard_collision(player, ms)
  inspect(caught, content="false")
  inspect(gs.alert, content="Alert")
}

///|
test "guard alert timer decays" {
  let gs : @types.GuardState = {
    pos: @types.vec2i(5, 3),
    patrol_index: 0,
    forward: true,
    alert: Alert,
    alert_timer: 0.5,
  }
  let ms : @types.MazeState = {
    door_states: [],
    button_pressed: [],
    guard_states: [gs],
    collectibles_collected: [],
  }
  @simulation.update_guard_alert_timers(ms, 0.6)
  inspect(gs.alert, content="Idle")
}

///|
test "validate_level_structure catches bad button link" {
  let bad_level : @types.LevelDef = {
    world: 0,
    level: 0,
    ascii: "#####\n#S.X#\n#####",
    button_links: [{ button_id: 99, door_id: 99 }],
    guard_patrols: [],
    timed_door_durations: [],
    par_loops: 1,
    name: "Bad Level",
  }
  let maze = @maze.parse_maze(bad_level)
  let errors = @simulation.validate_level_structure(maze, bad_level)
  inspect(errors.length() > 0, content="true")
}

///|
test "validate_level_structure catches bad guard patrol" {
  let bad_level : @types.LevelDef = {
    world: 0,
    level: 0,
    ascii: "#####\n#S.X#\n#####",
    button_links: [],
    guard_patrols: [[@types.vec2i(0, 0)]],
    timed_door_durations: [],
    par_loops: 1,
    name: "Bad Patrol",
  }
  let maze = @maze.parse_maze(bad_level)
  let errors = @simulation.validate_level_structure(maze, bad_level)
  // Should catch: patrol < 2 waypoints AND waypoint on wall
  inspect(errors.length() >= 2, content="true")
}

///|
test "door animation progress updates correctly" {
  let ms : @types.MazeState = {
    door_states: [
      { door_id: 0, open: true, timer: 0, anim_progress: 0.0, prev_open: false },
    ],
    button_pressed: [],
    guard_states: [],
    collectibles_collected: [],
  }
  // Open door - progress should increase
  @types.update_door_animations(ms, 0.1)
  inspect(ms.door_states[0].anim_progress > 0.0, content="true")
  // Keep updating until fully open
  for _i in 0..<20 {
    @types.update_door_animations(ms, 0.1)
  }
  inspect(ms.door_states[0].anim_progress == 1.0, content="true")
  // Now close door
  ms.door_states[0].open = false
  for _i in 0..<20 {
    @types.update_door_animations(ms, 0.1)
  }
  inspect(ms.door_states[0].anim_progress == 0.0, content="true")
}

///|
test "manhattan distance calculation" {
  inspect(
    @types.manhattan_dist(@types.vec2i(0, 0), @types.vec2i(3, 4)),
    content="7",
  )
  inspect(
    @types.manhattan_dist(@types.vec2i(5, 5), @types.vec2i(5, 5)),
    content="0",
  )
  inspect(
    @types.manhattan_dist(@types.vec2i(1, 1), @types.vec2i(4, 5)),
    content="7",
  )
}

///|
test "is_walkable blocks closed doors" {
  let level = @maze.get_level(0, 1).unwrap() // "One Button" has a door
  let maze = @maze.parse_maze(level)
  let ms = @types.new_maze_state(maze)
  // Find door position
  let mut door_pos = @types.vec2i(0, 0)
  for y in 0..<maze.height {
    for x in 0..<maze.width {
      if maze.tiles[y][x].kind is Door(_) {
        door_pos = @types.vec2i(x, y)
      }
    }
  }
  // Door should be closed (not walkable)
  inspect(@simulation.is_walkable(maze, ms, door_pos), content="false")
  // Open the door
  ms.door_states[0].open = true
  inspect(@simulation.is_walkable(maze, ms, door_pos), content="true")
}
