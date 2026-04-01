///|
pub fn draw_grid(game : @types.Game) -> Unit {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  match game.current_level {
    None => ()
    Some(level) => {
      for r in 0..< @types.grid_rows {
        for c in 0..< @types.grid_cols {
          let x = ox + c * cs
          let y = oy + r * cs
          let depth = if c < level.depth_profile.length() {
            level.depth_profile[c]
          } else {
            0
          }
          let is_sub = @types.is_submerged(game.tide_level, depth, r)
          match game.grid[r][c] {
            Rock => {
              @raylib.draw_rectangle(x, y, cs, cs, @types.color_rock)
              @raylib.draw_rectangle(
                x + 2,
                y + 2,
                cs - 4,
                cs - 4,
                @types.color_rock_dark,
              )
            }
            Empty => {
              let bg = if is_sub {
                @types.color_water_deep
              } else {
                @types.color_empty_cell
              }
              @raylib.draw_rectangle(x, y, cs, cs, bg)
            }
            Organism(kind) => {
              let bg = if is_sub {
                @types.color_water_mid
              } else {
                @types.color_sand
              }
              @raylib.draw_rectangle(x, y, cs, cs, bg)
              draw_organism_icon(kind, x, y, cs)
            }
          }
          @raylib.draw_rectangle_lines(x, y, cs, cs, @types.color_hud_dim)
        }
      }
    }
  }
}

///|
pub fn draw_water_overlay(game : @types.Game) -> Unit {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  match game.current_level {
    None => ()
    Some(level) => {
      for c in 0..< @types.grid_cols {
        let depth = if c < level.depth_profile.length() {
          level.depth_profile[c]
        } else {
          0
        }
        let water_row = @types.grid_rows - game.tide_level - depth
        if water_row < @types.grid_rows {
          let start_row = if water_row < 0 { 0 } else { water_row }
          let x = ox + c * cs
          let y = oy + start_row * cs
          let h = (@types.grid_rows - start_row) * cs
          @raylib.draw_rectangle(x, y, cs, h, @types.color_submerged)
        }
      }
    }
  }
}

///|
pub fn draw_hover(game : @types.Game) -> Unit {
  if game.hover_row >= 0 && game.hover_col >= 0 {
    let x = @types.grid_offset_x + game.hover_col * @types.cell_size
    let y = @types.grid_offset_y + game.hover_row * @types.cell_size
    let color = match game.selected_organism {
      Some(_) => @types.color_selected
      None => @types.color_hover
    }
    @raylib.draw_rectangle(
      x,
      y,
      @types.cell_size,
      @types.cell_size,
      color,
    )
  }
}

///|
fn draw_organism_icon(
  kind : @types.OrganismKind,
  x : Int,
  y : Int,
  size : Int
) -> Unit {
  let color = @types.organism_color(kind)
  let profile = @types.get_profile(kind)
  let cx = x + size / 2
  let cy = y + size / 2
  let half = size / 3
  match kind {
    Barnacle => {
      @raylib.draw_rectangle(
        cx - half / 2,
        cy - half,
        half,
        half * 2,
        color,
      )
      @raylib.draw_rectangle(cx - half, cy, half * 2, half / 2, color)
    }
    Anemone => {
      @raylib.draw_circle(cx, cy + half / 2, Float::from_int(half), color)
      for i in 0..<5 {
        let tx = cx - half + i * (half / 2)
        @raylib.draw_line(tx, cy + half / 2, tx + 2, cy - half / 2, color)
      }
    }
    Crab => {
      @raylib.draw_rectangle(
        cx - half,
        cy - half / 3,
        half * 2,
        half,
        color,
      )
      @raylib.draw_line(cx - half, cy, cx - half - 6, cy - 8, color)
      @raylib.draw_line(cx + half, cy, cx + half + 6, cy - 8, color)
    }
    Starfish => {
      @raylib.draw_circle(
        cx,
        cy,
        Float::from_int(half / 2),
        color,
      )
      @raylib.draw_line(cx, cy - half, cx, cy + half, color)
      @raylib.draw_line(cx - half, cy, cx + half, cy, color)
      @raylib.draw_line(
        cx - half + 4,
        cy - half + 4,
        cx + half - 4,
        cy + half - 4,
        color,
      )
    }
    Algae => {
      for i in 0..<3 {
        let lx = cx - half / 2 + i * (half / 2)
        @raylib.draw_line(lx, cy + half, lx + 3, cy - half, color)
      }
      @raylib.draw_circle(cx, cy, Float::from_int(half / 3), color)
    }
    Urchin => {
      @raylib.draw_circle(
        cx,
        cy,
        Float::from_int(half / 2),
        color,
      )
      @raylib.draw_line(cx, cy - half, cx, cy + half, color)
      @raylib.draw_line(cx - half, cy, cx + half, cy, color)
    }
  }
  @draw.draw_text(
    profile.symbol,
    x + 2,
    y + size - 16,
    12,
    @types.color_hud_text,
  )
}

///|
pub fn draw_tide_indicator(game : @types.Game) -> Unit {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  let total_w = @types.grid_cols * cs
  let indicator_x = ox - 30
  let phase_text = match game.tide_phase {
    Low => "LOW"
    Mid => "MID"
    High => "HIGH"
  }
  @draw.draw_text(phase_text, indicator_x, oy - 24, 16, @types.color_tide_indicator)
  @draw.draw_text(
    "Tide: \{game.tide_level}",
    ox + total_w + 10,
    oy - 24,
    16,
    @types.color_tide_indicator,
  )
  let bar_y = oy + @types.grid_rows * cs + 8
  let bar_w = total_w
  let bar_h = 12
  @raylib.draw_rectangle(ox, bar_y, bar_w, bar_h, @types.color_bar_bg)
  let fill_w = game.tide_level * bar_w / @types.max_tide
  @raylib.draw_rectangle(ox, bar_y, fill_w, bar_h, @types.color_tide_indicator)
  @raylib.draw_rectangle_lines(ox, bar_y, bar_w, bar_h, @types.color_hud_dim)
}

///|
pub fn draw_depth_labels(game : @types.Game) -> Unit {
  match game.current_level {
    None => ()
    Some(level) => {
      let ox = @types.grid_offset_x
      let oy = @types.grid_offset_y + @types.grid_rows * @types.cell_size + 24
      for c in 0..< @types.grid_cols {
        let depth = if c < level.depth_profile.length() {
          level.depth_profile[c]
        } else {
          0
        }
        let x = ox + c * @types.cell_size + @types.cell_size / 2 - 4
        @draw.draw_text("d\{depth}", x, oy, 12, @types.color_hud_dim)
      }
    }
  }
}
