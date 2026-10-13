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
pub(all) struct Player {
  mut pos : Vec2i
  mut dir : Direction
  mut alive : Bool
} derive(Debug)

///|
pub extend Player with Debug::{to_repr}

///|
pub(all) struct Ghost {
  recording : Array[Direction?]
  color : GhostColor
  mut pos : Vec2i
  mut active : Bool
  trail_positions : Array[Vec2i] // history of positions for trail visualization
} derive(Debug)

///|
pub extend Ghost with Debug::{to_repr}

///|
pub(all) struct Recording {
  moves : Array[Direction?]
} derive(Debug)

///|
pub extend Recording with Debug::{to_repr}

///|
pub(all) struct Tile {
  kind : TileKind
} derive(Debug)

///|
pub extend Tile with Debug::{to_repr}

///|
pub(all) struct ButtonLink {
  button_id : Int32
  door_id : Int32
} derive(Debug)

///|
pub extend ButtonLink with Debug::{to_repr}

///|
pub(all) struct GuardDef {
  patrol : Array[Vec2i]
  mut patrol_index : Int32
  mut forward : Bool
} derive(Debug)

///|
pub extend GuardDef with Debug::{to_repr}

///|
pub(all) struct GuardState {
  mut pos : Vec2i
  mut patrol_index : Int32
  mut forward : Bool
  mut alert : GuardAlertState
  mut alert_timer : Float // countdown for alert state visual
} derive(Debug)

///|
pub extend GuardState with Debug::{to_repr}

///|
pub(all) struct Maze {
  width : Int32
  height : Int32
  tiles : Array[Array[Tile]]
  button_links : Array[ButtonLink]
  guard_defs : Array[GuardDef]
  start : Vec2i
  exit : Vec2i
  collectible_positions : Array[Vec2i]
} derive(Debug)

///|
pub extend Maze with Debug::{to_repr}

///|
pub(all) struct DoorState {
  door_id : Int32
  mut open : Bool
  mut timer : Int32
  mut anim_progress : Float // 0.0 = closed, 1.0 = open (for smooth animation)
  mut prev_open : Bool // track previous state for transition detection
} derive(Debug)

///|
pub extend DoorState with Debug::{to_repr}

///|
pub(all) struct MazeState {
  mut door_states : Array[DoorState]
  mut button_pressed : Array[Bool]
  mut guard_states : Array[GuardState]
  mut collectibles_collected : Array[Bool]
} derive(Debug)

///|
pub extend MazeState with Debug::{to_repr}

///|
pub(all) struct LevelDef {
  world : Int32
  level : Int32
  ascii : String
  button_links : Array[ButtonLink]
  guard_patrols : Array[Array[Vec2i]]
  timed_door_durations : Array[(Int32, Int32)]
  par_loops : Int32
  name : String
} derive(Debug)

///|
pub extend LevelDef with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut best_loops : Int32
  mut stars : Int32
  mut collectibles_got : Int32
  mut collectibles_total : Int32
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct TimelineEntry {
  player_pos : Vec2i
  ghost_positions : Array[Vec2i]
  guard_positions : Array[Vec2i]
  buttons_pressed : Array[Bool]
  doors_open : Array[Bool]
} derive(Debug)

///|
pub extend TimelineEntry with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_world : Int32
  mut current_level : Int32
  mut maze : Maze?
  mut maze_state : MazeState?
  player : Player
  mut ghosts : Array[Ghost]
  mut current_recording : Array[Direction?]
  mut recordings : Array[Recording]
  mut tick : Int32
  mut max_ticks : Int32
  mut loop_count : Int32
  mut timeline : Array[TimelineEntry]
  mut level_scores : Array[Array[LevelScore]]
  mut message : String
  mut message_timer : Float
  mut frame_count : Int32
  mut tick_timer : Float
  mut planning_tick : Int32
  mut selected_world : Int32
  mut selected_level : Int32
  mut result_loops : Int32
  mut result_stars : Int32
  mut result_collectibles : Int32
  mut result_total_collectibles : Int32
  mut restart_flash_timer : Float // visual flash on quick restart
  mut ghost_button_feedback : Array[GhostButtonEvent] // feedback when ghost presses button
  mut planning_paused : Bool // explicit pause indicator in planning mode
  mut loop_transition_timer : Float // smooth transition between loops
} derive(Debug)

///|
pub extend Game with Debug::{to_repr}

///|
pub(all) struct GhostButtonEvent {
  ghost_index : Int32
  button_id : Int32
  mut timer : Float
} derive(Debug)

///|
pub extend GhostButtonEvent with Debug::{to_repr}
