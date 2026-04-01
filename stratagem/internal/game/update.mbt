///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count = game.frame_count + 1
  // Update hover hex from mouse
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let mxf = Float::from_int(mx)
  let myf = Float::from_int(my)
  if mx < @types.ui_panel_x {
    game.hover_hex = Some(@types.pixel_to_hex(mxf, myf))
  } else {
    game.hover_hex = None
  }
  match game.screen {
    Title => update_title(game)
    Campaign => update_campaign(game)
    Skirmish => update_skirmish(game)
    Playing => update_playing(game)
    Results => update_results(game)
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyC) {
    game.screen = Campaign
  }
  if @raylib.is_key_pressed(@raylib.KeyS) {
    game.screen = Skirmish
  }
  if @raylib.is_key_pressed(@raylib.KeyQ) {
    // Can't close window from code, just go back
    ()
  }
}

///|
fn update_campaign(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
    return
  }
  // Level selection with number keys
  let keys = [
    @raylib.KeyOne,
    @raylib.KeyTwo,
    @raylib.KeyThree,
    @raylib.KeyFour,
    @raylib.KeyFive,
    @raylib.KeySix,
    @raylib.KeySeven,
    @raylib.KeyEight,
    @raylib.KeyNine,
    @raylib.KeyZero,
    @raylib.KeyMinus,
    @raylib.KeyEqual,
  ]
  for i in 0..<keys.length() {
    if @raylib.is_key_pressed(keys[i]) && i < game.campaign.levels_unlocked {
      game.campaign.current_level = i
      start_campaign_battle(game, i)
      return
    }
  }
}

///|
fn start_campaign_battle(game : @types.Game, level : Int) -> Unit {
  let def = @levels.get_campaign_level(level)
  let battle = setup_battle_from_def(game, def)
  game.battle = Some(battle)
  game.screen = Playing
  game.difficulty = Normal
}

///|
fn setup_battle_from_def(
  game : @types.Game,
  def : @types.LevelDef
) -> @types.Battle {
  let battle = @types.new_battle()
  // Setup terrain
  let total = def.width * def.height
  for i = 0; i < total; i = i + 1 {
    if i < def.terrain.length() {
      battle.map.tiles[i].terrain = @types.terrain_from_int(def.terrain[i])
    }
  }
  // Setup flag if capture victory
  match def.victory {
    CaptureFlag(fc, fr) => {
      let idx = @types.hex_index(@types.hex(fc, fr), battle.map.width)
      battle.map.tiles[idx].has_flag = true
    }
    _ => ()
  }
  battle.victory_condition = def.victory
  // Place player units
  let mut uid = 0
  for i in 0..<def.player_units.length() {
    let (kind, col, row) = def.player_units[i]
    let unit = @types.new_unit(uid, kind, Player, col, row)
    let _ = @types.place_unit_on_map(battle, unit)
    battle.units.push(unit)
    uid = uid + 1
  }
  // Place enemy units
  for i in 0..<def.enemy_units.length() {
    let (kind, col, row) = def.enemy_units[i]
    let unit = @types.new_unit(uid, kind, Enemy, col, row)
    let _ = @types.place_unit_on_map(battle, unit)
    battle.units.push(unit)
    uid = uid + 1
  }
  battle.next_unit_id = uid
  // Seed RNG
  @types.seed_rng(game.rng + game.frame_count)
  // Initial fog update
  @types.update_fog_of_war(battle)
  // Show initial turn banner
  battle.turn_banner_timer = 1.0
  battle
}

///|
fn update_skirmish(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
    return
  }
  let setup = game.skirmish
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    setup.map_index = (setup.map_index + 1) % @types.total_skirmish_maps
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    setup.map_index = (setup.map_index + @types.total_skirmish_maps - 1) % @types.total_skirmish_maps
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    setup.army_size = @types.mini(setup.army_size + 1, 8)
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    setup.army_size = @types.maxi(setup.army_size - 1, 2)
  }
  if @raylib.is_key_pressed(@raylib.KeyD) {
    setup.difficulty = match setup.difficulty {
      Easy => Normal
      Normal => Hard
      Hard => Easy
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    start_skirmish_battle(game)
  }
}

