///|
pub fn draw_jar_background() -> Unit {
  let x = @types.grid_offset_x - 10
  let y = @types.grid_offset_y - 10
  let w = @types.grid_size * @types.cell_size + 20
  let h = @types.grid_size * @types.cell_size + 20
  @raylib.draw_rectangle_rounded(rect(x, y, w, h), 0.05, 8, @types.color_jar)
  @raylib.draw_rectangle_rounded_lines_ex(
    rect(x, y, w, h), 0.05, 8, 2.0, @types.color_jar_border,
  )
  let lid_y = y - 16
  @raylib.draw_rectangle_rounded(
    rect(x + 10, lid_y, w - 20, 18), 0.3, 4, @types.color_jar_border,
  )
}

///|
pub fn draw_grid_cells(game : @types.Game) -> Unit {
  for r in 0..<@types.grid_size {
    for c in 0..<@types.grid_size {
      let cx = @types.grid_offset_x + c * @types.cell_size
      let cy = @types.grid_offset_y + r * @types.cell_size
      let is_locked = match game.current_level {
        Some(level) => @types.is_cell_locked(level, r, c)
        _ => false
      }
      if is_locked {
        @raylib.draw_rectangle(
          cx, cy, @types.cell_size, @types.cell_size, @types.color_soil_dark,
        )
        @draw.draw_text(
          "X",
          cx + @types.cell_size / 2 - 5,
          cy + @types.cell_size / 2 - 8,
          16,
          @types.color_locked,
        )
      } else {
        @raylib.draw_rectangle(
          cx, cy, @types.cell_size, @types.cell_size, @types.color_empty_cell,
        )
        match game.grid[r][c] {
          Empty => draw_soil_texture(cx, cy)
          Organism(kind) => draw_organism_cell(kind, cx, cy, game.frame_count)
        }
      }
      @raylib.draw_rectangle_lines(
        cx, cy, @types.cell_size, @types.cell_size, @types.color_soil_dark,
      )
    }
  }
}

///|
fn draw_soil_texture(cx : Int, cy : Int) -> Unit {
  let s = @types.cell_size
  let dark = @types.color_soil
  let seed1 = (cx * 7 + cy * 13) % 5
  let seed2 = (cx * 3 + cy * 11) % 4
  @raylib.draw_rectangle(cx + seed1 * 8, cy + seed2 * 10, 3, 2, dark)
  @raylib.draw_rectangle(
    cx + ((seed1 + 2) * 6) % s,
    cy + ((seed2 + 3) * 7) % s,
    2,
    3,
    dark,
  )
}

///|
fn draw_organism_cell(
  kind : @types.OrganismKind,
  cx : Int,
  cy : Int,
  frame : Int
) -> Unit {
  let color = @types.organism_color(kind)
  let half = @types.cell_size / 2
  let qtr = @types.cell_size / 4
  match kind {
    Moss => {
      @raylib.draw_rectangle(
        cx + 4, cy + 4, @types.cell_size - 8, @types.cell_size - 8, color,
      )
      let bob = (frame / 30) % 2
      @raylib.draw_rectangle(cx + 10, cy + 8 - bob, 8, 12, @types.color_fern)
      @raylib.draw_rectangle(cx + 28, cy + 12 - bob, 6, 10, @types.color_fern)
      @raylib.draw_rectangle(cx + 44, cy + 6 - bob, 7, 14, @types.color_fern)
    }
    Fern => {
      @raylib.draw_rectangle(
        cx + 4, cy + 4, @types.cell_size - 8, @types.cell_size - 8, color,
      )
      let bob = (frame / 25) % 3
      @raylib.draw_triangle(
        vec2(cx + half, cy + 6 - bob),
        vec2(cx + 10, cy + @types.cell_size - 8),
        vec2(cx + @types.cell_size - 10, cy + @types.cell_size - 8),
        @raylib.Color::new(20, 100, 40, 255),
      )
    }
    Beetle => {
      @raylib.draw_circle(cx + half, cy + half, fi(qtr), color)
      let bob = (frame / 10) % 2
      @raylib.draw_rectangle(
        cx + half - 10, cy + half + qtr - 2, 4, 6 + bob, @types.color_soil,
      )
      @raylib.draw_rectangle(
        cx + half + 6, cy + half + qtr - 2, 4, 6 + bob, @types.color_soil,
      )
      @raylib.draw_circle(
        cx + half - 5,
        cy + half - 4,
        3.0,
        @raylib.Color::new(40, 40, 40, 255),
      )
      @raylib.draw_circle(
        cx + half + 5,
        cy + half - 4,
        3.0,
        @raylib.Color::new(40, 40, 40, 255),
      )
    }
    Snail => {
      @raylib.draw_circle(cx + half, cy + half + 4, fi(qtr + 2), color)
      @raylib.draw_circle(
        cx + half,
        cy + half + 4,
        fi(qtr - 4),
        @raylib.Color::new(140, 120, 80, 255),
      )
      let bob = (frame / 20) % 3
      @raylib.draw_line(
        cx + half - 6,
        cy + half - 6,
        cx + half - 10,
        cy + half - 16 - bob,
        color,
      )
      @raylib.draw_line(
        cx + half + 6,
        cy + half - 6,
        cx + half + 10,
        cy + half - 16 - bob,
        color,
      )
      @raylib.draw_circle(cx + half - 10, cy + half - 17 - bob, 2.0, color)
      @raylib.draw_circle(cx + half + 10, cy + half - 17 - bob, 2.0, color)
    }
    Fungus => {
      @raylib.draw_rectangle(
        cx + half - 3,
        cy + half,
        6,
        20,
        @raylib.Color::new(180, 160, 130, 255),
      )
      @raylib.draw_circle(cx + half, cy + half - 2, fi(qtr + 4), color)
      let spots = @raylib.Color::new(220, 200, 170, 255)
      @raylib.draw_circle(cx + half - 6, cy + half - 6, 3.0, spots)
      @raylib.draw_circle(cx + half + 4, cy + half - 8, 2.0, spots)
      @raylib.draw_circle(cx + half + 7, cy + half - 2, 2.0, spots)
    }
    Worm => {
      let bob = (frame / 15) % 4
      let segments = 5
      for s in 0..<segments {
        let sx = cx + 12 + s * 8 + (if s % 2 == 0 { bob } else { 0 - bob })
        let sy = cy + half - 3 + (if s % 2 == 0 { 2 } else { -2 })
        @raylib.draw_circle(sx, sy, 5.0, color)
      }
      @raylib.draw_circle(
        cx + 10,
        cy + half - 5,
        2.0,
        @raylib.Color::new(40, 40, 40, 255),
      )
    }
  }
}

///|
pub fn draw_hover_highlight(game : @types.Game) -> Unit {
  if game.hover_row >= 0 && game.hover_col >= 0 {
    let cx = @types.grid_offset_x + game.hover_col * @types.cell_size
    let cy = @types.grid_offset_y + game.hover_row * @types.cell_size
    if game.selected_organism is Some(_) {
      @raylib.draw_rectangle(
        cx, cy, @types.cell_size, @types.cell_size, @types.color_hover,
      )
    }
    @raylib.draw_rectangle_lines(
      cx + 1,
      cy + 1,
      @types.cell_size - 2,
      @types.cell_size - 2,
      @types.color_selected,
    )
  }
}
