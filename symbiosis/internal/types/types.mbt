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
pub(all) struct Character {
  mut pos : Vec2i
  mut on_anchor : Bool
  mut reached_exit : Bool
  mut alive : Bool
} derive(Debug)

///|
pub extend Character with Debug::{to_repr}

///|
pub(all) struct SwitchLink {
  switch_id : Int
  door_id : Int
} derive(Eq, Debug)

///|
pub extend SwitchLink with Eq::{not_equal, equal}

///|
pub extend SwitchLink with Debug::{to_repr}

///|
pub(all) struct Level {
  world : Int
  index : Int
  floor_tiles : Array[Array[TileKind]]
  ceiling_tiles : Array[Array[TileKind]]
  switch_links : Array[SwitchLink]
  floor_start : Vec2i
  ceiling_start : Vec2i
  floor_exit : Vec2i
  ceiling_exit : Vec2i
  goal : GoalKind
  par_moves : Int
  gems : Array[Vec2i]
  ceiling_gems : Array[Vec2i]
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut best_moves : Int
  mut stars : Int
  mut gem_collected : Bool
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct Snapshot {
  luna_pos : Vec2i
  sol_pos : Vec2i
  door_states : Array[Bool]
  floor_gems_collected : Array[Bool]
  ceiling_gems_collected : Array[Bool]
  luna_on_anchor : Bool
  sol_on_anchor : Bool
  luna_reached_exit : Bool
  sol_reached_exit : Bool
} derive(Debug)

///|
pub extend Snapshot with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut selected_world : Int
  mut selected_level : Int
  mut current_level : Level?
  luna : Character
  sol : Character
  mut door_states : Array[Bool]
  mut floor_gems_collected : Array[Bool]
  mut ceiling_gems_collected : Array[Bool]
  mut move_count : Int
  mut play_state : PlayState
  mut history : Array[Snapshot]
  mut scores : Array[Array[LevelScore]]
  mut frame_count : Int
  mut message : String
  mut message_timer : Float
} derive(Debug)

///|
pub extend Game with Debug::{to_repr}
