///|
/// Converts grid coordinates to a flat map array index.
fn idx(x : Int, y : Int) -> Int {
  y * @types.grid_w + x
}

///|
/// Returns true if `(x, y)` is within the grid dimensions.
fn in_bounds(x : Int, y : Int) -> Bool {
  x >= 0 && x < @types.grid_w && y >= 0 && y < @types.grid_h
}

///|
/// Returns the tile type at `(x, y)`, returning `tile_wall` for out-of-bounds coordinates.
fn @types.Game::tile_at(game : @types.Game, x : Int, y : Int) -> @types.Tile {
  if not(in_bounds(x, y)) {
    Wall
  } else {
    game.map[idx(x, y)]
  }
}

///|
/// Writes tile type `t` into the map at `(x, y)`, ignoring out-of-bounds coordinates.
fn @types.Game::set_tile(game : @types.Game, x : Int, y : Int, t : @types.Tile) -> Unit {
  if not(in_bounds(x, y)) {
    return
  }
  game.map[idx(x, y)] = t
}

///|
/// Sets the HUD status message with a display duration of `ttl` seconds.
fn @types.Game::set_msg(game : @types.Game, msg : String, ttl : Float) -> Unit {
  game.msg = msg
  game.msg_t = ttl
}

///|
/// Instantly places actor `a` at tile `(x, y)`, clearing all interpolation state.
fn actor_place(a : @types.Actor, x : Int, y : Int) -> Unit {
  a.x = x
  a.y = y
  a.from_x = x
  a.from_y = y
  a.to_x = x
  a.to_y = y
  a.fx = Float::from_int(x)
  a.fy = Float::from_int(y)
  a.t = 1.0
  a.moving = false
}

///|
/// Begins smooth movement of actor `a` toward tile `(tx, ty)`, resetting the interpolation counter.
fn actor_start_move(a : @types.Actor, tx : Int, ty : Int) -> Unit {
  if a.x == tx && a.y == ty {
    return
  }

  a.from_x = a.x
  a.from_y = a.y
  a.to_x = tx
  a.to_y = ty
  a.t = 0.0
  a.moving = true
}

///|
/// Advances the actor's interpolated float position each frame, committing tile coordinates when `t` reaches 1.0.
fn actor_tick(a : @types.Actor, dt : Float, move_t : Float) -> Unit {
  if not(a.moving) {
    a.fx = Float::from_int(a.x)
    a.fy = Float::from_int(a.y)
    return
  }

  a.t = a.t + dt / move_t
  if a.t >= 1.0 {
    a.t = 1.0
    a.x = a.to_x
    a.y = a.to_y
    a.fx = Float::from_int(a.x)
    a.fy = Float::from_int(a.y)
    a.moving = false
    return
  }

  a.fx = @types.lerpf(Float::from_int(a.from_x), Float::from_int(a.to_x), a.t)
  a.fy = @types.lerpf(Float::from_int(a.from_y), Float::from_int(a.to_y), a.t)
}

///|
/// Deactivates and resets all particles in the pool.
fn @types.Game::clear_particles(game : @types.Game) -> Unit {
  for particle in game.particles {
    particle.active = false
    particle.x = 0.0
    particle.y = 0.0
    particle.vx = 0.0
    particle.vy = 0.0
    particle.life = 0.0
    particle.size = 0.0
    particle.kind = 0
  }
}

///|
/// Activates the first free slot in the particle pool with the given position, velocity, lifetime, size, and kind.
fn @types.Game::emit_particle(
  game : @types.Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  kind : Int,
) -> Unit {
  for particle in game.particles {
    if particle.active {
      continue
    }

    particle.active = true
    particle.x = x
    particle.y = y
    particle.vx = vx
    particle.vy = vy
    particle.life = life
    particle.size = size
    particle.kind = kind
    break
  }
}

///|
/// Emits `n` particles of the given kind around pixel position `(x, y)` with random velocities.
fn @types.Game::burst(
  game : @types.Game,
  x : Float,
  y : Float,
  n : Int,
  kind : Int,
) -> Unit {
  for _i in 0..<n {
    game.emit_particle(
      x + @types.randf(-10.0, 10.0),
      y + @types.randf(-10.0, 10.0),
      @types.randf(-170.0, 170.0),
      @types.randf(-150.0, 110.0),
      @types.randf(0.20, 1.0),
      @types.randf(1.4, 5.0),
      kind,
    )
  }
}

