///|
fn sort_indices_by_gravity(
  entities : Array[@types.Entity],
  dir : @types.GravityDir,
) -> Array[Int] {
  let indices : Array[Int] = []
  for i in 0..<entities.length() {
    indices.push(i)
  }
  // Bubble sort by gravity-favored position (farthest in gravity dir first)
  let n = indices.length()
  for i in 0..<n {
    let limit = n - 1 - i
    for j in 0..<limit {
      let a = entities[indices[j]]
      let b = entities[indices[j + 1]]
      let swap = match dir {
        Down => a.y < b.y
        Up => a.y > b.y
        Left => a.x > b.x
        Right => a.x < b.x
      }
      if swap {
        let tmp = indices[j]
        indices[j] = indices[j + 1]
        indices[j + 1] = tmp
      }
    }
  }
  indices
}

///|
fn can_move_to(
  level : @types.Level,
  entity : @types.Entity,
  nx : Int,
  ny : Int,
) -> Bool {
  if nx < 0 || nx >= level.width || ny < 0 || ny >= level.height {
    return false
  }
  let tile = @types.get_tile(level, nx, ny)
  if @types.is_solid(tile) {
    return false
  }
  match @types.entity_at_except(level, nx, ny, entity.id) {
    Some(_) => false
    None => true
  }
}

///|
fn can_push_to(level : @types.Level, nx : Int, ny : Int) -> Bool {
  if nx < 0 || nx >= level.width || ny < 0 || ny >= level.height {
    return false
  }
  let tile = @types.get_tile(level, nx, ny)
  if @types.is_solid(tile) {
    return false
  }
  match @types.entity_at(level, nx, ny) {
    Some(_) => false
    None => true
  }
}

///|
fn process_tile_effects(level : @types.Level, entity : @types.Entity) -> Unit {
  let tile = @types.get_tile(level, entity.x, entity.y)
  match tile {
    Exit => if entity.kind == Player { level.completed = true }
    Spike => if entity.kind == Player { level.player_dead = true }
    Portal(id) => {
      let (px, py) = @types.find_matching_portal(level, id, entity.x, entity.y)
      if px != entity.x || py != entity.y {
        entity.from_x = entity.x
        entity.from_y = entity.y
        entity.x = px
        entity.y = py
      }
    }
    Switch(id) =>
      if entity.kind == Player {
        @types.open_gates(level, id)
        @types.set_tile(level, entity.x, entity.y, Empty)
      }
    _ => ()
  }
}

///|
fn process_entity_collisions(
  level : @types.Level,
  entity : @types.Entity,
) -> Unit {
  if entity.kind != Player {
    return
  }
  // Check all entities at same position (shouldn't normally happen after move,
  // but keys/gems can be stepped on)
  for i in 0..<level.entities.length() {
    let other = level.entities[i]
    if !other.active || other.id == entity.id {
      continue
    }
    if other.x == entity.x && other.y == entity.y {
      match other.kind {
        Key => {
          other.active = false
          level.keys_collected = level.keys_collected + 1
          // Open all gates with matching key count
          @types.open_gates(level, level.keys_collected)
        }
        Gem => {
          other.active = false
          level.gems_collected = level.gems_collected + 1
        }
        Enemy =>
          // Player walked into an enemy - death
          level.player_dead = true
        _ => ()
      }
    }
  }
}

