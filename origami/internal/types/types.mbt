///|
pub(all) struct Vec2i {
  x : Int
  y : Int
} derive(Eq, Show)

///|
pub(all) struct PaperCell {
  mut has_paper : Bool
  mut layers : Int
} derive(Eq, Show)

///|
pub(all) struct Paper {
  width : Int
  height : Int
  cells : Array[PaperCell]
} derive(Show)

///|
pub(all) struct LayerCheck {
  pos : Vec2i
  required_layers : Int
} derive(Eq, Show)

///|
pub(all) struct Level {
  initial_paper : Paper
  target_silhouette : Paper
  layer_checks : Array[LayerCheck]
  par_folds : Int
  tier : Tier
  name : String
} derive(Show)

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : StarRating
  mut folds_used : Int
} derive(Show)

///|
pub(all) struct FoldAction {
  dir : FoldDir
  line_pos : Int
  paper_before : Paper
} derive(Show)

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
