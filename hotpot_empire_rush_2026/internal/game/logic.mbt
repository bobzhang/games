///|
/// Clears the player hand to the empty ingredient state.
fn @types.Game::clear_hand(game : @types.Game) -> Unit {
  game.hand.kind = @types.ingredient_none
  game.hand.flavor = 0
  game.hand.prepped = false
}

///|
/// Resets the prep board to its idle state with default timing target.
fn @types.Game::clear_prep(game : @types.Game) -> Unit {
  game.prep.active = false
  game.prep.kind = @types.ingredient_none
  game.prep.flavor = 0
  game.prep.progress = 0.0
  game.prep.target = @types.prep_target_base
  game.prep.output_ready = false
  game.prep.out_kind = @types.ingredient_none
  game.prep.out_flavor = 0
}

///|
/// Resets the hotpot to an empty, non-cooking state with default target.
fn @types.Game::clear_pot(game : @types.Game) -> Unit {
  game.pot.broth = -1
  game.pot.protein = -1
  game.pot.veg = -1
  game.pot.spice = 0
  game.pot.cooking = false
  game.pot.progress = 0.0
  game.pot.target = @types.cook_target_base
  game.pot.ready = false
}

///|
/// Deactivates all order slots and zeroes their fields.
fn @types.Game::clear_orders(game : @types.Game) -> Unit {
  for i in 0..<@types.max_orders {
    game.orders[i].active = false
    game.orders[i].id = i + 1
    game.orders[i].broth = 0
    game.orders[i].protein = 0
    game.orders[i].veg = 0
    game.orders[i].spice = 0
    game.orders[i].patience = 0.0
    game.orders[i].max_patience = 0.0
    game.orders[i].pulse = 0.0
  }
}

///|
/// Initialises a fresh kitchen run: resets state, meters, timers, and spawns two orders.
fn @types.Game::start_run(game : @types.Game) -> Unit {
  game.state = @types.state_playing
  game.cursor_x = 1
  game.cursor_y = 1

  game.score = 0
  game.combo = 0
  game.combo_t = 0.0
  game.reputation = @types.reputation_start
  game.boost_meter = @types.boost_meter_max
  game.boost_t = 0.0
  game.rush_cd = 0.0
  game.spawn_cd = 0.9
  game.order_serial = 1
  game.elapsed = 0.0
  game.served = 0
  game.failed = 0
  game.next_protein_pick = @raylib.get_random_value(0, @types.protein_count - 1)
  game.next_veg_pick = @raylib.get_random_value(0, @types.veg_count - 1)
  game.flash_t = 0.0

  game.clear_hand()
  game.clear_prep()
  game.clear_pot()
  game.clear_orders()
  ignore(game.spawn_order())
  ignore(game.spawn_order())

  @types.set_message(game, "Kitchen open. Build orders from the queue head.")
}

