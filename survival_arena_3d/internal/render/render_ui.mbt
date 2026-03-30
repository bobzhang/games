// 2D UI overlay

///|
/// Draws all screen-space UI for the current game state, including combat HUD,
/// shop/wave summary panels, and menu/pause/game-over overlays.
pub fn draw_ui(game : @types.Game) -> Unit {
  match game.state {
    Menu => game.draw_menu()
    Playing => {
      game.draw_hud()
      game.draw_crosshair()
      game.draw_weapon_display()
      game.draw_damage_flash()
      game.draw_damage_indicators()
      game.draw_message()
    }
    WaveComplete => {
      game.draw_hud()
      game.draw_crosshair()
      game.draw_weapon_display()
      game.draw_wave_summary()
      game.draw_shop_ui()
      game.draw_message()
    }
    Paused => {
      game.draw_hud()
      game.draw_pause_overlay()
    }
    GameOver => game.draw_game_over()
  }
}

///|
fn @types.Game::draw_menu(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(10, 10, 20, 255))
  // Title
  let title = "SURVIVAL ARENA 3D"
  let tw = @draw.measure_text(title, 52)
  @draw.draw_text(
    title,
    (sw - tw) / 2,
    140,
    52,
    @raylib.Color::new(200, 50, 50, 255),
  )
  // Subtitle
  let sub = "Wave-based FPS Survival"
  let sub_w = @draw.measure_text(sub, 22)
  @draw.draw_text(
    sub,
    (sw - sub_w) / 2,
    200,
    22,
    @raylib.Color::new(180, 180, 200, 255),
  )
  // Instructions
  let blink = @math.sinf(game.menu_blink * 2.0)
  let start_color = if blink > 0.0 {
    @raylib.Color::new(255, 255, 100, 255)
  } else {
    @raylib.Color::new(200, 200, 80, 255)
  }
  let start_text = "Press ENTER or SPACE to Start"
  let start_w = @draw.measure_text(start_text, 26)
  @draw.draw_text(start_text, (sw - start_w) / 2, 300, 26, start_color)
  // Controls info
  let controls : Array[String] = [
    "WASD - Move | Mouse - Look", "Left Click - Shoot | Shift - Sprint", "1-6 / Scroll - Switch Weapon | R - Reload",
    "Ctrl/C - Crouch | ESC - Pause",
  ]
  for i in 0..<controls.length() {
    let text = controls[i]
    let cw = @draw.measure_text(text, 16)
    @draw.draw_text(
      text,
      (sw - cw) / 2,
      400 + i * 26,
      16,
      @raylib.Color::new(140, 140, 160, 255),
    )
  }
  // Game info
  let info = "Survive 30 waves of enemies. Collect ammo crates. Buy upgrades between waves."
  let iw = @draw.measure_text(info, 14)
  @draw.draw_text(
    info,
    (sw - iw) / 2,
    sh - 60,
    14,
    @raylib.Color::new(120, 120, 140, 255),
  )
}

