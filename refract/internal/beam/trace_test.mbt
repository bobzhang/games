///|
test "trace beam straight through empty grid" {
  let grid = @types.new_grid()
  // Place source at (0,3) facing East
  let cell = grid.cells[3 * grid.width + 0]
  cell.component = Some(Source)
  cell.direction = E
  cell.locked = true
  let segments = trace_all_beams(grid)
  // Should have at least one segment
  assert_true!(segments.length() > 0)
}

///|
test "trace beam to receiver" {
  let grid = @types.new_grid()
  // Source at (0,3) facing East
  let src = grid.cells[3 * grid.width + 0]
  src.component = Some(Source)
  src.direction = E
  src.locked = true
  // Receiver at (5,3) expecting white
  let recv = grid.cells[3 * grid.width + 5]
  recv.component = Some(Receiver)
  recv.direction = W
  recv.target_color = Some(@types.beam_color_white())
  recv.locked = true
  let _segments = trace_all_beams(grid)
  // Check receiver satisfaction
  let satisfied = check_all_receivers(grid)
  assert_true!(satisfied)
}

///|
test "filter removes channel" {
  let grid = @types.new_grid()
  // Source at (0,3) facing East (white)
  let src = grid.cells[3 * grid.width + 0]
  src.component = Some(Source)
  src.direction = E
  src.locked = true
  // Red filter at (3,3)
  let flt = grid.cells[3 * grid.width + 3]
  flt.component = Some(Filter)
  flt.direction = E
  flt.filter_color = Some(Red)
  // Receiver at (6,3) expecting cyan
  let recv = grid.cells[3 * grid.width + 6]
  recv.component = Some(Receiver)
  recv.direction = W
  recv.target_color = Some(@types.beam_color_cyan())
  recv.locked = true
  let _segments = trace_all_beams(grid)
  let satisfied = check_all_receivers(grid)
  assert_true!(satisfied)
}

///|
test "mirror reflects beam" {
  let grid = @types.new_grid()
  // Source at (0,1) facing East
  let src = grid.cells[1 * grid.width + 0]
  src.component = Some(Source)
  src.direction = E
  src.locked = true
  // "/" mirror at (4,1) facing N (slash)
  let mir = grid.cells[1 * grid.width + 4]
  mir.component = Some(Mirror)
  mir.direction = N // "/" slash
  // Beam going E hits "/" -> reflects to N
  // Receiver at (4,0) would be hit... but actually trace goes from (4,1) to N direction
  // Actually receiver needs to be reachable. Let's put receiver at (4,0)... wait that's just one step.
  // Let's use a simpler test - source goes E, mirror at (4,1) is "\" (facing E), redirects S
  mir.direction = E // "\" backslash: E->S
  // Receiver at (4,5) expecting white, facing N
  let recv = grid.cells[5 * grid.width + 4]
  recv.component = Some(Receiver)
  recv.direction = N
  recv.target_color = Some(@types.beam_color_white())
  recv.locked = true
  let _segments = trace_all_beams(grid)
  let satisfied = check_all_receivers(grid)
  assert_true!(satisfied)
}

///|
test "prism splits white into RGB" {
  let grid = @types.new_grid()
  // Source at (0,3) facing East
  let src = grid.cells[3 * grid.width + 0]
  src.component = Some(Source)
  src.direction = E
  src.locked = true
  // Prism at (3,3)
  let prism = grid.cells[3 * grid.width + 3]
  prism.component = Some(Prism)
  prism.direction = E
  let segments = trace_all_beams(grid)
  // Should have the incoming segment + 3 split segments (R, G, B)
  // At minimum: 1 segment from source to prism + 3 from prism outward
  assert_true!(segments.length() >= 4)
}

///|
test "combiner merges colors" {
  let grid = @types.new_grid()
  // Red source at (0,2) facing East
  let src1 = grid.cells[2 * grid.width + 0]
  src1.component = Some(Source)
  src1.direction = E
  src1.target_color = Some(@types.beam_color_red())
  src1.locked = true
  // Green source at (0,5) facing East
  let src2 = grid.cells[5 * grid.width + 0]
  src2.component = Some(Source)
  src2.direction = E
  src2.target_color = Some(@types.beam_color_green())
  src2.locked = true
  // Mirror at (4,2) - "\" backslash: E->S
  let mir1 = grid.cells[2 * grid.width + 4]
  mir1.component = Some(Mirror)
  mir1.direction = E
  // Mirror at (4,5) - "/" slash: E->N
  let mir2 = grid.cells[5 * grid.width + 4]
  mir2.component = Some(Mirror)
  mir2.direction = N
  // Combiner at (4,3) facing E
  let comb = grid.cells[3 * grid.width + 4]
  comb.component = Some(Combiner)
  comb.direction = E
  // Receiver at (8,3) expecting yellow
  let recv = grid.cells[3 * grid.width + 8]
  recv.component = Some(Receiver)
  recv.direction = W
  recv.target_color = Some(@types.beam_color_yellow())
  recv.locked = true
  let _segments = trace_all_beams(grid)
  let satisfied = check_all_receivers(grid)
  assert_true!(satisfied)
}

///|
test "receiver not satisfied with wrong color" {
  let grid = @types.new_grid()
  // Source at (0,3) facing East (white)
  let src = grid.cells[3 * grid.width + 0]
  src.component = Some(Source)
  src.direction = E
  src.locked = true
  // Receiver at (5,3) expecting red
  let recv = grid.cells[3 * grid.width + 5]
  recv.component = Some(Receiver)
  recv.direction = W
  recv.target_color = Some(@types.beam_color_red())
  recv.locked = true
  let _segments = trace_all_beams(grid)
  let satisfied = check_all_receivers(grid)
  // White != Red
  assert_false!(satisfied)
}

///|
test "beam crossing count" {
  let beams : Array[@types.BeamSegment] = [
    {
      start: @types.vec2i(0, 3),
      end_: @types.vec2i(9, 3),
      color: @types.beam_color_white(),
      direction: E,
    },
    {
      start: @types.vec2i(5, 0),
      end_: @types.vec2i(5, 7),
      color: @types.beam_color_red(),
      direction: S,
    },
  ]
  let crossings = count_beam_crossings(beams)
  assert_eq!(crossings, 1)
}
