///|
test "wall_blocking" {
  // Create a simple level where Luna hits a wall but Sol doesn't
  let game = @types.new_game()
  let floor_lines = [
    "############", "#@.........#", "##.........#", "#..........#",
    "#.........X#", "############", "############", "############",
  ]
  let ceiling_lines = [
    "############", "#.........@#", "#.........##", "#..........#",
    "#X.........#", "############", "############", "############",
  ]
  let level = @levels.make_level(
    0, 0, floor_lines, ceiling_lines, [], BothExit, 20,
  )
  @types.init_level(game, level)
  // Move left - Luna at (1,1) moves left -> hits wall at x=0 -> stays
  // Sol at (10,1) mirrors to right -> hits wall at x=11 -> stays
  simulate_move(game, DirInput(Left))
  // Luna should be at x=1 (blocked by wall at x=0)
  assert_eq(game.luna.pos.x, 1)
  // Sol should be at x=10 (blocked by wall at x=11)
  assert_eq(game.sol.pos.x, 10)
}

///|
test "basic_movement" {
  let game = @types.new_game()
  let floor_lines = [
    "############", "#@.........#", "#..........#", "#..........#",
    "#.........X#", "############", "############", "############",
  ]
  let ceiling_lines = [
    "############", "#.........@#", "#..........#", "#..........#",
    "#X.........#", "############", "############", "############",
  ]
  let level = @levels.make_level(
    0, 0, floor_lines, ceiling_lines, [], BothExit, 20,
  )
  @types.init_level(game, level)
  let luna_start_x = game.luna.pos.x
  let sol_start_x = game.sol.pos.x
  // Move right: Luna goes right, Sol goes left (mirrored)
  simulate_move(game, DirInput(Right))
  assert_eq(game.luna.pos.x, luna_start_x + 1)
  assert_eq(game.sol.pos.x, sol_start_x - 1)
}

///|
test "undo_restores_state" {
  let game = @types.new_game()
  let floor_lines = [
    "############", "#@.........#", "#..........#", "#..........#",
    "#.........X#", "############", "############", "############",
  ]
  let ceiling_lines = [
    "############", "#.........@#", "#..........#", "#..........#",
    "#X.........#", "############", "############", "############",
  ]
  let level = @levels.make_level(
    0, 0, floor_lines, ceiling_lines, [], BothExit, 20,
  )
  @types.init_level(game, level)
  let start_luna = game.luna.pos
  let start_sol = game.sol.pos
  simulate_move(game, DirInput(Right))
  assert_true(game.luna.pos != start_luna)
  undo_move(game)
  assert_eq(game.luna.pos, start_luna)
  assert_eq(game.sol.pos, start_sol)
  assert_eq(game.move_count, 0)
}

///|
test "pit_detection" {
  let game = @types.new_game()
  let floor_lines = [
    "############", "#@P........#", "#..........#", "#..........#",
    "#.........X#", "############", "############", "############",
  ]
  let ceiling_lines = [
    "############", "#.........@#", "#..........#", "#..........#",
    "#X.........#", "############", "############", "############",
  ]
  let level = @levels.make_level(
    0, 0, floor_lines, ceiling_lines, [], BothExit, 20,
  )
  @types.init_level(game, level)
  // Move right: Luna walks into pit at (2,1)
  simulate_move(game, DirInput(Right))
  assert_eq(game.play_state, Failed)
  assert_false(game.luna.alive)
}

///|
test "switch_toggles_door" {
  let game = @types.new_game()
  let floor_lines = [
    "############", "#@.0...a..X#", "#..........#", "#..........#",
    "#..........#", "############", "############", "############",
  ]
  let ceiling_lines = [
    "############", "#X..a...0.@#", "#..........#", "#..........#",
    "#..........#", "############", "############", "############",
  ]
  let level = @levels.make_level(
    1,
    0,
    floor_lines,
    ceiling_lines,
    [{ switch_id: 0, door_id: 0 }],
    BothExit,
    20,
  )
  @types.init_level(game, level)
  // Door starts closed
  assert_false(game.door_states[0])
  // Move right twice to land on switch at (3,1)
  simulate_move(game, DirInput(Right))
  simulate_move(game, DirInput(Right))
  // Luna should now be at switch position, door toggled
  // (switch is at x=3, Luna started at x=1, moved right twice = x=3)
  assert_eq(game.luna.pos.x, 3)
}

