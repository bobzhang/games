///|
pub fn are_adjacent(c1 : @types.Component, c2 : @types.Component) -> Bool {
  let dc = @types.absf(
    Float::from_int(c1.col) - Float::from_int(c2.col),
  )
  let dr = @types.absf(
    Float::from_int(c1.row) - Float::from_int(c2.row),
  )
  (dc <= 1.0 && dr <= 1.0) && (dc + dr > 0.0)
}

///|
pub fn gears_can_mesh(
  c1 : @types.Component,
  c2 : @types.Component
) -> Bool {
  match (c1.kind, c2.kind) {
    (Gear(_), Gear(_)) => are_adjacent(c1, c2)
    _ => false
  }
}

///|
pub fn gear_mesh_ratio(
  driving : @types.Component,
  driven : @types.Component
) -> Float {
  match (driving.kind, driven.kind) {
    (Gear(s1), Gear(s2)) => {
      let t1 = Float::from_int(@types.gear_teeth(s1))
      let t2 = Float::from_int(@types.gear_teeth(s2))
      t1 / t2
    }
    _ => 1.0
  }
}

///|
pub fn build_connections(game : @types.Game) -> Unit {
  let comps = game.components
  for i in 0..<comps.length() {
    comps[i].connected_to = []
  }
  for i in 0..<comps.length() {
    if !comps[i].active {
      continue
    }
    for j = i + 1; j < comps.length(); j = j + 1 {
      if !comps[j].active {
        continue
      }
      if can_connect(comps[i], comps[j]) {
        comps[i].connected_to.push(j)
        comps[j].connected_to.push(i)
      }
    }
  }
}

///|
fn can_connect(c1 : @types.Component, c2 : @types.Component) -> Bool {
  if !are_adjacent(c1, c2) {
    return false
  }
  match (c1.kind, c2.kind) {
    (Gear(_), Gear(_)) => true
    (Gear(_), Cam) => true
    (Cam, Gear(_)) => true
    (Gear(_), Escapement) => true
    (Escapement, Gear(_)) => true
    (Cam, Bell) => true
    (Bell, Cam) => true
    (Spring, Gear(_)) => true
    (Gear(_), Spring) => true
    (Cam, Spring) => true
    (Spring, Cam) => true
    _ => false
  }
}

///|
pub fn propagate_rotation(
  game : @types.Game,
  source_idx : Int,
  speed : Float,
  clockwise : Bool,
  visited : Array[Bool]
) -> Unit {
  if source_idx < 0 || source_idx >= game.components.length() {
    return
  }
  if visited[source_idx] {
    return
  }
  visited[source_idx] = true
  let comp = game.components[source_idx]
  comp.rotation_speed = speed
  comp.clockwise = clockwise
  let conns = comp.connected_to
  for i in 0..<conns.length() {
    let neighbor_idx = conns[i]
    if visited[neighbor_idx] {
      continue
    }
    let neighbor = game.components[neighbor_idx]
    match (comp.kind, neighbor.kind) {
      (Gear(s1), Gear(s2)) => {
        let ratio = Float::from_int(@types.gear_teeth(s1)) / Float::from_int(
            @types.gear_teeth(s2),
          )
        let new_speed = speed * ratio
        propagate_rotation(game, neighbor_idx, new_speed, !clockwise, visited)
      }
      (Gear(_), Cam) =>
        propagate_rotation(game, neighbor_idx, speed, clockwise, visited)
      (Gear(_), Escapement) => {
        let esc_speed = speed * 0.5
        propagate_rotation(game, neighbor_idx, esc_speed, clockwise, visited)
      }
      (Spring, Gear(_)) => {
        if comp.spring_released {
          let spring_speed = speed * @types.spring_force
          propagate_rotation(
            game, neighbor_idx, spring_speed, clockwise, visited,
          )
        }
      }
      (Gear(_), Spring) =>
        propagate_rotation(game, neighbor_idx, speed, clockwise, visited)
      _ =>
        propagate_rotation(game, neighbor_idx, speed, clockwise, visited)
    }
  }
}

///|
pub fn init_simulation(game : @types.Game) -> Unit {
  let sim = game.sim
  @types.reset_simulation(sim)
  sim.state = Running
  // Count bells
  let mut bell_count = 0
  for i in 0..<game.components.length() {
    let c = game.components[i]
    c.rotation = 0.0
    c.rotation_speed = 0.0
    c.cam_offset = 0.0
    c.spring_released = false
    c.escapement_phase = 0.0
    c.escapement_locked = false
    c.bell_rung = false
    c.bell_ring_timer = 0.0
    match c.kind {
      Bell => bell_count += 1
      _ => ()
    }
  }
  sim.total_bells = bell_count
  build_connections(game)
  // Find driving gears (fixed gears act as power sources)
  let visited : Array[Bool] = Array::make(game.components.length(), false)
  for i in 0..<game.components.length() {
    let c = game.components[i]
    if c.active && c.fixed {
      match c.kind {
        Gear(_) => {
          if !visited[i] {
            let speed = @types.base_rotation_speed * @types.gear_speed_ratio(
                match c.kind {
                  Gear(s) => s
                  _ => Medium
                },
              )
            propagate_rotation(game, i, speed, true, visited)
          }
        }
        _ => ()
      }
    }
  }
}

