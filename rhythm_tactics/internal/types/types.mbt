///|
pub(all) struct Cell {
  x : Int32
  y : Int32
} derive(Eq, Debug)

///|
pub extend Cell with Eq::{not_equal, equal}

///|
pub extend Cell with Debug::{to_repr}

///|
pub(all) struct Tile {
  mut kind : TileKind
  mut has_item : Bool
  mut item_kind : Int32
  mut item : ItemKind?
} derive(Debug)

///|
pub extend Tile with Debug::{to_repr}

///|
pub fn Tile::floor() -> Tile {
  { kind: Floor, has_item: false, item_kind: 0, item: None, }
}

///|
pub fn Tile::wall() -> Tile {
  { kind: Wall, has_item: false, item_kind: 0, item: None, }
}

///|
pub(all) struct Enemy {
  id : Int32
  mut active : Bool
  kind : EnemyKind
  mut x : Int32
  mut y : Int32
  mut hp : Int32
  max_hp : Int32
  damage : Int32
  mut intent : EnemyIntent
  beat_pattern : Array[Bool]
  mut pattern_idx : Int32
  mut is_elite : Bool
  mut frozen_beats : Int32
  mut stunned_beats : Int32
} derive(Debug)

///|
pub extend Enemy with Debug::{to_repr}

///|
pub fn Enemy::new(
  id : Int32,
  kind : EnemyKind,
  x : Int32,
  y : Int32,
  hp~ : Int32,
  damage~ : Int32,
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
  damage : Int32
  range : Int32
  beat_cost : Int32
  name : String
} derive(Debug)

///|
pub extend Weapon with Debug::{to_repr}

///|
pub(all) struct Player {
  mut x : Int32
  mut y : Int32
  mut hp : Int32
  mut max_hp : Int32
  mut gold : Int32
  mut combo : Int32
  mut max_combo : Int32
  mut weapon_damage : Int32
  mut shield : Int32
  mut special_charges : Int32
  mut beat_multiplier : Float
  mut speed_boost_beats : Int32
  mut beat_freeze_beats : Int32
  mut weapon : WeaponKind
  mut weapon_beat_counter : Int32
  abilities : Array[AbilityKind]
  mut consecutive_perfects : Int32
  mut facing : Direction
  mut invincible_beats : Int32
  mut double_damage_beats : Int32
  mut mana : Int32
  mut max_mana : Int32
  spell_slots : SpellSlots
  learned_spells : Array[SpellKind]
  mut floor_attacks : Int32
} derive(Debug)

///|
pub extend Player with Debug::{to_repr}

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
  width : Int32
  height : Int32
  tiles : Array[Tile]
} derive(Debug)

///|
pub extend Grid with Debug::{to_repr}

///|
pub fn Grid::new(width : Int32, height : Int32) -> Grid {
  let tiles : Array[Tile] = []
  for _ in 0..<(width * height) {
    tiles.push(Tile::floor())
  }
  { width, height, tiles, }
}

///|
pub(all) struct BeatState {
  mut bpm : Float
  mut beat_timer : Float
  mut beat_count : Int32
  mut beat_window : Float
  mut in_window : Bool
  mut last_rating : BeatRating
  mut combo : Int32
  mut max_combo : Int32
  mut perfect_window : Float
  mut good_window : Float
} derive(Debug)

///|
pub extend BeatState with Debug::{to_repr}

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
  floor_num : Int32
  exit_x : Int32
  exit_y : Int32
} derive(Debug)

///|
pub extend Floor with Debug::{to_repr}

///|
pub fn Floor::new(floor_num : Int32) -> Floor {
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
  r : Int32
  g : Int32
  b : Int32
  mut size : Float
} derive(Debug)

///|
pub extend Particle with Debug::{to_repr}

///|
pub(all) struct ShopEntry {
  kind : ShopItemKind
  price : Int32
  name : String
  desc : String
} derive(Debug)

///|
pub extend ShopEntry with Debug::{to_repr}

///|
pub(all) struct ScoreState {
  mut base_kills : Int32
  mut beat_bonus : Int32
  mut combo_bonus : Int32
  mut floor_bonus : Int32
  mut total : Int32
} derive(Debug)

///|
pub extend ScoreState with Debug::{to_repr}

