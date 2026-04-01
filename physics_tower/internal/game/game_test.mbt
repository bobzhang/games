///|
test "combo detection: wood+steel flex" {
  let world = @types.new_world()
  let _id0 = @physics.add_body(world, Block, Wood, 500.0, 790.0, 0.0)
  let _id1 = @physics.add_body(world, Beam, Steel, 500.0, 740.0, 0.0)
  @physics.auto_join(world, 1)
  let combos = @game.check_combos(world)
  inspect(combos.length() > 0, content="true")
  // Should detect FlexCombo
  let mut found_flex = false
  for c in combos {
    match c.kind {
      FlexCombo => found_flex = true
      _ => ()
    }
  }
  inspect(found_flex, content="true")
}

///|
test "combo detection: stone+stone monolith" {
  let world = @types.new_world()
  let _id0 = @physics.add_body(world, Block, Stone, 500.0, 790.0, 0.0)
  let _id1 = @physics.add_body(world, Block, Stone, 500.0, 730.0, 0.0)
  @physics.auto_join(world, 1)
  let combos = @game.check_combos(world)
  let mut found_mono = false
  for c in combos {
    match c.kind {
      MonolithCombo => found_mono = true
      _ => ()
    }
  }
  inspect(found_mono, content="true")
}

///|
test "combo detection: steel+steel reinforced" {
  let world = @types.new_world()
  let _id0 = @physics.add_body(world, Beam, Steel, 500.0, 790.0, 0.0)
  let _id1 = @physics.add_body(world, Beam, Steel, 500.0, 770.0, 0.0)
  @physics.auto_join(world, 1)
  let combos = @game.check_combos(world)
  let mut found_reinforced = false
  for c in combos {
    match c.kind {
      ReinforcedCombo => found_reinforced = true
      _ => ()
    }
  }
  inspect(found_reinforced, content="true")
}

///|
test "combo detection: wood+wood lightweight" {
  let world = @types.new_world()
  let _id0 = @physics.add_body(world, Block, Wood, 500.0, 790.0, 0.0)
  let _id1 = @physics.add_body(world, Block, Wood, 500.0, 730.0, 0.0)
  @physics.auto_join(world, 1)
  let combos = @game.check_combos(world)
  let mut found_light = false
  for c in combos {
    match c.kind {
      LightweightCombo => found_light = true
      _ => ()
    }
  }
  inspect(found_light, content="true")
}

///|
test "combo detection: no combo for different non-adjacent materials" {
  let world = @types.new_world()
  // Place bodies far apart so they don't auto-join
  let _id0 = @physics.add_body(world, Block, Wood, 200.0, 790.0, 0.0)
  let _id1 = @physics.add_body(world, Block, Stone, 800.0, 790.0, 0.0)
  // Don't auto-join (they're far apart)
  let combos = @game.check_combos(world)
  // No joints = no combos
  inspect(combos.length(), content="0")
}

///|
test "combo count function" {
  let combos : Array[@types.ActiveCombo] = [
    { kind: FlexCombo, body_a_id: 0, body_b_id: 1, bonus_value: 1.5 },
    { kind: FlexCombo, body_a_id: 2, body_b_id: 3, bonus_value: 1.5 },
    { kind: MonolithCombo, body_a_id: 4, body_b_id: 5, bonus_value: 1.3 },
    { kind: ReinforcedCombo, body_a_id: 6, body_b_id: 7, bonus_value: 0.8 },
  ]
  let (flex, mono, rein, light) = @game.count_combos(combos)
  inspect(flex, content="2")
  inspect(mono, content="1")
  inspect(rein, content="1")
  inspect(light, content="0")
}

///|
test "combo name returns non-empty string" {
  inspect(@game.combo_name(FlexCombo).length() > 0, content="true")
  inspect(@game.combo_name(MonolithCombo).length() > 0, content="true")
  inspect(@game.combo_name(ReinforcedCombo).length() > 0, content="true")
  inspect(@game.combo_name(LightweightCombo).length() > 0, content="true")
}

///|
test "combo color returns valid RGB" {
  let (r, g, b) = @game.combo_color(FlexCombo)
  inspect(r >= 0 && r <= 255, content="true")
  inspect(g >= 0 && g <= 255, content="true")
  inspect(b >= 0 && b <= 255, content="true")
}

///|
test "tutorial state initializes correctly" {
  let tut = @types.new_tutorial_state()
  inspect(tut.step, content="0")
  inspect(tut.completed, content="false")
  inspect(tut.message, content="")
}

///|
test "tutorial should show on level 0" {
  let game = @types.new_game()
  game.current_level = 0
  game.tutorial_shown = false
  inspect(@game.should_show_tutorial(game), content="true")
}

///|
test "tutorial should not show when already shown" {
  let game = @types.new_game()
  game.current_level = 0
  game.tutorial_shown = true
  inspect(@game.should_show_tutorial(game), content="false")
}

///|
test "tutorial should not show on level 2" {
  let game = @types.new_game()
  game.current_level = 2
  game.tutorial_shown = false
  inspect(@game.should_show_tutorial(game), content="false")
}

