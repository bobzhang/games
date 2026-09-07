///|
pub(all) struct Vec2i {
  x : Int
  y : Int
} derive(Eq, Debug)

///|
pub extend Vec2i with Eq::{not_equal, equal}

///|
pub extend Vec2i with Debug::{to_repr}

///|
pub(all) struct PaperCell {
  mut has_paper : Bool
  mut layers : Int
} derive(Eq, Debug)

///|
pub extend PaperCell with Eq::{not_equal, equal}

///|
pub extend PaperCell with Debug::{to_repr}

///|
pub(all) struct Paper {
  width : Int
  height : Int
  cells : Array[PaperCell]
} derive(Debug)

///|
pub extend Paper with Debug::{to_repr}

///|
pub(all) struct LayerCheck {
  pos : Vec2i
  required_layers : Int
} derive(Eq, Debug)

///|
pub extend LayerCheck with Eq::{not_equal, equal}

///|
pub extend LayerCheck with Debug::{to_repr}

///|
pub(all) struct Level {
  initial_paper : Paper
  target_silhouette : Paper
  layer_checks : Array[LayerCheck]
  par_folds : Int
  tier : Tier
  name : String
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : StarRating
  mut folds_used : Int
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct FoldAction {
  dir : FoldDir
  line_pos : Int
  paper_before : Paper
} derive(Debug)

///|
pub extend FoldAction with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut current_paper : Paper
  mut fold_history : Array[FoldAction]
  mut target : Level
  mut current_tier : Tier
  mut current_level_index : Int
  mut fold_dir : FoldDir
  mut fold_line : Int
  mut play_state : PlayState
  mut anim_timer : Float
  mut scores : Array[LevelScore]
  mut frame_count : Int
  mut message : String
  mut message_timer : Float
  mut hover_button : Int
  mut show_target : Bool
}
