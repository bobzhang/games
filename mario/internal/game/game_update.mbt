///|
/// Main update entry point — dispatches to the current game-state handler.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.frame_counter += 1
  update_clouds(game, dt)
  match game.state {
    Title => update_title(game)
    LevelIntro => update_level_intro(game, dt)
    Playing => update_playing(game, dt)
    Paused => update_paused(game)
    LevelClear => update_level_clear(game, dt)
    LevelTally => update_level_tally(game, dt)
    PlayerDied => update_player_died(game, dt)
    GameOver => update_game_over(game, dt)
    Victory => update_victory(game)
    BonusRoom => update_playing(game, dt)
  }
}

///|
fn update_clouds(game : @types.Game, dt : Float) -> Unit {
  let map_pixel_w = Float::from_int(game.map_width * @types.tile_size)
  for i in 0..<game.clouds.length() {
    let c = game.clouds[i]
    c.x = c.x + c.speed * dt
    if c.x > map_pixel_w + 200.0 {
      c.x = -c.w - 50.0
    }
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.score = 0
    game.coins = 0
    game.lives = 3
    game.level_index = 0
    game.world_num = 1
    game.level_num = 1
    game.saved_power = Small
    game.enemies_defeated = 0
    game.level_deaths = 0
    start_level_intro(game)
  }
}

///|
fn start_level_intro(game : @types.Game) -> Unit {
  game.state = LevelIntro
  game.intro_timer = 2.5
}

///|
fn update_level_intro(game : @types.Game, dt : Float) -> Unit {
  game.intro_timer = game.intro_timer - dt
  if game.intro_timer <= 0.0 {
    load_level(game, game.level_index)
    game.state = Playing
  }
}

///|
fn update_playing(game : @types.Game, dt : Float) -> Unit {
  // Bonus room fade-in
  if game.bonus_fade_timer > 0.0 {
    game.bonus_fade_timer = game.bonus_fade_timer - dt
    if game.bonus_fade_timer <= 0.0 {
      game.bonus_fade_timer = 0.0
    }
    return
  }
  // Timer countdown
  game.time_remaining = game.time_remaining - dt
  if game.time_remaining <= 0.0 {
    game.time_remaining = 0.0
    kill_player(game)
  }
  // Update all systems
  update_player(game, dt)
  update_enemies(game, dt)
  update_items(game, dt)
  update_fireballs(game, dt)
  update_particles(game, dt)
  update_score_popups(game, dt)
  update_bumped_blocks(game, dt)
  update_camera(game, dt)
  // Check boss defeated — route through tally like flagpole clears
  if game.boss_defeated {
    game.boss_defeated = false
    start_level_tally(game)
    return
  }
  // Check death pit
  let pit_y = Float::from_int(game.map_height * @types.tile_size + 100)
  if game.player.y > pit_y && not(game.player.dead) {
    kill_player(game)
  }
}

///|
fn update_paused(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyP) ||
    @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = Playing
  }
}

///|
fn update_level_clear(game : @types.Game, dt : Float) -> Unit {
  // Animate flag sliding down and Mario sliding with it
  if not(game.flag_done) {
    let slide_speed : Float = 300.0
    game.flag_y = game.flag_y + slide_speed * dt
    let p = game.player
    p.y = p.y + slide_speed * dt
    p.vy = 0.0
    p.vx = 0.0
    p.on_ground = false
    if game.flag_y >= game.flag_target_y {
      game.flag_y = game.flag_target_y
      game.flag_done = true
      game.mario_auto = true
    }
  }
  // Auto-walk Mario to the castle
  if game.mario_auto {
    let p = game.player
    p.vx = 120.0
    p.facing_right = true
    p.anim_timer = p.anim_timer + dt * 8.0
    p.anim_frame = p.anim_timer.to_int() % 3
    p.x = p.x + p.vx * dt
    // Apply gravity so Mario lands
    p.vy = p.vy + @types.gravity_high * dt
    if p.vy > @types.max_fall_speed {
      p.vy = @types.max_fall_speed
    }
    p.y = p.y + p.vy * dt
    // Simple ground check
    let foot_ty = @types.world_to_tile_y(p.y)
    let foot_tx = @types.world_to_tile_x(p.x)
    let tile_below = @types.get_tile(game, foot_tx, foot_ty)
    if @types.is_solid(tile_below) {
      p.y = @types.tile_to_world_y(foot_ty)
      p.vy = 0.0
      p.on_ground = true
    }
    if p.x >= game.mario_target_x {
      // Transition to tally screen
      start_level_tally(game)
    }
  }
}

