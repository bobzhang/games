///|
#derive(Eq, Debug)
pub(all) struct FabricCell {
  state : CellState
  color_index : Int32
}

///|
pub extend FabricCell with Eq::{not_equal, equal}

///|
pub extend FabricCell with Debug::{to_repr}

///|
/// The target pattern the player must match
#derive(Debug)
pub(all) struct FabricPattern {
  rows : Int32
  cols : Int32
  cells : Array[FabricCell]
  warp_colors : Array[Int32]
  weft_colors : Array[Int32]
}

///|
pub extend FabricPattern with Debug::{to_repr}

///|
/// A single heddle row configuration: which warps are raised
#derive(Debug)
pub(all) struct HeddleRow {
  mut raised : Array[Bool]
}

///|
pub extend HeddleRow with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct Level {
  target : FabricPattern
  warp_colors : Array[Int32]
  weft_colors : Array[Int32]
  par_changes : Int32
  weave_type : WeaveType
  tier : Tier
  level_num : Int32
  hint : String
}

///|
pub extend Level with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct LevelScore {
  mut stars : Int32
  mut completed : Bool
  mut best_changes : Int32
}

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_level : Int32
  mut current_tier : Tier
  mut heddles : Array[HeddleRow]
  mut warp_colors : Array[Int32]
  mut weft_colors : Array[Int32]
  mut target : FabricPattern
  mut level_scores : Array[LevelScore]
  mut heddle_changes : Int32
  mut selected_row : Int32
  mut message : String
  mut message_timer : Float
  mut frame_count : Int32
  mut anim_timer : Float
  mut tier_select_index : Int32
  mut show_comparison : Bool
  mut weave_type_guess : WeaveType
  mut has_guessed_type : Bool
  mut show_hint : Bool
}
