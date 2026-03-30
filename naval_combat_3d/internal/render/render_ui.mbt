// 2D UI overlay

///|
/// Draws the active 2D naval HUD/menu overlays for the current game state.
pub fn draw_ui(game : @types.Game) -> Unit {
  match game.state {
    Menu => game.draw_menu()
    Playing => {
      game.draw_hud()
      game.draw_message_log()
      game.draw_minimap()
      if game.message_timer > 0.0 {
        game.draw_message()
      }
    }
    Paused => {
      game.draw_hud()
      draw_pause_overlay()
    }
    BattleComplete => {
      game.draw_hud()
      game.draw_battle_complete()
    }
    BattleSelect => game.draw_battle_select()
    GameOver => game.draw_game_over()
  }
}

///|
fn @types.Game::draw_menu(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(15, 30, 60, 255),
  )
  let title = "NAVAL COMBAT 3D"
  let tw = @draw.measure_text(title, 52)
  @draw.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    120,
    52,
    @raylib.Color::new(220, 200, 140, 255),
  )
  let sub = "Command your ship. Destroy the fleet."
  let sw = @draw.measure_text(sub, 20)
  @draw.draw_text(
    sub,
    (@types.screen_width - sw) / 2,
    185,
    20,
    @raylib.Color::new(140, 160, 200, 255),
  )
  let art = "~ ~ ~ __|__ ~ ~ ~"
  let aw = @draw.measure_text(art, 24)
  @draw.draw_text(
    art,
    (@types.screen_width - aw) / 2,
    240,
    24,
    @raylib.Color::new(100, 140, 200, 200),
  )
  let items : Array[String] = ["Quick Battle", "Battle Select"]
  for i in 0..<items.length() {
    let y = 310 + i * 40
    let iw = @draw.measure_text(items[i], 28)
    let ix = (@types.screen_width - iw) / 2
    if game.menu_cursor == i {
      @raylib.draw_rectangle(
        ix - 20,
        y - 5,
        iw + 40,
        36,
        @raylib.Color::new(60, 80, 120, 200),
      )
      @draw.draw_text(
        "> \{items[i]} <",
        ix - 20,
        y,
        28,
        @raylib.Color::new(255, 220, 100, 255),
      )
    } else {
      @draw.draw_text(
        items[i],
        ix,
        y,
        28,
        @raylib.Color::new(160, 170, 200, 255),
      )
    }
  }
  let controls : Array[String] = [
    "WASD - Sail and Steer", "Q / Left Click - Fire Port Cannons", "E / Right Click - Fire Starboard Cannons",
    "Space - Fire Both Broadsides", "P / ESC - Pause", "Mouse Wheel - Rotate Camera",
  ]
  for i in 0..<controls.length() {
    let y = 430 + i * 24
    let cw = @draw.measure_text(controls[i], 16)
    @draw.draw_text(
      controls[i],
      (@types.screen_width - cw) / 2,
      y,
      16,
      @raylib.Color::new(120, 140, 170, 255),
    )
  }
  @draw.draw_text(
    "8 Battles | Wind Sailing | Broadside Cannons",
    10,
    @types.screen_height - 25,
    14,
    @raylib.Color::new(80, 100, 130, 255),
  )
}

