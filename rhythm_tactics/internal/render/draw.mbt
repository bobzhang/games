///|
/// Draw the full game frame.
pub fn draw_frame(game : @types.Game) -> Unit {
  // Use themed bg color if available
  let bg = match game.floor_theme {
    Some(td) => td.bg_color
    None => @types.color_bg
  }
  @raylib.clear_background(bg)
  match game.screen {
    Title => draw_title(game)
    Playing => draw_playing(game)
    BeatFail => draw_playing(game)
    LevelComplete => draw_level_complete(game)
    GameOver => draw_game_over(game)
    FloorSelect => draw_floor_select(game)
    Shop => draw_shop(game)
    FloorTransition => draw_enhanced_floor_transition(game)
    BossIntro => draw_enhanced_boss_intro(game)
    AbilityChoice => draw_ability_choice(game)
    RunSummary => draw_enhanced_run_summary(game)
    CurseOffer => draw_curse_offer(game)
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
  // Show meta progress if any runs completed
  let meta = game.meta
  if meta.total_runs > 0 {
    draw_centered(
      "Best: \{meta.best_score}  Combo: \{meta.highest_combo}  Runs: \{meta.total_runs}",
      cx,
      570,
      16,
      @raylib.Color::new(120, 120, 150, 180),
    )
    let mut unlocked_str = "Weapons: "
    for i, w in meta.unlocked_weapons {
      if i > 0 {
        unlocked_str = unlocked_str + ", "
      }
      unlocked_str = unlocked_str + @types.weapon_data(w).name
    }
    draw_centered(
      unlocked_str,
      cx,
      595,
      14,
      @raylib.Color::new(100, 140, 180, 160),
    )
    // Show unlocked achievements
    let mut ach_count = 0
    for a in game.achievements.achievements {
      if a.unlocked {
        ach_count = ach_count + 1
      }
    }
    if ach_count > 0 {
      draw_centered(
        "Achievements: \{ach_count}/\{game.achievements.achievements.length()}",
        cx,
        618,
        14,
        @raylib.Color::new(255, 215, 0, 160),
      )
    }
  }
  // Controls hint for spells
  draw_centered(
    "Spells: 1-4 keys  |  Space: Special Attack",
    cx,
    560,
    14,
    @raylib.Color::new(130, 130, 150, 160),
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
    Float::from_int(beat.combo) / 20.0F,
    0.0F,
    1.0F,
  )
  let enhanced_pulse = pulse * (1.0F + combo_intensity * 2.0F)
  draw_grid(floor, enhanced_pulse, game.is_boss_floor, game.floor_theme)
  // Draw items on floor
  draw_items(floor)
  // Draw enemies
  draw_enemies(floor, beat)
  // Draw enemy threat markers
  draw_enemy_threat_markers(floor)
  // Draw spell AoE preview
  draw_spell_preview(game)
  // Draw player
  draw_player(game, pulse)
  // Draw facing direction arrow
  draw_player_direction_arrow(game)
  // Draw weapon effects
  draw_weapon_effects(game)
  // Draw particles
  draw_particles(game)
  // Draw trail particles
  draw_trail_particles(game)
  // Draw damage numbers
  draw_damage_numbers(game)
  // Draw beat indicator (hidden if BlindBeat curse)
  if !@types.has_curse(game.curses, BlindBeat) {
    draw_enhanced_beat_indicator(beat)
  }
  // Draw HUD
  draw_hud(game)
  // Draw spell HUD
  draw_spell_hud(game)
  // Draw boss health bar + phase indicator
  draw_boss_health_bar(game)
  draw_boss_phase_indicator(game)
  // Draw active curses
  draw_active_curses(game)
  // Draw enemy info panel
  draw_enemy_info_panel(game)
  // Draw mana regen effect
  draw_mana_regen_effect(game)
  // Draw special attack indicator
  draw_special_indicator(game)
  // Draw floor info bar
  draw_floor_info_bar(game)
  // Draw combo with scale effect
  draw_combo(game, beat, game.combo_scale)
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
  // Theme ambient particles
  draw_theme_particles(game)
  // Theme ambient text
  draw_theme_ambient(game)
  // Combo encouragement
  draw_combo_encouragement(game)
  // Combo visual overlay
  draw_combo_visual_overlay(game)
  // Border flash effect
  draw_border_flash(game)
  // Screen pulse (BPM intensity)
  draw_screen_pulse(game)
  // Mini-map
  draw_minimap(game)
  // Score multiplier/beat counter
  draw_score_multiplier(game)
  // Achievement toasts
  draw_achievement_toasts(game)
  // Weapon switch flash
  draw_weapon_switch_flash(game)
  // Combo milestone celebration
  draw_milestone_celebration(game)
}

///|
fn draw_border_flash(game : @types.Game) -> Unit {
  match game.border_flash_color {
    Some(color) => {
      let alpha = @types.clampf(game.border_flash_timer / 0.2F, 0.0F, 1.0F)
      let a = (alpha * 100.0F).to_int()
      let c = @raylib.Color::new(
        color.r.to_int(),
        color.g.to_int(),
        color.b.to_int(),
        a,
      )
      let thickness = 4
      // Top
      @raylib.draw_rectangle(0, 0, @types.screen_w, thickness, c)
      // Bottom
      @raylib.draw_rectangle(
        0,
        @types.screen_h - thickness,
        @types.screen_w,
        thickness,
        c,
      )
      // Left
      @raylib.draw_rectangle(0, 0, thickness, @types.screen_h, c)
      // Right
      @raylib.draw_rectangle(
        @types.screen_w - thickness,
        0,
        thickness,
        @types.screen_h,
        c,
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
      p.x.to_int(),
      p.y.to_int(),
      size.to_int(),
      size.to_int(),
      color,
    )
  }
}

///|
fn draw_grid(
  floor : @types.Floor,
  pulse : Float,
  is_boss : Bool,
  theme : @types.FloorThemeData?,
) -> Unit {
  let grid = floor.grid
  let ts = @types.tile_size
  for y in 0..<grid.height {
    for x in 0..<grid.width {
      let idx = @types.grid_index(x, y, grid.width)
      let tile = grid.tiles[idx]
      let sx = @types.tile_screen_x(x)
      let sy = @types.tile_screen_y(y)
      let base_color = if is_boss &&
        tile.kind == Spike &&
        (x == 0 || y == 0 || x == grid.width - 1 || y == grid.height - 1) {
        @types.color_lava
      } else {
        @types.themed_tile_color(tile.kind, theme)
      }
      let pulse_boost = (pulse * 20.0F).to_int()
      let r = @types.clampi(base_color.r.to_int() + pulse_boost, 0, 255)
      let g = @types.clampi(base_color.g.to_int() + pulse_boost, 0, 255)
      let b = @types.clampi(base_color.b.to_int() + pulse_boost, 0, 255)
      let color = @raylib.Color::new(r, g, b, 255)
      @raylib.draw_rectangle(sx, sy, ts, ts, color)
      @raylib.draw_rectangle_lines(sx, sy, ts, ts, @types.color_grid_line)
      // Lava glow effect
      if tile.kind == Lava {
        let lava_pulse = @math.sinf(game_time() * 5.0F + Float::from_int(x + y)) *
          0.3F +
          0.7F
        let la = (lava_pulse * 60.0F).to_int()
        @raylib.draw_rectangle(
          sx,
          sy,
          ts,
          ts,
          @raylib.Color::new(255, 100, 20, la),
        )
      }
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
            @raylib.draw_circle(
              cx,
              cy,
              3.0,
              @raylib.Color::new(200, 170, 0, 255),
            )
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
            @raylib.draw_rectangle(
              cx - 3,
              cy - 3,
              6,
              6,
              @raylib.Color::new(150, 210, 255, 255),
            )
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
            @raylib.draw_circle(
              cx,
              cy,
              3.0,
              @raylib.Color::new(230, 180, 255, 255),
            )
          }
          Some(Bomb) => {
            // Red circle with fuse
            let c = @raylib.Color::new(255, 60, 60, 255)
            @raylib.draw_circle(cx, cy + 1, 6.0, c)
            @raylib.draw_rectangle(
              cx - 1,
              cy - 7,
              2,
              5,
              @raylib.Color::new(200, 200, 200, 255),
            )
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
    if !enemy.active {
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
      @raylib.Color::new(base.r.to_int(), base.g.to_int(), base.b.to_int(), 160)
    }
    // Boss enemies are larger
    let is_boss_enemy = match enemy.kind {
      BeatDragon | RhythmLich => true
      _ => false
    }
    let margin = if is_boss_enemy { 2 } else { 6 }
    // Enemy body
    @raylib.draw_rectangle(
      sx + margin,
      sy + margin,
      ts - margin * 2,
      ts - margin * 2,
      color,
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
        sx + margin + 4,
        sy + margin + 4,
        ts - margin * 2 - 8,
        ts - margin * 2 - 8,
        inner_color,
      )
      // Phase indicator for bosses (3-phase system: >75% P1, 75-50% P2, <50% P3)
      let phase = @types.boss_phase_from_hp(enemy.kind, enemy.hp, enemy.max_hp)
      let phase_text = match phase {
        Phase1 => "P1"
        Phase2 => "P2"
        Phase3 => "P3"
      }
      draw_centered_at(
        phase_text,
        sx + ts / 2,
        sy + ts - 8,
        8,
        @raylib.Color::new(255, 255, 255, 200),
      )
    }
    // Elite / status indicators
    draw_elite_indicator(enemy, sx, sy, ts)
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
        @raylib.draw_circle(fx, fy, Float::from_int(4 - i) + 1.0F, fire_color)
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
    sx + margin,
    sy + margin,
    ts - margin * 2,
    ts - margin * 2,
    color,
  )
  // Weapon shape indicator
  let wc = @types.weapon_color(game.player.weapon)
  let cx = sx + ts / 2
  let cy = sy + ts / 2
  match game.player.weapon {
    Sword => {
      @raylib.draw_rectangle(cx - 1, cy - 7, 3, 14, wc)
      @raylib.draw_rectangle(cx - 4, cy + 2, 9, 3, wc)
    }
    Spear => {
      @raylib.draw_rectangle(cx - 1, cy - 8, 2, 16, wc)
      @raylib.draw_rectangle(cx - 3, cy - 8, 6, 4, wc)
    }
    Whip => {
      @raylib.draw_rectangle(cx - 6, cy - 1, 12, 2, wc)
      @raylib.draw_rectangle(cx + 4, cy - 3, 2, 6, wc)
    }
    Hammer => {
      @raylib.draw_rectangle(cx - 1, cy - 2, 2, 10, wc)
      @raylib.draw_rectangle(cx - 5, cy - 6, 10, 5, wc)
    }
    Bow => {
      @raylib.draw_rectangle(cx - 5, cy - 6, 2, 12, wc)
      @raylib.draw_rectangle(cx - 3, cy - 1, 8, 2, wc)
    }
    Staff => {
      @raylib.draw_rectangle(cx - 1, cy - 8, 2, 16, wc)
      @raylib.draw_circle(cx, cy - 8, 4.0, wc)
    }
  }
  // Draw weapon attack preview (faint)
  draw_attack_preview(game)
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
  // Invincibility glow
  if game.player.invincible_beats > 0 {
    let ia = (@math.sinf(game_time() * 10.0F) * 60.0F + 80.0F).to_int()
    @raylib.draw_rectangle_lines(
      sx,
      sy,
      ts,
      ts,
      @raylib.Color::new(255, 215, 0, ia),
    )
  }
  // Double damage glow
  if game.player.double_damage_beats > 0 {
    @raylib.draw_rectangle_lines(
      sx + 1,
      sy + 1,
      ts - 2,
      ts - 2,
      @raylib.Color::new(255, 80, 40, 150),
    )
  }
  // Speed boost glow
  if game.player.speed_boost_beats > 0 {
    @raylib.draw_rectangle_lines(
      sx,
      sy,
      ts,
      ts,
      @raylib.Color::new(255, 255, 100, 150),
    )
  }
  // Beat freeze indicator
  if game.player.beat_freeze_beats > 0 {
    @raylib.draw_rectangle_lines(
      sx + 1,
      sy + 1,
      ts - 2,
      ts - 2,
      @raylib.Color::new(150, 220, 255, 200),
    )
  }
}

///|
fn draw_attack_preview(game : @types.Game) -> Unit {
  let cells = @types.weapon_attack_cells(game.player.weapon, game.player.facing)
  let ts = @types.tile_size
  let wc = @types.weapon_color(game.player.weapon)
  let preview_color = @raylib.Color::new(
    wc.r.to_int(),
    wc.g.to_int(),
    wc.b.to_int(),
    40,
  )
  for cell in cells {
    let (dx, dy) = cell
    let tx = game.player.x + dx
    let ty = game.player.y + dy
    if @types.in_bounds(tx, ty, @types.grid_w, @types.grid_h) {
      let px = @types.tile_screen_x(tx)
      let py = @types.tile_screen_y(ty)
      @raylib.draw_rectangle(px + 2, py + 2, ts - 4, ts - 4, preview_color)
    }
  }
}

///|
fn draw_combo(
  game : @types.Game,
  beat : @types.BeatState,
  scale : Float,
) -> Unit {
  if beat.combo > 0 {
    let combo_text = "COMBO: \{beat.combo}x"
    let mult = @beat.combo_multiplier(beat)
    let mult_i = (mult * 10.0F).to_int()
    let mult_text = "DMG x\{mult_i / 10}.\{mult_i % 10}"
    let x = @types.screen_w - 180
    let y = 70
    // Combo box with visual intensity scaling
    let level = @types.combo_visual_level(beat.combo)
    let box_color = match level {
      3 => @raylib.Color::new(40, 20, 50, 220)
      2 => @raylib.Color::new(30, 20, 40, 210)
      _ => @types.color_hud_bg
    }
    @raylib.draw_rectangle(x - 5, y - 5, 170, 65, box_color)
    // Rainbow border at high combo
    if level >= 2 {
      let hue = @math.sinf(game.anim_timer * 3.0F)
      let rr = (hue * 80.0F + 175.0F).to_int()
      let gg = ((hue + 1.0F) * 60.0F + 100.0F).to_int()
      let bb = ((1.0F - hue) * 80.0F + 175.0F).to_int()
      @raylib.draw_rectangle_lines(
        x - 5,
        y - 5,
        170,
        65,
        @raylib.Color::new(
          @types.clampi(rr, 0, 255),
          @types.clampi(gg, 0, 255),
          @types.clampi(bb, 0, 255),
          200,
        ),
      )
    }
    let combo_color = if beat.combo >= 30 {
      @raylib.Color::new(255, 100, 255, 255)
    } else if beat.combo >= 15 {
      @types.color_perfect
    } else if beat.combo >= 5 {
      @types.color_good
    } else {
      @raylib.white
    }
    let font_size = (22.0F * scale).to_int()
    @draw.draw_text(combo_text, x, y, font_size, combo_color)
    @draw.draw_text(
      mult_text,
      x,
      y + 24,
      16,
      @raylib.Color::new(180, 180, 200, 200),
    )
    // Milestone text
    let cs = game.combo_state
    if cs.milestone_flash_timer > 0.0F {
      let ms_text = @types.milestone_text(cs.last_milestone)
      let ms_color = @types.milestone_color(cs.last_milestone)
      let ma = @types.clampf(cs.milestone_flash_timer, 0.0F, 1.0F)
      let alpha = (ma * 255.0F).to_int()
      let mc = @raylib.Color::new(
        ms_color.r.to_int(),
        ms_color.g.to_int(),
        ms_color.b.to_int(),
        alpha,
      )
      @draw.draw_text(ms_text, x, y + 46, 14, mc)
    }
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
  @draw.draw_text("Score: \{game.score}", px + 10, py + 80, 18, @raylib.white)
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
  let wd = @types.weapon_data(game.player.weapon)
  @draw.draw_text(
    "\{wd.name}: \{game.player.weapon_damage + wd.damage - 1} dmg",
    px + 10,
    py + 130,
    16,
    @types.weapon_color(game.player.weapon),
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
  // Active buffs
  let mut buff_y = py + 260
  if game.player.speed_boost_beats > 0 {
    @draw.draw_text(
      "Speed: \{game.player.speed_boost_beats} beats",
      px + 10,
      buff_y,
      12,
      @raylib.Color::new(255, 255, 100, 255),
    )
    buff_y = buff_y + 14
  }
  if game.player.beat_freeze_beats > 0 {
    @draw.draw_text(
      "Freeze: \{game.player.beat_freeze_beats} beats",
      px + 10,
      buff_y,
      12,
      @raylib.Color::new(150, 220, 255, 255),
    )
    buff_y = buff_y + 14
  }
  if game.player.invincible_beats > 0 {
    @draw.draw_text(
      "Invincible: \{game.player.invincible_beats}",
      px + 10,
      buff_y,
      12,
      @raylib.Color::new(255, 215, 0, 255),
    )
    buff_y = buff_y + 14
  }
  if game.player.double_damage_beats > 0 {
    @draw.draw_text(
      "2x Damage: \{game.player.double_damage_beats}",
      px + 10,
      buff_y,
      12,
      @raylib.Color::new(255, 100, 50, 255),
    )
    buff_y = buff_y + 14
  }
  // Show abilities
  for a in game.player.abilities {
    @draw.draw_text(
      @types.ability_name(a),
      px + 10,
      buff_y,
      11,
      @raylib.Color::new(200, 150, 255, 180),
    )
    buff_y = buff_y + 13
  }
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
  draw_centered("FLOOR CLEARED!", cx, 200, 42, @types.color_perfect)
  draw_centered("Score: \{game.score}", cx, 270, 24, @raylib.white)
  draw_centered(
    "Max Combo: \{game.beat.max_combo}",
    cx,
    310,
    20,
    @types.color_good,
  )
  // Floor clear bonus
  let bonus = game.player.hp * @types.score_floor_hp_mult +
    game.player.gold * @types.score_floor_gold_mult
  draw_centered(
    "Floor Bonus: +\{bonus}",
    cx,
    340,
    18,
    @raylib.Color::new(200, 200, 100, 255),
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
  draw_centered("GAME OVER", cx, 140, 48, @types.color_miss)
  draw_centered("Final Score: \{game.score}", cx, 220, 28, @raylib.white)
  // Letter grade
  let grade = @types.compute_score_grade(game.score)
  let grade_text = "Grade: \{@types.grade_text(grade)}"
  draw_centered(grade_text, cx, 260, 36, @types.grade_color(grade))
  // Score breakdown
  draw_centered(
    "Kill Score: \{game.score_state.base_kills}",
    cx,
    310,
    18,
    @raylib.Color::new(180, 180, 200, 255),
  )
  draw_centered(
    "Beat Bonus: \{game.score_state.beat_bonus}",
    cx,
    335,
    18,
    @types.color_perfect,
  )
  draw_centered(
    "Combo Bonus: \{game.score_state.combo_bonus}",
    cx,
    360,
    18,
    @types.color_good,
  )
  draw_centered(
    "Floor Bonus: \{game.score_state.floor_bonus}",
    cx,
    385,
    18,
    @raylib.Color::new(200, 200, 100, 255),
  )
  draw_centered(
    "Floors Cleared: \{game.floors_cleared}",
    cx,
    420,
    22,
    @raylib.Color::new(180, 180, 200, 255),
  )
  draw_centered(
    "Best Combo: \{game.beat.max_combo}",
    cx,
    450,
    20,
    @types.color_good,
  )
  if game.message_timer > 0.0F {
    draw_centered(game.message_text, cx, 480, 20, @types.color_perfect)
  }
  let blink = if game.frame_count / 30 % 2 == 0 { 255 } else { 120 }
  draw_centered(
    "Press ENTER to restart",
    cx,
    540,
    22,
    @raylib.Color::new(255, 255, 255, blink),
  )
}

///|
fn draw_floor_select(game : @types.Game) -> Unit {
  let cx = @types.screen_w / 2
  let floor_num = game.floors_cleared + 1
  draw_centered("FLOOR SELECT", cx, 140, 36, @types.color_good)
  draw_centered("Entering Floor \{floor_num}", cx, 200, 28, @raylib.white)
  // Difficulty indicator
  let diff_text = @types.floor_difficulty_text(floor_num)
  let diff_color = @types.floor_difficulty_color(floor_num)
  draw_centered("Difficulty: \{diff_text}", cx, 235, 20, diff_color)
  // BPM info
  let bpm = @types.bpm_for_floor(floor_num)
  draw_centered(
    "BPM: \{bpm.to_int()}",
    cx,
    280,
    22,
    @raylib.Color::new(255, 200, 100, 255),
  )
  // Boss warning
  if @types.is_boss_floor(floor_num) {
    let blink = if game.frame_count / 15 % 2 == 0 { 255 } else { 180 }
    draw_centered(
      "!! BOSS FLOOR !!",
      cx,
      310,
      28,
      @raylib.Color::new(255, 60, 60, blink),
    )
  }
  // Show floor difficulty info
  let kinds = @content.floor_enemy_kinds(floor_num)
  let enemy_count = @content.floor_enemy_count(floor_num)
  draw_centered(
    "Enemies: \{enemy_count}",
    cx,
    350,
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
  draw_centered(kind_str, cx, 380, 16, @raylib.Color::new(180, 180, 200, 200))
  // Beat window info
  let pw = @types.perfect_window_for_floor(floor_num)
  let pw_ms = (pw * 1000.0F).to_int()
  draw_centered(
    "Perfect Window: +/-\{pw_ms}ms",
    cx,
    410,
    16,
    @raylib.Color::new(255, 215, 0, 200),
  )
  // Show active curses
  if game.curses.active_curses.length() > 0 {
    let mut curse_str = "Active Curses: "
    for i, c in game.curses.active_curses {
      if i > 0 {
        curse_str = curse_str + ", "
      }
      curse_str = curse_str + @types.curse_name(c)
    }
    draw_centered(curse_str, cx, 440, 14, @raylib.Color::new(200, 100, 80, 200))
  }
  // Show equipped spells
  if game.player.learned_spells.length() > 0 {
    let mut spell_str = "Spells: "
    for i, s in game.player.learned_spells {
      if i > 0 {
        spell_str = spell_str + ", "
      }
      spell_str = spell_str + @types.spell_data(s).name
    }
    draw_centered(
      spell_str,
      cx,
      460,
      14,
      @raylib.Color::new(100, 180, 255, 200),
    )
  }
  // Player stats summary
  draw_centered(
    "HP: \{game.player.hp}/\{game.player.max_hp}  Mana: \{game.player.mana}/\{game.player.max_mana}  Gold: \{game.player.gold}",
    cx,
    490,
    16,
    @raylib.Color::new(180, 180, 200, 200),
  )
  let blink = if game.frame_count / 30 % 2 == 0 { 255 } else { 120 }
  draw_centered(
    "Press ENTER to begin",
    cx,
    530,
    22,
    @raylib.Color::new(255, 255, 255, blink),
  )
}

///|
fn draw_shop(game : @types.Game) -> Unit {
  @raylib.clear_background(@types.color_shop_bg)
  let cx = @types.screen_w / 2
  draw_centered("SHOP", cx, 60, 42, @types.color_gold)
  draw_centered("Gold: \{game.player.gold}", cx, 100, 24, @types.color_gold)
  // Show HP and Mana
  draw_centered(
    "HP: \{game.player.hp}/\{game.player.max_hp}  Mana: \{game.player.mana}/\{game.player.max_mana}",
    cx,
    125,
    16,
    @raylib.Color::new(180, 180, 200, 200),
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
        item_x,
        y,
        item_w,
        item_h - 10,
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
      "\{entry.price}g",
      item_x + item_w - 80,
      y + 10,
      22,
      price_color,
    )
    // Description
    @draw.draw_text(
      entry.desc,
      item_x + 15,
      y + 40,
      16,
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
  draw_centered("Leave Shop", cx, leave_y + 15, 22, @raylib.white)
  // Controls hint
  draw_centered(
    "UP/DOWN to navigate, ENTER to buy/leave",
    cx,
    640,
    16,
    @raylib.Color::new(140, 140, 160, 200),
  )
  // Message
  if game.message_timer > 0.0F {
    let alpha = @types.clampf(game.message_timer / 0.5F, 0.0F, 1.0F)
    let a = (alpha * 255.0F).to_int()
    draw_centered(
      game.message_text,
      cx,
      670,
      20,
      @raylib.Color::new(255, 255, 255, a),
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
fn draw_ability_choice(game : @types.Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(15, 10, 25, 255))
  let cx = @types.screen_w / 2
  draw_centered("BOSS DEFEATED!", cx, 80, 36, @types.color_perfect)
  draw_centered("Choose an Ability", cx, 130, 28, @raylib.white)
  let start_y = 200
  let item_h = 100
  for i, choice in game.ability_choices {
    let y = start_y + i * item_h
    let is_selected = i == game.ability_cursor
    let bg = if is_selected {
      @raylib.Color::new(60, 40, 80, 255)
    } else {
      @raylib.Color::new(30, 25, 45, 255)
    }
    let w = 450
    let x = cx - w / 2
    @raylib.draw_rectangle(x, y, w, item_h - 15, bg)
    if is_selected {
      @raylib.draw_rectangle_lines(x, y, w, item_h - 15, @types.color_perfect)
    }
    @draw.draw_text(
      choice.name,
      x + 20,
      y + 12,
      24,
      if is_selected {
        @types.color_perfect
      } else {
        @raylib.white
      },
    )
    @draw.draw_text(
      choice.desc,
      x + 20,
      y + 45,
      16,
      @raylib.Color::new(180, 180, 200, 200),
    )
  }
  let blink = if game.frame_count / 30 % 2 == 0 { 255 } else { 120 }
  draw_centered(
    "ENTER to select",
    cx,
    560,
    20,
    @raylib.Color::new(255, 255, 255, blink),
  )
}

///|
/// Draw a mini score/multiplier indicator near the beat bar.
fn draw_score_multiplier(game : @types.Game) -> Unit {
  let y = @types.beat_indicator_y - 20
  let curse_mult = if @types.has_curse(game.curses, DoubleTime) {
    "+50%"
  } else {
    ""
  }
  if curse_mult.length() > 0 {
    @draw.draw_text(
      "Score: \{curse_mult}",
      @types.screen_w - 120,
      y,
      14,
      @raylib.Color::new(255, 200, 100, 180),
    )
  }
  // Show current floor beat count
  @draw.draw_text(
    "Beat #\{game.beat.beat_count}",
    @types.screen_w - 120,
    y + 16,
    12,
    @raylib.Color::new(150, 150, 170, 150),
  )
}

///|
/// Draw mini-map in corner showing enemy positions.
fn draw_minimap(game : @types.Game) -> Unit {
  guard game.floor is Some(floor) else { return }
  let map_x = @types.screen_w - 110
  let map_y = @types.screen_h - 130
  let cell_size = 8
  let gw = floor.grid.width
  let gh = floor.grid.height
  // Background
  @raylib.draw_rectangle(
    map_x - 2,
    map_y - 2,
    gw * cell_size + 4,
    gh * cell_size + 4,
    @raylib.Color::new(10, 10, 20, 180),
  )
  // Tiles
  for y in 0..<gh {
    for x in 0..<gw {
      let idx = @types.grid_index(x, y, gw)
      let tile = floor.grid.tiles[idx]
      let px = map_x + x * cell_size
      let py = map_y + y * cell_size
      let color = match tile.kind {
        Wall => @raylib.Color::new(60, 60, 80, 200)
        Floor => @raylib.Color::new(25, 25, 40, 150)
        Exit => @raylib.Color::new(0, 200, 100, 200)
        Spike => @raylib.Color::new(200, 50, 50, 150)
        Ice => @raylib.Color::new(100, 180, 220, 150)
        Pit => @raylib.Color::new(5, 5, 10, 200)
        Lava => @raylib.Color::new(200, 60, 20, 180)
      }
      @raylib.draw_rectangle(px, py, cell_size - 1, cell_size - 1, color)
    }
  }
  // Enemies
  for enemy in floor.enemies {
    if enemy.active {
      let px = map_x + enemy.x * cell_size
      let py = map_y + enemy.y * cell_size
      let ec = if enemy.is_elite {
        @raylib.Color::new(255, 215, 0, 255)
      } else {
        @raylib.Color::new(255, 60, 60, 200)
      }
      @raylib.draw_rectangle(px + 1, py + 1, cell_size - 2, cell_size - 2, ec)
    }
  }
  // Player
  let ppx = map_x + game.player.x * cell_size
  let ppy = map_y + game.player.y * cell_size
  @raylib.draw_rectangle(
    ppx,
    ppy,
    cell_size,
    cell_size,
    @raylib.Color::new(80, 200, 255, 255),
  )
  // Label
  @draw.draw_text(
    "Map",
    map_x,
    map_y - 14,
    11,
    @raylib.Color::new(140, 140, 160, 180),
  )
}

///|
/// Draw combo visual effects overlay (for high combos).
fn draw_combo_visual_overlay(game : @types.Game) -> Unit {
  let level = @types.combo_visual_level(game.beat.combo)
  // Level 1: trail particles on player (handled via normal particles)
  // Level 2: rainbow border pulsing
  if level >= 2 {
    let hue = @math.sinf(game.anim_timer * 4.0F)
    let rr = (hue * 80.0F + 175.0F).to_int()
    let gg = ((hue + 0.5F) * 60.0F + 120.0F).to_int()
    let bb = ((1.0F - hue) * 80.0F + 175.0F).to_int()
    let alpha = if level >= 3 { 80 } else { 40 }
    let c = @raylib.Color::new(
      @types.clampi(rr, 0, 255),
      @types.clampi(gg, 0, 255),
      @types.clampi(bb, 0, 255),
      alpha,
    )
    let t = 3
    @raylib.draw_rectangle(0, 0, @types.screen_w, t, c)
    @raylib.draw_rectangle(0, @types.screen_h - t, @types.screen_w, t, c)
    @raylib.draw_rectangle(0, 0, t, @types.screen_h, c)
    @raylib.draw_rectangle(@types.screen_w - t, 0, t, @types.screen_h, c)
  }
  // Level 3: add screen vibration effect (handled by screen_shake)
  if level >= 3 && game.screen_shake < 1.0F {
    // Subtle continuous vibration at max combo
    // (This is mostly cosmetic - don't override real shakes)
  }
}

///|
/// Draw ambient theme particles.
fn draw_theme_particles(game : @types.Game) -> Unit {
  match game.floor_theme {
    Some(td) => {
      let ac = td.accent_color
      match td.theme {
        Volcano => {
          // Rising ember particles
          let count = 5
          for i in 0..<count {
            let t = game.anim_timer + Float::from_int(i) * 1.3F
            let x = ((@math.sinf(t * 0.7F) + 1.0F) *
            Float::from_int(@types.screen_w) /
            2.0F).to_int()
            let y = @types.screen_h - (t * 30.0F).to_int() % @types.screen_h
            let alpha = 100 - y * 100 / @types.screen_h
            if alpha > 0 {
              @raylib.draw_rectangle(
                x,
                y,
                2,
                2,
                @raylib.Color::new(
                  ac.r.to_int(),
                  ac.g.to_int(),
                  ac.b.to_int(),
                  alpha,
                ),
              )
            }
          }
        }
        IceDungeon => {
          // Falling snow particles
          let count = 8
          for i in 0..<count {
            let t = game.anim_timer + Float::from_int(i) * 0.9F
            let x = ((@math.sinf(t * 0.5F) + 1.0F) *
            Float::from_int(@types.screen_w) /
            2.0F).to_int()
            let y = (t * 20.0F).to_int() % @types.screen_h
            @raylib.draw_rectangle(
              x,
              y,
              2,
              2,
              @raylib.Color::new(200, 230, 255, 80),
            )
          }
        }
        Cave => {
          // Dim flickering points
          let count = 3
          for i in 0..<count {
            let t = game.anim_timer + Float::from_int(i) * 2.1F
            let x = ((@math.sinf(t * 0.3F) + 1.0F) *
            Float::from_int(@types.screen_w) /
            2.0F).to_int()
            let y = ((@types.cos_approx(t * 0.4F) + 1.0F) *
            Float::from_int(@types.screen_h) /
            2.0F).to_int()
            let flicker = (@math.sinf(t * 8.0F) * 40.0F + 50.0F).to_int()
            @raylib.draw_rectangle(
              x,
              y,
              1,
              1,
              @raylib.Color::new(
                ac.r.to_int(),
                ac.g.to_int(),
                ac.b.to_int(),
                @types.clampi(flicker, 10, 90),
              ),
            )
          }
        }
        _ => ()
      }
    }
    None => ()
  }
}

///|
fn draw_theme_ambient(game : @types.Game) -> Unit {
  match game.floor_theme {
    Some(td) => {
      let text = @types.theme_ambient_text(td.theme)
      if text.length() > 0 {
        let alpha = (@math.sinf(game.anim_timer * 0.5F) * 40.0F + 60.0F).to_int()
        @draw.draw_text(
          text,
          @types.grid_offset_x,
          @types.screen_h - 30,
          12,
          @raylib.Color::new(
            td.accent_color.r.to_int(),
            td.accent_color.g.to_int(),
            td.accent_color.b.to_int(),
            @types.clampi(alpha, 20, 100),
          ),
        )
      }
    }
    None => ()
  }
}

///|
fn draw_combo_encouragement(game : @types.Game) -> Unit {
  let text = @types.combo_encouragement(game.beat.combo)
  if text.length() > 0 {
    let pulse = @math.sinf(game.anim_timer * 6.0F) * 0.3F + 0.7F
    let a = (pulse * 200.0F).to_int()
    let size = 16 + game.beat.combo / 10 * 2
    let capped_size = if size > 28 { 28 } else { size }
    draw_centered(
      text,
      @types.screen_w - 90,
      40,
      capped_size,
      @raylib.Color::new(255, 255, 200, a),
    )
  }
}

///|
fn draw_enemy_threat_markers(floor : @types.Floor) -> Unit {
  let ts = @types.tile_size
  for enemy in floor.enemies {
    if !enemy.active {
      continue
    }
    let threat = @types.enemy_threat_level(enemy)
    if threat.length() > 0 {
      let sx = @types.tile_screen_x(enemy.x)
      let sy = @types.tile_screen_y(enemy.y)
      @draw.draw_text(
        threat,
        sx + ts - 8 * threat.length(),
        sy + ts - 12,
        10,
        @raylib.Color::new(255, 80, 40, 180),
      )
    }
  }
}

///|
fn draw_player_direction_arrow(game : @types.Game) -> Unit {
  let ts = @types.tile_size
  let sx = @types.tile_screen_x(game.player.x)
  let sy = @types.tile_screen_y(game.player.y)
  let arrow = @types.direction_arrow(game.player.facing)
  let ax = sx + ts / 2 + @types.dir_dx(game.player.facing) * (ts / 3)
  let ay = sy + ts / 2 + @types.dir_dy(game.player.facing) * (ts / 3)
  @draw.draw_text(
    arrow,
    ax - 4,
    ay - 6,
    12,
    @raylib.Color::new(255, 255, 255, 140),
  )
}

///|
/// Draw spell cast indicators on the grid - shows AoE zones for active spells.
fn draw_spell_preview(game : @types.Game) -> Unit {
  let ts = @types.tile_size
  for i in 0..<4 {
    if @types.can_cast_spell(game.player, i) {
      match game.player.spell_slots.spells[i] {
        Some(kind) => {
          let data = @types.spell_data(kind)
          let sc = @types.spell_color(kind)
          let preview_alpha = (@math.sinf(game.anim_timer * 4.0F) * 15.0F +
          20.0F).to_int()
          let pc = @raylib.Color::new(
            sc.r.to_int(),
            sc.g.to_int(),
            sc.b.to_int(),
            @types.clampi(preview_alpha, 5, 35),
          )
          // Only show preview for AoE spells
          match kind {
            FrostNova | VoidPulse => {
              // Adjacent tiles
              let dirs : Array[@types.Direction] = [North, South, East, West]
              for dir in dirs {
                let tx = game.player.x + @types.dir_dx(dir)
                let ty = game.player.y + @types.dir_dy(dir)
                if @types.in_bounds(tx, ty, @types.grid_w, @types.grid_h) {
                  @raylib.draw_rectangle(
                    @types.tile_screen_x(tx) + 2,
                    @types.tile_screen_y(ty) + 2,
                    ts - 4,
                    ts - 4,
                    pc,
                  )
                }
              }
            }
            Inferno => {
              // 3x3 AoE
              let cx = game.player.x + @types.dir_dx(game.player.facing) * 2
              let cy = game.player.y + @types.dir_dy(game.player.facing) * 2
              for dy = -1; dy <= 1; dy = dy + 1 {
                for dx = -1; dx <= 1; dx = dx + 1 {
                  let tx = cx + dx
                  let ty = cy + dy
                  if @types.in_bounds(tx, ty, @types.grid_w, @types.grid_h) {
                    @raylib.draw_rectangle(
                      @types.tile_screen_x(tx) + 2,
                      @types.tile_screen_y(ty) + 2,
                      ts - 4,
                      ts - 4,
                      pc,
                    )
                  }
                }
              }
            }
            _ =>
              // Directional spells: show line in faced direction
              if data.range > 0 && data.range < 10 {
                let dir = game.player.facing
                for r in 1..<=data.range {
                  let tx = game.player.x + @types.dir_dx(dir) * r
                  let ty = game.player.y + @types.dir_dy(dir) * r
                  if @types.in_bounds(tx, ty, @types.grid_w, @types.grid_h) {
                    @raylib.draw_rectangle(
                      @types.tile_screen_x(tx) + 2,
                      @types.tile_screen_y(ty) + 2,
                      ts - 4,
                      ts - 4,
                      pc,
                    )
                  }
                }
              }
          }
        }
        None => ()
      }
    }
  }
}

///|
/// Draw enemy count and active elites info in corner.
fn draw_enemy_info_panel(game : @types.Game) -> Unit {
  guard game.floor is Some(floor) else { return }
  let total = @content.active_enemy_count(floor.enemies)
  let elites = @content.active_elite_count(floor.enemies)
  if total > 0 {
    let x = @types.screen_w - 180
    let y = 200
    @draw.draw_text(
      "Enemies: \{total}",
      x,
      y,
      14,
      @raylib.Color::new(255, 120, 100, 200),
    )
    if elites > 0 {
      @draw.draw_text(
        "Elites: \{elites}",
        x,
        y + 16,
        14,
        @types.color_elite_outline,
      )
    }
  }
}

///|
/// Draw mana regeneration effect (sparkle when gaining mana on Perfect).
fn draw_mana_regen_effect(game : @types.Game) -> Unit {
  if game.beat.last_rating == Perfect && game.player.mana < game.player.max_mana {
    let pulse = @beat.beat_pulse(game.beat)
    if pulse > 0.5F {
      let sx = @types.tile_screen_x(game.player.x) + @types.tile_size / 2
      let sy = @types.tile_screen_y(game.player.y)
      let alpha = (pulse * 200.0F).to_int()
      @draw.draw_text(
        "+M",
        sx - 6,
        sy - 12,
        10,
        @raylib.Color::new(80, 150, 255, @types.clampi(alpha, 0, 200)),
      )
    }
  }
}

///|
/// Draw enhanced special attack indicator.
fn draw_special_indicator(game : @types.Game) -> Unit {
  if game.player.special_charges > 0 {
    let ts = @types.tile_size
    let sx = @types.tile_screen_x(game.player.x)
    let sy = @types.tile_screen_y(game.player.y)
    let pulse = @math.sinf(game.anim_timer * 3.0F) * 0.3F + 0.7F
    let a = (pulse * 40.0F).to_int()
    // Show special range (adjacent tiles)
    let dirs : Array[@types.Direction] = [North, South, East, West]
    for dir in dirs {
      let tx = game.player.x + @types.dir_dx(dir)
      let ty = game.player.y + @types.dir_dy(dir)
      if @types.in_bounds(tx, ty, @types.grid_w, @types.grid_h) {
        let px = @types.tile_screen_x(tx)
        let py = @types.tile_screen_y(ty)
        @raylib.draw_rectangle(
          px + 2,
          py + 2,
          ts - 4,
          ts - 4,
          @raylib.Color::new(200, 150, 255, a),
        )
      }
    }
    // Special charge count on player
    let sc_text = "\{game.player.special_charges}"
    @draw.draw_text(
      sc_text,
      sx + 2,
      sy + ts - 12,
      10,
      @raylib.Color::new(200, 150, 255, 180),
    )
  }
}

///|
/// Draw floor info in the top-center area.
fn draw_floor_info_bar(game : @types.Game) -> Unit {
  guard game.floor is Some(floor) else { return }
  let cx = @types.screen_w / 2
  let theme_name = match game.floor_theme {
    Some(td) => td.name
    None => ""
  }
  if theme_name.length() > 0 {
    let alpha = 120
    draw_centered(
      "Floor \{floor.floor_num} - \{theme_name}",
      cx,
      2,
      14,
      @raylib.Color::new(180, 180, 200, alpha),
    )
  }
}

///|
/// Accumulated game time via frame time.
fn game_time() -> Float {
  @raylib.get_frame_time()
}

// ============================================================
// === Curse Offer Screen ===
// ============================================================

///|
fn draw_curse_offer(game : @types.Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(20, 10, 15, 255))
  let cx = @types.screen_w / 2
  draw_centered("BOSS DEFEATED!", cx, 80, 36, @types.color_perfect)
  draw_centered(
    "Accept a Curse? (Risk / Reward)",
    cx,
    130,
    22,
    @raylib.Color::new(200, 180, 160, 255),
  )
  let start_y = 200
  let item_h = 100
  for i, curse in game.curse_offers {
    let y = start_y + i * item_h
    let is_selected = i == game.curse_cursor
    let bg = if is_selected {
      @raylib.Color::new(60, 30, 40, 255)
    } else {
      @raylib.Color::new(30, 20, 25, 255)
    }
    let w = 450
    let x = cx - w / 2
    @raylib.draw_rectangle(x, y, w, item_h - 15, bg)
    if is_selected {
      @raylib.draw_rectangle_lines(
        x,
        y,
        w,
        item_h - 15,
        @types.curse_color(curse),
      )
    }
    let cc = @types.curse_color(curse)
    @draw.draw_text(
      @types.curse_name(curse),
      x + 20,
      y + 12,
      24,
      if is_selected {
        cc
      } else {
        @raylib.white
      },
    )
    @draw.draw_text(
      @types.curse_desc(curse),
      x + 20,
      y + 45,
      16,
      @raylib.Color::new(180, 180, 200, 200),
    )
  }
  // "Skip" option
  let skip_y = start_y + game.curse_offers.length() * item_h
  let is_skip = game.curse_cursor >= game.curse_offers.length()
  let skip_bg = if is_skip {
    @raylib.Color::new(40, 40, 50, 255)
  } else {
    @raylib.Color::new(25, 25, 35, 255)
  }
  let skip_w = 450
  let skip_x = cx - skip_w / 2
  @raylib.draw_rectangle(skip_x, skip_y, skip_w, 50, skip_bg)
  if is_skip {
    @raylib.draw_rectangle_lines(skip_x, skip_y, skip_w, 50, @raylib.white)
  }
  draw_centered("Skip (No Curse)", cx, skip_y + 15, 22, @raylib.white)
  // Active curses display
  if game.curses.active_curses.length() > 0 {
    let mut curse_str = "Active Curses: "
    for i, c in game.curses.active_curses {
      if i > 0 {
        curse_str = curse_str + ", "
      }
      curse_str = curse_str + @types.curse_name(c)
    }
    draw_centered(
      curse_str,
      cx,
      600,
      14,
      @raylib.Color::new(200, 150, 100, 180),
    )
  }
  let blink = if game.frame_count / 30 % 2 == 0 { 255 } else { 120 }
  draw_centered(
    "ENTER to select",
    cx,
    640,
    20,
    @raylib.Color::new(255, 255, 255, blink),
  )
}

// ============================================================
// === Damage Numbers ===
// ============================================================

///|
fn draw_damage_numbers(game : @types.Game) -> Unit {
  for dn in game.damage_numbers {
    let alpha = @types.clampf(dn.life / @types.damage_number_life, 0.0F, 1.0F)
    let a = (alpha * 255.0F).to_int()
    let c = @raylib.Color::new(
      dn.color.r.to_int(),
      dn.color.g.to_int(),
      dn.color.b.to_int(),
      a,
    )
    let size = 18 + (4.0F * (1.0F - alpha)).to_int()
    let text = dn.value.to_string()
    let w = @draw.measure_text(text, size)
    @draw.draw_text(text, dn.x.to_int() - w / 2, dn.y.to_int(), size, c)
  }
}

// ============================================================
// === Trail Particles ===
// ============================================================

///|
fn draw_trail_particles(game : @types.Game) -> Unit {
  for p in game.trail_particles {
    let alpha = @types.clampf(p.life / p.max_life, 0.0F, 1.0F)
    let a = (alpha * 255.0F).to_int()
    let color = @raylib.Color::new(p.r, p.g, p.b, a)
    let size = @types.maxf(p.size, 1.0F)
    @raylib.draw_rectangle(
      p.x.to_int(),
      p.y.to_int(),
      size.to_int(),
      size.to_int(),
      color,
    )
  }
}

// ============================================================
// === Achievement Toast ===
// ============================================================

///|
fn draw_achievement_toasts(game : @types.Game) -> Unit {
  let toasts = game.achievements.toasts
  for i, toast in toasts {
    let alpha = @types.clampf(toast.timer / 1.0F, 0.0F, 1.0F)
    let a = (alpha * 255.0F).to_int()
    let y = 10 + i * 30
    let text = toast.text
    let w = @draw.measure_text(text, 18) + 20
    let x = @types.screen_w / 2 - w / 2
    @raylib.draw_rectangle(x, y, w, 25, @raylib.Color::new(40, 30, 60, a))
    @raylib.draw_rectangle_lines(
      x,
      y,
      w,
      25,
      @raylib.Color::new(255, 215, 0, a),
    )
    draw_centered(
      text,
      @types.screen_w / 2,
      y + 4,
      16,
      @raylib.Color::new(255, 215, 0, a),
    )
  }
}

// ============================================================
// === Elite Enemy Golden Outline ===
// ============================================================

///|
fn draw_elite_indicator(
  enemy : @types.Enemy,
  sx : Int,
  sy : Int,
  ts : Int,
) -> Unit {
  if enemy.is_elite {
    // Golden outline
    @raylib.draw_rectangle_lines(
      sx + 1,
      sy + 1,
      ts - 2,
      ts - 2,
      @types.color_elite_outline,
    )
    @raylib.draw_rectangle_lines(
      sx + 2,
      sy + 2,
      ts - 4,
      ts - 4,
      @types.color_elite_outline,
    )
    // "E" marker
    @draw.draw_text("E", sx + ts - 12, sy + 3, 10, @types.color_elite_outline)
  }
  // Frozen indicator
  if enemy.frozen_beats > 0 {
    @raylib.draw_rectangle(
      sx + 4,
      sy + 4,
      ts - 8,
      ts - 8,
      @raylib.Color::new(100, 200, 255, 60),
    )
  }
  // Stun indicator
  if enemy.stunned_beats > 0 {
    @raylib.draw_rectangle(
      sx + 4,
      sy + 4,
      ts - 8,
      ts - 8,
      @raylib.Color::new(255, 255, 100, 50),
    )
    draw_centered_at(
      "!",
      sx + ts / 2,
      sy + ts / 2,
      14,
      @raylib.Color::new(255, 255, 100, 200),
    )
  }
}

// ============================================================
// === Spell Slots HUD ===
// ============================================================

///|
fn draw_spell_hud(game : @types.Game) -> Unit {
  let px = 10
  let py = 400
  @draw.draw_text(
    "Mana: \{game.player.mana}/\{game.player.max_mana}",
    px,
    py,
    16,
    @raylib.Color::new(100, 150, 255, 255),
  )
  // Mana bar
  let bar_w = 120
  let mana_frac = Float::from_int(game.player.mana) /
    Float::from_int(game.player.max_mana)
  let filled = (Float::from_int(bar_w) * mana_frac).to_int()
  @raylib.draw_rectangle(px, py + 20, bar_w, 6, @raylib.darkgray)
  @raylib.draw_rectangle(
    px,
    py + 20,
    filled,
    6,
    @raylib.Color::new(80, 120, 255, 255),
  )
  // Spell slots
  for i in 0..<4 {
    let slot_y = py + 35 + i * 22
    let slot_text = match game.player.spell_slots.spells[i] {
      None => "\{i + 1}: ---"
      Some(kind) => {
        let data = @types.spell_data(kind)
        let cd = game.player.spell_slots.cooldowns[i]
        let cd_str = if cd > 0 { " [CD:\{cd}]" } else { "" }
        "\{i + 1}: \{data.name}\{cd_str}"
      }
    }
    let color = match game.player.spell_slots.spells[i] {
      None => @raylib.Color::new(100, 100, 120, 150)
      Some(kind) =>
        if @types.can_cast_spell(game.player, i) {
          @types.spell_color(kind)
        } else {
          @raylib.Color::new(100, 100, 120, 180)
        }
    }
    @draw.draw_text(slot_text, px, slot_y, 13, color)
  }
}

// ============================================================
// === Boss Health Bar with Phase Indicators ===
// ============================================================

///|
fn draw_boss_health_bar(game : @types.Game) -> Unit {
  guard game.floor is Some(floor) else { return }
  if !game.is_boss_floor {
    return
  }
  for enemy in floor.enemies {
    if !enemy.active {
      continue
    }
    match enemy.kind {
      BeatDragon | RhythmLich => {
        let bar_w = 300
        let bar_h = 16
        let x = @types.screen_w / 2 - bar_w / 2
        let y = 40
        // Background
        @raylib.draw_rectangle(
          x - 2,
          y - 2,
          bar_w + 4,
          bar_h + 4,
          @raylib.Color::new(40, 20, 20, 220),
        )
        // HP fill
        let hp_frac = Float::from_int(enemy.hp) / Float::from_int(enemy.max_hp)
        let filled = (Float::from_int(bar_w) * hp_frac).to_int()
        @raylib.draw_rectangle(x, y, bar_w, bar_h, @raylib.darkgray)
        let bar_color = if hp_frac > 0.5F {
          @raylib.Color::new(255, 200, 0, 255)
        } else if hp_frac > 0.3F {
          @raylib.Color::new(255, 140, 0, 255)
        } else {
          @raylib.Color::new(255, 60, 40, 255)
        }
        @raylib.draw_rectangle(x, y, filled, bar_h, bar_color)
        // Phase markers
        let phase2_x = match enemy.kind {
          BeatDragon => x + bar_w / 2 // 50%
          _ => x + bar_w * 30 / 100
        } // 30% for Lich
        @raylib.draw_rectangle(
          phase2_x,
          y,
          2,
          bar_h,
          @raylib.Color::new(255, 255, 255, 120),
        )
        // Boss name and HP text
        let name = match enemy.kind {
          BeatDragon => "Beat Dragon"
          RhythmLich => "Rhythm Lich"
          _ => "Boss"
        }
        draw_centered(
          "\{name}: \{enemy.hp}/\{enemy.max_hp}",
          @types.screen_w / 2,
          y + bar_h + 4,
          14,
          @raylib.Color::new(255, 200, 150, 220),
        )
      }
      _ => ()
    }
  }
}

// ============================================================
// === Active Curses Display ===
// ============================================================

///|
fn draw_active_curses(game : @types.Game) -> Unit {
  if game.curses.active_curses.length() == 0 {
    return
  }
  let x = @types.screen_w - 180
  let mut y = 140
  @draw.draw_text("Curses:", x, y, 14, @raylib.Color::new(200, 100, 80, 200))
  y = y + 16
  for curse in game.curses.active_curses {
    let cc = @types.curse_color(curse)
    @draw.draw_text(@types.curse_name(curse), x, y, 12, cc)
    y = y + 14
  }
}

// ============================================================
// === Screen Pulse (BPM-based intensity) ===
// ============================================================

///|
fn draw_screen_pulse(game : @types.Game) -> Unit {
  let pulse = @beat.beat_pulse(game.beat)
  let intensity = @types.screen_pulse_for_bpm(game.beat.bpm)
  let alpha = (pulse * intensity * 30.0F).to_int()
  if alpha > 1 {
    @raylib.draw_rectangle(
      0,
      0,
      @types.screen_w,
      @types.screen_h,
      @raylib.Color::new(255, 255, 255, @types.clampi(alpha, 0, 40)),
    )
  }
}

// ============================================================
// === BPM Counter Animation ===
// ============================================================

///|
fn draw_bpm_animation(game : @types.Game) -> Unit {
  if game.bpm_anim_timer <= 0.0F {
    return
  }
  let cx = @types.screen_w / 2
  let cy = @types.screen_h / 2
  let alpha = @types.clampf(game.bpm_anim_timer / 1.0F, 0.0F, 1.0F)
  let a = (alpha * 255.0F).to_int()
  let bpm_int = game.bpm_anim_value.to_int()
  let text = "\{bpm_int} BPM"
  let size = 36 + ((1.0F - alpha) * 12.0F).to_int()
  draw_centered(text, cx, cy + 60, size, @raylib.Color::new(255, 200, 100, a))
}

// ============================================================
// === Weapon Visual Effects ===
// ============================================================

///|
fn draw_weapon_effects(game : @types.Game) -> Unit {
  for ef in game.weapon_effects {
    let progress = 1.0F - ef.timer / ef.max_timer
    let alpha = ((1.0F - progress) * 220.0F).to_int()
    let color = @types.weapon_effect_color(ef.kind)
    let c = @raylib.Color::new(
      color.r.to_int(),
      color.g.to_int(),
      color.b.to_int(),
      @types.clampi(alpha, 0, 255),
    )
    let dx = @types.dir_dx(ef.direction)
    let dy = @types.dir_dy(ef.direction)
    let ts = @types.tile_size
    match ef.kind {
      Sword => {
        // White slash arc animation - 3 frame stages
        let sweep = progress * 3.14159F
        let radius = Float::from_int(ts) * 0.7F
        let base_angle = match ef.direction {
          North => -1.57F
          South => 1.57F
          East => 0.0F
          West => 3.14159F
        }
        let arc_start = base_angle - 0.8F + sweep * 0.5F
        let arc_end = base_angle + 0.8F - sweep * 0.3F
        let steps = 8
        for i in 0..<steps {
          let t = Float::from_int(i) / Float::from_int(steps)
          let angle = arc_start + (arc_end - arc_start) * t
          let px = ef.x + radius * @types.cos_approx(angle)
          let py = ef.y + radius * @types.sin_approx(angle)
          let size = 3.0F * (1.0F - progress)
          @raylib.draw_rectangle(
            px.to_int(),
            py.to_int(),
            size.to_int() + 1,
            size.to_int() + 1,
            c,
          )
        }
      }
      Spear => {
        // Thrust line animation
        let length = Float::from_int(ts) * (0.5F + progress * 1.5F)
        let fx = Float::from_int(dx)
        let fy = Float::from_int(dy)
        let ex = ef.x + fx * length
        let ey = ef.y + fy * length
        @raylib.draw_line(
          ef.x.to_int(),
          ef.y.to_int(),
          ex.to_int(),
          ey.to_int(),
          c,
        )
        @raylib.draw_circle(
          ex.to_int(),
          ey.to_int(),
          3.0F * (1.0F - progress),
          c,
        )
      }
      Whip => {
        // Curved line trail
        let steps = 10
        let reach = Float::from_int(ts) * 1.2F * (0.3F + progress * 0.7F)
        for i in 0..<steps {
          let t = Float::from_int(i) / Float::from_int(steps)
          let wave = @math.sinf(t * 3.14159F + progress * 6.0F) * 12.0F
          let fx = Float::from_int(dx)
          let fy = Float::from_int(dy)
          let perpx = Float::from_int(0 - dy)
          let perpy = Float::from_int(dx)
          let px = ef.x + fx * reach * t + perpx * wave
          let py = ef.y + fy * reach * t + perpy * wave
          let size = 2.0F * (1.0F - t) * (1.0F - progress)
          @raylib.draw_rectangle(
            px.to_int(),
            py.to_int(),
            @types.maxf(size, 1.0F).to_int(),
            @types.maxf(size, 1.0F).to_int(),
            c,
          )
        }
      }
      Hammer => {
        // Impact circle with expanding ring
        let radius = Float::from_int(ts) * 0.5F * (0.3F + progress * 1.5F)
        let impact_x = ef.x + Float::from_int(dx * ts)
        let impact_y = ef.y + Float::from_int(dy * ts)
        let thickness = @types.maxf(3.0F * (1.0F - progress), 1.0F)
        // Inner circle
        @raylib.draw_circle(impact_x.to_int(), impact_y.to_int(), thickness, c)
        // Expanding ring
        let ring_r = radius
        let ring_steps = 16
        for i in 0..<ring_steps {
          let angle = Float::from_int(i) * 6.28F / Float::from_int(ring_steps)
          let rx = impact_x + ring_r * @types.cos_approx(angle)
          let ry = impact_y + ring_r * @types.sin_approx(angle)
          @raylib.draw_rectangle(rx.to_int(), ry.to_int(), 2, 2, c)
        }
      }
      Bow => {
        // Arrow projectile trail (fast line)
        let speed = Float::from_int(ts) * 3.0F
        let travel = speed * progress
        let fx = Float::from_int(dx)
        let fy = Float::from_int(dy)
        let head_x = ef.x + fx * travel
        let head_y = ef.y + fy * travel
        let tail_len = 20.0F * (1.0F - progress * 0.5F)
        let tail_x = head_x - fx * tail_len
        let tail_y = head_y - fy * tail_len
        @raylib.draw_line(
          tail_x.to_int(),
          tail_y.to_int(),
          head_x.to_int(),
          head_y.to_int(),
          c,
        )
        // Arrowhead
        @raylib.draw_circle(head_x.to_int(), head_y.to_int(), 2.0F, c)
      }
      Staff => {
        // Expanding circle pulse
        let max_r = Float::from_int(ts) * 1.5F
        let radius = max_r * progress
        let steps = 24
        let ring_alpha = ((1.0F - progress) * 200.0F).to_int()
        let rc = @raylib.Color::new(
          color.r.to_int(),
          color.g.to_int(),
          color.b.to_int(),
          @types.clampi(ring_alpha, 0, 255),
        )
        for i in 0..<steps {
          let angle = Float::from_int(i) * 6.28F / Float::from_int(steps)
          let px = ef.x + radius * @types.cos_approx(angle)
          let py = ef.y + radius * @types.sin_approx(angle)
          @raylib.draw_rectangle(px.to_int(), py.to_int(), 2, 2, rc)
        }
      }
    }
  }
}

// ============================================================
// === Enhanced Boss Intro ===
// ============================================================

///|
fn draw_enhanced_boss_intro(game : @types.Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(10, 5, 15, 255))
  let cx = @types.screen_w / 2
  let cy = @types.screen_h / 2
  let progress = 1.0F - game.boss_intro_timer / @types.boss_intro_duration
  let alpha = @types.clampf(progress * 3.0F, 0.0F, 1.0F)
  let a = (alpha * 255.0F).to_int()
  // Dramatic background darken pulse
  let darken_pulse = @math.sinf(progress * 8.0F) * 20.0F
  let dark_a = (darken_pulse + 30.0F).to_int()
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(0, 0, 0, @types.clampi(dark_a, 0, 60)),
  )
  // Pulsing boss name text
  let name_pulse = @math.sinf(progress * 12.0F) * 0.2F + 0.8F
  let name_alpha = (alpha * name_pulse * 255.0F).to_int()
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
  // "BOSS!" with growing size
  let boss_size = 60 + (progress * 20.0F).to_int()
  draw_centered(
    "BOSS!",
    cx + sx,
    cy - 80 + sy_off,
    boss_size,
    @raylib.Color::new(255, 40, 40, @types.clampi(name_alpha, 0, 255)),
  )
  // Boss name and shape preview
  guard game.floor is Some(floor) else { return }
  let boss_name = if floor.floor_num == 5 {
    "THE BEAT DRAGON"
  } else {
    "THE RHYTHM LICH"
  }
  let boss_color = if floor.floor_num == 5 {
    @raylib.Color::new(255, 120, 40, @types.clampi(a, 0, 255))
  } else {
    @raylib.Color::new(160, 60, 255, @types.clampi(a, 0, 255))
  }
  // Boss shape preview - pulsing rectangle
  let shape_size = 40 + (@math.sinf(progress * 6.0F) * 8.0F).to_int()
  let shape_alpha = (alpha * 150.0F).to_int()
  let shape_color = @raylib.Color::new(
    boss_color.r.to_int(),
    boss_color.g.to_int(),
    boss_color.b.to_int(),
    @types.clampi(shape_alpha, 0, 180),
  )
  @raylib.draw_rectangle(
    cx - shape_size / 2,
    cy - 20 - shape_size / 2,
    shape_size,
    shape_size,
    shape_color,
  )
  @raylib.draw_rectangle_lines(
    cx - shape_size / 2 - 2,
    cy - 20 - shape_size / 2 - 2,
    shape_size + 4,
    shape_size + 4,
    boss_color,
  )
  draw_centered(boss_name, cx, cy + 40, 28, boss_color)
  // Phase info
  draw_centered(
    "3 Phases - Adapts as HP drops",
    cx,
    cy + 75,
    16,
    @raylib.Color::new(
      200,
      180,
      160,
      @types.clampi((alpha * 180.0F).to_int(), 0, 200),
    ),
  )
  // Countdown hint with dramatic entrance
  if progress > 0.5F {
    let hint_a = ((progress - 0.5F) * 2.0F * 255.0F).to_int()
    draw_centered(
      "Prepare yourself...",
      cx,
      cy + 110,
      20,
      @raylib.Color::new(180, 180, 200, @types.clampi(hint_a, 0, 255)),
    )
  }
}

// ============================================================
// === Enhanced Floor Transition (Wipe Effect) ===
// ============================================================

///|
fn draw_enhanced_floor_transition(game : @types.Game) -> Unit {
  @raylib.clear_background(@types.color_bg)
  let cx = @types.screen_w / 2
  let cy = @types.screen_h / 2
  let floor_num = game.transition_floor
  let progress = 1.0F - game.transition_timer / @types.floor_transition_duration
  // Wipe effect - horizontal reveal
  let wipe_x = (progress * Float::from_int(@types.screen_w) * 1.2F).to_int()
  // Background wipe bar
  @raylib.draw_rectangle(
    0,
    0,
    wipe_x,
    @types.screen_h,
    @raylib.Color::new(15, 15, 30, 200),
  )
  // Wipe edge glow
  if wipe_x > 0 && wipe_x < @types.screen_w {
    let edge_height = @types.screen_h
    let glow_w = 6
    @raylib.draw_rectangle(
      wipe_x - glow_w,
      0,
      glow_w * 2,
      edge_height,
      @raylib.Color::new(80, 200, 255, 100),
    )
  }
  let alpha = @types.clampf(progress * 2.0F, 0.0F, 1.0F)
  let a = (alpha * 255.0F).to_int()
  let size = 48 + (progress * 20.0F).to_int()
  draw_centered(
    "FLOOR \{floor_num}",
    cx,
    cy - 60,
    size,
    @raylib.Color::new(80, 200, 255, @types.clampi(a, 0, 255)),
  )
  // Theme name
  let theme = @types.floor_theme(floor_num)
  let td = @types.theme_data(theme)
  draw_centered(
    td.name,
    cx,
    cy,
    24,
    @raylib.Color::new(
      td.accent_color.r.to_int(),
      td.accent_color.g.to_int(),
      td.accent_color.b.to_int(),
      @types.clampi(a, 0, 255),
    ),
  )
  // BPM display
  let bpm = @types.bpm_for_floor(floor_num)
  draw_centered(
    "\{bpm.to_int()} BPM",
    cx,
    cy + 40,
    28,
    @raylib.Color::new(255, 200, 100, @types.clampi(a, 0, 255)),
  )
  // Boss warning
  if @types.is_boss_floor(floor_num) {
    let blink = if game.frame_count / 10 % 2 == 0 { a } else { a / 2 }
    draw_centered(
      "BOSS BATTLE!",
      cx,
      cy + 90,
      32,
      @raylib.Color::new(255, 40, 40, @types.clampi(blink, 0, 255)),
    )
  }
  // BPM counter animation
  draw_bpm_animation(game)
}

// ============================================================
// === Weapon Switch Flash ===
// ============================================================

///|
fn draw_weapon_switch_flash(game : @types.Game) -> Unit {
  if game.weapon_switch_flash > 0.0F {
    let alpha = (game.weapon_switch_flash /
    @types.weapon_switch_flash_duration *
    150.0F).to_int()
    let wc = @types.weapon_color(game.player.weapon)
    let c = @raylib.Color::new(
      wc.r.to_int(),
      wc.g.to_int(),
      wc.b.to_int(),
      @types.clampi(alpha, 0, 150),
    )
    // Flash overlay on player area
    let sx = @types.tile_screen_x(game.player.x)
    let sy = @types.tile_screen_y(game.player.y)
    let ts = @types.tile_size
    @raylib.draw_rectangle(sx - 4, sy - 4, ts + 8, ts + 8, c)
    // Weapon name text briefly
    let name = @types.weapon_data(game.player.weapon).name
    draw_centered_at(
      name,
      sx + ts / 2,
      sy - 12,
      12,
      @raylib.Color::new(255, 255, 255, @types.clampi(alpha, 0, 200)),
    )
  }
}

// ============================================================
// === Combo Milestone Celebration Text ===
// ============================================================

///|
fn draw_milestone_celebration(game : @types.Game) -> Unit {
  let cs = game.combo_state
  if cs.milestone_flash_timer > 0.3F {
    let ms = cs.last_milestone
    let text = @types.milestone_text(ms)
    if text.length() > 0 {
      let mc = @types.milestone_color(ms)
      let progress = cs.milestone_flash_timer / 1.5F
      let size_boost = (progress * 12.0F).to_int()
      let base_size = 32 + size_boost
      let pulse = @math.sinf(game.anim_timer * 8.0F) * 0.2F + 0.8F
      let alpha = (progress * pulse * 255.0F).to_int()
      let color = @raylib.Color::new(
        mc.r.to_int(),
        mc.g.to_int(),
        mc.b.to_int(),
        @types.clampi(alpha, 0, 255),
      )
      let cx = @types.screen_w / 2
      let y_offset = ((1.0F - progress) * 20.0F).to_int()
      draw_centered(text, cx, 520 - y_offset, base_size, color)
    }
  }
}

// ============================================================
// === Enhanced Beat Indicator ===
// ============================================================

///|
fn draw_enhanced_beat_indicator(beat : @types.BeatState) -> Unit {
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
  // Enhanced: larger pulse on perfect hits
  if beat.last_rating == Perfect {
    let pulse = @beat.beat_pulse(beat)
    if pulse > 0.3F {
      let pulse_size = (pulse * 8.0F).to_int()
      let pulse_alpha = (pulse * 120.0F).to_int()
      @raylib.draw_rectangle(
        indicator_x - 3 - pulse_size / 2,
        y,
        6 + pulse_size,
        h,
        @raylib.Color::new(255, 215, 0, @types.clampi(pulse_alpha, 0, 120)),
      )
    }
  }
  // Visual feedback trail - fading trail of last positions
  let trail_alpha = 40
  let trail_offset = 20
  let trail_x = indicator_x - trail_offset
  if trail_x > 0 {
    @raylib.draw_rectangle(
      trail_x,
      y + h / 2 - 1,
      trail_offset,
      2,
      @raylib.Color::new(
        indicator_color.r.to_int(),
        indicator_color.g.to_int(),
        indicator_color.b.to_int(),
        trail_alpha,
      ),
    )
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

// ============================================================
// === Enhanced Run Summary with Detailed Stats ===
// ============================================================

///|
fn draw_enhanced_run_summary(game : @types.Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(12, 8, 20, 255))
  let cx = @types.screen_w / 2
  let is_win = game.floors_cleared >= @types.max_floor
  let title = if is_win { "VICTORY!" } else { "RUN OVER" }
  let title_color = if is_win {
    @types.color_perfect
  } else {
    @types.color_miss
  }
  draw_centered(title, cx, 30, 36, title_color)
  // Score and grade
  let grade = @types.compute_score_grade(game.score)
  draw_centered("Score: \{game.score}", cx, 68, 24, @raylib.white)
  draw_centered(
    "Grade: \{@types.grade_text(grade)}",
    cx,
    95,
    32,
    @types.grade_color(grade),
  )
  // Grade distance
  let dist_text = @types.grade_distance_text(game.score)
  draw_centered(dist_text, cx, 125, 14, @raylib.Color::new(180, 180, 200, 180))
  // Core stats (compact)
  let sy = 148
  draw_centered(
    "Floors: \{game.floors_cleared}  Combo: \{game.beat.max_combo}  Kills: \{game.run_kills}  Perfects: \{game.run_perfects}",
    cx,
    sy,
    16,
    @raylib.Color::new(180, 180, 200, 230),
  )
  // Weapon info
  let wd = @types.weapon_data(game.player.weapon)
  draw_centered(
    "Final Weapon: \{wd.name}",
    cx,
    sy + 22,
    16,
    @types.weapon_color(game.player.weapon),
  )
  // Weapon usage distribution
  let (best_weapon, best_count) = @types.most_used_weapon(game.run_stats)
  if best_count > 0 {
    draw_centered(
      "Most Used: \{@types.weapon_data(best_weapon).name} (\{best_count} attacks)",
      cx,
      sy + 42,
      14,
      @types.weapon_color(best_weapon),
    )
  }
  // Spell usage
  if game.run_stats.total_spells_cast > 0 {
    let mut spell_str = "Spells Cast: \{game.run_stats.total_spells_cast}"
    if game.run_stats.spell_usage.length() > 0 {
      spell_str = spell_str + " ("
      for i, su in game.run_stats.spell_usage {
        let (sk, count) = su
        if i > 0 {
          spell_str = spell_str + ", "
        }
        spell_str = spell_str + "\{@types.spell_data(sk).name}:\{count}"
      }
      spell_str = spell_str + ")"
    }
    draw_centered(
      spell_str,
      cx,
      sy + 62,
      13,
      @raylib.Color::new(100, 180, 255, 200),
    )
  }
  // Damage stats
  draw_centered(
    "Damage Dealt: \{game.run_stats.total_damage_dealt}  Taken: \{game.run_stats.total_damage_taken}  Items: \{game.run_stats.total_items}",
    cx,
    sy + 82,
    13,
    @raylib.Color::new(160, 160, 180, 180),
  )
  // Active curses
  if game.curses.active_curses.length() > 0 {
    let mut curse_str = "Curses: "
    for i, c in game.curses.active_curses {
      if i > 0 {
        curse_str = curse_str + ", "
      }
      curse_str = curse_str + @types.curse_name(c)
    }
    draw_centered(
      curse_str,
      cx,
      sy + 100,
      13,
      @raylib.Color::new(200, 100, 80, 200),
    )
  }
  // Score breakdown
  let bd_y = sy + 120
  draw_centered(
    "--- Score Breakdown ---",
    cx,
    bd_y,
    16,
    @raylib.Color::new(140, 140, 160, 255),
  )
  draw_centered(
    "Kill Score: \{game.score_state.base_kills}",
    cx,
    bd_y + 20,
    14,
    @raylib.Color::new(160, 160, 180, 200),
  )
  draw_centered(
    "Beat Bonus: \{game.score_state.beat_bonus}",
    cx,
    bd_y + 38,
    14,
    @types.color_perfect,
  )
  draw_centered(
    "Combo Bonus: \{game.score_state.combo_bonus}",
    cx,
    bd_y + 56,
    14,
    @types.color_good,
  )
  draw_centered(
    "Floor Bonus: \{game.score_state.floor_bonus}",
    cx,
    bd_y + 74,
    14,
    @raylib.Color::new(200, 200, 100, 255),
  )
  // Floor-by-floor breakdown (compact, scrollable if many floors)
  if game.run_stats.floor_history.length() > 0 {
    let fh_y = bd_y + 98
    draw_centered(
      "--- Floor History ---",
      cx,
      fh_y,
      16,
      @raylib.Color::new(140, 140, 160, 255),
    )
    let max_shown = if game.run_stats.floor_history.length() > 6 {
      6
    } else {
      game.run_stats.floor_history.length()
    }
    for i in 0..<max_shown {
      let fs = game.run_stats.floor_history[i]
      let text = "F\{fs.floor_num}: K\{fs.enemies_killed} P\{fs.perfects_hit} I\{fs.items_collected} S\{fs.spells_cast} D+\{fs.damage_dealt}/-\{fs.damage_taken}"
      draw_centered(
        text,
        cx,
        fh_y + 20 + i * 16,
        12,
        @raylib.Color::new(150, 150, 170, 180),
      )
    }
    if game.run_stats.floor_history.length() > 6 {
      draw_centered(
        "... and \{game.run_stats.floor_history.length() - 6} more floors",
        cx,
        fh_y + 20 + 6 * 16,
        11,
        @raylib.Color::new(120, 120, 140, 150),
      )
    }
  }
  // Meta progress comparison
  let meta = game.meta
  let meta_y = if game.run_stats.floor_history.length() > 0 {
    let fh_y = sy + 120 + 98
    let shown = if game.run_stats.floor_history.length() > 6 {
      7
    } else {
      game.run_stats.floor_history.length()
    }
    fh_y + 20 + shown * 16 + 10
  } else {
    sy + 120 + 100
  }
  draw_centered(
    "--- Personal Best ---",
    cx,
    meta_y,
    14,
    @raylib.Color::new(140, 140, 160, 200),
  )
  let is_new_best = game.score >= meta.best_score && game.score > 0
  let best_color = if is_new_best {
    @types.color_perfect
  } else {
    @raylib.Color::new(120, 120, 150, 200)
  }
  let best_prefix = if is_new_best { "NEW BEST! " } else { "" }
  draw_centered(
    "\{best_prefix}Best: \{meta.best_score}  Combo: \{meta.highest_combo}  Runs: \{meta.total_runs}",
    cx,
    meta_y + 18,
    13,
    best_color,
  )
  // Achievements
  let mut ach_str = ""
  for a in game.achievements.achievements {
    if a.unlocked {
      if ach_str.length() > 0 {
        ach_str = ach_str + ", "
      }
      ach_str = ach_str + a.name
    }
  }
  if ach_str.length() > 0 {
    draw_centered(
      "Achievements: \{ach_str}",
      cx,
      meta_y + 36,
      12,
      @raylib.Color::new(255, 215, 0, 180),
    )
  }
  let blink = if game.frame_count / 30 % 2 == 0 { 255 } else { 120 }
  draw_centered(
    "Press ENTER to play again",
    cx,
    680,
    20,
    @raylib.Color::new(255, 255, 255, blink),
  )
  // Message
  if game.message_timer > 0.0F {
    draw_centered(game.message_text, cx, 700, 16, @types.color_perfect)
  }
}

// ============================================================
// === Boss Phase Indicator on Health Bar ===
// ============================================================

///|
fn draw_boss_phase_indicator(game : @types.Game) -> Unit {
  guard game.floor is Some(floor) else { return }
  if !game.is_boss_floor {
    return
  }
  for enemy in floor.enemies {
    if !enemy.active {
      continue
    }
    match enemy.kind {
      BeatDragon => {
        let phase = game.boss_phases.dragon_phase
        let pc = @types.boss_phase_color(phase)
        let text = @types.boss_phase_name(phase)
        @draw.draw_text(text, @types.screen_w / 2 + 160, 42, 14, pc)
      }
      RhythmLich => {
        let phase = game.boss_phases.lich_phase
        let pc = @types.boss_phase_color(phase)
        let text = @types.boss_phase_name(phase)
        @draw.draw_text(text, @types.screen_w / 2 + 160, 42, 14, pc)
      }
      _ => ()
    }
  }
}
