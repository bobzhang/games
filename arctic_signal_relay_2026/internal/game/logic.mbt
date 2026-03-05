///|
/// Deactivates all towers and resets their fields to zero.
fn @types.Game::clear_towers(game : @types.Game) -> Unit {
  for tower in game.towers {
    tower.active = false
    tower.x = 0.0
    tower.y = 0.0
    tower.need = 0
    tower.delivered = 0
    tower.pulse_t = 0.0
  }
}

///|
/// Deactivates all storms and resets their fields to zero.
fn @types.Game::clear_storms(game : @types.Game) -> Unit {
  for storm in game.storms {
    storm.active = false
    storm.x = 0.0
    storm.y = 0.0
    storm.r = 0.0
    storm.vx = 0.0
    storm.vy = 0.0
    storm.phase = 0.0
    storm.strength = 0.0
  }
}

///|
/// Returns the mission time limit in seconds for the given stage, clamped to `timer_floor`.
fn stage_timer_limit(stage : Int) -> Float {
  let raw = @types.timer_base - Float::from_int(stage - 1) * @types.timer_step
  @types.maxf(@types.timer_floor, raw)
}

///|
/// Returns the number of relay towers to spawn for the given stage, clamped to `[3, max_towers]`.
fn stage_tower_count(stage : Int) -> Int {
  (2 + stage).clamp(min=3, max=@types.max_towers)
}

///|
/// Returns the number of storm cells to spawn for the given stage, clamped to `[1, max_storms]`.
fn stage_storm_count(stage : Int) -> Int {
  (1 + stage / 2).clamp(min=1, max=@types.max_storms)
}

///|
/// Returns the number of power cells a tower at `idx` requires for the given stage.
fn stage_tower_need(stage : Int, idx : Int) -> Int {
  let base = 1 + (stage - 1) / 2
  (base + idx % 2).clamp(min=1, max=4)
}

///|
/// Sets the in-game hint text and its display duration in seconds.
fn @types.Game::set_hint(
  game : @types.Game,
  text : String,
  ttl : Float,
) -> Unit {
  game.hint_text = text
  game.hint_t = ttl
}

///|
/// Returns true if the candidate position `(x, y)` is far enough from the depot and all previously placed towers to be a valid tower spawn location.
fn @types.Game::tower_spot_ok(
  game : @types.Game,
  placed : Int,
  x : Float,
  y : Float,
) -> Bool {
  if @types.dist2(x, y, @types.depot_x(), @types.depot_y()) < 250.0 * 250.0 {
    return false
  }

  for i in 0..<placed {
    if not(game.towers[i].active) {
      continue
    }

    if @types.dist2(x, y, game.towers[i].x, game.towers[i].y) < 190.0 * 190.0 {
      return false
    }
  }

  true
}

