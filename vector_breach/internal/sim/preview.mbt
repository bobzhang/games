// preview.mbt - Command preview system.
// Before confirming, players see exactly what will happen: affected tiles,
// damage, push trajectories. Full information makes the game tactical.

///|
/// Preview a player command: return which tiles will be affected and how.
pub fn preview_command(
  battle : @types.BattleState,
  mech_idx : Int,
  command : @types.Command,
) -> Array[@types.PreviewTile] {
  let result : Array[@types.PreviewTile] = []
  let unit_id = preview_find_player_id(battle, mech_idx)
  if unit_id < 0 {
    return result
  }
  let u = battle.units[unit_id]
  if !u.active || u.hp <= 0 {
    return result
  }
  match command {
    Move(tx, ty) => preview_move(battle, unit_id, tx, ty, result)
    Attack(ability_id, tx, ty) =>
      preview_attack(battle, unit_id, ability_id, tx, ty, result)
    Overclock(ability_id) =>
      preview_overclock(battle, unit_id, ability_id, result)
    Wait => () // Nothing to preview
    Push(tx, ty, dir) => preview_push(battle, unit_id, tx, ty, dir, result)
  }
  result
}

///|
fn preview_find_player_id(battle : @types.BattleState, idx : Int) -> Int {
  let mut count = 0
  for i = 0; i < battle.units.length(); i = i + 1 {
    if battle.units[i].team == Player {
      if count == idx {
        return i
      }
      count += 1
    }
  }
  -1
}

///|
/// Preview a move command.
fn preview_move(
  battle : @types.BattleState,
  unit_id : Int,
  tx : Int,
  ty : Int,
  result : Array[@types.PreviewTile],
) -> Unit {
  let u = battle.units[unit_id]
  let stats = @content.get_mech_stats(u.mech_class)
  let dist = @types.manhattan(u.x, u.y, tx, ty)
  if dist > stats.move_range {
    return
  }
  if !is_walkable(battle, tx, ty) {
    return
  }
  result.push({ x: tx, y: ty, effect: MovePreview, affected_unit: unit_id })
  // Check for hazard at destination
  if battle.grid.in_bounds(tx, ty) {
    let tile = battle.grid.get(tx, ty)
    match tile.hazard {
      None => ()
      _ => result.push({ x: tx, y: ty, effect: HazardPreview, affected_unit: unit_id })
    }
  }
}

///|
/// Preview an attack command.
fn preview_attack(
  battle : @types.BattleState,
  unit_id : Int,
  ability_id : Int,
  tx : Int,
  ty : Int,
  result : Array[@types.PreviewTile],
) -> Unit {
  let u = battle.units[unit_id]
  match u.mech_class {
    Vanguard =>
      if ability_id == 0 {
        preview_vanguard_ram(battle, unit_id, tx, ty, result)
      } else {
        preview_vanguard_tractor(battle, unit_id, tx, ty, result)
      }
    Striker =>
      if ability_id == 0 {
        preview_striker_blade(battle, unit_id, tx, ty, result)
      } else {
        preview_striker_dash(battle, unit_id, tx, ty, result)
      }
    Sentinel =>
      if ability_id == 0 {
        preview_sentinel_cannon(battle, unit_id, tx, ty, result)
      } else {
        preview_sentinel_artillery(battle, unit_id, tx, ty, result)
      }
  }
}

///|
/// Preview Vanguard Ram: show move tile, damage tile, and push trajectory.
fn preview_vanguard_ram(
  battle : @types.BattleState,
  unit_id : Int,
  tx : Int,
  ty : Int,
  result : Array[@types.PreviewTile],
) -> Unit {
  let u = battle.units[unit_id]
  let target_id = unit_at(battle, tx, ty)
  if target_id < 0 {
    return
  }
  let dist = @types.manhattan(u.x, u.y, tx, ty)
  if dist > 3 {
    return
  }
  // Show movement step
  let (sdx, sdy) = step_toward(u.x, u.y, tx, ty)
  let step_x = u.x + sdx
  let step_y = u.y + sdy
  if is_walkable(battle, step_x, step_y) {
    result.push({ x: step_x, y: step_y, effect: MovePreview, affected_unit: unit_id })
  }
  // Show damage on target
  result.push({ x: tx, y: ty, effect: DamagePreview, affected_unit: target_id })
  // Show push trajectory
  let target = battle.units[target_id]
  let pdx = sign(target.x - u.x)
  let pdy = sign(target.y - u.y)
  preview_push_trajectory(battle, target_id, pdx, pdy, 2, result)
}

///|
/// Preview Vanguard Tractor Beam: show pull trajectory.
fn preview_vanguard_tractor(
  battle : @types.BattleState,
  unit_id : Int,
  tx : Int,
  ty : Int,
  result : Array[@types.PreviewTile],
) -> Unit {
  let u = battle.units[unit_id]
  let target_id = unit_at(battle, tx, ty)
  if target_id < 0 {
    return
  }
  let dist = @types.manhattan(u.x, u.y, tx, ty)
  if dist > 4 {
    return
  }
  let target = battle.units[target_id]
  let raw_dx = u.x - target.x
  let raw_dy = u.y - target.y
  let pull_dx = sign(raw_dx)
  let pull_dy = sign(raw_dy)
  result.push({ x: tx, y: ty, effect: PullPreview, affected_unit: target_id })
  preview_push_trajectory(battle, target_id, pull_dx, pull_dy, 2, result)
}

