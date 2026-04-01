///|
pub(all) struct Tile {
  mut height : Int
  mut is_settlement : Bool
  mut is_sand : Bool
} derive(Eq, Show)

///|
pub(all) struct Grid {
  width : Int
  height : Int
  tiles : Array[Tile]
} derive(Show)

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
} derive(Show)

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : Int
} derive(Show)

///|
pub(all) struct GridSnapshot {
  tiles : Array[Tile]
  sea_level : Int
  sand_remaining : Int
} derive(Show)

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
} derive(Show)
