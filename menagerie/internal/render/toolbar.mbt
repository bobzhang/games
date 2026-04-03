///|
fn draw_toolbar(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  // Toolbar background
  @raylib.draw_rectangle(
    0, 0, sw, @types.grid_offset_y, @types.color_toolbar_bg,
  )
  let slot_w = @types.toolbar_slot_w
  let slot_gap = @types.toolbar_slot_gap
  let start_x = @types.toolbar_start_x
  let start_y = 8
  let slot_h = @types.toolbar_slot_h
  for i, slot in game.tool_slots {
    let sx = start_x + i * (slot_w + slot_gap)
    // Highlight selected tool
    let is_selected = tool_eq(game.current_tool, slot.tool)
    if is_selected {
      @raylib.draw_rectangle(
        sx - 2,
        start_y - 2,
        slot_w + 4,
        slot_h + 4,
        @types.color_tool_selected,
      )
    }
    // Tool background
    @raylib.draw_rectangle(sx, start_y, slot_w, slot_h, slot.color)
    // Darken slightly
    @raylib.draw_rectangle(
      sx,
      start_y,
      slot_w,
      slot_h,
      @raylib.Color::new(0, 0, 0, 80),
    )
    // Label
    let lw = @draw.measure_text(slot.label, 14)
    @draw.draw_text(
      slot.label,
      sx + (slot_w - lw) / 2,
      start_y + 20,
      14,
      @types.color_hud_text,
    )
  }
  // Fence mode indicator
  let level = @levels.get_level(game.current_level)
  let tier_str = @types.tier_label(level.tier)
  let info = "Lvl \{game.current_level + 1} [T\{tier_str}]  Fence: \{fence_mode_str(game.fence_mode)} (Tab)"
  @draw.draw_text(info, start_x, 72, 14, @types.color_hud_text)
  // Right side: key hints
  @draw.draw_text(
    "Enter: Check  R: Reset  N: Needs  ESC: Pause",
    sw - 430,
    72,
    14,
    @types.color_hud_text,
  )
}

///|
fn tool_eq(a : @types.Tool, b : @types.Tool) -> Bool {
  match (a, b) {
    (TerrainBrush(t1), TerrainBrush(t2)) => t1 == t2
    (FenceTool, FenceTool) => true
    (EraserTool, EraserTool) => true
    (AnimalPlacer(s1), AnimalPlacer(s2)) => s1 == s2
    _ => false
  }
}

///|
fn fence_mode_str(mode : @types.FenceMode) -> String {
  match mode {
    Horizontal => "H"
    Vertical => "V"
  }
}
