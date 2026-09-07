///|
/// Load and parse a maze from level definition for testing/validation
pub fn load_maze(world : Int, level : Int) -> (@types.Maze, @types.MazeState)? {
  match @maze.get_level(world, level) {
    Some(level_def) => {
      let maze = @maze.parse_maze(level_def)
      let state = @types.new_maze_state(maze)
      Some((maze, state))
    }
    None => None
  }
}

///|
/// Check whether a position is walkable (not a wall, not a closed door)
pub fn is_walkable(
  maze : @types.Maze,
  maze_state : @types.MazeState,
  pos : @types.Vec2i,
) -> Bool {
  if !@types.in_bounds(pos, maze.width, maze.height) {
    return false
  }
  let tile = maze.tiles[pos.y][pos.x]
  match tile.kind {
    Wall => false
    Door(id) => is_door_open(maze_state, id)
    TimedDoor(id, _) => is_door_open(maze_state, id)
    _ => true
  }
}

///|
/// Check if a specific door is open
pub fn is_door_open(maze_state : @types.MazeState, door_id : Int) -> Bool {
  for ds in maze_state.door_states {
    if ds.door_id == door_id {
      return ds.open
    }
  }
  false
}

///|
/// Move player in given direction if walkable, recording the move
pub fn try_move_player(
  maze : @types.Maze,
  maze_state : @types.MazeState,
  player : @types.Player,
  dir : @types.Direction,
) -> Bool {
  let delta = @types.dir_to_delta(dir)
  let new_pos = @types.vec2i_add(player.pos, delta)
  player.dir = dir
  if is_walkable(maze, maze_state, new_pos) {
    player.pos = new_pos
    return true
  }
  false
}

///|
/// Advance a ghost by one tick using its recorded moves
pub fn advance_ghost(
  ghost : @types.Ghost,
  maze : @types.Maze,
  maze_state : @types.MazeState,
  tick : Int,
) -> Unit {
  if !ghost.active {
    return
  }
  if tick >= ghost.recording.length() {
    return
  }
  match ghost.recording[tick] {
    Some(dir) => {
      let delta = @types.dir_to_delta(dir)
      let new_pos = @types.vec2i_add(ghost.pos, delta)
      if is_walkable(maze, maze_state, new_pos) {
        ghost.pos = new_pos
      }
    }
    None => () // Ghost stood still this tick
  }
  // Record trail position
  ghost.trail_positions.push(ghost.pos)
  // Keep trail manageable (max 200 entries)
  if ghost.trail_positions.length() > 200 {
    let _ = ghost.trail_positions.remove(0)
  }
}

///|
/// Update all button states based on player and ghost positions
pub fn update_buttons(
  maze : @types.Maze,
  maze_state : @types.MazeState,
  player : @types.Player,
  ghosts : Array[@types.Ghost],
) -> Unit {
  // Reset all button pressed states
  for i in 0..<maze_state.button_pressed.length() {
    maze_state.button_pressed[i] = false
  }
  // Check each tile for button occupancy
  for y in 0..<maze.height {
    for x in 0..<maze.width {
      match maze.tiles[y][x].kind {
        Button(btn_id) => {
          let pos = @types.vec2i(x, y)
          // Check if player is on button
          if @types.vec2i_eq(player.pos, pos) && player.alive {
            mark_button_pressed(maze_state, btn_id)
          }
          // Check if any active ghost is on button
          for ghost in ghosts {
            if ghost.active && @types.vec2i_eq(ghost.pos, pos) {
              mark_button_pressed(maze_state, btn_id)
            }
          }
        }
        _ => ()
      }
    }
  }
}

///|
fn mark_button_pressed(maze_state : @types.MazeState, btn_id : Int) -> Unit {
  if btn_id < maze_state.button_pressed.length() {
    maze_state.button_pressed[btn_id] = true
  }
}

