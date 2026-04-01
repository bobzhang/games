///|
pub fn trace_all_beams(grid : @types.Grid) -> Array[@types.BeamSegment] {
  let segments : Array[@types.BeamSegment] = []
  @types.grid_clear_received(grid)
  let total = grid.width * grid.height
  let combiner_input_colors : Array[@types.BeamColor] = Array::make(
    total,
    @types.beam_color_black(),
  )
  // Find all sources and trace beams from them
  for y in 0..<grid.height {
    for x in 0..<grid.width {
      match @types.grid_get(grid, x, y) {
        Some(cell) =>
          match cell.component {
            Some(Source) => {
              let source_color = match cell.target_color {
                Some(c) => c
                None => @types.beam_color_white()
              }
              trace_beam(
                grid,
                x,
                y,
                cell.direction,
                source_color,
                segments,
                combiner_input_colors,
                0,
              )
            }
            _ => ()
          }
        None => ()
      }
    }
  }
  // Process combiners - trace output beams from combiners that received input
  for y in 0..<grid.height {
    for x in 0..<grid.width {
      match @types.grid_get(grid, x, y) {
        Some(cell) =>
          match cell.component {
            Some(Combiner) => {
              let idx = y * grid.width + x
              let combined = combiner_input_colors[idx]
              if !@types.beam_color_is_black(combined) {
                trace_beam(
                  grid,
                  x,
                  y,
                  cell.direction,
                  combined,
                  segments,
                  combiner_input_colors,
                  0,
                )
              }
            }
            _ => ()
          }
        None => ()
      }
    }
  }
  segments
}

///|
fn trace_beam(
  grid : @types.Grid,
  start_x : Int,
  start_y : Int,
  dir : @types.Direction,
  color : @types.BeamColor,
  segments : Array[@types.BeamSegment],
  combiner_inputs : Array[@types.BeamColor],
  depth : Int,
) -> Unit {
  if depth > 50 || @types.beam_color_is_black(color) {
    return
  }
  let max_steps = grid.width + grid.height + 2
  let dx = @types.direction_dx(dir)
  let dy = @types.direction_dy(dir)
  let nx = start_x + dx
  let ny = start_y + dy
  if !@types.grid_in_bounds(grid, nx, ny) {
    segments.push({
      start: @types.vec2i(start_x, start_y),
      end_: @types.vec2i(start_x, start_y),
      color,
      direction: dir,
    })
    return
  }
  let mut cx = nx
  let mut cy = ny
  let mut steps = 1
  while steps < max_steps {
    if !@types.grid_in_bounds(grid, cx, cy) {
      segments.push({
        start: @types.vec2i(start_x, start_y),
        end_: @types.vec2i(cx - dx, cy - dy),
        color,
        direction: dir,
      })
      break
    }
    match @types.grid_get(grid, cx, cy) {
      Some(cell) =>
        match cell.component {
          None => {
            let next_x = cx + dx
            let next_y = cy + dy
            if !@types.grid_in_bounds(grid, next_x, next_y) {
              segments.push({
                start: @types.vec2i(start_x, start_y),
                end_: @types.vec2i(cx, cy),
                color,
                direction: dir,
              })
              break
            }
            cx = next_x
            cy = next_y
          }
          Some(Mirror) => {
            segments.push({
              start: @types.vec2i(start_x, start_y),
              end_: @types.vec2i(cx, cy),
              color,
              direction: dir,
            })
            match @types.mirror_reflect(dir, cell.direction) {
              Some(new_dir) =>
                trace_beam(
                  grid,
                  cx,
                  cy,
                  new_dir,
                  color,
                  segments,
                  combiner_inputs,
                  depth + 1,
                )
              None => ()
            }
            break
          }
          Some(Prism) => {
            segments.push({
              start: @types.vec2i(start_x, start_y),
              end_: @types.vec2i(cx, cy),
              color,
              direction: dir,
            })
            let channels = @types.beam_color_channel_count(color)
            if channels <= 1 {
              trace_beam(
                grid,
                cx,
                cy,
                dir,
                color,
                segments,
                combiner_inputs,
                depth + 1,
              )
            } else {
              let mut dir_idx = 0
              if color.r {
                let split_dir = get_split_direction(dir, dir_idx)
                trace_beam(
                  grid,
                  cx,
                  cy,
                  split_dir,
                  @types.beam_color_red(),
                  segments,
                  combiner_inputs,
                  depth + 1,
                )
                dir_idx += 1
              }
              if color.g {
                let split_dir = get_split_direction(dir, dir_idx)
                trace_beam(
                  grid,
                  cx,
                  cy,
                  split_dir,
                  @types.beam_color_green(),
                  segments,
                  combiner_inputs,
                  depth + 1,
                )
                dir_idx += 1
              }
              if color.b {
                let split_dir = get_split_direction(dir, dir_idx)
                trace_beam(
                  grid,
                  cx,
                  cy,
                  split_dir,
                  @types.beam_color_blue(),
                  segments,
                  combiner_inputs,
                  depth + 1,
                )
                ignore(dir_idx)
              }
            }
            break
          }
          Some(Filter) => {
            segments.push({
              start: @types.vec2i(start_x, start_y),
              end_: @types.vec2i(cx, cy),
              color,
              direction: dir,
            })
            match cell.filter_color {
              Some(fc) => {
                let filtered = @types.beam_color_remove_channel(color, fc)
                if !@types.beam_color_is_black(filtered) {
                  trace_beam(
                    grid,
                    cx,
                    cy,
                    dir,
                    filtered,
                    segments,
                    combiner_inputs,
                    depth + 1,
                  )
                }
              }
              None => ()
            }
            break
          }
          Some(Combiner) => {
            segments.push({
              start: @types.vec2i(start_x, start_y),
              end_: @types.vec2i(cx, cy),
              color,
              direction: dir,
            })
            let idx = cy * grid.width + cx
            combiner_inputs[idx] = @types.beam_color_add(
              combiner_inputs[idx],
              color,
            )
            break
          }
          Some(Receiver) => {
            segments.push({
              start: @types.vec2i(start_x, start_y),
              end_: @types.vec2i(cx, cy),
              color,
              direction: dir,
            })
            match cell.received_color {
              Some(existing) =>
                cell.received_color = Some(
                  @types.beam_color_add(existing, color),
                )
              None => cell.received_color = Some(color)
            }
            break
          }
          Some(Source) => {
            segments.push({
              start: @types.vec2i(start_x, start_y),
              end_: @types.vec2i(cx, cy),
              color,
              direction: dir,
            })
            break
          }
        }
      None => break
    }
    steps += 1
  }
}

