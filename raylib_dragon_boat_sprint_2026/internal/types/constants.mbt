///|
/// Window width in pixels.
pub let screen_w : Int = 1720

///|
/// Window height in pixels.
pub let screen_h : Int = 980

///|
/// Target frame rate for race simulation.
pub let target_fps : Int = 120

///|
/// Hazard id for floating debris.
pub let hazard_debris : Int = 0

///|
/// Hazard id for destabilizing wave rings.
pub let hazard_wave : Int = 1

///|
/// Maximum number of active hazards.
pub let max_hazards : Int = 96

///|
/// Number of rival boats in a race.
pub let max_rivals : Int = 4

///|
/// Left edge of the river playfield.
pub let river_x : Int = 56

///|
/// Top edge of the river playfield.
pub let river_y : Int = 56

///|
/// River playfield width in pixels.
pub let river_w : Int = 1188

///|
/// River playfield height in pixels.
pub let river_h : Int = 868

///|
/// Left edge of the right-side HUD panel.
pub let hud_x : Int = river_x + river_w + 24

///|
/// Width of the right-side HUD panel.
pub let hud_w : Int = screen_w - hud_x - 24

///|
/// Fixed Y position of the player's boat on screen.
pub let boat_y : Int = river_y + river_h - 138

///|
/// Horizontal pixel scale from lane value to screen X.
pub let lane_span_px : Float = 430.0

///|
/// Screen-space conversion factor from distance units.
pub let distance_to_px : Float = 0.34

///|
/// Distance ahead of player that remains visible.
pub let visible_distance : Float = 2320.0

///|
/// Total race distance required to finish.
pub let finish_distance : Float = 5200.0

///|
/// Distance spacing between checkpoints.
pub let checkpoint_gap : Float = 1040.0

///|
/// Number of checkpoints in a full run.
pub let checkpoint_count : Int = 4

///|
/// Rhythm beat period in seconds.
pub let beat_period : Float = 0.62

///|
/// Timing window for perfect paddle strokes.
pub let beat_perfect_window : Float = 0.08

///|
/// Timing window for good paddle strokes.
pub let beat_good_window : Float = 0.16

///|
/// Baseline forward speed before bonuses and penalties.
pub let base_speed : Float = 132.0

///|
/// Returns world distance for a checkpoint index.
pub fn checkpoint_distance(index : Int) -> Float {
  checkpoint_gap * Float::from_int(index + 1)
}
