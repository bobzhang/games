///|
/// Draw the full game frame.
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.clear_background(@types.color_bg)
  match game.screen {
    Title => draw_title(game)
    Playing => draw_playing(game)
    BeatFail => draw_playing(game)
    LevelComplete => draw_level_complete(game)
    GameOver => draw_game_over(game)
    FloorSelect => draw_floor_select(game)
  }
}

///|
fn draw_title(game : @types.Game) -> Unit {
  let cx = @types.screen_w / 2
  let pulse = @math.sinf(game.anim_timer * 2.0F) * 0.3F + 0.7F
  let alpha = (pulse * 255.0F).to_int()
  let title_color = @raylib.Color::new(80, 200, 255, alpha)
  draw_centered("RHYTHM TACTICS", cx, 180, 48, title_color)
  draw_centered(
    "Crypt of the NecroDancer meets Chess",
    cx,
    250,
    20,
    @raylib.Color::new(180, 180, 200, 200),
  )
  let blink = if game.frame_count / 30 % 2 == 0 { 255 } else { 120 }
  draw_centered(
    "Press ENTER to Start",
    cx,
    400,
    24,
    @raylib.Color::new(255, 255, 255, blink),
  )
  draw_centered(
    "Move with Arrow Keys / WASD",
    cx,
    470,
    18,
    @raylib.Color::new(150, 150, 170, 200),
  )
  draw_centered(
    "Stay on the beat to build combos!",
    cx,
    500,
    18,
    @raylib.Color::new(150, 150, 170, 200),
  )
  draw_centered(
    "Miss the beat = lose your turn!",
    cx,
    530,
    18,
    @raylib.Color::new(200, 100, 100, 200),
  )
}

///|
fn draw_playing(game : @types.Game) -> Unit {
  guard game.floor is Some(floor) else { return }
  let beat = game.beat
  let pulse = @beat.beat_pulse(beat)
  // Draw grid
  draw_grid(floor, pulse)
  // Draw enemies
  draw_enemies(floor, beat)
  // Draw player
  draw_player(game, pulse)
  // Draw beat indicator
  draw_beat_indicator(beat)
  // Draw HUD
  draw_hud(game)
  // Draw combo
  draw_combo(beat)
  // Draw message
  if game.message_timer > 0.0F {
    let alpha = @types.clampf(game.message_timer / 0.5F, 0.0F, 1.0F)
    let a = (alpha * 255.0F).to_int()
    let color = @types.rating_color(beat.last_rating)
    let msg_color = @raylib.Color::new(
      color.r.to_int(),
      color.g.to_int(),
      color.b.to_int(),
      a,
    )
    draw_centered(game.message_text, @types.screen_w / 2, 30, 24, msg_color)
  }
  // Beat fail overlay
  if game.screen == BeatFail {
    @raylib.draw_rectangle(
      0,
      0,
      @types.screen_w,
      @types.screen_h,
      @raylib.Color::new(200, 0, 0, 60),
    )
  }
}

///|
fn draw_grid(floor : @types.Floor, pulse : Float) -> Unit {
  let grid = floor.grid
  let ts = @types.tile_size
  for y in 0..<grid.height {
    for x in 0..<grid.width {
      let idx = @types.grid_index(x, y, grid.width)
      let tile = grid.tiles[idx]
      let sx = @types.tile_screen_x(x)
      let sy = @types.tile_screen_y(y)
      // Base tile color with beat pulse
      let base_color = @types.tile_color(tile.kind)
      let pulse_boost = (pulse * 20.0F).to_int()
      let r = @types.clampi(base_color.r.to_int() + pulse_boost, 0, 255)
      let g = @types.clampi(base_color.g.to_int() + pulse_boost, 0, 255)
      let b = @types.clampi(base_color.b.to_int() + pulse_boost, 0, 255)
      let color = @raylib.Color::new(r, g, b, 255)
      @raylib.draw_rectangle(sx, sy, ts, ts, color)
      // Grid lines
      @raylib.draw_rectangle_lines(sx, sy, ts, ts, @types.color_grid_line)
      // Exit marker
      if x == floor.exit_x && y == floor.exit_y {
        let exit_pulse = @math.sinf(game_time() * 3.0F) * 0.3F + 0.7F
        let ea = (exit_pulse * 255.0F).to_int()
        let exit_color = @raylib.Color::new(0, 255, 130, ea)
        @raylib.draw_rectangle(sx + 4, sy + 4, ts - 8, ts - 8, exit_color)
        draw_centered_at(
          "EXIT",
          sx + ts / 2,
          sy + ts / 2 - 5,
          10,
          @raylib.white,
        )
      }
      // Item marker
      if tile.has_item {
        let gem_size = 8
        let gem_x = sx + ts / 2 - gem_size / 2
        let gem_y = sy + ts / 2 - gem_size / 2
        @raylib.draw_rectangle(
          gem_x,
          gem_y,
          gem_size,
          gem_size,
          @types.color_gold,
        )
      }
    }
  }
}

