///|
pub(all) struct Mapping {
  cipher_to_plain : Array[Int32] // 26 elements, -1 = unmapped
  plain_used : Array[Bool] // 26 elements, tracks which plain letters are assigned
} derive(Debug)

///|
pub extend Mapping with Debug::{to_repr}

///|
pub(all) struct UndoEntry {
  cipher_idx : Int32 // cipher letter index (0-25)
  old_plain : Int32 // previous mapping value (-1 or 0-25)
  old_displaced_cipher : Int32 // if we displaced another mapping, which cipher letter (-1 if none)
  old_displaced_plain : Int32 // and what was its old plain value
} derive(Debug)

///|
pub extend UndoEntry with Debug::{to_repr}

///|
pub(all) struct Level {
  id : Int32
  tier : Tier
  cipher_kind : CipherKind
  plaintext : String
  ciphertext : String
  key_info : String // e.g. "shift=3" or "key=LEMON"
  par_swaps : Int32
  hint_text : String
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : Int32
  mut best_swaps : Int32
  mut best_no_hints : Bool
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct PatternMatch {
  pattern : String
  positions : Array[Int32]
  count : Int32
} derive(Debug)

///|
pub extend PatternMatch with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut selected_tier : Tier
  mut selected_level : Int32
  mut play_state : PlayState
  // Current level data
  mut current_level : Int32
  mapping : Mapping
  mut undo_stack : Array[UndoEntry]
  mut swap_count : Int32
  mut hints_used : Int32
  mut selected_cipher_letter : Int32 // -1 = none, 0-25 = A-Z
  mut active_tool : Tool
  // Scroll and animation
  mut frame_count : Int32
  mut scroll_offset : Int32
  mut message_flash_timer : Float
  mut result_timer : Float
  // Level scores
  level_scores : Array[LevelScore]
  // Pattern cache
  mut cached_patterns : Array[PatternMatch]
  mut patterns_dirty : Bool
  // Selected pattern for highlighting
  mut selected_pattern_idx : Int32 // -1 = none
} derive(Debug)

///|
pub extend Game with Debug::{to_repr}
