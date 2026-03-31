///|
/// Main game update called each frame.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.frame_count = game.frame_count + 1
  game.anim_timer = game.anim_timer + dt
  if game.message_timer > 0.0F {
    game.message_timer = game.message_timer - dt
    if game.message_timer < 0.0F {
      game.message_timer = 0.0F
    }
  }
  // Clear sound queue from previous frame
  @types.clear_sound_queue(game)
  // Update particles
  @types.update_particles(game, dt)
  @types.update_trail_particles(game, dt)
  @types.update_damage_numbers(game, dt)
  @types.update_achievement_toasts(game.achievements, dt)
  // Update weapon effects
  @types.update_weapon_effects(game, dt)
  // Update weapon switch flash
  @types.update_weapon_switch_flash(game, dt)
  // BPM animation
  if game.bpm_anim_timer > 0.0F {
    game.bpm_anim_timer = game.bpm_anim_timer - dt
    let progress = 1.0F - game.bpm_anim_timer / 1.5F
    game.bpm_anim_value = game.bpm_anim_value + (game.bpm_anim_target - game.bpm_anim_value) * @types.clampf(progress, 0.0F, 1.0F)
  }
  // Update border flash
  if game.border_flash_timer > 0.0F {
    game.border_flash_timer = game.border_flash_timer - dt
    if game.border_flash_timer <= 0.0F {
      game.border_flash_color = None
    }
  }
  // Decay screen shake
  if game.screen_shake > 0.0F {
    game.screen_shake = game.screen_shake * 0.9F
    if game.screen_shake < 0.5F {
      game.screen_shake = 0.0F
    }
  }
  // Decay combo scale toward 1.0
  if game.combo_scale > 1.0F {
    game.combo_scale = game.combo_scale - dt * 3.0F
    if game.combo_scale < 1.0F {
      game.combo_scale = 1.0F
    }
  }
  // Decay combo visual intensity
  if game.combo_visual_intensity > 0.0F {
    game.combo_visual_intensity = game.combo_visual_intensity - dt * 2.0F
    if game.combo_visual_intensity < 0.0F {
      game.combo_visual_intensity = 0.0F
    }
  }
  // Update combo state timers
  update_combo_state(game)
  match game.screen {
    Title => update_title(game)
    Playing => update_playing(game, dt)
    BeatFail => update_beat_fail(game)
    LevelComplete => update_level_complete(game)
    GameOver => update_game_over(game)
    FloorSelect => update_floor_select(game)
    Shop => update_shop(game)
    FloorTransition => update_floor_transition(game, dt)
    BossIntro => update_boss_intro(game, dt)
    AbilityChoice => update_ability_choice(game)
    RunSummary => update_run_summary(game)
    CurseOffer => update_curse_offer(game)
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    start_new_game(game)
  }
}

///|
fn update_floor_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    let floor_num = game.floors_cleared + 1
    // Start floor transition
    game.transition_floor = floor_num
    game.transition_timer = @types.floor_transition_duration
    game.screen = FloorTransition
  }
}

///|
fn update_floor_transition(game : @types.Game, dt : Float) -> Unit {
  game.transition_timer = game.transition_timer - dt
  if game.transition_timer <= 0.0F {
    let floor_num = game.transition_floor
    // Set BPM and windows for this floor
    let bpm = @types.bpm_for_floor(floor_num)
    let old_bpm = game.beat.bpm
    game.beat.bpm = bpm
    game.beat.perfect_window = @types.perfect_window_for_floor(floor_num)
    game.beat.good_window = @types.good_window_for_floor(floor_num)
    // Apply DoubleTime curse
    if @types.has_curse(game.curses, DoubleTime) {
      game.beat.bpm = game.beat.bpm * (1.0F + @types.curse_bpm_bonus_pct)
    }
    // Apply BlindBeat curse
    if @types.has_curse(game.curses, BlindBeat) {
      game.beat.perfect_window = game.beat.perfect_window + @types.blind_beat_perfect_bonus
    }
    // BPM animation
    start_bpm_animation(game, old_bpm, game.beat.bpm)
    // Account for speed boost widening beat window
    if game.player.speed_boost_beats > 0 {
      game.beat.perfect_window = game.beat.perfect_window + 0.03
      game.beat.good_window = game.beat.good_window + 0.05
    }
    let floor = @content.generate_floor(game, floor_num)
    game.floor = Some(floor)
    game.player.x = 1
    game.player.y = 1
    // Initialize per-floor stats tracking
    @types.start_floor_stats(game, floor_num)
    @beat.reset(game.beat)
    game.beat.bpm = bpm
    // Check if boss floor
    if @types.is_boss_floor(floor_num) {
      game.boss_intro_timer = @types.boss_intro_duration
      game.screen_shake = 10.0
      game.screen = BossIntro
    } else {
      game.is_boss_floor = false
      game.screen = Playing
      @types.set_message(game, "Floor \{floor_num} - Move to the beat!")
    }
  }
}

///|
fn update_boss_intro(game : @types.Game, dt : Float) -> Unit {
  game.boss_intro_timer = game.boss_intro_timer - dt
  if game.boss_intro_timer <= 0.0F {
    game.screen = Playing
    @types.set_message(game, "Defeat the boss!")
  }
}

///|
fn update_playing(game : @types.Game, dt : Float) -> Unit {
  let beat = game.beat
  let new_beat = @beat.tick(beat, dt)
  guard game.floor is Some(floor) else { return }
  if new_beat {
    // Sound event: beat tick
    @types.push_sound(game, BeatTick)
    // Process ability effects on beat
    process_ability_effects_on_beat(game)
    // Tick spell cooldowns
    @types.tick_spell_cooldowns(game.player)
    // Flush pending death explosions on beat
    @types.flush_death_explosions(game)
    // Decrement enemy frozen/stun timers
    for enemy in floor.enemies {
      if enemy.frozen_beats > 0 {
        enemy.frozen_beats = enemy.frozen_beats - 1
      }
      if enemy.stunned_beats > 0 {
        enemy.stunned_beats = enemy.stunned_beats - 1
      }
    }
    // Decrement player buff timers on beat
    if game.player.speed_boost_beats > 0 {
      game.player.speed_boost_beats = game.player.speed_boost_beats - 1
      if game.player.speed_boost_beats == 0 {
        let floor_num = floor.floor_num
        game.beat.perfect_window = @types.perfect_window_for_floor(floor_num)
        game.beat.good_window = @types.good_window_for_floor(floor_num)
      }
    }
    if game.player.beat_freeze_beats > 0 {
      game.player.beat_freeze_beats = game.player.beat_freeze_beats - 1
    }
    // Only execute enemy beats if not frozen
    if game.player.beat_freeze_beats <= 0 {
      execute_enemy_beats(game, floor)
    }
    // Recompute intents for next beat
    let rng = @types.game_rng(game)
    @content.compute_enemy_intents(
      floor, game.player.x, game.player.y, rng, beat.beat_count,
    )
    @types.sync_rng(game, rng)
  }
  // Handle spell input (1-4 keys)
  handle_spell_input(game, floor)
  // Handle player input
  let action = read_player_input()
  match action {
    Some(act) => handle_player_action(game, floor, act)
    None => ()
  }
  // Check for spike damage
  match @types.grid_get(floor.grid, game.player.x, game.player.y) {
    Some(tile) =>
      if tile.kind == Spike && new_beat {
        game.player.hp = game.player.hp - @types.spike_damage
        @types.set_message(game, "Ouch! Spikes!")
        if game.player.hp <= 0 {
          finalize_run(game)
          @types.set_message(game, "You died on the spikes...")
          return
        }
      }
    None => ()
  }
  // Check for lava damage
  match @types.grid_get(floor.grid, game.player.x, game.player.y) {
    Some(tile) =>
      if tile.kind == Lava && new_beat {
        game.player.hp = game.player.hp - @types.lava_damage
        @types.set_message(game, "Burning! Lava!")
        if game.player.hp <= 0 {
          finalize_run(game)
          @types.set_message(game, "Burned alive!")
          return
        }
      }
    None => ()
  }
  // Check for exit - on boss floors, only if all bosses dead
  if game.player.x == floor.exit_x && game.player.y == floor.exit_y {
    let can_exit = if game.is_boss_floor {
      all_bosses_dead(floor)
    } else {
      true
    }
    if can_exit {
      // Compute floor clear bonus
      let floor_bonus = game.player.hp * @types.score_floor_hp_mult +
        game.player.gold * @types.score_floor_gold_mult
      game.score_state.floor_bonus = game.score_state.floor_bonus + floor_bonus
      game.score = game.score + floor_bonus
      game.floors_cleared = game.floors_cleared + 1
      game.is_boss_floor = false
      // Finalize floor stats
      @types.finalize_floor_stats(game)
      @types.push_sound(game, LevelComplete)
      @types.set_message(game, "Floor cleared! +\{floor_bonus} bonus!")
      game.screen = LevelComplete
    } else {
      @types.set_message(game, "Defeat the boss first!")
    }
  }
  // Check for item pickup
  check_item_pickup(game, floor)
}

