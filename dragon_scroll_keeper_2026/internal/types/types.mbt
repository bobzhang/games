///|
/// Stores runtime data for Breach.
pub(all) struct Breach {
  room : Int
  mut severity : Float
  mut raider_cd : Float
  mut ember_cd : Float

  fn new(room : Int) -> Breach
}

///|
/// Stores runtime data for Raider.
pub(all) struct Raider {
  active : Bool
  mut room : Int
  mut x : Float
  mut y : Float
  mut hp : Float
  max_hp : Float
  mut panic_t : Float
  mut attack_cd : Float

  fn new() -> Raider
}

///|
/// Stores runtime data for Flame.
pub(all) struct Flame {
  active : Bool
  room : Int
  x : Float
  y : Float
  mut intensity : Float
  mut spread_cd : Float

  fn new() -> Flame
}

///|
/// Enumerates high-level states in the game flow.
pub(all) enum GameState {
  Title
  Playing
  Paused
  GameOver
} derive(Eq)

///|
/// Stores runtime data for Keeper.
pub(all) struct Keeper {
  mut room : Int
  mut x : Float
  mut y : Float
  mut facing_x : Float
  mut facing_y : Float
  mut stamina : Float
  mut extinguisher_mode : Bool
  mut action_cd : Float
  mut shield_cd : Float
  mut shield_t : Float
  mut ink_shields : Float

  fn new() -> Keeper
}

///|
/// Aggregates all mutable state needed to run one game session.
pub(all) struct Game {
  breaches : Array[Breach]
  raiders : Array[Raider]
  flames : Array[Flame]
  keeper : Keeper
  mut state : GameState
  mut wave : Int
  mut wave_t : Float
  mut wave_goal_t : Float
  mut breach_event_cd : Float
  mut scroll_integrity : Float
  mut seal_charges : Int
  mut score : Int
  mut best_score : Int
  mut raiders_defeated : Int
  mut flames_cleared : Int
  mut seals_done : Int
  mut time_s : Float
  mut message : String
  mut message_t : Float
  mut input_x : Float
  mut input_y : Float
  mut input_action_press : Bool
  mut input_cancel_press : Bool
  mut input_shield_press : Bool
  mut input_pause_press : Bool
  mut input_restart_press : Bool

  fn new() -> Game
}

///|
/// Creates a default Breach value for a new session.
#deprecated
pub fn Breach::new(room : Int) -> Breach {
  { room, severity: 0.0, raider_cd: randf(0.8, 1.6), ember_cd: randf(0.7, 1.4) }
}

///|
/// Creates a default Raider value for a new session.
#deprecated
pub fn Raider::new() -> Raider {
  {
    active: false,
    room: 0,
    x: 0.0,
    y: 0.0,
    hp: 0.0,
    max_hp: 1.0,
    panic_t: 0.0,
    attack_cd: 0.0,
  }
}

///|
/// Creates a default Flame value for a new session.
#deprecated
pub fn Flame::new() -> Flame {
  { active: false, room: 0, x: 0.0, y: 0.0, intensity: 0.0, spread_cd: 0.0 }
}

///|
/// Creates a default Keeper value for a new session.
#deprecated
pub fn Keeper::new() -> Keeper {
  {
    room: vault_room,
    x: chamber_center_x(),
    y: chamber_center_y(),
    facing_x: 1.0,
    facing_y: 0.0,
    stamina: keeper_stamina_max,
    extinguisher_mode: false,
    action_cd: 0.0,
    shield_cd: 0.0,
    shield_t: 0.0,
    ink_shields: ink_shield_stock_start,
  }
}

///|
/// Creates a default Game value for a new session.
#deprecated
pub fn Game::new() -> Game {
  {
    breaches: Array::makei(chamber_count, fn(room) { Breach(room) }),
    raiders: Array::makei(max_raiders, fn(_i) { Raider() }),
    flames: Array::makei(max_flames, fn(_i) { Flame() }),
    keeper: Keeper(),
    state: Title,
    wave: 1,
    wave_t: 0.0,
    wave_goal_t: wave_duration(1),
    breach_event_cd: 1.4,
    scroll_integrity: scroll_integrity_max,
    seal_charges: seal_charges_start,
    score: 0,
    best_score: 0,
    raiders_defeated: 0,
    flames_cleared: 0,
    seals_done: 0,
    time_s: 0.0,
    message: "Press J to begin guarding the dragon scroll vault.",
    message_t: 99.0,
    input_x: 0.0,
    input_y: 0.0,
    input_action_press: false,
    input_cancel_press: false,
    input_shield_press: false,
    input_pause_press: false,
    input_restart_press: false,
  }
}
