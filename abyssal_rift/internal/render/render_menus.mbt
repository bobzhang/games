///|
pub fn draw_title_screen(game : @types.Game) -> Unit {
  @raylib.clear_background(@types.color_bg)
  // Animated background particles
  let t = Float::from_int(game.frame_count) * 0.02
  for i in 0..<20 {
    let fi = Float::from_int(i)
    let x = (Float::from_double(@math.sin((t + fi * 0.7).to_double())) * 0.5 + 0.5) * Float::from_int(@types.screen_w)
    let y = (Float::from_double(@math.cos((t * 0.8 + fi * 1.1).to_double())) * 0.5 + 0.5) * Float::from_int(@types.screen_h)
    let alpha = 30 + ((Float::from_double(@math.sin((t + fi).to_double())) * 0.5 + 0.5) * 40.0).to_int()
    @raylib.draw_circle(x.to_int(), y.to_int(), 3.0 + fi * 0.3, @raylib.Color::new(80, 120, 200, alpha))
  }
  // Title
  let title = "ABYSSAL RIFT"
  let title_w = @raylib.measure_text(title, 60)
  @raylib.draw_text(title, (@types.screen_w - title_w) / 2, 200, 60, @raylib.Color::new(100, 200, 255, 255))
  // Subtitle
  let sub = "A Roguelite Dungeon Crawler"
  let sub_w = @raylib.measure_text(sub, 20)
  @raylib.draw_text(sub, (@types.screen_w - sub_w) / 2, 275, 20, @raylib.Color::new(150, 150, 170, 200))
  // Start prompt (blinking)
  if game.frame_count % 60 < 40 {
    let start = "Press ENTER to start"
    let start_w = @raylib.measure_text(start, 24)
    @raylib.draw_text(start, (@types.screen_w - start_w) / 2, 450, 24, @raylib.white)
  }
  // Controls
  let controls = "WASD: Move | Mouse: Aim | Click: Attack | Space: Dash | ESC: Pause"
  let ctrl_w = @raylib.measure_text(controls, 14)
  @raylib.draw_text(controls, (@types.screen_w - ctrl_w) / 2, @types.screen_h - 60, 14, @raylib.Color::new(120, 120, 140, 180))
}

///|
pub fn draw_pause_overlay(_game : @types.Game) -> Unit {
  @raylib.draw_rectangle(0, 0, @types.screen_w, @types.screen_h, @raylib.Color::new(0, 0, 0, 150))
  let text = "PAUSED"
  let tw = @raylib.measure_text(text, 48)
  @raylib.draw_text(text, (@types.screen_w - tw) / 2, @types.screen_h / 2 - 40, 48, @raylib.white)
  let sub = "Press ESC to resume"
  let sw = @raylib.measure_text(sub, 20)
  @raylib.draw_text(sub, (@types.screen_w - sw) / 2, @types.screen_h / 2 + 20, 20, @raylib.Color::new(180, 180, 180, 200))
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
  // Restart prompt
  if game.frame_count % 60 < 40 {
    let restart = "Press ENTER to restart"
    let rw = @raylib.measure_text(restart, 20)
    @raylib.draw_text(restart, (@types.screen_w - rw) / 2, 500, 20, @raylib.white)
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
  let fv = "8"
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
  // Restart prompt
  if game.frame_count % 60 < 40 {
    let restart = "Press ENTER to play again"
    let rw = @raylib.measure_text(restart, 20)
    @raylib.draw_text(restart, (@types.screen_w - rw) / 2, 530, 20, @raylib.white)
  }
}