///|
fn @types.Game::draw_hud(game : @types.Game) -> Unit {
  let ship = game.player
  // Top bar background
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    50,
    @raylib.Color::new(0, 0, 0, 160),
  )
  @draw.draw_text(
    "Battle: \{game.current_battle + 1}/\{game.total_battles}",
    10,
    5,
    20,
    @raylib.Color::new(220, 200, 140, 255),
  )
  @draw.draw_text(
    "Score: \{game.score}",
    220,
    5,
    20,
    @raylib.Color::new(200, 200, 200, 255),
  )
  @draw.draw_text(
    "Enemies: \{game.enemies_alive}",
    420,
    5,
    20,
    @raylib.Color::new(255, 150, 100, 255),
  )
  // Wind indicator on HUD - arrow drawn with 2D lines
  let wind_hud_x = 660
  let wind_hud_y = 25
  @draw.draw_text("Wind", 650, 5, 16, @raylib.Color::new(150, 180, 220, 255))
  // Draw wind arrow on HUD
  let wind_rel = @types.angle_diff(ship.heading, game.wind_angle)
  let arrow_len : Float = 12.0
  let ax = @math.sinf(wind_rel) * arrow_len
  let ay = -@math.cosf(wind_rel) * arrow_len
  let cx = wind_hud_x + 20
  let cy = wind_hud_y
  @raylib.draw_line(
    cx,
    cy,
    cx + ax.to_int(),
    cy + ay.to_int(),
    @raylib.Color::new(180, 200, 255, 255),
  )
  // Arrowhead
  let head_size : Float = 4.0
  let ha1x = ax + @math.cosf(wind_rel + 2.5) * head_size
  let ha1y = ay - @math.sinf(wind_rel + 2.5) * head_size
  let ha2x = ax + @math.cosf(wind_rel - 2.5) * head_size
  let ha2y = ay - @math.sinf(wind_rel - 2.5) * head_size
  @raylib.draw_line(
    cx + ax.to_int(),
    cy + ay.to_int(),
    cx + ha1x.to_int(),
    cy + ha1y.to_int(),
    @raylib.Color::new(180, 200, 255, 255),
  )
  @raylib.draw_line(
    cx + ax.to_int(),
    cy + ay.to_int(),
    cx + ha2x.to_int(),
    cy + ha2y.to_int(),
    @raylib.Color::new(180, 200, 255, 255),
  )
  let wind_str = if wind_rel.abs() < 0.5 {
    "Tail"
  } else if wind_rel.abs() > 2.6 {
    "Head"
  } else {
    "Cross"
  }
  @draw.draw_text(
    wind_str,
    700,
    5,
    16,
    @raylib.Color::new(180, 200, 255, 255),
  )
  // Wind strength bar
  let wind_pct = game.wind_speed / @types.wind_speed_gale
  let wind_bar_w = (wind_pct * 40.0).to_int()
  @raylib.draw_rectangle(
    700,
    25,
    40,
    6,
    @raylib.Color::new(30, 30, 50, 200),
  )
  @raylib.draw_rectangle(
    700,
    25,
    wind_bar_w,
    6,
    @raylib.Color::new(150, 180, 255, 220),
  )
  // Speed
  let speed_pct = (ship.speed / @types.player_max_sail * 100.0).to_int()
  @draw.draw_text(
    "Speed: \{speed_pct}%",
    830,
    5,
    16,
    @raylib.Color::new(200, 220, 255, 255),
  )
  let sail_pct = (ship.sail_amount * 100.0).to_int()
  @draw.draw_text(
    "Sails: \{sail_pct}%",
    830,
    25,
    16,
    @raylib.Color::new(220, 220, 200, 255),
  )
  // HP bars - bottom left
  let bar_x = 10
  let bar_base_y = @types.screen_height - 80
  let bar_w = 150
  let bar_h = 16
  draw_hp_bar(
    bar_x,
    bar_base_y,
    bar_w,
    bar_h,
    "Hull",
    ship.hull_hp,
    ship.max_hp,
    180,
    60,
    60,
  )
  draw_hp_bar(
    bar_x,
    bar_base_y + 22,
    bar_w,
    bar_h,
    "Sails",
    ship.sail_hp,
    ship.max_hp,
    200,
    200,
    140,
  )
  draw_hp_bar(
    bar_x,
    bar_base_y + 44,
    bar_w,
    bar_h,
    "Rudder",
    ship.rudder_hp,
    ship.max_hp,
    100,
    160,
    220,
  )
  // Reload indicators - bottom right
  let reload_x = @types.screen_width - 200
  let reload_y = @types.screen_height - 50
  let left_pct : Float = if ship.reload_time > 0.0 {
    1.0 - ship.reload_left / ship.reload_time
  } else {
    1.0
  }
  let right_pct : Float = if ship.reload_time > 0.0 {
    1.0 - ship.reload_right / ship.reload_time
  } else {
    1.0
  }
  @draw.draw_text(
    "Port",
    reload_x,
    reload_y,
    14,
    @raylib.Color::new(180, 180, 200, 255),
  )
  @raylib.draw_rectangle(
    reload_x + 50,
    reload_y + 2,
    60,
    12,
    @raylib.Color::new(40, 40, 50, 200),
  )
  let left_fill = (left_pct * 60.0).to_int()
  let left_color = if left_pct >= 1.0 {
    @raylib.Color::new(100, 255, 100, 255)
  } else {
    @raylib.Color::new(255, 200, 50, 255)
  }
  @raylib.draw_rectangle(reload_x + 50, reload_y + 2, left_fill, 12, left_color)
  // Ready text
  if left_pct >= 1.0 {
    @draw.draw_text(
      "READY",
      reload_x + 115,
      reload_y,
      12,
      @raylib.Color::new(100, 255, 100, 255),
    )
  }
  @draw.draw_text(
    "Star",
    reload_x,
    reload_y + 18,
    14,
    @raylib.Color::new(180, 180, 200, 255),
  )
  @raylib.draw_rectangle(
    reload_x + 50,
    reload_y + 20,
    60,
    12,
    @raylib.Color::new(40, 40, 50, 200),
  )
  let right_fill = (right_pct * 60.0).to_int()
  let right_color = if right_pct >= 1.0 {
    @raylib.Color::new(100, 255, 100, 255)
  } else {
    @raylib.Color::new(255, 200, 50, 255)
  }
  @raylib.draw_rectangle(
    reload_x + 50,
    reload_y + 20,
    right_fill,
    12,
    right_color,
  )
  if right_pct >= 1.0 {
    @draw.draw_text(
      "READY",
      reload_x + 115,
      reload_y + 18,
      12,
      @raylib.Color::new(100, 255, 100, 255),
    )
  }
  // Bottom control hints
  @raylib.draw_rectangle(
    0,
    @types.screen_height - 20,
    @types.screen_width,
    20,
    @raylib.Color::new(0, 0, 0, 100),
  )
  @draw.draw_text(
    "WASD: Sail | Q/LMB: Port Fire | E/RMB: Starboard Fire | Space: Both | P: Pause",
    10,
    @types.screen_height - 18,
    12,
    @raylib.Color::new(130, 140, 160, 255),
  )
}

