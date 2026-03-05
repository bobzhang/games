///|
/// Sets the HUD status text and its display lifetime in seconds.
fn @types.Game::set_status(
  game : @types.Game,
  text : String,
  ttl : Float,
) -> Unit {
  game.status_text = text
  game.status_t = ttl
}

///|
/// Deactivates all node slots, resetting them to default values.
fn @types.Game::clear_nodes(game : @types.Game) -> Unit {
  for i in 0..<game.nodes.length() {
    game.nodes[i] = @types.Node::new()
  }
}

///|
/// Deactivates all enemy slots, resetting them to default values.
fn @types.Game::clear_enemies(game : @types.Game) -> Unit {
  for i in 0..<game.enemies.length() {
    game.enemies[i] = @types.Enemy::new()
  }
}

///|
/// Deactivates all bolt projectile slots, resetting them to default values.
fn @types.Game::clear_bolts(game : @types.Game) -> Unit {
  for i in 0..<game.bolts.length() {
    game.bolts[i] = @types.Bolt::new()
  }
}

///|
/// Deactivates all pulse effect slots, resetting them to default values.
fn @types.Game::clear_pulses(game : @types.Game) -> Unit {
  for i in 0..<game.pulses.length() {
    game.pulses[i] = @types.PulseFx::new()
  }
}

///|
/// Returns the index of the first inactive node slot, or -1 if the pool is full.
fn @types.Game::alloc_node(game : @types.Game) -> Int {
  for i, slot in game.nodes {
    if !slot.active {
      break i
    }
  } nobreak {
    -1
  }
}

///|
/// Returns the index of the first inactive enemy slot, or -1 if the pool is full.
fn @types.Game::alloc_enemy(game : @types.Game) -> Int {
  for i, slot in game.enemies {
    if !slot.active {
      break i
    }
  } nobreak {
    -1
  }
}

///|
/// Returns the index of the first inactive bolt slot, or -1 if the pool is full.
fn @types.Game::alloc_bolt(game : @types.Game) -> Int {
  for i, slot in game.bolts {
    if !slot.active {
      break i
    }
  } nobreak {
    -1
  }
}

///|
/// Returns the index of the first inactive pulse slot, or -1 if the pool is full.
fn @types.Game::alloc_pulse(game : @types.Game) -> Int {
  for i, slot in game.pulses {
    if !slot.active {
      break i
    }
  } nobreak {
    -1
  }
}

///|
/// Spawns a ring pulse effect at the given world position with the specified radius, lifetime, and kind.
fn @types.Game::emit_pulse(
  game : @types.Game,
  x : Float,
  y : Float,
  start_radius : Float,
  life : Float,
  kind : Int,
) -> Unit {
  let i = game.alloc_pulse()
  if i < 0 {
    return
  }

  game.pulses[i] = {
    active: true,
    x,
    y,
    radius: start_radius,
    life,
    max_life: life,
    kind,
  }
}

///|
/// Returns the number of currently active enemies.
fn @types.Game::active_enemy_count(game : @types.Game) -> Int {
  let mut count = 0
  for enemy in game.enemies {
    if enemy.active {
      count = count + 1
    }
  }
  count
}

///|
/// Increments the wave counter, queues enemy spawns, awards wave energy, and sets status text.
fn @types.Game::begin_next_wave(game : @types.Game) -> Unit {
  game.wave = game.wave + 1
  game.pending_spawns = @types.wave_spawn_count(game.wave)
  game.spawn_cd = 0.35
  game.wave_delay = @types.wave_intro_delay
  game.energy = @types.minf(
    @types.energy_max,
    game.energy + @types.wave_energy_bonus + Float::from_int(game.wave) * 1.5,
  )
  game.set_status("Wave " + game.wave.to_string() + " incoming", 1.5)
}

///|
/// Resets all pools and counters, then begins wave 1 of a new defense run.
fn @types.Game::start_new_run(game : @types.Game) -> Unit {
  game.clear_nodes()
  game.clear_enemies()
  game.clear_bolts()
  game.clear_pulses()

  game.state = Playing
  game.score = 0
  game.kills = 0
  game.wave = 0
  game.pending_spawns = 0
  game.spawn_cd = 0.0
  game.wave_delay = 0.0
  game.gate_hp = @types.gate_hp_max
  game.energy = @types.energy_start
  game.barrier_charge = 0.0
  game.barrier_flash = 0.0
  game.combo = 0
  game.combo_timer = 0.0
  game.shake_t = 0.0
  game.cursor_x = @types.gate_gx + 1
  game.cursor_y = @types.gate_gy
  game.cursor_dir = Left

  game.set_status("Deploy guardians and hold the moon gate", 1.7)
  game.begin_next_wave()
}

