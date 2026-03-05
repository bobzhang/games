///|
/// Window width in pixels.
pub let screen_w : Int = 1440

///|
/// Window height in pixels.
pub let screen_h : Int = 900

///|
/// Target rendering frame rate in frames per second.
pub let target_fps : Int = 120

///|
/// Left edge X coordinate of the world viewport in pixels.
pub let world_x0 : Int = 24

///|
/// Top edge Y coordinate of the world viewport in pixels.
pub let world_y0 : Int = 24

///|
/// Width of the world viewport in pixels.
pub let world_w : Int = 980

///|
/// Height of the world viewport in pixels.
pub let world_h : Int = 852

///|
/// Left edge X coordinate of the side information panel in pixels.
pub let panel_x0 : Int = world_x0 + world_w + 20

///|
/// Width of the side information panel in pixels.
pub let panel_w : Int = screen_w - panel_x0 - 24

///|
/// Maximum number of relay towers that can be active simultaneously.
pub let max_towers : Int = 6

///|
/// Maximum number of storm cells that can be active simultaneously.
pub let max_storms : Int = 5

///|
/// Collision and body radius of the rover in pixels.
pub let rover_r : Float = 22.0

///|
/// Linear acceleration applied to the rover per unit of input (px/s²).
pub let rover_accel : Float = 760.0

///|
/// Velocity drag coefficient applied to the rover each frame to simulate friction.
pub let rover_drag : Float = 5.0

///|
/// Maximum rover speed under calm conditions (px/s).
pub let rover_max_speed : Float = 280.0

///|
/// Magnitude of wind force applied to the rover when inside a storm cell (px/s²).
pub let rover_wind_force : Float = 180.0

///|
/// Fraction of rover control authority lost per unit of storm intensity (0–1 scale).
pub let storm_control_penalty : Float = 0.45

///|
/// Maximum number of power cells the rover can carry at once.
pub let cargo_capacity : Int = 3

///|
/// Maximum rover energy capacity.
pub let energy_max : Float = 100.0

///|
/// Maximum rover heat capacity.
pub let heat_max : Float = 100.0

///|
/// Base energy drained per second while the rover is stationary.
pub let energy_idle_drain : Float = 1.6

///|
/// Additional energy drained per pixel of speed per second while moving.
pub let energy_move_drain : Float = 0.008

///|
/// Additional energy drained per second per unit of storm intensity.
pub let energy_storm_drain : Float = 7.4

///|
/// Energy restored per second while the rover is inside the depot.
pub let energy_recharge_rate : Float = 29.0

///|
/// Base heat drained per second while the rover is stationary.
pub let heat_idle_drain : Float = 2.0

///|
/// Additional heat drained per second per unit of storm intensity.
pub let heat_storm_drain : Float = 10.8

///|
/// Heat restored per second while the rover is inside the depot.
pub let heat_recharge_rate : Float = 34.0

///|
/// Mission time limit in seconds for stage 1 (decreases each stage).
pub let timer_base : Float = 92.0

///|
/// Minimum mission time limit in seconds, applied once the per-stage reduction reaches this floor.
pub let timer_floor : Float = 48.0

///|
/// Number of seconds subtracted from the mission timer limit for each additional stage.
pub let timer_step : Float = 5.0

///|
/// Bonus seconds added to the mission timer when the first relay tower is brought online.
pub let tower_online_bonus_base : Float = 3.0

///|
/// Additional bonus seconds added per stage level when a relay tower is brought online.
pub let tower_online_bonus_step : Float = 0.9
