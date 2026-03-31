///|
pub(all) struct Vec2 {
  mut x : Float
  mut y : Float
}

///|
pub(all) struct Body {
  mut id : Int
  mut active : Bool
  kind : PieceKind
  material : Material
  mut x : Float
  mut y : Float
  mut angle : Float
  mut vx : Float
  mut vy : Float
  mut angular_vel : Float
  width : Float
  height : Float
  mut mass : Float
  mut stress : Float
  mut broken : Bool
  mut grounded : Bool
}

///|
pub(all) struct Joint {
  mut active : Bool
  kind : JointKind
  body_a : Int
  body_b : Int
  local_x_a : Float
  local_y_a : Float
  local_x_b : Float
  local_y_b : Float
  mut stress : Float
  mut broken : Bool
  strength : Float
}

///|
pub(all) struct World {
  bodies : Array[Body]
  joints : Array[Joint]
  mut gravity : Float
  ground_y : Float
  mut wind_force : Float
  mut quake_timer : Float
  mut quake_intensity : Float
}

///|
pub(all) struct Level {
  name : String
  description : String
  target_height : Float
  budget : Int
  test_kinds : Array[TestKind]
  available_pieces : Array[(PieceKind, Material, Int)]
}

///|
pub(all) struct Game {
  mut screen : Screen
  world : World
  mut current_level : Int
  mut selected_piece : Int
  mut ghost_x : Float
  mut ghost_y : Float
  mut ghost_angle : Float
  mut score : Int
  mut best_height : Float
  mut test_phase : Int
  mut test_timer : Float
  mut frame_count : Int
  mut rng_state : UInt
  mut message_text : String
  mut message_timer : Float
  inventory : Array[(PieceKind, Material, Int)]
  mut tower_height : Float
}
