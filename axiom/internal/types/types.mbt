///|
pub(all) struct Vec2i {
  x : Int32
  y : Int32
} derive(Eq, Debug)

///|
pub extend Vec2i with Eq::{not_equal, equal}

///|
pub extend Vec2i with Debug::{to_repr}

///|
pub(all) struct Robot {
  mut pos : Vec2i
  mut dir : Direction
  mut alive : Bool
} derive(Debug)

///|
pub extend Robot with Debug::{to_repr}

///|
pub(all) struct Command {
  mut kind : CommandKind
} derive(Debug)

///|
pub extend Command with Debug::{to_repr}

///|
pub(all) struct Program {
  mut commands : Array[Command]
  mut max_slots : Int32
} derive(Debug)

///|
pub extend Program with Debug::{to_repr}

///|
pub(all) struct Tile {
  mut kind : TileKind
} derive(Debug)

///|
pub extend Tile with Debug::{to_repr}

///|
pub(all) struct Grid {
  mut tiles : Array[Array[Tile]]
  mut width : Int32
  mut height : Int32
} derive(Debug)

///|
pub extend Grid with Debug::{to_repr}

///|
pub(all) struct Level {
  mut grid : Grid
  mut robot : Robot
  mut goals : Array[Vec2i]
  mut goals_collected : Array[Bool]
  mut blocks : Array[Vec2i]
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelDef {
  world : Int32
  index : Int32
  name : String
  ascii : Array[String]
  start_x : Int32
  start_y : Int32
  start_dir : Direction
  par : Int32
  optimal : Int32
  hint : String
  available_commands : Array[CommandKind]
} derive(Debug)

///|
pub extend LevelDef with Debug::{to_repr}

///|
pub(all) struct RobotState {
  mut pos : Vec2i
  mut dir : Direction
  mut alive : Bool
  mut goals_collected : Array[Bool]
  mut blocks : Array[Vec2i]
  mut cmd_index : Int32
} derive(Debug)

///|
pub extend RobotState with Debug::{to_repr}

///|
pub(all) struct ExecutionTrace {
  mut states : Array[RobotState]
  mut success : Bool
  mut fail_reason : String
} derive(Debug)

///|
pub extend ExecutionTrace with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut best_instructions : Int32
  mut medal : Medal
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct EditorState {
  mut cursor : Int32
  mut palette_cursor : Int32
  mut palette_open : Bool
  mut palette_commands : Array[CommandKind]
  mut loop_count : Int32
  mut condition_index : Int32
} derive(Debug)

///|
pub extend EditorState with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut current_world : Int32
  mut current_level : Int32
  mut level : Level?
  mut level_def : LevelDef?
  mut program : Program
  mut editor : EditorState
  mut run_state : RunState
  mut trace : ExecutionTrace?
  mut trace_step : Int32
  mut trace_timer : Float
  mut run_speed : Int32
  mut scores : Array[Array[LevelScore]]
  mut frame_count : Int32
  mut message : String
  mut message_timer : Float
  mut title_anim : Float
  mut total_stars : Int32
} derive(Debug)

///|
pub extend Game with Debug::{to_repr}