///|
fn start_skirmish_battle(game : @types.Game) -> Unit {
  let def = @levels.get_skirmish_map(game.skirmish.map_index)
  let (player_units, enemy_units) = @levels.generate_skirmish_units(
    game.skirmish.army_size,
  )
  let modified_def : @types.LevelDef = {
    name: def.name,
    width: def.width,
    height: def.height,
    terrain: def.terrain,
    player_units,
    enemy_units,
    victory: def.victory,
    description: def.description,
  }
  let battle = setup_battle_from_def(game, modified_def)
  game.battle = Some(battle)
  game.screen = Playing
  game.difficulty = game.skirmish.difficulty
}

///|
fn update_playing(game : @types.Game) -> Unit {
  let battle = match game.battle {
    Some(b) => b
    None => return
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
    game.battle = None
    return
  }
  // Check for game result
  if battle.result != Ongoing {
    return
  }
  // Update visual effect timers
  let dt : Float = 1.0 / 60.0
  if battle.attack_flash_timer > 0.0 {
    battle.attack_flash_timer = battle.attack_flash_timer - dt
    if battle.attack_flash_timer <= 0.0 {
      battle.attack_flash_timer = 0.0
      battle.attack_flash_pos = None
    }
  }
  if battle.hit_shake_timer > 0.0 {
    battle.hit_shake_timer = battle.hit_shake_timer - dt
    if battle.hit_shake_timer <= 0.0 {
      battle.hit_shake_timer = 0.0
      battle.hit_shake_target = None
    }
  }
  if battle.damage_popup_timer > 0.0 {
    battle.damage_popup_timer = battle.damage_popup_timer - dt
    if battle.damage_popup_timer <= 0.0 {
      battle.damage_popup_timer = 0.0
      battle.damage_popup_pos = None
    }
  }
  if battle.turn_banner_timer > 0.0 {
    battle.turn_banner_timer = battle.turn_banner_timer - dt
    if battle.turn_banner_timer <= 0.0 {
      battle.turn_banner_timer = 0.0
    }
  }
  // Handle animation timer
  if battle.anim_timer > 0.0 {
    battle.anim_timer = battle.anim_timer - dt
    if battle.anim_timer <= 0.0 {
      battle.anim_timer = 0.0
      battle.anim_message = ""
      // After enemy turn animation, check if done
      if battle.phase == Animating {
        // Check victory after enemy actions
        let result = @combat.check_victory(battle)
        if result != Ongoing {
          battle.result = result
          finish_battle(game, battle)
          return
        }
        // Start player turn
        battle.phase = Select
        battle.turn = battle.turn + 1
        @types.reset_team_turn(battle, Player)
        @types.update_fog_of_war(battle)
        // Show turn banner
        battle.turn_banner_timer = 1.0
      }
    }
    return
  }
  match battle.phase {
    Select => update_select(game, battle)
    Move => update_move(game, battle)
    Attack => update_attack(game, battle)
    EnemyTurn => update_enemy_turn(game, battle)
    Animating => ()
  }
}

///|
fn update_select(game : @types.Game, battle : @types.Battle) -> Unit {
  // End turn
  if @raylib.is_key_pressed(@raylib.KeySpace) {
    // End player turn, start enemy
    battle.phase = EnemyTurn
    battle.selected_unit = -1
    battle.move_targets = []
    battle.attack_targets = []
    battle.turn_banner_timer = 0.8
    return
  }
  // Tab to next available unit
  if @raylib.is_key_pressed(@raylib.KeyTab) {
    select_next_unit(battle)
    return
  }
  // R to deselect
  if @raylib.is_key_pressed(@raylib.KeyR) {
    battle.selected_unit = -1
    battle.move_targets = []
    battle.attack_targets = []
    return
  }
  // Mouse click
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    match game.hover_hex {
      Some(hc) => {
        if @types.hex_valid(hc, battle.map.width, battle.map.height) {
          match @types.get_unit_at(battle, hc) {
            Some(unit) =>
              if unit.team == Player && unit.active {
                battle.selected_unit = unit.id
                // Compute available moves and attacks
                if !(unit.moved) {
                  battle.move_targets = @combat.compute_move_range(battle, unit)
                } else {
                  battle.move_targets = []
                }
                if !(unit.attacked) {
                  battle.attack_targets = @combat.compute_attack_targets(
                    battle, unit,
                  )
                } else {
                  battle.attack_targets = []
                }
                // If unit has moves, go to Move phase
                if battle.move_targets.length() > 0 {
                  battle.phase = Move
                } else if battle.attack_targets.length() > 0 {
                  battle.phase = Attack
                }
              }
            None => {
              battle.selected_unit = -1
              battle.move_targets = []
              battle.attack_targets = []
            }
          }
        }
      }
      None => ()
    }
  }
}

