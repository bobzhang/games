///|
test "peg_position at index 0 is top center" {
  // Peg 0 should be at top of circle (12 o'clock)
  let pos = @types.peg_position(0)
  // x should be at frame_center_x
  let dx = @types.absf(pos.x - @types.frame_center_x)
  inspect(dx < 1.0, content="true")
  // y should be at frame_center_y - frame_radius
  let dy = @types.absf(pos.y - (@types.frame_center_y - @types.frame_radius))
  inspect(dy < 1.0, content="true")
}

///|
test "peg_position at index 6 is right center" {
  // Peg 6 is 1/4 way around = 3 o'clock (rightmost)
  let pos = @types.peg_position(6)
  let dx = @types.absf(pos.x - (@types.frame_center_x + @types.frame_radius))
  inspect(dx < 1.0, content="true")
  let dy = @types.absf(pos.y - @types.frame_center_y)
  inspect(dy < 1.0, content="true")
}

///|
test "peg_position at index 12 is bottom center" {
  let pos = @types.peg_position(12)
  let dx = @types.absf(pos.x - @types.frame_center_x)
  inspect(dx < 1.0, content="true")
  let dy = @types.absf(pos.y - (@types.frame_center_y + @types.frame_radius))
  inspect(dy < 1.0, content="true")
}

///|
test "make_pegs creates 24 pegs" {
  let pegs = @types.make_pegs()
  inspect(pegs.length(), content="24")
  inspect(pegs[0].index, content="0")
  inspect(pegs[23].index, content="23")
}

///|
test "vec2f_dist" {
  let a = @types.vec2f(0.0, 0.0)
  let b = @types.vec2f(3.0, 4.0)
  inspect(@types.vec2f_dist(a, b), content="5")
}

///|
test "cosf and sinf" {
  inspect(@types.cosf(0.0), content="1")
  inspect(@types.sinf(0.0), content="0")
}

///|
test "tier_for_level" {
  inspect(@types.tier_for_level(0), content="Lines")
  inspect(@types.tier_for_level(7), content="Lines")
  inspect(@types.tier_for_level(8), content="Weave")
  inspect(@types.tier_for_level(16), content="Weave")
  inspect(@types.tier_for_level(17), content="Art")
  inspect(@types.tier_for_level(24), content="Art")
}

///|
test "absf" {
  inspect(@types.absf(5.0), content="5")
  inspect(@types.absf(-5.0), content="5")
  inspect(@types.absf(0.0), content="0")
}
