///|
test "island satisfied" {
  let islands = [@types.island(0, 0, 2), @types.island(2, 0, 2)]
  let br = @types.new_bridge(0, 1, Horizontal)
  br.count = 2
  let bridges = [br]
  inspect(@solver.is_island_satisfied(islands, bridges, 0), content="true")
  inspect(@solver.is_island_satisfied(islands, bridges, 1), content="true")
}

///|
test "island not satisfied" {
  let islands = [@types.island(0, 0, 2), @types.island(2, 0, 1)]
  let bridges = [@types.new_bridge(0, 1, Horizontal)]
  inspect(@solver.is_island_satisfied(islands, bridges, 0), content="false")
  inspect(@solver.is_island_satisfied(islands, bridges, 1), content="true")
}

///|
test "island over" {
  let islands = [@types.island(0, 0, 1), @types.island(2, 0, 1)]
  let br = @types.new_bridge(0, 1, Horizontal)
  br.count = 2
  let bridges = [br]
  inspect(@solver.is_island_over(islands, bridges, 0), content="true")
}

///|
test "all islands satisfied" {
  let islands = [@types.island(0, 0, 1), @types.island(2, 0, 1)]
  let bridges = [@types.new_bridge(0, 1, Horizontal)]
  inspect(@solver.all_islands_satisfied(islands, bridges), content="true")
}

///|
test "has crossing" {
  let islands = [
    @types.island(0, 2, 1),
    @types.island(4, 2, 1),
    @types.island(2, 0, 1),
    @types.island(2, 4, 1),
  ]
  let bridges = [
    @types.new_bridge(0, 1, Horizontal),
    @types.new_bridge(2, 3, Vertical),
  ]
  inspect(@solver.has_crossing(islands, bridges), content="true")
}

///|
test "no crossing" {
  let islands = [
    @types.island(0, 0, 1),
    @types.island(2, 0, 1),
    @types.island(0, 2, 1),
    @types.island(0, 4, 1),
  ]
  let bridges = [
    @types.new_bridge(0, 1, Horizontal),
    @types.new_bridge(2, 3, Vertical),
  ]
  inspect(@solver.has_crossing(islands, bridges), content="false")
}

///|
test "puzzle solved simple" {
  let islands = [
    @types.island(0, 0, 2),
    @types.island(2, 0, 2),
    @types.island(0, 2, 2),
    @types.island(2, 2, 2),
  ]
  let bridges = [
    @types.new_bridge(0, 1, Horizontal),
    @types.new_bridge(0, 2, Vertical),
    @types.new_bridge(1, 3, Vertical),
    @types.new_bridge(2, 3, Horizontal),
  ]
  inspect(@solver.is_puzzle_solved(islands, bridges), content="true")
}

///|
test "puzzle not solved - unsatisfied" {
  let islands = [
    @types.island(0, 0, 2),
    @types.island(2, 0, 1),
    @types.island(0, 2, 1),
  ]
  let bridges = [@types.new_bridge(0, 1, Horizontal)]
  inspect(@solver.is_puzzle_solved(islands, bridges), content="false")
}

///|
test "satisfaction counts" {
  let islands = [
    @types.island(0, 0, 1),
    @types.island(2, 0, 2),
    @types.island(4, 0, 1),
  ]
  let bridges = [
    @types.new_bridge(0, 1, Horizontal),
    @types.new_bridge(1, 2, Horizontal),
  ]
  let (sat, total) = @solver.satisfaction_counts(islands, bridges)
  inspect(sat, content="3")
  inspect(total, content="3")
}

///|
test "compute stars - 1 star" {
  let br = @types.new_bridge(0, 1, Horizontal)
  br.count = 2
  let bridges = [br, @types.new_bridge(1, 2, Vertical)]
  // 3 segments, par is 2 -> over par -> 1 star
  inspect(@solver.compute_stars(bridges, 2, 0), content="1")
}

///|
test "compute stars - 2 stars" {
  let bridges = [@types.new_bridge(0, 1, Horizontal)]
  // 1 segment, par is 2 -> within par but has removals -> 2 stars
  inspect(@solver.compute_stars(bridges, 2, 1), content="2")
}

///|
test "compute stars - 3 stars" {
  let bridges = [@types.new_bridge(0, 1, Horizontal)]
  // 1 segment, par is 2, no removals -> 3 stars
  inspect(@solver.compute_stars(bridges, 2, 0), content="3")
}

///|
test "forced bridge detection" {
  // Island 0 needs 1, only one neighbor possible
  let islands = [
    @types.island(0, 0, 1),
    @types.island(2, 0, 1),
  ]
  let bridges : Array[@types.Bridge] = []
  let (a, b) = @solver.find_forced_bridge(islands, bridges)
  inspect(a >= 0, content="true")
  inspect(b >= 0, content="true")
}

///|
test "hint when no forced" {
  let islands = [
    @types.island(0, 0, 2),
    @types.island(2, 0, 2),
    @types.island(0, 2, 2),
    @types.island(2, 2, 2),
  ]
  let bridges : Array[@types.Bridge] = []
  let (a, b) = @solver.find_hint(islands, bridges)
  inspect(a >= 0, content="true")
  inspect(b >= 0, content="true")
}
