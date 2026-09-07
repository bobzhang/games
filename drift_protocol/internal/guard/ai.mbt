///|
/// Update all guard AI
pub fn update_guards(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.level.guards.length() {
    let g = game.level.guards[i]
    if !g.active {
      continue
    }
    update_guard_detection(g, game, dt)
    update_guard_state(g, game, dt)
    update_guard_movement(g, game, dt)
    // Update pixel position (smooth lerp)
    let target_px = @types.tile_to_pixel_x(g.gx)
    let target_py = @types.tile_to_pixel_y(g.gy)
    g.px = @types.lerpf(g.px, target_px, @types.move_lerp_speed * dt)
    g.py = @types.lerpf(g.py, target_py, @types.move_lerp_speed * dt)
  }
}

///|
/// Update detection meter for a guard
fn update_guard_detection(
  g : @types.Guard,
  game : @types.Game,
  dt : Float,
) -> Unit {
  let can_see = point_in_vision_cone(
    g,
    game.player.gx,
    game.player.gy,
    game.level.tiles,
  )
  if can_see {
    let rate = detection_speed_at(
      game.level.tiles,
      game.player.gx,
      game.player.gy,
    )
    g.detection_meter = @types.minf(
      g.detection_meter + rate * dt,
      @types.detection_max,
    )
    if g.detection_meter >= @types.detection_max {
      // Full detection - go to alert
      if g.alert_state is Patrolling {
        g.alert_state = Suspicious
        g.suspicious_timer = @types.suspicious_duration
        g.investigate_x = game.player.gx
        g.investigate_y = game.player.gy
        game.player.detected_count += 1
      }
    }
  } else {
    // Decay detection
    g.detection_meter = @types.maxf(g.detection_meter - 0.3 * dt, 0.0)
  }
}

///|
/// Generate search offsets around the investigation point
fn generate_search_offsets(
  g : @types.Guard,
  tiles : Array[Array[@types.TileKind]],
) -> Array[@types.Vec2i] {
  let offsets : Array[@types.Vec2i] = []
  // Search in a pattern around the investigation point: cardinal then diagonal
  let candidates : Array[@types.Vec2i] = [
    { x: g.investigate_x, y: g.investigate_y, },
    { x: g.investigate_x + 1, y: g.investigate_y, },
    { x: g.investigate_x - 1, y: g.investigate_y, },
    { x: g.investigate_x, y: g.investigate_y + 1, },
    { x: g.investigate_x, y: g.investigate_y - 1, },
    { x: g.investigate_x + 1, y: g.investigate_y + 1, },
    { x: g.investigate_x - 1, y: g.investigate_y - 1, },
  ]
  for i in 0..<candidates.length() {
    let c = candidates[i]
    if @types.in_bounds(c.x, c.y) && @types.tile_walkable(tiles[c.y][c.x]) {
      offsets.push(c)
    }
  }
  offsets
}

///|
/// Update guard state machine
fn update_guard_state(g : @types.Guard, game : @types.Game, dt : Float) -> Unit {
  match g.alert_state {
    Patrolling => ()
    Suspicious => {
      g.suspicious_timer -= dt
      // Handle look timer: guard pauses to look around at each search point
      if g.look_timer > 0.0 {
        g.look_timer -= dt
        // Rotate while looking
        g.facing_angle = normalize_angle(g.facing_angle + 1.5 * dt)
        update_facing_from_angle(g)
        return
      }
      if g.suspicious_timer <= 0.0 {
        // Check if can still see player
        let can_see = point_in_vision_cone(
          g,
          game.player.gx,
          game.player.gy,
          game.level.tiles,
        )
        if can_see && g.detection_meter > 0.5 {
          // Escalate to alert
          g.alert_state = Alert
          g.alert_timer = @types.alert_duration
          game.player.alert_triggered = true
          @types.push_sound(game, AlertTriggered)
          // Radio other guards
          alert_nearby_guards(game, g.investigate_x, g.investigate_y)
        } else {
          // Return to patrol
          g.alert_state = Patrolling
          g.detection_meter = 0.0
          g.searching = false
          g.search_index = 0
        }
      }
      // Start searching if reached investigation point and not already searching
      if !g.searching && g.gx == g.investigate_x && g.gy == g.investigate_y {
        g.searching = true
        g.search_offsets = generate_search_offsets(g, game.level.tiles)
        g.search_index = 0
        g.look_timer = @types.search_look_duration
      }
    }
    Alert => {
      g.alert_timer -= dt
      // Update investigation target to player position if visible
      let can_see = point_in_vision_cone(
        g,
        game.player.gx,
        game.player.gy,
        game.level.tiles,
      )
      if can_see {
        g.investigate_x = game.player.gx
        g.investigate_y = game.player.gy
        g.alert_timer = @types.alert_duration // Reset timer while seeing player
      }
      if g.alert_timer <= 0.0 {
        g.alert_state = Suspicious
        g.suspicious_timer = @types.suspicious_duration
        g.detection_meter = 0.3
        g.searching = false
        g.search_index = 0
      }
    }
  }
}

