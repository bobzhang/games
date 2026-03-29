///|
pub fn draw_title_screen(game : @types.Game) -> Unit {
  @raylib.clear_background(@types.color_bg)
  let t = Float::from_int(game.frame_count) * 0.02
  let sw = Float::from_int(@types.screen_w)
  let sh = Float::from_int(@types.screen_h)
  // Slow drifting background layer (large dim particles)
  for i in 0..<10 {
    let fi = Float::from_int(i)
    let x = (Float::from_double(@math.sin((t * 0.3 + fi * 1.3).to_double())) * 0.5 + 0.5) * sw
    let y = (Float::from_double(@math.cos((t * 0.2 + fi * 0.9).to_double())) * 0.5 + 0.5) * sh
    let alpha = 12 + ((Float::from_double(@math.sin((t * 0.5 + fi * 0.7).to_double())) * 0.5 + 0.5) * 18.0).to_int()
    @raylib.draw_circle(x.to_int(), y.to_int(), 20.0 + fi * 3.0, @raylib.Color::new(40, 60, 120, alpha))
  }
  // Mid-layer animated particles
  for i in 0..<30 {
    let fi = Float::from_int(i)
    let x = (Float::from_double(@math.sin((t + fi * 0.7).to_double())) * 0.5 + 0.5) * sw
    let y = (Float::from_double(@math.cos((t * 0.8 + fi * 1.1).to_double())) * 0.5 + 0.5) * sh
    let alpha = 25 + ((Float::from_double(@math.sin((t + fi).to_double())) * 0.5 + 0.5) * 45.0).to_int()
    @raylib.draw_circle(x.to_int(), y.to_int(), 2.0 + fi * 0.25, @raylib.Color::new(80, 120, 200, alpha))
  }
  // Rising mote particles (small, moving upward)
  for i in 0..<15 {
    let fi = Float::from_int(i)
    let base_x = (fi / 15.0) * sw + Float::from_double(@math.sin((t * 0.4 + fi * 2.0).to_double())) * 30.0
    // Use modulo-style wrapping for vertical rise
    let rise_speed : Float = Float::from_double(0.6) + fi * Float::from_double(0.05)
    let base_y = sh - ((t * rise_speed * 60.0 + fi * 80.0) % (sh + 40.0)) + 20.0
    let alpha = 30 + ((Float::from_double(@math.sin((t * 1.5 + fi * 0.8).to_double())) * 0.5 + 0.5) * 35.0).to_int()
    @raylib.draw_circle(base_x.to_int(), base_y.to_int(), 1.5, @raylib.Color::new(100, 160, 255, alpha))
  }
  // Title with glow effect
  let title = "ABYSSAL RIFT"
  let title_w = @raylib.measure_text(title, 60)
  let title_x = (@types.screen_w - title_w) / 2
  let title_y = 200
  // Glow pulse
  let glow_pulse = Float::from_double(@math.sin((t * 1.5).to_double())) * 0.3 + 0.7
  let glow_alpha = (glow_pulse * 60.0).to_int()
  @raylib.draw_text(title, title_x - 2, title_y - 2, 60, @raylib.Color::new(60, 140, 220, glow_alpha))
  @raylib.draw_text(title, title_x + 2, title_y + 2, 60, @raylib.Color::new(60, 140, 220, glow_alpha))
  @raylib.draw_text(title, title_x, title_y, 60, @raylib.Color::new(100, 200, 255, 255))
  // Subtitle
  let sub = "A Roguelite Dungeon Crawler"
  let sub_w = @raylib.measure_text(sub, 20)
  @raylib.draw_text(sub, (@types.screen_w - sub_w) / 2, 275, 20, @raylib.Color::new(150, 150, 170, 200))
  // Weapon display rotation
  let weapons = ["Sword", "Daggers", "Bow", "Staff"]
  let weapon_idx = (game.frame_count / 120) % 4
  let weapon_name = weapons[weapon_idx]
  let weapon_alpha_t = Float::from_int(game.frame_count % 120) / 120.0
  // Fade in for first half, fade out for second half
  let weapon_alpha = if weapon_alpha_t < 0.15 {
    (weapon_alpha_t / 0.15 * 180.0).to_int()
  } else if weapon_alpha_t > 0.85 {
    ((1.0 - weapon_alpha_t.to_double()) / 0.15 * 180.0).to_int()
  } else {
    180
  }
  let wn_w = @raylib.measure_text(weapon_name, 18)
  @raylib.draw_text(weapon_name, (@types.screen_w - wn_w) / 2, 340, 18, @raylib.Color::new(160, 180, 220, @types.clampi(weapon_alpha, 0, 255)))
  // Decorative line under weapon
  let line_cx = @types.screen_w / 2
  let line_half = 40 + ((Float::from_double(@math.sin((t * 0.8).to_double())) * 0.5 + 0.5) * 20.0).to_int()
  @raylib.draw_line(line_cx - line_half, 365, line_cx + line_half, 365, @raylib.Color::new(80, 120, 180, 60))
  // Start prompt (smooth pulse instead of hard blink)
  let prompt_pulse = Float::from_double(@math.sin((t * 2.0).to_double())) * 0.35 + 0.65
  let prompt_alpha = (prompt_pulse * 255.0).to_int()
  let start = "Press ENTER to start"
  let start_w = @raylib.measure_text(start, 24)
  @raylib.draw_text(start, (@types.screen_w - start_w) / 2, 450, 24, @raylib.Color::new(255, 255, 255, @types.clampi(prompt_alpha, 0, 255)))
  // Controls
  let controls = "WASD: Move | Mouse: Aim | Click: Attack | Space: Dash | ESC: Pause"
  let ctrl_w = @raylib.measure_text(controls, 14)
  @raylib.draw_text(controls, (@types.screen_w - ctrl_w) / 2, @types.screen_h - 60, 14, @raylib.Color::new(120, 120, 140, 180))
}

