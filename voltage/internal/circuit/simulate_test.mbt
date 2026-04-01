///|
test "reset_simulation clears state" {
  let state = @types.new_level_state(4, 2, 0, 0)
  state.cells[0][0].powered = true
  state.cells[0][0].voltage = 3.0
  state.devices_satisfied = 2
  @circuit.reset_simulation(state)
  inspect(state.cells[0][0].powered, content="false")
  inspect(state.cells[0][0].voltage, content="0")
  inspect(state.devices_satisfied, content="0")
}

///|
test "connect_cells creates bidirectional link" {
  let state = @types.new_level_state(4, 2, 0, 0)
  state.cells[0][0].component = Battery
  state.cells[0][1].component = Wire
  @circuit.connect_cells(state, 0, 0, 1, 0)
  // cell(0,0) should connect Right(3), cell(1,0) should connect Left(2)
  inspect(state.cells[0][0].connections[3], content="true")
  inspect(state.cells[0][1].connections[2], content="true")
}

///|
test "connect_cells rejects non-adjacent" {
  let state = @types.new_level_state(4, 2, 0, 0)
  state.cells[0][0].component = Battery
  state.cells[0][2].component = Wire
  @circuit.connect_cells(state, 0, 0, 2, 0)
  inspect(state.cells[0][0].connections[3], content="false")
}

///|
test "connect_cells rejects empty components" {
  let state = @types.new_level_state(4, 2, 0, 0)
  state.cells[0][0].component = Battery
  // cell(1,0) is Empty
  @circuit.connect_cells(state, 0, 0, 1, 0)
  inspect(state.cells[0][0].connections[3], content="false")
}

///|
test "disconnect_cells removes link" {
  let state = @types.new_level_state(4, 2, 0, 0)
  state.cells[0][0].component = Battery
  state.cells[0][1].component = Wire
  @circuit.connect_cells(state, 0, 0, 1, 0)
  inspect(state.cells[0][0].connections[3], content="true")
  @circuit.disconnect_cells(state, 0, 0, 1, 0)
  inspect(state.cells[0][0].connections[3], content="false")
  inspect(state.cells[0][1].connections[2], content="false")
}

///|
test "auto_connect connects to all neighbors" {
  let state = @types.new_level_state(4, 2, 0, 0)
  state.cells[0][0].component = Battery
  state.cells[0][2].component = Battery
  state.cells[1][1].component = Wire
  // Place wire at (1,0), should connect to (0,0) left and (2,0) right
  state.cells[0][1].component = Wire
  @circuit.auto_connect(state, 1, 0)
  inspect(state.cells[0][1].connections[2], content="true")
  inspect(state.cells[0][1].connections[3], content="true")
  inspect(state.cells[0][1].connections[1], content="true")
}

///|
test "simple series circuit: 1 battery 1 device" {
  let state = @types.new_level_state(2, 1, 0, 0)
  // Battery at (0,0), Wire at (1,0), Device(1.5) at (2,0)
  state.cells[0][0].component = Battery
  state.cells[0][1].component = Wire
  state.cells[0][2].component = Device(1.5)
  @circuit.connect_cells(state, 0, 0, 1, 0)
  @circuit.connect_cells(state, 1, 0, 2, 0)
  @circuit.simulate(state)
  inspect(state.devices_total, content="1")
  inspect(state.devices_satisfied, content="1")
  inspect(state.cells[0][2].powered, content="true")
}

///|
test "series circuit: 2 batteries = 3V" {
  let state = @types.new_level_state(4, 2, 0, 0)
  // Bat(0,0) -> Bat(1,0) -> Wire(2,0) -> Device(3.0)(3,0)
  state.cells[0][0].component = Battery
  state.cells[0][1].component = Battery
  state.cells[0][2].component = Wire
  state.cells[0][3].component = Device(3.0)
  @circuit.connect_cells(state, 0, 0, 1, 0)
  @circuit.connect_cells(state, 1, 0, 2, 0)
  @circuit.connect_cells(state, 2, 0, 3, 0)
  @circuit.simulate(state)
  inspect(state.devices_satisfied, content="1")
  // Voltage on device should be 3.0
  inspect(state.cells[0][3].voltage, content="3")
}

///|
test "device not satisfied with wrong voltage" {
  let state = @types.new_level_state(4, 2, 0, 0)
  // 1 battery (1.5V) connected to device needing 3.0V
  state.cells[0][0].component = Battery
  state.cells[0][1].component = Wire
  state.cells[0][2].component = Device(3.0)
  @circuit.connect_cells(state, 0, 0, 1, 0)
  @circuit.connect_cells(state, 1, 0, 2, 0)
  @circuit.simulate(state)
  inspect(state.devices_satisfied, content="0")
}

