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
} derive(Show)

///|
pub fn Tile::floor() -> Tile {
  { kind: Floor, has_item: false, item_kind: 0 }
}

///|
pub fn Tile::wall() -> Tile {
  { kind: Wall, has_item: false, item_kind: 0 }
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
pub(all) struct Player {
  mut x : Int
  mut y : Int
  mut hp : Int
  max_hp : Int
  mut gold : Int
  mut combo : Int
  mut max_combo : Int
  mut weapon_damage : Int
  mut shield : Int
  mut special_charges : Int
  mut beat_multiplier : Float
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
  }
}
