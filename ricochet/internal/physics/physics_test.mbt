///|
test "check_wall_collision detects nearby ball" {
  let ball_pos = @types.vec2(50.0, 5.0)
  let wall = @types.new_wall(0.0, 0.0, 100.0, 0.0)
  let (hit, _normal, _contact) = @physics.check_wall_collision(
    ball_pos, @types.ball_radius, wall,
  )
  assert_true(hit)
}

///|
test "check_wall_collision misses distant ball" {
  let ball_pos = @types.vec2(50.0, 50.0)
  let wall = @types.new_wall(0.0, 0.0, 100.0, 0.0)
  let (hit, _normal, _contact) = @physics.check_wall_collision(
    ball_pos, @types.ball_radius, wall,
  )
  assert_true(!hit)
}

///|
test "check_circle_collision hit" {
  let ball_pos = @types.vec2(100.0, 100.0)
  let target_pos = @types.vec2(105.0, 100.0)
  let result = @physics.check_circle_collision(
    ball_pos, @types.ball_radius, target_pos, @types.target_radius,
  )
  assert_true(result)
}

///|
test "check_circle_collision miss" {
  let ball_pos = @types.vec2(100.0, 100.0)
  let target_pos = @types.vec2(200.0, 200.0)
  let result = @physics.check_circle_collision(
    ball_pos, @types.ball_radius, target_pos, @types.target_radius,
  )
  assert_true(!result)
}

///|
test "check_gate blocks wrong direction" {
  let gate = @types.new_gate(0.0, 50.0, 100.0, 50.0, 0.0, -1.0)
  // Ball moving downward (y+) at a gate that allows upward (y-) only
  let ball_pos = @types.vec2(50.0, 50.0)
  let ball_vel = @types.vec2(0.0, 100.0)
  let (intersects, correct) = @physics.check_gate(
    ball_pos, ball_vel, @types.ball_radius, gate,
  )
  assert_true(intersects)
  assert_true(!correct)
}

///|
test "check_gate allows correct direction" {
  let gate = @types.new_gate(0.0, 50.0, 100.0, 50.0, 0.0, -1.0)
  // Ball moving upward (y-) at a gate that allows upward (y-)
  let ball_pos = @types.vec2(50.0, 50.0)
  let ball_vel = @types.vec2(0.0, -100.0)
  let (intersects, correct) = @physics.check_gate(
    ball_pos, ball_vel, @types.ball_radius, gate,
  )
  assert_true(intersects)
  assert_true(correct)
}

///|
test "ball reflection angle of incidence equals angle of reflection" {
  // Ball moving at 45 degrees hits horizontal wall
  let vel = @types.vec2(100.0, 100.0)
  let normal = @types.vec2(0.0, -1.0)
  let reflected = @types.vec2_reflect(vel, normal)
  // Reflected should be (100, -100)
  assert_true(@types.absf(reflected.x - 100.0) < 0.1)
  assert_true(@types.absf(reflected.y - -100.0) < 0.1)
}

///|
test "preview path returns points" {
  let level : @types.Level = {
    walls: [],
    targets: [@types.new_target(500.0, 100.0, 15.0)],
    splitters: [],
    gates: [],
    bumpers: [],
    pickups: [],
    start_pos: @types.vec2(500.0, 600.0),
    par_bounces: 0,
  }
  let points = @physics.compute_preview(
    level, level.start_pos, -@types.pi / 4.0, 5,
  )
  // Should have at least start point and end point
  assert_true(points.length() >= 2)
}

///|
test "target hit detection in simulation" {
  let level : @types.Level = {
    walls: [],
    targets: [@types.new_target(500.0, 100.0, 30.0)],
    splitters: [],
    gates: [],
    bumpers: [],
    pickups: [],
    start_pos: @types.vec2(500.0, 600.0),
    par_bounces: 0,
  }
  let game = @types.new_game()
  game.current_level = Some(level)
  // Create ball heading straight at target
  let ball = @types.new_ball(
    @types.vec2(500.0, 130.0), @types.vec2(0.0, -@types.ball_speed),
  )
  game.balls.push(ball)
  // Simulate several steps
  for _i in 0..<60 {
    @physics.simulate_step(game, 1.0 / 60.0)
  }
  // Target should be hit
  assert_true(level.targets[0].hit)
}
