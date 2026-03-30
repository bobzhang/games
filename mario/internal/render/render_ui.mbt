// ── UI color constants ──

///|
let hud_bg : @raylib.Color = @raylib.Color::new(0, 0, 0, 160)

///|
let hud_white : @raylib.Color = @raylib.Color::new(252, 252, 252, 255)

///|
let hud_yellow : @raylib.Color = @raylib.Color::new(252, 200, 32, 255)

///|
let hud_coin : @raylib.Color = @raylib.Color::new(252, 200, 32, 255)

///|
let overlay_bg : @raylib.Color = @raylib.Color::new(0, 0, 0, 180)

///|
/// Draw the HUD and any state-specific overlays.
pub fn draw_ui(game : @types.Game) -> Unit {
  match game.state {
    Title => draw_title_screen(game)
    LevelIntro => draw_level_intro(game)
    Playing | LevelClear | BonusRoom => {
      draw_hud(game)
      // Draw fade overlay for bonus room transitions
      draw_fade_overlay(game)
    }
    Paused => {
      draw_hud(game)
      draw_pause_overlay(game)
    }
    LevelTally => draw_level_tally_screen(game)
    PlayerDied => draw_hud(game)
    GameOver => draw_game_over(game)
    Victory => draw_victory(game)
  }
  @fps.draw()
}

///|
fn draw_hud(game : @types.Game) -> Unit {
  // Top bar background
  @raylib.draw_rectangle(0, 0, @types.screen_w, 36, hud_bg)
  // MARIO label + score
  @draw.draw_text("MARIO", 30, 4, 16, hud_white)
  let score_str = game.score.to_string()
  @draw.draw_text(score_str, 30, 18, 16, hud_white)
  // Coins (animated coin icon)
  let coin_phase = game.frame_counter / 8 % 4
  let coin_w = match coin_phase {
    0 => 10
    1 => 6
    2 => 2
    _ => 6
  }
  let coin_x = 220 + (10 - coin_w) / 2
  @raylib.draw_rectangle(coin_x, 6, coin_w, 16, hud_coin)
  if coin_w > 4 {
    @raylib.draw_rectangle(
      coin_x + 1,
      8,
      coin_w / 3,
      12,
      @raylib.Color::new(252, 228, 120, 255),
    )
  }
  let coin_text = "x" +
    (if game.coins < 10 { "0" } else { "" }) +
    game.coins.to_string()
  @draw.draw_text(coin_text, 236, 10, 16, hud_white)
  // World
  @draw.draw_text("WORLD", 400, 4, 16, hud_white)
  let world_text = game.world_num.to_string() + "-" + game.level_num.to_string()
  @draw.draw_text(world_text, 410, 18, 16, hud_white)
  // Time
  @draw.draw_text("TIME", 600, 4, 16, hud_white)
  let time_text = game.time_remaining.to_int().to_string()
  @draw.draw_text(time_text, 608, 18, 16, hud_white)
  // Lives
  let lives_text = "x" + game.lives.to_string()
  @draw.draw_text(lives_text, 780, 10, 16, hud_white)
  @raylib.draw_rectangle(760, 6, 12, 6, @raylib.Color::new(228, 0, 0, 255))
  @raylib.draw_rectangle(762, 12, 8, 6, @raylib.Color::new(252, 188, 116, 255))
  @raylib.draw_rectangle(760, 18, 12, 8, @raylib.Color::new(32, 64, 200, 255))
  // Power state indicator
  let power_text = match game.player.power {
    Small => ""
    Big => "[BIG]"
    Fire => "[FIRE]"
  }
  if power_text.length() > 0 {
    @draw.draw_text(power_text, 860, 10, 16, hud_yellow)
  }
  // Star timer
  if game.player.star_timer > 0.0 {
    let star_text = "STAR:" + game.player.star_timer.to_int().to_string()
    @draw.draw_text(
      star_text,
      860,
      10,
      16,
      @types.star_color(game.frame_counter / 3 % 5),
    )
  }
  // Bonus room indicator
  if game.in_bonus_room {
    let br_text = "BONUS ROOM!"
    let br_tw = @draw.measure_text(br_text, 20)
    @draw.draw_text(
      br_text,
      480 - br_tw / 2,
      42,
      20,
      @raylib.Color::new(252, 228, 0, 255),
    )
  }
}

