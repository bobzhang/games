///|
fn @types.Game::damage_tile_at_point(
  game : @types.Game,
  world_x : Float,
  world_y : Float,
  power : Int,
) -> Bool {
  if not(@world.point_in_world(world_x, world_y)) {
    return true
  }

  let tx = @types.world_x_to_tile(world_x)
  let ty = @types.world_y_to_tile(world_y)
  let tile = @types.get_tile(game, tx, ty)
  if not(@types.is_tile_solid_for_bullet(tile)) {
    return false
  }

  let idx = @types.tile_index(tx, ty)
  match tile {
    Brick => {
      game.map_hp[idx] -= power
      if game.map_hp[idx] <= 0 {
        @types.set_tile(game, tx, ty, Empty, 0)
        @particles.spawn_explosion(
          game,
          @types.tile_center_x(tx),
          @types.tile_center_y(ty),
          0.45,
        )
      } else {
        @particles.spawn_spark_burst(game, world_x, world_y, 6)
      }
    }
    Steel => {
      if power >= 3 {
        @types.set_tile(game, tx, ty, Empty, 0)
        @particles.spawn_explosion(
          game,
          @types.tile_center_x(tx),
          @types.tile_center_y(ty),
          0.7,
        )
      } else {
        @particles.spawn_spark_burst(game, world_x, world_y, 9)
      }
    }
    Base => {
      game.base_alive = false
      game.base_flash = 1.0
      @particles.spawn_explosion(
        game,
        @types.tile_center_x(tx),
        @types.tile_center_y(ty),
        2.1,
      )
      @types.push_camera_shake(game, 3.6)
    }
    _ => ()
  }
  true
}

///|
fn @types.Game::update_starfield(game : @types.Game, dt : Float) -> Unit {
  for star in game.stars {
    star.y += star.speed * dt
    star.twinkle += dt * 3.0
    if star.y > Float::from_int(@types.screen_height + 10) {
      star.y = -4.0
      star.x = Float::from_int(@types.rand_range(game, 0, @types.screen_width))
      star.speed = Float::from_int(@types.rand_range(game, 12, 85))
      star.twinkle = @types.rand_rangef(game, 0.0, 6.2)
    }
  }
}

///|
fn @types.Game::enter_game_over(game : @types.Game) -> Unit {
  if game.state == GameOver {
    return
  }
  game.state = GameOver
  game.game_over_timer = if game.demo_mode {
    0.8
  } else {
    @types.game_over_delay
  }
}

///|
fn @types.Game::start_manual_campaign(game : @types.Game) -> Unit {
  game.demo_mode = false
  game.demo_elapsed = 0.0
  start_new_campaign(game)
}

///|
fn @types.Game::start_demo_campaign(game : @types.Game) -> Unit {
  game.demo_mode = true
  game.coop_enabled = true
  game.demo_runs += 1
  game.demo_elapsed = 0.0
  start_new_campaign(game)

  for i in 0..<@types.max_players {
    if not(game.players[i].active) {
      continue
    }
    game.players[i].lives = 6
    game.players[i].weapon_level = 1
    game.players[i].reload_delay = @types.player_reload_base * 0.92
  }
}

///|
fn @types.Game::update_menu(game : @types.Game, dt : Float) -> Unit {
  game.menu_blink += dt * @types.menu_select_blink_speed

  if @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyW) {
    game.menu_cursor -= 1
    if game.menu_cursor < 0 {
      game.menu_cursor = 3
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) ||
    @raylib.is_key_pressed(@raylib.KeyS) {
    game.menu_cursor += 1
    if game.menu_cursor > 3 {
      game.menu_cursor = 0
    }
  }

  if @raylib.is_key_pressed(@raylib.KeyC) {
    game.coop_enabled = not(game.coop_enabled)
  }
  if @raylib.is_key_pressed(@raylib.KeyD) {
    game.start_demo_campaign()
    return
  }

  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.menu_cursor == 0 {
      game.start_manual_campaign()
    } else if game.menu_cursor == 1 {
      game.start_demo_campaign()
    } else if game.menu_cursor == 2 {
      game.coop_enabled = not(game.coop_enabled)
    } else {
      @raylib.close_window()
    }
  }
}