///|
/// Update guard movement based on state
fn update_guard_movement(
  g : @types.Guard,
  game : @types.Game,
  dt : Float,
) -> Unit {
  g.move_timer -= dt
  if g.move_timer > 0.0 {
    return
  }
  let interval = match g.alert_state {
    Patrolling => @types.guard_move_interval
    Suspicious => @types.guard_move_interval * 0.8
    Alert => @types.guard_move_interval * 0.5
  }
  g.move_timer = interval
  match g.alert_state {
    Patrolling => move_guard_patrol(g, game)
    Suspicious => move_guard_search(g, game)
    Alert => move_guard_toward(g, g.investigate_x, g.investigate_y, game)
  }
}

///|
/// Move guard during suspicious search behavior
fn move_guard_search(g : @types.Guard, game : @types.Game) -> Unit {
  if g.searching && g.search_offsets.length() > 0 {
    let target = g.search_offsets[g.search_index]
    if g.gx == target.x && g.gy == target.y {
      // Reached search point, pause to look around then move to next
      g.search_index += 1
      if g.search_index >= g.search_offsets.length() {
        g.search_index = 0 // loop search pattern
      }
      g.look_timer = @types.search_look_duration
      return
    }
    step_toward(g, target.x, target.y, game)
  } else {
    // Not searching yet, walk to investigation point
    move_guard_toward(g, g.investigate_x, g.investigate_y, game)
  }
}

///|
/// Move guard along patrol route
fn move_guard_patrol(g : @types.Guard, game : @types.Game) -> Unit {
  if g.kind is Sentinel || g.patrol_points.length() <= 1 {
    // Sentinel rotates in place
    g.facing_angle = normalize_angle(g.facing_angle + 0.5)
    update_facing_from_angle(g)
    return
  }
  let target = g.patrol_points[g.patrol_index]
  if g.gx == target.x && g.gy == target.y {
    // Reached waypoint, advance
    if g.patrol_forward {
      g.patrol_index += 1
      if g.patrol_index >= g.patrol_points.length() {
        g.patrol_index = g.patrol_points.length() - 2
        g.patrol_forward = false
        if g.patrol_index < 0 {
          g.patrol_index = 0
        }
      }
    } else {
      g.patrol_index -= 1
      if g.patrol_index < 0 {
        g.patrol_index = 1
        g.patrol_forward = true
        if g.patrol_index >= g.patrol_points.length() {
          g.patrol_index = 0
        }
      }
    }
  }
  let dest = g.patrol_points[g.patrol_index]
  step_toward(g, dest.x, dest.y, game)
}

///|
/// Move guard toward a target position
fn move_guard_toward(
  g : @types.Guard,
  tx : Int,
  ty : Int,
  game : @types.Game,
) -> Unit {
  step_toward(g, tx, ty, game)
}

