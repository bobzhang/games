///|
/// Converts board grid coordinates to a flat row-major map index.
fn idx(x : Int, y : Int) -> Int {
  y * @types.grid_w + x
}

///|
/// Returns true when `(x, y)` is within the grid boundaries.
fn in_bounds(x : Int, y : Int) -> Bool {
  x >= 0 && x < @types.grid_w && y >= 0 && y < @types.grid_h
}

///|
/// Returns the tile kind at `(x, y)`, treating out-of-bounds positions as Wall.
fn @types.Game::tile_at(
  game : @types.Game,
  x : Int,
  y : Int,
) -> @types.TileKind {
  if !in_bounds(x, y) {
    Wall
  } else {
    game.map[idx(x, y)]
  }
}

///|
/// Writes a tile kind into the map at `(x, y)`, ignoring out-of-bounds positions.
fn @types.Game::set_tile(
  game : @types.Game,
  x : Int,
  y : Int,
  t : @types.TileKind,
) -> Unit {
  if !in_bounds(x, y) {
    return
  }
  game.map[idx(x, y)] = t
}

///|
/// Sets the on-screen message text and its display duration in seconds.
fn @types.Game::set_msg(game : @types.Game, msg : String, ttl : Float) -> Unit {
  game.msg = msg
  game.msg_t = ttl
}

