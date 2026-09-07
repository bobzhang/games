///|
/// Run the full deterministic toppling simulation.
/// Takes an array of dominoes (with starter already set to Toppling at tick 0).
/// Returns the array of topple events and the final tick count.
pub fn simulate(
  dominoes : Array[@types.Domino],
) -> (Array[@types.ToppleEvent], Int) {
  let events : Array[@types.ToppleEvent] = []
  // Find the starter and begin it toppling
  for i in 0..<dominoes.length() {
    if dominoes[i].is_starter && dominoes[i].state == Standing {
      dominoes[i].state = Toppling
      dominoes[i].topple_tick = 0
      events.push({ pos: dominoes[i].pos, tick: 0, kind: dominoes[i].kind, })
    }
  }
  let mut current_tick = 0
  let mut changed = true
  while changed && current_tick < @types.max_ticks {
    changed = false
    current_tick += 1
    // Process all dominoes that started toppling at the previous tick
    let process_tick = current_tick - 1
    for i in 0..<dominoes.length() {
      let d = dominoes[i]
      if d.state == Toppling && d.topple_tick == process_tick {
        // Handle delay: if this is a delay domino, it waits extra ticks
        if d.kind == Delay && d.delay_remaining > 0 {
          // Move it to trigger later
          d.topple_tick = process_tick + 1
          d.delay_remaining -= 1
          changed = true
          continue
        }
        // Determine which neighbors to trigger
        match d.kind {
          Normal | Heavy | Delay => {
            let range = @types.kind_range(d.kind)
            trigger_in_direction(
              dominoes,
              d.pos,
              d.orientation,
              range,
              current_tick,
              events,
            )
          }
          Splitter => {
            let (perp1, perp2) = @types.perpendicular_orientations(
              d.orientation,
            )
            trigger_in_direction(
              dominoes,
              d.pos,
              perp1,
              1,
              current_tick,
              events,
            )
            trigger_in_direction(
              dominoes,
              d.pos,
              perp2,
              1,
              current_tick,
              events,
            )
          }
        }
        // Mark this domino as fallen
        d.state = Fallen
        changed = true
      }
    }
    // Also check if any domino is still toppling (with delays)
    if !changed {
      for i in 0..<dominoes.length() {
        if dominoes[i].state == Toppling {
          changed = true
          break
        }
      }
    }
  }
  // Mark any remaining toppling dominoes as fallen
  for i in 0..<dominoes.length() {
    if dominoes[i].state == Toppling {
      dominoes[i].state = Fallen
    }
  }
  (events, current_tick)
}

///|
fn trigger_in_direction(
  dominoes : Array[@types.Domino],
  from : @types.Vec2i,
  orientation : @types.Orientation,
  range : Int,
  tick : Int,
  events : Array[@types.ToppleEvent],
) -> Unit {
  let dx = @types.orientation_dx(orientation)
  let dy = @types.orientation_dy(orientation)
  for r in 1..<=range {
    let nx = from.x + dx * r
    let ny = from.y + dy * r
    if !@types.in_grid(nx, ny) {
      continue
    }
    let target_pos = @types.vec2i(nx, ny)
    let idx = @types.find_domino_at(dominoes, target_pos)
    if idx >= 0 {
      let target = dominoes[idx]
      if target.state == Standing {
        target.state = Toppling
        target.topple_tick = tick
        if target.kind == Delay {
          target.delay_remaining = 2
        }
        events.push({ pos: target.pos, tick, kind: target.kind, })
        // Only topple the first domino found in this direction
        return
      }
    }
  }
}

///|
/// Check if all target dominoes have been knocked down
pub fn all_targets_fallen(dominoes : Array[@types.Domino]) -> Bool {
  for i in 0..<dominoes.length() {
    if dominoes[i].is_target && dominoes[i].state != Fallen {
      return false
    }
  }
  true
}

///|
/// Count the number of player-placed (non-target, non-starter) dominoes
pub fn count_placed(dominoes : Array[@types.Domino]) -> Int {
  let mut count = 0
  for i in 0..<dominoes.length() {
    if !dominoes[i].is_target && !dominoes[i].is_starter {
      count += 1
    }
  }
  count
}

///|
/// Calculate star rating
pub fn calculate_stars(
  all_hit : Bool,
  dominoes_used : Int,
  ticks_taken : Int,
  par_count : Int,
  par_ticks : Int,
) -> Int {
  if !all_hit {
    return 0
  }
  let mut stars = 1
  if dominoes_used <= par_count {
    stars = 2
  }
  if dominoes_used <= par_count && ticks_taken <= par_ticks {
    stars = 3
  }
  stars
}
