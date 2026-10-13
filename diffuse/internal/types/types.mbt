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
  width : Int32
  height : Int32
  tiles : Array[Tile]
} derive(Debug)

///|
pub extend Grid with Debug::{to_repr}

///|
pub(all) struct InkBudget {
  mut cyan : Int32
  mut magenta : Int32
  mut yellow : Int32
} derive(Debug)

///|
pub extend InkBudget with Debug::{to_repr}

///|
pub(all) struct Level {
  grid : Grid
  budget : InkBudget
  par_drops : Int32
  tier : Tier
  name : String
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : StarRating
  mut drops_used : Int32
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct HistoryEntry {
  tiles : Array[Tile]
  budget : InkBudget
  drops_used : Int32
} derive(Debug)

///|
pub extend HistoryEntry with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut selected_tier : Tier
  mut selected_level : Int32
  mut grid : Grid
  mut budget : InkBudget
  mut par_drops : Int32
  mut drops_used : Int32
  mut turn : Int32
  mut selected_channel : InkChannel
  mut play_state : PlayState
  mut level_name : String
  scores : Array[LevelScore]
  history : Array[HistoryEntry]
  mut hover_col : Int32
  mut hover_row : Int32
  mut frame_count : Int32
  mut spread_timer : Float
  mut show_preview : Bool
} derive(Debug)

///|
pub extend Game with Debug::{to_repr}
