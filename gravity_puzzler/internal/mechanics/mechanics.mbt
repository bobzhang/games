///|
/// Stone Ruins: Pressure plates - step on to permanently open a gate
pub fn process_pressure_plate(level : @types.Level, entity : @types.Entity) -> Unit {
  let tile = @types.get_tile(level, entity.x, entity.y)
  match tile {
    PressurePlate(id) => {
      // Open the corresponding gate permanently
      @types.open_gates(level, id)
      // Replace plate with empty (permanently activated)
      @types.set_tile(level, entity.x, entity.y, Empty)
    }
    _ => ()
  }
}

///|
/// Crystal Caverns: Mirror - redirect entity movement at 90 degrees
/// Returns the new direction for an entity passing through a mirror tile
pub fn process_mirror(level : @types.Level, entity : @types.Entity, dir : @types.GravityDir) -> @types.GravityDir {
  let tile = @types.get_tile(level, entity.x, entity.y)
  match tile {
    Mirror(id) => @types.mirror_reflect(dir, id)
    _ => dir
  }
}

///|
/// Apply mirror redirect to an entity: move it in the reflected direction
pub fn apply_mirror_movement(
  level : @types.Level,
  entity : @types.Entity,
  current_dir : @types.GravityDir
) -> Bool {
  let tile = @types.get_tile(level, entity.x, entity.y)
  match tile {
    Mirror(id) => {
      let new_dir = @types.mirror_reflect(current_dir, id)
      let (dx, dy) = @types.gravity_vector(new_dir)
      let nx = entity.x + dx
      let ny = entity.y + dy
      if nx >= 0 &&
        nx < level.width &&
        ny >= 0 &&
        ny < level.height &&
        !(@types.is_solid(@types.get_tile(level, nx, ny))) {
        // Check no entity blocking
        match @types.entity_at_except(level, nx, ny, entity.id) {
          Some(_) => false
          None => {
            entity.from_x = entity.x
            entity.from_y = entity.y
            entity.x = nx
            entity.y = ny
            entity.slide_timer = 1.0
            true
          }
        }
      } else {
        false
      }
    }
    _ => false
  }
}

///|
/// Void Expanse: Gravity wells pull entities toward a point
pub fn apply_gravity_wells(level : @types.Level) -> Bool {
  let mut moved = false
  // Find all gravity well tiles
  let wells : Array[(Int, Int)] = []
  for y in 0..<level.height {
    for x in 0..<level.width {
      if @types.get_tile(level, x, y) == GravityWell {
        wells.push((x, y))
      }
    }
  }
  if wells.length() == 0 {
    return false
  }
  // For each entity, pull toward nearest gravity well (1 tile step)
  for i in 0..<level.entities.length() {
    let entity = level.entities[i]
    if !(entity.active) {
      continue
    }
    // Find nearest well
    let mut best_dx = 0
    let mut best_dy = 0
    let mut best_dist = 99999.0
    for j in 0..<wells.length() {
      let (wx, wy) = wells[j]
      let ddx = wx - entity.x
      let ddy = wy - entity.y
      let dist = (ddx * ddx + ddy * ddy).to_double().sqrt()
      if dist > 0.5 && dist < best_dist && dist <= 4.0 {
        best_dist = dist
        // Move one step toward well
        best_dx = if ddx > 0 {
          1
        } else if ddx < 0 {
          -1
        } else {
          0
        }
        best_dy = if ddy > 0 {
          1
        } else if ddy < 0 {
          -1
        } else {
          0
        }
      }
    }
    if best_dx != 0 || best_dy != 0 {
      let nx = entity.x + best_dx
      let ny = entity.y + best_dy
      if nx >= 0 &&
        nx < level.width &&
        ny >= 0 &&
        ny < level.height &&
        !(@types.is_solid(@types.get_tile(level, nx, ny))) {
        match @types.entity_at_except(level, nx, ny, entity.id) {
          Some(_) => ()
          None => {
            entity.from_x = entity.x
            entity.from_y = entity.y
            entity.x = nx
            entity.y = ny
            entity.slide_timer = 1.0
            moved = true
          }
        }
      }
    }
  }
  moved
}

///|
/// Magma Depths: Timed lava - tiles cycle between solid lava and empty
pub fn update_timed_lava(level : @types.Level, lava_timer : Float) -> Unit {
  // Lava tiles cycle: solid for half the period, empty for the other half
  let half_period = @types.lava_cycle_period * 0.5
  let is_active = lava_timer < half_period
  for y in 0..<level.height {
    for x in 0..<level.width {
      let tile = @types.get_tile(level, x, y)
      match tile {
        TimedLava => {
          // If lava is active, it acts as solid (already handled by is_solid)
          // If inactive, treat as spike (dangerous but passable during active phase)
          if !(is_active) {
            // When lava recedes, make it passable but still dangerous
            // We use the existing tile, just check differently
            ()
          }
        }
        _ => ()
      }
    }
  }
}

///|
/// Check if timed lava is currently in active (solid/dangerous) phase
pub fn is_lava_active(lava_timer : Float) -> Bool {
  lava_timer < @types.lava_cycle_period * 0.5
}