///|
/// Resets and configures towers, storms, rover state, and objectives for the given stage number, then transitions the game to the Play state.
fn @types.Game::setup_stage(game : @types.Game, stage : Int) -> Unit {
  game.clear_towers()
  game.clear_storms()

  game.state = Play
  game.stage = if stage < 1 { 1 } else { stage }
  game.result_win = false
  game.result_note = ""

  game.mission_limit_s = stage_timer_limit(game.stage)
  game.timer_s = game.mission_limit_s
  game.objective_total = 0
  game.objective_done = 0

  game.rover_x = @types.depot_x()
  game.rover_y = @types.depot_y()
  game.rover_vx = 0.0
  game.rover_vy = 0.0
  game.rover_energy = @types.energy_max
  game.rover_heat = @types.heat_max
  game.cargo_cells = 0
  game.storm_intensity = 0.0
  game.in_depot = true
  game.nearby_tower = -1
  game.flash_t = 0.0

  let tower_count = stage_tower_count(game.stage)
  for i in 0..<tower_count {
    let mut tx = @types.randf(
      @types.world_left() + 120.0,
      @types.world_right() - 120.0,
    )
    let mut ty = @types.randf(
      @types.world_top() + 120.0,
      @types.world_bottom() - 120.0,
    )

    for _attempt in 0..<36 {
      let cand_x = @types.randf(
        @types.world_left() + 120.0,
        @types.world_right() - 120.0,
      )
      let cand_y = @types.randf(
        @types.world_top() + 120.0,
        @types.world_bottom() - 120.0,
      )
      if game.tower_spot_ok(i, cand_x, cand_y) {
        tx = cand_x
        ty = cand_y
        break
      }
    }

    game.towers[i].active = true
    game.towers[i].x = tx
    game.towers[i].y = ty
    game.towers[i].need = stage_tower_need(game.stage, i)
    game.towers[i].delivered = 0
    game.towers[i].pulse_t = @types.randf(0.0, 6.28)
    game.objective_total = game.objective_total + game.towers[i].need
  }

  let storm_count = stage_storm_count(game.stage)
  for i in 0..<storm_count {
    let mut sx = @types.randf(
      @types.world_left() + 140.0,
      @types.world_right() - 140.0,
    )
    let mut sy = @types.randf(
      @types.world_top() + 140.0,
      @types.world_bottom() - 140.0,
    )

    for _attempt in 0..<24 {
      if @types.dist2(sx, sy, @types.depot_x(), @types.depot_y()) >
        230.0 * 230.0 {
        break
      }
      sx = @types.randf(
        @types.world_left() + 140.0,
        @types.world_right() - 140.0,
      )
      sy = @types.randf(
        @types.world_top() + 140.0,
        @types.world_bottom() - 140.0,
      )
    }

    let mut vx = @types.randf(-120.0, 120.0)
    let mut vy = @types.randf(-120.0, 120.0)
    if vx.abs() + vy.abs() < 50.0 {
      vx = 54.0 + Float::from_int(i) * 18.0
      vy = -62.0 + Float::from_int(i) * 12.0
    }

    game.storms[i].active = true
    game.storms[i].x = sx
    game.storms[i].y = sy
    game.storms[i].r = @types.randf(90.0, 152.0) +
      Float::from_int(game.stage) * 7.0
    game.storms[i].vx = vx
    game.storms[i].vy = vy
    game.storms[i].phase = @types.randf(0.0, 6.28)
    game.storms[i].strength = @types.clampf(
      0.52 + Float::from_int(game.stage) * 0.10 + @types.randf(0.0, 0.28),
      0.4,
      1.7,
    )
  }

  game.set_hint("Load cells at depot, deliver to relay towers", 2.2)
}

///|
/// Initialises the game to the Title state with decorative towers and storms for the title screen backdrop.
pub fn init_title_scene(game : @types.Game) -> Unit {
  game.clear_towers()
  game.clear_storms()

  game.state = Title
  game.stage = 1
  game.mission_limit_s = stage_timer_limit(1)
  game.timer_s = game.mission_limit_s
  game.objective_total = 0
  game.objective_done = 0
  game.rover_x = @types.depot_x()
  game.rover_y = @types.depot_y()
  game.rover_vx = 0.0
  game.rover_vy = 0.0
  game.rover_energy = @types.energy_max
  game.rover_heat = @types.heat_max
  game.cargo_cells = 0
  game.storm_intensity = 0.0
  game.in_depot = true
  game.nearby_tower = -1
  game.result_note = ""
  game.result_win = false
  game.flash_t = 0.0
  game.set_hint("Arctic relay prep", 0.0)

  for i in 0..<3 {
    game.towers[i].active = true
    game.towers[i].x = @types.world_left() + 420.0 + Float::from_int(i) * 170.0
    game.towers[i].y = @types.world_top() +
      210.0 +
      Float::from_int(i % 2) * 220.0
    game.towers[i].need = 2
    game.towers[i].delivered = i % 2
    game.towers[i].pulse_t = Float::from_int(i)
  }

  for i in 0..<2 {
    game.storms[i].active = true
    game.storms[i].x = @types.world_left() + 500.0 + Float::from_int(i) * 200.0
    game.storms[i].y = @types.world_top() + 260.0 + Float::from_int(i) * 180.0
    game.storms[i].r = 120.0
    game.storms[i].vx = 42.0 - Float::from_int(i) * 18.0
    game.storms[i].vy = 34.0 + Float::from_int(i) * 20.0
    game.storms[i].phase = Float::from_int(i) * 2.1
    game.storms[i].strength = 0.62
  }
}