///|
pub fn draw_pause_overlay(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(0, 0, @types.screen_w, @types.screen_h, @raylib.Color::new(0, 0, 0, 150))
  let cx = @types.screen_w / 2
  let text = "PAUSED"
  let tw = @raylib.measure_text(text, 48)
  @raylib.draw_text(text, (cx - tw / 2), @types.screen_h / 2 - 80, 48, @raylib.white)
  let sub = "Press ESC to resume"
  let sw = @raylib.measure_text(sub, 20)
  @raylib.draw_text(sub, (cx - sw / 2), @types.screen_h / 2 - 30, 20, @raylib.Color::new(180, 180, 180, 200))
  // Divider
  @raylib.draw_line(cx - 140, @types.screen_h / 2, cx + 140, @types.screen_h / 2, @raylib.Color::new(100, 100, 120, 80))
  // Run stats
  let stat_color = @raylib.Color::new(180, 190, 210, 200)
  let stats_y = @types.screen_h / 2 + 20
  let stats_text = "Floor: \{game.floor_num}  |  Gold: \{game.player.gold}  |  Slain: \{game.enemies_killed}  |  Rooms: \{game.rooms_cleared}"
  let stw = @raylib.measure_text(stats_text, 18)
  @raylib.draw_text(stats_text, (cx - stw / 2), stats_y, 18, stat_color)
  // Weapon info
  let weapon_stats = @data.get_weapon_stats(game.player.weapon)
  let weapon_text = "Weapon: \{weapon_stats.name}"
  let wtw = @raylib.measure_text(weapon_text, 16)
  @raylib.draw_text(weapon_text, (cx - wtw / 2), stats_y + 30, 16, @raylib.Color::new(160, 200, 255, 180))
  // Passive count
  let num_passives = game.player.passives.length()
  let passive_text = "Items: \{num_passives}"
  let ptw = @raylib.measure_text(passive_text, 16)
  @raylib.draw_text(passive_text, (cx - ptw / 2), stats_y + 55, 16, @raylib.Color::new(200, 140, 255, 180))
  // Controls reminder
  let controls_y = @types.screen_h / 2 + 110
  @raylib.draw_line(cx - 140, controls_y - 10, cx + 140, controls_y - 10, @raylib.Color::new(100, 100, 120, 50))
  let ctrl_color = @raylib.Color::new(120, 120, 140, 160)
  let c1 = "WASD: Move  |  Mouse: Aim  |  Click: Attack"
  let c1w = @raylib.measure_text(c1, 14)
  @raylib.draw_text(c1, (cx - c1w / 2), controls_y, 14, ctrl_color)
  let c2 = "Space: Dash  |  ESC: Resume"
  let c2w = @raylib.measure_text(c2, 14)
  @raylib.draw_text(c2, (cx - c2w / 2), controls_y + 22, 14, ctrl_color)
}

