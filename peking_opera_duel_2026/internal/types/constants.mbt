///|
/// Window width in pixels.
pub let screen_w : Int = 1600

///|
/// Window height in pixels.
pub let screen_h : Int = 960

///|
/// Fixed update and render rate target.
pub let target_fps : Int = 120

///|
/// Number of supported stance ids.
pub let stance_count : Int = 4

///|
/// Minimum lane coordinate on each axis.
pub let lane_axis_min : Int = -1

///|
/// Maximum lane coordinate on each axis.
pub let lane_axis_max : Int = 1

///|
/// Duel timer duration in seconds.
pub let duel_duration : Float = 90.0

///|
/// Lead time before a prompt expires around beat time.
pub let prompt_lead_time : Float = 1.18

///|
/// Initial beat spawn interval in seconds.
pub let beat_start_interval : Float = 1.02

///|
/// Fastest beat spawn interval in seconds.
pub let beat_min_interval : Float = 0.54

///|
/// Per-second beat interval acceleration amount.
pub let beat_accel_per_sec : Float = 0.0042

///|
/// Timing window radius for a perfect hit.
pub let timing_perfect : Float = 0.07

///|
/// Timing window radius for a good hit.
pub let timing_good : Float = 0.15

///|
/// Timing window radius for a valid deflect.
pub let timing_deflect : Float = 0.20

///|
/// Miss threshold beyond the prompt deadline.
pub let timing_miss : Float = 0.28

///|
/// Starting and maximum health value.
pub let health_max : Float = 100.0

///|
/// Starting and maximum harmony value.
pub let harmony_max : Float = 100.0

///|
/// Passive health drain per second while playing.
pub let health_drain_per_sec : Float = 0.34

///|
/// Passive harmony drain per second while playing.
pub let harmony_drain_per_sec : Float = 0.48

///|
/// Extra harmony penalty for off-beat movement.
pub let offbeat_harmony_penalty : Float = 4.5

///|
/// Health penalty applied on a miss.
pub let miss_health_penalty : Float = 8.5

///|
/// Harmony penalty applied on a miss.
pub let miss_harmony_penalty : Float = 12.0

///|
/// Additional harmony loss for wrong-stance hits.
pub let mismatch_harmony_extra : Float = 3.0

///|
/// Harmony penalty paid when deflecting.
pub let deflect_harmony_penalty : Float = 4.2

///|
/// Acclaim gained from a successful deflect.
pub let deflect_acclaim_gain : Int = 8

///|
/// Base acclaim gained from a good hit.
pub let good_acclaim_gain : Int = 22

///|
/// Base acclaim gained from a perfect hit.
pub let perfect_acclaim_gain : Int = 32

///|
/// Bonus acclaim gained per combo stack.
pub let combo_acclaim_step : Int = 3

///|
/// Health restored by a successful hit.
pub let hit_health_recover : Float = 1.6

///|
/// Harmony restored by a successful hit.
pub let hit_harmony_recover : Float = 2.2

///|
/// Duration of burst focus in seconds.
pub let burst_duration : Float = 1.7

///|
/// Cooldown between burst activations in seconds.
pub let burst_cooldown : Float = 8.0

///|
/// Simulation speed multiplier during burst.
pub let burst_slow_factor : Float = 0.46

///|
/// Left x bound of the stage drawing area.
pub let stage_left : Int = 140

///|
/// Top y bound of the stage drawing area.
pub let stage_top : Int = 110

///|
/// Stage drawing width in pixels.
pub let stage_w : Int = 1320

///|
/// Stage drawing height in pixels.
pub let stage_h : Int = 740

///|
/// Horizontal pixel step per lane index.
pub let lane_step_x : Int = 220

///|
/// Vertical pixel step per lane index.
pub let lane_step_y : Int = 120


///|
/// Available stance types for player and rival.
pub(all) enum Stance {
  Spear
  Fan
  Guard
  Sleeve
} derive(Eq)

///|
/// Convert an integer index (mod 4) to the corresponding stance.
pub fn Stance::from_int(i : Int) -> Stance {
  match i % stance_count {
    0 => Spear
    1 => Fan
    2 => Guard
    _ => Sleeve
  }
}
