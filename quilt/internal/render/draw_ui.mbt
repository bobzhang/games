///|
fn draw_tray(game : @types.Game) -> Unit {
  let tx = @types.tray_x
  let ty = @types.tray_y
  let ps = @types.tray_patch_size
  let gap = @types.tray_gap
  let cols = @types.tray_cols
  // Tray background
  let tray_count = game.tray.length()
  let rows = (tray_count + cols - 1) / cols
  let tray_w = cols * (ps + gap) + gap
  let tray_h = rows * (ps + gap) + gap + 30
  @raylib.draw_rectangle(tx - gap, ty - 30, tray_w, tray_h, @types.color_tray_bg)
  @raylib.draw_rectangle_lines(
    tx - gap,
    ty - 30,
    tray_w,
    tray_h,
    @types.color_grid_line,
  )
  @draw.draw_text("Patch Tray", tx, ty - 26, 18, @types.color_text)
  // Draw patches
  for i in 0..<tray_count {
    let col = i % cols
    let row = i / cols
    let px = tx + col * (ps + gap)
    let py = ty + row * (ps + gap)
    let patch = game.tray[i]
    // Draw mini patch
    draw_mini_patch(patch, px, py, ps)
    // Highlight selected
    if game.selected_tray == i {
      @raylib.draw_rectangle(px - 1, py - 1, ps + 2, ps + 2, @types.color_selected)
    }
  }
  // Controls help below tray
  let help_y = ty + tray_h - 20
  draw_controls_help(tx - gap, help_y)
}

///|
fn draw_mini_patch(patch : @types.Patch, x : Int, y : Int, size : Int) -> Unit {
  let base = if patch.pinned {
    @types.color_pinned
  } else {
    @types.color_patch_base
  }
  @raylib.draw_rectangle(x, y, size, size, base)
  @raylib.draw_rectangle_lines(x, y, size, size, @types.color_grid_line)
  // Draw colored edges (thinner for mini)
  let t = 3
  let m = 2
  // North
  let nc = edge_display_color(patch, 0)
  @raylib.draw_rectangle(x + m, y, size - m * 2, t, nc)
  // East
  let ec = edge_display_color(patch, 1)
  @raylib.draw_rectangle(x + size - t, y + m, t, size - m * 2, ec)
  // South
  let sc = edge_display_color(patch, 2)
  @raylib.draw_rectangle(x + m, y + size - t, size - m * 2, t, sc)
  // West
  let wc = edge_display_color(patch, 3)
  @raylib.draw_rectangle(x, y + m, t, size - m * 2, wc)
  // Pinned indicator
  if patch.pinned {
    @draw.draw_text("P", x + size / 2 - 4, y + size / 2 - 6, 12, @types.color_text)
  }
}

///|
fn edge_display_color(patch : @types.Patch, idx : Int) -> @raylib.Color {
  if patch.wildcard_edges[idx] {
    @types.color_wildcard
  } else {
    @types.pattern_color(patch.edges[idx])
  }
}

///|
fn draw_hud(game : @types.Game) -> Unit {
  // Level title
  let title = if game.is_daily {
    "Daily Quilt"
  } else {
    "Level " + game.current_level.to_string() + " - " + @types.tier_name(game.current_tier)
  }
  @draw.draw_text(title, @types.grid_offset_x, 10, 28, @types.color_title)
  // Rotation and swap counters
  let counter_x = @types.grid_offset_x
  let counter_y = 50
  @draw.draw_text(
    "Rotations: " + game.rotations.to_string(),
    counter_x,
    counter_y,
    20,
    @types.color_text,
  )
  @draw.draw_text(
    "Swaps: " + game.swaps.to_string(),
    counter_x + 200,
    counter_y,
    20,
    @types.color_text,
  )
  // Match progress bar
  let board = game.board
  let total_pairs = @matching.count_edge_pairs(board)
  let matched_pairs = @matching.count_matched_pairs(board)
  let filled = @matching.count_filled_cells(board)
  let total_cells = board.size * board.size
  let bar_x = @types.grid_offset_x
  let bar_y = 76
  let bar_w = 300
  let bar_h = 14
  @raylib.draw_rectangle(bar_x, bar_y, bar_w, bar_h, @types.color_progress_bg)
  if total_pairs > 0 {
    let fill_w = matched_pairs * bar_w / total_pairs
    @raylib.draw_rectangle(bar_x, bar_y, fill_w, bar_h, @types.color_progress_fill)
  }
  @raylib.draw_rectangle_lines(bar_x, bar_y, bar_w, bar_h, @types.color_grid_line)
  let progress_text =
    matched_pairs.to_string() +
    "/" +
    total_pairs.to_string() +
    " edges matched  |  " +
    filled.to_string() +
    "/" +
    total_cells.to_string() +
    " placed"
  @draw.draw_text(progress_text, bar_x + bar_w + 10, bar_y - 1, 14, @types.color_text_light)
  // Play state indicator
  let state_text = match game.play_state {
    Placing => "Click tray patch, then grid cell"
    Selecting => "Click a placed patch to swap"
    Swapping => "Click another patch to swap with"
    Complete => "Puzzle Complete!"
  }
  @draw.draw_text(
    state_text,
    @types.tray_x,
    @types.grid_offset_y - 25,
    16,
    @types.color_text_light,
  )
  // Edge pattern legend
  draw_legend()
}

///|
fn draw_controls_help(x : Int, y : Int) -> Unit {
  @draw.draw_text("[R] Rotate  [Click] Place/Select  [Right-click] Remove  [Esc] Back", x, y, 13, @types.color_text_light)
}

///|
fn draw_legend() -> Unit {
  let lx = 920
  let ly = 100
  @draw.draw_text("Patterns:", lx, ly, 16, @types.color_text)
  let patterns = @types.all_patterns()
  for i in 0..<patterns.length() {
    let px = lx
    let py = ly + 24 + i * 22
    let c = @types.pattern_color(patterns[i])
    @raylib.draw_rectangle(px, py + 2, 14, 14, c)
    @raylib.draw_rectangle_lines(px, py + 2, 14, 14, @types.color_grid_line)
    @draw.draw_text(@types.pattern_name(patterns[i]), px + 20, py, 16, @types.color_text)
  }
  // Wildcard
  let wy = ly + 24 + patterns.length() * 22
  @raylib.draw_rectangle(lx, wy + 2, 14, 14, @types.color_wildcard)
  @raylib.draw_rectangle_lines(lx, wy + 2, 14, 14, @types.color_grid_line)
  @draw.draw_text("Wildcard", lx + 20, wy, 16, @types.color_text)
  // Match indicators
  let my = wy + 28
  @raylib.draw_circle(lx + 6, my + 8, 4.0, @types.color_matched)
  @draw.draw_text("Matched", lx + 20, my, 16, @types.color_text)
  @raylib.draw_circle(lx + 6, my + 28, 4.0, @types.color_mismatched)
  @draw.draw_text("Mismatched", lx + 20, my + 20, 16, @types.color_text)
}

///|
fn draw_stars(x : Int, y : Int, count : Int, size : Int) -> Unit {
  for i in 0..<3 {
    let sx = x + i * (size + 4)
    let c = if i < count {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    // Simple star as filled circle + text
    @raylib.draw_circle(sx + size / 2, y + size / 2, Float::from_int(size / 2), c)
    @draw.draw_text(
      "*",
      sx + size / 2 - 4,
      y + size / 2 - 8,
      16,
      @raylib.white,
    )
  }
}
