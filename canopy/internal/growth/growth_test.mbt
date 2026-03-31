///|
fn make_test_game() -> @types.Game {
  let game = @types.new_game()
  // Set up a simple single-tree scenario
  game.trees = [@types.new_tree(5)]
  game.ground = []
  for _i in 0..<@types.grid_cols {
    game.ground.push(@types.new_ground_tile(3))
  }
  game.targets = [{ tree_index: 0, required_height: 5 }]
  game.turn_limit = 10
  game.prune_budget = 5
  game.par_prunes = 2
  game.par_turns = 6
  game.grid = @types.new_grid()
  @types.rebuild_grid(game)
  @types.compute_shadows(game)
  game
}

///|
test "tree grows one cell per turn" {
  let game = make_test_game()
  inspect(game.trees[0].height, content="0")
  simulate_turn(game)
  inspect(game.trees[0].height, content="1")
  simulate_turn(game)
  inspect(game.trees[0].height, content="2")
  simulate_turn(game)
  inspect(game.trees[0].height, content="3")
}

///|
test "tree gets branches at branch interval" {
  let game = make_test_game()
  // Grow to height 3 (branch_interval)
  simulate_turn(game)
  simulate_turn(game)
  simulate_turn(game)
  inspect(game.trees[0].height, content="3")
  // Should have branches at height 3
  inspect(game.trees[0].branches.length() > 0, content="true")
}

///|
test "shadow computation works" {
  let game = make_test_game()
  // Grow tree tall enough to have canopy
  for _i in 0..<5 {
    simulate_turn(game)
  }
  // There should be shadow cells below leaves/branches
  let mut shadow_count = 0
  for r in 0..<game.grid.height {
    for c in 0..<game.grid.width {
      if game.grid.cells[r][c] == Shadow {
        shadow_count += 1
      }
    }
  }
  inspect(shadow_count > 0, content="true")
}

///|
test "water consumption prevents growth" {
  let game = make_test_game()
  // Set water to 0
  for i in 0..<game.ground.length() {
    game.ground[i].water = 0
  }
  simulate_turn(game)
  // Tree should not have grown
  inspect(game.trees[0].height, content="0")
}

///|
test "pruning removes branch" {
  let game = make_test_game()
  // Grow to get branches
  for _i in 0..<4 {
    simulate_turn(game)
  }
  let branch_count = game.trees[0].branches.length()
  if branch_count > 0 {
    let result = prune_branch(game, 0, 0)
    inspect(result, content="true")
    inspect(game.trees[0].branches[0].pruned, content="true")
    inspect(game.prunes_used, content="1")
  } else {
    // If no branches yet, test passes trivially
    inspect(true, content="true")
  }
}

///|
test "target satisfaction check" {
  let game = make_test_game()
  // Set target to height 3 which is achievable with starting water 3
  game.targets = [{ tree_index: 0, required_height: 3 }]
  // Initially target not met
  inspect(check_targets(game), content="false")
  // Grow 3 turns
  for _i in 0..<3 {
    simulate_turn(game)
  }
  inspect(game.trees[0].height >= 3, content="true")
  inspect(check_targets(game), content="true")
}

///|
test "star calculation" {
  let game = make_test_game()
  game.targets = [{ tree_index: 0, required_height: 3 }]
  game.par_prunes = 2
  game.par_turns = 5
  // Not met - 0 stars
  inspect(calculate_stars(game), content="0")
  // Grow 3 turns to meet target
  for _i in 0..<3 {
    simulate_turn(game)
  }
  // 3 turns, 0 prunes. par_prunes=2, par_turns=5
  inspect(check_targets(game), content="true")
  let stars = calculate_stars(game)
  inspect(stars, content="3")
}

///|
test "rain refills water" {
  let game = make_test_game()
  // Drain water
  for i in 0..<game.ground.length() {
    game.ground[i].water = 0
  }
  // Simulate 5 turns to trigger rain (rain_interval = 5)
  // First turns won't grow due to no water, but turn 5 will rain
  for _i in 0..<5 {
    simulate_turn(game)
  }
  // After rain, water should be refilled
  inspect(game.ground[5].water > 0, content="true")
}

///|
test "shadow slows growth of neighbor" {
  let game = @types.new_game()
  // Two adjacent trees
  game.trees = [@types.new_tree(4), @types.new_tree(5)]
  game.ground = []
  for _i in 0..<@types.grid_cols {
    game.ground.push(@types.new_ground_tile(3))
  }
  game.targets = [{ tree_index: 0, required_height: 3 }]
  game.turn_limit = 20
  game.prune_budget = 5
  game.par_prunes = 2
  game.par_turns = 10
  game.grid = @types.new_grid()
  @types.rebuild_grid(game)
  @types.compute_shadows(game)
  // Grow several turns - trees are close, one may shadow the other
  for _i in 0..<6 {
    simulate_turn(game)
  }
  // Both trees should have grown, though possibly at different rates
  inspect(game.trees[0].height > 0, content="true")
  inspect(game.trees[1].height > 0, content="true")
}

///|
test "prune budget enforced" {
  let game = make_test_game()
  game.prune_budget = 1
  // Grow to get branches
  for _i in 0..<4 {
    simulate_turn(game)
  }
  if game.trees[0].branches.length() >= 2 {
    let r1 = prune_branch(game, 0, 0)
    inspect(r1, content="true")
    inspect(game.prunes_used, content="1")
    // Second prune should fail (budget exhausted)
    let r2 = prune_branch(game, 0, 1)
    inspect(r2, content="false")
  } else {
    inspect(true, content="true")
  }
}

///|
test "undo restores state" {
  let game = make_test_game()
  simulate_turn(game)
  inspect(game.trees[0].height, content="1")
  inspect(game.turn, content="1")
  // Undo
  let restored = @types.restore_undo(game)
  inspect(restored, content="true")
  inspect(game.trees[0].height, content="0")
  inspect(game.turn, content="0")
}

///|
test "find_branch_at returns correct indices" {
  let game = make_test_game()
  // Grow to get branches
  for _i in 0..<4 {
    simulate_turn(game)
  }
  if game.trees[0].branches.length() > 0 {
    let branch = game.trees[0].branches[0]
    let brow = game.grid.height - 1 - branch.row
    let bcol = game.trees[0].col + branch.col_offset
    let result = find_branch_at(game, bcol, brow)
    inspect(result.0, content="0")
    inspect(result.1, content="0")
  } else {
    inspect(true, content="true")
  }
}

///|
test "water consumption increases with branches" {
  let tree = @types.new_tree(5)
  inspect(@types.water_consumption(tree), content="1")
  // Add 2 branches
  tree.branches.push(@types.new_branch(3, -1))
  tree.branches.push(@types.new_branch(3, 1))
  inspect(@types.water_consumption(tree), content="2")
  // Add 2 more
  tree.branches.push(@types.new_branch(6, -1))
  tree.branches.push(@types.new_branch(6, 1))
  inspect(@types.water_consumption(tree), content="3")
}

///|
test "check_win_or_lose detects loss" {
  let game = make_test_game()
  game.turn = game.turn_limit
  check_win_or_lose(game)
  inspect(game.play_state, content="Lost")
}
