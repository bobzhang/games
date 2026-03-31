///|
pub fn draw_playing(game : @types.Game) -> Unit {
  let level = game.current_level
  // Title bar
  let tier_col = @types.tier_color(level.tier)
  @draw.draw_text(
    @types.tier_name(level.tier) + " - " + level.name,
    20,
    10,
    28,
    tier_col,
  )
  // Draw grid
  draw_grid(game)
  // Draw UI panel
  draw_play_ui(game)
  // Draw note labels on the left
  draw_note_labels(game)
  // Draw column numbers on top
  draw_column_numbers(game)
  // Draw interval indicators
  draw_interval_indicators(game)
}

///|
fn draw_grid(game : @types.Game) -> Unit {
  let grid = game.grid
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cw = @types.cell_width
  let ch = @types.cell_height
  // Grid background
  @raylib.draw_rectangle(
    ox,
    oy,
    cw * grid.cols,
    ch * grid.rows,
    @types.color_grid_bg,
  )
  // Grid lines
  for c in 0..=grid.cols {
    let x = ox + c * cw
    @raylib.draw_line(x, oy, x, oy + ch * grid.rows, @types.color_grid_line)
  }
  for r in 0..=grid.rows {
    let y = oy + r * ch
    @raylib.draw_line(ox, y, ox + cw * grid.cols, y, @types.color_grid_line)
  }
  // Playback column highlight
  if game.play_state == Playing {
    let px = ox + game.playback_col * cw
    @raylib.draw_rectangle(px, oy, cw, ch * grid.rows, @types.color_playback)
  }
  // Draw cells
  for c in 0..<grid.cols {
    for r in 0..<grid.rows {
      let cell = grid.cells[c][r]
      let x = ox + c * cw
      let y = oy + r * ch
      // Target indicator (border)
      if cell.is_target {
        @raylib.draw_rectangle_lines(x + 2, y + 2, cw - 4, ch - 4, @types.color_target)
        @raylib.draw_rectangle_lines(x + 3, y + 3, cw - 6, ch - 6, @types.color_target)
      }
      // Filled note
      if cell.has_note {
        let note = @types.note_from_row(r)
        let col = @types.note_color(note)
        let inner_pad = 6
        if cell.is_locked {
          // Locked notes are slightly dimmer with a lock indicator
          let dim_col = @raylib.Color::new(
            col.r.to_int() * 7 / 10,
            col.g.to_int() * 7 / 10,
            col.b.to_int() * 7 / 10,
            200,
          )
          @raylib.draw_rectangle(
            x + inner_pad,
            y + inner_pad,
            cw - inner_pad * 2,
            ch - inner_pad * 2,
            dim_col,
          )
          // Lock icon (small square in corner)
          @raylib.draw_rectangle(
            x + cw - 16,
            y + 4,
            10,
            10,
            @types.color_locked,
          )
        } else {
          @raylib.draw_rectangle(
            x + inner_pad,
            y + inner_pad,
            cw - inner_pad * 2,
            ch - inner_pad * 2,
            col,
          )
        }
        // Note name in cell
        let name = @types.note_name(note)
        let tw = @draw.measure_text(name, 18)
        @draw.draw_text(
          name,
          x + (cw - tw) / 2,
          y + (ch - 18) / 2,
          18,
          @raylib.Color::new(255, 255, 255, 220),
        )
      }
    }
  }
  // Hover highlight
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  if mx >= ox && mx < ox + cw * grid.cols && my >= oy && my < oy + ch * grid.rows {
    let hc = (mx - ox) / cw
    let hr = (my - oy) / ch
    if hc >= 0 && hc < grid.cols && hr >= 0 && hr < grid.rows {
      let cell = grid.cells[hc][hr]
      if !(cell.is_locked) {
        let hx = ox + hc * cw
        let hy = oy + hr * ch
        @raylib.draw_rectangle_lines(
          hx + 1,
          hy + 1,
          cw - 2,
          ch - 2,
          @raylib.Color::new(255, 255, 255, 100),
        )
      }
    }
  }
}

///|
fn draw_note_labels(_game : @types.Game) -> Unit {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let ch = @types.cell_height
  for r in 0..<@types.grid_rows {
    let note = @types.note_from_row(r)
    let name = @types.note_name(note)
    let col = @types.note_color(note)
    let y = oy + r * ch + (ch - 22) / 2
    @draw.draw_text(name, ox - 40, y, 22, col)
  }
}

///|
fn draw_column_numbers(_game : @types.Game) -> Unit {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cw = @types.cell_width
  for c in 0..<@types.grid_cols {
    let label = (c + 1).to_string()
    let tw = @draw.measure_text(label, 16)
    let x = ox + c * cw + (cw - tw) / 2
    @draw.draw_text(label, x, oy - 22, 16, @types.color_text_dim)
  }
}

///|
fn draw_interval_indicators(game : @types.Game) -> Unit {
  let grid = game.grid
  let ox = @types.grid_offset_x + @types.cell_width * grid.cols + 15
  let oy = @types.grid_offset_y
  let ch = @types.cell_height
  // Show harmony info for each column that has 2+ notes
  @draw.draw_text("Column Harmony", ox, oy - 25, 16, @types.color_text_dim)
  for c in 0..<grid.cols {
    let pairs = @harmony.column_interval_pairs(grid, c)
    if pairs.length() > 0 {
      let col_score = @harmony.compute_column_harmony(grid, c)
      let y = oy + c * ch
      let score_str = if col_score >= 0 {
        "+" + col_score.to_string()
      } else {
        col_score.to_string()
      }
      let col = if col_score > 0 {
        @types.color_consonant
      } else if col_score < 0 {
        @types.color_dissonant
      } else {
        @types.color_text_dim
      }
      @draw.draw_text(
        "Col " + (c + 1).to_string() + ": " + score_str,
        ox,
        y,
        16,
        col,
      )
    }
  }
}
