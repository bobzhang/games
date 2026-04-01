///|
/// World 3 "Gates" - One-way gates + bumpers + everything combined.

///|
pub fn level_21() -> @types.Level {
  // Intro to bumpers
  {
    walls: [],
    targets: [
      @types.new_target(200.0, 100.0, @types.target_radius),
      @types.new_target(800.0, 100.0, @types.target_radius),
    ],
    splitters: [],
    gates: [],
    bumpers: [@types.new_bumper(500.0, 350.0, @types.bumper_radius)],
    pickups: [],
    start_pos: @types.vec2(500.0, 600.0),
    par_bounces: 3,
  }
}

///|
pub fn level_22() -> @types.Level {
  // Bumper chain
  {
    walls: [@types.new_wall(300.0, 200.0, 700.0, 200.0)],
    targets: [
      @types.new_target(500.0, 80.0, @types.target_radius),
      @types.new_target(150.0, 350.0, @types.target_radius),
    ],
    splitters: [],
    gates: [],
    bumpers: [
      @types.new_bumper(350.0, 400.0, @types.bumper_radius),
      @types.new_bumper(650.0, 300.0, @types.bumper_radius),
    ],
    pickups: [@types.new_pickup(500.0, 300.0, @types.pickup_radius)],
    start_pos: @types.vec2(500.0, 600.0),
    par_bounces: 4,
  }
}

///|
pub fn level_23() -> @types.Level {
  // Intro to one-way gates (pass through right direction only)
  {
    walls: [],
    targets: [
      @types.new_target(500.0, 100.0, @types.target_radius),
      @types.new_target(500.0, 500.0, @types.target_radius),
    ],
    splitters: [],
    gates: [
      // Gate at y=300, allows upward passage only
      @types.new_gate(350.0, 300.0, 650.0, 300.0, 0.0, -1.0),
    ],
    bumpers: [],
    pickups: [],
    start_pos: @types.vec2(500.0, 600.0),
    par_bounces: 4,
  }
}

///|
pub fn level_24() -> @types.Level {
  // Gate + bumper combo
  {
    walls: [
      @types.new_wall(200.0, 250.0, 400.0, 250.0),
      @types.new_wall(600.0, 250.0, 800.0, 250.0),
    ],
    targets: [
      @types.new_target(300.0, 100.0, @types.target_radius),
      @types.new_target(700.0, 100.0, @types.target_radius),
      @types.new_target(500.0, 400.0, @types.target_radius),
    ],
    splitters: [],
    gates: [@types.new_gate(400.0, 350.0, 600.0, 350.0, 0.0, -1.0)],
    bumpers: [@types.new_bumper(500.0, 200.0, @types.bumper_radius)],
    pickups: [@types.new_pickup(500.0, 150.0, @types.pickup_radius)],
    start_pos: @types.vec2(500.0, 600.0),
    par_bounces: 5,
  }
}

///|
pub fn level_25() -> @types.Level {
  // Gate maze: multiple gates directing flow
  {
    walls: [
      @types.new_wall(300.0, 400.0, 300.0, 200.0),
      @types.new_wall(700.0, 400.0, 700.0, 200.0),
    ],
    targets: [
      @types.new_target(150.0, 100.0, @types.target_radius),
      @types.new_target(500.0, 100.0, @types.target_radius),
      @types.new_target(850.0, 100.0, @types.target_radius),
    ],
    splitters: [],
    gates: [
      @types.new_gate(350.0, 300.0, 500.0, 300.0, -1.0, 0.0),
      @types.new_gate(500.0, 300.0, 650.0, 300.0, 1.0, 0.0),
    ],
    bumpers: [],
    pickups: [],
    start_pos: @types.vec2(500.0, 600.0),
    par_bounces: 6,
  }
}

///|
pub fn level_26() -> @types.Level {
  // Splitter + gate combo
  {
    walls: [
      @types.new_wall(200.0, 300.0, 400.0, 200.0),
      @types.new_wall(600.0, 200.0, 800.0, 300.0),
    ],
    targets: [
      @types.new_target(100.0, 100.0, @types.target_radius),
      @types.new_target(900.0, 100.0, @types.target_radius),
      @types.new_target(500.0, 500.0, @types.target_radius),
    ],
    splitters: [@types.new_splitter(500.0, 350.0, @types.splitter_radius)],
    gates: [@types.new_gate(400.0, 450.0, 600.0, 450.0, 0.0, 1.0)],
    bumpers: [],
    pickups: [@types.new_pickup(500.0, 150.0, @types.pickup_radius)],
    start_pos: @types.vec2(500.0, 650.0),
    par_bounces: 5,
  }
}

