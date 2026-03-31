///|
pub fn vec2i(x : Int, y : Int) -> Vec2i {
  { x, y }
}

///|
pub fn new_branch(row : Int, col_offset : Int) -> Branch {
  { row, col_offset, pruned: false }
}

///|
pub fn new_tree(col : Int) -> Tree {
  { col, height: 0, branches: [], growth_timer: 0, shadowed: false }
}

///|
pub fn new_ground_tile(water : Int) -> GroundTile {
  { water, has_seed: false }
}

///|
pub fn new_grid() -> Grid {
  let cells : Array[Array[CellKind]] = []
  for _r in 0..<grid_rows {
    let row : Array[CellKind] = []
    for _c in 0..<grid_cols {
      row.push(Empty)
    }
    cells.push(row)
  }
  { width: grid_cols, height: grid_rows, cells }
}

///|
pub fn new_level_score() -> LevelScore {
  { stars: 0, completed: false, turns_used: 0, prunes_used: 0 }
}

///|
pub fn clone_tree(t : Tree) -> Tree {
  let branches : Array[Branch] = []
  for i in 0..<t.branches.length() {
    let b = t.branches[i]
    branches.push({ row: b.row, col_offset: b.col_offset, pruned: b.pruned })
  }
  {
    col: t.col,
    height: t.height,
    branches,
    growth_timer: t.growth_timer,
    shadowed: t.shadowed,
  }
}

///|
pub fn clone_trees(trees : Array[Tree]) -> Array[Tree] {
  let result : Array[Tree] = []
  for i in 0..<trees.length() {
    result.push(clone_tree(trees[i]))
  }
  result
}

///|
pub fn clone_ground(ground : Array[GroundTile]) -> Array[GroundTile] {
  let result : Array[GroundTile] = []
  for i in 0..<ground.length() {
    let g = ground[i]
    result.push({ water: g.water, has_seed: g.has_seed })
  }
  result
}

///|
pub fn save_undo(game : Game) -> Unit {
  let state : UndoState = {
    trees: clone_trees(game.trees),
    turn: game.turn,
    prunes_used: game.prunes_used,
    ground: clone_ground(game.ground),
  }
  game.undo_stack.push(state)
}

///|
pub fn restore_undo(game : Game) -> Bool {
  if game.undo_stack.length() == 0 {
    return false
  }
  let state = game.undo_stack.pop().unwrap()
  game.trees = state.trees
  game.turn = state.turn
  game.prunes_used = state.prunes_used
  game.ground = state.ground
  rebuild_grid(game)
  true
}

///|
pub fn rebuild_grid(game : Game) -> Unit {
  // Clear grid
  for r in 0..<game.grid.height {
    for c in 0..<game.grid.width {
      game.grid.cells[r][c] = Empty
    }
  }
  // Place trees
  for i in 0..<game.trees.length() {
    let tree = game.trees[i]
    // Trunk cells: row 0 is top, grid_rows-1 is bottom
    // Tree height grows up from bottom
    for h in 0..<tree.height {
      let row = game.grid.height - 1 - h
      if row >= 0 && row < game.grid.height && tree.col >= 0 && tree.col < game.grid.width {
        game.grid.cells[row][tree.col] = Trunk
      }
    }
    // Branch cells
    for b in 0..<tree.branches.length() {
      let branch = tree.branches[b]
      if !(branch.pruned) {
        let row = game.grid.height - 1 - branch.row
        let bcol = tree.col + branch.col_offset
        if row >= 0 && row < game.grid.height && bcol >= 0 && bcol < game.grid.width {
          game.grid.cells[row][bcol] = Branch
        }
        // Add leaf on top of branch
        let leaf_row = row - 1
        if leaf_row >= 0 && leaf_row < game.grid.height && bcol >= 0 && bcol < game.grid.width {
          if game.grid.cells[leaf_row][bcol] == Empty {
            game.grid.cells[leaf_row][bcol] = Leaf
          }
        }
      }
    }
    // Leaf at top of trunk
    if tree.height > 0 {
      let top_row = game.grid.height - 1 - tree.height
      if top_row >= 0 && top_row < game.grid.height && tree.col >= 0 && tree.col < game.grid.width {
        if game.grid.cells[top_row][tree.col] == Empty {
          game.grid.cells[top_row][tree.col] = Leaf
        }
      }
    }
  }
}