///|
fn draw_title_screen(game : @types.Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(92, 148, 252, 255))
  for i in 0..<5 {
    let cx = 100 + i * 200
    let cy = 80 + i * 47 % 120
    @raylib.draw_ellipse(cx, cy, 50, 25, @raylib.Color::new(252, 252, 252, 200))
    @raylib.draw_ellipse(
      cx + 30,
      cy - 10,
      35,
      20,
      @raylib.Color::new(252, 252, 252, 200),
    )
    @raylib.draw_ellipse(
      cx - 25,
      cy - 5,
      30,
      18,
      @raylib.Color::new(252, 252, 252, 200),
    )
  }
  @raylib.draw_rectangle(0, 560, 960, 160, @raylib.Color::new(192, 96, 0, 255))
  @raylib.draw_rectangle(0, 552, 960, 12, @raylib.Color::new(0, 188, 0, 255))
  @raylib.draw_rectangle(230, 180, 500, 120, @raylib.Color::new(228, 0, 0, 255))
  @raylib.draw_rectangle(234, 184, 492, 112, @raylib.Color::new(148, 0, 0, 255))
  @raylib.draw_rectangle(238, 188, 484, 104, @raylib.Color::new(228, 0, 0, 255))
  let title1 = "SUPER"
  let title2 = "MARIO"
  let tw1 = @draw.measure_text(title1, 60)
  let tw2 = @draw.measure_text(title2, 60)
  @draw.draw_text(
    title1,
    480 - tw1 / 2 + 3,
    198 + 3,
    60,
    @raylib.Color::new(100, 0, 0, 255),
  )
  @draw.draw_text(
    title1,
    480 - tw1 / 2,
    198,
    60,
    @raylib.Color::new(252, 252, 252, 255),
  )
  @draw.draw_text(
    title2,
    480 - tw2 / 2 + 3,
    253 + 3,
    60,
    @raylib.Color::new(100, 0, 0, 255),
  )
  @draw.draw_text(
    title2,
    480 - tw2 / 2,
    253,
    60,
    @raylib.Color::new(252, 228, 0, 255),
  )
  let sub = "M O O N B I T   E D I T I O N"
  let tw_sub = @draw.measure_text(sub, 16)
  @draw.draw_text(
    sub,
    480 - tw_sub / 2,
    330,
    16,
    @raylib.Color::new(252, 252, 252, 255),
  )
  let blink = game.frame_counter / 30 % 2
  if blink == 0 {
    let prompt = "PRESS ENTER TO START"
    let tw_p = @draw.measure_text(prompt, 24)
    @draw.draw_text(
      prompt,
      480 - tw_p / 2,
      420,
      24,
      @raylib.Color::new(252, 252, 252, 255),
    )
  }
  @draw.draw_text(
    "ARROWS / WASD = Move     SPACE / UP / W = Jump",
    140,
    480,
    16,
    @raylib.Color::new(252, 252, 252, 200),
  )
  @draw.draw_text(
    "SHIFT / Z / X = Run & Fire     P / ESC = Pause",
    140,
    500,
    16,
    @raylib.Color::new(252, 252, 252, 200),
  )
  @draw.draw_text(
    "DOWN on green pipes = Secret areas!",
    280,
    520,
    16,
    @raylib.Color::new(252, 228, 0, 200),
  )
  @draw.draw_text(
    "Built with MoonBit + Raylib",
    340,
    680,
    16,
    @raylib.Color::new(200, 200, 200, 180),
  )
}

