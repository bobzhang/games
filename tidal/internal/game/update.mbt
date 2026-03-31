///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count += 1
  if game.message_timer > 0.0 {
    game.message_timer -= 1.0 / 60.0
    if game.message_timer <= 0.0 {
      game.message = ""
    }
  }
  match game.screen {
    Title => update_title(game)
    TierSelect => update_tier_select(game)
    LevelSelect => update_level_select(game)
    Playing => update_playing(game)
    Results => update_results(game)
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    game.screen = TierSelect
  }
}

///|
fn update_tier_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
    return
  }
  // Click or number key to select tier
  for t in 0..<3 {
    let key = match t {
      0 => @raylib.KeyOne
      1 => @raylib.KeyTwo
      _ => @raylib.KeyThree
    }
    if @raylib.is_key_pressed(key) {
      game.current_tier = t
      game.screen = LevelSelect
      return
    }
  }
  // Mouse click on tier boxes
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    for t in 0..<3 {
      let bx = 200 + t * 320
      let by = 280
      let bw = 260
      let bh = 180
      if mx >= bx && mx < bx + bw && my >= by && my < by + bh {
        game.current_tier = t
        game.screen = LevelSelect
        return
      }
    }
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = TierSelect
    return
  }
  let tier_offset = game.current_tier * @types.levels_per_tier
  // Number keys 1-9 and 0 for level 10
  for i in 0..<10 {
    let key = match i {
      0 => @raylib.KeyOne
      1 => @raylib.KeyTwo
      2 => @raylib.KeyThree
      3 => @raylib.KeyFour
      4 => @raylib.KeyFive
      5 => @raylib.KeySix
      6 => @raylib.KeySeven
      7 => @raylib.KeyEight
      8 => @raylib.KeyNine
      _ => @raylib.KeyZero
    }
    if @raylib.is_key_pressed(key) {
      game.current_level = tier_offset + i
      load_level(game)
      game.screen = Playing
      return
    }
  }
  // Mouse click on level boxes
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    for i in 0..<10 {
      let col = i % 5
      let row = i / 5
      let bx = 140 + col * 200
      let by = 220 + row * 200
      let bw = 160
      let bh = 160
      if mx >= bx && mx < bx + bw && my >= by && my < by + bh {
        game.current_level = tier_offset + i
        load_level(game)
        game.screen = Playing
        return
      }
    }
  }
}

///|
fn update_playing(game : @types.Game) -> Unit {
  match game.play_state {
    Editing => update_editing(game)
    Simulating => update_simulating(game)
    Stepping => update_stepping(game)
    Complete => update_complete(game)
    Failed => update_failed(game)
  }
}

///|
fn update_editing(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  // Cycle emitter phase with tab
  if @raylib.is_key_pressed(@raylib.KeyTab) {
    game.emitter_phase = (game.emitter_phase + 1) % 4
  }
  // Select palette slot with number keys
  let level = @levels.get_level(game.current_level)
  let num_slots = level.budget.length()
  for i in 0..<num_slots {
    let key = match i {
      0 => @raylib.KeyOne
      1 => @raylib.KeyTwo
      2 => @raylib.KeyThree
      _ => @raylib.KeyFour
    }
    if @raylib.is_key_pressed(key) {
      game.selected_slot = i
    }
  }
  // Click on grid to place/remove
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let gx = @types.screen_to_grid_x(mx)
    let gy = @types.screen_to_grid_y(my)
    if @types.grid_in_bounds(gx, gy) {
      let tile = @types.grid_get(game.grid, gx, gy)
      // Can't place on walls, targets, or pre-placed emitters
      if !tile.has_wall && !tile.is_target {
        match tile.object {
          Empty => {
            // Place object from budget
            if game.selected_slot < num_slots {
              let budget = level.budget[game.selected_slot]
              if budget.used < budget.total {
                let kind : @types.TileKind = match budget.kind {
                  PlaceEmitter => Emitter(game.emitter_phase)
                  PlaceReflector => Reflector
                  PlacePhaseShifter => PhaseShifter
                  PlaceAbsorber => Absorber
                }
                tile.object = kind
                budget.used += 1
                game.objects_placed += 1
              }
            }
          }
          Emitter(_) | Reflector | PhaseShifter | Absorber => {
            // Remove if it was player-placed (not pre-placed)
            let is_pre = is_pre_placed(level, gx, gy)
            if !is_pre {
              // Return to budget
              let bkind = object_to_placeable(tile.object)
              match bkind {
                Some(pk) => {
                  for b in level.budget {
                    if b.kind == pk {
                      b.used -= 1
                    }
                  }
                  game.objects_placed -= 1
                }
                None => ()
              }
              tile.object = Empty
            }
          }
          _ => ()
        }
      }
    }
  }
  // Right-click to remove
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let gx = @types.screen_to_grid_x(mx)
    let gy = @types.screen_to_grid_y(my)
    if @types.grid_in_bounds(gx, gy) {
      let tile = @types.grid_get(game.grid, gx, gy)
      let level = @levels.get_level(game.current_level)
      let is_pre = is_pre_placed(level, gx, gy)
      if !is_pre {
        match tile.object {
          Emitter(_) | Reflector | PhaseShifter | Absorber => {
            let bkind = object_to_placeable(tile.object)
            match bkind {
              Some(pk) => {
                for b in level.budget {
                  if b.kind == pk {
                    b.used -= 1
                  }
                }
                game.objects_placed -= 1
              }
              None => ()
            }
            tile.object = Empty
          }
          _ => ()
        }
      }
    }
  }
  // Enter or Space to start simulation
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    // Save edit state for reset
    game.edit_grid = @types.clone_grid(game.grid)
    game.play_state = Simulating
    game.sim_tick = 0
    game.sim_timer = 0.0
  }
  // S for step mode
  if @raylib.is_key_pressed(@raylib.KeyS) {
    game.edit_grid = @types.clone_grid(game.grid)
    game.play_state = Stepping
    game.sim_tick = 0
    game.sim_timer = 0.0
  }
}

