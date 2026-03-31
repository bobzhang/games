///|
/// Check if hints are available for the current world
pub fn hints_available(game : @types.Game) -> Bool {
  let world = game.current_world
  if world >= 0 && world < game.hints.hints_remaining.length() {
    game.hints.hints_remaining[world] > 0
  } else {
    false
  }
}

///|
/// Get remaining hints for current world
pub fn hints_remaining(game : @types.Game) -> Int {
  let world = game.current_world
  if world >= 0 && world < game.hints.hints_remaining.length() {
    game.hints.hints_remaining[world]
  } else {
    0
  }
}

///|
/// Use a hint: compute the best next gravity rotation
pub fn use_hint(game : @types.Game) -> Unit {
  let world = game.current_world
  if world < 0 || world >= game.hints.hints_remaining.length() {
    return
  }
  if game.hints.hints_remaining[world] <= 0 {
    game.message_text = "No hints remaining!"
    game.message_timer = @types.message_duration
    return
  }
  let level = match game.level {
    Some(l) => l
    None => return
  }
  // Compute hint: try each gravity direction and pick the one
  // that gets the player closest to the exit
  let best_dir = compute_best_direction(level, game)
  game.hints.hints_remaining[world] = game.hints.hints_remaining[world] - 1
  game.hints.hint_active = true
  game.hints.hint_dir = best_dir
  game.hints.hint_timer = @types.hint_display_duration
  game.message_text = "Hint: try rotating gravity!"
  game.message_timer = @types.message_duration
}

///|
/// Update the hint display timer
pub fn update_hint(game : @types.Game, dt : Float) -> Unit {
  if game.hints.hint_active {
    game.hints.hint_timer = game.hints.hint_timer - dt
    if game.hints.hint_timer <= 0.0 {
      game.hints.hint_active = false
      game.hints.hint_timer = 0.0
    }
  }
}

///|
/// Get the level-specific hint text for the current level
pub fn get_current_level_hint_text(game : @types.Game) -> String {
  let world = game.current_world
  let level = game.current_level
  get_hint_text_for_level(world, level)
}

///|
/// Get hint text for a specific world and level
pub fn get_hint_text_for_level(world : Int, level : Int) -> String {
  let index = world * @types.levels_per_world + level
  match index {
    // World 1: Stone Ruins - basic gravity hints
    0 => "Try rotating gravity left to reach the exit"
    1 => "Use gravity rotation to get over the walls"
    2 => "Collect the gem before reaching the exit"
    3 => "Navigate through the corridors with gravity shifts"
    4 => "Push the box out of your path with gravity"
    5 => "Use boxes as stepping stones after rotation"
    6 => "Collect both gems by planning your gravity rotations"
    7 => "Alternate between gravity directions to navigate the maze"
    8 => "Use a zigzag pattern with gravity changes"
    9 => "Combine box pushing with gravity rotation"
    // World 2: Crystal Caverns - ice and portal hints
    10 => "Ice tiles are slippery - plan your path carefully"
    11 => "Use ice and walls together to control your slide"
    12 => "Portals teleport you - use them to bypass walls"
    13 => "Combine portals with gravity to reach the gem"
    14 => "Ice and portals together create tricky paths"
    15 => "Watch for ice near portals - you might slide past"
    16 => "Mirror Cave has tricky portal and ice combos"
    17 => "Watch out for the enemy while navigating ice"
    18 => "Two portal pairs - plan which to use first"
    19 => "Crystal Peak combines all Crystal Cavern mechanics with an enemy"
    // World 3: Void Expanse - crumble and switch hints
    20 => "Crumble tiles break after you leave - no going back"
    21 => "Plan your path over crumble tiles carefully"
    22 => "Hit the switch to open the gate"
    23 => "Get to the switch before the gate blocks your path"
    24 => "Crumble tiles limit your options - choose wisely"
    25 => "Two switches control two gates"
    26 => "Combine crumble paths with switch timing"
    27 => "Watch out for the enemy near the switch!"
    28 => "Dark Matter requires precise crumble and switch play"
    29 => "The enemy in Void Heart adds extra pressure"
    // World 4: Magma Depths - spike and conveyor hints
    30 => "Avoid spikes - they are instant death"
    31 => "Route around spikes using gravity rotation"
    32 => "Conveyors push you automatically - use them wisely"
    33 => "Boulders roll and can block spikes"
    34 => "Conveyors and spikes together - time your moves"
    35 => "Drop the boulder to clear a path"
    36 => "The enemy chases you - stay ahead!"
    37 => "Use boulders to crush the enemy"
    38 => "Lure the enemy into the boulder's path"
    39 => "Magma Core has an enemy - crush it with a boulder"
    // World 5: Sky Citadel - combined mechanic hints
    40 => "All mechanics combined - use what you have learned"
    41 => "Crumble and gates together require planning"
    42 => "Spikes with portals - teleport past the danger"
    43 => "Ice and crumble are a dangerous combination"
    44 => "Keys and portals unlock new possibilities"
    45 => "The enemy adds pressure while dodging hazards"
    46 => "Complex puzzles need step-by-step thinking"
    47 => "Use the boulder to crush the enemy in Sky Fortress"
    48 => "The Citadel tests everything you know"
    _ => "Use all your skills to complete the Final Ascent - watch the enemy!"
  }
}

///|
/// Get difficulty rating for a level (1-5 stars)
pub fn get_level_difficulty(world : Int, level : Int) -> Int {
  // Difficulty increases across worlds and within worlds
  let base_diff = world + 1
  let level_diff = level / 3
  let total = base_diff + level_diff
  if total > 5 { 5 } else { total }
}

