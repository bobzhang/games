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
  match game.screen {
    Title => update_title(game)
    Playing => update_playing(game, dt)
    BeatFail => update_beat_fail(game)
    LevelComplete => update_level_complete(game)
    GameOver => update_game_over(game)
    FloorSelect => update_floor_select(game)
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
    let floor = @content.generate_floor(game, floor_num)
    game.floor = Some(floor)
    game.player.x = 1
    game.player.y = 1
    @beat.reset(game.beat)
    game.screen = Playing
    @types.set_message(game, "Floor \{floor_num} - Move to the beat!")
  }
}

///|
fn update_playing(game : @types.Game, dt : Float) -> Unit {
  let beat = game.beat
  let new_beat = @beat.tick(beat, dt)
  guard game.floor is Some(floor) else { return }
  if new_beat {
    execute_enemy_beats(game, floor)
    // Recompute intents for next beat
    let rng = @types.game_rng(game)
    @content.compute_enemy_intents(floor, game.player.x, game.player.y, rng)
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
  // Check for exit
  if game.player.x == floor.exit_x && game.player.y == floor.exit_y {
    game.screen = LevelComplete
    game.floors_cleared = game.floors_cleared + 1
    game.score = game.score + 100 * floor.floor_num
    @types.set_message(game, "Floor cleared!")
  }
  // Check for item pickup
  let idx = @types.grid_index(
    game.player.x,
    game.player.y,
    floor.grid.width,
  )
  let tile = floor.grid.tiles[idx]
  if tile.has_item {
    tile.has_item = false
    game.player.gold = game.player.gold + 10
    game.score = game.score + 25
    @types.set_message(game, "+10 Gold!")
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
fn handle_player_action(
  game : @types.Game,
  floor : @types.Floor,
  action : @types.PlayerAction,
) -> Unit {
  let beat = game.beat
  let rating = @beat.rate_input(beat)
  @beat.update_combo(beat, rating)
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
      // Good or Perfect - execute action
      match action {
        Move(dir) => {
          let nx = game.player.x + @types.dir_dx(dir)
          let ny = game.player.y + @types.dir_dy(dir)
          // Check if enemy is at target (attack instead of move)
          let enemy_idx = @types.find_enemy_at(floor.enemies, nx, ny)
          if enemy_idx >= 0 {
            let dmg = @beat.compute_damage(
              game.player.weapon_damage,
              beat,
              rating,
            )
            let enemy = floor.enemies[enemy_idx]
            enemy.hp = enemy.hp - dmg
            game.score = game.score + dmg * 5
            if enemy.hp <= 0 {
              enemy.active = false
              game.score = game.score + 50
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
              game.player.weapon_damage,
              beat,
              rating,
            )
            let enemy = floor.enemies[enemy_idx]
            enemy.hp = enemy.hp - dmg
            if enemy.hp <= 0 {
              enemy.active = false
              game.score = game.score + 50
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
                  game.player.weapon_damage + 2,
                  beat,
                  rating,
                )
                floor.enemies[ei].hp = floor.enemies[ei].hp - dmg
                if floor.enemies[ei].hp <= 0 {
                  floor.enemies[ei].active = false
                  game.score = game.score + 50
                }
              }
            }
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
          enemy.x,
          enemy.y,
          game.player.x,
          game.player.y,
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
      game.screen = GameOver
      @types.set_message(game, "YOU WIN! All floors cleared!")
    } else {
      game.screen = FloorSelect
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
  game.score = 0
  game.floors_cleared = 0
  game.floor = None
  @beat.reset(game.beat)
  game.screen = FloorSelect
  @types.set_message(game, "Choose your floor!")
}
