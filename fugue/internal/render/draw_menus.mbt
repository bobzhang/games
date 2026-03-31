///|
fn draw_title(game : @types.Game) -> Unit {
  let _ = game
  // Title
  let title = "FUGUE"
  let tw = @draw.measure_text(title, 72)
  @draw.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    160,
    72,
    @types.color_title,
  )
  // Subtitle
  let sub = "A Music Composition Puzzle"
  let sw = @draw.measure_text(sub, 24)
  @draw.draw_text(
    sub,
    (@types.screen_width - sw) / 2,
    245,
    24,
    @types.color_text_dim,
  )
  // Decorative notes
  draw_decorative_notes(380)
  // Start prompt
  let prompt = "Press ENTER to begin"
  let pw = @draw.measure_text(prompt, 28)
  @draw.draw_text(
    prompt,
    (@types.screen_width - pw) / 2,
    480,
    28,
    @types.color_text,
  )
  // Credits
  let cred = "Place notes. Build harmony. Solve the puzzle."
  let crw = @draw.measure_text(cred, 18)
  @draw.draw_text(
    cred,
    (@types.screen_width - crw) / 2,
    560,
    18,
    @types.color_text_dim,
  )
}

///|
fn draw_decorative_notes(y : Int) -> Unit {
  let notes = ["C", "D", "E", "F", "G", "A", "B"]
  let colors = [
    @types.color_note_c, @types.color_note_d, @types.color_note_e,
    @types.color_note_f, @types.color_note_g, @types.color_note_a,
    @types.color_note_b,
  ]
  let total_w = notes.length() * 50
  let start_x = (@types.screen_width - total_w) / 2
  for i in 0..<notes.length() {
    let x = start_x + i * 50
    @raylib.draw_rectangle(x, y, 36, 36, colors[i])
    let tw = @draw.measure_text(notes[i], 18)
    @draw.draw_text(notes[i], x + (36 - tw) / 2, y + 9, 18, @raylib.white)
  }
}