///|
pub fn ScoreState::new() -> ScoreState {
  { base_kills: 0, beat_bonus: 0, combo_bonus: 0, floor_bonus: 0, total: 0, }
}

///|
pub(all) struct FloorThemeData {
  theme : FloorTheme
  bg_color : @raylib.Color
  floor_color : @raylib.Color
  wall_color : @raylib.Color
  accent_color : @raylib.Color
  name : String
}

///|
pub(all) struct ComboState {
  mut fever_active : Bool
  mut fever_beats : Int32
  mut frenzy_active : Bool
  mut frenzy_beats : Int32
  mut storm_triggered : Bool
  mut last_milestone : ComboMilestone
  mut milestone_flash_timer : Float
} derive(Debug)

///|
pub extend ComboState with Debug::{to_repr}

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
  mut best_score : Int32
  mut highest_combo : Int32
  mut floors_cleared : Int32
  mut bosses_defeated : Int32
  mut total_runs : Int32
  mut total_kills : Int32
  mut total_perfects : Int32
  unlocked_weapons : Array[WeaponKind]
  floor_mastery : Array[Int32]
  run_history : Array[RunRecord]
} derive(Debug)

///|
pub extend MetaProgress with Debug::{to_repr}

///|
pub fn MetaProgress::new() -> MetaProgress {
  let mastery : Array[Int32] = []
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
  score : Int32
  max_combo : Int32
  floors : Int32
  weapon : WeaponKind
  grade : ScoreGrade
} derive(Debug)

///|
pub extend RunRecord with Debug::{to_repr}

///|
pub(all) struct AbilityChoice {
  ability : AbilityKind
  name : String
  desc : String
} derive(Debug)

// === Spell System ===

///|
pub extend AbilityChoice with Debug::{to_repr}

///|
pub(all) struct SpellData {
  kind : SpellKind
  element : Element
  name : String
  desc : String
  mana_cost : Int32
  beat_cooldown : Int32
  damage : Int32
  range : Int32
  aoe_radius : Int32
} derive(Debug)

///|
pub extend SpellData with Debug::{to_repr}

///|
pub(all) struct SpellSlots {
  spells : Array[SpellKind?]
  mut cooldowns : Array[Int32]
} derive(Debug)

///|
pub extend SpellSlots with Debug::{to_repr}

///|
pub fn SpellSlots::new() -> SpellSlots {
  { spells: [None, None, None, None], cooldowns: [0, 0, 0, 0], }
}

// === Curse / Run Modifier System ===

///|
pub(all) struct CurseState {
  active_curses : Array[CurseKind]
} derive(Debug)

///|
pub extend CurseState with Debug::{to_repr}

///|
pub fn CurseState::new() -> CurseState {
  { active_curses: [], }
}

// === Achievement System ===

///|
pub(all) struct Achievement {
  kind : AchievementKind
  name : String
  desc : String
  mut unlocked : Bool
} derive(Debug)

///|
pub extend Achievement with Debug::{to_repr}

///|
pub(all) struct AchievementState {
  achievements : Array[Achievement]
  toasts : Array[AchievementToast]
} derive(Debug)

///|
pub extend AchievementState with Debug::{to_repr}

///|
pub(all) struct AchievementToast {
  text : String
  mut timer : Float
} derive(Debug)

///|
pub extend AchievementToast with Debug::{to_repr}

///|
pub fn AchievementState::new() -> AchievementState {
  let achs : Array[Achievement] = [
    {
      kind: FirstBlood,
      name: "First Blood",
      desc: "Kill first enemy",
      unlocked: false,
    },
    {
      kind: Perfect10,
      name: "Perfect 10",
      desc: "10 Perfects in a row",
      unlocked: false,
    },
    {
      kind: BossSlayer,
      name: "Boss Slayer",
      desc: "Defeat first boss",
      unlocked: false,
    },
    {
      kind: ComboKing,
      name: "Combo King",
      desc: "Reach 50 combo",
      unlocked: false,
    },
    {
      kind: SpeedDemon,
      name: "Speed Demon",
      desc: "Clear floor 10 under 200 beats",
      unlocked: false,
    },
    {
      kind: Pacifist,
      name: "Pacifist",
      desc: "Clear a floor without attacking",
      unlocked: false,
    },
  ]
  { achievements: achs, toasts: [], }
}

// === Visual Polish: Damage Numbers ===

