///|
fn make_test_game() -> @types.Game {
  @types.new_game()
}

///|
fn setup_level(
  game : @types.Game,
  input_pos : @types.Vec2i,
  input_rpm : Float,
  input_dir : @types.RotDir,
  input_radius : Int,
  outputs : Array[@types.Output],
  budget : Int,
) -> Unit {
  let input_kind : @types.GearKind = match input_radius {
    1 => Small
    3 => Large
    _ => Medium
  }
  let level : @types.Level = {
    name: "Test",
    tier: Gears,
    input: {
      pos: input_pos,
      rpm: input_rpm,
      dir: input_dir,
      radius: input_radius,
    },
    outputs,
    available_gears: [Small, Medium, Large, Belt, Ratchet],
    gear_budget: budget,
    par_gears: budget,
    hint: "",
  }
  game.current_level = Some(level)
  game.placed_gears = []
  game.belts = []
  game.connections = []
  // Place input gear
  let ig = @types.new_gear(input_pos, input_kind)
  ig.rpm = input_rpm
  ig.dir = input_dir
  game.placed_gears.push(ig)
}

///|
test "simulate propagates to single adjacent gear" {
  let game = make_test_game()
  let output_pos : @types.Vec2i = { x: 5, y: 0, }
  setup_level(
    game,
    { x: 2, y: 0, },
    60.0,
    CW,
    1,
    [@types.new_output(output_pos, 30.0, CCW)],
    4,
  )
  // Place a Medium gear at (5,0): dist from (2,0) = 3 = 1+2, meshes
  let g = @types.new_gear(output_pos, Medium)
  game.placed_gears.push(g)
  simulate(game)
  // Medium at output should have: rpm = 60 * (1/2) = 30, dir = CCW
  inspect(game.placed_gears[1].rpm, content="30")
  inspect(game.placed_gears[1].dir, content="CCW")
}

///|
test "simulate direction flips each mesh" {
  let game = make_test_game()
  setup_level(game, { x: 0, y: 0, }, 60.0, CW, 2, [], 6)
  // Place Medium at (4,0): dist=4 = 2+2, meshes
  let g1 = @types.new_gear({ x: 4, y: 0, }, Medium)
  game.placed_gears.push(g1)
  // Place Medium at (8,0): dist from (4,0)=4 = 2+2, meshes
  let g2 = @types.new_gear({ x: 8, y: 0, }, Medium)
  game.placed_gears.push(g2)
  simulate(game)
  // First gear: CW -> CCW
  inspect(game.placed_gears[1].dir, content="CCW")
  // Second gear: CCW -> CW
  inspect(game.placed_gears[2].dir, content="CW")
}

///|
test "simulate speed ratio small to large" {
  let game = make_test_game()
  setup_level(game, { x: 0, y: 0, }, 60.0, CW, 1, [], 4)
  // Place Large at (4,0): dist=4 = 1+3, meshes
  let g = @types.new_gear({ x: 4, y: 0, }, Large)
  game.placed_gears.push(g)
  simulate(game)
  // Speed: 60 * (1/3) = 20 RPM
  inspect(game.placed_gears[1].rpm, content="20")
}

///|
test "simulate speed ratio large to small" {
  let game = make_test_game()
  setup_level(game, { x: 0, y: 0, }, 60.0, CW, 3, [], 4)
  // Place Small at (4,0): dist=4 = 3+1, meshes
  let g = @types.new_gear({ x: 4, y: 0, }, Small)
  game.placed_gears.push(g)
  simulate(game)
  // Speed: 60 * (3/1) = 180 RPM
  inspect(game.placed_gears[1].rpm, content="180")
}