///|
fn draw_tier_select(game : @types.Game) -> Unit {
  let _ = game
  let title = "Select Tier"
  let tw = @draw.measure_text(title, 40)
  @draw.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    60,
    40,
    @types.color_title,
  )
  // Three tier buttons
  let tiers : Array[(@types.Tier, String, String)] = [
    (Melody, "1. Melody", "Match target notes - 7 levels"),
    (Harmony, "2. Harmony", "Maximize consonance - 7 levels"),
    (Counterpoint, "3. Counterpoint", "Two-voice puzzles - 6 levels"),
  ]
  for i in 0..<tiers.length() {
    let (tier, name, desc) = tiers[i]
    let bx = (@types.screen_width - 500) / 2
    let by = 170 + i * 150
    let bw = 500
    let bh = 120
    let tier_col = @types.tier_color(tier)
    // Hover detection
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let hovered = mx >= bx && mx < bx + bw && my >= by && my < by + bh
    let bg_col = if hovered {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(bx, by, bw, bh, bg_col)
    @raylib.draw_rectangle_lines(bx, by, bw, bh, tier_col)
    @draw.draw_text(name, bx + 30, by + 20, 32, tier_col)
    @draw.draw_text(desc, bx + 30, by + 62, 18, @types.color_text_dim)
    // Star count for completed levels
    let (lo, hi) = @types.tier_level_range(tier)
    let mut total_stars = 0
    for lvl in lo..=hi {
      if lvl < game.level_scores.length() {
        total_stars += game.level_scores[lvl].stars
      }
    }
    let star_str = total_stars.to_string() + " stars"
    @draw.draw_text(star_str, bx + bw - 120, by + 25, 20, @types.color_star_on)
  }
  @draw.draw_text(
    "Esc: Back to title",
    20,
    @types.screen_height - 40,
    16,
    @types.color_text_dim,
  )
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let tier = game.selected_tier
  let tier_col = @types.tier_color(tier)
  let title = @types.tier_name(tier) + " Levels"
  let tw = @draw.measure_text(title, 36)
  @draw.draw_text(title, (@types.screen_width - tw) / 2, 40, 36, tier_col)
  let (lo, hi) = @types.tier_level_range(tier)
  let count = hi - lo + 1
  let cols = 4
  let btn_w = 240
  let btn_h = 100
  let gap_x = 30
  let gap_y = 25
  let total_w = cols * btn_w + (cols - 1) * gap_x
  let start_x = (@types.screen_width - total_w) / 2
  let start_y = 110
  for i in 0..<count {
    let lvl_id = lo + i
    let col = i % cols
    let row = i / cols
    let bx = start_x + col * (btn_w + gap_x)
    let by = start_y + row * (btn_h + gap_y)
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let hovered = mx >= bx && mx < bx + btn_w && my >= by && my < by + btn_h
    let bg = if hovered {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(bx, by, btn_w, btn_h, bg)
    @raylib.draw_rectangle_lines(bx, by, btn_w, btn_h, tier_col)
    // Level number and name
    let num_str = (i + 1).to_string() + "."
    @draw.draw_text(num_str, bx + 12, by + 10, 20, tier_col)
    // Get level name inline
    let lname = get_level_name(lvl_id)
    @draw.draw_text(lname, bx + 42, by + 10, 20, @types.color_text)
    // Stars
    if lvl_id < game.level_scores.length() {
      let score = game.level_scores[lvl_id]
      let star_y = by + 50
      for s in 0..<3 {
        let star_x = bx + 12 + s * 30
        let star_col = if s < score.stars {
          @types.color_star_on
        } else {
          @types.color_star_off
        }
        @draw.draw_text("*", star_x, star_y, 28, star_col)
      }
      if score.completed {
        @draw.draw_text(
          "Done",
          bx + btn_w - 55,
          by + btn_h - 25,
          14,
          @types.color_consonant,
        )
      }
    }
  }
  @draw.draw_text(
    "Esc: Back to tiers",
    20,
    @types.screen_height - 40,
    16,
    @types.color_text_dim,
  )
}

///|
fn get_level_name(id : Int) -> String {
  match id {
    0 => "First Steps"
    1 => "Scale Up"
    2 => "Peak"
    3 => "Stepwise"
    4 => "Leap"
    5 => "Zigzag"
    6 => "Full Scale"
    7 => "First Chord"
    8 => "Power Fifths"
    9 => "Triad Builder"
    10 => "Careful Steps"
    11 => "Dense Harmony"
    12 => "Consonance Chain"
    13 => "Full Harmony"
    14 => "Parallel Motion"
    15 => "Contrary Motion"
    16 => "Call and Response"
    17 => "Tight Weave"
    18 => "Grand Fugue"
    19 => "Masterwork"
    _ => "Unknown"
  }
}

///|
fn draw_results(game : @types.Game) -> Unit {
  let level = game.current_level
  let tier_col = @types.tier_color(level.tier)
  // Level complete header
  let header = if game.stars > 0 { "Level Complete!" } else { "Try Again" }
  let hw = @draw.measure_text(header, 44)
  let header_col = if game.stars > 0 {
    @types.color_consonant
  } else {
    @types.color_dissonant
  }
  @draw.draw_text(header, (@types.screen_width - hw) / 2, 100, 44, header_col)
  // Level name
  let name = level.name
  let nw = @draw.measure_text(name, 28)
  @draw.draw_text(name, (@types.screen_width - nw) / 2, 160, 28, tier_col)
  // Stars
  let star_y = 220
  let star_total_w = 3 * 60
  let star_start = (@types.screen_width - star_total_w) / 2
  for s in 0..<3 {
    let sx = star_start + s * 60
    let col = if s < game.stars {
      @types.color_star_on
    } else {
      @types.color_star_off
    }
    @draw.draw_text("*", sx + 10, star_y, 48, col)
  }
  // Score details
  let detail_x = (@types.screen_width - 300) / 2
  let detail_y = 310
  let matched = @harmony.count_matched(game.grid, level.targets)
  let total_t = level.targets.length()
  @draw.draw_text(
    "Targets: " + matched.to_string() + "/" + total_t.to_string(),
    detail_x,
    detail_y,
    24,
    @types.color_text,
  )
  let harm = @harmony.compute_total_harmony(game.grid)
  let harm_str = if harm >= 0 {
    "+" + harm.to_string()
  } else {
    harm.to_string()
  }
  @draw.draw_text(
    "Harmony Score: " + harm_str,
    detail_x,
    detail_y + 40,
    24,
    if harm > 0 { @types.color_consonant } else if harm < 0 {
      @types.color_dissonant
    } else {
      @types.color_text
    },
  )
  let notes_used = @types.count_notes_in_grid(game.grid)
  @draw.draw_text(
    "Notes Used: " + notes_used.to_string() + "/" + level.note_budget.to_string(),
    detail_x,
    detail_y + 80,
    24,
    @types.color_text,
  )
  // Actions
  let act_y = 500
  @draw.draw_text(
    "Enter: Next Level",
    (@types.screen_width - 200) / 2,
    act_y,
    24,
    @types.color_text,
  )
  @draw.draw_text(
    "R: Retry Level",
    (@types.screen_width - 200) / 2,
    act_y + 40,
    24,
    @types.color_text_dim,
  )
  @draw.draw_text(
    "Esc: Back to Levels",
    (@types.screen_width - 200) / 2,
    act_y + 80,
    24,
    @types.color_text_dim,
  )
}
