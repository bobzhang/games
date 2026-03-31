///|
pub fn simulate(game : @types.Game) -> Unit {
  let level = match game.current_level {
    Some(l) => l
    None => return
  }
  // Reset all gear RPMs
  for i in 0..<game.placed_gears.length() {
    if game.placed_gears[i].active {
      game.placed_gears[i].rpm = 0.0
      game.placed_gears[i].dir = CW
    }
  }
  // Reset output satisfaction
  for i in 0..<level.outputs.length() {
    level.outputs[i].satisfied = false
  }
  game.connections = []
  // Find the input gear among placed gears
  let input_idx = @types.find_gear_at(game.placed_gears, level.input.pos)
  if input_idx < 0 {
    return
  }
  // Set input gear properties
  game.placed_gears[input_idx].rpm = level.input.rpm
  game.placed_gears[input_idx].dir = level.input.dir
  // BFS from input gear
  let visited : Array[Bool] = Array::new(capacity=game.placed_gears.length())
  for _i in 0..<game.placed_gears.length() {
    visited.push(false)
  }
  let queue : Array[Int] = [input_idx]
  visited[input_idx] = true
  while queue.length() > 0 {
    let curr = queue.remove(0)
    let curr_gear = game.placed_gears[curr]
    if !curr_gear.active {
      continue
    }
    // Check meshing with all other gears
    for j in 0..<game.placed_gears.length() {
      if visited[j] || !game.placed_gears[j].active {
        continue
      }
      let other = game.placed_gears[j]
      // Skip belt-type gears in mesh check
      if curr_gear.kind == Belt || other.kind == Belt {
        continue
      }
      let dsq = @types.grid_dist_sq(curr_gear.pos, other.pos)
      if @types.can_mesh(curr_gear.radius, other.radius, dsq) {
        // Check ratchet direction
        if is_ratchet_blocked(curr_gear, other) {
          continue
        }
        let ratio = @types.speed_ratio(curr_gear.radius, other.radius)
        let new_rpm = curr_gear.rpm * ratio
        let new_dir = @types.flip_dir(curr_gear.dir)
        other.rpm = new_rpm
        other.dir = new_dir
        game.connections.push(
          {
            from: curr,
            to: j,
            ratio,
            flips_dir: true,
          },
        )
        visited[j] = true
        queue.push(j)
      }
    }
    // Check belt connections
    for b in 0..<game.belts.length() {
      let belt = game.belts[b]
      if !belt.active {
        continue
      }
      let target_idx = find_belt_target(game, curr, curr_gear, belt)
      if target_idx >= 0 && !visited[target_idx] {
        let target_gear = game.placed_gears[target_idx]
        let ratio = @types.speed_ratio(curr_gear.radius, target_gear.radius)
        let new_rpm = curr_gear.rpm * ratio
        // Belt preserves direction
        target_gear.rpm = new_rpm
        target_gear.dir = curr_gear.dir
        game.connections.push(
          {
            from: curr,
            to: target_idx,
            ratio,
            flips_dir: false,
          },
        )
        visited[target_idx] = true
        queue.push(target_idx)
      }
    }
  }
  // Check outputs
  check_outputs(game, level)
}

///|
fn find_belt_target(
  game : @types.Game,
  curr_idx : Int,
  curr_gear : @types.Gear,
  belt : @types.BeltLink
) -> Int {
  if curr_gear.pos == belt.from_pos {
    let idx = @types.find_gear_at(game.placed_gears, belt.to_pos)
    if idx >= 0 && idx != curr_idx {
      idx
    } else {
      -1
    }
  } else if curr_gear.pos == belt.to_pos {
    let idx = @types.find_gear_at(game.placed_gears, belt.from_pos)
    if idx >= 0 && idx != curr_idx {
      idx
    } else {
      -1
    }
  } else {
    -1
  }
}

///|
fn is_ratchet_blocked(driving : @types.Gear, driven : @types.Gear) -> Bool {
  // Ratchet only transmits in CW direction
  if driven.kind == Ratchet && driving.dir == CW {
    // Mesh would flip to CCW - ratchet blocks CCW transmission
    return true
  }
  if driving.kind == Ratchet && driving.dir == CCW {
    // Ratchet driving in CCW is blocked
    return true
  }
  false
}

///|
fn check_outputs(game : @types.Game, level : @types.Level) -> Unit {
  let mut all_satisfied = true
  for i in 0..<level.outputs.length() {
    let output = level.outputs[i]
    let gear_idx = @types.find_gear_at(game.placed_gears, output.pos)
    if gear_idx >= 0 {
      let gear = game.placed_gears[gear_idx]
      if @types.check_output(output, gear.rpm, gear.dir) {
        output.satisfied = true
      } else {
        output.satisfied = false
        all_satisfied = false
      }
    } else {
      output.satisfied = false
      all_satisfied = false
    }
  }
  if all_satisfied && level.outputs.length() > 0 {
    game.play_state = Solved
    // Calculate score
    let gears_used = @types.count_placed_gears(game.placed_gears)
    let level_idx = game.selected_level
    game.scores[level_idx].completed = true
    game.scores[level_idx].gears_used = gears_used
    let mut stars = 1
    if gears_used <= level.par_gears {
      stars = 2
    }
    // 3 stars: par gears and minimal energy loss (fewer connections)
    if gears_used <= level.par_gears && game.connections.length() <= gears_used {
      stars = 3
    }
    if stars > game.scores[level_idx].stars {
      game.scores[level_idx].stars = stars
    }
  }
}

///|
pub fn update_gear_angles(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.placed_gears.length() {
    let gear = game.placed_gears[i]
    if gear.active && @types.absf(gear.rpm) > 0.01 {
      let rps = gear.rpm / 60.0
      let delta_angle = rps * 2.0 * @types.pi * dt
      let dir_mult : Float = match gear.dir {
        CW => 1.0
        CCW => -1.0
      }
      gear.angle = gear.angle + delta_angle * dir_mult
    }
  }
}

///|
pub fn can_place_gear(
  game : @types.Game,
  pos : @types.Vec2i,
  kind : @types.GearKind
) -> Bool {
  let level = match game.current_level {
    Some(l) => l
    None => return false
  }
  // Check if within grid
  if pos.x < 0 || pos.x >= @types.grid_cols || pos.y < 0 ||
    pos.y >= @types.grid_rows {
    return false
  }
  // Check if peg already occupied
  if @types.find_gear_at(game.placed_gears, pos) >= 0 {
    return false
  }
  // Check budget
  let used = @types.count_placed_gears(game.placed_gears)
  if used >= level.gear_budget {
    return false
  }
  // Check gear kind is available in level
  let mut available = false
  for i in 0..<level.available_gears.length() {
    if level.available_gears[i] == kind {
      available = true
      break
    }
  }
  if !available {
    return false
  }
  // Check overlap with existing gears
  let new_gear = @types.new_gear(pos, kind)
  for i in 0..<game.placed_gears.length() {
    if game.placed_gears[i].active && @types.gears_overlap(
        new_gear, game.placed_gears[i],
      ) {
      return false
    }
  }
  true
}

///|
pub fn all_outputs_count(game : @types.Game) -> (Int, Int) {
  let level = match game.current_level {
    Some(l) => l
    None => return (0, 0)
  }
  let mut total = level.outputs.length()
  let mut satisfied = 0
  for i in 0..<level.outputs.length() {
    if level.outputs[i].satisfied {
      satisfied += 1
    }
  }
  // Suppress unused warning
  let _ = total
  total = level.outputs.length()
  (satisfied, total)
}
