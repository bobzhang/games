///|
test "manhattan_dist basic cases" {
  inspect(
    @types.manhattan_dist(@types.vec2i(0, 0), @types.vec2i(0, 0)),
    content="0",
  )
  inspect(
    @types.manhattan_dist(@types.vec2i(0, 0), @types.vec2i(1, 0)),
    content="1",
  )
  inspect(
    @types.manhattan_dist(@types.vec2i(0, 0), @types.vec2i(0, 1)),
    content="1",
  )
  inspect(
    @types.manhattan_dist(@types.vec2i(0, 0), @types.vec2i(3, 4)),
    content="7",
  )
  inspect(
    @types.manhattan_dist(@types.vec2i(5, 5), @types.vec2i(2, 1)),
    content="7",
  )
}

///|
test "manhattan_dist negative coordinates" {
  inspect(
    @types.manhattan_dist(@types.vec2i(-1, -1), @types.vec2i(1, 1)),
    content="4",
  )
  inspect(
    @types.manhattan_dist(@types.vec2i(3, 0), @types.vec2i(0, 3)),
    content="6",
  )
}

///|
test "new_game has new fields initialized" {
  let game = @types.new_game()
  inspect(game.restart_flash_timer == 0.0, content="true")
  inspect(game.ghost_button_feedback.length(), content="0")
  inspect(game.planning_paused, content="false")
  inspect(game.loop_transition_timer == 0.0, content="true")
}

///|
test "new_ghost has trail_positions initialized" {
  let start = @types.vec2i(3, 4)
  let ghost = @types.new_ghost([], Green, start)
  inspect(ghost.trail_positions.length(), content="1")
  inspect(@types.vec2i_eq(ghost.trail_positions[0], start), content="true")
}

///|
test "new_maze_state door states have animation fields" {
  let level = @maze.get_level(0, 1).unwrap()
  let maze = @maze.parse_maze(level)
  let ms = @types.new_maze_state(maze)
  for ds in ms.door_states {
    inspect(ds.anim_progress == 0.0, content="true")
    inspect(ds.prev_open, content="false")
  }
}

///|
test "new_maze_state guard states have alert fields" {
  let level = @maze.get_level(1, 1).unwrap() // "On Patrol" has guards
  let maze = @maze.parse_maze(level)
  let ms = @types.new_maze_state(maze)
  for gs in ms.guard_states {
    inspect(gs.alert, content="Idle")
    inspect(gs.alert_timer == 0.0, content="true")
  }
}

///|
test "update_door_animations opens smoothly" {
  let ms : @types.MazeState = {
    door_states: [
      { door_id: 0, open: true, timer: 0, anim_progress: 0.0, prev_open: false },
    ],
    button_pressed: [],
    guard_states: [],
    collectibles_collected: [],
  }
  // First update should increase anim_progress
  @types.update_door_animations(ms, 0.05)
  inspect(ms.door_states[0].anim_progress > 0.0, content="true")
  inspect(ms.door_states[0].anim_progress < 1.0, content="true")
}

///|
test "update_door_animations closes smoothly" {
  let ms : @types.MazeState = {
    door_states: [
      { door_id: 0, open: false, timer: 0, anim_progress: 1.0, prev_open: true },
    ],
    button_pressed: [],
    guard_states: [],
    collectibles_collected: [],
  }
  // Should decrease from 1.0 toward 0.0
  @types.update_door_animations(ms, 0.05)
  inspect(ms.door_states[0].anim_progress < 1.0, content="true")
  inspect(ms.door_states[0].anim_progress > 0.0, content="true")
}

///|
test "lerpf interpolation" {
  inspect(@types.lerpf(0.0, 10.0, 0.0) == 0.0, content="true")
  inspect(@types.lerpf(0.0, 10.0, 1.0) == 10.0, content="true")
  inspect(@types.lerpf(0.0, 10.0, 0.5) == 5.0, content="true")
}

///|
test "guard alert state enum values" {
  let idle : @types.GuardAlertState = Idle
  let alert : @types.GuardAlertState = Alert
  let chasing : @types.GuardAlertState = Chasing
  inspect(idle, content="Idle")
  inspect(alert, content="Alert")
  inspect(chasing, content="Chasing")
  inspect(idle == idle, content="true")
  inspect(idle == alert, content="false")
}
