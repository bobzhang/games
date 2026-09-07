///|
pub(all) struct Vec2i {
  x : Int
  y : Int
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
  mut max_slots : Int
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
  mut width : Int
  mut height : Int
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
  world : Int
  index : Int
  name : String
  ascii : Array[String]
  start_x : Int
  start_y : Int
  start_dir : Direction
  par : Int
  optimal : Int
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
  mut cmd_index : Int
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
  mut best_instructions : Int
  mut medal : Medal
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct EditorState {
  mut cursor : Int
  mut palette_cursor : Int
  mut palette_open : Bool
  mut palette_commands : Array[CommandKind]
  mut loop_count : Int
  mut condition_index : Int
} derive(Debug)

///|
pub extend EditorState with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut current_world : Int
  mut current_level : Int
  mut level : Level?
  mut level_def : LevelDef?
  mut program : Program
  mut editor : EditorState
  mut run_state : RunState
  mut trace : ExecutionTrace?
  mut trace_step : Int
  mut trace_timer : Float
  mut run_speed : Int
  mut scores : Array[Array[LevelScore]]
  mut frame_count : Int
  mut message : String
  mut message_timer : Float
  mut title_anim : Float
  mut total_stars : Int
} derive(Debug)

///|
pub extend Game with Debug::{to_repr}