///|
/// Advances all active particles by `dt`, applying drag and gravity, and deactivates expired ones.
fn @types.Game::update_particles(game : @types.Game, dt : Float) -> Unit {
  for particle in game.particles {
    if not(particle.active) {
      continue
    }

    particle.life = particle.life - dt
    if particle.life <= 0.0 {
      particle.active = false
      continue
    }

    particle.x = particle.x + particle.vx * dt
    particle.y = particle.y + particle.vy * dt

    let drag : Float = if particle.kind == 2 { 2.8 } else { 2.1 }
    particle.vx = particle.vx * (1.0 - drag * dt)
    particle.vy = particle.vy * (1.0 - (drag - 0.4) * dt) +
      dt * (if particle.kind == 1 { 84.0 } else { 118.0 })
  }
}

///|
/// Returns true if any active flare is within Manhattan distance 2 of `(x, y)`, hiding the player from drone detection.
fn @types.Game::flare_cover_at(game : @types.Game, x : Int, y : Int) -> Bool {
  for flare in game.flares {
    if not(flare.active) {
      continue
    }

    let d : Int = @types.manhattan(x, y, flare.x, flare.y)
    if d <= 2 {
      return true
    }
  }

  false
}

///|
/// Returns the index of the active core at tile `(x, y)`, or -1 if none present.
fn @types.Game::core_index_at(game : @types.Game, x : Int, y : Int) -> Int {
  for i in 0..<game.cores.length() {
    if not(game.cores[i].active) {
      continue
    }

    if game.cores[i].x == x && game.cores[i].y == y {
      return i
    }
  }

  -1
}

///|
/// Returns the index of an active drone occupying tile `(x, y)`, skipping drone index `skip`, or -1 if none.
fn @types.Game::drone_index_at(
  game : @types.Game,
  x : Int,
  y : Int,
  skip : Int,
) -> Int {
  for i in 0..<game.drones.length() {
    if i == skip || not(game.drones[i].active) {
      continue
    }

    if game.drones[i].body.x == x && game.drones[i].body.y == y {
      return i
    }
  }

  -1
}

///|
/// Generates the facility map with perimeter walls, corridor wall columns and rows, extra wall blocks, exit tile, and start tile.
fn @types.Game::build_map(game : @types.Game) -> Unit {
  for y in 0..<@types.grid_h {
    for x in 0..<@types.grid_w {
      if x == 0 || y == 0 || x == @types.grid_w - 1 || y == @types.grid_h - 1 {
        game.set_tile(x, y, Wall)
      } else {
        game.set_tile(x, y, Floor)
      }
    }
  }

  for x = 3; x < @types.grid_w - 2; x = x + 4 {
    for y in 1..<(@types.grid_h - 1) {
      let keep_gap : Bool = y == 2 || y == 6 || y == 10
      if not(keep_gap) {
        game.set_tile(x, y, Wall)
      }
    }
  }

  for y = 3; y < @types.grid_h - 2; y = y + 4 {
    for x in 2..<(@types.grid_w - 2) {
      let keep_gap : Bool = x == 5 || x == 9 || x == 13 || x == 17
      if not(keep_gap) {
        game.set_tile(x, y, Wall)
      }
    }
  }

  let extra_walls : Array[(Int, Int)] = [
    (20, 2),
    (20, 3),
    (20, 4),
    (20, 5),
    (19, 5),
    (18, 5),
    (17, 5),
    (16, 5),
    (15, 5),
    (14, 5),
    (14, 4),
    (14, 3),
  ]

  for extra_wall in extra_walls {
    game.set_tile(extra_wall.0, extra_wall.1, Wall)
  }

  game.set_tile(@types.exit_x, @types.exit_y, Exit)
  game.set_tile(@types.start_x, @types.start_y, Floor)
}

