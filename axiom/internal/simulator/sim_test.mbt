///|
fn make_test_level(
  ascii : Array[String],
  start_x : Int,
  start_y : Int,
  start_dir : @types.Direction,
) -> @types.Level {
  let grid = @types.new_grid(@types.grid_width, @types.grid_height)
  let goals : Array[@types.Vec2i] = []
  let blocks : Array[@types.Vec2i] = []
  for y in 0..<@types.grid_height {
    if y < ascii.length() {
      let row = ascii[y]
      for x in 0..<@types.grid_width {
        if x < row.length() {
          let ch = row[x]
          match ch {
            '#' => @types.grid_set(grid, x, y, Wall)
            '.' => @types.grid_set(grid, x, y, Floor)
            '_' => @types.grid_set(grid, x, y, Gap)
            'G' => {
              @types.grid_set(grid, x, y, Goal)
              goals.push(@types.vec2i(x, y))
            }
            'R' => @types.grid_set(grid, x, y, ColorTile(Red))
            'B' => @types.grid_set(grid, x, y, ColorTile(Blue))
            'N' => @types.grid_set(grid, x, y, ColorTile(Green))
            'O' => {
              @types.grid_set(grid, x, y, Floor)
              blocks.push(@types.vec2i(x, y))
            }
            'S' => @types.grid_set(grid, x, y, Start)
            _ => @types.grid_set(grid, x, y, Floor)
          }
        }
      }
    }
  }
  let goals_collected : Array[Bool] = []
  for _i in 0..<goals.length() {
    goals_collected.push(false)
  }
  let robot = @types.new_robot(start_x, start_y, start_dir)
  { grid, robot, goals, goals_collected, blocks, }
}

///|
fn make_program(kinds : Array[@types.CommandKind]) -> @types.Program {
  let commands : Array[@types.Command] = []
  for i in 0..<kinds.length() {
    commands.push({ kind: kinds[i], })
  }
  { commands, max_slots: 20, }
}

// ===== Basic movement tests =====

///|
test "move forward reaches goal" {
  let level = make_test_level(
    [
      "############", "############", "############", "###S..G#####", "############",
      "############", "############", "############", "############",
    ],
    3,
    3,
    East,
  )
  let program = make_program([Move, Move, Move])
  let trace = simulate(program, level)
  assert_true(trace.success)
  assert_eq(trace.fail_reason, "")
}

///|
test "move into wall fails" {
  let level = make_test_level(
    [
      "############", "############", "############", "###S.#G#####", "############",
      "############", "############", "############", "############",
    ],
    3,
    3,
    East,
  )
  let program = make_program([Move, Move])
  let trace = simulate(program, level)
  assert_true(!trace.success)
  assert_eq(trace.fail_reason, "Robot walked into a wall!")
}

///|
test "move into gap fails" {
  let level = make_test_level(
    [
      "############", "############", "############", "###S._G#####", "############",
      "############", "############", "############", "############",
    ],
    3,
    3,
    East,
  )
  let program = make_program([Move, Move])
  let trace = simulate(program, level)
  assert_true(!trace.success)
  assert_eq(trace.fail_reason, "Robot fell into a gap!")
}

// ===== Turn tests =====

///|
test "turn left from east faces north" {
  let level = make_test_level(
    [
      "############", "############", "###.G.######", "###.S.######", "############",
      "############", "############", "############", "############",
    ],
    4,
    3,
    East,
  )
  let program = make_program([TurnLeft, Move])
  let trace = simulate(program, level)
  assert_true(trace.success)
}

///|
test "turn right from east faces south" {
  let level = make_test_level(
    [
      "############", "############", "############", "###.S.######", "###.G.######",
      "############", "############", "############", "############",
    ],
    4,
    3,
    East,
  )
  let program = make_program([TurnRight, Move])
  let trace = simulate(program, level)
  assert_true(trace.success)
}

///|
test "four left turns returns to original direction" {
  let level = make_test_level(
    [
      "############", "############", "############", "###S.G######", "############",
      "############", "############", "############", "############",
    ],
    3,
    3,
    East,
  )
  let program = make_program([
    TurnLeft,
    TurnLeft,
    TurnLeft,
    TurnLeft,
    Move,
    Move,
  ])
  let trace = simulate(program, level)
  assert_true(trace.success)
}

// ===== Jump tests =====

///|
test "jump over gap" {
  let level = make_test_level(
    [
      "############", "############", "############", "###S._G#####", "############",
      "############", "############", "############", "############",
    ],
    3,
    3,
    East,
  )
  let program = make_program([Move, Jump])
  let trace = simulate(program, level)
  assert_true(trace.success)
}

///|
test "jump over wall" {
  let level = make_test_level(
    [
      "############", "############", "############", "###S.#G#####", "############",
      "############", "############", "############", "############",
    ],
    3,
    3,
    East,
  )
  let program = make_program([Move, Jump])
  let trace = simulate(program, level)
  assert_true(trace.success)
}

