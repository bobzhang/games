///|
/// Grants `points` to the specified `team` and updates the total and high scores.
pub fn grant_score(
  game : @types.Game,
  team : @types.Team,
  points : Int,
) -> Unit {
  game.score_total += points
  match team {
    Player1 => game.players[0].score += points
    Player2 => game.players[1].score += points
    _ => ()
  }
  if game.score_total > game.high_score {
    game.high_score = game.score_total
  }
}

///|
/// Increments the kill combo counter and resets the combo timer.
pub fn bump_combo(game : @types.Game) -> Unit {
  game.kill_combo += 1
  if game.kill_combo > 9 {
    game.kill_combo = 9
  }
  game.combo_timer = 2.1
}

///|
/// Returns the score multiplier based on the current kill combo streak.
pub fn combo_multiplier(game : @types.Game) -> Int {
  if game.kill_combo <= 1 {
    1
  } else if game.kill_combo <= 3 {
    2
  } else if game.kill_combo <= 6 {
    3
  } else {
    4
  }
}

///|
/// Updates the combo timer, resetting the combo when it expires.
pub fn update_combo(game : @types.Game, dt : Float) -> Unit {
  if game.combo_timer > 0.0 {
    game.combo_timer -= dt
    if game.combo_timer <= 0.0 {
      game.combo_timer = 0.0
      game.kill_combo = 0
    }
  }
}
