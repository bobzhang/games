// Draw a single 2D view panel
///|
fn draw_view_panel(
  game : @types.Game,
  view : @types.ViewKind,
  panel_x : Int,
  panel_y : Int,
  level : @types.Level
) -> Unit {
  let size = level.size
  let cs = @types.cell_size_for_grid(size)
  let grid_w = size * cs
  let grid_h = size * cs
  // Panel background
  @raylib.draw_rectangle(
    panel_x - 5,
    panel_y - 5,
    grid_w + 10,
    grid_h + 35,
    @types.color_panel_bg,
  )
  // Label
  let label = match view {
    Top => "TOP (X-Z)"
    Front => "FRONT (X-Y)"
    Side => "SIDE (Z-Y)"
  }
  @draw.draw_text(label, panel_x, panel_y - 22, 16, @types.color_text)
  // Get current and target silhouettes
  let current = @voxel.compute_silhouette(game.grid, view)
  let target = match view {
    Top => level.targets.top
    Front => level.targets.front
    Side => level.targets.side
  }
  // Draw grid cells
  for row in 0..<size {
    for col in 0..<size {
      let cx = panel_x + col * cs
      let cy = panel_y + row * cs
      let idx = col + row * size
      let cur = current.cells[idx]
      let tgt = target.cells[idx]
      // Background cell
      @raylib.draw_rectangle(cx + 1, cy + 1, cs - 2, cs - 2, @types.color_empty)
      // Target overlay (faded)
      if tgt {
        @raylib.draw_rectangle(cx + 1, cy + 1, cs - 2, cs - 2, @types.color_target)
      }
      // Current silhouette
      if cur {
        let cell_color = if tgt {
          @types.color_matched
        } else {
          @types.color_unmatched
        }
        @raylib.draw_rectangle(cx + 2, cy + 2, cs - 4, cs - 4, cell_color)
      } else if tgt {
        // Target but not filled: show as outline
        @raylib.draw_rectangle_lines(cx + 2, cy + 2, cs - 4, cs - 4, @types.color_target)
      }
      // Grid lines
      @raylib.draw_rectangle_lines(cx, cy, cs, cs, @types.color_grid_line)
    }
  }
  // Hover highlight
  if game.hover.active && game.play_state == Editing {
    let (hover_col, hover_row) = match view {
      Top => (game.hover.vx, game.hover.vz)
      Front => (game.hover.vx, size - 1 - game.hover.vy)
      Side => (game.hover.vz, size - 1 - game.hover.vy)
    }
    if hover_col >= 0 && hover_col < size && hover_row >= 0 && hover_row < size {
      let hx = panel_x + hover_col * cs
      let hy = panel_y + hover_row * cs
      @raylib.draw_rectangle(hx + 1, hy + 1, cs - 2, cs - 2, @types.color_hover)
    }
  }
  // Match indicator
  let sil_match = @voxel.silhouettes_match(current, target)
  let status_color = if sil_match {
    @types.color_matched
  } else {
    @types.color_unmatched
  }
  let status_text = if sil_match { "MATCH" } else { "---" }
  @draw.draw_text(
    status_text,
    panel_x + grid_w / 2 - 20,
    panel_y + grid_h + 5,
    14,
    status_color,
  )
}

///|
pub fn draw_all_views(game : @types.Game, level : @types.Level) -> Unit {
  draw_view_panel(
    game,
    Top,
    @types.view_top_x,
    @types.view_top_y,
    level,
  )
  draw_view_panel(
    game,
    Front,
    @types.view_front_x,
    @types.view_front_y,
    level,
  )
  draw_view_panel(
    game,
    Side,
    @types.view_side_x,
    @types.view_side_y,
    level,
  )
}