///|
fn all_bosses_dead(floor : @types.Floor) -> Bool {
  for enemy in floor.enemies {
    if enemy.active {
      match enemy.kind {
        BeatDragon | RhythmLich => return false
        _ => ()
      }
    }
  }
  true
}

///|
fn check_item_pickup(game : @types.Game, floor : @types.Floor) -> Unit {
  let idx = @types.grid_index(
    game.player.x, game.player.y, floor.grid.width,
  )
  let tile = floor.grid.tiles[idx]
  if tile.has_item {
    tile.has_item = false
    // Track item pickup
    game.current_floor_stats.items_collected = game.current_floor_stats.items_collected + 1
    game.run_stats.total_items = game.run_stats.total_items + 1
    @types.push_sound(game, ItemPickup)
    match tile.item {
      Some(Gold(amount)) => {
        game.player.gold = game.player.gold + amount
        game.score = game.score + 25
        @types.set_message(game, "+\{amount} Gold!")
      }
      Some(HealthPotion) => {
        game.player.hp = @types.clampi(
          game.player.hp + 3, 0, game.player.max_hp,
        )
        @types.set_message(game, "Health Potion! +3 HP")
      }
      Some(ShieldOrb) => {
        game.player.shield = game.player.shield + 2
        @types.set_message(game, "Shield Orb! +2 Shield")
      }
      Some(SpeedBoost) => {
        game.player.speed_boost_beats = @types.speed_boost_duration
        // Widen beat windows
        game.beat.perfect_window = game.beat.perfect_window + 0.03
        game.beat.good_window = game.beat.good_window + 0.05
        @types.set_message(game, "Speed Boost! Wider beat window!")
      }
      Some(WeaponUpgrade) => {
        game.player.weapon_damage = game.player.weapon_damage + 1
        @types.set_message(game, "Weapon Upgrade! +1 damage!")
      }
      Some(BeatFreeze) => {
        game.player.beat_freeze_beats = @types.beat_freeze_duration
        @types.set_message(game, "Beat Freeze! Enemies paused!")
      }
      Some(SpecialCharge) => {
        game.player.special_charges = game.player.special_charges + 1
        @types.set_message(game, "Special Charge! +1 special")
      }
      Some(Bomb) => {
        // Explode adjacent enemies
        let dirs : Array[@types.Direction] = [North, South, East, West]
        let mut killed = 0
        for dir in dirs {
          let tx = game.player.x + @types.dir_dx(dir)
          let ty = game.player.y + @types.dir_dy(dir)
          let ei = @types.find_enemy_at(floor.enemies, tx, ty)
          if ei >= 0 {
            let enemy = floor.enemies[ei]
            enemy.hp = enemy.hp - 5
            if enemy.hp <= 0 {
              enemy.active = false
              killed = killed + 1
              let sx = Float::from_int(
                @types.tile_screen_x(enemy.x) + @types.tile_size / 2,
              )
              let sy = Float::from_int(
                @types.tile_screen_y(enemy.y) + @types.tile_size / 2,
              )
              @types.spawn_death_particles(
                game, sx, sy, @types.enemy_color(enemy.kind),
              )
              add_kill_score(game, enemy, Good)
            }
          }
        }
        game.screen_shake = 8.0
        @types.set_message(game, "BOMB! \{killed} enemies hit!")
      }
      None => {
        // Legacy gold pickup
        game.player.gold = game.player.gold + 10
        game.score = game.score + 25
        @types.set_message(game, "+10 Gold!")
      }
    }
    tile.item = None
  }
}

///|
fn read_player_input() -> @types.PlayerAction? {
  if @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyW) {
    Some(Move(North))
  } else if @raylib.is_key_pressed(@raylib.KeyDown) ||
    @raylib.is_key_pressed(@raylib.KeyS) {
    Some(Move(South))
  } else if @raylib.is_key_pressed(@raylib.KeyLeft) ||
    @raylib.is_key_pressed(@raylib.KeyA) {
    Some(Move(West))
  } else if @raylib.is_key_pressed(@raylib.KeyRight) ||
    @raylib.is_key_pressed(@raylib.KeyD) {
    Some(Move(East))
  } else if @raylib.is_key_pressed(@raylib.KeySpace) {
    Some(Special)
  } else {
    None
  }
}

///|
fn add_kill_score(
  game : @types.Game,
  enemy : @types.Enemy,
  rating : @types.BeatRating,
) -> Unit {
  let base = enemy.max_hp * @types.score_kill_base_mult
  let rating_mult = @types.score_rating_mult(rating)
  let combo_bonus = game.beat.combo * @types.score_combo_bonus
  let total = (Float::from_int(base) * rating_mult).to_int() + combo_bonus
  game.score_state.base_kills = game.score_state.base_kills + base
  game.score_state.beat_bonus = game.score_state.beat_bonus +
    (Float::from_int(base) * (rating_mult - 1.0F)).to_int()
  game.score_state.combo_bonus = game.score_state.combo_bonus + combo_bonus
  game.score = game.score + total
}

///|
fn trigger_border_flash(game : @types.Game, rating : @types.BeatRating) -> Unit {
  let color = match rating {
    Perfect => @types.color_perfect
    Good => @types.color_good
    Miss => @types.color_miss
  }
  game.border_flash_color = Some(color)
  game.border_flash_timer = 0.2
}

