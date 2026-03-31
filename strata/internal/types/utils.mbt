///|
pub fn rock_color(kind : RockKind) -> @raylib.Color {
  match kind {
    Sandstone => color_sandstone
    Limestone => color_limestone
    Shale => color_shale
    Granite => color_granite
    Basalt => color_basalt
    Coal => color_coal
    Chalk => color_chalk
    Slate => color_slate
  }
}

///|
pub fn rock_name(kind : RockKind) -> String {
  match kind {
    Sandstone => "Sandstone"
    Limestone => "Limestone"
    Shale => "Shale"
    Granite => "Granite"
    Basalt => "Basalt"
    Coal => "Coal"
    Chalk => "Chalk"
    Slate => "Slate"
  }
}

///|
pub fn rock_index(kind : RockKind) -> Int {
  match kind {
    Sandstone => 0
    Limestone => 1
    Shale => 2
    Granite => 3
    Basalt => 4
    Coal => 5
    Chalk => 6
    Slate => 7
  }
}

///|
pub fn rock_from_index(idx : Int) -> RockKind {
  match idx {
    0 => Sandstone
    1 => Limestone
    2 => Shale
    3 => Granite
    4 => Basalt
    5 => Coal
    6 => Chalk
    _ => Slate
  }
}

///|
pub fn tier_name(t : Tier) -> String {
  match t {
    Surface => "Surface"
    Bedrock => "Bedrock"
    DeepCore => "Deep Core"
  }
}

///|
pub fn tier_color(t : Tier) -> @raylib.Color {
  match t {
    Surface => color_tier_surface
    Bedrock => color_tier_bedrock
    DeepCore => color_tier_deep
  }
}

///|
pub fn tier_level_range(t : Tier) -> (Int, Int) {
  match t {
    Surface => (0, 7)
    Bedrock => (8, 16)
    DeepCore => (17, 24)
  }
}

///|
pub fn tier_from_level(idx : Int) -> Tier {
  if idx < 8 {
    Surface
  } else if idx < 17 {
    Bedrock
  } else {
    DeepCore
  }
}

///|
pub fn clue_kind_name(kind : ClueKind) -> String {
  match kind {
    FossilAge => "Fossil Age"
    Superposition => "Superposition"
    Dating => "Dating"
    Intrusion => "Intrusion"
    Unconformity => "Unconformity"
  }
}

///|
pub fn new_clue(
  kind : ClueKind,
  param_a : Int,
  param_b : Int,
  text : String
) -> Clue {
  { kind, param_a, param_b, text, satisfied: false }
}

///|
pub fn new_level(
  tier : Tier,
  name : String,
  rocks : Array[RockKind],
  clues : Array[Clue],
  par_moves : Int
) -> Level {
  { tier, name, rocks, clues, par_moves }
}

///|
pub fn new_level_score() -> LevelScore {
  { stars: 0, completed: false, best_moves: 999 }
}

///|
pub fn new_game() -> Game {
  let scores : Array[LevelScore] = Array::new(capacity=total_levels)
  for _i in 0..<total_levels {
    scores.push(new_level_score())
  }
  {
    screen: Title,
    current_tier: Surface,
    current_level: 0,
    slots: [],
    tray: [],
    play_state: Arranging,
    moves: 0,
    selected_tray: -1,
    selected_slot: -1,
    any_incorrect: false,
    scores,
    undo_stack: [],
    frame_count: 0,
    message: "",
    message_timer: 0.0,
    anim_timer: 0.0,
    tier_page: 0,
  }
}

///|
pub fn save_undo(game : Game) -> Unit {
  let snap_slots : Array[RockKind?] = Array::new(capacity=game.slots.length())
  for i in 0..<game.slots.length() {
    snap_slots.push(game.slots[i])
  }
  let snap_tray : Array[RockKind] = Array::new(capacity=game.tray.length())
  for i in 0..<game.tray.length() {
    snap_tray.push(game.tray[i])
  }
  game.undo_stack.push({ slots: snap_slots, tray: snap_tray })
}

///|
pub fn pop_undo(game : Game) -> Bool {
  if game.undo_stack.length() > 0 {
    let entry = game.undo_stack.pop().unwrap()
    game.slots = entry.slots
    game.tray = entry.tray
    true
  } else {
    false
  }
}

///|
pub fn set_message(game : Game, msg : String, duration : Float) -> Unit {
  game.message = msg
  game.message_timer = duration
}

///|
pub fn find_rock_slot(slots : Array[RockKind?], rock : RockKind) -> Int {
  for i in 0..<slots.length() {
    match slots[i] {
      Some(r) => if r == rock { return i }
      None => ()
    }
  }
  -1
}

///|
pub fn count_filled_slots(slots : Array[RockKind?]) -> Int {
  let mut count = 0
  for i in 0..<slots.length() {
    match slots[i] {
      Some(_) => count += 1
      None => ()
    }
  }
  count
}

///|
pub fn all_slots_filled(slots : Array[RockKind?]) -> Bool {
  count_filled_slots(slots) == slots.length()
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
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
pub fn sinf(a : Float) -> Float {
  // Taylor series approximation for sin
  let pi : Float = 3.14159265
  let mut x = a
  // Normalize to -pi..pi
  for ;; {
    if x > pi {
      x = x - 2.0 * pi
    } else if x < -pi {
      x = x + 2.0 * pi
    } else {
      break
    }
  }
  let x2 = x * x
  let x3 = x2 * x
  let x5 = x3 * x2
  let x7 = x5 * x2
  x - x3 / 6.0 + x5 / 120.0 - x7 / 5040.0
}
