///|
/// Width of the game window in pixels.
pub let screen_w : Int = 1440

///|
/// Height of the game window in pixels.
pub let screen_h : Int = 900

///|
/// Target frame rate used by the game loop.
pub let target_fps : Int = 120

///|
/// Number of drivable lanes on the mountain route.
pub let lane_count : Int = 3

///|
/// Maximum hazards allocated in the hazard pool.
pub let max_hazards : Int = 72

///|
/// Top Y position of the road perspective region.
pub let road_top_y_i : Int = 130

///|
/// Fixed Y position of the tea cart on screen.
pub let cart_y : Float = 760.0

///|
/// Minimum allowed cart speed.
pub let speed_min : Float = 130.0

///|
/// Base cruising speed at run start.
pub let speed_base : Float = 260.0

///|
/// Maximum allowed cart speed.
pub let speed_max : Float = 430.0

///|
/// Forward acceleration while cruising.
pub let cruise_accel : Float = 200.0

///|
/// Passive drag applied to speed each frame.
pub let natural_drag : Float = 0.45

///|
/// Deceleration force applied while braking.
pub let brake_force : Float = 760.0

///|
/// Speed penalty while stabilize action is held.
pub let stabilize_speed_penalty : Float = 170.0

///|
/// Smoothing speed for lane-follow interpolation.
pub let lane_follow_speed : Float = 7.2

///|
/// Smoothing speed for cart tilt interpolation.
pub let tilt_follow_speed : Float = 8.5

///|
/// Strength of road wobble influence on cart stability.
pub let route_wobble_strength : Float = 0.92

///|
/// Damping applied to wobble while stabilizing.
pub let stabilize_wobble_damp : Float = 6.0

///|
/// Cargo quality loss per second from route wear.
pub let route_wear_cargo_dps : Float = 1.4

///|
/// Cart durability loss per second from route wear.
pub let route_wear_durability_dps : Float = 1.1

///|
/// Duration of active speed boost.
pub let boost_duration : Float = 0.9

///|
/// Cooldown after using boost.
pub let boost_cooldown : Float = 2.3

///|
/// Extra acceleration applied during boost.
pub let boost_accel : Float = 540.0

///|
/// Heat gained per second while boosting.
pub let boost_heat_gain : Float = 38.0

///|
/// Passive heat cooling rate while idle.
pub let boost_heat_cool_idle : Float = 14.0

///|
/// Heat cooling rate while stabilizing.
pub let boost_heat_cool_stabilize : Float = 18.0

///|
/// Heat threshold above which boost cannot start.
pub let boost_heat_start_limit : Float = 88.0

///|
/// Heat threshold for overheat state.
pub let boost_heat_critical : Float = 100.0

///|
/// Durability loss per second while overheated.
pub let overheat_durability_dps : Float = 5.2

///|
/// Cargo quality loss per second while overheated.
pub let overheat_cargo_dps : Float = 4.4

///|
/// Reputation loss per second while overheated.
pub let overheat_reputation_dps : Float = 2.6

///|
/// Base hazard spawn interval.
pub let hazard_spawn_base : Float = 1.15

///|
/// Minimum hazard spawn interval at high difficulty.
pub let hazard_spawn_floor : Float = 0.42

///|
/// Difficulty scaling step applied to spawn interval.
pub let hazard_spawn_difficulty_step : Float = 0.03

///|
/// Distance window used to register hazard collisions.
pub let hazard_collision_window : Float = 54.0

///|
/// Distance window used to register safe hazard passes.
pub let hazard_pass_window : Float = 60.0

///|
/// Base distance required for first checkpoint.
pub let checkpoint_distance_base : Float = 1500.0

///|
/// Additional checkpoint distance added per segment.
pub let checkpoint_distance_step : Float = 180.0

///|
/// Base timer granted for checkpoint delivery.
pub let checkpoint_timer_base : Float = 23.0

///|
/// Timer decay per checkpoint level.
pub let checkpoint_timer_decay : Float = 0.55

///|
/// Minimum checkpoint timer floor.
pub let checkpoint_timer_min : Float = 10.5

///|
/// Minimum cargo quality required for good delivery.
pub let delivery_quality_floor : Float = 34.0

///|
/// Minimum durability required for good delivery.
pub let delivery_durability_floor : Float = 26.0

///|
/// Reputation gain on successful delivery.
pub let delivery_reputation_gain : Float = 5.5

///|
/// Base reputation loss on failed delivery.
pub let delivery_reputation_loss_base : Float = 9.0

///|
/// Additional reputation loss when delivery is late.
pub let delivery_reputation_loss_late : Float = 7.5

///|
/// Additional reputation loss for poor cargo quality.
pub let delivery_reputation_loss_quality : Float = 8.5

///|
/// Additional reputation loss for poor durability.
pub let delivery_reputation_loss_durability : Float = 5.0

///|
/// Base score awarded for successful delivery.
pub let delivery_score_base : Int = 180

///|
/// Maximum score multiplier level.
pub let delivery_multiplier_max : Int = 6
