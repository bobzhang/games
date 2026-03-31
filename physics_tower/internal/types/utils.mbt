///|
pub fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
pub fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
}

///|
pub fn lerp(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
pub fn snap_to_grid(v : Float, grid : Float) -> Float {
  let half = grid * 0.5
  let shifted = v + half
  let n = (shifted / grid).to_int()
  Float::from_int(n) * grid
}

///|
pub fn piece_dimensions(kind : PieceKind) -> (Float, Float) {
  match kind {
    Beam => (beam_w, beam_h)
    Block => (block_w, block_h)
    Triangle => (triangle_w, triangle_h)
    Arch => (arch_w, arch_h)
    Cable => (cable_w, cable_h)
  }
}

///|
pub fn material_mass(mat : Material) -> Float {
  match mat {
    Wood => mass_wood
    Stone => mass_stone
    Steel => mass_steel
  }
}

///|
pub fn material_strength(mat : Material) -> Float {
  match mat {
    Wood => stress_wood
    Stone => stress_stone
    Steel => stress_steel
  }
}

///|
pub fn new_body(
  id : Int,
  kind : PieceKind,
  material : Material,
  x : Float,
  y : Float,
  angle : Float
) -> Body {
  let (w, h) = piece_dimensions(kind)
  let m = material_mass(material) * w * h * 0.001
  {
    id,
    active: true,
    kind,
    material,
    x,
    y,
    angle,
    vx: 0.0,
    vy: 0.0,
    angular_vel: 0.0,
    width: w,
    height: h,
    mass: m,
    stress: 0.0,
    broken: false,
    grounded: false,
  }
}

///|
pub fn new_joint(
  kind : JointKind,
  body_a : Int,
  body_b : Int,
  lxa : Float,
  lya : Float,
  lxb : Float,
  lyb : Float,
  strength : Float
) -> Joint {
  {
    active: true,
    kind,
    body_a,
    body_b,
    local_x_a: lxa,
    local_y_a: lya,
    local_x_b: lxb,
    local_y_b: lyb,
    stress: 0.0,
    broken: false,
    strength,
  }
}

///|
pub fn new_world() -> World {
  {
    bodies: Array::new(capacity=max_bodies),
    joints: Array::new(capacity=max_joints),
    gravity: gravity,
    ground_y,
    wind_force: 0.0,
    quake_timer: 0.0,
    quake_intensity: 0.0,
  }
}

///|
pub fn new_particle(
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  r : Int,
  g : Int,
  b : Int
) -> Particle {
  { x, y, vx, vy, life, max_life: life, size, r, g, b }
}

///|
pub fn new_destruction_state() -> DestructionState {
  {
    particles: Array::new(capacity=max_particles),
    slow_motion: 0.0,
    camera_shake: 0.0,
    shake_x: 0.0,
    shake_y: 0.0,
    chain_breaks: 0,
    replay_timer: 0.0,
    replay_active: false,
  }
}

///|
pub fn new_challenge_state(mode : ChallengeMode) -> ChallengeState {
  let (time, target, budget) = match mode {
    TimeAttack => (time_attack_duration, 0.0F, 999)
    BudgetMode => (120.0F, 300.0F, 8)
    Survival => (0.0F, 200.0F, 20)
    Precision => (90.0F, 400.0F, 15)
  }
  {
    mode,
    time_left: time,
    rounds_survived: 0,
    target_height: target,
    budget_used: 0,
    budget_limit: budget,
    hazard_round: 0,
    hazard_timer: 0.0,
    completed: false,
    challenge_score: 0,
  }
}

///|
pub fn default_upgrades() -> Array[Upgrade] {
  [
    {
      kind: Reinforce(Wood),
      name: "Reinforce Wood",
      description: "+50% stress tolerance for Wood",
      cost: upgrade_cost_reinforce,
      purchased: false,
    },
    {
      kind: Reinforce(Stone),
      name: "Reinforce Stone",
      description: "+50% stress tolerance for Stone",
      cost: upgrade_cost_reinforce,
      purchased: false,
    },
    {
      kind: Reinforce(Steel),
      name: "Reinforce Steel",
      description: "+50% stress tolerance for Steel",
      cost: upgrade_cost_reinforce,
      purchased: false,
    },
    {
      kind: Lightweight(Wood),
      name: "Lightweight Wood",
      description: "-30% mass for Wood pieces",
      cost: upgrade_cost_lightweight,
      purchased: false,
    },
    {
      kind: Lightweight(Stone),
      name: "Lightweight Stone",
      description: "-30% mass for Stone pieces",
      cost: upgrade_cost_lightweight,
      purchased: false,
    },
    {
      kind: Lightweight(Steel),
      name: "Lightweight Steel",
      description: "-30% mass for Steel pieces",
      cost: upgrade_cost_lightweight,
      purchased: false,
    },
    {
      kind: FlexJoints,
      name: "Flex Joints",
      description: "Hinges don't break as easily",
      cost: upgrade_cost_flex,
      purchased: false,
    },
    {
      kind: DeepFoundation,
      name: "Deep Foundation",
      description: "Ground pieces are immovable",
      cost: upgrade_cost_foundation,
      purchased: false,
    },
  ]
}

///|
pub fn default_blueprints() -> Array[Blueprint] {
  [
    // Column: 3 blocks stacked
    {
      kind: Column,
      name: "Column",
      pieces: [
        (Block, Stone, 0.0, 0.0, 0.0),
        (Block, Stone, 0.0, -60.0, 0.0),
        (Block, Stone, 0.0, -120.0, 0.0),
      ],
      cost: 3,
    },
    // Arch: 2 columns + beam on top
    {
      kind: ArchWay,
      name: "Archway",
      pieces: [
        (Block, Stone, -70.0, 0.0, 0.0),
        (Block, Stone, -70.0, -60.0, 0.0),
        (Block, Stone, 70.0, 0.0, 0.0),
        (Block, Stone, 70.0, -60.0, 0.0),
        (Beam, Steel, 0.0, -100.0, 0.0),
      ],
      cost: 5,
    },
    // Truss: triangle pattern
    {
      kind: Truss,
      name: "Truss",
      pieces: [
        (Block, Wood, -40.0, 0.0, 0.0),
        (Block, Wood, 40.0, 0.0, 0.0),
        (Triangle, Wood, 0.0, -55.0, 0.0),
        (Beam, Wood, 0.0, -90.0, 0.0),
      ],
      cost: 4,
    },
    // Foundation: wide base
    {
      kind: Foundation,
      name: "Foundation",
      pieces: [
        (Beam, Stone, -60.0, 0.0, 0.0),
        (Beam, Stone, 60.0, 0.0, 0.0),
        (Block, Stone, 0.0, 0.0, 0.0),
      ],
      cost: 3,
    },
  ]
}

///|
pub fn new_tutorial_state() -> TutorialState {
  {
    step: 0,
    completed: false,
    highlight_x: 0,
    highlight_y: 0,
    highlight_w: 0,
    highlight_h: 0,
    message: "",
    show_arrow: false,
    arrow_x: 0,
    arrow_y: 0,
    blink_timer: 0.0,
  }
}

///|
pub fn new_statistics(level_count : Int) -> Statistics {
  let best = Array::new(capacity=level_count)
  let stars = Array::new(capacity=level_count)
  for _i in 0..<level_count {
    best.push(0.0F)
    stars.push(0)
  }
  {
    total_builds: 0,
    total_breaks: 0,
    best_heights: best,
    materials_used: [0, 0, 0],
    levels_completed: 0,
    stars_earned: 0,
    level_stars: stars,
    total_pieces_placed: 0,
    total_tests_run: 0,
    challenges_completed: 0,
  }
}

///|
pub fn new_replay_state() -> ReplayState {
  {
    actions: Array::new(capacity=64),
    test_height: 0.0,
    test_score: 0,
    test_passed: false,
    playback_index: 0,
    playback_timer: 0.0,
    playback_speed: 1.0,
    is_recording: false,
    is_playing: false,
    ghost_pieces: Array::new(capacity=64),
    ghost_visible: false,
  }
}

///|
pub fn new_game() -> Game {
  {
    screen: Title,
    world: new_world(),
    current_level: 0,
    selected_piece: 0,
    ghost_x: 600.0,
    ghost_y: 400.0,
    ghost_angle: 0.0,
    score: 0,
    total_score: 0,
    best_height: 0.0,
    test_phase: 0,
    test_timer: 0.0,
    frame_count: 0,
    rng_state: 12345U,
    message_text: "",
    message_timer: 0.0,
    inventory: Array::new(capacity=20),
    tower_height: 0.0,
    blueprints: default_blueprints(),
    selected_blueprint: -1,
    custom_blueprints: Array::new(capacity=10),
    destruction: new_destruction_state(),
    upgrades: default_upgrades(),
    challenge_state: None,
    star_anim_timer: 0.0,
    result_stars: 0,
    reinforce_wood: false,
    reinforce_stone: false,
    reinforce_steel: false,
    lightweight_wood: false,
    lightweight_stone: false,
    lightweight_steel: false,
    flex_joints: false,
    deep_foundation: false,
    active_combos: Array::new(capacity=32),
    tutorial: new_tutorial_state(),
    statistics: new_statistics(20),
    replay: new_replay_state(),
    sound_queue: Array::new(capacity=16),
    current_world: 0,
    tutorial_shown: false,
  }
}

///|
pub fn pointer_in_rect(
  mx : Float,
  my : Float,
  rx : Int,
  ry : Int,
  rw : Int,
  rh : Int
) -> Bool {
  let x0 = Float::from_int(rx)
  let y0 = Float::from_int(ry)
  let x1 = Float::from_int(rx + rw)
  let y1 = Float::from_int(ry + rh)
  mx >= x0 && mx <= x1 && my >= y0 && my <= y1
}
