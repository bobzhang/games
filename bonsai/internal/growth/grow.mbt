///|
/// Collect all branch tips (cells that are Branch/Trunk with no child in their growth direction)
pub fn find_tips(g : @types.TreeGrid) -> Array[@types.Vec2i] {
  let tips : Array[@types.Vec2i] = []
  for y in 0..<g.height {
    for x in 0..<g.width {
      let cell = @types.grid_get(g, x, y)
      if @types.is_branch_or_trunk(cell.kind) {
        let nx = x + @types.dir_dx(cell.growth_dir)
        let ny = y + @types.dir_dy(cell.growth_dir)
        let is_tip = if @types.grid_in_bounds(g, nx, ny) {
          let next = @types.grid_get(g, nx, ny)
          !@types.is_solid(next.kind)
        } else {
          true
        }
        if is_tip {
          // Also check that no adjacent cell has this as parent
          let mut has_child = false
          let dirs : Array[@types.GrowthDir] = [
            Up,
            UpLeft,
            UpRight,
            Left,
            Right,
          ]
          for d in dirs {
            let cx = x + @types.dir_dx(d)
            let cy = y + @types.dir_dy(d)
            if @types.grid_in_bounds(g, cx, cy) {
              let child = @types.grid_get(g, cx, cy)
              if @types.is_branch_or_trunk(child.kind) || child.kind == Leaf {
                has_child = true
                break
              }
            }
          }
          // A tip is a branch/trunk that has no solid cell in any forward direction
          // Simplified: just check the primary growth direction
          if !has_child {
            tips.push({ x, y })
          }
        }
      }
    }
  }
  tips
}

///|
/// Find tips more simply: a branch/trunk cell whose growth-direction neighbor is empty/OOB
pub fn find_growth_tips(g : @types.TreeGrid) -> Array[@types.Vec2i] {
  let tips : Array[@types.Vec2i] = []
  for y in 0..<g.height {
    for x in 0..<g.width {
      let cell = @types.grid_get(g, x, y)
      if @types.is_branch_or_trunk(cell.kind) {
        let nx = x + @types.dir_dx(cell.growth_dir)
        let ny = y + @types.dir_dy(cell.growth_dir)
        if @types.grid_in_bounds(g, nx, ny) {
          let next = @types.grid_get(g, nx, ny)
          if !@types.is_solid(next.kind) && next.kind != Pruned {
            tips.push({ x, y })
          }
        }
        // if OOB, it's a tip but can't grow
      }
    }
  }
  tips
}

///|
/// Compute left fork direction from a growth direction
pub fn fork_left(dir : @types.GrowthDir) -> @types.GrowthDir {
  match dir {
    Up => UpLeft
    UpLeft => Left
    UpRight => Up
    Left => UpLeft // curve down-left doesn't exist, go up-left
    Right => UpRight
  }
}

///|
/// Compute right fork direction from a growth direction
pub fn fork_right(dir : @types.GrowthDir) -> @types.GrowthDir {
  match dir {
    Up => UpRight
    UpLeft => Up
    UpRight => Right
    Left => UpLeft
    Right => UpRight // curve, go up-right
  }
}

///|
/// Cherry species has curved growth: directions rotate slightly
pub fn cherry_curve(dir : @types.GrowthDir, age : Int) -> @types.GrowthDir {
  if age % 4 == 0 {
    // Slight curve
    match dir {
      UpLeft => Up
      UpRight => Up
      Up => if age % 8 == 0 { UpLeft } else { UpRight }
      Left => UpLeft
      Right => UpRight
    }
  } else {
    dir
  }
}

