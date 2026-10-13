///|
pub(all) struct Vec2i {
  x : Int32
  y : Int32
} derive(Eq, Debug, ToJson)

///|
pub extend Vec2i with Eq::{not_equal, equal}

///|
pub extend Vec2i with Debug::{to_repr}

///|
pub extend Vec2i with ToJson::{to_json}

///|
pub(all) struct Agent {
  mut gx : Int32
  mut gy : Int32
  mut px : Float
  mut py : Float
  mut target_px : Float
  mut target_py : Float
  mut moving : Bool
  mut running : Bool
  mut facing : Direction
  mut visible : Bool
  mut coins : Int32
  mut hacked_terminals : Int32
  mut detected_count : Int32
  mut alert_triggered : Bool
  mut in_shadow : Bool
} derive(Debug)

///|
pub extend Agent with Debug::{to_repr}

///|
pub(all) struct Guard {
  mut gx : Int32
  mut gy : Int32
  mut px : Float
  mut py : Float
  mut kind : GuardKind
  mut alert_state : AlertState
  mut facing : Direction
  mut facing_angle : Float
  mut vision_range : Float
  mut vision_cone : Float
  mut patrol_points : Array[Vec2i]
  mut patrol_index : Int32
  mut patrol_forward : Bool
  mut suspicious_timer : Float
  mut alert_timer : Float
  mut investigate_x : Int32
  mut investigate_y : Int32
  mut detection_meter : Float
  mut active : Bool
  mut speed : Float
  mut move_timer : Float
  // Search behavior: guards investigate nearby offsets before returning to patrol
  mut search_offsets : Array[Vec2i]
  mut search_index : Int32
  mut searching : Bool
  mut look_timer : Float
} derive(Debug)

///|
pub extend Guard with Debug::{to_repr}

///|
pub(all) struct Camera {
  mut gx : Int32
  mut gy : Int32
  mut facing_angle : Float
  mut rotation_speed : Float
  mut vision_range : Float
  mut active : Bool
  mut powered : Bool
} derive(Debug)

///|
pub extend Camera with Debug::{to_repr}

///|
pub(all) struct Terminal {
  mut gx : Int32
  mut gy : Int32
  mut hacked : Bool
  mut high_security : Bool
  mut connected_id : Int32
  mut data_value : Int32
} derive(Debug)

///|
pub extend Terminal with Debug::{to_repr}

///|
pub(all) struct Door {
  mut gx : Int32
  mut gy : Int32
  mut open : Bool
  mut locked : Bool
  mut power_id : Int32
} derive(Debug)

///|
pub extend Door with Debug::{to_repr}

///|
pub(all) struct LaserGrid {
  mut gx : Int32
  mut gy : Int32
  mut active : Bool
  mut power_id : Int32
  mut horizontal : Bool
  mut length : Int32
} derive(Debug)

///|
pub extend LaserGrid with Debug::{to_repr}

///|
pub(all) struct PowerNode {
  mut gx : Int32
  mut gy : Int32
  mut powered : Bool
  mut node_id : Int32
  mut connected_ids : Array[Int32]
} derive(Debug)

///|
pub extend PowerNode with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut base_score : Int32
  mut ghost_bonus : Int32
  mut no_alert_bonus : Int32
  mut speed_bonus : Int32
  mut data_bonus : Int32
  mut total : Int32
  mut grade : ScoreGrade
  mut time_taken : Float
  mut all_data : Bool
  mut ghost : Bool
  mut no_alerts : Bool
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct HackMiniGame {
  mut active : Bool
  mut sequence : Array[Int32]
  mut input : Array[Int32]
  mut timer : Float
  mut max_time : Float
  mut current_pos : Int32
  mut success : Bool
  mut failed : Bool
  mut target_terminal : Int32
} derive(Debug)

///|
pub extend HackMiniGame with Debug::{to_repr}

///|
pub(all) struct Level {
  mut name : String
  mut tier : Tier
  mut width : Int32
  mut height : Int32
  mut tiles : Array[Array[TileKind]]
  mut guards : Array[Guard]
  mut cameras : Array[Camera]
  mut terminals : Array[Terminal]
  mut doors : Array[Door]
  mut lasers : Array[LaserGrid]
  mut power_nodes : Array[PowerNode]
  mut start_x : Int32
  mut start_y : Int32
  mut exit_x : Int32
  mut exit_y : Int32
  mut par_time : Float
  mut total_data : Int32
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut player : Agent
  mut level : Level
  mut level_index : Int32
  mut hack_game : HackMiniGame
  mut score : LevelScore
  mut level_scores : Array[LevelScore?]
  mut sound_queue : Array[SoundEvent]
  mut time_played : Float
  mut message : String
  mut message_timer : Float
  mut rng : Int32
  mut frame_count : Int32
  mut menu_selection : Int32
  mut coin_target_x : Int32
  mut coin_target_y : Int32
  mut coin_active : Bool
  mut coin_timer : Float
  mut move_cooldown : Float
  mut level_complete : Bool
  mut fade_timer : Float
  mut all_levels_complete : Bool
  mut noise_x : Int32
  mut noise_y : Int32
  mut noise_radius : Int32
  mut noise_timer : Float
  // Game feel: brief pause on detection
  mut detection_pause : Float
  // Smooth camera offset
  mut camera_offset_x : Float
  mut camera_offset_y : Float
} derive(Debug)

///|
pub extend Game with Debug::{to_repr}
