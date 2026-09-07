///|
pub fn new_mapping() -> Mapping {
  let c2p : Array[Int] = Array(capacity=alphabet_size)
  let pu : Array[Bool] = Array(capacity=alphabet_size)
  for _i in 0..<alphabet_size {
    c2p.push(unmapped)
    pu.push(false)
  }
  { cipher_to_plain: c2p, plain_used: pu, }
}

///|
pub fn copy_mapping(src : Mapping) -> Mapping {
  let c2p : Array[Int] = Array(capacity=alphabet_size)
  let pu : Array[Bool] = Array(capacity=alphabet_size)
  for i in 0..<alphabet_size {
    c2p.push(src.cipher_to_plain[i])
    pu.push(src.plain_used[i])
  }
  { cipher_to_plain: c2p, plain_used: pu, }
}

///|
pub fn clear_mapping(m : Mapping) -> Unit {
  for i in 0..<alphabet_size {
    m.cipher_to_plain[i] = unmapped
    m.plain_used[i] = false
  }
}

///|
pub fn assign_mapping(
  m : Mapping,
  cipher_idx : Int,
  plain_idx : Int,
) -> UndoEntry {
  let old_plain = m.cipher_to_plain[cipher_idx]
  let mut old_displaced_cipher = -1
  let mut old_displaced_plain = -1
  if m.plain_used[plain_idx] {
    for i in 0..<alphabet_size {
      if m.cipher_to_plain[i] == plain_idx && i != cipher_idx {
        old_displaced_cipher = i
        old_displaced_plain = plain_idx
        m.cipher_to_plain[i] = unmapped
        break
      }
    }
  }
  if old_plain >= 0 {
    m.plain_used[old_plain] = false
  }
  m.cipher_to_plain[cipher_idx] = plain_idx
  m.plain_used[plain_idx] = true
  { cipher_idx, old_plain, old_displaced_cipher, old_displaced_plain, }
}

///|
pub fn undo_mapping(m : Mapping, entry : UndoEntry) -> Unit {
  let cipher_idx = entry.cipher_idx
  let current_plain = m.cipher_to_plain[cipher_idx]
  if current_plain >= 0 {
    m.plain_used[current_plain] = false
  }
  m.cipher_to_plain[cipher_idx] = entry.old_plain
  if entry.old_plain >= 0 {
    m.plain_used[entry.old_plain] = true
  }
  if entry.old_displaced_cipher >= 0 {
    m.cipher_to_plain[entry.old_displaced_cipher] = entry.old_displaced_plain
    if entry.old_displaced_plain >= 0 {
      m.plain_used[entry.old_displaced_plain] = true
    }
  }
}

///|
pub fn mapping_complete(m : Mapping) -> Bool {
  for i in 0..<alphabet_size {
    if m.cipher_to_plain[i] == unmapped {
      return false
    }
  }
  true
}

///|
pub fn is_upper(c : Char) -> Bool {
  c >= 'A' && c <= 'Z'
}

///|
pub fn char_to_idx(c : Char) -> Int {
  c.to_int() - 'A'.to_int()
}

///|
pub fn idx_to_char(i : Int) -> Char {
  Int::unsafe_to_char('A'.to_int() + i)
}

///|
pub fn str_char_at(s : String, i : Int) -> Char {
  s[i].to_int().unsafe_to_char()
}

///|
pub fn apply_mapping_to_text(ciphertext : String, m : Mapping) -> String {
  let buf = StringBuilder()
  for i in 0..<ciphertext.length() {
    let c = str_char_at(ciphertext, i)
    if is_upper(c) {
      let ci = char_to_idx(c)
      let pi = m.cipher_to_plain[ci]
      if pi >= 0 {
        buf.write_char(idx_to_char(pi))
      } else {
        buf.write_char('_')
      }
    } else {
      buf.write_char(c)
    }
  }
  buf.to_string()
}

///|
pub fn check_solution(
  ciphertext : String,
  plaintext : String,
  m : Mapping,
) -> Bool {
  for i in 0..<ciphertext.length() {
    let c = str_char_at(ciphertext, i)
    if is_upper(c) {
      let ci = char_to_idx(c)
      let pi = m.cipher_to_plain[ci]
      if pi < 0 {
        return false
      }
      let expected = str_char_at(plaintext, i)
      if idx_to_char(pi) != expected {
        return false
      }
    }
  }
  true
}

///|
pub fn count_correct(
  ciphertext : String,
  plaintext : String,
  m : Mapping,
) -> Int {
  let mut count = 0
  let checked : Array[Bool] = Array(capacity=alphabet_size)
  for _i in 0..<alphabet_size {
    checked.push(false)
  }
  for i in 0..<ciphertext.length() {
    let c = str_char_at(ciphertext, i)
    if is_upper(c) {
      let ci = char_to_idx(c)
      if !checked[ci] {
        checked[ci] = true
        let pi = m.cipher_to_plain[ci]
        if pi >= 0 {
          let expected = str_char_at(plaintext, i)
          if idx_to_char(pi) == expected {
            count += 1
          }
        }
      }
    }
  }
  count
}

