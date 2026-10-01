///|
test "new_heddle_row creates all-false row" {
  let h = @types.new_heddle_row(8)
  for i in 0..<8 {
    assert_eq(h.raised[i], false)
  }
}

///|
test "new_fabric_pattern dimensions" {
  let p = @types.new_fabric_pattern(12, 8, [0], [0])
  assert_eq(p.rows, 12)
  assert_eq(p.cols, 8)
  assert_eq(p.cells.length(), 96)
}

///|
test "pattern_get and pattern_set" {
  let p = @types.new_fabric_pattern(4, 4, [0], [0])
  let cell : @types.FabricCell = { state: WarpOver, color_index: 2, }
  @types.pattern_set(p, 1, 2, cell)
  let got = @types.pattern_get(p, 1, 2)
  assert_eq(got.state, WarpOver)
  assert_eq(got.color_index, 2)
}

///|
test "build_player_fabric basic" {
  let game = @types.new_game()
  // Set first row: raise every other warp
  let h = game.heddles[0]
  for col in 0..<@types.grid_cols {
    h.raised[col] = col % 2 == 0
  }
  let fabric = @types.build_player_fabric(game)
  // Col 0 should be WarpOver
  let c0 = @types.pattern_get(fabric, 0, 0)
  assert_eq(c0.state, WarpOver)
  // Col 1 should be WeftOver
  let c1 = @types.pattern_get(fabric, 0, 1)
  assert_eq(c1.state, WeftOver)
}

///|
test "count_matches perfect" {
  let p1 = @types.new_fabric_pattern(2, 2, [0], [0])
  let p2 = @types.new_fabric_pattern(2, 2, [0], [0])
  // Both default to same state
  assert_eq(@types.count_matches(p1, p2), 4)
}

///|
test "count_matches partial" {
  let p1 = @types.new_fabric_pattern(2, 2, [0], [0])
  let p2 = @types.new_fabric_pattern(2, 2, [0], [0])
  @types.pattern_set(p1, 0, 0, { state: WarpOver, color_index: 0, })
  // p2[0,0] is still default WeftOver
  let matches = @types.count_matches(p1, p2)
  assert_eq(matches, 3)
}

///|
test "patterns_match true" {
  let p1 = @types.new_fabric_pattern(2, 2, [0], [0])
  let p2 = @types.new_fabric_pattern(2, 2, [0], [0])
  assert_true(@types.patterns_match(p1, p2))
}

///|
test "patterns_match false" {
  let p1 = @types.new_fabric_pattern(2, 2, [0], [0])
  let p2 = @types.new_fabric_pattern(2, 2, [0], [0])
  @types.pattern_set(p1, 0, 0, { state: WarpOver, color_index: 1, })
  assert_true(!@types.patterns_match(p1, p2))
}

///|
test "tier_name" {
  assert_eq(@types.tier_name(Apprentice), "Apprentice")
  assert_eq(@types.tier_name(Journeyman), "Journeyman")
  assert_eq(@types.tier_name(Master), "Master")
}

///|
test "tier_levels" {
  let (s1, c1) = @types.tier_levels(Apprentice)
  assert_eq(s1, 0)
  assert_eq(c1, @types.tier1_count)
  let (s2, c2) = @types.tier_levels(Journeyman)
  assert_eq(s2, @types.tier1_count)
  assert_eq(c2, @types.tier2_count)
  let (s3, c3) = @types.tier_levels(Master)
  assert_eq(s3, @types.tier1_count + @types.tier2_count)
  assert_eq(c3, @types.tier3_count)
}

///|
test "weave_type_name" {
  assert_eq(@types.weave_type_name(Plain), "Plain")
  assert_eq(@types.weave_type_name(Twill), "Twill")
  assert_eq(@types.weave_type_name(Herringbone), "Herringbone")
  assert_eq(@types.weave_type_name(Diamond), "Diamond")
  assert_eq(@types.weave_type_name(Satin), "Satin")
  assert_eq(@types.weave_type_name(Custom), "Custom")
}

///|
test "cell_color valid indices" {
  for i in 0..<4 {
    let c = @types.cell_color(i)
    // Verify it returns the expected color by checking it's not the default gray
    assert_true(c.r.to_int() != 128 || c.g.to_int() != 128)
  }
}

///|
test "cell_color invalid index" {
  let c = @types.cell_color(99)
  assert_eq(c.r.to_int(), 128)
  assert_eq(c.g.to_int(), 128)
  assert_eq(c.b.to_int(), 128)
}

///|
test "mini and maxi" {
  assert_eq(@types.mini(3, 5), 3)
  assert_eq(@types.mini(7, 2), 2)
  assert_eq(@types.maxi(3, 5), 5)
  assert_eq(@types.maxi(7, 2), 7)
}

///|
test "absf and absi" {
  assert_true(@types.absf(-3.5) == 3.5)
  assert_true(@types.absf(2.0) == 2.0)
  assert_eq(@types.absi(-5), 5)
  assert_eq(@types.absi(3), 3)
}

///|
test "new_game initializes correctly" {
  let game = @types.new_game()
  assert_eq(game.screen, Title)
  assert_eq(game.play_state, Weaving)
  assert_eq(game.current_level, 0)
  assert_eq(game.heddles.length(), @types.grid_rows)
  assert_eq(game.level_scores.length(), @types.total_levels)
  assert_eq(game.heddle_changes, 0)
  assert_eq(game.selected_row, 0)
}

///|
test "new_level_score defaults" {
  let score = @types.new_level_score()
  assert_eq(score.stars, 0)
  assert_eq(score.completed, false)
  assert_eq(score.best_changes, 999)
}

///|
test "set_message" {
  let game = @types.new_game()
  @types.set_message(game, "Test", 2.0)
  assert_eq(game.message, "Test")
  assert_true(game.message_timer == 2.0)
}
