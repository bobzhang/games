// Main game update dispatcher (FSM)

///|
/// Advances one frame of dungeon gameplay by dispatching updates for the active game state.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.frame_counter += 1
  match game.state {
    StateMenu => game.update_menu(dt)
    StatePlaying => game.update_playing(dt)
    StatePaused => game.update_paused(dt)
    StateGameOver => game.update_game_over(dt)
    StateLevelUp => game.update_level_up(dt)
    StateFloorComplete => game.update_floor_complete(dt)
    StateClassSelect => game.update_class_select(dt)
    StateShop => game.update_shop(dt)
    StateShrine => game.update_shrine(dt)
  }
  // Update message
  if game.message_timer > 0.0 {
    game.message_timer -= dt
    if game.message_timer <= 0.0 {
      game.message_timer = 0.0
    }
  }
  // Update level up timer
  if game.level_up_timer > 0.0 {
    game.level_up_timer -= dt
    if game.level_up_timer <= 0.0 {
      game.level_up_timer = 0.0
    }
  }
}

///|
fn @types.Game::update_menu(game : @types.Game, dt : Float) -> Unit {
  game.menu_blink += dt * @types.menu_blink_speed
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.menu_cursor -= 1
    if game.menu_cursor < 0 {
      game.menu_cursor = 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.menu_cursor += 1
    if game.menu_cursor > 1 {
      game.menu_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.menu_cursor == 0 {
      // New game
      game.start_new_game()
    } else {
      // Continue (restart)
      game.start_new_game()
    }
  }
}

///|
fn @types.Game::start_new_game(game : @types.Game) -> Unit {
  // Reset player stats to base defaults
  game.player_hp = @types.player_start_hp
  game.player_max_hp = @types.player_start_hp
  game.player_mana = @types.player_start_mana
  game.player_max_mana = @types.player_start_mana
  game.player_atk = @types.player_start_atk
  game.player_def = @types.player_start_def
  game.player_str = @types.player_start_str
  game.player_dex = @types.player_start_dex
  game.player_int_stat = @types.player_start_int_stat
  game.player_level = 1
  game.player_xp = 0
  game.player_xp_next = @types.xp_per_level
  game.current_floor = 0
  game.camera_yaw = 0.0
  game.camera_pitch = 0.0
  game.player_gold = 0
  game.player_keys = 0
  game.player_boss_keys = 0
  game.player_kills = 0
  game.player_total_gold = 0
  game.player_weapon = Sword
  game.player_armor = @types.armor_none
  game.mana_regen_accum = 0.0
  // Reset equipment
  game.equip_weapon_rarity = @types.rarity_common
  game.equip_weapon_bonus = 0
  game.equip_armor_rarity = @types.rarity_common
  game.equip_armor_bonus = 0
  game.equip_ring_kind = -1
  game.equip_ring_rarity = @types.rarity_common
  game.equip_ring_bonus = 0
  // Reset inventory
  for i in 0..<@types.max_inventory {
    game.inventory[i].active = false
    game.inventory[i].kind = 0
    game.inventory[i].rarity = @types.rarity_common
    game.inventory[i].stat_bonus = 0
    game.inventory[i].name_idx = 0
  }
  // Reset spells
  for i in 0..<@types.max_spells {
    game.spells[i].active = false
    game.spells[i].spell_type = None
  }
  // Reset buffs
  for i in 0..<@types.max_buffs {
    game.buffs[i].active = false
    game.buffs[i].timer = 0.0
    game.buffs[i].value = 0
    game.buffs[i].kind = 0
  }
  // Class starting kits
  match game.player_class {
    Warrior => {
      game.player_weapon = Sword
      game.player_armor = @types.armor_chain
      game.player_max_hp += 20
      game.player_hp = game.player_max_hp
      game.player_str = @types.player_start_str + 3
      game.player_def += 3
      game.equip_armor_bonus = 3
    }
    Rogue => {
      game.player_weapon = Dagger
      game.player_armor = @types.armor_leather
      game.player_dex = @types.player_start_dex + 5
      game.player_atk += 2
      game.equip_weapon_bonus = 2
      game.equip_ring_kind = @types.ring_crit_chance
      game.equip_ring_bonus = 5
    }
    Mage => {
      game.player_weapon = Staff
      game.player_armor = @types.armor_robes
      game.player_int_stat = @types.player_start_int_stat + 5
      game.player_max_mana += 20
      game.player_mana = game.player_max_mana
      game.equip_ring_kind = @types.ring_mana_regen
      game.equip_ring_bonus = 3
    }
  }
  // Reset floor info
  for i in 0..<@types.max_floors {
    game.floor_info[i].cleared = false
    game.floor_info[i].enemies_killed = 0
    game.floor_info[i].enemies_total = 0
  }
  // Generate first dungeon
  generate_dungeon(game)
  game.state = StatePlaying
  @raylib.disable_cursor()
}

///|
fn @types.Game::update_playing(game : @types.Game, dt : Float) -> Unit {
  // Pause
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = StatePaused
    @raylib.enable_cursor()
    return
  }
  // Update systems
  update_player(game, dt)
  update_enemies(game, dt)
  update_projectiles(game, dt)
  update_particles(game, dt)
  update_loot_bob(game, dt)
  @types.update_shake(game, dt)
  @types.update_damage_numbers(game, dt)
}

