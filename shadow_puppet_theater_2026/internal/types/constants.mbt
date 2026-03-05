///|
/// Width of the game window in pixels.
pub let screen_w : Int = 1600

///|
/// Height of the game window in pixels.
pub let screen_h : Int = 960

///|
/// Target frame rate used by the main loop.
pub let target_fps : Int = 120

///|
/// Minimum axis value for pose components.
pub let pose_axis_min : Int = -2

///|
/// Maximum axis value for pose components.
pub let pose_axis_max : Int = 2

///|
/// Maximum target sequence length at high stages.
pub let max_sequence_len : Int = 8

///|
/// Upper bound of the spotlight meter.
pub let spotlight_max : Float = 100.0

///|
/// Starting spotlight value for a new show.
pub let spotlight_start : Float = 78.0

///|
/// Upper bound of the excitement meter.
pub let excitement_max : Float = 100.0

///|
/// Base cue response time in early stages.
pub let cue_base_time : Float = 3.25

///|
/// Cue-time reduction per stage.
pub let cue_drop_per_stage : Float = 0.11

///|
/// Minimum cue response time at high stages.
pub let cue_min_time : Float = 1.05

///|
/// Time window for keeping combo streak alive.
pub let combo_hold_time : Float = 2.4

///|
/// Duration of the burst slow-motion effect.
pub let burst_duration : Float = 1.8

///|
/// Cooldown between burst activations.
pub let burst_cooldown : Float = 9.0

///|
/// Global simulation speed multiplier while burst is active.
pub let burst_slow_factor : Float = 0.46

///|
/// Passive spotlight drain per second.
pub let spotlight_drain : Float = 2.55

///|
/// Passive excitement drain per second.
pub let excitement_drain : Float = 3.15

///|
/// Spotlight penalty for a wrong pose lock.
pub let mistake_spotlight_loss : Float = 18.0

///|
/// Spotlight penalty for timing out a cue.
pub let timeout_spotlight_loss : Float = 24.0

///|
/// Excitement penalty for a wrong pose lock.
pub let mistake_excitement_loss : Float = 15.0

///|
/// Spotlight gain for a correct pose lock.
pub let correct_spotlight_gain : Float = 3.6

///|
/// Excitement gain for a correct pose lock.
pub let correct_excitement_gain : Float = 8.0

///|
/// X coordinate of the stage projection screen.
pub let stage_screen_x : Int = 248

///|
/// Y coordinate of the stage projection screen.
pub let stage_screen_y : Int = 126

///|
/// Width of the stage projection screen.
pub let stage_screen_w : Int = 980

///|
/// Height of the stage projection screen.
pub let stage_screen_h : Int = 682

///|
/// Returns cue response time for a stage after difficulty scaling.
pub fn cue_time_for_stage(stage : Int) -> Float {
  let raw = cue_base_time - Float::from_int(stage - 1) * cue_drop_per_stage
  if raw < cue_min_time {
    cue_min_time
  } else {
    raw
  }
}

///|
/// Returns sequence length target for a stage after difficulty scaling.
pub fn sequence_len_for_stage(stage : Int) -> Int {
  let raw = 3 + (stage - 1) / 2
  if raw > max_sequence_len {
    max_sequence_len
  } else {
    raw
  }
}