///|
/// Draws the last few battle messages with fade based on age and color coding.
/// Messages are sorted by remaining timer so newest (highest timer) appear first.
fn @types.Game::draw_message_log(game : @types.Game) -> Unit {
  let max_show = 5
  let log_x = 10
  let log_base_y = @types.screen_height - 140
  // Collect active message indices with their timers
  let active : Array[(Int, Float)] = []
  for i in 0..<game.messages.length() {
    let m = game.messages[i]
    if m.active && m.timer > 0.0 {
      active.push((i, m.timer))
    }
  }
  // Sort by timer descending (newest = highest timer first) -- simple
  // insertion sort since the array is tiny (max 8 elements)
  for i in 1..<active.length() {
    let key = active[i]
    let mut j = i - 1
    while j >= 0 && active[j].1 < key.1 {
      active[j + 1] = active[j]
      j -= 1
    }
    active[j + 1] = key
  }
  // Render top entries
  let count = active.length().min(max_show)
  for slot in 0..<count {
    let msg = game.messages[active[slot].0]
    let fade = msg.timer / @types.message_display_time
    let alpha = (fade * 255.0).to_int().clamp(min=0, max=255)
    let y = log_base_y - slot * 18
    // Background strip
    let tw = @draw.measure_text(msg.text, 14)
    @raylib.draw_rectangle(
      log_x - 2,
      y - 1,
      tw + 8,
      16,
      @raylib.Color::new(0, 0, 0, alpha / 2),
    )
    @draw.draw_text(
      msg.text,
      log_x,
      y,
      14,
      @raylib.Color::new(msg.color_r, msg.color_g, msg.color_b, alpha),
    )
  }
}

