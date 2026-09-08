///|
pub fn cosf(a : Float) -> Float {
  Float::from_double(@math.cos(a.to_double()))
}

///|
pub fn sinf(a : Float) -> Float {
  Float::from_double(@math.sin(a.to_double()))
}

///|
pub fn sqrtf(a : Float) -> Float {
  Float::from_double(a.to_double().sqrt())
}

///|
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
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
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn absi(v : Int) -> Int {
  if v < 0 {
    -v
  } else {
    v
  }
}

///|
let rng_state : Ref[Int] = { val: 12345, }

///|
pub fn seed_rng(s : Int) -> Unit {
  rng_state.val = s
}

///|
pub fn rng_next() -> Int {
  rng_state.val = rng_state.val * 1103515245 + 12345
  let v = rng_state.val / 65536
  if v < 0 {
    -v
  } else {
    v
  }
}

///|
pub fn rng_int(max : Int) -> Int {
  if max <= 0 {
    0
  } else {
    rng_next() % max
  }
}

///|
pub fn rng_float() -> Float {
  Float::from_int(rng_next() % 10000) / 10000.0
}

// Hex coordinate math - odd-r offset (flat-top hexes)

///|
pub fn hex(col : Int, row : Int) -> HexCoord {
  { col, row, }
}

///|
pub fn hex_valid(c : HexCoord, w : Int, h : Int) -> Bool {
  c.col >= 0 && c.col < w && c.row >= 0 && c.row < h
}

///|
pub fn hex_index(c : HexCoord, w : Int) -> Int {
  c.row * w + c.col
}

///|
pub fn hex_from_index(idx : Int, w : Int) -> HexCoord {
  { col: idx % w, row: idx / w, }
}

///|
pub fn hex_neighbors(c : HexCoord) -> Array[HexCoord] {
  let result : Array[HexCoord] = []
  let parity = c.row % 2
  if parity == 0 {
    // Even row
    result.push({ col: c.col + 1, row: c.row, })
    result.push({ col: c.col - 1, row: c.row, })
    result.push({ col: c.col, row: c.row - 1, })
    result.push({ col: c.col - 1, row: c.row - 1, })
    result.push({ col: c.col, row: c.row + 1, })
    result.push({ col: c.col - 1, row: c.row + 1, })
  } else {
    // Odd row
    result.push({ col: c.col + 1, row: c.row, })
    result.push({ col: c.col - 1, row: c.row, })
    result.push({ col: c.col + 1, row: c.row - 1, })
    result.push({ col: c.col, row: c.row - 1, })
    result.push({ col: c.col + 1, row: c.row + 1, })
    result.push({ col: c.col, row: c.row + 1, })
  }
  result
}

// Convert hex to cube coordinates for distance calc

///|
pub fn hex_to_cube(c : HexCoord) -> (Int, Int, Int) {
  let x = c.col - (c.row - c.row % 2) / 2
  let z = c.row
  let y = -x - z
  (x, y, z)
}

///|
pub fn hex_distance(a : HexCoord, b : HexCoord) -> Int {
  let (ax, ay, az) = hex_to_cube(a)
  let (bx, by, bz) = hex_to_cube(b)
  (absi(ax - bx) + absi(ay - by) + absi(az - bz)) / 2
}

// Convert hex to pixel position (flat-top, odd-r offset)

///|
pub fn hex_to_pixel(c : HexCoord) -> (Float, Float) {
  let size = hex_size
  let w = size * 2.0
  let h = sqrtf(3.0) * size
  let x = map_offset_x + Float::from_int(c.col) * w * 0.75 + size
  let y = if c.col % 2 == 1 {
    map_offset_y + Float::from_int(c.row) * h + h / 2.0 + h / 2.0
  } else {
    map_offset_y + Float::from_int(c.row) * h + h / 2.0
  }
  (x, y)
}

// Convert pixel to hex (approximate, find nearest)

///|
pub fn pixel_to_hex(px : Float, py : Float) -> HexCoord {
  let mut best_col = 0
  let mut best_row = 0
  let mut best_dist : Float = 999999.0
  for row in 0..<grid_height {
    for col in 0..<grid_width {
      let (hx, hy) = hex_to_pixel({ col, row, })
      let dx = px - hx
      let dy = py - hy
      let d = dx * dx + dy * dy
      if d < best_dist {
        best_dist = d
        best_col = col
        best_row = row
      }
    }
  }
  { col: best_col, row: best_row, }
}

// Line of sight check (Bresenham-like on hex grid)

///|
pub fn hex_line(a : HexCoord, b : HexCoord) -> Array[HexCoord] {
  let result : Array[HexCoord] = []
  let n = hex_distance(a, b)
  if n == 0 {
    result.push(a)
    return result
  }
  let (ax, ay) = hex_to_pixel(a)
  let (bx, by) = hex_to_pixel(b)
  for i in 0..<=n {
    let t = Float::from_int(i) / Float::from_int(n)
    let px = ax + (bx - ax) * t
    let py = ay + (by - ay) * t
    let h = pixel_to_hex(px, py)
    if result.length() == 0 ||
      ({
        let last = result[result.length() - 1]
        last.col != h.col || last.row != h.row
      }) {
      result.push(h)
    }
  }
  result
}

