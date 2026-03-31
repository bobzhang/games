///|
/// World 1 "Lines" - Simple walls and targets. Learn aiming and bouncing.

///|
pub fn level_1() -> @types.Level {
  // Tutorial: single target directly ahead
  {
    walls: [],
    targets: [@types.new_target(500.0, 150.0, @types.target_radius)],
    splitters: [],
    gates: [],
    bumpers: [],
    pickups: [@types.new_pickup(700.0, 100.0, @types.pickup_radius)],
    start_pos: @types.vec2(500.0, 600.0),
    par_bounces: 0,
  }
}

///|
pub fn level_2() -> @types.Level {
  // One wall bounce to reach target
  {
    walls: [@types.new_wall(300.0, 300.0, 700.0, 300.0)],
    targets: [@types.new_target(200.0, 150.0, @types.target_radius)],
    splitters: [],
    gates: [],
    bumpers: [],
    pickups: [],
    start_pos: @types.vec2(500.0, 600.0),
    par_bounces: 2,
  }
}

///|
pub fn level_3() -> @types.Level {
  // Two targets, straight shot possible
  {
    walls: [],
    targets: [
      @types.new_target(300.0, 200.0, @types.target_radius),
      @types.new_target(700.0, 200.0, @types.target_radius),
    ],
    splitters: [],
    gates: [],
    bumpers: [],
    pickups: [@types.new_pickup(500.0, 100.0, @types.pickup_radius)],
    start_pos: @types.vec2(500.0, 600.0),
    par_bounces: 3,
  }
}

///|
pub fn level_4() -> @types.Level {
  // Angled wall to redirect ball
  {
    walls: [@types.new_wall(400.0, 350.0, 600.0, 250.0)],
    targets: [
      @types.new_target(800.0, 400.0, @types.target_radius),
      @types.new_target(200.0, 150.0, @types.target_radius),
    ],
    splitters: [],
    gates: [],
    bumpers: [],
    pickups: [],
    start_pos: @types.vec2(100.0, 600.0),
    par_bounces: 4,
  }
}

///|
pub fn level_5() -> @types.Level {
  // Corridor with walls
  {
    walls: [
      @types.new_wall(200.0, 200.0, 200.0, 500.0),
      @types.new_wall(800.0, 200.0, 800.0, 500.0),
    ],
    targets: [
      @types.new_target(500.0, 100.0, @types.target_radius),
      @types.new_target(500.0, 350.0, @types.target_radius),
    ],
    splitters: [],
    gates: [],
    bumpers: [],
    pickups: [@types.new_pickup(500.0, 250.0, @types.pickup_radius)],
    start_pos: @types.vec2(500.0, 650.0),
    par_bounces: 3,
  }
}

///|
pub fn level_6() -> @types.Level {
  // V-shaped walls creating a funnel
  {
    walls: [
      @types.new_wall(200.0, 100.0, 450.0, 350.0),
      @types.new_wall(800.0, 100.0, 550.0, 350.0),
    ],
    targets: [
      @types.new_target(500.0, 80.0, @types.target_radius),
      @types.new_target(150.0, 400.0, @types.target_radius),
      @types.new_target(850.0, 400.0, @types.target_radius),
    ],
    splitters: [],
    gates: [],
    bumpers: [],
    pickups: [],
    start_pos: @types.vec2(500.0, 600.0),
    par_bounces: 5,
  }
}

///|
pub fn level_7() -> @types.Level {
  // Zigzag path through angled walls
  {
    walls: [
      @types.new_wall(300.0, 500.0, 500.0, 400.0),
      @types.new_wall(500.0, 300.0, 700.0, 200.0),
    ],
    targets: [
      @types.new_target(800.0, 100.0, @types.target_radius),
      @types.new_target(100.0, 300.0, @types.target_radius),
    ],
    splitters: [],
    gates: [],
    bumpers: [],
    pickups: [@types.new_pickup(600.0, 350.0, @types.pickup_radius)],
    start_pos: @types.vec2(100.0, 650.0),
    par_bounces: 5,
  }
}

///|
pub fn level_8() -> @types.Level {
  // Box room with targets at corners
  {
    walls: [
      @types.new_wall(250.0, 200.0, 750.0, 200.0),
      @types.new_wall(250.0, 500.0, 750.0, 500.0),
      @types.new_wall(250.0, 200.0, 250.0, 500.0),
      @types.new_wall(750.0, 200.0, 750.0, 500.0),
    ],
    targets: [
      @types.new_target(500.0, 100.0, @types.target_radius),
      @types.new_target(100.0, 350.0, @types.target_radius),
      @types.new_target(900.0, 350.0, @types.target_radius),
    ],
    splitters: [],
    gates: [],
    bumpers: [],
    pickups: [],
    start_pos: @types.vec2(500.0, 650.0),
    par_bounces: 6,
  }
}

///|
pub fn level_9() -> @types.Level {
  // Multiple angled walls - precision aiming needed
  {
    walls: [
      @types.new_wall(200.0, 450.0, 400.0, 350.0),
      @types.new_wall(600.0, 350.0, 800.0, 450.0),
      @types.new_wall(350.0, 200.0, 650.0, 200.0),
    ],
    targets: [
      @types.new_target(500.0, 100.0, @types.target_radius),
      @types.new_target(150.0, 200.0, @types.target_radius),
      @types.new_target(850.0, 200.0, @types.target_radius),
    ],
    splitters: [],
    gates: [],
    bumpers: [],
    pickups: [@types.new_pickup(500.0, 300.0, @types.pickup_radius)],
    start_pos: @types.vec2(500.0, 600.0),
    par_bounces: 7,
  }
}

///|
pub fn level_10() -> @types.Level {
  // World 1 finale - complex wall arrangement, 4 targets
  {
    walls: [
      @types.new_wall(150.0, 400.0, 350.0, 300.0),
      @types.new_wall(650.0, 300.0, 850.0, 400.0),
      @types.new_wall(400.0, 150.0, 600.0, 150.0),
      @types.new_wall(300.0, 550.0, 700.0, 550.0),
    ],
    targets: [
      @types.new_target(200.0, 100.0, @types.target_radius),
      @types.new_target(800.0, 100.0, @types.target_radius),
      @types.new_target(200.0, 500.0, @types.target_radius),
      @types.new_target(800.0, 500.0, @types.target_radius),
    ],
    splitters: [],
    gates: [],
    bumpers: [],
    pickups: [@types.new_pickup(500.0, 350.0, @types.pickup_radius)],
    start_pos: @types.vec2(500.0, 650.0),
    par_bounces: 8,
  }
}