///|
/// Teleports an actor to `(x, y)` instantly, resetting all interpolation state.
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
/// Begins smooth tile-to-tile movement from the actor's current position toward `(tx, ty)`.
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
/// Advances the actor's movement interpolation by `dt` seconds, snapping to the target when complete.
fn actor_tick(a : @types.Actor, dt : Float, move_t : Float) -> Unit {
  if !a.moving {
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
/// Deactivates and zeroes every particle slot in the pool.
fn @types.Game::clear_particles(game : @types.Game) -> Unit {
  for particle in game.particles {
    particle.active = false
    particle.x = 0.0
    particle.y = 0.0
    particle.vx = 0.0
    particle.vy = 0.0
    particle.life = 0.0
    particle.size = 0.0
    particle.kind = Spark
  }
}

///|
/// Spawns a single particle into the first inactive slot, initializing all physics fields.
fn @types.Game::emit_particle(
  game : @types.Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  kind : @types.ParticleKind,
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
/// Emits `n` particles of the given kind scattered randomly around pixel position `(x, y)`.
fn @types.Game::burst(
  game : @types.Game,
  x : Float,
  y : Float,
  n : Int,
  kind : @types.ParticleKind,
) -> Unit {
  for _i in 0..<n {
    game.emit_particle(
      x + @types.randf(-10.0, 10.0),
      y + @types.randf(-10.0, 10.0),
      @types.randf(-170.0, 170.0),
      @types.randf(-150.0, 110.0),
      @types.randf(0.20, 1.0),
      @types.randf(1.4, 5.2),
      kind,
    )
  }
}

///|
/// Advances all active particles by `dt` seconds, applying velocity, drag, and gravity.
fn @types.Game::update_particles(game : @types.Game, dt : Float) -> Unit {
  for particle in game.particles {
    if !particle.active {
      continue
    }

    particle.life = particle.life - dt
    if particle.life <= 0.0 {
      particle.active = false
      continue
    }

    particle.x = particle.x + particle.vx * dt
    particle.y = particle.y + particle.vy * dt

    let drag : Float = match particle.kind {
      Smoke => 2.6
      Spark | Glitter => 2.1
    }
    let gravity : Float = match particle.kind {
      Glitter => 84.0
      Spark | Smoke => 122.0
    }
    particle.vx = particle.vx * (1.0 - drag * dt)
    particle.vy = particle.vy * (1.0 - (drag - 0.5) * dt) + dt * gravity
  }
}

///|
/// Returns true if any active smoke cloud covers the cell at `(x, y)` within Manhattan distance 1.
fn @types.Game::smoke_cover_at(game : @types.Game, x : Int, y : Int) -> Bool {
  for smoke in game.smokes {
    if !smoke.active {
      continue
    }

    let d : Int = @types.manhattan(x, y, smoke.x, smoke.y)
    if d <= 1 {
      return true
    }
  }

  false
}

///|
/// Returns the index of an active guard occupying `(x, y)`, skipping guard `skip`, or -1 if none found.
fn @types.Game::guard_index_at(
  game : @types.Game,
  x : Int,
  y : Int,
  skip : Int,
) -> Int {
  for i in 0..<game.guards.length() {
    if i == skip || !game.guards[i].active {
      continue
    }

    if game.guards[i].body.x == x && game.guards[i].body.y == y {
      return i
    }
  }

  -1
}

///|
/// Returns the index of an active loot item at `(x, y)`, or -1 if none is present.
fn @types.Game::loot_index_at(game : @types.Game, x : Int, y : Int) -> Int {
  for i in 0..<game.loots.length() {
    if !game.loots[i].active {
      continue
    }

    if game.loots[i].x == x && game.loots[i].y == y {
      return i
    }
  }

  -1
}

///|
/// Returns true if the tile at `(x, y)` is impassable for the player, considering the vault-open state for the exit.
fn @types.Game::blocked_by_map(game : @types.Game, x : Int, y : Int) -> Bool {
  if !in_bounds(x, y) {
    return true
  }

  match game.tile_at(x, y) {
    Wall => true
    Exit => !game.vault_open
    Floor | Door => false
  }
}

///|
/// Returns true if the cell `(x, y)` is impassable for guard `gid`, accounting for map tiles and other guards.
fn @types.Game::blocked_for_guard(
  game : @types.Game,
  gid : Int,
  x : Int,
  y : Int,
) -> Bool {
  if game.blocked_by_map(x, y) {
    return true
  }

  let g2 : Int = game.guard_index_at(x, y, gid)
  g2 >= 0
}

///|
/// Resets the tile map to all walls then carves train-car floor layouts, corridors, crates, and the exit.
fn @types.Game::clear_map(game : @types.Game) -> Unit {
  for y in 0..<@types.grid_h {
    for x in 0..<@types.grid_w {
      game.set_tile(x, y, Wall)
    }
  }

  for car in 0..<5 {
    let x0 : Int = 1 + car * 5
    let x1 : Int = x0 + 3

    for y in 2..<=10 {
      for x in x0..<=x1 {
        game.set_tile(x, y, Floor)
      }
    }
  }

  for car in 0..<4 {
    let door_x : Int = 5 + car * 5
    game.set_tile(door_x, 6, Door)
    game.set_tile(door_x, 5, Floor)
    game.set_tile(door_x, 7, Floor)
  }

  let crate_cells : Array[(Int, Int)] = [
    (2, 4),
    (3, 8),
    (7, 3),
    (8, 9),
    (12, 4),
    (13, 8),
    (17, 3),
    (18, 9),
    (22, 4),
    (23, 8),
    (11, 6),
    (16, 6),
  ]

  for crate_cell in crate_cells {
    game.set_tile(crate_cell.0, crate_cell.1, Wall)
  }

  game.set_tile(@types.start_x, @types.start_y, Floor)
  game.set_tile(@types.exit_x, @types.exit_y, Exit)
}

///|
/// Returns the score value associated with a particular loot kind.
fn loot_score(kind : @types.LootKind) -> Int {
  match kind {
    Blueprint => @types.score_blueprint
    Keycard => @types.score_keycard
    Gold => @types.score_gold
  }
}

///|
/// Places loot items on the map according to the predefined loot layout plan.
fn @types.Game::load_loot(game : @types.Game) -> Unit {
  let loot_plan : Array[(Int, Int, @types.LootKind)] = [
    (3, 3, Blueprint),
    (8, 8, Gold),
    (12, 6, Keycard),
    (13, 3, Gold),
    (17, 7, Keycard),
    (22, 6, Blueprint),
    (23, 9, Gold),
    (7, 6, Gold),
  ]

  for i in 0..<game.loots.length() {
    if i < loot_plan.length() {
      game.loots[i].active = true
      game.loots[i].x = loot_plan[i].0
      game.loots[i].y = loot_plan[i].1
      game.loots[i].kind = loot_plan[i].2
      game.loots[i].value = loot_score(loot_plan[i].2)
    } else {
      game.loots[i].active = false
      game.loots[i].x = 0
      game.loots[i].y = 0
      game.loots[i].kind = Gold
      game.loots[i].value = 0
    }
  }
}

///|
/// Initializes all guard entities from the predefined patrol plan, positioning and seeding each one.
fn @types.Game::load_guards(game : @types.Game) -> Unit {
  let plan : Array[(Int, Int, Int, Int, Int, Int, Int)] = [
    (6, 6, 1, 0, 6, 9, 0),
    (12, 4, 1, 0, 11, 14, 1),
    (17, 8, 1, 0, 16, 19, 2),
    (20, 4, 0, 1, 4, 9, 3),
    (22, 6, 1, 0, 21, 24, 0),
    (3, 8, 1, 0, 1, 4, 1),
  ]

  for i in 0..<game.guards.length() {
    game.guards[i].active = i < plan.length()
    game.guards[i].mode = Patrol
    game.guards[i].move_cd = @types.randf(0.02, 0.25)
    game.guards[i].stun_t = 0.0
    game.guards[i].seed = 101 + i * 269
    game.guards[i].alert_t = 0.0

    if game.guards[i].active {
      let px : Int = plan[i].0
      let py : Int = plan[i].1
      actor_place(game.guards[i].body, px, py)

      game.guards[i].dir_x = plan[i].2
      game.guards[i].dir_y = plan[i].3
      game.guards[i].patrol_min = plan[i].4
      game.guards[i].patrol_max = plan[i].5
      game.guards[i].color_id = plan[i].6
    } else {
      actor_place(game.guards[i].body, 0, 0)
      game.guards[i].dir_x = 1
      game.guards[i].dir_y = 0
      game.guards[i].patrol_min = 0
      game.guards[i].patrol_max = 0
      game.guards[i].color_id = 0
    }
  }
}

///|
/// Resets all run state, builds the map, places loot and guards, and transitions to the Play state.
fn @types.Game::start_run(game : @types.Game) -> Unit {
  game.clear_map()
  game.load_loot()
  game.load_guards()
  game.clear_particles()

  for smoke in game.smokes {
    smoke.active = false
    smoke.x = 0
    smoke.y = 0
    smoke.t = 0.0
  }

  actor_place(game.player, @types.start_x, @types.start_y)

  game.state = Play
  game.win = false
  game.loss_reason = ""

  game.lives = 3
  game.score = 0
  game.loot_taken = 0
  game.vault_open = false
  game.time_left = @types.run_time_limit

  game.req_dx = 0
  game.req_dy = 0
  game.action_down = false
  game.action_pressed = false

  game.move_cd = 0.0
  game.action_cd = 0.0
  game.smoke_energy = 100.0
  game.touch_cd = 0.0

  game.msg = ""
  game.msg_t = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0

  game.time_s = 0.0
  game.hint_i = 0

  game.set_msg("Steal 6 loot pieces, unlock cable, escape right.", 2.6)
}

///|
/// Transitions to the Title state, resetting input and transient visual effects.
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
/// Ends the current run, recording win/loss and reason, updating the best score, and emitting a particle burst.
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
    game.score = game.score + @types.score_escape + game.lives * 120
    game.set_msg("Heist complete. The clockwork train is yours.", 3.0)
    game.burst(
      Float::from_int(@types.cell_center_x(Float::from_int(@types.exit_x))),
      Float::from_int(@types.cell_center_y(Float::from_int(@types.exit_y))),
      72,
      Glitter,
    )
  } else {
    game.set_msg("Heist failed. Railway security locked down.", 2.8)
    game.burst(
      Float::from_int(@types.cell_center_x(game.player.fx)),
      Float::from_int(@types.cell_center_y(game.player.fy)),
      44,
      Smoke,
    )
  }

  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
/// Advances to the next hint message and displays it in the message area.
fn @types.Game::cycle_hint(game : @types.Game) -> Unit {
  game.hint_i = (game.hint_i + 1) % 4
  game.set_msg(@types.hint_text(game.hint_i), 2.8)
}

///|
/// Deploys a smoke cloud at the player's position, stunning nearby guards and spending smoke energy; returns true on success.
fn @types.Game::deploy_smoke(game : @types.Game) -> Bool {
  if game.action_cd > 0.0 || game.smoke_energy < @types.smoke_cost {
    return false
  }

  let mut slot : Int = -1
  for i in 0..<game.smokes.length() {
    if !game.smokes[i].active {
      slot = i
      break
    }
  }

  if slot < 0 {
    return false
  }

  game.smokes[slot].active = true
  game.smokes[slot].x = game.player.x
  game.smokes[slot].y = game.player.y
  game.smokes[slot].t = @types.smoke_ttl

  game.smoke_energy = @types.clampf(
    game.smoke_energy - @types.smoke_cost,
    0.0,
    100.0,
  )
  game.action_cd = 0.35

  let mut stunned : Int = 0
  for guard_val in game.guards {
    if !guard_val.active || guard_val.mode == Stunned {
      continue
    }

    let d : Int = @types.manhattan(
      guard_val.body.x,
      guard_val.body.y,
      game.player.x,
      game.player.y,
    )

    if d <= 2 {
      guard_val.mode = Stunned
      guard_val.stun_t = 2.3
      guard_val.move_cd = 0.18
      stunned = stunned + 1
    }
  }

  if stunned > 0 {
    game.score = game.score + stunned * 80
    game.set_msg(
      "Smoke pulse stunned " + stunned.to_string() + " guard(s).",
      1.7,
    )
  } else {
    game.set_msg("Smoke deployed.", 1.2)
  }

  game.burst(
    Float::from_int(@types.cell_center_x(game.player.fx)),
    Float::from_int(@types.cell_center_y(game.player.fy)),
    36,
    Smoke,
  )

  true
}

///|
/// Advances all active smoke cloud timers and emits ambient smoke particles each frame.
fn @types.Game::update_smokes(game : @types.Game, dt : Float) -> Unit {
  for smoke in game.smokes {
    if !smoke.active {
      continue
    }

    smoke.t = smoke.t - dt
    if smoke.t <= 0.0 {
      smoke.active = false
      continue
    }

    if @raylib.get_random_value(0, 4) == 0 {
      game.emit_particle(
        Float::from_int(@types.cell_center_x(Float::from_int(smoke.x))) +
        @types.randf(-14.0, 14.0),
        Float::from_int(@types.cell_center_y(Float::from_int(smoke.y))) +
        @types.randf(-14.0, 14.0),
        @types.randf(-18.0, 18.0),
        @types.randf(-26.0, -8.0),
        @types.randf(0.35, 0.9),
        @types.randf(4.0, 9.0),
        Smoke,
      )
    }
  }
}

///|
/// Returns true if two axis-aligned positions share an unobstructed straight line, considering walls and smoke.
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
      let t = game.tile_at(x0, y)
      if t == Wall || game.smoke_cover_at(x0, y) {
        return false
      }
    }

    return true
  }

  if y0 == y1 {
    let x_min : Int = x0.min(x1)
    let x_max : Int = x0.max(x1)

    for x in (x_min + 1)..<x_max {
      let t = game.tile_at(x, y0)
      if t == Wall || game.smoke_cover_at(x, y0) {
        return false
      }
    }

    return true
  }

  false
}

