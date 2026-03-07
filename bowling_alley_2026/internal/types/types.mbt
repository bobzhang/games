///|
/// High-level phase of a bowling run.
pub(all) enum GameState {
  Title
  Play
  Result
} derive(Eq)

///|
/// Physical state of a single pin.
pub(all) struct Pin {
  mut standing : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut ang : Float
  mut ang_v : Float

  fn new() -> Pin
}

///|
/// Pooled particle used for strike and collision effects.
pub(all) struct Spark {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut size : Float
  mut kind : Int

  fn new() -> Spark
}

///|
/// Full mutable game state for a ten-pin bowling simulation, covering
/// physics (ball and pins), standard bowling scoring, throw input
/// (aim, spin, power), UI timers, and touch/mouse input tracking.
pub(all) struct Game {
  // ──── Pin & particle pools ────
  /// Array of 10 bowling pins with physics state (position, velocity, angle).
  /// Arranged in standard triangular formation at the start of each frame.
  /// Pins with `standing = false` have been knocked down and continue to
  /// slide until they settle.
  pins : Array[Pin]
  /// Object pool of spark particles, pre-allocated to `max_sparks` (1200).
  /// Spawned on ball-pin impacts, pin-pin chain reactions, and throws.
  /// Purely cosmetic; each spark has position, velocity, lifetime, and kind.
  sparks : Array[Spark]
  // ──── Scoring data ────
  /// Flat log of knocked-pin counts for every delivery, up to `max_rolls` (24).
  /// Entry `i` holds the number of pins knocked on the i-th roll.
  /// Read by `recompute_score` to calculate running frame totals.
  rolls : Array[Int]
  /// Running cumulative score for each of the 10 frames.
  /// A value of -1 means the frame's total is not yet resolved (awaiting
  /// bonus rolls for a strike or spare). Recomputed after every scored roll.
  frame_totals : Array[Int]
  /// Number of valid entries currently stored in `rolls`.
  /// Incremented by `push_roll`; used as the upper bound when walking the
  /// roll log in `recompute_score`.
  mut roll_count : Int
  // ──── Core state ────
  /// Which screen/phase the game is currently in.
  /// Possible values: `Title`, `Play`, `Result`.
  /// The main update loop dispatches input and simulation based on this value.
  mut state : GameState
  /// Current bowling frame index, 0-based (0..9 for frames 1..10).
  /// Advanced after completing all rolls in a frame. Triggers `finalize_match`
  /// when it reaches 10.
  mut frame : Int
  /// Which roll within the current frame (0 = first, 1 = second, 2 = third
  /// in the 10th frame only). Used to determine whether a strike/spare
  /// occurred and what happens next.
  mut roll_in_frame : Int
  /// Number of pins knocked on the first roll of the current frame.
  /// Stored to detect spares (first_roll + second_roll == 10) and to
  /// handle 10th-frame bonus logic.
  mut first_roll : Int
  /// Number of pins standing just before the current delivery was thrown.
  /// Typically 10 after a reset or equal to `pins_left` from the prior roll.
  /// The difference `pins_before_roll - count_standing()` gives the knocked count.
  mut pins_before_roll : Int
  /// Number of pins currently standing (0..10). Updated in real time as
  /// pins are knocked by `knock_pin`. Read by the scoring and UI systems.
  mut pins_left : Int
  // ──── Ball physics ────
  /// Current x position of the bowling ball center, in pixels.
  /// Starts at `ball_start_x` (lane center) before each throw.
  mut ball_x : Float
  /// Current y position of the bowling ball center, in pixels.
  /// Starts at `ball_start_y` (near foul line) before each throw.
  /// Decreases as the ball travels up the lane toward the pins.
  mut ball_y : Float
  /// Current horizontal velocity of the ball, in pixels/second.
  /// Positive = rightward. Influenced by aim angle, spin drift, and
  /// lane-edge bounces. Decays via drag each frame.
  mut ball_vx : Float
  /// Current vertical velocity of the ball, in pixels/second.
  /// Negative = toward pins. Set by throw power; decays via drag.
  mut ball_vy : Float
  /// Spin factor applied to the ball after release, in the range [-1, 1].
  /// Copied from the `spin` input setting at throw time. Causes lateral
  /// drift during travel (adds 44 * spin px/s^2 to ball_vx each frame).
  mut ball_spin : Float
  /// Whether the ball is currently traveling down the lane.
  /// Set to true on throw; set to false when the ball reaches the end
  /// of the lane or slows below the speed threshold.
  mut ball_live : Bool
  // ──── Throw input state ────
  /// Whether the player is allowed to initiate a throw right now.
  /// True after `prepare_roll` sets up a new delivery; false while the
  /// ball is live or while a roll is being resolved.
  mut can_throw : Bool
  /// Whether the player is currently holding the power-charge button.
  /// Set to true on the first frame the throw key/button is held;
  /// reset to false when released (which fires the ball).
  mut charging : Bool
  /// Current throw power level, oscillating in the range [0.14, 1.0].
  /// Bounces between min and max while the player holds the charge button.
  /// Higher power = faster ball speed on release (520 + power * 780 px/s).
  mut power : Float
  /// Direction of the power oscillation: +1.0 = increasing, -1.0 = decreasing.
  /// Flips when `power` hits the upper (1.0) or lower (0.14) bound.
  mut power_dir : Float
  /// Current aim angle offset in degrees, range [`aim_min`, `aim_max`]
  /// (i.e. -36..+36). Adjusted with Left/Right keys or touch buttons.
  /// Converted to radians at throw time to set ball_vx and ball_vy.
  mut aim : Float
  /// Current spin setting in the range [`spin_min`, `spin_max`] (-1..+1).
  /// Adjusted with Q/E keys or touch buttons. Applied to `ball_spin` on throw.
  mut spin : Float
  // ──── Timers ────
  /// Countdown timer for resolving a completed delivery, in seconds.
  /// Set to ~0.42-0.52 s after the ball stops or exits the lane.
  /// While positive, the system waits for pins to settle before scoring.
  /// A value of -1 means no resolve is pending.
  mut resolve_t : Float
  /// Total elapsed game time during the current match, in seconds.
  /// Accumulates every play-state frame by `dt`. Used for UI animations.
  mut game_t : Float
  /// Accumulated UI animation time, in seconds. Advances every play frame.
  /// Used for pulsing and oscillating UI element animations.
  mut ui_t : Float
  /// Remaining duration of the screen-shake effect, in seconds.
  /// Set to ~0.08 s on each pin knock. The renderer offsets the camera
  /// while this is positive.
  mut shake_t : Float
  // ──── Status message ────
  /// Short text shown on screen (e.g. "Strike!", "Frame 3 roll 2",
  /// "Final score 180"). Set by `set_message` along with `message_t`.
  mut message : String
  /// Remaining display time for `message`, in seconds.
  /// Counts down toward 0; when non-positive the message is hidden.
  mut message_t : Float
  // ──── Match statistics ────
  /// Number of strikes rolled in the current match.
  /// Incremented when 10 pins are knocked on the first delivery of a frame.
  mut strikes : Int
  /// Number of spares rolled in the current match.
  /// Incremented when the first and second rolls of a frame total 10.
  mut spares : Int
  /// Number of open frames (neither strike nor spare) in the current match.
  /// Incremented when a non-10th frame ends without all pins knocked.
  mut opens : Int
  /// Current match score, recomputed after each scored roll using standard
  /// bowling rules (strikes and spares add bonus from subsequent rolls).
  /// Range 0..300.
  mut score : Int
  /// Highest score achieved across all matches this session.
  /// Updated whenever `score` exceeds it. Displayed on the result screen.
  mut best_score : Int
  /// Number of pins knocked on the most recent delivery.
  /// Used by the UI to display per-roll feedback. Reset to 0 at throw time.
  mut last_knock : Int
  // ──── Touch / mouse input ────
  /// Cooldown timer preventing rapid repeated touch presses, in seconds.
  /// Set to 0.18 s after a touch-triggered action; counts down to 0.
  mut touch_cd : Float
  /// Current mouse/touch x position in screen coordinates.
  /// Read each frame from raylib and used for touch-button hit testing.
  mut mouse_x : Float
  /// Current mouse/touch y position in screen coordinates.
  /// Read each frame from raylib and used for touch-button hit testing.
  mut mouse_y : Float
  /// Whether the left mouse button or primary touch is currently held.
  /// Used together with `mouse_x`/`mouse_y` for touch-button detection.
  mut mouse_hold : Bool
  /// Number of active touch points this frame (0 if no touches).
  /// Used to distinguish touch input from mouse input for button detection.
  mut touch_count : Int