///|
/// Initialize the level tally screen with scoring data.
fn start_level_tally(game : @types.Game) -> Unit {
  game.state = LevelTally
  game.tally_timer = 0.0
  game.tally_phase = 0
  // Calculate bonuses
  game.tally_time_bonus = game.time_remaining.to_int() * 50
  game.tally_coin_bonus = game.level_coins_collected * @types.score_coin
  game.tally_enemy_bonus = game.enemies_defeated * 100
  // Height bonus based on flag_height_frac (0 = top = max bonus)
  let one : Float = 1.0
  let scale : Float = 5000.0
  game.tally_height_bonus = ((one - game.flag_height_frac) * scale).to_int()
  // Calculate rank
  let coin_pct = if game.level_total_coins > 0 {
    game.level_coins_collected * 100 / game.level_total_coins
  } else {
    100
  }
  game.tally_rank = if coin_pct >= 100 && game.level_deaths == 0 {
    "PERFECT"
  } else if coin_pct >= 80 {
    "GREAT"
  } else {
    "GOOD"
  }
  // Save power for next level
  game.saved_power = game.player.power
}

///|
/// Update the level tally screen animation.
fn update_level_tally(game : @types.Game, dt : Float) -> Unit {
  game.tally_timer = game.tally_timer + dt
  // Phase progression: each bonus line appears after a delay
  if game.tally_phase == 0 && game.tally_timer > 0.5 {
    game.tally_phase = 1
    game.score = game.score + game.tally_time_bonus
    game.time_remaining = 0.0
  }
  if game.tally_phase == 1 && game.tally_timer > 1.2 {
    game.tally_phase = 2
    game.score = game.score + game.tally_coin_bonus
  }
  if game.tally_phase == 2 && game.tally_timer > 1.9 {
    game.tally_phase = 3
    game.score = game.score + game.tally_enemy_bonus
  }
  if game.tally_phase == 3 && game.tally_timer > 2.6 {
    game.tally_phase = 4
    game.score = game.score + game.tally_height_bonus
  }
  if game.tally_phase == 4 && game.tally_timer > 3.3 {
    game.tally_phase = 5
  }
  // After showing rank, wait for key press or timeout
  if game.tally_phase >= 5 && game.tally_timer > 5.0 {
    advance_to_next_level(game)
  }
  if game.tally_phase >= 5 {
    if @raylib.is_key_pressed(@raylib.KeyEnter) ||
      @raylib.is_key_pressed(@raylib.KeySpace) {
      advance_to_next_level(game)
    }
  }
}

///|
fn update_player_died(game : @types.Game, dt : Float) -> Unit {
  let p = game.player
  p.death_timer = p.death_timer + dt
  // Brief pause, then Mario jumps up and falls
  if p.death_timer > 0.5 {
    p.death_vy = p.death_vy + 1500.0 * dt
    p.y = p.y + p.death_vy * dt
  }
  if p.death_timer > 3.0 {
    game.lives = game.lives - 1
    game.level_deaths = game.level_deaths + 1
    if game.lives <= 0 {
      game.state = GameOver
      game.game_over_timer = 0.0
    } else {
      // Check for checkpoint respawn
      if game.checkpoint_active {
        load_level(game, game.level_index)
        game.player.x = game.checkpoint_x
        game.player.y = game.checkpoint_y
        game.state = Playing
      } else {
        start_level_intro(game)
      }
    }
  }
}

///|
fn update_game_over(game : @types.Game, dt : Float) -> Unit {
  game.game_over_timer = game.game_over_timer + dt
  if game.game_over_timer > 3.0 {
    if @raylib.is_key_pressed(@raylib.KeyEnter) ||
      @raylib.is_key_pressed(@raylib.KeySpace) {
      game.state = Title
    }
  }
}

///|
fn update_victory(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.state = Title
  }
}

///|
fn advance_to_next_level(game : @types.Game) -> Unit {
  game.level_deaths = 0
  game.level_index = game.level_index + 1
  if game.level_index >= @types.total_levels {
    game.state = Victory
  } else {
    game.level_num = game.level_num + 1
    if game.level_num > 4 {
      game.level_num = 1
      game.world_num = game.world_num + 1
    }
    start_level_intro(game)
  }
}