///|
/// Transitions to the game-over state, finalises the best score, and sets status text.
fn @types.Game::enter_game_over(game : @types.Game) -> Unit {
  if game.state == GameOver {
    return
  }

  game.state = GameOver
  game.pending_spawns = 0
  game.spawn_cd = 0.0
  game.wave_delay = 0.0
  game.combo = 0
  game.combo_timer = 0.0

  if game.score > game.best_score {
    game.best_score = game.score
  }

  game.set_status("The moon gate has fallen", 2.0)
}

///|
/// Returns the index of the node at grid cell `(gx, gy)`, or -1 if none exists.
fn @types.Game::find_node_at(game : @types.Game, gx : Int, gy : Int) -> Int {
  for i in 0..<game.nodes.length() {
    if game.nodes[i].active && game.nodes[i].gx == gx && game.nodes[i].gy == gy {
      return i
    }
  }
  -1
}

///|
/// Moves the placement cursor one cell in the input direction and updates the last-moved direction.
fn @types.Game::move_cursor(game : @types.Game) -> Unit {
  if game.input_move_x < 0 {
    game.cursor_x = (game.cursor_x - 1).clamp(min=0, max=@types.grid_cols - 1)
    game.cursor_dir = Left
  } else if game.input_move_x > 0 {
    game.cursor_x = (game.cursor_x + 1).clamp(min=0, max=@types.grid_cols - 1)
    game.cursor_dir = Right
  }

  if game.input_move_y < 0 {
    game.cursor_y = (game.cursor_y - 1).clamp(min=0, max=@types.grid_rows - 1)
    game.cursor_dir = Up
  } else if game.input_move_y > 0 {
    game.cursor_y = (game.cursor_y + 1).clamp(min=0, max=@types.grid_rows - 1)
    game.cursor_dir = Down
  }
}

///|
/// Builds a new guardian node, rotates or upgrades an existing one at the cursor cell, spending energy as needed.
fn @types.Game::try_build_or_upgrade(game : @types.Game) -> Unit {
  let gx = game.cursor_x
  let gy = game.cursor_y

  if @types.is_gate_cell(gx, gy) {
    game.set_status("Gate tile reserved", 0.5)
    return
  }

  let node_index = game.find_node_at(gx, gy)
  if node_index < 0 {
    if game.energy < @types.node_build_cost {
      game.set_status("Not enough energy", 0.6)
      return
    }

    let slot = game.alloc_node()
    if slot < 0 {
      return
    }

    game.nodes[slot] = {
      active: true,
      gx,
      gy,
      level: 1,
      facing: game.cursor_dir,
      cooldown: 0.2,
      pulse: 1.0,
    }

    game.energy = game.energy - @types.node_build_cost
    game.emit_pulse(
      @types.cell_center_x(gx),
      @types.cell_center_y(gy),
      14.0,
      0.38,
      0,
    )
    game.set_status("Guardian deployed", 0.5)
    return
  }

  if game.nodes[node_index].facing != game.cursor_dir {
    game.nodes[node_index].facing = game.cursor_dir
    game.nodes[node_index].pulse = 0.6
    game.emit_pulse(
      @types.cell_center_x(gx),
      @types.cell_center_y(gy),
      12.0,
      0.24,
      0,
    )
    return
  }

  if game.nodes[node_index].level < @types.node_max_level {
    let next_level = game.nodes[node_index].level + 1
    let upgrade_cost = @types.node_upgrade_cost(next_level)

    if game.energy < upgrade_cost {
      game.set_status(
        "Need " + upgrade_cost.to_int().to_string() + " energy",
        0.6,
      )
      return
    }

    game.energy = game.energy - upgrade_cost
    game.nodes[node_index].level = next_level
    game.nodes[node_index].pulse = 1.2
    game.nodes[node_index].cooldown = @types.minf(
      game.nodes[node_index].cooldown,
      0.1,
    )
    game.emit_pulse(
      @types.cell_center_x(gx),
      @types.cell_center_y(gy),
      16.0,
      0.42,
      1,
    )
    game.set_status("Node upgraded to L" + next_level.to_string(), 0.7)
    return
  }

  game.nodes[node_index].facing = game.nodes[node_index].facing.rotate_cw()
  game.nodes[node_index].pulse = 0.45
}

