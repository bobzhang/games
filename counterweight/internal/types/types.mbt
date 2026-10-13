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
pub(all) struct Node {
  mut id : Int32
  mut pos : Vec2i
  mut kind : NodeKind
  mut left_conn : Int32
  mut right_conn : Int32
  mut height : Float
  mut base_height : Float
  mut locked : Bool
} derive(Debug)

///|
pub extend Node with Debug::{to_repr}

///|
pub(all) struct Rope {
  mut active : Bool
  mut from_node : Int32
  mut to_node : Int32
  mut from_side : RopeSide
  mut to_side : RopeSide
  mut max_load : Float
  mut broken : Bool
  mut breakable : Bool
} derive(Debug)

///|
pub extend Rope with Debug::{to_repr}

///|
pub(all) struct Weight {
  mut active : Bool
  mut node_id : Int32
  mut mass : Float
  mut current_y : Float
  mut target_y : Float
  mut bob_timer : Float
} derive(Debug)

///|
pub extend Weight with Debug::{to_repr}

///|
pub(all) struct Crate {
  mut active : Bool
  mut node_id : Int32
  mut mass : Float
  mut current_y : Float
  mut target_y : Float
  mut target_height : Float
  mut at_target : Bool
} derive(Debug)

///|
pub extend Crate with Debug::{to_repr}

///|
pub(all) struct Platform {
  mut active : Bool
  mut node_id : Int32
  mut width : Float
  mut height_val : Float
  mut connected_to : Int32
} derive(Debug)

///|
pub extend Platform with Debug::{to_repr}

///|
pub(all) struct Bucket {
  mut active : Bool
  mut node_id : Int32
  mut mass : Float
  mut max_mass : Float
  mut fill_rate : Float
  mut filling : Bool
  mut current_y : Float
  mut target_y : Float
} derive(Debug)

///|
pub extend Bucket with Debug::{to_repr}

///|
pub(all) struct LevelTarget {
  mut crate_index : Int32
  mut target_height : Float
  mut tolerance : Float
} derive(Debug)

///|
pub extend LevelTarget with Debug::{to_repr}

///|
pub(all) struct LevelDef {
  mut tier : Tier
  mut index : Int32
  mut name : String
  mut nodes : Array[Node]
  mut ropes : Array[Rope]
  mut weights : Array[Weight]
  mut crates : Array[Crate]
  mut platforms : Array[Platform]
  mut buckets : Array[Bucket]
  mut targets : Array[LevelTarget]
  mut par_connections : Int32
  mut par_rehooks : Int32
  mut has_waterfall : Bool
  mut waterfall_x : Int32
} derive(Debug)

///|
pub extend LevelDef with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : Int32
  mut connections_used : Int32
  mut rehooks : Int32
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_tier : Tier
  mut current_level : Int32
  mut selected_tier : Int32
  mut selected_level : Int32
  mut nodes : Array[Node]
  mut ropes : Array[Rope]
  mut weights : Array[Weight]
  mut crates : Array[Crate]
  mut platforms : Array[Platform]
  mut buckets : Array[Bucket]
  mut targets : Array[LevelTarget]
  mut par_connections : Int32
  mut par_rehooks : Int32
  mut connections_used : Int32
  mut rehooks : Int32
  mut has_waterfall : Bool
  mut waterfall_x : Int32
  mut settle_timer : Float
  mut anim_timer : Float
  mut hover_node : Int32
  mut message : String
  mut message_timer : Float
  mut scores : Array[LevelScore]
  mut frame_count : Int32
  mut grid_offset_x : Int32
  mut grid_offset_y : Int32
} derive(Debug)

///|
pub extend Game with Debug::{to_repr}
