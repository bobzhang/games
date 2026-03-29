///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.frame_count += 1
  clear_events(game)
  // Hit pause
  if game.hit_pause_timer > 0.0 {
    game.hit_pause_timer -= dt
    update_camera(game, dt)
    return
  }
  match game.state {
    Title => update_title(game)
    Playing => update_playing(game, dt)
    Paused => update_paused(game)
    GameOver => update_game_over(game)
    Victory => update_victory(game)
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) || @raylib.is_key_pressed(@raylib.KeySpace) {
    start_new_run(game)
  }
}

///|
fn update_playing(game : @types.Game, dt : Float) -> Unit {
  // Floor transition overlay
  if game.floor_transition_timer > 0.0 {
    game.floor_transition_timer -= dt
    return
  }
  let input = read_input(game)
  if input.pause_pressed {
    game.state = Paused
    return
  }
  update_player_movement(game, input, dt)
  update_player_combat(game, input, dt)
  update_player_state(game, dt)
  update_status_effects(game, dt)
  update_enemies(game, dt)
  update_boss(game, dt)
  update_projectiles(game, dt)
  update_homing_projectiles(game, dt)
  update_items(game, dt)
  update_shop(game, input)
  update_reward_choice(game, input)
  update_damage_numbers(game, dt)
  update_particles(game, dt)
  update_camera(game, dt)
  process_events(game)
  update_room_flow(game, dt)
  if game.room_clear_timer > 0.0 {
    game.room_clear_timer -= dt
  }
  // Check stairs interaction (require pressing E)
  if game.stairs_active && !game.reward_active {
    let d2 = @types.dist2(
      game.player.x, game.player.y, game.stairs_x, game.stairs_y,
    )
    if d2 < 30.0 * 30.0 && input.interact_pressed {
      advance_floor(game)
    }
  }
}

///|
fn update_paused(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = Playing
  }
}

///|
fn update_game_over(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) || @raylib.is_key_pressed(@raylib.KeySpace) {
    start_new_run(game)
  }
}

///|
fn update_victory(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    start_new_run(game)
  }
}

///|
fn start_new_run(game : @types.Game) -> Unit {
  // Reset player
  let p = game.player
  p.x = 400.0
  p.y = 300.0
  p.vx = 0.0
  p.vy = 0.0
  p.hp = 100
  p.max_hp = 100
  p.shield = 30.0
  p.max_shield = 30.0
  p.shield_regen_timer = 0.0
  p.invuln_timer = 0.0
  p.dash_cooldown = 0.0
  p.dash_timer = 0.0
  p.weapon = Sword
  p.attack_state = Idle
  p.combo_count = 0
  p.combo_timer = 0.0
  p.attack_buffered = false
  p.speed = 1.0
  p.damage_mult = 1.0
  p.crit_chance = 0.05
  p.defense = 0
  p.gold = 0
  p.dead = false
  p.passives.clear()
  p.status_effects.clear()
  // Clear shop
  for i in 0..<game.shop_items.length() {
    game.shop_items[i].active = false
  }
  game.shop_active = false
  // Clear reward choices
  game.reward_active = false
  game.reward_choices.clear()
  // Clear pools
  for i in 0..<game.enemies.length() {
    game.enemies[i].active = false
  }
  for i in 0..<game.projectiles.length() {
    game.projectiles[i].active = false
  }
  for i in 0..<game.items.length() {
    game.items[i].active = false
  }
  for i in 0..<game.particles.length() {
    game.particles[i].active = false
  }
  for i in 0..<game.damage_numbers.length() {
    game.damage_numbers[i].active = false
  }
  game.events.clear()
  // Reset stats
  game.enemies_killed = 0
  game.rooms_cleared = 0
  game.floor_rooms_cleared = 0
  game.stairs_active = false
  game.boss_active = false
  game.boss_phase = 0
  game.boss_phase_timer = 0.0
  game.boss_attack_pattern = 0
  game.floor_transition_timer = 0.0
  // Generate floor
  game.floor_num = 1
  let (floor, new_rng) = @dungeon.generate_floor(game.floor_num, game.rng_state)
  game.rng_state = new_rng
  game.floor = Some(floor)
  // Position player in center of start room
  let room = floor.rooms[0]
  let ts = @types.tile_sizef
  p.x = (Float::from_int(room.x) + Float::from_int(room.w) / 2.0) * ts
  p.y = (Float::from_int(room.y) + Float::from_int(room.h) / 2.0) * ts
  // Camera snap
  game.camera.x = p.x
  game.camera.y = p.y
  // Reveal adjacent rooms from start
  reveal_adjacent_rooms(floor, 0)
  // Room flow will handle enemy spawning when the room is entered
  game.room_clear_timer = 0.0
  game.state = Playing
}

