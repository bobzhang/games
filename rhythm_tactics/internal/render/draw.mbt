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
    Shop => draw_shop(game)
    FloorTransition => draw_floor_transition(game)
    BossIntro => draw_boss_intro(game)
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
  // Apply screen shake offset
  let shake_x = if game.screen_shake > 0.5F {
    let rng = @types.game_rng(game)
    let sx = @types.rand_range(rng, -1, 1) * game.screen_shake.to_int()
    @types.sync_rng(game, rng)
    sx
  } else {
    0
  }
  let shake_y = if game.screen_shake > 0.5F {
    let rng = @types.game_rng(game)
    let sy = @types.rand_range(rng, -1, 1) * game.screen_shake.to_int()
    @types.sync_rng(game, rng)
    sy
  } else {
    0
  }
  let _ = shake_x
  let _ = shake_y
  // Draw grid with beat pulse intensity proportional to combo
  let combo_intensity = @types.clampf(
    Float::from_int(beat.combo) / 20.0F, 0.0F, 1.0F,
  )
  let enhanced_pulse = pulse * (1.0F + combo_intensity * 2.0F)
  draw_grid(floor, enhanced_pulse, game.is_boss_floor)
  // Draw items on floor
  draw_items(floor)
  // Draw enemies
  draw_enemies(floor, beat)
  // Draw player
  draw_player(game, pulse)
  // Draw particles
  draw_particles(game)
  // Draw beat indicator
  draw_beat_indicator(beat)
  // Draw HUD
  draw_hud(game)
  // Draw combo with scale effect
  draw_combo(beat, game.combo_scale)
  // Draw message
  if game.message_timer > 0.0F {
    let alpha = @types.clampf(game.message_timer / 0.5F, 0.0F, 1.0F)
    let a = (alpha * 255.0F).to_int()
    let color = @types.rating_color(beat.last_rating)
    let msg_color = @raylib.Color::new(
      color.r.to_int(), color.g.to_int(), color.b.to_int(), a,
    )
    draw_centered(game.message_text, @types.screen_w / 2, 30, 24, msg_color)
  }
  // Beat fail overlay
  if game.screen == BeatFail {
    @raylib.draw_rectangle(
      0, 0, @types.screen_w, @types.screen_h,
      @raylib.Color::new(200, 0, 0, 60),
    )
  }
  // Border flash effect
  draw_border_flash(game)
}

///|
fn draw_border_flash(game : @types.Game) -> Unit {
  match game.border_flash_color {
    Some(color) => {
      let alpha = @types.clampf(
        game.border_flash_timer / 0.2F, 0.0F, 1.0F,
      )
      let a = (alpha * 100.0F).to_int()
      let c = @raylib.Color::new(
        color.r.to_int(), color.g.to_int(), color.b.to_int(), a,
      )
      let thickness = 4
      // Top
      @raylib.draw_rectangle(0, 0, @types.screen_w, thickness, c)
      // Bottom
      @raylib.draw_rectangle(
        0, @types.screen_h - thickness, @types.screen_w, thickness, c,
      )
      // Left
      @raylib.draw_rectangle(0, 0, thickness, @types.screen_h, c)
      // Right
      @raylib.draw_rectangle(
        @types.screen_w - thickness, 0, thickness, @types.screen_h, c,
      )
    }
    None => ()
  }
}

///|
fn draw_particles(game : @types.Game) -> Unit {
  for p in game.particles {
    let alpha = @types.clampf(p.life / p.max_life, 0.0F, 1.0F)
    let a = (alpha * 255.0F).to_int()
    let color = @raylib.Color::new(p.r, p.g, p.b, a)
    let size = @types.maxf(p.size, 1.0F)
    @raylib.draw_rectangle(
      p.x.to_int(), p.y.to_int(), size.to_int(), size.to_int(), color,
    )
  }
}

///|
fn draw_grid(
  floor : @types.Floor,
  pulse : Float,
  is_boss : Bool,
) -> Unit {
  let grid = floor.grid
  let ts = @types.tile_size
  for y in 0..<grid.height {
    for x in 0..<grid.width {
      let idx = @types.grid_index(x, y, grid.width)
      let tile = grid.tiles[idx]
      let sx = @types.tile_screen_x(x)
      let sy = @types.tile_screen_y(y)
      // Boss floor: lava border color for spikes at edges
      let base_color = if is_boss && tile.kind == Spike &&
        (x == 0 || y == 0 || x == grid.width - 1 || y == grid.height - 1) {
        @types.color_lava
      } else {
        @types.tile_color(tile.kind)
      }
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
          "EXIT", sx + ts / 2, sy + ts / 2 - 5, 10, @raylib.white,
        )
      }
    }
  }
}