///|
fn @types.Game::draw_hud(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let player = game.player
  // Top bar background
  @raylib.draw_rectangle(0, 0, sw, 44, @raylib.Color::new(0, 0, 0, 160))
  // Wave info
  @draw.draw_text(
    "Wave: \{game.current_wave + 1}/\{@types.max_waves}",
    10,
    12,
    20,
    @raylib.Color::new(200, 220, 255, 255),
  )
  // Score
  @draw.draw_text(
    "Score: \{player.score}",
    200,
    12,
    20,
    @raylib.Color::new(200, 200, 200, 255),
  )
  // Gold
  @draw.draw_text(
    "Gold: \{player.money}",
    400,
    12,
    20,
    @raylib.Color::new(255, 215, 0, 255),
  )
  // Kills
  @draw.draw_text(
    "Kills: \{player.kills}",
    580,
    12,
    20,
    @raylib.Color::new(200, 100, 100, 255),
  )
  // FPS
  let fps = @raylib.get_fps()
  @draw.draw_text(
    "FPS: \{fps}",
    sw - 100,
    12,
    18,
    @raylib.Color::new(150, 150, 150, 255),
  )
  // Health bar (bottom left)
  let sh = @types.screen_height
  let bar_x = 20
  let bar_y = sh - 60
  let bar_w = 200
  let bar_h = 20
  // HP background
  @raylib.draw_rectangle(
    bar_x - 2,
    bar_y - 2,
    bar_w + 4,
    bar_h + 4,
    @raylib.Color::new(0, 0, 0, 180),
  )
  // HP fill
  let hp_pct = player.hp / @types.player_max_hp
  let hp_fill_w = (Float::from_int(bar_w) * hp_pct).to_int()
  let hp_color = if hp_pct > 0.6 {
    @raylib.Color::new(0, 200, 50, 255)
  } else if hp_pct > 0.3 {
    @raylib.Color::new(220, 200, 0, 255)
  } else {
    @raylib.Color::new(220, 50, 30, 255)
  }
  @raylib.draw_rectangle(bar_x, bar_y, hp_fill_w, bar_h, hp_color)
  @draw.draw_text(
    "HP: \{player.hp.to_int()}/\{@types.player_max_hp.to_int()}",
    bar_x + 5,
    bar_y + 2,
    16,
    @raylib.Color::new(255, 255, 255, 255),
  )
  // Armor bar
  let armor_y = bar_y - 28
  @raylib.draw_rectangle(
    bar_x - 2,
    armor_y - 2,
    bar_w + 4,
    bar_h + 4,
    @raylib.Color::new(0, 0, 0, 180),
  )
  let armor_pct = player.armor / @types.player_max_armor
  let armor_fill_w = (Float::from_int(bar_w) * armor_pct).to_int()
  @raylib.draw_rectangle(
    bar_x,
    armor_y,
    armor_fill_w,
    bar_h,
    @raylib.Color::new(50, 120, 220, 255),
  )
  @draw.draw_text(
    "Armor: \{player.armor.to_int()}/\{@types.player_max_armor.to_int()}",
    bar_x + 5,
    armor_y + 2,
    16,
    @raylib.Color::new(255, 255, 255, 255),
  )
  // Ammo display (bottom right) - mag/mag_size | reserve
  let ammo_x = sw - 250
  let ammo_y = sh - 72
  @raylib.draw_rectangle(
    ammo_x - 5,
    ammo_y - 5,
    240,
    66,
    @raylib.Color::new(0, 0, 0, 160),
  )
  let weapon = player.current_weapon.to_int()
  let weapon_text = @types.weapon_name(weapon)
  @draw.draw_text(
    weapon_text,
    ammo_x,
    ammo_y,
    20,
    @raylib.Color::new(255, 220, 100, 255),
  )
  // Magazine / max | reserve format
  let mag_cur = player.magazine[weapon]
  let mag_max = @types.effective_mag_size(player, weapon)
  let reserve = player.ammo[weapon]
  let ammo_text = if player.current_weapon == Pistol {
    "\{mag_cur}/\{mag_max} | INF"
  } else {
    "\{mag_cur}/\{mag_max} | \{reserve}"
  }
  let ammo_color = if mag_cur > 0 {
    @raylib.Color::new(200, 200, 200, 255)
  } else if reserve > 0 || player.current_weapon == Pistol {
    @raylib.Color::new(255, 180, 80, 255)
  } else {
    @raylib.Color::new(255, 80, 80, 255)
  }
  @draw.draw_text(ammo_text, ammo_x, ammo_y + 22, 18, ammo_color)
  // Reload progress bar
  let ws = game.weapons[weapon]
  if ws.reloading {
    let reload_total = @types.weapon_reload_time(weapon)
    let reload_pct : Float = if reload_total > 0.0 {
      let one : Float = 1.0
      one - ws.reload_time / reload_total
    } else {
      1.0
    }
    let rbar_x = ammo_x
    let rbar_y = ammo_y + 44
    let rbar_w = 180
    let rbar_h = 8
    @raylib.draw_rectangle(
      rbar_x, rbar_y, rbar_w, rbar_h,
      @raylib.Color::new(40, 40, 50, 200),
    )
    let fill_w = (Float::from_int(rbar_w) * reload_pct).to_int()
    @raylib.draw_rectangle(
      rbar_x, rbar_y, fill_w, rbar_h,
      @raylib.Color::new(100, 200, 255, 255),
    )
    @draw.draw_text(
      "RELOADING",
      rbar_x + rbar_w / 2 - 30,
      rbar_y - 12,
      12,
      @raylib.Color::new(100, 200, 255, 255),
    )
  }
  // Weapon switch indicator
  if player.weapon_switch_timer > 0.0 {
    @draw.draw_text(
      "EQUIPPING...",
      ammo_x,
      ammo_y + 44,
      12,
      @raylib.Color::new(255, 220, 100, 200),
    )
  }
  // Weapon slots indicator
  let slot_y = sh - 95
  for i in 0..<@types.weapon_count {
    let slot_x = ammo_x + i * 50
    let is_selected = i == weapon
    let bg_color = if is_selected {
      @raylib.Color::new(80, 80, 120, 200)
    } else {
      @raylib.Color::new(30, 30, 40, 150)
    }
    @raylib.draw_rectangle(slot_x, slot_y, 44, 28, bg_color)
    @raylib.draw_rectangle_lines(
      slot_x,
      slot_y,
      44,
      28,
      if is_selected {
        @raylib.Color::new(200, 200, 255, 255)
      } else {
        @raylib.Color::new(80, 80, 100, 255)
      },
    )
    let key_text = "\{i + 1}"
    @draw.draw_text(
      key_text,
      slot_x + 4,
      slot_y + 4,
      14,
      @raylib.Color::new(200, 200, 200, 255),
    )
    let short_name = if i == 0 {
      "P"
    } else if i == 1 {
      "SG"
    } else if i == 2 {
      "R"
    } else if i == 3 {
      "S"
    } else if i == 4 {
      "RL"
    } else {
      "MG"
    }
    @draw.draw_text(
      short_name,
      slot_x + 18,
      slot_y + 8,
      12,
      @raylib.Color::new(180, 180, 200, 255),
    )
  }
  // Enemy count during wave
  if game.wave_active {
    let alive = @types.count_active_enemies(game)
    let remaining = game.enemies_to_spawn - game.enemies_spawned + alive
    @draw.draw_text(
      "Enemies: \{remaining}",
      sw / 2 - 50,
      50,
      18,
      @raylib.Color::new(255, 150, 100, 255),
    )
  }
}

