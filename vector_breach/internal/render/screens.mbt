// screens.mbt - Mission briefing, debrief, and run summary rendering.

///|
fn draw_mission_briefing(game : @types.Game) -> Unit {
  let cx = @types.screen_w / 2
  let def = @content.get_mission_def(game.run.current_mission)
  // Background with subtle grid pattern
  for row = 0; row < @types.screen_h / 40; row = row + 1 {
    @raylib.draw_line(
      0, row * 40, @types.screen_w, row * 40,
      @raylib.Color::new(30, 40, 60, 30),
    )
  }
  // Header bar
  @raylib.draw_rectangle(
    0, 40, @types.screen_w, 60, @raylib.Color::new(20, 30, 50, 220),
  )
  @raylib.draw_line(0, 40, @types.screen_w, 40, @types.color_player)
  @raylib.draw_line(0, 100, @types.screen_w, 100, @types.color_player)
  @types.draw_shadow_text(
    "MISSION BRIEFING", 30, 12, @types.font_small, @types.color_text_dim,
  )
  @types.draw_center_text(
    def.name, cx, 55, @types.font_title - 8, @types.color_player,
  )
  // Objective
  let obj_y = 130
  @types.draw_shadow_text(
    "OBJECTIVE", 40, obj_y, @types.font_body, @types.color_selected,
  )
  @raylib.draw_line(
    40, obj_y + 24, 240, obj_y + 24,
    @raylib.Color::new(255, 220, 80, 80),
  )
  let obj_text = format_objective(def.objective)
  @types.draw_shadow_text(
    obj_text, 40, obj_y + 34, @types.font_body - 2, @types.color_text,
  )
  // Briefing narrative text (word-wrapped)
  let brief_y = obj_y + 80
  @types.draw_shadow_text(
    "INTEL", 40, brief_y, @types.font_body, @types.color_selected,
  )
  @raylib.draw_line(
    40, brief_y + 24, 160, brief_y + 24,
    @raylib.Color::new(255, 220, 80, 80),
  )
  draw_wrapped_text(
    def.briefing, 40, brief_y + 34, @types.screen_w - 80,
    @types.font_body - 2, @types.color_text,
  )
  // Enemy preview
  let enemy_y = brief_y + 140
  @types.draw_shadow_text(
    "HOSTILE FORCES", 40, enemy_y, @types.font_body, @types.color_enemy,
  )
  @raylib.draw_line(
    40, enemy_y + 24, 240, enemy_y + 24,
    @raylib.Color::new(220, 60, 60, 80),
  )
  let mut line_y = enemy_y + 34
  let type_names : Array[String] = []
  let type_counts : Array[Int] = []
  for i = 0; i < def.enemy_types.length(); i = i + 1 {
    let (etype, _, _) = def.enemy_types[i]
    let name = @content.get_enemy_name(etype)
    let mut found = false
    for j = 0; j < type_names.length(); j = j + 1 {
      if type_names[j] == name {
        type_counts[j] += 1
        found = true
        break
      }
    }
    if !found {
      type_names.push(name)
      type_counts.push(1)
    }
  }
  for i = 0; i < type_names.length(); i = i + 1 {
    let entry = "\{type_counts[i]}x \{type_names[i]}"
    @types.draw_shadow_text(
      entry, 60, line_y, @types.font_body - 2, @types.color_enemy,
    )
    line_y += 22
  }
  // Deploy button with pulsing glow
  let btn_y = @types.screen_h - 80
  let btn_w = 200
  let btn_h = 44
  let btn_x = cx - btn_w / 2
  let pulse = Float::from_double(
    @math.sin(game.anim_timer.to_double() * 3.0),
  )
  let glow_alpha = 60 + (pulse * 30.0).to_int()
  @raylib.draw_rectangle(
    btn_x - 3, btn_y - 3, btn_w + 6, btn_h + 6,
    @raylib.Color::new(80, 180, 255, glow_alpha),
  )
  @raylib.draw_rectangle(
    btn_x, btn_y, btn_w, btn_h,
    @raylib.Color::new(25, 35, 55, 240),
  )
  @raylib.draw_rectangle_lines(
    btn_x, btn_y, btn_w, btn_h, @types.color_player,
  )
  @types.draw_center_text(
    "DEPLOY", cx, btn_y + 12, @types.font_body + 2, @types.color_player,
  )
}