///|
fn draw_items(floor : @types.Floor) -> Unit {
  let grid = floor.grid
  let ts = @types.tile_size
  for y in 0..<grid.height {
    for x in 0..<grid.width {
      let idx = @types.grid_index(x, y, grid.width)
      let tile = grid.tiles[idx]
      if tile.has_item {
        let sx = @types.tile_screen_x(x)
        let sy = @types.tile_screen_y(y)
        let cx = sx + ts / 2
        let cy = sy + ts / 2
        match tile.item {
          Some(Gold(_)) => {
            // Gold coin - small yellow circle
            @raylib.draw_circle(cx, cy, 6.0, @types.color_gold)
            @raylib.draw_circle(cx, cy, 3.0, @raylib.Color::new(200, 170, 0, 255))
          }
          Some(HealthPotion) => {
            // Red cross
            let c = @raylib.Color::new(255, 80, 120, 255)
            @raylib.draw_rectangle(cx - 2, cy - 6, 4, 12, c)
            @raylib.draw_rectangle(cx - 6, cy - 2, 12, 4, c)
          }
          Some(ShieldOrb) => {
            // Blue diamond
            let c = @raylib.Color::new(100, 180, 255, 255)
            @raylib.draw_rectangle(cx - 5, cy - 5, 10, 10, c)
            @raylib.draw_rectangle(cx - 3, cy - 3, 6, 6, @raylib.Color::new(150, 210, 255, 255))
          }
          Some(SpeedBoost) => {
            // Yellow lightning bolt (triangle)
            let c = @raylib.Color::new(255, 255, 100, 255)
            @raylib.draw_rectangle(cx - 2, cy - 7, 4, 14, c)
            @raylib.draw_rectangle(cx - 5, cy - 1, 10, 3, c)
          }
          Some(WeaponUpgrade) => {
            // Orange sword shape
            let c = @raylib.Color::new(255, 140, 40, 255)
            @raylib.draw_rectangle(cx - 1, cy - 7, 3, 14, c)
            @raylib.draw_rectangle(cx - 4, cy + 2, 9, 3, c)
          }
          Some(BeatFreeze) => {
            // Cyan snowflake
            let c = @raylib.Color::new(150, 220, 255, 255)
            @raylib.draw_rectangle(cx - 1, cy - 6, 2, 12, c)
            @raylib.draw_rectangle(cx - 6, cy - 1, 12, 2, c)
            @raylib.draw_rectangle(cx - 4, cy - 4, 2, 2, c)
            @raylib.draw_rectangle(cx + 2, cy + 2, 2, 2, c)
          }
          Some(SpecialCharge) => {
            // Purple star (circle)
            let c = @raylib.Color::new(200, 120, 255, 255)
            @raylib.draw_circle(cx, cy, 6.0, c)
            @raylib.draw_circle(cx, cy, 3.0, @raylib.Color::new(230, 180, 255, 255))
          }
          Some(Bomb) => {
            // Red circle with fuse
            let c = @raylib.Color::new(255, 60, 60, 255)
            @raylib.draw_circle(cx, cy + 1, 6.0, c)
            @raylib.draw_rectangle(cx - 1, cy - 7, 2, 5, @raylib.Color::new(200, 200, 200, 255))
          }
          None => {
            // Legacy gold square
            let gem_size = 8
            let gem_x = sx + ts / 2 - gem_size / 2
            let gem_y = sy + ts / 2 - gem_size / 2
            @raylib.draw_rectangle(
              gem_x, gem_y, gem_size, gem_size, @types.color_gold,
            )
          }
        }
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
        base.r.to_int(), base.g.to_int(), base.b.to_int(), 160,
      )
    }
    // Boss enemies are larger
    let is_boss_enemy = match enemy.kind {
      BeatDragon | RhythmLich => true
      _ => false
    }
    let margin = if is_boss_enemy { 2 } else { 6 }
    // Enemy body
    @raylib.draw_rectangle(
      sx + margin, sy + margin, ts - margin * 2, ts - margin * 2, color,
    )
    // Boss-specific decorations
    if is_boss_enemy {
      // Draw inner pattern for bosses
      let inner_color = @raylib.Color::new(
        @types.clampi(base.r.to_int() - 40, 0, 255),
        @types.clampi(base.g.to_int() - 40, 0, 255),
        @types.clampi(base.b.to_int() - 40, 0, 255),
        255,
      )
      @raylib.draw_rectangle(
        sx + margin + 4, sy + margin + 4,
        ts - margin * 2 - 8, ts - margin * 2 - 8,
        inner_color,
      )
      // Phase indicator for bosses
      let hp_frac = Float::from_int(enemy.hp) / Float::from_int(enemy.max_hp)
      let phase_text = match enemy.kind {
        BeatDragon => if hp_frac < 0.5F { "P2" } else { "P1" }
        RhythmLich => if hp_frac < 0.3F { "P2" } else { "P1" }
        _ => ""
      }
      draw_centered_at(
        phase_text, sx + ts / 2, sy + ts - 8, 8,
        @raylib.Color::new(255, 255, 255, 200),
      )
    }
    // HP bar
    if enemy.hp < enemy.max_hp {
      let bar_w = ts - 8
      let hp_frac = Float::from_int(enemy.hp) / Float::from_int(enemy.max_hp)
      let filled = (Float::from_int(bar_w) * hp_frac).to_int()
      @raylib.draw_rectangle(sx + 4, sy + 2, bar_w, 3, @raylib.darkgray)
      let bar_color = if is_boss_enemy {
        @raylib.Color::new(255, 200, 0, 255)
      } else {
        @raylib.red
      }
      @raylib.draw_rectangle(sx + 4, sy + 2, filled, 3, bar_color)
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
    BreathFire(dir, _) => {
      // Fire breath indicator - red line in direction
      let dx = @types.dir_dx(dir)
      let dy = @types.dir_dy(dir)
      let fire_color = @raylib.Color::new(255, 100, 0, 220)
      for i in 1..<4 {
        let fx = cx + dx * (ts / 3) * i
        let fy = cy + dy * (ts / 3) * i
        @raylib.draw_circle(
          fx, fy, Float::from_int(4 - i) + 1.0F, fire_color,
        )
      }
    }
    AoeFreeze(_) => {
      let freeze_color = @raylib.Color::new(150, 220, 255, 180)
      @raylib.draw_circle(cx, cy, 8.0, freeze_color)
      @raylib.draw_circle(cx, cy, 5.0, @raylib.Color::new(200, 240, 255, 120))
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
  let r = @types.clampi(@types.color_player.r.to_int() + boost, 0, 255)
  let g = @types.clampi(@types.color_player.g.to_int() + boost, 0, 255)
  let b = @types.clampi(@types.color_player.b.to_int() + boost, 0, 255)
  let color = @raylib.Color::new(r, g, b, 255)
  let margin = 4
  @raylib.draw_rectangle(
    sx + margin, sy + margin, ts - margin * 2, ts - margin * 2, color,
  )
  // Weapon indicator (small square in center)
  let weapon_size = 6
  let wcx = sx + ts / 2 - weapon_size / 2
  let wcy = sy + ts / 2 - weapon_size / 2
  @raylib.draw_rectangle(wcx, wcy, weapon_size, weapon_size, @raylib.white)
  // Shield indicator
  if game.player.shield > 0 {
    @raylib.draw_rectangle_lines(
      sx + 2, sy + 2, ts - 4, ts - 4,
      @raylib.Color::new(100, 200, 255, 180),
    )
  }
  // Speed boost glow
  if game.player.speed_boost_beats > 0 {
    @raylib.draw_rectangle_lines(
      sx, sy, ts, ts, @raylib.Color::new(255, 255, 100, 150),
    )
  }
  // Beat freeze indicator
  if game.player.beat_freeze_beats > 0 {
    @raylib.draw_rectangle_lines(
      sx + 1, sy + 1, ts - 2, ts - 2,
      @raylib.Color::new(150, 220, 255, 200),
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
      mx - 2, y + 4, 4, h - 8,
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
    bpm_text, 10, y + h / 2 - 8, 16,
    @raylib.Color::new(150, 150, 170, 200),
  )
}

///|
fn draw_combo(beat : @types.BeatState, scale : Float) -> Unit {
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
    // Scale up combo text size when scale > 1
    let font_size = (22.0F * scale).to_int()
    @draw.draw_text(combo_text, x, y, font_size, combo_color)
    @draw.draw_text(
      mult_text, x, y + 24, 16,
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
  let panel_h = 280
  @raylib.draw_rectangle(px, py, panel_w, panel_h, @types.color_hud_bg)
  // HP
  let hp_text = "HP: \{game.player.hp}/\{game.player.max_hp}"
  @draw.draw_text(
    hp_text, px + 10, py + 10, 20,
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
    "Gold: \{game.player.gold}", px + 10, py + 55, 18, @types.color_gold,
  )
  // Score
  @draw.draw_text(
    "Score: \{game.score}", px + 10, py + 80, 18, @raylib.white,
  )
  // Floor
  let floor_text = "Floor: \{game.floors_cleared + 1}/\{@types.max_floor}"
  @draw.draw_text(
    floor_text, px + 10, py + 105, 18,
    @raylib.Color::new(180, 180, 200, 255),
  )
  // Weapon
  @draw.draw_text(
    "Weapon: \{game.player.weapon_damage} dmg", px + 10, py + 130, 16,
    @raylib.Color::new(160, 160, 180, 255),
  )
  // Shield
  @draw.draw_text(
    "Shield: \{game.player.shield}", px + 10, py + 155, 16,
    @raylib.Color::new(100, 200, 255, 255),
  )
  // Special charges
  @draw.draw_text(
    "Special: \{game.player.special_charges}", px + 10, py + 180, 16,
    @raylib.Color::new(200, 150, 255, 255),
  )
  // Beat rating display
  let rating_text = @types.rating_text(game.beat.last_rating)
  let rating_color = @types.rating_color(game.beat.last_rating)
  @draw.draw_text(rating_text, px + 10, py + 215, 22, rating_color)
  // Max combo
  @draw.draw_text(
    "Best Combo: \{game.beat.max_combo}", px + 10, py + 240, 14,
    @raylib.Color::new(140, 140, 160, 200),
  )
  // Active buffs
  let mut buff_y = py + 260
  if game.player.speed_boost_beats > 0 {
    @draw.draw_text(
      "Speed: \{game.player.speed_boost_beats} beats", px + 10, buff_y, 12,
      @raylib.Color::new(255, 255, 100, 255),
    )
    buff_y = buff_y + 14
  }
  if game.player.beat_freeze_beats > 0 {
    @draw.draw_text(
      "Freeze: \{game.player.beat_freeze_beats} beats", px + 10, buff_y, 12,
      @raylib.Color::new(150, 220, 255, 255),
    )
  }
}

///|
fn draw_level_complete(game : @types.Game) -> Unit {
  draw_playing(game)
  // Overlay
  @raylib.draw_rectangle(
    0, 0, @types.screen_w, @types.screen_h,
    @raylib.Color::new(0, 0, 0, 150),
  )
  let cx = @types.screen_w / 2
  draw_centered("FLOOR CLEARED!", cx, 200, 42, @types.color_perfect)
  draw_centered("Score: \{game.score}", cx, 270, 24, @raylib.white)
  draw_centered(
    "Max Combo: \{game.beat.max_combo}", cx, 310, 20, @types.color_good,
  )
  // Floor clear bonus
  let bonus = game.player.hp * @types.score_floor_hp_mult +
    game.player.gold * @types.score_floor_gold_mult
  draw_centered(
    "Floor Bonus: +\{bonus}", cx, 340, 18,
    @raylib.Color::new(200, 200, 100, 255),
  )
  let blink = if game.frame_count / 30 % 2 == 0 { 255 } else { 120 }
  draw_centered(
    "Press ENTER to continue", cx, 430, 22,
    @raylib.Color::new(255, 255, 255, blink),
  )
}

///|
fn draw_game_over(game : @types.Game) -> Unit {
  let cx = @types.screen_w / 2
  draw_centered("GAME OVER", cx, 140, 48, @types.color_miss)
  draw_centered("Final Score: \{game.score}", cx, 220, 28, @raylib.white)
  // Letter grade
  let grade = @types.compute_score_grade(game.score)
  let grade_text = "Grade: \{@types.grade_text(grade)}"
  draw_centered(grade_text, cx, 260, 36, @types.grade_color(grade))
  // Score breakdown
  draw_centered(
    "Kill Score: \{game.score_state.base_kills}", cx, 310, 18,
    @raylib.Color::new(180, 180, 200, 255),
  )
  draw_centered(
    "Beat Bonus: \{game.score_state.beat_bonus}", cx, 335, 18,
    @types.color_perfect,
  )
  draw_centered(
    "Combo Bonus: \{game.score_state.combo_bonus}", cx, 360, 18,
    @types.color_good,
  )
  draw_centered(
    "Floor Bonus: \{game.score_state.floor_bonus}", cx, 385, 18,
    @raylib.Color::new(200, 200, 100, 255),
  )
  draw_centered(
    "Floors Cleared: \{game.floors_cleared}", cx, 420, 22,
    @raylib.Color::new(180, 180, 200, 255),
  )
  draw_centered(
    "Best Combo: \{game.beat.max_combo}", cx, 450, 20, @types.color_good,
  )
  if game.message_timer > 0.0F {
    draw_centered(game.message_text, cx, 480, 20, @types.color_perfect)
  }
  let blink = if game.frame_count / 30 % 2 == 0 { 255 } else { 120 }
  draw_centered(
    "Press ENTER to restart", cx, 540, 22,
    @raylib.Color::new(255, 255, 255, blink),
  )
}

///|
fn draw_floor_select(game : @types.Game) -> Unit {
  let cx = @types.screen_w / 2
  let floor_num = game.floors_cleared + 1
  draw_centered("FLOOR SELECT", cx, 160, 36, @types.color_good)
  draw_centered("Entering Floor \{floor_num}", cx, 230, 28, @raylib.white)
  // BPM info
  let bpm = @types.bpm_for_floor(floor_num)
  draw_centered(
    "BPM: \{bpm.to_int()}", cx, 280, 22,
    @raylib.Color::new(255, 200, 100, 255),
  )
  // Boss warning
  if @types.is_boss_floor(floor_num) {
    let blink = if game.frame_count / 15 % 2 == 0 { 255 } else { 180 }
    draw_centered(
      "!! BOSS FLOOR !!", cx, 310, 28,
      @raylib.Color::new(255, 60, 60, blink),
    )
  }
  // Show floor difficulty info
  let kinds = @content.floor_enemy_kinds(floor_num)
  let enemy_count = @content.floor_enemy_count(floor_num)
  draw_centered(
    "Enemies: \{enemy_count}", cx, 350, 20,
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
    kind_str, cx, 380, 16, @raylib.Color::new(180, 180, 200, 200),
  )
  // Beat window info
  let pw = @types.perfect_window_for_floor(floor_num)
  let pw_ms = (pw * 1000.0F).to_int()
  draw_centered(
    "Perfect Window: +/-\{pw_ms}ms", cx, 410, 16,
    @raylib.Color::new(255, 215, 0, 200),
  )
  let blink = if game.frame_count / 30 % 2 == 0 { 255 } else { 120 }
  draw_centered(
    "Press ENTER to begin", cx, 480, 22,
    @raylib.Color::new(255, 255, 255, blink),
  )
}

///|
fn draw_shop(game : @types.Game) -> Unit {
  @raylib.clear_background(@types.color_shop_bg)
  let cx = @types.screen_w / 2
  draw_centered("SHOP", cx, 60, 42, @types.color_gold)
  draw_centered(
    "Gold: \{game.player.gold}", cx, 110, 24, @types.color_gold,
  )
  // Draw shop items
  let start_y = 170
  let item_h = 80
  for i, entry in game.shop_items {
    let y = start_y + i * item_h
    let is_selected = i == game.shop_cursor
    let bg_color = if is_selected {
      @types.color_shop_highlight
    } else {
      @types.color_hud_bg
    }
    let item_w = 400
    let item_x = cx - item_w / 2
    @raylib.draw_rectangle(item_x, y, item_w, item_h - 10, bg_color)
    if is_selected {
      @raylib.draw_rectangle_lines(
        item_x, y, item_w, item_h - 10,
        @types.color_gold,
      )
    }
    // Item name
    let name_color = if game.player.gold >= entry.price {
      @raylib.white
    } else {
      @raylib.Color::new(120, 120, 120, 255)
    }
    @draw.draw_text(entry.name, item_x + 15, y + 10, 22, name_color)
    // Price
    let price_color = if game.player.gold >= entry.price {
      @types.color_gold
    } else {
      @raylib.Color::new(180, 60, 60, 255)
    }
    @draw.draw_text(
      "\{entry.price}g", item_x + item_w - 80, y + 10, 22, price_color,
    )
    // Description
    @draw.draw_text(
      entry.desc, item_x + 15, y + 40, 16,
      @raylib.Color::new(160, 160, 180, 200),
    )
  }
  // "Leave Shop" option
  let leave_y = start_y + game.shop_items.length() * item_h
  let is_leave_selected = game.shop_cursor >= game.shop_items.length()
  let leave_bg = if is_leave_selected {
    @types.color_shop_highlight
  } else {
    @types.color_hud_bg
  }
  let leave_w = 400
  let leave_x = cx - leave_w / 2
  @raylib.draw_rectangle(leave_x, leave_y, leave_w, 50, leave_bg)
  if is_leave_selected {
    @raylib.draw_rectangle_lines(
      leave_x, leave_y, leave_w, 50, @types.color_gold,
    )
  }
  draw_centered(
    "Leave Shop", cx, leave_y + 15, 22, @raylib.white,
  )
  // Controls hint
  draw_centered(
    "UP/DOWN to navigate, ENTER to buy/leave", cx, 640, 16,
    @raylib.Color::new(140, 140, 160, 200),
  )
  // Message
  if game.message_timer > 0.0F {
    let alpha = @types.clampf(game.message_timer / 0.5F, 0.0F, 1.0F)
    let a = (alpha * 255.0F).to_int()
    draw_centered(
      game.message_text, cx, 670, 20,
      @raylib.Color::new(255, 255, 255, a),
    )
  }
}

///|
fn draw_floor_transition(game : @types.Game) -> Unit {
  @raylib.clear_background(@types.color_bg)
  let cx = @types.screen_w / 2
  let cy = @types.screen_h / 2
  let floor_num = game.transition_floor
  // Animated floor number
  let progress = 1.0F - game.transition_timer / @types.floor_transition_duration
  let alpha = @types.clampf(progress * 2.0F, 0.0F, 1.0F)
  let a = (alpha * 255.0F).to_int()
  let size = 48 + (progress * 20.0F).to_int()
  draw_centered(
    "FLOOR \{floor_num}", cx, cy - 40, size,
    @raylib.Color::new(80, 200, 255, a),
  )
  // BPM display
  let bpm = @types.bpm_for_floor(floor_num)
  draw_centered(
    "\{bpm.to_int()} BPM", cx, cy + 40, 28,
    @raylib.Color::new(255, 200, 100, a),
  )
  // Boss warning
  if @types.is_boss_floor(floor_num) {
    let blink = if game.frame_count / 10 % 2 == 0 { a } else { a / 2 }
    draw_centered(
      "BOSS BATTLE!", cx, cy + 90, 32,
      @raylib.Color::new(255, 40, 40, blink),
    )
  }
}

///|
fn draw_boss_intro(game : @types.Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(10, 5, 15, 255))
  let cx = @types.screen_w / 2
  let cy = @types.screen_h / 2
  // Dramatic "BOSS!" text with screen shake effect
  let progress = 1.0F - game.boss_intro_timer / @types.boss_intro_duration
  let alpha = @types.clampf(progress * 3.0F, 0.0F, 1.0F)
  let a = (alpha * 255.0F).to_int()
  // Shake text position
  let rng = @types.game_rng(game)
  let shake_amount = (game.screen_shake * 2.0F).to_int()
  let sx = if shake_amount > 0 {
    @types.rand_range(rng, -shake_amount, shake_amount)
  } else {
    0
  }
  let sy_off = if shake_amount > 0 {
    @types.rand_range(rng, -shake_amount, shake_amount)
  } else {
    0
  }
  @types.sync_rng(game, rng)
  draw_centered(
    "BOSS!", cx + sx, cy - 60 + sy_off, 72,
    @raylib.Color::new(255, 40, 40, a),
  )
  // Boss name
  guard game.floor is Some(floor) else { return }
  let boss_name = if floor.floor_num == 5 {
    "THE BEAT DRAGON"
  } else {
    "THE RHYTHM LICH"
  }
  draw_centered(
    boss_name, cx, cy + 30, 28,
    @raylib.Color::new(255, 200, 100, a),
  )
  // Countdown hint
  if progress > 0.5F {
    let hint_a = ((progress - 0.5F) * 2.0F * 255.0F).to_int()
    draw_centered(
      "Prepare yourself...", cx, cy + 100, 20,
      @raylib.Color::new(180, 180, 200, hint_a),
    )
  }
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