///|
test "simulate belt preserves direction" {
  let game = make_test_game()
  setup_level(game, { x: 0, y: 0, }, 60.0, CW, 2, [], 4)
  // Place Medium at (8,0): too far to mesh (dist=8 > 2+2=4)
  let g = @types.new_gear({ x: 8, y: 0, }, Medium)
  game.placed_gears.push(g)
  // Add a belt connecting them
  game.belts.push(@types.new_belt({ x: 0, y: 0, }, { x: 8, y: 0, }))
  simulate(game)
  // Belt preserves direction: should be CW
  inspect(game.placed_gears[1].dir, content="CW")
  // Same radius, ratio = 1: rpm = 60
  inspect(game.placed_gears[1].rpm, content="60")
}

///|
test "simulate output satisfaction" {
  let game = make_test_game()
  let out = @types.new_output({ x: 5, y: 0, }, 30.0, CCW)
  setup_level(game, { x: 2, y: 0, }, 60.0, CW, 1, [out], 4)
  // Place Medium at output position
  let g = @types.new_gear({ x: 5, y: 0, }, Medium)
  game.placed_gears.push(g)
  simulate(game)
  let level = game.current_level.unwrap()
  inspect(level.outputs[0].satisfied, content="true")
  inspect(game.play_state, content="Solved")
}

///|
test "simulate unsatisfied output wrong direction" {
  let game = make_test_game()
  let out = @types.new_output({ x: 5, y: 0, }, 30.0, CW) // wants CW but will get CCW
  setup_level(game, { x: 2, y: 0, }, 60.0, CW, 1, [out], 4)
  let g = @types.new_gear({ x: 5, y: 0, }, Medium)
  game.placed_gears.push(g)
  simulate(game)
  let level = game.current_level.unwrap()
  inspect(level.outputs[0].satisfied, content="false")
}

///|
test "can_place_gear checks budget" {
  let game = make_test_game()
  setup_level(
    game,
    { x: 0, y: 0, },
    60.0,
    CW,
    2,
    [],
    2, // budget = 2 (input uses 1)
  )
  // Can place one more
  inspect(can_place_gear(game, { x: 4, y: 0, }, Medium), content="true")
  // Place it
  game.placed_gears.push(@types.new_gear({ x: 4, y: 0, }, Medium))
  // Now at budget
  inspect(can_place_gear(game, { x: 8, y: 0, }, Medium), content="false")
}

///|
test "can_place_gear checks overlap" {
  let game = make_test_game()
  setup_level(game, { x: 0, y: 0, }, 60.0, CW, 2, [], 10)
  // Try to place Medium at (1,0): overlaps with input Medium at (0,0)
  // dist=1, min_dist = 2+2 = 4, 1 < 16 so overlap
  inspect(can_place_gear(game, { x: 1, y: 0, }, Medium), content="false")
  // Place at (4,0): dist=4, min_dist=4, 16 < 16 = false, so no overlap
  inspect(can_place_gear(game, { x: 4, y: 0, }, Medium), content="true")
}

///|
test "can_place_gear checks occupied" {
  let game = make_test_game()
  setup_level(game, { x: 0, y: 0, }, 60.0, CW, 2, [], 10)
  // Input gear is at (0,0)
  inspect(can_place_gear(game, { x: 0, y: 0, }, Small), content="false")
}

///|
test "simulate multi-gear chain" {
  let game = make_test_game()
  setup_level(game, { x: 0, y: 0, }, 120.0, CW, 2, [], 6)
  // Medium(0,0) -> Medium(4,0) -> Small(7,0)
  // dist 4,0 to 0,0 = 4 = 2+2 ok
  let g1 = @types.new_gear({ x: 4, y: 0, }, Medium)
  game.placed_gears.push(g1)
  // dist 7,0 to 4,0 = 3 = 2+1 ok
  let g2 = @types.new_gear({ x: 7, y: 0, }, Small)
  game.placed_gears.push(g2)
  simulate(game)
  // g1: 120 * 2/2 = 120, dir = CCW
  inspect(game.placed_gears[1].rpm, content="120")
  inspect(game.placed_gears[1].dir, content="CCW")
  // g2: 120 * 2/1 = 240, dir = CW
  inspect(game.placed_gears[2].rpm, content="240")
  inspect(game.placed_gears[2].dir, content="CW")
}
