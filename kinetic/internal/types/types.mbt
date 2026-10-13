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
pub(all) struct Gear {
  mut pos : Vec2i
  mut kind : GearKind
  mut radius : Int32
  mut rpm : Float
  mut dir : RotDir
  mut angle : Float
  mut active : Bool
} derive(Debug)

///|
pub extend Gear with Debug::{to_repr}

///|
pub(all) struct Connection {
  from : Int32
  to : Int32
  ratio : Float
  flips_dir : Bool
} derive(Debug)

///|
pub extend Connection with Debug::{to_repr}

///|
pub(all) struct Output {
  pos : Vec2i
  target_rpm : Float
  target_dir : RotDir
  mut satisfied : Bool
} derive(Debug)

///|
pub extend Output with Debug::{to_repr}

///|
pub(all) struct InputGear {
  pos : Vec2i
  rpm : Float
  dir : RotDir
  radius : Int32
} derive(Debug)

///|
pub extend InputGear with Debug::{to_repr}

///|
pub(all) struct BeltLink {
  mut from_pos : Vec2i
  mut to_pos : Vec2i
  mut active : Bool
} derive(Debug)

///|
pub extend BeltLink with Debug::{to_repr}

///|
pub(all) struct Level {
  name : String
  tier : Tier
  input : InputGear
  outputs : Array[Output]
  available_gears : Array[GearKind]
  gear_budget : Int32
  par_gears : Int32
  hint : String
} derive(Debug)

///|
pub extend Level with Debug::{to_repr}

///|
pub(all) struct LevelScore {
  mut stars : Int32
  mut gears_used : Int32
  mut completed : Bool
} derive(Debug)

///|
pub extend LevelScore with Debug::{to_repr}

///|
pub(all) struct Game {
  mut screen : Screen
  mut selected_tier : Tier
  mut selected_level : Int32
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
  mut frame_count : Int32
  mut message : String
  mut message_timer : Float
  mut anim_timer : Float
  mut title_gear_angle : Float
} derive(Debug)

///|
pub extend Game with Debug::{to_repr}