///|
/// Returns the index of the nearest active, incomplete tower within interaction range of `(x, y)`, or -1 if none is found.
fn @types.Game::closest_pending_tower(
  game : @types.Game,
  x : Float,
  y : Float,
) -> Int {
  let mut best_idx = -1
  let mut best_d2 = @types.tower_interact_r() * @types.tower_interact_r()

  for i in 0..<game.towers.length() {
    if not(game.towers[i].active) {
      continue
    }
    if game.towers[i].delivered >= game.towers[i].need {
      continue
    }

    let d2 = @types.dist2(x, y, game.towers[i].x, game.towers[i].y)
    if d2 <= best_d2 {
      best_d2 = d2
      best_idx = i
    }
  }

  best_idx
}

///|
/// Updates the rover's `in_depot` flag and `nearby_tower` index based on its current position.
fn @types.Game::update_proximity(game : @types.Game) -> Unit {
  game.in_depot = @types.dist2(
      game.rover_x,
      game.rover_y,
      @types.depot_x(),
      @types.depot_y(),
    ) <=
    @types.depot_r() * @types.depot_r()
  game.nearby_tower = game.closest_pending_tower(game.rover_x, game.rover_y)
}

///|
/// Advances all active storm cells by `dt` seconds, applying oscillating drift and bouncing them off the world boundary.
fn @types.Game::update_storms(game : @types.Game, dt : Float) -> Unit {
  let left = @types.world_left() + 20.0
  let right = @types.world_right() - 20.0
  let top = @types.world_top() + 20.0
  let bottom = @types.world_bottom() - 20.0

  for storm in game.storms {
    if not(storm.active) {
      continue
    }

    storm.phase = storm.phase + dt * (0.8 + storm.strength * 0.8)

    let drift_x = @math.cosf(storm.phase * 0.7) * 18.0
    let drift_y = @math.sinf(storm.phase * 0.6) * 14.0

    storm.x = storm.x + (storm.vx + drift_x) * dt
    storm.y = storm.y + (storm.vy + drift_y) * dt

    if storm.x - storm.r < left {
      storm.x = left + storm.r
      storm.vx = storm.vx.abs()
    } else if storm.x + storm.r > right {
      storm.x = right - storm.r
      storm.vx = -storm.vx.abs()
    }

    if storm.y - storm.r < top {
      storm.y = top + storm.r
      storm.vy = storm.vy.abs()
    } else if storm.y + storm.r > bottom {
      storm.y = bottom - storm.r
      storm.vy = -storm.vy.abs()
    }
  }
}

///|
/// Returns the combined storm intensity, wind X, and wind Y acting on position `(x, y)` from all active storms.
fn @types.Game::storm_effect_at(
  game : @types.Game,
  x : Float,
  y : Float,
) -> (Float, Float, Float) {
  let mut intensity : Float = 0.0
  let mut wind_x : Float = 0.0
  let mut wind_y : Float = 0.0

  for i, storm in game.storms {
    if !storm.active {
      continue
    }

    let rr = storm.r
    let rr2 = rr * rr
    let d2 = @types.dist2(x, y, storm.x, storm.y)

    if d2 > rr2 {
      continue
    }

    let center_gain : Float = 1.0 - d2 / rr2
    let amp : Float = storm.strength * (0.35 + center_gain * 0.95)
    intensity = intensity + amp

    let swirl : Float = 8.0 + center_gain * 22.0
    wind_x = wind_x +
      storm.vx * 0.008 * amp +
      @math.cosf(storm.phase + Float::from_int(i) * 0.7) * swirl
    wind_y = wind_y +
      storm.vy * 0.008 * amp +
      @math.sinf(storm.phase + Float::from_int(i) * 0.7) * swirl
  }

  (@types.clampf(intensity, 0.0, 1.8), wind_x, wind_y)
}

