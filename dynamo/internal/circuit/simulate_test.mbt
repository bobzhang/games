///|
test "reset_simulation clears state" {
  let state = @types.new_level_state(4, 2, 2)
  state.cells[0][0].powered = true
  state.cells[0][0].wattage = 3.0
  state.devices_satisfied = 2
  @circuit.reset_simulation(state)
  inspect(state.cells[0][0].powered, content="false")
  inspect(state.cells[0][0].wattage, content="0")
  inspect(state.devices_satisfied, content="0")
}

///|
test "connect_cells creates bidirectional link" {
  let state = @types.new_level_state(4, 2, 2)
  state.cells[0][0].component = Coil
  state.cells[0][1].component = Wire
  @circuit.connect_cells(state, 0, 0, 1, 0)
  inspect(state.cells[0][0].connections[3], content="true")
  inspect(state.cells[0][1].connections[2], content="true")
}

///|
test "connect_cells rejects non-adjacent" {
  let state = @types.new_level_state(4, 2, 2)
  state.cells[0][0].component = Coil
  state.cells[0][2].component = Wire
  @circuit.connect_cells(state, 0, 0, 2, 0)
  inspect(state.cells[0][0].connections[3], content="false")
}

///|
test "connect_cells rejects empty components" {
  let state = @types.new_level_state(4, 2, 2)
  state.cells[0][0].component = Coil
  @circuit.connect_cells(state, 0, 0, 1, 0)
  inspect(state.cells[0][0].connections[3], content="false")
}

///|
test "disconnect_cells removes link" {
  let state = @types.new_level_state(4, 2, 2)
  state.cells[0][0].component = Coil
  state.cells[0][1].component = Wire
  @circuit.connect_cells(state, 0, 0, 1, 0)
  inspect(state.cells[0][0].connections[3], content="true")
  @circuit.disconnect_cells(state, 0, 0, 1, 0)
  inspect(state.cells[0][0].connections[3], content="false")
  inspect(state.cells[0][1].connections[2], content="false")
}

///|
test "auto_connect connects to all neighbors" {
  let state = @types.new_level_state(4, 2, 2)
  state.cells[0][0].component = Coil
  state.cells[0][2].component = Coil
  state.cells[1][1].component = Wire
  state.cells[0][1].component = Wire
  @circuit.auto_connect(state, 1, 0)
  inspect(state.cells[0][1].connections[2], content="true")
  inspect(state.cells[0][1].connections[3], content="true")
  inspect(state.cells[0][1].connections[1], content="true")
}

///|
test "simple magnet-coil-device: 1 field line" {
  let state = @types.new_level_state(2, 2, 1)
  // Magnet at (0,0), Coil at (1,0), Wire at (2,0), Device(1.5) at (3,0)
  state.cells[0][0].component = Magnet(North)
  state.cells[0][1].component = Coil
  state.cells[0][2].component = Wire
  state.cells[0][3].component = Device(1.5)
  @circuit.connect_cells(state, 1, 0, 2, 0)
  @circuit.connect_cells(state, 2, 0, 3, 0)
  @circuit.simulate(state)
  inspect(state.devices_total, content="1")
  inspect(state.devices_satisfied, content="1")
  inspect(state.cells[0][1].field_lines > 0, content="true")
}

///|
test "two magnets flanking coil: 2 field lines" {
  let state = @types.new_level_state(4, 4, 2)
  // Magnet(0,2) emits down to Coil(1,2), Magnet(2,2) emits left to Coil(1,2)
  // Coil(1,2) -> Wire(1,3) -> Device(3.0)(1,4)
  state.cells[2][0].component = Magnet(North)
  state.cells[2][1].component = Coil
  state.cells[2][2].component = Magnet(South)
  state.cells[3][1].component = Wire
  state.cells[4][1].component = Device(3.0)
  @circuit.connect_cells(state, 1, 2, 1, 3)
  @circuit.connect_cells(state, 1, 3, 1, 4)
  @circuit.simulate(state)
  // Coil at (1,2) should have 2 field lines (from left and right magnets)
  inspect(state.cells[2][1].field_lines, content="2")
  inspect(state.devices_satisfied, content="1")
}

