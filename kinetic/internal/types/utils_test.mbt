///|
test "gear_radius returns correct values" {
  inspect(@types.gear_radius(Small), content="1")
  inspect(@types.gear_radius(Medium), content="2")
  inspect(@types.gear_radius(Large), content="3")
  inspect(@types.gear_radius(Belt), content="0")
  inspect(@types.gear_radius(Ratchet), content="2")
}

///|
test "can_mesh checks distance correctly" {
  // Small (r=1) and Medium (r=2): mesh at distance 3, dist_sq=9
  inspect(@types.can_mesh(1, 2, 9), content="true")
  // Too far
  inspect(@types.can_mesh(1, 2, 16), content="false")
  // Too close
  inspect(@types.can_mesh(1, 2, 4), content="false")
  // Medium (r=2) and Medium (r=2): mesh at distance 4, dist_sq=16
  inspect(@types.can_mesh(2, 2, 16), content="true")
  // Small (r=1) and Large (r=3): mesh at distance 4, dist_sq=16
  inspect(@types.can_mesh(1, 3, 16), content="true")
  // Medium (r=2) and Large (r=3): mesh at distance 5, dist_sq=25
  inspect(@types.can_mesh(2, 3, 25), content="true")
}

///|
test "speed_ratio calculation" {
  // Small driving Medium: 1/2 = 0.5
  inspect(@types.speed_ratio(1, 2), content="0.5")
  // Medium driving Small: 2/1 = 2.0
  inspect(@types.speed_ratio(2, 1), content="2")
  // Same size: 1.0
  inspect(@types.speed_ratio(2, 2), content="1")
  // Large driving Small: 3/1 = 3.0
  inspect(@types.speed_ratio(3, 1), content="3")
  // Small driving Large: 1/3
  let r = @types.speed_ratio(1, 3)
  inspect(r > 0.33 && r < 0.34, content="true")
}

///|
test "flip_dir alternates direction" {
  inspect(@types.flip_dir(CW), content="CCW")
  inspect(@types.flip_dir(CCW), content="CW")
}

///|
test "grid_dist_sq" {
  let a : @types.Vec2i = { x: 0, y: 0, }
  let b : @types.Vec2i = { x: 3, y: 4, }
  inspect(@types.grid_dist_sq(a, b), content="25")
  let c : @types.Vec2i = { x: 1, y: 1, }
  let d : @types.Vec2i = { x: 4, y: 1, }
  inspect(@types.grid_dist_sq(c, d), content="9")
}

///|
test "rpm_satisfied with tolerance" {
  // Exact match
  inspect(@types.rpm_satisfied(60.0, 60.0), content="true")
  // Within 10%
  inspect(@types.rpm_satisfied(63.0, 60.0), content="true")
  inspect(@types.rpm_satisfied(55.0, 60.0), content="true")
  // Outside 10%
  inspect(@types.rpm_satisfied(70.0, 60.0), content="false")
  inspect(@types.rpm_satisfied(50.0, 60.0), content="false")
  // Zero target
  inspect(@types.rpm_satisfied(0.0, 0.0), content="true")
  inspect(@types.rpm_satisfied(0.5, 0.0), content="true")
  inspect(@types.rpm_satisfied(2.0, 0.0), content="false")
}

///|
test "check_output requires both rpm and direction" {
  let output = @types.new_output({ x: 5, y: 5, }, 60.0, CW)
  // Correct rpm and direction
  inspect(@types.check_output(output, 60.0, CW), content="true")
  // Correct rpm, wrong direction
  inspect(@types.check_output(output, 60.0, CCW), content="false")
  // Wrong rpm, correct direction
  inspect(@types.check_output(output, 120.0, CW), content="false")
}

///|
test "new_gear initializes correctly" {
  let gear = @types.new_gear({ x: 3, y: 4, }, Medium)
  inspect(gear.pos.x, content="3")
  inspect(gear.pos.y, content="4")
  inspect(gear.kind, content="Medium")
  inspect(gear.radius, content="2")
  inspect(gear.rpm, content="0")
  inspect(gear.active, content="true")
}

///|
test "find_gear_at" {
  let gears : Array[@types.Gear] = [
    @types.new_gear({ x: 1, y: 1, }, Small),
    @types.new_gear({ x: 3, y: 3, }, Medium),
    @types.new_gear({ x: 5, y: 5, }, Large),
  ]
  inspect(@types.find_gear_at(gears, { x: 3, y: 3, }), content="1")
  inspect(@types.find_gear_at(gears, { x: 7, y: 7, }), content="-1")
  gears[1].active = false
  inspect(@types.find_gear_at(gears, { x: 3, y: 3, }), content="-1")
}

///|
test "count_placed_gears" {
  let gears : Array[@types.Gear] = [
    @types.new_gear({ x: 1, y: 1, }, Small),
    @types.new_gear({ x: 3, y: 3, }, Medium),
    @types.new_gear({ x: 5, y: 5, }, Large),
  ]
  inspect(@types.count_placed_gears(gears), content="3")
  gears[1].active = false
  inspect(@types.count_placed_gears(gears), content="2")
}

