// undo.mbt - Snapshot/restore system for undoing commands before turn confirm.

///|
/// Save a snapshot of battle state before executing a command.
pub fn save_snapshot(battle : @types.BattleState) -> @types.BattleSnapshot {
  let unit_states : Array[@types.UnitSnapshot] = []
  for i = 0; i < battle.units.length(); i = i + 1 {
    let u = battle.units[i]
    let statuses_copy : Array[@types.StatusEffect] = []
    for j = 0; j < u.statuses.length(); j = j + 1 {
      statuses_copy.push(u.statuses[j])
    }
    unit_states.push(
      {
        id: u.id,
        active: u.active,
        x: u.x,
        y: u.y,
        hp: u.hp,
        max_hp: u.max_hp,
        shield: u.shield,
        heat: u.heat,
        max_heat: u.max_heat,
        stunned: u.stunned,
        moved_this_turn: u.moved_this_turn,
        acted_this_turn: u.acted_this_turn,
        statuses: statuses_copy,
      },
    )
  }
  let tile_states : Array[@types.Tile] = []
  for i = 0; i < battle.grid.tiles.length(); i = i + 1 {
    let t = battle.grid.tiles[i]
    tile_states.push({ kind: t.kind, hazard: t.hazard, occupied_by: t.occupied_by })
  }
  let cmds : Array[@types.Command] = []
  for i = 0; i < battle.player_commands.length(); i = i + 1 {
    cmds.push(battle.player_commands[i])
  }
  {
    unit_states,
    tile_states,
    grid_width: battle.grid.width,
    grid_height: battle.grid.height,
    selected_mech: battle.selected_mech,
    cursor_x: battle.cursor_x,
    cursor_y: battle.cursor_y,
    commands: cmds,
  }
}

///|
/// Restore a battle state from a snapshot.
pub fn restore_snapshot(
  battle : @types.BattleState,
  snap : @types.BattleSnapshot,
) -> Unit {
  // Restore unit states
  for i = 0; i < snap.unit_states.length() && i < battle.units.length(); i = i + 1 {
    let u = battle.units[i]
    let s = snap.unit_states[i]
    u.active = s.active
    u.x = s.x
    u.y = s.y
    u.hp = s.hp
    u.max_hp = s.max_hp
    u.shield = s.shield
    u.heat = s.heat
    u.max_heat = s.max_heat
    u.stunned = s.stunned
    u.moved_this_turn = s.moved_this_turn
    u.acted_this_turn = s.acted_this_turn
    u.statuses = []
    for j = 0; j < s.statuses.length(); j = j + 1 {
      u.statuses.push(s.statuses[j])
    }
  }
  // Restore grid tiles
  for i = 0; i < snap.tile_states.length() && i < battle.grid.tiles.length(); i = i + 1 {
    let t = snap.tile_states[i]
    battle.grid.tiles[i] = { kind: t.kind, hazard: t.hazard, occupied_by: t.occupied_by }
  }
  // Restore commands
  battle.player_commands = []
  for i = 0; i < snap.commands.length(); i = i + 1 {
    battle.player_commands.push(snap.commands[i])
  }
  battle.selected_mech = snap.selected_mech
  battle.cursor_x = snap.cursor_x
  battle.cursor_y = snap.cursor_y
}

///|
/// Push a snapshot onto the undo stack.
pub fn push_undo(battle : @types.BattleState) -> Unit {
  let snap = save_snapshot(battle)
  battle.undo_stack.push(snap)
}

///|
/// Pop and restore the last snapshot. Returns true if undo succeeded.
pub fn pop_undo(battle : @types.BattleState) -> Bool {
  if battle.undo_stack.length() > 0 {
    let snap = battle.undo_stack.pop()
    match snap {
      Some(s) => {
        restore_snapshot(battle, s)
        true
      }
      None => false
    }
  } else {
    false
  }
}

///|
/// Clear the undo stack (at start of turn or turn confirmation).
pub fn clear_undo_stack(battle : @types.BattleState) -> Unit {
  battle.undo_stack = []
}