///|
/// Grow the tree by one turn. Returns a new grid (the original is not modified in place).
pub fn grow_one_turn(
  g : @types.TreeGrid,
  species : @types.Species,
) -> @types.TreeGrid {
  let result = @types.clone_grid(g)
  let tips = find_growth_tips(g)
  let fi = @types.fork_interval(species)
  for tip in tips {
    let cell = @types.grid_get(g, tip.x, tip.y)
    let age = cell.age
    let dir = match species {
      Cherry => cherry_curve(cell.growth_dir, age)
      _ => cell.growth_dir
    }
    let should_fork = age > 0 && age % fi == 0
    if should_fork {
      // Fork: create two branches in fork directions
      let ld = fork_left(dir)
      let rd = fork_right(dir)
      let lx = tip.x + @types.dir_dx(ld)
      let ly = tip.y + @types.dir_dy(ld)
      let rx = tip.x + @types.dir_dx(rd)
      let ry = tip.y + @types.dir_dy(rd)
      if @types.grid_in_bounds(result, lx, ly) {
        let lc = @types.grid_get(result, lx, ly)
        if !@types.is_solid(lc.kind) && lc.kind != Pruned {
          @types.grid_set_kind(result, lx, ly, Branch, ld)
          result.cells[@types.grid_index(result, lx, ly)].age = 1
        }
      }
      if @types.grid_in_bounds(result, rx, ry) {
        let rc = @types.grid_get(result, rx, ry)
        if !@types.is_solid(rc.kind) && rc.kind != Pruned {
          @types.grid_set_kind(result, rx, ry, Branch, rd)
          result.cells[@types.grid_index(result, rx, ry)].age = 1
        }
      }
      // Mark the fork point with incremented age
      let ti = @types.grid_index(result, tip.x, tip.y)
      result.cells[ti].age = age + 1
      result.cells[ti].stagnant_turns = 0
    } else {
      // Grow straight
      let nx = tip.x + @types.dir_dx(dir)
      let ny = tip.y + @types.dir_dy(dir)
      if @types.grid_in_bounds(result, nx, ny) {
        let nc = @types.grid_get(result, nx, ny)
        if !@types.is_solid(nc.kind) && nc.kind != Pruned {
          @types.grid_set_kind(result, nx, ny, Branch, dir)
          result.cells[@types.grid_index(result, nx, ny)].age = age + 1
          let ti = @types.grid_index(result, tip.x, tip.y)
          result.cells[ti].stagnant_turns = 0
        } else {
          // Can't grow, mark stagnant
          let ti = @types.grid_index(result, tip.x, tip.y)
          result.cells[ti].stagnant_turns = cell.stagnant_turns + 1
        }
      } else {
        let ti = @types.grid_index(result, tip.x, tip.y)
        result.cells[ti].stagnant_turns = cell.stagnant_turns + 1
      }
    }
  }
  // Update ages for all existing cells (increment for non-tips)
  for y in 0..<result.height {
    for x in 0..<result.width {
      let c = @types.grid_get(result, x, y)
      if @types.is_branch_or_trunk(c.kind) {
        // Check if this was not a tip (already had its age set)
        let was_tip = tips.iter().any(fn(t) { t.x == x && t.y == y })
        if !was_tip {
          // not a tip: just sits there
          ()
        }
      }
    }
  }
  // Generate leaves on stagnant tips
  generate_leaves(result)
  result
}

///|
/// Turn stagnant tips into leaves
pub fn generate_leaves(g : @types.TreeGrid) -> Unit {
  for y in 0..<g.height {
    for x in 0..<g.width {
      let cell = @types.grid_get(g, x, y)
      if @types.is_branch_or_trunk(cell.kind) &&
        cell.stagnant_turns >= @types.leaf_stagnant_threshold {
        // Convert to leaf
        let idx = @types.grid_index(g, x, y)
        g.cells[idx].kind = Leaf
      }
    }
  }
}

