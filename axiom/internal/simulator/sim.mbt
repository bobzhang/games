///|
fn eval_condition(
  cond : @types.Condition,
  robot : @types.Robot,
  level : @types.Level
) -> Bool {
  match cond {
    PathAhead => {
      let delta = @types.dir_delta(robot.dir)
      let nx = robot.pos.x + delta.x
      let ny = robot.pos.y + delta.y
      if !@types.grid_in_bounds(level.grid, nx, ny) {
        return false
      }
      let tile = @types.grid_get(level.grid, nx, ny)
      @types.is_tile_walkable(tile) &&
        !@types.has_block_at(level.blocks, nx, ny)
    }
    WallAhead => {
      let delta = @types.dir_delta(robot.dir)
      let nx = robot.pos.x + delta.x
      let ny = robot.pos.y + delta.y
      if !@types.grid_in_bounds(level.grid, nx, ny) {
        return true
      }
      let tile = @types.grid_get(level.grid, nx, ny)
      @types.is_tile_solid(tile) || @types.has_block_at(level.blocks, nx, ny)
    }
    AtGoal => {
      for i in 0..<level.goals.length() {
        if @types.vec2i_eq(level.goals[i], robot.pos) && !level.goals_collected[i] {
          return true
        }
      }
      false
    }
    OnColor(color) => {
      let tile = @types.grid_get(level.grid, robot.pos.x, robot.pos.y)
      match tile {
        ColorTile(c) => c == color
        _ => false
      }
    }
  }
}

///|
fn try_collect_goals(
  robot : @types.Robot,
  goals : Array[@types.Vec2i],
  collected : Array[Bool]
) -> Unit {
  for i in 0..<goals.length() {
    if !collected[i] && @types.vec2i_eq(goals[i], robot.pos) {
      collected[i] = true
    }
  }
}

///|
fn expand_program(
  commands : Array[@types.Command]
) -> Array[@types.CommandKind] {
  let expanded : Array[@types.CommandKind] = []
  let mut i = 0
  while i < commands.length() {
    match commands[i].kind {
      Loop(n) => {
        // Collect the commands following the Loop that it applies to
        // Loop repeats the next command n times
        if i + 1 < commands.length() {
          for _rep in 0..<n {
            expanded.push(commands[i + 1].kind)
          }
          i += 2
        } else {
          // No command after loop - skip
          i += 1
        }
      }
      other => {
        expanded.push(other)
        i += 1
      }
    }
  }
  expanded
}

