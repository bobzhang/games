///|
test "cosf and sinf" {
  inspect(@types.cosf(0.0), content="1")
  inspect(@types.sinf(0.0), content="0")
}

///|
test "absf" {
  inspect(@types.absf(5.0), content="5")
  inspect(@types.absf(-5.0), content="5")
  inspect(@types.absf(0.0), content="0")
}

///|
test "clampf" {
  inspect(@types.clampf(0.5, 0.0, 1.0), content="0.5")
  inspect(@types.clampf(-1.0, 0.0, 1.0), content="0")
  inspect(@types.clampf(2.0, 0.0, 1.0), content="1")
}

///|
test "maxf and minf" {
  inspect(@types.maxf(3.0, 7.0), content="7")
  inspect(@types.minf(3.0, 7.0), content="3")
}

///|
test "lerpf" {
  inspect(@types.lerpf(0.0, 10.0, 0.0), content="0")
  inspect(@types.lerpf(0.0, 10.0, 1.0), content="10")
  inspect(@types.lerpf(0.0, 10.0, 0.5), content="5")
}

///|
test "maxi and mini" {
  inspect(@types.maxi(3, 7), content="7")
  inspect(@types.mini(3, 7), content="3")
}

///|
test "gear_radius" {
  inspect(@types.gear_radius(Small), content="24")
  inspect(@types.gear_radius(Medium), content="36")
  inspect(@types.gear_radius(Large), content="48")
}

///|
test "gear_teeth" {
  inspect(@types.gear_teeth(Small), content="8")
  inspect(@types.gear_teeth(Medium), content="12")
  inspect(@types.gear_teeth(Large), content="16")
}

///|
test "gear_speed_ratio" {
  inspect(@types.gear_speed_ratio(Small), content="2")
  inspect(@types.gear_speed_ratio(Medium), content="1")
  inspect(@types.gear_speed_ratio(Large), content="0.5")
}

///|
test "cell_center" {
  let cx = @types.cell_center_x(0)
  let cy = @types.cell_center_y(0)
  inspect(cx, content="112")
  inspect(cy, content="112")
}

///|
test "grid_valid" {
  inspect(@types.grid_valid(0, 0), content="true")
  inspect(@types.grid_valid(7, 7), content="true")
  inspect(@types.grid_valid(-1, 0), content="false")
  inspect(@types.grid_valid(8, 0), content="false")
}

///|
test "new_component" {
  let c = @types.new_component(Gear(Small), 3, 4)
  inspect(c.active, content="true")
  inspect(c.col, content="3")
  inspect(c.row, content="4")
  inspect(c.fixed, content="false")
  inspect(c.rotation, content="0")
}

///|
test "new_fixed_component" {
  let c = @types.new_fixed_component(Gear(Medium), 1, 2)
  inspect(c.fixed, content="true")
  inspect(c.col, content="1")
}

///|
test "new_bell" {
  let b = @types.new_bell(5, 5, 10)
  inspect(b.kind, content="Bell")
  inspect(b.bell_target_tick, content="10")
  inspect(b.fixed, content="true")
}

///|
test "palette operations" {
  let p = @types.new_palette()
  @types.palette_add(p, Gear(Small), 3)
  @types.palette_add(p, Cam, 2)
  inspect(p.available.length(), content="2")
  inspect(@types.palette_remaining(p, 0), content="3")
  inspect(@types.palette_remaining(p, 1), content="2")
  inspect(@types.palette_remaining(p, 5), content="0")
}

///|
test "new_simulation" {
  let sim = @types.new_simulation()
  inspect(sim.state, content="Idle")
  inspect(sim.tick, content="0")
  inspect(sim.bells_rung.length(), content="0")
}

///|
test "reset_simulation" {
  let sim = @types.new_simulation()
  sim.state = Running
  sim.tick = 42
  sim.bells_rung = [1, 2, 3]
  @types.reset_simulation(sim)
  inspect(sim.state, content="Idle")
  inspect(sim.tick, content="0")
  inspect(sim.bells_rung.length(), content="0")
}

///|
test "new_game initial state" {
  let game = @types.new_game()
  inspect(game.screen, content="Title")
  inspect(game.components.length(), content="0")
  inspect(game.level_stars.length(), content="20")
  inspect(game.frame_count, content="0")
  inspect(game.current_level, content="0")
}

///|
test "grid operations" {
  let game = @types.new_game()
  inspect(@types.grid_get(game, 0, 0), content="-1")
  @types.grid_set(game, 3, 4, 5)
  inspect(@types.grid_get(game, 3, 4), content="5")
  @types.clear_grid(game)
  inspect(@types.grid_get(game, 3, 4), content="-1")
}

///|
test "count_placed_components" {
  let game = @types.new_game()
  inspect(@types.count_placed_components(game), content="0")
  let c1 = @types.new_component(Gear(Small), 0, 0)
  game.components.push(c1)
  inspect(@types.count_placed_components(game), content="1")
  let c2 = @types.new_fixed_component(Bell, 1, 1)
  game.components.push(c2)
  inspect(@types.count_placed_components(game), content="1")
}

///|
test "mouse_to_grid" {
  let col = @types.mouse_to_grid_col(112)
  let row = @types.mouse_to_grid_row(112)
  inspect(col, content="0")
  inspect(row, content="0")
}

///|
test "component_color" {
  let c1 = @types.component_color(Gear(Small))
  inspect(c1 == @types.color_gear_copper, content="true")
  let c2 = @types.component_color(Bell)
  inspect(c2 == @types.color_bell, content="true")
}

///|
test "tier_name" {
  inspect(@types.tier_name(Ticks), content="Ticks")
  inspect(@types.tier_name(Timing), content="Timing")
  inspect(@types.tier_name(Clockwork), content="Clockwork")
}

///|
test "set_message" {
  let game = @types.new_game()
  @types.set_message(game, "Hello", 2.0)
  inspect(game.message, content="Hello")
  inspect(game.message_timer, content="2")
}

///|
test "sqrtf" {
  inspect(@types.sqrtf(4.0), content="2")
  inspect(@types.sqrtf(9.0), content="3")
}

///|
test "fmodf" {
  inspect(@types.fmodf(5.0, 3.0), content="2")
  inspect(@types.fmodf(10.0, 5.0), content="0")
}