///|
/// Removes the node at the cursor cell and refunds its energy value.
fn @types.Game::try_sell_node(game : @types.Game) -> Unit {
  let node_index = game.find_node_at(game.cursor_x, game.cursor_y)
  if node_index < 0 {
    game.set_status("No node on this tile", 0.5)
    return
  }

  let refund = @types.node_sell_refund(game.nodes[node_index].level)
  game.energy = @types.minf(@types.energy_max, game.energy + refund)
  game.nodes[node_index] = @types.Node::new()

  game.emit_pulse(
    @types.cell_center_x(game.cursor_x),
    @types.cell_center_y(game.cursor_y),
    20.0,
    0.45,
    2,
  )
  game.set_status("Salvaged +" + refund.to_int().to_string(), 0.55)
}

///|
/// Allocates a new enemy at a random screen edge with stats scaled to the current wave.
fn @types.Game::spawn_enemy(game : @types.Game) -> Bool {
  let slot = game.alloc_enemy()
  if slot < 0 {
    return false
  }

  let side = @types.randi(0, 3)
  let mut x : Float = 0.0
  let mut y : Float = 0.0
  if side == 0 {
    x = @types.randf(@types.board_left() + 10.0, @types.board_right() - 10.0)
    y = @types.board_top() - 42.0
  } else if side == 1 {
    x = @types.board_right() + 42.0
    y = @types.randf(@types.board_top() + 10.0, @types.board_bottom() - 10.0)
  } else if side == 2 {
    x = @types.randf(@types.board_left() + 10.0, @types.board_right() - 10.0)
    y = @types.board_bottom() + 42.0
  } else {
    x = @types.board_left() - 42.0
    y = @types.randf(@types.board_top() + 10.0, @types.board_bottom() - 10.0)
  }

  let mut kind : @types.EnemyKind = Skitter
  let roll = @types.randi(0, 99)
  let heavy_cut = 12 + (26).min(game.wave * 3)
  let wraith_cut = 72 - (22).min(game.wave * 2)

  if roll < heavy_cut {
    kind = Carapace
  } else if roll >= wraith_cut {
    kind = Wraith
  }

  let wavef = Float::from_int(game.wave - 1)
  let base_hp = @types.enemy_base_hp +
    wavef * @types.enemy_hp_per_wave +
    @types.randf(-2.0, 4.0)
  let base_speed = @types.enemy_base_speed +
    @types.minf(100.0, wavef * @types.enemy_speed_per_wave)

  let mut hp = base_hp
  let mut speed = base_speed
  let mut radius : Float = 12.0
  let mut reward = 8 + game.wave / 2
  let mut gate_damage = @types.enemy_contact_damage_base +
    wavef * @types.enemy_contact_damage_wave

  match kind {
    Carapace => {
      hp = base_hp * 1.85
      speed = base_speed * 0.78
      radius = 17.0
      reward = 14 + game.wave
      gate_damage = @types.enemy_contact_damage_base * 1.45 +
        wavef * @types.enemy_contact_damage_wave
    }
    Wraith => {
      hp = base_hp * 1.15
      speed = base_speed * 1.08
      radius = 13.0
      reward = 11 + game.wave
      gate_damage = @types.enemy_contact_damage_base * 1.05 +
        wavef * @types.enemy_contact_damage_wave * 0.9
    }
    _ => {
      hp = base_hp * 0.84
      speed = base_speed * 1.28
      radius = 10.0
      reward = 8 + game.wave / 2
      gate_damage = @types.enemy_contact_damage_base * 0.75 +
        wavef * @types.enemy_contact_damage_wave * 0.7
    }
  }

  game.enemies[slot] = {
    active: true,
    kind,
    x,
    y,
    vx: 0.0,
    vy: 0.0,
    hp,
    max_hp: hp,
    speed,
    radius,
    reward,
    gate_damage,
    phase: @types.randf(0.0, 6.283),
  }

  true
}

///|
/// Manages the wave intro delay, per-spawn cooldown, and triggers the next wave when all enemies are defeated.
fn @types.Game::update_wave_spawner(game : @types.Game, dt : Float) -> Unit {
  if game.wave_delay > 0.0 {
    game.wave_delay = @types.maxf(0.0, game.wave_delay - dt)
  }

  if game.pending_spawns > 0 {
    if game.wave_delay > 0.0 {
      return
    }

    game.spawn_cd = game.spawn_cd - dt
    if game.spawn_cd <= 0.0 {
      if game.spawn_enemy() {
        game.pending_spawns = game.pending_spawns - 1
      }
      game.spawn_cd = @types.wave_spawn_cd(game.wave)
    }
    return
  }

  if game.active_enemy_count() == 0 {
    game.begin_next_wave()
  }
}

