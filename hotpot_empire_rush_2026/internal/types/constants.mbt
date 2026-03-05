///|
/// Width of the game window in pixels.
pub let screen_w : Int = 1680

///|
/// Height of the game window in pixels.
pub let screen_h : Int = 960

///|
/// Target frame rate used by the game loop.
pub let target_fps : Int = 120

///|
/// Number of station columns in the kitchen grid.
pub let station_cols : Int = 4

///|
/// Number of station rows in the kitchen grid.
pub let station_rows : Int = 3

///|
/// Width of one station tile in pixels.
pub let station_tile_w : Int = 232

///|
/// Height of one station tile in pixels.
pub let station_tile_h : Int = 178

///|
/// Gap between adjacent station tiles in pixels.
pub let station_gap : Int = 14

///|
/// Left edge of the kitchen grid in pixels.
pub let kitchen_left : Int = 52

///|
/// Top edge of the kitchen grid in pixels.
pub let kitchen_top : Int = 130


///|
/// Number of broth variants available.
pub let broth_count : Int = 3

///|
/// Number of protein variants available.
pub let protein_count : Int = 3

///|
/// Number of vegetable variants available.
pub let veg_count : Int = 3

///|
/// Number of spice intensity levels.
pub let spice_levels : Int = 3

///|
/// Maximum concurrent customer orders.
pub let max_orders : Int = 6

///|
/// Maximum reputation meter value.
pub let reputation_max : Float = 100.0

///|
/// Reputation value at the start of a new run.
pub let reputation_start : Float = 72.0

///|
/// Reputation gained when an order is served correctly.
pub let rep_gain_served : Float = 4.0

///|
/// Reputation lost when an order times out.
pub let rep_loss_timeout : Float = 9.5

///|
/// Reputation lost when serving the wrong order.
pub let rep_loss_wrong_serve : Float = 7.0

///|
/// Reputation lost when discarding an active pot.
pub let rep_loss_discard_pot : Float = 3.0

///|
/// Base score awarded for one correct serve.
pub let score_base_serve : Int = 120

///|
/// Time window in seconds to preserve combo chain.
pub let combo_keep_time : Float = 4.2

///|
/// Base prep duration target in seconds.
pub let prep_target_base : Float = 3.2

///|
/// Base cooking duration target in seconds.
pub let cook_target_base : Float = 6.4

///|
/// Maximum value of the rush boost meter.
pub let boost_meter_max : Float = 100.0

///|
/// Boost meter cost paid on rush activation.
pub let boost_cost : Float = 35.0

///|
/// Duration of active rush boost in seconds.
pub let boost_duration : Float = 2.8

///|
/// Boost meter recharge rate per second.
pub let boost_charge_per_s : Float = 11.0

///|
/// Movement/progress multiplier during rush boost.
pub let boost_speed_mult : Float = 1.9

///|
/// Cooldown after ringing rush bell in seconds.
pub let rush_cooldown : Float = 7.0

///|
/// Lifetime of transient UI messages in seconds.
pub let msg_ttl : Float = 2.4


///|
/// Kind of ingredient the player can carry.
pub(all) enum Ingredient {
  None
  Protein
  Veg
} derive(Eq)

///|
/// High-level game phase.
pub(all) enum GameState {
  Title
  Playing
  Paused
  GameOver
} derive(Eq)

///|
/// Kitchen grid station identity.
pub(all) enum Station {
  Broth
  Protein
  Veg
  Spice
  Prep
  Pot
  Serve
  Rush
  Trash
  Queue
  Reputation
  Storage
} derive(Eq)
