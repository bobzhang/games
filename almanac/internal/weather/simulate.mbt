///|
pub fn simulate_turn(
  grid : @types.Grid,
  sources : Array[@types.Source]
) -> Unit {
  let w = grid.width
  let h = grid.height
  // Build a new weather state array for simultaneous resolution
  let next : Array[@types.WeatherState] = []
  for i in 0..<grid.tiles.length() {
    next.push(grid.tiles[i].weather)
  }
  // Step 1: Apply direct source effects
  for si in 0..<sources.length() {
    let src = sources[si]
    let sc = src.col
    let sr = src.row
    let idx = @types.grid_index(sc, sr, w)
    match src.kind {
      Sun => next[idx] = Sunny
      Rain => next[idx] = Rainy
      Wind => next[idx] = Windy
    }
  }
  // Step 2: Sun propagation - sun makes adjacent tiles sunny (blocked by clouds)
  for si in 0..<sources.length() {
    let src = sources[si]
    if src.kind != Sun {
      continue
    }
    let sc = src.col
    let sr = src.row
    let dirs : Array[(Int, Int)] = [(-1, 0), (1, 0), (0, -1), (0, 1)]
    for d in 0..<dirs.length() {
      let (dx, dy) = dirs[d]
      let nc = sc + dx
      let nr = sr + dy
      if @types.in_bounds(nc, nr, w, h) {
        let ni = @types.grid_index(nc, nr, w)
        // Sun is blocked by existing clouds
        if next[ni] == Cloudy || next[ni] == Stormy {
          continue
        }
        if next[ni] == Clear {
          next[ni] = Sunny
        }
      }
    }
  }
  // Step 3: Rain propagation - rain makes adjacent tiles rainy, flows downhill
  for si in 0..<sources.length() {
    let src = sources[si]
    if src.kind != Rain {
      continue
    }
    let sc = src.col
    let sr = src.row
    let src_height = grid.tiles[@types.grid_index(sc, sr, w)].height
    let dirs : Array[(Int, Int)] = [(-1, 0), (1, 0), (0, -1), (0, 1)]
    for d in 0..<dirs.length() {
      let (dx, dy) = dirs[d]
      let nc = sc + dx
      let nr = sr + dy
      if @types.in_bounds(nc, nr, w, h) {
        let ni = @types.grid_index(nc, nr, w)
        let neighbor_height = grid.tiles[ni].height
        // Rain flows to equal or lower height
        if neighbor_height <= src_height {
          if next[ni] == Clear || next[ni] == Sunny {
            next[ni] = Rainy
          }
        }
      }
    }
  }
  // Step 3b: Rain secondary flow - rainy tiles also flow downhill
  let flow_changed = true
  let mut flow_iters = 0
  while flow_changed && flow_iters < 5 {
    flow_iters += 1
    let mut did_change = false
    for r in 0..<h {
      for c in 0..<w {
        let idx = @types.grid_index(c, r, w)
        if next[idx] == Rainy {
          let tile_h = grid.tiles[idx].height
          let dirs : Array[(Int, Int)] = [(-1, 0), (1, 0), (0, -1), (0, 1)]
          for d in 0..<dirs.length() {
            let (dx, dy) = dirs[d]
            let nc = c + dx
            let nr = r + dy
            if @types.in_bounds(nc, nr, w, h) {
              let ni = @types.grid_index(nc, nr, w)
              let nh = grid.tiles[ni].height
              // Flow downhill only (strict)
              if nh < tile_h && next[ni] == Clear {
                next[ni] = Rainy
                did_change = true
              }
            }
          }
        }
      }
    }
    if !did_change {
      break
    }
  }
  // Step 4: Rain creates clouds above (one tile north of rain source)
  for si in 0..<sources.length() {
    let src = sources[si]
    if src.kind != Rain {
      continue
    }
    let nc = src.col
    let nr = src.row - 1
    if @types.in_bounds(nc, nr, w, h) {
      let ni = @types.grid_index(nc, nr, w)
      if next[ni] == Clear || next[ni] == Sunny {
        next[ni] = Cloudy
      }
    }
  }
  // Step 5: Wind pushes clouds in wind direction
  for si in 0..<sources.length() {
    let src = sources[si]
    if src.kind != Wind {
      continue
    }
    let wdx = @types.wind_dir_dx(src.wind_dir)
    let wdy = @types.wind_dir_dy(src.wind_dir)
    // Push clouds: scan in reverse to avoid double-moving
    // We need a separate pass to find clouds then move them
    let cloud_positions : Array[(Int, Int)] = []
    for r in 0..<h {
      for c in 0..<w {
        let idx = @types.grid_index(c, r, w)
        if next[idx] == Cloudy {
          cloud_positions.push((c, r))
        }
      }
    }
    for ci in 0..<cloud_positions.length() {
      let (cc, cr) = cloud_positions[ci]
      let nc = cc + wdx
      let nr = cr + wdy
      let old_idx = @types.grid_index(cc, cr, w)
      // Check hill blocks: wind blocked if target is higher
      if @types.in_bounds(nc, nr, w, h) {
        let new_idx = @types.grid_index(nc, nr, w)
        let src_h = grid.tiles[old_idx].height
        let dst_h = grid.tiles[new_idx].height
        if dst_h <= src_h + 1 {
          // Move cloud
          if next[new_idx] == Clear || next[new_idx] == Sunny {
            next[new_idx] = Cloudy
            next[old_idx] = Clear
          }
        }
      } else {
        // Cloud pushed off grid - disappears
        next[old_idx] = Clear
      }
    }
  }
  // Step 6: Wind makes adjacent clear tiles windy
  for si in 0..<sources.length() {
    let src = sources[si]
    if src.kind != Wind {
      continue
    }
    let sc = src.col
    let sr = src.row
    let dirs : Array[(Int, Int)] = [(-1, 0), (1, 0), (0, -1), (0, 1)]
    for d in 0..<dirs.length() {
      let (dx, dy) = dirs[d]
      let nc = sc + dx
      let nr = sr + dy
      if @types.in_bounds(nc, nr, w, h) {
        let ni = @types.grid_index(nc, nr, w)
        if next[ni] == Clear {
          next[ni] = Windy
        }
      }
    }
  }
  // Step 7: Interaction - Rain + Wind on same tile = Storm
  for i in 0..<next.length() {
    // Check if tile has both rain and wind influence
    let c = i % w
    let r = i / w
    if next[i] == Rainy {
      // Check if any wind source is adjacent or on this tile
      let mut has_wind = false
      for si in 0..<sources.length() {
        if sources[si].kind == Wind {
          let wc = sources[si].col
          let wr = sources[si].row
          let dist_c = if wc > c { wc - c } else { c - wc }
          let dist_r = if wr > r { wr - r } else { r - wr }
          if (dist_c + dist_r) <= 1 {
            has_wind = true
          }
        }
      }
      if has_wind {
        next[i] = Stormy
      }
    } else if next[i] == Windy {
      // Check if any rain source is adjacent or on this tile
      let mut has_rain = false
      for si in 0..<sources.length() {
        if sources[si].kind == Rain {
          let rc = sources[si].col
          let rr = sources[si].row
          let dist_c = if rc > c { rc - c } else { c - rc }
          let dist_r = if rr > r { rr - r } else { r - rr }
          if (dist_c + dist_r) <= 1 {
            has_rain = true
          }
        }
      }
      if has_rain {
        next[i] = Stormy
      }
    }
  }
  // Step 8: Cancellation - Sunny + Rainy on same tile = Clear
  for i in 0..<next.length() {
    let c = i % w
    let r = i / w
    if next[i] == Sunny {
      // Check if any rain source would also affect this tile
      let mut has_rain_influence = false
      for si in 0..<sources.length() {
        if sources[si].kind == Rain {
          let rc = sources[si].col
          let rr = sources[si].row
          let dist_c = if rc > c { rc - c } else { c - rc }
          let dist_r = if rr > r { rr - r } else { r - rr }
          if (dist_c + dist_r) <= 1 {
            let rain_h = grid.tiles[@types.grid_index(rc, rr, w)].height
            let tile_h = grid.tiles[i].height
            if tile_h <= rain_h {
              has_rain_influence = true
            }
          }
        }
      }
      if has_rain_influence {
        next[i] = Clear
      }
    } else if next[i] == Rainy {
      // Check if any sun source would also affect this tile
      let mut has_sun_influence = false
      for si in 0..<sources.length() {
        if sources[si].kind == Sun {
          let sc2 = sources[si].col
          let sr2 = sources[si].row
          let dist_c = if sc2 > c { sc2 - c } else { c - sc2 }
          let dist_r = if sr2 > r { sr2 - r } else { r - sr2 }
          if (dist_c + dist_r) <= 1 {
            // Check not blocked by cloud
            let ni2 = @types.grid_index(c, r, w)
            if next[ni2] != Cloudy {
              has_sun_influence = true
            }
          }
        }
      }
      if has_sun_influence {
        next[i] = Clear
      }
    }
  }
  // Apply the new states
  for i in 0..<grid.tiles.length() {
    grid.tiles[i].weather = next[i]
  }
}
