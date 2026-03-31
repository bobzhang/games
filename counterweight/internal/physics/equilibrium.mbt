///|
fn get_node_total_mass(game : @types.Game, node_id : Int) -> Float {
  let mut mass : Float = 0.0
  for i in 0..<game.weights.length() {
    if game.weights[i].active && game.weights[i].node_id == node_id {
      mass = mass + game.weights[i].mass
    }
  }
  for i in 0..<game.crates.length() {
    if game.crates[i].active && game.crates[i].node_id == node_id {
      mass = mass + game.crates[i].mass
    }
  }
  for i in 0..<game.buckets.length() {
    if game.buckets[i].active && game.buckets[i].node_id == node_id {
      mass = mass + game.buckets[i].mass
    }
  }
  mass
}

///|
fn find_connected_node(
  game : @types.Game,
  pulley_id : Int,
  side : @types.RopeSide
) -> Int {
  for i in 0..<game.ropes.length() {
    if game.ropes[i].active && !game.ropes[i].broken {
      let r = game.ropes[i]
      if r.from_node == pulley_id && r.from_side == side {
        return r.to_node
      }
      if r.to_node == pulley_id && r.to_side == side {
        return r.from_node
      }
    }
  }
  -1
}

///|
fn compute_side_mass_depth(
  game : @types.Game,
  pulley_id : Int,
  side : @types.RopeSide,
  depth : Int
) -> Float {
  if depth > 10 {
    return 0.0
  }
  let connected = find_connected_node(game, pulley_id, side)
  if connected < 0 {
    return 0.0
  }
  let direct_mass = get_node_total_mass(game, connected)
  let node = game.nodes[connected]
  if node.kind == Pulley || node.kind == Ratchet {
    let left_m = compute_side_mass_depth(game, connected, LeftSide, depth + 1)
    let right_m = compute_side_mass_depth(
      game, connected, RightSide, depth + 1,
    )
    return direct_mass + @types.maxf(left_m, right_m)
  }
  direct_mass
}

///|
fn compute_side_mass(
  game : @types.Game,
  pulley_id : Int,
  side : @types.RopeSide
) -> Float {
  compute_side_mass_depth(game, pulley_id, side, 0)
}

///|
fn apply_height_change(
  game : @types.Game,
  node_id : Int,
  delta : Float
) -> Unit {
  let node = game.nodes[node_id]
  if node.locked || node.kind == Anchor {
    return
  }
  node.height = node.base_height + delta
  for i in 0..<game.weights.length() {
    if game.weights[i].active && game.weights[i].node_id == node_id {
      game.weights[i].target_y = node.height
    }
  }
  for i in 0..<game.crates.length() {
    if game.crates[i].active && game.crates[i].node_id == node_id {
      game.crates[i].target_y = node.height
    }
  }
  for i in 0..<game.buckets.length() {
    if game.buckets[i].active && game.buckets[i].node_id == node_id {
      game.buckets[i].target_y = node.height
    }
  }
}

///|
pub fn solve_equilibrium(game : @types.Game) -> Unit {
  // Reset all non-anchor node heights to base
  for i in 0..<game.nodes.length() {
    let node = game.nodes[i]
    if node.kind != Anchor {
      node.height = node.base_height
    }
  }
  // Update bucket mass if filling
  if game.has_waterfall {
    for i in 0..<game.buckets.length() {
      if game.buckets[i].active && game.buckets[i].filling {
        let b = game.buckets[i]
        b.mass = @types.minf(b.mass + b.fill_rate, b.max_mass)
      }
    }
  }
  let max_iters = 20
  // Iterative equilibrium solver
  for _iter in 0..<max_iters {
    let mut changed = false
    for i in 0..<game.nodes.length() {
      let node = game.nodes[i]
      if node.kind == Pulley || node.kind == Ratchet {
        let left_node_id = find_connected_node(game, i, LeftSide)
        let right_node_id = find_connected_node(game, i, RightSide)
        if left_node_id >= 0 && right_node_id >= 0 {
          let left_mass = compute_side_mass(game, i, LeftSide)
          let right_mass = compute_side_mass(game, i, RightSide)
          let diff = right_mass - left_mass
          let left_delta = -diff * @types.height_per_mass_diff
          let right_delta = diff * @types.height_per_mass_diff
          // Ratchet: only allow downward movement
          let mut skip = false
          if node.kind == Ratchet {
            let left_node = game.nodes[left_node_id]
            let right_node = game.nodes[right_node_id]
            if left_delta < left_node.height - left_node.base_height {
              skip = true
            }
            if right_delta < right_node.height - right_node.base_height {
              skip = true
            }
          }
          if !skip {
            let old_left = game.nodes[left_node_id].height
            let old_right = game.nodes[right_node_id].height
            apply_height_change(game, left_node_id, left_delta)
            apply_height_change(game, right_node_id, right_delta)
            if @types.absf(game.nodes[left_node_id].height - old_left) > 0.01 ||
              @types.absf(game.nodes[right_node_id].height - old_right) > 0.01 {
              changed = true
            }
          }
        } else if left_node_id >= 0 {
          let left_mass = compute_side_mass(game, i, LeftSide)
          if left_mass > 0.0 {
            apply_height_change(
              game,
              left_node_id,
              left_mass * @types.height_per_mass_diff,
            )
            changed = true
          }
        } else if right_node_id >= 0 {
          let right_mass = compute_side_mass(game, i, RightSide)
          if right_mass > 0.0 {
            apply_height_change(
              game,
              right_node_id,
              right_mass * @types.height_per_mass_diff,
            )
            changed = true
          }
        }
      }
    }
    // Check breakable ropes
    for i in 0..<game.ropes.length() {
      if game.ropes[i].active && game.ropes[i].breakable && !game.ropes[i].broken {
        let r = game.ropes[i]
        let load : Float = get_node_total_mass(game, r.to_node) +
          get_node_total_mass(game, r.from_node)
        if load > r.max_load {
          r.broken = true
          changed = true
        }
      }
    }
    if !changed {
      break
    }
  }
  // Check if buckets are under waterfall
  if game.has_waterfall {
    for i in 0..<game.buckets.length() {
      if game.buckets[i].active {
        let b = game.buckets[i]
        let bnode = game.nodes[b.node_id]
        if bnode.pos.x == game.waterfall_x {
          b.filling = true
        } else {
          b.filling = false
        }
      }
    }
  }
}

///|
pub fn check_targets(game : @types.Game) -> Bool {
  let mut all_met = true
  for i in 0..<game.targets.length() {
    let t = game.targets[i]
    if t.crate_index >= 0 && t.crate_index < game.crates.length() {
      let c = game.crates[t.crate_index]
      if c.active {
        let diff = @types.absf(c.target_y - t.target_height)
        if diff <= t.tolerance {
          c.at_target = true
        } else {
          c.at_target = false
          all_met = false
        }
      }
    }
  }
  all_met
}

///|
pub fn validate_connection(
  game : @types.Game,
  from_id : Int,
  to_id : Int
) -> Bool {
  if from_id == to_id {
    return false
  }
  if from_id < 0 || from_id >= game.nodes.length() {
    return false
  }
  if to_id < 0 || to_id >= game.nodes.length() {
    return false
  }
  for i in 0..<game.ropes.length() {
    if game.ropes[i].active && !game.ropes[i].broken {
      let r = game.ropes[i]
      if (r.from_node == from_id && r.to_node == to_id) ||
        (r.from_node == to_id && r.to_node == from_id) {
        return false
      }
    }
  }
  true
}
