///|
/// Width of the game window in pixels.
pub let screen_w : Int = 1440

///|
/// Height of the game window in pixels.
pub let screen_h : Int = 900

///|
/// Target frame rate for simulation and rendering.
pub let target_fps : Int = 120

///|
/// Number of district columns in the city grid.
pub let city_cols : Int = 10

///|
/// Number of district rows in the city grid.
pub let city_rows : Int = 6

///|
/// Total number of districts in the city grid.
pub let district_count : Int = city_cols * city_rows

///|
/// X-origin of the city grid in screen pixels.
pub let city_origin_x_i : Int = 120

///|
/// Y-origin of the city grid in screen pixels.
pub let city_origin_y_i : Int = 148

///|
/// Width of one district cell in pixels.
pub let cell_w_i : Int = 116

///|
/// Height of one district cell in pixels.
pub let cell_h_i : Int = 102

///|
/// Number of suspects tracked in the case.
pub let suspect_count : Int = 4

///|
/// Number of evidence chains per suspect.
pub let chains_per_suspect : Int = 3

///|
/// Number of clues required per chain.
pub let clue_steps_per_chain : Int = 2

///|
/// Total number of clues generated for a case.
pub let clue_count : Int = suspect_count *
  chains_per_suspect *
  clue_steps_per_chain

///|
/// Maximum number of simultaneous active incidents.
pub let max_incidents : Int = 8

///|
/// Maximum trust value.
pub let trust_max : Float = 100.0

///|
/// Base per-second trust decay during play.
pub let trust_decay_base : Float = 0.95

///|
/// Case time limit in seconds.
pub let time_limit_s : Float = 210.0

///|
/// Base incident spawn interval in seconds.
pub let incident_spawn_base : Float = 4.9

///|
/// Lower bound for incident spawn interval in seconds.
pub let incident_spawn_floor : Float = 2.2

///|
/// Base countdown timer for new incidents.
pub let incident_timer_base : Float = 19.0

///|
/// Amount to reduce incident timer per severity step.
pub let incident_timer_drop : Float = 2.9

///|
/// Duration of a focus ability activation in seconds.
pub let focus_duration : Float = 1.7

///|
/// Cooldown of focus ability in seconds.
pub let focus_cooldown : Float = 7.0

///|
/// Score awarded when discovering a clue.
pub let score_clue : Int = 45

///|
/// Score awarded when completing a chain.
pub let score_chain_complete : Int = 80

///|
/// Score awarded when unlocking a suspect deduction.
pub let score_deduction_unlock : Int = 130

///|
/// Score awarded for resolving an incident.
pub let score_incident_resolve : Int = 180

///|
/// Score penalty applied for a wrong accusation.
pub let score_wrong_accuse_penalty : Int = 95

///|
/// Evidence points granted by each discovered clue.
pub let evidence_per_clue : Int = 5

///|
/// Bonus evidence points granted while focus is active.
pub let evidence_focus_bonus : Int = 3

///|
/// Number of completed chains needed to unlock deduction.
pub let deduction_chains_to_unlock : Int = 2

///|
/// Trust gain from discovering a clue.
pub let trust_gain_clue : Float = 0.9

///|
/// Trust gain from completing a chain.
pub let trust_gain_chain : Float = 1.8

///|
/// Trust gain from unlocking a deduction.
pub let trust_gain_deduction : Float = 4.2

///|
/// Trust gain from resolving an incident.
pub let trust_gain_resolve : Float = 5.4

///|
/// Trust penalty when an incident times out.
pub let trust_penalty_missed_incident : Float = 7.8

///|
/// Trust penalty for accusing the wrong suspect.
pub let trust_penalty_wrong_accuse : Float = 12.0

///|
/// Circle constant `2*pi` used by animation math.
pub let tau : Float = 6.28318530718
