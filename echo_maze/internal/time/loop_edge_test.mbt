///|
test "multiple loops create correct ghost chain" {
  let game = @types.new_game()
  let _ = @time.load_level(game, 0, 1) // "One Button"
  // Record first loop
  game.current_recording = [Some(East), Some(East), Some(South)]
  let _ = @time.finish_loop(game)
  inspect(game.ghosts.length(), content="1")
  inspect(game.ghosts[0].color, content="Green")
  // Record second loop
  game.current_recording = [Some(South), Some(South)]
  let _ = @time.finish_loop(game)
  inspect(game.ghosts.length(), content="2")
  inspect(game.ghosts[1].color, content="Yellow")
  // Record third loop
  game.current_recording = [Some(East)]
  let _ = @time.finish_loop(game)
  inspect(game.ghosts.length(), content="3")
  inspect(game.ghosts[2].color, content="Orange")
}

///|
test "undo loop removes in correct order - LIFO" {
  let game = @types.new_game()
  let _ = @time.load_level(game, 0, 1)
  // Create 3 ghosts
  game.current_recording = [Some(East)]
  let _ = @time.finish_loop(game)
  game.current_recording = [Some(South)]
  let _ = @time.finish_loop(game)
  game.current_recording = [Some(West)]
  let _ = @time.finish_loop(game)
  inspect(game.ghosts.length(), content="3")
  // Undo removes last (Orange) first
  let _ = @time.undo_loop(game)
  inspect(game.ghosts.length(), content="2")
  inspect(game.ghosts[1].color, content="Yellow")
  // Undo removes Yellow
  let _ = @time.undo_loop(game)
  inspect(game.ghosts.length(), content="1")
  inspect(game.ghosts[0].color, content="Green")
  // Undo removes Green
  let _ = @time.undo_loop(game)
  inspect(game.ghosts.length(), content="0")
}

///|
test "start_new_loop finishes current recording" {
  let game = @types.new_game()
  let _ = @time.load_level(game, 0, 1)
  // Record some moves
  game.current_recording = [Some(East), Some(East)]
  // Start new loop should save current recording as ghost
  @time.start_new_loop(game)
  inspect(game.ghosts.length(), content="1")
  inspect(game.play_state, content="Recording")
  inspect(game.current_recording.length(), content="0")
}

///|
test "start_new_loop blocked at max ghosts" {
  let game = @types.new_game()
  let _ = @time.load_level(game, 0, 1)
  // Fill up ghost slots
  for _i in 0..<@types.max_ghosts {
    game.current_recording = [Some(East)]
    let _ = @time.finish_loop(game)
  }
  // Try to start new loop - should be blocked
  game.current_recording = [Some(West)]
  @time.start_new_loop(game)
  // Should show message instead of creating ghost
  inspect(game.message.length() > 0, content="true")
}

///|
test "advance_tick records timeline with button and door state" {
  let game = @types.new_game()
  let _ = @time.load_level(game, 0, 1) // "One Button"
  let _ = @time.advance_tick(game, Some(East))
  inspect(game.timeline.length(), content="1")
  let entry = game.timeline[0]
  // Timeline entry should have button and door state arrays
  inspect(entry.buttons_pressed.length() > 0, content="true")
  inspect(entry.doors_open.length() > 0, content="true")
}

///|
test "load_level clears previous state completely" {
  let game = @types.new_game()
  let _ = @time.load_level(game, 0, 0)
  // Dirty up the game state
  game.current_recording = [Some(East), Some(East), Some(East)]
  let _ = @time.finish_loop(game)
  game.tick = 50
  game.timeline.push(
    {
      player_pos: @types.vec2i(0, 0),
      ghost_positions: [],
      guard_positions: [],
      buttons_pressed: [],
      doors_open: [],
    },
  )
  // Load a different level
  let _ = @time.load_level(game, 1, 0)
  inspect(game.ghosts.length(), content="0")
  inspect(game.recordings.length(), content="0")
  inspect(game.timeline.length(), content="0")
  inspect(game.tick, content="0")
  inspect(game.loop_count, content="0")
}

///|
test "complete_current_level with multiple loops scores correctly" {
  let game = @types.new_game()
  let _ = @time.load_level(game, 0, 1) // par_loops = 2
  // Create one ghost (so we're on loop 2)
  game.current_recording = [Some(East)]
  let _ = @time.finish_loop(game)
  // Move player to exit
  let maze = game.maze.unwrap()
  game.player.pos = maze.exit
  @time.complete_current_level(game)
  // loops_used = loop_count(1) + 1 = 2, par = 2, so within par
  inspect(game.result_loops, content="2")
  inspect(game.result_stars >= 2, content="true")
}

///|
test "complete_current_level over par gives 1 star" {
  let game = @types.new_game()
  let _ = @time.load_level(game, 0, 0) // par_loops = 1
  // Create 2 ghosts (over par)
  game.current_recording = [Some(East)]
  let _ = @time.finish_loop(game)
  game.current_recording = [Some(East)]
  let _ = @time.finish_loop(game)
  // Move player to exit
  let maze = game.maze.unwrap()
  game.player.pos = maze.exit
  @time.complete_current_level(game)
  // loops_used = 3, par = 1, over par
  inspect(game.result_stars, content="1")
}

///|
test "all levels can be loaded and reset without error" {
  let game = @types.new_game()
  let levels = @maze.get_all_levels()
  for l in levels {
    let loaded = @time.load_level(game, l.world, l.level)
    inspect(loaded, content="true")
    @time.reset_level(game)
    inspect(game.play_state, content="Recording")
  }
}