///|
fn draw_enemies(floor : @types.Floor, beat : @types.BeatState) -> Unit {
  let ts = @types.tile_size
  for enemy in floor.enemies {
    if !(enemy.active) {
      continue
    }
    let sx = @types.tile_screen_x(enemy.x)
    let sy = @types.tile_screen_y(enemy.y)
    let base = @types.enemy_color(enemy.kind)
    // Pulse enemies that will act next beat
    let acts = @beat.enemy_acts_this_beat(enemy)
    let color = if acts {
      let p = @beat.beat_pulse(beat)
      let boost = (p * 80.0F).to_int()
      @raylib.Color::new(
        @types.clampi(base.r.to_int() + boost, 0, 255),
        @types.clampi(base.g.to_int() + boost, 0, 255),
        @types.clampi(base.b.to_int() + boost, 0, 255),
        255,
      )
    } else {
      @raylib.Color::new(
        base.r.to_int(),
        base.g.to_int(),
        base.b.to_int(),
        160,
      )
    }
    // Enemy body
    let margin = 6
    @raylib.draw_rectangle(
      sx + margin,
      sy + margin,
      ts - margin * 2,
      ts - margin * 2,
      color,
    )
    // HP bar
    if enemy.hp < enemy.max_hp {
      let bar_w = ts - 8
      let hp_frac = Float::from_int(enemy.hp) /
        Float::from_int(enemy.max_hp)
      let filled = (Float::from_int(bar_w) * hp_frac).to_int()
      @raylib.draw_rectangle(sx + 4, sy + 2, bar_w, 3, @raylib.darkgray)
      @raylib.draw_rectangle(sx + 4, sy + 2, filled, 3, @raylib.red)
    }
    // Intent arrow
    draw_enemy_intent(enemy, sx, sy, ts)
  }
}

///|
fn draw_enemy_intent(
  enemy : @types.Enemy,
  sx : Int,
  sy : Int,
  ts : Int,
) -> Unit {
  let cx = sx + ts / 2
  let cy = sy + ts / 2
  let intent_color = @raylib.Color::new(255, 255, 0, 180)
  match enemy.intent {
    Move(dir) => {
      let dx = @types.dir_dx(dir)
      let dy = @types.dir_dy(dir)
      let ax = cx + dx * (ts / 3)
      let ay = cy + dy * (ts / 3)
      @raylib.draw_line(cx, cy, ax, ay, intent_color)
    }
    Attack(dir, _) => {
      let dx = @types.dir_dx(dir)
      let dy = @types.dir_dy(dir)
      let ax = cx + dx * (ts / 3)
      let ay = cy + dy * (ts / 3)
      let atk_color = @raylib.Color::new(255, 60, 60, 200)
      @raylib.draw_line(cx, cy, ax, ay, atk_color)
      @raylib.draw_circle(ax, ay, 3.0, atk_color)
    }
    Charge(dir, _) => {
      let dx = @types.dir_dx(dir)
      let dy = @types.dir_dy(dir)
      let ax = cx + dx * (ts / 2)
      let ay = cy + dy * (ts / 2)
      let charge_color = @raylib.Color::new(255, 140, 0, 200)
      @raylib.draw_line(cx, cy, ax, ay, charge_color)
      @raylib.draw_circle(ax, ay, 4.0, charge_color)
    }
    Summon(_, _, _) => {
      let summon_color = @raylib.Color::new(200, 100, 255, 180)
      @raylib.draw_circle(cx, cy, 6.0, summon_color)
    }
    Wait => ()
  }
}

///|
fn draw_player(game : @types.Game, pulse : Float) -> Unit {
  let ts = @types.tile_size
  let sx = @types.tile_screen_x(game.player.x)
  let sy = @types.tile_screen_y(game.player.y)
  // Player body with beat pulse
  let boost = (pulse * 60.0F).to_int()
  let r = @types.clampi(
    @types.color_player.r.to_int() + boost,
    0,
    255,
  )
  let g = @types.clampi(
    @types.color_player.g.to_int() + boost,
    0,
    255,
  )
  let b = @types.clampi(
    @types.color_player.b.to_int() + boost,
    0,
    255,
  )
  let color = @raylib.Color::new(r, g, b, 255)
  let margin = 4
  @raylib.draw_rectangle(
    sx + margin,
    sy + margin,
    ts - margin * 2,
    ts - margin * 2,
    color,
  )
  // Weapon indicator (small square in center)
  let weapon_size = 6
  let wcx = sx + ts / 2 - weapon_size / 2
  let wcy = sy + ts / 2 - weapon_size / 2
  @raylib.draw_rectangle(wcx, wcy, weapon_size, weapon_size, @raylib.white)
  // Shield indicator
  if game.player.shield > 0 {
    @raylib.draw_rectangle_lines(
      sx + 2,
      sy + 2,
      ts - 4,
      ts - 4,
      @raylib.Color::new(100, 200, 255, 180),
    )
  }
}