///|
/// Kill the player — triggers death animation.
pub fn kill_player(game : @types.Game) -> Unit {
  if game.player.dead {
    return
  }
  game.player.dead = true
  game.player.death_timer = 0.0
  game.player.death_vy = -500.0
  game.player.vx = 0.0
  game.player.vy = 0.0
  // If in bonus room, return to normal level on death
  if game.in_bonus_room {
    game.in_bonus_room = false
  }
  game.state = PlayerDied
}

///|
fn update_camera(game : @types.Game, dt : Float) -> Unit {
  let target_x = game.player.x - @types.camera_offset_x
  let max_x = Float::from_int(
    game.map_width * @types.tile_size - @types.screen_w,
  )
  let mut cam = target_x
  if cam < 0.0 {
    cam = 0.0
  }
  if cam > max_x {
    cam = max_x
  }
  game.camera_x = @utils.lerpf(
    game.camera_x,
    cam,
    @utils.clampf(8.0 * dt, 0.0, 1.0),
  )
}

///|
fn update_particles(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.particles.length() {
    let p = game.particles[i]
    if not(p.active) {
      continue
    }
    p.life = p.life - dt
    if p.life <= 0.0 {
      p.active = false
      continue
    }
    p.x = p.x + p.vx * dt
    p.y = p.y + p.vy * dt
    if p.has_gravity {
      p.vy = p.vy + 800.0 * dt
    }
  }
}

///|
fn update_score_popups(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.score_popups.length() {
    let s = game.score_popups[i]
    if not(s.active) {
      continue
    }
    s.life = s.life - dt
    if s.life <= 0.0 {
      s.active = false
      continue
    }
    s.y = s.y + s.vy * dt
  }
}

///|
fn update_bumped_blocks(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.bumped_blocks.length() {
    let b = game.bumped_blocks[i]
    if not(b.active) {
      continue
    }
    b.offset_y = b.offset_y + b.velocity * dt
    b.velocity = b.velocity + 600.0 * dt
    if b.offset_y >= 0.0 {
      b.offset_y = 0.0
      b.active = false
    }
  }
}

///|
/// Spawn a floating score popup at the given position.
pub fn spawn_score_popup(
  game : @types.Game,
  x : Float,
  y : Float,
  text : String,
) -> Unit {
  for i in 0..<game.score_popups.length() {
    if not(game.score_popups[i].active) {
      let s = game.score_popups[i]
      s.active = true
      s.x = x
      s.y = y
      s.vy = -120.0
      s.life = 1.0
      s.text = text
      return
    }
  }
}

///|
/// Spawn particles for a brick break effect.
pub fn spawn_brick_particles(
  game : @types.Game,
  wx : Float,
  wy : Float,
) -> Unit {
  let color = @raylib.Color::new(200, 88, 24, 255)
  let mut count = 0
  for i in 0..<game.particles.length() {
    if count >= 8 {
      break
    }
    if not(game.particles[i].active) {
      let p = game.particles[i]
      p.active = true
      p.x = wx + @types.rand_rangef(game, -8.0, 8.0)
      p.y = wy + @types.rand_rangef(game, -8.0, 8.0)
      p.vx = @types.rand_rangef(game, -200.0, 200.0)
      p.vy = @types.rand_rangef(game, -400.0, -100.0)
      p.life = @types.rand_rangef(game, 0.5, 1.2)
      p.max_life = p.life
      p.size = @types.rand_rangef(game, 6.0, 14.0)
      p.color = color
      p.has_gravity = true
      count = count + 1
    }
  }
}

///|
/// Spawn a stomp-poof effect.
pub fn spawn_stomp_poof(game : @types.Game, wx : Float, wy : Float) -> Unit {
  let mut count = 0
  for i in 0..<game.particles.length() {
    if count >= 6 {
      break
    }
    if not(game.particles[i].active) {
      let p = game.particles[i]
      p.active = true
      p.x = wx + @types.rand_rangef(game, -12.0, 12.0)
      p.y = wy + @types.rand_rangef(game, -8.0, 4.0)
      p.vx = @types.rand_rangef(game, -80.0, 80.0)
      p.vy = @types.rand_rangef(game, -60.0, -20.0)
      p.life = 0.35
      p.max_life = 0.35
      p.size = @types.rand_rangef(game, 4.0, 10.0)
      p.color = @raylib.Color::new(255, 255, 255, 200)
      p.has_gravity = false
      count = count + 1
    }
  }
}

