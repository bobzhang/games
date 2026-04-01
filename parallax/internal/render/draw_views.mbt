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
  // Hover highlight with strong pulsing effect
  if game.hover.active && game.play_state == Editing {
    let (hover_col, hover_row) = match view {
      Top => (game.hover.vx, game.hover.vz)
      Front => (game.hover.vx, size - 1 - game.hover.vy)
      Side => (game.hover.vz, size - 1 - game.hover.vy)
    }
    if hover_col >= 0 && hover_col < size && hover_row >= 0 && hover_row < size {
      let hx = panel_x + hover_col * cs
      let hy = panel_y + hover_row * cs
      // Pulsing highlight for the hovered cell
      let t : Float = Float::from_int(game.frame_count) * 0.12
      let pulse = Float::from_double(@math.sin(t.to_double())) * 40.0 + 120.0
      let alpha = pulse.to_int()
      let is_in_this_view = game.hover.view == view
      if is_in_this_view {
        // Strong yellow highlight for the active view
        let highlight = @raylib.Color::new(255, 255, 100, alpha)
        @raylib.draw_rectangle(hx + 1, hy + 1, cs - 2, cs - 2, highlight)
        // Bright border
        let border = @raylib.Color::new(255, 255, 180, 200)
        @raylib.draw_rectangle_lines(hx, hy, cs, cs, border)
        @raylib.draw_rectangle_lines(hx - 1, hy - 1, cs + 2, cs + 2, border)
      } else {
        // Softer highlight for cross-view preview (shows the projection)
        let cross_highlight = @raylib.Color::new(200, 200, 255, alpha / 2)
        @raylib.draw_rectangle(
          hx + 1, hy + 1, cs - 2, cs - 2, cross_highlight,
        )
        let cross_border = @raylib.Color::new(150, 150, 220, 140)
        @raylib.draw_rectangle_lines(hx, hy, cs, cs, cross_border)
      }
      // Draw crosshair lines through the hovered cell for easier alignment
      if is_in_this_view {
        let line_color = @raylib.Color::new(255, 255, 200, 40)
        // Horizontal guide
        @raylib.draw_rectangle(
          panel_x,
          hy + cs / 2,
          size * cs,
          1,
          line_color,
        )
        // Vertical guide
        @raylib.draw_rectangle(
          hx + cs / 2,
          panel_y,
          1,
          size * cs,
          line_color,
        )
      }
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