///|
pub fn update_simulation(game : @types.Game, dt : Float) -> Unit {
  let sim = game.sim
  if sim.state != Running {
    return
  }
  let scaled_dt = dt * sim.speed_mult
  // Update tick timer
  sim.tick_timer = sim.tick_timer + scaled_dt
  let mut ticked = false
  if sim.tick_timer >= sim.tick_interval {
    sim.tick_timer = sim.tick_timer - sim.tick_interval
    sim.tick = sim.tick + 1
    ticked = true
  }
  // Update each component
  for i in 0..<game.components.length() {
    let c = game.components[i]
    if !c.active {
      continue
    }
    match c.kind {
      Gear(_) => update_gear(c, scaled_dt)
      Cam => update_cam(c, game, scaled_dt)
      Spring => update_spring(c, game, sim)
      Escapement => update_escapement(c, scaled_dt)
      Bell => {
        if ticked {
          check_bell_trigger(c, game, sim)
        }
        update_bell_timer(c, dt)
      }
    }
  }
  // Check completion
  check_completion(game)
}

///|
fn update_gear(c : @types.Component, dt : Float) -> Unit {
  let dir : Float = if c.clockwise { 1.0 } else { -1.0 }
  c.rotation = c.rotation + c.rotation_speed * dir * dt
  if c.rotation > @types.two_pi {
    c.rotation = c.rotation - @types.two_pi
  }
  if c.rotation < 0.0 {
    c.rotation = c.rotation + @types.two_pi
  }
}

///|
fn update_cam(
  c : @types.Component,
  _game : @types.Game,
  dt : Float
) -> Unit {
  // Cam oscillates based on rotation
  c.rotation = c.rotation + c.rotation_speed * dt
  if c.rotation > @types.two_pi {
    c.rotation = c.rotation - @types.two_pi
  }
  // Cam offset follows a sinusoidal pattern
  c.cam_offset = @types.sinf(c.rotation) * @types.cam_push_distance
}

///|
fn update_spring(
  c : @types.Component,
  _game : @types.Game,
  sim : @types.Simulation
) -> Unit {
  if !c.spring_released {
    // Accumulate energy from connected rotating gears
    if c.rotation_speed > 0.0 {
      c.spring_energy = @types.minf(c.spring_energy + 0.02, 1.0)
    }
    // Release when fully charged or when triggered by tick
    if c.spring_energy >= 1.0 {
      c.spring_released = true
    }
  } else {
    // Release energy - decrease over time
    c.spring_energy = @types.maxf(
      c.spring_energy - Float::from_int(1) / (
          @types.spring_release_speed * Float::from_int(sim.tick + 1)
        ),
      0.0,
    )
    if c.spring_energy <= 0.0 {
      c.spring_released = false
    }
  }
}

///|
fn update_escapement(c : @types.Component, dt : Float) -> Unit {
  if c.rotation_speed > 0.0 {
    c.escapement_phase = c.escapement_phase + dt * c.rotation_speed
    if c.escapement_phase >= @types.escapement_period {
      c.escapement_phase = c.escapement_phase - @types.escapement_period
      c.escapement_locked = !c.escapement_locked
    }
  }
}

///|
fn check_bell_trigger(
  bell : @types.Component,
  game : @types.Game,
  sim : @types.Simulation
) -> Unit {
  if bell.bell_rung {
    return
  }
  // Check if the bell should ring at this tick
  if sim.tick == bell.bell_target_tick {
    // Check if there's a cam adjacent that is pushing toward this bell
    let mut triggered = false
    for i in 0..<bell.connected_to.length() {
      let idx = bell.connected_to[i]
      let neighbor = game.components[idx]
      match neighbor.kind {
        Cam => {
          if @types.absf(neighbor.cam_offset) > @types.bell_trigger_distance {
            triggered = true
          }
        }
        Gear(_) => {
          if neighbor.rotation_speed > 0.0 {
            triggered = true
          }
        }
        Spring => {
          if neighbor.spring_released {
            triggered = true
          }
        }
        _ => ()
      }
    }
    if triggered {
      bell.bell_rung = true
      bell.bell_ring_timer = @types.bell_ring_duration
      sim.bells_rung.push(bell.bell_target_tick)
      sim.bells_order.push(sim.tick)
    }
  }
}

///|
fn update_bell_timer(c : @types.Component, dt : Float) -> Unit {
  if c.bell_ring_timer > 0.0 {
    c.bell_ring_timer = c.bell_ring_timer - dt
  }
}

///|
fn check_completion(game : @types.Game) -> Unit {
  let sim = game.sim
  // Check if all bells have rung
  if sim.bells_rung.length() >= sim.total_bells && sim.total_bells > 0 {
    sim.state = Complete
    return
  }
  // Check if simulation has run too long (timeout)
  let max_tick = max_target_tick(game) + 20
  if sim.tick > max_tick {
    sim.state = Failed
  }
}

///|
fn max_target_tick(game : @types.Game) -> Int {
  let mut max_t = 0
  for i in 0..<game.components.length() {
    let c = game.components[i]
    if c.active {
      match c.kind {
        Bell => {
          if c.bell_target_tick > max_t {
            max_t = c.bell_target_tick
          }
        }
        _ => ()
      }
    }
  }
  max_t
}

///|
pub fn calculate_stars(game : @types.Game) -> Int {
  let sim = game.sim
  if sim.state != Complete {
    return 0
  }
  let mut stars = 1 // All bells rang
  // Check par components
  let placed = @types.count_placed_components(game)
  if placed <= game.level_def.par_components {
    stars = 2
  }
  // Check timing order
  let targets = game.level_def.bell_targets
  if targets.length() > 0 && sim.bells_rung.length() == targets.length() {
    let mut correct_order = true
    for i in 0..<targets.length() {
      if sim.bells_rung[i] != targets[i] {
        correct_order = false
      }
    }
    if correct_order && placed <= game.level_def.par_components {
      stars = 3
    }
  }
  stars
}
