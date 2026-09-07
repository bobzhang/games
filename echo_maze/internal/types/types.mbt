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
  button_id : Int
  door_id : Int
} derive(Debug)

///|
pub extend ButtonLink with Debug::{to_repr}

///|
pub(all) struct GuardDef {
  patrol : Array[Vec2i]
  mut patrol_index : Int
  mut forward : Bool
} derive(Debug)

///|
pub extend GuardDef with Debug::{to_repr}

///|
pub(all) struct GuardState {
  mut pos : Vec2i
  mut patrol_index : Int
  mut forward : Bool
  mut alert : GuardAlertState
  mut alert_timer : Float // countdown for alert state visual
} derive(Debug)

///|
pub extend GuardState with Debug::{to_repr}

///|
pub(all) struct Maze {
  width : Int
  height : Int
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
  door_id : Int
  mut open : Bool
  mut timer : Int
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
  world : Int
  level : Int
  ascii : String
  button_links : Array[ButtonLink]
  guard_patrols : Array[Array[Vec2i]]
  timed_door_durations : Array[(Int, Int)]
  par_loops : Int
  name : String
} derive(Debug)

///|
pub extend LevelDef with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut best_loops : Int
  mut stars : Int
  mut collectibles_got : Int
  mut collectibles_total : Int
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
  mut current_world : Int
  mut current_level : Int
  mut maze : Maze?
  mut maze_state : MazeState?
  player : Player
  mut ghosts : Array[Ghost]
  mut current_recording : Array[Direction?]
  mut recordings : Array[Recording]
  mut tick : Int
  mut max_ticks : Int
  mut loop_count : Int
  mut timeline : Array[TimelineEntry]
  mut level_scores : Array[Array[LevelScore]]
  mut message : String
  mut message_timer : Float
  mut frame_count : Int
  mut tick_timer : Float
  mut planning_tick : Int
  mut selected_world : Int
  mut selected_level : Int
  mut result_loops : Int
  mut result_stars : Int
  mut result_collectibles : Int
  mut result_total_collectibles : Int
  mut restart_flash_timer : Float // visual flash on quick restart
  mut ghost_button_feedback : Array[GhostButtonEvent] // feedback when ghost presses button
  mut planning_paused : Bool // explicit pause indicator in planning mode
  mut loop_transition_timer : Float // smooth transition between loops
} derive(Debug)

///|
pub extend Game with Debug::{to_repr}

///|
pub(all) struct GhostButtonEvent {
  ghost_index : Int
  button_id : Int
  mut timer : Float
} derive(Debug)

///|
pub extend GhostButtonEvent with Debug::{to_repr}
