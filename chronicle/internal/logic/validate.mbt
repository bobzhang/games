///|
pub fn check_order(timeline : Array[Int], solution_order : Array[Int]) -> Bool {
  if timeline.length() != solution_order.length() {
    return false
  }
  for i in 0..<timeline.length() {
    if timeline[i] != solution_order[i] {
      return false
    }
  }
  true
}

///|
pub fn count_correct_positions(
  timeline : Array[Int],
  solution_order : Array[Int],
) -> Int {
  let mut count = 0
  let len = @types.mini(timeline.length(), solution_order.length())
  for i in 0..<len {
    if timeline[i] == solution_order[i] {
      count += 1
    }
  }
  count
}

///|
pub fn check_links(
  placed : Array[@types.CauseLink],
  solution : Array[@types.CauseLink],
) -> Bool {
  if placed.length() != solution.length() {
    return false
  }
  // Every solution link must be in placed
  for i in 0..<solution.length() {
    let mut found = false
    for j in 0..<placed.length() {
      if placed[j].from_id == solution[i].from_id &&
        placed[j].to_id == solution[i].to_id {
        found = true
        break
      }
    }
    if !found {
      return false
    }
  }
  // Every placed link must be in solution
  for i in 0..<placed.length() {
    let mut found = false
    for j in 0..<solution.length() {
      if solution[j].from_id == placed[i].from_id &&
        solution[j].to_id == placed[i].to_id {
        found = true
        break
      }
    }
    if !found {
      return false
    }
  }
  true
}

///|
pub fn count_correct_links(
  placed : Array[@types.CauseLink],
  solution : Array[@types.CauseLink],
) -> Int {
  let mut count = 0
  for i in 0..<placed.length() {
    for j in 0..<solution.length() {
      if placed[i].from_id == solution[j].from_id &&
        placed[i].to_id == solution[j].to_id {
        count += 1
        break
      }
    }
  }
  count
}

///|
pub fn check_clue_satisfied(clue : @types.Clue, timeline : Array[Int]) -> Bool {
  let pos_a = @types.card_in_slot(timeline, clue.card_a)
  let pos_b = @types.card_in_slot(timeline, clue.card_b)
  if pos_a < 0 || pos_b < 0 {
    return false
  }
  match clue.kind {
    Before => pos_a < pos_b
    After => pos_a > pos_b
    Because =>
      // A caused B means A must come before B
      pos_a < pos_b
    During => {
      // Simultaneous: adjacent
      let diff = pos_a - pos_b
      diff == 1 || diff == -1
    }
    NotAdjacent => {
      let diff = pos_a - pos_b
      !(diff == 1 || diff == -1)
    }
  }
}

///|
pub fn check_all_clues(
  clues : Array[@types.Clue],
  timeline : Array[Int],
) -> Bool {
  for i in 0..<clues.length() {
    if !check_clue_satisfied(clues[i], timeline) {
      return false
    }
  }
  true
}

///|
pub fn check_anchors(case_ : @types.Case, timeline : Array[Int]) -> Bool {
  for i in 0..<case_.anchors.length() {
    let card_id = case_.anchors[i]
    let fixed = @types.get_fixed_slot(case_.cards, card_id)
    if fixed >= 0 {
      let actual = @types.card_in_slot(timeline, card_id)
      if actual != fixed {
        return false
      }
    }
  }
  true
}

///|
pub fn compute_score(
  case_ : @types.Case,
  timeline : Array[Int],
  placed_links : Array[@types.CauseLink],
  rewinds : Int,
) -> @types.CaseScore {
  let order_ok = check_order(timeline, case_.solution_order)
  let links_ok = check_links(placed_links, case_.solution_links)
  let no_rewinds = rewinds == 0
  let mut stars = 0
  if order_ok {
    stars = 1
  }
  if order_ok && links_ok {
    stars = 2
  }
  if order_ok && links_ok && no_rewinds {
    stars = 3
  }
  let order_count = count_correct_positions(timeline, case_.solution_order)
  let link_count = count_correct_links(placed_links, case_.solution_links)
  {
    order_correct: order_ok,
    links_correct: links_ok,
    no_rewinds,
    stars,
    order_count,
    link_count,
  }
}