///|
/// Places eight energy cores at their fixed tile positions and activates them in the pool.
fn @types.Game::init_cores(game : @types.Game) -> Unit {
  let plan : Array[(Int, Int, Int)] = [
    (5, 11, 0),
    (8, 9, 1),
    (12, 7, 2),
    (16, 10, 0),
    (18, 8, 1),
    (6, 5, 2),
    (10, 3, 0),
    (17, 2, 1),
  ]

  for i in 0..<game.cores.length() {
    game.cores[i].active = i < plan.length()
    if game.cores[i].active {
      game.cores[i].x = plan[i].0
      game.cores[i].y = plan[i].1
      game.cores[i].kind = plan[i].2
    } else {
      game.cores[i].x = 0
      game.cores[i].y = 0
      game.cores[i].kind = 0
    }
  }
}

///|
/// Places five patrol drones at their fixed starting tiles with individual patrol ranges and colors.
fn @types.Game::init_drones(game : @types.Game) -> Unit {
  let plan : Array[(Int, Int, Int, Int, Int, Int, Int)] = [
    (6, 2, 1, 0, 5, 9, 0),
    (10, 6, 0, 1, 4, 10, 1),
    (14, 10, 1, 0, 13, 18, 2),
    (18, 6, 0, 1, 2, 10, 0),
    (8, 10, 1, 0, 5, 12, 1),
  ]

  for i in 0..<game.drones.length() {
    game.drones[i].active = i < plan.length()
    game.drones[i].mode = Patrol
    game.drones[i].move_cd = @types.randf(0.04, 0.30)
    game.drones[i].stun_t = 0.0
    game.drones[i].seed = 151 + i * 241
    game.drones[i].alert_t = 0.0

    if game.drones[i].active {
      actor_place(game.drones[i].body, plan[i].0, plan[i].1)
      game.drones[i].dir_x = plan[i].2
      game.drones[i].dir_y = plan[i].3
      game.drones[i].patrol_min = plan[i].4
      game.drones[i].patrol_max = plan[i].5
      game.drones[i].color_id = plan[i].6
    } else {
      actor_place(game.drones[i].body, 0, 0)
      game.drones[i].dir_x = 1
      game.drones[i].dir_y = 0
      game.drones[i].patrol_min = 0
      game.drones[i].patrol_max = 0
      game.drones[i].color_id = 0
    }
  }
}

///|
/// Deactivates all flare entries in the pool.
fn @types.Game::clear_flares(game : @types.Game) -> Unit {
  for flare in game.flares {
    flare.active = false
    flare.x = 0
    flare.y = 0
    flare.t = 0.0
  }
}

///|
/// Resets the entire game state, rebuilds the map, places all entities, and transitions to the play state.
fn @types.Game::start_run(game : @types.Game) -> Unit {
  game.build_map()
  game.init_cores()
  game.init_drones()
  game.clear_flares()
  game.clear_particles()

  actor_place(game.player, @types.start_x, @types.start_y)

  game.state = Play
  game.win = false
  game.loss_reason = ""

  game.lives = @types.max_lives
  game.score = 0
  game.cores_taken = 0
  game.portal_on = false
  game.time_left = @types.round_time_limit

  game.req_dx = 0
  game.req_dy = 0
  game.action_down = false
  game.action_pressed = false

  game.move_cd = 0.0
  game.action_cd = 0.0
  game.flare_energy = 100.0
  game.teleport_cd = 0.0
  game.touch_cd = 0.0

  game.msg = ""
  game.msg_t = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0

  game.time_s = 0.0
  game.hint_i = 0

  game.set_msg("Collect 6 cores to restore portal and unlock exit.", 2.6)
}

///|
/// Transitions to the title screen and clears transient input and effect state.
fn @types.Game::go_title(game : @types.Game) -> Unit {
  game.state = Title
  game.req_dx = 0
  game.req_dy = 0
  game.action_down = false
  game.action_pressed = false
  game.touch_cd = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0
}

