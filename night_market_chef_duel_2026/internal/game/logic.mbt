///|
/// Resets an order slot to inactive with zeroed fields.
fn clear_order(order : @types.Order) -> Unit {
  order.active = false
  order.dish = Skewers
  order.patience = 0.0
  order.patience_max = 0.0
  order.reward = 0
  order.ticket_no = 0
}

///|
/// Clears the active cooking pipeline, resetting dish, lane, stage, and progress.
fn @types.Game::clear_cooking(game : @types.Game) -> Unit {
  game.cooking.active = false
  game.cooking.dish = DishNone
  game.cooking.lane = Grill
  game.cooking.stage = Prep
  game.cooking.prep_progress = 0.0
  game.cooking.cook_progress = 0.0
}

///|
/// Clears all orders and the cooking pipeline, and resets cursor and selection.
fn @types.Game::clear_round_entities(game : @types.Game) -> Unit {
  for order in game.orders {
    clear_order(order)
  }
  game.clear_cooking()
  game.ready_dish = DishNone
  game.ready_quality = 0.0
  game.selected_order = -1
  game.cursor = PrepStation
}

///|
/// Resets all run state to initial values including score, combo, timers, and entities.
fn @types.Game::init_game(game : @types.Game) -> Unit {
  game.state = Title
  game.score = 0
  game.combo = 0
  game.combo_timer = 0.0
  game.served_orders = 0
  game.failed_orders = 0
  game.next_order_id = 1
  game.spawn_t = 0.6
  game.elapsed_t = 0.0
  game.boost_t = 0.0
  game.boost_cd = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0
  game.clear_round_entities()
}

///|
/// Initialises a new round, preserving the best score, and spawns the first two orders.
fn @types.Game::start_round(game : @types.Game) -> Unit {
  let keep_best = game.best_score
  game.init_game()
  game.best_score = keep_best
  game.state = Play
  game.spawn_order()
  game.spawn_order()
}

///|
/// Returns a randomly chosen dish whose distribution shifts toward harder dishes as elapsed time grows.
fn choose_dish_for_wave(elapsed_t : Float) -> @types.Dish {
  let r = @types.randi(0, 999)
  let late = @types.clampf(elapsed_t / 95.0, 0.0, 1.0)
  let easy_band = 350 - (late * 120.0).to_int()
  let mid_band = easy_band + 260
  let hard_band = mid_band + 220

  if r < easy_band {
    Skewers
  } else if r < mid_band {
    Noodles
  } else if r < hard_band {
    FriedRice
  } else {
    Squid
  }
}

///|
/// Returns the starting patience time for a new order, reduced by round pressure and dish difficulty.
fn @types.Game::base_patience(game : @types.Game, dish : @types.Dish) -> Float {
  let rush = Float::from_int(game.served_orders + game.failed_orders) * 0.1
  let lane_bias : Float = match dish {
    Squid => -0.8
    Noodles => 0.5
    _ => 0.0
  }

  @types.maxf(
    @types.patience_floor,
    @types.patience_base - rush + lane_bias + @types.randf(-1.0, 1.3),
  )
}

///|
/// Returns the index of the first inactive order slot, or -1 if all slots are occupied.
fn @types.Game::find_free_order_slot(game : @types.Game) -> Int {
  for i, slot in game.orders {
    if !slot.active {
      return i
    }
  }
  -1
}

///|
/// Returns the time until the next order spawn, decreasing as total orders processed increases.
fn @types.Game::next_spawn_interval(game : @types.Game) -> Float {
  let pressure = Float::from_int(game.served_orders + game.failed_orders) * 0.07
  let base = @types.maxf(
    @types.spawn_interval_min,
    @types.spawn_interval_start - pressure,
  )
  @types.clampf(
    base + @types.randf(-0.22, 0.35),
    @types.spawn_interval_min,
    @types.spawn_interval_start,
  )
}

///|
/// Fills the next free order slot with a dish, patience, and reward based on current wave progression.
fn @types.Game::spawn_order(game : @types.Game) -> Unit {
  let slot = game.find_free_order_slot()
  if slot < 0 {
    game.spawn_t = 0.45
    return
  }

  let dish = choose_dish_for_wave(game.elapsed_t)
  let patience = game.base_patience(dish)

  game.orders[slot].active = true
  game.orders[slot].dish = dish
  game.orders[slot].patience = patience
  game.orders[slot].patience_max = patience
  game.orders[slot].reward = @types.dish_base_reward(dish)
  game.orders[slot].ticket_no = game.next_order_id

  game.next_order_id = game.next_order_id + 1
  game.spawn_t = game.next_spawn_interval()
}

///|
/// Returns true if `selected_order` refers to an active order slot.
fn @types.Game::selected_is_valid(game : @types.Game) -> Bool {
  game.selected_order >= 0 &&
  game.selected_order < @types.max_orders &&
  game.orders[game.selected_order].active
}

