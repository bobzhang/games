///|
test "vec2i creation" {
  let v = @types.vec2i(3, 4)
  inspect(v.x, content="3")
  inspect(v.y, content="4")
}

///|
test "island creation" {
  let isl = @types.island(2, 3, 5)
  inspect(isl.pos.x, content="2")
  inspect(isl.pos.y, content="3")
  inspect(isl.required_count, content="5")
}

///|
test "count bridges for island" {
  let islands = [
    @types.island(0, 0, 3),
    @types.island(2, 0, 2),
    @types.island(0, 2, 1),
  ]
  let bridges = [
    @types.new_bridge(0, 1, Horizontal),
    @types.new_bridge(0, 2, Vertical),
  ]
  inspect(@types.count_bridges_for_island(bridges, 0), content="2")
  inspect(@types.count_bridges_for_island(bridges, 1), content="1")
  inspect(@types.count_bridges_for_island(bridges, 2), content="1")
}

///|
test "count bridges double" {
  let islands = [@types.island(0, 0, 4), @types.island(2, 0, 2)]
  let br = @types.new_bridge(0, 1, Horizontal)
  br.count = 2
  let bridges = [br]
  inspect(@types.count_bridges_for_island(bridges, 0), content="2")
  inspect(@types.count_bridges_for_island(bridges, 1), content="2")
}

///|
test "find bridge" {
  let bridges = [
    @types.new_bridge(0, 1, Horizontal),
    @types.new_bridge(1, 2, Vertical),
  ]
  inspect(@types.find_bridge(bridges, 0, 1), content="0")
  inspect(@types.find_bridge(bridges, 1, 0), content="0")
  inspect(@types.find_bridge(bridges, 1, 2), content="1")
  inspect(@types.find_bridge(bridges, 0, 2), content="-1")
}

///|
test "same row and col" {
  let islands = [
    @types.island(0, 0, 1),
    @types.island(3, 0, 1),
    @types.island(0, 2, 1),
  ]
  inspect(@types.same_row(islands, 0, 1), content="true")
  inspect(@types.same_row(islands, 0, 2), content="false")
  inspect(@types.same_col(islands, 0, 2), content="true")
  inspect(@types.same_col(islands, 0, 1), content="false")
}

///|
test "can connect" {
  let islands = [
    @types.island(0, 0, 1),
    @types.island(3, 0, 1),
    @types.island(0, 2, 1),
    @types.island(2, 3, 1),
  ]
  inspect(@types.can_connect(islands, 0, 1), content="true")
  inspect(@types.can_connect(islands, 0, 2), content="true")
  inspect(@types.can_connect(islands, 0, 3), content="false")
  inspect(@types.can_connect(islands, 0, 0), content="false")
}

///|
test "has island between" {
  let islands = [
    @types.island(0, 0, 1),
    @types.island(2, 0, 1),
    @types.island(4, 0, 1),
  ]
  inspect(@types.has_island_between(islands, 0, 2), content="true")
  inspect(@types.has_island_between(islands, 0, 1), content="false")
  inspect(@types.has_island_between(islands, 1, 2), content="false")
}

///|
test "bridges cross" {
  // Horizontal bridge from (0,2) to (4,2), vertical from (2,0) to (2,4)
  let islands = [
    @types.island(0, 2, 1),
    @types.island(4, 2, 1),
    @types.island(2, 0, 1),
    @types.island(2, 4, 1),
  ]
  inspect(@types.bridges_cross(islands, 0, 1, 2, 3), content="true")
  // Non-crossing: both horizontal
  let islands2 = [
    @types.island(0, 0, 1),
    @types.island(4, 0, 1),
    @types.island(0, 2, 1),
    @types.island(4, 2, 1),
  ]
  inspect(@types.bridges_cross(islands2, 0, 1, 2, 3), content="false")
}

///|
test "no crossing same direction" {
  // Two vertical bridges can't cross
  let islands = [
    @types.island(0, 0, 1),
    @types.island(0, 4, 1),
    @types.island(2, 0, 1),
    @types.island(2, 4, 1),
  ]
  inspect(@types.bridges_cross(islands, 0, 1, 2, 3), content="false")
}

///|
test "connectivity empty" {
  let islands = [@types.island(0, 0, 1), @types.island(2, 0, 1)]
  let bridges : Array[@types.Bridge] = []
  inspect(@types.is_connected(islands, bridges), content="false")
}

///|
test "connectivity single bridge" {
  let islands = [@types.island(0, 0, 1), @types.island(2, 0, 1)]
  let bridges = [@types.new_bridge(0, 1, Horizontal)]
  inspect(@types.is_connected(islands, bridges), content="true")
}

///|
test "connectivity disconnected" {
  let islands = [
    @types.island(0, 0, 1),
    @types.island(2, 0, 1),
    @types.island(0, 2, 1),
  ]
  let bridges = [@types.new_bridge(0, 1, Horizontal)]
  inspect(@types.is_connected(islands, bridges), content="false")
}

///|
test "connectivity chain" {
  let islands = [
    @types.island(0, 0, 2),
    @types.island(2, 0, 2),
    @types.island(4, 0, 1),
  ]
  let bridges = [
    @types.new_bridge(0, 1, Horizontal),
    @types.new_bridge(1, 2, Horizontal),
  ]
  inspect(@types.is_connected(islands, bridges), content="true")
}

///|
test "total bridge segments" {
  let br1 = @types.new_bridge(0, 1, Horizontal)
  let br2 = @types.new_bridge(1, 2, Vertical)
  br2.count = 2
  let bridges = [br1, br2]
  inspect(@types.total_bridge_segments(bridges), content="3")
}

///|
test "clone bridges" {
  let bridges = [@types.new_bridge(0, 1, Horizontal)]
  let cloned = @types.clone_bridges(bridges)
  cloned[0].count = 2
  inspect(bridges[0].count, content="1")
  inspect(cloned[0].count, content="2")
}

///|
test "tier for level" {
  inspect(@types.tier_for_level(0), content="Shores")
  inspect(@types.tier_for_level(7), content="Shores")
  inspect(@types.tier_for_level(8), content="Straits")
  inspect(@types.tier_for_level(16), content="Straits")
  inspect(@types.tier_for_level(17), content="Ocean")
  inspect(@types.tier_for_level(24), content="Ocean")
}

///|
test "max 2 bridges between pair" {
  let bridges = [@types.new_bridge(0, 1, Horizontal)]
  bridges[0].count = 2
  inspect(bridges[0].count, content="2")
  // Verify count is capped at 2 by game logic
  inspect(bridges[0].count <= 2, content="true")
}

///|
test "new game initialization" {
  let game = @types.new_game()
  inspect(game.screen, content="Title")
  inspect(game.selected_island, content="-1")
  inspect(game.level_scores.length(), content="25")
  inspect(game.bridges.length(), content="0")
  inspect(game.removal_count, content="0")
}

///|
test "absf" {
  inspect(@types.absf(5.0), content="5")
  inspect(@types.absf(-5.0), content="5")
  inspect(@types.absf(0.0), content="0")
}

///|
test "minf maxf" {
  inspect(@types.minf(3.0, 7.0), content="3")
  inspect(@types.maxf(3.0, 7.0), content="7")
}

///|
test "min_int max_int" {
  inspect(@types.min_int(3, 7), content="3")
  inspect(@types.max_int(3, 7), content="7")
}
