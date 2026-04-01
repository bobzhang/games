///|
pub fn cosf(a : Float) -> Float {
  Float::from_double(@math.cos(a.to_double()))
}

///|
pub fn sinf(a : Float) -> Float {
  Float::from_double(@math.sin(a.to_double()))
}

///|
pub fn sqrtf(a : Float) -> Float {
  Float::from_double(a.to_double().sqrt())
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
pub fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

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
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
pub fn new_cell(kind : CellKind) -> Cell {
  {
    kind,
    gate_open: kind != Gate,
    switch_link_id: -1,
    arrow_offset: 0,
    has_pickup: false,
  }
}

///|
pub fn make_cell(
  kind : CellKind,
  gate_open? : Bool = true,
  switch_link_id? : Int = -1,
  arrow_offset? : Int = 0,
  has_pickup? : Bool = false,
) -> Cell {
  { kind, gate_open, switch_link_id, arrow_offset, has_pickup }
}

///|
pub fn new_spiral(cells : Array[Cell]) -> Spiral {
  { cells, }
}

///|
pub fn new_switch_link(
  cw : Int,
  ccw : Int,
  gcw : Array[Int],
  gccw : Array[Int],
) -> SwitchLink {
  {
    switch_cell_cw: cw,
    switch_cell_ccw: ccw,
    gate_cells_cw: gcw,
    gate_cells_ccw: gccw,
  }
}

///|
pub fn new_level(
  cw : Spiral,
  ccw : Spiral,
  links : Array[SwitchLink],
  par : Int,
  pickups : Int,
  name : String,
) -> Level {
  {
    cw_spiral: cw,
    ccw_spiral: ccw,
    switch_links: links,
    par_steps: par,
    pickups_total: pickups,
    name,
  }
}

///|
pub fn new_level_score() -> LevelScore {
  { completed: false, steps: 0, stars: 0, pickups: 0 }
}

///|
pub fn new_game() -> Game {
  let scores : Array[LevelScore] = Array::new(capacity=total_levels)
  for _i in 0..<total_levels {
    scores.push(new_level_score())
  }
  {
    screen: Title,
    selected_tier: Coil,
    selected_level: 0,
    cw_pos: 0,
    ccw_pos: 0,
    steps: 0,
    play_state: Moving,
    pickups_collected: [],
    pickups_count: 0,
    oneshot_used: [],
    current_level: None,
    history: [],
    level_scores: scores,
    message: "",
    message_timer: 0.0,
    frame_count: 0,
    anim_timer: 0.0,
  }
}

///|
pub fn cell_pos_on_spiral(
  index : Int,
  total : Int,
  is_cw : Bool,
  cx : Float,
  cy : Float,
) -> (Float, Float) {
  let base_radius : Float = 60.0
  let max_rings : Float = 8.0
  let progress = Float::from_int(index) /
    Float::from_int(if total > 1 { total - 1 } else { 1 })
  let radius = base_radius + max_rings * ring_spacing * (1.0 - progress)
  let total_turns : Float = 3.0
  let angle = if is_cw {
    progress * total_turns * 2.0 * pi
  } else {
    -progress * total_turns * 2.0 * pi + pi
  }
  let x = cx + radius * cosf(angle)
  let y = cy + radius * sinf(angle)
  (x, y)
}

///|
pub fn tier_of_level(level_index : Int) -> Tier {
  if level_index < tier1_count {
    Coil
  } else if level_index < tier1_count + tier2_count {
    Twist
  } else {
    DoubleHelix
  }
}

///|
pub fn tier_start_index(tier : Tier) -> Int {
  match tier {
    Coil => 0
    Twist => tier1_count
    DoubleHelix => tier1_count + tier2_count
  }
}

///|
pub fn tier_level_count(tier : Tier) -> Int {
  match tier {
    Coil => tier1_count
    Twist => tier2_count
    DoubleHelix => tier3_count
  }
}

///|
pub fn tier_name(tier : Tier) -> String {
  match tier {
    Coil => "Coil"
    Twist => "Twist"
    DoubleHelix => "Double Helix"
  }
}

///|
pub fn tier_color(tier : Tier) -> @raylib.Color {
  match tier {
    Coil => color_tier_coil
    Twist => color_tier_twist
    DoubleHelix => color_tier_double
  }
}

///|
pub fn save_history(game : Game) -> Unit {
  match game.current_level {
    None => ()
    Some(level) => {
      let gcw : Array[Bool] = Array::new(
        capacity=level.cw_spiral.cells.length(),
      )
      for i in 0..<level.cw_spiral.cells.length() {
        gcw.push(level.cw_spiral.cells[i].gate_open)
      }
      let gccw : Array[Bool] = Array::new(
        capacity=level.ccw_spiral.cells.length(),
      )
      for i in 0..<level.ccw_spiral.cells.length() {
        gccw.push(level.ccw_spiral.cells[i].gate_open)
      }
      let ou : Array[Bool] = Array::new(capacity=game.oneshot_used.length())
      for i in 0..<game.oneshot_used.length() {
        ou.push(game.oneshot_used[i])
      }
      let pc : Array[Bool] = Array::new(
        capacity=game.pickups_collected.length(),
      )
      for i in 0..<game.pickups_collected.length() {
        pc.push(game.pickups_collected[i])
      }
      game.history.push({
        cw_pos: game.cw_pos,
        ccw_pos: game.ccw_pos,
        gate_states_cw: gcw,
        gate_states_ccw: gccw,
        oneshot_used: ou,
        pickups_collected: pc,
        pickups_count: game.pickups_count,
      })
    }
  }
}

///|
pub fn restore_history(game : Game) -> Unit {
  if game.history.length() == 0 {
    return
  }
  let entry = game.history.unsafe_pop()
  game.cw_pos = entry.cw_pos
  game.ccw_pos = entry.ccw_pos
  game.steps -= 1
  game.pickups_count = entry.pickups_count
  for i in 0..<entry.pickups_collected.length() {
    game.pickups_collected[i] = entry.pickups_collected[i]
  }
  for i in 0..<entry.oneshot_used.length() {
    game.oneshot_used[i] = entry.oneshot_used[i]
  }
  match game.current_level {
    None => ()
    Some(level) => {
      for i in 0..<entry.gate_states_cw.length() {
        level.cw_spiral.cells[i].gate_open = entry.gate_states_cw[i]
      }
      for i in 0..<entry.gate_states_ccw.length() {
        level.ccw_spiral.cells[i].gate_open = entry.gate_states_ccw[i]
      }
    }
  }
  game.play_state = Moving
}

///|
pub fn calculate_stars(
  steps : Int,
  par : Int,
  pickups : Int,
  total_pickups : Int,
) -> Int {
  if steps <= par && pickups >= total_pickups {
    3
  } else if steps <= par {
    2
  } else {
    1
  }
}
