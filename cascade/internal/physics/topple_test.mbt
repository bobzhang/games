///|
test "normal domino topples range 1" {
  let dominoes = [
    @types.new_domino(@types.vec2i(2, 5), Normal, E, false, true),
    @types.new_domino(@types.vec2i(3, 5), Normal, E, true, false),
  ]
  let (events, _max_tick) = @physics.simulate(dominoes)
  // Starter should topple the target
  inspect(events.length() > 0, content="true")
  inspect(dominoes[1].state, content="Fallen")
}

///|
test "heavy domino topples range 2" {
  let dominoes = [
    @types.new_domino(@types.vec2i(2, 5), Heavy, E, false, true),
    @types.new_domino(@types.vec2i(4, 5), Normal, E, true, false),
  ]
  let (_events, _max_tick) = @physics.simulate(dominoes)
  // Heavy can reach 2 sockets away
  inspect(dominoes[1].state, content="Fallen")
}

///|
test "heavy domino does not topple range 3" {
  let dominoes = [
    @types.new_domino(@types.vec2i(2, 5), Heavy, E, false, true),
    @types.new_domino(@types.vec2i(5, 5), Normal, E, true, false),
  ]
  let (_events, _max_tick) = @physics.simulate(dominoes)
  // 3 sockets away is out of range for heavy
  inspect(dominoes[1].state, content="Standing")
}

///|
test "splitter triggers perpendicular" {
  let dominoes = [
    @types.new_domino(@types.vec2i(5, 5), Normal, E, false, true),
    @types.new_domino(@types.vec2i(6, 5), Splitter, E, false, false),
    @types.new_domino(@types.vec2i(6, 4), Normal, E, true, false),
    @types.new_domino(@types.vec2i(6, 6), Normal, E, true, false),
  ]
  let (_events, _max_tick) = @physics.simulate(dominoes)
  // Splitter facing E triggers N and S perpendicular
  inspect(dominoes[2].state, content="Fallen")
  inspect(dominoes[3].state, content="Fallen")
}

///|
test "delay waits 2 ticks" {
  let dominoes = [
    @types.new_domino(@types.vec2i(3, 5), Normal, E, false, true),
    @types.new_domino(@types.vec2i(4, 5), Delay, E, false, false),
    @types.new_domino(@types.vec2i(5, 5), Normal, E, true, false),
  ]
  let (events, _max_tick) = @physics.simulate(dominoes)
  // Find the tick when the target was hit
  let mut target_tick = -1
  for i in 0..<events.length() {
    if events[i].pos.x == 5 && events[i].pos.y == 5 {
      target_tick = events[i].tick
    }
  }
  // Delay should be at tick 0, processes at tick 1, waits 2 extra ticks,
  // so target should be hit at tick 4 or later
  inspect(target_tick >= 4, content="true")
  inspect(dominoes[2].state, content="Fallen")
}

///|
test "chain propagation A->B->C" {
  let dominoes = [
    @types.new_domino(@types.vec2i(2, 5), Normal, E, false, true),
    @types.new_domino(@types.vec2i(3, 5), Normal, E, false, false),
    @types.new_domino(@types.vec2i(4, 5), Normal, E, true, false),
  ]
  let (events, _max_tick) = @physics.simulate(dominoes)
  // All should be fallen
  inspect(dominoes[0].state, content="Fallen")
  inspect(dominoes[1].state, content="Fallen")
  inspect(dominoes[2].state, content="Fallen")
  // Events should show progressive ticks
  inspect(events.length(), content="3")
  inspect(events[0].tick < events[1].tick, content="true")
  inspect(events[1].tick < events[2].tick, content="true")
}

///|
test "target completion check" {
  let dominoes = [
    @types.new_domino(@types.vec2i(0, 0), Normal, E, true, false),
    @types.new_domino(@types.vec2i(1, 0), Normal, E, true, false),
  ]
  inspect(@physics.all_targets_fallen(dominoes), content="false")
  dominoes[0].state = Fallen
  inspect(@physics.all_targets_fallen(dominoes), content="false")
  dominoes[1].state = Fallen
  inspect(@physics.all_targets_fallen(dominoes), content="true")
}

///|
test "count_placed" {
  let dominoes = [
    @types.new_domino(@types.vec2i(0, 0), Normal, E, false, true),
    @types.new_domino(@types.vec2i(1, 0), Normal, E, true, false),
    @types.new_domino(@types.vec2i(2, 0), Normal, E, false, false),
    @types.new_domino(@types.vec2i(3, 0), Normal, E, false, false),
  ]
  inspect(@physics.count_placed(dominoes), content="2")
}

///|
test "calculate_stars" {
  // No targets hit
  inspect(@physics.calculate_stars(false, 3, 10, 3, 12), content="0")
  // All hit but over par
  inspect(@physics.calculate_stars(true, 5, 10, 3, 12), content="1")
  // Within par count but over par ticks
  inspect(@physics.calculate_stars(true, 3, 15, 3, 12), content="2")
  // Within both pars
  inspect(@physics.calculate_stars(true, 3, 10, 3, 12), content="3")
  // Under par count and under par ticks
  inspect(@physics.calculate_stars(true, 2, 8, 3, 12), content="3")
}

///|
test "domino can only be toppled once" {
  // Two dominoes point at the same target
  let dominoes = [
    @types.new_domino(@types.vec2i(3, 5), Normal, E, false, true),
    @types.new_domino(@types.vec2i(5, 4), Normal, S, false, false),
    @types.new_domino(@types.vec2i(4, 5), Normal, E, false, false),
    @types.new_domino(@types.vec2i(5, 5), Normal, E, true, false),
  ]
  let (events, _max_tick) = @physics.simulate(dominoes)
  // Target at (5,5) should only appear once in events
  let mut count = 0
  for i in 0..<events.length() {
    if events[i].pos.x == 5 && events[i].pos.y == 5 {
      count += 1
    }
  }
  inspect(count, content="1")
}

///|
test "topple does not go backwards" {
  let dominoes = [
    @types.new_domino(@types.vec2i(5, 5), Normal, E, false, true),
    @types.new_domino(@types.vec2i(4, 5), Normal, E, true, false),
  ]
  let (_events, _max_tick) = @physics.simulate(dominoes)
  // Domino at (4,5) should NOT be toppled because starter faces East
  inspect(dominoes[1].state, content="Standing")
}
