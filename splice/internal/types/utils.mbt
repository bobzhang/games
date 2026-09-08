///|
pub fn codon_to_trait(b0 : Base, b1 : Base, b2 : Base) -> Trait {
  match (b0, b1, b2) {
    (A, T, G) => Start
    (T, G, A) => Stop
    (A, A, A) => Strength
    (T, T, T) => Speed
    (G, G, G) => Shield
    (C, C, C) => Stealth
    (A, T, C) => Heal
    (G, A, T) => Poison
    (T, C, A) => Armor
    (A, G, C) => Vision
    _ => Neutral
  }
}

///|
pub fn find_start_codon(seq : Array[Base]) -> Int {
  for i in 0..<(seq.length() - 2) {
    if seq[i] == A && seq[i + 1] == T && seq[i + 2] == G {
      return i
    }
  }
  -1
}

///|
pub fn read_sequence(seq : Array[Base]) -> ReadResult {
  let start_pos = find_start_codon(seq)
  if start_pos < 0 {
    return { traits: [], valid: false, }
  }
  let traits : Array[Trait] = []
  traits.push(Start)
  let mut pos = start_pos + 3
  while pos + 2 < seq.length() {
    let tr = codon_to_trait(seq[pos], seq[pos + 1], seq[pos + 2])
    traits.push(tr)
    if tr == Stop {
      return { traits, valid: true, }
    }
    pos += 3
  }
  // Reached end without Stop - still valid but incomplete
  { traits, valid: true, }
}

///|
pub fn traits_match(produced : Array[Trait], target : Array[Trait]) -> Bool {
  if produced.length() != target.length() {
    return false
  }
  for i in 0..<produced.length() {
    if produced[i] != target[i] {
      return false
    }
  }
  true
}

///|
pub fn base_color(b : Base) -> @raylib.Color {
  match b {
    A => color_base_a
    T => color_base_t
    G => color_base_g
    C => color_base_c
  }
}

///|
pub fn base_char(b : Base) -> String {
  match b {
    A => "A"
    T => "T"
    G => "G"
    C => "C"
  }
}

///|
pub fn trait_color(t : Trait) -> @raylib.Color {
  match t {
    Start => color_trait_start
    Stop => color_trait_stop
    Strength => color_trait_strength
    Speed => color_trait_speed
    Shield => color_trait_shield
    Stealth => color_trait_stealth
    Heal => color_trait_heal
    Poison => color_trait_poison
    Armor => color_trait_armor
    Vision => color_trait_vision
    Neutral => color_trait_neutral
  }
}

///|
pub fn trait_name(t : Trait) -> String {
  match t {
    Start => "START"
    Stop => "STOP"
    Strength => "STR"
    Speed => "SPD"
    Shield => "SHD"
    Stealth => "STL"
    Heal => "HEL"
    Poison => "PSN"
    Armor => "ARM"
    Vision => "VIS"
    Neutral => "---"
  }
}

///|
pub fn op_name(op : OpKind) -> String {
  match op {
    Cut => "CUT"
    Insert => "INSERT"
    Duplicate => "DUPLICATE"
    Invert => "INVERT"
    Delete => "DELETE"
  }
}

///|
pub fn op_color(op : OpKind) -> @raylib.Color {
  match op {
    Cut => color_op_cut
    Insert => color_op_insert
    Duplicate => color_op_duplicate
    Invert => color_op_invert
    Delete => color_op_delete
  }
}

///|
pub fn op_key(op : OpKind) -> String {
  match op {
    Cut => "1"
    Insert => "2"
    Duplicate => "3"
    Invert => "4"
    Delete => "5"
  }
}

///|
pub fn tier_name(t : Tier) -> String {
  match t {
    LabBasics => "LAB BASICS"
    GeneEditing => "GENE EDITING"
    Mastery => "MASTERY"
  }
}

///|
pub fn tier_from_index(i : Int) -> Tier {
  if i == 0 {
    LabBasics
  } else if i == 1 {
    GeneEditing
  } else {
    Mastery
  }
}

///|
pub fn tier_level_count(tier : Int) -> Int {
  if tier == 0 {
    tier1_count
  } else if tier == 1 {
    tier2_count
  } else {
    tier3_count
  }
}

///|
pub fn tier_level_offset(tier : Int) -> Int {
  if tier == 0 {
    0
  } else if tier == 1 {
    tier1_count
  } else {
    tier1_count + tier2_count
  }
}

///|
pub fn copy_sequence(seq : Array[Base]) -> Array[Base] {
  let result : Array[Base] = Array::new(capacity=seq.length())
  for i in 0..<seq.length() {
    result.push(seq[i])
  }
  result
}

///|
pub fn new_level_score() -> LevelScore {
  { completed: false, stars: 0, best_edits: 999, }
}

///|
pub fn new_game() -> Game {
  let scores : Array[LevelScore] = Array::new(capacity=total_levels)
  for _i in 0..<total_levels {
    scores.push(new_level_score())
  }
  {
    screen: Title,
    play_state: Editing,
    current_sequence: [],
    original_sequence: [],
    cursor: 0,
    selection_start: -1,
    selection_end: -1,
    edit_count: 0,
    ops_history: [],
    current_tier: 0,
    current_level: 0,
    insert_base: A,
    selected_op: Cut,
    level_scores: scores,
    message: "",
    message_timer: 0.0,
    frame_count: 0,
    anim_timer: 0.0,
    show_help: false,
    confirm_verify: false,
  }
}

///|
pub fn set_message(game : Game, msg : String, duration : Float) -> Unit {
  game.message = msg
  game.message_timer = duration
}

///|
pub fn has_selection(game : Game) -> Bool {
  game.selection_start >= 0 &&
  game.selection_end >= 0 &&
  game.selection_start != game.selection_end
}

///|
pub fn selection_min(game : Game) -> Int {
  if game.selection_start < game.selection_end {
    game.selection_start
  } else {
    game.selection_end
  }
}

///|
pub fn selection_max(game : Game) -> Int {
  if game.selection_start > game.selection_end {
    game.selection_start
  } else {
    game.selection_end
  }
}

///|
pub fn clamp_cursor(game : Game) -> Unit {
  let len = game.current_sequence.length()
  if game.cursor < 0 {
    game.cursor = 0
  }
  if game.cursor > len {
    game.cursor = len
  }
}

///|
pub fn clear_selection(game : Game) -> Unit {
  game.selection_start = -1
  game.selection_end = -1
}

///|
pub fn color_with_alpha(c : @raylib.Color, alpha : Int) -> @raylib.Color {
  @raylib.Color::new(c.r.to_int(), c.g.to_int(), c.b.to_int(), alpha)
}

///|
pub fn compute_stars(edit_count : Int, par : Int, min : Int) -> Int {
  if edit_count <= min {
    3
  } else if edit_count <= par {
    2
  } else {
    1
  }
}