///|
/// Preview Striker Blade: just the damage tile.
fn preview_striker_blade(
  battle : @types.BattleState,
  _unit_id : Int,
  tx : Int,
  ty : Int,
  result : Array[@types.PreviewTile],
) -> Unit {
  let target_id = unit_at(battle, tx, ty)
  if target_id >= 0 {
    result.push({ x: tx, y: ty, effect: DamagePreview, affected_unit: target_id })
  } else {
    result.push({ x: tx, y: ty, effect: DamagePreview, affected_unit: -1 })
  }
}

///|
/// Preview Striker Dash: show dash path and damage.
fn preview_striker_dash(
  battle : @types.BattleState,
  unit_id : Int,
  tx : Int,
  ty : Int,
  result : Array[@types.PreviewTile],
) -> Unit {
  let u = battle.units[unit_id]
  let dist = @types.manhattan(u.x, u.y, tx, ty)
  if dist > 3 {
    return
  }
  let target_id = unit_at(battle, tx, ty)
  if target_id >= 0 {
    // Show stop tile before target
    let (sdx, sdy) = step_toward(u.x, u.y, tx, ty)
    let stop_x = tx - sdx
    let stop_y = ty - sdy
    result.push({ x: stop_x, y: stop_y, effect: MovePreview, affected_unit: unit_id })
    result.push({ x: tx, y: ty, effect: DamagePreview, affected_unit: target_id })
  } else {
    result.push({ x: tx, y: ty, effect: MovePreview, affected_unit: unit_id })
  }
}

///|
/// Preview Sentinel Cannon: LOS line and damage.
fn preview_sentinel_cannon(
  battle : @types.BattleState,
  unit_id : Int,
  tx : Int,
  ty : Int,
  result : Array[@types.PreviewTile],
) -> Unit {
  let u = battle.units[unit_id]
  let dist = @types.manhattan(u.x, u.y, tx, ty)
  if dist > 4 {
    return
  }
  if !has_line_of_sight(battle, u.x, u.y, tx, ty) {
    return
  }
  let target_id = unit_at(battle, tx, ty)
  result.push({
    x: tx,
    y: ty,
    effect: DamagePreview,
    affected_unit: target_id,
  })
}

///|
/// Preview Sentinel Artillery: show all tiles in the 3x3 area.
fn preview_sentinel_artillery(
  battle : @types.BattleState,
  unit_id : Int,
  tx : Int,
  ty : Int,
  result : Array[@types.PreviewTile],
) -> Unit {
  let u = battle.units[unit_id]
  let dist = @types.manhattan(u.x, u.y, tx, ty)
  if dist > 5 {
    return
  }
  for dy = -1; dy <= 1; dy = dy + 1 {
    for dx = -1; dx <= 1; dx = dx + 1 {
      let ax = tx + dx
      let ay = ty + dy
      if battle.grid.in_bounds(ax, ay) {
        let hit_id = unit_at(battle, ax, ay)
        if hit_id >= 0 && hit_id != unit_id {
          result.push({ x: ax, y: ay, effect: DamagePreview, affected_unit: hit_id })
        } else {
          result.push({ x: ax, y: ay, effect: DamagePreview, affected_unit: -1 })
        }
      }
    }
  }
}

///|
/// Preview overclock: same as attack preview but targeting nearest enemy.
fn preview_overclock(
  battle : @types.BattleState,
  unit_id : Int,
  ability_id : Int,
  result : Array[@types.PreviewTile],
) -> Unit {
  let u = battle.units[unit_id]
  let target_id = find_nearest_unit(battle, u.x, u.y, Enemy)
  if target_id >= 0 {
    let target = battle.units[target_id]
    preview_attack(battle, unit_id, ability_id, target.x, target.y, result)
  }
}

///|
/// Preview a push command.
fn preview_push(
  battle : @types.BattleState,
  _unit_id : Int,
  tx : Int,
  ty : Int,
  dir : Int,
  result : Array[@types.PreviewTile],
) -> Unit {
  let target_id = unit_at(battle, tx, ty)
  if target_id < 0 {
    return
  }
  let (dx, dy) = preview_decode_dir(dir)
  result.push({ x: tx, y: ty, effect: PushPreview, affected_unit: target_id })
  preview_push_trajectory(battle, target_id, dx, dy, 2, result)
}

///|
fn preview_decode_dir(dir : Int) -> (Int, Int) {
  match dir {
    0 => (0, -1)
    1 => (0, 1)
    2 => (1, 0)
    _ => (-1, 0)
  }
}