///|
fn handle_player_action(
  game : @types.Game,
  floor : @types.Floor,
  action : @types.PlayerAction,
) -> Unit {
  let beat = game.beat
  let rating = @beat.rate_input(beat)
  @beat.update_combo(beat, rating)
  // Trigger border flash and combo scale
  trigger_border_flash(game, rating)
  // Sound events for beat rating
  match rating {
    Perfect => @types.push_sound(game, BeatPerfect)
    Good => @types.push_sound(game, BeatGood)
    Miss => @types.push_sound(game, BeatMiss)
  }
  // Track perfects and mana regen
  match rating {
    Perfect => {
      game.player.consecutive_perfects = game.player.consecutive_perfects + 1
      game.run_perfects = game.run_perfects + 1
      game.current_floor_stats.perfects_hit = game.current_floor_stats.perfects_hit + 1
      // Mana regen on Perfect
      game.player.mana = @types.clampi(
        game.player.mana + @types.mana_regen_on_perfect, 0, game.player.max_mana,
      )
      // Achievement: Perfect 10
      if game.player.consecutive_perfects >= 10 {
        let _ = @types.check_achievement(game.achievements, Perfect10)
      }
    }
    Good => game.player.consecutive_perfects = 0
    Miss => game.player.consecutive_perfects = 0
  }
  match rating {
    Miss => {
      @types.set_message(game, "MISS! Lost the beat!")
      game.player.hp = game.player.hp - @types.miss_damage
      game.combo_state.storm_triggered = false
      if game.player.hp <= 0 {
        finalize_run(game)
        @types.set_message(game, "Game Over - missed too many beats")
        return
      }
      game.screen = BeatFail
      game.message_timer = 0.3
    }
    _ => {
      // Bump combo scale on combo increase
      if beat.combo > 1 {
        game.combo_scale = 1.0F + Float::from_int(
            @types.clampi(beat.combo, 0, 20),
          ) *
          0.05
      }
      // Add combo streak bonus
      let combo_pts = beat.combo * @types.score_combo_bonus
      game.score_state.combo_bonus = game.score_state.combo_bonus + combo_pts
      game.score = game.score + combo_pts
      // Check combo milestones
      process_combo_milestone(game, beat.combo)
      // Good or Perfect - execute action
      match action {
        Move(dir) => {
          game.player.facing = dir
          let nx = game.player.x + @types.dir_dx(dir)
          let ny = game.player.y + @types.dir_dy(dir)
          // Check if enemy is at target (weapon attack)
          let enemy_idx = @types.find_enemy_at(floor.enemies, nx, ny)
          if enemy_idx >= 0 {
            // Use weapon system
            if @types.weapon_can_attack(game.player.weapon, game.player.weapon_beat_counter) {
              weapon_attack_enemies(game, floor, dir, rating)
            } else {
              @types.set_message(game, "Weapon charging...")
            }
          } else if @types.grid_is_walkable(floor.grid, nx, ny) {
            game.player.x = nx
            game.player.y = ny
            // Trail particles on beat-synced movement
            let trail_sx = Float::from_int(
              @types.tile_screen_x(nx) + @types.tile_size / 2,
            )
            let trail_sy = Float::from_int(
              @types.tile_screen_y(ny) + @types.tile_size / 2,
            )
            @types.spawn_trail_particles(game, trail_sx, trail_sy)
            // Double Step: move extra tile on Perfect
            if rating == Perfect && @types.has_ability(game.player, DoubleStep) {
              let nx2 = game.player.x + @types.dir_dx(dir)
              let ny2 = game.player.y + @types.dir_dy(dir)
              if @types.grid_is_walkable(floor.grid, nx2, ny2) &&
                @types.find_enemy_at(floor.enemies, nx2, ny2) < 0 {
                game.player.x = nx2
                game.player.y = ny2
              }
            }
            // Ice slide
            match @types.grid_get(floor.grid, game.player.x, game.player.y) {
              Some(tile) =>
                if tile.kind == Ice {
                  let sx = game.player.x + @types.dir_dx(dir)
                  let sy = game.player.y + @types.dir_dy(dir)
                  if @types.grid_is_walkable(floor.grid, sx, sy) &&
                    @types.find_enemy_at(floor.enemies, sx, sy) < 0 {
                    game.player.x = sx
                    game.player.y = sy
                  }
                }
              None => ()
            }
            @types.set_message(game, @types.rating_text(rating))
          } else {
            @types.set_message(game, "\{@types.rating_text(rating)} Blocked!")
          }
        }
        Attack(dir) => {
          game.player.facing = dir
          if @types.weapon_can_attack(game.player.weapon, game.player.weapon_beat_counter) {
            weapon_attack_enemies(game, floor, dir, rating)
          } else {
            @types.set_message(game, "Weapon charging...")
          }
        }
        Special => {
          if game.player.special_charges > 0 {
            game.player.special_charges = game.player.special_charges - 1
            let dirs : Array[@types.Direction] = [North, South, East, West]
            for dir in dirs {
              let tx = game.player.x + @types.dir_dx(dir)
              let ty = game.player.y + @types.dir_dy(dir)
              let ei = @types.find_enemy_at(floor.enemies, tx, ty)
              if ei >= 0 {
                let dmg = @beat.compute_damage(
                  game.player.weapon_damage + 2, beat, rating,
                )
                floor.enemies[ei].hp = floor.enemies[ei].hp - dmg
                if floor.enemies[ei].hp <= 0 {
                  floor.enemies[ei].active = false
                  game.run_kills = game.run_kills + 1
                  add_kill_score(game, floor.enemies[ei], rating)
                  let sx = Float::from_int(
                    @types.tile_screen_x(floor.enemies[ei].x) +
                    @types.tile_size / 2,
                  )
                  let sy = Float::from_int(
                    @types.tile_screen_y(floor.enemies[ei].y) +
                    @types.tile_size / 2,
                  )
                  @types.spawn_death_particles(
                    game,
                    sx,
                    sy,
                    @types.enemy_color(floor.enemies[ei].kind),
                  )
                }
              }
            }
            game.screen_shake = 5.0
            @types.set_message(game, "SPECIAL ATTACK!")
          } else {
            @types.set_message(game, "No charges left!")
          }
        }
        Wait => @types.set_message(game, @types.rating_text(rating))
      }
      // Sync player combo with beat combo for display
      game.player.combo = beat.combo
      if beat.combo > game.player.max_combo {
        game.player.max_combo = beat.combo
      }
    }
  }
}

///|
fn execute_enemy_beats(game : @types.Game, floor : @types.Floor) -> Unit {
  for enemy in floor.enemies {
    if !(enemy.active) {
      continue
    }
    @beat.advance_enemy_pattern(enemy)
    if !(@beat.enemy_acts_this_beat(enemy)) {
      continue
    }
    // Frozen/stunned enemies skip their turn
    if enemy.frozen_beats > 0 || enemy.stunned_beats > 0 {
      continue
    }
    match enemy.intent {
      Move(dir) => {
        let nx = enemy.x + @types.dir_dx(dir)
        let ny = enemy.y + @types.dir_dy(dir)
        if @types.grid_is_walkable(floor.grid, nx, ny) &&
          !(@types.has_enemy_at(floor.enemies, nx, ny)) &&
          !(nx == game.player.x && ny == game.player.y) {
          enemy.x = nx
          enemy.y = ny
        }
        // Elite Bat: double move
        if enemy.is_elite && enemy.kind == Bat {
          @content.elite_bat_double_move(enemy, floor, game.player.x, game.player.y)
        }
      }
      Attack(_dir, dmg) => {
        // Elite Skeleton: cross-pattern attack
        if enemy.is_elite && enemy.kind == Skeleton {
          let cells = @content.elite_skeleton_cross_cells(enemy.x, enemy.y)
          for cell in cells {
            let (cx, cy) = cell
            if cx == game.player.x && cy == game.player.y {
              if game.player.invincible_beats <= 0 && !(try_shadow_dodge(game)) {
                let actual = if game.player.shield > 0 {
                  game.player.shield = game.player.shield - 1
                  (dmg + 1) / 2
                } else {
                  dmg
                }
                game.player.hp = game.player.hp - actual
                @types.set_message(game, "Cross attack! -\{actual} HP!")
                if game.player.hp <= 0 {
                  finalize_run(game)
                }
              }
              break
            }
          }
          continue
        }
        // Check if player is still adjacent
        let dist = @types.manhattan_dist(
          enemy.x, enemy.y, game.player.x, game.player.y,
        )
        if dist <= 1 {
          // Check invincibility from Fever
          if game.player.invincible_beats > 0 {
            @types.set_message(game, "INVINCIBLE! Attack blocked!")
            try_counter_attack(game, floor)
          } else if try_shadow_dodge(game) {
            @types.set_message(game, "Shadow Dodge!")
            try_counter_attack(game, floor)
          } else {
            let actual_dmg = if game.player.shield > 0 {
              game.player.shield = game.player.shield - 1
              (dmg + 1) / 2
            } else {
              dmg
            }
            game.player.hp = game.player.hp - actual_dmg
            game.current_floor_stats.damage_taken = game.current_floor_stats.damage_taken + actual_dmg
            game.run_stats.total_damage_taken = game.run_stats.total_damage_taken + actual_dmg
            @types.push_sound(game, PlayerHit)
            @types.set_message(game, "Hit for \{actual_dmg} damage!")
            if game.player.hp <= 0 {
              finalize_run(game)
              @types.set_message(game, "Game Over!")
            }
          }
        }
      }
      Charge(dir, power) => {
        let mut cx = enemy.x
        let mut cy = enemy.y
        for _ in 0..<2 {
          let nx = cx + @types.dir_dx(dir)
          let ny = cy + @types.dir_dy(dir)
          if @types.grid_is_walkable(floor.grid, nx, ny) &&
            !(@types.has_enemy_at(floor.enemies, nx, ny)) {
            if nx == game.player.x && ny == game.player.y {
              if game.player.invincible_beats <= 0 {
                game.player.hp = game.player.hp - power
                if game.player.hp <= 0 {
                  finalize_run(game)
                }
              }
              break
            }
            cx = nx
            cy = ny
          } else {
            break
          }
        }
        enemy.x = cx
        enemy.y = cy
      }
      Summon(kind, sx, sy) => {
        if @types.grid_is_walkable(floor.grid, sx, sy) &&
          !(@types.has_enemy_at(floor.enemies, sx, sy)) {
          let new_id = floor.enemies.length()
          floor.enemies.push(@content.make_enemy(kind, new_id, sx, sy))
        }
      }
      BreathFire(dir, dmg) => {
        // Fire breath in a line of 3 tiles
        let mut fx = enemy.x
        let mut fy = enemy.y
        for _ in 0..<3 {
          fx = fx + @types.dir_dx(dir)
          fy = fy + @types.dir_dy(dir)
          if !@types.in_bounds(fx, fy, floor.grid.width, floor.grid.height) {
            break
          }
          // Set tile to spike briefly (fire)
          @types.grid_set_kind(floor.grid, fx, fy, Spike)
          if fx == game.player.x && fy == game.player.y {
            if game.player.invincible_beats > 0 {
              @types.set_message(game, "INVINCIBLE! Fire blocked!")
            } else {
              let actual = if game.player.shield > 0 {
                game.player.shield = game.player.shield - 1
                (dmg + 1) / 2
              } else {
                dmg
              }
              game.player.hp = game.player.hp - actual
              @types.set_message(game, "Fire breath! -\{actual} HP!")
              if game.player.hp <= 0 {
                finalize_run(game)
                @types.set_message(game, "Burned to a crisp!")
              }
            }
          }
        }
        game.screen_shake = 6.0F
      }
      AoeFreeze(radius) => {
        // Freeze tiles around player position
        let apx = game.player.x
        let apy = game.player.y
        let neg_r = 0 - radius
        for dy = neg_r; dy <= radius; dy = dy + 1 {
          for dx = neg_r; dx <= radius; dx = dx + 1 {
            let fx = apx + dx
            let fy = apy + dy
            if @types.in_bounds(fx, fy, floor.grid.width, floor.grid.height) {
              match @types.grid_get(floor.grid, fx, fy) {
                Some(tile) =>
                  if tile.kind == Floor {
                    @types.grid_set_kind(floor.grid, fx, fy, Ice)
                  }
                None => ()
              }
            }
          }
        }
        @types.set_message(game, "Lich casts Ice!")
        game.screen_shake = 4.0F
      }
      Wait => ()
    }
  }
}

