///|
#derive(Eq, Debug)
pub(all) struct HexCoord {
  row : Int32
  col : Int32
}

///|
pub extend HexCoord with Eq::{not_equal, equal}

///|
pub extend HexCoord with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct HexBoard {
  size : Int32
  cells : Array[Array[CellState]]
}

///|
pub extend HexBoard with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct Pattern {
  kind : PatternKind
  positions : Array[HexCoord]
  points : Int32
}

///|
pub extend Pattern with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct Move {
  pos : HexCoord
  player : Player
}

///|
pub extend Move with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct PuzzleLevel {
  id : Int32
  board : HexBoard
  current_player : Player
  target_score : Int32
  hint : String
}

///|
pub extend PuzzleLevel with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct CaptureAnim {
  mut pos : HexCoord
  mut timer : Float
}

///|
pub extend CaptureAnim with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct PatternAnim {
  mut kind : PatternKind
  mut positions : Array[HexCoord]
  mut timer : Float
}

///|
pub extend PatternAnim with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct ScoreAnim {
  mut x : Float
  mut y : Float
  mut text : String
  mut timer : Float
}

///|
pub extend ScoreAnim with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut mode : GameMode
  mut difficulty : Difficulty
  mut play_state : PlayState
  board : HexBoard
  mut current_player : Player
  mut black_score : Int32
  mut white_score : Int32
  mut black_captures : Int32
  mut white_captures : Int32
  mut patterns_found : Array[Pattern]
  mut last_move : HexCoord?
  mut move_count : Int32
  mut black_passed : Bool
  mut white_passed : Bool
  mut frame_count : Int32
  mut ai_delay : Float
  mut capture_anims : Array[CaptureAnim]
  mut pattern_anims : Array[PatternAnim]
  mut score_anims : Array[ScoreAnim]
  mut hover_hex : HexCoord?
  mut puzzle_levels : Array[PuzzleLevel]
  mut current_puzzle : Int32
  mut puzzle_score : Int32
  mut puzzle_solved : Bool
  mut menu_selection : Int32
  mut winner : Player?
  mut result_message : String
}