///|
/// Advances the guard's pseudo-random seed using a linear congruential step.
fn guard_seed_next(seed : Int) -> Int {
  let n : Int = (seed * 48271 + 131) % 2147483647
  if n <= 0 {
    1
  } else {
    n
  }
}

///|
/// Selects the best adjacent step toward the player for a guard in Hunt mode using Manhattan distance.
fn @types.Game::guard_choose_chase_step(
  game : @types.Game,
  gid : Int,
) -> (Int, Int) {
  let gx : Int = game.guards[gid].body.x
  let gy : Int = game.guards[gid].body.y

  let px : Int = game.player.x
  let py : Int = game.player.y

  let dirs : Array[(Int, Int)] = [(-1, 0), (1, 0), (0, -1), (0, 1)]

  let best_i = for i in 0..<4; best_i = -1, best_d = 999999 {
    let nx : Int = gx + dirs[i].0
    let ny : Int = gy + dirs[i].1

    if game.blocked_for_guard(gid, nx, ny) {
      continue
    }

    let d : Int = @types.manhattan(nx, ny, px, py)
    if d < best_d {
      continue i, d
    }
  } nobreak {
    best_i
  }

  if best_i < 0 {
    (0, 0)
  } else {
    dirs[best_i]
  }
}

///|
/// Selects the next patrol step for a guard, reversing direction at patrol boundaries or when blocked.
fn @types.Game::guard_choose_patrol_step(
  game : @types.Game,
  gid : Int,
) -> (Int, Int) {
  let g = game.guards[gid]
  let gx : Int = g.body.x
  let gy : Int = g.body.y

  if g.dir_x != 0 {
    let mut nx : Int = gx + g.dir_x
    if nx < g.patrol_min ||
      nx > g.patrol_max ||
      game.blocked_for_guard(gid, nx, gy) {
      g.dir_x = -g.dir_x
      nx = gx + g.dir_x
    }

    if nx >= g.patrol_min &&
      nx <= g.patrol_max &&
      !game.blocked_for_guard(gid, nx, gy) {
      return (g.dir_x, 0)
    }
  }

  if g.dir_y != 0 {
    let mut ny : Int = gy + g.dir_y
    if ny < g.patrol_min ||
      ny > g.patrol_max ||
      game.blocked_for_guard(gid, gx, ny) {
      g.dir_y = -g.dir_y
      ny = gy + g.dir_y
    }

    if ny >= g.patrol_min &&
      ny <= g.patrol_max &&
      !game.blocked_for_guard(gid, gx, ny) {
      return (0, g.dir_y)
    }
  }

  g.seed = guard_seed_next(g.seed)
  let dirs : Array[(Int, Int)] = [(-1, 0), (1, 0), (0, -1), (0, 1)]
  let start : Int = g.seed % 4

  for t in 0..<4 {
    let k : Int = (start + t) % 4
    let nx : Int = gx + dirs[k].0
    let ny : Int = gy + dirs[k].1
    if game.blocked_for_guard(gid, nx, ny) {
      continue
    }

    return dirs[k]
  }

  (0, 0)
}