///|
fn update_beat_fail(game : @types.Game) -> Unit {
  // Brief pause after a miss
  if game.message_timer <= 0.0F {
    game.screen = Playing
  }
}

///|
fn update_level_complete(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    // Update floor mastery
    let total_actions = game.run_perfects + 1
    let pct = game.run_perfects * 100 / total_actions
    @types.update_floor_mastery(game.meta, game.floors_cleared, pct)
    // Achievement: Pacifist (no attacks on floor)
    if game.player.floor_attacks == 0 {
      let _ = @types.check_achievement(game.achievements, Pacifist)
    }
    // Achievement: Speed Demon (floor 10 under 200 beats)
    if game.floors_cleared == 10 && game.beat.beat_count < 200 {
      let _ = @types.check_achievement(game.achievements, SpeedDemon)
    }
    // Reset per-floor counters
    game.player.floor_attacks = 0
    if game.floors_cleared >= @types.max_floor {
      finalize_run(game)
      @types.set_message(game, "YOU WIN! All floors cleared!")
    } else if game.is_boss_floor {
      // Achievement: Boss Slayer
      let _ = @types.check_achievement(game.achievements, BossSlayer)
      // After boss: offer curse, then ability choice
      offer_curse_choice(game)
    } else {
      setup_shop(game)
      game.screen = Shop
    }
  }
}

///|
fn setup_shop(game : @types.Game) -> Unit {
  let rng = @types.game_rng(game)
  let all_kinds : Array[@types.ShopItemKind] = [
    ShopHealthPotion, ShopShield, ShopWeaponUpgrade, ShopSpecialCharge,
    ShopBeatWindow, ShopManaPotion,
  ]
  game.shop_items.clear()
  for _ in 0..<4 {
    let idx = @types.rand_range(rng, 0, all_kinds.length() - 1)
    game.shop_items.push(@types.make_shop_entry(all_kinds[idx]))
  }
  // Offer a random weapon every other floor
  if game.floors_cleared % 2 == 0 {
    let weapons = @types.all_weapon_kinds()
    let wi = @types.rand_range(rng, 0, weapons.length() - 1)
    let wk = weapons[wi]
    if wk != game.player.weapon {
      game.shop_items.push(@types.make_shop_entry(ShopWeapon(wk)))
    }
  }
  // Offer a spell every 3 floors
  if game.floors_cleared % 3 == 0 && game.floors_cleared > 0 {
    let spells = @types.all_spell_kinds()
    let si = @types.rand_range(rng, 0, spells.length() - 1)
    let sk = spells[si]
    if !@types.has_spell(game.player, sk) {
      game.shop_items.push(@types.make_shop_entry(ShopSpell(sk)))
    }
  }
  game.shop_cursor = 0
  @types.sync_rng(game, rng)
}

///|
fn update_shop(game : @types.Game) -> Unit {
  // Navigate with up/down
  if @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyW) {
    game.shop_cursor = game.shop_cursor - 1
    if game.shop_cursor < 0 {
      game.shop_cursor = game.shop_items.length()
      // Extra slot for "Leave Shop"
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) ||
    @raylib.is_key_pressed(@raylib.KeyS) {
    game.shop_cursor = game.shop_cursor + 1
    if game.shop_cursor > game.shop_items.length() {
      game.shop_cursor = 0
    }
  }
  // Buy with Enter/Space
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.shop_cursor >= game.shop_items.length() {
      // Leave shop
      game.screen = FloorSelect
      @types.set_message(game, "Onward!")
    } else {
      let entry = game.shop_items[game.shop_cursor]
      if game.player.gold >= entry.price {
        game.player.gold = game.player.gold - entry.price
        apply_shop_purchase(game, entry.kind)
        @types.push_sound(game, ShopPurchase)
        @types.set_message(game, "Purchased \{entry.name}!")
      } else {
        @types.set_message(game, "Not enough gold!")
      }
    }
  }
  // Quick exit with Escape
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = FloorSelect
  }
}

///|
fn apply_shop_purchase(game : @types.Game, kind : @types.ShopItemKind) -> Unit {
  match kind {
    ShopHealthPotion =>
      game.player.hp = @types.clampi(
        game.player.hp + 3, 0, game.player.max_hp,
      )
    ShopShield => game.player.shield = game.player.shield + 2
    ShopWeaponUpgrade =>
      game.player.weapon_damage = game.player.weapon_damage + 1
    ShopSpecialCharge =>
      game.player.special_charges = game.player.special_charges + 1
    ShopBeatWindow => {
      game.beat.perfect_window = game.beat.perfect_window + 0.01
      game.beat.good_window = game.beat.good_window + 0.02
    }
    ShopWeapon(wk) => {
      game.player.weapon = wk
      game.player.weapon_beat_counter = 0
      @types.trigger_weapon_switch_flash(game)
    }
    ShopSpell(sk) => {
      if !@types.has_spell(game.player, sk) {
        game.player.learned_spells.push(sk)
        let _ = @types.equip_spell(game.player, sk)
        @types.set_message(game, "Learned \{@types.spell_data(sk).name}!")
      } else {
        @types.set_message(game, "Already known!")
        // Refund
        game.player.gold = game.player.gold + @types.shop_item_price(kind)
      }
    }
    ShopManaPotion =>
      game.player.mana = @types.clampi(
        game.player.mana + 5, 0, game.player.max_mana,
      )
  }
}

