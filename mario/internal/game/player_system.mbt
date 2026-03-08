///|
/// Update the player: input, physics, collision.
fn update_player(game : @types.Game, dt : Float) -> Unit {
  let p = game.player
  if p.dead {
    return
  }
  // Power-up transformation animations freeze gameplay
  if p.grow_timer > 0.0 {
    p.grow_timer = p.grow_timer - dt
    if p.grow_timer <= 0.0 {
      p.grow_timer = 0.0
    }
    return
  }
  if p.shrink_timer > 0.0 {
    p.shrink_timer = p.shrink_timer - dt
    if p.shrink_timer <= 0.0 {
      p.shrink_timer = 0.0
    }
    return
  }
  // Level-clear auto walk
  if game.mario_auto {
    return
  }
  // Pause check
  if @raylib.is_key_pressed(@raylib.KeyP) ||
    @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = Paused
    return
  }
  // Invulnerability countdown
  if p.invuln_timer > 0.0 {
    p.invuln_timer = p.invuln_timer - dt
  }
  // Star power countdown
  if p.star_timer > 0.0 {
    p.star_timer = p.star_timer - dt
    if p.star_timer <= 0.0 {
      p.star_timer = 0.0
    }
  }
  // ── Input ──
  let left = @raylib.is_key_down(@raylib.KeyLeft) ||
    @raylib.is_key_down(@raylib.KeyA)
  let right = @raylib.is_key_down(@raylib.KeyRight) ||
    @raylib.is_key_down(@raylib.KeyD)
  let jump_pressed = @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyW)
  let jump_held = @raylib.is_key_down(@raylib.KeySpace) ||
    @raylib.is_key_down(@raylib.KeyUp) ||
    @raylib.is_key_down(@raylib.KeyW)
  let run_held = @raylib.is_key_down(@raylib.KeyLeftShift) ||
    @raylib.is_key_down(@raylib.KeyRightShift) ||
    @raylib.is_key_down(@raylib.KeyZ) ||
    @raylib.is_key_down(@raylib.KeyX)
  let duck = @raylib.is_key_down(@raylib.KeyDown) ||
    @raylib.is_key_down(@raylib.KeyS)
  let fire_pressed = @raylib.is_key_pressed(@raylib.KeyZ) ||
    @raylib.is_key_pressed(@raylib.KeyX) ||
    @raylib.is_key_pressed(@raylib.KeyLeftShift)
  // Ducking (only when big and on ground)
  p.ducking = duck && p.on_ground && p.power != Small
  // ── Horizontal movement ──
  let max_speed = if run_held { @types.run_speed } else { @types.walk_speed }
  let accel = if p.on_ground {
    @types.ground_accel
  } else {
    @types.air_accel
  }
  if right && not(p.ducking) {
    p.facing_right = true
    if p.vx < 0.0 && p.on_ground {
      // Skidding
      p.skid_timer = 0.2
      p.vx = p.vx + @types.ground_decel * 2.0 * dt
      if p.vx > 0.0 {
        p.vx = 0.0
      }
    } else {
      p.vx = p.vx + accel * dt
      if p.vx > max_speed {
        p.vx = max_speed
      }
    }
  } else if left && not(p.ducking) {
    p.facing_right = false
    if p.vx > 0.0 && p.on_ground {
      p.skid_timer = 0.2
      p.vx = p.vx - @types.ground_decel * 2.0 * dt
      if p.vx < 0.0 {
        p.vx = 0.0
      }
    } else {
      p.vx = p.vx - accel * dt
      if p.vx < -max_speed {
        p.vx = -max_speed
      }
    }
  } else if p.on_ground {
    // Friction
    if p.vx > 0.0 {
      p.vx = p.vx - @types.ground_decel * dt
      if p.vx < 0.0 {
        p.vx = 0.0
      }
    } else if p.vx < 0.0 {
      p.vx = p.vx + @types.ground_decel * dt
      if p.vx > 0.0 {
        p.vx = 0.0
      }
    }
  }
  // Skid timer decay
  if p.skid_timer > 0.0 {
    p.skid_timer = p.skid_timer - dt
  }
  // ── Coyote time ──
  p.was_on_ground = p.on_ground
  if p.on_ground {
    p.coyote_timer = @types.coyote_time
    p.stomp_combo = 0
  } else {
    p.coyote_timer = p.coyote_timer - dt
  }
  // ── Jump buffer ──
  if jump_pressed {
    p.jump_buffer = @types.jump_buffer_time
  } else {
    p.jump_buffer = p.jump_buffer - dt
  }
  // ── Jump ──
  let can_jump = p.coyote_timer > 0.0 && p.jump_buffer > 0.0
  if can_jump && not(p.ducking) {
    p.vy = @types.jump_velocity
    p.on_ground = false
    p.coyote_timer = 0.0
    p.jump_buffer = 0.0
  }
  // Variable jump height: release early = fall faster
  if not(jump_held) && p.vy < 0.0 {
    // Apply extra gravity to cut the jump short
    p.vy = p.vy + @types.gravity_high * dt
  }
  // ── Gravity ──
  let gravity = if jump_held && p.vy < 0.0 {
    @types.gravity_low
  } else {
    @types.gravity_high
  }
  p.vy = p.vy + gravity * dt
  if p.vy > @types.max_fall_speed {
    p.vy = @types.max_fall_speed
  }
  // ── Move & collide ──
  move_player_x(game, dt)
  move_player_y(game, dt)
  // ── Walking animation ──
  if p.on_ground {
    let speed = @utils.absf(p.vx)
    if speed > 10.0 {
      p.anim_timer = p.anim_timer + speed * dt * 0.015
      p.anim_frame = p.anim_timer.to_int() % 3
    } else {
      p.anim_frame = 0
      p.anim_timer = 0.0
    }
  }
  // ── Fireball shooting ──
  if p.power == Fire && fire_pressed {
    shoot_fireball(game)
  }
  // ── Enemy collision ──
  check_enemy_collisions(game)
  // ── Item collection ──
  check_item_collisions(game)
  // ── Flagpole check ──
  check_flagpole(game)
}

