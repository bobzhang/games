///|
pub fn simulate_turn(game : @types.Game) -> Unit {
  // Save undo state before simulating
  @types.save_undo(game)
  game.turn += 1
  // Rain cycle: every rain_interval turns, refill water
  if game.turn % @types.rain_interval == 0 {
    apply_rain(game)
  }
  // Grow each tree
  for i in 0..<game.trees.length() {
    grow_tree(game, i)
  }
  // Rebuild grid and compute shadows
  @types.rebuild_grid(game)
  @types.compute_shadows(game)
}

///|
fn grow_tree(game : @types.Game, i : Int) -> Unit {
  let tree = game.trees[i]
  if tree.col < 0 || tree.col >= game.ground.length() {
    return
  }
  let water_needed = @types.water_consumption(tree)
  if game.ground[tree.col].water <= 0 {
    return
  }
  // Shadowed trees grow slower
  if tree.shadowed {
    tree.growth_timer += 1
    if tree.growth_timer < @types.shadow_growth_delay {
      game.ground[tree.col].water = @types.maxi(
        game.ground[tree.col].water - 1,
        0,
      )
      return
    }
    tree.growth_timer = 0
  }
  // Consume water
  game.ground[tree.col].water = @types.maxi(
    game.ground[tree.col].water - water_needed,
    0,
  )
  // Grow trunk by 1
  if tree.height < game.grid.height - 1 {
    tree.height += 1
    // Add branches every branch_interval cells of height
    if tree.height > 1 && tree.height % @types.branch_interval == 0 {
      add_branches(tree, game)
    }
  }
}

///|
fn add_branches(tree : @types.Tree, game : @types.Game) -> Unit {
  let row = tree.height
  // Try to add branch left
  let left_col = tree.col - 1
  if left_col >= 0 {
    let mut blocked = false
    // Check if another tree trunk is there
    let grid_row = game.grid.height - 1 - row
    if grid_row >= 0 && grid_row < game.grid.height {
      let cell = game.grid.cells[grid_row][left_col]
      if cell == Trunk {
        blocked = true
      }
    }
    if !blocked {
      tree.branches.push(@types.new_branch(row, -1))
    }
  }
  // Try to add branch right
  let right_col = tree.col + 1
  if right_col < game.grid.width {
    let mut blocked = false
    let grid_row = game.grid.height - 1 - row
    if grid_row >= 0 && grid_row < game.grid.height {
      let cell = game.grid.cells[grid_row][right_col]
      if cell == Trunk {
        blocked = true
      }
    }
    if !blocked {
      tree.branches.push(@types.new_branch(row, 1))
    }
  }
}

///|
fn apply_rain(game : @types.Game) -> Unit {
  for i in 0..<game.ground.length() {
    game.ground[i].water = @types.mini(
      game.ground[i].water + 2,
      @types.max_water,
    )
  }
}

///|
pub fn prune_branch(
  game : @types.Game,
  tree_index : Int,
  branch_index : Int,
) -> Bool {
  if tree_index < 0 || tree_index >= game.trees.length() {
    return false
  }
  let tree = game.trees[tree_index]
  if branch_index < 0 || branch_index >= tree.branches.length() {
    return false
  }
  let branch = tree.branches[branch_index]
  if branch.pruned {
    return false
  }
  if game.prunes_used >= game.prune_budget {
    return false
  }
  // Save undo before pruning
  @types.save_undo(game)
  branch.pruned = true
  game.prunes_used += 1
  // Rebuild grid and shadows
  @types.rebuild_grid(game)
  @types.compute_shadows(game)
  true
}

///|
pub fn find_branch_at(
  game : @types.Game,
  grid_col : Int,
  grid_row : Int,
) -> (Int, Int) {
  // Returns (tree_index, branch_index) or (-1, -1)
  for i in 0..<game.trees.length() {
    let tree = game.trees[i]
    for b in 0..<tree.branches.length() {
      let branch = tree.branches[b]
      if !branch.pruned {
        let brow = game.grid.height - 1 - branch.row
        let bcol = tree.col + branch.col_offset
        if brow == grid_row && bcol == grid_col {
          return (i, b)
        }
      }
    }
  }
  (-1, -1)
}
