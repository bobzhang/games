///|
/// Simulate one tick of wave propagation on the grid.
/// Returns nothing - modifies grid in place.
pub fn simulate_tick(grid : @types.WaveGrid) -> Unit {
  let w = grid.width
  let h = grid.height
  // Track contributions for interference
  let contributions : Array[Array[@types.WaveFront]] = Array::new(
    capacity=w * h,
  )
  for _i in 0..<(w * h) {
    contributions.push([])
  }
  // Step 2: For each tile, propagate waves outward
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      let tile = grid.tiles[idx]
      // Emitters always generate waves at full amplitude
      match tile.object {
        Emitter(ep) => {
          // The emitter tile itself has amplitude 1.0
          contributions[idx].push({ amplitude: 1.0, phase: ep, direction: -1 })
          // Send waves to adjacent tiles
          for d in 0..<4 {
            let nx = x + @types.dir_dx(d)
            let ny = y + @types.dir_dy(d)
            if @types.grid_in_bounds(nx, ny) {
              let ni = ny * w + nx
              let ntile = grid.tiles[ni]
              if !ntile.has_wall && !is_blocking_object(ntile.object) {
                let amp : Float = 1.0 - @types.decay_rate
                contributions[ni].push({
                  amplitude: amp,
                  phase: ep,
                  direction: d,
                })
              }
            }
          }
        }
        _ => ()
      }
      // Existing wave amplitude propagates outward
      if tile.amplitude > 0.01 {
        match tile.object {
          Emitter(_) => () // emitter handled above
          Reflector =>
            // Reflector bounces wave back
            // Look at each incoming wave front and bounce it
            for wf in tile.wave_fronts {
              if wf.direction >= 0 {
                let bounce_dir = @types.opposite_dir(wf.direction)
                let nx = x + @types.dir_dx(bounce_dir)
                let ny = y + @types.dir_dy(bounce_dir)
                if @types.grid_in_bounds(nx, ny) {
                  let ni = ny * w + nx
                  let ntile = grid.tiles[ni]
                  if !ntile.has_wall && !is_blocking_object(ntile.object) {
                    let amp : Float = wf.amplitude - @types.decay_rate
                    if amp > 0.01 {
                      contributions[ni].push({
                        amplitude: amp,
                        phase: wf.phase,
                        direction: bounce_dir,
                      })
                    }
                  }
                }
              } else {
                // Omnidirectional: bounce all 4 directions
                for d in 0..<4 {
                  let nx = x + @types.dir_dx(d)
                  let ny = y + @types.dir_dy(d)
                  if @types.grid_in_bounds(nx, ny) {
                    let ni = ny * w + nx
                    let ntile = grid.tiles[ni]
                    if !ntile.has_wall && !is_blocking_object(ntile.object) {
                      let amp : Float = wf.amplitude - @types.decay_rate
                      if amp > 0.01 {
                        contributions[ni].push({
                          amplitude: amp,
                          phase: wf.phase,
                          direction: d,
                        })
                      }
                    }
                  }
                }
              }
            }
          PhaseShifter =>
            // Phase shifter: shift phase by +1 and continue
            for wf in tile.wave_fronts {
              let shifted_phase = (wf.phase + 1) % 4
              if wf.direction >= 0 {
                // Continue in same direction
                let nx = x + @types.dir_dx(wf.direction)
                let ny = y + @types.dir_dy(wf.direction)
                if @types.grid_in_bounds(nx, ny) {
                  let ni = ny * w + nx
                  let ntile = grid.tiles[ni]
                  if !ntile.has_wall && !is_blocking_object(ntile.object) {
                    let amp : Float = wf.amplitude - @types.decay_rate
                    if amp > 0.01 {
                      contributions[ni].push({
                        amplitude: amp,
                        phase: shifted_phase,
                        direction: wf.direction,
                      })
                    }
                  }
                }
              } else {
                for d in 0..<4 {
                  let nx = x + @types.dir_dx(d)
                  let ny = y + @types.dir_dy(d)
                  if @types.grid_in_bounds(nx, ny) {
                    let ni = ny * w + nx
                    let ntile = grid.tiles[ni]
                    if !ntile.has_wall && !is_blocking_object(ntile.object) {
                      let amp : Float = wf.amplitude - @types.decay_rate
                      if amp > 0.01 {
                        contributions[ni].push({
                          amplitude: amp,
                          phase: shifted_phase,
                          direction: d,
                        })
                      }
                    }
                  }
                }
              }
            }
          Absorber => () // Absorber eats waves, no propagation
          _ =>
            // Normal tile or target: propagate in all 4 directions
            for d in 0..<4 {
              let nx = x + @types.dir_dx(d)
              let ny = y + @types.dir_dy(d)
              if @types.grid_in_bounds(nx, ny) {
                let ni = ny * w + nx
                let ntile = grid.tiles[ni]
                if !ntile.has_wall && !is_blocking_object(ntile.object) {
                  let amp : Float = tile.amplitude - @types.decay_rate
                  if amp > 0.01 {
                    contributions[ni].push({
                      amplitude: amp,
                      phase: tile.phase,
                      direction: d,
                    })
                  }
                }
              }
            }
        }
      }
    }
  }
  // Step 3: Resolve interference for each tile
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      let tile = grid.tiles[idx]
      let contribs = contributions[idx]
      // Keep the wave fronts for next tick's directional info
      tile.wave_fronts = contribs
      match tile.object {
        Emitter(ep) => {
          // Emitter always has full amplitude at its own phase
          tile.amplitude = 1.0
          tile.phase = ep
        }
        Wall | Absorber => {
          tile.amplitude = 0.0
          tile.phase = 0
        }
        _ =>
          if contribs.length() == 0 {
            tile.amplitude = 0.0
            tile.phase = 0
          } else if contribs.length() == 1 {
            tile.amplitude = @types.clampf(contribs[0].amplitude, 0.0, 1.0)
            tile.phase = contribs[0].phase
          } else {
            // Interference resolution
            let result = resolve_interference(contribs)
            tile.amplitude = @types.clampf(result.0, 0.0, 1.0)
            tile.phase = result.1
          }
      }
    }
  }
}