  fn new() -> Game
}

///|
/// Creates a standing pin with zero velocity.
#deprecated
pub fn Pin::new() -> Pin {
  { standing: true, x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, ang: 0.0, ang_v: 0.0 }
}

///|
/// Creates an inactive spark instance for the particle pool.
#deprecated
pub fn Spark::new() -> Spark {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    life: 0.0,
    size: 0.0,
    kind: 0,
  }
}

///|
/// Creates a new game in title state with initialized pins and score buffers.
#deprecated
pub fn Game::new() -> Game {
  let pins : Array[Pin] = Array::makei(10, fn(_i) { Pin() })
  let sparks : Array[Spark] = Array::makei(max_sparks, fn(_i) { Spark() })

  {
    pins,
    sparks,
    rolls: Array::make(max_rolls, 0),
    frame_totals: Array::make(10, -1),
    roll_count: 0,
    state: Title,
    frame: 0,
    roll_in_frame: 0,
    first_roll: 0,
    pins_before_roll: 10,
    pins_left: 10,
    ball_x: ball_start_x,
    ball_y: ball_start_y,
    ball_vx: 0.0,
    ball_vy: 0.0,
    ball_spin: 0.0,
    ball_live: false,
    can_throw: false,
    charging: false,
    power: 0.22,
    power_dir: 1.0,
    aim: 0.0,
    spin: 0.0,
    resolve_t: 0.0,
    game_t: 0.0,
    ui_t: 0.0,
    shake_t: 0.0,
    message: "",
    message_t: 0.0,
    strikes: 0,
    spares: 0,
    opens: 0,
    score: 0,
    best_score: 0,
    last_knock: 0,
    touch_cd: 0.0,
    mouse_x: 0.0,
    mouse_y: 0.0,
    mouse_hold: false,
    touch_count: 0,
  }
}