///|
/// Clears `selected_order` if the referenced order is no longer active.
fn @types.Game::ensure_selected_order(game : @types.Game) -> Unit {
  if not(game.selected_is_valid()) {
    game.selected_order = -1
  }
}

///|
/// Returns the selected order index if valid, otherwise the active order with the least patience remaining.
fn @types.Game::choose_target_order(game : @types.Game) -> Int {
  game.ensure_selected_order()
  if game.selected_order >= 0 {
    return game.selected_order
  }

  let mut best = -1
  let mut best_patience : Float = 99999.0
  for i in 0..<game.orders.length() {
    if game.orders[i].active && game.orders[i].patience < best_patience {
      best_patience = game.orders[i].patience
      best = i
    }
  }
  best
}

///|
/// Increments the failed-order count, resets combo, triggers screen flash/shake, and transitions to GameOver if limit is reached.
fn @types.Game::register_failure(game : @types.Game) -> Unit {
  game.failed_orders = game.failed_orders + 1
  game.combo = 0
  game.combo_timer = 0.0
  game.flash_t = @types.maxf(game.flash_t, 0.36)
  game.shake_t = @types.maxf(game.shake_t, 0.32)

  if game.failed_orders >= @types.fail_limit {
    game.state = GameOver
    game.best_score = game.best_score.max(game.score)
  }
}

///|
/// Ticks patience timers for all active orders and calls `register_failure` for any that expire.
fn @types.Game::update_orders(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.orders.length() {
    if game.orders[i].active {
      game.orders[i].patience = game.orders[i].patience - dt
      if game.orders[i].patience <= 0.0 {
        clear_order(game.orders[i])
        if game.selected_order == i {
          game.selected_order = -1
        }
        if game.state == Play {
          game.register_failure()
        }
      }
    }
  }
}

///|
/// Returns the order index matching the given dish with the least patience, preferring the selected order.
fn @types.Game::find_matching_order(
  game : @types.Game,
  dish : @types.Dish,
) -> Int {
  game.ensure_selected_order()

  if game.selected_order >= 0 {
    let selected = game.selected_order
    if game.orders[selected].active && game.orders[selected].dish == dish {
      return selected
    }
  }

  let mut best = -1
  let mut best_patience : Float = 99999.0
  for i in 0..<game.orders.length() {
    if game.orders[i].active &&
      game.orders[i].dish == dish &&
      game.orders[i].patience < best_patience {
      best_patience = game.orders[i].patience
      best = i
    }
  }
  best
}

///|
/// Returns 1.7 when boost is active, 1.0 otherwise.
fn @types.Game::boost_multiplier(game : @types.Game) -> Float {
  if game.boost_t > 0.0 {
    1.7
  } else {
    1.0
  }
}

///|
/// Moves the cooked dish to the ready slot if cook progress has met the required threshold.
fn @types.Game::finish_cooking_if_ready(game : @types.Game) -> Unit {
  if not(game.cooking.active) || game.cooking.stage != Heat {
    return
  }

  let need = @types.dish_cook_need(game.cooking.dish)
  if game.cooking.cook_progress >= need && game.ready_dish == DishNone {
    let overflow = game.cooking.cook_progress - need
    game.ready_dish = game.cooking.dish
    game.ready_quality = @types.clampf(1.0 - overflow * 0.18, 0.58, 1.15)
    game.clear_cooking()
    game.flash_t = @types.maxf(game.flash_t, 0.2)
  }
}

///|
/// Handles J press at the prep station: advances prep progress or starts a new dish if the pipeline is idle.
fn @types.Game::apply_press_j_at_prep(game : @types.Game) -> Unit {
  if game.cooking.active {
    if game.cooking.stage == Prep {
      game.cooking.prep_progress = game.cooking.prep_progress +
        @types.prep_press_gain * game.boost_multiplier()
      let need = @types.dish_prep_need(game.cooking.dish)
      if game.cooking.prep_progress >= need {
        game.cooking.prep_progress = need
        game.cooking.stage = Heat
      }
    }
    return
  }

  if game.ready_dish != DishNone {
    return
  }

  let target = game.choose_target_order()
  if target < 0 {
    return
  }

  let dish = game.orders[target].dish
  game.cooking.active = true
  game.cooking.dish = dish
  game.cooking.lane = @types.dish_lane(dish)
  game.cooking.stage = Prep
  game.cooking.prep_progress = 0.0
  game.cooking.cook_progress = 0.0
  game.selected_order = target
  game.flash_t = @types.maxf(game.flash_t, 0.1)
}

