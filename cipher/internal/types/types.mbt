///|
pub(all) struct Mapping {
  cipher_to_plain : Array[Int] // 26 elements, -1 = unmapped
  plain_used : Array[Bool] // 26 elements, tracks which plain letters are assigned
} derive(Show)

///|
pub(all) struct UndoEntry {
  cipher_idx : Int // cipher letter index (0-25)
  old_plain : Int // previous mapping value (-1 or 0-25)
  old_displaced_cipher : Int // if we displaced another mapping, which cipher letter (-1 if none)
  old_displaced_plain : Int // and what was its old plain value
} derive(Show)

///|
pub(all) struct Level {
  id : Int
  tier : Tier
  cipher_kind : CipherKind
  plaintext : String
  ciphertext : String
  key_info : String // e.g. "shift=3" or "key=LEMON"
  par_swaps : Int
  hint_text : String
} derive(Show)

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : Int
  mut best_swaps : Int
  mut best_no_hints : Bool
} derive(Show)

///|
pub(all) struct PatternMatch {
  pattern : String
  positions : Array[Int]
  count : Int
} derive(Show)

///|
pub(all) struct Game {
  mut screen : Screen
  mut selected_tier : Tier
  mut selected_level : Int
  mut play_state : PlayState
  // Current level data
  mut current_level : Int
  mapping : Mapping
  mut undo_stack : Array[UndoEntry]
  mut swap_count : Int
  mut hints_used : Int
  mut selected_cipher_letter : Int // -1 = none, 0-25 = A-Z
  mut active_tool : Tool
  // Scroll and animation
  mut frame_count : Int
  mut scroll_offset : Int
  mut message_flash_timer : Float
  mut result_timer : Float
  // Level scores
  level_scores : Array[LevelScore]
  // Pattern cache
  mut cached_patterns : Array[PatternMatch]
  mut patterns_dirty : Bool
  // Selected pattern for highlighting
  mut selected_pattern_idx : Int // -1 = none
} derive(Show)
