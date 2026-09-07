// effects.mbt - Pure state-mutation functions for the simulation.
// Push/pull physics is the central mechanic of Vector Breach.

///|
/// Move a unit on the grid, updating tile occupancy.
pub fn move_unit_to(
  battle : @types.BattleState,
  unit_id : Int,
  nx : Int,
  ny : Int,
) -> Unit {
  let u = battle.units[unit_id]
  // Clear old tile
  if battle.grid.in_bounds(u.x, u.y) {
    let old_tile = battle.grid.get(u.x, u.y)
    if old_tile.occupied_by == unit_id {
      battle.grid.set(u.x, u.y, { ..old_tile, occupied_by: -1, })
    }
  }
  // Set new position
  u.x = nx
  u.y = ny
  // Mark new tile
  if battle.grid.in_bounds(nx, ny) {
    battle.grid.set(nx, ny, { ..battle.grid.get(nx, ny), occupied_by: unit_id, })
  }
}

///|
/// Deal damage to a unit, respecting shields. Returns actual damage dealt.
/// Optional attacker_id is used for augment effects (chain lightning, vampire core).
pub fn apply_damage(
  battle : @types.BattleState,
  unit_id : Int,
  amount : Int,
) -> Int {
  apply_damage_from(battle, unit_id, amount, -1)
}

///|
/// Deal damage from a specific attacker. Enables augment triggers.
pub fn apply_damage_from(
  battle : @types.BattleState,
  unit_id : Int,
  amount : Int,
  attacker_id : Int,
) -> Int {
  if unit_id < 0 || unit_id >= battle.units.length() {
    return 0
  }
  let u = battle.units[unit_id]
  if !u.active || u.hp <= 0 {
    return 0
  }
  let mut remaining = amount
  // Hivemind Phase 1: damage to boss is halved while minions are alive
  if u.enemy_type == Boss &&
    battle.mission_id == 8 &&
    battle.boss_phase == 1 &&
    hivemind_has_minions(battle) {
    remaining = remaining / 2
    if remaining < 1 && amount > 0 {
      remaining = 1
    }
    battle.turn_log.push("Hivemind link halves damage to \{remaining}!")
  }
  // Shield absorbs first
  if u.shield > 0 {
    if u.shield >= remaining {
      u.shield -= remaining
      battle.turn_log.push(
        "Shield absorbs \{remaining} damage on unit \{unit_id}",
      )
      return 0
    }
    remaining -= u.shield
    battle.turn_log.push("Shield absorbs \{u.shield} damage on unit \{unit_id}")
    u.shield = 0
  }
  u.hp -= remaining
  // Track damage taken by player for FLAWLESS combo
  if u.team == Player && remaining > 0 {
    battle.damage_taken_this_turn = true
  }
  // Normal hit FX
  if remaining > 0 {
    @types.emit_hitstop(battle, 0.06)
    @types.emit_shake(battle, 2.0)
  }
  let was_killed = u.hp <= 0
  if was_killed {
    u.hp = 0
    kill_unit(battle, unit_id)
    // VampireCore augment: heal attacker 1 HP on kill
    if attacker_id >= 0 && attacker_id < battle.units.length() {
      let attacker = battle.units[attacker_id]
      if attacker.active &&
        attacker.team == Player &&
        @types.battle_has_augment(battle, VampireCore) {
        apply_vampire_heal(battle, attacker_id)
      }
    }
  }
  remaining
}

///|
/// VampireCore heal effect: heal 1 HP on kill (capped at max).
fn apply_vampire_heal(battle : @types.BattleState, unit_id : Int) -> Unit {
  let u = battle.units[unit_id]
  if u.hp < u.max_hp {
    u.hp += 1
    let name = get_unit_name(battle, unit_id)
    battle.turn_log.push("\{name} drains 1 HP (Vampire Core)")
  }
}

///|
/// ChainLightning effect: after dealing damage, check for adjacent enemies
/// and deal 1 damage to the first one found.
pub fn apply_chain_lightning(
  battle : @types.BattleState,
  target_id : Int,
  attacker_id : Int,
) -> Unit {
  if target_id < 0 || target_id >= battle.units.length() {
    return
  }
  let target = battle.units[target_id]
  if !target.active {
    return
  }
  let dx_arr = [0, 0, 1, -1]
  let dy_arr = [-1, 1, 0, 0]
  for d = 0; d < 4; d = d + 1 {
    let nx = target.x + dx_arr[d]
    let ny = target.y + dy_arr[d]
    let adj_id = unit_at(battle, nx, ny)
    if adj_id >= 0 && adj_id != attacker_id && adj_id != target_id {
      let adj = battle.units[adj_id]
      if adj.active && adj.hp > 0 && adj.team == Enemy {
        let adj_name = get_unit_name(battle, adj_id)
        let _ = apply_damage(battle, adj_id, 1)
        battle.turn_log.push(
          "Chain Lightning arcs to \{adj_name} for 1 damage!",
        )
        return // Only chain to one enemy
      }
    }
  }
}

