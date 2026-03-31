///|
pub(all) struct Cell {
  x : Int
  y : Int
} derive(Eq, Show)

///|
pub(all) struct Tile {
  mut kind : TileKind
  mut has_item : Bool
  mut item_kind : Int
  mut item : ItemKind?
} derive(Show)

///|
pub fn Tile::floor() -> Tile {
  { kind: Floor, has_item: false, item_kind: 0, item: None }
}

///|
pub fn Tile::wall() -> Tile {
  { kind: Wall, has_item: false, item_kind: 0, item: None }
}

///|
pub(all) struct Enemy {
  id : Int
  mut active : Bool
  kind : EnemyKind
  mut x : Int
  mut y : Int
  mut hp : Int
  max_hp : Int
  damage : Int
  mut intent : EnemyIntent
  beat_pattern : Array[Bool]
  mut pattern_idx : Int
  mut is_elite : Bool
  mut frozen_beats : Int
  mut stunned_beats : Int
} derive(Show)

///|
pub fn Enemy::new(
  id : Int,
  kind : EnemyKind,
  x : Int,
  y : Int,
  hp~ : Int,
  damage~ : Int,
  beat_pattern~ : Array[Bool],
) -> Enemy {
  {
    id,
    active: true,
    kind,
    x,
    y,
    hp,
    max_hp: hp,
    damage,
    intent: Wait,
    beat_pattern,
    pattern_idx: 0,
    is_elite: false,
    frozen_beats: 0,
    stunned_beats: 0,
  }
}

///|
pub(all) struct Weapon {
  kind : WeaponKind
  damage : Int
  range : Int
  beat_cost : Int
  name : String
} derive(Show)

///|
pub(all) struct Player {
  mut x : Int
  mut y : Int
  mut hp : Int
  mut max_hp : Int
  mut gold : Int
  mut combo : Int
  mut max_combo : Int
  mut weapon_damage : Int
  mut shield : Int
  mut special_charges : Int
  mut beat_multiplier : Float
  mut speed_boost_beats : Int
  mut beat_freeze_beats : Int
  mut weapon : WeaponKind
  mut weapon_beat_counter : Int
  abilities : Array[AbilityKind]
  mut consecutive_perfects : Int
  mut facing : Direction
  mut invincible_beats : Int
  mut double_damage_beats : Int
  mut mana : Int
  mut max_mana : Int
  spell_slots : SpellSlots
  learned_spells : Array[SpellKind]
  mut floor_attacks : Int
} derive(Show)

///|
pub fn Player::new() -> Player {
  {
    x: 1,
    y: 1,
    hp: 6,
    max_hp: 6,
    gold: 0,
    combo: 0,
    max_combo: 0,
    weapon_damage: 1,
    shield: 0,
    special_charges: 3,
    beat_multiplier: 1.0,
    speed_boost_beats: 0,
    beat_freeze_beats: 0,
    weapon: Sword,
    weapon_beat_counter: 0,
    abilities: [],
    consecutive_perfects: 0,
    facing: South,
    invincible_beats: 0,
    double_damage_beats: 0,
    mana: 10,
    max_mana: 10,
    spell_slots: SpellSlots::new(),
    learned_spells: [],
    floor_attacks: 0,
  }
}

///|
pub(all) struct Grid {
  width : Int
  height : Int
  tiles : Array[Tile]
} derive(Show)

///|
pub fn Grid::new(width : Int, height : Int) -> Grid {
  let tiles : Array[Tile] = []
  for _ in 0..<(width * height) {
    tiles.push(Tile::floor())
  }
  { width, height, tiles }
}

///|
pub(all) struct BeatState {
  mut bpm : Float
  mut beat_timer : Float
  mut beat_count : Int
  mut beat_window : Float
  mut in_window : Bool
  mut last_rating : BeatRating
  mut combo : Int
  mut max_combo : Int
  mut perfect_window : Float
  mut good_window : Float
} derive(Show)