///|
test "device not satisfied with wrong wattage" {
  let state = @types.new_level_state(2, 2, 1)
  // 1 field line -> 1.5W, but device needs 3.0W
  state.cells[0][0].component = Magnet(North)
  state.cells[0][1].component = Coil
  state.cells[0][2].component = Wire
  state.cells[0][3].component = Device(3.0)
  @circuit.connect_cells(state, 1, 0, 2, 0)
  @circuit.connect_cells(state, 2, 0, 3, 0)
  @circuit.simulate(state)
  inspect(state.devices_satisfied, content="0")
}

///|
test "disconnected device gets 0 wattage" {
  let state = @types.new_level_state(4, 2, 2)
  state.cells[0][0].component = Magnet(North)
  state.cells[0][3].component = Device(1.5)
  @circuit.simulate(state)
  inspect(state.cells[0][3].wattage, content="0")
  inspect(state.devices_satisfied, content="0")
}

///|
test "can_place checks magnet budget" {
  let state = @types.new_level_state(1, 1, 1)
  inspect(@circuit.can_place(state, 0, 0, Magnet(North)), content="true")
  state.magnets_used = 1
  inspect(@circuit.can_place(state, 1, 0, Magnet(North)), content="false")
}

///|
test "can_place checks coil budget" {
  let state = @types.new_level_state(2, 1, 1)
  inspect(@circuit.can_place(state, 0, 0, Coil), content="true")
  state.coils_used = 1
  inspect(@circuit.can_place(state, 1, 0, Coil), content="false")
}

///|
test "can_place rejects fixed cell" {
  let state = @types.new_level_state(4, 2, 2)
  state.cells[0][0].fixed = true
  inspect(@circuit.can_place(state, 0, 0, Magnet(North)), content="false")
}

///|
test "place_component increments magnet count" {
  let state = @types.new_level_state(4, 2, 2)
  let ok = @circuit.place_component(state, 0, 0, Magnet(North))
  inspect(ok, content="true")
  inspect(state.magnets_used, content="1")
  inspect(state.cells[0][0].component, content="Magnet(North)")
}

///|
test "place_component increments coil count" {
  let state = @types.new_level_state(4, 2, 2)
  let ok = @circuit.place_component(state, 0, 0, Coil)
  inspect(ok, content="true")
  inspect(state.coils_used, content="1")
}

///|
test "remove_component decrements magnet count" {
  let state = @types.new_level_state(4, 2, 2)
  let _ = @circuit.place_component(state, 0, 0, Magnet(South))
  inspect(state.magnets_used, content="1")
  let ok = @circuit.remove_component(state, 0, 0)
  inspect(ok, content="true")
  inspect(state.magnets_used, content="0")
  inspect(state.cells[0][0].component, content="Empty")
}

///|
test "remove_component decrements coil count" {
  let state = @types.new_level_state(4, 2, 2)
  let _ = @circuit.place_component(state, 0, 0, Coil)
  inspect(state.coils_used, content="1")
  let ok = @circuit.remove_component(state, 0, 0)
  inspect(ok, content="true")
  inspect(state.coils_used, content="0")
}

///|
test "remove_component rejects fixed" {
  let state = @types.new_level_state(4, 2, 2)
  state.cells[0][0].component = Magnet(North)
  state.cells[0][0].fixed = true
  let ok = @circuit.remove_component(state, 0, 0)
  inspect(ok, content="false")
}

///|
test "evaluate_level 3 stars" {
  let state = @types.new_level_state(2, 2, 1)
  state.cells[0][0].component = Magnet(North)
  state.cells[0][1].component = Coil
  state.cells[0][2].component = Device(1.5)
  @circuit.connect_cells(state, 1, 0, 2, 0)
  state.magnets_used = 1
  state.coils_used = 1
  state.par_magnets = 1
  let result = @circuit.evaluate_level(state)
  inspect(result.completed, content="true")
  inspect(result.stars, content="3")
}