///|
/// Fires a new bolt projectile from position `(x, y)` towards target `(tx, ty)` with the given damage.
fn @types.Game::spawn_bolt(
  game : @types.Game,
  x : Float,
  y : Float,
  tx : Float,
  ty : Float,
  dmg : Float,
) -> Unit {
  let slot = game.alloc_bolt()
  if slot < 0 {
    return
  }

  let dx = tx - x
  let dy = ty - y
  let d2 = dx * dx + dy * dy
  if d2 <= 0.0001 {
    return
  }

  let inv = Float::from_int(1) / d2.sqrt()
  game.bolts[slot] = {
    active: true,
    x,
    y,
    vx: dx * inv * @types.node_projectile_speed,
    vy: dy * inv * @types.node_projectile_speed,
    life: @types.bolt_life,
    dmg,
  }
}

///|
/// Deactivates an enemy, awards score with combo multiplier, restores energy, and contributes to barrier charge.
fn @types.Game::kill_enemy(
  game : @types.Game,
  enemy_index : Int,
  by_barrier : Bool,
) -> Unit {
  if enemy_index < 0 || not(game.enemies[enemy_index].active) {
    return
  }

  let reward = game.enemies[enemy_index].reward
  let hit_x = game.enemies[enemy_index].x
  let hit_y = game.enemies[enemy_index].y
  let hit_r = game.enemies[enemy_index].radius

  game.enemies[enemy_index].active = false
  game.kills = game.kills + 1

  if game.combo_timer > 0.0 {
    game.combo = game.combo + 1
  } else {
    game.combo = 1
  }
  game.combo_timer = @types.combo_window

  let combo_mult = 1 + (game.combo - 1) / @types.combo_score_step
  game.score = game.score + reward * combo_mult

  game.energy = @types.minf(
    @types.energy_max,
    game.energy + Float::from_int(reward) * 0.85,
  )

  let combo_for_charge = game.combo.min(@types.barrier_charge_combo_cap)
  game.barrier_charge = @types.minf(
    @types.barrier_charge_goal,
    game.barrier_charge +
    @types.barrier_charge_kill +
    Float::from_int(combo_for_charge) * @types.barrier_charge_combo,
  )

  game.emit_pulse(hit_x, hit_y, hit_r + 4.0, 0.42, 1)
  if by_barrier {
    game.emit_pulse(hit_x, hit_y, hit_r + 12.0, 0.48, 2)
  }

  if game.combo > 0 && game.combo % 6 == 0 {
    game.set_status("Combo x" + game.combo.to_string(), 0.5)
  }
}

///|
/// Ticks guardian cooldowns and fires bolts at the nearest in-cone enemy within range.
fn @types.Game::update_nodes(game : @types.Game, dt : Float) -> Unit {
  for node in game.nodes {
    if not(node.active) {
      continue
    }

    node.pulse = @types.maxf(0.0, node.pulse - dt * 2.8)

    if node.cooldown > 0.0 {
      node.cooldown = node.cooldown - dt
    }
    if node.cooldown > 0.0 {
      continue
    }

    let x = @types.cell_center_x(node.gx)
    let y = @types.cell_center_y(node.gy)
    let range = @types.node_range(node.level)
    let range2 = range * range
    let fx = @types.dir_vec_x(node.facing)
    let fy = @types.dir_vec_y(node.facing)

    let mut best = -1
    let mut best_d2 = range2
    for j in 0..<game.enemies.length() {
      if not(game.enemies[j].active) {
        continue
      }

      let dx = game.enemies[j].x - x
      let dy = game.enemies[j].y - y
      let d2 = dx * dx + dy * dy
      if d2 > range2 {
        continue
      }

      let dot = dx * fx + dy * fy
      if dot <= 0.0 {
        continue
      }

      if dot * dot < d2 * @types.node_cone_dot_sq {
        continue
      }

      if d2 < best_d2 {
        best = j
        best_d2 = d2
      }
    }

    if best >= 0 {
      game.spawn_bolt(
        x,
        y,
        game.enemies[best].x,
        game.enemies[best].y,
        @types.node_damage(node.level),
      )
      node.cooldown = @types.node_fire_cd(node.level)
      node.pulse = @types.maxf(node.pulse, 0.72)
    }
  }
}