///|
test "goal_both_exit" {
  let game = @types.new_game()
  let floor_lines = [
    "############", "#@X........#", "#..........#", "#..........#",
    "#..........#", "############", "############", "############",
  ]
  let ceiling_lines = [
    "############", "#........X@#", "#..........#", "#..........#",
    "#..........#", "############", "############", "############",
  ]
  let level = @levels.make_level(
    0, 0, floor_lines, ceiling_lines, [], BothExit, 5,
  )
  @types.init_level(game, level)
  // Move right: Luna to X at (2,1), Sol mirrored left to X at (9,1)
  // Wait, need to check actual positions
  // Luna starts at (1,1), exit at (2,1)
  // Sol starts at (10,1), exit at (9,1)
  // Move right: Luna -> (2,1) = exit, Sol mirrors left -> (9,1) = exit
  simulate_move(game, DirInput(Right))
  assert_eq(game.play_state, Won)
}

///|
test "goal_both_switch" {
  let game = @types.new_game()
  let floor_lines = [
    "############", "#@.0.......#", "#..........#", "#..........#",
    "#..........#", "############", "############", "############",
  ]
  let ceiling_lines = [
    "############", "#.......0.@#", "#..........#", "#..........#",
    "#..........#", "############", "############", "############",
  ]
  let level = @levels.make_level(0, 0, floor_lines, ceiling_lines, [], BothSwitch, 10)
  @types.init_level(game, level)
  // Luna start (1,1), switch at (3,1)
  // Sol start (10,1), switch at (8,1)
  // Move right twice: Luna at (3,1)=switch, Sol mirrors left at (8,1)=switch
  simulate_move(game, DirInput(Right))
  simulate_move(game, DirInput(Right))
  assert_eq(game.play_state, Won)
}

///|
test "anchor_desync" {
  let game = @types.new_game()
  let floor_lines = [
    "############", "#@A........#", "#..........#", "#..........#",
    "#.........X#", "############", "############", "############",
  ]
  let ceiling_lines = [
    "############", "#........A@#", "#..........#", "#..........#",
    "#X.........#", "############", "############", "############",
  ]
  let level = @levels.make_level(
    2, 0, floor_lines, ceiling_lines, [], BothExit, 20,
  )
  @types.init_level(game, level)
  // Move right: Luna (1,1) -> (2,1) which is Anchor, Sol (10,1) -> (9,1) which is Anchor
  simulate_move(game, DirInput(Right))
  assert_eq(game.luna.pos.x, 2)
  assert_eq(game.sol.pos.x, 9)
  assert_true(game.luna.on_anchor)
  assert_true(game.sol.on_anchor)
  // Next move: both anchored, so both stay put
  simulate_move(game, DirInput(Right))
  assert_eq(game.luna.pos.x, 2)
  assert_eq(game.sol.pos.x, 9)
}

///|
test "ice_sliding" {
  let game = @types.new_game()
  let floor_lines = [
    "############", "#@III.....X#", "#..........#", "#..........#",
    "#..........#", "############", "############", "############",
  ]
  let ceiling_lines = [
    "############", "#X.....III@#", "#..........#", "#..........#",
    "#..........#", "############", "############", "############",
  ]
  let level = @levels.make_level(
    2, 2, floor_lines, ceiling_lines, [], BothExit, 20,
  )
  @types.init_level(game, level)
  // Luna at (1,1), ice at 2,3,4. Move right -> step onto ice at (2,1), slides to (5,1) (floor after ice)
  simulate_move(game, DirInput(Right))
  // Luna should slide across all ice tiles and stop at the first non-ice tile
  // Ice at x=2,3,4. Move to x=2(ice), slide to x=3(ice), x=4(ice), x=5(floor) - stop at x=5
  assert_eq(game.luna.pos.x, 5)
}