///|
fn move_player_x(game : @types.Game, dt : Float) -> Unit {
  let p = game.player
  p.x = p.x + p.vx * dt
  // Left boundary
  if p.x - @types.player_half_w < 0.0 {
    p.x = @types.player_half_w
    p.vx = 0.0
  }
  // Right boundary
  let right_bound = Float::from_int(game.map_width * @types.tile_size) -
    @types.player_half_w
  if p.x + @types.player_half_w > right_bound + @types.player_half_w {
    p.x = right_bound
    p.vx = 0.0
  }
  // Tile collision
  let h = p.height()
  let left = p.x - @types.player_half_w
  let right = p.x + @types.player_half_w
  let top = p.y - h
  let bottom = p.y - 1.0
  let min_tx = @types.world_to_tile_x(left)
  let max_tx = @types.world_to_tile_x(right - 1.0)
  let min_ty = @types.world_to_tile_y(top)
  let max_ty = @types.world_to_tile_y(bottom)
  for ty in min_ty..=max_ty {
    for tx in min_tx..=max_tx {
      let tile = @types.get_tile(game, tx, ty)
      if @types.is_solid(tile) {
        let tile_left = @types.tile_to_world_x(tx)
        let tile_right = tile_left + @types.tile_sizef
        if p.vx > 0.0 {
          // Moving right — push left
          if p.x + @types.player_half_w > tile_left &&
            p.x - @types.player_half_w < tile_right {
            p.x = tile_left - @types.player_half_w
            p.vx = 0.0
          }
        } else if p.vx < 0.0 {
          // Moving left — push right
          if p.x - @types.player_half_w < tile_right &&
            p.x + @types.player_half_w > tile_left {
            p.x = tile_right + @types.player_half_w
            p.vx = 0.0
          }
        }
      }
    }
  }
}

///|
fn move_player_y(game : @types.Game, dt : Float) -> Unit {
  let p = game.player
  p.y = p.y + p.vy * dt
  p.on_ground = false
  let h = p.height()
  let left = p.x - @types.player_half_w + 2.0
  let right = p.x + @types.player_half_w - 2.0
  let top = p.y - h
  let bottom = p.y
  let min_tx = @types.world_to_tile_x(left)
  let max_tx = @types.world_to_tile_x(right - 1.0)
  if p.vy >= 0.0 {
    // Falling — check below
    let foot_ty = @types.world_to_tile_y(bottom)
    for tx in min_tx..=max_tx {
      let tile = @types.get_tile(game, tx, foot_ty)
      if @types.is_solid(tile) {
        let tile_top = @types.tile_to_world_y(foot_ty)
        if p.y >= tile_top && p.y - p.vy * dt <= tile_top + 4.0 {
          p.y = tile_top
          p.vy = 0.0
          p.on_ground = true
        }
      }
    }
  } else {
    // Rising — check above (head bonk)
    let head_ty = @types.world_to_tile_y(top)
    for tx in min_tx..=max_tx {
      let tile = @types.get_tile(game, tx, head_ty)
      if @types.is_solid(tile) || @types.is_bumpable(tile) {
        let tile_bottom = @types.tile_to_world_y(head_ty) + @types.tile_sizef
        if top < tile_bottom {
          p.y = tile_bottom + h
          p.vy = 0.0
          // Bump the block
          handle_block_bump(game, tx, head_ty)
        }
      }
    }
  }
}

