///|
test "get_level_returns_correct_id" {
  for i in 0..<20 {
    let level = get_level(i)
    assert_eq(level.id, i)
  }
}

///|
test "all_levels_have_depth_profile_length_8" {
  for i in 0..<20 {
    let level = get_level(i)
    assert_eq(level.depth_profile.length(), 8)
  }
}

///|
test "all_levels_have_matching_counts" {
  for i in 0..<20 {
    let level = get_level(i)
    assert_eq(level.available_organisms.length(), level.organism_counts.length())
  }
}

///|
test "all_levels_have_target_species" {
  for i in 0..<20 {
    let level = get_level(i)
    assert_true(level.target_species.length() > 0)
  }
}

///|
test "target_species_are_available" {
  for i in 0..<20 {
    let level = get_level(i)
    for j in 0..<level.target_species.length() {
      let target = level.target_species[j]
      let mut found = false
      for k in 0..<level.available_organisms.length() {
        if level.available_organisms[k] == target {
          found = true
          break
        }
      }
      assert_true(found)
    }
  }
}

///|
test "get_tier_for_level" {
  assert_eq(get_tier_for_level(0), Shallow)
  assert_eq(get_tier_for_level(6), Shallow)
  assert_eq(get_tier_for_level(7), Middle)
  assert_eq(get_tier_for_level(13), Middle)
  assert_eq(get_tier_for_level(14), Deep)
  assert_eq(get_tier_for_level(19), Deep)
}

///|
test "setup_level_places_rocks" {
  let game = @types.new_game()
  setup_level(game, 4)
  match game.current_level {
    Some(level) => {
      for i in 0..<level.rock_cells.length() {
        let (r, c) = level.rock_cells[i]
        assert_eq(game.grid[r][c], Rock)
      }
    }
    None => fail("Level should be set")
  }
}

///|
test "setup_level_resets_state" {
  let game = @types.new_game()
  game.current_turn = 5
  game.current_cycle = 2
  setup_level(game, 0)
  assert_eq(game.current_turn, 0)
  assert_eq(game.current_cycle, 0)
  assert_eq(game.tide_level, 1)
  assert_eq(game.tide_phase, Low)
}

///|
test "tier1_levels_are_shallow" {
  for i in 0..<7 {
    let level = get_level(i)
    assert_eq(level.tier, Shallow)
  }
}

///|
test "tier2_levels_are_middle" {
  for i in 7..<14 {
    let level = get_level(i)
    assert_eq(level.tier, Middle)
  }
}

///|
test "tier3_levels_are_deep" {
  for i in 14..<20 {
    let level = get_level(i)
    assert_eq(level.tier, Deep)
  }
}

///|
test "depth_profiles_have_valid_values" {
  for i in 0..<20 {
    let level = get_level(i)
    for j in 0..<level.depth_profile.length() {
      let d = level.depth_profile[j]
      assert_true(d >= 0 && d <= 4)
    }
  }
}

///|
test "rock_cells_are_in_grid" {
  for i in 0..<20 {
    let level = get_level(i)
    for j in 0..<level.rock_cells.length() {
      let (r, c) = level.rock_cells[j]
      assert_true(@types.in_grid(r, c))
    }
  }
}