///|
fn advance_floor(game : @types.Game) -> Unit {
  game.floor_num += 1
  // Check victory condition (floor 10 cleared)
  if game.floor_num > 10 {
    game.state = Victory
    return
  }
  // Clear shop
  for i in 0..<game.shop_items.length() {
    game.shop_items[i].active = false
  }
  game.shop_active = false
  // Clear reward choices
  game.reward_active = false
  game.reward_choices.clear()
  // Clear pools
  for i in 0..<game.enemies.length() {
    game.enemies[i].active = false
  }
  for i in 0..<game.projectiles.length() {
    game.projectiles[i].active = false
  }
  for i in 0..<game.items.length() {
    game.items[i].active = false
  }
  for i in 0..<game.particles.length() {
    game.particles[i].active = false
  }
  for i in 0..<game.damage_numbers.length() {
    game.damage_numbers[i].active = false
  }
  game.events.clear()
  game.stairs_active = false
  game.floor_rooms_cleared = 0
  game.boss_active = false
  game.boss_phase = 0
  game.boss_phase_timer = 0.0
  game.boss_attack_pattern = 0
  // Generate new floor
  let (floor, new_rng) = @dungeon.generate_floor(game.floor_num, game.rng_state)
  game.rng_state = new_rng
  game.floor = Some(floor)
  // Position player at start room center
  let room = floor.rooms[0]
  let ts = @types.tile_sizef
  game.player.x = (Float::from_int(room.x) + Float::from_int(room.w) / 2.0) * ts
  game.player.y = (Float::from_int(room.y) + Float::from_int(room.h) / 2.0) * ts
  game.camera.x = game.player.x
  game.camera.y = game.player.y
  // Reveal adjacent rooms from start
  reveal_adjacent_rooms(floor, 0)
  game.room_clear_timer = 0.0
  game.floor_transition_timer = 2.0
}

///|
pub fn update_particles(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.particles.length() {
    let p = game.particles[i]
    if !p.active {
      continue
    }
    p.life -= dt
    if p.life <= 0.0 {
      p.active = false
      continue
    }
    p.x += p.vx * dt
    p.y += p.vy * dt
    p.vx *= 0.96
    p.vy *= 0.96
    p.size *= 0.98
  }
}

///|
pub fn spawn_particles_burst(
  game : @types.Game,
  x : Float,
  y : Float,
  count : Int,
  r : Int,
  g : Int,
  b : Int
) -> Unit {
  for _i in 0..<count {
    let idx = @types.alloc_particle(game.particles)
    let p = game.particles[idx]
    p.active = true
    p.x = x
    p.y = y
    let (s1, vx) = @types.rng_range(game.rng_state, -200.0, 200.0)
    let (s2, vy) = @types.rng_range(s1, -200.0, 200.0)
    let (s3, life) = @types.rng_range(s2, 0.3, 0.8)
    let (s4, size) = @types.rng_range(s3, 2.0, 6.0)
    game.rng_state = s4
    p.vx = vx
    p.vy = vy
    p.life = life
    p.max_life = life
    p.size = size
    p.r = r
    p.g = g
    p.b = b
  }
}

///|
fn process_events(game : @types.Game) -> Unit {
  for i in 0..<game.events.length() {
    match game.events[i] {
      Hit(x, y, _damage, is_crit) => {
        let (r, g, b) = if is_crit { (255, 200, 50) } else { (255, 160, 100) }
        spawn_particles_burst(game, x, y, if is_crit { 12 } else { 6 }, r, g, b)
      }
      Kill(_kind, x, y) =>
        spawn_particles_burst(game, x, y, 20, 200, 60, 60)
      PlayerDamaged(_amount, x, y) =>
        spawn_particles_burst(game, x, y, 8, 255, 80, 80)
      DashUsed(x, y, _dx, _dy) =>
        spawn_particles_burst(game, x, y, 5, 100, 200, 255)
      Pickup(_kind, x, y) =>
        spawn_particles_burst(game, x, y, 4, 255, 215, 0)
      _ => ()
    }
  }
}