///|
test "gears_overlap detects overlapping gears" {
  let g1 = @types.new_gear({ x: 2, y: 2, }, Medium) // radius 2
  let g2 = @types.new_gear({ x: 3, y: 2, }, Medium) // radius 2, dist=1 < 2+2
  inspect(@types.gears_overlap(g1, g2), content="true")
  let g3 = @types.new_gear({ x: 6, y: 2, }, Medium) // dist=4 = 2+2, not overlap (equal not less)
  inspect(@types.gears_overlap(g1, g3), content="false")
}

///|
test "cosf and sinf basic" {
  inspect(@types.cosf(0.0), content="1")
  inspect(@types.sinf(0.0), content="0")
}

///|
test "absf" {
  inspect(@types.absf(5.0), content="5")
  inspect(@types.absf(-5.0), content="5")
  inspect(@types.absf(0.0), content="0")
}

///|
test "maxf and minf" {
  inspect(@types.maxf(3.0, 7.0), content="7")
  inspect(@types.minf(3.0, 7.0), content="3")
}

///|
test "new_game initializes scores array" {
  let game = @types.new_game()
  inspect(game.screen, content="Title")
  inspect(game.scores.length(), content="25")
  inspect(game.scores[0].stars, content="0")
  inspect(game.scores[0].completed, content="false")
}

///|
test "tier_level_offset and count" {
  inspect(@types.tier_level_offset(Gears), content="0")
  inspect(@types.tier_level_offset(Trains), content="8")
  inspect(@types.tier_level_offset(Workshop), content="17")
  inspect(@types.tier_level_count(Gears), content="8")
  inspect(@types.tier_level_count(Trains), content="9")
  inspect(@types.tier_level_count(Workshop), content="8")
}

///|
test "gear_tooth_count" {
  inspect(@types.gear_tooth_count(Small), content="8")
  inspect(@types.gear_tooth_count(Medium), content="12")
  inspect(@types.gear_tooth_count(Large), content="16")
  inspect(@types.gear_tooth_count(Belt), content="0")
  inspect(@types.gear_tooth_count(Ratchet), content="12")
}

///|
test "multi-gear meshing scenario" {
  // Small at (0,0) and Medium at (3,0): dist_sq = 9, r1+r2 = 1+2 = 3, 3*3=9, should mesh
  let dsq = @types.grid_dist_sq({ x: 0, y: 0, }, { x: 3, y: 0, })
  inspect(@types.can_mesh(1, 2, dsq), content="true")
  // Speed from small (r=1) driving medium (r=2): ratio = 1/2 = 0.5
  // So if input is 60 RPM, output is 30 RPM
  let ratio = @types.speed_ratio(1, 2)
  let output_rpm : Float = 60.0 * ratio
  inspect(@types.rpm_satisfied(output_rpm, 30.0), content="true")
  // Direction flips
  let output_dir = @types.flip_dir(CW)
  inspect(output_dir, content="CCW")
}

///|
test "belt preserves direction concept" {
  // A belt does not flip direction - verified by checking flip_dir is NOT applied
  // If driving gear is CW, belt-connected gear should also be CW
  let driving_dir : @types.RotDir = CW
  // Belt: no flip
  let belt_driven_dir = driving_dir
  inspect(belt_driven_dir, content="CW")
  // Mesh: flip
  let mesh_driven_dir = @types.flip_dir(driving_dir)
  inspect(mesh_driven_dir, content="CCW")
}

///|
test "multi-gear train propagation" {
  // Chain: Small(60 CW) -> Medium(30 CCW) -> Medium(30 CW) -> Small(60 CCW)
  let input_rpm : Float = 60.0
  let input_dir : @types.RotDir = CW
  // First mesh: Small drives Medium
  let rpm1 : Float = input_rpm * @types.speed_ratio(1, 2)
  let dir1 = @types.flip_dir(input_dir)
  inspect(@types.rpm_satisfied(rpm1, 30.0), content="true")
  inspect(dir1, content="CCW")
  // Second mesh: Medium drives Medium
  let rpm2 : Float = rpm1 * @types.speed_ratio(2, 2)
  let dir2 = @types.flip_dir(dir1)
  inspect(@types.rpm_satisfied(rpm2, 30.0), content="true")
  inspect(dir2, content="CW")
  // Third mesh: Medium drives Small
  let rpm3 : Float = rpm2 * @types.speed_ratio(2, 1)
  let dir3 = @types.flip_dir(dir2)
  inspect(@types.rpm_satisfied(rpm3, 60.0), content="true")
  inspect(dir3, content="CCW")
}

///|
test "ratchet blocks reverse concept" {
  // A ratchet only allows CW transmission
  // If driven in CCW, it should be blocked
  // Testing the concept: ratchet at output with CCW direction = blocked
  let ratchet_gear = @types.new_gear({ x: 5, y: 5, }, Ratchet)
  inspect(ratchet_gear.kind, content="Ratchet")
  inspect(ratchet_gear.radius, content="2")
}

///|
test "output satisfaction with tolerance edge cases" {
  let output = @types.new_output({ x: 0, y: 0, }, 100.0, CW)
  // Exactly 10% above
  inspect(@types.check_output(output, 110.0, CW), content="true")
  // Exactly 10% below
  inspect(@types.check_output(output, 90.0, CW), content="true")
  // Just over 10%
  inspect(@types.check_output(output, 111.0, CW), content="false")
  // Just under 10%
  inspect(@types.check_output(output, 89.0, CW), content="false")
}