///|
fn draw_beat_indicator(beat : @types.BeatState) -> Unit {
  let y = @types.beat_indicator_y
  let h = @types.beat_indicator_h
  let w = @types.screen_w
  // Background bar
  @raylib.draw_rectangle(0, y, w, h, @types.color_hud_bg)
  // Beat markers (4 markers evenly spaced)
  let marker_count = 4
  let spacing = w / marker_count
  for i in 0..<marker_count {
    let mx = i * spacing + spacing / 2
    @raylib.draw_rectangle(
      mx - 2,
      y + 4,
      4,
      h - 8,
      @raylib.Color::new(60, 60, 80, 255),
    )
  }
  // Moving indicator
  let phase = @beat.beat_phase(beat)
  let indicator_x = (phase * Float::from_int(spacing)).to_int()
  let indicator_color = if beat.in_window {
    @types.color_perfect
  } else {
    @raylib.Color::new(200, 200, 220, 255)
  }
  @raylib.draw_rectangle(indicator_x - 3, y + 2, 6, h - 4, indicator_color)
  // Window zone visualization
  if beat.in_window {
    @raylib.draw_rectangle(0, y, w, h, @raylib.Color::new(255, 215, 0, 30))
  }
  // BPM display
  let bpm_text = "\{beat.bpm.to_int()} BPM"
  @draw.draw_text(
    bpm_text,
    10,
    y + h / 2 - 8,
    16,
    @raylib.Color::new(150, 150, 170, 200),
  )
}

///|
fn draw_combo(beat : @types.BeatState) -> Unit {
  if beat.combo > 0 {
    let combo_text = "COMBO: \{beat.combo}x"
    let mult = @beat.combo_multiplier(beat)
    let mult_i = (mult * 10.0F).to_int()
    let mult_text = "DMG x\{mult_i / 10}.\{mult_i % 10}"
    let x = @types.screen_w - 180
    let y = 70
    // Combo box
    @raylib.draw_rectangle(x - 5, y - 5, 170, 50, @types.color_hud_bg)
    let combo_color = if beat.combo >= 10 {
      @types.color_perfect
    } else if beat.combo >= 5 {
      @types.color_good
    } else {
      @raylib.white
    }
    @draw.draw_text(combo_text, x, y, 22, combo_color)
    @draw.draw_text(
      mult_text,
      x,
      y + 24,
      16,
      @raylib.Color::new(180, 180, 200, 200),
    )
  }
}

///|
fn draw_hud(game : @types.Game) -> Unit {
  // Left panel - player stats
  let px = 10
  let py = 70
  let panel_w = 210
  let panel_h = 260
  @raylib.draw_rectangle(px, py, panel_w, panel_h, @types.color_hud_bg)
  // HP
  let hp_text = "HP: \{game.player.hp}/\{game.player.max_hp}"
  @draw.draw_text(
    hp_text,
    px + 10,
    py + 10,
    20,
    @raylib.Color::new(255, 100, 100, 255),
  )
  // HP bar
  let bar_w = panel_w - 20
  let hp_frac = Float::from_int(game.player.hp) /
    Float::from_int(game.player.max_hp)
  let filled = (Float::from_int(bar_w) * hp_frac).to_int()
  @raylib.draw_rectangle(px + 10, py + 35, bar_w, 8, @raylib.darkgray)
  let hp_color = if hp_frac > 0.5F {
    @raylib.Color::new(80, 220, 80, 255)
  } else if hp_frac > 0.25F {
    @raylib.Color::new(220, 180, 40, 255)
  } else {
    @raylib.Color::new(220, 40, 40, 255)
  }
  @raylib.draw_rectangle(px + 10, py + 35, filled, 8, hp_color)
  // Gold
  @draw.draw_text(
    "Gold: \{game.player.gold}",
    px + 10,
    py + 55,
    18,
    @types.color_gold,
  )
  // Score
  @draw.draw_text(
    "Score: \{game.score}",
    px + 10,
    py + 80,
    18,
    @raylib.white,
  )
  // Floor
  let floor_text = "Floor: \{game.floors_cleared + 1}/\{@types.max_floor}"
  @draw.draw_text(
    floor_text,
    px + 10,
    py + 105,
    18,
    @raylib.Color::new(180, 180, 200, 255),
  )
  // Weapon
  @draw.draw_text(
    "Weapon: \{game.player.weapon_damage} dmg",
    px + 10,
    py + 130,
    16,
    @raylib.Color::new(160, 160, 180, 255),
  )
  // Shield
  @draw.draw_text(
    "Shield: \{game.player.shield}",
    px + 10,
    py + 155,
    16,
    @raylib.Color::new(100, 200, 255, 255),
  )
  // Special charges
  @draw.draw_text(
    "Special: \{game.player.special_charges}",
    px + 10,
    py + 180,
    16,
    @raylib.Color::new(200, 150, 255, 255),
  )
  // Beat rating display
  let rating_text = @types.rating_text(game.beat.last_rating)
  let rating_color = @types.rating_color(game.beat.last_rating)
  @draw.draw_text(rating_text, px + 10, py + 215, 22, rating_color)
  // Max combo
  @draw.draw_text(
    "Best Combo: \{game.beat.max_combo}",
    px + 10,
    py + 240,
    14,
    @raylib.Color::new(140, 140, 160, 200),
  )
}

