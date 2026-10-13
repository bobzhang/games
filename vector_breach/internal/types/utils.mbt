///|
pub fn clampf(v : Float, low : Float, high : Float) -> Float {
  if v < low {
    low
  } else if v > high {
    high
  } else {
    v
  }
}

///|
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
pub fn abs_int(v : Int32) -> Int32 {
  if v < 0 {
    -v
  } else {
    v
  }
}

///|
pub fn manhattan(x1 : Int32, y1 : Int32, x2 : Int32, y2 : Int32) -> Int32 {
  abs_int(x1 - x2) + abs_int(y1 - y2)
}

///|
pub fn direction_dx(dir : Direction) -> Int32 {
  match dir {
    North => 0
    South => 0
    East => 1
    West => -1
  }
}

///|
pub fn direction_dy(dir : Direction) -> Int32 {
  match dir {
    North => -1
    South => 1
    East => 0
    West => 0
  }
}

///|
pub fn direction_from_delta(dx : Int32, dy : Int32) -> Direction {
  if abs_int(dx) >= abs_int(dy) {
    if dx >= 0 {
      East
    } else {
      West
    }
  } else if dy >= 0 {
    South
  } else {
    North
  }
}

///|
pub fn opposite_direction(dir : Direction) -> Direction {
  match dir {
    North => South
    South => North
    East => West
    West => East
  }
}

///|
pub fn rand_next(state : Ref[UInt32]) -> UInt32 {
  let mut x = state.val
  x = x ^ (x << 13)
  x = x ^ (x >> 17)
  x = x ^ (x << 5)
  state.val = x
  x
}

///|
pub fn rand_range(state : Ref[UInt32], low : Int32, high : Int32) -> Int32 {
  if high <= low {
    return low
  }
  let r = rand_next(state)
  let range = (high - low + 1).reinterpret_as_uint()
  low + (r % range).reinterpret_as_int()
}

///|
pub fn tile_to_screen_x(gx : Int32) -> Int32 {
  grid_offset_x + gx * tile_size
}

///|
pub fn tile_to_screen_y(gy : Int32) -> Int32 {
  grid_offset_y + gy * tile_size
}

///|
pub fn screen_to_tile_x(sx : Int32) -> Int32 {
  (sx - grid_offset_x) / tile_size
}

///|
pub fn screen_to_tile_y(sy : Int32) -> Int32 {
  (sy - grid_offset_y) / tile_size
}

///|
pub fn tile_center_x(gx : Int32) -> Int32 {
  grid_offset_x + gx * tile_size + tile_size / 2
}

///|
pub fn tile_center_y(gy : Int32) -> Int32 {
  grid_offset_y + gy * tile_size + tile_size / 2
}

///|
pub fn draw_shadow_text(
  text : String,
  x : Int32,
  y : Int32,
  size : Int32,
  color : @raylib.Color,
) -> Unit {
  @draw.draw_text(text, x + 1, y + 1, size, @raylib.black)
  @draw.draw_text(text, x, y, size, color)
}

///|
pub fn draw_center_text(
  text : String,
  cx : Int32,
  y : Int32,
  size : Int32,
  color : @raylib.Color,
) -> Unit {
  let w = @draw.measure_text(text, size)
  draw_shadow_text(text, cx - w / 2, y, size, color)
}

///|
pub fn make_default_unit(
  id : Int32,
  team : UnitTeam,
  x : Int32,
  y : Int32,
) -> CombatUnit {
  let (hp, max_hp, max_heat, mech_class, enemy_type) = match team {
    Player => (5, 5, max_heat, Vanguard, Rammer)
    Enemy => (3, 3, 0, Vanguard, Rammer)
  }
  {
    id,
    active: true,
    team,
    x,
    y,
    hp,
    max_hp,
    shield: 0,
    heat: 0,
    max_heat,
    stunned: false,
    moved_this_turn: false,
    acted_this_turn: false,
    mech_class,
    enemy_type,
    intent: March(x, y),
    statuses: [],
    upgrade_tier: 0,
    orbital_used: false,
  }
}

///|
pub fn new_battle(objective : Objective) -> BattleState {
  {
    grid: Grid::new(grid_w, grid_h),
    units: [],
    turn: 1,
    phase: Battle,
    objective,
    objective_progress: 0,
    player_commands: [],
    selected_mech: 0,
    cursor_x: 0,
    cursor_y: 0,
    turn_log: [],
    anim_queue: [],
    anim_current: None,
    floating_texts: [],
    particles: [],
    rings: [],
    screen_fx: default_screen_fx(),
    mission_id: 1,
    augments: [],
    score: 0,
    combo_text: "",
    combo_timer: 0.0,
    damage_taken_this_turn: false,
    undo_stack: [],
    boss_phase: 1,
    boss_narrative_text: "",
    boss_narrative_timer: 0.0,
    boss_walls_deployed: [],
  }
}

