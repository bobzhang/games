///|
test "orientation_dx N" {
  inspect(@types.orientation_dx(N), content="0")
}

///|
test "orientation_dy N" {
  inspect(@types.orientation_dy(N), content="-1")
}

///|
test "orientation_dx E" {
  inspect(@types.orientation_dx(E), content="1")
}

///|
test "orientation_dy E" {
  inspect(@types.orientation_dy(E), content="0")
}

///|
test "orientation_dx S" {
  inspect(@types.orientation_dx(S), content="0")
}

///|
test "orientation_dy S" {
  inspect(@types.orientation_dy(S), content="1")
}

///|
test "orientation_dx W" {
  inspect(@types.orientation_dx(W), content="-1")
}

///|
test "orientation_dy W" {
  inspect(@types.orientation_dy(W), content="0")
}

///|
test "orientation_dx NE" {
  inspect(@types.orientation_dx(NE), content="1")
}

///|
test "orientation_dy NE" {
  inspect(@types.orientation_dy(NE), content="-1")
}

///|
test "orientation_dx SE" {
  inspect(@types.orientation_dx(SE), content="1")
}

///|
test "orientation_dy SE" {
  inspect(@types.orientation_dy(SE), content="1")
}

///|
test "orientation_dx SW" {
  inspect(@types.orientation_dx(SW), content="-1")
}

///|
test "orientation_dy SW" {
  inspect(@types.orientation_dy(SW), content="1")
}

///|
test "orientation_dx NW" {
  inspect(@types.orientation_dx(NW), content="-1")
}

///|
test "orientation_dy NW" {
  inspect(@types.orientation_dy(NW), content="-1")
}

///|
test "perpendicular N/S gives W/E" {
  let (a, b) = @types.perpendicular_orientations(N)
  inspect(a, content="W")
  inspect(b, content="E")
}

///|
test "perpendicular E/W gives N/S" {
  let (a, b) = @types.perpendicular_orientations(E)
  inspect(a, content="N")
  inspect(b, content="S")
}

///|
test "perpendicular NE/SW gives NW/SE" {
  let (a, b) = @types.perpendicular_orientations(NE)
  inspect(a, content="NW")
  inspect(b, content="SE")
}

///|
test "next_orientation cycles" {
  inspect(@types.next_orientation(N), content="NE")
  inspect(@types.next_orientation(NE), content="E")
  inspect(@types.next_orientation(E), content="SE")
  inspect(@types.next_orientation(NW), content="N")
}

///|
test "prev_orientation cycles" {
  inspect(@types.prev_orientation(N), content="NW")
  inspect(@types.prev_orientation(NE), content="N")
  inspect(@types.prev_orientation(E), content="NE")
}

///|
test "socket_to_screen and back" {
  let sx = @types.socket_to_screen_x(5)
  let sy = @types.socket_to_screen_y(3)
  let gx = @types.screen_to_socket_x(sx)
  let gy = @types.screen_to_socket_y(sy)
  inspect(gx, content="5")
  inspect(gy, content="3")
}

///|
test "in_grid bounds" {
  inspect(@types.in_grid(0, 0), content="true")
  inspect(@types.in_grid(15, 11), content="true")
  inspect(@types.in_grid(16, 0), content="false")
  inspect(@types.in_grid(0, 12), content="false")
  inspect(@types.in_grid(-1, 0), content="false")
}

///|
test "vec2i_eq" {
  let a = @types.vec2i(3, 4)
  let b = @types.vec2i(3, 4)
  let c = @types.vec2i(5, 4)
  inspect(@types.vec2i_eq(a, b), content="true")
  inspect(@types.vec2i_eq(a, c), content="false")
}

///|
test "find_domino_at" {
  let dominoes = [
    @types.new_domino(@types.vec2i(1, 2), Normal, E, false, false),
    @types.new_domino(@types.vec2i(3, 4), Normal, S, true, false),
  ]
  inspect(@types.find_domino_at(dominoes, @types.vec2i(1, 2)), content="0")
  inspect(@types.find_domino_at(dominoes, @types.vec2i(3, 4)), content="1")
  inspect(@types.find_domino_at(dominoes, @types.vec2i(5, 6)), content="-1")
}

///|
test "count_targets" {
  let dominoes = [
    @types.new_domino(@types.vec2i(0, 0), Normal, E, true, false),
    @types.new_domino(@types.vec2i(1, 0), Normal, E, false, false),
    @types.new_domino(@types.vec2i(2, 0), Normal, E, true, false),
  ]
  inspect(@types.count_targets(dominoes), content="2")
}

///|
test "count_fallen_targets" {
  let dominoes = [
    @types.new_domino(@types.vec2i(0, 0), Normal, E, true, false),
    @types.new_domino(@types.vec2i(1, 0), Normal, E, true, false),
  ]
  dominoes[0].state = Fallen
  inspect(@types.count_fallen_targets(dominoes), content="1")
}

///|
test "budget_remaining" {
  let budget = @types.new_budget(3, 1, 0, 0)
  let dominoes = [
    @types.new_domino(@types.vec2i(0, 0), Normal, E, false, false),
    @types.new_domino(@types.vec2i(1, 0), Normal, E, true, false),
    @types.new_domino(@types.vec2i(2, 0), Normal, E, false, true),
  ]
  // Only non-target, non-starter count against budget
  inspect(@types.budget_remaining(budget, dominoes, Normal), content="2")
  inspect(@types.budget_remaining(budget, dominoes, Heavy), content="1")
}

///|
test "clone_domino preserves fields" {
  let d = @types.new_domino(@types.vec2i(5, 7), Heavy, NE, true, false)
  d.state = Toppling
  d.topple_tick = 3
  let c = @types.clone_domino(d)
  inspect(c.pos.x, content="5")
  inspect(c.pos.y, content="7")
  inspect(c.kind, content="Heavy")
  inspect(c.orientation, content="NE")
  inspect(c.is_target, content="true")
  inspect(c.state, content="Toppling")
  inspect(c.topple_tick, content="3")
}

///|
test "kind_range" {
  inspect(@types.kind_range(Normal), content="1")
  inspect(@types.kind_range(Heavy), content="2")
  inspect(@types.kind_range(Splitter), content="1")
  inspect(@types.kind_range(Delay), content="1")
}

///|
test "clampf" {
  inspect(@types.clampf(0.5, 0.0, 1.0), content="0.5")
  inspect(@types.clampf(-1.0, 0.0, 1.0), content="0")
  inspect(@types.clampf(2.0, 0.0, 1.0), content="1")
}

///|
test "lerpf" {
  inspect(@types.lerpf(0.0, 10.0, 0.5), content="5")
  inspect(@types.lerpf(0.0, 10.0, 0.0), content="0")
  inspect(@types.lerpf(0.0, 10.0, 1.0), content="10")
}

///|
test "new_game initializes scores" {
  let game = @types.new_game()
  inspect(game.screen, content="Title")
  inspect(game.scores.length(), content="24")
  inspect(game.play_state, content="Editing")
  inspect(game.tick_speed, content="2")
}

///|
test "level_index" {
  inspect(@types.level_index(Chains, 0), content="0")
  inspect(@types.level_index(Chains, 7), content="7")
  inspect(@types.level_index(Splits, 0), content="8")
  inspect(@types.level_index(Timing, 0), content="16")
  inspect(@types.level_index(Timing, 7), content="23")
}
