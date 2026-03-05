///|
/// Window width in pixels.
pub let screen_w : Int = 1600

///|
/// Window height in pixels.
pub let screen_h : Int = 960

///|
/// Fixed simulation and rendering target frequency.
pub let target_fps : Int = 120

///|
/// Total number of assignable rooms.
pub let room_count : Int = 4

///|
/// Number of students managed each week.
pub let student_count : Int = 6

///|
/// Starting funds for a new run.
pub let start_funds : Float = 1650.0

///|
/// Starting school reputation for a new run.
pub let start_reputation : Float = 62.0

///|
/// Initial week length in simulation seconds.
pub let week_duration_base : Float = 36.0

///|
/// Week length decrease applied each new week.
pub let week_duration_drop : Float = 1.35

///|
/// Minimum allowed week length.
pub let week_duration_min : Float = 18.0

///|
/// Weekly fixed upkeep before growth.
pub let week_upkeep_base : Float = 220.0

///|
/// Additional weekly upkeep per week level.
pub let week_upkeep_growth : Float = 38.0

///|
/// Salary paid per student at week rollover.
pub let student_salary_weekly : Float = 52.0

///|
/// Base per-second operating cost while running.
pub let operation_cost_per_sec : Float = 5.2

///|
/// Extra operation cost scaling by week.
pub let operation_cost_week_scale : Float = 1.6

///|
/// Passive reputation decay per second.
pub let reputation_passive_drain_per_sec : Float = 0.05

///|
/// Funds spent per second for students in training.
pub let train_cost_per_sec : Float = 8.0

///|
/// Skill gain per second in training room.
pub let train_skill_gain_per_sec : Float = 2.9

///|
/// Fatigue gain per second in training room.
pub let train_fatigue_gain_per_sec : Float = 6.8

///|
/// Income per second from sparring assignments.
pub let spar_income_per_sec : Float = 13.0

///|
/// Reputation gain per second from sparring.
pub let spar_rep_gain_per_sec : Float = 0.46

///|
/// Fatigue gain per second from sparring.
pub let spar_fatigue_gain_per_sec : Float = 4.2

///|
/// Base stipend per second from defense assignments.
pub let defense_stipend_per_sec : Float = 2.6

///|
/// Week-based multiplier for defense stipend.
pub let defense_stipend_week_scale : Float = 0.24

///|
/// Fatigue gain per second from defense duty.
pub let defense_fatigue_gain_per_sec : Float = 3.0

///|
/// Fatigue recovery per second in rest room.
pub let rest_fatigue_recover_per_sec : Float = 9.5

///|
/// Maximum fatigue value for a student.
pub let fatigue_max : Float = 100.0

///|
/// Fatigue point where reputation penalties begin.
pub let fatigue_penalty_start : Float = 74.0

///|
/// Reputation loss per second above fatigue penalty threshold.
pub let fatigue_rep_penalty_per_sec : Float = 0.12

///|
/// Fatigue level that can trigger burnout incidents.
pub let burnout_threshold : Float = 99.0

///|
/// Fatigue recovery granted to all students at week end.
pub let weekly_recovery_bonus : Float = 11.0

///|
/// Initial seconds between random incidents.
pub let incident_gap_base : Float = 12.5

///|
/// Per-week reduction of incident gap.
pub let incident_gap_drop : Float = 0.52

///|
/// Minimum allowed incident gap.
pub let incident_gap_min : Float = 4.8

///|
/// Random variation applied to incident delay.
pub let incident_gap_jitter : Float = 2.2

///|
/// Base incident severity multiplier.
pub let incident_severity_base : Float = 1.0

///|
/// Additional incident severity per week.
pub let incident_severity_growth : Float = 0.23

///|
/// Duration of time-burst mode in seconds.
pub let burst_duration : Float = 2.2

///|
/// Cooldown between time-burst activations.
pub let burst_cooldown : Float = 9.0

///|
/// Simulation speed multiplier during burst mode.
pub let burst_time_multiplier : Float = 3.5

///|
/// Assignable room types for student placement.
pub(all) enum Room {
  Rest
  Train
  Sparring
  Defense
} derive(Eq)