///|
/// Handles J press at a heat station: advances cook progress if the active dish matches the station lane.
fn @types.Game::apply_press_j_at_heat(
  game : @types.Game,
  lane : @types.Lane,
) -> Unit {
  if not(game.cooking.active) || game.cooking.stage != Heat {
    return
  }

  if game.cooking.lane != lane {
    game.combo = 0
    game.combo_timer = 0.0
    game.flash_t = @types.maxf(game.flash_t, 0.12)
    return
  }

  game.cooking.cook_progress = game.cooking.cook_progress +
    @types.heat_press_gain * game.boost_multiplier()
  game.finish_cooking_if_ready()
}

///|
/// Attempts to serve the ready dish: finds a matching order, calculates payout with bonuses, updates score and combo.
fn @types.Game::try_serve_ready_dish(game : @types.Game) -> Unit {
  if game.ready_dish == DishNone {
    return
  }

  let matched_order = game.find_matching_order(game.ready_dish)
  if matched_order < 0 {
    game.ready_dish = DishNone
    game.ready_quality = 0.0
    game.register_failure()
    return
  }

  let base = game.orders[matched_order].reward
  let patience_ratio : Float = if game.orders[matched_order].patience_max <=
    0.01 {
    0.0
  } else {
    @types.clampf(
      game.orders[matched_order].patience /
      game.orders[matched_order].patience_max,
      0.0,
      1.0,
    )
  }

  let patience_bonus = (Float::from_int(base) * patience_ratio * 0.45).to_int()
  let quality_bonus = (Float::from_int(base) * (game.ready_quality - 0.5) * 0.34).to_int()
  let combo_bonus = game.combo * 18

  let gained = (18).max(base + patience_bonus + quality_bonus + combo_bonus)
  game.score = game.score + gained
  game.best_score = game.best_score.max(game.score)

  game.served_orders = game.served_orders + 1
  game.combo = (game.combo + 1).clamp(min=0, max=99)
  game.combo_timer = @types.combo_window

  clear_order(game.orders[matched_order])
  if game.selected_order == matched_order {
    game.selected_order = -1
  }

  game.ready_dish = DishNone
  game.ready_quality = 0.0
  game.flash_t = @types.maxf(game.flash_t, 0.22)
}

///|
/// Dispatches J press to the appropriate handler based on the current cursor position.
fn @types.Game::apply_press_j(game : @types.Game) -> Unit {
  match game.cursor {
    OrderSlot(i) => if game.orders[i].active { game.selected_order = i }
    PrepStation => game.apply_press_j_at_prep()
    GrillStation => game.apply_press_j_at_heat(Grill)
    WokStation => game.apply_press_j_at_heat(Wok)
    PassStation => ()
  }
}

///|
/// Handles K press: serves a ready dish at the pass, deselects an order, or cancels active cooking.
fn @types.Game::apply_press_k(game : @types.Game) -> Unit {
  match game.cursor {
    PassStation => game.try_serve_ready_dish()
    OrderSlot(i) =>
      if game.selected_order == i {
        game.selected_order = -1
        game.flash_t = @types.maxf(game.flash_t, 0.08)
      }
    PrepStation | GrillStation | WokStation =>
      if game.cooking.active {
        game.clear_cooking()
        game.combo = 0
        game.combo_timer = 0.0
        game.flash_t = @types.maxf(game.flash_t, 0.16)
      }
  }
}

///|
/// Moves the navigation cursor to the nearest node in the given direction using a distance-and-alignment heuristic.
fn @types.Game::move_cursor(
  game : @types.Game,
  dir_x : Int,
  dir_y : Int,
) -> Unit {
  if dir_x == 0 && dir_y == 0 {
    return
  }

  let cur = @types.node_pos(game.cursor)
  let mut best = game.cursor
  let mut best_score : Float = 1000000.0

  let nodes = @types.all_nav_nodes()
  for node in nodes {
    if node != game.cursor {
      let p = @types.node_pos(node)
      let vx = p.0 - cur.0
      let vy = p.1 - cur.1

      let mut accepted = true
      if dir_x < 0 && vx >= -6.0 {
        accepted = false
      }
      if dir_x > 0 && vx <= 6.0 {
        accepted = false
      }
      if dir_y < 0 && vy >= -6.0 {
        accepted = false
      }
      if dir_y > 0 && vy <= 6.0 {
        accepted = false
      }

      if accepted {
        let forward : Float = if dir_x != 0 { vx.abs() } else { vy.abs() }
        let side : Float = if dir_x != 0 { vy.abs() } else { vx.abs() }
        let score : Float = forward + side * 1.9
        if score < best_score {
          best_score = score
          best = node
        }
      }
    }
  }

  game.cursor = best
}

///|
/// Starts a boost session if the cooldown has expired, setting boost timer and cooldown.
fn @types.Game::activate_boost(game : @types.Game) -> Unit {
  if game.boost_cd <= 0.0 {
    game.boost_t = @types.boost_time
    game.boost_cd = @types.boost_cooldown
    game.flash_t = @types.maxf(game.flash_t, 0.14)
  }
}