///|
test "tutorial total is 3 steps" {
  inspect(@game.tutorial_total(), content="3")
}

///|
test "statistics initialization" {
  let stats = @types.new_statistics(20)
  inspect(stats.total_builds, content="0")
  inspect(stats.total_breaks, content="0")
  inspect(stats.levels_completed, content="0")
  inspect(stats.stars_earned, content="0")
  inspect(stats.best_heights.length(), content="20")
  inspect(stats.level_stars.length(), content="20")
  inspect(stats.materials_used.length(), content="3")
}

///|
test "record piece placed updates stats" {
  let game = @types.new_game()
  inspect(game.statistics.total_pieces_placed, content="0")
  @game.record_piece_placed(game, Wood)
  inspect(game.statistics.total_pieces_placed, content="1")
  @game.record_piece_placed(game, Stone)
  inspect(game.statistics.total_pieces_placed, content="2")
  // Material counts
  let (wood, stone, steel) = @game.material_usage(game)
  inspect(wood, content="1")
  inspect(stone, content="1")
  inspect(steel, content="0")
}

///|
test "record build increments counters" {
  let game = @types.new_game()
  @game.record_build(game)
  inspect(game.statistics.total_builds, content="1")
  inspect(game.statistics.total_tests_run, content="1")
  @game.record_build(game)
  inspect(game.statistics.total_builds, content="2")
}

///|
test "record level result updates best height and stars" {
  let game = @types.new_game()
  @game.record_level_result(game, 0, 300.0, 2, true)
  inspect(@game.best_height_for_level(game, 0) > 299.0, content="true")
  inspect(@game.stars_for_level(game, 0), content="2")
  // Higher stars should replace
  @game.record_level_result(game, 0, 350.0, 3, true)
  inspect(@game.stars_for_level(game, 0), content="3")
  // Lower stars should not replace
  @game.record_level_result(game, 0, 200.0, 1, true)
  inspect(@game.stars_for_level(game, 0), content="3")
}

///|
test "completion percentage" {
  let game = @types.new_game()
  inspect(@game.completion_percentage(game), content="0")
  // Complete one level
  @game.record_level_result(game, 0, 300.0, 2, true)
  // 1 of 20 = 5%
  inspect(@game.completion_percentage(game), content="5")
}

///|
test "stats summary returns lines" {
  let game = @types.new_game()
  let lines = @game.stats_summary(game)
  inspect(lines.length() > 5, content="true")
}

///|
test "replay state initialization" {
  let replay = @types.new_replay_state()
  inspect(replay.actions.length(), content="0")
  inspect(replay.is_recording, content="false")
  inspect(replay.is_playing, content="false")
  inspect(replay.ghost_visible, content="false")
}

///|
test "replay recording and playback" {
  let game = @types.new_game()
  // Start recording
  @game.start_recording(game)
  inspect(game.replay.is_recording, content="true")
  // Record some actions
  @game.record_place(game, Block, Wood, 500.0, 700.0, 0.0)
  @game.record_place(game, Block, Stone, 500.0, 640.0, 0.0)
  @game.record_rotate(game, 0)
  inspect(game.replay.actions.length(), content="3")
  // Stop recording
  @game.stop_recording(game, 200.0, 500, true)
  inspect(game.replay.is_recording, content="false")
  inspect(game.replay.test_height > 199.0, content="true")
  inspect(game.replay.test_passed, content="true")
}

///|
test "replay has_replay check" {
  let game = @types.new_game()
  inspect(@game.has_replay(game), content="false")
  @game.start_recording(game)
  @game.record_place(game, Block, Wood, 500.0, 700.0, 0.0)
  @game.stop_recording(game, 100.0, 200, false)
  inspect(@game.has_replay(game), content="true")
}

///|
test "replay action count" {
  let game = @types.new_game()
  @game.start_recording(game)
  @game.record_place(game, Block, Wood, 500.0, 700.0, 0.0)
  @game.record_place(game, Beam, Steel, 500.0, 600.0, 0.0)
  inspect(@game.replay_action_count(game), content="2")
}

///|
test "replay progress calculation" {
  let game = @types.new_game()
  // No actions = 100%
  inspect(@game.playback_progress(game), content="100")
  @game.start_recording(game)
  @game.record_place(game, Block, Wood, 500.0, 700.0, 0.0)
  @game.record_place(game, Block, Wood, 500.0, 640.0, 0.0)
  @game.stop_recording(game, 100.0, 200, false)
  // Not playing yet, index is 0
  inspect(@game.playback_progress(game), content="0")
}

///|
test "ghost tower save and visibility" {
  let game = @types.new_game()
  // No ghost initially
  inspect(@game.ghost_visible(game), content="false")
  // Add some bodies to the world
  let _id = @physics.add_body(game.world, Block, Wood, 500.0, 700.0, 0.0)
  // Save ghost
  @game.save_ghost_tower(game)
  inspect(@game.ghost_visible(game), content="true")
  let pieces = @game.ghost_pieces(game)
  inspect(pieces.length(), content="1")
  // Toggle off
  @game.toggle_ghost(game)
  inspect(@game.ghost_visible(game), content="false")
  // Toggle on
  @game.toggle_ghost(game)
  inspect(@game.ghost_visible(game), content="true")
  // Clear
  @game.clear_ghost_tower(game)
  inspect(@game.ghost_visible(game), content="false")
}

