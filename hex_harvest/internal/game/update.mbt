///|
/// Main update dispatch
pub fn update(game : @types.Game) -> Unit {
  let dt = @types.minf(@raylib.get_frame_time(), 0.05)
  game.frame_count += 1
  // Update message timer
  if game.message_timer > 0.0 {
    game.message_timer -= dt
    if game.message_timer <= 0.0 {
      game.message = ""
    }
  }
  // Update animations
  if game.water_anim_timer > 0.0 {
    game.water_anim_timer -= dt
    if game.water_anim_timer <= 0.0 {
      game.newly_watered = []
    }
  }
  if game.harvest_anim_timer > 0.0 {
    game.harvest_anim_timer -= dt
    if game.harvest_anim_timer <= 0.0 {
      game.newly_harvested = []
    }
  }
  // Update click feedback
  if game.click_feedback_timer > 0.0 {
    game.click_feedback_timer -= dt
  }
  // Update staged turn phase timer
  if game.phase_timer > 0.0 {
    game.phase_timer -= dt
    if game.phase_timer <= 0.0 {
      advance_turn_phase(game)
    }
  }
  match game.screen {
    Title => process_title_input(game)
    WorldSelect => process_world_select_input(game)
    LevelSelect => process_level_select_input(game)
    Playing => update_playing(game)
    Results => process_results_input(game)
  }
}

///|
fn update_playing(game : @types.Game) -> Unit {
  // Update hover
  update_hover(game)
  // Process input
  process_playing_input(game)
}

///|
fn update_hover(game : @types.Game) -> Unit {
  let mx = Float::from_int(@raylib.get_mouse_x())
  let my = Float::from_int(@raylib.get_mouse_y())
  let (col, row) = @hex.hex_at_screen(mx, my)
  game.hover_col = col
  game.hover_row = row
  if @types.hex_in_bounds(col, row) {
    let tile = game.level.grid.tiles[row][col]
    game.hover_valid = match game.place_mode {
      CropPlace(_) => @types.tile_plantable(tile)
      ChannelPlace => @types.tile_channelable(tile)
    }
  } else {
    game.hover_valid = false
  }
}

///|
/// Process title screen input
fn process_title_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyDown) || @raylib.is_key_pressed(@raylib.KeyS) {
    game.menu_selection = (game.menu_selection + 1) % 2
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) || @raylib.is_key_pressed(@raylib.KeyW) {
    game.menu_selection = (game.menu_selection + 1) % 2
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    match game.menu_selection {
      0 => {
        game.screen = WorldSelect
        game.menu_selection = 0
      }
      _ => () // Quit handled by window close
    }
  }
}

///|
fn process_world_select_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyRight) || @raylib.is_key_pressed(@raylib.KeyD) {
    game.menu_selection = (game.menu_selection + 1) % @types.total_worlds
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) || @raylib.is_key_pressed(@raylib.KeyA) {
    game.menu_selection = (game.menu_selection + @types.total_worlds - 1) % @types.total_worlds
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.world_index = game.menu_selection
    game.screen = LevelSelect
    game.menu_selection = 0
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
    game.menu_selection = 0
  }
}

///|
fn process_level_select_input(game : @types.Game) -> Unit {
  // Navigate 4x2 grid
  if @raylib.is_key_pressed(@raylib.KeyRight) || @raylib.is_key_pressed(@raylib.KeyD) {
    game.menu_selection = (game.menu_selection + 1) % @types.levels_per_world
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) || @raylib.is_key_pressed(@raylib.KeyA) {
    game.menu_selection = (game.menu_selection + @types.levels_per_world - 1) % @types.levels_per_world
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) || @raylib.is_key_pressed(@raylib.KeyS) {
    let next = game.menu_selection + 4
    if next < @types.levels_per_world {
      game.menu_selection = next
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) || @raylib.is_key_pressed(@raylib.KeyW) {
    let prev = game.menu_selection - 4
    if prev >= 0 {
      game.menu_selection = prev
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    let global_index = game.world_index * @types.levels_per_world + game.menu_selection
    start_level(game, global_index)
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = WorldSelect
    game.menu_selection = game.world_index
  }
}

///|
/// Process playing state input
fn process_playing_input(game : @types.Game) -> Unit {
  // Crop selection via number keys
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    game.selected_crop = Wheat
    game.place_mode = CropPlace(Wheat)
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) {
    game.selected_crop = Corn
    game.place_mode = CropPlace(Corn)
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) {
    game.selected_crop = Berry
    game.place_mode = CropPlace(Berry)
  }
  if @raylib.is_key_pressed(@raylib.KeyFour) {
    game.selected_crop = Flower
    game.place_mode = CropPlace(Flower)
  }
  if @raylib.is_key_pressed(@raylib.KeyFive) {
    game.place_mode = ChannelPlace
  }
  // Place crop/channel on click
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    if game.hover_valid && @types.hex_in_bounds(game.hover_col, game.hover_row) {
      // Save undo state
      save_undo(game)
      let tile = game.level.grid.tiles[game.hover_row][game.hover_col]
      match game.place_mode {
        CropPlace(kind) => {
          tile.crop = Some(kind)
          tile.crop_state = Seed
          tile.crop_turns = 0
        }
        ChannelPlace => tile.has_channel = true
      }
      // Execute turn
      execute_turn(game)
    }
  }
  // Remove crop on right-click
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
    if @types.hex_in_bounds(game.hover_col, game.hover_row) {
      let rtile = game.level.grid.tiles[game.hover_row][game.hover_col]
      match rtile.crop {
        Some(_) =>
          if rtile.crop_state != Harvested {
            save_undo(game)
            rtile.crop = None
            rtile.crop_state = Seed
            rtile.crop_turns = 0
            @types.set_message(game, "Crop removed", 0.6)
          }
        None => ()
      }
    }
  }
  // End turn without placing (Enter)
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    save_undo(game)
    execute_turn(game)
  }
  // Undo
  if @raylib.is_key_pressed(@raylib.KeyU) {
    undo(game)
  }
  // Restart level
  if @raylib.is_key_pressed(@raylib.KeyR) {
    let global_index = game.world_index * @types.levels_per_world + game.level_index % @types.levels_per_world
    start_level(game, global_index)
  }
  // Back to menu
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    game.menu_selection = game.level_index % @types.levels_per_world
  }
}

