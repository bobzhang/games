///|
test "token advancement on empty path" {
  let cw = @types.new_spiral([
    @types.new_cell(Path),
    @types.new_cell(Path),
    @types.new_cell(Path),
    @types.new_cell(Path),
    @types.new_cell(Path),
  ])
  let ccw = @types.new_spiral([
    @types.new_cell(Path),
    @types.new_cell(Path),
    @types.new_cell(Path),
    @types.new_cell(Path),
    @types.new_cell(Path),
  ])
  let level = @types.new_level(cw, ccw, [], 5, 0, "test")
  let game = @types.new_game()
  game.current_level = Some(level)
  game.pickups_collected = [false, false, false, false, false, false, false, false, false, false]
  game.oneshot_used = []
  game.screen = Playing
  game.play_state = Moving
  @spiral.step(game)
  inspect(game.cw_pos, content="1")
  inspect(game.ccw_pos, content="1")
  inspect(game.steps, content="1")
  @spiral.step(game)
  inspect(game.cw_pos, content="2")
  inspect(game.ccw_pos, content="2")
}

///|
test "gate blocking when closed" {
  let cw = @types.new_spiral([
    @types.new_cell(Path),
    @types.make_cell(Gate, gate_open=false),
    @types.new_cell(Path),
    @types.new_cell(Path),
    @types.new_cell(Path),
  ])
  let ccw = @types.new_spiral([
    @types.new_cell(Path),
    @types.new_cell(Path),
    @types.new_cell(Path),
    @types.new_cell(Path),
    @types.new_cell(Path),
  ])
  let level = @types.new_level(cw, ccw, [], 5, 0, "test")
  let game = @types.new_game()
  game.current_level = Some(level)
  game.pickups_collected = [false, false, false, false, false, false, false, false, false, false]
  game.oneshot_used = []
  game.play_state = Moving
  @spiral.step(game)
  // CW blocked by closed gate at pos 1, CCW moves to 1
  inspect(game.cw_pos, content="0")
  inspect(game.ccw_pos, content="1")
}

///|
test "switch toggles gates" {
  let cw = @types.new_spiral([
    @types.new_cell(Path),
    @types.make_cell(Switch, switch_link_id=0),
    @types.new_cell(Path),
    @types.new_cell(Path),
    @types.new_cell(Path),
  ])
  let ccw = @types.new_spiral([
    @types.new_cell(Path),
    @types.new_cell(Path),
    @types.make_cell(Gate, gate_open=false, switch_link_id=0),
    @types.new_cell(Path),
    @types.new_cell(Path),
  ])
  let level = @types.new_level(
    cw,
    ccw,
    [@types.new_switch_link(1, -1, [], [2])],
    5,
    0,
    "test",
  )
  let game = @types.new_game()
  game.current_level = Some(level)
  game.pickups_collected = [false, false, false, false, false, false, false, false, false, false]
  game.oneshot_used = [false]
  game.play_state = Moving
  // Initially gate at ccw[2] is closed
  inspect(level.ccw_spiral.cells[2].gate_open, content="false")
  // Step to position 1 - CW lands on switch
  @spiral.step(game)
  // Gate should now be open
  inspect(level.ccw_spiral.cells[2].gate_open, content="true")
}

///|
test "win detection" {
  let cw = @types.new_spiral([
    @types.new_cell(Path),
    @types.new_cell(Path),
    @types.new_cell(Path),
  ])
  let ccw = @types.new_spiral([
    @types.new_cell(Path),
    @types.new_cell(Path),
    @types.new_cell(Path),
  ])
  let level = @types.new_level(cw, ccw, [], 3, 0, "test")
  let game = @types.new_game()
  game.current_level = Some(level)
  game.pickups_collected = [false, false, false, false, false, false]
  game.oneshot_used = []
  game.play_state = Moving
  @spiral.step(game)
  inspect(game.play_state, content="Moving")
  @spiral.step(game)
  // Both at position 2 (last cell, index 2)
  inspect(game.play_state, content="Won")
}

///|
test "one-shot switch permanent activation" {
  let cw = @types.new_spiral([
    @types.new_cell(Path),
    @types.make_cell(OneShotSwitch, switch_link_id=0),
    @types.new_cell(Path),
    @types.new_cell(Path),
    @types.new_cell(Path),
  ])
  let ccw = @types.new_spiral([
    @types.new_cell(Path),
    @types.new_cell(Path),
    @types.make_cell(Gate, gate_open=false, switch_link_id=0),
    @types.new_cell(Path),
    @types.new_cell(Path),
  ])
  let level = @types.new_level(
    cw,
    ccw,
    [@types.new_switch_link(1, -1, [], [2])],
    5,
    0,
    "test",
  )
  let game = @types.new_game()
  game.current_level = Some(level)
  game.pickups_collected = [false, false, false, false, false, false, false, false, false, false]
  game.oneshot_used = [false]
  game.play_state = Moving
  inspect(level.ccw_spiral.cells[2].gate_open, content="false")
  // Step - CW lands on one-shot at pos 1
  @spiral.step(game)
  inspect(level.ccw_spiral.cells[2].gate_open, content="true")
  inspect(game.oneshot_used[0], content="true")
}

///|
test "arrow offset skip" {
  let cw = @types.new_spiral([
    @types.new_cell(Path),
    @types.make_cell(Path, arrow_offset=2),
    @types.new_cell(Path),
    @types.new_cell(Path),
    @types.new_cell(Path),
    @types.new_cell(Path),
  ])
  let ccw = @types.new_spiral([
    @types.new_cell(Path),
    @types.new_cell(Path),
    @types.new_cell(Path),
    @types.new_cell(Path),
    @types.new_cell(Path),
    @types.new_cell(Path),
  ])
  let level = @types.new_level(cw, ccw, [], 6, 0, "test")
  let game = @types.new_game()
  game.current_level = Some(level)
  game.pickups_collected = [false, false, false, false, false, false, false, false, false, false, false, false]
  game.oneshot_used = []
  game.play_state = Moving
  // Step to pos 1, arrow pushes +2 to pos 3
  @spiral.step(game)
  inspect(game.cw_pos, content="3")
  inspect(game.ccw_pos, content="1")
}

///|
test "check blocked detects stuck state" {
  let cw = @types.new_spiral([
    @types.new_cell(Path),
    @types.make_cell(Gate, gate_open=false),
    @types.new_cell(Path),
  ])
  let ccw = @types.new_spiral([
    @types.new_cell(Path),
    @types.make_cell(Gate, gate_open=false),
    @types.new_cell(Path),
  ])
  let level = @types.new_level(cw, ccw, [], 3, 0, "test")
  let game = @types.new_game()
  game.current_level = Some(level)
  game.pickups_collected = [false, false, false, false, false, false]
  game.oneshot_used = []
  game.play_state = Moving
  // Both at position 0, next is closed gate
  let blocked = @spiral.check_blocked(game)
  inspect(blocked, content="true")
}