///|
fn update_game_over(game : @types.Game) -> Unit {
  // GameOver is now only used for backwards compat; RunSummary is preferred
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    start_new_game(game)
  }
}

///|
fn update_combo_state(game : @types.Game) -> Unit {
  let cs = game.combo_state
  if cs.milestone_flash_timer > 0.0F {
    cs.milestone_flash_timer = cs.milestone_flash_timer - 0.016F
    if cs.milestone_flash_timer < 0.0F {
      cs.milestone_flash_timer = 0.0F
    }
  }
}

///|
fn process_combo_milestone(game : @types.Game, combo : Int) -> Unit {
  // Achievement: Combo King
  if combo >= 50 {
    let _ = @types.check_achievement(game.achievements, ComboKing)
  }
  let ms = @types.check_combo_milestone(combo)
  let cs = game.combo_state
  match ms {
    Fever => {
      cs.fever_active = true
      cs.fever_beats = @types.fever_duration
      cs.last_milestone = Fever
      cs.milestone_flash_timer = 1.5F
      game.player.invincible_beats = @types.fever_duration
      @types.set_message(game, "FEVER! Invincible!")
      game.screen_shake = 4.0F
      @types.push_sound(game, ComboMilestoneSound(Fever))
      @types.spawn_milestone_burst(game, Fever)
    }
    Frenzy => {
      cs.frenzy_active = true
      cs.frenzy_beats = @types.frenzy_duration
      cs.last_milestone = Frenzy
      cs.milestone_flash_timer = 1.5F
      game.player.double_damage_beats = @types.frenzy_duration
      @types.set_message(game, "FRENZY! Double damage!")
      game.screen_shake = 6.0F
      @types.push_sound(game, ComboMilestoneSound(Frenzy))
      @types.spawn_milestone_burst(game, Frenzy)
    }
    PerfectStorm => {
      cs.storm_triggered = true
      cs.last_milestone = PerfectStorm
      cs.milestone_flash_timer = 2.0F
      // Damage all enemies + full heal
      guard game.floor is Some(floor) else { return }
      for enemy in floor.enemies {
        if enemy.active {
          enemy.hp = enemy.hp - 5
          if enemy.hp <= 0 {
            enemy.active = false
            game.run_kills = game.run_kills + 1
            let sx = Float::from_int(
              @types.tile_screen_x(enemy.x) + @types.tile_size / 2,
            )
            let sy = Float::from_int(
              @types.tile_screen_y(enemy.y) + @types.tile_size / 2,
            )
            @types.spawn_death_particles(
              game, sx, sy, @types.enemy_color(enemy.kind),
            )
          }
        }
      }
      game.player.hp = game.player.max_hp
      @types.set_message(game, "PERFECT STORM! Full heal + AoE!")
      game.screen_shake = 10.0F
      @types.push_sound(game, ComboMilestoneSound(PerfectStorm))
      @types.spawn_milestone_burst(game, PerfectStorm)
    }
    NoMilestone => ()
  }
  // Update visual intensity
  let level = @types.combo_visual_level(combo)
  game.combo_visual_intensity = Float::from_int(level) / 3.0F
}

///|
fn process_ability_effects_on_beat(game : @types.Game) -> Unit {
  let player = game.player
  // Decrement invincibility
  if player.invincible_beats > 0 {
    player.invincible_beats = player.invincible_beats - 1
  }
  // Decrement double damage
  if player.double_damage_beats > 0 {
    player.double_damage_beats = player.double_damage_beats - 1
  }
  // Decrement combo state
  let cs = game.combo_state
  if cs.fever_beats > 0 {
    cs.fever_beats = cs.fever_beats - 1
    if cs.fever_beats <= 0 {
      cs.fever_active = false
    }
  }
  if cs.frenzy_beats > 0 {
    cs.frenzy_beats = cs.frenzy_beats - 1
    if cs.frenzy_beats <= 0 {
      cs.frenzy_active = false
    }
  }
  // Heal Beat: heal 1 HP every 16 consecutive perfects
  if @types.has_ability(player, HealBeat) {
    if player.consecutive_perfects > 0 &&
      player.consecutive_perfects % @types.heal_beat_threshold == 0 {
      player.hp = @types.clampi(player.hp + 1, 0, player.max_hp)
      @types.set_message(game, "Heal Beat! +1 HP")
    }
  }
  // Rhythm Shield: +1 shield every 8 combo
  if @types.has_ability(player, RhythmShield) {
    let combo = game.beat.combo
    if combo > 0 && combo % @types.shield_combo_threshold == 0 {
      player.shield = player.shield + 1
    }
  }
  // Weapon beat counter
  player.weapon_beat_counter = player.weapon_beat_counter + 1
}

///|
fn weapon_attack_enemies(
  game : @types.Game,
  floor : @types.Floor,
  dir : @types.Direction,
  rating : @types.BeatRating,
) -> Unit {
  let player = game.player
  let weapon = player.weapon
  let cells = @types.weapon_attack_cells(weapon, dir)
  let base_dmg = @types.weapon_base_damage(weapon) + player.weapon_damage - 1
  // Glass Cannon curse: 2x damage
  let curse_mult = if @types.has_curse(game.curses, GlassCannon) { 2 } else { 1 }
  let effective_dmg = if player.double_damage_beats > 0 {
    base_dmg * 2 * curse_mult
  } else {
    base_dmg * curse_mult
  }
  let dmg = @beat.compute_damage(effective_dmg, game.beat, rating)
  let mut hit_any = false
  player.floor_attacks = player.floor_attacks + 1
  // Track weapon usage
  @types.record_weapon_usage(game, weapon)
  // Spawn weapon visual effect
  let effect_x = Float::from_int(
    @types.tile_screen_x(player.x) + @types.tile_size / 2,
  )
  let effect_y = Float::from_int(
    @types.tile_screen_y(player.y) + @types.tile_size / 2,
  )
  @types.spawn_weapon_effect(game, weapon, effect_x, effect_y, dir)
  // Sound event: player attack
  @types.push_sound(game, PlayerAttack)
  for cell in cells {
    let (dx, dy) = cell
    let tx = player.x + dx
    let ty = player.y + dy
    let ei = @types.find_enemy_at(floor.enemies, tx, ty)
    if ei >= 0 {
      let enemy = floor.enemies[ei]
      enemy.hp = enemy.hp - dmg
      hit_any = true
      let sx = Float::from_int(
        @types.tile_screen_x(enemy.x) + @types.tile_size / 2,
      )
      let sy = Float::from_int(
        @types.tile_screen_y(enemy.y) + @types.tile_size / 2,
      )
      // Spawn damage number
      @types.spawn_damage_number(game, sx, sy - 10.0F, dmg, rating)
      // Track damage dealt
      game.current_floor_stats.damage_dealt = game.current_floor_stats.damage_dealt + dmg
      game.run_stats.total_damage_dealt = game.run_stats.total_damage_dealt + dmg
      // Check boss phase transition
      let _ = @types.check_boss_phase_transition(game, enemy.kind, enemy.hp, enemy.max_hp)
      if enemy.hp <= 0 {
        enemy.active = false
        game.run_kills = game.run_kills + 1
        game.current_floor_stats.enemies_killed = game.current_floor_stats.enemies_killed + 1
        add_kill_score(game, enemy, rating)
        // Beat-synced death explosion (queued for next beat)
        @types.queue_death_explosion(game, sx, sy, @types.enemy_color(enemy.kind))
        // Sound: enemy death
        @types.push_sound(game, EnemyDeath)
        // Achievement: First Blood
        if game.run_kills == 1 {
          let _ = @types.check_achievement(game.achievements, FirstBlood)
        }
        // Elite Slime splits
        if enemy.is_elite && enemy.kind == Slime {
          let splits = @content.elite_slime_split(
            enemy.x, enemy.y, floor.enemies.length(), floor,
          )
          for s in splits {
            floor.enemies.push(s)
          }
        }
        // Drop spell on elite kill
        if enemy.is_elite {
          maybe_drop_spell(game)
          game.player.gold = game.player.gold + @types.elite_gold_drop
        }
      }
    }
  }
  if hit_any {
    @types.set_message(
      game, "\{@types.rating_text(rating)} \{@types.weapon_data(weapon).name} Hit! \{dmg} dmg",
    )
  }
}