///|
/// Trace a push trajectory and add preview tiles.
/// Simulates push physics without modifying state.
fn preview_push_trajectory(
  battle : @types.BattleState,
  unit_id : Int,
  dx : Int,
  dy : Int,
  distance : Int,
  result : Array[@types.PreviewTile],
) -> Unit {
  let u = battle.units[unit_id]
  let mut cx = u.x
  let mut cy = u.y
  for step = 0; step < distance; step = step + 1 {
    let nx = cx + dx
    let ny = cy + dy
    if !battle.grid.in_bounds(nx, ny) {
      // Would slam into edge
      result.push({ x: cx, y: cy, effect: CollisionPreview, affected_unit: unit_id })
      return
    }
    let tile = battle.grid.get(nx, ny)
    if tile.kind == Wall {
      result.push({ x: cx, y: cy, effect: CollisionPreview, affected_unit: unit_id })
      return
    }
    if tile.kind == Chasm {
      result.push({ x: nx, y: ny, effect: KillPreview, affected_unit: unit_id })
      return
    }
    if tile.occupied_by >= 0 && tile.occupied_by != unit_id {
      result.push({
        x: nx,
        y: ny,
        effect: CollisionPreview,
        affected_unit: tile.occupied_by,
      })
      return
    }
    result.push({ x: nx, y: ny, effect: PushPreview, affected_unit: unit_id })
    cx = nx
    cy = ny
  }
}

///|
/// Preview enemy intents: show all tiles that will be affected next turn.
pub fn preview_enemy_intents(
  battle : @types.BattleState,
) -> Array[@types.PreviewTile] {
  let result : Array[@types.PreviewTile] = []
  for i = 0; i < battle.units.length(); i = i + 1 {
    let u = battle.units[i]
    if u.active && u.hp > 0 && u.team == Enemy && !u.stunned {
      preview_single_intent(battle, i, result)
    }
  }
  result
}

///|
/// Preview a single enemy's intent.
fn preview_single_intent(
  battle : @types.BattleState,
  unit_id : Int,
  result : Array[@types.PreviewTile],
) -> Unit {
  let u = battle.units[unit_id]
  match u.intent {
    March(tx, ty) =>
      result.push({ x: tx, y: ty, effect: MovePreview, affected_unit: unit_id })
    Charge(dx, dy) => {
      let mut cx = u.x + dx
      let mut cy = u.y + dy
      let mut steps = 0
      while steps < 4 && battle.grid.in_bounds(cx, cy) {
        let tile = battle.grid.get(cx, cy)
        if tile.kind == Wall {
          break
        }
        if tile.occupied_by >= 0 {
          result.push({
            x: cx,
            y: cy,
            effect: DamagePreview,
            affected_unit: tile.occupied_by,
          })
          break
        }
        result.push({ x: cx, y: cy, effect: MovePreview, affected_unit: unit_id })
        cx += dx
        cy += dy
        steps += 1
      }
    }
    FireLine(dx, dy, range) => {
      let mut cx = u.x + dx
      let mut cy = u.y + dy
      let mut steps = 0
      while steps < range && battle.grid.in_bounds(cx, cy) {
        let tile = battle.grid.get(cx, cy)
        if tile.kind == Wall {
          break
        }
        if tile.occupied_by >= 0 {
          result.push({
            x: cx,
            y: cy,
            effect: DamagePreview,
            affected_unit: tile.occupied_by,
          })
        } else {
          result.push({ x: cx, y: cy, effect: DamagePreview, affected_unit: -1 })
        }
        cx += dx
        cy += dy
        steps += 1
      }
    }
    Leap(tx, ty) => {
      result.push({ x: tx, y: ty, effect: MovePreview, affected_unit: unit_id })
      // Show adjacent damage tiles
      let dx_arr = [0, 0, 1, -1]
      let dy_arr = [-1, 1, 0, 0]
      for d = 0; d < 4; d = d + 1 {
        let ax = tx + dx_arr[d]
        let ay = ty + dy_arr[d]
        if battle.grid.in_bounds(ax, ay) {
          let hit_id = unit_at(battle, ax, ay)
          if hit_id >= 0 {
            let hit_unit = battle.units[hit_id]
            if hit_unit.team == Player && hit_unit.active {
              result.push({ x: ax, y: ay, effect: DamagePreview, affected_unit: hit_id })
            }
          }
        }
      }
    }
    AreaBlast(tx, ty, radius) => {
      for dy = -radius; dy <= radius; dy = dy + 1 {
        for dx = -radius; dx <= radius; dx = dx + 1 {
          let ax = tx + dx
          let ay = ty + dy
          if battle.grid.in_bounds(ax, ay) {
            let hit_id = unit_at(battle, ax, ay)
            result.push({
              x: ax,
              y: ay,
              effect: DamagePreview,
              affected_unit: hit_id,
            })
          }
        }
      }
    }
    Summon(tx, ty, _amount) =>
      result.push({ x: tx, y: ty, effect: MovePreview, affected_unit: -1 })
    MinePlace(tx, ty) =>
      result.push({ x: tx, y: ty, effect: HazardPreview, affected_unit: -1 })
  }
}
