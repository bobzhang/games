///|
fn draw_level_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  @draw.draw_text("SELECT LEVEL", w / 2 - 105, 30, 32, @types.color_hud_text)
  let cols = 5
  let btn_w = 200
  let btn_h = 85
  let gap = 12
  let start_x = (w - cols * (btn_w + gap)) / 2
  let start_y = 90
  for i in 0..<@types.total_levels {
    let col = i % cols
    let row = i / cols
    let x = start_x + col * (btn_w + gap)
    let y = start_y + row * (btn_h + gap)
    let level = @levels.get_level(i)
    let unlocked = @types.is_level_unlocked(game, i)
    let progress = game.level_progress[i]
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let hovered = unlocked &&
      mx >= x &&
      mx < x + btn_w &&
      my >= y &&
      my < y + btn_h
    let bg_color = if !unlocked {
      @raylib.Color::new(28, 25, 35, 255)
    } else if hovered {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(x, y, btn_w, btn_h, bg_color)
    // Tier indicator bar
    let tier_color = match level.tier {
      1 => @raylib.Color::new(100, 180, 255, 255)
      2 => @raylib.Color::new(255, 180, 50, 255)
      _ => @raylib.Color::new(220, 100, 255, 255)
    }
    @raylib.draw_rectangle(x, y, 4, btn_h, tier_color)
    // Level number and name
    let num_str = (i + 1).to_string()
    let text_color = if unlocked {
      @types.color_hud_text
    } else {
      @raylib.Color::new(70, 65, 85, 255)
    }
    @draw.draw_text(num_str, x + 12, y + 8, 22, text_color)
    let name = if unlocked { level.name } else { "???" }
    @draw.draw_text(name, x + 12, y + 34, 14, text_color)
    if progress.completed {
      draw_stars_small(x + 12, y + 56, progress.best_stars)
    }
  }
  @draw.draw_text(
    "ESC - Back to Title",
    20,
    @types.screen_height - 40,
    16,
    @types.color_hud_dim,
  )
}
