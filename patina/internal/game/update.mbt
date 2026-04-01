///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count = game.frame_count + 1
  let dt = @types.minf(@raylib.get_frame_time(), 0.05)
  // Update message timer
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - dt
  }
  // Update animation timer
  if game.anim_timer > 0.0 {
    game.anim_timer = game.anim_timer - dt
    if game.anim_timer <= 0.0 {
      game.anim_region = -1
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
  game.title_anim_timer = game.title_anim_timer +
    @raylib.get_frame_time()
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = TierSelect
  }
}

///|
fn update_tier_select(game : @types.Game) -> Unit {
  let idx = @types.tier_index(game.selected_tier)
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    if idx < 2 {
      game.selected_tier = @types.tier_from_index(idx + 1)
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    if idx > 0 {
      game.selected_tier = @types.tier_from_index(idx - 1)
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    let (lo, _hi) = @types.tier_level_range(game.selected_tier)
    game.selected_level = lo
    game.screen = LevelSelect
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  let (lo, hi) = @types.tier_level_range(game.selected_tier)
  let count = hi - lo
  let cols = if count <= 4 { count } else { 4 }
  let local_idx = game.selected_level - lo
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    if game.selected_level < hi - 1 {
      game.selected_level = game.selected_level + 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    if game.selected_level > lo {
      game.selected_level = game.selected_level - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    let next = local_idx + cols
    if next < count {
      game.selected_level = lo + next
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    let prev = local_idx - cols
    if prev >= 0 {
      game.selected_level = lo + prev
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    start_level(game, game.selected_level)
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = TierSelect
  }
}

///|
fn start_level(game : @types.Game, level_idx : Int) -> Unit {
  let level = @levels.get_level(level_idx)
  // Deep copy regions for the working copy
  let regions : Array[@types.Region] = []
  for i in 0..<level.artwork.regions.length() {
    regions.push(@types.clone_region(level.artwork.regions[i]))
  }
  let working_art = @types.new_artwork(
    level.artwork.width,
    level.artwork.height,
    regions,
  )
  let working_level : @types.Level = {
    tier: level.tier,
    name: level.name,
    artwork: working_art,
    budget: level.budget,
    par_tools: level.par_tools,
  }
  game.current_level = Some(working_level)
  game.current_budget = Some(@types.clone_budget(level.budget))
  game.selected_tool = Clean
  game.play_state = Selecting
  game.undo_stack = []
  game.total_tools_used = 0
  game.hover_region = -1
  game.anim_region = -1
  game.anim_timer = 0.0
  game.score = None
  game.message = ""
  game.message_timer = 0.0
  game.screen = Playing
}

///|
fn update_playing(game : @types.Game) -> Unit {
  match game.current_level {
    None => return
    Some(level) => {
      // Tool selection via number keys
      if @raylib.is_key_pressed(@raylib.KeyOne) {
        game.selected_tool = Clean
      }
      if @raylib.is_key_pressed(@raylib.KeyTwo) {
        game.selected_tool = Fill
      }
      if @raylib.is_key_pressed(@raylib.KeyThree) {
        game.selected_tool = Retouch
      }
      if @raylib.is_key_pressed(@raylib.KeyFour) {
        game.selected_tool = Seal
      }
      // Undo with Z
      if @raylib.is_key_pressed(@raylib.KeyZ) {
        undo_last(game)
      }
      // Restart with R
      if @raylib.is_key_pressed(@raylib.KeyR) {
        start_level(game, game.selected_level)
        return
      }
      // Back to level select with ESC
      if @raylib.is_key_pressed(@raylib.KeyEscape) {
        game.screen = LevelSelect
        return
      }
      // Mouse hover detection
      let mx = @raylib.get_mouse_x()
      let my = @raylib.get_mouse_y()
      game.hover_region = get_region_at(mx, my)
      // Mouse click to apply tool
      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        let region_idx = get_region_at(mx, my)
        if region_idx >= 0 && region_idx < level.artwork.regions.length() {
          try_apply_tool(game, level, region_idx)
        }
      }
      // Check level completion
      if game.play_state == Selecting && @restoration.is_level_complete(
        level.artwork,
      ) {
        complete_level(game, level)
      }
    }
  }
}

///|
fn get_region_at(mx : Int, my : Int) -> Int {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let sz = @types.region_size
  let pad = @types.grid_padding
  let cols = @types.grid_cols
  let rows = @types.grid_rows
  // Check bounds
  let total_w = cols * sz + (cols - 1) * pad
  let total_h = rows * sz + (rows - 1) * pad
  if mx < ox || mx >= ox + total_w || my < oy || my >= oy + total_h {
    return -1
  }
  let rel_x = mx - ox
  let rel_y = my - oy
  let cell_w = sz + pad
  let col = rel_x / cell_w
  let row = rel_y / cell_w
  // Check if in padding gap
  let in_cell_x = rel_x - col * cell_w
  let in_cell_y = rel_y - row * cell_w
  if in_cell_x >= sz || in_cell_y >= sz {
    return -1
  }
  if col >= cols || row >= rows {
    return -1
  }
  row * cols + col
}

///|
fn try_apply_tool(
  game : @types.Game,
  level : @types.Level,
  region_idx : Int
) -> Unit {
  let budget = match game.current_budget {
    Some(b) => b
    None => return
  }
  let tool = game.selected_tool
  let remaining = @types.get_budget_for_tool(budget, tool)
  if remaining <= 0 {
    game.message = "No " + @types.tool_name(tool) + " uses remaining!"
    game.message_timer = 1.5
    return
  }
  let region = level.artwork.regions[region_idx]
  // Save undo state before applying
  let prev_treats : Array[@types.ToolKind] = []
  for i in 0..<region.treatments_applied.length() {
    prev_treats.push(region.treatments_applied[i])
  }
  let undo : @types.UndoEntry = {
    region_index: region_idx,
    prev_state: region.state,
    prev_treatments: prev_treats,
    prev_fragile: region.fragile,
    prev_stain_permanent: region.stain_permanent,
    tool_used: tool,
  }
  // Try to apply
  let applied = @restoration.apply_tool(region, tool)
  if applied {
    game.undo_stack.push(undo)
    @types.use_budget(budget, tool)
    game.total_tools_used = game.total_tools_used + 1
    game.anim_region = region_idx
    game.anim_timer = 0.4
    // Feedback message
    match region.state {
      Worsened => {
        game.message = "Damage worsened!"
        game.message_timer = 1.5
      }
      Restored => {
        game.message = "Region restored!"
        game.message_timer = 1.0
      }
      _ => ()
    }
  } else {
    game.message = "Cannot apply " +
      @types.tool_name(tool) +
      " here"
    game.message_timer = 1.0
  }
}

///|
fn undo_last(game : @types.Game) -> Unit {
  if game.undo_stack.length() == 0 {
    game.message = "Nothing to undo"
    game.message_timer = 0.8
    return
  }
  let entry = game.undo_stack.pop().unwrap()
  match game.current_level {
    None => return
    Some(level) => {
      let region = level.artwork.regions[entry.region_index]
      // Restore previous state
      region.state = entry.prev_state
      region.fragile = entry.prev_fragile
      region.stain_permanent = entry.prev_stain_permanent
      // Restore damage types - we need to reconstruct from original level
      // For simplicity, remove the last treatment and restore state
      while region.treatments_applied.length() > 0 {
        let _ = region.treatments_applied.pop()

      }
      for i in 0..<entry.prev_treatments.length() {
        region.treatments_applied.push(entry.prev_treatments[i])
      }
      // We also need to restore the damage_types. Since we can't perfectly
      // reconstruct, we reload the original region's damage types and replay.
      restore_region_damage(game, level, entry.region_index, entry.prev_treatments)
      // Restore budget
      match game.current_budget {
        Some(b) => @types.restore_budget(b, entry.tool_used)
        None => ()
      }
      game.total_tools_used = game.total_tools_used - 1
      game.message = "Undone"
      game.message_timer = 0.6
    }
  }
}

///|
fn restore_region_damage(
  game : @types.Game,
  _level : @types.Level,
  region_idx : Int,
  _prev_treatments : Array[@types.ToolKind]
) -> Unit {
  // Get the original level data to restore damage types
  let orig_level = @levels.get_level(game.selected_level)
  if region_idx < orig_level.artwork.regions.length() {
    let orig = orig_level.artwork.regions[region_idx]
    match game.current_level {
      Some(cur_level) => {
        let region = cur_level.artwork.regions[region_idx]
        // Clear current damage types
        while region.damage_types.length() > 0 {
          let _ = region.damage_types.pop()

        }
        // Restore original damage
        for i in 0..<orig.damage_types.length() {
          region.damage_types.push(orig.damage_types[i])
        }
        // Replay all previous treatments to get correct state
        // Reset the region first
        region.state = if orig.damage_types.length() == 0 {
          Pristine
        } else {
          Damaged
        }
        region.fragile = false
        region.stain_permanent = false
        while region.treatments_applied.length() > 0 {
          let _ = region.treatments_applied.pop()

        }
        // Re-read the saved treatments from the undo entry's prev state
        // The prev_treatments were saved before the tool was applied
        // We need to replay those treatments
        let saved_treats = _prev_treatments
        // Restore original damage again (replay will modify it)
        while region.damage_types.length() > 0 {
          let _ = region.damage_types.pop()

        }
        for i in 0..<orig.damage_types.length() {
          region.damage_types.push(orig.damage_types[i])
        }
        region.state = if orig.damage_types.length() == 0 {
          Pristine
        } else {
          Damaged
        }
        region.fragile = false
        region.stain_permanent = false
        // Replay treatments
        for i in 0..<saved_treats.length() {
          let _ = @restoration.apply_tool(region, saved_treats[i])

        }
      }
      None => ()
    }
  }
}

///|
fn complete_level(game : @types.Game, level : @types.Level) -> Unit {
  let stars = @restoration.calculate_stars(
    level.artwork,
    game.total_tools_used,
    level.par_tools,
  )
  let score_info = @restoration.check_completion(level.artwork)
  let score : @types.LevelScore = {
    stars,
    restored_count: score_info.restored_count,
    worsened_count: score_info.worsened_count,
    sealed_count: score_info.sealed_count,
    total_tools_used: game.total_tools_used,
  }
  game.score = Some(score)
  // Update best score
  if stars > game.level_scores[game.selected_level] {
    game.level_scores[game.selected_level] = stars
  }
  game.screen = Results
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    // Next level
    if game.selected_level < 19 {
      game.selected_level = game.selected_level + 1
      start_level(game, game.selected_level)
    } else {
      game.screen = LevelSelect
    }
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.selected_level)
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}