///|
fn @types.Game::draw_crosshair(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  let cx = sw / 2
  let cy = sh / 2
  let size = 10
  let gap = 3
  // Crosshair color: neutral when idle, tinted on hit
  let color = if game.hit_marker_timer > 0.0 {
    if game.hit_marker_is_kill {
      @raylib.Color::new(255, 50, 50, 255)
    } else {
      @raylib.Color::new(255, 255, 255, 255)
    }
  } else {
    @raylib.Color::new(220, 220, 220, 200)
  }
  // Cross lines
  @raylib.draw_rectangle(cx - size, cy - 1, size - gap, 2, color)
  @raylib.draw_rectangle(cx + gap + 1, cy - 1, size - gap, 2, color)
  @raylib.draw_rectangle(cx - 1, cy - size, 2, size - gap, color)
  @raylib.draw_rectangle(cx - 1, cy + gap + 1, 2, size - gap, color)
  // Center dot
  @raylib.draw_rectangle(cx - 1, cy - 1, 2, 2, color)
  // Hit marker X: white for body, red for kill
  if game.hit_marker_timer > 0.0 {
    let hm_size = 6
    let hm_color = if game.hit_marker_is_kill {
      @raylib.Color::new(255, 50, 50, 255)
    } else {
      @raylib.Color::new(255, 255, 255, 230)
    }
    // Top-left to bottom-right diagonal
    @raylib.draw_rectangle(cx - hm_size - 2, cy - hm_size - 2, 4, 4, hm_color)
    @raylib.draw_rectangle(cx + hm_size - 2, cy + hm_size - 2, 4, 4, hm_color)
    // Top-right to bottom-left diagonal
    @raylib.draw_rectangle(cx + hm_size - 2, cy - hm_size - 2, 4, 4, hm_color)
    @raylib.draw_rectangle(cx - hm_size - 2, cy + hm_size - 2, 4, 4, hm_color)
  }
}

