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
  }
}
