///|
fn draw_playing(game : @types.Game) -> Unit {
  match game.current_level {
    None => ()
    Some(level) => {
      draw_grid_background()
      draw_zones(level.zones)
      // Draw ghost preview first (behind the tree)
      match game.ghost_tree {
        Some(ghost) => draw_ghost_tree(ghost, level.species)
        None => ()
      }
      draw_tree(game.tree, level.species)
      draw_hover(game)
      draw_playing_ui(game, level)
    }
  }
}

///|
fn draw_grid_background() -> Unit {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_render_size
  let w = @types.grid_width
  let h = @types.grid_height
  // Grid background
  @raylib.draw_rectangle(
    ox - 2,
    oy - 2,
    w * cs + 4,
    h * cs + 4,
    @raylib.Color::new(40, 36, 30, 255),
  )
  if !draw_board_art() {
    @raylib.draw_rectangle(
      ox,
      oy,
      w * cs,
      h * cs,
      @raylib.Color::new(28, 25, 21, 255),
    )
  }
  // Grid lines
  for x in 0..<=w {
    @raylib.draw_line(
      ox + x * cs,
      oy,
      ox + x * cs,
      oy + h * cs,
      @types.color_grid_line,
    )
  }
  for y in 0..<=h {
    @raylib.draw_line(
      ox,
      oy + y * cs,
      ox + w * cs,
      oy + y * cs,
      @types.color_grid_line,
    )
  }
  // Ground line
  @raylib.draw_rectangle(
    ox,
    oy + (h - 1) * cs + cs,
    w * cs,
    4,
    @raylib.Color::new(80, 60, 40, 255),
  )
}

///|
fn draw_zones(zones : Array[@types.Zone]) -> Unit {
  let cs = @types.cell_render_size
  for zone in zones {
    let color = match zone.kind {
      Required => @types.color_zone_required
      Forbidden => @types.color_zone_forbidden
      TipTarget => @types.color_zone_tip
    }
    for pos in zone.positions {
      let sx = @types.cell_screen_x(pos.x)
      let sy = @types.cell_screen_y(pos.y)
      @raylib.draw_rectangle(sx, sy, cs, cs, color)
      // Draw border
      let border_color = match zone.kind {
        Required => @raylib.Color::new(50, 200, 80, 120)
        Forbidden => @raylib.Color::new(200, 50, 50, 120)
        TipTarget => @raylib.Color::new(255, 200, 50, 140)
      }
      @raylib.draw_rectangle_lines(sx, sy, cs, cs, border_color)
      // Draw zone icon
      match zone.kind {
        Required => {
          // Small "+" sign
          let cx = sx + cs / 2
          let cy = sy + cs / 2
          @raylib.draw_line(cx - 4, cy, cx + 4, cy, border_color)
          @raylib.draw_line(cx, cy - 4, cx, cy + 4, border_color)
        }
        Forbidden => {
          // Small "x" sign
          @raylib.draw_line(
            sx + 6,
            sy + 6,
            sx + cs - 6,
            sy + cs - 6,
            border_color,
          )
          @raylib.draw_line(
            sx + cs - 6,
            sy + 6,
            sx + 6,
            sy + cs - 6,
            border_color,
          )
        }
        TipTarget => {
          // Small diamond
          let cx = sx + cs / 2
          let cy = sy + cs / 2
          @raylib.draw_line(cx, cy - 5, cx + 5, cy, border_color)
          @raylib.draw_line(cx + 5, cy, cx, cy + 5, border_color)
          @raylib.draw_line(cx, cy + 5, cx - 5, cy, border_color)
          @raylib.draw_line(cx - 5, cy, cx, cy - 5, border_color)
        }
      }
    }
  }
}