///|
/// Ends the current run, records win/loss outcome, applies score bonuses, and transitions to the result screen.
fn @types.Game::finish_run(
  game : @types.Game,
  win : Bool,
  reason : String,
) -> Unit {
  if game.state != Play {
    return
  }

  game.state = Result
  game.win = win
  game.loss_reason = reason
  game.req_dx = 0
  game.req_dy = 0
  game.action_pressed = false

  if win {
    game.score = game.score + @types.score_win + game.lives * 140
    game.set_msg("Blackout escaped. Portal network secured.", 3.0)
    game.burst(
      Float::from_int(@types.cell_center_x(Float::from_int(@types.exit_x))),
      Float::from_int(@types.cell_center_y(Float::from_int(@types.exit_y))),
      72,
      1,
    )
  } else {
    game.set_msg("Escape failed.", 2.6)
  }

  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
/// Advances the hint index and displays the next rotating hint message in the HUD.
fn @types.Game::cycle_hint(game : @types.Game) -> Unit {
  game.hint_i = (game.hint_i + 1) % 4
  game.set_msg(@types.hint_text(game.hint_i), 2.8)
}

///|
/// Returns true if tile `(x, y)` is a wall or a locked exit (exit tile when portal is offline).
fn @types.Game::blocked_by_map(game : @types.Game, x : Int, y : Int) -> Bool {
  if not(in_bounds(x, y)) {
    return true
  }

  let t = game.tile_at(x, y)
  if t == Wall {
    return true
  }

  t == Exit && not(game.portal_on)
}

///|
/// Returns true if the given tile is impassable for the player (currently delegates to `blocked_by_map`).
fn @types.Game::blocked_for_actor(game : @types.Game, x : Int, y : Int) -> Bool {
  if game.blocked_by_map(x, y) {
    return true
  }

  false
}

///|
/// Attempts to move the player one tile in direction `(dx, dy)`, returning true if the move was accepted.
fn @types.Game::try_move_player(game : @types.Game, dx : Int, dy : Int) -> Bool {
  if dx == 0 && dy == 0 {
    return false
  }
  if game.player.moving {
    return false
  }

  let tx : Int = game.player.x + dx
  let ty : Int = game.player.y + dy

  if game.blocked_for_actor(tx, ty) {
    return false
  }

  actor_start_move(game.player, tx, ty)
  game.move_cd = 0.02

  true
}

///|
/// Collects the energy core at the player's current tile, adds score, and activates the portal network once 6 cores are gathered.
fn @types.Game::collect_core(game : @types.Game) -> Unit {
  if game.player.moving {
    return
  }

  let i : Int = game.core_index_at(game.player.x, game.player.y)
  if i < 0 {
    return
  }

  game.cores[i].active = false
  game.cores_taken = game.cores_taken + 1
  game.score = game.score + @types.score_core
  game.flash_t = 0.20

  game.set_msg(
    "Energy core " +
    game.cores_taken.to_string() +
    "/" +
    @types.core_need.to_string(),
    1.6,
  )

  game.burst(
    Float::from_int(@types.cell_center_x(game.player.fx)),
    Float::from_int(@types.cell_center_y(game.player.fy)),
    22,
    1,
  )

  if game.cores_taken >= @types.core_need && not(game.portal_on) {
    game.portal_on = true
    game.score = game.score + 260
    game.shake_t = 0.34

    game.set_msg("Portal online. Reach exit gate.", 2.6)

    game.burst(
      Float::from_int(@types.cell_center_x(Float::from_int(@types.portal_ax))),
      Float::from_int(@types.cell_center_y(Float::from_int(@types.portal_ay))),
      30,
      2,
    )
    game.burst(
      Float::from_int(@types.cell_center_x(Float::from_int(@types.portal_bx))),
      Float::from_int(@types.cell_center_y(Float::from_int(@types.portal_by))),
      30,
      2,
    )
  }
}

///|
/// Returns true if there is an unobstructed horizontal or vertical line of sight between `(x0, y0)` and `(x1, y1)`.
fn @types.Game::line_of_sight(
  game : @types.Game,
  x0 : Int,
  y0 : Int,
  x1 : Int,
  y1 : Int,
) -> Bool {
  if x0 == x1 {
    let y_min : Int = y0.min(y1)
    let y_max : Int = y0.max(y1)

    for y in (y_min + 1)..<y_max {
      if game.tile_at(x0, y) == Wall {
        return false
      }
    }

    return true
  }

  if y0 == y1 {
    let x_min : Int = x0.min(x1)
    let x_max : Int = x0.max(x1)

    for x in (x_min + 1)..<x_max {
      if game.tile_at(x, y0) == Wall {
        return false
      }
    }

    return true
  }

  false
}

///|
/// Advances a drone's LCG pseudo-random seed and returns the next value (always positive).
fn drone_seed_next(seed : Int) -> Int {
  let n : Int = (seed * 48271 + 97) % 2147483647
  if n <= 0 {
    1
  } else {
    n
  }
}

///|
/// Returns true if tile `(x, y)` is impassable for drone `gid` (wall, locked exit, or occupied by another drone).
fn @types.Game::blocked_for_drone(
  game : @types.Game,
  gid : Int,
  x : Int,
  y : Int,
) -> Bool {
  if game.blocked_by_map(x, y) {
    return true
  }

  let g2 : Int = game.drone_index_at(x, y, gid)
  g2 >= 0
}

///|
/// Determines the next movement step for drone `i`: hunts toward the player when in range or line-of-sight, otherwise bounces along its patrol axis.
fn @types.Game::choose_drone_step(game : @types.Game, i : Int) -> (Int, Int) {
  let d = game.drones[i]
  let gx : Int = d.body.x
  let gy : Int = d.body.y
  let px : Int = game.player.x
  let py : Int = game.player.y

  let dist : Int = @types.manhattan(gx, gy, px, py)
  let sees : Bool = game.line_of_sight(gx, gy, px, py)
  let flare_cover : Bool = game.flare_cover_at(px, py)

  if dist <= 3 || (sees && dist <= 7 && not(flare_cover)) {
    d.mode = Hunt
    d.alert_t = 1.2
  } else {
    d.alert_t = d.alert_t - 0.16
    if d.alert_t <= 0.0 {
      d.mode = Patrol
    }
  }

  let dirs : Array[(Int, Int)] = [(-1, 0), (1, 0), (0, -1), (0, 1)]

  if d.mode == Hunt {
    let mut best_k : Int = -1
    let mut best_d : Int = 999999

    for k in 0..<4 {
      let nx : Int = gx + dirs[k].0
      let ny : Int = gy + dirs[k].1
      if game.blocked_for_drone(i, nx, ny) {
        continue
      }

      let dd : Int = @types.manhattan(nx, ny, px, py)
      if dd < best_d {
        best_d = dd
        best_k = k
      }
    }

    if best_k >= 0 {
      return dirs[best_k]
    }
  }

  if d.dir_x != 0 {
    let mut nx : Int = gx + d.dir_x
    if nx < d.patrol_min ||
      nx > d.patrol_max ||
      game.blocked_for_drone(i, nx, gy) {
      d.dir_x = -d.dir_x
      nx = gx + d.dir_x
    }

    if nx >= d.patrol_min &&
      nx <= d.patrol_max &&
      not(game.blocked_for_drone(i, nx, gy)) {
      return (d.dir_x, 0)
    }
  }

  if d.dir_y != 0 {
    let mut ny : Int = gy + d.dir_y
    if ny < d.patrol_min ||
      ny > d.patrol_max ||
      game.blocked_for_drone(i, gx, ny) {
      d.dir_y = -d.dir_y
      ny = gy + d.dir_y
    }

    if ny >= d.patrol_min &&
      ny <= d.patrol_max &&
      not(game.blocked_for_drone(i, gx, ny)) {
      return (0, d.dir_y)
    }
  }

  d.seed = drone_seed_next(d.seed)
  let start : Int = d.seed % 4

  for t in 0..<4 {
    let k : Int = (start + t) % 4
    let nx : Int = gx + dirs[k].0
    let ny : Int = gy + dirs[k].1
    if game.blocked_for_drone(i, nx, ny) {
      continue
    }

    return dirs[k]
  }

  (0, 0)
}

///|
/// Ticks all active drones each frame: advances interpolation, drains stun timers, and issues movement steps when cooldown expires.
fn @types.Game::update_drones(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.drones.length() {
    if not(game.drones[i].active) {
      continue
    }

    actor_tick(game.drones[i].body, dt, @types.drone_move_t)

    if game.drones[i].mode == Stunned {
      game.drones[i].stun_t = game.drones[i].stun_t - dt
      if game.drones[i].stun_t <= 0.0 {
        game.drones[i].mode = Patrol
        game.drones[i].stun_t = 0.0
      }
    }

    if game.drones[i].alert_t > 0.0 {
      game.drones[i].alert_t = game.drones[i].alert_t - dt
    }

    if game.drones[i].body.moving {
      continue
    }

    game.drones[i].move_cd = game.drones[i].move_cd - dt
    if game.drones[i].move_cd > 0.0 {
      continue
    }

    if game.drones[i].mode == Stunned {
      game.drones[i].move_cd = 0.14
      continue
    }

    let step = game.choose_drone_step(i)
    if step.0 != 0 || step.1 != 0 {
      actor_start_move(
        game.drones[i].body,
        game.drones[i].body.x + step.0,
        game.drones[i].body.y + step.1,
      )
    }

    game.drones[i].move_cd = @types.drone_move_t * @types.randf(0.80, 1.20)
  }
}

///|
/// Counts down flare lifetimes each frame and emits smoke particles; deactivates flares whose time has expired.
fn @types.Game::update_flares(game : @types.Game, dt : Float) -> Unit {
  for flare in game.flares {
    if not(flare.active) {
      continue
    }

    flare.t = flare.t - dt
    if flare.t <= 0.0 {
      flare.active = false
      continue
    }

    if @raylib.get_random_value(0, 4) == 0 {
      game.emit_particle(
        Float::from_int(@types.cell_center_x(Float::from_int(flare.x))) +
        @types.randf(-16.0, 16.0),
        Float::from_int(@types.cell_center_y(Float::from_int(flare.y))) +
        @types.randf(-16.0, 16.0),
        @types.randf(-20.0, 20.0),
        @types.randf(-28.0, -8.0),
        @types.randf(0.3, 0.9),
        @types.randf(4.0, 9.0),
        2,
      )
    }
  }
}

///|
/// Deploys a flare at the player's current tile, consuming energy, stunning nearby drones, and emitting a burst of particles.
fn @types.Game::deploy_flare(game : @types.Game) -> Bool {
  if game.action_cd > 0.0 || game.flare_energy < @types.flare_cost {
    return false
  }

  let mut slot : Int = -1
  for i in 0..<game.flares.length() {
    if not(game.flares[i].active) {
      slot = i
      break
    }
  }

  if slot < 0 {
    return false
  }

  game.flares[slot].active = true
  game.flares[slot].x = game.player.x
  game.flares[slot].y = game.player.y
  game.flares[slot].t = @types.flare_ttl

  game.flare_energy = @types.clampf(
    game.flare_energy - @types.flare_cost,
    0.0,
    100.0,
  )
  game.action_cd = 0.34

  let mut stunned : Int = 0
  for drone in game.drones {
    if not(drone.active) || drone.mode == Stunned {
      continue
    }

    let d : Int = @types.manhattan(
      game.player.x,
      game.player.y,
      drone.body.x,
      drone.body.y,
    )

    if d <= 2 {
      drone.mode = Stunned
      drone.stun_t = @types.flare_stun_t
      drone.move_cd = 0.14
      stunned = stunned + 1
    }
  }

  if stunned > 0 {
    game.score = game.score + stunned * @types.score_stun
    game.set_msg("Flare stunned " + stunned.to_string() + " drone(s).", 1.5)
  } else {
    game.set_msg("Flare deployed.", 1.2)
  }

  game.burst(
    Float::from_int(@types.cell_center_x(game.player.fx)),
    Float::from_int(@types.cell_center_y(game.player.fy)),
    34,
    2,
  )

  true
}

///|
/// Teleports the player between portal A and B if standing on one and the portal is active; returns true on success.
fn @types.Game::try_portal(game : @types.Game) -> Bool {
  if not(game.portal_on) || game.teleport_cd > 0.0 {
    return false
  }

  if game.player.x == @types.portal_ax && game.player.y == @types.portal_ay {
    actor_place(game.player, @types.portal_bx, @types.portal_by)
  } else if game.player.x == @types.portal_bx &&
    game.player.y == @types.portal_by {
    actor_place(game.player, @types.portal_ax, @types.portal_ay)
  } else {
    return false
  }

  game.teleport_cd = 0.50
  game.action_cd = 0.22
  game.score = game.score + @types.score_teleport

  game.set_msg("Portal jump.", 1.0)

  game.burst(
    Float::from_int(@types.cell_center_x(game.player.fx)),
    Float::from_int(@types.cell_center_y(game.player.fy)),
    30,
    1,
  )

  true
}

///|
/// Checks if a non-stunned drone shares the player's tile, reduces lives, triggers flash and shake effects, and ends the run on last life.
fn @types.Game::handle_player_hit(game : @types.Game) -> Unit {
  if game.flash_t > 0.0 {
    return
  }

  for drone in game.drones {
    if not(drone.active) || drone.mode == Stunned {
      continue
    }

    if drone.body.x == game.player.x && drone.body.y == game.player.y {
      game.lives = game.lives - 1
      game.flash_t = 1.05
      game.shake_t = 0.28

      game.burst(
        Float::from_int(@types.cell_center_x(game.player.fx)),
        Float::from_int(@types.cell_center_y(game.player.fy)),
        34,
        2,
      )

      if game.lives <= 0 {
        game.finish_run(false, "Neutralized by blackout drones")
      } else {
        actor_place(game.player, @types.start_x, @types.start_y)
        game.move_cd = 0.24
        game.set_msg("Drone contact. Life lost.", 1.8)
      }

      break
    }
  }
}

///|
/// Decrements all per-frame timers: message display, flash, shake, movement cooldown, action cooldown, teleport cooldown, and touch debounce.
fn @types.Game::update_timers(game : @types.Game, dt : Float) -> Unit {
  if game.msg_t > 0.0 {
    game.msg_t = game.msg_t - dt
  }

  if game.flash_t > 0.0 {
    game.flash_t = game.flash_t - dt
  }

  if game.shake_t > 0.0 {
    game.shake_t = game.shake_t - dt
  }

  if game.move_cd > 0.0 {
    game.move_cd = game.move_cd - dt
  }

  if game.action_cd > 0.0 {
    game.action_cd = game.action_cd - dt
  }

  if game.teleport_cd > 0.0 {
    game.teleport_cd = game.teleport_cd - dt
  }

  if game.touch_cd > 0.0 {
    game.touch_cd = game.touch_cd - dt
  }
}

///|
/// Advances the title screen each frame: increments the animation timer and ticks timers and particles.
fn @types.Game::update_title(game : @types.Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt
  game.update_timers(dt)
  game.update_particles(dt)
}

///|
/// Advances the result screen each frame: increments the animation timer and ticks timers and particles.
fn @types.Game::update_result(game : @types.Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt
  game.update_timers(dt)
  game.update_particles(dt)
}

///|
/// Runs one gameplay frame: decrements the countdown timer, moves the player, handles action input, updates flares/drones/cores/hits/particles, and checks win/loss conditions.
fn @types.Game::update_play(game : @types.Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt
  game.time_left = game.time_left - dt

  game.update_timers(dt)

  game.flare_energy = @types.clampf(game.flare_energy + dt * 16.0, 0.0, 100.0)

  actor_tick(game.player, dt, @types.player_move_t)

  if not(game.player.moving) && game.move_cd <= 0.0 {
    ignore(game.try_move_player(game.req_dx, game.req_dy))
  }

  if game.action_pressed {
    if not(game.try_portal()) {
      ignore(game.deploy_flare())
    }
  }

  game.update_flares(dt)
  game.update_drones(dt)
  game.collect_core()
  game.handle_player_hit()
  game.update_particles(dt)

  if game.state == Play &&
    not(game.player.moving) &&
    game.portal_on &&
    game.player.x == @types.exit_x &&
    game.player.y == @types.exit_y {
    game.finish_run(true, "")
  }

  if game.state == Play && game.time_left <= 0.0 {
    game.finish_run(false, "Blackout stabilized before escape")
  }
}

///|
/// Advances one frame of blackout gameplay, input, and state transitions.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  // Process input at the start of each frame
  if game.state == Title {
    game.update_title_input()
  } else if game.state == Play {
    game.update_play_input()
  } else {
    game.update_result_input()
  }

  if game.state == Title {
    game.update_title(dt)
  } else if game.state == Play {
    game.update_play(dt)
  } else {
    game.update_result(dt)
  }

  game.action_pressed = false
}
