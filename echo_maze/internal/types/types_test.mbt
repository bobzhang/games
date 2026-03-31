///|
test "vec2i creation" {
  let v = @types.vec2i(3, 5)
  inspect(v.x, content="3")
  inspect(v.y, content="5")
}

///|
test "vec2i_add" {
  let a = @types.vec2i(1, 2)
  let b = @types.vec2i(3, 4)
  let c = @types.vec2i_add(a, b)
  inspect(c.x, content="4")
  inspect(c.y, content="6")
}

///|
test "vec2i_eq" {
  let a = @types.vec2i(5, 5)
  let b = @types.vec2i(5, 5)
  let c = @types.vec2i(3, 5)
  inspect(@types.vec2i_eq(a, b), content="true")
  inspect(@types.vec2i_eq(a, c), content="false")
}

///|
test "dir_to_delta" {
  let n = @types.dir_to_delta(North)
  inspect(n.x, content="0")
  inspect(n.y, content="-1")
  let s = @types.dir_to_delta(South)
  inspect(s.x, content="0")
  inspect(s.y, content="1")
  let e = @types.dir_to_delta(East)
  inspect(e.x, content="1")
  inspect(e.y, content="0")
  let w = @types.dir_to_delta(West)
  inspect(w.x, content="-1")
  inspect(w.y, content="0")
}

///|
test "in_bounds" {
  inspect(@types.in_bounds(@types.vec2i(0, 0), 10, 10), content="true")
  inspect(@types.in_bounds(@types.vec2i(9, 9), 10, 10), content="true")
  inspect(@types.in_bounds(@types.vec2i(-1, 0), 10, 10), content="false")
  inspect(@types.in_bounds(@types.vec2i(10, 0), 10, 10), content="false")
  inspect(@types.in_bounds(@types.vec2i(0, 10), 10, 10), content="false")
}

///|
test "mini and maxi" {
  inspect(@types.mini(3, 5), content="3")
  inspect(@types.mini(5, 3), content="3")
  inspect(@types.maxi(3, 5), content="5")
  inspect(@types.maxi(5, 3), content="5")
}

///|
test "clampi" {
  inspect(@types.clampi(5, 0, 10), content="5")
  inspect(@types.clampi(-5, 0, 10), content="0")
  inspect(@types.clampi(15, 0, 10), content="10")
}

///|
test "absf" {
  inspect(@types.absf(5.0) == 5.0, content="true")
  inspect(@types.absf(-5.0) == 5.0, content="true")
  inspect(@types.absf(0.0) == 0.0, content="true")
}

///|
test "ghost_color_for_index" {
  inspect(@types.ghost_color_for_index(0), content="Green")
  inspect(@types.ghost_color_for_index(1), content="Yellow")
  inspect(@types.ghost_color_for_index(2), content="Orange")
  inspect(@types.ghost_color_for_index(3), content="Green")
}

///|
test "tile_to_screen coordinates" {
  let x = @types.tile_to_screen_x(0)
  inspect(x, content="80")
  let y = @types.tile_to_screen_y(0)
  inspect(y, content="36")
  let x2 = @types.tile_to_screen_x(1)
  inspect(x2, content="128")
}

///|
test "new_player creates at position" {
  let p = @types.new_player(@types.vec2i(5, 3))
  inspect(p.pos.x, content="5")
  inspect(p.pos.y, content="3")
  inspect(p.alive, content="true")
}

///|
test "new_ghost creates active ghost" {
  let rec : Array[@types.Direction?] = [Some(East), Some(East)]
  let g = @types.new_ghost(rec, Green, @types.vec2i(1, 1))
  inspect(g.active, content="true")
  inspect(g.recording.length(), content="2")
  inspect(g.pos.x, content="1")
}

///|
test "new_game creates valid initial state" {
  let game = @types.new_game()
  inspect(game.screen, content="Title")
  inspect(game.play_state, content="Recording")
  inspect(game.ghosts.length(), content="0")
  inspect(game.level_scores.length(), content="3")
  for i in 0..<3 {
    inspect(game.level_scores[i].length(), content="8")
  }
}

///|
test "world_stars counts correctly" {
  let game = @types.new_game()
  // No stars initially
  inspect(@types.world_stars(game, 0), content="0")
  // Add some stars
  game.level_scores[0][0].stars = 3
  game.level_scores[0][1].stars = 2
  inspect(@types.world_stars(game, 0), content="5")
}

///|
test "is_world_unlocked" {
  let game = @types.new_game()
  // World 0 always unlocked
  inspect(@types.is_world_unlocked(game, 0), content="true")
  // World 1 needs 6 stars from world 0
  inspect(@types.is_world_unlocked(game, 1), content="false")
  // Give 6 stars to world 0
  game.level_scores[0][0].stars = 3
  game.level_scores[0][1].stars = 3
  inspect(@types.is_world_unlocked(game, 1), content="true")
}

///|
test "is_level_unlocked" {
  let game = @types.new_game()
  // Level 0 of world 0 is unlocked
  inspect(@types.is_level_unlocked(game, 0, 0), content="true")
  // Level 1 requires level 0 completed
  inspect(@types.is_level_unlocked(game, 0, 1), content="false")
  game.level_scores[0][0].completed = true
  inspect(@types.is_level_unlocked(game, 0, 1), content="true")
}

///|
test "set_message" {
  let game = @types.new_game()
  @types.set_message(game, "Hello", 3.0)
  inspect(game.message, content="Hello")
  inspect(game.message_timer == 3.0, content="true")
}

///|
test "new_level_score defaults" {
  let score = @types.new_level_score()
  inspect(score.completed, content="false")
  inspect(score.best_loops, content="99")
  inspect(score.stars, content="0")
}

///|
test "minf and maxf" {
  inspect(@types.minf(3.0, 5.0) == 3.0, content="true")
  inspect(@types.minf(5.0, 3.0) == 3.0, content="true")
  inspect(@types.maxf(3.0, 5.0) == 5.0, content="true")
  inspect(@types.maxf(5.0, 3.0) == 5.0, content="true")
}