///|
fn draw_tree(grid : @types.TreeGrid, species : @types.Species) -> Unit {
  let cs = @types.cell_render_size
  for y in 0..<grid.height {
    for x in 0..<grid.width {
      let cell = @types.grid_get(grid, x, y)
      let sx = @types.cell_screen_x(x)
      let sy = @types.cell_screen_y(y)
      match cell.kind {
        Trunk =>
          if !draw_trunk_art(sx, sy) {
            // Thick brown rectangle
            let pad = cs / 6
            @raylib.draw_rectangle(
              sx + pad,
              sy,
              cs - pad * 2,
              cs,
              @types.color_trunk,
            )
            // Darker edge
            @raylib.draw_rectangle(
              sx + pad,
              sy,
              2,
              cs,
              @raylib.Color::new(70, 45, 20, 255),
            )
          }
        Branch =>
          if !draw_branch_art(sx, sy, cell.growth_dir) {
            let bcolor = @types.branch_color(species)
            // Thinner rectangle along growth direction
            let pad = cs / 4
            let dx = @types.dir_dx(cell.growth_dir)
            let dy = @types.dir_dy(cell.growth_dir)
            if dx == 0 {
              // Vertical branch
              @raylib.draw_rectangle(sx + pad, sy, cs - pad * 2, cs, bcolor)
            } else if dy == 0 {
              // Horizontal branch
              @raylib.draw_rectangle(sx, sy + pad, cs, cs - pad * 2, bcolor)
            } else {
              // Diagonal - draw an L shape
              @raylib.draw_rectangle(sx + pad, sy, cs - pad * 2, cs / 2, bcolor)
              if dx > 0 {
                @raylib.draw_rectangle(
                  sx + cs / 2,
                  sy + pad,
                  cs / 2,
                  cs - pad * 2,
                  bcolor,
                )
              } else {
                @raylib.draw_rectangle(
                  sx,
                  sy + pad,
                  cs / 2,
                  cs - pad * 2,
                  bcolor,
                )
              }
            }
          }
        Leaf =>
          if !draw_leaf_art(sx, sy, species) {
            let lcolor = @types.leaf_color(species)
            let cx = sx + cs / 2
            let cy = sy + cs / 2
            let radius = Float::from_int(cs) / 2.5
            @raylib.draw_circle(cx, cy, radius, lcolor)
            // Inner highlight
            @raylib.draw_circle(
              cx - 2,
              cy - 2,
              radius * 0.5,
              @raylib.Color::new(
                (lcolor.r.to_int() + 40) |> min(255),
                (lcolor.g.to_int() + 40) |> min(255),
                (lcolor.b.to_int() + 40) |> min(255),
                200,
              ),
            )
          }
        Pruned =>
          if !draw_pruned_art(sx, sy) {
            // Faint mark
            @raylib.draw_rectangle(
              sx + cs / 4,
              sy + cs / 4,
              cs / 2,
              cs / 2,
              @types.color_pruned,
            )
          }
        Empty => ()
      }
    }
  }
}

///|
fn min(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn draw_ghost_tree(ghost : @types.TreeGrid, species : @types.Species) -> Unit {
  let cs = @types.cell_render_size
  let ghost_color = @types.color_ghost
  for y in 0..<ghost.height {
    for x in 0..<ghost.width {
      let cell = @types.grid_get(ghost, x, y)
      let sx = @types.cell_screen_x(x)
      let sy = @types.cell_screen_y(y)
      match cell.kind {
        Branch => {
          let _ = species
          let pad = cs / 4
          @raylib.draw_rectangle(
            sx + pad,
            sy + pad,
            cs - pad * 2,
            cs - pad * 2,
            ghost_color,
          )
        }
        Leaf => {
          let cx = sx + cs / 2
          let cy = sy + cs / 2
          @raylib.draw_circle(cx, cy, Float::from_int(cs) / 3.0, ghost_color)
        }
        _ => ()
      }
    }
  }
}

///|
fn draw_hover(game : @types.Game) -> Unit {
  match game.hover_cell {
    None => ()
    Some(pos) =>
      if @types.grid_in_bounds(game.tree, pos.x, pos.y) {
        let cell = @types.grid_get(game.tree, pos.x, pos.y)
        if cell.kind == Branch || cell.kind == Leaf {
          let sx = @types.cell_screen_x(pos.x)
          let sy = @types.cell_screen_y(pos.y)
          let cs = @types.cell_render_size
          @raylib.draw_rectangle(sx, sy, cs, cs, @types.color_hover)
          @raylib.draw_rectangle_lines(
            sx,
            sy,
            cs,
            cs,
            @raylib.Color::new(255, 255, 100, 200),
          )
        }
      }
  }
}