///|
fn @types.Game::update_stage_intro(game : @types.Game, dt : Float) -> Unit {
  game.stage_intro_timer -= dt
  if game.stage_intro_timer <= 0.0 {
    game.stage_intro_timer = 0.0
    game.state = Playing
  }
}

///|
fn @types.Game::update_stage_clear(game : @types.Game, dt : Float) -> Unit {
  game.stage_clear_timer -= dt
  if game.stage_clear_timer > 0.0 {
    return
  }

  game.stage_index += 1
  if game.stage_index >= @types.level_count {
    game.state = CampaignClear
    game.campaign_clear_timer = if game.demo_mode {
      1.0
    } else {
      @types.campaign_clear_delay
    }
  } else {
    load_stage(game, game.stage_index)
  }
}

///|
fn @types.Game::update_campaign_clear(game : @types.Game, dt : Float) -> Unit {
  game.campaign_clear_timer -= dt
  if game.campaign_clear_timer <= 0.0 {
    if game.demo_mode {
      game.start_demo_campaign()
    } else {
      game.state = Menu
      game.menu_cursor = 0
    }
  }
}

///|
fn @types.Game::update_game_over(game : @types.Game, dt : Float) -> Unit {
  game.game_over_timer -= dt
  if game.game_over_timer <= 0.0 {
    if game.demo_mode {
      game.start_demo_campaign()
    } else {
      game.state = Menu
      game.menu_cursor = 0
    }
  }
}

///|
fn @types.Game::update_playing(game : @types.Game, dt : Float) -> Unit {
  if game.demo_mode && @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.demo_mode = false
    game.state = Menu
    game.menu_cursor = 0
    return
  }

  if not(game.demo_mode) && @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = Paused
    return
  }

  @types.update_camera_shake(game, dt)
  @score.update_combo(game, dt)
  game.update_global_effects(dt)
  game.update_player_reload_timers(dt)

  game.update_player_input(dt)
  game.update_enemy_spawn(dt)
  game.update_enemies(dt)
  game.update_bullets(dt)
  game.update_cores(dt)
  game.update_powerups(dt)
  game.update_player_respawns(dt)
  @particles.update_particles(game, dt)

  if game.base_flash > 0.0 {
    game.base_flash -= dt * 2.0
    if game.base_flash < 0.0 {
      game.base_flash = 0.0
    }
  }

  if not(game.base_alive) {
    game.enter_game_over()
    return
  }

  if game.all_players_out() {
    game.enter_game_over()
    return
  }

  if game.stage_is_clear() {
    game.state = StageClear
    game.stage_clear_timer = if game.demo_mode {
      0.65
    } else {
      @types.stage_clear_time
    }
    @particles.spawn_spark_burst(
      game,
      Float::from_int(@types.map_pixel_w / 2),
      Float::from_int(@types.map_pixel_h / 2),
      50,
    )
  }
}

///|
fn @types.Game::update_paused(game : @types.Game, dt : Float) -> Unit {
  game.pause_blink += dt * 4.5
  @particles.update_particles(game, dt)
  if @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = Playing
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = Menu
    game.menu_cursor = 0
  }
}

///|
/// Advances one frame of campaign/menu simulation.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.frame_counter += 1
  game.update_starfield(dt)
  if game.demo_mode && game.state != Menu {
    game.demo_elapsed += dt
  }

  match game.state {
    Menu => { game.update_menu(dt) }
    StageIntro => { game.update_stage_intro(dt) }
    Playing => { game.update_playing(dt) }
    Paused => { game.update_paused(dt) }
    StageClear => { game.update_stage_clear(dt) }
    GameOver => { game.update_game_over(dt) }
    CampaignClear => { game.update_campaign_clear(dt) }
  }
}
