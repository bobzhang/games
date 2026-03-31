///|
/// Calculate level score
pub fn calculate_score(game : @types.Game) -> @types.LevelScore {
  let score = @types.new_level_score()
  let level = game.level
  // Base score: 1000 per level
  score.base_score = 1000
  // Ghost bonus: never detected
  score.ghost = game.player.detected_count == 0
  if score.ghost {
    score.ghost_bonus = 500
  }
  // No alert bonus
  score.no_alerts = !game.player.alert_triggered
  if score.no_alerts {
    score.no_alert_bonus = 300
  }
  // Speed bonus: based on par time
  score.time_taken = game.time_played
  if game.time_played < level.par_time {
    let ratio : Float = 1.0 - game.time_played / level.par_time
    score.speed_bonus = (ratio * 500.0).to_int()
  }
  // Data bonus: all terminals hacked
  let hacked_value = @hacking.hacked_data_value(game)
  score.data_bonus = hacked_value
  score.all_data = @hacking.all_terminals_hacked(game)
  if score.all_data {
    score.data_bonus += 200 // Bonus for getting all data
  }
  // Total
  score.total = score.base_score + score.ghost_bonus + score.no_alert_bonus +
    score.speed_bonus + score.data_bonus
  // Grade
  score.grade = if score.total >= 2200 {
    S
  } else if score.total >= 1800 {
    A
  } else if score.total >= 1400 {
    B
  } else {
    C
  }
  score
}

///|
/// Get total score across all levels
pub fn total_score(game : @types.Game) -> Int {
  let mut total = 0
  for i in 0..<game.level_scores.length() {
    match game.level_scores[i] {
      Some(s) => total += s.total
      None => ()
    }
  }
  total
}

///|
/// Get best grade across all levels
pub fn best_grade(game : @types.Game) -> @types.ScoreGrade {
  let mut best : @types.ScoreGrade = C
  for i in 0..<game.level_scores.length() {
    match game.level_scores[i] {
      Some(s) =>
        match s.grade {
          S => best = S
          A =>
            if best is (B | C) {
              best = A
            }
          B =>
            if best is C {
              best = B
            }
          _ => ()
        }
      None => ()
    }
  }
  best
}

///|
/// Check if all levels have been completed
pub fn all_levels_complete(game : @types.Game) -> Bool {
  for i in 0..<@types.total_levels {
    if game.level_scores[i] is None {
      return false
    }
  }
  true
}