///|
pub fn compute_shadows(game : Game) -> Unit {
  // First clear shadows from grid
  for r in 0..<game.grid.height {
    for c in 0..<game.grid.width {
      if game.grid.cells[r][c] == Shadow {
        game.grid.cells[r][c] = Empty
      }
    }
  }
  // Reset tree shadow state
  for i in 0..<game.trees.length() {
    game.trees[i].shadowed = false
  }
  // For each tree, branches and leaves cast shadow downward
  for i in 0..<game.trees.length() {
    let tree = game.trees[i]
    // Collect canopy columns: any branch or leaf position
    let canopy_cols : Array[Vec2i] = [] // x=col, y=row (grid row)
    for b in 0..<tree.branches.length() {
      let branch = tree.branches[b]
      if !(branch.pruned) {
        let bcol = tree.col + branch.col_offset
        let brow = game.grid.height - 1 - branch.row
        canopy_cols.push(vec2i(bcol, brow))
        // Leaf above branch
        let lrow = brow - 1
        if lrow >= 0 {
          canopy_cols.push(vec2i(bcol, lrow))
        }
      }
    }
    // Leaf at top of trunk
    if tree.height > 0 {
      let top_row = game.grid.height - 1 - tree.height
      if top_row >= 0 {
        canopy_cols.push(vec2i(tree.col, top_row))
      }
    }
    // Cast shadow below each canopy cell
    for c in 0..<canopy_cols.length() {
      let cp = canopy_cols[c]
      for r = cp.y + 1; r < game.grid.height; r = r + 1 {
        if cp.x >= 0 && cp.x < game.grid.width {
          let cell = game.grid.cells[r][cp.x]
          if cell == Empty {
            game.grid.cells[r][cp.x] = Shadow
          }
        }
      }
    }
  }
  // Determine which trees are shadowed
  // A tree is shadowed if its top trunk cell or leaf is in a column where
  // another tree's canopy is above it
  for i in 0..<game.trees.length() {
    let tree = game.trees[i]
    if tree.height > 0 {
      let top_row = game.grid.height - 1 - tree.height
      // Check if there's a canopy cell above this tree from another tree
      let mut has_shadow_above = false
      for r in 0..<top_row {
        if tree.col >= 0 && tree.col < game.grid.width {
          let cell = game.grid.cells[r][tree.col]
          if cell == Leaf || cell == Branch {
            // Make sure it's not from the same tree
            let mut from_self = false
            for b in 0..<tree.branches.length() {
              let branch = tree.branches[b]
              if !(branch.pruned) {
                let bcol = tree.col + branch.col_offset
                let brow = game.grid.height - 1 - branch.row
                if bcol == tree.col && (brow == r || brow - 1 == r) {
                  from_self = true
                }
              }
            }
            // Check leaf at top
            let my_top = game.grid.height - 1 - tree.height
            if my_top == r && tree.col == tree.col {
              from_self = true
            }
            if !(from_self) {
              has_shadow_above = true
            }
          }
        }
      }
      tree.shadowed = has_shadow_above
    }
  }
}

///|
pub fn water_consumption(tree : Tree) -> Int {
  // Base consumption of 1, plus 1 for every 2 active branches
  let mut active_branches = 0
  for b in 0..<tree.branches.length() {
    if !(tree.branches[b].pruned) {
      active_branches += 1
    }
  }
  1 + active_branches / 2
}

///|
pub fn new_game() -> Game {
  let scores : Array[LevelScore] = []
  for _i in 0..<total_levels {
    scores.push(new_level_score())
  }
  {
    screen: Title,
    play_state: Idle,
    current_tier: Seedling,
    current_level: 0,
    grid: new_grid(),
    trees: [],
    ground: [],
    turn: 0,
    prunes_used: 0,
    targets: [],
    turn_limit: 10,
    prune_budget: 3,
    par_prunes: 2,
    par_turns: 8,
    level_scores: scores,
    undo_stack: [],
    frame_count: 0,
    anim_timer: 0.0,
    message: "",
    message_timer: 0.0,
    hover_col: -1,
    hover_row: -1,
    selected_tier: 0,
  }
}

///|
pub fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn absi(a : Int) -> Int {
  if a < 0 {
    -a
  } else {
    a
  }
}