///|
test "evaluate_level 1 star over budget" {
  let state = @types.new_level_state(4, 2, 1)
  state.cells[0][0].component = Magnet(North)
  state.cells[0][1].component = Coil
  state.cells[0][2].component = Device(1.5)
  @circuit.connect_cells(state, 1, 0, 2, 0)
  state.magnets_used = 2
  state.coils_used = 1
  state.par_magnets = 1
  let result = @circuit.evaluate_level(state)
  inspect(result.completed, content="true")
  inspect(result.stars, content="1")
}

///|
test "magnet blocks field line from passing through" {
  let state = @types.new_level_state(4, 2, 2)
  // Magnet at (0,0), Magnet at (1,0) blocks, Coil at (2,0)
  state.cells[0][0].component = Magnet(North)
  state.cells[0][1].component = Magnet(South)
  state.cells[0][2].component = Coil
  state.cells[0][3].component = Device(1.5)
  @circuit.connect_cells(state, 2, 0, 3, 0)
  @circuit.simulate(state)
  // Coil at (2,0) gets field line from Magnet at (1,0) but not from (0,0)
  // because (1,0) blocks (0,0)'s rightward line
  inspect(state.cells[0][2].field_lines, content="1")
}

///|
test "field line strength decreases with distance" {
  let state = @types.new_level_state(4, 2, 2)
  // Magnet at (0,0), empty cells, coil far away at (7,0)
  state.cells[0][0].component = Magnet(North)
  state.cells[0][7].component = Coil
  state.cells[0][7].component = Coil
  @circuit.simulate(state)
  // Field strength starts at 1.0, decreases 0.15 per cell
  // After 6 cells: 1.0 - 6*0.15 = 0.1 -> just barely reaches
  // The coil should capture the field line
  inspect(state.cells[0][7].field_lines > 0, content="true")
}

///|
test "coil not connected to device generates no satisfaction" {
  let state = @types.new_level_state(4, 2, 2)
  state.cells[0][0].component = Magnet(North)
  state.cells[0][1].component = Coil
  state.cells[0][5].component = Device(1.5)
  // No connections between coil and device
  @circuit.simulate(state)
  inspect(state.devices_satisfied, content="0")
}

///|
test "count_field_lines_at tracks field line paths" {
  let state = @types.new_level_state(4, 2, 2)
  state.cells[0][0].component = Magnet(North)
  state.cells[0][4].component = Coil
  @circuit.simulate(state)
  // Field line goes from (0,0) to (4,0), cells (1,0), (2,0), (3,0) are on path
  let count = @circuit.count_field_lines_at(state, 2, 0)
  inspect(count > 0, content="true")
}

///|
test "multiple coils on same network sum power" {
  let state = @types.new_level_state(4, 4, 2)
  // Two magnets feeding two coils, wired to one device
  state.cells[0][0].component = Magnet(North)
  state.cells[0][1].component = Coil
  state.cells[2][0].component = Magnet(South)
  state.cells[2][1].component = Coil
  state.cells[1][1].component = Wire
  state.cells[1][2].component = Device(3.0)
  @circuit.connect_cells(state, 1, 0, 1, 1)
  @circuit.connect_cells(state, 1, 2, 1, 1)
  @circuit.connect_cells(state, 1, 1, 2, 1)
  @circuit.simulate(state)
  // Each coil gets 1 field line = 1.5W each, total = 3.0W
  inspect(state.devices_satisfied, content="1")
}

///|
test "wire placement auto-connects" {
  let state = @types.new_level_state(4, 2, 2)
  state.cells[0][0].component = Coil
  let ok = @circuit.place_component(state, 1, 0, Wire)
  inspect(ok, content="true")
  // Should auto-connect to coil on left
  inspect(state.cells[0][1].connections[2], content="true")
  inspect(state.cells[0][0].connections[3], content="true")
}
