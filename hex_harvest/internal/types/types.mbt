///|
pub(all) struct HexCoord {
  col : Int32
  row : Int32
} derive(Eq, Debug)

///|
pub extend HexCoord with Eq::{not_equal, equal}

///|
pub extend HexCoord with Debug::{to_repr}

///|
pub(all) struct HexTile {
  mut kind : TileKind
  mut height : Int32
  mut watered : Bool
  mut crop : CropKind?
  mut crop_state : CropState
  mut crop_turns : Int32
  mut has_channel : Bool
} derive(Debug)

///|
pub extend HexTile with Debug::{to_repr}

///|
pub(all) struct HexGrid {
  width : Int32
  height : Int32
  tiles : Array[Array[HexTile]]
} derive(Debug)

///|
pub extend HexGrid with Debug::{to_repr}

///|
pub(all) struct WaterSource {
  col : Int32
  row : Int32
} derive(Debug)

///|
pub extend WaterSource with Debug::{to_repr}

///|
pub(all) struct GoalPos {
  col : Int32
  row : Int32
} derive(Debug)

///|
pub extend GoalPos with Debug::{to_repr}

///|
pub(all) struct Level {
  mut grid : HexGrid
  mut water_sources : Array[WaterSource]
  mut turn_budget : Int32
  mut target_yield : Int32
  mut goals : Array[GoalPos]
  mut par_turns : Int32
  mut name : String
  mut world : Int32
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut yield_collected : Int32
  mut target_yield : Int32
  mut turns_used : Int32
  mut turn_budget : Int32
  mut par_turns : Int32
  mut goals_collected : Int32
  mut total_goals : Int32
  mut stars : Int32
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct UndoState {
  mut tiles : Array[Array[HexTile]]
  mut turn : Int32
  mut yield_collected : Int32
  mut goals_collected : Int32
} derive(Debug)

///|
pub extend UndoState with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut level : Level
  mut level_index : Int32
  mut world_index : Int32
  mut turn : Int32
  mut yield_collected : Int32
  mut goals_collected : Int32
  mut selected_crop : CropKind
  mut place_mode : PlaceMode
  mut hover_col : Int32
  mut hover_row : Int32
  mut hover_valid : Bool
  mut score : LevelScore
  mut level_scores : Array[Array[LevelScore?]]
  mut message : String
  mut message_timer : Float
  mut frame_count : Int32
  mut menu_selection : Int32
  mut water_anim_timer : Float
  mut newly_watered : Array[HexCoord]
  mut newly_harvested : Array[HexCoord]
  mut harvest_anim_timer : Float
  mut undo_stack : Array[UndoState]
  mut level_complete : Bool
  mut fade_timer : Float
  mut rng : Int32
  mut turn_phase : TurnPhase
  mut phase_timer : Float
  mut click_feedback_timer : Float
  mut click_feedback_col : Int32
  mut click_feedback_row : Int32
} derive(Debug)

///|
pub extend Game with Debug::{to_repr}
