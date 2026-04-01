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
test "clampf" {
  inspect(@types.clampf(0.5, 0.0, 1.0), content="0.5")
  inspect(@types.clampf(-1.0, 0.0, 1.0), content="0")
  inspect(@types.clampf(2.0, 0.0, 1.0), content="1")
}

///|
test "clampi" {
  inspect(@types.clampi(5, 0, 10), content="5")
  inspect(@types.clampi(-1, 0, 10), content="0")
  inspect(@types.clampi(15, 0, 10), content="10")
}

///|
test "lerpf" {
  inspect(@types.lerpf(0.0, 10.0, 0.0), content="0")
  inspect(@types.lerpf(0.0, 10.0, 1.0), content="10")
  inspect(@types.lerpf(0.0, 10.0, 0.5), content="5")
}

///|
test "sqrtf" {
  inspect(@types.sqrtf(4.0), content="2")
  inspect(@types.sqrtf(9.0), content="3")
}

///|
test "rng produces values in range" {
  @types.seed_rng(42)
  for _i in 0..<100 {
    let v = @types.rng_int(10)
    inspect(v >= 0 && v < 10, content="true")
  }
}

///|
test "rng_float in 0..1" {
  @types.seed_rng(123)
  for _i in 0..<100 {
    let v = @types.rng_float()
    inspect(v >= 0.0 && v < 1.0, content="true")
  }
}

///|
test "new_cell defaults" {
  let c = @types.new_cell()
  inspect(c.component, content="Empty")
  inspect(c.fixed, content="false")
  inspect(c.powered, content="false")
  inspect(c.field_lines, content="0")
  inspect(c.wattage, content="0")
  inspect(c.connections.length(), content="4")
}

///|
test "new_cell_with" {
  let c = @types.new_cell_with(Magnet(North), true)
  inspect(c.component, content="Magnet(North)")
  inspect(c.fixed, content="true")
}

///|
test "new_level_state dimensions" {
  let ls = @types.new_level_state(4, 2, 3)
  inspect(ls.cells.length(), content="6")
  inspect(ls.cells[0].length(), content="8")
  inspect(ls.magnet_budget, content="4")
  inspect(ls.coil_budget, content="2")
  inspect(ls.par_magnets, content="3")
}

///|
test "new_game initial state" {
  let g = @types.new_game()
  inspect(g.screen, content="Title")
  inspect(g.current_level, content="0")
  inspect(g.level_results.length(), content="20")
  inspect(g.sparks.length(), content="64")
  inspect(g.frame_count, content="0")
}

///|
test "cell_center coordinates" {
  let cx = @types.cell_center_x(0)
  let cy = @types.cell_center_y(0)
  inspect(cx, content="116")
  inspect(cy, content="116")
}

///|
test "direction_index" {
  inspect(@types.direction_index(Up), content="0")
  inspect(@types.direction_index(Down), content="1")
  inspect(@types.direction_index(Left), content="2")
  inspect(@types.direction_index(Right), content="3")
}

///|
test "opposite_direction" {
  inspect(@types.opposite_direction(Up), content="Down")
  inspect(@types.opposite_direction(Left), content="Right")
}

///|
test "direction_delta" {
  let (dc, dr) = @types.direction_delta(Up)
  inspect(dc, content="0")
  inspect(dr, content="-1")
  let (dc2, dr2) = @types.direction_delta(Right)
  inspect(dc2, content="1")
  inspect(dr2, content="0")
}

///|
test "in_bounds" {
  inspect(@types.in_bounds(0, 0), content="true")
  inspect(@types.in_bounds(7, 5), content="true")
  inspect(@types.in_bounds(8, 0), content="false")
  inspect(@types.in_bounds(-1, 0), content="false")
  inspect(@types.in_bounds(0, 6), content="false")
}

///|
test "is_connectable" {
  inspect(@types.is_connectable(Empty), content="false")
  inspect(@types.is_connectable(Magnet(North)), content="true")
  inspect(@types.is_connectable(Coil), content="true")
  inspect(@types.is_connectable(Wire), content="true")
  inspect(@types.is_connectable(Device(3.0)), content="true")
}

///|
test "is_conductor" {
  inspect(@types.is_conductor(Empty), content="false")
  inspect(@types.is_conductor(Magnet(North)), content="true")
  inspect(@types.is_conductor(Coil), content="true")
  inspect(@types.is_conductor(Wire), content="true")
}

///|
test "is_magnet" {
  inspect(@types.is_magnet(Magnet(North)), content="true")
  inspect(@types.is_magnet(Magnet(South)), content="true")
  inspect(@types.is_magnet(Wire), content="false")
  inspect(@types.is_magnet(Empty), content="false")
}

///|
test "is_coil" {
  inspect(@types.is_coil(Coil), content="true")
  inspect(@types.is_coil(Wire), content="false")
  inspect(@types.is_coil(Magnet(North)), content="false")
}

///|
test "manhattan_dist" {
  inspect(@types.manhattan_dist(0, 0, 3, 4), content="7")
  inspect(@types.manhattan_dist(2, 2, 2, 2), content="0")
  inspect(@types.manhattan_dist(0, 0, 1, 0), content="1")
}

///|
test "alloc_spark finds inactive" {
  let sparks : Array[@types.Spark] = []
  for _i in 0..<4 {
    sparks.push(@types.new_spark())
  }
  let idx = @types.alloc_spark(sparks)
  inspect(idx, content="0")
  sparks[0].active = true
  let idx2 = @types.alloc_spark(sparks)
  inspect(idx2, content="1")
}

///|
test "new_level_result defaults" {
  let r = @types.new_level_result()
  inspect(r.stars, content="0")
  inspect(r.completed, content="false")
}

///|
test "sinf and cosf" {
  inspect(@types.cosf(0.0), content="1")
  inspect(@types.sinf(0.0), content="0")
}

///|
test "set_message updates game" {
  let g = @types.new_game()
  @types.set_message(g, "test", 2.0)
  inspect(g.message, content="test")
  inspect(g.message_timer, content="2")
}
