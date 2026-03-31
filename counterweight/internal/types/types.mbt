///|
pub(all) struct Vec2i {
  x : Int
  y : Int
} derive(Eq, Show)

///|
pub(all) struct Node {
  mut id : Int
  mut pos : Vec2i
  mut kind : NodeKind
  mut left_conn : Int
  mut right_conn : Int
  mut height : Float
  mut base_height : Float
  mut locked : Bool
} derive(Show)

///|
pub(all) struct Rope {
  mut active : Bool
  mut from_node : Int
  mut to_node : Int
  mut from_side : RopeSide
  mut to_side : RopeSide
  mut max_load : Float
  mut broken : Bool
  mut breakable : Bool
} derive(Show)

///|
pub(all) struct Weight {
  mut active : Bool
  mut node_id : Int
  mut mass : Float
  mut current_y : Float
  mut target_y : Float
  mut bob_timer : Float
} derive(Show)

///|
pub(all) struct Crate {
  mut active : Bool
  mut node_id : Int
  mut mass : Float
  mut current_y : Float
  mut target_y : Float
  mut target_height : Float
  mut at_target : Bool
} derive(Show)

///|
pub(all) struct Platform {
  mut active : Bool
  mut node_id : Int
  mut width : Float
  mut height_val : Float
  mut connected_to : Int
} derive(Show)

///|
pub(all) struct Bucket {
  mut active : Bool
  mut node_id : Int
  mut mass : Float
  mut max_mass : Float
  mut fill_rate : Float
  mut filling : Bool
  mut current_y : Float
  mut target_y : Float
} derive(Show)

///|
pub(all) struct LevelTarget {
  mut crate_index : Int
  mut target_height : Float
  mut tolerance : Float
} derive(Show)

///|
pub(all) struct LevelDef {
  mut tier : Tier
  mut index : Int
  mut name : String
  mut nodes : Array[Node]
  mut ropes : Array[Rope]
  mut weights : Array[Weight]
  mut crates : Array[Crate]
  mut platforms : Array[Platform]
  mut buckets : Array[Bucket]
  mut targets : Array[LevelTarget]
  mut par_connections : Int
  mut par_rehooks : Int
  mut has_waterfall : Bool
  mut waterfall_x : Int
} derive(Show)

///|
pub(all) struct LevelScore {
  mut completed : Bool
  mut stars : Int
  mut connections_used : Int
  mut rehooks : Int
} derive(Show)

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_tier : Tier
  mut current_level : Int
  mut selected_tier : Int
  mut selected_level : Int
  mut nodes : Array[Node]
  mut ropes : Array[Rope]
  mut weights : Array[Weight]
  mut crates : Array[Crate]
  mut platforms : Array[Platform]
  mut buckets : Array[Bucket]
  mut targets : Array[LevelTarget]
  mut par_connections : Int
  mut par_rehooks : Int
  mut connections_used : Int
  mut rehooks : Int
  mut has_waterfall : Bool
  mut waterfall_x : Int
  mut settle_timer : Float
  mut anim_timer : Float
  mut hover_node : Int
  mut message : String
  mut message_timer : Float
  mut scores : Array[LevelScore]
  mut frame_count : Int
  mut grid_offset_x : Int
  mut grid_offset_y : Int
} derive(Show)
