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
    StateEquipPopup => game.update_equip_popup(dt)
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
  game.weapon_affix = AffixNone
  // Reset discovered weapons - none found yet
  for i in 0..<@types.max_discovered_weapons {
    game.discovered_weapons[i] = false
  }
  // Reset fire DOT tracking
  for i in 0..<@types.max_enemies {
    game.enemy_fire_dot[i] = 0.0
  }
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
      // Warrior discovers Sword
      game.discovered_weapons[@types.weapon_kind_index(Sword)] = true
    }
    Rogue => {
      game.player_weapon = Dagger
      game.player_armor = @types.armor_leather
      game.player_dex = @types.player_start_dex + 5
      game.player_atk += 2
      game.equip_weapon_bonus = 2
      game.equip_ring_kind = @types.ring_crit_chance
      game.equip_ring_bonus = 5
      // Rogue discovers Dagger
      game.discovered_weapons[@types.weapon_kind_index(Dagger)] = true
    }
    Mage => {
      game.player_weapon = Staff
      game.player_armor = @types.armor_robes
      game.player_int_stat = @types.player_start_int_stat + 5
      game.player_max_mana += 20
      game.player_mana = game.player_max_mana
      game.equip_ring_kind = @types.ring_mana_regen
      game.equip_ring_bonus = 3
      // Mage discovers Staff and starts with Fireball + Ice Bolt
      game.discovered_weapons[@types.weapon_kind_index(Staff)] = true
      game.spells[0].active = true
      game.spells[0].spell_type = Fireball
      game.spells[1].active = true
      game.spells[1].spell_type = IceBolt
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
  // Hitstop: freeze gameplay (but keep particles/visuals updating)
  if @types.update_hitstop(game, dt) {
    update_particles(game, dt)
    @types.update_shake(game, dt)
    @types.update_damage_numbers(game, dt)
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
  @types.update_buffs(game, dt)
  @types.update_messages(game, dt)
  // Fire DOT on enemies
  update_fire_dots(game, dt)
}

///|
fn update_fire_dots(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.enemies.length() {
    if game.enemy_fire_dot[i] <= 0.0 {
      continue
    }
    let e = game.enemies[i]
    if !e.active {
      game.enemy_fire_dot[i] = 0.0
      continue
    }
    game.enemy_fire_dot[i] -= dt
    // Tick damage every second (check if we crossed a 1-second boundary)
    let remaining = game.enemy_fire_dot[i]
    let prev = remaining + dt
    if prev.to_int() != remaining.to_int() || remaining <= 0.0 {
      e.hp -= @types.fire_dot_damage
      e.hit_flash = 0.15
      @types.spawn_particles(game, e.x, 1.2, e.z, 3, 255, 100, 30)
      @types.spawn_damage_number(
        game,
        e.x,
        1.8,
        e.z,
        @types.fire_dot_damage,
        255,
        100,
        30,
        false,
      )
      if e.hp <= 0 {
        kill_enemy(game, i)
        game.enemy_fire_dot[i] = 0.0
      }
    }
    if game.enemy_fire_dot[i] < 0.0 {
      game.enemy_fire_dot[i] = 0.0
    }
  }
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
  // Navigate level-up card choices
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.levelup_card_cursor -= 1
    if game.levelup_card_cursor < 0 {
      game.levelup_card_cursor = @types.max_levelup_cards - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.levelup_card_cursor += 1
    if game.levelup_card_cursor >= @types.max_levelup_cards {
      game.levelup_card_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    let card_id = game.levelup_cards[game.levelup_card_cursor]
    // Apply the chosen card effect
    if card_id == 0 {
      game.player_max_hp += 5
      game.player_hp = (game.player_hp + 5).min(game.player_max_hp)
      @types.add_message(game, "Level Up: +5 Max HP!", 50, 255, 50)
    } else if card_id == 1 {
      game.player_atk += 3
      @types.add_message(game, "Level Up: +3 ATK!", 255, 100, 80)
    } else if card_id == 2 {
      game.player_max_mana += 10
      game.player_mana = (game.player_mana + 10).min(game.player_max_mana)
      @types.add_message(game, "Level Up: +10 Max Mana!", 80, 120, 255)
    } else if card_id == 3 {
      game.player_def += 2
      @types.add_message(game, "Level Up: +2 DEF!", 100, 150, 255)
    } else if card_id == 4 {
      game.player_dex += 5
      @types.add_message(game, "Level Up: +5% Crit!", 255, 215, 80)
    } else {
      game.player_str += 2
      game.player_dex += 2
      game.player_int_stat += 2
      @types.add_message(game, "Level Up: +2 STR/DEX/INT!", 200, 200, 255)
    }
    @types.spawn_particles(game, game.player_x, 1.0, game.player_z, 20, 255, 255, 50)
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
          game,
          game.player_x,
          1.0,
          game.player_z,
          8,
          255,
          215,
          0,
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
      let boon_id = game.shrine_boon_ids[game.shrine_cursor]
      if boon_id == 0 {
        game.player_max_hp += 15
        game.player_hp += 15
        @types.add_message(game, "Shrine blessing: +15 Max HP!", 120, 200, 255)
      } else if boon_id == 1 {
        game.player_max_mana += 10
        game.player_mana = (game.player_mana + 10).min(game.player_max_mana)
        @types.add_message(game, "Shrine blessing: +10 Max Mana!", 80, 120, 255)
      } else if boon_id == 2 {
        game.player_atk += 5
        @types.add_message(game, "Shrine blessing: +5 ATK!", 255, 100, 80)
      } else if boon_id == 10 {
        // Berserker's Fury: permanent buff (stored as special buff)
        @types.add_buff(game, @types.buff_berserker, 999.0, 20)
        @types.add_message(
          game,
          "Berserker's Fury! +20% DMG when below 30% HP!",
          255,
          80,
          40,
        )
      } else if boon_id == 11 {
        // Mana Shield: permanent buff
        @types.add_buff(game, @types.buff_mana_shield, 999.0, 1)
        @types.add_message(
          game,
          "Mana Shield! Absorb damage with mana!",
          80,
          120,
          255,
        )
      } else if boon_id == 12 {
        // Shadow Step: permanent buff
        @types.add_buff(game, @types.buff_shadow_step, 999.0, 1)
        @types.add_message(
          game,
          "Shadow Step! Brief invisibility after dodge!",
          150,
          80,
          200,
        )
      }
      @types.spawn_particles(
        game,
        game.player_x,
        1.5,
        game.player_z,
        16,
        120,
        200,
        255,
      )
      game.damage_flash = 0.15
    } else {
      @types.add_message(game, "Not enough HP to sacrifice!", 200, 100, 100)
    }
  }
}

///|
fn @types.Game::update_equip_popup(game : @types.Game, _dt : Float) -> Unit {
  // E to equip, Q to discard/sell
  if @raylib.is_key_pressed(@raylib.KeyE) {
    // Equip the pending item
    if game.pending_equip_kind == @types.loot_equip_weapon {
      game.equip_weapon_bonus = game.pending_equip_bonus
      game.equip_weapon_rarity = game.pending_equip_rarity
      game.weapon_affix = game.pending_equip_affix
      game.player_weapon = game.pending_equip_weapon_type
      // Discover the weapon type
      game.discovered_weapons[@types.weapon_kind_index(game.player_weapon)] = true
      let affix_str = @types.get_affix_name(game.weapon_affix)
      let wpn_str = @types.get_weapon_name(game.player_weapon)
      if affix_str == "" {
        @types.add_message(
          game,
          "Equipped \{@types.get_rarity_name(game.pending_equip_rarity)} \{wpn_str} +\{game.pending_equip_bonus}!",
          @types.get_rarity_color_r(game.pending_equip_rarity),
          @types.get_rarity_color_g(game.pending_equip_rarity),
          @types.get_rarity_color_b(game.pending_equip_rarity),
        )
      } else {
        @types.add_message(
          game,
          "Equipped \{affix_str} \{@types.get_rarity_name(game.pending_equip_rarity)} \{wpn_str} +\{game.pending_equip_bonus}!",
          @types.get_rarity_color_r(game.pending_equip_rarity),
          @types.get_rarity_color_g(game.pending_equip_rarity),
          @types.get_rarity_color_b(game.pending_equip_rarity),
        )
      }
    } else if game.pending_equip_kind == @types.loot_equip_armor {
      game.equip_armor_bonus = game.pending_equip_bonus
      game.equip_armor_rarity = game.pending_equip_rarity
      @types.add_message(
        game,
        "Equipped \{@types.get_rarity_name(game.pending_equip_rarity)} Armor +\{game.pending_equip_bonus}!",
        @types.get_rarity_color_r(game.pending_equip_rarity),
        @types.get_rarity_color_g(game.pending_equip_rarity),
        @types.get_rarity_color_b(game.pending_equip_rarity),
      )
    } else if game.pending_equip_kind == @types.loot_equip_ring {
      game.equip_ring_kind = game.pending_equip_ring_kind
      game.equip_ring_rarity = game.pending_equip_rarity
      game.equip_ring_bonus = game.pending_equip_bonus
      @types.add_message(
        game,
        "Equipped \{@types.get_rarity_name(game.pending_equip_rarity)} \{@types.get_ring_name(game.pending_equip_ring_kind)}!",
        @types.get_rarity_color_r(game.pending_equip_rarity),
        @types.get_rarity_color_g(game.pending_equip_rarity),
        @types.get_rarity_color_b(game.pending_equip_rarity),
      )
    }
    @types.spawn_particles(game, game.player_x, 1.0, game.player_z, 12, 100, 200, 255)
    game.state = StatePlaying
    @raylib.disable_cursor()
  }
  if @raylib.is_key_pressed(@raylib.KeyQ) {
    // Discard/sell for gold
    let gold = 10 + game.pending_equip_rarity * 15
    game.player_gold += gold
    game.player_total_gold += gold
    @types.add_message(game, "Sold equipment for \{gold} gold", 255, 215, 0)
    @types.spawn_particles(game, game.player_x, 1.0, game.player_z, 8, 255, 215, 0)
    game.state = StatePlaying
    @raylib.disable_cursor()
  }
}