///|
fn update_move(game : @types.Game, battle : @types.Battle) -> Unit {
  // R to deselect / cancel
  if @raylib.is_key_pressed(@raylib.KeyR) {
    battle.phase = Select
    battle.selected_unit = -1
    battle.move_targets = []
    battle.attack_targets = []
    return
  }
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    match game.hover_hex {
      Some(hc) => {
        if @types.hex_valid(hc, battle.map.width, battle.map.height) {
          // Check if clicking on a move target
          let mut is_move_target = false
          for i in 0..<battle.move_targets.length() {
            if battle.move_targets[i].col == hc.col && battle.move_targets[i].row == hc.row {
              is_move_target = true
              break
            }
          }
          if is_move_target {
            let _ = @combat.move_unit(battle, battle.selected_unit, hc)
            // After moving, show attack targets
            match @types.get_unit(battle, battle.selected_unit) {
              Some(unit) => {
                battle.move_targets = []
                if !(unit.attacked) {
                  battle.attack_targets = @combat.compute_attack_targets(
                    battle, unit,
                  )
                  if battle.attack_targets.length() > 0 {
                    battle.phase = Attack
                  } else {
                    // No attack targets, mark done
                    unit.attacked = true
                    battle.selected_unit = -1
                    battle.attack_targets = []
                    battle.phase = Select
                    @types.update_fog_of_war(battle)
                  }
                } else {
                  battle.selected_unit = -1
                  battle.attack_targets = []
                  battle.phase = Select
                  @types.update_fog_of_war(battle)
                }
              }
              None => {
                battle.phase = Select
                battle.selected_unit = -1
                battle.move_targets = []
                battle.attack_targets = []
              }
            }
          } else {
            // Click elsewhere - check if clicking different player unit
            match @types.get_unit_at(battle, hc) {
              Some(unit) =>
                if unit.team == Player && unit.active {
                  battle.selected_unit = unit.id
                  if !(unit.moved) {
                    battle.move_targets = @combat.compute_move_range(
                      battle, unit,
                    )
                  } else {
                    battle.move_targets = []
                  }
                  if !(unit.attacked) {
                    battle.attack_targets = @combat.compute_attack_targets(
                      battle, unit,
                    )
                  } else {
                    battle.attack_targets = []
                  }
                  if battle.move_targets.length() > 0 {
                    battle.phase = Move
                  } else if battle.attack_targets.length() > 0 {
                    battle.phase = Attack
                  } else {
                    battle.phase = Select
                  }
                } else {
                  // Deselect
                  battle.phase = Select
                  battle.selected_unit = -1
                  battle.move_targets = []
                  battle.attack_targets = []
                }
              None => {
                battle.phase = Select
                battle.selected_unit = -1
                battle.move_targets = []
                battle.attack_targets = []
              }
            }
          }
        }
      }
      None => ()
    }
  }
}