///|
pub fn draw_game_over(game : @types.Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(30, 10, 10, 255))
  // Background particles
  let t = Float::from_int(game.frame_count) * 0.015
  for i in 0..<15 {
    let fi = Float::from_int(i)
    let x = (Float::from_double(@math.sin((t + fi * 0.9).to_double())) * 0.5 + 0.5) *
      Float::from_int(@types.screen_w)
    let y = (Float::from_double(@math.cos((t * 0.7 + fi * 1.3).to_double())) * 0.5 + 0.5) *
      Float::from_int(@types.screen_h)
    let alpha = 15 +
      ((Float::from_double(@math.sin((t + fi).to_double())) * 0.5 + 0.5) * 25.0).to_int()
    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      2.0 + fi * 0.2,
      @raylib.Color::new(200, 40, 40, alpha),
    )
  }
  let text = "GAME OVER"
  let tw = @raylib.measure_text(text, 56)
  @raylib.draw_text(
    text,
    (@types.screen_w - tw) / 2,
    160,
    56,
    @raylib.Color::new(220, 50, 50, 255),
  )
  // Divider line
  let cx = @types.screen_w / 2
  @raylib.draw_line(cx - 120, 230, cx + 120, 230, @raylib.Color::new(150, 40, 40, 120))
  // Stats
  let p = game.player
  let stat_x = cx - 100
  let mut sy = 260
  let stat_color = @raylib.Color::new(200, 200, 200, 220)
  let val_color = @raylib.Color::new(255, 255, 255, 255)
  // Floor reached
  @raylib.draw_text("Floor Reached:", stat_x, sy, 20, stat_color)
  let fv = "\{game.floor_num}"
  let fvw = @raylib.measure_text(fv, 20)
  @raylib.draw_text(fv, cx + 100 - fvw, sy, 20, val_color)
  sy += 32
  // Enemies killed
  @raylib.draw_text("Enemies Slain:", stat_x, sy, 20, stat_color)
  let ev = "\{game.enemies_killed}"
  let evw = @raylib.measure_text(ev, 20)
  @raylib.draw_text(ev, cx + 100 - evw, sy, 20, val_color)
  sy += 32
  // Rooms cleared
  @raylib.draw_text("Rooms Cleared:", stat_x, sy, 20, stat_color)
  let rv = "\{game.rooms_cleared}"
  let rvw = @raylib.measure_text(rv, 20)
  @raylib.draw_text(rv, cx + 100 - rvw, sy, 20, val_color)
  sy += 32
  // Gold collected
  @raylib.draw_text("Gold Collected:", stat_x, sy, 20, stat_color)
  let gv = "\{p.gold}"
  let gvw = @raylib.measure_text(gv, 20)
  @raylib.draw_text(gv, cx + 100 - gvw, sy, 20, @types.color_gold_text)
  sy += 32
  // Passives collected
  let num_passives = p.passives.length()
  @raylib.draw_text("Items Found:", stat_x, sy, 20, stat_color)
  let pv = "\{num_passives}"
  let pvw = @raylib.measure_text(pv, 20)
  @raylib.draw_text(pv, cx + 100 - pvw, sy, 20, @raylib.Color::new(200, 100, 255, 255))
  sy += 40
  // Tokens to be earned
  let tokens = game.floor_num * 3 + game.enemies_killed / 5 +
    (if game.floor_num >= 5 { 10 } else { 0 }) +
    (if game.floor_num >= 10 { 20 } else { 0 }) + game.rooms_cleared * 2
  let token_text = "+\{tokens} Abyss Tokens"
  let token_tw = @raylib.measure_text(token_text, 22)
  @raylib.draw_text(
    token_text,
    (cx - token_tw / 2),
    sy,
    22,
    @raylib.Color::new(255, 215, 0, 255),
  )
  // Restart prompt
  if game.frame_count % 60 < 40 {
    let restart = "Press ENTER to continue"
    let rw = @raylib.measure_text(restart, 20)
    @raylib.draw_text(restart, (@types.screen_w - rw) / 2, 520, 20, @raylib.white)
  }
}