///|
/// Advances all active guards: ticks movement interpolation, updates stun and alert timers, and chooses the next step.
fn @types.Game::update_guards(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.guards.length() {
    if !game.guards[i].active {
      continue
    }

    actor_tick(game.guards[i].body, dt, @types.guard_move_t)

    if game.guards[i].mode == Stunned {
      game.guards[i].stun_t = game.guards[i].stun_t - dt
      if game.guards[i].stun_t <= 0.0 {
        game.guards[i].mode = Patrol
        game.guards[i].stun_t = 0.0
      }
    }

    if game.guards[i].alert_t > 0.0 {
      game.guards[i].alert_t = game.guards[i].alert_t - dt
    }

    if game.guards[i].body.moving {
      continue
    }

    game.guards[i].move_cd = game.guards[i].move_cd - dt
    if game.guards[i].move_cd > 0.0 {
      continue
    }

    if game.guards[i].mode == Stunned {
      game.guards[i].move_cd = 0.10
      continue
    }

    let d : Int = @types.manhattan(
      game.guards[i].body.x,
      game.guards[i].body.y,
      game.player.x,
      game.player.y,
    )
    let sees : Bool = game.line_of_sight(
      game.guards[i].body.x,
      game.guards[i].body.y,
      game.player.x,
      game.player.y,
    )

    if !game.smoke_cover_at(game.player.x, game.player.y) &&
      (d <= 3 || (sees && d <= 8)) {
      game.guards[i].mode = Hunt
      game.guards[i].alert_t = 1.1
    } else if game.guards[i].alert_t <= 0.0 {
      game.guards[i].mode = Patrol
    }

    let step = match game.guards[i].mode {
      Hunt => game.guard_choose_chase_step(i)
      Patrol | Stunned => game.guard_choose_patrol_step(i)
    }

    if step.0 != 0 || step.1 != 0 {
      actor_start_move(
        game.guards[i].body,
        game.guards[i].body.x + step.0,
        game.guards[i].body.y + step.1,
      )
    }

    game.guards[i].move_cd = @types.guard_move_t * @types.randf(0.80, 1.22)
  }
}

