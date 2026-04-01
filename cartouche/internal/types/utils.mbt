///|
pub fn sinf(a : Float) -> Float {
  Float::from_double(@math.sin(a.to_double()))
}

///|
pub fn cosf(a : Float) -> Float {
  Float::from_double(@math.cos(a.to_double()))
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

// Symbol utilities

///|
pub fn symbol_index(s : Symbol) -> Int {
  match s {
    Circle => 0
    Triangle => 1
    Square => 2
    Diamond => 3
    Star => 4
    Cross => 5
    Arrow => 6
    Wave => 7
    Spiral => 8
    Dot => 9
    Crescent => 10
    Lightning => 11
    Eye => 12
    Hand => 13
    Sun => 14
    MoonSym => 15
    Mountain => 16
    River => 17
    Tree => 18
    Flame => 19
  }
}

///|
pub fn symbol_from_index(i : Int) -> Symbol {
  match i {
    0 => Circle
    1 => Triangle
    2 => Square
    3 => Diamond
    4 => Star
    5 => Cross
    6 => Arrow
    7 => Wave
    8 => Spiral
    9 => Dot
    10 => Crescent
    11 => Lightning
    12 => Eye
    13 => Hand
    14 => Sun
    15 => MoonSym
    16 => Mountain
    17 => River
    18 => Tree
    _ => Flame
  }
}

///|
pub fn all_symbols() -> Array[Symbol] {
  [
    Circle, Triangle, Square, Diamond, Star, Cross, Arrow, Wave, Spiral, Dot,
    Crescent, Lightning, Eye, Hand, Sun, MoonSym, Mountain, River, Tree, Flame,
  ]
}

///|
pub fn letter_from_index(i : Int) -> String {
  match i {
    0 => "A"
    1 => "B"
    2 => "C"
    3 => "D"
    4 => "E"
    5 => "F"
    6 => "G"
    7 => "H"
    8 => "I"
    9 => "J"
    10 => "K"
    11 => "L"
    12 => "M"
    13 => "N"
    14 => "O"
    15 => "P"
    16 => "Q"
    17 => "R"
    18 => "S"
    19 => "T"
    _ => "?"
  }
}

///|
pub fn letter_index(ch : String) -> Int {
  match ch {
    "A" => 0
    "B" => 1
    "C" => 2
    "D" => 3
    "E" => 4
    "F" => 5
    "G" => 6
    "H" => 7
    "I" => 8
    "J" => 9
    "K" => 10
    "L" => 11
    "M" => 12
    "N" => 13
    "O" => 14
    "P" => 15
    "Q" => 16
    "R" => 17
    "S" => 18
    "T" => 19
    _ => -1
  }
}

// Mapping operations

///|
pub fn new_mapping() -> Mapping {
  let values : Array[Int] = Array::make(symbol_count, -1)
  { values, }
}

///|
pub fn copy_mapping(m : Mapping) -> Mapping {
  let values : Array[Int] = Array::make(symbol_count, -1)
  for i in 0..<symbol_count {
    values[i] = m.values[i]
  }
  { values, }
}

///|
pub fn mapping_set(m : Mapping, sym : Symbol, letter_idx : Int) -> Unit {
  m.values[symbol_index(sym)] = letter_idx
}

///|
pub fn mapping_get(m : Mapping, sym : Symbol) -> Int {
  m.values[symbol_index(sym)]
}

///|
pub fn mapping_clear(m : Mapping, sym : Symbol) -> Unit {
  m.values[symbol_index(sym)] = -1
}

///|
pub fn is_letter_used(m : Mapping, letter_idx : Int) -> Bool {
  for i in 0..<symbol_count {
    if m.values[i] == letter_idx {
      return true
    }
  }
  false
}

///|
pub fn find_symbol_for_letter(m : Mapping, letter_idx : Int) -> Int {
  for i in 0..<symbol_count {
    if m.values[i] == letter_idx {
      return i
    }
  }
  -1
}

// Inscription operations

///|
pub fn new_inscription(symbols : Array[InscriptionSymbol]) -> Inscription {
  { symbols, }
}

///|
pub fn make_symbol(s : Symbol) -> InscriptionSymbol {
  { symbol: Some(s) }
}

///|
pub fn make_space() -> InscriptionSymbol {
  { symbol: None }
}

///|
pub fn decode_inscription(
  inscription : Inscription,
  mapping : Mapping
) -> String {
  let mut result = ""
  for i in 0..<inscription.symbols.length() {
    match inscription.symbols[i].symbol {
      None => result = result + " "
      Some(sym) => {
        let letter_idx = mapping_get(mapping, sym)
        if letter_idx >= 0 {
          result = result + letter_from_index(letter_idx)
        } else {
          result = result + "_"
        }
      }
    }
  }
  result
}

///|
pub fn get_inscription_symbols_unique(inscription : Inscription) -> Array[Symbol] {
  let result : Array[Symbol] = []
  for i in 0..<inscription.symbols.length() {
    match inscription.symbols[i].symbol {
      None => ()
      Some(sym) => {
        let mut found = false
        for j in 0..<result.length() {
          if result[j] == sym {
            found = true
            break
          }
        }
        if !found {
          result.push(sym)
        }
      }
    }
  }
  result
}

// Tablet score

///|
pub fn new_tablet_score() -> TabletScore {
  { solved: false, stars: 0, guesses_used: 0, wrong_count: 0 }
}

// New game

///|
pub fn new_game() -> Game {
  let scores : Array[TabletScore] = []
  for _i in 0..<total_tablets {
    scores.push(new_tablet_score())
  }
  {
    screen: Title,
    play_state: Decoding,
    current_tier: Fragments,
    current_tablet_index: 0,
    current_mapping: new_mapping(),
    guesses: 0,
    wrong_count: 0,
    selected_symbol: None,
    undo_stack: [],
    scores,
    message: "",
    message_timer: 0.0,
    frame_count: 0,
    anim_timer: 0.0,
    hint_symbol: None,
    hint_timer: 0.0,
  }
}

///|
pub fn set_message(game : Game, msg : String, duration : Float) -> Unit {
  game.message = msg
  game.message_timer = duration
}

///|
pub fn tier_name(tier : Tier) -> String {
  match tier {
    Fragments => "Fragments"
    Scrolls => "Scrolls"
    Monuments => "Monuments"
  }
}

///|
pub fn tier_color(tier : Tier) -> @raylib.Color {
  match tier {
    Fragments => color_tier1
    Scrolls => color_tier2
    Monuments => color_tier3
  }
}

///|
pub fn tier_tablet_offset(tier : Tier) -> Int {
  match tier {
    Fragments => 0
    Scrolls => tier1_count
    Monuments => tier1_count + tier2_count
  }
}

///|
pub fn tier_tablet_count(tier : Tier) -> Int {
  match tier {
    Fragments => tier1_count
    Scrolls => tier2_count
    Monuments => tier3_count
  }
}

///|
pub fn total_stars_for_tier(game : Game, tier : Tier) -> Int {
  let offset = tier_tablet_offset(tier)
  let count = tier_tablet_count(tier)
  let mut total = 0
  for i in offset..<(offset + count) {
    total = total + game.scores[i].stars
  }
  total
}

///|
pub fn total_stars(game : Game) -> Int {
  let mut total = 0
  for i in 0..<total_tablets {
    total = total + game.scores[i].stars
  }
  total
}

///|
pub fn is_given_symbol(tablet : Tablet, sym : Symbol) -> Bool {
  mapping_get(tablet.given_mapping, sym) >= 0
}