///|
fn update_simulating(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyR) {
    reset_to_edit(game)
    return
  }
  game.sim_timer += 1.0 / 60.0 * game.sim_speed
  if game.sim_timer >= @types.sim_tick_interval {
    game.sim_timer -= @types.sim_tick_interval
    do_sim_tick(game)
  }
}

///|
fn update_stepping(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyR) {
    reset_to_edit(game)
    return
  }
  // Space or Enter to advance one tick
  if @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) {
    do_sim_tick(game)
  }
  // P to switch to auto simulation
  if @raylib.is_key_pressed(@raylib.KeyP) {
    game.play_state = Simulating
  }
}

///|
fn update_complete(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = Results
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}

///|
fn update_failed(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyR) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) {
    reset_to_edit(game)
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  // N for next level
  if @raylib.is_key_pressed(@raylib.KeyN) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) {
    if game.current_level < @types.total_levels - 1 {
      game.current_level += 1
      load_level(game)
      game.screen = Playing
    } else {
      game.screen = LevelSelect
    }
  }
  // R to retry
  if @raylib.is_key_pressed(@raylib.KeyR) {
    load_level(game)
    game.screen = Playing
  }
}

///|
fn do_sim_tick(game : @types.Game) -> Unit {
  game.sim_tick += 1
  @wave.simulate_tick(game.grid)
  let all_ok = @wave.check_targets(game.grid)
  if all_ok {
    // Level complete
    game.play_state = Complete
    // Calculate score
    let level = @levels.get_level(game.current_level)
    let mut stars = 1
    if game.objects_placed <= level.par_objects {
      stars = 2
    }
    if game.objects_placed <= level.par_objects &&
      game.sim_tick <= level.par_ticks {
      stars = 3
    }
    let score = game.scores[game.current_level]
    score.completed = true
    if stars > score.stars {
      score.stars = stars
    }
    score.objects_used = game.objects_placed
    score.ticks_used = game.sim_tick
    game.message = "Level Complete!"
    game.message_timer = 3.0
  } else if game.sim_tick >= @types.max_ticks {
    game.play_state = Failed
    game.message = "Time's up! Press R to retry."
    game.message_timer = 5.0
  }
}

///|
fn reset_to_edit(game : @types.Game) -> Unit {
  // Restore grid from edit snapshot
  let level = @levels.get_level(game.current_level)
  // Reset budget used counts
  for b in level.budget {
    b.used = 0
  }
  load_level(game)
  game.play_state = Editing
  game.sim_tick = 0
  game.sim_timer = 0.0
}

///|
pub fn load_level(game : @types.Game) -> Unit {
  let level = @levels.get_level(game.current_level)
  let grid = @types.new_wave_grid()
  // Place walls from pre_placed
  for pp in level.pre_placed {
    if @types.grid_in_bounds(pp.x, pp.y) {
      let tile = @types.grid_get(grid, pp.x, pp.y)
      match pp.kind {
        Wall => {
          tile.has_wall = true
          tile.object = Wall
        }
        _ => tile.object = pp.kind
      }
    }
  }
  // Place targets
  for td in level.targets {
    if @types.grid_in_bounds(td.x, td.y) {
      let tile = @types.grid_get(grid, td.x, td.y)
      tile.is_target = true
      tile.target_min = td.min_amp
      tile.target_max = td.max_amp
      tile.target_phase = td.phase
      tile.object = Target
    }
  }
  // Reset budget
  for b in level.budget {
    b.used = 0
  }
  game.grid = grid
  game.edit_grid = @types.clone_grid(grid)
  game.play_state = Editing
  game.sim_tick = 0
  game.sim_timer = 0.0
  game.objects_placed = 0
  game.selected_slot = 0
  game.emitter_phase = 0
  game.message = ""
  game.message_timer = 0.0
  game.sim_speed = 1.0
}

///|
fn is_pre_placed(level : @types.Level, x : Int, y : Int) -> Bool {
  for pp in level.pre_placed {
    if pp.x == x && pp.y == y {
      return true
    }
  }
  false
}

///|
fn object_to_placeable(kind : @types.TileKind) -> @types.PlaceableKind? {
  match kind {
    Emitter(_) => Some(PlaceEmitter)
    Reflector => Some(PlaceReflector)
    PhaseShifter => Some(PlacePhaseShifter)
    Absorber => Some(PlaceAbsorber)
    _ => None
  }
}