///|
/// Update door states based on button press state and button links
pub fn update_doors(maze : @types.Maze, maze_state : @types.MazeState) -> Unit {
  // First close all non-timed doors
  for ds in maze_state.door_states {
    // Check if this door is timed
    let mut is_timed = false
    for y in 0..<maze.height {
      for x in 0..<maze.width {
        match maze.tiles[y][x].kind {
          TimedDoor(id, _) => if id == ds.door_id { is_timed = true }
          _ => ()
        }
      }
    }
    if !is_timed {
      ds.open = false
    }
  }
  // Open doors linked to pressed buttons
  for link in maze.button_links {
    if link.button_id < maze_state.button_pressed.length() &&
      maze_state.button_pressed[link.button_id] {
      set_door_open(maze_state, link.door_id, true)
    }
  }
}

///|
/// Update timed doors - they cycle open/closed on their own
pub fn update_timed_doors(
  maze : @types.Maze,
  maze_state : @types.MazeState,
  tick : Int,
) -> Unit {
  for y in 0..<maze.height {
    for x in 0..<maze.width {
      match maze.tiles[y][x].kind {
        TimedDoor(id, duration) => {
          // Cycle: open for `duration` ticks, closed for `duration` ticks
          let cycle = duration * 2
          let phase = tick % cycle
          let should_open = phase < duration
          set_door_open(maze_state, id, should_open)
        }
        _ => ()
      }
    }
  }
}

///|
fn set_door_open(
  maze_state : @types.MazeState,
  door_id : Int,
  open : Bool,
) -> Unit {
  for ds in maze_state.door_states {
    if ds.door_id == door_id {
      ds.open = open
      return
    }
  }
}

///|
/// Advance guards along their patrol paths
pub fn update_guards(maze_state : @types.MazeState) -> Unit {
  for _gs in maze_state.guard_states {
    // Guard patrol is handled at the Game level via guard_defs
    // Here we just track state
    ()
  }
  ignore(maze_state)
}

///|
/// Advance a single guard along its patrol path
pub fn advance_guard(
  guard_def : @types.GuardDef,
  guard_state : @types.GuardState,
) -> Unit {
  let patrol = guard_def.patrol
  if patrol.length() <= 1 {
    return
  }
  if guard_state.forward {
    guard_state.patrol_index += 1
    if guard_state.patrol_index >= patrol.length() {
      guard_state.patrol_index = patrol.length() - 2
      guard_state.forward = false
    }
  } else {
    guard_state.patrol_index -= 1
    if guard_state.patrol_index < 0 {
      guard_state.patrol_index = 1
      guard_state.forward = true
    }
  }
  let idx = @types.clampi(guard_state.patrol_index, 0, patrol.length() - 1)
  guard_state.pos = patrol[idx]
}

///|
/// Check if player collides with any guard (caught!)
/// Also updates guard alert states based on proximity
pub fn check_guard_collision(
  player : @types.Player,
  maze_state : @types.MazeState,
) -> Bool {
  if !player.alive {
    return false
  }
  let mut caught = false
  for gs in maze_state.guard_states {
    let dist = @types.manhattan_dist(player.pos, gs.pos)
    if @types.vec2i_eq(player.pos, gs.pos) {
      gs.alert = Chasing
      gs.alert_timer = 2.0
      caught = true
    } else {
      // Adjacent check (1-tile detection range, cardinal only)
      let dx = player.pos.x - gs.pos.x
      let dy = player.pos.y - gs.pos.y
      if dx >= -1 &&
        dx <= 1 &&
        dy >= -1 &&
        dy <= 1 &&
        (dx != 0 || dy != 0) &&
        (dx == 0 || dy == 0) {
        gs.alert = Chasing
        gs.alert_timer = 2.0
        caught = true
      } else if dist <= 3 {
        // Near detection range - alert state
        gs.alert = Alert
        gs.alert_timer = 1.0
        // Decay alert
      } else if gs.alert_timer <= 0.0 {
        gs.alert = Idle
      }
    }
  }
  caught
}

