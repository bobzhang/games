///|
fn draw_level_select(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  // Header
  let hdr = "SELECT LEVEL"
  let hw = @draw.measure_text(hdr, 36)
  @draw.draw_text(hdr, (sw - hw) / 2, 30, 36, @types.color_title)
  // Stars summary
  let summary = "Stars: \{game.total_stars} / \{@levels.level_count() * 3}  Completed: \{game.levels_completed} / \{@levels.level_count()}"
  let sumw = @draw.measure_text(summary, 18)
  @draw.draw_text(summary, (sw - sumw) / 2, 80, 18, @types.color_hud_text)
  // Level buttons
  let start_y = 140
  let button_h = 56
  let gap = 8
  let visible = 10
  for i in 0..<visible {
    let lvl = game.level_select_scroll + i
    if lvl >= @levels.level_count() {
      break
    }
    let by = start_y + i * (button_h + gap)
    let level = @levels.get_level(lvl)
    let unlocked = is_level_unlocked_render(game, lvl)
    let stars = game.stars_earned[lvl]
    let bg_color = if unlocked == false {
      @types.color_level_locked
    } else if stars > 0 {
      @types.color_level_completed
    } else {
      @types.color_level_available
    }
    @raylib.draw_rectangle(80, by, 864, button_h, bg_color)
    // Level number and tier
    let tier_str = match level.tier {
      1 => "I"
      2 => "II"
      _ => "III"
    }
    let label = "Level \{lvl + 1} [Tier \{tier_str}]"
    @draw.draw_text(label, 96, by + 8, 20, @types.color_hud_text)
    // Description
    @draw.draw_text(level.description, 96, by + 32, 16, @types.color_hud_text)
    // Stars
    draw_stars_at(stars, 820, by + 16, 20)
    // Species icons
    let mut sx = 500
    for sp in level.species {
      let icon = @types.species_icon(sp)
      let col = @types.species_color(sp)
      @draw.draw_text(icon, sx, by + 8, 20, col)
      sx += 24
    }
  }
  // Scroll hints
  if game.level_select_scroll > 0 {
    @draw.draw_text("^ UP ^", 470, 120, 16, @types.color_warning)
  }
  let max_scroll = @levels.level_count() - visible
  if game.level_select_scroll < max_scroll {
    @draw.draw_text(
      "v DOWN v", 460, start_y + visible * (button_h + gap) + 4, 16,
      @types.color_warning,
    )
  }
  // Footer
  @draw.draw_text(
    "Click or press 1-9 to select  |  ESC: Back", 280, 740, 16,
    @types.color_hud_text,
  )
}

///|
fn is_level_unlocked_render(game : @types.Game, level_id : Int) -> Bool {
  if level_id == 0 {
    return true
  }
  if level_id > 0 && game.stars_earned[level_id - 1] > 0 {
    return true
  }
  false
}

///|
fn draw_stars_at(count : Int, x : Int, y : Int, size : Int) -> Unit {
  for i in 0..<3 {
    let col = if i < count {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    @draw.draw_text("*", x + i * (size + 2), y, size, col)
  }
}
