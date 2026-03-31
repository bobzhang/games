///|
pub fn step(game : @types.Game) -> Unit {
  let level = match game.current_level {
    None => return
    Some(l) => l
  }
  if game.play_state != Moving {
    return
  }
  // Save current state for undo
  @types.save_history(game)
  game.steps += 1
  // Compute new positions
  let new_cw = game.cw_pos + 1
  let new_ccw = game.ccw_pos + 1
  let cw_len = level.cw_spiral.cells.length()
  let ccw_len = level.ccw_spiral.cells.length()
  // Check if CW is blocked by closed gate
  let cw_blocked = if new_cw < cw_len {
    let cell = level.cw_spiral.cells[new_cw]
    cell.kind == Gate && !cell.gate_open
  } else {
    false
  }
  // Check if CCW is blocked by closed gate
  let ccw_blocked = if new_ccw < ccw_len {
    let cell = level.ccw_spiral.cells[new_ccw]
    cell.kind == Gate && !cell.gate_open
  } else {
    false
  }
  // Move tokens that are not blocked (and not already at end)
  if !cw_blocked && new_cw < cw_len {
    game.cw_pos = new_cw
  }
  if !ccw_blocked && new_ccw < ccw_len {
    game.ccw_pos = new_ccw
  }
  // Check sync points - both must be on sync points at the same time
  let cw_on_sync = game.cw_pos < cw_len &&
    level.cw_spiral.cells[game.cw_pos].kind == SyncPoint
  let ccw_on_sync = game.ccw_pos < ccw_len &&
    level.ccw_spiral.cells[game.ccw_pos].kind == SyncPoint
  if cw_on_sync && !ccw_on_sync {
    // CW is stuck on sync, push it back
    game.cw_pos = game.cw_pos
    // CW stays, but is blocked next step
  }
  if ccw_on_sync && !cw_on_sync {
    game.ccw_pos = game.ccw_pos
  }
  // Process switches on CW spiral
  if game.cw_pos < cw_len {
    let cell = level.cw_spiral.cells[game.cw_pos]
    if cell.kind == Switch {
      toggle_linked_gates(level, cell.switch_link_id)
    }
    if cell.kind == OneShotSwitch {
      let link_id = cell.switch_link_id
      if link_id >= 0 && link_id < game.oneshot_used.length() {
        if !game.oneshot_used[link_id] {
          game.oneshot_used[link_id] = true
          open_linked_gates(level, link_id)
        }
      }
    }
  }
  // Process switches on CCW spiral
  if game.ccw_pos < ccw_len {
    let cell = level.ccw_spiral.cells[game.ccw_pos]
    if cell.kind == Switch {
      toggle_linked_gates(level, cell.switch_link_id)
    }
    if cell.kind == OneShotSwitch {
      let link_id = cell.switch_link_id
      if link_id >= 0 && link_id < game.oneshot_used.length() {
        if !game.oneshot_used[link_id] {
          game.oneshot_used[link_id] = true
          open_linked_gates(level, link_id)
        }
      }
    }
  }
  // Apply arrow offsets after landing
  if game.cw_pos < cw_len {
    let offset = level.cw_spiral.cells[game.cw_pos].arrow_offset
    if offset != 0 {
      let adj = game.cw_pos + offset
      if adj >= 0 && adj < cw_len {
        game.cw_pos = adj
      }
    }
  }
  if game.ccw_pos < ccw_len {
    let offset = level.ccw_spiral.cells[game.ccw_pos].arrow_offset
    if offset != 0 {
      let adj = game.ccw_pos + offset
      if adj >= 0 && adj < ccw_len {
        game.ccw_pos = adj
      }
    }
  }
  // Collect pickups
  if game.cw_pos < cw_len {
    if level.cw_spiral.cells[game.cw_pos].has_pickup {
      let idx = game.cw_pos
      if idx < game.pickups_collected.length() && !game.pickups_collected[idx] {
        game.pickups_collected[idx] = true
        game.pickups_count += 1
      }
    }
  }
  if game.ccw_pos < ccw_len {
    if level.ccw_spiral.cells[game.ccw_pos].has_pickup {
      let idx = cw_len + game.ccw_pos
      if idx < game.pickups_collected.length() && !game.pickups_collected[idx] {
        game.pickups_collected[idx] = true
        game.pickups_count += 1
      }
    }
  }
  // Check win condition: both at last cell
  let cw_at_end = game.cw_pos >= cw_len - 1
  let ccw_at_end = game.ccw_pos >= ccw_len - 1
  if cw_at_end && ccw_at_end {
    game.play_state = Won
  }
}

///|
fn toggle_linked_gates(level : @types.Level, link_id : Int) -> Unit {
  for i in 0..<level.switch_links.length() {
    let link = level.switch_links[i]
    if i == link_id {
      // Toggle gates on CW spiral
      for j in 0..<link.gate_cells_cw.length() {
        let ci = link.gate_cells_cw[j]
        if ci >= 0 && ci < level.cw_spiral.cells.length() {
          level.cw_spiral.cells[ci].gate_open = !level.cw_spiral.cells[ci].gate_open
        }
      }
      // Toggle gates on CCW spiral
      for j in 0..<link.gate_cells_ccw.length() {
        let ci = link.gate_cells_ccw[j]
        if ci >= 0 && ci < level.ccw_spiral.cells.length() {
          level.ccw_spiral.cells[ci].gate_open = !level.ccw_spiral.cells[ci].gate_open
        }
      }
    }
  }
}

///|
fn open_linked_gates(level : @types.Level, link_id : Int) -> Unit {
  for i in 0..<level.switch_links.length() {
    let link = level.switch_links[i]
    if i == link_id {
      for j in 0..<link.gate_cells_cw.length() {
        let ci = link.gate_cells_cw[j]
        if ci >= 0 && ci < level.cw_spiral.cells.length() {
          level.cw_spiral.cells[ci].gate_open = true
        }
      }
      for j in 0..<link.gate_cells_ccw.length() {
        let ci = link.gate_cells_ccw[j]
        if ci >= 0 && ci < level.ccw_spiral.cells.length() {
          level.ccw_spiral.cells[ci].gate_open = true
        }
      }
    }
  }
}

///|
pub fn check_blocked(game : @types.Game) -> Bool {
  let level = match game.current_level {
    None => return false
    Some(l) => l
  }
  let cw_len = level.cw_spiral.cells.length()
  let ccw_len = level.ccw_spiral.cells.length()
  let cw_at_end = game.cw_pos >= cw_len - 1
  let ccw_at_end = game.ccw_pos >= ccw_len - 1
  if cw_at_end && ccw_at_end {
    return false
  }
  // Check if next step for non-finished tokens is blocked
  let cw_next_blocked = if !cw_at_end {
    let next = game.cw_pos + 1
    if next < cw_len {
      let cell = level.cw_spiral.cells[next]
      cell.kind == Gate && !cell.gate_open
    } else {
      false
    }
  } else {
    false
  }
  let ccw_next_blocked = if !ccw_at_end {
    let next = game.ccw_pos + 1
    if next < ccw_len {
      let cell = level.ccw_spiral.cells[next]
      cell.kind == Gate && !cell.gate_open
    } else {
      false
    }
  } else {
    false
  }
  // Blocked only if both non-finished tokens are stuck
  let cw_stuck = cw_at_end || cw_next_blocked
  let ccw_stuck = ccw_at_end || ccw_next_blocked
  cw_stuck && ccw_stuck && !(cw_at_end && ccw_at_end)
}