///|
fn @types.Game::draw_weapon_display(game : @types.Game) -> Unit {
  let sh = @types.screen_height
  let sw = @types.screen_width
  let player = game.player
  // Weapon view model (simplified gun shape in 2D)
  let weapon = player.current_weapon
  let gun_x = sw / 2 + 80
  let gun_y = sh - 140
  // Muzzle flash
  if player.flash_timer > 0.0 {
    let flash_alpha = (player.flash_timer / 0.08 * 200.0).to_int()
    let fa = flash_alpha.clamp(min=0, max=200)
    @raylib.draw_rectangle(
      gun_x - 5,
      gun_y - 30,
      10,
      20,
      @raylib.Color::new(255, 230, 100, fa),
    )
    @raylib.draw_rectangle(
      gun_x - 10,
      gun_y - 20,
      20,
      10,
      @raylib.Color::new(255, 200, 50, fa),
    )
  }
  match weapon {
    Pistol => {
      // Pistol shape
      @raylib.draw_rectangle(
        gun_x - 6,
        gun_y,
        12,
        30,
        @raylib.Color::new(80, 80, 90, 255),
      )
      @raylib.draw_rectangle(
        gun_x - 4,
        gun_y - 15,
        8,
        18,
        @raylib.Color::new(100, 100, 110, 255),
      )
    }
    Shotgun => {
      // Shotgun shape - wider
      @raylib.draw_rectangle(
        gun_x - 8,
        gun_y,
        16,
        35,
        @raylib.Color::new(120, 80, 40, 255),
      )
      @raylib.draw_rectangle(
        gun_x - 5,
        gun_y - 25,
        10,
        28,
        @raylib.Color::new(90, 90, 100, 255),
      )
      @raylib.draw_rectangle(
        gun_x - 5,
        gun_y - 28,
        10,
        6,
        @raylib.Color::new(70, 70, 80, 255),
      )
    }
    Rifle => {
      // Rifle shape - long
      @raylib.draw_rectangle(
        gun_x - 6,
        gun_y,
        12,
        30,
        @raylib.Color::new(50, 80, 50, 255),
      )
      @raylib.draw_rectangle(
        gun_x - 4,
        gun_y - 35,
        8,
        38,
        @raylib.Color::new(80, 90, 80, 255),
      )
      @raylib.draw_rectangle(
        gun_x - 3,
        gun_y - 40,
        6,
        8,
        @raylib.Color::new(60, 70, 60, 255),
      )
    }
    Sniper => {
      // Sniper shape - very long barrel with scope
      @raylib.draw_rectangle(
        gun_x - 5,
        gun_y,
        10,
        32,
        @raylib.Color::new(60, 60, 70, 255),
      )
      @raylib.draw_rectangle(
        gun_x - 3,
        gun_y - 45,
        6,
        48,
        @raylib.Color::new(90, 90, 100, 255),
      )
      // Scope
      @raylib.draw_rectangle(
        gun_x - 6,
        gun_y - 30,
        12,
        6,
        @raylib.Color::new(40, 40, 50, 255),
      )
      @raylib.draw_rectangle(
        gun_x - 2,
        gun_y - 50,
        4,
        8,
        @raylib.Color::new(70, 70, 80, 255),
      )
    }
    Minigun => {
      // Minigun shape - wide with multiple barrels
      @raylib.draw_rectangle(
        gun_x - 10,
        gun_y,
        20,
        28,
        @raylib.Color::new(70, 70, 80, 255),
      )
      @raylib.draw_rectangle(
        gun_x - 8,
        gun_y - 30,
        16,
        34,
        @raylib.Color::new(90, 90, 100, 255),
      )
      // Multiple barrels
      @raylib.draw_rectangle(
        gun_x - 6,
        gun_y - 38,
        4,
        12,
        @raylib.Color::new(100, 100, 110, 255),
      )
      @raylib.draw_rectangle(
        gun_x + 2,
        gun_y - 38,
        4,
        12,
        @raylib.Color::new(100, 100, 110, 255),
      )
      // Ammo box
      @raylib.draw_rectangle(
        gun_x + 10,
        gun_y - 5,
        12,
        16,
        @raylib.Color::new(60, 80, 50, 255),
      )
    }
    _ => {
      // Rocket launcher - chunky
      @raylib.draw_rectangle(
        gun_x - 10,
        gun_y,
        20,
        30,
        @raylib.Color::new(60, 80, 60, 255),
      )
      @raylib.draw_rectangle(
        gun_x - 8,
        gun_y - 30,
        16,
        35,
        @raylib.Color::new(80, 80, 60, 255),
      )
      @raylib.draw_rectangle(
        gun_x - 10,
        gun_y - 15,
        20,
        8,
        @raylib.Color::new(120, 50, 30, 255),
      )
    }
  }
}

