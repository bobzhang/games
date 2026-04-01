///|
test "vec2i constructor" {
  let v = vec2i(3, 7)
  inspect(v.x, content="3")
  inspect(v.y, content="7")
}

///|
test "new_branch constructor" {
  let b = new_branch(5, -1)
  inspect(b.row, content="5")
  inspect(b.col_offset, content="-1")
  inspect(b.pruned, content="false")
}

///|
test "new_tree constructor" {
  let t = new_tree(4)
  inspect(t.col, content="4")
  inspect(t.height, content="0")
  inspect(t.branches.length(), content="0")
  inspect(t.growth_timer, content="0")
  inspect(t.shadowed, content="false")
}

///|
test "new_ground_tile constructor" {
  let g = new_ground_tile(2)
  inspect(g.water, content="2")
  inspect(g.has_seed, content="false")
}

///|
test "new_grid dimensions" {
  let g = new_grid()
  inspect(g.width, content="12")
  inspect(g.height, content="10")
  inspect(g.cells.length(), content="10")
  inspect(g.cells[0].length(), content="12")
}

///|
test "new_grid all cells start empty" {
  let g = new_grid()
  let mut all_empty = true
  for r in 0..<g.height {
    for c in 0..<g.width {
      if g.cells[r][c] != Empty {
        all_empty = false
      }
    }
  }
  inspect(all_empty, content="true")
}

///|
test "clone_tree is independent copy" {
  let t = new_tree(5)
  t.height = 3
  t.branches.push(new_branch(2, 1))
  let c = clone_tree(t)
  inspect(c.col, content="5")
  inspect(c.height, content="3")
  inspect(c.branches.length(), content="1")
  // Mutating clone does not affect original
  c.height = 99
  c.branches[0].pruned = true
  inspect(t.height, content="3")
  inspect(t.branches[0].pruned, content="false")
}

///|
test "clone_trees" {
  let trees = [new_tree(1), new_tree(2)]
  trees[0].height = 5
  let cloned = clone_trees(trees)
  inspect(cloned.length(), content="2")
  inspect(cloned[0].height, content="5")
  cloned[0].height = 99
  inspect(trees[0].height, content="5")
}

///|
test "clone_ground is independent" {
  let ground = [new_ground_tile(3), new_ground_tile(1)]
  let cloned = clone_ground(ground)
  inspect(cloned.length(), content="2")
  inspect(cloned[0].water, content="3")
  cloned[0].water = 0
  inspect(ground[0].water, content="3")
}

///|
test "rebuild_grid places trunk cells" {
  let game = new_game()
  game.trees = [new_tree(5)]
  game.trees[0].height = 3
  rebuild_grid(game)
  // Trunk at column 5, rows: grid_rows-1, grid_rows-2, grid_rows-3
  // grid_rows=10, so rows 9, 8, 7
  inspect(game.grid.cells[9][5], content="Trunk")
  inspect(game.grid.cells[8][5], content="Trunk")
  inspect(game.grid.cells[7][5], content="Trunk")
  // Above the trunk should be a leaf (row 6)
  inspect(game.grid.cells[6][5], content="Leaf")
}

///|
test "rebuild_grid places branch and leaf" {
  let game = new_game()
  game.trees = [new_tree(5)]
  game.trees[0].height = 4
  game.trees[0].branches.push(new_branch(3, 1))
  rebuild_grid(game)
  // Branch at row=3 means grid row = 10-1-3 = 6, col = 5+1 = 6
  inspect(game.grid.cells[6][6], content="Branch")
  // Leaf above branch at row 5, col 6
  inspect(game.grid.cells[5][6], content="Leaf")
}

///|
test "rebuild_grid skips pruned branches" {
  let game = new_game()
  game.trees = [new_tree(5)]
  game.trees[0].height = 4
  let b = new_branch(3, 1)
  b.pruned = true
  game.trees[0].branches.push(b)
  rebuild_grid(game)
  // Grid row 6, col 6 should still be Empty since branch is pruned
  inspect(game.grid.cells[6][6], content="Empty")
}

///|
test "water_consumption base with no branches" {
  let t = new_tree(5)
  t.height = 3
  inspect(water_consumption(t), content="1")
}

///|
test "water_consumption increases with branches" {
  let t = new_tree(5)
  t.branches.push(new_branch(3, -1))
  t.branches.push(new_branch(3, 1))
  // 1 + 2/2 = 2
  inspect(water_consumption(t), content="2")
}

///|
test "water_consumption skips pruned branches" {
  let t = new_tree(5)
  let b1 = new_branch(3, -1)
  let b2 = new_branch(3, 1)
  b2.pruned = true
  t.branches.push(b1)
  t.branches.push(b2)
  // Only 1 active branch: 1 + 1/2 = 1
  inspect(water_consumption(t), content="1")
}

///|
test "compute_shadows marks shadow cells under branches" {
  let game = new_game()
  game.trees = [new_tree(5)]
  game.trees[0].height = 5
  // Add a branch that sticks out to column 6 (col_offset=1)
  game.trees[0].branches.push(new_branch(3, 1))
  game.ground = []
  for _i in 0..<grid_cols {
    game.ground.push(new_ground_tile(3))
  }
  rebuild_grid(game)
  compute_shadows(game)
  // Branch at row=3 -> grid row = 10-1-3 = 6, col = 5+1 = 6
  // Leaf above branch at grid row 5, col 6
  // Shadow should be cast below the leaf/branch in column 6 on Empty cells
  let mut shadow_found = false
  for r in 7..<game.grid.height {
    if game.grid.cells[r][6] == Shadow {
      shadow_found = true
      break
    }
  }
  inspect(shadow_found, content="true")
}

///|
test "save_undo and restore_undo" {
  let game = new_game()
  game.trees = [new_tree(5)]
  game.ground = []
  for _i in 0..<grid_cols {
    game.ground.push(new_ground_tile(3))
  }
  save_undo(game)
  game.trees[0].height = 10
  game.turn = 5
  game.prunes_used = 3
  let ok = restore_undo(game)
  inspect(ok, content="true")
  inspect(game.trees[0].height, content="0")
  inspect(game.turn, content="0")
  inspect(game.prunes_used, content="0")
}

///|
test "restore_undo returns false when empty" {
  let game = new_game()
  inspect(restore_undo(game), content="false")
}

///|
test "new_level_score defaults" {
  let s = new_level_score()
  inspect(s.stars, content="0")
  inspect(s.completed, content="false")
  inspect(s.turns_used, content="0")
  inspect(s.prunes_used, content="0")
}

///|
test "maxi mini absi" {
  inspect(maxi(3, 7), content="7")
  inspect(mini(3, 7), content="3")
  inspect(absi(-4), content="4")
  inspect(absi(4), content="4")
  inspect(absi(0), content="0")
}

///|
test "new_game initializes properly" {
  let g = new_game()
  inspect(g.screen, content="Title")
  inspect(g.play_state, content="Idle")
  inspect(g.current_tier, content="Seedling")
  inspect(g.current_level, content="0")
  inspect(g.turn, content="0")
  inspect(g.prunes_used, content="0")
  inspect(g.level_scores.length(), content="20")
  inspect(g.grid.width, content="12")
  inspect(g.grid.height, content="10")
}