///|
fn resolve_interference(contribs : Array[@types.WaveFront]) -> (Float, Int) {
  // Use vector addition with phase as angle
  // phase 0 = 0 deg, 1 = 90 deg, 2 = 180 deg, 3 = 270 deg
  let mut sum_x : Float = 0.0
  let mut sum_y : Float = 0.0
  for c in contribs {
    let angle : Float = Float::from_int(c.phase) * 1.5707963
    sum_x += c.amplitude * @types.cosf(angle)
    sum_y += c.amplitude * @types.sinf(angle)
  }
  let result_amp : Float = @types.clampf(
    Float::from_double(
      (sum_x.to_double() * sum_x.to_double() +
      sum_y.to_double() * sum_y.to_double()).sqrt(),
    ),
    0.0,
    1.0,
  )
  // Determine phase from angle
  let angle = Float::from_double(
    @math.atan2(sum_y.to_double(), sum_x.to_double()),
  )
  let pi : Float = 3.14159265
  let mut phase = 0
  if angle >= -pi / 4.0 && angle < pi / 4.0 {
    phase = 0
  } else if angle >= pi / 4.0 && angle < 3.0 * pi / 4.0 {
    phase = 1
  } else if angle >= 3.0 * pi / 4.0 || angle < -3.0 * pi / 4.0 {
    phase = 2
  } else {
    phase = 3
  }
  (result_amp, phase)
}

///|
fn is_blocking_object(obj : @types.TileKind) -> Bool {
  match obj {
    Absorber => true
    _ => false
  }
}
