///|
pub fn get_level(index : Int) -> @types.Level {
  match index {
    // Tier 1: Seedling (7 levels) - Single trees, learn growth and water
    0 =>
      // Level 1: Just grow a tree
      {
        seed_columns: [5],
        targets: [{ tree_index: 0, required_height: 5, }],
        turn_limit: 8,
        prune_budget: 0,
        par_prunes: 0,
        par_turns: 6,
        tier: Seedling,
        water_levels: [2, 2, 2, 3, 3, 3, 3, 2, 2, 2, 2, 2],
      }
    1 =>
      // Level 2: Grow taller
      {
        seed_columns: [6],
        targets: [{ tree_index: 0, required_height: 7, }],
        turn_limit: 10,
        prune_budget: 1,
        par_prunes: 0,
        par_turns: 8,
        tier: Seedling,
        water_levels: [2, 2, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2],
      }
    2 =>
      // Level 3: Water management
      {
        seed_columns: [4],
        targets: [{ tree_index: 0, required_height: 6, }],
        turn_limit: 10,
        prune_budget: 2,
        par_prunes: 1,
        par_turns: 8,
        tier: Seedling,
        water_levels: [1, 1, 1, 2, 2, 1, 1, 1, 1, 1, 1, 1],
      }
    3 =>
      // Level 4: Pruning basics
      {
        seed_columns: [6],
        targets: [{ tree_index: 0, required_height: 8, }],
        turn_limit: 12,
        prune_budget: 3,
        par_prunes: 2,
        par_turns: 10,
        tier: Seedling,
        water_levels: [1, 1, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1],
      }
    4 =>
      // Level 5: Low water challenge
      {
        seed_columns: [5],
        targets: [{ tree_index: 0, required_height: 5, }],
        turn_limit: 12,
        prune_budget: 3,
        par_prunes: 2,
        par_turns: 10,
        tier: Seedling,
        water_levels: [0, 0, 1, 1, 1, 2, 1, 1, 1, 0, 0, 0],
      }
    5 =>
      // Level 6: Rain timing
      {
        seed_columns: [3],
        targets: [{ tree_index: 0, required_height: 7, }],
        turn_limit: 12,
        prune_budget: 2,
        par_prunes: 1,
        par_turns: 9,
        tier: Seedling,
        water_levels: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      }
    6 =>
      // Level 7: Max height challenge
      {
        seed_columns: [6],
        targets: [{ tree_index: 0, required_height: 9, }],
        turn_limit: 14,
        prune_budget: 4,
        par_prunes: 2,
        par_turns: 11,
        tier: Seedling,
        water_levels: [2, 2, 2, 3, 3, 3, 3, 3, 2, 2, 2, 2],
      }
    // Tier 2: Grove (7 levels) - Multiple trees, shadow competition
    7 =>
      // Level 8: Two trees
      {
        seed_columns: [3, 8],
        targets: [
          { tree_index: 0, required_height: 5, },
          { tree_index: 1, required_height: 5, },
        ],
        turn_limit: 10,
        prune_budget: 2,
        par_prunes: 1,
        par_turns: 7,
        tier: Grove,
        water_levels: [2, 2, 3, 3, 2, 2, 2, 3, 3, 2, 2, 2],
      }
    8 =>
      // Level 9: Shadow management
      {
        seed_columns: [4, 6],
        targets: [
          { tree_index: 0, required_height: 6, },
          { tree_index: 1, required_height: 6, },
        ],
        turn_limit: 12,
        prune_budget: 4,
        par_prunes: 2,
        par_turns: 9,
        tier: Grove,
        water_levels: [1, 2, 2, 3, 3, 3, 3, 2, 2, 1, 1, 1],
      }
    9 =>
      // Level 10: Unequal targets
      {
        seed_columns: [3, 7],
        targets: [
          { tree_index: 0, required_height: 7, },
          { tree_index: 1, required_height: 4, },
        ],
        turn_limit: 12,
        prune_budget: 3,
        par_prunes: 2,
        par_turns: 9,
        tier: Grove,
        water_levels: [2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 2],
      }
    10 =>
      // Level 11: Three trees
      {
        seed_columns: [2, 6, 10],
        targets: [
          { tree_index: 0, required_height: 5, },
          { tree_index: 1, required_height: 5, },
          { tree_index: 2, required_height: 5, },
        ],
        turn_limit: 10,
        prune_budget: 3,
        par_prunes: 2,
        par_turns: 7,
        tier: Grove,
        water_levels: [2, 2, 3, 2, 2, 2, 3, 2, 2, 2, 3, 2],
      }
    11 =>
      // Level 12: Pruning competition
      {
        seed_columns: [4, 5, 7],
        targets: [{ tree_index: 1, required_height: 7, }],
        turn_limit: 12,
        prune_budget: 4,
        par_prunes: 3,
        par_turns: 10,
        tier: Grove,
        water_levels: [1, 2, 2, 3, 3, 3, 3, 3, 2, 2, 1, 1],
      }
    12 =>
      // Level 13: Water scarcity grove
      {
        seed_columns: [3, 8],
        targets: [
          { tree_index: 0, required_height: 6, },
          { tree_index: 1, required_height: 6, },
        ],
        turn_limit: 14,
        prune_budget: 5,
        par_prunes: 3,
        par_turns: 11,
        tier: Grove,
        water_levels: [0, 1, 1, 2, 1, 0, 0, 1, 2, 1, 1, 0],
      }
    13 =>
      // Level 14: The tall one
      {
        seed_columns: [3, 6, 9],
        targets: [{ tree_index: 1, required_height: 8, }],
        turn_limit: 14,
        prune_budget: 5,
        par_prunes: 3,
        par_turns: 11,
        tier: Grove,
        water_levels: [2, 2, 2, 2, 3, 3, 3, 3, 2, 2, 2, 2],
      }
    // Tier 3: Forest (6 levels) - Dense planting, water scarcity
    14 =>
      // Level 15: Dense forest
      {
        seed_columns: [1, 3, 5, 7, 9],
        targets: [
          { tree_index: 0, required_height: 5, },
          { tree_index: 2, required_height: 5, },
          { tree_index: 4, required_height: 5, },
        ],
        turn_limit: 12,
        prune_budget: 6,
        par_prunes: 4,
        par_turns: 10,
        tier: Forest,
        water_levels: [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2],
      }
    15 =>
      // Level 16: Selective growth
      {
        seed_columns: [2, 4, 6, 8, 10],
        targets: [
          { tree_index: 1, required_height: 7, },
          { tree_index: 3, required_height: 7, },
        ],
        turn_limit: 14,
        prune_budget: 8,
        par_prunes: 5,
        par_turns: 11,
        tier: Forest,
        water_levels: [1, 1, 2, 2, 3, 2, 3, 2, 2, 1, 1, 1],
      }
    16 =>
      // Level 17: Water crisis
      {
        seed_columns: [2, 5, 8, 11],
        targets: [
          { tree_index: 0, required_height: 6, },
          { tree_index: 1, required_height: 6, },
          { tree_index: 2, required_height: 6, },
          { tree_index: 3, required_height: 6, },
        ],
        turn_limit: 16,
        prune_budget: 8,
        par_prunes: 5,
        par_turns: 13,
        tier: Forest,
        water_levels: [0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1],
      }
    17 =>
      // Level 18: The canopy race
      {
        seed_columns: [1, 3, 5, 7, 9, 11],
        targets: [
          { tree_index: 2, required_height: 8, },
          { tree_index: 3, required_height: 8, },
        ],
        turn_limit: 16,
        prune_budget: 10,
        par_prunes: 6,
        par_turns: 13,
        tier: Forest,
        water_levels: [1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1],
      }
    18 =>
      // Level 19: Precision pruning
      {
        seed_columns: [0, 2, 4, 6, 8, 10],
        targets: [
          { tree_index: 0, required_height: 7, },
          { tree_index: 2, required_height: 9, },
          { tree_index: 5, required_height: 7, },
        ],
        turn_limit: 18,
        prune_budget: 10,
        par_prunes: 7,
        par_turns: 15,
        tier: Forest,
        water_levels: [2, 1, 2, 1, 3, 1, 3, 1, 2, 1, 2, 1],
      }
    _ =>
      // Level 20: The ultimate forest
      {
        seed_columns: [0, 2, 3, 5, 6, 8, 9, 11],
        targets: [
          { tree_index: 0, required_height: 6, },
          { tree_index: 3, required_height: 8, },
          { tree_index: 4, required_height: 8, },
          { tree_index: 7, required_height: 6, },
        ],
        turn_limit: 20,
        prune_budget: 12,
        par_prunes: 8,
        par_turns: 16,
        tier: Forest,
        water_levels: [1, 0, 1, 2, 1, 2, 2, 1, 2, 1, 0, 1],
      }
  }
}