///|
/// Check if timed lava is dangerous to the player (during transition)
pub fn is_lava_deadly(lava_timer : Float) -> Bool {
  let phase = lava_timer / @types.lava_cycle_period
  // Deadly during the active phase
  phase < 0.5
}

///|
/// Sky Citadel: Wind gusts push entities sideways on certain beats
pub fn apply_wind_gusts(level : @types.Level, wind_beat : Int) -> Bool {
  // Wind blows every other beat
  if wind_beat % 2 != 0 {
    return false
  }
  let mut moved = false
  for y in 0..<level.height {
    for x in 0..<level.width {
      let tile = @types.get_tile(level, x, y)
      match tile {
        WindGust(dir) => {
          // Push any entity on this tile in the wind direction
          for i in 0..<level.entities.length() {
            let entity = level.entities[i]
            if !(entity.active) || entity.x != x || entity.y != y {
              continue
            }
            let (dx, dy) = @types.gravity_vector(dir)
            let nx = entity.x + dx
            let ny = entity.y + dy
            if nx >= 0 &&
              nx < level.width &&
              ny >= 0 &&
              ny < level.height &&
              !(@types.is_solid(@types.get_tile(level, nx, ny))) {
              match @types.entity_at_except(level, nx, ny, entity.id) {
                Some(_) => ()
                None => {
                  entity.from_x = entity.x
                  entity.from_y = entity.y
                  entity.x = nx
                  entity.y = ny
                  entity.slide_timer = 1.0
                  moved = true
                }
              }
            }
          }
        }
        _ => ()
      }
    }
  }
  moved
}

///|
/// Process all world-specific mechanics after settling
pub fn process_world_mechanics(
  level : @types.Level,
  game : @types.Game
) -> Bool {
  let mut any_moved = false
  // Process pressure plates for all entities
  for i in 0..<level.entities.length() {
    let entity = level.entities[i]
    if entity.active {
      process_pressure_plate(level, entity)
    }
  }
  // Process gravity wells (Void Expanse - world 2)
  if level.world == 2 {
    if apply_gravity_wells(level) {
      any_moved = true
    }
  }
  // Process wind gusts (Sky Citadel - world 4)
  if level.world == 4 {
    if apply_wind_gusts(level, game.wind_beat) {
      any_moved = true
    }
  }
  any_moved
}

///|
/// Process enemy entity movement: enemies move 1 tile toward the player per settle step
pub fn process_enemies(level : @types.Level, game : @types.Game) -> Bool {
  let player = match @types.find_player(level) {
    Some(p) => p
    None => return false
  }
  let mut any_moved = false
  for i in 0..<level.entities.length() {
    let entity = level.entities[i]
    if !(entity.active) || entity.kind != Enemy {
      continue
    }
    // Calculate direction toward player
    let ddx = player.x - entity.x
    let ddy = player.y - entity.y
    // Move one step in the axis with the greatest distance
    let mut move_x = 0
    let mut move_y = 0
    let abs_dx = if ddx > 0 { ddx } else { -ddx }
    let abs_dy = if ddy > 0 { ddy } else { -ddy }
    if abs_dx >= abs_dy {
      move_x = if ddx > 0 { 1 } else if ddx < 0 { -1 } else { 0 }
    } else {
      move_y = if ddy > 0 { 1 } else if ddy < 0 { -1 } else { 0 }
    }
    if move_x != 0 || move_y != 0 {
      let nx = entity.x + move_x
      let ny = entity.y + move_y
      if nx >= 0 &&
        nx < level.width &&
        ny >= 0 &&
        ny < level.height &&
        !(@types.is_solid(@types.get_tile(level, nx, ny))) {
        // Check if target is blocked by a non-player entity
        let mut blocked = false
        for j in 0..<level.entities.length() {
          let other = level.entities[j]
          if other.active &&
            other.id != entity.id &&
            other.x == nx &&
            other.y == ny &&
            other.kind != Player &&
            other.kind != Key &&
            other.kind != Gem {
            blocked = true
            break
          }
        }
        if !(blocked) {
          entity.from_x = entity.x
          entity.from_y = entity.y
          entity.x = nx
          entity.y = ny
          entity.slide_timer = 1.0
          any_moved = true
        }
      }
    }
  }
  ignore(game)
  any_moved
}

///|
/// Check if any enemy is on the same tile as the player (kills player)
pub fn check_enemy_player_collision(level : @types.Level) -> Unit {
  let player = match @types.find_player(level) {
    Some(p) => p
    None => return
  }
  for i in 0..<level.entities.length() {
    let e = level.entities[i]
    if e.active && e.kind == Enemy && e.x == player.x && e.y == player.y {
      level.player_dead = true
      return
    }
  }
}

///|
/// Check if boulders crushed any enemies (boulder on same tile kills enemy)
pub fn check_boulder_crush_enemies(level : @types.Level) -> Unit {
  for i in 0..<level.entities.length() {
    let boulder = level.entities[i]
    if !(boulder.active) || boulder.kind != Boulder {
      continue
    }
    for j in 0..<level.entities.length() {
      let enemy = level.entities[j]
      if enemy.active &&
        enemy.kind == Enemy &&
        enemy.x == boulder.x &&
        enemy.y == boulder.y {
        // Enemy is crushed by boulder
        enemy.active = false
      }
    }
  }
}
