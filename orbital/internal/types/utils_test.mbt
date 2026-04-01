///|
test "vec2f basic operations" {
  let a = @types.vec2f(3.0, 4.0)
  let b = @types.vec2f(1.0, 2.0)
  let sum = @types.vec2f_add(a, b)
  inspect(sum.x, content="4")
  inspect(sum.y, content="6")
  let diff = @types.vec2f_sub(a, b)
  inspect(diff.x, content="2")
  inspect(diff.y, content="2")
  let scaled = @types.vec2f_scale(a, 2.0)
  inspect(scaled.x, content="6")
  inspect(scaled.y, content="8")
}

///|
test "vec2f_len" {
  let v = @types.vec2f(3.0, 4.0)
  inspect(@types.vec2f_len(v), content="5")
}

///|
test "vec2f_dist" {
  let a = @types.vec2f(0.0, 0.0)
  let b = @types.vec2f(3.0, 4.0)
  inspect(@types.vec2f_dist(a, b), content="5")
}

///|
test "vec2f_normalize" {
  let v = @types.vec2f(0.0, 5.0)
  let n = @types.vec2f_normalize(v)
  inspect(n.x, content="0")
  inspect(n.y, content="1")
  let z = @types.vec2f_normalize(@types.vec2f_zero())
  inspect(z.x, content="0")
  inspect(z.y, content="0")
}

///|
test "clampf" {
  inspect(@types.clampf(0.5, 0.0, 1.0), content="0.5")
  inspect(@types.clampf(-1.0, 0.0, 1.0), content="0")
  inspect(@types.clampf(2.0, 0.0, 1.0), content="1")
}

///|
test "absf" {
  inspect(@types.absf(5.0), content="5")
  inspect(@types.absf(-5.0), content="5")
  inspect(@types.absf(0.0), content="0")
}

///|
test "maxf and minf" {
  inspect(@types.maxf(3.0, 7.0), content="7")
  inspect(@types.minf(3.0, 7.0), content="3")
}

///|
test "cosf and sinf" {
  inspect(@types.cosf(0.0), content="1")
  inspect(@types.sinf(0.0), content="0")
}

///|
test "new_game initializes correctly" {
  let game = @types.new_game()
  inspect(game.screen, content="Title")
  inspect(game.play_state, content="Aiming")
  inspect(game.current_level, content="0")
  inspect(game.scores.length(), content="25")
  inspect(game.stars.length() > 0, content="true")
}

///|
test "tier_start_index" {
  inspect(@types.tier_start_index(Launch), content="0")
  inspect(@types.tier_start_index(Slingshot), content="8")
  inspect(@types.tier_start_index(Navigation), content="17")
}

///|
test "tier_level_count" {
  inspect(@types.tier_level_count(Launch), content="8")
  inspect(@types.tier_level_count(Slingshot), content="9")
  inspect(@types.tier_level_count(Navigation), content="8")
}

///|
test "tier_unlocked initial state" {
  let game = @types.new_game()
  inspect(@types.tier_unlocked(Launch, game.scores), content="true")
  inspect(@types.tier_unlocked(Slingshot, game.scores), content="false")
  inspect(@types.tier_unlocked(Navigation, game.scores), content="false")
}

///|
test "tier_unlocked after completing levels" {
  let game = @types.new_game()
  // Complete 4 tier1 levels to unlock tier2
  for i in 0..<4 {
    game.scores[i].completed = true
  }
  inspect(@types.tier_unlocked(Slingshot, game.scores), content="true")
  inspect(@types.tier_unlocked(Navigation, game.scores), content="false")
}

///|
test "level_index_for" {
  inspect(@types.level_index_for(Launch, 0), content="0")
  inspect(@types.level_index_for(Launch, 7), content="7")
  inspect(@types.level_index_for(Slingshot, 0), content="8")
  inspect(@types.level_index_for(Navigation, 0), content="17")
}