///|
test "can_place checks budget" {
  let state = @types.new_level_state(1, 1, 0, 0)
  inspect(@circuit.can_place(state, 0, 0, Battery), content="true")
  state.batteries_used = 1
  inspect(@circuit.can_place(state, 1, 0, Battery), content="false")
}

///|
test "can_place rejects fixed cell" {
  let state = @types.new_level_state(4, 2, 0, 0)
  state.cells[0][0].fixed = true
  inspect(@circuit.can_place(state, 0, 0, Battery), content="false")
}

///|
test "place_component increments count" {
  let state = @types.new_level_state(4, 2, 0, 0)
  let ok = @circuit.place_component(state, 0, 0, Battery)
  inspect(ok, content="true")
  inspect(state.batteries_used, content="1")
  inspect(state.cells[0][0].component, content="Battery")
}

///|
test "remove_component decrements count" {
  let state = @types.new_level_state(4, 2, 0, 0)
  let _ = @circuit.place_component(state, 0, 0, Battery)
  inspect(state.batteries_used, content="1")
  let ok = @circuit.remove_component(state, 0, 0)
  inspect(ok, content="true")
  inspect(state.batteries_used, content="0")
  inspect(state.cells[0][0].component, content="Empty")
}

///|
test "remove_component rejects fixed" {
  let state = @types.new_level_state(4, 2, 0, 0)
  state.cells[0][0].component = Battery
  state.cells[0][0].fixed = true
  let ok = @circuit.remove_component(state, 0, 0)
  inspect(ok, content="false")
}

///|
test "toggle_switch flips state" {
  let state = @types.new_level_state(4, 2, 0, 1)
  state.cells[0][0].component = Switch(false)
  let ok = @circuit.toggle_switch(state, 0, 0)
  inspect(ok, content="true")
  inspect(state.cells[0][0].component, content="Switch(true)")
  let ok2 = @circuit.toggle_switch(state, 0, 0)
  inspect(ok2, content="true")
  inspect(state.cells[0][0].component, content="Switch(false)")
}

///|
test "toggle_switch rejects non-switch" {
  let state = @types.new_level_state(4, 2, 0, 0)
  state.cells[0][0].component = Wire
  let ok = @circuit.toggle_switch(state, 0, 0)
  inspect(ok, content="false")
}

///|
test "evaluate_level 3 stars" {
  let state = @types.new_level_state(2, 1, 0, 0)
  state.cells[0][0].component = Battery
  state.cells[0][1].component = Device(1.5)
  @circuit.connect_cells(state, 0, 0, 1, 0)
  state.batteries_used = 1
  state.par_batteries = 1
  let result = @circuit.evaluate_level(state)
  inspect(result.completed, content="true")
  inspect(result.stars, content="3")
}

///|
test "evaluate_level 1 star over budget" {
  let state = @types.new_level_state(4, 1, 0, 0)
  state.cells[0][0].component = Battery
  state.cells[0][1].component = Device(1.5)
  @circuit.connect_cells(state, 0, 0, 1, 0)
  state.batteries_used = 2
  state.par_batteries = 1
  let result = @circuit.evaluate_level(state)
  inspect(result.completed, content="true")
  inspect(result.stars, content="1")
}

///|
test "disconnected device gets 0 voltage" {
  let state = @types.new_level_state(4, 2, 0, 0)
  state.cells[0][0].component = Battery
  state.cells[0][3].component = Device(1.5)
  // No connections
  @circuit.simulate(state)
  inspect(state.cells[0][3].voltage, content="0")
  inspect(state.devices_satisfied, content="0")
}

///|
test "switch off blocks current" {
  let state = @types.new_level_state(4, 2, 0, 1)
  state.cells[0][0].component = Battery
  state.cells[0][1].component = Switch(false)
  state.cells[0][2].component = Device(1.5)
  @circuit.connect_cells(state, 0, 0, 1, 0)
  @circuit.connect_cells(state, 1, 0, 2, 0)
  @circuit.simulate(state)
  inspect(state.devices_satisfied, content="0")
}

///|
test "switch on allows current" {
  let state = @types.new_level_state(4, 2, 0, 1)
  state.cells[0][0].component = Battery
  state.cells[0][1].component = Switch(true)
  state.cells[0][2].component = Device(1.5)
  @circuit.connect_cells(state, 0, 0, 1, 0)
  @circuit.connect_cells(state, 1, 0, 2, 0)
  @circuit.simulate(state)
  inspect(state.devices_satisfied, content="1")
}
