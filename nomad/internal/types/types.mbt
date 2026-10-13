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
  kind : TileKind
} derive(Eq, Debug)

///|
pub extend HexTile with Eq::{not_equal, equal}

///|
pub extend HexTile with Debug::{to_repr}

///|
pub(all) struct HexMap {
  width : Int32
  height : Int32
  tiles : Array[Array[HexTile]]
} derive(Debug)

///|
pub extend HexMap with Debug::{to_repr}

///|
pub(all) struct Caravan {
  mut pos : HexCoord
  mut water : Int32
  mut max_water : Int32
  mut gold : Int32
  mut artifacts : Int32
  mut route : Array[HexCoord]
  mut route_index : Int32
  mut move_timer : Float
} derive(Debug)

///|
pub extend Caravan with Debug::{to_repr}

///|
pub(all) struct Level {
  map : HexMap
  start : HexCoord
  destination : HexCoord
  starting_water : Int32
  gold_target : Int32
  total_artifacts : Int32
  tier : Tier
  name : String
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut stars : Int32
  mut best_gold : Int32
  mut best_artifacts : Int32
  mut completed : Bool
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_tier : Tier
  mut current_level : Int32
  mut caravan : Caravan
  mut level : Level?
  mut route : Array[HexCoord]
  mut hover_hex : HexCoord?
  mut scores : Array[LevelScore]
  mut message : String
  mut message_timer : Float
  mut rng : Int32
  mut frame_count : Int32
  mut execute_timer : Float
  mut result_gold : Int32
  mut result_artifacts : Int32
  mut result_stars : Int32
  mut water_preview : Int32
  mut anim_timer : Float
} derive(Debug)

///|
pub extend Game with Debug::{to_repr}