///|
pub fn level_27() -> @types.Level {
  // Everything: walls, splitter, bumper, gate
  {
    walls: [
      @types.new_wall(250.0, 400.0, 450.0, 300.0),
      @types.new_wall(550.0, 300.0, 750.0, 400.0),
    ],
    targets: [
      @types.new_target(150.0, 150.0, @types.target_radius),
      @types.new_target(500.0, 80.0, @types.target_radius),
      @types.new_target(850.0, 150.0, @types.target_radius),
      @types.new_target(500.0, 550.0, @types.target_radius),
    ],
    splitters: [@types.new_splitter(500.0, 250.0, @types.splitter_radius)],
    gates: [@types.new_gate(350.0, 500.0, 650.0, 500.0, 0.0, 1.0)],
    bumpers: [
      @types.new_bumper(300.0, 150.0, @types.bumper_radius),
      @types.new_bumper(700.0, 150.0, @types.bumper_radius),
    ],
    pickups: [],
    start_pos: @types.vec2(500.0, 650.0),
    par_bounces: 6,
  }
}

///|
pub fn level_28() -> @types.Level {
  // Twin splitters and gate gauntlet
  {
    walls: [
      @types.new_wall(150.0, 300.0, 350.0, 200.0),
      @types.new_wall(650.0, 200.0, 850.0, 300.0),
      @types.new_wall(400.0, 100.0, 600.0, 100.0),
    ],
    targets: [
      @types.new_target(100.0, 80.0, @types.target_radius),
      @types.new_target(500.0, 50.0, @types.target_radius),
      @types.new_target(900.0, 80.0, @types.target_radius),
      @types.new_target(300.0, 550.0, @types.target_radius),
      @types.new_target(700.0, 550.0, @types.target_radius),
    ],
    splitters: [
      @types.new_splitter(400.0, 350.0, @types.splitter_radius),
      @types.new_splitter(600.0, 350.0, @types.splitter_radius),
    ],
    gates: [
      @types.new_gate(350.0, 450.0, 500.0, 450.0, 0.0, 1.0),
      @types.new_gate(500.0, 450.0, 650.0, 450.0, 0.0, 1.0),
    ],
    bumpers: [@types.new_bumper(500.0, 200.0, @types.bumper_radius)],
    pickups: [@types.new_pickup(500.0, 300.0, @types.pickup_radius)],
    start_pos: @types.vec2(500.0, 650.0),
    par_bounces: 7,
  }
}

///|
pub fn level_29() -> @types.Level {
  // Gauntlet: bumper ring around targets
  {
    walls: [
      @types.new_wall(200.0, 350.0, 350.0, 250.0),
      @types.new_wall(650.0, 250.0, 800.0, 350.0),
    ],
    targets: [
      @types.new_target(300.0, 100.0, @types.target_radius),
      @types.new_target(500.0, 100.0, @types.target_radius),
      @types.new_target(700.0, 100.0, @types.target_radius),
      @types.new_target(200.0, 500.0, @types.target_radius),
      @types.new_target(800.0, 500.0, @types.target_radius),
    ],
    splitters: [@types.new_splitter(500.0, 350.0, @types.splitter_radius)],
    gates: [@types.new_gate(400.0, 200.0, 600.0, 200.0, 0.0, -1.0)],
    bumpers: [
      @types.new_bumper(350.0, 150.0, @types.bumper_radius),
      @types.new_bumper(650.0, 150.0, @types.bumper_radius),
      @types.new_bumper(500.0, 500.0, @types.bumper_radius),
    ],
    pickups: [],
    start_pos: @types.vec2(500.0, 650.0),
    par_bounces: 8,
  }
}

///|
pub fn level_30() -> @types.Level {
  // Final boss level: everything combined, 5 targets
  {
    walls: [
      @types.new_wall(200.0, 400.0, 400.0, 300.0),
      @types.new_wall(600.0, 300.0, 800.0, 400.0),
      @types.new_wall(350.0, 150.0, 650.0, 150.0),
      @types.new_wall(150.0, 550.0, 350.0, 550.0),
      @types.new_wall(650.0, 550.0, 850.0, 550.0),
    ],
    targets: [
      @types.new_target(100.0, 80.0, @types.target_radius),
      @types.new_target(500.0, 50.0, @types.target_radius),
      @types.new_target(900.0, 80.0, @types.target_radius),
      @types.new_target(250.0, 500.0, @types.target_radius),
      @types.new_target(750.0, 500.0, @types.target_radius),
    ],
    splitters: [
      @types.new_splitter(500.0, 350.0, @types.splitter_radius),
      @types.new_splitter(300.0, 200.0, @types.splitter_radius),
    ],
    gates: [
      @types.new_gate(350.0, 480.0, 500.0, 480.0, 0.0, 1.0),
      @types.new_gate(500.0, 480.0, 650.0, 480.0, 0.0, 1.0),
    ],
    bumpers: [
      @types.new_bumper(200.0, 250.0, @types.bumper_radius),
      @types.new_bumper(800.0, 250.0, @types.bumper_radius),
      @types.new_bumper(500.0, 550.0, @types.bumper_radius),
    ],
    pickups: [@types.new_pickup(500.0, 250.0, @types.pickup_radius)],
    start_pos: @types.vec2(500.0, 650.0),
    par_bounces: 10,
  }
}
