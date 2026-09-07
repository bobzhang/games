///|
pub(all) struct Tile {
  mut height : Int
  mut is_settlement : Bool
  mut is_sand : Bool
} derive(Eq, Debug)

///|
pub extend Tile with Eq::{not_equal, equal}

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
pub(all) struct Level {
  grid_width : Int
  grid_height : Int
  heights : Array[Int]
  settlements : Array[Int]
  max_sea_level : Int
  sand_budget : Int
  par_sand : Int
  name : String
  tier : Tier
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : Int
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct GridSnapshot {
  tiles : Array[Tile]
  sea_level : Int
  sand_remaining : Int
} derive(Debug)

///|
pub extend GridSnapshot with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut grid : Grid
  mut sea_level : Int
  mut max_sea_level : Int
  mut sand_remaining : Int
  mut turn : Int
  mut selected_tier : Tier
  mut selected_level : Int
  mut level_scores : Array[LevelScore]
  mut history : Array[GridSnapshot]
  mut never_disconnected : Bool
  mut message : String
  mut message_timer : Float
  mut frame_count : Int
  mut anim_timer : Float
  mut hover_x : Int
  mut hover_y : Int
  mut rising_anim : Float
  mut show_flood_preview : Bool
} derive(Debug)

///|
pub extend Game with Debug::{to_repr}
