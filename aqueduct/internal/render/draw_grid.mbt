///|
/// Draw the elevation grid background.
pub fn draw_grid(game : @types.Game) -> Unit {
  let level = game.levels[game.current_level]
  let cols = level.grid_cols
  let rows = level.grid_rows
  // Draw grid background
  let gw = cols * @types.cell_size
  let gh = rows * @types.cell_size
  @raylib.draw_rectangle(
    @types.grid_offset_x - 2,
    @types.grid_offset_y - 2,
    gw + 4,
    gh + 4,
    @types.color_grid_line,
  )
  // Draw each cell with elevation-based color
  for y in 0..<rows {
    for x in 0..<cols {
      let idx = y * cols + x
      let tile = game.grid[idx]
      let sx = @types.grid_offset_x + x * @types.cell_size
      let sy = @types.grid_offset_y + y * @types.cell_size
      let cs = @types.cell_size
      // Elevation color
      let elev_idx = if tile.elevation >= 0 && tile.elevation <= 4 {
        tile.elevation
      } else {
        0
      }
      let base_color = @types.color_elevation[elev_idx]
      @raylib.draw_rectangle(sx, sy, cs, cs, base_color)
      // Draw cell outline
      @raylib.draw_rectangle_lines(sx, sy, cs, cs, @types.color_grid_line)
      // Draw elevation number in corner
      let elev_str = tile.elevation.to_string()
      @draw.draw_text(elev_str, sx + 2, sy + 1, 12, @types.color_hud_dim)
    }
  }
}

///|
/// Draw tile contents (springs, fountains, aqueducts, etc.)
pub fn draw_tiles(game : @types.Game) -> Unit {
  let level = game.levels[game.current_level]
  let cols = level.grid_cols
  let rows = level.grid_rows
  let cs = @types.cell_size
  let half = cs / 2
  for y in 0..<rows {
    for x in 0..<cols {
      let idx = y * cols + x
      let tile = game.grid[idx]
      let sx = @types.grid_offset_x + x * cs
      let sy = @types.grid_offset_y + y * cs
      let cx = sx + half
      let cy = sy + half
      match tile.kind {
        Spring => draw_spring(cx, cy, half, tile.has_water, game.anim_timer)
        Fountain =>
          draw_fountain(cx, cy, half, tile.has_water, game.anim_timer)
        Aqueduct => draw_aqueduct(sx, sy, cs, tile)
        Reservoir => draw_reservoir(sx, sy, cs, tile)
        Dam => draw_dam(sx, sy, cs, tile)
        Empty => ()
      }
    }
  }
}

///|
fn draw_spring(
  cx : Int,
  cy : Int,
  half : Int,
  has_water : Bool,
  anim_timer : Float
) -> Unit {
  let r = Float::from_int(half - 6)
  let pulse : Float = 1.0 + sinf(anim_timer * 3.0) * 0.1
  let draw_r = r * pulse
  @raylib.draw_circle(cx, cy, draw_r, @types.color_spring)
  if has_water {
    let inner_r = draw_r * 0.6
    @raylib.draw_circle(cx, cy, inner_r, @types.color_water)
  }
  // Draw "S" label
  @draw.draw_text("S", cx - 5, cy - 8, 16, @types.color_selected)
}

///|
fn draw_fountain(
  cx : Int,
  cy : Int,
  half : Int,
  filled : Bool,
  anim_timer : Float
) -> Unit {
  let r = Float::from_int(half - 6)
  let color = if filled { @types.color_fountain_filled } else { @types.color_fountain }
  @raylib.draw_circle(cx, cy, r, color)
  if filled {
    let pulse : Float = 1.0 + sinf(anim_timer * 4.0) * 0.15
    let inner_r = r * 0.5 * pulse
    @raylib.draw_circle(cx, cy, inner_r, @types.color_water_flow)
  }
  // Draw "F" label
  @draw.draw_text("F", cx - 5, cy - 8, 16, @types.color_selected)
}

///|
fn draw_aqueduct(sx : Int, sy : Int, cs : Int, tile : @types.Tile) -> Unit {
  let color = if tile.has_water {
    @types.color_aqueduct_wet
  } else {
    @types.color_aqueduct
  }
  let inset = cs / 5
  @raylib.draw_rectangle(sx + inset, sy + inset, cs - inset * 2, cs - inset * 2, color)
  // Draw connection lines
  let cx = sx + cs / 2
  let cy = sy + cs / 2
  let water_color = if tile.has_water { @types.color_water_flow } else { color }
  for d in tile.connections {
    match d {
      North =>
        @raylib.draw_rectangle(cx - 3, sy, 6, cs / 2, water_color)
      South =>
        @raylib.draw_rectangle(cx - 3, cy, 6, cs / 2, water_color)
      East =>
        @raylib.draw_rectangle(cx, cy - 3, cs / 2, 6, water_color)
      West =>
        @raylib.draw_rectangle(sx, cy - 3, cs / 2, 6, water_color)
    }
  }
}