///|
/// Check if ghost collides with guard (ghost gets deactivated)
pub fn check_ghost_guard_collision(
  ghosts : Array[@types.Ghost],
  maze_state : @types.MazeState,
) -> Unit {
  for ghost in ghosts {
    if !ghost.active {
      continue
    }
    for gs in maze_state.guard_states {
      if @types.vec2i_eq(ghost.pos, gs.pos) {
        ghost.active = false
      }
    }
  }
}

///|
/// Check if player reached the exit
pub fn check_exit(player : @types.Player, maze : @types.Maze) -> Bool {
  player.alive && @types.vec2i_eq(player.pos, maze.exit)
}

///|
/// Collect any collectible at player position
pub fn check_collectibles(
  player : @types.Player,
  maze : @types.Maze,
  maze_state : @types.MazeState,
) -> Int {
  let mut collected = 0
  for i in 0..<maze.collectible_positions.length() {
    if !maze_state.collectibles_collected[i] &&
      @types.vec2i_eq(player.pos, maze.collectible_positions[i]) {
      maze_state.collectibles_collected[i] = true
      collected += 1
    }
  }
  collected
}

///|
/// Run a full simulation tick
pub fn run_tick(
  maze : @types.Maze,
  maze_state : @types.MazeState,
  player : @types.Player,
  ghosts : Array[@types.Ghost],
  tick : Int,
  move_dir : @types.Direction?,
) -> TickResult {
  // 1. Move player
  match move_dir {
    Some(dir) => {
      let _ = try_move_player(maze, maze_state, player, dir)
    }
    None => ()
  }
  // 2. Replay ghosts
  for ghost in ghosts {
    advance_ghost(ghost, maze, maze_state, tick)
  }
  // 3. Advance guards
  for i in 0..<maze.guard_defs.length() {
    if i < maze_state.guard_states.length() {
      advance_guard(maze.guard_defs[i], maze_state.guard_states[i])
    }
  }
  // 4. Update buttons
  update_buttons(maze, maze_state, player, ghosts)
  // 5. Update doors (button-linked)
  update_doors(maze, maze_state)
  // 6. Update timed doors
  update_timed_doors(maze, maze_state, tick)
  // 7. Check collectibles
  let collected = check_collectibles(player, maze, maze_state)
  // 8. Check guard collision with ghosts
  check_ghost_guard_collision(ghosts, maze_state)
  // 9. Check guard collision with player
  if check_guard_collision(player, maze_state) {
    player.alive = false
    return Failed
  }
  // 10. Check exit
  if check_exit(player, maze) {
    return Completed(collected)
  }
  Continue(collected)
}

///|
pub(all) enum TickResult {
  Continue(Int) // collected count this tick
  Completed(Int) // level complete, collected count
  Failed // player caught
} derive(Debug, Eq)

///|
pub extend TickResult with Debug::{to_repr}

///|
pub extend TickResult with Eq::{not_equal, equal}

///|
pub impl Show for TickResult with fn output(self, logger) {
  Show::output(Debug::to_repr(self), logger)
}

///|
pub extend TickResult with Show::{to_string, output}

///|
/// Count total collectibles obtained
pub fn count_collectibles(maze_state : @types.MazeState) -> Int {
  let mut count = 0
  for c in maze_state.collectibles_collected {
    if c {
      count += 1
    }
  }
  count
}

///|
/// Detect which ghosts are pressing which buttons this tick
pub fn detect_ghost_button_presses(
  maze : @types.Maze,
  ghosts : Array[@types.Ghost],
) -> Array[(Int, Int)] {
  let result : Array[(Int, Int)] = [] // (ghost_index, button_id)
  for y in 0..<maze.height {
    for x in 0..<maze.width {
      match maze.tiles[y][x].kind {
        Button(btn_id) => {
          let pos = @types.vec2i(x, y)
          for gi, ghost in ghosts {
            if ghost.active && @types.vec2i_eq(ghost.pos, pos) {
              result.push((gi, btn_id))
            }
          }
        }
        _ => ()
      }
    }
  }
  result
}