///|
/// Get hint tip for the current screen state
pub fn get_context_tip(game : @types.Game) -> String {
  match game.screen {
    Title => "Press ENTER to start or S for statistics"
    WorldSelect => "LEFT/RIGHT to browse, ENTER to select world"
    LevelSelect => "Navigate with arrows, ENTER to play"
    Playing => {
      match game.level {
        Some(level) => {
          if level.moves == 0 {
            "Q/E to rotate gravity, Arrow keys to move"
          } else if level.moves <= 2 {
            "Press Z to undo your last move"
          } else if level.moves > level.par_moves + 5 {
            "Try pressing H for a hint"
          } else {
            ""
          }
        }
        None => ""
      }
    }
    Paused => "ESC to resume, Q to quit"
    LevelComplete => "ENTER for next level, ESC for level select"
    Editor => "TAB to switch modes, T to test play"
    Statistics => "ESC to return to title"
  }
}

///|
/// Draw the hint arrow overlay on screen
pub fn draw_hint(game : @types.Game) -> Unit {
  if !(game.hints.hint_active) {
    return
  }
  let alpha_f = game.hints.hint_timer / @types.hint_display_duration
  let alpha = (alpha_f * 220.0).to_int()
  let a = if alpha > 255 { 255 } else if alpha < 0 { 0 } else { alpha }
  let color = @raylib.Color::new(255, 255, 100, a)
  let bg_color = @raylib.Color::new(0, 0, 0, a / 2)
  // Draw a large arrow in the center of the screen showing the hint direction
  let cx = @types.screen_w / 2
  let cy = @types.screen_h / 2 - 40
  let (dx, dy) = @types.gravity_vector(game.hints.hint_dir)
  let fdx = Float::from_int(dx)
  let fdy = Float::from_int(dy)
  // Background circle
  @raylib.draw_circle(cx, cy, 60.0, bg_color)
  // Arrow line
  let ax1 = Float::from_int(cx) - fdx * 30.0
  let ay1 = Float::from_int(cy) - fdy * 30.0
  let ax2 = Float::from_int(cx) + fdx * 30.0
  let ay2 = Float::from_int(cy) + fdy * 30.0
  @raylib.draw_line(ax1.to_int(), ay1.to_int(), ax2.to_int(), ay2.to_int(), color)
  // Arrow head (triangle)
  let tip_x = Float::from_int(cx) + fdx * 45.0
  let tip_y = Float::from_int(cy) + fdy * 45.0
  let perp_x = fdy
  let perp_y = -fdx
  @raylib.draw_triangle(
    @raylib.Vector2::new(tip_x, tip_y),
    @raylib.Vector2::new(ax2 - perp_x * 12.0, ay2 - perp_y * 12.0),
    @raylib.Vector2::new(ax2 + perp_x * 12.0, ay2 + perp_y * 12.0),
    color,
  )
  // Direction label
  let dir_label = match game.hints.hint_dir {
    Down => "DOWN"
    Up => "UP"
    Left => "LEFT"
    Right => "RIGHT"
  }
  @draw.draw_text(dir_label, cx - 24, cy + 55, 20, color)
  // Remaining hints count
  let remaining = hints_remaining(game)
  let hint_text = "Hints: " + remaining.to_string()
  @draw.draw_text(hint_text, cx - 30, cy + 80, 16, @raylib.Color::new(200, 200, 200, a))
}

///|
/// Compute the best gravity direction to hint
fn compute_best_direction(level : @types.Level, game : @types.Game) -> @types.GravityDir {
  // Find exit position
  let mut exit_x = 0
  let mut exit_y = 0
  for y in 0..<level.height {
    for x in 0..<level.width {
      if @types.get_tile(level, x, y) == Exit {
        exit_x = x
        exit_y = y
      }
    }
  }
  // Find player position
  let player = match @types.find_player(level) {
    Some(p) => p
    None => return level.gravity
  }
  // Try all 4 directions, simulate settling, measure distance to exit
  let dirs : Array[@types.GravityDir] = [Down, Up, Left, Right]
  let mut best_dir = level.gravity
  let mut best_dist = 99999.0
  for i in 0..<4 {
    let dir = dirs[i]
    if dir == level.gravity {
      continue
    }
    // Estimate: simulate where player would end up
    let (dx, dy) = @types.gravity_vector(dir)
    let mut sim_x = player.x
    let mut sim_y = player.y
    // Simulate falling in that direction up to 12 tiles
    for _step in 0..<12 {
      let nx = sim_x + dx
      let ny = sim_y + dy
      if nx < 0 || nx >= level.width || ny < 0 || ny >= level.height {
        break
      }
      if @types.is_solid(@types.get_tile(level, nx, ny)) {
        break
      }
      // Check for entities blocking
      let mut blocked = false
      for j in 0..<level.entities.length() {
        let e = level.entities[j]
        if e.active && e.x == nx && e.y == ny && e.kind != Key && e.kind != Gem {
          blocked = true
        }
      }
      if blocked {
        break
      }
      sim_x = nx
      sim_y = ny
    }
    let ddx = sim_x - exit_x
    let ddy = sim_y - exit_y
    let dist_sq = ddx * ddx + ddy * ddy
    let dist = dist_sq.to_double().sqrt()
    if dist < best_dist {
      best_dist = dist
      best_dir = dir
    }
  }
  ignore(game)
  best_dir
}