///|
fn draw_level_intro(game : @types.Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(0, 0, 0, 255))
  let world_text = "WORLD  " +
    game.world_num.to_string() +
    " - " +
    game.level_num.to_string()
  let tw = @draw.measure_text(world_text, 40)
  @draw.draw_text(world_text, 480 - tw / 2, 280, 40, hud_white)
  @raylib.draw_rectangle(400, 360, 20, 10, @raylib.Color::new(228, 0, 0, 255))
  @raylib.draw_rectangle(
    402,
    370,
    16,
    8,
    @raylib.Color::new(252, 188, 116, 255),
  )
  @raylib.draw_rectangle(400, 378, 20, 12, @raylib.Color::new(32, 64, 200, 255))
  let lives_text = "x  " + game.lives.to_string()
  @draw.draw_text(lives_text, 440, 365, 28, hud_white)
}

///|
fn draw_pause_overlay(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(0, 0, @types.screen_w, @types.screen_h, overlay_bg)
  let blink = game.frame_counter / 20 % 2
  let color = if blink == 0 { hud_white } else { hud_yellow }
  let text = "P A U S E D"
  let tw = @draw.measure_text(text, 48)
  @draw.draw_text(text, 480 - tw / 2, 320, 48, color)
  @draw.draw_text(
    "Press P or ESC to resume",
    350,
    390,
    20,
    @raylib.Color::new(200, 200, 200, 200),
  )
}

///|
/// Draw the level tally / scoring screen after completing a level.
fn draw_level_tally_screen(game : @types.Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(0, 0, 0, 255))
  // Title
  let title = "LEVEL CLEAR!"
  let tw = @draw.measure_text(title, 40)
  let title_col = @raylib.Color::new(252, 228, 0, 255)
  @draw.draw_text(title, 480 - tw / 2, 80, 40, title_col)
  // Score breakdown box
  let box_x = 200
  let box_y = 150
  let box_w = 560
  @raylib.draw_rectangle(box_x, box_y, box_w, 380, @raylib.Color::new(
    20, 20, 60, 240,
  ))
  @raylib.draw_rectangle(box_x + 2, box_y + 2, box_w - 4, 376, @raylib.Color::new(
    10, 10, 40, 240,
  ))
  let label_x = box_x + 40
  let value_x = box_x + box_w - 120
  let mut row_y = box_y + 30
  // Time bonus
  if game.tally_phase >= 1 {
    @draw.draw_text("TIME BONUS:", label_x, row_y, 24, hud_white)
    @draw.draw_text(
      game.tally_time_bonus.to_string(),
      value_x,
      row_y,
      24,
      hud_yellow,
    )
  }
  row_y = row_y + 50
  // Coin bonus
  if game.tally_phase >= 2 {
    let coin_label = "COINS: " +
      game.level_coins_collected.to_string() +
      " x " +
      @types.score_coin.to_string()
    @draw.draw_text(coin_label, label_x, row_y, 24, hud_white)
    @draw.draw_text(
      game.tally_coin_bonus.to_string(),
      value_x,
      row_y,
      24,
      hud_yellow,
    )
  }
  row_y = row_y + 50
  // Enemy bonus
  if game.tally_phase >= 3 {
    let enemy_label = "ENEMIES: " +
      game.enemies_defeated.to_string() +
      " x 100"
    @draw.draw_text(enemy_label, label_x, row_y, 24, hud_white)
    @draw.draw_text(
      game.tally_enemy_bonus.to_string(),
      value_x,
      row_y,
      24,
      hud_yellow,
    )
  }
  row_y = row_y + 50
  // Height bonus
  if game.tally_phase >= 4 {
    @draw.draw_text("FLAGPOLE BONUS:", label_x, row_y, 24, hud_white)
    @draw.draw_text(
      game.tally_height_bonus.to_string(),
      value_x,
      row_y,
      24,
      hud_yellow,
    )
  }
  row_y = row_y + 60
  // Total and rank
  if game.tally_phase >= 5 {
    // Divider line
    @raylib.draw_rectangle(label_x, row_y - 10, box_w - 80, 2, hud_white)
    let total = game.tally_time_bonus +
      game.tally_coin_bonus +
      game.tally_enemy_bonus +
      game.tally_height_bonus
    @draw.draw_text("TOTAL:", label_x, row_y, 28, hud_white)
    @draw.draw_text(total.to_string(), value_x, row_y, 28, hud_yellow)
    row_y = row_y + 50
    // Rank
    let rank_col = match game.tally_rank {
      "PERFECT" => @raylib.Color::new(252, 228, 0, 255)
      "GREAT" => @raylib.Color::new(0, 252, 0, 255)
      _ => @raylib.Color::new(200, 200, 200, 255)
    }
    let rank_text = "RANK: " + game.tally_rank
    let rank_tw = @draw.measure_text(rank_text, 32)
    @draw.draw_text(rank_text, 480 - rank_tw / 2, row_y, 32, rank_col)
    // Blink prompt
    let blink = game.frame_counter / 30 % 2
    if blink == 0 {
      let prompt = "PRESS ENTER TO CONTINUE"
      let ptw = @draw.measure_text(prompt, 20)
      @draw.draw_text(prompt, 480 - ptw / 2, row_y + 50, 20, hud_white)
    }
  }
}