///|
pub fn battle_has_augment(battle : BattleState, kind : AugmentKind) -> Bool {
  for i = 0; i < battle.augments.length(); i = i + 1 {
    if battle.augments[i] == kind {
      return true
    }
  }
  false
}

///|
pub fn new_anim(
  kind : AnimKind,
  unit_id : Int32,
  sx : Int32,
  sy : Int32,
  tx : Int32,
  ty : Int32,
) -> AnimState {
  {
    playing: false,
    timer: 0.0,
    kind,
    source_x: sx,
    source_y: sy,
    target_x: tx,
    target_y: ty,
    unit_id,
    alpha: 1.0,
  }
}

// ============================================================================
// Sim-level visual effect helpers (data writes to BattleState)
// ============================================================================

///|
/// Emit a hitstop (freeze frames) for the given duration in seconds.
pub fn emit_hitstop(battle : BattleState, seconds : Float) -> Unit {
  if seconds > battle.screen_fx.hitstop_timer {
    battle.screen_fx.hitstop_timer = seconds
  }
}

///|
/// Emit a camera shake.
pub fn emit_shake(battle : BattleState, intensity : Float) -> Unit {
  battle.screen_fx.shake_timer = shake_duration
  if intensity > battle.screen_fx.shake_intensity {
    battle.screen_fx.shake_intensity = intensity
  }
}

///|
/// Emit a screen flash.
pub fn emit_flash(
  battle : BattleState,
  r : Int32,
  g : Int32,
  b : Int32,
  alpha : Int32,
) -> Unit {
  battle.screen_fx.flash_timer = flash_duration
  battle.screen_fx.flash_r = r
  battle.screen_fx.flash_g = g
  battle.screen_fx.flash_b = b
  battle.screen_fx.flash_alpha = alpha
}

///|
/// Emit slow-motion effect.
pub fn emit_slowmo(battle : BattleState, seconds : Float) -> Unit {
  if seconds > battle.screen_fx.slowmo_timer {
    battle.screen_fx.slowmo_timer = seconds
  }
}

///|
/// Emit a screen tint overlay.
pub fn emit_tint(
  battle : BattleState,
  r : Int32,
  g : Int32,
  b : Int32,
  alpha : Int32,
  dur : Float,
) -> Unit {
  battle.screen_fx.tint_timer = dur
  battle.screen_fx.tint_r = r
  battle.screen_fx.tint_g = g
  battle.screen_fx.tint_b = b
  battle.screen_fx.tint_alpha = alpha
}

///|
/// Emit an expanding ring effect at grid position.
pub fn emit_ring(
  battle : BattleState,
  gx : Int32,
  gy : Int32,
  max_r : Float,
  dur : Float,
  r : Int32,
  g : Int32,
  b : Int32,
) -> Unit {
  let cx = Float::from_int(tile_center_x(gx))
  let cy = Float::from_int(tile_center_y(gy))
  battle.rings.push({
    x: cx,
    y: cy,
    radius: 0.0,
    max_radius: max_r,
    timer: 0.0,
    duration: dur,
    color_r: r,
    color_g: g,
    color_b: b,
  })
}

///|
/// Emit a floating text at grid position.
pub fn emit_float_text(
  battle : BattleState,
  gx : Int32,
  gy : Int32,
  text : String,
  r : Int32,
  g : Int32,
  b : Int32,
  sc : Float,
  gl : Bool,
) -> Unit {
  let sx = Float::from_int(tile_center_x(gx))
  let sy = Float::from_int(tile_center_y(gy)) - 30.0
  battle.floating_texts.push({
    text,
    x: sx,
    y: sy,
    timer: 0.0,
    duration: float_text_duration,
    color_r: r,
    color_g: g,
    color_b: b,
    scale: sc,
    glow: gl,
  })
}

///|
pub fn default_screen_fx() -> ScreenFX {
  {
    shake_timer: 0.0,
    shake_intensity: 0.0,
    flash_timer: 0.0,
    flash_r: 255,
    flash_g: 255,
    flash_b: 255,
    flash_alpha: 0,
    slowmo_timer: 0.0,
    pulse_timer: 0.0,
    hitstop_timer: 0.0,
    tint_timer: 0.0,
    tint_r: 0,
    tint_g: 0,
    tint_b: 0,
    tint_alpha: 0,
  }
}
