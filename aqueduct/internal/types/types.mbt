///|
pub(all) struct Pos {
  x : Int
  y : Int
} derive(Eq, Show, Hash, Compare)

///|
pub(all) struct Tile {
  mut kind : TileKind
  elevation : Int
  mut has_water : Bool
  mut water_level : Int
  mut connections : Array[Direction]
} derive(Show)

///|
pub(all) struct Level {
  name : String
  tier : Tier
  grid_cols : Int
  grid_rows : Int
  elevations : Array[Int]
  springs : Array[Pos]
  fountains : Array[Pos]
  reservoirs : Array[Pos]
  dams : Array[(Pos, Direction)]
  par_segments : Int
} derive(Show)

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : Int
  mut segments_used : Int
} derive(Show)

///|
pub(all) struct UndoEntry {
  pos : Pos
  prev_kind : TileKind
  prev_connections : Array[Direction]
} derive(Show)

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_tier : Tier
  mut current_level : Int
  mut hover_cell : Pos?
  mut selected_tool : TileKind
  levels : Array[Level]
  scores : Array[LevelScore]
  mut grid : Array[Tile]
  mut segments_placed : Int
  mut undo_stack : Array[UndoEntry]
  mut frame_count : Int
  mut message : String
  mut message_timer : Float
  mut sim_timer : Float
  mut sim_step : Int
  mut fountains_filled : Int
  mut total_fountains : Int
  mut anim_timer : Float
  mut water_sources : Array[Pos]
} derive(Show)
