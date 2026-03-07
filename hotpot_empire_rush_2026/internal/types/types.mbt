///|
/// Per-frame player input state used by game logic.
pub(all) struct InputState {
  mut move_x : Int
  mut move_y : Int
  mut press_interact : Bool
  mut press_serve_cancel : Bool
  mut press_boost : Bool
  mut press_pause : Bool
  mut press_restart : Bool
  mut press_start : Bool

  fn new() -> InputState
}

///|
/// Creates a cleared input state with no active actions.
#deprecated
pub fn InputState::new() -> InputState {
  {
    move_x: 0,
    move_y: 0,
    press_interact: false,
    press_serve_cancel: false,
    press_boost: false,
    press_pause: false,
    press_restart: false,
    press_start: false,
  }
}

///|
/// Customer order specification and patience timers.
pub(all) struct Order {
  mut active : Bool
  mut id : Int
  mut broth : Int
  mut protein : Int
  mut veg : Int
  mut spice : Int
  mut patience : Float
  mut max_patience : Float
  mut pulse : Float

  fn new(id : Int) -> Order
}

///|
/// Creates an inactive order entry with the given stable id.
#deprecated
pub fn Order::new(id : Int) -> Order {
  {
    active: false,
    id,
    broth: 0,
    protein: 0,
    veg: 0,
    spice: 0,
    patience: 0.0,
    max_patience: 0.0,
    pulse: 0.0,
  }
}

///|
/// Item currently carried by the player hand.
pub(all) struct Item {
  mut kind : Ingredient
  mut flavor : Int
  mut prepped : Bool
}

///|
/// Returns an empty hand item placeholder.
pub fn Item::empty() -> Item {
  { kind: None, flavor: 0, prepped: false }
}

///|
/// Prep-board workflow state and pending output.
pub(all) struct PrepState {
  mut active : Bool
  mut kind : Ingredient
  mut flavor : Int
  mut progress : Float
  mut target : Float
  mut output_ready : Bool
  mut out_kind : Ingredient
  mut out_flavor : Int

  fn new() -> PrepState
}

///|
/// Creates a reset prep state with default timing targets.
#deprecated
pub fn PrepState::new() -> PrepState {
  {
    active: false,
    kind: None,
    flavor: 0,
    progress: 0.0,
    target: prep_target_base,
    output_ready: false,
    out_kind: None,
    out_flavor: 0,
  }
}

///|
/// Hotpot cooking state with selected ingredients and progress.
pub(all) struct PotState {
  mut broth : Int
  mut protein : Int
  mut veg : Int
  mut spice : Int
  mut cooking : Bool
  mut progress : Float
  mut target : Float
  mut ready : Bool

  fn new() -> PotState
}

///|
/// Creates an empty pot state with base cooking target.
#deprecated
pub fn PotState::new() -> PotState {
  {
    broth: -1,
    protein: -1,
    veg: -1,
    spice: 0,
    cooking: false,
    progress: 0.0,
    target: cook_target_base,
    ready: false,
  }
}

///|
/// Complete mutable state for one hotpot empire run.
/// Holds the kitchen grid, customer queue, cooking workflow,
/// scoring/combo system, boost mechanics, and HUD message state.
pub(all) struct Game {
  // ──── Sub-system state ────

  /// Per-frame player input snapshot (movement, interact, serve/cancel, boost, pause, restart).
  /// Cleared and repopulated every frame by `update_input`.
  input : InputState

  /// Fixed-size pool of customer order slots (length = `max_orders`, i.e. 6).
  /// Active orders count down their patience; timed-out orders hurt reputation.
  /// Orders are served FIFO from index 0 and shift left on removal.
  orders : Array[Order]

  /// Prep-board workflow: accepts a raw Protein or Veg from the player's hand,
  /// runs a progress timer, then holds the prepped output for collection.
  prep : PrepState

  /// Hotpot cooking state: accumulates broth, protein, veg, and spice selections,
  /// runs a cooking timer, and flags the pot as ready for serving.
  pot : PotState

  /// The single item currently carried in the player's hand.
  /// `kind == None` means the hand is empty. Used to shuttle ingredients
  /// between stations (Protein/Veg crate -> Prep -> Pot).
  hand : Item

  // ──── Core game state ────

  /// Current high-level game phase: Title, Playing, Paused, or GameOver.
  /// Determines which update and render path runs each frame.
  mut state : GameState

  /// Column index of the player's cursor on the 4x3 kitchen station grid.
  /// Range: 0..`station_cols`-1 (0..3). Moved by WASD/arrow keys.
  mut cursor_x : Int

  /// Row index of the player's cursor on the 4x3 kitchen station grid.
  /// Range: 0..`station_rows`-1 (0..2). Moved by WASD/arrow keys.
  mut cursor_y : Int

  // ──── Scoring and combo ────

  /// Cumulative score for the current run. Increases on correct serves
  /// (base + patience bonus + combo bonus) and resets to 0 on run start.
  mut score : Int

