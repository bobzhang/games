///|
fn sinf(a : Float) -> Float {
  Float::from_double(@math.sin(a.to_double()))
}

///|
fn paper_origin_x() -> Int32 {
  // Center the grid in the left portion of the screen
  100
}

///|
fn paper_origin_y() -> Int32 {
  (@types.screen_height - @types.grid_size * @types.cell_size) / 2
}

///|
fn target_origin_x() -> Int32 {
  // Target shown to the right
  @types.screen_width - @types.grid_size * @types.cell_size - 100
}

///|
fn target_origin_y() -> Int32 {
  paper_origin_y()
}

///|
fn layer_color(layers : Int32, max_l : Int32) -> @raylib.Color {
  // Interpolate from paper_base (light) to paper_dark based on layer ratio
  let base_r = @types.color_paper_base.r.to_int()
  let base_g = @types.color_paper_base.g.to_int()
  let base_b = @types.color_paper_base.b.to_int()
  let dark_r = @types.color_paper_dark.r.to_int()
  let dark_g = @types.color_paper_dark.g.to_int()
  let dark_b = @types.color_paper_dark.b.to_int()
  let clamped_max = if max_l < 1 { 1 } else { max_l }
  let t : Double = if layers <= 1 {
    0.0
  } else {
    Int32::to_double(layers - 1) / Int32::to_double(clamped_max)
  }
  let r = base_r + (Int32::to_double(dark_r - base_r) * t).to_int()
  let g = base_g + (Int32::to_double(dark_g - base_g) * t).to_int()
  let b = base_b + (Int32::to_double(dark_b - base_b) * t).to_int()
  @raylib.Color::new(r, g, b, 255)
}

///|
fn draw_paper_grid(
  paper : @types.Paper,
  ox : Int32,
  oy : Int32,
  show_layers : Bool,
) -> Unit {
  let cs = @types.cell_size
  let max_l = @types.max_layers(paper)
  // Draw cells
  for y in 0..<paper.height {
    for x in 0..<paper.width {
      let cell = @types.get_cell(paper, x, y)
      let px = ox + x * cs
      let py = oy + y * cs
      if cell.has_paper {
        let col = layer_color(cell.layers, max_l)
        @raylib.draw_rectangle(px, py, cs, cs, col)
        // Layer number
        if show_layers && cell.layers > 1 {
          let txt = cell.layers.to_string()
          let tw = @draw.measure_text(txt, 14)
          @draw.draw_text(
            txt,
            px + (cs - tw) / 2,
            py + (cs - 14) / 2,
            14,
            @raylib.Color::new(80, 60, 40, 180),
          )
        }
      }
      // Grid line
      @raylib.draw_rectangle_lines(px, py, cs, cs, @types.color_grid_line)
    }
  }
}

///|
fn draw_target_ghost(target : @types.Paper, ox : Int32, oy : Int32) -> Unit {
  let cs = @types.cell_size
  for y in 0..<target.height {
    for x in 0..<target.width {
      let cell = @types.get_cell(target, x, y)
      let px = ox + x * cs
      let py = oy + y * cs
      if cell.has_paper {
        @raylib.draw_rectangle(px, py, cs, cs, @types.color_target_ghost)
        @raylib.draw_rectangle_lines(
          px, py, cs, cs, @types.color_target_outline,
        )
      }
    }
  }
}

///|
fn draw_fold_line_preview(game : @types.Game, ox : Int32, oy : Int32) -> Unit {
  let cs = @types.cell_size
  let gs = @types.grid_size
  let line = game.fold_line
  let time = Float::from_int(game.frame_count) * 0.1
  let pulse = (sinf(time) * 40.0 + 180.0).to_int()
  let col = @raylib.Color::new(220, 50, 50, pulse)
  match game.fold_dir {
    Left | Right => {
      // Vertical line at column 'line'
      let lx = ox + line * cs
      for seg in 0..<gs {
        let sy = oy + seg * cs
        @raylib.draw_rectangle(lx - 2, sy, 4, cs / 2, col)
      }
      // Arrow indicator
      draw_fold_arrow(game.fold_dir, lx, oy + gs * cs / 2, cs)
    }
    Up | Down => {
      // Horizontal line at row 'line'
      let ly = oy + line * cs
      for seg in 0..<gs {
        let sx = ox + seg * cs
        @raylib.draw_rectangle(sx, ly - 2, cs / 2, 4, col)
      }
      draw_fold_arrow(game.fold_dir, ox + gs * cs / 2, ly, cs)
    }
  }
}

