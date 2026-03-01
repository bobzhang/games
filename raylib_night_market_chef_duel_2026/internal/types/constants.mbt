///|
/// Window width in pixels.
pub let screen_w : Int = 1280

///|
/// Window height in pixels.
pub let screen_h : Int = 720

///|
/// Fixed update/render target frequency.
pub let target_fps : Int = 120

///|
/// Height of the top HUD band.
pub let hud_h : Int = 112

///|
/// Maximum simultaneous active order slots.
pub let max_orders : Int = 6

///|
/// Failed-order count that ends the run.
pub let fail_limit : Int = 6

///|
/// Seconds before combo score bonus expires.
pub let combo_window : Float = 5.0

///|
/// Initial delay between order spawns.
pub let spawn_interval_start : Float = 3.4

///|
/// Fastest allowed order spawn interval.
pub let spawn_interval_min : Float = 1.15

///|
/// Starting patience time for new orders.
pub let patience_base : Float = 19.0

///|
/// Minimum patience floor at high progression.
pub let patience_floor : Float = 8.5

///|
/// Prep progress added by one prep input.
pub let prep_press_gain : Float = 0.9

///|
/// Heat progress added by one cook input.
pub let heat_press_gain : Float = 1.0

///|
/// Duration of temporary boost mode.
pub let boost_time : Float = 1.15

///|
/// Cooldown between boost activations.
pub let boost_cooldown : Float = 5.0

///|
/// Prep-rate multiplier during boost.
pub let boost_prep_rate : Float = 1.7

///|
/// Cook-rate multiplier during boost.
pub let boost_heat_rate : Float = 1.1

///|
/// X position of the order list column.
pub let orders_x : Float = 206.0

///|
/// Y position of the first order row.
pub let orders_y0 : Float = 176.0

///|
/// Vertical spacing between order rows.
pub let orders_gap : Float = 76.0

///|
/// X position of the prep station node.
pub let prep_x : Float = 592.0

///|
/// Y position of the prep station node.
pub let prep_y : Float = 224.0

///|
/// X position of the grill station node.
pub let grill_x : Float = 470.0

///|
/// Y position of the grill station node.
pub let grill_y : Float = 454.0

///|
/// X position of the wok station node.
pub let wok_x : Float = 716.0

///|
/// Y position of the wok station node.
pub let wok_y : Float = 454.0

///|
/// X position of the serving pass node.
pub let pass_x : Float = 1030.0

///|
/// Y position of the serving pass node.
pub let pass_y : Float = 312.0

///|
/// Navigation node id for prep station.
pub let node_prep : Int = max_orders

///|
/// Navigation node id for grill station.
pub let node_grill : Int = max_orders + 1

///|
/// Navigation node id for wok station.
pub let node_wok : Int = max_orders + 2

///|
/// Navigation node id for serving pass.
pub let node_pass : Int = max_orders + 3

///|
/// Total navigation node count.
pub let node_count : Int = max_orders + 4