///|
/// Advances all bolts, deactivates out-of-bounds ones, and applies damage and pulses on enemy hit.
fn @types.Game::update_bolts(game : @types.Game, dt : Float) -> Unit {
  for bolt in game.bolts {
    if not(bolt.active) {
      continue
    }

    bolt.life = bolt.life - dt
    if bolt.life <= 0.0 {
      bolt.active = false
      continue
    }

    bolt.x = bolt.x + bolt.vx * dt
    bolt.y = bolt.y + bolt.vy * dt

    if bolt.x < @types.board_left() - 110.0 ||
      bolt.x > @types.board_right() + 110.0 ||
      bolt.y < @types.board_top() - 110.0 ||
      bolt.y > @types.board_bottom() + 110.0 {
      bolt.active = false
      continue
    }

    for j in 0..<game.enemies.length() {
      if not(game.enemies[j].active) {
        continue
      }

      let hit_r = game.enemies[j].radius + @types.bolt_hit_radius
      let hit_r2 = hit_r * hit_r
      if @types.dist2(bolt.x, bolt.y, game.enemies[j].x, game.enemies[j].y) <=
        hit_r2 {
        game.enemies[j].hp = game.enemies[j].hp - bolt.dmg
        bolt.active = false
        game.emit_pulse(bolt.x, bolt.y, 7.0, 0.22, 0)

        if game.enemies[j].hp <= 0.0 {
          game.kill_enemy(j, false)
        }
        break
      }
    }
  }
}

///|
/// Moves all enemies toward the gate with wobble and handles contact damage and gate breach.
fn @types.Game::update_enemies(game : @types.Game, dt : Float) -> Unit {
  let gx = @types.gate_x()
  let gy = @types.gate_y()

  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      continue
    }

    game.enemies[i].phase = game.enemies[i].phase +
      dt * (1.2 + Float::from_int(game.enemies[i].kind.to_int()) * 0.35)

    let wobble : Float = match game.enemies[i].kind {
      Wraith => 28.0
      Carapace => 10.0
      _ => 16.0
    }

    let tx = gx +
      @math.sinf(game.enemies[i].phase * 1.6 + Float::from_int(i) * 0.13) *
      wobble
    let ty = gy +
      @math.cosf(game.enemies[i].phase * 1.3 + Float::from_int(i) * 0.11) *
      wobble

    let dx = tx - game.enemies[i].x
    let dy = ty - game.enemies[i].y
    let d2 = dx * dx + dy * dy

    if d2 > 1.0 {
      let inv = Float::from_int(1) / d2.sqrt()
      game.enemies[i].vx = dx * inv * game.enemies[i].speed
      game.enemies[i].vy = dy * inv * game.enemies[i].speed
    }

    game.enemies[i].x = game.enemies[i].x + game.enemies[i].vx * dt
    game.enemies[i].y = game.enemies[i].y + game.enemies[i].vy * dt

    let hit_r = @types.gate_hit_radius + game.enemies[i].radius
    if @types.dist2(game.enemies[i].x, game.enemies[i].y, gx, gy) <=
      hit_r * hit_r {
      game.gate_hp = @types.maxf(
        0.0,
        game.gate_hp - game.enemies[i].gate_damage,
      )
      game.enemies[i].active = false
      game.combo = 0
      game.combo_timer = 0.0
      game.shake_t = @types.maxf(game.shake_t, @types.shake_time_hit)
      game.emit_pulse(gx, gy, @types.gate_radius + 18.0, 0.48, 2)

      if game.gate_hp <= 0.0 {
        game.enter_game_over()
        return
      }
    }
  }
}

///|
/// Consumes a full barrier charge to deal damage and push all enemies within barrier radius.
fn @types.Game::trigger_barrier(game : @types.Game) -> Unit {
  if game.barrier_charge < @types.barrier_charge_goal {
    game.set_status("Barrier not charged", 0.5)
    return
  }

  game.barrier_charge = 0.0
  game.barrier_flash = @types.barrier_flash_time
  game.shake_t = @types.maxf(game.shake_t, 0.32)

  let gx = @types.gate_x()
  let gy = @types.gate_y()
  let radius2 = @types.barrier_radius * @types.barrier_radius

  game.emit_pulse(gx, gy, @types.gate_radius + 14.0, 0.58, 2)

  for i, enemy in game.enemies {
    if !enemy.active {
      continue
    }

    let dx = enemy.x - gx
    let dy = enemy.y - gy
    let d2 = dx * dx + dy * dy
    if d2 > radius2 {
      continue
    }

    enemy.hp = enemy.hp - @types.barrier_damage
    if enemy.hp <= 0.0 {
      game.kill_enemy(i, true)
      continue
    }

    if d2 > 1.0 {
      let inv = Float::from_int(1) / d2.sqrt()
      enemy.x = enemy.x + dx * inv * @types.barrier_push
      enemy.y = enemy.y + dy * inv * @types.barrier_push
      enemy.vx = enemy.vx + dx * inv * 80.0
      enemy.vy = enemy.vy + dy * inv * 80.0
    }
  }

  game.set_status("Barrier burst released", 0.7)
}