///|
/// Draws a small tactical minimap showing ship positions relative to the player.
fn @types.Game::draw_minimap(game : @types.Game) -> Unit {
  let map_size = 120
  let map_x = @types.screen_width - map_size - 10
  let map_y = 60
  let map_cx = map_x + map_size / 2
  let map_cy = map_y + map_size / 2
  let map_scale : Float = Float::from_int(map_size) / @types.ocean_size
  // Background
  @raylib.draw_rectangle(
    map_x,
    map_y,
    map_size,
    map_size,
    @raylib.Color::new(10, 30, 60, 180),
  )
  @raylib.draw_rectangle_lines(
    map_x,
    map_y,
    map_size,
    map_size,
    @raylib.Color::new(80, 100, 140, 200),
  )
  // Islands on minimap
  for i in 0..<game.island_count {
    let island = game.islands[i]
    if !island.active {
      continue
    }
    let ix = map_cx + (island.x * map_scale).to_int()
    let iz = map_cy + (island.z * map_scale).to_int()
    let ir = (island.radius * map_scale).to_int().clamp(min=2, max=8)
    @raylib.draw_circle(
      ix,
      iz,
      Float::from_int(ir),
      @raylib.Color::new(100, 85, 60, 200),
    )
  }
  // Player on minimap (green triangle)
  let px = map_cx + (game.player.x * map_scale).to_int()
  let pz = map_cy + (game.player.z * map_scale).to_int()
  @raylib.draw_circle(
    px,
    pz,
    3.0,
    @raylib.Color::new(50, 255, 50, 255),
  )
  // Enemies on minimap (red dots)
  for enemy in game.enemies {
    if !enemy.active {
      continue
    }
    let ex = map_cx + (enemy.x * map_scale).to_int()
    let ez = map_cy + (enemy.z * map_scale).to_int()
    @raylib.draw_circle(
      ex,
      ez,
      2.0,
      @raylib.Color::new(255, 60, 60, 255),
    )
  }
  // Fleet ships on minimap (blue dots)
  for fs in game.fleet_ships {
    if !fs.active {
      continue
    }
    let fx = map_cx + (fs.x * map_scale).to_int()
    let fz = map_cy + (fs.z * map_scale).to_int()
    @raylib.draw_circle(
      fx,
      fz,
      2.0,
      @raylib.Color::new(50, 150, 255, 255),
    )
  }
  // Convoy ships on minimap (yellow dots)
  for cs in game.convoy_ships {
    if !cs.active || cs.arrived {
      continue
    }
    let ccx = map_cx + (cs.x * map_scale).to_int()
    let ccz = map_cy + (cs.z * map_scale).to_int()
    @raylib.draw_circle(
      ccx,
      ccz,
      2.0,
      @raylib.Color::new(255, 220, 80, 255),
    )
  }
  // Label
  @draw.draw_text(
    "MAP",
    map_x + map_size / 2 - 12,
    map_y - 14,
    12,
    @raylib.Color::new(140, 160, 200, 200),
  )
}

///|
fn draw_hp_bar(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  label : String,
  hp : Float,
  max_hp : Float,
  r : Int,
  g : Int,
  b : Int,
) -> Unit {
  let pct : Float = if max_hp > 0.0 { hp / max_hp } else { 0.0 }
  let clamped = @types.clampf(pct, 0.0, 1.0)
  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(30, 30, 40, 200))
  let fill_w = (clamped * Float::from_int(w)).to_int()
  @raylib.draw_rectangle(x, y, fill_w, h, @raylib.Color::new(r, g, b, 220))
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(100, 100, 120, 255),
  )
  @draw.draw_text(
    label,
    x + 4,
    y + 1,
    12,
    @raylib.Color::new(255, 255, 255, 220),
  )
  let pct_text = "\{(clamped * 100.0).to_int()}%"
  let tw = @draw.measure_text(pct_text, 12)
  @draw.draw_text(
    pct_text,
    x + w - tw - 4,
    y + 1,
    12,
    @raylib.Color::new(255, 255, 255, 200),
  )
}

///|
fn @types.Game::draw_message(game : @types.Game) -> Unit {
  let text = game.message_text
  let tw = @draw.measure_text(text, 28)
  let y = 60
  @raylib.draw_rectangle(
    (@types.screen_width - tw) / 2 - 15,
    y - 5,
    tw + 30,
    40,
    @raylib.Color::new(0, 0, 0, 180),
  )
  @draw.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    y,
    28,
    @raylib.Color::new(255, 220, 100, 255),
  )
}

///|
fn draw_pause_overlay() -> Unit {
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
    @types.screen_height / 2 - 50,
    60,
    @raylib.white,
  )
  let hint = "Press P or ESC to resume"
  let hw = @draw.measure_text(hint, 20)
  @draw.draw_text(
    hint,
    (@types.screen_width - hw) / 2,
    @types.screen_height / 2 + 20,
    20,
    @raylib.Color::new(180, 180, 200, 255),
  )
}

