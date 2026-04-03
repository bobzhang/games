///|
pub fn update(game : @types.Game) -> Unit {
  let dt = @raylib.get_frame_time()
  game.frame_count += 1
  game.anim_timer = game.anim_timer + dt
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - dt
    if game.message_timer <= 0.0 {
      game.message = ""
    }
  }
  match game.screen {
    Title => update_title(game)
    LevelSelect => update_level_select(game)
    Playing => update_playing(game)
    LevelComplete => update_level_complete(game)
    Paused => update_paused(game)
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.screen = LevelSelect
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
    return
  }
  let visible = @types.level_visible_count
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    if game.level_select_scroll > 0 {
      game.level_select_scroll -= 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    let max_scroll = @levels.level_count() - visible
    if game.level_select_scroll < max_scroll {
      game.level_select_scroll += 1
    }
  }
  // Handle mouse clicks on level buttons
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    handle_level_select_click(game, mx, my)
  }
  // Number keys 1-9 for quick level selection
  let number_keys = [
    @raylib.KeyOne,
    @raylib.KeyTwo,
    @raylib.KeyThree,
    @raylib.KeyFour,
    @raylib.KeyFive,
    @raylib.KeySix,
    @raylib.KeySeven,
    @raylib.KeyEight,
    @raylib.KeyNine,
  ]
  for i, key in number_keys {
    if @raylib.is_key_pressed(key) {
      let lvl = game.level_select_scroll + i
      if lvl < @levels.level_count() && game.is_level_unlocked(lvl) {
        start_level(game, lvl)
        return
      }
    }
  }
}

///|
fn handle_level_select_click(game : @types.Game, mx : Int, my : Int) -> Unit {
  let start_y = @types.level_button_y
  let button_h = @types.level_button_h
  let gap = @types.level_button_gap
  let visible = @types.level_visible_count
  let bx = @types.level_button_x
  let bw = @types.level_button_w
  for i in 0..<visible {
    let lvl = game.level_select_scroll + i
    if lvl >= @levels.level_count() {
      break
    }
    let by = start_y + i * (button_h + gap)
    if mx >= bx && mx <= bx + bw && my >= by && my < by + button_h {
      if game.is_level_unlocked(lvl) {
        start_level(game, lvl)
      }
      return
    }
  }
}

///|
fn start_level(game : @types.Game, level_id : Int) -> Unit {
  game.current_level = level_id
  game.screen = Playing
  game.grid.clear()
  game.current_tool = TerrainBrush(Grass)
  game.show_needs_panel = true
  game.fence_mode = Horizontal
  let level = @levels.get_level(level_id)
  // Apply preset terrain
  for pt in level.preset_terrain {
    game.grid.set_terrain(pt.0, pt.1, Some(pt.2))
  }
  // Apply preset fences
  for pf in level.preset_fences {
    if pf.2 {
      game.grid.set_fence_top(pf.0, pf.1, true)
    }
    if pf.3 {
      game.grid.set_fence_left(pf.0, pf.1, true)
    }
  }
  // Place animal placers in tool slots
  rebuild_tool_slots(game, level)
  refresh_enclosures(game)
  @types.set_message(game, level.description)
}

///|
fn rebuild_tool_slots(game : @types.Game, level : @types.LevelDef) -> Unit {
  let slots = @types.build_tool_slots()
  for sp in level.species {
    slots.push({
      tool: AnimalPlacer(sp),
      label: @types.species_icon(sp),
      color: @types.species_color(sp),
    })
  }
  game.tool_slots = slots
}

///|
fn refresh_enclosures(game : @types.Game) -> Unit {
  game.enclosures = @habitat.find_enclosures(game.grid)
  @habitat.assign_animals_to_enclosures(game.grid, game.enclosures)
}

///|
fn update_playing(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Paused
    return
  }
  // Tool hotkeys: 1-5 for terrain, 6 for fence, 7 for eraser
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    game.current_tool = TerrainBrush(Grass)
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) {
    game.current_tool = TerrainBrush(Water)
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) {
    game.current_tool = TerrainBrush(Sand)
  }
  if @raylib.is_key_pressed(@raylib.KeyFour) {
    game.current_tool = TerrainBrush(Rock)
  }
  if @raylib.is_key_pressed(@raylib.KeyFive) {
    game.current_tool = TerrainBrush(Trees)
  }
  if @raylib.is_key_pressed(@raylib.KeySix) {
    game.current_tool = FenceTool
  }
  if @raylib.is_key_pressed(@raylib.KeySeven) {
    game.current_tool = EraserTool
  }
  // Toggle fence mode with Tab
  if @raylib.is_key_pressed(@raylib.KeyTab) {
    game.fence_mode = match game.fence_mode {
      Horizontal => Vertical
      Vertical => Horizontal
    }
  }
  // Toggle needs panel with N
  if @raylib.is_key_pressed(@raylib.KeyN) {
    game.show_needs_panel = game.show_needs_panel == false
  }
  // Check / validate with Enter
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    check_level(game)
    return
  }
  // Reset with R
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.current_level)
    return
  }
  // Update hover position
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let gx = @types.grid_offset_x
  let gy = @types.grid_offset_y
  let cs = @types.cell_size
  let col = (mx - gx) / cs
  let row = (my - gy) / cs
  if col >= 0 &&
    col < @types.grid_cols &&
    row >= 0 &&
    row < @types.grid_rows &&
    mx >= gx &&
    my >= gy {
    game.hover_col = col
    game.hover_row = row
  } else {
    game.hover_col = -1
    game.hover_row = -1
  }
  // Handle toolbar clicks
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    if my < @types.grid_offset_y {
      handle_toolbar_click(game, mx, my)
      return
    }
  }
  // Handle grid clicks
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) ||
    @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) {
    if game.hover_col >= 0 && game.hover_row >= 0 {
      handle_grid_click(game, game.hover_col, game.hover_row)
    }
  }
  // Right click to erase
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) ||
    @raylib.is_mouse_button_down(@raylib.MouseButtonRight) {
    if game.hover_col >= 0 && game.hover_row >= 0 {
      handle_grid_erase(game, game.hover_col, game.hover_row)
    }
  }
}