///|
fn handle_block_bump(game : @types.Game, tx : Int, ty : Int) -> Unit {
  let tile = @types.get_tile(game, tx, ty)
  let wx = @types.tile_to_world_x(tx) + @types.tile_sizef / 2.0
  let wy = @types.tile_to_world_y(ty)
  match tile {
    QuestionCoin => {
      @types.set_tile(game, tx, ty, UsedBlock)
      game.score = game.score + @types.score_coin
      game.coins = game.coins + 1
      if game.coins >= 100 {
        game.coins = game.coins - 100
        game.lives = game.lives + 1
      }
      bump_block(game, tx, ty)
      spawn_coin_popup(game, wx, wy)
      spawn_score_popup(game, wx, wy - 20.0, @types.score_coin.to_string())
    }
    QuestionMushroom => {
      @types.set_tile(game, tx, ty, UsedBlock)
      bump_block(game, tx, ty)
      if game.player.power == Small {
        spawn_item(game, Mushroom, wx, wy)
      } else {
        spawn_item(game, FireFlower, wx, wy)
      }
    }
    QuestionStar => {
      @types.set_tile(game, tx, ty, UsedBlock)
      bump_block(game, tx, ty)
      spawn_item(game, Star, wx, wy)
    }
    QuestionOneUp => {
      @types.set_tile(game, tx, ty, UsedBlock)
      bump_block(game, tx, ty)
      spawn_item(game, OneUp, wx, wy)
    }
    HiddenCoin => {
      @types.set_tile(game, tx, ty, UsedBlock)
      game.score = game.score + @types.score_coin
      game.coins = game.coins + 1
      if game.coins >= 100 {
        game.coins = game.coins - 100
        game.lives = game.lives + 1
      }
      bump_block(game, tx, ty)
      spawn_coin_popup(game, wx, wy)
      spawn_score_popup(game, wx, wy - 20.0, @types.score_coin.to_string())
    }
    HiddenOneUp => {
      @types.set_tile(game, tx, ty, UsedBlock)
      bump_block(game, tx, ty)
      spawn_item(game, OneUp, wx, wy)
    }
    BrickBlock => {
      if game.player.power != Small {
        // Big Mario breaks bricks
        @types.set_tile(game, tx, ty, Empty)
        game.score = game.score + @types.score_brick
        spawn_brick_particles(game, wx, wy + @types.tile_sizef / 2.0)
        spawn_score_popup(game, wx, wy, @types.score_brick.to_string())
        // Kill enemies on top
        kill_enemies_on_block(game, tx, ty)
      } else {
        bump_block(game, tx, ty)
        kill_enemies_on_block(game, tx, ty)
      }
    }
    _ => ()
  }
}

///|
fn kill_enemies_on_block(game : @types.Game, tx : Int, ty : Int) -> Unit {
  let bx = @types.tile_to_world_x(tx) + @types.tile_sizef / 2.0
  let by = @types.tile_to_world_y(ty)
  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if not(e.active) || e.dead {
      continue
    }
    // Check if enemy is standing on this tile
    let ex_tile = @types.world_to_tile_x(e.x)
    let ey_tile = @types.world_to_tile_y(e.y)
    if (ex_tile == tx || ex_tile == tx - 1 || ex_tile == tx + 1) && ey_tile == ty {
      e.dead = true
      e.dead_timer = 0.0
      e.vy = -300.0
      game.score = game.score + 100
      spawn_score_popup(game, e.x, e.y - e.height, "100")
      ignore(bx)
      ignore(by)
    }
  }
}

