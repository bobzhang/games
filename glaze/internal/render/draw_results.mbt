///|
fn draw_results(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  // Header
  let header = "FIRING RESULTS"
  let hw = @draw.measure_text(header, 40)
  @draw.draw_text(header, (w - hw) / 2, 30, 40, @types.color_highlight)
  // Show fired grid vs target side-by-side
  let cs = 50
  let gap = 3
  let grid_w = @types.grid_cols * (cs + gap)
  let total_w = grid_w * 2 + 80
  let start_x = (w - total_w) / 2
  let grid_y = 100
  // Fired result label
  let fired_label = "YOUR RESULT"
  let fl_w = @draw.measure_text(fired_label, 18)
  @draw.draw_text(
    fired_label,
    start_x + (grid_w - fl_w) / 2,
    grid_y - 24,
    18,
    @types.color_text,
  )
  // Target label
  let target_label = "TARGET"
  let tl_w = @draw.measure_text(target_label, 18)
  let target_x = start_x + grid_w + 80
  @draw.draw_text(
    target_label,
    target_x + (grid_w - tl_w) / 2,
    grid_y - 24,
    18,
    @types.color_text,
  )
  // Draw fired grid
  for row in 0..<@types.grid_rows {
    for col in 0..<@types.grid_cols {
      let cx = start_x + col * (cs + gap)
      let cy = grid_y + row * (cs + gap)
      let cell = @types.get_cell(game.grid, row, col)
      let color = @types.fired_to_raylib(cell.fired)
      @raylib.draw_rectangle(cx, cy, cs, cs, color)
      // Crack marks
      if cell.fired is FCracked {
        @raylib.draw_line(
          cx + 5,
          cy + 5,
          cx + cs - 5,
          cy + cs - 5,
          @types.color_crack_mark,
        )
        @raylib.draw_line(
          cx + cs - 5,
          cy + 5,
          cx + 5,
          cy + cs - 5,
          @types.color_crack_mark,
        )
      }
      // Match indicator
      let idx = @types.grid_index(row, col)
      if idx < game.target_grid.length() {
        if cell.fired == game.target_grid[idx] {
          // Green check mark corner
          @raylib.draw_rectangle(cx + cs - 10, cy, 10, 10, @types.color_success)
        } else {
          // Red X corner
          @raylib.draw_rectangle(cx + cs - 10, cy, 10, 10, @types.color_fail)
        }
      }
    }
  }
  // Draw target grid
  for row in 0..<@types.grid_rows {
    for col in 0..<@types.grid_cols {
      let cx = target_x + col * (cs + gap)
      let cy = grid_y + row * (cs + gap)
      let idx = @types.grid_index(row, col)
      if idx < game.target_grid.length() {
        let color = @types.fired_to_raylib(game.target_grid[idx])
        @raylib.draw_rectangle(cx, cy, cs, cs, color)
      }
    }
  }
  // Score panel
  guard game.score is Some(score) else { return }
  let panel_y = grid_y + @types.grid_rows * (cs + gap) + 30
  // Stars
  draw_stars(w / 2 - 60, panel_y, score.stars, 3, 30)
  // Score details
  let match_str = "Matched: \{score.matched_cells} / \{score.total_cells}"
  let mw = @draw.measure_text(match_str, 24)
  let match_color = if score.matched_cells == score.total_cells {
    @types.color_success
  } else {
    @types.color_text
  }
  @draw.draw_text(match_str, (w - mw) / 2, panel_y + 50, 24, match_color)
  if score.cracked_cells > 0 {
    let crack_str = "Cracked: \{score.cracked_cells}"
    let crw = @draw.measure_text(crack_str, 20)
    @draw.draw_text(
      crack_str,
      (w - crw) / 2,
      panel_y + 80,
      20,
      @types.color_fail,
    )
  }
  let moves_str = "Moves used: \{score.moves_used}"
  let mvw = @draw.measure_text(moves_str, 20)
  @draw.draw_text(
    moves_str,
    (w - mvw) / 2,
    panel_y + 106,
    20,
    @types.color_text_dim,
  )
  // Rating text
  let rating = match score.stars {
    3 => "MASTERPIECE!"
    2 => "Well Done!"
    1 => "Good Effort"
    _ => "Try Again"
  }
  let rating_color = match score.stars {
    3 => @types.color_star_gold
    2 => @types.color_success
    1 => @types.color_text
    _ => @types.color_fail
  }
  let rw = @draw.measure_text(rating, 32)
  @draw.draw_text(rating, (w - rw) / 2, panel_y + 140, 32, rating_color)
  // Navigation
  let nav_y = h - 50
  let nav = "R: Retry  N: Next Level  ENTER: Level Select  ESC: Back"
  let nw = @draw.measure_text(nav, 18)
  @draw.draw_text(nav, (w - nw) / 2, nav_y, 18, @types.color_text_dim)
}