///|
pub fn BeatState::new(bpm : Float) -> BeatState {
  {
    bpm,
    beat_timer: 0.0,
    beat_count: 0,
    beat_window: beat_window_good,
    in_window: false,
    last_rating: Miss,
    combo: 0,
    max_combo: 0,
    perfect_window: beat_window_perfect,
    good_window: beat_window_good,
  }
}

///|
pub(all) struct Floor {
  grid : Grid
  enemies : Array[Enemy]
  floor_num : Int
  exit_x : Int
  exit_y : Int
} derive(Show)

///|
pub fn Floor::new(floor_num : Int) -> Floor {
  {
    grid: Grid::new(grid_w, grid_h),
    enemies: [],
    floor_num,
    exit_x: grid_w - 2,
    exit_y: grid_h - 2,
  }
}

///|
pub(all) struct Particle {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut max_life : Float
  r : Int
  g : Int
  b : Int
  mut size : Float
} derive(Show)

///|
pub(all) struct ShopEntry {
  kind : ShopItemKind
  price : Int
  name : String
  desc : String
} derive(Show)

///|
pub(all) struct ScoreState {
  mut base_kills : Int
  mut beat_bonus : Int
  mut combo_bonus : Int
  mut floor_bonus : Int
  mut total : Int
} derive(Show)

///|
pub fn ScoreState::new() -> ScoreState {
  { base_kills: 0, beat_bonus: 0, combo_bonus: 0, floor_bonus: 0, total: 0 }
}

///|
pub(all) struct FloorThemeData {
  theme : FloorTheme
  bg_color : @raylib.Color
  floor_color : @raylib.Color
  wall_color : @raylib.Color
  accent_color : @raylib.Color
  name : String
} derive(Show)

///|
pub(all) struct ComboState {
  mut fever_active : Bool
  mut fever_beats : Int
  mut frenzy_active : Bool
  mut frenzy_beats : Int
  mut storm_triggered : Bool
  mut last_milestone : ComboMilestone
  mut milestone_flash_timer : Float
} derive(Show)

///|
pub fn ComboState::new() -> ComboState {
  {
    fever_active: false,
    fever_beats: 0,
    frenzy_active: false,
    frenzy_beats: 0,
    storm_triggered: false,
    last_milestone: NoMilestone,
    milestone_flash_timer: 0.0,
  }
}

///|
pub(all) struct MetaProgress {
  mut best_score : Int
  mut highest_combo : Int
  mut floors_cleared : Int
  mut bosses_defeated : Int
  mut total_runs : Int
  mut total_kills : Int
  mut total_perfects : Int
  unlocked_weapons : Array[WeaponKind]
  floor_mastery : Array[Int]
  run_history : Array[RunRecord]
} derive(Show)

///|
pub fn MetaProgress::new() -> MetaProgress {
  let mastery : Array[Int] = []
  for _ in 0..<max_floor {
    mastery.push(0)
  }
  {
    best_score: 0,
    highest_combo: 0,
    floors_cleared: 0,
    bosses_defeated: 0,
    total_runs: 0,
    total_kills: 0,
    total_perfects: 0,
    unlocked_weapons: [Sword],
    floor_mastery: mastery,
    run_history: [],
  }
}

///|
pub(all) struct RunRecord {
  score : Int
  max_combo : Int
  floors : Int
  weapon : WeaponKind
  grade : ScoreGrade
} derive(Show)

///|
pub(all) struct AbilityChoice {
  ability : AbilityKind
  name : String
  desc : String
} derive(Show)

// === Spell System ===

///|
pub(all) struct SpellData {
  kind : SpellKind
  element : Element
  name : String
  desc : String
  mana_cost : Int
  beat_cooldown : Int
  damage : Int
  range : Int
  aoe_radius : Int
} derive(Show)

///|
pub(all) struct SpellSlots {
  spells : Array[SpellKind?]
  mut cooldowns : Array[Int]
} derive(Show)