///|
fn try_counter_attack(game : @types.Game, floor : @types.Floor) -> Unit {
  if !@types.has_ability(game.player, CounterAttack) {
    return
  }
  // Attack all adjacent enemies
  let dirs : Array[@types.Direction] = [North, South, East, West]
  for dir in dirs {
    let tx = game.player.x + @types.dir_dx(dir)
    let ty = game.player.y + @types.dir_dy(dir)
    let ei = @types.find_enemy_at(floor.enemies, tx, ty)
    if ei >= 0 {
      let enemy = floor.enemies[ei]
      enemy.hp = enemy.hp - 1
      if enemy.hp <= 0 {
        enemy.active = false
        game.run_kills = game.run_kills + 1
        let sx = Float::from_int(
          @types.tile_screen_x(enemy.x) + @types.tile_size / 2,
        )
        let sy = Float::from_int(
          @types.tile_screen_y(enemy.y) + @types.tile_size / 2,
        )
        @types.spawn_death_particles(
          game, sx, sy, @types.enemy_color(enemy.kind),
        )
      }
    }
  }
}

///|
fn try_shadow_dodge(game : @types.Game) -> Bool {
  if !@types.has_ability(game.player, ShadowDodge) {
    return false
  }
  if game.beat.last_rating != Good {
    return false
  }
  let rng = @types.game_rng(game)
  let roll = @types.rand_range(rng, 0, 99)
  @types.sync_rng(game, rng)
  roll < @types.shadow_dodge_chance
}

///|
fn update_ability_choice(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyW) {
    game.ability_cursor = game.ability_cursor - 1
    if game.ability_cursor < 0 {
      game.ability_cursor = game.ability_choices.length() - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) ||
    @raylib.is_key_pressed(@raylib.KeyS) {
    game.ability_cursor = game.ability_cursor + 1
    if game.ability_cursor >= game.ability_choices.length() {
      game.ability_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.ability_cursor < game.ability_choices.length() {
      let choice = game.ability_choices[game.ability_cursor]
      game.player.abilities.push(choice.ability)
      @types.set_message(
        game, "Unlocked: \{choice.name}!",
      )
    }
    game.choosing_ability = false
    // After boss: go to shop
    setup_shop(game)
    game.screen = Shop
  }
}

///|
fn offer_ability_choices(game : @types.Game) -> Unit {
  let all = @types.all_ability_kinds()
  let available : Array[@types.AbilityKind] = []
  for a in all {
    if !@types.has_ability(game.player, a) {
      available.push(a)
    }
  }
  game.ability_choices.clear()
  let rng = @types.game_rng(game)
  let count = if available.length() < 3 { available.length() } else { 3 }
  let used : Array[Int] = []
  for _ in 0..<count {
    for _ in 0..<20 {
      let idx = @types.rand_range(rng, 0, available.length() - 1)
      let mut already = false
      for u in used {
        if u == idx {
          already = true
          break
        }
      }
      if !already {
        used.push(idx)
        game.ability_choices.push(@types.make_ability_choice(available[idx]))
        break
      }
    }
  }
  @types.sync_rng(game, rng)
  game.ability_cursor = 0
  game.choosing_ability = true
  game.screen = AbilityChoice
}

///|
fn update_run_summary(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    start_new_game(game)
  }
}

///|
fn finalize_run(game : @types.Game) -> Unit {
  // Apply curse score multiplier
  let mult = curse_score_multiplier(game)
  if mult > 1.0F {
    game.score = (Float::from_int(game.score) * mult).to_int()
  }
  // Count bosses defeated this run
  let mut bosses = 0
  if game.floors_cleared >= 5 {
    bosses = bosses + 1
  }
  if game.floors_cleared >= 10 {
    bosses = bosses + 1
  }
  @types.update_meta_after_run(
    game.meta,
    game.score,
    game.beat.max_combo,
    game.floors_cleared,
    bosses,
    game.run_kills,
    game.run_perfects,
    game.player.weapon,
  )
  game.score_state.total = game.score
  game.screen = RunSummary
}

///|
fn start_new_game(game : @types.Game) -> Unit {
  game.player.x = 1
  game.player.y = 1
  game.player.hp = game.player.max_hp
  game.player.gold = 0
  game.player.combo = 0
  game.player.max_combo = 0
  game.player.weapon_damage = 1
  game.player.shield = 0
  game.player.special_charges = 3
  game.player.beat_multiplier = 1.0
  game.player.speed_boost_beats = 0
  game.player.beat_freeze_beats = 0
  game.player.weapon = Sword
  game.player.weapon_beat_counter = 0
  game.player.abilities.clear()
  game.player.consecutive_perfects = 0
  game.player.facing = South
  game.player.invincible_beats = 0
  game.player.double_damage_beats = 0
  game.player.mana = game.player.max_mana
  game.player.spell_slots.spells[0] = None
  game.player.spell_slots.spells[1] = None
  game.player.spell_slots.spells[2] = None
  game.player.spell_slots.spells[3] = None
  game.player.spell_slots.cooldowns[0] = 0
  game.player.spell_slots.cooldowns[1] = 0
  game.player.spell_slots.cooldowns[2] = 0
  game.player.spell_slots.cooldowns[3] = 0
  game.player.learned_spells.clear()
  game.player.floor_attacks = 0
  game.score = 0
  game.floors_cleared = 0
  game.floor = None
  game.is_boss_floor = false
  game.particles.clear()
  game.trail_particles.clear()
  game.damage_numbers.clear()
  game.pending_death_explosions.clear()
  game.border_flash_color = None
  game.border_flash_timer = 0.0
  game.combo_scale = 1.0
  game.screen_shake = 0.0
  game.score_state.base_kills = 0
  game.score_state.beat_bonus = 0
  game.score_state.combo_bonus = 0
  game.score_state.floor_bonus = 0
  game.score_state.total = 0
  game.combo_state.fever_active = false
  game.combo_state.fever_beats = 0
  game.combo_state.frenzy_active = false
  game.combo_state.frenzy_beats = 0
  game.combo_state.storm_triggered = false
  game.combo_state.last_milestone = NoMilestone
  game.combo_state.milestone_flash_timer = 0.0
  game.floor_theme = None
  game.ability_choices.clear()
  game.ability_cursor = 0
  game.choosing_ability = false
  game.combo_visual_intensity = 0.0
  game.run_perfects = 0
  game.run_kills = 0
  game.curses.active_curses.clear()
  game.curse_offers.clear()
  game.curse_cursor = 0
  game.showing_curse_offer = false
  game.bpm_anim_value = 0.0
  game.bpm_anim_target = 0.0
  game.bpm_anim_timer = 0.0
  // Reset Phase 5 fields
  game.sound_queue.clear()
  game.weapon_effects.clear()
  @types.reset_boss_phases(game)
  @types.reset_run_stats(game)
  game.current_floor_stats = @types.FloorStats::new(0)
  game.weapon_switch_flash = 0.0
  game.floor_wipe_progress = 0.0
  game.boss_intro_pulse = 0.0
  @beat.reset(game.beat)
  game.beat.bpm = @types.bpm_for_floor(1)
  game.beat.perfect_window = @types.perfect_window_for_floor(1)
  game.beat.good_window = @types.good_window_for_floor(1)
  game.screen = FloorSelect
  @types.set_message(game, "Choose your floor!")
}

// ============================================================
// === Spell System ===
// ============================================================