///|
fn draw_mission_debrief(game : @types.Game) -> Unit {
  let cx = @types.screen_w / 2
  let def = @content.get_mission_def(game.run.current_mission)
  // Draw battle in background dimmed
  match game.battle {
    Some(b) => {
      draw_grid(b)
      draw_units(b, game)
    }
    None => ()
  }
  @raylib.draw_rectangle(
    0, 0, @types.screen_w, @types.screen_h,
    @raylib.Color::new(0, 0, 0, 180),
  )
  // Header
  @types.draw_center_text(
    "MISSION COMPLETE", cx, 60, @types.font_title - 4,
    @raylib.Color::new(80, 220, 120, 255),
  )
  @types.draw_center_text(
    def.name, cx, 110, @types.font_body + 4, @types.color_player,
  )
  // Debrief narrative text
  let debrief_y = 160
  @types.draw_shadow_text(
    "DEBRIEF", 60, debrief_y, @types.font_body, @types.color_selected,
  )
  @raylib.draw_line(
    60, debrief_y + 24, 200, debrief_y + 24,
    @raylib.Color::new(255, 220, 80, 80),
  )
  draw_wrapped_text(
    def.debrief, 60, debrief_y + 34, @types.screen_w - 120,
    @types.font_body - 2, @types.color_text,
  )
  // Score summary
  let score_y = debrief_y + 120
  @types.draw_shadow_text(
    "SCORE", 60, score_y, @types.font_body, @types.color_selected,
  )
  @raylib.draw_line(
    60, score_y + 24, 160, score_y + 24,
    @raylib.Color::new(255, 220, 80, 80),
  )
  let battle_score = match game.battle {
    Some(b) => b.score
    None => 0
  }
  let turns_taken = match game.battle {
    Some(b) => b.turn
    None => 0
  }
  @types.draw_shadow_text(
    "Battle Score: \{battle_score}", 80, score_y + 34,
    @types.font_body - 2, @types.color_text,
  )
  @types.draw_shadow_text(
    "Turns Taken: \{turns_taken}", 80, score_y + 56,
    @types.font_body - 2, @types.color_text,
  )
  @types.draw_shadow_text(
    "Reward Tier: \{def.reward_tier}", 80, score_y + 78,
    @types.font_body - 2, @types.color_text,
  )
  // Continue prompt
  let blink = Float::from_double(
    @math.sin(game.anim_timer.to_double() * 3.0),
  )
  if blink > 0.0 {
    @types.draw_center_text(
      "Press ENTER to continue", cx, @types.screen_h - 60,
      @types.font_body, @types.color_text,
    )
  }
}

