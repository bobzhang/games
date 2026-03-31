///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.frame_count = game.frame_count + 1
  // Update play time
  update_play_time(game, dt)
  // Update animation timers
  if game.gravity_anim_timer > 0.0 {
    game.gravity_anim_timer = game.gravity_anim_timer - dt
    if game.gravity_anim_timer < 0.0 {
      game.gravity_anim_timer = 0.0
    }
  }
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - dt
    if game.message_timer < 0.0 {
      game.message_timer = 0.0
    }
  }
  // Update entity slide animation timers
  match game.level {
    Some(level) =>
      for i in 0..<level.entities.length() {
        let e = level.entities[i]
        if e.slide_timer > 0.0 {
          e.slide_timer = e.slide_timer - dt * @types.anim_speed
          if e.slide_timer < 0.0 {
            e.slide_timer = 0.0
          }
        }
      }
    None => ()
  }
  // Update particle effects
  @particles.update_particles(game, dt)
  // Update ambient effects
  @effects.update_ambient(game, dt)
  // Update gravity rotation visual
  @effects.update_gravity_rotation(game, dt)
  // Update bounce timers
  @effects.update_bounce(game, dt)
  // Update ghost replay
  @replay.update_ghost(game, dt)
  // Update hint display
  @hints.update_hint(game, dt)
  // Update speedrun timer
  @effects.update_speedrun_timer(game, dt)
  // Update world-specific timers
  update_world_timers(game, dt)
  // Update achievement toasts
  update_achievement_toasts(game, dt)
  match game.screen {
    Title => update_title(game)
    Playing => update_playing(game, dt)
    LevelComplete => update_level_complete(game)
    WorldSelect => update_world_select(game)
    LevelSelect => update_level_select(game)
    Paused => update_paused(game)
    Editor => @editor.update_editor(game)
    Statistics => update_statistics(game)
  }
}

///|
fn update_world_timers(game : @types.Game, dt : Float) -> Unit {
  // Lava timer cycles
  game.lava_timer = game.lava_timer + dt
  if game.lava_timer >= @types.lava_cycle_period {
    game.lava_timer = game.lava_timer - @types.lava_cycle_period
  }
  // Wind beat timer
  game.wind_timer = game.wind_timer + dt
  if game.wind_timer >= @types.wind_beat_period {
    game.wind_timer = game.wind_timer - @types.wind_beat_period
    game.wind_beat = game.wind_beat + 1
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = WorldSelect
  }
  // L key opens level editor
  if @raylib.is_key_pressed(@raylib.KeyL) {
    @editor.init_editor(game)
    check_achievements_on_editor(game)
    game.screen = Editor
  }
  // T key toggles speedrun timer
  if @raylib.is_key_pressed(@raylib.KeyT) {
    game.speedrun_active = !(game.speedrun_active)
    if game.speedrun_active {
      game.speedrun_timer = 0.0
    }
  }
  // A key cycles accessibility mode
  if @raylib.is_key_pressed(@raylib.KeyA) {
    game.accessibility = match game.accessibility {
      Normal => HighContrast
      HighContrast => LargeText
      LargeText => Normal
    }
    game.message_text = match game.accessibility {
      Normal => "Accessibility: Normal"
      HighContrast => "Accessibility: High Contrast"
      LargeText => "Accessibility: Large Text"
    }
    game.message_timer = @types.message_duration
  }
  // S key opens statistics
  if @raylib.is_key_pressed(@raylib.KeyS) {
    game.screen = Statistics
  }
}