///|
fn spawn_coin_popup(game : @types.Game, wx : Float, wy : Float) -> Unit {
  let mut count = 0
  for i in 0..<game.particles.length() {
    if count >= 4 {
      break
    }
    if not(game.particles[i].active) {
      let p = game.particles[i]
      p.active = true
      p.x = wx + @types.rand_rangef(game, -6.0, 6.0)
      p.y = wy
      p.vx = @types.rand_rangef(game, -40.0, 40.0)
      p.vy = @types.rand_rangef(game, -350.0, -200.0)
      p.life = 0.6
      p.max_life = 0.6
      p.size = @types.rand_rangef(game, 4.0, 8.0)
      p.color = @raylib.Color::new(252, 200, 32, 255)
      p.has_gravity = true
      count = count + 1
    }
  }
}

///|
fn spawn_item(
  game : @types.Game,
  kind : @types.ItemKind,
  wx : Float,
  wy : Float
) -> Unit {
  for i in 0..<game.items.length() {
    if not(game.items[i].active) {
      let it = game.items[i]
      it.active = true
      it.kind = kind
      it.x = wx
      it.y = wy
      it.vx = 0.0
      it.vy = 0.0
      it.on_ground = false
      it.emerging = true
      it.emerge_start_y = wy
      it.emerge_target_y = wy - @types.tile_sizef
      return
    }
  }
}

///|
fn shoot_fireball(game : @types.Game) -> Unit {
  for i in 0..<game.fireballs.length() {
    if not(game.fireballs[i].active) {
      let fb = game.fireballs[i]
      fb.active = true
      fb.x = game.player.x + (if game.player.facing_right { 20.0 } else { -20.0 })
      fb.y = game.player.y - game.player.height() / 2.0
      fb.vx = if game.player.facing_right {
        @types.fireball_speed_x
      } else {
        -@types.fireball_speed_x
      }
      fb.vy = 0.0
      return
    }
  }
}

///|
fn check_enemy_collisions(game : @types.Game) -> Unit {
  let p = game.player
  if p.dead {
    return
  }
  let ph = p.height()
  let p_left = p.x - @types.player_half_w
  let p_right = p.x + @types.player_half_w
  let p_top = p.y - ph
  let p_bottom = p.y
  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if not(e.active) || e.dead {
      continue
    }
    let ehw = e.width / 2.0
    let e_left = e.x - ehw
    let e_right = e.x + ehw
    let e_top = e.y - e.height
    let e_bottom = e.y
    // AABB overlap check
    if p_right <= e_left || p_left >= e_right || p_bottom <= e_top ||
      p_top >= e_bottom {
      continue
    }
    // Star power kills instantly
    if p.star_timer > 0.0 {
      e.dead = true
      e.dead_timer = 0.0
      e.vy = -300.0
      game.score = game.score + 200
      spawn_score_popup(game, e.x, e.y - e.height, "200")
      spawn_stomp_poof(game, e.x, e.y)
      continue
    }
    // Stomp check: Mario is falling and his feet are above enemy's midpoint
    let stomp_threshold = e_top + e.height * 0.4
    if p.vy > 0.0 && p_bottom < stomp_threshold + 8.0 && p_bottom > e_top - 8.0 {
      // Stomped!
      let combo_pts = @types.stomp_score(p.stomp_combo)
      p.stomp_combo = p.stomp_combo + 1
      game.score = game.score + combo_pts
      p.vy = @types.bounce_velocity
      p.on_ground = false
      p.coyote_timer = 0.0
      spawn_stomp_poof(game, e.x, e.y)
      spawn_score_popup(
        game,
        e.x,
        e.y - e.height,
        combo_pts.to_string(),
      )
      match e.kind {
        Goomba => {
          e.squished = true
          e.dead = true
          e.dead_timer = 0.0
          e.vy = 0.0
        }
        KoopaTroopa => {
          // Convert to shell
          e.kind = KoopaShell
          e.height = 36.0
          e.vx = 0.0
          e.shell_moving = false
        }
        KoopaShell => {
          if e.shell_moving {
            // Stop the shell
            e.vx = 0.0
            e.shell_moving = false
          } else {
            // Kick the shell
            e.shell_moving = true
            e.vx = if p.x < e.x { @types.shell_speed } else { -@types.shell_speed }
          }
        }
      }
    } else {
      // Side collision — damage Mario
      if e.kind == KoopaShell && not(e.shell_moving) {
        // Kick stationary shell
        e.shell_moving = true
        e.vx = if p.x < e.x { @types.shell_speed } else { -@types.shell_speed }
      } else {
        damage_player(game)
      }
    }
  }
}

