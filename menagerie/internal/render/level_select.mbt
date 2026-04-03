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
  let start_y = @types.level_button_y
  let button_h = @types.level_button_h
  let gap = @types.level_button_gap
  let visible = @types.level_visible_count
  let bx = @types.level_button_x
  let bw = @types.level_button_w
  for i in 0..<visible {
    let lvl = game.level_select_scroll + i
    if lvl >= @levels.level_count() {
      break
    }
    let by = start_y + i * (button_h + gap)
    let level = @levels.get_level(lvl)
    let unlocked = game.is_level_unlocked(lvl)
    let stars = game.stars_earned[lvl]
    let bg_color = if unlocked == false {
      @types.color_level_locked
    } else if stars > 0 {
      @types.color_level_completed
    } else {
      @types.color_level_available
    }
    @raylib.draw_rectangle(bx, by, bw, button_h, bg_color)
    // Level number and tier
    let tier_str = @types.tier_label(level.tier)
    let label = "Level \{lvl + 1} [Tier \{tier_str}]"
    @draw.draw_text(label, bx + 16, by + 8, 20, @types.color_hud_text)
    // Description
    @draw.draw_text(
      level.description,
      bx + 16,
      by + 32,
      16,
      @types.color_hud_text,
    )
    // Stars
    draw_stars(stars, 820, by + 16, 20, 2)
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
      "v DOWN v",
      460,
      start_y + visible * (button_h + gap) + 4,
      16,
      @types.color_warning,
    )
  }
  // Footer
  @draw.draw_text(
    "Click or press 1-9 to select  |  ESC: Back", 280, 740, 16, @types.color_hud_text,
  )
}
