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

///|
test "score calculation at exactly par time gives no speed bonus" {
  let game = @types.new_game()
  game.level.terminals = []
  game.level.par_time = 60.0
  game.player.detected_count = 0
  game.player.alert_triggered = false
  game.time_played = 60.0 // Exactly par time
  let score = @game.calculate_score(game)
  inspect(score.speed_bonus, content="0")
}

///|
test "score calculation well over par gives no speed bonus" {
  let game = @types.new_game()
  game.level.terminals = []
  game.level.par_time = 60.0
  game.player.detected_count = 0
  game.player.alert_triggered = false
  game.time_played = 120.0 // Double par time
  let score = @game.calculate_score(game)
  inspect(score.speed_bonus, content="0")
}

///|
test "score grade boundaries" {
  let game = @types.new_game()
  game.level.terminals = []
  game.level.par_time = 60.0
  game.player.detected_count = 0
  game.player.alert_triggered = false
  // base(1000) + ghost(500) + no_alert(300) + all_data(200, vacuously true) = 2000
  game.time_played = 60.0 // No speed bonus
  let score_a = @game.calculate_score(game)
  inspect(score_a.total, content="2000")
  inspect(score_a.grade, content="A")
  // Detected once, no alert: base(1000) + no_alert(300) + all_data(200) = 1500
  game.player.detected_count = 1
  let score_b = @game.calculate_score(game)
  inspect(score_b.total, content="1500")
  inspect(score_b.grade, content="B")
  // Detected + alert: base(1000) + all_data(200) = 1200
  game.player.alert_triggered = true
  let score_c = @game.calculate_score(game)
  inspect(score_c.total, content="1200")
  inspect(score_c.grade, content="C")
}

///|
test "score with partial data collection" {
  let game = @types.new_game()
  let t1 = @types.new_terminal(3, 3, false, 1)
  t1.data_value = 150
  t1.hacked = true
  let t2 = @types.new_terminal(5, 5, false, 2)
  t2.data_value = 250
  t2.hacked = false
  game.level.terminals = [t1, t2]
  game.level.par_time = 60.0
  game.player.detected_count = 0
  game.player.alert_triggered = false
  game.time_played = 60.0
  let score = @game.calculate_score(game)
  // data_bonus = hacked_value(150) + no all_data bonus
  inspect(score.data_bonus, content="150")
  inspect(score.all_data, content="false")
}

///|
test "best_grade returns highest grade across levels" {
  let game = @types.new_game()
  let s1 = @types.new_level_score()
  s1.grade = C
  let s2 = @types.new_level_score()
  s2.grade = A
  let s3 = @types.new_level_score()
  s3.grade = B
  game.level_scores[0] = Some(s1)
  game.level_scores[1] = Some(s2)
  game.level_scores[2] = Some(s3)
  inspect(@game.best_grade(game), content="A")
}

///|
test "best_grade with S rank" {
  let game = @types.new_game()
  let s1 = @types.new_level_score()
  s1.grade = B
  let s2 = @types.new_level_score()
  s2.grade = S
  game.level_scores[0] = Some(s1)
  game.level_scores[5] = Some(s2)
  inspect(@game.best_grade(game), content="S")
}

///|
test "best_grade with no completed levels returns C" {
  let game = @types.new_game()
  inspect(@game.best_grade(game), content="C")
}

///|
test "total_score with no completed levels is zero" {
  let game = @types.new_game()
  inspect(@game.total_score(game), content="0")
}

///|
///|
test "score zero time gives maximum speed bonus" {
  let game = @types.new_game()
  game.level.terminals = []
  game.level.par_time = 60.0
  game.player.detected_count = 0
  game.player.alert_triggered = false
  game.time_played = 0.0
  let score = @game.calculate_score(game)
  // ratio = 1.0, speed_bonus = 500
  inspect(score.speed_bonus, content="500")
  // base(1000) + ghost(500) + no_alert(300) + speed(500) + all_data(200) = 2500
  inspect(score.total, content="2500")
  inspect(score.grade, content="S")
}