///|
fn @types.Game::draw_damage_flash(game : @types.Game) -> Unit {
  if game.player.flash_timer > 0.0 && game.player.damage_timer > 0.0 {
    let alpha = (game.player.flash_timer / 0.2 * 100.0).to_int()
    let a = alpha.clamp(min=0, max=100)
    @raylib.draw_rectangle(
      0,
      0,
      @types.screen_width,
      @types.screen_height,
      @raylib.Color::new(200, 0, 0, a),
    )
  }
}

///|
fn @types.Game::draw_damage_indicators(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  let cx = Float::from_int(sw) / 2.0
  let cy = Float::from_int(sh) / 2.0
  let indicator_dist : Float = 100.0
  let indicator_w : Float = 8.0
  let indicator_h : Float = 30.0
  for di in game.damage_indicators {
    if !di.active {
      continue
    }
    let alpha_f = @types.minf(di.timer * 2.0, 1.0) * 220.0
    let alpha = alpha_f.to_int().clamp(min=0, max=220)
    let angle = di.angle
    let ix = cx + @math.cosf(angle) * indicator_dist
    let iy = cy + @math.sinf(angle) * indicator_dist
    let degrees = angle * 180.0 / @types.pi
    @raylib.draw_rectangle_pro(
      @raylib.Rectangle::new(ix, iy, indicator_w, indicator_h),
      @raylib.Vector2::new(indicator_w / 2.0, indicator_h / 2.0),
      degrees + 90.0,
      @raylib.Color::new(220, 30, 30, alpha),
    )
  }
}

///|
fn @types.Game::draw_message(game : @types.Game) -> Unit {
  if game.message_timer > 0.0 {
    let alpha_f = @types.minf(game.message_timer * 2.0, 1.0) * 255.0
    let alpha = alpha_f.to_int()
    let a = alpha.clamp(min=0, max=255)
    let text = game.message_text
    let tw = @draw.measure_text(text, 22)
    let cx = (@types.screen_width - tw) / 2
    let cy = 80
    @raylib.draw_rectangle(
      cx - 10,
      cy - 5,
      tw + 20,
      32,
      @raylib.Color::new(0, 0, 0, a / 2),
    )
    @draw.draw_text(text, cx, cy, 22, @raylib.Color::new(255, 255, 200, a))
  }
}