///|
/// Spawn a small dust puff when Mario lands on the ground.
pub fn spawn_landing_dust(game : @types.Game, wx : Float, wy : Float) -> Unit {
  let mut count = 0
  for i in 0..<game.particles.length() {
    if count >= 4 {
      break
    }
    if not(game.particles[i].active) {
      let p = game.particles[i]
      p.active = true
      p.x = wx + @types.rand_rangef(game, -10.0, 10.0)
      p.y = wy + @types.rand_rangef(game, -4.0, 2.0)
      p.vx = @types.rand_rangef(game, -50.0, 50.0)
      p.vy = @types.rand_rangef(game, -30.0, -10.0)
      p.life = 0.25
      p.max_life = 0.25
      p.size = @types.rand_rangef(game, 3.0, 7.0)
      p.color = @raylib.Color::new(220, 220, 220, 160)
      p.has_gravity = false
      count = count + 1
    }
  }
}

///|
/// Spawn a small dust trail when Mario skids (changes direction while running).
pub fn spawn_skid_dust(game : @types.Game, wx : Float, wy : Float) -> Unit {
  let mut count = 0
  for i in 0..<game.particles.length() {
    if count >= 2 {
      break
    }
    if not(game.particles[i].active) {
      let p = game.particles[i]
      p.active = true
      p.x = wx + @types.rand_rangef(game, -6.0, 6.0)
      p.y = wy + @types.rand_rangef(game, -6.0, 0.0)
      p.vx = @types.rand_rangef(game, -20.0, 20.0)
      p.vy = @types.rand_rangef(game, -40.0, -15.0)
      p.life = 0.2
      p.max_life = 0.2
      p.size = @types.rand_rangef(game, 2.0, 5.0)
      p.color = @raylib.Color::new(200, 200, 200, 140)
      p.has_gravity = false
      count = count + 1
    }
  }
}

///|
/// Start a block bump animation.
pub fn bump_block(game : @types.Game, tx : Int, ty : Int) -> Unit {
  for i in 0..<game.bumped_blocks.length() {
    if not(game.bumped_blocks[i].active) {
      let b = game.bumped_blocks[i]
      b.active = true
      b.tile_x = tx
      b.tile_y = ty
      b.offset_y = -12.0
      b.velocity = -200.0
      return
    }
  }
}

///|
/// Spawn coin collect sparkle particles.
pub fn spawn_coin_sparkle(game : @types.Game, wx : Float, wy : Float) -> Unit {
  let mut count = 0
  for i in 0..<game.particles.length() {
    if count >= 6 {
      break
    }
    if not(game.particles[i].active) {
      let p = game.particles[i]
      p.active = true
      p.x = wx + @types.rand_rangef(game, -10.0, 10.0)
      p.y = wy + @types.rand_rangef(game, -10.0, 10.0)
      p.vx = @types.rand_rangef(game, -60.0, 60.0)
      p.vy = @types.rand_rangef(game, -100.0, -30.0)
      p.life = 0.4
      p.max_life = 0.4
      p.size = @types.rand_rangef(game, 3.0, 6.0)
      p.color = @raylib.Color::new(252, 220, 32, 255)
      p.has_gravity = false
      count = count + 1
    }
  }
}

///|
/// Enter a bonus room through a pipe.
pub fn enter_bonus_room(game : @types.Game) -> Unit {
  // Save current state
  game.bonus_return_x = game.player.x
  game.bonus_return_y = game.player.y
  game.bonus_return_level = game.level_index
  game.bonus_saved_tiles = game.map_tiles
  game.bonus_saved_width = game.map_width
  game.bonus_saved_height = game.map_height
  game.bonus_saved_enemies = game.enemies.map(fn(e) { e.clone() })
  game.bonus_saved_items = game.items.map(fn(i) { i.clone() })
  game.bonus_saved_fireballs = game.fireballs.map(fn(f) { f.clone() })
  game.in_bonus_room = true
  game.bonus_fade_timer = 0.5
  game.bonus_fade_in = true
  // Load bonus room
  let rows = @levels.bonus_room_rows(game.level_index)
  let height = rows.length()
  let width = rows[0].length()
  game.map_width = width
  game.map_height = height
  game.map_tiles = Array::make(width * height, Empty)
  // Deactivate enemies and items
  for i in 0..<game.enemies.length() {
    game.enemies[i].active = false
  }
  for i in 0..<game.items.length() {
    game.items[i].active = false
  }
  for i in 0..<game.fireballs.length() {
    game.fireballs[i].active = false
  }
  // Parse bonus room tiles
  for y in 0..<height {
    let row = rows[y]
    for x in 0..<width {
      if x >= row.length() {
        continue
      }
      let ch = Int::unsafe_to_char(row[x].to_int())
      let tile = parse_tile_char(ch)
      @types.set_tile(game, x, y, tile)
      match ch {
        'S' => {
          game.player.x = Float::from_int(
            x * @types.tile_size + @types.tile_size / 2,
          )
          game.player.y = Float::from_int(y * @types.tile_size)
        }
        _ => ()
      }
    }
  }
  game.player.vx = 0.0
  game.player.vy = 0.0
  game.player.on_ground = false
  game.camera_x = 0.0
  game.state = BonusRoom
}