///|
fn draw_reservoir(sx : Int, sy : Int, cs : Int, tile : @types.Tile) -> Unit {
  let color = if tile.has_water {
    @types.color_reservoir_full
  } else {
    @types.color_reservoir
  }
  let inset = cs / 6
  @raylib.draw_rectangle(sx + inset, sy + inset, cs - inset * 2, cs - inset * 2, color)
  // Draw fill level
  if tile.water_level > 0 && !tile.has_water {
    let fill_h = (cs - inset * 2) * tile.water_level / 3
    let fill_y = sy + cs - inset - fill_h
    @raylib.draw_rectangle(
      sx + inset,
      fill_y,
      cs - inset * 2,
      fill_h,
      @types.color_water,
    )
  }
  // Draw connections
  let cx = sx + cs / 2
  let cy = sy + cs / 2
  for d in tile.connections {
    match d {
      North =>
        @raylib.draw_rectangle(cx - 3, sy, 6, cs / 2, color)
      South =>
        @raylib.draw_rectangle(cx - 3, cy, 6, cs / 2, color)
      East =>
        @raylib.draw_rectangle(cx, cy - 3, cs / 2, 6, color)
      West =>
        @raylib.draw_rectangle(sx, cy - 3, cs / 2, 6, color)
    }
  }
  @draw.draw_text("R", sx + cs / 2 - 5, sy + cs / 2 - 8, 16, @types.color_selected)
}

///|
fn draw_dam(sx : Int, sy : Int, cs : Int, tile : @types.Tile) -> Unit {
  let inset = cs / 5
  @raylib.draw_rectangle(
    sx + inset,
    sy + inset,
    cs - inset * 2,
    cs - inset * 2,
    @types.color_dam,
  )
  // Draw blocked direction as a thick red line
  let cx = sx + cs / 2
  let cy = sy + cs / 2
  // Find which direction is blocked (not in connections)
  for d in @types.all_directions {
    let mut found = false
    for c in tile.connections {
      if c == d {
        found = true
        break
      }
    }
    if !found {
      // This direction is blocked - draw red bar
      let red = @raylib.Color::new(255, 50, 50, 220)
      match d {
        North =>
          @raylib.draw_rectangle(sx + inset, sy + inset, cs - inset * 2, 4, red)
        South =>
          @raylib.draw_rectangle(
            sx + inset,
            sy + cs - inset - 4,
            cs - inset * 2,
            4,
            red,
          )
        East =>
          @raylib.draw_rectangle(
            sx + cs - inset - 4,
            sy + inset,
            4,
            cs - inset * 2,
            red,
          )
        West =>
          @raylib.draw_rectangle(sx + inset, sy + inset, 4, cs - inset * 2, red)
      }
    }
  }
  @draw.draw_text("D", cx - 5, cy - 8, 16, @types.color_selected)
}

///|
/// Draw hover highlight on the grid.
pub fn draw_hover(game : @types.Game) -> Unit {
  guard game.hover_cell is Some(pos) else { return }
  let (sx, sy) = @types.grid_to_screen(pos)
  let cs = @types.cell_size
  let color = if @types.can_place_at(game, pos) {
    @types.color_hover
  } else {
    @types.color_invalid
  }
  @raylib.draw_rectangle(sx, sy, cs, cs, color)
}

///|
/// Draw water flow animation overlay.
pub fn draw_water_overlay(game : @types.Game) -> Unit {
  let level = game.levels[game.current_level]
  let cols = level.grid_cols
  let rows = level.grid_rows
  let cs = @types.cell_size
  for y in 0..<rows {
    for x in 0..<cols {
      let idx = y * cols + x
      let tile = game.grid[idx]
      if tile.has_water && !(tile.kind is Spring) && !(tile.kind is Fountain) {
        let sx = @types.grid_offset_x + x * cs
        let sy = @types.grid_offset_y + y * cs
        let pulse_val : Float = 128.0 + sinf(game.anim_timer * 2.0 + Float::from_int(x + y) * 0.5) * 60.0
        let pulse_alpha = pulse_val.to_int()
        let alpha = if pulse_alpha > 255 {
          255
        } else if pulse_alpha < 0 {
          0
        } else {
          pulse_alpha
        }
        let water_overlay = @raylib.Color::new(40, 140, 255, alpha)
        let inset = cs / 5
        @raylib.draw_rectangle(
          sx + inset,
          sy + inset,
          cs - inset * 2,
          cs - inset * 2,
          water_overlay,
        )
      }
    }
  }
}