///|
pub fn has_line_of_sight(map : HexMap, from : HexCoord, to : HexCoord) -> Bool {
  let line = hex_line(from, to)
  let len = line.length()
  for i = 1; i < len - 1; i = i + 1 {
    let c = line[i]
    if hex_valid(c, map.width, map.height) {
      let idx = hex_index(c, map.width)
      if map.tiles[idx].terrain == Forest {
        return false
      }
    }
  }
  true
}

// Terrain cost for movement

///|
pub fn terrain_move_cost(t : Terrain) -> Int {
  match t {
    Plains => 1
    Forest => 2
    Hills => 2
    Water => 999
  }
}

// Unit stat lookups

///|
pub fn unit_base_hp(kind : UnitKind) -> Int {
  match kind {
    Infantry => 3
    Cavalry => 2
    Artillery => 2
  }
}

///|
pub fn unit_base_atk(kind : UnitKind) -> Int {
  match kind {
    Infantry => 2
    Cavalry => 3
    Artillery => 4
  }
}

///|
pub fn unit_base_move(kind : UnitKind) -> Int {
  match kind {
    Infantry => 2
    Cavalry => 4
    Artillery => 1
  }
}

///|
pub fn unit_base_range(kind : UnitKind) -> Int {
  match kind {
    Infantry => 1
    Cavalry => 1
    Artillery => 2
  }
}

///|
pub fn unit_base_sight(kind : UnitKind) -> Int {
  match kind {
    Infantry => 2
    Cavalry => 3
    Artillery => 2
  }
}

///|
pub fn unit_kind_name(kind : UnitKind) -> String {
  match kind {
    Infantry => "Infantry"
    Cavalry => "Cavalry"
    Artillery => "Artillery"
  }
}

///|
pub fn terrain_name(t : Terrain) -> String {
  match t {
    Plains => "Plains"
    Forest => "Forest"
    Hills => "Hills"
    Water => "Water"
  }
}

// Constructors

///|
pub fn unit_base_def(kind : UnitKind) -> Int {
  match kind {
    Infantry => 1
    Cavalry => 0
    Artillery => 0
  }
}

///|
pub fn new_unit(
  id : Int,
  kind : UnitKind,
  team : Team,
  col : Int,
  row : Int,
) -> GameUnit {
  let move_r = unit_base_move(kind)
  {
    id,
    pos: hex(col, row),
    kind,
    team,
    hp: unit_base_hp(kind),
    max_hp: unit_base_hp(kind),
    atk: unit_base_atk(kind),
    def: unit_base_def(kind),
    move_range: move_r,
    attack_range: unit_base_range(kind),
    sight_range: unit_base_sight(kind),
    moved: false,
    attacked: false,
    active: true,
  }
}

///|
pub fn new_tile(terrain : Terrain) -> HexTile {
  { terrain, fog_player: Hidden, unit_id: -1, has_flag: false, }
}

///|
pub fn new_hex_map(w : Int, h : Int) -> HexMap {
  let tiles : Array[HexTile] = Array::new(capacity=w * h)
  let total = w * h
  for _i in 0..<total {
    tiles.push(new_tile(Plains))
  }
  { width: w, height: h, tiles, }
}

///|
pub fn new_battle() -> Battle {
  {
    map: new_hex_map(grid_width, grid_height),
    units: [],
    phase: Select,
    selected_unit: -1,
    turn: 1,
    result: Ongoing,
    victory_condition: EliminateAll,
    move_targets: [],
    attack_targets: [],
    player_done_count: 0,
    anim_timer: 0.0,
    anim_message: "",
    next_unit_id: 0,
    attack_flash_timer: 0.0,
    attack_flash_pos: None,
    hit_shake_timer: 0.0,
    hit_shake_target: None,
    damage_popup_timer: 0.0,
    damage_popup_pos: None,
    damage_popup_value: 0,
    turn_banner_timer: 0.0,
  }
}

///|
pub fn new_campaign() -> CampaignState {
  let scores : Array[Int] = Array::new(capacity=total_campaign_levels)
  for _i in 0..<total_campaign_levels {
    scores.push(0)
  }
  {
    current_level: 0,
    levels_unlocked: 1,
    total_score: 0,
    level_scores: scores,
  }
}

///|
pub fn new_skirmish_setup() -> SkirmishSetup {
  { map_index: 0, army_size: 4, difficulty: Normal, }
}

///|
pub fn new_game() -> Game {
  {
    screen: Title,
    battle: None,
    campaign: new_campaign(),
    skirmish: new_skirmish_setup(),
    last_score: 0,
    last_turns: 0,
    last_units_remaining: 0,
    last_was_victory: false,
    frame_count: 0,
    rng: 42,
    hover_hex: None,
    scroll_y: 0.0,
    difficulty: Normal,
  }
}

// Place unit on map

///|
pub fn place_unit_on_map(battle : Battle, unit : GameUnit) -> GameUnit {
  let idx = hex_index(unit.pos, battle.map.width)
  battle.map.tiles[idx].unit_id = unit.id
  unit
}

