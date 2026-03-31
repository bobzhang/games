///|
pub(all) struct InkColor {
  mut c : Bool
  mut m : Bool
  mut y : Bool
} derive(Eq, Show)

///|
pub(all) struct Tile {
  mut kind : TileKind
  mut ink : InkColor
  mut target_color : InkColor
} derive(Show)

///|
pub(all) struct Grid {
  width : Int
  height : Int
  tiles : Array[Tile]
} derive(Show)

///|
pub(all) struct InkBudget {
  mut cyan : Int
  mut magenta : Int
  mut yellow : Int
} derive(Show)

///|
pub(all) struct Level {
  grid : Grid
  budget : InkBudget
  par_drops : Int
  tier : Tier
  name : String
} derive(Show)

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : StarRating
  mut drops_used : Int
} derive(Show)

///|
pub(all) struct HistoryEntry {
  tiles : Array[Tile]
  budget : InkBudget
  drops_used : Int
} derive(Show)

///|
pub(all) struct Game {
  mut screen : Screen
  mut selected_tier : Tier
  mut selected_level : Int
  mut grid : Grid
  mut budget : InkBudget
  mut par_drops : Int
  mut drops_used : Int
  mut turn : Int
  mut selected_channel : InkChannel
  mut play_state : PlayState
  mut level_name : String
  scores : Array[LevelScore]
  history : Array[HistoryEntry]
  mut hover_col : Int
  mut hover_row : Int
  mut frame_count : Int
  mut spread_timer : Float
  mut show_preview : Bool
} derive(Show)