///|
fn @types.Game::draw_wave_summary(game : @types.Game) -> Unit {
  if !game.show_wave_summary {
    return
  }
  let sw = @types.screen_width
  let panel_w = 260
  let panel_h = 130
  let panel_x = (sw - panel_w) / 2
  let panel_y = (@types.screen_height - panel_h) / 2
  let alpha_f = @types.minf(game.wave_summary_timer, 1.0) * 230.0
  let alpha = alpha_f.to_int().clamp(min=0, max=230)
  @raylib.draw_rectangle(
    panel_x, panel_y, panel_w, panel_h,
    @raylib.Color::new(10, 15, 25, alpha),
  )
  @raylib.draw_rectangle_lines(
    panel_x, panel_y, panel_w, panel_h,
    @raylib.Color::new(100, 180, 100, alpha),
  )
  let title = "Wave \{game.current_wave} Complete!"
  let ttw = @draw.measure_text(title, 18)
  @draw.draw_text(
    title, panel_x + (panel_w - ttw) / 2, panel_y + 8, 18,
    @raylib.Color::new(100, 255, 100, alpha),
  )
  let wave_shots_fired = game.total_shots_fired - game.wave_start_shots_fired
  let wave_shots_hit = game.total_shots_hit - game.wave_start_shots_hit
  let accuracy = if wave_shots_fired > 0 {
    wave_shots_hit * 100 / wave_shots_fired
  } else {
    0
  }
  @draw.draw_text(
    "Kills: \{game.wave_summary_kills}", panel_x + 15, panel_y + 34, 16,
    @raylib.Color::new(220, 220, 240, alpha),
  )
  @draw.draw_text(
    "Accuracy: \{accuracy}%", panel_x + 15, panel_y + 56, 16,
    @raylib.Color::new(220, 220, 240, alpha),
  )
  @draw.draw_text(
    "Gold earned: +\{game.wave_summary_money}", panel_x + 15, panel_y + 78, 16,
    @raylib.Color::new(255, 215, 0, alpha),
  )
  @draw.draw_text(
    "Score: \{game.player.score}", panel_x + 15, panel_y + 100, 16,
    @raylib.Color::new(200, 200, 220, alpha),
  )
}