///|
fn update_world_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    if game.current_world > 0 {
      game.current_world = game.current_world - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    if game.current_world < @types.num_worlds - 1 {
      game.current_world = game.current_world + 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.current_level = 0
    game.screen = LevelSelect
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  let unlocked = game.levels_unlocked[game.current_world]
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    if game.current_level > 0 {
      game.current_level = game.current_level - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    if game.current_level < @types.levels_per_world - 1 &&
      game.current_level < unlocked - 1 {
      game.current_level = game.current_level + 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    if game.current_level >= 5 {
      game.current_level = game.current_level - 5
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    let next = game.current_level + 5
    if next < @types.levels_per_world && next < unlocked {
      game.current_level = next
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.current_level < unlocked {
      start_level(game, game.current_world, game.current_level)
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = WorldSelect
  }
}

///|
fn start_level(game : @types.Game, world : Int, level : Int) -> Unit {
  let lvl = @content.get_level(world, level)
  game.level = Some(lvl)
  game.current_world = world
  game.current_level = level
  game.undo_stack = []
  game.settling = false
  game.settle_timer = 0.0
  game.gravity_anim_timer = 0.0
  game.screen = Playing
  game.used_undo_this_level = false
  game.used_hint_this_level = false
  // Clear replay history for new attempt
  @replay.clear_history(game)
  // Reset gravity rotation visual
  game.gravity_rot_angle = @types.gravity_dir_to_angle(lvl.gravity)
  game.gravity_rot_target = game.gravity_rot_angle
  // Initial settle - let everything fall into place
  ignore(@physics.settle_all(lvl))
}

///|
fn update_playing(game : @types.Game, dt : Float) -> Unit {
  let level = match game.level {
    Some(l) => l
    None => return
  }
  // Check for death
  if level.player_dead {
    // Spawn death particles
    let player = match @types.find_player(level) {
      Some(p) => p
      None => {
        if @raylib.is_key_pressed(@raylib.KeyR) {
          restart_level(game)
        }
        return
      }
    }
    let px = @types.tile_to_pixel_x(player.x) + @types.tile_sizef * 0.5
    let py = @types.tile_to_pixel_y(player.y) + @types.tile_sizef * 0.5
    if game.message_timer <= 0.0 {
      @particles.spawn_spike_death(game, px, py)
      track_death(game)
    }
    game.message_text = "Oops! Press R to retry"
    game.message_timer = @types.message_duration
    if @raylib.is_key_pressed(@raylib.KeyR) {
      restart_level(game)
    }
    return
  }
  // Check for lava death (Magma Depths)
  if level.world == 3 {
    check_lava_death(level, game)
  }
  // Check for completion
  if level.completed {
    complete_level(game)
    return
  }
  // Handle settling (gravity animation)
  if game.settling {
    game.settle_timer = game.settle_timer - dt
    if game.settle_timer <= 0.0 {
      let moved = @physics.step_gravity(level)
      // Also apply world-specific mechanics during settling
      let mech_moved = @mechanics.process_world_mechanics(level, game)
      // Process enemy movement during settling
      let enemy_moved = @mechanics.process_enemies(level, game)
      // Check enemy-player collision
      @mechanics.check_enemy_player_collision(level)
      // Check if boulders crushed enemies
      @mechanics.check_boulder_crush_enemies(level)
      if moved || mech_moved || enemy_moved {
        game.settle_timer = @types.settle_delay
        // Spawn gravity trail particles for moving entities
        spawn_movement_particles(game, level)
      } else {
        game.settling = false
        // Trigger landing bounce for entities that just stopped
        trigger_landing_bounces(game, level)
      }
    }
    return
  }
  // Pause
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Paused
    return
  }
  // Restart
  if @raylib.is_key_pressed(@raylib.KeyR) {
    restart_level(game)
    return
  }
  // Undo
  if @raylib.is_key_pressed(@raylib.KeyZ) {
    if game.undo_stack.length() > 0 {
      let snap = game.undo_stack.pop()
      match snap {
        Some(s) => {
          @types.restore_snapshot(level, s)
          track_undo(game)
        }
        None => ()
      }
    }
    return
  }
  // Hint: H key
  if @raylib.is_key_pressed(@raylib.KeyH) {
    @hints.use_hint(game)
    track_hint_used(game)
    return
  }
  // Ghost replay toggle: V key
  if @raylib.is_key_pressed(@raylib.KeyV) {
    if game.ghost.active {
      @replay.stop_ghost_replay(game)
    } else {
      @replay.start_ghost_replay(game)
    }
  }
  // Gravity rotation: Q = counter-clockwise, E = clockwise
  if @raylib.is_key_pressed(@raylib.KeyQ) {
    let new_dir = @types.rotate_gravity_ccw(level.gravity)
    @physics.rotate_gravity(level, game, new_dir)
    @replay.record_gravity_rotate(game, new_dir)
    check_achievements_on_rotate(game)
    game.settling = true
    game.settle_timer = @types.settle_delay
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyE) {
    let new_dir = @types.rotate_gravity_cw(level.gravity)
    @physics.rotate_gravity(level, game, new_dir)
    @replay.record_gravity_rotate(game, new_dir)
    check_achievements_on_rotate(game)
    game.settling = true
    game.settle_timer = @types.settle_delay
    return
  }
  // Player movement (perpendicular to gravity)
  let (perp1, perp2) = @types.gravity_perp_vectors(level.gravity)
  let (p1x, p1y) = perp1
  let (p2x, p2y) = perp2
  // Map arrow keys based on gravity direction
  let mut moved = false
  match level.gravity {
    Down | Up => {
      if @raylib.is_key_pressed(@raylib.KeyLeft) {
        moved = @physics.try_move_player(level, game, p1x, p1y)
        if moved {
          @replay.record_player_move(game, p1x, p1y)
        }
      }
      if @raylib.is_key_pressed(@raylib.KeyRight) && !(moved) {
        moved = @physics.try_move_player(level, game, p2x, p2y)
        if moved {
          @replay.record_player_move(game, p2x, p2y)
        }
      }
    }
    Left | Right => {
      if @raylib.is_key_pressed(@raylib.KeyUp) {
        moved = @physics.try_move_player(level, game, p1x, p1y)
        if moved {
          @replay.record_player_move(game, p1x, p1y)
        }
      }
      if @raylib.is_key_pressed(@raylib.KeyDown) && !(moved) {
        moved = @physics.try_move_player(level, game, p2x, p2y)
        if moved {
          @replay.record_player_move(game, p2x, p2y)
        }
      }
    }
  }
  if moved {
    check_achievements_on_move(game)
    // Trigger settling after player move
    game.settling = true
    game.settle_timer = @types.settle_delay
    // Check for collectible particles
    check_collection_particles(game, level)
  }
}

///|
fn spawn_movement_particles(game : @types.Game, level : @types.Level) -> Unit {
  for i in 0..<level.entities.length() {
    let e = level.entities[i]
    if e.active && e.falling {
      let px = @types.tile_to_pixel_x(e.x) + @types.tile_sizef * 0.5
      let py = @types.tile_to_pixel_y(e.y) + @types.tile_sizef * 0.5
      @particles.spawn_gravity_trail(game, px, py, level.gravity)
    }
  }
}

///|
fn trigger_landing_bounces(game : @types.Game, level : @types.Level) -> Unit {
  for i in 0..<level.entities.length() {
    let e = level.entities[i]
    if e.active && !(e.falling) && e.from_x == e.x && e.from_y == e.y {
      @effects.trigger_bounce(game, e.id)
    }
  }
}

///|
fn check_collection_particles(game : @types.Game, level : @types.Level) -> Unit {
  for i in 0..<level.entities.length() {
    let e = level.entities[i]
    if !(e.active) {
      let px = @types.tile_to_pixel_x(e.x) + @types.tile_sizef * 0.5
      let py = @types.tile_to_pixel_y(e.y) + @types.tile_sizef * 0.5
      match e.kind {
        Gem => @particles.spawn_gem_sparkle(game, px, py)
        Key => @particles.spawn_key_ring(game, px, py)
        _ => ()
      }
    }
  }
}

///|
fn check_lava_death(level : @types.Level, game : @types.Game) -> Unit {
  if !(@mechanics.is_lava_deadly(game.lava_timer)) {
    return
  }
  let player = match @types.find_player(level) {
    Some(p) => p
    None => return
  }
  if @types.get_tile(level, player.x, player.y) == TimedLava {
    level.player_dead = true
  }
}

///|
fn update_paused(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyP) {
    game.screen = Playing
  }
  if @raylib.is_key_pressed(@raylib.KeyQ) {
    // Save progress before quitting to level select
    save_progress(game)
    game.screen = LevelSelect
  }
}

///|
fn update_level_complete(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    // Go to next level
    let next_level = game.current_level + 1
    if next_level < @types.levels_per_world {
      start_level(game, game.current_world, next_level)
    } else {
      // Completed world, go to world select
      let next_world = game.current_world + 1
      if next_world < @types.num_worlds {
        game.current_world = next_world
      }
      game.screen = WorldSelect
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}

///|
fn complete_level(game : @types.Game) -> Unit {
  let level = match game.level {
    Some(l) => l
    None => return
  }
  let stars = @types.calc_stars(level.moves, level.par_moves)
  let global_idx = game.current_world * @types.levels_per_world +
    game.current_level
  if global_idx < game.level_stars.length() && stars > game.level_stars[global_idx] {
    game.total_stars = game.total_stars - game.level_stars[global_idx] + stars
    game.level_stars[global_idx] = stars
  }
  // Unlock next level
  let next = game.current_level + 2
  if next > game.levels_unlocked[game.current_world] {
    game.levels_unlocked[game.current_world] = if next > @types.levels_per_world {
      @types.levels_per_world
    } else {
      next
    }
  }
  // Unlock next world if all levels completed
  if game.levels_unlocked[game.current_world] >= @types.levels_per_world {
    let nw = game.current_world + 1
    if nw < @types.num_worlds && game.levels_unlocked[nw] < 1 {
      game.levels_unlocked[nw] = 1
    }
  }
  // Save replay as best if improved
  @replay.save_best_replay(game)
  // Update stats
  game.stats.total_levels_completed = game.stats.total_levels_completed + 1
  game.stats.total_stars_earned = game.total_stars
  game.stats.total_gems_collected = game.stats.total_gems_collected + level.gems_collected
  game.stats.total_keys_collected = game.stats.total_keys_collected + level.keys_collected
  // Check achievements on level complete
  check_achievements_on_complete(game)
  // Save progress
  save_progress(game)
  // Spawn celebration particles
  let cx = Float::from_int(@types.screen_w / 2)
  let cy = Float::from_int(@types.screen_h / 2)
  @particles.spawn_celebration(game, cx, cy)
  game.screen = LevelComplete
}

///|
fn restart_level(game : @types.Game) -> Unit {
  start_level(game, game.current_world, game.current_level)
}

///|
fn update_statistics(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.screen = Title
  }
}