///|
/// Exit the bonus room and return to the main level.
pub fn exit_bonus_room(game : @types.Game) -> Unit {
  game.in_bonus_room = false
  game.bonus_fade_timer = 0.5
  game.bonus_fade_in = true
  // Restore saved level
  game.map_tiles = game.bonus_saved_tiles
  game.map_width = game.bonus_saved_width
  game.map_height = game.bonus_saved_height
  // Restore player position (just above the pipe entrance)
  game.player.x = game.bonus_return_x
  game.player.y = game.bonus_return_y - @types.tile_sizef
  game.player.vx = 0.0
  game.player.vy = 0.0
  game.player.on_ground = false
  game.camera_x = game.player.x - @types.camera_offset_x
  let max_cam = Float::from_int(
    game.map_width * @types.tile_size - @types.screen_w,
  )
  if game.camera_x < 0.0 {
    game.camera_x = 0.0
  }
  if game.camera_x > max_cam {
    game.camera_x = max_cam
  }
  // Restore saved entity state instead of reloading from level data
  for i in 0..<game.enemies.length() {
    if i < game.bonus_saved_enemies.length() {
      let src = game.bonus_saved_enemies[i]
      let dst = game.enemies[i]
      dst.active = src.active
      dst.kind = src.kind
      dst.x = src.x
      dst.y = src.y
      dst.vx = src.vx
      dst.vy = src.vy
      dst.on_ground = src.on_ground
      dst.dead = src.dead
      dst.dead_timer = src.dead_timer
      dst.squished = src.squished
      dst.anim_timer = src.anim_timer
      dst.anim_frame = src.anim_frame
      dst.shell_moving = src.shell_moving
      dst.width = src.width
      dst.height = src.height
      dst.pipe_timer = src.pipe_timer
      dst.extended = src.extended
      dst.hop_timer = src.hop_timer
      dst.firebar_angle = src.firebar_angle
      dst.firebar_segments = src.firebar_segments
      dst.boss_hp = src.boss_hp
      dst.fire_cooldown = src.fire_cooldown
      dst.patrol_left = src.patrol_left
      dst.patrol_right = src.patrol_right
    } else {
      game.enemies[i].active = false
    }
  }
  for i in 0..<game.items.length() {
    if i < game.bonus_saved_items.length() {
      let src = game.bonus_saved_items[i]
      let dst = game.items[i]
      dst.active = src.active
      dst.kind = src.kind
      dst.x = src.x
      dst.y = src.y
      dst.vx = src.vx
      dst.vy = src.vy
      dst.on_ground = src.on_ground
      dst.emerging = src.emerging
      dst.emerge_start_y = src.emerge_start_y
      dst.emerge_target_y = src.emerge_target_y
    } else {
      game.items[i].active = false
    }
  }
  for i in 0..<game.fireballs.length() {
    if i < game.bonus_saved_fireballs.length() {
      let src = game.bonus_saved_fireballs[i]
      let dst = game.fireballs[i]
      dst.active = src.active
      dst.x = src.x
      dst.y = src.y
      dst.vx = src.vx
      dst.vy = src.vy
    } else {
      game.fireballs[i].active = false
    }
  }
  game.state = Playing
}

