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
  // Update particles
  @types.update_particles(game, dt)
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
    game.beat.bpm = bpm
    game.beat.perfect_window = @types.perfect_window_for_floor(floor_num)
    game.beat.good_window = @types.good_window_for_floor(floor_num)
    // Account for speed boost widening beat window
    if game.player.speed_boost_beats > 0 {
      game.beat.perfect_window = game.beat.perfect_window + 0.03
      game.beat.good_window = game.beat.good_window + 0.05
    }
    let floor = @content.generate_floor(game, floor_num)
    game.floor = Some(floor)
    game.player.x = 1
    game.player.y = 1
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
    // Decrement player buff timers on beat
    if game.player.speed_boost_beats > 0 {
      game.player.speed_boost_beats = game.player.speed_boost_beats - 1
      if game.player.speed_boost_beats == 0 {
        // Restore normal windows
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
          game.screen = GameOver
          @types.set_message(game, "You died on the spikes...")
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
  match rating {
    Miss => {
      // Miss = lose turn, combo reset, take damage from adjacent enemies
      @types.set_message(game, "MISS! Lost the beat!")
      game.player.hp = game.player.hp - @types.miss_damage
      if game.player.hp <= 0 {
        game.screen = GameOver
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
      // Good or Perfect - execute action
      match action {
        Move(dir) => {
          let nx = game.player.x + @types.dir_dx(dir)
          let ny = game.player.y + @types.dir_dy(dir)
          // Check if enemy is at target (attack instead of move)
          let enemy_idx = @types.find_enemy_at(floor.enemies, nx, ny)
          if enemy_idx >= 0 {
            let dmg = @beat.compute_damage(
              game.player.weapon_damage, beat, rating,
            )
            let enemy = floor.enemies[enemy_idx]
            enemy.hp = enemy.hp - dmg
            if enemy.hp <= 0 {
              enemy.active = false
              add_kill_score(game, enemy, rating)
              // Spawn death particles
              let sx = Float::from_int(
                @types.tile_screen_x(enemy.x) + @types.tile_size / 2,
              )
              let sy = Float::from_int(
                @types.tile_screen_y(enemy.y) + @types.tile_size / 2,
              )
              @types.spawn_death_particles(
                game, sx, sy, @types.enemy_color(enemy.kind),
              )
              @types.set_message(
                game,
                "\{@types.rating_text(rating)} Hit! Enemy defeated!",
              )
            } else {
              @types.set_message(
                game,
                "\{@types.rating_text(rating)} Hit! \{dmg} dmg",
              )
            }
          } else if @types.grid_is_walkable(floor.grid, nx, ny) {
            game.player.x = nx
            game.player.y = ny
            @types.set_message(game, @types.rating_text(rating))
          } else {
            @types.set_message(game, "\{@types.rating_text(rating)} Blocked!")
          }
        }
        Attack(dir) => {
          let tx = game.player.x + @types.dir_dx(dir)
          let ty = game.player.y + @types.dir_dy(dir)
          let enemy_idx = @types.find_enemy_at(floor.enemies, tx, ty)
          if enemy_idx >= 0 {
            let dmg = @beat.compute_damage(
              game.player.weapon_damage, beat, rating,
            )
            let enemy = floor.enemies[enemy_idx]
            enemy.hp = enemy.hp - dmg
            if enemy.hp <= 0 {
              enemy.active = false
              add_kill_score(game, enemy, rating)
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
        Special => {
          if game.player.special_charges > 0 {
            game.player.special_charges = game.player.special_charges - 1
            // Special: damage all adjacent enemies
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
      }
      Attack(_, dmg) => {
        // Check if player is still adjacent
        let dist = @types.manhattan_dist(
          enemy.x, enemy.y, game.player.x, game.player.y,
        )
        if dist <= 1 {
          let actual_dmg = if game.player.shield > 0 {
            game.player.shield = game.player.shield - 1
            (dmg + 1) / 2
          } else {
            dmg
          }
          game.player.hp = game.player.hp - actual_dmg
          @types.set_message(game, "Hit for \{actual_dmg} damage!")
          if game.player.hp <= 0 {
            game.screen = GameOver
            @types.set_message(game, "Game Over!")
          }
        }
      }
      Charge(dir, power) => {
        // Charge two tiles in direction
        let mut cx = enemy.x
        let mut cy = enemy.y
        for _ in 0..<2 {
          let nx = cx + @types.dir_dx(dir)
          let ny = cy + @types.dir_dy(dir)
          if @types.grid_is_walkable(floor.grid, nx, ny) &&
            !(@types.has_enemy_at(floor.enemies, nx, ny)) {
            if nx == game.player.x && ny == game.player.y {
              game.player.hp = game.player.hp - power
              if game.player.hp <= 0 {
                game.screen = GameOver
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
            let actual = if game.player.shield > 0 {
              game.player.shield = game.player.shield - 1
              (dmg + 1) / 2
            } else {
              dmg
            }
            game.player.hp = game.player.hp - actual
            @types.set_message(game, "Fire breath! -\{actual} HP!")
            if game.player.hp <= 0 {
              game.screen = GameOver
              @types.set_message(game, "Burned to a crisp!")
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
    if game.floors_cleared >= @types.max_floor {
      // Compute final score
      game.score_state.total = game.score
      game.screen = GameOver
      @types.set_message(game, "YOU WIN! All floors cleared!")
    } else {
      // Go to shop between floors
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
    ShopBeatWindow,
  ]
  // Pick 4 random items (with possible duplicates)
  game.shop_items.clear()
  for _ in 0..<4 {
    let idx = @types.rand_range(rng, 0, all_kinds.length() - 1)
    game.shop_items.push(@types.make_shop_entry(all_kinds[idx]))
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
      // Permanently widen beat window slightly
      game.beat.perfect_window = game.beat.perfect_window + 0.01
      game.beat.good_window = game.beat.good_window + 0.02
    }
  }
}

///|
fn update_game_over(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    start_new_game(game)
  }
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
  game.score = 0
  game.floors_cleared = 0
  game.floor = None
  game.is_boss_floor = false
  game.particles.clear()
  game.border_flash_color = None
  game.border_flash_timer = 0.0
  game.combo_scale = 1.0
  game.screen_shake = 0.0
  game.score_state.base_kills = 0
  game.score_state.beat_bonus = 0
  game.score_state.combo_bonus = 0
  game.score_state.floor_bonus = 0
  game.score_state.total = 0
  @beat.reset(game.beat)
  game.beat.bpm = @types.bpm_for_floor(1)
  game.beat.perfect_window = @types.perfect_window_for_floor(1)
  game.beat.good_window = @types.good_window_for_floor(1)
  game.screen = FloorSelect
  @types.set_message(game, "Choose your floor!")
}