///|
/// Prune: remove the cell at (x,y) and everything "above" it (all cells
/// reachable by following growth directions from this cell).
/// Returns the number of cells pruned.
pub fn prune_at(g : @types.TreeGrid, x : Int, y : Int) -> Int {
  let cell = @types.grid_get(g, x, y)
  if !@types.is_solid(cell.kind) {
    return 0
  }
  if cell.kind == Trunk {
    // Can't prune the trunk base
    return 0
  }
  // BFS/flood to find all cells that are "children" of this cell
  // A child is any adjacent solid cell that could have grown from this direction
  let to_remove : Array[@types.Vec2i] = []
  let queue : Array[@types.Vec2i] = [{ x, y }]
  let visited = Array::make(g.width * g.height, false)
  visited[@types.grid_index(g, x, y)] = true
  while queue.length() > 0 {
    let pos = queue.unsafe_pop()
    to_remove.push(pos)
    // Check all directions for children
    let dirs : Array[@types.GrowthDir] = [Up, UpLeft, UpRight, Left, Right]
    for d in dirs {
      let nx = pos.x + @types.dir_dx(d)
      let ny = pos.y + @types.dir_dy(d)
      if @types.grid_in_bounds(g, nx, ny) {
        let ni = @types.grid_index(g, nx, ny)
        if !visited[ni] {
          let nc = @types.grid_get(g, nx, ny)
          if @types.is_solid(nc.kind) {
            // Only prune cells that are above or beside (not below the cut)
            // Check: this neighbor is a child if it's "upstream" in growth
            // i.e., its growth leads away from us, or it's above
            if ny <= pos.y || (ny == pos.y && nc.kind != Trunk) {
              visited[ni] = true
              queue.push({ x: nx, y: ny })
            }
          }
        }
      }
    }
  }
  // Actually remove
  let count = to_remove.length()
  for pos in to_remove {
    let idx = @types.grid_index(g, pos.x, pos.y)
    g.cells[idx].kind = Pruned
    g.cells[idx].age = 0
    g.cells[idx].stagnant_turns = 0
  }
  count
}

///|
/// Check zone satisfaction.
/// Returns (required_ok, forbidden_ok, tips_ok)
pub fn check_zones(
  g : @types.TreeGrid,
  zones : Array[@types.Zone],
) -> (Bool, Bool, Bool) {
  let mut req_ok = true
  let mut forb_ok = true
  let mut tip_ok = true
  for zone in zones {
    match zone.kind {
      Required => {
        // All positions must have solid cells
        let mut all_filled = true
        for pos in zone.positions {
          if @types.grid_in_bounds(g, pos.x, pos.y) {
            let c = @types.grid_get(g, pos.x, pos.y)
            if !@types.is_solid(c.kind) {
              all_filled = false
              break
            }
          } else {
            all_filled = false
            break
          }
        }
        if !all_filled {
          req_ok = false
        }
      }
      Forbidden => {
        // All positions must be empty or pruned
        let mut all_clear = true
        for pos in zone.positions {
          if @types.grid_in_bounds(g, pos.x, pos.y) {
            let c = @types.grid_get(g, pos.x, pos.y)
            if @types.is_solid(c.kind) {
              all_clear = false
              break
            }
          }
        }
        if !all_clear {
          forb_ok = false
        }
      }
      TipTarget => {
        // At least one position must have a branch tip or leaf
        let mut any_tip = false
        for pos in zone.positions {
          if @types.grid_in_bounds(g, pos.x, pos.y) {
            let c = @types.grid_get(g, pos.x, pos.y)
            if c.kind == Branch || c.kind == Leaf {
              // Check it's actually a tip (no solid in growth dir)
              let nx = pos.x + @types.dir_dx(c.growth_dir)
              let ny = pos.y + @types.dir_dy(c.growth_dir)
              if @types.grid_in_bounds(g, nx, ny) {
                let nc = @types.grid_get(g, nx, ny)
                if !@types.is_solid(nc.kind) {
                  any_tip = true
                }
              } else {
                any_tip = true
              }
            }
            // Leaves always count as tips
            if c.kind == Leaf {
              any_tip = true
            }
          }
        }
        if !any_tip {
          tip_ok = false
        }
      }
    }
  }
  (req_ok, forb_ok, tip_ok)
}

///|
/// Calculate stars for a level result
pub fn calculate_stars(
  g : @types.TreeGrid,
  zones : Array[@types.Zone],
  total_prunes : Int,
  par : Int,
) -> Int {
  let (req_ok, forb_ok, tip_ok) = check_zones(g, zones)
  if req_ok && forb_ok {
    if tip_ok {
      if total_prunes <= par {
        3
      } else {
        2
      }
    } else {
      1
    }
  } else {
    0
  }
}