///|
pub fn simulate(
  program : @types.Program,
  level : @types.Level
) -> @types.ExecutionTrace {
  let robot = @types.clone_robot(level.robot)
  let goals_collected = @types.clone_goals_collected(level.goals_collected)
  let blocks = @types.clone_blocks(level.blocks)
  let states : Array[@types.RobotState] = []
  // Record initial state
  states.push(
    @types.make_robot_state(robot, goals_collected, blocks, -1),
  )
  let expanded = expand_program(program.commands)
  if expanded.length() == 0 {
    return {
      states,
      success: false,
      fail_reason: "Empty program",
    }
  }
  let mut step = 0
  let mut cmd_idx = 0
  let mut skip_next = false
  while cmd_idx < expanded.length() && step < @types.max_steps {
    let kind = expanded[cmd_idx]
    if skip_next {
      skip_next = false
      cmd_idx += 1
      continue
    }
    match kind {
      If(cond) => {
        let result = eval_condition(cond, robot, level)
        if !result {
          // Skip the next command
          skip_next = true
        }
        cmd_idx += 1
        // Record state (If itself doesn't change position)
        states.push(
          @types.make_robot_state(robot, goals_collected, blocks, cmd_idx - 1),
        )
        step += 1
        continue
      }
      Move => {
        let delta = @types.dir_delta(robot.dir)
        let nx = robot.pos.x + delta.x
        let ny = robot.pos.y + delta.y
        if !@types.grid_in_bounds(level.grid, nx, ny) {
          robot.alive = false
          states.push(
            @types.make_robot_state(robot, goals_collected, blocks, cmd_idx),
          )
          return {
            states,
            success: false,
            fail_reason: "Robot walked out of bounds!",
          }
        }
        let tile = @types.grid_get(level.grid, nx, ny)
        if @types.is_tile_solid(tile) {
          robot.alive = false
          states.push(
            @types.make_robot_state(robot, goals_collected, blocks, cmd_idx),
          )
          return {
            states,
            success: false,
            fail_reason: "Robot walked into a wall!",
          }
        }
        if @types.has_block_at(blocks, nx, ny) {
          robot.alive = false
          states.push(
            @types.make_robot_state(robot, goals_collected, blocks, cmd_idx),
          )
          return {
            states,
            success: false,
            fail_reason: "Robot walked into a block!",
          }
        }
        if @types.is_tile_gap(tile) {
          robot.pos = @types.vec2i(nx, ny)
          robot.alive = false
          states.push(
            @types.make_robot_state(robot, goals_collected, blocks, cmd_idx),
          )
          return {
            states,
            success: false,
            fail_reason: "Robot fell into a gap!",
          }
        }
        robot.pos = @types.vec2i(nx, ny)
        try_collect_goals(robot, level.goals, goals_collected)
      }
      TurnLeft => robot.dir = @types.turn_left(robot.dir)
      TurnRight => robot.dir = @types.turn_right(robot.dir)
      Jump => {
        let delta = @types.dir_delta(robot.dir)
        // Jump over one tile, land two tiles ahead
        let over_x = robot.pos.x + delta.x
        let over_y = robot.pos.y + delta.y
        let land_x = robot.pos.x + delta.x * 2
        let land_y = robot.pos.y + delta.y * 2
        if !@types.grid_in_bounds(level.grid, land_x, land_y) {
          robot.alive = false
          states.push(
            @types.make_robot_state(robot, goals_collected, blocks, cmd_idx),
          )
          return {
            states,
            success: false,
            fail_reason: "Robot jumped out of bounds!",
          }
        }
        let land_tile = @types.grid_get(level.grid, land_x, land_y)
        if @types.is_tile_solid(land_tile) {
          robot.alive = false
          states.push(
            @types.make_robot_state(robot, goals_collected, blocks, cmd_idx),
          )
          return {
            states,
            success: false,
            fail_reason: "Robot jumped into a wall!",
          }
        }
        if @types.has_block_at(blocks, land_x, land_y) {
          robot.alive = false
          states.push(
            @types.make_robot_state(robot, goals_collected, blocks, cmd_idx),
          )
          return {
            states,
            success: false,
            fail_reason: "Robot jumped onto a block!",
          }
        }
        if @types.is_tile_gap(land_tile) {
          // Can jump over gap and land on gap -> fall
          // Unless the over tile is the gap and land is fine
          // Actually jump is meant to jump OVER one tile
          // Check if over tile is gap or wall - that's fine, we jump over it
          // But landing on a gap = fall
          robot.pos = @types.vec2i(land_x, land_y)
          robot.alive = false
          states.push(
            @types.make_robot_state(robot, goals_collected, blocks, cmd_idx),
          )
          return {
            states,
            success: false,
            fail_reason: "Robot landed in a gap!",
          }
        }
        // Successful jump: ignore what's in the middle (over_x, over_y)
        let _ = over_x
        let _ = over_y
        robot.pos = @types.vec2i(land_x, land_y)
        try_collect_goals(robot, level.goals, goals_collected)
      }
      Push => {
        let delta = @types.dir_delta(robot.dir)
        let bx = robot.pos.x + delta.x
        let by = robot.pos.y + delta.y
        let block_idx = @types.find_block_index(blocks, bx, by)
        if block_idx < 0 {
          robot.alive = false
          states.push(
            @types.make_robot_state(robot, goals_collected, blocks, cmd_idx),
          )
          return {
            states,
            success: false,
            fail_reason: "Nothing to push!",
          }
        }
        let push_x = bx + delta.x
        let push_y = by + delta.y
        if !@types.grid_in_bounds(level.grid, push_x, push_y) {
          robot.alive = false
          states.push(
            @types.make_robot_state(robot, goals_collected, blocks, cmd_idx),
          )
          return {
            states,
            success: false,
            fail_reason: "Can't push block out of bounds!",
          }
        }
        let push_tile = @types.grid_get(level.grid, push_x, push_y)
        if @types.is_tile_solid(push_tile) ||
          @types.has_block_at(blocks, push_x, push_y) {
          robot.alive = false
          states.push(
            @types.make_robot_state(robot, goals_collected, blocks, cmd_idx),
          )
          return {
            states,
            success: false,
            fail_reason: "Can't push block there!",
          }
        }
        // Push block (it might fall into a gap - that's OK, block disappears)
        if @types.is_tile_gap(push_tile) {
          // Block falls into gap, filling it - change gap to floor
          @types.grid_set(level.grid, push_x, push_y, Floor)
          // Remove block
          blocks.remove(block_idx) |> ignore
        } else {
          // Move block
          blocks[block_idx] = @types.vec2i(push_x, push_y)
        }
      }
      Loop(_) =>
        // Loops should have been expanded
        ()
    }
    states.push(
      @types.make_robot_state(robot, goals_collected, blocks, cmd_idx),
    )
    cmd_idx += 1
    step += 1
  }
  if step >= @types.max_steps {
    return {
      states,
      success: false,
      fail_reason: "Program took too many steps (timeout)!",
    }
  }
  let success = @types.all_goals_collected(goals_collected)
  let fail_reason = if success {
    ""
  } else {
    "Not all goals collected!"
  }
  { states, success, fail_reason }
}
