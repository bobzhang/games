///|
pub(all) struct FabricCell {
  state : CellState
  color_index : Int
} derive(Eq, Show)

///|
/// The target pattern the player must match
pub(all) struct FabricPattern {
  rows : Int
  cols : Int
  cells : Array[FabricCell]
  warp_colors : Array[Int]
  weft_colors : Array[Int]
} derive(Show)

///|
/// A single heddle row configuration: which warps are raised
pub(all) struct HeddleRow {
  mut raised : Array[Bool]
} derive(Show)

///|
pub(all) struct Level {
  target : FabricPattern
  warp_colors : Array[Int]
  weft_colors : Array[Int]
  par_changes : Int
  weave_type : WeaveType
  tier : Tier
  level_num : Int
  hint : String
} derive(Show)

///|
pub(all) struct LevelScore {
  mut stars : Int
  mut completed : Bool
  mut best_changes : Int
} derive(Show)

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_level : Int
  mut current_tier : Tier
  mut heddles : Array[HeddleRow]
  mut warp_colors : Array[Int]
  mut weft_colors : Array[Int]
  mut target : FabricPattern
  mut level_scores : Array[LevelScore]
  mut heddle_changes : Int
  mut selected_row : Int
  mut message : String
  mut message_timer : Float
  mut frame_count : Int
  mut anim_timer : Float
  mut tier_select_index : Int
  mut show_comparison : Bool
  mut weave_type_guess : WeaveType
  mut has_guessed_type : Bool
  mut show_hint : Bool
}