///|
fn handle_spell_input(game : @types.Game, floor : @types.Floor) -> Unit {
  let keys : Array[Int] = [
    @raylib.KeyOne, @raylib.KeyTwo, @raylib.KeyThree, @raylib.KeyFour,
  ]
  for i in 0..<4 {
    if @raylib.is_key_pressed(keys[i]) {
      if @types.can_cast_spell(game.player, i) {
        match game.player.spell_slots.spells[i] {
          Some(kind) => cast_spell(game, floor, kind, i)
          None => ()
        }
      } else {
        match game.player.spell_slots.spells[i] {
          Some(_) => @types.set_message(game, "Spell not ready!")
          None => @types.set_message(game, "No spell in slot \{i + 1}")
        }
      }
    }
  }
}

///|
fn cast_spell(
  game : @types.Game,
  floor : @types.Floor,
  kind : @types.SpellKind,
  slot : Int,
) -> Unit {
  let data = @types.spell_data(kind)
  let player = game.player
  // Deduct mana and set cooldown
  player.mana = player.mana - data.mana_cost
  player.spell_slots.cooldowns[slot] = data.beat_cooldown
  let rating = @beat.rate_input(game.beat)
  @beat.update_combo(game.beat, rating)
  trigger_border_flash(game, rating)
  // Track spell usage and sound
  @types.record_spell_usage(game, kind)
  @types.push_sound(game, SpellCast(data.element))
  // Spell cast visual effects
  let cast_sx = Float::from_int(@types.tile_screen_x(player.x) + @types.tile_size / 2)
  let cast_sy = Float::from_int(@types.tile_screen_y(player.y) + @types.tile_size / 2)
  @types.spawn_spell_particles(game, cast_sx, cast_sy, data.element)
  @types.spell_border_flash(game, data.element)
  match kind {
    Fireball => {
      // 3 damage to enemy in faced direction, range 1
      let dir = player.facing
      let tx = player.x + @types.dir_dx(dir)
      let ty = player.y + @types.dir_dy(dir)
      let ei = @types.find_enemy_at(floor.enemies, tx, ty)
      if ei >= 0 {
        let dmg = @beat.compute_damage(data.damage, game.beat, rating)
        let enemy = floor.enemies[ei]
        enemy.hp = enemy.hp - dmg
        let sx = Float::from_int(@types.tile_screen_x(tx) + @types.tile_size / 2)
        let sy = Float::from_int(@types.tile_screen_y(ty) + @types.tile_size / 2)
        @types.spawn_damage_number(game, sx, sy - 10.0F, dmg, rating)
        if enemy.hp <= 0 {
          handle_enemy_death(game, floor, ei, rating)
        }
      }
      game.screen_shake = 3.0F
      @types.set_message(game, "Fireball!")
    }
    FrostNova => {
      // 1 damage and freeze all adjacent enemies (bosses resist)
      let dirs : Array[@types.Direction] = [North, South, East, West]
      let mut frozen_count = 0
      for dir in dirs {
        let tx = player.x + @types.dir_dx(dir)
        let ty = player.y + @types.dir_dy(dir)
        let ei = @types.find_enemy_at(floor.enemies, tx, ty)
        if ei >= 0 {
          let enemy = floor.enemies[ei]
          enemy.hp = enemy.hp - data.damage
          if @content.can_freeze_enemy(enemy) {
            enemy.frozen_beats = 3
            frozen_count = frozen_count + 1
          }
          let sx = Float::from_int(@types.tile_screen_x(tx) + @types.tile_size / 2)
          let sy = Float::from_int(@types.tile_screen_y(ty) + @types.tile_size / 2)
          @types.spawn_damage_number(game, sx, sy - 10.0F, data.damage, rating)
          if enemy.hp <= 0 {
            handle_enemy_death(game, floor, ei, rating)
          }
        }
      }
      @types.set_message(game, "Frost Nova! \{frozen_count} frozen!")
    }
    ChainLightning => {
      // 2 damage, chains to up to 3 enemies (nearest first)
      let mut hits = 0
      let mut last_x = player.x
      let mut last_y = player.y
      for enemy in floor.enemies {
        if hits >= 3 {
          break
        }
        if !(enemy.active) {
          continue
        }
        let dist = @types.manhattan_dist(last_x, last_y, enemy.x, enemy.y)
        if dist <= data.range {
          let dmg = @beat.compute_damage(data.damage, game.beat, rating)
          enemy.hp = enemy.hp - dmg
          let sx = Float::from_int(@types.tile_screen_x(enemy.x) + @types.tile_size / 2)
          let sy = Float::from_int(@types.tile_screen_y(enemy.y) + @types.tile_size / 2)
          @types.spawn_damage_number(game, sx, sy - 10.0F, dmg, rating)
          last_x = enemy.x
          last_y = enemy.y
          hits = hits + 1
          if enemy.hp <= 0 {
            enemy.active = false
            game.run_kills = game.run_kills + 1
            add_kill_score(game, enemy, rating)
            @types.queue_death_explosion(game, sx, sy, @types.enemy_color(enemy.kind))
          }
        }
      }
      game.screen_shake = 4.0F
      @types.set_message(game, "Chain Lightning! \{hits} hit!")
    }
    ShadowStep => {
      // Teleport to a random empty tile
      let rng = @types.game_rng(game)
      for _ in 0..<30 {
        let tx = @types.rand_range(rng, 1, floor.grid.width - 2)
        let ty = @types.rand_range(rng, 1, floor.grid.height - 2)
        if @types.grid_is_walkable(floor.grid, tx, ty) &&
          @types.find_enemy_at(floor.enemies, tx, ty) < 0 {
          player.x = tx
          player.y = ty
          break
        }
      }
      @types.sync_rng(game, rng)
      @types.set_message(game, "Shadow Step!")
    }
    Inferno => {
      // 3x3 AoE centered on tile in facing direction
      let cx = player.x + @types.dir_dx(player.facing) * 2
      let cy = player.y + @types.dir_dy(player.facing) * 2
      for dy = -1; dy <= 1; dy = dy + 1 {
        for dx = -1; dx <= 1; dx = dx + 1 {
          let tx = cx + dx
          let ty = cy + dy
          let ei = @types.find_enemy_at(floor.enemies, tx, ty)
          if ei >= 0 {
            let dmg = @beat.compute_damage(data.damage, game.beat, rating)
            let enemy = floor.enemies[ei]
            enemy.hp = enemy.hp - dmg
            let sx = Float::from_int(@types.tile_screen_x(tx) + @types.tile_size / 2)
            let sy = Float::from_int(@types.tile_screen_y(ty) + @types.tile_size / 2)
            @types.spawn_damage_number(game, sx, sy - 10.0F, dmg, rating)
            if enemy.hp <= 0 {
              enemy.active = false
              game.run_kills = game.run_kills + 1
              add_kill_score(game, enemy, rating)
              @types.queue_death_explosion(game, sx, sy, @types.enemy_color(enemy.kind))
            }
          }
        }
      }
      game.screen_shake = 6.0F
      @types.set_message(game, "Inferno!")
    }
    Blizzard => {
      // Freeze all enemies for 2 beats (bosses resist)
      let mut frozen_count = 0
      for enemy in floor.enemies {
        if enemy.active && @content.can_freeze_enemy(enemy) {
          enemy.frozen_beats = 2
          frozen_count = frozen_count + 1
        }
      }
      game.screen_shake = 3.0F
      @types.set_message(game, "Blizzard! \{frozen_count} frozen!")
    }
    ThunderStrike => {
      // 5 damage single target + stun, in faced direction range 2
      let dir = player.facing
      let mut target_idx = -1
      for r in 1..=2 {
        let tx = player.x + @types.dir_dx(dir) * r
        let ty = player.y + @types.dir_dy(dir) * r
        let ei = @types.find_enemy_at(floor.enemies, tx, ty)
        if ei >= 0 {
          target_idx = ei
          break
        }
      }
      if target_idx >= 0 {
        let dmg = @beat.compute_damage(data.damage, game.beat, rating)
        let enemy = floor.enemies[target_idx]
        enemy.hp = enemy.hp - dmg
        enemy.stunned_beats = @content.stun_duration_for(enemy)
        let sx = Float::from_int(@types.tile_screen_x(enemy.x) + @types.tile_size / 2)
        let sy = Float::from_int(@types.tile_screen_y(enemy.y) + @types.tile_size / 2)
        @types.spawn_damage_number(game, sx, sy - 10.0F, dmg, rating)
        if enemy.hp <= 0 {
          handle_enemy_death(game, floor, target_idx, rating)
        }
        game.screen_shake = 5.0F
        @types.set_message(game, "Thunder Strike! \{dmg} dmg + Stun!")
      } else {
        @types.set_message(game, "Thunder Strike! No target!")
      }
    }
    VoidPulse => {
      // Push all adjacent enemies 2 tiles away + 1 damage
      let dirs : Array[@types.Direction] = [North, South, East, West]
      for dir in dirs {
        let tx = player.x + @types.dir_dx(dir)
        let ty = player.y + @types.dir_dy(dir)
        let ei = @types.find_enemy_at(floor.enemies, tx, ty)
        if ei >= 0 {
          let enemy = floor.enemies[ei]
          enemy.hp = enemy.hp - data.damage
          // Push 2 tiles
          for _ in 0..<2 {
            let nx = enemy.x + @types.dir_dx(dir)
            let ny = enemy.y + @types.dir_dy(dir)
            if @types.grid_is_walkable(floor.grid, nx, ny) &&
              @types.find_enemy_at(floor.enemies, nx, ny) < 0 {
              enemy.x = nx
              enemy.y = ny
            }
          }
          if enemy.hp <= 0 {
            enemy.active = false
            game.run_kills = game.run_kills + 1
            add_kill_score(game, enemy, rating)
            let sx = Float::from_int(@types.tile_screen_x(enemy.x) + @types.tile_size / 2)
            let sy = Float::from_int(@types.tile_screen_y(enemy.y) + @types.tile_size / 2)
            @types.queue_death_explosion(game, sx, sy, @types.enemy_color(enemy.kind))
          }
        }
      }
      game.screen_shake = 4.0F
      @types.set_message(game, "Void Pulse!")
    }
  }
}