///|
pub fn draw_victory_screen(game : @types.Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(10, 15, 30, 255))
  // Animated gold particles
  let t = Float::from_int(game.frame_count) * 0.02
  for i in 0..<25 {
    let fi = Float::from_int(i)
    let x = (Float::from_double(@math.sin((t + fi * 0.5).to_double())) * 0.5 + 0.5) *
      Float::from_int(@types.screen_w)
    let y = (Float::from_double(@math.cos((t * 0.6 + fi * 0.8).to_double())) * 0.5 + 0.5) *
      Float::from_int(@types.screen_h)
    let alpha = 20 +
      ((Float::from_double(@math.sin((t * 2.0 + fi).to_double())) * 0.5 + 0.5) * 40.0).to_int()
    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      2.0 + fi * 0.3,
      @raylib.Color::new(255, 215, 0, alpha),
    )
  }
  // Title
  let text = "VICTORY!"
  let tw = @raylib.measure_text(text, 60)
  @raylib.draw_text(
    text,
    (@types.screen_w - tw) / 2,
    120,
    60,
    @raylib.Color::new(255, 215, 0, 255),
  )
  // Subtitle
  let sub = "The Abyss has been conquered"
  let sw = @raylib.measure_text(sub, 22)
  @raylib.draw_text(
    sub,
    (@types.screen_w - sw) / 2,
    190,
    22,
    @raylib.Color::new(180, 200, 255, 200),
  )
  // Divider
  let cx = @types.screen_w / 2
  @raylib.draw_line(
    cx - 140,
    225,
    cx + 140,
    225,
    @raylib.Color::new(255, 215, 0, 80),
  )
  // Stats
  let p = game.player
  let stat_x = cx - 110
  let mut sy = 255
  let stat_color = @raylib.Color::new(180, 200, 220, 220)
  let val_color = @raylib.Color::new(255, 255, 255, 255)
  // Floors cleared
  @raylib.draw_text("Floors Cleared:", stat_x, sy, 20, stat_color)
  let fv = "10"
  let fvw = @raylib.measure_text(fv, 20)
  @raylib.draw_text(fv, cx + 110 - fvw, sy, 20, val_color)
  sy += 32
  // Enemies killed
  @raylib.draw_text("Enemies Slain:", stat_x, sy, 20, stat_color)
  let ev = "\{game.enemies_killed}"
  let evw = @raylib.measure_text(ev, 20)
  @raylib.draw_text(ev, cx + 110 - evw, sy, 20, val_color)
  sy += 32
  // Rooms cleared
  @raylib.draw_text("Rooms Cleared:", stat_x, sy, 20, stat_color)
  let rv = "\{game.rooms_cleared}"
  let rvw = @raylib.measure_text(rv, 20)
  @raylib.draw_text(rv, cx + 110 - rvw, sy, 20, val_color)
  sy += 32
  // Gold
  @raylib.draw_text("Gold Collected:", stat_x, sy, 20, stat_color)
  let gv = "\{p.gold}"
  let gvw = @raylib.measure_text(gv, 20)
  @raylib.draw_text(gv, cx + 110 - gvw, sy, 20, @types.color_gold_text)
  sy += 32
  // Passives
  let num_passives = p.passives.length()
  @raylib.draw_text("Items Found:", stat_x, sy, 20, stat_color)
  let pv = "\{num_passives}"
  let pvw = @raylib.measure_text(pv, 20)
  @raylib.draw_text(pv, cx + 110 - pvw, sy, 20, @raylib.Color::new(200, 100, 255, 255))
  sy += 32
  // Final weapon
  let weapon_stats = @data.get_weapon_stats(p.weapon)
  @raylib.draw_text("Final Weapon:", stat_x, sy, 20, stat_color)
  let wvw = @raylib.measure_text(weapon_stats.name, 20)
  @raylib.draw_text(
    weapon_stats.name,
    cx + 110 - wvw,
    sy,
    20,
    @raylib.Color::new(200, 230, 255, 255),
  )
  sy += 40
  // Tokens to be earned
  let tokens = game.floor_num * 3 + game.enemies_killed / 5 +
    (if game.floor_num >= 5 { 10 } else { 0 }) +
    (if game.floor_num >= 10 { 20 } else { 0 }) + game.rooms_cleared * 2
  let token_text = "+\{tokens} Abyss Tokens"
  let token_tw = @raylib.measure_text(token_text, 22)
  @raylib.draw_text(
    token_text,
    (cx - token_tw / 2),
    sy,
    22,
    @raylib.Color::new(255, 215, 0, 255),
  )
  // Restart prompt
  if game.frame_count % 60 < 40 {
    let restart = "Press ENTER to continue"
    let rw = @raylib.measure_text(restart, 20)
    @raylib.draw_text(restart, (@types.screen_w - rw) / 2, 550, 20, @raylib.white)
  }
}

