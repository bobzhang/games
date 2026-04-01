///|
fn fi(v : Int) -> Float {
  Float::from_int(v)
}

///|
pub fn draw_grid(game : @types.Game) -> Unit {
  match game.current_level {
    None => ()
    Some(level) => {
      let ox = @types.grid_offset_x
      let oy = @types.grid_offset_y
      let cs = @types.cell_size
      let grid = level.grid
      // Draw tiles
      for y in 0..<grid.height {
        for x in 0..<grid.width {
          let px = ox + x * cs
          let py = oy + y * cs
          let tile = @types.grid_get(grid, x, y)
          // Base tile color
          let base_color = match tile {
            Empty =>
              if (x + y) % 2 == 0 {
                @types.color_grass
              } else {
                @types.color_grass_alt
              }
            House(_) =>
              if (x + y) % 2 == 0 {
                @types.color_grass
              } else {
                @types.color_grass_alt
              }
            Road => @types.color_road
            Water =>
              if (x + y) % 2 == 0 {
                @types.color_water
              } else {
                @types.color_water_dark
              }
          }
          @raylib.draw_rectangle(px, py, cs, cs, base_color)
          // Draw grid lines
          @raylib.draw_rectangle_lines(px, py, cs, cs, @types.color_grid_line)
          // Draw house
          match tile {
            House(cid) => draw_house_tile(px, py, cs, cid, level.houses)
            Road => {
              // Draw road markings - dashed center line
              let cx = px + cs / 2
              let cy = py + cs / 2
              @raylib.draw_rectangle(
                cx - 1,
                py + 4,
                2,
                cs - 8,
                @raylib.Color::new(200, 200, 190, 100),
              )
              @raylib.draw_rectangle(
                px + 4,
                cy - 1,
                cs - 8,
                2,
                @raylib.Color::new(200, 200, 190, 100),
              )
            }
            Water => {
              // Draw wave pattern
              let wave_y = py + cs / 2
              for wx in 0..<3 {
                let wx_pos = px + 8 + wx * 18
                @raylib.draw_line(
                  wx_pos,
                  wave_y - 2,
                  wx_pos + 8,
                  wave_y + 2,
                  @raylib.Color::new(100, 160, 220, 120),
                )
                @raylib.draw_line(
                  wx_pos + 8,
                  wave_y + 2,
                  wx_pos + 16,
                  wave_y - 2,
                  @raylib.Color::new(100, 160, 220, 120),
                )
              }
            }
            _ => ()
          }
        }
      }
      // Draw grid border
      @raylib.draw_rectangle_lines(
        ox - 2,
        oy - 2,
        grid.width * cs + 4,
        grid.height * cs + 4,
        @types.color_fence,
      )
      @raylib.draw_rectangle_lines(
        ox - 3,
        oy - 3,
        grid.width * cs + 6,
        grid.height * cs + 6,
        @types.color_fence,
      )
    }
  }
}

///|
fn draw_house_tile(
  px : Int,
  py : Int,
  cs : Int,
  cid : Int,
  houses : Array[@types.House],
) -> Unit {
  let color = @types.house_color(cid)
  let margin = 8
  // House body
  @raylib.draw_rectangle(
    px + margin,
    py + margin + 6,
    cs - margin * 2,
    cs - margin * 2 - 6,
    color,
  )
  // Roof triangle
  @raylib.draw_triangle(
    @raylib.Vector2::new(fi(px + cs / 2), fi(py + margin - 2)),
    @raylib.Vector2::new(fi(px + margin - 2), fi(py + margin + 8)),
    @raylib.Vector2::new(fi(px + cs - margin + 2), fi(py + margin + 8)),
    color,
  )
  // Door
  let dr = color.r.to_int() * 3 / 4
  let dg = color.g.to_int() * 3 / 4
  let db = color.b.to_int() * 3 / 4
  @raylib.draw_rectangle(
    px + cs / 2 - 4,
    py + cs - margin - 12,
    8,
    12,
    @raylib.Color::new(dr, dg, db, 255),
  )
  // Find required area for this house and display it
  let mut area = 0
  for i in 0..<houses.length() {
    if houses[i].color_id == cid {
      area = houses[i].required_area
      break
    }
  }
  if area > 0 {
    let area_str = area.to_string()
    let tw = @draw.measure_text(area_str, 16)
    @draw.draw_text(
      area_str,
      px + cs / 2 - tw / 2,
      py + margin + 12,
      16,
      @raylib.white,
    )
  }
}

///|
pub fn draw_fences(game : @types.Game) -> Unit {
  match game.current_level {
    None => ()
    Some(_) => {
      let ox = @types.grid_offset_x
      let oy = @types.grid_offset_y
      let cs = @types.cell_size
      let thickness = @types.fence_thickness
      for i in 0..<game.fences.length() {
        let f = game.fences[i]
        match f.orient {
          Horizontal => {
            let fx = fi(ox + f.col * cs)
            let fy = fi(oy + f.row * cs) - thickness / 2.0
            @raylib.draw_rectangle_rec(
              @raylib.Rectangle::new(fx, fy, fi(cs), thickness),
              @types.color_fence,
            )
            @raylib.draw_circle(
              ox + f.col * cs,
              oy + f.row * cs,
              4.0,
              @types.color_fence,
            )
            @raylib.draw_circle(
              ox + (f.col + 1) * cs,
              oy + f.row * cs,
              4.0,
              @types.color_fence,
            )
          }
          Vertical => {
            let fx = fi(ox + f.col * cs) - thickness / 2.0
            let fy = fi(oy + f.row * cs)
            @raylib.draw_rectangle_rec(
              @raylib.Rectangle::new(fx, fy, thickness, fi(cs)),
              @types.color_fence,
            )
            @raylib.draw_circle(
              ox + f.col * cs,
              oy + f.row * cs,
              4.0,
              @types.color_fence,
            )
            @raylib.draw_circle(
              ox + f.col * cs,
              oy + (f.row + 1) * cs,
              4.0,
              @types.color_fence,
            )
          }
        }
      }
    }
  }
}

///|
pub fn draw_hover_fence(game : @types.Game) -> Unit {
  match game.hover_fence {
    None => ()
    Some(f) =>
      if game.play_state != Complete {
        let ox = @types.grid_offset_x
        let oy = @types.grid_offset_y
        let cs = @types.cell_size
        let thickness = @types.fence_hover_thickness
        let color = @types.color_fence_hover
        match f.orient {
          Horizontal => {
            let fx = fi(ox + f.col * cs)
            let fy = fi(oy + f.row * cs) - thickness / 2.0
            @raylib.draw_rectangle_rec(
              @raylib.Rectangle::new(fx, fy, fi(cs), thickness),
              color,
            )
          }
          Vertical => {
            let fx = fi(ox + f.col * cs) - thickness / 2.0
            let fy = fi(oy + f.row * cs)
            @raylib.draw_rectangle_rec(
              @raylib.Rectangle::new(fx, fy, thickness, fi(cs)),
              color,
            )
          }
        }
      }
  }
}

///|
pub fn draw_region_shading(game : @types.Game) -> Unit {
  if game.regions.length() == 0 {
    return
  }
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  for i in 0..<game.regions.length() {
    let r = game.regions[i]
    // Only shade regions that contain a house
    if r.houses.length() > 0 {
      let shade = @types.region_shade(r.houses[0].color_id)
      for j in 0..<r.tiles.length() {
        let t = r.tiles[j]
        @raylib.draw_rectangle(
          ox + t.x * cs + 2,
          oy + t.y * cs + 2,
          cs - 4,
          cs - 4,
          shade,
        )
      }
    }
  }
}