///|
pub fn step_gravity(level : @types.Level) -> Bool {
  let (dx, dy) = @types.gravity_vector(level.gravity)
  let mut moved = false
  let order = sort_indices_by_gravity(level.entities, level.gravity)
  for idx in order {
    let entity = level.entities[idx]
    if !entity.active {
      continue
    }
    let nx = entity.x + dx
    let ny = entity.y + dy
    if can_move_to(level, entity, nx, ny) {
      entity.from_x = entity.x
      entity.from_y = entity.y
      entity.x = nx
      entity.y = ny
      entity.falling = true
      entity.slide_timer = 1.0
      moved = true
      process_tile_effects(level, entity)
      process_entity_collisions(level, entity)
      // Boulder rolling logic: if resting on something, try to slide sideways
    } else if entity.kind == Boulder && !entity.falling {
      let (perp1, perp2) = @types.gravity_perp_vectors(level.gravity)
      let (p1x, p1y) = perp1
      let (p2x, p2y) = perp2
      // Try left perpendicular first
      let sx1 = entity.x + p1x
      let sy1 = entity.y + p1y
      let sx1d = sx1 + dx
      let sy1d = sy1 + dy
      if can_move_to(level, entity, sx1, sy1) && can_push_to(level, sx1d, sy1d) {
        entity.from_x = entity.x
        entity.from_y = entity.y
        entity.x = sx1
        entity.y = sy1
        entity.falling = true
        entity.slide_timer = 1.0
        moved = true
        process_tile_effects(level, entity)
      } else {
        // Try right perpendicular
        let sx2 = entity.x + p2x
        let sy2 = entity.y + p2y
        let sx2d = sx2 + dx
        let sy2d = sy2 + dy
        if can_move_to(level, entity, sx2, sy2) &&
          can_push_to(level, sx2d, sy2d) {
          entity.from_x = entity.x
          entity.from_y = entity.y
          entity.x = sx2
          entity.y = sy2
          entity.falling = true
          entity.slide_timer = 1.0
          moved = true
          process_tile_effects(level, entity)
        } else {
          entity.falling = false
        }
      }
    } else {
      entity.falling = false
    }
  }
  // Handle ice sliding: entities on ice keep moving in gravity direction
  for idx in order {
    let entity = level.entities[idx]
    if !entity.active || entity.falling {
      continue
    }
    let tile = @types.get_tile(level, entity.x, entity.y)
    match tile {
      Ice =>
        // On ice, try to slide perpendicular to last movement
        // Ice makes the entity slippery - it continues in gravity direction
        // This is handled by the main gravity step already
        ()
      _ => ()
    }
  }
  // Handle conveyor belt effects
  for i in 0..<level.entities.length() {
    let entity = level.entities[i]
    if !entity.active || entity.falling {
      continue
    }
    let tile = @types.get_tile(level, entity.x, entity.y)
    match tile {
      Conveyor(conv_dir) => {
        let (cdx, cdy) = @types.gravity_vector(conv_dir)
        let cnx = entity.x + cdx
        let cny = entity.y + cdy
        if can_move_to(level, entity, cnx, cny) {
          entity.from_x = entity.x
          entity.from_y = entity.y
          entity.x = cnx
          entity.y = cny
          entity.slide_timer = 1.0
          moved = true
          process_tile_effects(level, entity)
          process_entity_collisions(level, entity)
        }
      }
      _ => ()
    }
  }
  // Handle crumble tiles: mark tiles that entities just left
  for i in 0..<level.entities.length() {
    let entity = level.entities[i]
    if !entity.active {
      continue
    }
    if entity.from_x != entity.x || entity.from_y != entity.y {
      let old_tile = @types.get_tile(level, entity.from_x, entity.from_y)
      match old_tile {
        Crumble => @types.set_tile(level, entity.from_x, entity.from_y, Empty)
        _ => ()
      }
    }
  }
  moved
}

///|
pub fn rotate_gravity(
  level : @types.Level,
  game : @types.Game,
  new_dir : @types.GravityDir,
) -> Unit {
  if level.gravity == new_dir {
    return
  }
  // Save undo state before rotation
  game.undo_stack.push(@types.save_snapshot(level))
  game.gravity_anim_from = level.gravity
  game.gravity_anim_timer = @types.gravity_anim_duration
  level.gravity = new_dir
  level.moves = level.moves + 1
}

///|
pub fn try_move_player(
  level : @types.Level,
  game : @types.Game,
  dx : Int,
  dy : Int,
) -> Bool {
  let player = match @types.find_player(level) {
    Some(p) => p
    None => return false
  }
  let nx = player.x + dx
  let ny = player.y + dy
  // Check bounds
  if nx < 0 || nx >= level.width || ny < 0 || ny >= level.height {
    return false
  }
  let tile = @types.get_tile(level, nx, ny)
  if @types.is_solid(tile) {
    return false
  }
  // Check for pushable entity
  match @types.entity_at_except(level, nx, ny, player.id) {
    Some(other) =>
      match other.kind {
        Box | Boulder => {
          // Try to push
          let pnx = nx + dx
          let pny = ny + dy
          if can_push_to(level, pnx, pny) {
            // Save undo before player move
            game.undo_stack.push(@types.save_snapshot(level))
            other.from_x = other.x
            other.from_y = other.y
            other.x = pnx
            other.y = pny
            other.slide_timer = 1.0
            player.from_x = player.x
            player.from_y = player.y
            player.x = nx
            player.y = ny
            player.slide_timer = 1.0
            level.moves = level.moves + 1
            process_tile_effects(level, player)
            process_tile_effects(level, other)
            process_entity_collisions(level, player)
            return true
          }
          return false
        }
        Key | Gem => {
          // Walk over collectibles
          game.undo_stack.push(@types.save_snapshot(level))
          player.from_x = player.x
          player.from_y = player.y
          player.x = nx
          player.y = ny
          player.slide_timer = 1.0
          level.moves = level.moves + 1
          process_tile_effects(level, player)
          process_entity_collisions(level, player)
          return true
        }
        Enemy => {
          // Walking into an enemy kills the player
          game.undo_stack.push(@types.save_snapshot(level))
          player.from_x = player.x
          player.from_y = player.y
          player.x = nx
          player.y = ny
          player.slide_timer = 1.0
          level.moves = level.moves + 1
          level.player_dead = true
          return true
        }
        _ => return false
      }
    None => {
      // Empty space - move there
      game.undo_stack.push(@types.save_snapshot(level))
      player.from_x = player.x
      player.from_y = player.y
      player.x = nx
      player.y = ny
      player.slide_timer = 1.0
      level.moves = level.moves + 1
      process_tile_effects(level, player)
      process_entity_collisions(level, player)
      return true
    }
  }
}

///|
pub fn settle_all(level : @types.Level) -> Bool {
  let mut any_moved = true
  let mut total_moved = false
  let mut iterations = 0
  while any_moved && iterations < 100 {
    any_moved = step_gravity(level)
    if any_moved {
      total_moved = true
    }
    iterations = iterations + 1
  }
  total_moved
}