///|
/// Load a level from the level data.
pub fn load_level(game : @types.Game, level_index : Int) -> Unit {
  let rows = @levels.level_rows(level_index)
  let height = rows.length()
  let width = rows[0].length()
  game.map_width = width
  game.map_height = height
  game.map_tiles = Array::make(width * height, Empty)
  // Deactivate all entities
  for i in 0..<game.enemies.length() {
    game.enemies[i].active = false
  }
  for i in 0..<game.items.length() {
    game.items[i].active = false
  }
  for i in 0..<game.fireballs.length() {
    game.fireballs[i].active = false
  }
  for i in 0..<game.particles.length() {
    game.particles[i].active = false
  }
  for i in 0..<game.score_popups.length() {
    game.score_popups[i].active = false
  }
  for i in 0..<game.bumped_blocks.length() {
    game.bumped_blocks[i].active = false
  }
  // Reset player
  game.player.dead = false
  game.player.vx = 0.0
  game.player.vy = 0.0
  game.player.on_ground = false
  game.player.facing_right = true
  game.player.ducking = false
  game.player.invuln_timer = 0.0
  game.player.coyote_timer = 0.0
  game.player.jump_buffer = 0.0
  game.player.anim_timer = 0.0
  game.player.anim_frame = 0
  game.player.grow_timer = 0.0
  game.player.shrink_timer = 0.0
  game.player.stomp_combo = 0
  game.player.star_timer = 0.0
  // Power-up persistence: restore saved power
  game.player.power = game.saved_power
  // Reset camera and timers
  game.camera_x = 0.0
  game.time_remaining = @types.level_time
  game.clear_timer = 0.0
  game.flag_done = false
  game.mario_auto = false
  game.flag_y = 0.0
  game.flag_target_y = 0.0
  // Reset checkpoint
  game.checkpoint_active = false
  game.checkpoint_x = 0.0
  game.checkpoint_y = 0.0
  // Reset level stats (level_deaths is NOT reset here — it persists across
  // death-respawns and is only cleared when advancing to a new level)
  game.level_coins_collected = 0
  game.enemies_defeated = 0
  game.flag_height_frac = 1.0
  game.in_bonus_room = false
  game.bonus_fade_timer = 0.0
  // Parse tile data
  let mut player_set = false
  for y in 0..<height {
    let row = rows[y]
    for x in 0..<width {
      if x >= row.length() {
        continue
      }
      let ch = Int::unsafe_to_char(row[x].to_int())
      let tile = parse_tile_char(ch)
      @types.set_tile(game, x, y, tile)
      // Handle special spawn characters
      match ch {
        'S' => {
          game.player.x = Float::from_int(
            x * @types.tile_size + @types.tile_size / 2,
          )
          game.player.y = Float::from_int(y * @types.tile_size)
          player_set = true
        }
        'G' => spawn_enemy_at(game, Goomba, x, y)
        'K' => spawn_enemy_at(game, KoopaTroopa, x, y)
        'P' => spawn_enemy_at(game, PiranhaPlant, x, y)
        'Z' => spawn_enemy_at(game, BuzzyBeetle, x, y)
        'R' => spawn_enemy_at(game, Firebar, x, y)
        'W' => spawn_enemy_at(game, BowserLite, x, y)
        '^' => {
          game.flag_y = Float::from_int(y * @types.tile_size)
          game.flag_target_y = Float::from_int(12 * @types.tile_size)
        }
        _ => ()
      }
    }
  }
  if not(player_set) {
    game.player.x = 120.0
    game.player.y = Float::from_int(12 * @types.tile_size)
  }
  // Count total coins for tally
  game.level_total_coins = @types.count_coin_tiles(game)
}

///|
fn parse_tile_char(ch : Char) -> @types.TileKind {
  match ch {
    '#' => Ground
    '=' => Ground
    'B' => BrickBlock
    '?' => QuestionCoin
    'M' => QuestionMushroom
    '*' => QuestionStar
    '1' => QuestionOneUp
    'U' => UsedBlock
    'H' => HiddenCoin
    'L' => HiddenOneUp
    '[' => PipeTopLeft
    ']' => PipeTopRight
    '{' => PipeBodyLeft
    '}' => PipeBodyRight
    '|' => Flagpole
    '^' => FlagTop
    'C' => CastleBlock
    'T' => CastleTop
    'D' => CastleDoor
    'c' => CoinTile
    'E' => PipeEntrance
    'F' => Checkpoint
    'h' => HiddenBonusCoin
    'n' => HiddenBonusOneUp
    _ => Empty
  }
}

///|
fn spawn_enemy_at(
  game : @types.Game,
  kind : @types.EnemyKind,
  tx : Int,
  ty : Int,
) -> Unit {
  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      let ex = Float::from_int(tx * @types.tile_size + @types.tile_size / 2)
      let ey = Float::from_int(ty * @types.tile_size + @types.tile_size)
      let e = @types.Enemy::new(kind, ex, ey)
      game.enemies[i] = e
      return
    }
  }
}
