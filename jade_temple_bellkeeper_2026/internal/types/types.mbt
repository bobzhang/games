///|
/// Bell node orbiting the shrine and storing cooldown state.
pub(all) struct Bell {
  mut x : Float
  mut y : Float
  mut cooldown : Float
  mut glow : Float
  mut charge : Float
}

///|
/// Runtime foe record for hostile spirits and relic carriers.
pub(all) struct Foe {
  mut active : Bool
  mut kind : FoeKind
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut w : Float
  mut h : Float
  mut hp : Float
  mut life : Float
  mut phase : Float
  mut shot_cd : Float
  mut reward : Int
  mut marked : Bool
}

///|
/// Runtime projectile record for bellkeeper bolts.
pub(all) struct Bolt {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut dmg : Float
  mut kind : Int
}

///|
/// Runtime spark effect record.
pub(all) struct Spark {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut size : Float
  mut kind : Int
}

///|
/// Runtime expanding ring effect record.
pub(all) struct Ring {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut r : Float
  mut life : Float
  mut kind : Int
}

///|
/// Runtime echo trail effect record.
pub(all) struct Echo {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut w : Float
  mut h : Float
  mut life : Float
  mut rot : Float
}

///|
/// Mutable hero state for movement, dashing, and damage feedback.
pub(all) struct Hero {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut w : Float
  mut h : Float
  mut angle : Float
  mut dash_cd : Float
  mut dash_t : Float
  mut invuln : Float
  mut hurt_t : Float
  mut aura_t : Float
  mut anim_t : Float
}

///|
/// High-level state machine for scene flow.
pub(all) enum GameState {
  Title
  Play
  StageClear
  GameOver
} derive(Eq)

///|
/// Global mutable game state for jade temple defense.
pub(all) struct Game {
  bells : Array[Bell]
  foes : Array[Foe]
  bolts : Array[Bolt]
  sparks : Array[Spark]
  rings : Array[Ring]
  echoes : Array[Echo]
  hero : Hero
  mut state : GameState
  mut stage : Int
  mut stage_goal : Int
  mut score : Int
  mut best_score : Int
  mut defeats : Int
  mut rescued : Int
  mut combo : Int
  mut combo_t : Float
  mut shrine_hp : Float
  mut spirit : Float
  mut time_left : Float
  mut spawn_cd : Float
  mut wave_t : Float
  mut flash_t : Float
  mut shake_t : Float
  mut result_t : Float
  mut hint_t : Float
  mut time_s : Float
  mut input_x : Float
  mut input_y : Float
  mut input_ring_press : Bool
  mut input_dash_press : Bool
  mut input_restart_press : Bool
  mut touch_mode : Bool
  mut touch_ring_prev : Bool
  mut touch_dash_prev : Bool
  mut touch_restart_prev : Bool
  mut mouse_x : Float
  mut mouse_y : Float
  mut mouse_hold : Bool
  mut touch_count : Int
}

///|
/// Creates an inactive foe record with default values.
pub fn Foe::new() -> Foe {
  {
    active: false,
    kind: Wisp,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    w: 0.0,
    h: 0.0,
    hp: 0.0,
    life: 0.0,
    phase: 0.0,
    shot_cd: 0.0,
    reward: 0,
    marked: false,
  }
}

///|
/// Creates an inactive bolt record.
pub fn Bolt::new() -> Bolt {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    life: 0.0,
    dmg: 0.0,
    kind: 0,
  }
}

///|
/// Creates an inactive spark effect record.
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
/// Creates an inactive ring effect record.
pub fn Ring::new() -> Ring {
  { active: false, x: 0.0, y: 0.0, r: 0.0, life: 0.0, kind: 0 }
}

///|
/// Creates an inactive echo effect record.
pub fn Echo::new() -> Echo {
  { active: false, x: 0.0, y: 0.0, w: 0.0, h: 0.0, life: 0.0, rot: 0.0 }
}

///|
/// Creates a hero positioned near the shrine with default stats.
pub fn Hero::new() -> Hero {
  {
    x: shrine_x(),
    y: shrine_y() + 130.0,
    vx: 0.0,
    vy: 0.0,
    w: hero_w,
    h: hero_h,
    angle: 0.0,
    dash_cd: 0.0,
    dash_t: 0.0,
    invuln: 0.0,
    hurt_t: 0.0,
    aura_t: 0.0,
    anim_t: 0.0,
  }
}

///|
/// Creates a fresh game state with pooled objects and title defaults.
pub fn Game::new() -> Game {
  let bells = Array::makei(bell_count, fn(i) {
    let p = bell_pos(i)
    { x: p.0, y: p.1, cooldown: 0.0, glow: 0.0, charge: 1.0 }
  })

  {
    bells,
    foes: Array::makei(max_foes, fn(_i) { Foe::new() }),
    bolts: Array::makei(max_bolts, fn(_i) { Bolt::new() }),
    sparks: Array::makei(max_sparks, fn(_i) { Spark::new() }),
    rings: Array::makei(max_rings, fn(_i) { Ring::new() }),
    echoes: Array::makei(max_echoes, fn(_i) { Echo::new() }),
    hero: Hero::new(),
    state: Title,
    stage: 1,
    stage_goal: stage_goal_base,
    score: 0,
    best_score: 0,
    defeats: 0,
    rescued: 0,
    combo: 0,
    combo_t: 0.0,
    shrine_hp: shrine_max_hp,
    spirit: spirit_max,
    time_left: stage_time_base,
    spawn_cd: 0.0,
    wave_t: 0.0,
    flash_t: 0.0,
    shake_t: 0.0,
    result_t: 0.0,
    hint_t: 0.0,
    time_s: 0.0,
    input_x: 0.0,
    input_y: 0.0,
    input_ring_press: false,
    input_dash_press: false,
    input_restart_press: false,
    touch_mode: false,
    touch_ring_prev: false,
    touch_dash_prev: false,
    touch_restart_prev: false,
    mouse_x: 0.0,
    mouse_y: 0.0,
    mouse_hold: false,
    touch_count: 0,
  }
}