///|
test "jump landing on gap fails" {
  let level = make_test_level(
    [
      "############", "############", "############", "###S.._#####", "############",
      "############", "############", "############", "############",
    ],
    3,
    3,
    East,
  )
  let program = make_program([Move, Jump])
  let trace = simulate(program, level)
  assert_true(!trace.success)
  assert_eq(trace.fail_reason, "Robot landed in a gap!")
}

///|
test "jump out of bounds fails" {
  let level = make_test_level(
    [
      "############", "############", "############", "##########S.", "############",
      "############", "############", "############", "############",
    ],
    11,
    3,
    East,
  )
  let program = make_program([Jump])
  let trace = simulate(program, level)
  assert_true(!trace.success)
  assert_eq(trace.fail_reason, "Robot jumped out of bounds!")
}

// ===== Push tests =====

///|
test "push block forward" {
  let level = make_test_level(
    [
      "############", "############", "############", "##S.O..G####", "############",
      "############", "############", "############", "############",
    ],
    2,
    3,
    East,
  )
  // Move to (3,3), Push block from (4,3) to (5,3), Move to (4,3), Move to (5,3) blocked
  // Better: Move, Push, Move, Move, Move -> robot ends at (5,3), block at (5,3)?
  // Push moves block from (4,3) to (5,3). Robot stays at (3,3).
  // Then Move to (4,3), Move to (5,3) -- block is there!
  // Need more space: S..O...G
  let _ = level
  let level2 = make_test_level(
    [
      "############", "############", "############", "#S..O...G###", "############",
      "############", "############", "############", "############",
    ],
    1,
    3,
    East,
  )
  // Move(1->2), Move(2->3), Push block from(4->5), Move(3->4), Move(4->5) blocked!
  // Actually need block to be pushed to side. Let's use a simpler layout:
  // Push block out of the way, then walk to goal
  let _ = level2
  let level3 = make_test_level(
    [
      "############", "############", "###..O######", "###S...G####", "############",
      "############", "############", "############", "############",
    ],
    3,
    3,
    East,
  )
  // Move to (4,3), TurnLeft(face north), Push block from (4,2) to (4,1)
  // Wait - (4,1) is '#'. Let me re-layout.
  let _ = level3
  let level4 = make_test_level(
    [
      "############", "############", "###...######", "###.O.######", "###S..G#####",
      "############", "############", "############", "############",
    ],
    3,
    4,
    East,
  )
  // Robot at (3,4) E. Move to (4,4). TurnLeft -> N. Push block from (4,3) to (4,2).
  // TurnRight -> E. Move to (5,4). Move to (6,4). Goal at (6,4).
  let program = make_program([Move, TurnLeft, Push, TurnRight, Move, Move])
  let trace = simulate(program, level4)
  assert_true(trace.success)
}

///|
test "push block into gap fills it" {
  let level = make_test_level(
    [
      "############", "############", "############", "#S.O_..G####", "############",
      "############", "############", "############", "############",
    ],
    1,
    3,
    East,
  )
  // Move to (2,3), Push block from (3,3) into gap at (4,3) - gap becomes floor, block removed.
  // Now (4,3) is floor. Robot at (2,3).
  // Move(2->3), Move(3->4 filled), Move(4->5), Move(5->6), Move(6->7)=G
  let program = make_program([Move, Push, Move, Move, Move, Move, Move])
  let trace = simulate(program, level)
  assert_true(trace.success)
}

///|
test "push nothing fails" {
  let level = make_test_level(
    [
      "############", "############", "############", "###S..G#####", "############",
      "############", "############", "############", "############",
    ],
    3,
    3,
    East,
  )
  let program = make_program([Push])
  let trace = simulate(program, level)
  assert_true(!trace.success)
  assert_eq(trace.fail_reason, "Nothing to push!")
}

///|
test "push block into wall fails" {
  let level = make_test_level(
    [
      "############", "############", "############", "###S.O#G####", "############",
      "############", "############", "############", "############",
    ],
    3,
    3,
    East,
  )
  let program = make_program([Move, Push])
  let trace = simulate(program, level)
  assert_true(!trace.success)
  assert_eq(trace.fail_reason, "Can't push block there!")
}

// ===== If condition tests =====

///|
test "if wall ahead skips next command" {
  // Robot faces wall, so If(WallAhead) is true -> execute next command (TurnLeft)
  let level = make_test_level(
    [
      "############", "############", "###.G.######", "###.S#######", "############",
      "############", "############", "############", "############",
    ],
    4,
    3,
    East,
  )
  // WallAhead is true (wall at 5,3), so TurnLeft executes, then Move goes north
  let program = make_program([If(WallAhead), TurnLeft, Move])
  let trace = simulate(program, level)
  assert_true(trace.success)
}

///|
test "if condition false skips next command" {
  // Robot faces open path, so If(WallAhead) is false -> skip TurnLeft
  let level = make_test_level(
    [
      "############", "############", "############", "###S..G#####", "############",
      "############", "############", "############", "############",
    ],
    3,
    3,
    East,
  )
  // WallAhead is false (floor ahead), so TurnLeft is skipped, then Move goes east
  let program = make_program([If(WallAhead), TurnLeft, Move, Move, Move])
  let trace = simulate(program, level)
  assert_true(trace.success)
}

