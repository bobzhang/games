// ── UI color constants ──

let hud_bg : @raylib.Color = @raylib.Color::new(0, 0, 0, 160)
let hud_white : @raylib.Color = @raylib.Color::new(252, 252, 252, 255)
let hud_yellow : @raylib.Color = @raylib.Color::new(252, 200, 32, 255)
let hud_coin : @raylib.Color = @raylib.Color::new(252, 200, 32, 255)
let overlay_bg : @raylib.Color = @raylib.Color::new(0, 0, 0, 180)

///|
/// Draw the HUD and any state-specific overlays.
pub fn draw_ui(game : @types.Game) -> Unit {
  match game.state {
    Title => draw_title_screen(game)
    LevelIntro => draw_level_intro(game)
    Playing | LevelClear => draw_hud(game)
    Paused => {
      draw_hud(game)
      draw_pause_overlay(game)
    }
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
  // Coins
  @raylib.draw_rectangle(220, 8, 10, 14, hud_coin)
  @raylib.draw_rectangle(222, 6, 6, 4, hud_coin)
  let coin_text = "x" + (if game.coins < 10 { "0" } else { "" }) +
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
  // Small Mario icon for lives
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
      @types.star_color((game.frame_counter / 3) % 5),
    )
  }
}

///|
fn draw_title_screen(game : @types.Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(92, 148, 252, 255))
  // Draw some clouds for atmosphere
  for i in 0..<5 {
    let cx = 100 + i * 200
    let cy = 80 + (i * 47) % 120
    @raylib.draw_ellipse(cx, cy, 50, 25, @raylib.Color::new(
      252, 252, 252, 200,
    ))
    @raylib.draw_ellipse(cx + 30, cy - 10, 35, 20, @raylib.Color::new(
      252, 252, 252, 200,
    ))
    @raylib.draw_ellipse(cx - 25, cy - 5, 30, 18, @raylib.Color::new(
      252, 252, 252, 200,
    ))
  }
  // Ground
  @raylib.draw_rectangle(
    0,
    560,
    960,
    160,
    @raylib.Color::new(192, 96, 0, 255),
  )
  @raylib.draw_rectangle(0, 552, 960, 12, @raylib.Color::new(0, 188, 0, 255))
  // Title box
  @raylib.draw_rectangle(230, 180, 500, 120, @raylib.Color::new(
    228, 0, 0, 255,
  ))
  @raylib.draw_rectangle(234, 184, 492, 112, @raylib.Color::new(
    148, 0, 0, 255,
  ))
  @raylib.draw_rectangle(238, 188, 484, 104, @raylib.Color::new(
    228, 0, 0, 255,
  ))
  // Title text
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
  // Subtitle
  let sub = "M O O N B I T   E D I T I O N"
  let tw_sub = @draw.measure_text(sub, 16)
  @draw.draw_text(
    sub,
    480 - tw_sub / 2,
    330,
    16,
    @raylib.Color::new(252, 252, 252, 255),
  )
  // Blinking "Press ENTER" prompt
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
  // Controls info
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
  // Credits
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
  // World text
  let world_text = "WORLD  " + game.world_num.to_string() + " - " +
    game.level_num.to_string()
  let tw = @draw.measure_text(world_text, 40)
  @draw.draw_text(world_text, 480 - tw / 2, 280, 40, hud_white)
  // Mario icon + lives
  @raylib.draw_rectangle(400, 360, 20, 10, @raylib.Color::new(228, 0, 0, 255))
  @raylib.draw_rectangle(402, 370, 16, 8, @raylib.Color::new(
    252, 188, 116, 255,
  ))
  @raylib.draw_rectangle(400, 378, 20, 12, @raylib.Color::new(32, 64, 200, 255))
  let lives_text = "x  " + game.lives.to_string()
  @draw.draw_text(lives_text, 440, 365, 28, hud_white)
}

///|
fn draw_pause_overlay(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(0, 0, @types.screen_w, @types.screen_h, overlay_bg)
  let blink = game.frame_counter / 20 % 2
  let color = if blink == 0 {
    hud_white
  } else {
    hud_yellow
  }
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
  // Rainbow title
  let colors = [
    @raylib.Color::new(252, 0, 0, 255),
    @raylib.Color::new(252, 148, 0, 255),
    @raylib.Color::new(252, 252, 0, 255),
    @raylib.Color::new(0, 252, 0, 255),
    @raylib.Color::new(0, 148, 252, 255),
  ]
  let text1 = "CONGRATULATIONS!"
  let tw1 = @draw.measure_text(text1, 40)
  let col_idx = (game.frame_counter / 8) % 5
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
  // Blinking prompt
  let blink = game.frame_counter / 30 % 2
  if blink == 0 {
    let prompt = "PRESS ENTER TO PLAY AGAIN"
    let tw_p = @draw.measure_text(prompt, 20)
    @draw.draw_text(prompt, 480 - tw_p / 2, 480, 20, hud_white)
  }
}

