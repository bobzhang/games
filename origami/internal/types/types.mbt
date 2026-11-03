///|
#derive(Eq, Debug)
pub(all) struct Vec2i {
  x : Int32
  y : Int32
}

///|
pub extend Vec2i with Eq::{not_equal, equal}

///|
pub extend Vec2i with Debug::{to_repr}

///|
#derive(Eq, Debug)
pub(all) struct PaperCell {
  mut has_paper : Bool
  mut layers : Int32
}

///|
pub extend PaperCell with Eq::{not_equal, equal}

///|
pub extend PaperCell with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct Paper {
  width : Int32
  height : Int32
  cells : Array[PaperCell]
}

///|
pub extend Paper with Debug::{to_repr}

///|
#derive(Eq, Debug)
pub(all) struct LayerCheck {
  pos : Vec2i
  required_layers : Int32
}

///|
pub extend LayerCheck with Eq::{not_equal, equal}

///|
pub extend LayerCheck with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct Level {
  initial_paper : Paper
  target_silhouette : Paper
  layer_checks : Array[LayerCheck]
  par_folds : Int32
  tier : Tier
  name : String
}

///|
pub extend Level with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : StarRating
  mut folds_used : Int32
}

///|
pub extend LevelScore with Debug::{to_repr}

///|
#derive(Debug)
pub(all) struct FoldAction {
  dir : FoldDir
  line_pos : Int32
  paper_before : Paper
}

///|
pub extend FoldAction with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut current_paper : Paper
  mut fold_history : Array[FoldAction]
  mut target : Level
  mut current_tier : Tier
  mut current_level_index : Int32
  mut fold_dir : FoldDir
  mut fold_line : Int32
  mut play_state : PlayState
  mut anim_timer : Float
  mut scores : Array[LevelScore]
  mut frame_count : Int32
  mut message : String
  mut message_timer : Float
  mut hover_button : Int32
  mut show_target : Bool
}