///|
fn update_attack(game : @types.Game, battle : @types.Battle) -> Unit {
  // R to skip attack
  if @raylib.is_key_pressed(@raylib.KeyR) {
    match @types.get_unit(battle, battle.selected_unit) {
      Some(unit) => unit.attacked = true
      None => ()
    }
    battle.phase = Select
    battle.selected_unit = -1
    battle.move_targets = []
    battle.attack_targets = []
    return
  }
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    match game.hover_hex {
      Some(hc) => {
        if @types.hex_valid(hc, battle.map.width, battle.map.height) {
          // Check if clicking on attack target
          let mut is_attack_target = false
          for i in 0..<battle.attack_targets.length() {
            if battle.attack_targets[i].col == hc.col && battle.attack_targets[i].row == hc.row {
              is_attack_target = true
              break
            }
          }
          if is_attack_target {
            match @types.get_unit_at(battle, hc) {
              Some(target) => {
                // Trigger attack flash at attacker position
                match @types.get_unit(battle, battle.selected_unit) {
                  Some(attacker) => {
                    battle.attack_flash_timer = 0.3
                    battle.attack_flash_pos = Some(attacker.pos)
                  }
                  None => ()
                }
                let (dmg, killed) = @combat.resolve_attack(
                  battle, battle.selected_unit, target.id,
                )
                if dmg > 0 {
                  let msg = if killed {
                    "Hit for " + dmg.to_string() + " - DESTROYED!"
                  } else {
                    "Hit for " + dmg.to_string() + " damage"
                  }
                  battle.anim_message = msg
                  battle.anim_timer = 1.0
                  // Trigger hit shake on defender
                  battle.hit_shake_timer = 0.4
                  battle.hit_shake_target = Some(hc)
                  // Trigger damage popup
                  battle.damage_popup_timer = 0.8
                  battle.damage_popup_pos = Some(hc)
                  battle.damage_popup_value = dmg
                }
                // Check victory
                let result = @combat.check_victory(battle)
                if result != Ongoing {
                  battle.result = result
                  finish_battle(game, battle)
                  return
                }
              }
              None => ()
            }
            battle.selected_unit = -1
            battle.move_targets = []
            battle.attack_targets = []
            battle.phase = Select
            @types.update_fog_of_war(battle)
          }
        }
      }
      None => ()
    }
  }
}

///|
fn update_enemy_turn(game : @types.Game, battle : @types.Battle) -> Unit {
  @types.reset_team_turn(battle, Enemy)
  let messages = @ai.execute_ai_turn(battle, game.difficulty)
  // Show first message as animation
  if messages.length() > 0 {
    battle.anim_message = messages[0]
    battle.anim_timer = 1.5
    battle.phase = Animating
  } else {
    // No enemy actions, back to player
    battle.phase = Select
    battle.turn = battle.turn + 1
    @types.reset_team_turn(battle, Player)
    @types.update_fog_of_war(battle)
  }
}

///|
fn select_next_unit(battle : @types.Battle) -> Unit {
  let start = battle.selected_unit + 1
  let count = battle.units.length()
  for k = 0; k < count; k = k + 1 {
    let idx = (start + k) % count
    let u = battle.units[idx]
    if u.active && u.team == Player && !(u.moved && u.attacked) {
      battle.selected_unit = u.id
      if !(u.moved) {
        battle.move_targets = @combat.compute_move_range(battle, u)
      } else {
        battle.move_targets = []
      }
      if !(u.attacked) {
        battle.attack_targets = @combat.compute_attack_targets(battle, u)
      } else {
        battle.attack_targets = []
      }
      if battle.move_targets.length() > 0 {
        battle.phase = Move
      } else if battle.attack_targets.length() > 0 {
        battle.phase = Attack
      }
      return
    }
  }
}

///|
fn finish_battle(game : @types.Game, battle : @types.Battle) -> Unit {
  let was_victory = battle.result == Victory
  let score = @combat.calc_score(battle, was_victory)
  game.last_score = score
  game.last_turns = battle.turn
  game.last_units_remaining = @types.count_team_units(battle, Player)
  game.last_was_victory = was_victory
  // Update campaign progress if applicable
  if game.screen == Playing && was_victory {
    let lvl = game.campaign.current_level
    if score > game.campaign.level_scores[lvl] {
      game.campaign.level_scores[lvl] = score
    }
    if lvl + 1 < @types.total_campaign_levels && lvl + 1 >= game.campaign.levels_unlocked {
      game.campaign.levels_unlocked = lvl + 2
    }
    // Recalculate total score
    let mut total = 0
    for i in 0..<@types.total_campaign_levels {
      total = total + game.campaign.level_scores[i]
    }
    game.campaign.total_score = total
  }
  game.screen = Results
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.screen = Campaign
    game.battle = None
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
    game.battle = None
  }
}
