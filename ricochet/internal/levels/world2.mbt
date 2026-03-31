///|
/// World 2 "Splits" - Splitters introduced. Must plan for multiple ball paths.

///|
pub fn level_11() -> @types.Level {
  // Intro to splitters: one splitter, two targets on each side
  {
    walls: [],
    targets: [
      @types.new_target(200.0, 150.0, @types.target_radius),
      @types.new_target(800.0, 150.0, @types.target_radius),
    ],
    splitters: [
      @types.new_splitter(500.0, 350.0, @types.splitter_radius),
    ],
    gates: [],
    bumpers: [],
    pickups: [],
    start_pos: @types.vec2(500.0, 600.0),
    par_bounces: 2,
  }
}

///|
pub fn level_12() -> @types.Level {
  // Splitter with walls to guide split balls
  {
    walls: [
      @types.new_wall(200.0, 200.0, 200.0, 400.0),
      @types.new_wall(800.0, 200.0, 800.0, 400.0),
    ],
    targets: [
      @types.new_target(100.0, 100.0, @types.target_radius),
      @types.new_target(900.0, 100.0, @types.target_radius),
    ],
    splitters: [
      @types.new_splitter(500.0, 400.0, @types.splitter_radius),
    ],
    gates: [],
    bumpers: [],
    pickups: [@types.new_pickup(500.0, 200.0, @types.pickup_radius)],
    start_pos: @types.vec2(500.0, 600.0),
    par_bounces: 4,
  }
}

///|
pub fn level_13() -> @types.Level {
  // Two splitters in sequence
  {
    walls: [
      @types.new_wall(300.0, 250.0, 700.0, 250.0),
    ],
    targets: [
      @types.new_target(150.0, 100.0, @types.target_radius),
      @types.new_target(500.0, 100.0, @types.target_radius),
      @types.new_target(850.0, 100.0, @types.target_radius),
    ],
    splitters: [
      @types.new_splitter(500.0, 400.0, @types.splitter_radius),
      @types.new_splitter(300.0, 300.0, @types.splitter_radius),
    ],
    gates: [],
    bumpers: [],
    pickups: [],
    start_pos: @types.vec2(500.0, 600.0),
    par_bounces: 4,
  }
}

///|
pub fn level_14() -> @types.Level {
  // Splitter behind a wall - bounce to reach it
  {
    walls: [
      @types.new_wall(350.0, 350.0, 650.0, 350.0),
    ],
    targets: [
      @types.new_target(250.0, 150.0, @types.target_radius),
      @types.new_target(750.0, 150.0, @types.target_radius),
      @types.new_target(500.0, 500.0, @types.target_radius),
    ],
    splitters: [
      @types.new_splitter(500.0, 250.0, @types.splitter_radius),
    ],
    gates: [],
    bumpers: [],
    pickups: [@types.new_pickup(500.0, 100.0, @types.pickup_radius)],
    start_pos: @types.vec2(100.0, 600.0),
    par_bounces: 5,
  }
}

///|
pub fn level_15() -> @types.Level {
  // Dual splitters, targets all around
  {
    walls: [
      @types.new_wall(200.0, 300.0, 400.0, 200.0),
      @types.new_wall(600.0, 200.0, 800.0, 300.0),
    ],
    targets: [
      @types.new_target(100.0, 100.0, @types.target_radius),
      @types.new_target(500.0, 80.0, @types.target_radius),
      @types.new_target(900.0, 100.0, @types.target_radius),
    ],
    splitters: [
      @types.new_splitter(300.0, 400.0, @types.splitter_radius),
      @types.new_splitter(700.0, 400.0, @types.splitter_radius),
    ],
    gates: [],
    bumpers: [],
    pickups: [],
    start_pos: @types.vec2(500.0, 600.0),
    par_bounces: 5,
  }
}

///|
pub fn level_16() -> @types.Level {
  // Splitter chain: hit first, splits, one half hits second splitter
  {
    walls: [],
    targets: [
      @types.new_target(100.0, 100.0, @types.target_radius),
      @types.new_target(500.0, 100.0, @types.target_radius),
      @types.new_target(900.0, 100.0, @types.target_radius),
      @types.new_target(700.0, 300.0, @types.target_radius),
    ],
    splitters: [
      @types.new_splitter(400.0, 350.0, @types.splitter_radius),
      @types.new_splitter(700.0, 200.0, @types.splitter_radius),
    ],
    gates: [],
    bumpers: [],
    pickups: [@types.new_pickup(300.0, 200.0, @types.pickup_radius)],
    start_pos: @types.vec2(200.0, 600.0),
    par_bounces: 4,
  }
}