///|
/// Applies player input and storm wind forces to the rover's velocity, clamps speed, and moves the rover while keeping it within the world boundary.
fn @types.Game::update_rover(
  game : @types.Game,
  dt : Float,
  intensity : Float,
  wind_x : Float,
  wind_y : Float,
) -> Unit {
  let mut dir_x = game.input_x
  let mut dir_y = game.input_y

  let norm = dir_x.abs() + dir_y.abs()
  if norm > 0.0001 {
    dir_x = dir_x / norm
    dir_y = dir_y / norm
  }

  let ctrl : Float = 1.0 -
    @types.storm_control_penalty * @types.clampf(intensity, 0.0, 1.2)

  game.rover_vx = game.rover_vx +
    (dir_x * @types.rover_accel * ctrl + wind_x * @types.rover_wind_force) * dt
  game.rover_vy = game.rover_vy +
    (dir_y * @types.rover_accel * ctrl + wind_y * @types.rover_wind_force) * dt

  let damp = @types.clampf(
    1.0 - (@types.rover_drag + intensity * 2.2) * dt,
    0.0,
    1.0,
  )
  game.rover_vx = game.rover_vx * damp
  game.rover_vy = game.rover_vy * damp

  let max_speed = @types.maxf(
    130.0,
    @types.rover_max_speed * (1.0 - 0.24 * @types.clampf(intensity, 0.0, 1.0)),
  )
  let speed_sum = game.rover_vx.abs() + game.rover_vy.abs()
  if speed_sum > max_speed {
    let s = max_speed / speed_sum
    game.rover_vx = game.rover_vx * s
    game.rover_vy = game.rover_vy * s
  }

  game.rover_x = game.rover_x + game.rover_vx * dt
  game.rover_y = game.rover_y + game.rover_vy * dt

  let left = @types.world_left() + @types.rover_r + 4.0
  let right = @types.world_right() - @types.rover_r - 4.0
  let top = @types.world_top() + @types.rover_r + 4.0
  let bottom = @types.world_bottom() - @types.rover_r - 4.0

  if game.rover_x < left {
    game.rover_x = left
    game.rover_vx = 0.0
  } else if game.rover_x > right {
    game.rover_x = right
    game.rover_vx = 0.0
  }

  if game.rover_y < top {
    game.rover_y = top
    game.rover_vy = 0.0
  } else if game.rover_y > bottom {
    game.rover_y = bottom
    game.rover_vy = 0.0
  }
}

///|
/// Drains rover energy and heat based on movement speed and storm intensity, and recharges both while the rover is in the depot.
fn @types.Game::update_resources(
  game : @types.Game,
  dt : Float,
  intensity : Float,
) -> Unit {
  let speed = game.rover_vx.abs() + game.rover_vy.abs()
  let energy_drain = @types.energy_idle_drain +
    speed * @types.energy_move_drain +
    intensity * @types.energy_storm_drain
  let heat_drain = @types.heat_idle_drain + intensity * @types.heat_storm_drain

  let mut next_energy = game.rover_energy - energy_drain * dt
  let mut next_heat = game.rover_heat - heat_drain * dt

  if game.in_depot {
    next_energy = next_energy + @types.energy_recharge_rate * dt
    next_heat = next_heat + @types.heat_recharge_rate * dt
  }

  game.rover_energy = @types.clampf(next_energy, 0.0, @types.energy_max)
  game.rover_heat = @types.clampf(next_heat, 0.0, @types.heat_max)
}