///|
/// EmergencyRepair: auto-heal 1 HP when below 25%.
pub fn check_emergency_repair(
  battle : @types.BattleState,
  unit_id : Int,
) -> Unit {
  if unit_id < 0 || unit_id >= battle.units.length() {
    return
  }
  let u = battle.units[unit_id]
  if !u.active || u.hp <= 0 {
    return
  }
  // Below 25% means hp < max_hp / 4 (at least 1)
  let threshold = if u.max_hp / 4 > 0 { u.max_hp / 4 } else { 1 }
  if u.hp <= threshold && u.hp > 0 {
    u.hp += 1
    let name = get_unit_name(battle, unit_id)
    battle.turn_log.push(
      "\{name} emergency repair! +1 HP (\{u.hp}/\{u.max_hp})",
    )
  }
}

///|
/// Kill a unit - mark inactive and clear grid occupancy.
/// Emits kill flourish: ring + slowmo + floating text.
pub fn kill_unit(battle : @types.BattleState, unit_id : Int) -> Unit {
  let u = battle.units[unit_id]
  let kill_x = u.x
  let kill_y = u.y
  let is_enemy = u.team == Enemy
  u.active = false
  u.hp = 0
  // Clear tile
  if battle.grid.in_bounds(u.x, u.y) {
    let tile = battle.grid.get(u.x, u.y)
    if tile.occupied_by == unit_id {
      battle.grid.set(u.x, u.y, { ..tile, occupied_by: -1, })
    }
  }
  let name = get_unit_name(battle, unit_id)
  battle.turn_log.push("\{name} is destroyed!")
  // Kill flourish: hitstop + slowmo + ring + text
  @types.emit_hitstop(battle, 0.06)
  @types.emit_slowmo(battle, 0.2)
  @types.emit_shake(battle, 3.0)
  let (r, g, b) = if is_enemy { (80, 140, 255) } else { (220, 60, 60) }
  @types.emit_ring(battle, kill_x, kill_y, 45.0, 0.5, r, g, b)
  @types.emit_float_text(battle, kill_x, kill_y, "+KILL", r, g, b, 1.5, true)
}

///|
/// Apply shield to a unit.
pub fn apply_shield(
  battle : @types.BattleState,
  unit_id : Int,
  amount : Int,
) -> Unit {
  if unit_id < 0 || unit_id >= battle.units.length() {
    return
  }
  let u = battle.units[unit_id]
  if !u.active {
    return
  }
  u.shield += amount
  let name = get_unit_name(battle, unit_id)
  battle.turn_log.push("\{name} gains \{amount} shield")
}

///|
/// Stun a unit - it will skip its next action.
pub fn apply_stun(battle : @types.BattleState, unit_id : Int) -> Unit {
  if unit_id < 0 || unit_id >= battle.units.length() {
    return
  }
  let u = battle.units[unit_id]
  if !u.active {
    return
  }
  u.stunned = true
  let name = get_unit_name(battle, unit_id)
  battle.turn_log.push("\{name} is stunned!")
}

///|
/// Add heat to a unit.
pub fn apply_heat(
  battle : @types.BattleState,
  unit_id : Int,
  amount : Int,
) -> Unit {
  if unit_id < 0 || unit_id >= battle.units.length() {
    return
  }
  let u = battle.units[unit_id]
  u.heat += amount
  if u.heat > u.max_heat {
    // Overheated: stun and reset
    u.heat = 0
    apply_stun(battle, unit_id)
    let name = get_unit_name(battle, unit_id)
    battle.turn_log.push("\{name} overheated!")
  }
}