///|
/// Expands and expires all active ring pulse effects each frame.
fn @types.Game::update_pulses(game : @types.Game, dt : Float) -> Unit {
  for pulse in game.pulses {
    if not(pulse.active) {
      continue
    }

    pulse.life = pulse.life - dt
    if pulse.life <= 0.0 {
      pulse.active = false
      continue
    }

    let speed : Float = if pulse.kind == 0 {
      66.0
    } else if pulse.kind == 1 {
      92.0
    } else {
      120.0
    }
    pulse.radius = pulse.radius + dt * speed
  }
}

///|
/// Decrements the status, shake, and barrier flash timers by `dt`.
fn @types.Game::decay_overlay_timers(game : @types.Game, dt : Float) -> Unit {
  if game.status_t > 0.0 {
    game.status_t = @types.maxf(0.0, game.status_t - dt)
  }
  if game.shake_t > 0.0 {
    game.shake_t = @types.maxf(0.0, game.shake_t - dt)
  }
  if game.barrier_flash > 0.0 {
    game.barrier_flash = @types.maxf(0.0, game.barrier_flash - dt)
  }
}

///|
/// Handles input on the title screen to start a new run.
fn @types.Game::update_title_state(game : @types.Game) -> Unit {
  if game.input_place_press ||
    game.input_barrier_press ||
    game.input_restart_press {
    game.start_new_run()
  }
}

///|
/// Runs one frame of active gameplay: cursor movement, building, barrier, energy regen, and combat updates.
fn @types.Game::update_playing_state(game : @types.Game, dt : Float) -> Unit {
  if game.input_pause_press {
    game.state = Paused
    game.set_status("Paused", 0.4)
    return
  }

  game.move_cursor()

  if game.input_place_press {
    game.try_build_or_upgrade()
  }
  if game.input_cancel_press {
    game.try_sell_node()
  }
  if game.input_barrier_press {
    game.trigger_barrier()
  }

  game.energy = @types.minf(
    @types.energy_max,
    game.energy + (@types.energy_regen + Float::from_int(game.wave) * 0.22) * dt,
  )

  if game.combo_timer > 0.0 {
    game.combo_timer = game.combo_timer - dt
    if game.combo_timer <= 0.0 {
      game.combo_timer = 0.0
      game.combo = 0
    }
  }

  game.update_wave_spawner(dt)
  game.update_nodes(dt)
  game.update_bolts(dt)
  game.update_enemies(dt)
  game.update_pulses(dt)
}

///|
/// Handles input while paused to resume play.
fn @types.Game::update_paused_state(game : @types.Game) -> Unit {
  if game.input_pause_press || game.input_cancel_press {
    game.state = Playing
    game.set_status("Defense resumed", 0.5)
  }
}

///|
/// Handles input on the game-over screen to restart or return to title.
fn @types.Game::update_game_over_state(game : @types.Game) -> Unit {
  if game.input_place_press || game.input_restart_press {
    game.start_new_run()
    return
  }

  if game.input_cancel_press {
    game.clear_enemies()
    game.clear_bolts()
    game.clear_pulses()
    game.state = Title
    game.gate_hp = @types.gate_hp_max
    game.energy = @types.energy_start
    game.barrier_charge = 0.0
    game.set_status("Press J to begin defense", 0.0)
  }
}

///|
/// Advances one simulation step, including input, state transitions, and combat updates.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.update_input()
  game.time_s = game.time_s + dt

  if game.input_restart_press {
    game.start_new_run()
    return
  }

  match game.state {
    Title => {
      game.decay_overlay_timers(dt)
      game.update_pulses(dt)
      game.update_title_state()
    }
    Playing => {
      game.decay_overlay_timers(dt)
      game.update_playing_state(dt)
    }
    Paused => game.update_paused_state()
    _ => {
      game.decay_overlay_timers(dt)
      game.update_pulses(dt)
      game.update_game_over_state()
    }
  }
}
