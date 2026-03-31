///|
pub(all) struct HexCoord {
  col : Int
  row : Int
} derive(Eq, Show)

///|
pub(all) struct HexTile {
  kind : TileKind
} derive(Eq, Show)

///|
pub(all) struct HexMap {
  width : Int
  height : Int
  tiles : Array[Array[HexTile]]
} derive(Show)

///|
pub(all) struct Caravan {
  mut pos : HexCoord
  mut water : Int
  mut max_water : Int
  mut gold : Int
  mut artifacts : Int
  mut route : Array[HexCoord]
  mut route_index : Int
  mut move_timer : Float
} derive(Show)

///|
pub(all) struct Level {
  map : HexMap
  start : HexCoord
  destination : HexCoord
  starting_water : Int
  gold_target : Int
  total_artifacts : Int
  tier : Tier
  name : String
} derive(Show)

///|
pub(all) struct LevelScore {
  mut stars : Int
  mut best_gold : Int
  mut best_artifacts : Int
  mut completed : Bool
} derive(Show)

///|
pub(all) struct Game {
  mut screen : Screen
  mut play_state : PlayState
  mut current_tier : Tier
  mut current_level : Int
  mut caravan : Caravan
  mut level : Level?
  mut route : Array[HexCoord]
  mut hover_hex : HexCoord?
  mut scores : Array[LevelScore]
  mut message : String
  mut message_timer : Float
  mut rng : Int
  mut frame_count : Int
  mut execute_timer : Float
  mut result_gold : Int
  mut result_artifacts : Int
  mut result_stars : Int
  mut water_preview : Int
  mut anim_timer : Float
} derive(Show)