///|
fn @types.Game::draw_battle_complete(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 20, 40, 200),
  )
  if game.current_battle >= game.total_battles - 1 {
    let title = "VICTORY!"
    let tw = @draw.measure_text(title, 60)
    @draw.draw_text(
      title,
      (@types.screen_width - tw) / 2,
      @types.screen_height / 2 - 80,
      60,
      @raylib.Color::new(255, 220, 100, 255),
    )
    let score_text = "Final Score: \{game.score}"
    let sw = @draw.measure_text(score_text, 28)
    @draw.draw_text(
      score_text,
      (@types.screen_width - sw) / 2,
      @types.screen_height / 2,
      28,
      @raylib.Color::new(200, 220, 255, 255),
    )
    let msg = "All 8 battles won! You are the Admiral!"
    let mw = @draw.measure_text(msg, 20)
    @draw.draw_text(
      msg,
      (@types.screen_width - mw) / 2,
      @types.screen_height / 2 + 40,
      20,
      @raylib.Color::new(150, 200, 150, 255),
    )
  } else {
    let title = "BATTLE COMPLETE!"
    let tw = @draw.measure_text(title, 48)
    @draw.draw_text(
      title,
      (@types.screen_width - tw) / 2,
      @types.screen_height / 2 - 60,
      48,
      @raylib.Color::new(100, 255, 100, 255),
    )
    let score_text = "Score: \{game.score}"
    let sw = @draw.measure_text(score_text, 24)
    @draw.draw_text(
      score_text,
      (@types.screen_width - sw) / 2,
      @types.screen_height / 2,
      24,
      @raylib.Color::new(200, 200, 200, 255),
    )
    let next_text = "Next: Battle \{game.current_battle + 2}"
    let nw = @draw.measure_text(next_text, 20)
    @draw.draw_text(
      next_text,
      (@types.screen_width - nw) / 2,
      @types.screen_height / 2 + 35,
      20,
      @raylib.Color::new(180, 200, 255, 255),
    )
  }
  let prompt = "Press ENTER to continue"
  let pw = @draw.measure_text(prompt, 18)
  @draw.draw_text(
    prompt,
    (@types.screen_width - pw) / 2,
    @types.screen_height / 2 + 80,
    18,
    @raylib.Color::new(180, 180, 200, 255),
  )
}

///|
fn @types.Game::draw_battle_select(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(10, 20, 45, 255),
  )
  let title = "SELECT BATTLE"
  let tw = @draw.measure_text(title, 44)
  @draw.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    40,
    44,
    @raylib.Color::new(220, 200, 140, 255),
  )
  for i in 0..<game.total_battles {
    let y = 110 + i * 48
    let name = @levels.get_battle_name(i)
    let diff = @levels.get_battle_difficulty(i)
    let mut stars = ""
    for _ in 0..<diff {
      stars = stars + "*"
    }
    let label = "\{i + 1}. \{name}  [\{stars}]"
    if game.battle_select_cursor == i {
      @raylib.draw_rectangle(
        60,
        y - 4,
        @types.screen_width - 120,
        40,
        @raylib.Color::new(50, 70, 110, 220),
      )
      @draw.draw_text(
        "> \{label}",
        80,
        y,
        24,
        @raylib.Color::new(255, 220, 100, 255),
      )
    } else {
      @draw.draw_text(
        "  \{label}",
        80,
        y,
        24,
        @raylib.Color::new(150, 160, 190, 255),
      )
    }
  }
  let hint = "ENTER: Start | ESC: Back"
  let hw = @draw.measure_text(hint, 18)
  @draw.draw_text(
    hint,
    (@types.screen_width - hw) / 2,
    @types.screen_height - 40,
    18,
    @raylib.Color::new(140, 150, 180, 255),
  )
}

///|
fn @types.Game::draw_game_over(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(40, 0, 0, 220),
  )
  let title = "SHIP SUNK!"
  let tw = @draw.measure_text(title, 60)
  @draw.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 80,
    60,
    @raylib.Color::new(255, 80, 60, 255),
  )
  let score_text = "Score: \{game.score} | Battle: \{game.current_battle + 1}"
  let sw = @draw.measure_text(score_text, 24)
  @draw.draw_text(
    score_text,
    (@types.screen_width - sw) / 2,
    @types.screen_height / 2 + 10,
    24,
    @raylib.Color::new(200, 200, 200, 255),
  )
  let prompt = "Press ENTER to return to menu"
  let pw = @draw.measure_text(prompt, 18)
  @draw.draw_text(
    prompt,
    (@types.screen_width - pw) / 2,
    @types.screen_height / 2 + 50,
    18,
    @raylib.Color::new(180, 180, 200, 255),
  )
}