///|
/// Push a unit in direction (dx, dy) for up to `distance` tiles.
/// Handles wall collision, chasm kills, chain pushes, ice sliding,
/// lava burn, water immobilize, mine trigger, and environmental combos.
/// OverchargedPush augment adds +1 distance.
pub fn try_push(
  battle : @types.BattleState,
  unit_id : Int,
  dx : Int,
  dy : Int,
  distance : Int,
) -> Unit {
  if unit_id < 0 || unit_id >= battle.units.length() {
    return
  }
  let u = battle.units[unit_id]
  if !u.active || u.hp <= 0 {
    return
  }
  let name = get_unit_name(battle, unit_id)
  let bonus = if @types.battle_has_augment(battle, OverchargedPush) {
    1
  } else {
    0
  }
  let mut steps_remaining = distance + bonus
  while steps_remaining > 0 {
    let nx = u.x + dx
    let ny = u.y + dy
    // Hit edge of map
    if !battle.grid.in_bounds(nx, ny) {
      let _ = apply_damage(battle, unit_id, 1)
      battle.turn_log.push("\{name} slams into the edge!")
      // Wall collision FX
      @types.emit_hitstop(battle, 0.08)
      @types.emit_shake(battle, 4.0)
      return
    }
    let tile = battle.grid.get(nx, ny)
    // Hit a wall
    if tile.kind == Wall {
      // Check: wall adjacent to chasm -> wall falls, creating new chasm
      let wall_nx = nx + dx
      let wall_ny = ny + dy
      if battle.grid.in_bounds(wall_nx, wall_ny) {
        let beyond = battle.grid.get(wall_nx, wall_ny)
        if beyond.kind == Chasm {
          battle.grid.set(nx, ny, {
            kind: Chasm,
            hazard: None,
            occupied_by: -1,
          })
          battle.turn_log.push("Wall crumbles into the chasm!")
        }
      }
      let _ = apply_damage(battle, unit_id, 1)
      battle.turn_log.push("\{name} slams into a wall!")
      // Push-into-wall collision FX
      @types.emit_hitstop(battle, 0.08)
      @types.emit_shake(battle, 4.0)
      @types.emit_flash(battle, 255, 200, 100, 60)
      return
    }
    // Fall into chasm
    if tile.kind == Chasm {
      battle.turn_log.push("\{name} falls into a chasm!")
      // Combo: VOID KILL for enemies pushed into chasm
      if u.team == Enemy {
        add_combo_score(battle, 200, "VOID KILL!")
      }
      // Chasm kill FX: bigger hitstop + slowmo
      @types.emit_hitstop(battle, 0.12)
      @types.emit_slowmo(battle, 0.3)
      @types.emit_shake(battle, 5.0)
      @types.emit_ring(battle, nx, ny, 60.0, 0.6, 100, 40, 180)
      kill_unit(battle, unit_id)
      return
    }
    // Hit another unit - collision
    if tile.occupied_by >= 0 && tile.occupied_by != unit_id {
      let other_id = tile.occupied_by
      let other_name = get_unit_name(battle, other_id)
      let _ = apply_damage(battle, unit_id, 1)
      let _ = apply_damage(battle, other_id, 1)
      battle.turn_log.push("\{name} collides with \{other_name}!")
      // Collision burst FX
      @types.emit_hitstop(battle, 0.08)
      @types.emit_shake(battle, 4.0 + Float::from_int(distance))
      @types.emit_flash(battle, 255, 200, 100, 60)
      // Combo: CHAIN! for pushing enemy into another (escalating)
      if u.team == Enemy {
        add_combo_score(battle, 100, "CHAIN!")
        @types.emit_float_text(
          battle,
          nx,
          ny,
          "CHAIN x\{distance}!",
          255,
          200,
          40,
          1.0 + Float::from_int(distance) * 0.15,
          true,
        )
      }
      // Chain push: the blocking unit gets pushed 1 tile
      try_push(battle, other_id, dx, dy, 1)
      return
    }
    // Move to new tile
    move_unit_to(battle, unit_id, nx, ny)
    steps_remaining -= 1
    // Environmental interactions on landing tile
    match tile.kind {
      Lava => {
        // Lava: 3 damage + on-fire status (1 damage/turn for 2 turns)
        let _ = apply_damage(battle, unit_id, 3)
        battle.turn_log.push("\{name} is pushed into lava for 3 damage!")
        apply_status(battle, unit_id, OnFire(2))
      }
      Water => {
        // Water: immobilized for 1 turn
        battle.turn_log.push("\{name} is pushed into water! Immobilized!")
        apply_status(battle, unit_id, Immobilized(1))
        return // Stop movement in water
      }
      Ice =>
        // Ice: keep sliding until hitting wall/unit
        if steps_remaining == 0 {
          steps_remaining = 1
          battle.turn_log.push("\{name} slides on ice!")
        }
      _ => ()
    }
    // Mine hazard on tile
    if tile.hazard == Mine {
      let _ = apply_damage(battle, unit_id, 3)
      battle.turn_log.push("\{name} pushed onto a mine! 3 damage!")
      battle.grid.set(nx, ny, { ..battle.grid.get(nx, ny), hazard: None, })
      return
    }
    // Fire on ice -> melts to water
    if tile.kind == Ice && tile.hazard == Fire {
      battle.grid.set(nx, ny, {
        kind: Water,
        hazard: None,
        occupied_by: battle.grid.get(nx, ny).occupied_by,
      })
      battle.turn_log.push("Fire melts ice into water!")
    }
  }
}

