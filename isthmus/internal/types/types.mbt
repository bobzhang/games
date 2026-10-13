///|
pub(all) struct Tile {
  mut height : Int32
  mut is_settlement : Bool
  mut is_sand : Bool
} derive(Eq, Debug)

///|
pub extend Tile with Eq::{not_equal, equal}

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
pub(all) struct Level {
  grid_width : Int32
  grid_height : Int32
  heights : Array[Int32]
  settlements : Array[Int32]
  max_sea_level : Int32
  sand_budget : Int32
  par_sand : Int32
  name : String
  tier : Tier
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : Int32
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct GridSnapshot {
  tiles : Array[Tile]
  sea_level : Int32
  sand_remaining : Int32
} derive(Debug)

///|
pub extend GridSnapshot with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut grid : Grid
  mut sea_level : Int32
  mut max_sea_level : Int32
  mut sand_remaining : Int32
  mut turn : Int32
  mut selected_tier : Tier
  mut selected_level : Int32
  mut level_scores : Array[LevelScore]
  mut history : Array[GridSnapshot]
  mut never_disconnected : Bool
  mut message : String
  mut message_timer : Float
  mut frame_count : Int32
  mut anim_timer : Float
  mut hover_x : Int32
  mut hover_y : Int32
  mut rising_anim : Float
  mut show_flood_preview : Bool
} derive(Debug)

///|
pub extend Game with Debug::{to_repr}
