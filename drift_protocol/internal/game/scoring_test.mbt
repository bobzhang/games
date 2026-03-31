///|
test "score calculation with perfect run" {
  let game = @types.new_game()
  // Setup level with terminals
  let t1 = @types.new_terminal(3, 3, false, 1)
  t1.hacked = true
  t1.data_value = 100
  let t2 = @types.new_terminal(5, 5, false, 2)
  t2.hacked = true
  t2.data_value = 100
  game.level.terminals = [t1, t2]
  game.level.par_time = 60.0
  // Perfect ghost run, fast time
  game.player.detected_count = 0
  game.player.alert_triggered = false
  game.time_played = 30.0 // Half par time
  game.player.hacked_terminals = 2
  let score = @game.calculate_score(game)
  inspect(score.base_score, content="1000")
  inspect(score.ghost, content="true")
  inspect(score.ghost_bonus, content="500")
  inspect(score.no_alerts, content="true")
  inspect(score.no_alert_bonus, content="300")
  inspect(score.speed_bonus > 0, content="true")
  inspect(score.all_data, content="true")
  inspect(score.grade, content="S")
}

///|
test "score with detected run" {
  let game = @types.new_game()
  game.level.terminals = []
  game.level.par_time = 60.0
  game.player.detected_count = 3
  game.player.alert_triggered = true
  game.time_played = 90.0 // Over par time
  let score = @game.calculate_score(game)
  inspect(score.ghost, content="false")
  inspect(score.ghost_bonus, content="0")
  inspect(score.no_alerts, content="false")
  inspect(score.no_alert_bonus, content="0")
  inspect(score.speed_bonus, content="0")
  inspect(score.grade, content="C")
}

///|
test "all_levels_complete checks all scores" {
  let game = @types.new_game()
  inspect(@game.all_levels_complete(game), content="false")
  // Fill all level scores
  for i in 0..<@types.total_levels {
    game.level_scores[i] = Some(@types.new_level_score())
  }
  inspect(@game.all_levels_complete(game), content="true")
}

///|
test "total_score sums across levels" {
  let game = @types.new_game()
  let s1 = @types.new_level_score()
  s1.total = 1500
  let s2 = @types.new_level_score()
  s2.total = 2000
  game.level_scores[0] = Some(s1)
  game.level_scores[3] = Some(s2)
  inspect(@game.total_score(game), content="3500")
}
