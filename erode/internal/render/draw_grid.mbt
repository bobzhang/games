///|
fn draw_single_grid(
  grid : @types.Grid,
  ox : Int,
  oy : Int,
  label : String,
  preview : Array[Bool]?,
  target : @types.Grid?,
) -> Unit {
  let cs = @types.cell_size
  let size = grid.size
  // Draw label
  let label_w = @draw.measure_text(label, 24)
  let grid_pixel_w = size * cs
  @draw.draw_text(
    label,
    ox + (grid_pixel_w - label_w) / 2,
    oy - 32,
    24,
    @types.color_text,
  )
  // Draw cells
  for r in 0..<size {
    for c in 0..<size {
      let x = ox + c * cs
      let y = oy + r * cs
      let idx = r * size + c
      let solid = grid.cells[idx]
      if solid {
        // Base solid color
        @raylib.draw_rectangle(x, y, cs, cs, @types.color_solid)
        // Shading for depth effect: lighter top-left, darker bottom-right
        @raylib.draw_rectangle(
          x,
          y,
          cs,
          2,
          @raylib.Color::new(200, 160, 120, 80),
        )
        @raylib.draw_rectangle(
          x,
          y,
          2,
          cs,
          @raylib.Color::new(200, 160, 120, 60),
        )
        @raylib.draw_rectangle(
          x,
          y + cs - 2,
          cs,
          2,
          @raylib.Color::new(80, 60, 40, 80),
        )
        @raylib.draw_rectangle(
          x + cs - 2,
          y,
          2,
          cs,
          @raylib.Color::new(80, 60, 40, 60),
        )
      } else {
        @raylib.draw_rectangle(x, y, cs, cs, @types.color_empty)
      }
      // Preview overlay: cells that would be removed
      match preview {
        Some(p) =>
          if p[idx] {
            @raylib.draw_rectangle(x, y, cs, cs, @types.color_preview)
            // Draw X to indicate removal
            let cx = x + cs / 2
            let cy = y + cs / 2
            let half = cs / 4
            @raylib.draw_line(
              cx - half,
              cy - half,
              cx + half,
              cy + half,
              @raylib.white,
            )
            @raylib.draw_line(
              cx + half,
              cy - half,
              cx - half,
              cy + half,
              @raylib.white,
            )
          }
        None => ()
      }
      // Over/under erosion indicators when comparing to target
      match target {
        Some(tgt) => {
          let tgt_solid = tgt.cells[idx]
          if tgt_solid && !solid {
            // Over-eroded: target wants solid, we removed it
            @raylib.draw_rectangle(
              x + 2,
              y + 2,
              cs - 4,
              cs - 4,
              @types.color_over_eroded,
            )
          } else if !tgt_solid && solid {
            // Under-eroded: target wants empty, still solid
            @raylib.draw_rectangle(
              x + cs / 4,
              y + cs / 4,
              cs / 2,
              cs / 2,
              @types.color_under_eroded,
            )
          }
        }
        None => ()
      }
    }
  }
  // Draw grid lines
  for i in 0..<=size {
    let x = ox + i * cs
    let y = oy + i * cs
    @raylib.draw_line(x, oy, x, oy + size * cs, @types.color_grid_line)
    @raylib.draw_line(ox, y, ox + size * cs, y, @types.color_grid_line)
  }
}

///|
fn draw_target_grid(target : @types.Grid, ox : Int, oy : Int) -> Unit {
  let cs = @types.cell_size
  let size = target.size
  let label = "TARGET"
  let label_w = @draw.measure_text(label, 24)
  let grid_pixel_w = size * cs
  @draw.draw_text(
    label,
    ox + (grid_pixel_w - label_w) / 2,
    oy - 32,
    24,
    @types.color_target_match,
  )
  for r in 0..<size {
    for c in 0..<size {
      let x = ox + c * cs
      let y = oy + r * cs
      let idx = r * size + c
      if target.cells[idx] {
        @raylib.draw_rectangle(x, y, cs, cs, @types.color_target_match)
        // Subtle shading
        @raylib.draw_rectangle(
          x,
          y,
          cs,
          2,
          @raylib.Color::new(120, 240, 120, 60),
        )
        @raylib.draw_rectangle(
          x + cs - 2,
          y,
          2,
          cs,
          @raylib.Color::new(40, 120, 40, 60),
        )
      } else {
        @raylib.draw_rectangle(x, y, cs, cs, @types.color_empty)
      }
    }
  }
  for i in 0..<=size {
    let x = ox + i * cs
    let y = oy + i * cs
    @raylib.draw_line(x, oy, x, oy + size * cs, @types.color_grid_line)
    @raylib.draw_line(ox, y, ox + size * cs, y, @types.color_grid_line)
  }
}

///|
fn draw_playing(game : @types.Game) -> Unit {
  // Draw level name
  let levels = @levels.get_all_levels()
  let level = levels[game.current_level]
  let title = "Level \{game.current_level + 1}: \{level.name}"
  let title_w = @draw.measure_text(title, 28)
  @draw.draw_text(
    title,
    (@types.screen_width - title_w) / 2,
    10,
    28,
    @types.color_text_highlight,
  )
  // Draw tier badge
  let tier_text = @types.tier_name(game.current_tier)
  @draw.draw_text(tier_text, 20, 12, 20, @types.tier_color(game.current_tier))
  // Current grid with preview overlay
  let preview : Array[Bool]? = match game.play_state {
    Previewing(_) => Some(game.preview_cells)
    _ => None
  }
  draw_single_grid(
    game.grid,
    @types.grid_left_x,
    @types.grid_top_y,
    "YOUR BLOCK",
    preview,
    Some(game.target),
  )
  // Target grid
  draw_target_grid(game.target, @types.grid_right_x, @types.grid_top_y)
  // Draw UI elements
  draw_force_palette(game)
  draw_match_info(game)
  draw_controls_help(game)
}
