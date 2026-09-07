///|
fn sinf(a : Float) -> Float {
  Float::from_double(@math.sin(a.to_double()))
}

///|
fn draw_sky(game : @types.Game) -> Unit {
  let time = Float::from_int(game.frame_count) * 0.02
  let gx = @types.grid_offset_x
  let gy = @types.grid_offset_y
  let gw = @types.grid_cols * @types.cell_size
  let gh = @types.grid_rows * @types.cell_size
  if !draw_forest_board_art(game) {
    @raylib.draw_rectangle(gx - 10, gy - 10, gw + 20, gh + 20, @types.color_sky)
  }
  // Sun rays from top
  for i in 0..<8 {
    let fi = Float::from_int(i)
    let rx = gx + gw * (i * 2 + 1) / 16
    let ray_alpha = (sinf(time + fi * 0.5) * 20.0 + 40.0).to_int()
    let color = @raylib.Color::new(255, 220, 80, ray_alpha)
    @raylib.draw_line_ex(
      @raylib.Vector2::new(Float::from_int(rx), Float::from_int(gy)),
      @raylib.Vector2::new(
        Float::from_int(rx) + sinf(time * 0.3 + fi) * 15.0,
        Float::from_int(gy + gh),
      ),
      2.0,
      color,
    )
  }
}

///|
fn draw_grid_lines(_game : @types.Game) -> Unit {
  let gx = @types.grid_offset_x
  let gy = @types.grid_offset_y
  let cs = @types.cell_size
  // Vertical lines
  for c in 0..<=@types.grid_cols {
    let x = gx + c * cs
    @raylib.draw_line(
      x,
      gy,
      x,
      gy + @types.grid_rows * cs,
      @types.color_grid_line,
    )
  }
  // Horizontal lines
  for r in 0..<=@types.grid_rows {
    let y = gy + r * cs
    @raylib.draw_line(
      gx,
      y,
      gx + @types.grid_cols * cs,
      y,
      @types.color_grid_line,
    )
  }
}

///|
fn draw_cells(game : @types.Game) -> Unit {
  let gx = @types.grid_offset_x
  let gy = @types.grid_offset_y
  let cs = @types.cell_size
  let time = Float::from_int(game.frame_count) * 0.03
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      let x = gx + c * cs
      let y = gy + r * cs
      match game.grid.cells[r][c] {
        Trunk =>
          if !draw_trunk_art(x, y) {
            @raylib.draw_rectangle(
              x + 12,
              y + 1,
              cs - 24,
              cs - 2,
              @types.color_trunk,
            )
            @raylib.draw_line(
              x + 16,
              y + cs / 3,
              x + cs - 16,
              y + cs / 3,
              @raylib.Color::new(90, 60, 35, 180),
            )
          }
        Branch => {
          let leaf_pulse = sinf(time + Float::from_int(c * 3 + r * 7)) * 2.0
          if !draw_branch_art(x, y, leaf_pulse) {
            @raylib.draw_rectangle(
              x + 2,
              y + 14,
              cs - 4,
              cs - 28,
              @types.color_branch,
            )
            let lx = Float::from_int(x + cs / 2)
            let ly = Float::from_int(y + 8) + leaf_pulse
            @raylib.draw_circle(
              lx.to_int(),
              ly.to_int(),
              10.0,
              @types.color_leaf,
            )
          }
        }
        Leaf => {
          let pulse = sinf(time + Float::from_int(c * 5 + r * 3)) * 2.0
          if !draw_leaf_art(x, y, pulse) {
            let lx = Float::from_int(x + cs / 2)
            let ly = Float::from_int(y + cs / 2) + pulse
            @raylib.draw_circle(
              lx.to_int(),
              ly.to_int(),
              Float::from_int(cs / 2 - 4),
              @types.color_leaf,
            )
            @raylib.draw_circle(
              (lx - 6.0).to_int(),
              (ly + 3.0).to_int(),
              Float::from_int(cs / 3),
              @types.color_leaf_dark,
            )
          }
        }
        Shadow =>
          if !draw_shadow_art(x, y) {
            @raylib.draw_rectangle(x, y, cs, cs, @types.color_shadow)
          }
        Empty => ()
      }
    }
  }
}

