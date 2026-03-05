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
/// Integer id for the title screen state.
pub let state_title : Int = 0

///|
/// Integer id for active kitchen gameplay.
pub let state_playing : Int = 1

///|
/// Integer id for paused gameplay.
pub let state_paused : Int = 2

///|
/// Integer id for the game-over state.
pub let state_game_over : Int = 3

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
/// Sentinel station id for an invalid or empty station.
pub let station_none : Int = -1

///|
/// Station id for selecting broth.
pub let station_broth : Int = 0

///|
/// Station id for selecting protein.
pub let station_protein : Int = 1

///|
/// Station id for selecting vegetables.
pub let station_veg : Int = 2

///|
/// Station id for selecting spice level.
pub let station_spice : Int = 3

///|
/// Station id for prep board operations.
pub let station_prep : Int = 4

///|
/// Station id for the cooking pot.
pub let station_pot : Int = 5

///|
/// Station id for serving finished orders.
pub let station_serve : Int = 6

///|
/// Station id for triggering rush boost.
pub let station_rush : Int = 7

///|
/// Station id for discarding current pot/hand contents.
pub let station_trash : Int = 8

///|
/// Station id for viewing order queue.
pub let station_queue : Int = 9

///|
/// Station id for viewing reputation status.
pub let station_reputation : Int = 10

///|
/// Station id for storage information.
pub let station_storage : Int = 11

///|
/// Ingredient id representing empty hand or no ingredient.
pub let ingredient_none : Int = 0

///|
/// Ingredient id representing protein.
pub let ingredient_protein : Int = 1

///|
/// Ingredient id representing vegetables.
pub let ingredient_veg : Int = 2

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