///|
fn handle_toolbar_click(game : @types.Game, mx : Int, _my : Int) -> Unit {
  let slot_w = @types.toolbar_slot_w
  let slot_gap = @types.toolbar_slot_gap
  let start_x = @types.toolbar_start_x
  for i, slot in game.tool_slots {
    let sx = start_x + i * (slot_w + slot_gap)
    if mx >= sx && mx < sx + slot_w {
      game.current_tool = slot.tool
      return
    }
  }
}

///|
fn handle_grid_click(game : @types.Game, col : Int, row : Int) -> Unit {
  match game.current_tool {
    TerrainBrush(terrain) => {
      game.grid.set_terrain(col, row, Some(terrain))
      refresh_enclosures(game)
    }
    FenceTool =>
      match game.fence_mode {
        Horizontal => {
          let current = match game.grid.get(col, row) {
            Some(cell) => cell.fence_top
            None => false
          }
          game.grid.set_fence_top(col, row, current == false)
          refresh_enclosures(game)
        }
        Vertical => {
          let current = match game.grid.get(col, row) {
            Some(cell) => cell.fence_left
            None => false
          }
          game.grid.set_fence_left(col, row, current == false)
          refresh_enclosures(game)
        }
      }
    EraserTool => {
      game.grid.set_terrain(col, row, None)
      game.grid.set_animal(col, row, None)
      game.grid.set_fence_top(col, row, false)
      game.grid.set_fence_left(col, row, false)
      refresh_enclosures(game)
    }
    AnimalPlacer(species) => {
      // Remove this species from any other cell first
      remove_species_from_grid(game.grid, species)
      game.grid.set_animal(col, row, Some(species))
      refresh_enclosures(game)
    }
  }
}

///|
fn handle_grid_erase(game : @types.Game, col : Int, row : Int) -> Unit {
  game.grid.set_terrain(col, row, None)
  game.grid.set_animal(col, row, None)
  game.grid.set_fence_top(col, row, false)
  game.grid.set_fence_left(col, row, false)
  refresh_enclosures(game)
}

///|
fn remove_species_from_grid(
  grid : @types.Grid,
  species : @types.Species,
) -> Unit {
  for r in 0..<grid.rows {
    for c in 0..<grid.cols {
      match grid.cells[r][c].animal {
        Some(sp) => if sp == species { grid.cells[r][c].animal = None }
        None => ()
      }
    }
  }
}

///|
fn check_level(game : @types.Game) -> Unit {
  let level = @levels.get_level(game.current_level)
  refresh_enclosures(game)
  let result = @habitat.validate_level(game.grid, level, game.enclosures)
  game.level_results[game.current_level] = Some(result)
  if result.all_needs_met {
    let stars = @habitat.star_count(result.stars)
    if stars > game.stars_earned[game.current_level] {
      game.stars_earned[game.current_level] = stars
      recount_total_stars(game)
    }
    game.levels_completed = count_completed(game)
    game.screen = LevelComplete
    @types.set_message(game, "Level complete!")
  } else {
    let msg = if result.messages.length() > 0 {
      result.messages[0]
    } else {
      "Needs not met"
    }
    @types.set_message(game, msg)
  }
}

///|
fn recount_total_stars(game : @types.Game) -> Unit {
  let mut total = 0
  for s in game.stars_earned {
    total += s
  }
  game.total_stars = total
}

///|
fn count_completed(game : @types.Game) -> Int {
  let mut count = 0
  for s in game.stars_earned {
    if s > 0 {
      count += 1
    }
  }
  count
}

///|
fn update_level_complete(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.screen = LevelSelect
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.current_level)
  }
  if @raylib.is_key_pressed(@raylib.KeyN) {
    let next = game.current_level + 1
    if next < @levels.level_count() {
      start_level(game, next)
    } else {
      game.screen = LevelSelect
    }
  }
}

///|
fn update_paused(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = Playing
  }
  if @raylib.is_key_pressed(@raylib.KeyQ) {
    game.screen = LevelSelect
  }
}
