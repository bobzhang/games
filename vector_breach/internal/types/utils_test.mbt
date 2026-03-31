///|
test "grid in_bounds returns true for valid coordinates" {
  let g = @types.Grid::new(8, 8)
  inspect(g.in_bounds(0, 0), content="true")
  inspect(g.in_bounds(7, 7), content="true")
  inspect(g.in_bounds(3, 5), content="true")
}

///|
test "grid in_bounds returns false for out-of-bounds coordinates" {
  let g = @types.Grid::new(8, 8)
  inspect(g.in_bounds(-1, 0), content="false")
  inspect(g.in_bounds(0, -1), content="false")
  inspect(g.in_bounds(8, 0), content="false")
  inspect(g.in_bounds(0, 8), content="false")
  inspect(g.in_bounds(8, 8), content="false")
  inspect(g.in_bounds(-1, -1), content="false")
}

///|
test "grid get and set round-trip" {
  let g = @types.Grid::new(4, 4)
  let wall_tile : @types.Tile = { kind: Wall, hazard: None, occupied_by: -1 }
  g.set(2, 3, wall_tile)
  inspect(g.get(2, 3).kind, content="Wall")
  inspect(g.get(0, 0).kind, content="Floor")
}

///|
test "manhattan distance" {
  inspect(@types.manhattan(0, 0, 3, 4), content="7")
  inspect(@types.manhattan(2, 2, 2, 2), content="0")
  inspect(@types.manhattan(0, 0, 1, 0), content="1")
  inspect(@types.manhattan(5, 3, 1, 7), content="8")
}

///|
test "direction_dx and direction_dy" {
  inspect(@types.direction_dx(North), content="0")
  inspect(@types.direction_dy(North), content="-1")
  inspect(@types.direction_dx(South), content="0")
  inspect(@types.direction_dy(South), content="1")
  inspect(@types.direction_dx(East), content="1")
  inspect(@types.direction_dy(East), content="0")
  inspect(@types.direction_dx(West), content="-1")
  inspect(@types.direction_dy(West), content="0")
}

///|
test "direction_from_delta" {
  inspect(@types.direction_from_delta(1, 0), content="East")
  inspect(@types.direction_from_delta(-1, 0), content="West")
  inspect(@types.direction_from_delta(0, 1), content="South")
  inspect(@types.direction_from_delta(0, -1), content="North")
  inspect(@types.direction_from_delta(3, 1), content="East")
  inspect(@types.direction_from_delta(-2, -1), content="West")
}

///|
test "opposite_direction" {
  inspect(@types.opposite_direction(North), content="South")
  inspect(@types.opposite_direction(South), content="North")
  inspect(@types.opposite_direction(East), content="West")
  inspect(@types.opposite_direction(West), content="East")
}

///|
test "abs_int" {
  inspect(@types.abs_int(5), content="5")
  inspect(@types.abs_int(-5), content="5")
  inspect(@types.abs_int(0), content="0")
}

///|
test "clampf" {
  inspect(@types.clampf(0.5, 0.0, 1.0), content="0.5")
  inspect(@types.clampf(-1.0, 0.0, 1.0), content="0")
  inspect(@types.clampf(2.0, 0.0, 1.0), content="1")
}

///|
test "lerpf" {
  inspect(@types.lerpf(0.0, 10.0, 0.0), content="0")
  inspect(@types.lerpf(0.0, 10.0, 1.0), content="10")
  inspect(@types.lerpf(0.0, 10.0, 0.5), content="5")
}

///|
test "make_default_unit player" {
  let u = @types.make_default_unit(0, Player, 2, 3)
  inspect(u.id, content="0")
  inspect(u.team, content="Player")
  inspect(u.x, content="2")
  inspect(u.y, content="3")
  inspect(u.hp, content="5")
  inspect(u.active, content="true")
  inspect(u.stunned, content="false")
}

///|
test "make_default_unit enemy" {
  let u = @types.make_default_unit(1, Enemy, 6, 4)
  inspect(u.id, content="1")
  inspect(u.team, content="Enemy")
  inspect(u.hp, content="3")
}

///|
test "new_battle creates default state" {
  let b = @types.new_battle(Survive(5))
  inspect(b.grid.width, content="8")
  inspect(b.grid.height, content="8")
  inspect(b.turn, content="1")
  inspect(b.objective, content="Survive(5)")
  inspect(b.units.length(), content="0")
}

///|
test "has_augment" {
  let run : @types.RunState = {
    current_mission: 0,
    missions_completed: 0,
    squad: [0, 1, 2],
    augments: [VampireCore, HeatSink],
    grid_power: 3,
    reputation: 0,
    campaign: None,
    offered_augments: [],
    upgrade_tiers: [0, 0, 0],
    total_score: 0,
    mechs_lost: 0,
    best_combo: 0,
    total_turns: 0,
  }
  inspect(@types.has_augment(run, VampireCore), content="true")
  inspect(@types.has_augment(run, HeatSink), content="true")
  inspect(@types.has_augment(run, ChainLightning), content="false")
}