///|
test "sound queue push and clear" {
  let game = @types.new_game()
  inspect(game.sound_queue.length(), content="0")
  @game.push_sound(game, PlacePiece)
  @game.push_sound(game, RotatePiece)
  inspect(game.sound_queue.length(), content="2")
  inspect(@game.has_sound_event(game, PlacePiece), content="true")
  inspect(@game.has_sound_event(game, StartTest), content="false")
  @game.clear_sound_queue(game)
  inspect(game.sound_queue.length(), content="0")
}

///|
test "sound event counting" {
  let game = @types.new_game()
  @game.push_sound(game, BodyBreak)
  @game.push_sound(game, BodyBreak)
  @game.push_sound(game, JointBreak)
  inspect(@game.count_sound_events(game, BodyBreak), content="2")
  inspect(@game.count_sound_events(game, JointBreak), content="1")
  inspect(@game.count_sound_events(game, WindStart), content="0")
}

///|
test "sound event name is non-empty" {
  inspect(@game.sound_event_name(PlacePiece).length() > 0, content="true")
  inspect(@game.sound_event_name(LevelComplete).length() > 0, content="true")
}

///|
test "sound event priority ordering" {
  // LevelComplete should be highest priority
  let lc_prio = @game.sound_event_priority(LevelComplete)
  let pp_prio = @game.sound_event_priority(PlacePiece)
  inspect(lc_prio > pp_prio, content="true")
}

///|
test "filter sound queue limits events" {
  let game = @types.new_game()
  @game.push_sound(game, PlacePiece)
  @game.push_sound(game, BodyBreak)
  @game.push_sound(game, LevelComplete)
  @game.push_sound(game, JointBreak)
  let filtered = @game.filter_sound_queue(game, 2)
  inspect(filtered.length(), content="2")
  // The two highest priority events should be included
  // LevelComplete (10) and BodyBreak (7)
}

///|
test "replay result summary" {
  let game = @types.new_game()
  @game.start_recording(game)
  @game.record_place(game, Block, Wood, 500.0, 700.0, 0.0)
  @game.stop_recording(game, 250.0, 600, true)
  let summary = @game.replay_result_summary(game)
  inspect(summary.length() > 0, content="true")
}

///|
test "replay playback speed adjustment" {
  let game = @types.new_game()
  @game.set_playback_speed(game, 2.0)
  inspect(game.replay.playback_speed > 1.9, content="true")
  // Clamp to max
  @game.set_playback_speed(game, 10.0)
  inspect(game.replay.playback_speed < 4.1, content="true")
  // Clamp to min
  @game.set_playback_speed(game, 0.01)
  inspect(game.replay.playback_speed > 0.2, content="true")
}

///|
test "world stars calculation" {
  let game = @types.new_game()
  // No stars initially
  inspect(@game.world_stars(game, 0), content="0")
  // Earn stars on levels 0 and 1
  @game.record_level_result(game, 0, 300.0, 3, true)
  @game.record_level_result(game, 1, 280.0, 2, true)
  inspect(@game.world_stars(game, 0), content="5")
  inspect(@game.world_max_stars(0), content="21") // 7 levels * 3 stars
}

///|
test "world_max_stars for each world" {
  // World 0: 7 levels = 21 max stars
  inspect(@game.world_max_stars(0), content="21")
  // World 1: 7 levels = 21 max stars
  inspect(@game.world_max_stars(1), content="21")
  // World 2: 6 levels = 18 max stars
  inspect(@game.world_max_stars(2), content="18")
}

///|
test "update_game_combos clears and recalculates" {
  let game = @types.new_game()
  // Add some fake combos
  game.active_combos.push({
    kind: FlexCombo,
    body_a_id: 0,
    body_b_id: 1,
    bonus_value: 1.5,
  })
  inspect(game.active_combos.length(), content="1")
  // Update with empty world
  @game.update_game_combos(game)
  inspect(game.active_combos.length(), content="0")
}

///|
test "combo description returns non-empty" {
  inspect(@game.combo_description(FlexCombo).length() > 0, content="true")
  inspect(@game.combo_description(MonolithCombo).length() > 0, content="true")
}

///|
test "record_challenge_complete increments counter" {
  let game = @types.new_game()
  inspect(game.statistics.challenges_completed, content="0")
  @game.record_challenge_complete(game)
  inspect(game.statistics.challenges_completed, content="1")
}

///|
test "total_stars function" {
  let game = @types.new_game()
  inspect(@game.total_stars(game), content="0")
  @game.record_level_result(game, 0, 300.0, 2, true)
  inspect(@game.total_stars(game), content="2")
  @game.record_level_result(game, 1, 350.0, 3, true)
  inspect(@game.total_stars(game), content="5")
}
