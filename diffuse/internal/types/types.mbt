///|
pub(all) struct InkColor {
  mut c : Bool
  mut m : Bool
  mut y : Bool
} derive(Eq, Debug)

///|
pub extend InkColor with Eq::{not_equal, equal}

///|
pub extend InkColor with Debug::{to_repr}

///|
pub(all) struct Tile {
  mut kind : TileKind
  mut ink : InkColor
  mut target_color : InkColor
} derive(Debug)

///|
pub extend Tile with Debug::{to_repr}

///|
pub(all) struct Grid {
  width : Int
  height : Int
  tiles : Array[Tile]
} derive(Debug)

///|
pub extend Grid with Debug::{to_repr}

///|
pub(all) struct InkBudget {
  mut cyan : Int
  mut magenta : Int
  mut yellow : Int
} derive(Debug)

///|
pub extend InkBudget with Debug::{to_repr}

///|
pub(all) struct Level {
  grid : Grid
  budget : InkBudget
  par_drops : Int
  tier : Tier
  name : String
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : StarRating
  mut drops_used : Int
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct HistoryEntry {
  tiles : Array[Tile]
  budget : InkBudget
  drops_used : Int
} derive(Debug)

///|
pub extend HistoryEntry with Debug::{to_repr}

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
} derive(Debug)

///|
pub extend Game with Debug::{to_repr}