///|
/// Apply a status effect to a unit.
pub fn apply_status(
  battle : @types.BattleState,
  unit_id : Int,
  status : @types.StatusEffect,
) -> Unit {
  if unit_id < 0 || unit_id >= battle.units.length() {
    return
  }
  let u = battle.units[unit_id]
  if !u.active {
    return
  }
  u.statuses.push(status)
}

///|
/// Process status effects at end of turn (fire damage, immobilize expiry).
pub fn process_statuses(battle : @types.BattleState) -> Unit {
  for i = 0; i < battle.units.length(); i = i + 1 {
    let u = battle.units[i]
    if !u.active || u.hp <= 0 {
      continue i + 1
    }
    let name = get_unit_name(battle, i)
    let mut j = 0
    while j < u.statuses.length() {
      match u.statuses[j] {
        OnFire(turns) => {
          let _ = apply_damage(battle, i, 1)
          battle.turn_log.push("\{name} burns for 1 fire damage!")
          if turns <= 1 {
            let _ = u.statuses.remove(j)
          } else {
            u.statuses[j] = OnFire(turns - 1)
            j += 1
          }
        }
        Immobilized(turns) =>
          if turns <= 1 {
            let _ = u.statuses.remove(j)
            battle.turn_log.push("\{name} is no longer immobilized.")
          } else {
            u.statuses[j] = Immobilized(turns - 1)
            j += 1
          }
      }
    }
  }
}

///|
/// Check if a unit is immobilized.
pub fn is_immobilized(u : @types.CombatUnit) -> Bool {
  for i = 0; i < u.statuses.length(); i = i + 1 {
    match u.statuses[i] {
      Immobilized(_) => return true
      _ => ()
    }
  }
  false
}

///|
/// Add combo score with floating text and gold glow popoff.
pub fn add_combo_score(
  battle : @types.BattleState,
  points : Int,
  text : String,
) -> Unit {
  battle.score += points
  battle.combo_text = text
  battle.combo_timer = 2.0
  battle.turn_log.push("+\{points} \{text}")
  // Gold glow popoff at grid center
  let cx = @types.grid_w / 2
  let cy = @types.grid_h / 2
  @types.emit_float_text(
    battle,
    cx,
    cy,
    "+\{points} \{text}",
    255,
    220,
    40,
    1.5,
    true,
  )
}

///|
/// Pull a unit toward position (px, py) by up to `distance` tiles.
/// Pull direction is computed from unit toward puller.
pub fn try_pull(
  battle : @types.BattleState,
  unit_id : Int,
  toward_x : Int,
  toward_y : Int,
  distance : Int,
) -> Unit {
  if unit_id < 0 || unit_id >= battle.units.length() {
    return
  }
  let u = battle.units[unit_id]
  if !u.active || u.hp <= 0 {
    return
  }
  // Compute direction from unit toward puller
  let raw_dx = toward_x - u.x
  let raw_dy = toward_y - u.y
  // Normalize to unit direction (-1, 0, 1)
  let dx = sign(raw_dx)
  let dy = sign(raw_dy)
  if dx == 0 && dy == 0 {
    return
  }
  // Pull uses same physics as push, just in the opposite conceptual direction
  try_push(battle, unit_id, dx, dy, distance)
}

///|
/// Place a hazard on a tile.
pub fn place_hazard(
  battle : @types.BattleState,
  x : Int,
  y : Int,
  hazard : @types.HazardKind,
) -> Unit {
  if !battle.grid.in_bounds(x, y) {
    return
  }
  let tile = battle.grid.get(x, y)
  if tile.kind == Wall || tile.kind == Chasm {
    return
  }
  battle.grid.set(x, y, { ..tile, hazard, })
}

///|
/// Get a display name for a unit.
pub fn get_unit_name(battle : @types.BattleState, unit_id : Int) -> String {
  if unit_id < 0 || unit_id >= battle.units.length() {
    return "Unknown"
  }
  let u = battle.units[unit_id]
  match u.team {
    Player => {
      let stats = @content.get_mech_stats(u.mech_class)
      stats.name
    }
    Enemy => @content.get_enemy_name(u.enemy_type)
  }
}