///|
fn draw_game_over(game : @types.Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(0, 0, 0, 255))
  let text = "G A M E   O V E R"
  let tw = @draw.measure_text(text, 48)
  @draw.draw_text(
    text,
    480 - tw / 2,
    300,
    48,
    @raylib.Color::new(228, 0, 0, 255),
  )
  let score_text = "FINAL SCORE: " + game.score.to_string()
  let tw2 = @draw.measure_text(score_text, 24)
  @draw.draw_text(score_text, 480 - tw2 / 2, 380, 24, hud_white)
  if game.game_over_timer > 3.0 {
    let blink = game.frame_counter / 30 % 2
    if blink == 0 {
      let prompt = "PRESS ENTER"
      let tw_p = @draw.measure_text(prompt, 20)
      @draw.draw_text(prompt, 480 - tw_p / 2, 440, 20, hud_white)
    }
  }
}

///|
fn draw_victory(game : @types.Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(0, 0, 0, 255))
  let colors = [
    @raylib.Color::new(252, 0, 0, 255),
    @raylib.Color::new(252, 148, 0, 255),
    @raylib.Color::new(252, 252, 0, 255),
    @raylib.Color::new(0, 252, 0, 255),
    @raylib.Color::new(0, 148, 252, 255),
  ]
  let text1 = "CONGRATULATIONS!"
  let tw1 = @draw.measure_text(text1, 40)
  let col_idx = game.frame_counter / 8 % 5
  @draw.draw_text(text1, 480 - tw1 / 2, 200, 40, colors[col_idx])
  let text2 = "YOU SAVED THE MUSHROOM KINGDOM!"
  let tw2 = @draw.measure_text(text2, 24)
  @draw.draw_text(text2, 480 - tw2 / 2, 280, 24, hud_white)
  let score_text = "FINAL SCORE: " + game.score.to_string()
  let tw3 = @draw.measure_text(score_text, 28)
  @draw.draw_text(score_text, 480 - tw3 / 2, 350, 28, hud_yellow)
  let coins_text = "COINS: " + game.coins.to_string()
  let tw4 = @draw.measure_text(coins_text, 24)
  @draw.draw_text(coins_text, 480 - tw4 / 2, 400, 24, hud_coin)
  let blink = game.frame_counter / 30 % 2
  if blink == 0 {
    let prompt = "PRESS ENTER TO PLAY AGAIN"
    let tw_p = @draw.measure_text(prompt, 20)
    @draw.draw_text(prompt, 480 - tw_p / 2, 480, 20, hud_white)
  }
}