///|
fn @types.Game::draw_shop_ui(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let player = game.player
  let wi = player.current_weapon.to_int()
  let wname = @types.weapon_name(wi)
  // Shop panel
  let panel_w = 380
  let panel_h = 650
  let panel_x = (sw - panel_w) / 2
  let panel_y = 30
  @raylib.draw_rectangle(
    panel_x, panel_y, panel_w, panel_h,
    @raylib.Color::new(15, 18, 28, 230),
  )
  @raylib.draw_rectangle_lines(
    panel_x, panel_y, panel_w, panel_h,
    @raylib.Color::new(100, 120, 180, 255),
  )
  // Title
  let title = "SHOP - Between Waves"
  let ttw = @draw.measure_text(title, 20)
  @draw.draw_text(
    title, panel_x + (panel_w - ttw) / 2, panel_y + 8, 20,
    @raylib.Color::new(200, 220, 255, 255),
  )
  // Timer
  let timer_text = "Next wave in: \{game.wave_timer.to_int() + 1}s (SPACE to skip)"
  let ttw2 = @draw.measure_text(timer_text, 14)
  @draw.draw_text(
    timer_text, panel_x + (panel_w - ttw2) / 2, panel_y + 30, 14,
    @raylib.Color::new(255, 200, 100, 255),
  )
  // Build shop items dynamically for per-weapon upgrades
  let dmg_lvl = player.weapon_damage_level[wi]
  let rate_lvl = player.weapon_rate_level[wi]
  let mag_lvl = player.weapon_mag_level[wi]
  let max_lvl = @types.upgrade_max_level
  // Compute upgrade labels and costs
  let hundred : Float = 100.0
  let dmg_label = if dmg_lvl >= max_lvl {
    "\{wname} Damage [MAX]"
  } else {
    let cur_pct = (hundred + Float::from_int(dmg_lvl) * @types.upgrade_damage_step * hundred).to_int()
    let dmg_lvl_next = dmg_lvl + 1
    let nxt_pct = (hundred + Float::from_int(dmg_lvl_next) * @types.upgrade_damage_step * hundred).to_int()
    "\{wname} Dmg Lv\{dmg_lvl}: \{cur_pct}%->\{nxt_pct}%"
  }
  let dmg_cost = if dmg_lvl >= max_lvl { 0 } else { @types.upgrade_cost(dmg_lvl) }
  let rate_label = if rate_lvl >= max_lvl {
    "\{wname} Rate [MAX]"
  } else {
    let cur_pct = (hundred - Float::from_int(rate_lvl) * @types.upgrade_rate_step * hundred).to_int()
    let rate_lvl_next = rate_lvl + 1
    let nxt_pct = (hundred - Float::from_int(rate_lvl_next) * @types.upgrade_rate_step * hundred).to_int()
    "\{wname} Rate Lv\{rate_lvl}: \{cur_pct}%->\{nxt_pct}%"
  }
  let rate_cost = if rate_lvl >= max_lvl { 0 } else { @types.upgrade_cost(rate_lvl) }
  let cur_mag = @types.effective_mag_size(player, wi)
  let mag_label = if mag_lvl >= max_lvl {
    "\{wname} Mag [MAX]"
  } else {
    // Compute next mag size
    let base_mag = @types.weapon_mag_size(wi)
    let mag_lvl_next = mag_lvl + 1
    let nxt_bonus = (Float::from_int(base_mag) * Float::from_int(mag_lvl_next) * @types.upgrade_mag_step).to_int()
    let nxt_mag = base_mag + nxt_bonus
    "\{wname} Mag Lv\{mag_lvl}: \{cur_mag}->\{nxt_mag}"
  }
  let mag_cost = if mag_lvl >= max_lvl { 0 } else { @types.upgrade_cost(mag_lvl) }
  // Item list: (label, cost, is_maxed)
  let item_labels : Array[String] = [
    "Heal +40 HP",
    "Armor +30",
    "Shotgun Ammo +12",
    "Rifle Ammo +30",
    "Sniper Ammo +5",
    "Rocket Ammo +3",
    "Minigun Ammo +100",
    dmg_label,
    rate_label,
    mag_label,
    "Buy Sniper Rifle",
    "Buy Rocket Launcher",
    "Buy Minigun",
    "Place Barricade",
    "Place Spike Trap",
  ]
  let item_costs : Array[Int] = [
    @types.cost_heal,
    @types.cost_armor,
    @types.cost_shotgun_ammo,
    @types.cost_rifle_ammo,
    @types.cost_sniper_ammo,
    @types.cost_rocket_ammo,
    @types.cost_minigun_ammo,
    dmg_cost,
    rate_cost,
    mag_cost,
    @types.cost_buy_sniper,
    @types.cost_buy_rocket,
    @types.cost_buy_minigun,
    @types.cost_barricade,
    @types.cost_trap_spike,
  ]
  let item_maxed : Array[Bool] = [
    false, false, false, false, false, false, false,
    dmg_lvl >= max_lvl, rate_lvl >= max_lvl, mag_lvl >= max_lvl,
    player.owns_weapon[@types.Sniper.to_int()],
    player.owns_weapon[@types.Rocket.to_int()],
    player.owns_weapon[@types.Minigun.to_int()],
    false, false,
  ]
  let item_count = item_labels.length()
  for i in 0..<item_count {
    let label = item_labels[i]
    let cost = item_costs[i]
    let maxed = item_maxed[i]
    let iy = panel_y + 50 + i * 38
    let is_sel = game.shop_cursor == i
    let can_afford = player.money >= cost && !maxed
    let bg = if is_sel {
      @raylib.Color::new(50, 55, 80, 255)
    } else {
      @raylib.Color::new(25, 28, 40, 255)
    }
    @raylib.draw_rectangle(panel_x + 10, iy, panel_w - 20, 34, bg)
    if is_sel {
      @raylib.draw_rectangle_lines(
        panel_x + 10, iy, panel_w - 20, 34,
        @raylib.Color::new(150, 170, 220, 255),
      )
    }
    let text_color = if maxed {
      @raylib.Color::new(80, 180, 80, 255)
    } else if can_afford {
      @raylib.Color::new(220, 220, 240, 255)
    } else {
      @raylib.Color::new(100, 80, 80, 255)
    }
    let prefix = if is_sel { "> " } else { "  " }
    @draw.draw_text(prefix + label, panel_x + 14, iy + 5, 14, text_color)
    let cost_str = if maxed { "---" } else { "\{cost}g" }
    let cost_color = if maxed {
      @raylib.Color::new(80, 180, 80, 200)
    } else {
      @raylib.Color::new(255, 215, 0, 200)
    }
    @draw.draw_text(
      cost_str, panel_x + panel_w - 60, iy + 5, 14, cost_color,
    )
  }
  // Gold display
  let footer_y = panel_y + panel_h - 28
  @draw.draw_text(
    "Gold: \{player.money}", panel_x + 10, footer_y, 16,
    @raylib.Color::new(255, 215, 0, 255),
  )
  // Controls hint
  @draw.draw_text(
    "Up/Down: Select | E/Enter: Buy",
    panel_x + panel_w - 230, footer_y, 12,
    @raylib.Color::new(140, 140, 160, 255),
  )
}

