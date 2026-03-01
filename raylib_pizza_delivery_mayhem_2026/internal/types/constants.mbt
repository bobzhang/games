///|
/// Width of the game window in pixels.
pub let screen_w : Int = 1720

///|
/// Height of the game window in pixels.
pub let screen_h : Int = 980

///|
/// Target frame rate for simulation and rendering.
pub let target_fps : Int = 120

///|
/// State id used for the title screen.
pub let state_title : Int = 0

///|
/// State id used for active gameplay.
pub let state_play : Int = 1

///|
/// State id used for the result screen.
pub let state_result : Int = 2

///|
/// Traffic kind id for sedan vehicles.
pub let traffic_sedan : Int = 0

///|
/// Traffic kind id for buses.
pub let traffic_bus : Int = 1

///|
/// Traffic kind id for vans.
pub let traffic_van : Int = 2

///|
/// Pickup kind id for fuel refills.
pub let pickup_fuel : Int = 0

///|
/// Pickup kind id for scooter repairs.
pub let pickup_repair : Int = 1

///|
/// Pickup kind id for temporary speed boosts.
pub let pickup_speed : Int = 2

///|
/// Maximum number of traffic entities in the pool.
pub let max_traffic : Int = 220

///|
/// Maximum number of order entities in the pool.
pub let max_orders : Int = 90

///|
/// Maximum number of pickup entities in the pool.
pub let max_pickups : Int = 80

///|
/// Maximum number of particle entities in the pool.
pub let max_particles : Int = 1600

///|
/// Left edge of the playable world in pixels.
pub let world_x0 : Int = 24

///|
/// Top edge of the playable world in pixels.
pub let world_y0 : Int = 20

///|
/// Width of the playable world in pixels.
pub let world_w : Int = 1120

///|
/// Height of the playable world in pixels.
pub let world_h : Int = 940

///|
/// Left edge of the information panel.
pub let panel_x0 : Int = world_x0 + world_w + 24

///|
/// Width of the information panel.
pub let panel_w : Int = screen_w - panel_x0 - 24

///|
/// Road lane spacing used by spawn and movement logic.
pub let road_step : Int = 112

///|
/// Collision radius of the delivery rider.
pub let rider_r : Float = 20.0

///|
/// Run duration target in seconds.
pub let run_time_goal : Float = 210.0

///|
/// Score required for guaranteed mission success.
pub let score_goal : Int = 2200

///|
/// Returns the title-screen start button rectangle.
pub fn start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 280, 620, 560, 122)
}

///|
/// Returns the result-screen retry button rectangle.
pub fn retry_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 240, 648, 480, 110)
}

///|
/// Returns the on-screen left movement button rectangle.
pub fn btn_left() -> (Int, Int, Int, Int) {
  (1230, 730, 104, 96)
}

///|
/// Returns the on-screen right movement button rectangle.
pub fn btn_right() -> (Int, Int, Int, Int) {
  (1460, 730, 104, 96)
}

///|
/// Returns the on-screen up movement button rectangle.
pub fn btn_up() -> (Int, Int, Int, Int) {
  (1345, 624, 104, 96)
}

///|
/// Returns the on-screen down movement button rectangle.
pub fn btn_down() -> (Int, Int, Int, Int) {
  (1345, 836, 104, 96)
}

///|
/// Returns the on-screen boost action button rectangle.
pub fn btn_boost() -> (Int, Int, Int, Int) {
  (1582, 704, 110, 124)
}

///|
/// Returns the on-screen action button rectangle.
pub fn btn_action() -> (Int, Int, Int, Int) {
  (1582, 842, 110, 98)
}

///|
/// Returns the on-screen hint button rectangle.
pub fn btn_hint() -> (Int, Int, Int, Int) {
  (1582, 606, 110, 90)
}

///|
/// Returns the on-screen restart button rectangle.
pub fn btn_restart() -> (Int, Int, Int, Int) {
  (1462, 606, 110, 90)
}

///|
/// Returns x-position of the restaurant indexed by `i`.
pub fn restaurant_x(i : Int) -> Float {
  if i == 0 {
    Float::from_int(world_x0 + 120)
  } else if i == 1 {
    Float::from_int(world_x0 + world_w / 2)
  } else {
    Float::from_int(world_x0 + world_w - 140)
  }
}

///|
/// Returns y-position of the restaurant indexed by `i`.
pub fn restaurant_y(i : Int) -> Float {
  if i == 0 {
    Float::from_int(world_y0 + 136)
  } else if i == 1 {
    Float::from_int(world_y0 + world_h - 180)
  } else {
    Float::from_int(world_y0 + 300)
  }
}

///|
/// Returns x-position of the delivery depot.
pub fn depot_x() -> Float {
  Float::from_int(world_x0 + world_w - 120)
}

///|
/// Returns y-position of the delivery depot.
pub fn depot_y() -> Float {
  Float::from_int(world_y0 + 100)
}

///|
/// Returns width of the depot rectangle.
pub fn depot_w() -> Int {
  160
}

///|
/// Returns height of the depot rectangle.
pub fn depot_h() -> Int {
  120
}