  /// Highest score achieved across all runs in this session.
  /// Persists across restarts; updated whenever `score` exceeds it.
  mut best_score : Int

  /// Current combo streak count. Incremented on each correct serve,
  /// reset to 0 on wrong serve, timeout, or queue overflow.
  /// Each combo level adds 20 bonus points to the next serve.
  mut combo : Int

  /// Remaining seconds before the combo streak expires.
  /// Set to `combo_keep_time` (4.2 s) on each successful serve;
  /// when it reaches 0 the combo counter resets to 0.
  mut combo_t : Float

  // ──── Reputation (health) ────

  /// Restaurant reputation meter, acting as the player's health.
  /// Range: 0.0..`reputation_max` (100.0). Starts at `reputation_start` (72.0).
  /// Gains on correct serves (+4.0), drops on timeouts (-9.5),
  /// wrong serves (-7.0), pot discards (-3.0), and queue overflow (-2.2).
  /// The run ends in GameOver when reputation hits 0.
  mut reputation : Float

  // ──── Boost system ────

  /// Current charge level of the speed-boost meter.
  /// Range: 0.0..`boost_meter_max` (100.0). Passively recharges at
  /// `boost_charge_per_s` (11.0/s). Consumed by `boost_cost` (35.0)
  /// when the player activates a boost, and topped up by the Rush Bell.
  mut boost_meter : Float

  /// Remaining seconds of active speed boost.
  /// While > 0 the prep and cook progress multiplier is `boost_speed_mult` (1.9x).
  /// Set to `boost_duration` (2.8 s) on activation; counts down each frame.
  mut boost_t : Float

  /// Remaining cooldown in seconds before the Rush Bell station can be used again.
  /// Set to `rush_cooldown` (7.0 s) after each bell ring. Counts down each frame.
  mut rush_cd : Float

  // ──── Order spawning ────

  /// Countdown timer in seconds until the next customer order spawns.
  /// When it reaches 0, a new order is added to the queue (or overflow
  /// pressure is applied if the queue is full). Reset to `spawn_interval(elapsed)`.
  mut spawn_cd : Float

  /// Monotonically increasing serial number assigned to each new order.
  /// Used as the order's display id. Incremented after every `spawn_order`.
  mut order_serial : Int

  // ──── Session timing and stats ────

  /// Total elapsed play time in seconds for the current run.
  /// Used to scale difficulty: order spawn rate tightens and
  /// patience windows shorten as `elapsed` grows.
  mut elapsed : Float

  /// Number of orders successfully served this run.
  /// Purely a statistics counter displayed on the HUD and game-over screen.
  mut served : Int

  /// Number of orders that failed (timed out, wrong serve, or overflow).
  /// Purely a statistics counter displayed on the HUD and game-over screen.
  mut failed : Int

  // ──── Ingredient rotation ────

  /// Index of the next protein flavor to dispense from the Protein Crate.
  /// Range: 0..`protein_count`-1 (0..2). Cycles sequentially,
  /// randomised on run start and when the Storage station is used.
  mut next_protein_pick : Int

  /// Index of the next vegetable flavor to dispense from the Veg Basket.
  /// Range: 0..`veg_count`-1 (0..2). Cycles sequentially,
  /// randomised on run start and when the Storage station is used.
  mut next_veg_pick : Int

  // ──── HUD feedback ────

  /// Current HUD message text shown to the player (e.g. station labels,
  /// serve results, error prompts). Set by `set_message` alongside `msg_t`.
  mut msg : String

  /// Remaining display lifetime in seconds for the current HUD message.
  /// Set to `msg_ttl` (2.4 s) whenever a new message is posted.
  /// Counts down each frame; message fades when this reaches 0.
  mut msg_t : Float

  /// Screen-flash timer in seconds for visual feedback on events.
  /// Set to a short duration (0.14..0.6 s) on serve success, failure,
  /// timeout, pot discard, overflow, and game over. Counts down each frame.
  mut flash_t : Float

  fn new() -> Game
}

///|
/// Creates a new game with initialized queue, meters, and stats.
#deprecated
pub fn Game::new() -> Game {
  {
    input: InputState(),
    orders: Array::makei(max_orders, fn(i) { Order(i + 1) }),
    prep: PrepState(),
    pot: PotState(),
    hand: Item::empty(),
    state: Title,
    cursor_x: 1,
    cursor_y: 1,
    score: 0,
    best_score: 0,
    combo: 0,
    combo_t: 0.0,
    reputation: reputation_start,
    boost_meter: boost_meter_max,
    boost_t: 0.0,
    rush_cd: 0.0,
    spawn_cd: 1.0,
    order_serial: 1,
    elapsed: 0.0,
    served: 0,
    failed: 0,
    next_protein_pick: 0,
    next_veg_pick: 0,
    msg: "",
    msg_t: 0.0,
    flash_t: 0.0,
  }
}
