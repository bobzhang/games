///|
test "hex_dir_opposite" {
  assert_eq(hex_dir_opposite(E), W)
  assert_eq(hex_dir_opposite(NE), SW)
  assert_eq(hex_dir_opposite(NW), SE)
  assert_eq(hex_dir_opposite(W), E)
  assert_eq(hex_dir_opposite(SW), NE)
  assert_eq(hex_dir_opposite(SE), NW)
}

///|
test "hex_dir_cw full rotation" {
  assert_eq(hex_dir_cw(E), SE)
  assert_eq(hex_dir_cw(SE), SW)
  assert_eq(hex_dir_cw(SW), W)
  assert_eq(hex_dir_cw(W), NW)
  assert_eq(hex_dir_cw(NW), NE)
  assert_eq(hex_dir_cw(NE), E)
}

///|
test "hex_dir_ccw full rotation" {
  assert_eq(hex_dir_ccw(E), NE)
  assert_eq(hex_dir_ccw(NE), NW)
  assert_eq(hex_dir_ccw(NW), W)
  assert_eq(hex_dir_ccw(W), SW)
  assert_eq(hex_dir_ccw(SW), SE)
  assert_eq(hex_dir_ccw(SE), E)
}

///|
test "hex_dir_cw_ccw inverse" {
  let dirs = all_hex_dirs()
  for i in 0..<dirs.length() {
    assert_eq(hex_dir_ccw(hex_dir_cw(dirs[i])), dirs[i])
    assert_eq(hex_dir_cw(hex_dir_ccw(dirs[i])), dirs[i])
  }
}

///|
test "hex_dir_opposite is double cw3" {
  let dirs = all_hex_dirs()
  for i in 0..<dirs.length() {
    let d = dirs[i]
    let triple_cw = hex_dir_cw(hex_dir_cw(hex_dir_cw(d)))
    assert_eq(hex_dir_opposite(d), triple_cw)
  }
}

///|
test "mirror_reflect_hex E facing NE" {
  // Mirror normal NE (index 1), incoming E (index 0)
  // reflected = (2*1 - 0) % 6 = 2 => NW
  assert_eq(mirror_reflect_hex(E, NE), NW)
}

///|
test "mirror_reflect_hex W facing NE" {
  // Mirror normal NE (index 1), incoming W (index 3)
  // reflected = (2*1 - 3) % 6 = (-1) % 6 = 5 => SE
  assert_eq(mirror_reflect_hex(W, NE), SE)
}

///|
test "mirror_reflect_hex opposite returns same" {
  // Beam hitting mirror head-on bounces straight back
  // incoming=E(0), facing=E(0): reflected = (0-0)%6 = 0 => E
  assert_eq(mirror_reflect_hex(E, E), E)
}

///|
test "crystal_refract left" {
  assert_eq(crystal_refract(E, Left60), NE)
  assert_eq(crystal_refract(NE, Left60), NW)
  assert_eq(crystal_refract(W, Left60), SW)
}

///|
test "crystal_refract right" {
  assert_eq(crystal_refract(E, Right60), SE)
  assert_eq(crystal_refract(NE, Right60), E)
  assert_eq(crystal_refract(W, Right60), NW)
}

///|
test "hex neighbor deltas" {
  // E neighbor: q+1, r+0
  assert_eq(hex_dir_dq(E), 1)
  assert_eq(hex_dir_dr(E), 0)
  // W neighbor: q-1, r+0
  assert_eq(hex_dir_dq(W), -1)
  assert_eq(hex_dir_dr(W), 0)
  // NE neighbor: q+1, r-1
  assert_eq(hex_dir_dq(NE), 1)
  assert_eq(hex_dir_dr(NE), -1)
  // SW neighbor: q-1, r+1
  assert_eq(hex_dir_dq(SW), -1)
  assert_eq(hex_dir_dr(SW), 1)
}