// Remove unit from map tile

///|
pub fn remove_unit_from_map(battle : Battle, unit : GameUnit) -> GameUnit {
  let idx = hex_index(unit.pos, battle.map.width)
  if battle.map.tiles[idx].unit_id == unit.id {
    battle.map.tiles[idx].unit_id = -1
  }
  unit
}

// Get unit by id

///|
pub fn get_unit(battle : Battle, id : Int) -> GameUnit? {
  for i in 0..<battle.units.length() {
    if battle.units[i].id == id && battle.units[i].active {
      return Some(battle.units[i])
    }
  }
  None
}

// Get unit at hex

///|
pub fn get_unit_at(battle : Battle, c : HexCoord) -> GameUnit? {
  for i in 0..<battle.units.length() {
    if battle.units[i].active &&
      battle.units[i].pos.col == c.col &&
      battle.units[i].pos.row == c.row {
      return Some(battle.units[i])
    }
  }
  None
}

// Count active units for a team

///|
pub fn count_team_units(battle : Battle, team : Team) -> Int {
  let mut count = 0
  for i in 0..<battle.units.length() {
    if battle.units[i].active && battle.units[i].team == team {
      count += 1
    }
  }
  count
}

// Check if all player units have acted

///|
pub fn all_player_done(battle : Battle) -> Bool {
  for i in 0..<battle.units.length() {
    let u = battle.units[i]
    if u.active && u.team == Player && !(u.moved && u.attacked) {
      return false
    }
  }
  true
}

// Reset turn flags for a team

///|
pub fn reset_team_turn(battle : Battle, team : Team) -> Unit {
  let len = battle.units.length()
  for i = 0; i < len; i = i + 1 {
    if battle.units[i].active && battle.units[i].team == team {
      battle.units[i].moved = false
      battle.units[i].attacked = false
    }
  }
}

// Update fog of war based on player unit positions

///|
pub fn update_fog_of_war(battle : Battle) -> Unit {
  let map = battle.map
  // Set all visible to explored
  let tile_len = map.tiles.length()
  for i = 0; i < tile_len; i = i + 1 {
    if map.tiles[i].fog_player == Visible {
      map.tiles[i].fog_player = Explored
    }
  }
  // Reveal around each player unit
  let ulen = battle.units.length()
  for i = 0; i < ulen; i = i + 1 {
    let u = battle.units[i]
    if u.active && u.team == Player {
      let sight = u.sight_range
      for row in 0..<map.height {
        for col in 0..<map.width {
          let c = hex(col, row)
          if hex_distance(u.pos, c) <= sight {
            let idx = hex_index(c, map.width)
            map.tiles[idx].fog_player = Visible
          }
        }
      }
    }
  }
}

// Get terrain defense bonus

///|
pub fn terrain_def_bonus(terrain : Terrain, kind : UnitKind) -> Int {
  match (terrain, kind) {
    (Forest, Infantry) => 2
    (Forest, _) => 1
    (Hills, Artillery) => 1
    (Hills, Infantry) => 1
    (Hills, _) => 0
    _ => 0
  }
}

// Get terrain attack bonus (hills height advantage)

///|
pub fn terrain_atk_bonus(
  attacker_terrain : Terrain,
  _defender_terrain : Terrain,
) -> Int {
  match attacker_terrain {
    Hills => 1
    _ => 0
  }
}

// Get movement penalty from terrain for a unit kind

///|
pub fn terrain_move_penalty(terrain : Terrain, kind : UnitKind) -> Int {
  match (terrain, kind) {
    (Forest, Cavalry) => 1
    _ => 0
  }
}

// Artillery range bonus on hills

///|
pub fn terrain_range_bonus(terrain : Terrain, kind : UnitKind) -> Int {
  match (terrain, kind) {
    (Hills, Artillery) => 1
    _ => 0
  }
}

// Sight bonus on hills

///|
pub fn terrain_sight_bonus(terrain : Terrain) -> Int {
  match terrain {
    Hills => 1
    _ => 0
  }
}

// Get effective move range for unit

///|
pub fn effective_move_range(battle : Battle, unit : GameUnit) -> Int {
  let terrain_idx = hex_index(unit.pos, battle.map.width)
  let terrain = battle.map.tiles[terrain_idx].terrain
  let penalty = terrain_move_penalty(terrain, unit.kind)
  maxi(1, unit.move_range - penalty)
}

// Get effective attack range for unit

///|
pub fn effective_attack_range(battle : Battle, unit : GameUnit) -> Int {
  let terrain_idx = hex_index(unit.pos, battle.map.width)
  let terrain = battle.map.tiles[terrain_idx].terrain
  unit.attack_range + terrain_range_bonus(terrain, unit.kind)
}

// Get effective sight range for unit

///|
pub fn effective_sight_range(unit : GameUnit, terrain : Terrain) -> Int {
  unit.sight_range + terrain_sight_bonus(terrain)
}

// Terrain int code to enum

///|
pub fn terrain_from_int(v : Int) -> Terrain {
  match v {
    0 => Plains
    1 => Forest
    2 => Hills
    3 => Water
    _ => Plains
  }
}
