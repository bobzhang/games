///|
pub fn new_case_score() -> CaseScore {
  {
    order_correct: false,
    links_correct: false,
    no_rewinds: false,
    stars: 0,
    order_count: 0,
    link_count: 0,
  }
}

///|
pub fn new_game() -> Game {
  let case_scores : Array[Array[CaseScore]] = [[], [], []]
  // Tier 1: 7 cases
  for _i in 0..<7 {
    case_scores[0].push(new_case_score())
  }
  // Tier 2: 7 cases
  for _i in 0..<7 {
    case_scores[1].push(new_case_score())
  }
  // Tier 3: 6 cases
  for _i in 0..<6 {
    case_scores[2].push(new_case_score())
  }
  {
    screen: Title,
    play_state: Arranging,
    current_tier: Reports,
    current_case_index: 0,
    timeline_slots: [],
    placed_links: [],
    rewinds: 0,
    selected_card: -1,
    link_from: -1,
    dragging: false,
    drag_card_id: -1,
    drag_x: 0.0,
    drag_y: 0.0,
    hover_slot: -1,
    hover_card: -1,
    scroll_offset: 0.0,
    anim_timer: 0.0,
    result_score: new_case_score(),
    case_scores,
    frame_count: 0,
    message: "",
    message_timer: 0.0,
    title_pulse: 0.0,
  }
}

///|
pub fn find_card(cards : Array[EventCard], id : Int32) -> EventCard? {
  for i in 0..<cards.length() {
    if cards[i].id == id {
      return Some(cards[i])
    }
  }
  None
}

///|
pub fn card_in_slot(timeline : Array[Int32], card_id : Int32) -> Int32 {
  for i in 0..<timeline.length() {
    if timeline[i] == card_id {
      return i
    }
  }
  -1
}

///|
pub fn is_card_placed(timeline : Array[Int32], card_id : Int32) -> Bool {
  card_in_slot(timeline, card_id) >= 0
}

///|
pub fn is_slot_empty(timeline : Array[Int32], slot : Int32) -> Bool {
  if slot < 0 || slot >= timeline.length() {
    false
  } else {
    timeline[slot] == -1
  }
}

///|
pub fn count_placed(timeline : Array[Int32]) -> Int32 {
  let mut count = 0
  for i in 0..<timeline.length() {
    if timeline[i] != -1 {
      count += 1
    }
  }
  count
}

///|
pub fn is_anchor(case_ : Case, card_id : Int32) -> Bool {
  for i in 0..<case_.anchors.length() {
    if case_.anchors[i] == card_id {
      return true
    }
  }
  false
}

///|
pub fn get_fixed_slot(cards : Array[EventCard], card_id : Int32) -> Int32 {
  match find_card(cards, card_id) {
    Some(c) => c.fixed_slot
    None => -1
  }
}

///|
pub fn tier_index(tier : Tier) -> Int32 {
  match tier {
    Reports => 0
    Investigations => 1
    ColdCases => 2
  }
}

///|
pub fn tier_from_index(idx : Int32) -> Tier {
  match idx {
    0 => Reports
    1 => Investigations
    _ => ColdCases
  }
}

///|
pub fn tier_case_count(tier : Tier) -> Int32 {
  match tier {
    Reports => 7
    Investigations => 7
    ColdCases => 6
  }
}

///|
pub fn tier_name(tier : Tier) -> String {
  match tier {
    Reports => "REPORTS"
    Investigations => "INVESTIGATIONS"
    ColdCases => "COLD CASES"
  }
}

///|
pub fn clue_kind_label(kind : ClueKind) -> String {
  match kind {
    Before => "BEFORE"
    After => "AFTER"
    Because => "BECAUSE"
    During => "DURING"
    NotAdjacent => "NOT ADJACENT"
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
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn mini(a : Int32, b : Int32) -> Int32 {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn maxi(a : Int32, b : Int32) -> Int32 {
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
pub fn link_exists(links : Array[CauseLink], from : Int32, to : Int32) -> Bool {
  for i in 0..<links.length() {
    if links[i].from_id == from && links[i].to_id == to {
      return true
    }
  }
  false
}

///|
pub fn remove_link(
  links : Array[CauseLink],
  from : Int32,
  to : Int32,
) -> Array[CauseLink] {
  let result : Array[CauseLink] = []
  for i in 0..<links.length() {
    if !(links[i].from_id == from && links[i].to_id == to) {
      result.push(links[i])
    }
  }
  result
}

///|
pub fn make_event_card(
  id : Int32,
  actor : String,
  action : String,
  time_hint : String,
  fixed_slot : Int32,
) -> EventCard {
  let text = actor + " - " + action
  { id, text, actor, action, time_hint, fixed_slot, }
}

///|
pub fn make_clue(
  kind : ClueKind,
  card_a : Int32,
  card_b : Int32,
  text : String,
) -> Clue {
  { kind, card_a, card_b, text, }
}

///|
pub fn make_link(from_id : Int32, to_id : Int32) -> CauseLink {
  { from_id, to_id, }
}