///|
/// Ticks down the active boost timer and cooldown each frame.
fn @types.Game::update_boost(game : @types.Game, dt : Float) -> Unit {
  game.boost_t = @types.maxf(0.0, game.boost_t - dt)
  game.boost_cd = @types.maxf(0.0, game.boost_cd - dt)
}

///|
/// Passively advances cooking progress during an active boost and finalises the dish when complete.
fn @types.Game::update_cooking_passive(game : @types.Game, dt : Float) -> Unit {
  if not(game.cooking.active) {
    return
  }

  if game.boost_t > 0.0 {
    match game.cooking.stage {
      Prep => {
        game.cooking.prep_progress = game.cooking.prep_progress +
          dt * @types.boost_prep_rate
        let need = @types.dish_prep_need(game.cooking.dish)
        if game.cooking.prep_progress >= need {
          game.cooking.prep_progress = need
          game.cooking.stage = Heat
        }
      }
      Heat => {
        let on_lane = match (game.cursor, game.cooking.lane) {
          (GrillStation, Grill) | (WokStation, Wok) => true
          _ => false
        }
        if on_lane {
          game.cooking.cook_progress = game.cooking.cook_progress +
            dt * @types.boost_heat_rate
        }
      }
    }
  }

  game.finish_cooking_if_ready()
}

///|
/// Slowly degrades the ready dish quality over time until it is served.
fn @types.Game::update_ready_dish(game : @types.Game, dt : Float) -> Unit {
  if game.ready_dish != DishNone {
    game.ready_quality = @types.maxf(0.55, game.ready_quality - dt * 0.045)
  }
}

///|
/// Counts down the combo window timer and resets combo to zero when it expires.
fn @types.Game::update_combo_timer(game : @types.Game, dt : Float) -> Unit {
  if game.combo > 0 {
    game.combo_timer = game.combo_timer - dt
    if game.combo_timer <= 0.0 {
      game.combo = 0
      game.combo_timer = 0.0
    }
  }
}

///|
/// Counts down the spawn interval timer and triggers `spawn_order` when it reaches zero.
fn @types.Game::update_spawn(game : @types.Game, dt : Float) -> Unit {
  game.spawn_t = game.spawn_t - dt
  if game.spawn_t <= 0.0 {
    game.spawn_order()
  }
}

///|
/// Decrements flash and shake effect timers toward zero each frame.
fn @types.Game::update_effects(game : @types.Game, dt : Float) -> Unit {
  game.flash_t = @types.maxf(0.0, game.flash_t - dt)
  game.shake_t = @types.maxf(0.0, game.shake_t - dt)
}

///|
/// Checks for start input on the title screen and transitions to Play.
fn @types.Game::update_title(game : @types.Game) -> Unit {
  if game.input.press_start ||
    game.input.press_restart ||
    game.input.press_space {
    game.start_round()
  }
}

///|
/// Handles input while paused: R restarts the round, P or J resumes play.
fn @types.Game::update_paused(game : @types.Game) -> Unit {
  if game.input.press_restart {
    game.start_round()
  } else if game.input.press_pause || game.input.press_start {
    game.state = Play
  }
}

///|
/// Checks for restart or start input on the game-over screen and begins a new round.
fn @types.Game::update_game_over(game : @types.Game) -> Unit {
  if game.input.press_restart || game.input.press_start {
    game.start_round()
  }
}

///|
/// Processes all play-state logic: cursor movement, cooking, order updates, combo, spawning, and effect timers.
fn @types.Game::update_play(game : @types.Game, dt : Float) -> Unit {
  if game.input.press_restart {
    game.start_round()
    return
  }

  if game.input.press_pause {
    game.state = Paused
    return
  }

  if game.input.move_x != 0 || game.input.move_y != 0 {
    game.move_cursor(game.input.move_x, game.input.move_y)
  }

  if game.input.press_space {
    game.activate_boost()
  }

  if game.input.press_j {
    game.apply_press_j()
  }

  if game.input.press_k {
    game.apply_press_k()
  }

  game.update_boost(dt)
  game.update_cooking_passive(dt)
  game.update_orders(dt)

  if game.state == Play {
    game.update_ready_dish(dt)
    game.update_spawn(dt)
    game.update_combo_timer(dt)
    game.ensure_selected_order()
    game.elapsed_t = game.elapsed_t + dt
  }
}

///|
/// Capture input and advance one frame of chef-duel simulation.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.capture_input()
  let frame_dt = @types.clampf(dt, 0.0, 0.05)

  match game.state {
    Title => game.update_title()
    Play => game.update_play(frame_dt)
    Paused => game.update_paused()
    GameOver => game.update_game_over()
  }

  game.update_effects(frame_dt)
}