///|
/// Attempts to move the player one tile in direction `(dx, dy)`, emitting a spark burst on success; returns true if moved.
fn @types.Game::try_move_player(game : @types.Game, dx : Int, dy : Int) -> Bool {
  if dx == 0 && dy == 0 {
    return false
  }
  if game.player.moving {
    return false
  }

  let tx : Int = game.player.x + dx
  let ty : Int = game.player.y + dy

  if game.blocked_by_map(tx, ty) {
    return false
  }

  actor_start_move(game.player, tx, ty)
  game.move_cd = 0.02

  game.burst(
    Float::from_int(@types.cell_center_x(Float::from_int(tx))),
    Float::from_int(@types.cell_center_y(Float::from_int(ty))),
    8,
    Spark,
  )

  true
}

///|
/// Picks up any loot item on the player's current tile, updating score and unlocking the exit when enough is collected.
fn @types.Game::collect_loot(game : @types.Game) -> Unit {
  if game.player.moving {
    return
  }

  let i : Int = game.loot_index_at(game.player.x, game.player.y)
  if i < 0 {
    return
  }

  game.loots[i].active = false
  game.loot_taken = game.loot_taken + 1
  game.score = game.score + game.loots[i].value
  game.flash_t = 0.22

  let loot_label : String = match game.loots[i].kind {
    Blueprint => "Blueprint"
    Keycard => "Keycard"
    Gold => "Gold"
  }

  game.set_msg(
    "Stole " +
    loot_label +
    " (" +
    game.loot_taken.to_string() +
    "/" +
    @types.loot_need.to_string() +
    ")",
    1.8,
  )

  game.burst(
    Float::from_int(@types.cell_center_x(game.player.fx)),
    Float::from_int(@types.cell_center_y(game.player.fy)),
    24,
    Glitter,
  )

  if game.loot_taken >= @types.loot_need && !game.vault_open {
    game.vault_open = true
    game.score = game.score + 260
    game.shake_t = 0.30
    game.set_msg("Escape cable unlocked. Reach the rightmost car door.", 2.8)

    game.burst(
      Float::from_int(@types.cell_center_x(Float::from_int(@types.exit_x))),
      Float::from_int(@types.cell_center_y(Float::from_int(@types.exit_y))),
      42,
      Smoke,
    )
  }
}

