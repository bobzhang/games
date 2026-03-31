///|
/// Check a single FossilAge clue: rock at param_a index must be below (older than)
/// rock at param_b index. In our vertical stack, slot 0 is bottom (oldest).
/// param_a = rock_index of older rock, param_b = rock_index of younger rock.
pub fn check_fossil_age(
  slots : Array[@types.RockKind?],
  older_rock_idx : Int,
  younger_rock_idx : Int
) -> Bool {
  let older_rock = @types.rock_from_index(older_rock_idx)
  let younger_rock = @types.rock_from_index(younger_rock_idx)
  let pos_older = @types.find_rock_slot(slots, older_rock)
  let pos_younger = @types.find_rock_slot(slots, younger_rock)
  if pos_older < 0 || pos_younger < 0 {
    return false
  }
  // Lower slot index = older (bottom of stack)
  pos_older < pos_younger
}

///|
/// Check Superposition clue: rock at param_a must be directly above rock at param_b.
/// "above" means higher slot index (param_a slot = param_b slot + 1).
pub fn check_superposition(
  slots : Array[@types.RockKind?],
  above_rock_idx : Int,
  below_rock_idx : Int
) -> Bool {
  let above_rock = @types.rock_from_index(above_rock_idx)
  let below_rock = @types.rock_from_index(below_rock_idx)
  let pos_above = @types.find_rock_slot(slots, above_rock)
  let pos_below = @types.find_rock_slot(slots, below_rock)
  if pos_above < 0 || pos_below < 0 {
    return false
  }
  pos_above == pos_below + 1
}

///|
/// Check Dating clue: rock at param_a must be at exactly slot param_b (0-based).
pub fn check_dating(
  slots : Array[@types.RockKind?],
  rock_idx : Int,
  target_slot : Int
) -> Bool {
  let rock = @types.rock_from_index(rock_idx)
  let pos = @types.find_rock_slot(slots, rock)
  if pos < 0 {
    return false
  }
  pos == target_slot
}

///|
/// Check Intrusion clue: rock at param_a (intruding, e.g. basalt) cuts through
/// rock at param_b. The intruding rock must be younger (higher slot).
pub fn check_intrusion(
  slots : Array[@types.RockKind?],
  intruder_idx : Int,
  host_idx : Int
) -> Bool {
  let intruder = @types.rock_from_index(intruder_idx)
  let host = @types.rock_from_index(host_idx)
  let pos_intruder = @types.find_rock_slot(slots, intruder)
  let pos_host = @types.find_rock_slot(slots, host)
  if pos_intruder < 0 || pos_host < 0 {
    return false
  }
  pos_intruder > pos_host
}

///|
/// Check Unconformity clue: rocks at param_a and param_b must NOT be adjacent.
pub fn check_unconformity(
  slots : Array[@types.RockKind?],
  rock_a_idx : Int,
  rock_b_idx : Int
) -> Bool {
  let rock_a = @types.rock_from_index(rock_a_idx)
  let rock_b = @types.rock_from_index(rock_b_idx)
  let pos_a = @types.find_rock_slot(slots, rock_a)
  let pos_b = @types.find_rock_slot(slots, rock_b)
  if pos_a < 0 || pos_b < 0 {
    return false
  }
  let diff = pos_a - pos_b
  let abs_diff = if diff < 0 { -diff } else { diff }
  abs_diff > 1
}

///|
/// Check a single clue against current arrangement.
pub fn check_clue(
  clue : @types.Clue,
  slots : Array[@types.RockKind?]
) -> Bool {
  match clue.kind {
    FossilAge => check_fossil_age(slots, clue.param_a, clue.param_b)
    Superposition => check_superposition(slots, clue.param_a, clue.param_b)
    Dating => check_dating(slots, clue.param_a, clue.param_b)
    Intrusion => check_intrusion(slots, clue.param_a, clue.param_b)
    Unconformity => check_unconformity(slots, clue.param_a, clue.param_b)
  }
}

///|
/// Validate all clues against current arrangement, returning number satisfied.
pub fn validate_all(
  clues : Array[@types.Clue],
  slots : Array[@types.RockKind?]
) -> Int {
  let mut satisfied = 0
  for i in 0..<clues.length() {
    let ok = check_clue(clues[i], slots)
    clues[i].satisfied = ok
    if ok {
      satisfied += 1
    }
  }
  satisfied
}

///|
/// Check if all clues are satisfied.
pub fn all_satisfied(clues : Array[@types.Clue]) -> Bool {
  for i in 0..<clues.length() {
    if !(clues[i].satisfied) {
      return false
    }
  }
  true
}
