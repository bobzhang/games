///|
test "plain weave is checkerboard" {
  let warps = [0, 1, 0, 1, 0, 1, 0, 1]
  let wefts = [0, 0, 0, 0]
  let p = generate_plain(4, 8, warps, wefts)
  let c00 = @types.pattern_get(p, 0, 0)
  assert_eq(c00.state, WarpOver)
  let c01 = @types.pattern_get(p, 0, 1)
  assert_eq(c01.state, WeftOver)
  let c10 = @types.pattern_get(p, 1, 0)
  assert_eq(c10.state, WeftOver)
  let c11 = @types.pattern_get(p, 1, 1)
  assert_eq(c11.state, WarpOver)
}

///|
test "twill weave diagonal" {
  let warps = [0, 1, 0, 1, 0, 1, 0, 1]
  let wefts = [0, 0, 0, 0]
  let p = generate_twill(4, 8, warps, wefts, 2)
  // Row 0: pos=(col+0)%4 => col0=0(W), col1=1(W), col2=2(wf), col3=3(wf)
  let c00 = @types.pattern_get(p, 0, 0)
  assert_eq(c00.state, WarpOver)
  let c01 = @types.pattern_get(p, 0, 1)
  assert_eq(c01.state, WarpOver)
  let c02 = @types.pattern_get(p, 0, 2)
  assert_eq(c02.state, WeftOver)
  // Row 1: pos=(col+1)%4 => col0=1(W), col1=2(wf), col2=3(wf), col3=0(W)
  let c10 = @types.pattern_get(p, 1, 0)
  assert_eq(c10.state, WarpOver)
  let c11 = @types.pattern_get(p, 1, 1)
  assert_eq(c11.state, WeftOver)
  let c13 = @types.pattern_get(p, 1, 3)
  assert_eq(c13.state, WarpOver)
}

///|
test "heddles from pattern" {
  let warps = [0, 1, 0, 1, 0, 1, 0, 1]
  let wefts = [0, 0, 0, 0]
  let p = generate_plain(4, 8, warps, wefts)
  let heddles = heddles_from_pattern(p)
  assert_eq(heddles.length(), 4)
  assert_eq(heddles[0].raised[0], true)
  assert_eq(heddles[0].raised[1], false)
  assert_eq(heddles[1].raised[0], false)
  assert_eq(heddles[1].raised[1], true)
}

///|
test "count heddle changes" {
  let warps = [0, 1, 0, 1, 0, 1, 0, 1]
  let wefts = [0, 0, 0, 0]
  let p = generate_plain(4, 8, warps, wefts)
  let heddles = heddles_from_pattern(p)
  let changes = count_heddle_changes(heddles)
  assert_eq(changes, 3)
}

///|
test "identify plain weave" {
  let warps = [0, 1, 0, 1, 0, 1, 0, 1]
  let wefts = [0, 0, 0, 0]
  let p = generate_plain(4, 8, warps, wefts)
  let wt = identify_weave_type(p)
  assert_eq(wt, Plain)
}

///|
test "satin pattern generation" {
  let warps = [0, 1, 0, 1, 0, 1, 0, 1]
  let wefts = Array::make(12, 0)
  let p = generate_satin(12, 8, warps, wefts, 5, 2)
  let mut warp_count = 0
  for i in 0..<(12 * 8) {
    if p.cells[i].state == WarpOver {
      warp_count = warp_count + 1
    }
  }
  assert_true(warp_count > 10)
  assert_true(warp_count < 40)
}

///|
test "diamond pattern generation" {
  let warps = [0, 1, 0, 1, 0, 1, 0, 1]
  let wefts = Array::make(12, 0)
  let p = generate_diamond(12, 8, warps, wefts, 4)
  let total = 12 * 8
  let mut warp_count = 0
  for i in 0..<total {
    if p.cells[i].state == WarpOver {
      warp_count = warp_count + 1
    }
  }
  assert_true(warp_count > 0)
  assert_true(warp_count < total)
}