///|
/// Utility: sign of an integer (-1, 0, 1).
pub fn sign(v : Int) -> Int {
  if v > 0 {
    1
  } else if v < 0 {
    -1
  } else {
    0
  }
}

///|
/// Find the unit occupying a tile, or -1.
pub fn unit_at(battle : @types.BattleState, x : Int, y : Int) -> Int {
  if !battle.grid.in_bounds(x, y) {
    return -1
  }
  battle.grid.get(x, y).occupied_by
}

///|
/// Check if a tile is walkable (floor-like, not wall/chasm, not occupied).
pub fn is_walkable(battle : @types.BattleState, x : Int, y : Int) -> Bool {
  if !battle.grid.in_bounds(x, y) {
    return false
  }
  let tile = battle.grid.get(x, y)
  match tile.kind {
    Wall | Chasm => false
    _ => tile.occupied_by < 0
  }
}

///|
/// Check if a tile blocks movement (wall or out of bounds).
pub fn is_blocked(battle : @types.BattleState, x : Int, y : Int) -> Bool {
  if !battle.grid.in_bounds(x, y) {
    return true
  }
  let tile = battle.grid.get(x, y)
  tile.kind == Wall
}

///|
/// Check line of sight between two points (Bresenham-style).
/// Returns true if no wall tiles block the path.
pub fn has_line_of_sight(
  battle : @types.BattleState,
  x1 : Int,
  y1 : Int,
  x2 : Int,
  y2 : Int,
) -> Bool {
  let mut cx = x1
  let mut cy = y1
  let adx = @types.abs_int(x2 - x1)
  let ady = @types.abs_int(y2 - y1)
  let sx = sign(x2 - x1)
  let sy = sign(y2 - y1)
  let mut err = adx - ady
  while cx != x2 || cy != y2 {
    // Check current tile (skip start)
    if (cx != x1 || cy != y1) && battle.grid.in_bounds(cx, cy) {
      let tile = battle.grid.get(cx, cy)
      if tile.kind == Wall {
        return false
      }
    }
    let e2 = err * 2
    if e2 > -ady {
      err -= ady
      cx += sx
    }
    if e2 < adx {
      err += adx
      cy += sy
    }
  }
  true
}

///|
/// Find the nearest unit of a given team to position (x, y).
/// Returns the unit id, or -1 if none found.
pub fn find_nearest_unit(
  battle : @types.BattleState,
  x : Int,
  y : Int,
  team : @types.UnitTeam,
) -> Int {
  let mut best_id = -1
  let mut best_dist = 9999
  for i = 0; i < battle.units.length(); i = i + 1 {
    let u = battle.units[i]
    if u.active && u.hp > 0 && u.team == team {
      let d = @types.manhattan(x, y, u.x, u.y)
      if d < best_dist {
        best_dist = d
        best_id = i
      }
    }
  }
  best_id
}

///|
/// Find the unit of a team with the lowest HP.
pub fn find_weakest_unit(
  battle : @types.BattleState,
  team : @types.UnitTeam,
) -> Int {
  let mut best_id = -1
  let mut best_hp = 9999
  for i = 0; i < battle.units.length(); i = i + 1 {
    let u = battle.units[i]
    if u.active && u.hp > 0 && u.team == team {
      if u.hp < best_hp {
        best_hp = u.hp
        best_id = i
      }
    }
  }
  best_id
}

///|
/// Find the unit of a team with the most damage taken (lowest HP ratio).
pub fn find_most_damaged_unit(
  battle : @types.BattleState,
  team : @types.UnitTeam,
) -> Int {
  let mut best_id = -1
  let mut best_damage = -1
  for i = 0; i < battle.units.length(); i = i + 1 {
    let u = battle.units[i]
    if u.active && u.hp > 0 && u.team == team {
      let damage_taken = u.max_hp - u.hp
      if damage_taken > best_damage {
        best_damage = damage_taken
        best_id = i
      }
    }
  }
  // If no one is damaged, return nearest to center
  if best_id < 0 {
    best_id = find_weakest_unit(battle, team)
  }
  best_id
}

///|
/// Step one tile toward a target (returns dx, dy).
pub fn step_toward(
  from_x : Int,
  from_y : Int,
  to_x : Int,
  to_y : Int,
) -> (Int, Int) {
  let raw_dx = to_x - from_x
  let raw_dy = to_y - from_y
  let adx = @types.abs_int(raw_dx)
  let ady = @types.abs_int(raw_dy)
  // Move along the axis with greater distance
  if adx >= ady {
    (sign(raw_dx), 0)
  } else {
    (0, sign(raw_dy))
  }
}
