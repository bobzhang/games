///|
test "absf" {
  inspect(absf(-3.5), content="3.5")
  inspect(absf(3.5), content="3.5")
  inspect(absf(0.0), content="0")
}

///|
test "maxf and minf" {
  inspect(maxf(1.5, 3.5), content="3.5")
  inspect(maxf(3.5, 1.5), content="3.5")
  inspect(minf(1.5, 3.5), content="1.5")
  inspect(minf(3.5, 1.5), content="1.5")
}

///|
test "mini and maxi" {
  inspect(mini(3, 7), content="3")
  inspect(mini(7, 3), content="3")
  inspect(maxi(3, 7), content="7")
  inspect(maxi(7, 3), content="7")
}

///|
test "clampf within range" {
  inspect(clampf(5.0, 0.0, 10.0), content="5")
}

///|
test "clampf below range" {
  inspect(clampf(-3.0, 0.0, 10.0), content="0")
}

///|
test "clampf above range" {
  inspect(clampf(15.0, 0.0, 10.0), content="10")
}

///|
test "clampi within range" {
  inspect(clampi(5, 0, 10), content="5")
}

///|
test "clampi below range" {
  inspect(clampi(-3, 0, 10), content="0")
}

///|
test "clampi above range" {
  inspect(clampi(15, 0, 10), content="10")
}

///|
test "lerpf at boundaries" {
  inspect(lerpf(0.0, 10.0, 0.0), content="0")
  inspect(lerpf(0.0, 10.0, 1.0), content="10")
}

///|
test "lerpf at midpoint" {
  inspect(lerpf(0.0, 10.0, 0.5), content="5")
}

///|
test "new_cell path" {
  let c = new_cell(Path)
  inspect(c.kind, content="Path")
  inspect(c.gate_open, content="true")
  inspect(c.switch_link_id, content="-1")
  inspect(c.arrow_offset, content="0")
  inspect(c.has_pickup, content="false")
}

///|
test "new_cell gate starts closed" {
  let c = new_cell(Gate)
  inspect(c.kind, content="Gate")
  inspect(c.gate_open, content="false")
}

///|
test "new_cell switch" {
  let c = new_cell(Switch)
  inspect(c.kind, content="Switch")
  inspect(c.gate_open, content="true")
}

///|
test "make_cell with custom fields" {
  let c = make_cell(
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
  let c = make_cell(Path)
  inspect(c.gate_open, content="true")
  inspect(c.switch_link_id, content="-1")
  inspect(c.arrow_offset, content="0")
  inspect(c.has_pickup, content="false")
}

///|
test "new_spiral" {
  let s = new_spiral([new_cell(Path), new_cell(Gate), new_cell(Switch)])
  inspect(s.cells.length(), content="3")
  inspect(s.cells[0].kind, content="Path")
  inspect(s.cells[1].kind, content="Gate")
  inspect(s.cells[2].kind, content="Switch")
}

///|
test "new_switch_link" {
  let link = new_switch_link(1, 2, [3, 4], [5, 6])
  inspect(link.switch_cell_cw, content="1")
  inspect(link.switch_cell_ccw, content="2")
  inspect(link.gate_cells_cw.length(), content="2")
  inspect(link.gate_cells_ccw.length(), content="2")
}

///|
test "new_level constructor" {
  let cw = new_spiral([new_cell(Path), new_cell(Path)])
  let ccw = new_spiral([new_cell(Path), new_cell(Path)])
  let lev = new_level(cw, ccw, [], 5, 3, "Test")
  inspect(lev.par_steps, content="5")
  inspect(lev.pickups_total, content="3")
  inspect(lev.name, content="Test")
  inspect(lev.switch_links.length(), content="0")
}

///|
test "new_level_score defaults" {
  let s = new_level_score()
  inspect(s.completed, content="false")
  inspect(s.steps, content="0")
  inspect(s.stars, content="0")
  inspect(s.pickups, content="0")
}

///|
test "tier_of_level" {
  inspect(tier_of_level(0), content="Coil")
  inspect(tier_of_level(7), content="Coil")
  inspect(tier_of_level(8), content="Twist")
  inspect(tier_of_level(16), content="Twist")
  inspect(tier_of_level(17), content="DoubleHelix")
  inspect(tier_of_level(24), content="DoubleHelix")
}

///|
test "tier_start_index values" {
  inspect(tier_start_index(Coil), content="0")
  inspect(tier_start_index(Twist), content="8")
  inspect(tier_start_index(DoubleHelix), content="17")
}

///|
test "tier_level_count values" {
  inspect(tier_level_count(Coil), content="8")
  inspect(tier_level_count(Twist), content="9")
  inspect(tier_level_count(DoubleHelix), content="8")
}

///|
test "tier_name values" {
  inspect(tier_name(Coil), content="Coil")
  inspect(tier_name(Twist), content="Twist")
  inspect(tier_name(DoubleHelix), content="Double Helix")
}

///|
test "calculate_stars three stars" {
  // Under par and all pickups
  inspect(calculate_stars(5, 8, 3, 3), content="3")
}

///|
test "calculate_stars two stars" {
  // Under par but not all pickups
  inspect(calculate_stars(5, 8, 1, 3), content="2")
}

///|
test "calculate_stars one star" {
  // Over par
  inspect(calculate_stars(10, 8, 3, 3), content="1")
}

///|
test "calculate_stars at par" {
  // Exactly at par with all pickups
  inspect(calculate_stars(8, 8, 5, 5), content="3")
}

///|
test "new_game initializes properly" {
  let g = new_game()
  inspect(g.screen, content="Title")
  inspect(g.selected_tier, content="Coil")
  inspect(g.cw_pos, content="0")
  inspect(g.ccw_pos, content="0")
  inspect(g.steps, content="0")
  inspect(g.play_state, content="Moving")
  inspect(g.level_scores.length(), content="25")
  inspect(g.current_level, content="None")
}