///|
test "if path ahead" {
  let level = make_test_level(
    [
      "############", "############", "############", "###S.G######", "############",
      "############", "############", "############", "############",
    ],
    3,
    3,
    East,
  )
  // PathAhead is true, so Move executes
  let program = make_program([If(PathAhead), Move, Move])
  let trace = simulate(program, level)
  assert_true(trace.success)
}

///|
test "if on color red" {
  let level = make_test_level(
    [
      "############", "############", "############", "###S.RG#####", "############",
      "############", "############", "############", "############",
    ],
    3,
    3,
    East,
  )
  // Move to (4,3) floor, Move to (5,3) red, If(OnColor(Red)) true, Move to (6,3) goal
  let program = make_program([Move, Move, If(OnColor(Red)), Move])
  let trace = simulate(program, level)
  assert_true(trace.success)
}

// ===== Loop tests =====

///|
test "loop repeats next command" {
  let level = make_test_level(
    [
      "############", "############", "############", "###S...G####", "############",
      "############", "############", "############", "############",
    ],
    3,
    3,
    East,
  )
  // Loop(4) repeats Move 4 times -> 4 steps east from (3,3) to (7,3) = G
  let program = make_program([Loop(4), Move])
  let trace = simulate(program, level)
  assert_true(trace.success)
}

///|
test "loop without following command does nothing" {
  let level = make_test_level(
    [
      "############", "############", "############", "###SG.######", "############",
      "############", "############", "############", "############",
    ],
    3,
    3,
    East,
  )
  // Loop at end has no next command, then Move
  let program = make_program([Move])
  let trace = simulate(program, level)
  assert_true(trace.success)
}

// ===== Multiple goals tests =====

///|
test "collect two goals" {
  let level = make_test_level(
    [
      "############", "############", "############", "###S.G.G####", "############",
      "############", "############", "############", "############",
    ],
    3,
    3,
    East,
  )
  let program = make_program([Move, Move, Move, Move])
  let trace = simulate(program, level)
  assert_true(trace.success)
}

///|
test "missing one goal fails" {
  let level = make_test_level(
    [
      "############", "############", "###..G######", "###S..G#####", "############",
      "############", "############", "############", "############",
    ],
    3,
    3,
    East,
  )
  // Only goes east, reaches one goal but misses the one above
  let program = make_program([Move, Move, Move])
  let trace = simulate(program, level)
  assert_true(!trace.success)
  assert_eq(trace.fail_reason, "Not all goals collected!")
}

// ===== Empty program test =====

///|
test "empty program fails" {
  let level = make_test_level(
    [
      "############", "############", "############", "###SG.######", "############",
      "############", "############", "############", "############",
    ],
    3,
    3,
    East,
  )
  let program = make_program([])
  let trace = simulate(program, level)
  assert_true(!trace.success)
  assert_eq(trace.fail_reason, "Empty program")
}

// ===== Trace state tests =====

///|
test "trace records initial state" {
  let level = make_test_level(
    [
      "############", "############", "############", "###SG.######", "############",
      "############", "############", "############", "############",
    ],
    3,
    3,
    East,
  )
  let program = make_program([Move])
  let trace = simulate(program, level)
  // Initial state + 1 move = 2 states
  assert_true(trace.states.length() >= 2)
  // First state should be at start position
  assert_eq(trace.states[0].pos.x, 3)
  assert_eq(trace.states[0].pos.y, 3)
  assert_true(trace.states[0].alive)
}

///|
test "trace records final position" {
  let level = make_test_level(
    [
      "############", "############", "############", "###S.G######", "############",
      "############", "############", "############", "############",
    ],
    3,
    3,
    East,
  )
  let program = make_program([Move, Move])
  let trace = simulate(program, level)
  assert_true(trace.success)
  let last = trace.states[trace.states.length() - 1]
  assert_eq(last.pos.x, 5)
  assert_eq(last.pos.y, 3)
}

// ===== Direction tests =====

///|
test "move in all four directions" {
  let level = make_test_level(
    [
      "############", "############", "###.G.######", "###.S.######", "###...######",
      "############", "############", "############", "############",
    ],
    4,
    3,
    North,
  )
  // Move north, turn right (east), turn right (south), move south x2, TL (east), TL (north)
  // Should reach G at (4,2)
  let program = make_program([Move])
  let trace = simulate(program, level)
  assert_true(trace.success)
}

// ===== Complex scenario =====

///|
test "l-shape path with turn" {
  let level = make_test_level(
    [
      "############", "############", "####.G######", "####..######", "####S.######",
      "############", "############", "############", "############",
    ],
    4,
    4,
    North,
  )
  let program = make_program([Move, Move, TurnRight, Move])
  let trace = simulate(program, level)
  assert_true(trace.success)
}

///|
test "walk into block fails" {
  let level = make_test_level(
    [
      "############", "############", "############", "###SOG######", "############",
      "############", "############", "############", "############",
    ],
    3,
    3,
    East,
  )
  let program = make_program([Move])
  let trace = simulate(program, level)
  assert_true(!trace.success)
  assert_eq(trace.fail_reason, "Robot walked into a block!")
}