///|
fn draw_ground(game : @types.Game) -> Unit {
  let gx = @types.grid_offset_x
  let gy = @types.grid_offset_y + @types.grid_rows * @types.cell_size
  let cs = @types.cell_size
  if !draw_ground_art(gx, gy, @types.grid_cols * cs, 40) {
    @raylib.draw_rectangle(
      gx,
      gy,
      @types.grid_cols * cs,
      40,
      @types.color_ground,
    )
  }
  // Water bars per column
  for i in 0..<game.ground.length() {
    let x = gx + i * cs
    let bar_w = cs - 8
    let bar_h = 12
    let by = gy + 14
    // Background
    @raylib.draw_rectangle(x + 4, by, bar_w, bar_h, @types.color_water_empty)
    // Water fill
    if game.ground[i].water > 0 {
      let fill_w = bar_w * game.ground[i].water / @types.max_water
      @raylib.draw_rectangle(x + 4, by, fill_w, bar_h, @types.color_water)
    }
  }
}

///|
fn draw_target_markers(game : @types.Game) -> Unit {
  let gx = @types.grid_offset_x
  let gy = @types.grid_offset_y
  let cs = @types.cell_size
  for i in 0..<game.targets.length() {
    let target = game.targets[i]
    if target.tree_index >= 0 && target.tree_index < game.trees.length() {
      let tree = game.trees[target.tree_index]
      let target_row = @types.grid_rows - 1 - target.required_height
      let x = gx + tree.col * cs
      let y = gy + target_row * cs
      let met = @growth.target_met(game, i)
      let color = if met {
        @types.color_target_met
      } else {
        @types.color_target_marker
      }
      // Draw dashed line at target height
      let mut dx = x - 10
      while dx < x + cs + 10 {
        @raylib.draw_line(dx, y + cs / 2, dx + 4, y + cs / 2, color)
        dx += 8
      }
      if !draw_target_marker_art(x - 12, y + cs / 2, met) {
        @raylib.draw_triangle(
          @raylib.Vector2::new(
            Float::from_int(x - 12),
            Float::from_int(y + cs / 2),
          ),
          @raylib.Vector2::new(
            Float::from_int(x - 4),
            Float::from_int(y + cs / 2 - 5),
          ),
          @raylib.Vector2::new(
            Float::from_int(x - 4),
            Float::from_int(y + cs / 2 + 5),
          ),
          color,
        )
      }
      // Height label
      let label = target.required_height.to_string()
      @draw.draw_text(label, x - 30, y + cs / 2 - 6, 12, color)
    }
  }
}

///|
fn draw_hover_highlight(game : @types.Game) -> Unit {
  if game.hover_col >= 0 &&
    game.hover_col < @types.grid_cols &&
    game.hover_row >= 0 &&
    game.hover_row < @types.grid_rows {
    let gx = @types.grid_offset_x
    let gy = @types.grid_offset_y
    let cs = @types.cell_size
    let x = gx + game.hover_col * cs
    let y = gy + game.hover_row * cs
    let cell = game.grid.cells[game.hover_row][game.hover_col]
    if cell == Branch {
      // Highlight prunable branch
      @raylib.draw_rectangle_lines(
        x,
        y,
        cs,
        cs,
        @raylib.Color::new(255, 100, 100, 200),
      )
      if !draw_prune_shears_art(x + cs / 2, y + cs / 2) {
        @draw.draw_text(
          "X",
          x + cs / 2 - 4,
          y + cs / 2 - 6,
          14,
          @raylib.Color::new(255, 80, 80, 200),
        )
      }
    }
  }
}

///|
pub fn draw_forest(game : @types.Game) -> Unit {
  draw_sky(game)
  draw_grid_lines(game)
  draw_cells(game)
  draw_target_markers(game)
  draw_ground(game)
  draw_hover_highlight(game)
}
