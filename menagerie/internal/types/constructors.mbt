///|
pub fn new_game() -> Game {
  let grid = Grid::new(grid_cols, grid_rows)
  let level_results : Array[LevelResult?] = []
  let stars_earned : Array[Int] = []
  for _i in 0..<total_levels {
    level_results.push(None)
    stars_earned.push(0)
  }
  {
    screen: Title,
    grid,
    current_level: 0,
    current_tool: TerrainBrush(Grass),
    tool_slots: build_tool_slots(),
    enclosures: [],
    level_results,
    stars_earned,
    hover_col: -1,
    hover_row: -1,
    fence_mode: Horizontal,
    message: "",
    message_timer: 0.0,
    anim_timer: 0.0,
    frame_count: 0,
    total_stars: 0,
    levels_completed: 0,
    level_select_scroll: 0,
    show_needs_panel: true,
  }
}

///|
pub fn build_tool_slots() -> Array[ToolSlot] {
  [
    { tool: TerrainBrush(Grass), label: "Grass", color: color_grass },
    { tool: TerrainBrush(Water), label: "Water", color: color_water },
    { tool: TerrainBrush(Sand), label: "Sand", color: color_sand },
    { tool: TerrainBrush(Rock), label: "Rock", color: color_rock },
    { tool: TerrainBrush(Trees), label: "Trees", color: color_trees },
    { tool: FenceTool, label: "Fence", color: color_fence },
    { tool: EraserTool, label: "Erase", color: color_hud_text },
  ]
}

///|
pub fn new_level_result() -> LevelResult {
  {
    stars: Zero,
    all_needs_met: false,
    tiles_used: 0,
    par_tiles: 0,
    bonus_met: false,
    messages: [],
  }
}

///|
pub fn set_message(game : Game, msg : String) -> Unit {
  game.message = msg
  game.message_timer = 2.5
}

///|
pub fn Game::is_level_unlocked(self : Game, level_id : Int) -> Bool {
  if level_id == 0 {
    return true
  }
  if level_id > 0 && self.stars_earned[level_id - 1] > 0 {
    return true
  }
  false
}

///|
pub fn tier_label(tier : Int) -> String {
  match tier {
    1 => "I"
    2 => "II"
    3 => "III"
    _ => "?"
  }
}
