///|
test "splitter creates 2 balls" {
  let level : @types.Level = {
    walls: [],
    targets: [],
    splitters: [@types.new_splitter(500.0, 300.0, 20.0)],
    gates: [],
    bumpers: [],
    pickups: [],
    start_pos: @types.vec2(500.0, 600.0),
    par_bounces: 5,
  }
  let game = @types.new_game()
  game.current_level = Some(level)
  // Ball heading straight at splitter
  let ball = @types.new_ball(
    @types.vec2(500.0, 310.0),
    @types.vec2(0.0, -@types.ball_speed),
  )
  game.balls.push(ball)
  // Simulate until splitter is hit
  for _i in 0..<30 {
    @physics.simulate_step(game, 1.0 / 60.0)
  }
  // Should have created 2 new balls (original deactivated + 2 new)
  let mut active_count = 0
  for b in game.balls {
    if b.active {
      active_count += 1
    }
  }
  assert_true(active_count >= 2)
}

///|
test "level completion check" {
  let level : @types.Level = {
    walls: [],
    targets: [
      @types.new_target(100.0, 100.0, 15.0),
      @types.new_target(200.0, 200.0, 15.0),
    ],
    splitters: [],
    gates: [],
    bumpers: [],
    pickups: [],
    start_pos: @types.vec2(50.0, 50.0),
    par_bounces: 5,
  }
  assert_true(!@types.all_targets_hit(level))
  level.targets[0].hit = true
  assert_true(!@types.all_targets_hit(level))
  level.targets[1].hit = true
  assert_true(@types.all_targets_hit(level))
}

///|
test "pickup collection tracking" {
  let level : @types.Level = {
    walls: [],
    targets: [],
    splitters: [],
    gates: [],
    bumpers: [],
    pickups: [@types.new_pickup(100.0, 100.0, 10.0)],
    start_pos: @types.vec2(50.0, 50.0),
    par_bounces: 5,
  }
  assert_true(!@types.pickup_collected(level))
  level.pickups[0].collected = true
  assert_true(@types.pickup_collected(level))
}