///|
pub fn level_17() -> @types.Level {
  // Narrow corridor with splitter at the end
  {
    walls: [
      @types.new_wall(400.0, 200.0, 400.0, 550.0),
      @types.new_wall(600.0, 200.0, 600.0, 550.0),
    ],
    targets: [
      @types.new_target(200.0, 100.0, @types.target_radius),
      @types.new_target(800.0, 100.0, @types.target_radius),
      @types.new_target(500.0, 650.0, @types.target_radius),
    ],
    splitters: [
      @types.new_splitter(500.0, 200.0, @types.splitter_radius),
    ],
    gates: [],
    bumpers: [],
    pickups: [],
    start_pos: @types.vec2(500.0, 600.0),
    par_bounces: 5,
  }
}

///|
pub fn level_18() -> @types.Level {
  // Splitter maze with walls
  {
    walls: [
      @types.new_wall(300.0, 450.0, 500.0, 350.0),
      @types.new_wall(500.0, 350.0, 700.0, 450.0),
      @types.new_wall(200.0, 200.0, 400.0, 200.0),
      @types.new_wall(600.0, 200.0, 800.0, 200.0),
    ],
    targets: [
      @types.new_target(100.0, 100.0, @types.target_radius),
      @types.new_target(500.0, 100.0, @types.target_radius),
      @types.new_target(900.0, 100.0, @types.target_radius),
      @types.new_target(500.0, 550.0, @types.target_radius),
    ],
    splitters: [
      @types.new_splitter(500.0, 300.0, @types.splitter_radius),
    ],
    gates: [],
    bumpers: [],
    pickups: [@types.new_pickup(500.0, 450.0, @types.pickup_radius)],
    start_pos: @types.vec2(500.0, 650.0),
    par_bounces: 6,
  }
}

///|
pub fn level_19() -> @types.Level {
  // Triple splitter challenge
  {
    walls: [
      @types.new_wall(250.0, 300.0, 250.0, 500.0),
      @types.new_wall(750.0, 300.0, 750.0, 500.0),
    ],
    targets: [
      @types.new_target(100.0, 150.0, @types.target_radius),
      @types.new_target(500.0, 80.0, @types.target_radius),
      @types.new_target(900.0, 150.0, @types.target_radius),
      @types.new_target(100.0, 500.0, @types.target_radius),
    ],
    splitters: [
      @types.new_splitter(500.0, 400.0, @types.splitter_radius),
      @types.new_splitter(350.0, 250.0, @types.splitter_radius),
      @types.new_splitter(650.0, 250.0, @types.splitter_radius),
    ],
    gates: [],
    bumpers: [],
    pickups: [],
    start_pos: @types.vec2(500.0, 600.0),
    par_bounces: 5,
  }
}

///|
pub fn level_20() -> @types.Level {
  // World 2 finale: complex splitter arrangement
  {
    walls: [
      @types.new_wall(200.0, 350.0, 400.0, 250.0),
      @types.new_wall(600.0, 250.0, 800.0, 350.0),
      @types.new_wall(400.0, 150.0, 600.0, 150.0),
    ],
    targets: [
      @types.new_target(100.0, 80.0, @types.target_radius),
      @types.new_target(500.0, 50.0, @types.target_radius),
      @types.new_target(900.0, 80.0, @types.target_radius),
      @types.new_target(300.0, 500.0, @types.target_radius),
      @types.new_target(700.0, 500.0, @types.target_radius),
    ],
    splitters: [
      @types.new_splitter(500.0, 400.0, @types.splitter_radius),
      @types.new_splitter(300.0, 250.0, @types.splitter_radius),
    ],
    gates: [],
    bumpers: [],
    pickups: [@types.new_pickup(500.0, 250.0, @types.pickup_radius)],
    start_pos: @types.vec2(500.0, 650.0),
    par_bounces: 7,
  }
}
