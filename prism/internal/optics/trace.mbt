///|
pub fn trace_all_beams(grid : @types.HexGrid) -> Array[@types.BeamSegment] {
  let segments : Array[@types.BeamSegment] = []
  @types.grid_clear_received(grid)
  // Find all sources and trace beams from them
  let coords = @types.grid_all_coords(grid)
  for i in 0..<coords.length() {
    let (q, r) = coords[i]
    match @types.grid_get(grid, q, r) {
      Some(cell) =>
        match cell.component {
          Some(Source) => {
            let source_color = match cell.target_color {
              Some(c) => c
              None => @types.beam_color_white()
            }
            trace_beam(grid, q, r, cell.direction, source_color, segments, 0)
          }
          _ => ()
        }
      None => ()
    }
  }
  segments
}

///|
fn trace_beam(
  grid : @types.HexGrid,
  start_q : Int,
  start_r : Int,
  dir : @types.HexDir,
  color : @types.BeamColor,
  segments : Array[@types.BeamSegment],
  depth : Int,
) -> Unit {
  if depth > 60 || @types.beam_color_is_black(color) {
    return
  }
  let dq = @types.hex_dir_dq(dir)
  let dr = @types.hex_dir_dr(dir)
  let nq = start_q + dq
  let nr = start_r + dr
  // If first step is out of bounds, record a point segment
  if !@types.grid_in_bounds(grid, nq, nr) {
    segments.push({
      start: { q: start_q, r: start_r, },
      end_: { q: start_q, r: start_r, },
      color,
      direction: dir,
    })
    return
  }
  let mut cq = nq
  let mut cr = nr
  let max_steps = @types.grid_radius * 2 + 4
  for steps = 0; steps < max_steps; steps = steps + 1 {
    if !@types.grid_in_bounds(grid, cq, cr) {
      // Beam left the grid; segment ends at previous cell
      segments.push({
        start: { q: start_q, r: start_r, },
        end_: { q: cq - dq, r: cr - dr, },
        color,
        direction: dir,
      })
      return
    }
    match @types.grid_get(grid, cq, cr) {
      Some(cell) =>
        match cell.component {
          None => {
            // Empty cell, continue
            let next_q = cq + dq
            let next_r = cr + dr
            if !@types.grid_in_bounds(grid, next_q, next_r) {
              segments.push({
                start: { q: start_q, r: start_r, },
                end_: { q: cq, r: cr, },
                color,
                direction: dir,
              })
              return
            }
            cq = next_q
            cr = next_r
          }
          Some(Mirror) => {
            segments.push({
              start: { q: start_q, r: start_r, },
              end_: { q: cq, r: cr, },
              color,
              direction: dir,
            })
            let new_dir = @types.mirror_reflect_hex(dir, cell.direction)
            // Don't reflect back on itself (head-on reflection = absorbed)
            if new_dir != dir {
              trace_beam(grid, cq, cr, new_dir, color, segments, depth + 1)
            }
            return
          }
          Some(Crystal) => {
            segments.push({
              start: { q: start_q, r: start_r, },
              end_: { q: cq, r: cr, },
              color,
              direction: dir,
            })
            match cell.crystal_face {
              Some(face) => {
                let new_dir = @types.crystal_refract(dir, face)
                trace_beam(grid, cq, cr, new_dir, color, segments, depth + 1)
              }
              None =>
                // Default crystal: pass through (refract left)
                trace_beam(grid, cq, cr, dir, color, segments, depth + 1)
            }
            return
          }
          Some(Filter) => {
            segments.push({
              start: { q: start_q, r: start_r, },
              end_: { q: cq, r: cr, },
              color,
              direction: dir,
            })
            match cell.filter_color {
              Some(fc) => {
                let filtered = @types.beam_color_filter(color, fc)
                if !@types.beam_color_is_black(filtered) {
                  trace_beam(grid, cq, cr, dir, filtered, segments, depth + 1)
                }
              }
              None => ()
            }
            return
          }
          Some(Target) => {
            segments.push({
              start: { q: start_q, r: start_r, },
              end_: { q: cq, r: cr, },
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
            return
          }
          Some(Source) => {
            // Beam hits another source, stops
            segments.push({
              start: { q: start_q, r: start_r, },
              end_: { q: cq, r: cr, },
              color,
              direction: dir,
            })
            return
          }
        }
      None => return
    }
  }
}

///|
pub fn check_all_targets(grid : @types.HexGrid) -> Bool {
  let mut all_satisfied = true
  for _k, cell in grid.cells {
    match cell.component {
      Some(Target) =>
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
  }
  all_satisfied
}
