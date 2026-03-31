///|
/// Toggle a power node and all connected subsystems
pub fn toggle_power_node(game : @types.Game, node_index : Int) -> Unit {
  let pn = game.level.power_nodes[node_index]
  pn.powered = !pn.powered
  @types.push_sound(game, Hack)
  // Toggle all connected subsystems
  for i in 0..<pn.connected_ids.length() {
    let cid = pn.connected_ids[i]
    if cid >= 1000 {
      // Camera (offset by 1000)
      let cam_idx = cid - 1000
      if cam_idx < game.level.cameras.length() {
        let cam = game.level.cameras[cam_idx]
        cam.powered = !cam.powered
      }
    } else {
      // Check doors
      toggle_door_by_power_id(game, cid, pn.powered)
      // Check lasers
      toggle_laser_by_power_id(game, cid, pn.powered)
    }
  }
  if pn.powered {
    @types.set_message(game, "Power node activated", 1.5)
  } else {
    @types.set_message(game, "Power node deactivated", 1.5)
  }
}

///|
fn toggle_door_by_power_id(
  game : @types.Game,
  power_id : Int,
  powered : Bool
) -> Unit {
  for i in 0..<game.level.doors.length() {
    let d = game.level.doors[i]
    if d.power_id == power_id {
      d.open = !powered // When power is on, doors are locked; off = unlocked
      d.locked = powered
      if d.open {
        @types.push_sound(game, DoorOpen)
      }
    }
  }
}

///|
fn toggle_laser_by_power_id(
  game : @types.Game,
  power_id : Int,
  powered : Bool
) -> Unit {
  for i in 0..<game.level.lasers.length() {
    let l = game.level.lasers[i]
    if l.power_id == power_id {
      l.active = powered // Lasers active when powered
      if !l.active {
        @types.push_sound(game, LaserOff)
      }
    }
  }
}

///|
/// Check if all terminals in the level have been hacked
pub fn all_terminals_hacked(game : @types.Game) -> Bool {
  for i in 0..<game.level.terminals.length() {
    if !game.level.terminals[i].hacked {
      return false
    }
  }
  true
}

///|
/// Get the total data value of hacked terminals
pub fn hacked_data_value(game : @types.Game) -> Int {
  let mut total = 0
  for i in 0..<game.level.terminals.length() {
    if game.level.terminals[i].hacked {
      total += game.level.terminals[i].data_value
    }
  }
  total
}