///|
pub fn SpellSlots::new() -> SpellSlots {
  { spells: [None, None, None, None], cooldowns: [0, 0, 0, 0] }
}

// === Curse / Run Modifier System ===

///|
pub(all) struct CurseState {
  active_curses : Array[CurseKind]
} derive(Show)

///|
pub fn CurseState::new() -> CurseState {
  { active_curses: [] }
}

// === Achievement System ===

///|
pub(all) struct Achievement {
  kind : AchievementKind
  name : String
  desc : String
  mut unlocked : Bool
} derive(Show)

///|
pub(all) struct AchievementState {
  achievements : Array[Achievement]
  toasts : Array[AchievementToast]
} derive(Show)

///|
pub(all) struct AchievementToast {
  text : String
  mut timer : Float
} derive(Show)

///|
pub fn AchievementState::new() -> AchievementState {
  let achs : Array[Achievement] = [
    { kind: FirstBlood, name: "First Blood", desc: "Kill first enemy", unlocked: false },
    { kind: Perfect10, name: "Perfect 10", desc: "10 Perfects in a row", unlocked: false },
    { kind: BossSlayer, name: "Boss Slayer", desc: "Defeat first boss", unlocked: false },
    { kind: ComboKing, name: "Combo King", desc: "Reach 50 combo", unlocked: false },
    { kind: SpeedDemon, name: "Speed Demon", desc: "Clear floor 10 under 200 beats", unlocked: false },
    { kind: Pacifist, name: "Pacifist", desc: "Clear a floor without attacking", unlocked: false },
  ]
  { achievements: achs, toasts: [] }
}

// === Visual Polish: Damage Numbers ===

///|
pub(all) struct DamageNumber {
  mut x : Float
  mut y : Float
  mut vy : Float
  mut life : Float
  value : Int
  color : @raylib.Color
} derive(Show)

// === Weapon Visual Effects ===

///|
pub(all) struct WeaponEffect {
  kind : WeaponKind
  mut x : Float
  mut y : Float
  direction : Direction
  mut timer : Float
  max_timer : Float
} derive(Show)

///|
pub fn WeaponEffect::new(
  kind : WeaponKind,
  x : Float,
  y : Float,
  direction : Direction,
) -> WeaponEffect {
  { kind, x, y, direction, timer: 0.2, max_timer: 0.2 }
}

// === Boss Phase Tracking ===

///|
pub(all) struct BossPhaseState {
  mut dragon_phase : BossPhase
  mut lich_phase : BossPhase
  mut dragon_charge_cooldown : Int
  mut lich_teleport_cooldown : Int
  mut dragon_4dir_cooldown : Int
  mut lich_double_summon : Bool
} derive(Show)

///|
pub fn BossPhaseState::new() -> BossPhaseState {
  {
    dragon_phase: Phase1,
    lich_phase: Phase1,
    dragon_charge_cooldown: 0,
    lich_teleport_cooldown: 0,
    dragon_4dir_cooldown: 0,
    lich_double_summon: false,
  }
}

// === Per-Floor Run Statistics ===

///|
pub(all) struct FloorStats {
  mut floor_num : Int
  mut enemies_killed : Int
  mut perfects_hit : Int
  mut items_collected : Int
  mut spells_cast : Int
  mut damage_taken : Int
  mut damage_dealt : Int
} derive(Show)

///|
pub fn FloorStats::new(floor_num : Int) -> FloorStats {
  {
    floor_num,
    enemies_killed: 0,
    perfects_hit: 0,
    items_collected: 0,
    spells_cast: 0,
    damage_taken: 0,
    damage_dealt: 0,
  }
}

// === Run Statistics Detail ===

///|
pub(all) struct RunStats {
  floor_history : Array[FloorStats]
  mut weapon_usage : Array[(WeaponKind, Int)]
  mut spell_usage : Array[(SpellKind, Int)]
  mut total_items : Int
  mut total_spells_cast : Int
  mut total_damage_dealt : Int
  mut total_damage_taken : Int
} derive(Show)

