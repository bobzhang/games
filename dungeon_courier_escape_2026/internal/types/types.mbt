///|
/// Enumerates high-level states in the game flow.
pub(all) enum GameState {
  Title
  Play
  Retry
} derive(Eq)

///|
/// Stores runtime data for Player.
pub(all) struct Player {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut facing_deg : Float
  mut health : Float
  mut stealth : Float
  mut carrying_parcel : Int
}

///|
/// Stores runtime data for Parcel.
pub(all) struct Parcel {
  mut active : Bool
  mut delivered : Bool
  mut x : Float
  mut y : Float
  mut pulse : Float
}

///|
/// Stores runtime data for ExitMarker.
pub(all) struct ExitMarker {
  active : Bool
  x : Float
  y : Float
  radius : Float
}

///|
/// Stores runtime data for Guard.
pub(all) struct Guard {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut dir_deg : Float
  mut patrol_a_x : Float
  mut patrol_a_y : Float
  mut patrol_b_x : Float
  mut patrol_b_y : Float
  mut to_b : Bool
  mut speed : Float
  mut cone_range : Float
  mut cone_half_angle : Float
  mut alert_t : Float
  mut investigate_t : Float
  mut target_x : Float
  mut target_y : Float
}

///|
/// Stores runtime data for Trap.
pub(all) struct Trap {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut radius : Float
  mut blink_t : Float
  mut cooldown : Float
}

///|
/// Stores runtime data for Smoke.
pub(all) struct Smoke {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut radius : Float
  mut life : Float
}

///|
/// Stores runtime data for InputState.
pub(all) struct InputState {
  mut move_x : Float
  mut move_y : Float
  mut interact_press : Bool
  mut smoke_press : Bool
  mut sprint_hold : Bool
  mut start_press : Bool
  mut retry_press : Bool
}

///|
/// Aggregates all mutable state needed to run one game session.
pub(all) struct Game {
  player : Player
  parcels : Array[Parcel]
  exits : Array[ExitMarker]
  guards : Array[Guard]
  traps : Array[Trap]
  smokes : Array[Smoke]
  input : InputState
  mut state : GameState
  mut wave : Int
  mut score : Int
  mut delivered_total : Int
  mut delivered_wave : Int
  mut target_deliveries : Int
  mut smoke_stock : Int
  mut time_left : Float
  mut wave_clock : Float
  mut alarm_flash : Float
  mut info_t : Float
  mut hint : String
  mut fail_reason : String
  mut best_wave : Int
}

///|
/// Creates a default Player value for a new session.
pub fn Player::new() -> Player {
  {
    x: player_spawn_x(),
    y: player_spawn_y(),
    vx: 0.0,
    vy: 0.0,
    facing_deg: -90.0,
    health: player_health_max,
    stealth: player_stealth_max,
    carrying_parcel: -1,
  }
}

///|
/// Creates a default Parcel value for a new session.
pub fn Parcel::new() -> Parcel {
  { active: false, delivered: false, x: 0.0, y: 0.0, pulse: 0.0 }
}

///|
/// Creates a default ExitMarker value for a new session.
pub fn ExitMarker::new(x : Float, y : Float) -> ExitMarker {
  { active: true, x, y, radius: exit_radius }
}

///|
/// Creates a default Guard value for a new session.
pub fn Guard::new() -> Guard {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    dir_deg: 0.0,
    patrol_a_x: 0.0,
    patrol_a_y: 0.0,
    patrol_b_x: 0.0,
    patrol_b_y: 0.0,
    to_b: true,
    speed: guard_speed_base,
    cone_range: guard_cone_range_base,
    cone_half_angle: guard_cone_half_angle_base,
    alert_t: 0.0,
    investigate_t: 0.0,
    target_x: 0.0,
    target_y: 0.0,
  }
}

///|
/// Creates a default Trap value for a new session.
pub fn Trap::new() -> Trap {
  { active: false, x: 0.0, y: 0.0, radius: 0.0, blink_t: 0.0, cooldown: 0.0 }
}

///|
/// Creates a default Smoke value for a new session.
pub fn Smoke::new() -> Smoke {
  { active: false, x: 0.0, y: 0.0, radius: smoke_radius_base, life: 0.0 }
}

///|
/// Creates a default InputState value for a new session.
pub fn InputState::new() -> InputState {
  {
    move_x: 0.0,
    move_y: 0.0,
    interact_press: false,
    smoke_press: false,
    sprint_hold: false,
    start_press: false,
    retry_press: false,
  }
}

///|
/// Creates a default Game value for a new session.
pub fn Game::new() -> Game {
  let exits = Array::makei(max_exits, fn(i) {
    let p = default_exit_pos(i)
    ExitMarker::new(p.0, p.1)
  })

  {
    player: Player::new(),
    parcels: Array::makei(max_parcels, fn(_i) { Parcel::new() }),
    exits,
    guards: Array::makei(max_guards, fn(_i) { Guard::new() }),
    traps: Array::makei(max_traps, fn(_i) { Trap::new() }),
    smokes: Array::makei(max_smokes, fn(_i) { Smoke::new() }),
    input: InputState::new(),
    state: Title,
    wave: 1,
    score: 0,
    delivered_total: 0,
    delivered_wave: 0,
    target_deliveries: wave_target_base,
    smoke_stock: smoke_stock_base,
    time_left: wave_time_base,
    wave_clock: 0.0,
    alarm_flash: 0.0,
    info_t: 0.0,
    hint: "Press Enter to start courier run",
    fail_reason: "",
    best_wave: 1,
  }
}
