///|
test "start_recording resets state" {
  let game = @types.new_game()
  let _ = @time.load_level(game, 0, 0)
  // Record some moves
  game.current_recording = [Some(East), Some(East)]
  game.tick = 5
  @time.start_recording(game)
  inspect(game.current_recording.length(), content="0")
  inspect(game.tick, content="0")
  inspect(game.play_state, content="Recording")
}

///|
test "finish_loop creates ghost" {
  let game = @types.new_game()
  let _ = @time.load_level(game, 0, 0)
  game.current_recording = [Some(East), Some(East), Some(East)]
  let created = @time.finish_loop(game)
  inspect(created, content="true")
  inspect(game.ghosts.length(), content="1")
  inspect(game.recordings.length(), content="1")
  inspect(game.loop_count, content="1")
}

///|
test "finish_loop respects max ghosts" {
  let game = @types.new_game()
  let _ = @time.load_level(game, 0, 0)
  // Create max ghosts
  for _i in 0..<@types.max_ghosts {
    game.current_recording = [Some(East)]
    let _ = @time.finish_loop(game)

  }
  inspect(game.ghosts.length(), content="3")
  // Try to create one more
  game.current_recording = [Some(East)]
  let created = @time.finish_loop(game)
  inspect(created, content="false")
  inspect(game.ghosts.length(), content="3")
}

///|
test "undo_loop removes ghost" {
  let game = @types.new_game()
  let _ = @time.load_level(game, 0, 0)
  game.current_recording = [Some(East)]
  let _ = @time.finish_loop(game)
  inspect(game.ghosts.length(), content="1")
  let undone = @time.undo_loop(game)
  inspect(undone, content="true")
  inspect(game.ghosts.length(), content="0")
}

///|
test "undo_loop on empty returns false" {
  let game = @types.new_game()
  let _ = @time.load_level(game, 0, 0)
  let undone = @time.undo_loop(game)
  inspect(undone, content="false")
}

///|
test "reset_level clears all state" {
  let game = @types.new_game()
  let _ = @time.load_level(game, 0, 0)
  game.current_recording = [Some(East), Some(East)]
  let _ = @time.finish_loop(game)
  game.tick = 10
  @time.reset_level(game)
  inspect(game.ghosts.length(), content="0")
  inspect(game.recordings.length(), content="0")
  inspect(game.tick, content="0")
  inspect(game.loop_count, content="0")
  inspect(game.play_state, content="Recording")
}

///|
test "load_level sets maze" {
  let game = @types.new_game()
  let loaded = @time.load_level(game, 0, 0)
  inspect(loaded, content="true")
  inspect(game.maze is Some(_), content="true")
  inspect(game.maze_state is Some(_), content="true")
  inspect(game.current_world, content="0")
  inspect(game.current_level, content="0")
}

///|
test "load_level fails for invalid level" {
  let game = @types.new_game()
  let loaded = @time.load_level(game, 99, 99)
  inspect(loaded, content="false")
}

///|
test "advance_tick records and simulates" {
  let game = @types.new_game()
  let _ = @time.load_level(game, 0, 0)
  let start_tick = game.tick
  let result = @time.advance_tick(game, Some(East))
  inspect(game.tick == start_tick + 1, content="true")
  inspect(game.current_recording.length(), content="1")
  inspect(game.timeline.length(), content="1")
  inspect(result is Continue(_), content="true")
}

///|
test "complete_current_level updates scores" {
  let game = @types.new_game()
  let _ = @time.load_level(game, 0, 0)
  // Move player to exit
  let maze = game.maze.unwrap()
  game.player.pos = maze.exit
  @time.complete_current_level(game)
  inspect(game.screen, content="Results")
  inspect(game.level_scores[0][0].completed, content="true")
}

///|
test "enter_planning sets reviewing state" {
  let game = @types.new_game()
  let _ = @time.load_level(game, 0, 0)
  @time.enter_planning(game)
  inspect(game.play_state, content="Reviewing")
  inspect(game.planning_tick, content="0")
}