///|
pub fn RunStats::new() -> RunStats {
  {
    floor_history: [],
    weapon_usage: [(Sword, 0), (Spear, 0), (Whip, 0), (Hammer, 0), (Bow, 0), (Staff, 0)],
    spell_usage: [],
    total_items: 0,
    total_spells_cast: 0,
    total_damage_dealt: 0,
    total_damage_taken: 0,
  }
}

///|
pub(all) struct Game {
  mut screen : Screen
  player : Player
  beat : BeatState
  mut floor : Floor?
  mut frame_count : Int
  mut rng_state : Int
  mut score : Int
  mut floors_cleared : Int
  mut message_text : String
  mut message_timer : Float
  mut anim_timer : Float
  particles : Array[Particle]
  mut border_flash_color : @raylib.Color?
  mut border_flash_timer : Float
  mut combo_scale : Float
  mut transition_timer : Float
  mut transition_floor : Int
  mut boss_intro_timer : Float
  mut screen_shake : Float
  shop_items : Array[ShopEntry]
  mut shop_cursor : Int
  score_state : ScoreState
  mut is_boss_floor : Bool
  combo_state : ComboState
  meta : MetaProgress
  mut floor_theme : FloorThemeData?
  ability_choices : Array[AbilityChoice]
  mut ability_cursor : Int
  mut choosing_ability : Bool
  mut combo_visual_intensity : Float
  mut run_perfects : Int
  mut run_kills : Int
  curses : CurseState
  achievements : AchievementState
  damage_numbers : Array[DamageNumber]
  trail_particles : Array[Particle]
  mut pending_death_explosions : Array[(Float, Float, @raylib.Color)]
  curse_offers : Array[CurseKind]
  mut curse_cursor : Int
  mut showing_curse_offer : Bool
  mut bpm_anim_value : Float
  mut bpm_anim_target : Float
  mut bpm_anim_timer : Float
  // === Phase 5: New fields ===
  sound_queue : Array[SoundEvent]
  weapon_effects : Array[WeaponEffect]
  boss_phases : BossPhaseState
  run_stats : RunStats
  mut current_floor_stats : FloorStats
  mut weapon_switch_flash : Float
  mut floor_wipe_progress : Float
  mut boss_intro_pulse : Float
} derive(Show)

///|
pub fn Game::new() -> Game {
  {
    screen: Title,
    player: Player::new(),
    beat: BeatState::new(default_bpm),
    floor: None,
    frame_count: 0,
    rng_state: 0x2A3B4C5D,
    score: 0,
    floors_cleared: 0,
    message_text: "",
    message_timer: 0.0,
    anim_timer: 0.0,
    particles: [],
    border_flash_color: None,
    border_flash_timer: 0.0,
    combo_scale: 1.0,
    transition_timer: 0.0,
    transition_floor: 0,
    boss_intro_timer: 0.0,
    screen_shake: 0.0,
    shop_items: [],
    shop_cursor: 0,
    score_state: ScoreState::new(),
    is_boss_floor: false,
    combo_state: ComboState::new(),
    meta: MetaProgress::new(),
    floor_theme: None,
    ability_choices: [],
    ability_cursor: 0,
    choosing_ability: false,
    combo_visual_intensity: 0.0,
    run_perfects: 0,
    run_kills: 0,
    curses: CurseState::new(),
    achievements: AchievementState::new(),
    damage_numbers: [],
    trail_particles: [],
    pending_death_explosions: [],
    curse_offers: [],
    curse_cursor: 0,
    showing_curse_offer: false,
    bpm_anim_value: 0.0,
    bpm_anim_target: 0.0,
    bpm_anim_timer: 0.0,
    sound_queue: [],
    weapon_effects: [],
    boss_phases: BossPhaseState::new(),
    run_stats: RunStats::new(),
    current_floor_stats: FloorStats::new(0),
    weapon_switch_flash: 0.0,
    floor_wipe_progress: 0.0,
    boss_intro_pulse: 0.0,
  }
}