///|
fn @types.Game::update_paused(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = StatePlaying
    @raylib.disable_cursor()
  }
  if @raylib.is_key_pressed(@raylib.KeyM) {
    game.state = StateMenu
    @raylib.enable_cursor()
  }
}

///|
fn @types.Game::update_game_over(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    // Restart game
    game.start_new_game()
  }
  if @raylib.is_key_pressed(@raylib.KeyM) {
    game.state = StateMenu
    @raylib.enable_cursor()
  }
}

///|
fn @types.Game::update_level_up(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.state = StatePlaying
    @raylib.disable_cursor()
  }
}

///|
fn @types.Game::update_floor_complete(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.current_floor < @types.max_floors - 1 {
      game.current_floor += 1
      generate_dungeon(game)
      game.state = StatePlaying
      @raylib.disable_cursor()
    } else {
      // Game won - return to menu
      game.state = StateMenu
      @raylib.enable_cursor()
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyM) {
    game.state = StateMenu
    @raylib.enable_cursor()
  }
}

///|
fn @types.Game::update_class_select(game : @types.Game, dt : Float) -> Unit {
  game.menu_blink += dt * @types.menu_blink_speed
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.class_select_cursor -= 1
    if game.class_select_cursor < 0 {
      game.class_select_cursor = 2
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.class_select_cursor += 1
    if game.class_select_cursor > 2 {
      game.class_select_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.player_class = @types.ship_class_from_int(game.class_select_cursor)
    game.start_new_game()
  }
}

///|
fn @types.Game::update_shop(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = StatePlaying
    @raylib.disable_cursor()
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.shop_cursor -= 1
    if game.shop_cursor < 0 {
      game.shop_cursor = @types.max_shop_items - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.shop_cursor += 1
    if game.shop_cursor >= @types.max_shop_items {
      game.shop_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.shop_cursor >= 0 && game.shop_cursor < @types.max_shop_items {
      let item = game.shop_items[game.shop_cursor]
      if item.active && game.player_gold >= item.price {
        game.player_gold -= item.price
        if item.kind == @types.loot_health_potion {
          game.player_hp = (game.player_hp + @types.health_potion_heal).min(
            game.player_max_hp,
          )
          @types.add_message(game, "Bought Health Potion!", 50, 255, 50)
        } else if item.kind == @types.loot_mana_potion {
          game.player_mana = (game.player_mana + @types.mana_potion_restore).min(
            game.player_max_mana,
          )
          @types.add_message(game, "Bought Mana Potion!", 80, 100, 255)
        } else if item.kind == @types.loot_damage_boost {
          game.player_atk += @types.damage_boost_amount
          @types.add_message(
            game,
            "Bought Damage Scroll! +\{@types.damage_boost_amount} ATK",
            255,
            100,
            50,
          )
        } else if item.kind == @types.loot_armor {
          game.player_def += @types.armor_boost_amount
          @types.add_message(
            game,
            "Bought Armor Shard! +\{@types.armor_boost_amount} DEF",
            100,
            100,
            255,
          )
        } else if item.kind == @types.loot_key {
          game.player_keys += 1
          @types.add_message(game, "Bought a Key!", 200, 200, 50)
        } else if item.kind == @types.loot_speed_potion {
          @types.add_buff(
            game, @types.buff_speed, @types.speed_potion_duration, 1,
          )
          @types.add_message(game, "Bought Speed Potion!", 255, 255, 80)
        }
        item.active = false
        @types.spawn_particles(
          game, game.player_x, 1.0, game.player_z, 8, 255, 215, 0,
        )
      } else if item.active {
        @types.add_message(game, "Not enough gold!", 200, 100, 100)
      }
    }
  }
}

///|
fn @types.Game::update_shrine(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = StatePlaying
    @raylib.disable_cursor()
    return
  }
  if game.shrine_used {
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.shrine_cursor -= 1
    if game.shrine_cursor < 0 {
      game.shrine_cursor = 2
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.shrine_cursor += 1
    if game.shrine_cursor > 2 {
      game.shrine_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.player_hp > 20 {
      game.player_hp -= 20
      game.shrine_used = true
      if game.shrine_cursor == 0 {
        game.player_max_hp += 15
        game.player_hp += 15
        @types.add_message(
          game, "Shrine blessing: +15 Max HP!", 120, 200, 255,
        )
      } else if game.shrine_cursor == 1 {
        game.player_max_mana += 10
        game.player_mana = (game.player_mana + 10).min(
          game.player_max_mana,
        )
        @types.add_message(
          game, "Shrine blessing: +10 Max Mana!", 80, 120, 255,
        )
      } else {
        game.player_atk += 5
        @types.add_message(
          game, "Shrine blessing: +5 ATK!", 255, 100, 80,
        )
      }
      @types.spawn_particles(
        game, game.player_x, 1.5, game.player_z, 16, 120, 200, 255,
      )
      game.damage_flash = 0.15
    } else {
      @types.add_message(
        game, "Not enough HP to sacrifice!", 200, 100, 100,
      )
    }
  }
}