///|
/// Checks whether the player shares a tile with a non-stunned guard and applies a life penalty or ends the run.
fn @types.Game::handle_player_caught(game : @types.Game) -> Unit {
  if game.flash_t > 0.0 {
    return
  }

  if game.smoke_cover_at(game.player.x, game.player.y) {
    return
  }

  for i in 0..<game.guards.length() {
    if !game.guards[i].active || game.guards[i].mode == Stunned {
      continue
    }

    if game.guards[i].body.x != game.player.x ||
      game.guards[i].body.y != game.player.y {
      continue
    }

    game.lives = game.lives - 1
    game.flash_t = 1.2
    game.shake_t = 0.36

    game.burst(
      Float::from_int(@types.cell_center_x(game.player.fx)),
      Float::from_int(@types.cell_center_y(game.player.fy)),
      34,
      Smoke,
    )

    if game.lives <= 0 {
      game.finish_run(false, "Caught by railway guards")
      return
    }

    actor_place(game.player, @types.start_x, @types.start_y)
    game.move_cd = 0.24

    for guard_val in game.guards {
      if !guard_val.active {
        continue
      }
      guard_val.mode = Stunned
      guard_val.stun_t = 1.1
      guard_val.move_cd = 0.18
    }

    game.set_msg("Spotted. You lost a life.", 1.8)
    break
  }
}

///|
/// Decrements all gameplay cooldown and visual effect timers by `dt` seconds.
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

  if game.touch_cd > 0.0 {
    game.touch_cd = game.touch_cd - dt
  }
}

///|
/// Advances time-based animations on the title screen.
fn @types.Game::update_title(game : @types.Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt
  game.update_timers(dt)
  game.update_particles(dt)
}

///|
/// Advances time-based animations on the result screen.
fn @types.Game::update_result(game : @types.Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt
  game.update_timers(dt)
  game.update_particles(dt)
}

///|
/// Runs one frame of gameplay: ticks timers, moves actors, processes input actions, checks loot and capture, and advances particles.
fn @types.Game::update_play(game : @types.Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt
  game.time_left = game.time_left - dt

  game.update_timers(dt)

  game.smoke_energy = @types.clampf(game.smoke_energy + dt * 17.0, 0.0, 100.0)

  actor_tick(game.player, dt, @types.player_move_t)

  if !game.player.moving && game.move_cd <= 0.0 {
    ignore(game.try_move_player(game.req_dx, game.req_dy))
  }

  if game.action_pressed {
    ignore(game.deploy_smoke())
  }

  game.update_smokes(dt)
  game.update_guards(dt)
  game.collect_loot()
  game.handle_player_caught()

  if game.state == Play &&
    !game.player.moving &&
    game.vault_open &&
    game.player.x == @types.exit_x &&
    game.player.y == @types.exit_y {
    game.finish_run(true, "")
  }

  if game.state == Play && game.time_left <= 0.0 {
    game.finish_run(false, "Clockwork engine reached lockdown")
  }

  game.update_particles(dt)
}

///|
/// Advances one frame of game state, handling both input and simulation.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  match game.state {
    Title => game.update_title_input()
    Play => game.update_play_input()
    Result => game.update_result_input()
  }

  match game.state {
    Title => game.update_title(dt)
    Play => game.update_play(dt)
    Result => game.update_result(dt)
  }

  game.action_pressed = false
}
