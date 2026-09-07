///|
/// Start recording a new loop for the current level
pub fn start_recording(game : @types.Game) -> Unit {
  game.current_recording = []
  game.tick = 0
  game.play_state = Recording
  let maze = game.maze.unwrap()
  game.player.pos = maze.start
  game.player.dir = South
  game.player.alive = true
  // Reset all ghosts to start position
  for ghost in game.ghosts {
    ghost.pos = maze.start
    ghost.active = true
  }
  // Reset maze state
  game.maze_state = Some(@types.new_maze_state(maze))
}

///|
/// Record a move for the current tick
pub fn record_move(game : @types.Game, dir : @types.Direction?) -> Unit {
  game.current_recording.push(dir)
}

///|
/// Finish the current recording and create a ghost from it
/// Returns true if ghost was created, false if at max
pub fn finish_loop(game : @types.Game) -> Bool {
  if game.ghosts.length() >= @types.max_ghosts {
    return false
  }
  // Save recording
  let rec : @types.Recording = { moves: game.current_recording.copy(), }
  game.recordings.push(rec)
  // Create ghost from recording
  let maze = game.maze.unwrap()
  let color = @types.ghost_color_for_index(game.ghosts.length())
  let ghost = @types.new_ghost(rec.moves, color, maze.start)
  game.ghosts.push(ghost)
  game.loop_count += 1
  true
}

///|
/// Undo the last loop (remove most recent ghost)
pub fn undo_loop(game : @types.Game) -> Bool {
  if game.ghosts.length() == 0 {
    return false
  }
  let _ = game.ghosts.pop()
  let _ = game.recordings.pop()
  game.loop_count -= 1
  true
}

///|
/// Reset the entire level to fresh state
pub fn reset_level(game : @types.Game) -> Unit {
  game.ghosts = []
  game.recordings = []
  game.current_recording = []
  game.tick = 0
  game.loop_count = 0
  game.timeline = []
  let maze = game.maze.unwrap()
  game.player.pos = maze.start
  game.player.dir = South
  game.player.alive = true
  game.maze_state = Some(@types.new_maze_state(maze))
  game.play_state = Recording
}

///|
/// Load a specific level into the game
pub fn load_level(game : @types.Game, world : Int, level : Int) -> Bool {
  match @maze.get_level(world, level) {
    Some(level_def) => {
      let maze = @maze.parse_maze(level_def)
      game.maze = Some(maze)
      game.maze_state = Some(@types.new_maze_state(maze))
      game.current_world = world
      game.current_level = level
      game.max_ticks = @types.max_ticks_per_loop
      reset_level(game)
      @types.set_message(game, level_def.name, 2.0)
      true
    }
    None => false
  }
}

///|
/// Advance simulation by one tick during recording
pub fn advance_tick(
  game : @types.Game,
  move_dir : @types.Direction?,
) -> @simulation.TickResult {
  let maze = game.maze.unwrap()
  let maze_state = game.maze_state.unwrap()
  // Record the move
  record_move(game, move_dir)
  // Run simulation
  let result = @simulation.run_tick(
    maze,
    maze_state,
    game.player,
    game.ghosts,
    game.tick,
    move_dir,
  )
  // Save timeline entry
  let ghost_positions : Array[@types.Vec2i] = []
  for ghost in game.ghosts {
    ghost_positions.push(ghost.pos)
  }
  let guard_positions : Array[@types.Vec2i] = []
  for gs in maze_state.guard_states {
    guard_positions.push(gs.pos)
  }
  let buttons_pressed : Array[Bool] = maze_state.button_pressed.copy()
  let doors_open : Array[Bool] = []
  for ds in maze_state.door_states {
    doors_open.push(ds.open)
  }
  game.timeline.push({
    player_pos: game.player.pos,
    ghost_positions,
    guard_positions,
    buttons_pressed,
    doors_open,
  })
  game.tick += 1
  result
}

///|
/// Enter review/planning mode
pub fn enter_planning(game : @types.Game) -> Unit {
  game.play_state = Reviewing
  game.planning_tick = 0
}

///|
/// Start a new recording loop from planning mode
pub fn start_new_loop(game : @types.Game) -> Unit {
  if game.ghosts.length() >= @types.max_ghosts {
    @types.set_message(game, "Max ghosts reached!", 1.5)
    return
  }
  // Finish current recording as a ghost
  if game.current_recording.length() > 0 {
    let _ = finish_loop(game)
  }
  // Start fresh recording
  start_recording(game)
}

///|
/// Complete the level with results
pub fn complete_current_level(game : @types.Game) -> Unit {
  let maze = game.maze.unwrap()
  let maze_state = game.maze_state.unwrap()
  let loops_used = game.loop_count + 1 // Current loop counts
  let collectibles_got = @simulation.count_collectibles(maze_state)
  let collectibles_total = maze.collectible_positions.length()
  // Get par from level def
  let par = match @maze.get_level(game.current_world, game.current_level) {
    Some(ld) => ld.par_loops
    None => 3
  }
  let stars = @simulation.calculate_stars(
    loops_used, par, collectibles_got, collectibles_total,
  )
  // Update score
  if game.current_world < game.level_scores.length() &&
    game.current_level < game.level_scores[game.current_world].length() {
    let score = game.level_scores[game.current_world][game.current_level]
    score.completed = true
    if loops_used < score.best_loops {
      score.best_loops = loops_used
    }
    if stars > score.stars {
      score.stars = stars
    }
    score.collectibles_got = @types.maxi(
      score.collectibles_got,
      collectibles_got,
    )
    score.collectibles_total = collectibles_total
  }
  // Set result data
  game.result_loops = loops_used
  game.result_stars = stars
  game.result_collectibles = collectibles_got
  game.result_total_collectibles = collectibles_total
  game.play_state = Complete
  game.screen = Results
}
