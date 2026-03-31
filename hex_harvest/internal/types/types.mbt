///|
pub(all) struct HexCoord {
  col : Int
  row : Int
} derive(Eq, Show)

///|
pub(all) struct HexTile {
  mut kind : TileKind
  mut height : Int
  mut watered : Bool
  mut crop : CropKind?
  mut crop_state : CropState
  mut crop_turns : Int
  mut has_channel : Bool
} derive(Show)

///|
pub(all) struct HexGrid {
  width : Int
  height : Int
  tiles : Array[Array[HexTile]]
} derive(Show)

///|
pub(all) struct WaterSource {
  col : Int
  row : Int
} derive(Show)

///|
pub(all) struct GoalPos {
  col : Int
  row : Int
} derive(Show)

///|
pub(all) struct Level {
  mut grid : HexGrid
  mut water_sources : Array[WaterSource]
  mut turn_budget : Int
  mut target_yield : Int
  mut goals : Array[GoalPos]
  mut par_turns : Int
  mut name : String
  mut world : Int
} derive(Show)

///|
pub(all) struct LevelScore {
  mut yield_collected : Int
  mut target_yield : Int
  mut turns_used : Int
  mut turn_budget : Int
  mut par_turns : Int
  mut goals_collected : Int
  mut total_goals : Int
  mut stars : Int
} derive(Show)

///|
pub(all) struct UndoState {
  mut tiles : Array[Array[HexTile]]
  mut turn : Int
  mut yield_collected : Int
  mut goals_collected : Int
} derive(Show)

///|
pub(all) struct Game {
  mut screen : Screen
  mut level : Level
  mut level_index : Int
  mut world_index : Int
  mut turn : Int
  mut yield_collected : Int
  mut goals_collected : Int
  mut selected_crop : CropKind
  mut place_mode : PlaceMode
  mut hover_col : Int
  mut hover_row : Int
  mut hover_valid : Bool
  mut score : LevelScore
  mut level_scores : Array[Array[LevelScore?]]
  mut message : String
  mut message_timer : Float
  mut frame_count : Int
  mut menu_selection : Int
  mut water_anim_timer : Float
  mut newly_watered : Array[HexCoord]
  mut newly_harvested : Array[HexCoord]
  mut harvest_anim_timer : Float
  mut undo_stack : Array[UndoState]
  mut level_complete : Bool
  mut fade_timer : Float
  mut rng : Int
} derive(Show)