///|
fn get_split_direction(
  incoming : @types.Direction,
  index : Int,
) -> @types.Direction {
  match index {
    0 => incoming
    1 => @types.direction_cw(incoming)
    _ => @types.direction_ccw(incoming)
  }
}

///|
pub fn check_all_receivers(grid : @types.Grid) -> Bool {
  let mut all_satisfied = true
  for y in 0..<grid.height {
    for x in 0..<grid.width {
      match @types.grid_get(grid, x, y) {
        Some(cell) =>
          match cell.component {
            Some(Receiver) =>
              match (cell.target_color, cell.received_color) {
                (Some(target), Some(received)) =>
                  if target != received {
                    all_satisfied = false
                  }
                (Some(_), None) => all_satisfied = false
                _ => ()
              }
            _ => ()
          }
        None => ()
      }
    }
  }
  all_satisfied
}

///|
pub fn count_beam_crossings(beams : Array[@types.BeamSegment]) -> Int {
  let mut crossings = 0
  for i in 0..<beams.length() {
    let j_start = i + 1
    for j in j_start..<beams.length() {
      if segments_cross(beams[i], beams[j]) {
        crossings += 1
      }
    }
  }
  crossings
}

///|
fn segments_cross(a : @types.BeamSegment, b : @types.BeamSegment) -> Bool {
  let a_horiz = a.direction == E || a.direction == W
  let b_horiz = b.direction == E || b.direction == W
  if a_horiz == b_horiz {
    return false
  }
  let (h, v) = if a_horiz { (a, b) } else { (b, a) }
  let h_y = h.start.y
  let h_min_x = if h.start.x < h.end_.x { h.start.x } else { h.end_.x }
  let h_max_x = if h.start.x > h.end_.x { h.start.x } else { h.end_.x }
  let v_x = v.start.x
  let v_min_y = if v.start.y < v.end_.y { v.start.y } else { v.end_.y }
  let v_max_y = if v.start.y > v.end_.y { v.start.y } else { v.end_.y }
  v_x > h_min_x && v_x < h_max_x && h_y > v_min_y && h_y < v_max_y
}