///|
/// Take one step toward target
fn step_toward(
  g : @types.Guard,
  tx : Int,
  ty : Int,
  game : @types.Game,
) -> Unit {
  let dx = tx - g.gx
  let dy = ty - g.gy
  // Prefer axis with larger distance
  let mut nx = g.gx
  let mut ny = g.gy
  if @types.absi(dx) >= @types.absi(dy) {
    if dx > 0 {
      nx += 1
      g.facing = Right
    } else if dx < 0 {
      nx -= 1
      g.facing = Left
    }
  } else if dy > 0 {
    ny += 1
    g.facing = Down
  } else if dy < 0 {
    ny -= 1
    g.facing = Up
  }
  g.facing_angle = @types.direction_angle(g.facing)
  // Check if can move
  if @types.in_bounds(nx, ny) &&
    @types.tile_walkable(game.level.tiles[ny][nx]) &&
    !is_guard_at(game, nx, ny) {
    // Check doors - guards can't go through closed doors
    let door_idx = @types.find_door_at(game.level, nx, ny)
    if door_idx >= 0 && !game.level.doors[door_idx].open {
      return
    }
    // Check lasers - guards avoid active lasers
    let laser_idx = @types.find_laser_at(game.level, nx, ny)
    if laser_idx >= 0 && game.level.lasers[laser_idx].active {
      return
    }
    g.gx = nx
    g.gy = ny
  }
}

///|
fn is_guard_at(game : @types.Game, gx : Int, gy : Int) -> Bool {
  for i in 0..<game.level.guards.length() {
    let g = game.level.guards[i]
    if g.active && g.gx == gx && g.gy == gy {
      return true
    }
  }
  false
}

///|
fn update_facing_from_angle(g : @types.Guard) -> Unit {
  let a = normalize_angle(g.facing_angle)
  let quarter = @types.pi / 4.0
  if a >= -quarter && a < quarter {
    g.facing = Right
  } else if a >= quarter && a < 3.0 * quarter {
    g.facing = Down
  } else if a >= -3.0 * quarter && a < -quarter {
    g.facing = Up
  } else {
    g.facing = Left
  }
}

///|
/// Alert nearby guards to investigate a position
pub fn alert_nearby_guards(game : @types.Game, ix : Int, iy : Int) -> Unit {
  for i in 0..<game.level.guards.length() {
    let g = game.level.guards[i]
    if g.active && g.alert_state is Patrolling {
      let dist = @types.manhattan_dist(g.gx, g.gy, ix, iy)
      if dist <= 8 {
        g.alert_state = Suspicious
        g.suspicious_timer = @types.suspicious_duration
        g.investigate_x = ix
        g.investigate_y = iy
      }
    }
  }
}

///|
/// Make guards react to noise at a position
pub fn guards_hear_noise(
  game : @types.Game,
  nx : Int,
  ny : Int,
  radius : Int,
) -> Unit {
  for i in 0..<game.level.guards.length() {
    let g = game.level.guards[i]
    if !g.active {
      continue
    }
    let dist = @types.manhattan_dist(g.gx, g.gy, nx, ny)
    if dist <= radius {
      match g.alert_state {
        Patrolling => {
          g.alert_state = Suspicious
          g.suspicious_timer = @types.suspicious_duration
          g.investigate_x = nx
          g.investigate_y = ny
          g.searching = false
          g.search_index = 0
        }
        Suspicious => {
          g.investigate_x = nx
          g.investigate_y = ny
          g.suspicious_timer = @types.suspicious_duration
          // Redirect search to new noise location
          g.searching = false
          g.search_index = 0
        }
        Alert => {
          g.investigate_x = nx
          g.investigate_y = ny
        }
      }
    }
  }
}

///|
/// Update cameras (rotation)
pub fn update_cameras(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.level.cameras.length() {
    let cam = game.level.cameras[i]
    if cam.active && cam.powered {
      cam.facing_angle = normalize_angle(
        cam.facing_angle + cam.rotation_speed * dt,
      )
      // Check if camera sees player
      if point_in_camera_vision(
          cam,
          game.player.gx,
          game.player.gy,
          game.level.tiles,
        ) {
        // Camera detection triggers suspicion in nearby guards
        alert_nearby_guards(game, game.player.gx, game.player.gy)
        game.player.detected_count += 1
      }
    }
  }
}