///|
fn damage_player(game : @types.Game) -> Unit {
  let p = game.player
  if p.invuln_timer > 0.0 || p.dead {
    return
  }
  match p.power {
    Small => kill_player(game)
    Big => {
      p.power = Small
      p.invuln_timer = @types.invuln_duration
      p.shrink_timer = @types.shrink_duration
    }
    Fire => {
      p.power = Small
      p.invuln_timer = @types.invuln_duration
      p.shrink_timer = @types.shrink_duration
    }
  }
}

///|
fn check_item_collisions(game : @types.Game) -> Unit {
  let p = game.player
  if p.dead {
    return
  }
  let ph = p.height()
  let p_left = p.x - @types.player_half_w
  let p_right = p.x + @types.player_half_w
  let p_top = p.y - ph
  let p_bottom = p.y
  for i in 0..<game.items.length() {
    let it = game.items[i]
    if not(it.active) || it.emerging {
      continue
    }
    let item_hw : Float = 20.0
    let item_h : Float = 40.0
    let i_left = it.x - item_hw
    let i_right = it.x + item_hw
    let i_top = it.y - item_h
    let i_bottom = it.y
    if p_right <= i_left || p_left >= i_right || p_bottom <= i_top ||
      p_top >= i_bottom {
      continue
    }
    // Collected!
    it.active = false
    match it.kind {
      Mushroom => {
        if p.power == Small {
          p.power = Big
          p.grow_timer = @types.grow_duration
        }
        game.score = game.score + @types.score_mushroom
        spawn_score_popup(
          game,
          it.x,
          it.y - 30.0,
          @types.score_mushroom.to_string(),
        )
      }
      FireFlower => {
        p.power = Fire
        if p.power == Small {
          p.grow_timer = @types.grow_duration
        }
        game.score = game.score + @types.score_fire_flower
        spawn_score_popup(
          game,
          it.x,
          it.y - 30.0,
          @types.score_fire_flower.to_string(),
        )
      }
      Star => {
        p.star_timer = @types.star_duration
        game.score = game.score + @types.score_star
        spawn_score_popup(
          game,
          it.x,
          it.y - 30.0,
          @types.score_star.to_string(),
        )
      }
      OneUp => {
        game.lives = game.lives + 1
        spawn_score_popup(game, it.x, it.y - 30.0, "1UP")
      }
      CoinPopup => {
        game.score = game.score + @types.score_coin
        game.coins = game.coins + 1
        if game.coins >= 100 {
          game.coins = game.coins - 100
          game.lives = game.lives + 1
        }
      }
    }
  }
}

///|
fn check_flagpole(game : @types.Game) -> Unit {
  let p = game.player
  if game.state != Playing || p.dead {
    return
  }
  // Check if player touches a flagpole tile
  let px_tile = @types.world_to_tile_x(p.x)
  let py_tile = @types.world_to_tile_y(p.y - p.height() / 2.0)
  let range_start = py_tile - 1
  let range_end = py_tile + 1
  for ty in range_start..=range_end {
    let tile = @types.get_tile(game, px_tile, ty)
    if tile == Flagpole || tile == FlagTop {
      // Start level clear sequence
      game.state = LevelClear
      game.clear_timer = 0.0
      game.flag_done = false
      game.mario_auto = false
      // Find castle door X for auto-walk target
      game.mario_target_x = p.x + 300.0
      // Find actual castle position
      for cx in px_tile..<game.map_width {
        for cy in 0..<game.map_height {
          if @types.get_tile(game, cx, cy) == CastleDoor {
            game.mario_target_x = Float::from_int(
              cx * @types.tile_size + @types.tile_size / 2,
            )
          }
        }
      }
      // Calculate flag target
      let mut bottom_flag_y = Float::from_int(12 * @types.tile_size)
      for fy in 0..<game.map_height {
        if @types.get_tile(game, px_tile, fy) == Flagpole {
          bottom_flag_y = Float::from_int(fy * @types.tile_size)
        }
      }
      game.flag_target_y = bottom_flag_y
      // Height bonus: higher on pole = more points
      let pole_height = game.flag_target_y - game.flag_y
      let height_frac : Float = if pole_height > 0.0 {
        (p.y - p.height() - game.flag_y) / pole_height
      } else {
        1.0
      }
      let clamped = @utils.clampf(height_frac, 0.0, 1.0)
      let one : Float = 1.0
      let scale : Float = 5000.0
      let height_bonus = (one - clamped) * scale
      game.score = game.score + height_bonus.to_int()
      p.vx = 0.0
      return
    }
  }
}