///|
pub fn load_level(game : @types.Game, level_index : Int) -> Unit {
  let level = get_level(level_index)
  game.current_level = level_index
  game.turn = 0
  game.prunes_used = 0
  game.turn_limit = level.turn_limit
  game.prune_budget = level.prune_budget
  game.par_prunes = level.par_prunes
  game.par_turns = level.par_turns
  game.play_state = Idle
  game.undo_stack = []
  game.message = ""
  game.message_timer = 0.0
  // Set tier
  game.current_tier = level.tier
  // Create trees
  game.trees = []
  for i in 0..<level.seed_columns.length() {
    game.trees.push(@types.new_tree(level.seed_columns[i]))
  }
  // Set up ground tiles
  game.ground = []
  for i in 0..<@types.grid_cols {
    let water = if i < level.water_levels.length() {
      level.water_levels[i]
    } else {
      2
    }
    game.ground.push(@types.new_ground_tile(water))
  }
  // Set targets
  game.targets = []
  for i in 0..<level.targets.length() {
    game.targets.push(level.targets[i])
  }
  // Reset grid
  game.grid = @types.new_grid()
  @types.rebuild_grid(game)
  @types.compute_shadows(game)
}

///|
pub fn tier_for_level(index : Int) -> @types.Tier {
  if index < 7 {
    Seedling
  } else if index < 14 {
    Grove
  } else {
    Forest
  }
}

///|
pub fn tier_start_level(tier : @types.Tier) -> Int {
  match tier {
    Seedling => 0
    Grove => 7
    Forest => 14
  }
}

///|
pub fn tier_level_count(tier : @types.Tier) -> Int {
  match tier {
    Seedling => 7
    Grove => 7
    Forest => 6
  }
}