///|
/// Execute a turn: water flow -> crop growth -> harvest
pub fn execute_turn(game : @types.Game) -> Unit {
  game.turn += 1
  // 1. Water flows
  let new_water = @water.flow_water(game.level.grid)
  game.newly_watered = new_water
  game.water_anim_timer = 1.0
  // 2. Grow crops
  let _matured = @crops.grow_crops(game.level.grid)
  // 3. Auto-harvest mature crops
  let (yield_gained, harvested) = @crops.harvest_mature(game.level.grid)
  if yield_gained > 0 {
    game.yield_collected += yield_gained
    game.newly_harvested = harvested
    game.harvest_anim_timer = 1.5
  }
  // 4. Check goals (harvested crops on goal tiles)
  check_goals(game)
  // 5. Check end conditions
  if game.yield_collected >= game.level.target_yield {
    complete_level(game)
  } else if game.turn >= game.level.turn_budget {
    // Out of turns - still show results
    game.score = calculate_score(game)
    game.level_complete = false
    game.screen = Results
  }
}

///|
pub fn check_goals(game : @types.Game) -> Unit {
  let mut goals_done = 0
  for i in 0..<game.level.goals.length() {
    let goal = game.level.goals[i]
    let tile = game.level.grid.tiles[goal.row][goal.col]
    // Goal is "collected" if a crop was harvested there
    match tile.crop {
      Some(_) =>
        if tile.crop_state == Harvested {
          goals_done += 1
        }
      None => ()
    }
  }
  game.goals_collected = goals_done
}

///|
/// Start a level
pub fn start_level(game : @types.Game, index : Int) -> Unit {
  game.level = @levels.load_level(index)
  game.level_index = index
  game.turn = 0
  game.yield_collected = 0
  game.goals_collected = 0
  game.selected_crop = Wheat
  game.place_mode = CropPlace(Wheat)
  game.hover_col = -1
  game.hover_row = -1
  game.hover_valid = false
  game.newly_watered = []
  game.newly_harvested = []
  game.water_anim_timer = 0.0
  game.harvest_anim_timer = 0.0
  game.undo_stack = []
  game.level_complete = false
  game.fade_timer = 0.0
  game.message = ""
  game.message_timer = 0.0
  game.score = @types.new_level_score()
  game.screen = Playing
  @types.set_message(game, game.level.name, 2.0)
}

///|
pub fn complete_level(game : @types.Game) -> Unit {
  game.level_complete = true
  game.score = calculate_score(game)
  // Save best score
  let w = game.world_index
  let l = game.level_index % @types.levels_per_world
  match game.level_scores[w][l] {
    Some(prev) =>
      if game.score.stars > prev.stars {
        game.level_scores[w][l] = Some(game.score)
      }
    None => game.level_scores[w][l] = Some(game.score)
  }
  game.screen = Results
}

///|
pub fn calculate_score(game : @types.Game) -> @types.LevelScore {
  let mut stars = 0
  // Star 1: reach target yield
  if game.yield_collected >= game.level.target_yield {
    stars = 1
  }
  // Star 2: reach target within par turns
  if game.yield_collected >= game.level.target_yield && game.turn <= game.level.par_turns {
    stars = 2
  }
  // Star 3: all goals collected
  if game.yield_collected >= game.level.target_yield &&
    game.turn <= game.level.par_turns &&
    (game.level.goals.length() == 0 || game.goals_collected >= game.level.goals.length()) {
    stars = 3
  }
  {
    yield_collected: game.yield_collected,
    target_yield: game.level.target_yield,
    turns_used: game.turn,
    turn_budget: game.level.turn_budget,
    par_turns: game.level.par_turns,
    goals_collected: game.goals_collected,
    total_goals: game.level.goals.length(),
    stars,
  }
}

///|
fn process_results_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.screen = LevelSelect
    game.menu_selection = game.level_index % @types.levels_per_world
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    let global_index = game.world_index * @types.levels_per_world + game.level_index % @types.levels_per_world
    start_level(game, global_index)
  }
}

///|
pub fn save_undo(game : @types.Game) -> Unit {
  let saved_tiles = @types.clone_grid_tiles(game.level.grid)
  let state : @types.UndoState = {
    tiles: saved_tiles,
    turn: game.turn,
    yield_collected: game.yield_collected,
    goals_collected: game.goals_collected,
  }
  game.undo_stack.push(state)
  // Limit undo stack
  if game.undo_stack.length() > 30 {
    ignore(game.undo_stack.remove(0))
  }
}

///|
pub fn undo(game : @types.Game) -> Unit {
  if game.undo_stack.length() == 0 {
    @types.set_message(game, "Nothing to undo", 1.0)
    return
  }
  let state = game.undo_stack.pop()
  match state {
    Some(s) => {
      @types.restore_grid_tiles(game.level.grid, s.tiles)
      game.turn = s.turn
      game.yield_collected = s.yield_collected
      game.goals_collected = s.goals_collected
      game.newly_watered = []
      game.newly_harvested = []
      game.water_anim_timer = 0.0
      game.harvest_anim_timer = 0.0
      @types.set_message(game, "Undone", 0.8)
    }
    None => ()
  }
}
