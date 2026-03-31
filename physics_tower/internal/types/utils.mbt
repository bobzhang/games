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
    best_height: 0.0,
    test_phase: 0,
    test_timer: 0.0,
    frame_count: 0,
    rng_state: 12345U,
    message_text: "",
    message_timer: 0.0,
    inventory: Array::new(capacity=20),
    tower_height: 0.0,
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