///|
fn draw_run_summary(game : @types.Game) -> Unit {
  let cx = @types.screen_w / 2
  let battle_is_victory = match game.battle {
    Some(b) => b.phase == Victory
    None => false
  }
  let is_victory = game.run.missions_completed >= @types.total_missions ||
    battle_is_victory
  // Background
  @raylib.draw_rectangle(
    0, 0, @types.screen_w, @types.screen_h,
    @raylib.Color::new(8, 10, 18, 255),
  )
  // Decorative lines
  for i = 0; i < 6; i = i + 1 {
    let ly = 50 + i * 110
    @raylib.draw_line(
      30, ly, @types.screen_w - 30, ly,
      @raylib.Color::new(30, 50, 80, 60),
    )
  }
  // Title
  let title = if is_victory { "CAMPAIGN VICTORY" } else { "CAMPAIGN OVER" }
  let title_color = if is_victory {
    @raylib.Color::new(80, 220, 120, 255)
  } else {
    @types.color_enemy
  }
  @types.draw_center_text(title, cx, 40, @types.font_title, title_color)
  // Rating
  let score = game.run.total_score
  let rating = compute_rating(score, game.run.missions_completed)
  let rating_color = match rating {
    "S" => @raylib.Color::new(255, 220, 40, 255)
    "A" => @raylib.Color::new(80, 220, 120, 255)
    "B" => @types.color_player
    _ => @types.color_text_dim
  }
  @types.draw_center_text(
    "RATING: \{rating}", cx, 100, @types.font_title - 8, rating_color,
  )
  // Stats
  let stats_y = 170
  let left_x = cx - 200
  let right_x = cx + 20
  let line_h = 34
  draw_stat_line(
    "Total Score:", score.to_string(),
    left_x, stats_y, @types.color_selected,
  )
  draw_stat_line(
    "Missions:", game.run.missions_completed.to_string(),
    left_x, stats_y + line_h, @types.color_text,
  )
  draw_stat_line(
    "Total Turns:", game.run.total_turns.to_string(),
    left_x, stats_y + line_h * 2, @types.color_text,
  )
  draw_stat_line(
    "Mechs Lost:", game.run.mechs_lost.to_string(),
    left_x, stats_y + line_h * 3, @types.color_text,
  )
  draw_stat_line(
    "Best Combo:", game.run.best_combo.to_string(),
    right_x, stats_y, @types.color_text,
  )
  draw_stat_line(
    "Augments:", game.run.augments.length().to_string(),
    right_x, stats_y + line_h, @types.color_text,
  )
  draw_stat_line(
    "Grid Power:", game.run.grid_power.to_string(),
    right_x, stats_y + line_h * 2, @types.color_text,
  )
  // Augment list
  if game.run.augments.length() > 0 {
    let aug_y = stats_y + line_h * 4 + 16
    @types.draw_shadow_text(
      "AUGMENTS", left_x, aug_y, @types.font_body, @types.color_selected,
    )
    @raylib.draw_line(
      left_x, aug_y + 24, left_x + 140, aug_y + 24,
      @raylib.Color::new(255, 220, 80, 80),
    )
    let mut aug_line_y = aug_y + 34
    for i = 0; i < game.run.augments.length(); i = i + 1 {
      let aug_name = @content.get_augment_name(game.run.augments[i])
      @types.draw_shadow_text(
        aug_name, left_x + 20, aug_line_y, @types.font_small,
        @types.color_player,
      )
      aug_line_y += 20
    }
  }
  // Prompt
  let blink = Float::from_double(
    @math.sin(game.anim_timer.to_double() * 3.0),
  )
  if blink > 0.0 {
    @types.draw_center_text(
      "Press ENTER to return to title", cx, @types.screen_h - 50,
      @types.font_body, @types.color_text,
    )
  }
}

///|
fn compute_rating(score : Int, missions_completed : Int) -> String {
  let base = if missions_completed > 0 {
    missions_completed * 100
  } else {
    100
  }
  if score >= base * 3 {
    "S"
  } else if score >= base * 2 {
    "A"
  } else if score >= base {
    "B"
  } else {
    "C"
  }
}

///|
fn draw_stat_line(
  label : String,
  value : String,
  x : Int,
  y : Int,
  value_color : @raylib.Color,
) -> Unit {
  @types.draw_shadow_text(
    label, x, y, @types.font_body - 2, @types.color_text_dim,
  )
  let label_w = @draw.measure_text(label, @types.font_body - 2)
  @types.draw_shadow_text(
    value, x + label_w + 12, y, @types.font_body - 2, value_color,
  )
}

///|
fn format_objective(obj : @types.Objective) -> String {
  match obj {
    DefendGrid(turns) => "Defend the grid for \{turns} turns"
    Survive(turns) => "Survive for \{turns} turns"
    Assassinate(_) => "Eliminate the primary target"
    CapturePoints(n) => "Capture \{n} control points"
    Escort(_, _) => "Escort a mech to the extraction point"
  }
}

///|
fn draw_wrapped_text(
  text : String,
  x : Int,
  y : Int,
  max_width : Int,
  size : Int,
  color : @raylib.Color,
) -> Unit {
  let words = split_by_space(text)
  let mut line = ""
  let mut line_y = y
  for i = 0; i < words.length(); i = i + 1 {
    let test_line = if line == "" {
      words[i]
    } else {
      line + " " + words[i]
    }
    let w = @draw.measure_text(test_line, size)
    if w > max_width && line != "" {
      @types.draw_shadow_text(line, x, line_y, size, color)
      line_y += size + 6
      line = words[i]
    } else {
      line = test_line
    }
  }
  if line != "" {
    @types.draw_shadow_text(line, x, line_y, size, color)
  }
}

///|
fn split_by_space(s : String) -> Array[String] {
  let result : Array[String] = []
  let buf = StringBuilder::new()
  for c in s {
    if c == ' ' {
      let word = buf.to_string()
      if word != "" {
        result.push(word)
      }
      buf.reset()
    } else {
      buf.write_char(c)
    }
  }
  let last = buf.to_string()
  if last != "" {
    result.push(last)
  }
  result
}