///|
/// Processes a player action press: loads a power cell at the depot or delivers one to a nearby tower, updating cargo, objectives, timer bonus, and hint text accordingly.
fn @types.Game::apply_action(game : @types.Game) -> Unit {
  if not(game.input_action_press) {
    return
  }

  if game.in_depot {
    if game.cargo_cells < @types.cargo_capacity {
      game.cargo_cells = game.cargo_cells + 1
      game.set_hint("Power cell secured in cargo bay", 1.0)
      game.flash_t = 0.12
    } else {
      game.set_hint("Cargo bay is full", 0.9)
    }
    return
  }

  if game.nearby_tower >= 0 {
    if game.cargo_cells <= 0 {
      game.set_hint("No power cell in cargo", 0.9)
      return
    }

    let idx = game.nearby_tower
    if game.towers[idx].delivered < game.towers[idx].need {
      game.towers[idx].delivered = game.towers[idx].delivered + 1
      game.cargo_cells = game.cargo_cells - 1
      game.objective_done = game.objective_done + 1
      game.flash_t = 0.18

      if game.towers[idx].delivered >= game.towers[idx].need {
        let bonus = @types.tower_online_bonus_base +
          Float::from_int(game.stage) * @types.tower_online_bonus_step
        game.timer_s = game.timer_s + bonus
        game.set_hint("Relay online, +\{bonus.to_int()}s", 1.3)
      } else {
        game.set_hint("Relay charge delivered", 0.8)
      }
    }
    return
  }

  game.set_hint("Move close to depot or a relay tower", 0.8)
}

///|
/// Transitions the game to the Result state, records the win/loss outcome with a note, triggers a flash effect, and updates `best_stage` on a win.
fn @types.Game::set_result(
  game : @types.Game,
  win : Bool,
  note : String,
) -> Unit {
  game.state = Result
  game.result_win = win
  game.result_note = note
  game.flash_t = 0.8
  game.rover_vx = 0.0
  game.rover_vy = 0.0

  if win && game.stage > game.best_stage {
    game.best_stage = game.stage
  }
}

///|
/// Advances the Play state by one frame: ticks the mission timer, updates storms, applies storm effects to the rover, updates resources, animates tower pulses, processes action input, and checks win/loss conditions.
fn @types.Game::update_play_state(game : @types.Game, dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    init_title_scene(game)
    return
  }

  game.timer_s = game.timer_s - dt
  game.update_storms(dt)

  let effect = game.storm_effect_at(game.rover_x, game.rover_y)
  game.storm_intensity = effect.0

  game.update_rover(dt, effect.0, effect.1, effect.2)

  game.update_proximity()
  game.update_resources(dt, game.storm_intensity)

  for i in 0..<game.towers.length() {
    if game.towers[i].active {
      game.towers[i].pulse_t = game.towers[i].pulse_t +
        dt * (1.2 + Float::from_int(i) * 0.15)
    }
  }

  game.apply_action()

  if game.objective_total > 0 && game.objective_done >= game.objective_total {
    game.set_result(true, "All relay towers synchronized")
    return
  }

  if game.timer_s <= 0.0 {
    game.set_result(false, "Shift timer expired")
    return
  }

  if game.rover_energy <= 0.0 {
    game.set_result(false, "Battery depleted in whiteout")
    return
  }

  if game.rover_heat <= 0.0 {
    game.set_result(false, "Rover heat loss critical")
    return
  }
}

///|
/// Advances the game by one frame: clamps `dt`, ticks UI timers, dispatches input and state logic for the current game state, and handles stage transitions.
pub fn update_game(game : @types.Game, dt0 : Float) -> Unit {
  let dt = @types.clampf(dt0, 0.0, 0.05)
  game.ui_t = game.ui_t + dt
  game.flash_t = @types.maxf(0.0, game.flash_t - dt)
  game.hint_t = @types.maxf(0.0, game.hint_t - dt)

  match game.state {
    Title => {
      game.update_title_input()
      game.update_storms(dt)
      if game.input_start_press {
        game.setup_stage(1)
      }
    }
    Play => {
      game.update_play_input()
      game.update_play_state(dt)
    }
    Result => {
      game.update_result_input()
      if game.input_next_press {
        let next_stage = if game.result_win {
          game.stage + 1
        } else {
          game.stage
        }
        game.setup_stage(next_stage)
      } else if game.input_restart_press {
        game.setup_stage(1)
      }
    }
  }
}
