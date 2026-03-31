///|
pub fn check_all_crates_placed(game : @types.Game) -> Bool {
  for i in 0..<game.crates.length() {
    if game.crates[i].active && !game.crates[i].at_target {
      return false
    }
  }
  true
}

///|
pub fn compute_stars(
  connections_used : Int,
  rehooks : Int,
  par_connections : Int,
  par_rehooks : Int
) -> Int {
  // 1 star: complete
  // 2 star: within par connections
  // 3 star: par connections + fewest rehooks
  if connections_used <= par_connections && rehooks <= par_rehooks {
    3
  } else if connections_used <= par_connections {
    2
  } else {
    1
  }
}

///|
pub fn is_rope_valid(
  game : @types.Game,
  from_id : Int,
  to_id : Int
) -> Bool {
  // Basic validation
  if from_id < 0 || to_id < 0 {
    return false
  }
  if from_id >= game.nodes.length() || to_id >= game.nodes.length() {
    return false
  }
  if from_id == to_id {
    return false
  }
  let from_node = game.nodes[from_id]
  let to_node = game.nodes[to_id]
  // At least one must be a pulley, ratchet, or anchor
  let from_ok = from_node.kind == Pulley ||
    from_node.kind == Ratchet ||
    from_node.kind == Anchor
  let to_ok = to_node.kind == Pulley ||
    to_node.kind == Ratchet ||
    to_node.kind == Anchor ||
    to_node.kind == WeightHook ||
    to_node.kind == CrateHook
  if !(from_ok || to_ok) {
    return false
  }
  true
}

///|
pub fn animate_settling(game : @types.Game, dt : Float) -> Bool {
  let mut all_settled = true
  let speed : Float = 4.0
  for i in 0..<game.weights.length() {
    if game.weights[i].active {
      let w = game.weights[i]
      let diff = w.target_y - w.current_y
      if @types.absf(diff) > 0.01 {
        w.current_y = w.current_y + diff * speed * dt
        w.bob_timer = 0.5
        all_settled = false
      } else {
        w.current_y = w.target_y
        if w.bob_timer > 0.0 {
          w.bob_timer = w.bob_timer - dt
        }
      }
    }
  }
  for i in 0..<game.crates.length() {
    if game.crates[i].active {
      let c = game.crates[i]
      let diff = c.target_y - c.current_y
      if @types.absf(diff) > 0.01 {
        c.current_y = c.current_y + diff * speed * dt
        all_settled = false
      } else {
        c.current_y = c.target_y
      }
    }
  }
  for i in 0..<game.buckets.length() {
    if game.buckets[i].active {
      let b = game.buckets[i]
      let diff = b.target_y - b.current_y
      if @types.absf(diff) > 0.01 {
        b.current_y = b.current_y + diff * speed * dt
        all_settled = false
      } else {
        b.current_y = b.target_y
      }
    }
  }
  all_settled
}