///|
pub(all) struct DamageNumber {
  mut x : Float
  mut y : Float
  mut vy : Float
  mut life : Float
  value : Int32
  color : @raylib.Color
}

// === Weapon Visual Effects ===

///|
pub(all) struct WeaponEffect {
  kind : WeaponKind
  mut x : Float
  mut y : Float
  direction : Direction
  mut timer : Float
  max_timer : Float
} derive(Debug)

///|
pub extend WeaponEffect with Debug::{to_repr}

///|
pub fn WeaponEffect::new(
  kind : WeaponKind,
  x : Float,
  y : Float,
  direction : Direction,
) -> WeaponEffect {
  { kind, x, y, direction, timer: 0.2, max_timer: 0.2, }
}

// === Boss Phase Tracking ===

///|
pub(all) struct BossPhaseState {
  mut dragon_phase : BossPhase
  mut lich_phase : BossPhase
  mut dragon_charge_cooldown : Int32
  mut lich_teleport_cooldown : Int32
  mut dragon_4dir_cooldown : Int32
  mut lich_double_summon : Bool
} derive(Debug)

///|
pub extend BossPhaseState with Debug::{to_repr}

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
  mut floor_num : Int32
  mut enemies_killed : Int32
  mut perfects_hit : Int32
  mut items_collected : Int32
  mut spells_cast : Int32
  mut damage_taken : Int32
  mut damage_dealt : Int32
} derive(Debug)

///|
pub extend FloorStats with Debug::{to_repr}

///|
pub fn FloorStats::new(floor_num : Int32) -> FloorStats {
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
  mut weapon_usage : Array[(WeaponKind, Int32)]
  mut spell_usage : Array[(SpellKind, Int32)]
  mut total_items : Int32
  mut total_spells_cast : Int32
  mut total_damage_dealt : Int32
  mut total_damage_taken : Int32
} derive(Debug)

///|
pub extend RunStats with Debug::{to_repr}

///|
pub fn RunStats::new() -> RunStats {
  {
    floor_history: [],
    weapon_usage: [
      (Sword, 0),
      (Spear, 0),
      (Whip, 0),
      (Hammer, 0),
      (Bow, 0),
      (Staff, 0),
    ],
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
  mut frame_count : Int32
  mut rng_state : Int32
  mut score : Int32
  mut floors_cleared : Int32
  mut message_text : String
  mut message_timer : Float
  mut anim_timer : Float
  particles : Array[Particle]
  mut border_flash_color : @raylib.Color?
  mut border_flash_timer : Float
  mut combo_scale : Float
  mut transition_timer : Float
  mut transition_floor : Int32
  mut boss_intro_timer : Float
  mut screen_shake : Float
  shop_items : Array[ShopEntry]
  mut shop_cursor : Int32
  score_state : ScoreState
  mut is_boss_floor : Bool
  combo_state : ComboState
  meta : MetaProgress
  mut floor_theme : FloorThemeData?
  ability_choices : Array[AbilityChoice]
  mut ability_cursor : Int32
  mut choosing_ability : Bool
  mut combo_visual_intensity : Float
  mut run_perfects : Int32
  mut run_kills : Int32
  curses : CurseState
  achievements : AchievementState
  damage_numbers : Array[DamageNumber]
  trail_particles : Array[Particle]
  mut pending_death_explosions : Array[(Float, Float, @raylib.Color)]
  curse_offers : Array[CurseKind]
  mut curse_cursor : Int32
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
}

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

///|
/// `@raylib.Color` has no `Debug` impl, so the color-carrying structs below
/// cannot derive one. Render each color as its `(r, g, b, a)` channels.
fn color_repr(c : @raylib.Color) -> (Byte, Byte, Byte, Byte) {
  (c.r, c.g, c.b, c.a)
}

///|
pub impl Debug for FloorThemeData with fn to_repr(self) {
  Repr(
    (
      self.theme,
      color_repr(self.bg_color),
      color_repr(self.floor_color),
      color_repr(self.wall_color),
      color_repr(self.accent_color),
      self.name,
    ),
  )
}

///|
pub extend FloorThemeData with Debug::{to_repr}

///|
pub impl Debug for DamageNumber with fn to_repr(self) {
  Repr((self.x, self.y, self.vy, self.life, self.value, color_repr(self.color)))
}

///|
pub extend DamageNumber with Debug::{to_repr}