///|
fn @types.Game::draw_pause_overlay(game : @types.Game) -> Unit {
  ignore(game)
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 150),
  )
  let text = "PAUSED"
  let tw = @draw.measure_text(text, 60)
  @draw.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 60,
    60,
    @raylib.white,
  )
  let sub = "ESC - Resume | Q - Quit to Menu"
  let sw2 = @draw.measure_text(sub, 20)
  @draw.draw_text(
    sub,
    (@types.screen_width - sw2) / 2,
    @types.screen_height / 2 + 20,
    20,
    @raylib.Color::new(180, 180, 200, 255),
  )
}

///|
fn @types.Game::draw_game_over(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  let player = game.player
  // Check if it was a victory (survived all waves)
  let is_victory = game.current_wave >= @types.max_waves
  let bg_color = if is_victory {
    @raylib.Color::new(0, 30, 0, 220)
  } else {
    @raylib.Color::new(40, 0, 0, 220)
  }
  @raylib.draw_rectangle(0, 0, sw, sh, bg_color)
  let title = if is_victory { "VICTORY!" } else { "GAME OVER" }
  let title_color = if is_victory {
    @raylib.Color::new(100, 255, 100, 255)
  } else {
    @raylib.Color::new(255, 80, 60, 255)
  }
  let tw = @draw.measure_text(title, 60)
  @draw.draw_text(title, (sw - tw) / 2, sh / 2 - 100, 60, title_color)
  // Stats
  let stats : Array[String] = [
    "Score: \{player.score}",
    "Kills: \{player.kills}",
    {
      let wave_display = if game.current_wave >= @types.max_waves {
        @types.max_waves
      } else {
        game.current_wave + 1
      }
      "Wave Reached: \{wave_display}/\{@types.max_waves}"
    },
    "Gold Earned: \{player.money + player.score}",
  ]
  for i in 0..<stats.length() {
    let text = stats[i]
    let stw = @draw.measure_text(text, 22)
    @draw.draw_text(
      text,
      (sw - stw) / 2,
      sh / 2 - 20 + i * 30,
      22,
      @raylib.Color::new(200, 200, 220, 255),
    )
  }
  let restart_text = "Press ENTER or SPACE to return to Menu"
  let rw = @draw.measure_text(restart_text, 18)
  @draw.draw_text(
    restart_text,
    (sw - rw) / 2,
    sh / 2 + 120,
    18,
    @raylib.Color::new(180, 180, 200, 255),
  )
}