///|
/// Preview ghost collision with guards at a given tick
/// Returns array of (ghost_index, guard_index) collision pairs
pub fn preview_ghost_guard_collisions(
  ghosts : Array[@types.Ghost],
  maze_state : @types.MazeState,
) -> Array[(Int, Int)] {
  let collisions : Array[(Int, Int)] = []
  for gi, ghost in ghosts {
    if !ghost.active {
      continue
    }
    for gsi, gs in maze_state.guard_states {
      if @types.vec2i_eq(ghost.pos, gs.pos) {
        collisions.push((gi, gsi))
      }
    }
  }
  collisions
}

///|
/// Update guard alert timers (called per frame with dt)
pub fn update_guard_alert_timers(
  maze_state : @types.MazeState,
  dt : Float,
) -> Unit {
  for gs in maze_state.guard_states {
    if gs.alert_timer > 0.0 {
      gs.alert_timer -= dt
    }
    if gs.alert_timer <= 0.0 && gs.alert is (Alert | Chasing) {
      gs.alert = Idle
    }
  }
}

///|
/// Validate that a maze is structurally sound for gameplay
pub fn validate_level_structure(
  maze : @types.Maze,
  level_def : @types.LevelDef,
) -> Array[String] {
  let errors : Array[String] = []
  // Check start tile is actually Start
  if maze.start.y < maze.height && maze.start.x < maze.width {
    match maze.tiles[maze.start.y][maze.start.x].kind {
      Start => ()
      _ => errors.push("Start position is not a Start tile")
    }
  } else {
    errors.push("Start position out of bounds")
  }
  // Check exit tile is actually Exit
  if maze.exit.y < maze.height && maze.exit.x < maze.width {
    match maze.tiles[maze.exit.y][maze.exit.x].kind {
      Exit => ()
      _ => errors.push("Exit position is not an Exit tile")
    }
  } else {
    errors.push("Exit position out of bounds")
  }
  // Validate button links: each button_id should have a corresponding tile
  for link in level_def.button_links {
    let mut found_button = false
    let mut found_door = false
    for y in 0..<maze.height {
      for x in 0..<maze.width {
        match maze.tiles[y][x].kind {
          Button(id) => if id == link.button_id { found_button = true }
          Door(id) | TimedDoor(id, _) =>
            if id == link.door_id {
              found_door = true
            }
          _ => ()
        }
      }
    }
    if !found_button {
      errors.push(
        "Button link references non-existent button \{link.button_id}",
      )
    }
    if !found_door {
      errors.push("Button link references non-existent door \{link.door_id}")
    }
  }
  // Validate guard patrols: all positions should be on floor tiles
  for pi, patrol in level_def.guard_patrols {
    if patrol.length() < 2 {
      errors.push("Guard patrol \{pi} has fewer than 2 waypoints")
    }
    for wi, waypoint in patrol {
      if waypoint.y >= maze.height ||
        waypoint.x >= maze.width ||
        waypoint.y < 0 ||
        waypoint.x < 0 {
        errors.push(
          "Guard patrol \{pi} waypoint \{wi} is out of bounds: (\{waypoint.x}, \{waypoint.y})",
        )
      } else {
        let kind = maze.tiles[waypoint.y][waypoint.x].kind
        match kind {
          Wall =>
            errors.push(
              "Guard patrol \{pi} waypoint \{wi} is on a wall: (\{waypoint.x}, \{waypoint.y})",
            )
          _ => ()
        }
      }
    }
  }
  // Validate par is achievable (par >= 1)
  if level_def.par_loops < 1 {
    errors.push("Par loops is less than 1")
  }
  errors
}

///|
/// Calculate star rating for a completed level
pub fn calculate_stars(
  loop_count : Int,
  par_loops : Int,
  collectibles_got : Int,
  collectibles_total : Int,
) -> Int {
  let mut stars = 1 // 1 star for completing
  // 2 stars if completed within par
  if loop_count <= par_loops {
    stars = 2
  }
  // 3 stars if within par AND all collectibles
  if loop_count <= par_loops &&
    (collectibles_total == 0 || collectibles_got >= collectibles_total) {
    stars = 3
  }
  stars
}