///|
fn draw_fold_arrow(
  dir : @types.FoldDir,
  cx : Int32,
  cy : Int32,
  size : Int32,
) -> Unit {
  let s = size / 3
  let col = @types.color_fold_line
  match dir {
    Left =>
      // Arrow pointing left
      @raylib.draw_triangle(
        @raylib.Vector2::new(Float::from_int(cx - s), Float::from_int(cy)),
        @raylib.Vector2::new(
          Float::from_int(cx + s / 2),
          Float::from_int(cy - s),
        ),
        @raylib.Vector2::new(
          Float::from_int(cx + s / 2),
          Float::from_int(cy + s),
        ),
        col,
      )
    Right =>
      @raylib.draw_triangle(
        @raylib.Vector2::new(Float::from_int(cx + s), Float::from_int(cy)),
        @raylib.Vector2::new(
          Float::from_int(cx - s / 2),
          Float::from_int(cy + s),
        ),
        @raylib.Vector2::new(
          Float::from_int(cx - s / 2),
          Float::from_int(cy - s),
        ),
        col,
      )
    Up =>
      @raylib.draw_triangle(
        @raylib.Vector2::new(Float::from_int(cx), Float::from_int(cy - s)),
        @raylib.Vector2::new(
          Float::from_int(cx + s),
          Float::from_int(cy + s / 2),
        ),
        @raylib.Vector2::new(
          Float::from_int(cx - s),
          Float::from_int(cy + s / 2),
        ),
        col,
      )
    Down =>
      @raylib.draw_triangle(
        @raylib.Vector2::new(Float::from_int(cx), Float::from_int(cy + s)),
        @raylib.Vector2::new(
          Float::from_int(cx - s),
          Float::from_int(cy - s / 2),
        ),
        @raylib.Vector2::new(
          Float::from_int(cx + s),
          Float::from_int(cy - s / 2),
        ),
        col,
      )
  }
}

///|
fn draw_layer_checks(game : @types.Game, ox : Int32, oy : Int32) -> Unit {
  let cs = @types.cell_size
  let checks = game.target.layer_checks
  for i in 0..<checks.length() {
    let chk = checks[i]
    let px = ox + chk.pos.x * cs
    let py = oy + chk.pos.y * cs
    let ok = @types.single_layer_check_ok(game.current_paper, chk)
    let border_col = if ok {
      @types.color_check_ok
    } else {
      @types.color_check_gold
    }
    // Draw gold/green border around cell
    @raylib.draw_rectangle_lines_ex(
      @raylib.Rectangle::new(
        Float::from_int(px),
        Float::from_int(py),
        Float::from_int(cs),
        Float::from_int(cs),
      ),
      3.0,
      border_col,
    )
    // Draw required layer number
    let txt = chk.required_layers.to_string()
    let tw = @draw.measure_text(txt, 18)
    let text_col = if ok {
      @types.color_check_ok
    } else {
      @types.color_check_fail
    }
    @draw.draw_text(txt, px + (cs - tw) / 2, py + 2, 18, text_col)
  }
}

///|
fn draw_target_layer_checks(game : @types.Game, ox : Int32, oy : Int32) -> Unit {
  let cs = @types.cell_size
  let checks = game.target.layer_checks
  for i in 0..<checks.length() {
    let chk = checks[i]
    let px = ox + chk.pos.x * cs
    let py = oy + chk.pos.y * cs
    // Always show in gold on target
    @raylib.draw_rectangle_lines_ex(
      @raylib.Rectangle::new(
        Float::from_int(px),
        Float::from_int(py),
        Float::from_int(cs),
        Float::from_int(cs),
      ),
      3.0,
      @types.color_check_gold,
    )
    let txt = chk.required_layers.to_string()
    let tw = @draw.measure_text(txt, 18)
    @draw.draw_text(
      txt,
      px + (cs - tw) / 2,
      py + 2,
      18,
      @types.color_check_gold,
    )
  }
}