///|
pub fn draw_meta_screen(game : @types.Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(15, 12, 20, 255))
  let meta = game.meta
  // Background ambient particles
  let t = Float::from_int(game.frame_count) * 0.015
  let sw = Float::from_int(@types.screen_w)
  let sh = Float::from_int(@types.screen_h)
  for i in 0..<20 {
    let fi = Float::from_int(i)
    let x = (Float::from_double(@math.sin((t * 0.4 + fi * 0.8).to_double())) * 0.5 + 0.5) * sw
    let y = (Float::from_double(@math.cos((t * 0.3 + fi * 1.1).to_double())) * 0.5 + 0.5) * sh
    let alpha = 15 +
      ((Float::from_double(@math.sin((t + fi * 0.6).to_double())) * 0.5 + 0.5) * 25.0).to_int()
    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      2.0 + fi * 0.2,
      @raylib.Color::new(120, 80, 200, alpha),
    )
  }
  // Title
  let title = "ABYSS SANCTUM"
  let tw = @raylib.measure_text(title, 40)
  @raylib.draw_text(
    title,
    (@types.screen_w - tw) / 2,
    40,
    40,
    @raylib.Color::new(180, 140, 255, 255),
  )
  // Tokens
  let tokens_text = "Abyss Tokens: \{meta.abyss_tokens}"
  let ttw = @raylib.measure_text(tokens_text, 24)
  @raylib.draw_text(
    tokens_text,
    (@types.screen_w - ttw) / 2,
    95,
    24,
    @raylib.Color::new(255, 215, 0, 255),
  )
  // Divider
  let cx = @types.screen_w / 2
  @raylib.draw_line(
    cx - 200,
    125,
    cx + 200,
    125,
    @raylib.Color::new(120, 80, 200, 80),
  )
  // Upgrades list
  let names = [
    "1. Starting HP Up",
    "2. Starting Shield Up",
    "3. Starting Gold",
    "4. Weapon Mastery",
    "5. Dash Mastery",
    "6. Potion Efficiency",
  ]
  let descs = [
    "Max HP +10 per level",
    "Max Shield +10 per level",
    "Start with +15 gold per level",
    "All damage +5% per level",
    "Dash cooldown -10% per level",
    "Potion heal +10 per level",
  ]
  let base_costs = [10, 10, 8, 15, 12, 10]
  let max_levels = [3, 3, 3, 5, 3, 3]
  for i in 0..<6 {
    let level = meta.upgrades[i]
    let cost = base_costs[i] * (level + 1)
    let y = 150 + i * 55
    let maxed = level >= max_levels[i]
    let can_afford = meta.abyss_tokens >= cost && not(maxed)
    let color = if maxed {
      @raylib.Color::new(100, 200, 100, 255)
    } else if can_afford {
      @raylib.white
    } else {
      @raylib.Color::new(120, 120, 120, 180)
    }
    @raylib.draw_text(names[i], 200, y, 20, color)
    let level_text = if maxed {
      "MAX"
    } else {
      "Lv.\{level}/\{max_levels[i]}  Cost: \{cost}"
    }
    @raylib.draw_text(level_text, 550, y, 16, color)
    @raylib.draw_text(
      descs[i],
      550,
      y + 20,
      14,
      @raylib.Color::new(160, 160, 180, 180),
    )
  }
  // Stats
  let stats_text = "Total Runs: \{meta.total_runs}  Best Floor: \{meta.best_floor}  Total Kills: \{meta.total_kills}"
  @raylib.draw_text(
    stats_text,
    200,
    500,
    16,
    @raylib.Color::new(140, 140, 160, 180),
  )
  // Prompt
  if game.frame_count % 60 < 40 {
    let prompt = "Press 1-6 to buy upgrades | ENTER to start run"
    let pw = @raylib.measure_text(prompt, 20)
    @raylib.draw_text(
      prompt,
      (@types.screen_w - pw) / 2,
      560,
      20,
      @raylib.Color::new(200, 200, 220, 220),
    )
  }
}
