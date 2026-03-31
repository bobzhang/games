///|
pub(all) struct Vec2i {
  x : Int
  y : Int
} derive(Eq, Show)

///|
pub(all) struct Robot {
  mut pos : Vec2i
  mut dir : Direction
  mut alive : Bool
} derive(Show)

///|
pub(all) struct Command {
  mut kind : CommandKind
} derive(Show)

///|
pub(all) struct Program {
  mut commands : Array[Command]
  mut max_slots : Int
} derive(Show)

///|
pub(all) struct Tile {
  mut kind : TileKind
} derive(Show)

///|
pub(all) struct Grid {
  mut tiles : Array[Array[Tile]]
  mut width : Int
  mut height : Int
} derive(Show)

///|
pub(all) struct Level {
  mut grid : Grid
  mut robot : Robot
  mut goals : Array[Vec2i]
  mut goals_collected : Array[Bool]
  mut blocks : Array[Vec2i]
} derive(Show)

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
} derive(Show)

///|
pub(all) struct RobotState {
  mut pos : Vec2i
  mut dir : Direction
  mut alive : Bool
  mut goals_collected : Array[Bool]
  mut blocks : Array[Vec2i]
  mut cmd_index : Int
} derive(Show)

///|
pub(all) struct ExecutionTrace {
  mut states : Array[RobotState]
  mut success : Bool
  mut fail_reason : String
} derive(Show)

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut best_instructions : Int
  mut medal : Medal
} derive(Show)

///|
pub(all) struct EditorState {
  mut cursor : Int
  mut palette_cursor : Int
  mut palette_open : Bool
  mut palette_commands : Array[CommandKind]
  mut loop_count : Int
  mut condition_index : Int
} derive(Show)

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
} derive(Show)