///|
/// Returns a random float uniformly sampled from `[lo, hi]`.
fn randf(lo : Float, hi : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
/// Returns the current order spawn interval, decreasing with elapsed time.
fn spawn_interval(elapsed : Float) -> Float {
  @types.clampf(4.3 - elapsed * 0.045, 1.1, 4.3)
}

///|
/// Returns a randomised patience value for a new order, decreasing with elapsed time.
fn spawn_patience(elapsed : Float) -> Float {
  let base : Float = 26.0 - @types.minf(11.0, elapsed * 0.24)
  @types.clampf(base + randf(-2.2, 2.8), 11.0, 30.0)
}

///|
/// Returns the count of currently active orders in the queue.
fn @types.Game::active_order_count(game : @types.Game) -> Int {
  let mut count = 0
  for i in 0..<@types.max_orders {
    if game.orders[i].active {
      count = count + 1
    }
  }
  count
}

///|
/// Removes the order at `idx`, shifting remaining orders left and clearing the tail slot.
fn @types.Game::remove_order_at(game : @types.Game, idx : Int) -> Unit {
  if idx < 0 || idx >= @types.max_orders {
    return
  }

  let mut i = idx
  while i < @types.max_orders - 1 {
    game.orders[i].active = game.orders[i + 1].active
    game.orders[i].id = game.orders[i + 1].id
    game.orders[i].broth = game.orders[i + 1].broth
    game.orders[i].protein = game.orders[i + 1].protein
    game.orders[i].veg = game.orders[i + 1].veg
    game.orders[i].spice = game.orders[i + 1].spice
    game.orders[i].patience = game.orders[i + 1].patience
    game.orders[i].max_patience = game.orders[i + 1].max_patience
    game.orders[i].pulse = game.orders[i + 1].pulse
    i = i + 1
  }

  let tail = @types.max_orders - 1
  game.orders[tail].active = false
  game.orders[tail].id = game.order_serial + tail
  game.orders[tail].broth = 0
  game.orders[tail].protein = 0
  game.orders[tail].veg = 0
  game.orders[tail].spice = 0
  game.orders[tail].patience = 0.0
  game.orders[tail].max_patience = 0.0
  game.orders[tail].pulse = 0.0
}

///|
/// Spawns a new order in the first free slot; returns false if the queue is full.
fn @types.Game::spawn_order(game : @types.Game) -> Bool {
  let mut slot = -1
  for i in 0..<@types.max_orders {
    if not(game.orders[i].active) {
      slot = i
      break
    }
  }

  if slot < 0 {
    return false
  }

  let spice_cap = if game.elapsed >= 70.0 {
    2
  } else if game.elapsed >= 25.0 {
    1
  } else {
    0
  }

  game.orders[slot].active = true
  game.orders[slot].id = game.order_serial
  game.orders[slot].broth = @raylib.get_random_value(0, @types.broth_count - 1)
  game.orders[slot].protein = @raylib.get_random_value(
    0,
    @types.protein_count - 1,
  )
  game.orders[slot].veg = @raylib.get_random_value(0, @types.veg_count - 1)
  game.orders[slot].spice = @raylib.get_random_value(0, spice_cap)
  game.orders[slot].max_patience = spawn_patience(game.elapsed)
  game.orders[slot].patience = game.orders[slot].max_patience
  game.orders[slot].pulse = randf(0.0, 6.28)

  game.order_serial = game.order_serial + 1
  true
}

///|
/// Moves the cursor by `(dx, dy)` within grid bounds and updates the HUD message.
fn @types.Game::move_cursor(game : @types.Game, dx : Int, dy : Int) -> Unit {
  game.cursor_x = (game.cursor_x + dx).clamp(min=0, max=@types.station_cols - 1)
  game.cursor_y = (game.cursor_y + dy).clamp(min=0, max=@types.station_rows - 1)
  @types.set_message(
    game,
    @types.station_name(@types.station_at(game.cursor_x, game.cursor_y)),
  )
}

///|
/// Returns true when the pot has broth, protein, and veg set.
fn @types.Game::pot_has_core(game : @types.Game) -> Bool {
  game.pot.broth >= 0 && game.pot.protein >= 0 && game.pot.veg >= 0
}

///|
/// Returns true when the pot contains any ingredient or is cooking/ready.
fn @types.Game::pot_has_anything(game : @types.Game) -> Bool {
  game.pot.broth >= 0 ||
  game.pot.protein >= 0 ||
  game.pot.veg >= 0 ||
  game.pot.cooking ||
  game.pot.ready
}

///|
/// Handles J interaction at the broth station: cycles broth selection.
fn @types.Game::interact_broth(game : @types.Game) -> Unit {
  if game.pot.ready || game.pot.cooking {
    @types.set_message(game, "Pot is locked while cooking/ready.")
    return
  }

  if game.pot.broth < 0 {
    game.pot.broth = 0
  } else {
    game.pot.broth = (game.pot.broth + 1) % @types.broth_count
  }

  @types.set_message(game, "Broth set: \{@types.broth_name(game.pot.broth)}")
}

///|
/// Handles J interaction at the protein station: picks a raw protein into hand.
fn @types.Game::interact_protein(game : @types.Game) -> Unit {
  if game.hand.kind != @types.ingredient_none {
    @types.set_message(game, "Hands full. Drop with K or trash station.")
    return
  }

  game.hand.kind = @types.ingredient_protein
  game.hand.flavor = game.next_protein_pick
  game.hand.prepped = false
  game.next_protein_pick = (game.next_protein_pick + 1) % @types.protein_count

  @types.set_message(
    game,
    "Picked raw \{@types.protein_name(game.hand.flavor)}",
  )
}

///|
/// Handles J interaction at the veg station: picks a raw vegetable into hand.
fn @types.Game::interact_veg(game : @types.Game) -> Unit {
  if game.hand.kind != @types.ingredient_none {
    @types.set_message(game, "Hands full. Drop with K or trash station.")
    return
  }

  game.hand.kind = @types.ingredient_veg
  game.hand.flavor = game.next_veg_pick
  game.hand.prepped = false
  game.next_veg_pick = (game.next_veg_pick + 1) % @types.veg_count

  @types.set_message(game, "Picked raw \{@types.veg_name(game.hand.flavor)}")
}

///|
/// Handles J interaction at the spice station: cycles the pot spice level.
fn @types.Game::interact_spice(game : @types.Game) -> Unit {
  if game.pot.ready || game.pot.cooking {
    @types.set_message(game, "Spice can only be adjusted before cooking.")
    return
  }

  game.pot.spice = (game.pot.spice + 1) % @types.spice_levels
  @types.set_message(game, "Spice level: \{@types.spice_name(game.pot.spice)}")
}

///|
/// Handles J interaction at the prep board: starts prep, reports progress, or collects output.
fn @types.Game::interact_prep(game : @types.Game) -> Unit {
  if game.prep.active {
    let percent = (game.prep.progress /
      @types.maxf(game.prep.target, 0.01) *
      100.0)
      .to_int()
      .clamp(min=0, max=100)
    @types.set_message(game, "Prep in progress \{percent}%")
    return
  }

  if game.prep.output_ready {
    if game.hand.kind != @types.ingredient_none {
      @types.set_message(game, "Hands full. Cannot collect prepped ingredient.")
      return
    }

    game.hand.kind = game.prep.out_kind
    game.hand.flavor = game.prep.out_flavor
    game.hand.prepped = true
    game.prep.output_ready = false
    game.prep.out_kind = @types.ingredient_none
    game.prep.out_flavor = 0

    if game.hand.kind == @types.ingredient_protein {
      @types.set_message(
        game,
        "Collected sliced \{@types.protein_name(game.hand.flavor)}",
      )
    } else {
      @types.set_message(
        game,
        "Collected cleaned \{@types.veg_name(game.hand.flavor)}",
      )
    }
    return
  }

  if game.hand.kind == @types.ingredient_none {
    @types.set_message(game, "Bring raw protein/veg to prep.")
    return
  }

  if game.hand.prepped {
    @types.set_message(game, "Already prepped. Move item to pot.")
    return
  }

  if game.hand.kind != @types.ingredient_protein &&
    game.hand.kind != @types.ingredient_veg {
    @types.set_message(game, "Only protein or veg can be prepped.")
    return
  }

  game.prep.active = true
  game.prep.kind = game.hand.kind
  game.prep.flavor = game.hand.flavor
  game.prep.progress = 0.0
  game.prep.target = @types.prep_target_base +
    Float::from_int(game.hand.flavor) * 0.28

  game.clear_hand()
  @types.set_message(game, "Prep started.")
}

///|
/// Handles J interaction at the pot: loads prepped ingredients or starts cooking.
fn @types.Game::interact_pot(game : @types.Game) -> Unit {
  if game.pot.ready {
    @types.set_message(game, "Hotpot ready. Serve it with K at counter.")
    return
  }

  if game.hand.kind == @types.ingredient_protein && game.hand.prepped {
    if game.pot.protein >= 0 {
      @types.set_message(game, "Protein already loaded in pot.")
      return
    }
    game.pot.protein = game.hand.flavor
    game.clear_hand()
    @types.set_message(game, "Protein loaded into pot.")
    return
  }

  if game.hand.kind == @types.ingredient_veg && game.hand.prepped {
    if game.pot.veg >= 0 {
      @types.set_message(game, "Veg already loaded in pot.")
      return
    }
    game.pot.veg = game.hand.flavor
    game.clear_hand()
    @types.set_message(game, "Veg loaded into pot.")
    return
  }

  if game.hand.kind != @types.ingredient_none {
    @types.set_message(game, "Only prepped protein/veg can enter the pot.")
    return
  }

  if game.pot.cooking {
    @types.set_message(game, "Pot is simmering.")
    return
  }

  if not(game.pot_has_core()) {
    @types.set_message(
      game, "Pot requires broth + protein + veg before cooking.",
    )
    return
  }

  game.pot.cooking = true
  game.pot.progress = 0.0
  game.pot.target = @types.maxf(
    2.7,
    @types.cook_target_base - Float::from_int(game.pot.spice) * 0.55,
  )

  @types.set_message(game, "Cooking started. Wait for full simmer.")
}

///|
/// Handles J interaction at the rush bell: adds boost meter charge with a cooldown.
fn @types.Game::interact_rush(game : @types.Game) -> Unit {
  if game.rush_cd > 0.0 {
    let wait_s = game.rush_cd.to_int() + 1
    @types.set_message(game, "Rush bell cooling down \{wait_s}s")
    return
  }

  game.boost_meter = @types.clampf(
    game.boost_meter + 24.0,
    0.0,
    @types.boost_meter_max,
  )
  game.rush_cd = @types.rush_cooldown
  @types.set_message(game, "Rush bell rang. Boost meter refilled.")
}

///|
/// Handles J interaction at the trash station: discards the held ingredient.
fn @types.Game::interact_trash(game : @types.Game) -> Unit {
  if game.hand.kind == @types.ingredient_none {
    @types.set_message(game, "Nothing in hand to trash.")
    return
  }

  game.clear_hand()
  @types.set_message(game, "Ingredient discarded.")
}

///|
/// Handles J interaction at the queue monitor: repeats the head order demand as a message.
fn @types.Game::interact_queue(game : @types.Game) -> Unit {
  if game.orders[0].active {
    @types.set_message(
      game,
      "Queue head wants \{@types.broth_name(game.orders[0].broth)} / \{@types.protein_name(game.orders[0].protein)} / \{@types.veg_name(game.orders[0].veg)} / \{@types.spice_name(game.orders[0].spice)}",
    )
  } else {
    @types.set_message(game, "No active customer right now.")
  }
}

///|
/// Handles J interaction at the storage station: randomises the upcoming ingredient picks.
fn @types.Game::interact_storage(game : @types.Game) -> Unit {
  game.next_protein_pick = @raylib.get_random_value(0, @types.protein_count - 1)
  game.next_veg_pick = @raylib.get_random_value(0, @types.veg_count - 1)
  @types.set_message(game, "Storage shuffled upcoming ingredients.")
}

///|
/// Dispatches J interaction to the appropriate station handler.
fn @types.Game::handle_interact(game : @types.Game) -> Unit {
  let station = @types.station_at(game.cursor_x, game.cursor_y)

  if station == @types.station_broth {
    game.interact_broth()
  } else if station == @types.station_protein {
    game.interact_protein()
  } else if station == @types.station_veg {
    game.interact_veg()
  } else if station == @types.station_spice {
    game.interact_spice()
  } else if station == @types.station_prep {
    game.interact_prep()
  } else if station == @types.station_pot {
    game.interact_pot()
  } else if station == @types.station_rush {
    game.interact_rush()
  } else if station == @types.station_trash {
    game.interact_trash()
  } else if station == @types.station_queue {
    game.interact_queue()
  } else if station == @types.station_reputation {
    @types.set_message(
      game, "Reputation controls game over. Keep orders flowing.",
    )
  } else if station == @types.station_storage {
    game.interact_storage()
  } else {
    @types.set_message(game, "No interaction at this station.")
  }
}

///|
/// Returns true when the ready pot exactly matches the head order.
fn @types.Game::serve_matches_head(game : @types.Game) -> Bool {
  if not(game.orders[0].active) {
    return false
  }

  game.pot.broth == game.orders[0].broth &&
  game.pot.protein == game.orders[0].protein &&
  game.pot.veg == game.orders[0].veg &&
  game.pot.spice == game.orders[0].spice
}

///|
/// Serves the ready pot against the head order, scoring or penalising accordingly.
fn @types.Game::serve_head_order(game : @types.Game) -> Unit {
  if not(game.pot.ready) {
    @types.set_message(game, "No finished pot to serve.")
    return
  }

  if not(game.orders[0].active) {
    game.combo = 0
    game.combo_t = 0.0
    game.failed = game.failed + 1
    game.reputation = @types.clampf(
      game.reputation - @types.rep_loss_wrong_serve * 0.55,
      0.0,
      @types.reputation_max,
    )
    game.clear_pot()
    game.flash_t = 0.35
    @types.set_message(game, "Served with no queue head. Reputation down.")
    return
  }

  if game.serve_matches_head() {
    let patience_ratio = @types.clampf(
      game.orders[0].patience / @types.maxf(game.orders[0].max_patience, 0.01),
      0.0,
      1.0,
    )
    let patience_bonus = (patience_ratio * 90.0).to_int()

    game.combo = game.combo + 1
    game.combo_t = @types.combo_keep_time

    let combo_bonus = game.combo * 20
    let gain = @types.score_base_serve + patience_bonus + combo_bonus

    game.score = game.score + gain
    if game.score > game.best_score {
      game.best_score = game.score
    }

    game.reputation = @types.clampf(
      game.reputation + @types.rep_gain_served,
      0.0,
      @types.reputation_max,
    )

    game.served = game.served + 1
    game.remove_order_at(0)
    game.clear_pot()
    game.flash_t = 0.14
    @types.set_message(game, "Serve success +\{gain} (combo x\{game.combo})")
    return
  }

  game.combo = 0
  game.combo_t = 0.0
  game.failed = game.failed + 1
  game.reputation = @types.clampf(
    game.reputation - @types.rep_loss_wrong_serve,
    0.0,
    @types.reputation_max,
  )
  game.clear_pot()
  game.flash_t = 0.42
  @types.set_message(game, "Wrong order served! Combo broken.")
}

///|
/// Handles K input: serves at the counter, discards the pot, cancels prep, or drops hand.
fn @types.Game::handle_serve_cancel(game : @types.Game) -> Unit {
  let station = @types.station_at(game.cursor_x, game.cursor_y)

  if station == @types.station_serve {
    game.serve_head_order()
    return
  }

  if station == @types.station_pot {
    if game.pot_has_anything() {
      game.clear_pot()
      game.combo = 0
      game.combo_t = 0.0
      game.reputation = @types.clampf(
        game.reputation - @types.rep_loss_discard_pot,
        0.0,
        @types.reputation_max,
      )
      game.flash_t = 0.2
      @types.set_message(game, "Pot discarded. Reputation down.")
    } else {
      @types.set_message(game, "Pot is already empty.")
    }
    return
  }

  if station == @types.station_prep {
    if game.prep.active || game.prep.output_ready {
      game.clear_prep()
      @types.set_message(game, "Prep canceled.")
      return
    }
  }

  if game.hand.kind != @types.ingredient_none {
    game.clear_hand()
    @types.set_message(game, "Held item canceled.")
    return
  }

  @types.set_message(game, "Nothing to cancel here.")
}

///|
/// Activates the speed boost if meter is sufficient and no boost is already active.
fn @types.Game::trigger_boost(game : @types.Game) -> Unit {
  if game.boost_t > 0.0 {
    @types.set_message(game, "Boost already active.")
    return
  }

  if game.boost_meter < @types.boost_cost {
    @types.set_message(game, "Not enough boost meter.")
    return
  }

  game.boost_meter = @types.clampf(
    game.boost_meter - @types.boost_cost,
    0.0,
    @types.boost_meter_max,
  )
  game.boost_t = @types.boost_duration
  @types.set_message(game, "Boost active: prep and cook speed doubled.")
}

///|
/// Returns the current speed multiplier: boost value when boost is active, else 1.0.
fn @types.Game::boost_multiplier(game : @types.Game) -> Float {
  if game.boost_t > 0.0 {
    @types.boost_speed_mult
  } else {
    1.0
  }
}

///|
/// Advances elapsed time, boost meter, boost timer, rush cooldown, combo timer, and flash timer.
fn @types.Game::update_play_timers(game : @types.Game, dt : Float) -> Unit {
  game.elapsed = game.elapsed + dt

  game.boost_meter = @types.clampf(
    game.boost_meter + dt * @types.boost_charge_per_s,
    0.0,
    @types.boost_meter_max,
  )

  if game.boost_t > 0.0 {
    game.boost_t = @types.maxf(0.0, game.boost_t - dt)
  }

  if game.rush_cd > 0.0 {
    game.rush_cd = @types.maxf(0.0, game.rush_cd - dt)
  }

  if game.combo_t > 0.0 {
    game.combo_t = game.combo_t - dt
    if game.combo_t <= 0.0 {
      game.combo_t = 0.0
      game.combo = 0
    }
  }

  if game.msg_t > 0.0 {
    game.msg_t = @types.maxf(0.0, game.msg_t - dt)
  }

  if game.flash_t > 0.0 {
    game.flash_t = @types.maxf(0.0, game.flash_t - dt)
  }
}

///|
/// Advances prep and cooking progress, triggering completion events as thresholds are reached.
fn @types.Game::update_prep_and_pot(game : @types.Game, dt : Float) -> Unit {
  let speed = game.boost_multiplier()

  if game.prep.active {
    game.prep.progress = game.prep.progress + dt * speed
    if game.prep.progress >= game.prep.target {
      game.prep.active = false
      game.prep.output_ready = true
      game.prep.out_kind = game.prep.kind
      game.prep.out_flavor = game.prep.flavor
      @types.set_message(game, "Prep finished. Collect with J.")
    }
  }

  if game.pot.cooking {
    game.pot.progress = game.pot.progress + dt * speed
    if game.pot.progress >= game.pot.target {
      game.pot.progress = game.pot.target
      game.pot.cooking = false
      game.pot.ready = true
      @types.set_message(game, "Pot done. Move to Serve Counter and press K.")
    }
  }
}

///|
/// Ticks order patience timers, removing timed-out orders and updating trust and flash state.
fn @types.Game::update_order_patience(game : @types.Game, dt : Float) -> Unit {
  let mut i = 0
  while i < @types.max_orders {
    if not(game.orders[i].active) {
      i = i + 1
      continue
    }

    game.orders[i].pulse = game.orders[i].pulse + dt
    game.orders[i].patience = game.orders[i].patience - dt

    if game.orders[i].patience <= 0.0 {
      game.combo = 0
      game.combo_t = 0.0
      game.failed = game.failed + 1
      game.reputation = @types.clampf(
        game.reputation - @types.rep_loss_timeout,
        0.0,
        @types.reputation_max,
      )
      game.flash_t = 0.36
      @types.set_message(game, "A customer rage-quit from the queue.")
      game.remove_order_at(i)
      continue
    }

    i = i + 1
  }
}

///|
/// Manages the order spawn countdown and spawns new orders or applies overflow pressure.
fn @types.Game::update_order_spawn(game : @types.Game, dt : Float) -> Unit {
  game.spawn_cd = game.spawn_cd - dt
  if game.spawn_cd > 0.0 {
    return
  }

  if game.active_order_count() < @types.max_orders {
    ignore(game.spawn_order())
    game.spawn_cd = spawn_interval(game.elapsed)
  } else {
    game.combo = 0
    game.combo_t = 0.0
    game.reputation = @types.clampf(
      game.reputation - 2.2,
      0.0,
      @types.reputation_max,
    )
    game.flash_t = 0.24
    @types.set_message(game, "Queue overflow pressure. Reputation dropped.")
    game.spawn_cd = 1.3
  }
}

///|
/// Handles one update tick in the title state: ticks message and transitions to play on start.
fn @types.Game::update_title(game : @types.Game, dt : Float) -> Unit {
  if game.msg_t > 0.0 {
    game.msg_t = @types.maxf(0.0, game.msg_t - dt)
  }

  if game.input.press_start {
    game.start_run()
  }
}

///|
/// Handles one update tick in the paused state: ticks message and transitions back to play.
fn @types.Game::update_paused(game : @types.Game, dt : Float) -> Unit {
  if game.msg_t > 0.0 {
    game.msg_t = @types.maxf(0.0, game.msg_t - dt)
  }

  if game.input.press_pause || game.input.press_start {
    game.state = @types.state_playing
    @types.set_message(game, "Rush resumed.")
  }
}

///|
/// Handles one update tick in the game-over state: ticks timers and transitions on restart.
fn @types.Game::update_game_over(game : @types.Game, dt : Float) -> Unit {
  if game.msg_t > 0.0 {
    game.msg_t = @types.maxf(0.0, game.msg_t - dt)
  }

  if game.flash_t > 0.0 {
    game.flash_t = @types.maxf(0.0, game.flash_t - dt)
  }

  if game.input.press_start {
    game.state = @types.state_title
    @types.set_message(game, "Press J to start another shift.")
  }
}

///|
/// Handles one full update tick during active gameplay including all input and timer systems.
fn @types.Game::update_playing(game : @types.Game, dt : Float) -> Unit {
  if game.input.press_pause {
    game.state = @types.state_paused
    @types.set_message(game, "Shift paused.")
    return
  }

  if game.input.move_x != 0 || game.input.move_y != 0 {
    game.move_cursor(game.input.move_x, game.input.move_y)
  }

  if game.input.press_boost {
    game.trigger_boost()
  }

  if game.input.press_interact {
    game.handle_interact()
  }

  if game.input.press_serve_cancel {
    game.handle_serve_cancel()
  }

  game.update_play_timers(dt)
  game.update_prep_and_pot(dt)
  game.update_order_patience(dt)
  game.update_order_spawn(dt)

  if game.reputation <= 0.0 {
    game.state = @types.state_game_over
    game.reputation = 0.0
    if game.score > game.best_score {
      game.best_score = game.score
    }
    game.flash_t = 0.6
    @types.set_message(game, "Reputation collapsed. Service over.")
  }
}

///|
/// Advances one frame of kitchen simulation and state transitions.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.update_input()

  if game.input.press_restart {
    game.start_run()
    return
  }

  if game.state == @types.state_title {
    game.update_title(dt)
  } else if game.state == @types.state_playing {
    game.update_playing(dt)
  } else if game.state == @types.state_paused {
    game.update_paused(dt)
  } else {
    game.update_game_over(dt)
  }
}
