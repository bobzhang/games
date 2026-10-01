///|
test "absf" {
  inspect(@types.absf(-3.5), content="3.5")
  inspect(@types.absf(3.5), content="3.5")
  inspect(@types.absf(0.0), content="0")
}

///|
test "maxf and minf" {
  inspect(@types.maxf(1.5, 3.5), content="3.5")
  inspect(@types.maxf(3.5, 1.5), content="3.5")
  inspect(@types.minf(1.5, 3.5), content="1.5")
  inspect(@types.minf(3.5, 1.5), content="1.5")
}

///|
test "mini and maxi" {
  inspect(@types.mini(3, 7), content="3")
  inspect(@types.mini(7, 3), content="3")
  inspect(@types.maxi(3, 7), content="7")
  inspect(@types.maxi(7, 3), content="7")
}

///|
test "clampf within range" {
  inspect(@types.clampf(5.0, 0.0, 10.0), content="5")
}

///|
test "clampf below range" {
  inspect(@types.clampf(-3.0, 0.0, 10.0), content="0")
}

///|
test "clampf above range" {
  inspect(@types.clampf(15.0, 0.0, 10.0), content="10")
}

///|
test "clampi within range" {
  inspect(@types.clampi(5, 0, 10), content="5")
}

///|
test "clampi below range" {
  inspect(@types.clampi(-3, 0, 10), content="0")
}

///|
test "clampi above range" {
  inspect(@types.clampi(15, 0, 10), content="10")
}

///|
test "lerpf at boundaries" {
  inspect(@types.lerpf(0.0, 10.0, 0.0), content="0")
  inspect(@types.lerpf(0.0, 10.0, 1.0), content="10")
}

///|
test "lerpf at midpoint" {
  inspect(@types.lerpf(0.0, 10.0, 0.5), content="5")
}

///|
test "new_cell path" {
  let c = @types.new_cell(Path)
  inspect(c.kind, content="Path")
  inspect(c.gate_open, content="true")
  inspect(c.switch_link_id, content="-1")
  inspect(c.arrow_offset, content="0")
  inspect(c.has_pickup, content="false")
}

///|
test "new_cell gate starts closed" {
  let c = @types.new_cell(Gate)
  inspect(c.kind, content="Gate")
  inspect(c.gate_open, content="false")
}

///|
test "new_cell switch" {
  let c = @types.new_cell(Switch)
  inspect(c.kind, content="Switch")
  inspect(c.gate_open, content="true")
}

///|
test "make_cell with custom fields" {
  let c = @types.make_cell(
    Gate,
    gate_open=true,
    switch_link_id=2,
    arrow_offset=1,
    has_pickup=true,
  )
  inspect(c.kind, content="Gate")
  inspect(c.gate_open, content="true")
  inspect(c.switch_link_id, content="2")
  inspect(c.arrow_offset, content="1")
  inspect(c.has_pickup, content="true")
}

///|
test "make_cell defaults" {
  let c = @types.make_cell(Path)
  inspect(c.gate_open, content="true")
  inspect(c.switch_link_id, content="-1")
  inspect(c.arrow_offset, content="0")
  inspect(c.has_pickup, content="false")
}

///|
test "new_spiral" {
  let s = @types.new_spiral([
    @types.new_cell(Path),
    @types.new_cell(Gate),
    @types.new_cell(Switch),
  ])
  inspect(s.cells.length(), content="3")
  inspect(s.cells[0].kind, content="Path")
  inspect(s.cells[1].kind, content="Gate")
  inspect(s.cells[2].kind, content="Switch")
}

///|
test "new_switch_link" {
  let link = @types.new_switch_link(1, 2, [3, 4], [5, 6])
  inspect(link.switch_cell_cw, content="1")
  inspect(link.switch_cell_ccw, content="2")
  inspect(link.gate_cells_cw.length(), content="2")
  inspect(link.gate_cells_ccw.length(), content="2")
}

///|
test "new_level constructor" {
  let cw = @types.new_spiral([@types.new_cell(Path), @types.new_cell(Path)])
  let ccw = @types.new_spiral([@types.new_cell(Path), @types.new_cell(Path)])
  let lev = @types.new_level(cw, ccw, [], 5, 3, "Test")
  inspect(lev.par_steps, content="5")
  inspect(lev.pickups_total, content="3")
  inspect(lev.name, content="Test")
  inspect(lev.switch_links.length(), content="0")
}

///|
test "new_level_score defaults" {
  let s = @types.new_level_score()
  inspect(s.completed, content="false")
  inspect(s.steps, content="0")
  inspect(s.stars, content="0")
  inspect(s.pickups, content="0")
}

///|
test "tier_of_level" {
  inspect(@types.tier_of_level(0), content="Coil")
  inspect(@types.tier_of_level(7), content="Coil")
  inspect(@types.tier_of_level(8), content="Twist")
  inspect(@types.tier_of_level(16), content="Twist")
  inspect(@types.tier_of_level(17), content="DoubleHelix")
  inspect(@types.tier_of_level(24), content="DoubleHelix")
}

///|
test "tier_start_index values" {
  inspect(@types.tier_start_index(Coil), content="0")
  inspect(@types.tier_start_index(Twist), content="8")
  inspect(@types.tier_start_index(DoubleHelix), content="17")
}

///|
test "tier_level_count values" {
  inspect(@types.tier_level_count(Coil), content="8")
  inspect(@types.tier_level_count(Twist), content="9")
  inspect(@types.tier_level_count(DoubleHelix), content="8")
}

///|
test "tier_name values" {
  inspect(@types.tier_name(Coil), content="Coil")
  inspect(@types.tier_name(Twist), content="Twist")
  inspect(@types.tier_name(DoubleHelix), content="Double Helix")
}

///|
test "calculate_stars three stars" {
  // Under par and all pickups
  inspect(@types.calculate_stars(5, 8, 3, 3), content="3")
}

///|
test "calculate_stars two stars" {
  // Under par but not all pickups
  inspect(@types.calculate_stars(5, 8, 1, 3), content="2")
}

///|
test "calculate_stars one star" {
  // Over par
  inspect(@types.calculate_stars(10, 8, 3, 3), content="1")
}

///|
test "calculate_stars at par" {
  // Exactly at par with all pickups
  inspect(@types.calculate_stars(8, 8, 5, 5), content="3")
}

///|
test "new_game initializes properly" {
  let g = @types.new_game()
  inspect(g.screen, content="Title")
  inspect(g.selected_tier, content="Coil")
  inspect(g.cw_pos, content="0")
  inspect(g.ccw_pos, content="0")
  inspect(g.steps, content="0")
  inspect(g.play_state, content="Moving")
  inspect(g.level_scores.length(), content="25")
  debug_inspect(g.current_level, content="None")
}