///|
fn draw_level_complete(game : @types.Game) -> Unit {
  draw_playing(game)
  // Overlay
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(0, 0, 0, 150),
  )
  let cx = @types.screen_w / 2
  draw_centered("FLOOR CLEARED!", cx, 240, 42, @types.color_perfect)
  draw_centered("Score: \{game.score}", cx, 310, 24, @raylib.white)
  draw_centered(
    "Max Combo: \{game.beat.max_combo}",
    cx,
    350,
    20,
    @types.color_good,
  )
  let blink = if game.frame_count / 30 % 2 == 0 { 255 } else { 120 }
  draw_centered(
    "Press ENTER to continue",
    cx,
    430,
    22,
    @raylib.Color::new(255, 255, 255, blink),
  )
}

///|
fn draw_game_over(game : @types.Game) -> Unit {
  let cx = @types.screen_w / 2
  draw_centered("GAME OVER", cx, 200, 48, @types.color_miss)
  draw_centered("Final Score: \{game.score}", cx, 290, 28, @raylib.white)
  draw_centered(
    "Floors Cleared: \{game.floors_cleared}",
    cx,
    340,
    22,
    @raylib.Color::new(180, 180, 200, 255),
  )
  draw_centered(
    "Best Combo: \{game.beat.max_combo}",
    cx,
    380,
    20,
    @types.color_good,
  )
  if game.message_timer > 0.0F {
    draw_centered(game.message_text, cx, 430, 20, @types.color_perfect)
  }
  let blink = if game.frame_count / 30 % 2 == 0 { 255 } else { 120 }
  draw_centered(
    "Press ENTER to restart",
    cx,
    500,
    22,
    @raylib.Color::new(255, 255, 255, blink),
  )
}

///|
fn draw_floor_select(game : @types.Game) -> Unit {
  let cx = @types.screen_w / 2
  let floor_num = game.floors_cleared + 1
  draw_centered("FLOOR SELECT", cx, 200, 36, @types.color_good)
  draw_centered("Entering Floor \{floor_num}", cx, 280, 28, @raylib.white)
  // Show floor difficulty info
  let kinds = @content.floor_enemy_kinds(floor_num)
  let enemy_count = @content.floor_enemy_count(floor_num)
  draw_centered(
    "Enemies: \{enemy_count}",
    cx,
    340,
    20,
    @raylib.Color::new(200, 100, 100, 255),
  )
  let mut kind_str = "Types: "
  for i, kind in kinds {
    if i > 0 {
      kind_str = kind_str + ", "
    }
    kind_str = kind_str + kind.to_string()
  }
  draw_centered(
    kind_str,
    cx,
    370,
    16,
    @raylib.Color::new(180, 180, 200, 200),
  )
  let blink = if game.frame_count / 30 % 2 == 0 { 255 } else { 120 }
  draw_centered(
    "Press ENTER to begin",
    cx,
    450,
    22,
    @raylib.Color::new(255, 255, 255, blink),
  )
}

///|
fn draw_centered(
  text : String,
  cx : Int,
  y : Int,
  size : Int,
  color : @raylib.Color,
) -> Unit {
  let w = @draw.measure_text(text, size)
  @draw.draw_text(text, cx - w / 2, y, size, color)
}

///|
fn draw_centered_at(
  text : String,
  cx : Int,
  cy : Int,
  size : Int,
  color : @raylib.Color,
) -> Unit {
  let w = @draw.measure_text(text, size)
  @draw.draw_text(text, cx - w / 2, cy - size / 2, size, color)
}

///|
/// Accumulated game time via frame time.
fn game_time() -> Float {
  @raylib.get_frame_time()
}