///|
fn handle_enemy_death(
  game : @types.Game,
  floor : @types.Floor,
  ei : Int,
  rating : @types.BeatRating,
) -> Unit {
  let enemy = floor.enemies[ei]
  enemy.active = false
  game.run_kills = game.run_kills + 1
  game.current_floor_stats.enemies_killed = game.current_floor_stats.enemies_killed + 1
  add_kill_score(game, enemy, rating)
  // Sound event: enemy death
  @types.push_sound(game, EnemyDeath)
  // Check boss phase transitions
  match enemy.kind {
    BeatDragon | RhythmLich => ()
    _ => ()
  }
  let sx = Float::from_int(@types.tile_screen_x(enemy.x) + @types.tile_size / 2)
  let sy = Float::from_int(@types.tile_screen_y(enemy.y) + @types.tile_size / 2)
  // Boss enemies get enhanced death explosion
  match enemy.kind {
    BeatDragon | RhythmLich => {
      @types.spawn_boss_death_particles(game, sx, sy, @types.enemy_color(enemy.kind))
      game.screen_shake = 12.0F
    }
    _ => @types.queue_death_explosion(game, sx, sy, @types.enemy_color(enemy.kind))
  }
  // First Blood achievement
  if game.run_kills == 1 {
    let _ = @types.check_achievement(game.achievements, FirstBlood)
  }
  // Elite slime split
  if enemy.is_elite && enemy.kind == Slime {
    let splits = @content.elite_slime_split(
      enemy.x, enemy.y, floor.enemies.length(), floor,
    )
    for s in splits {
      floor.enemies.push(s)
    }
  }
  // Elite drops
  if enemy.is_elite {
    maybe_drop_spell(game)
    game.player.gold = game.player.gold + @types.elite_gold_drop
  }
  // Mana regen on kill (small bonus)
  game.player.mana = @types.clampi(game.player.mana + 1, 0, game.player.max_mana)
  // Drop gold for all kills
  let drop_gold = @content.enemy_drop_count(enemy) * 5
  game.player.gold = game.player.gold + drop_gold
}

///|
fn maybe_drop_spell(game : @types.Game) -> Unit {
  let rng = @types.game_rng(game)
  let roll = @types.rand_range(rng, 0, 99)
  if roll < @types.spell_drop_chance {
    let all = @types.all_spell_kinds()
    let idx = @types.rand_range(rng, 0, all.length() - 1)
    let spell = all[idx]
    if !@types.has_spell(game.player, spell) {
      game.player.learned_spells.push(spell)
      let _ = @types.equip_spell(game.player, spell)
      let data = @types.spell_data(spell)
      @types.set_message(game, "Learned \{data.name}!")
    }
  }
  @types.sync_rng(game, rng)
}

// ============================================================
// === Curse System ===
// ============================================================

///|
fn offer_curse_choice(game : @types.Game) -> Unit {
  let rng = @types.game_rng(game)
  let all = @types.all_curse_kinds()
  game.curse_offers.clear()
  // Offer 2 random curses not already active
  let mut offered = 0
  for _ in 0..<20 {
    if offered >= 2 {
      break
    }
    let idx = @types.rand_range(rng, 0, all.length() - 1)
    let curse = all[idx]
    if !@types.has_curse(game.curses, curse) {
      let mut dup = false
      for c in game.curse_offers {
        if c == curse {
          dup = true
          break
        }
      }
      if !dup {
        game.curse_offers.push(curse)
        offered = offered + 1
      }
    }
  }
  @types.sync_rng(game, rng)
  game.curse_cursor = 0
  game.showing_curse_offer = true
  if game.curse_offers.length() == 0 {
    // No curses available, go straight to ability choice
    offer_ability_choices(game)
  } else {
    game.screen = CurseOffer
  }
}

///|
fn update_curse_offer(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyW) {
    game.curse_cursor = game.curse_cursor - 1
    if game.curse_cursor < 0 {
      game.curse_cursor = game.curse_offers.length()
      // Extra slot for "Skip"
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) ||
    @raylib.is_key_pressed(@raylib.KeyS) {
    game.curse_cursor = game.curse_cursor + 1
    if game.curse_cursor > game.curse_offers.length() {
      game.curse_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.curse_cursor < game.curse_offers.length() {
      let curse = game.curse_offers[game.curse_cursor]
      apply_curse(game, curse)
      @types.push_sound(game, CurseAccepted)
      @types.set_message(game, "Curse: \{@types.curse_name(curse)}!")
    }
    game.showing_curse_offer = false
    // Then offer ability choice
    offer_ability_choices(game)
  }
}

///|
fn apply_curse(game : @types.Game, curse : @types.CurseKind) -> Unit {
  game.curses.active_curses.push(curse)
  match curse {
    DoubleTime => {
      // BPM +20%
      game.beat.bpm = game.beat.bpm * (1.0F + @types.curse_bpm_bonus_pct)
    }
    GlassCannon => {
      // 1 HP max
      game.player.max_hp = 1
      game.player.hp = 1
    }
    BlindBeat => {
      // Perfect window +50ms
      game.beat.perfect_window = game.beat.perfect_window + @types.blind_beat_perfect_bonus
    }
    Swarm => ()
    // Swarm effect is handled in floor generation
  }
}

// ============================================================
// === BPM transition animation ===
// ============================================================

///|
fn start_bpm_animation(game : @types.Game, from : Float, to : Float) -> Unit {
  game.bpm_anim_value = from
  game.bpm_anim_target = to
  game.bpm_anim_timer = 1.5F
}

// ============================================================
// === Apply curse score bonus at finalize ===
// ============================================================

///|
fn curse_score_multiplier(game : @types.Game) -> Float {
  let mut mult = 1.0F
  if @types.has_curse(game.curses, DoubleTime) {
    mult = mult + @types.curse_score_bonus_pct
  }
  mult
}
