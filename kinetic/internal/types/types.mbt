///|
pub(all) struct Vec2i {
  x : Int
  y : Int
} derive(Eq, Show)

///|
pub(all) struct Gear {
  mut pos : Vec2i
  mut kind : GearKind
  mut radius : Int
  mut rpm : Float
  mut dir : RotDir
  mut angle : Float
  mut active : Bool
} derive(Show)

///|
pub(all) struct Connection {
  from : Int
  to : Int
  ratio : Float
  flips_dir : Bool
} derive(Show)

///|
pub(all) struct Output {
  pos : Vec2i
  target_rpm : Float
  target_dir : RotDir
  mut satisfied : Bool
} derive(Show)

///|
pub(all) struct InputGear {
  pos : Vec2i
  rpm : Float
  dir : RotDir
  radius : Int
} derive(Show)

///|
pub(all) struct BeltLink {
  mut from_pos : Vec2i
  mut to_pos : Vec2i
  mut active : Bool
} derive(Show)

///|
pub(all) struct Level {
  name : String
  tier : Tier
  input : InputGear
  outputs : Array[Output]
  available_gears : Array[GearKind]
  gear_budget : Int
  par_gears : Int
  hint : String
} derive(Show)

///|
pub(all) struct LevelScore {
  mut stars : Int
  mut gears_used : Int
  mut completed : Bool
} derive(Show)

///|
pub(all) struct Game {
  mut screen : Screen
  mut selected_tier : Tier
  mut selected_level : Int
  mut play_state : PlayState
  mut placed_gears : Array[Gear]
  mut belts : Array[BeltLink]
  mut connections : Array[Connection]
  mut current_level : Level?
  mut selected_gear_kind : GearKind
  mut belt_start : Vec2i?
  mut scores : Array[LevelScore]
  mut hover_peg : Vec2i?
  mut sim_time : Float
  mut frame_count : Int
  mut message : String
  mut message_timer : Float
  mut anim_timer : Float
  mut title_gear_angle : Float
} derive(Show)