///|
pub fn count_unique_letters(text : String) -> Int {
  let seen : Array[Bool] = Array(capacity=alphabet_size)
  for _i in 0..<alphabet_size {
    seen.push(false)
  }
  let mut count = 0
  for i in 0..<text.length() {
    let c = str_char_at(text, i)
    if is_upper(c) {
      let idx = char_to_idx(c)
      if !seen[idx] {
        seen[idx] = true
        count += 1
      }
    }
  }
  count
}

///|
pub fn new_level_score() -> LevelScore {
  { completed: false, stars: 0, best_swaps: 9999, best_no_hints: false, }
}

///|
pub fn calc_stars(swap_count : Int, par_swaps : Int, hints_used : Int) -> Int {
  if hints_used == 0 && swap_count <= par_swaps {
    3
  } else if swap_count <= par_swaps {
    2
  } else {
    1
  }
}

///|
pub fn tier_name(t : Tier) -> String {
  match t {
    Recruit => "RECRUIT"
    Agent => "AGENT"
    Cryptographer => "CRYPTOGRAPHER"
  }
}

///|
pub fn tier_level_range(t : Tier) -> (Int, Int) {
  match t {
    Recruit => (0, 7)
    Agent => (8, 16)
    Cryptographer => (17, 24)
  }
}

///|
pub fn tier_for_level(level_id : Int) -> Tier {
  if level_id <= 7 {
    Recruit
  } else if level_id <= 16 {
    Agent
  } else {
    Cryptographer
  }
}

///|
pub fn new_game() -> Game {
  let scores : Array[LevelScore] = Array(capacity=25)
  for _i in 0..<25 {
    scores.push(new_level_score())
  }
  {
    screen: Title,
    selected_tier: Recruit,
    selected_level: 0,
    play_state: Solving,
    current_level: 0,
    mapping: new_mapping(),
    undo_stack: [],
    swap_count: 0,
    hints_used: 0,
    selected_cipher_letter: -1,
    active_tool: LetterSwap,
    frame_count: 0,
    scroll_offset: 0,
    message_flash_timer: 0.0,
    result_timer: 0.0,
    level_scores: scores,
    cached_patterns: [],
    patterns_dirty: true,
    selected_pattern_idx: -1,
  }
}

///|
pub fn reset_for_level(game : Game) -> Unit {
  clear_mapping(game.mapping)
  game.undo_stack = []
  game.swap_count = 0
  game.hints_used = 0
  game.selected_cipher_letter = -1
  game.active_tool = LetterSwap
  game.play_state = Solving
  game.scroll_offset = 0
  game.message_flash_timer = 0.0
  game.result_timer = 0.0
  game.cached_patterns = []
  game.patterns_dirty = true
  game.selected_pattern_idx = -1
}

///|
pub fn is_position_in_pattern(
  game : Game,
  text_pos : Int,
  ciphertext : String,
) -> Bool {
  if game.selected_pattern_idx < 0 ||
    game.selected_pattern_idx >= game.cached_patterns.length() {
    return false
  }
  let pat = game.cached_patterns[game.selected_pattern_idx]
  let pat_len = pat.pattern.length()
  // The pattern positions are in terms of the original ciphertext index
  // We need to check if text_pos falls within [pos, pos+pat_len) of any occurrence
  for p in pat.positions {
    // Count how many characters of the pattern we've seen up to text_pos
    // positions are in original text coordinates, so we need to span pat_len
    // cipher-letters from each start position
    let mut cipher_count = 0
    let mut end_pos = p
    while cipher_count < pat_len && end_pos < ciphertext.length() {
      let c = str_char_at(ciphertext, end_pos)
      if is_upper(c) {
        cipher_count = cipher_count + 1
      }
      if cipher_count < pat_len {
        end_pos = end_pos + 1
      }
    }
    if text_pos >= p && text_pos <= end_pos {
      return true
    }
  }
  false
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
pub fn mini(a : Int, b : Int) -> Int {
  if a < b {
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
  let pi : Float = 3.14159265
  let two_pi : Float = 6.28318530
  let mut x = a
  while x > pi {
    x = x - two_pi
  }
  while x < -pi {
    x = x + two_pi
  }
  let x2 = x * x
  let x3 = x2 * x
  let x5 = x3 * x2
  let x7 = x5 * x2
  x - x3 / 6.0 + x5 / 120.0 - x7 / 5040.0
}
