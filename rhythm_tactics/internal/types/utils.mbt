///|
pub fn grid_index(x : Int, y : Int, width : Int) -> Int {
  y * width + x
}

///|
pub fn in_bounds(x : Int, y : Int, w : Int, h : Int) -> Bool {
  x >= 0 && y >= 0 && x < w && y < h
}

///|
pub fn grid_get(grid : Grid, x : Int, y : Int) -> Tile? {
  if in_bounds(x, y, grid.width, grid.height) {
    Some(grid.tiles[grid_index(x, y, grid.width)])
  } else {
    None
  }
}

///|
pub fn grid_set_kind(grid : Grid, x : Int, y : Int, kind : TileKind) -> Unit {
  if in_bounds(x, y, grid.width, grid.height) {
    grid.tiles[grid_index(x, y, grid.width)].kind = kind
  }
}

///|
pub fn grid_is_walkable(grid : Grid, x : Int, y : Int) -> Bool {
  match grid_get(grid, x, y) {
    Some(tile) =>
      match tile.kind {
        Floor | Ice | Exit | Spike | Lava => true
        Wall | Pit => false
      }
    None => false
  }
}

///|
pub fn dir_dx(dir : Direction) -> Int {
  match dir {
    East => 1
    West => -1
    North | South => 0
  }
}

///|
pub fn dir_dy(dir : Direction) -> Int {
  match dir {
    South => 1
    North => -1
    East | West => 0
  }
}

///|
pub fn opposite_dir(dir : Direction) -> Direction {
  match dir {
    North => South
    South => North
    East => West
    West => East
  }
}

///|
pub fn rand_next(state : Ref[Int]) -> Int {
  let mut x = state.val
  x = x ^ (x << 13)
  x = x ^ (x >> 17)
  x = x ^ (x << 5)
  if x < 0 {
    x = -x
  }
  state.val = x
  x
}

///|
pub fn rand_range(state : Ref[Int], lo : Int, hi : Int) -> Int {
  if hi <= lo {
    lo
  } else {
    lo + rand_next(state) % (hi - lo + 1)
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
pub fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
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
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn tile_screen_x(gx : Int) -> Int {
  grid_offset_x + gx * tile_size
}

///|
pub fn tile_screen_y(gy : Int) -> Int {
  grid_offset_y + gy * tile_size
}

///|
pub fn manhattan_dist(x1 : Int, y1 : Int, x2 : Int, y2 : Int) -> Int {
  let dx = x1 - x2
  let dy = y1 - y2
  (if dx < 0 { -dx } else { dx }) + (if dy < 0 { -dy } else { dy })
}

///|
pub fn direction_from_to(
  fx : Int,
  fy : Int,
  tx : Int,
  ty : Int,
) -> Direction {
  let dx = tx - fx
  let dy = ty - fy
  let adx = if dx < 0 { -dx } else { dx }
  let ady = if dy < 0 { -dy } else { dy }
  if adx >= ady {
    if dx > 0 {
      East
    } else {
      West
    }
  } else if dy > 0 {
    South
  } else {
    North
  }
}

///|
pub fn has_enemy_at(enemies : Array[Enemy], x : Int, y : Int) -> Bool {
  for e in enemies {
    if e.active && e.x == x && e.y == y {
      return true
    }
  }
  false
}

///|
pub fn find_enemy_at(enemies : Array[Enemy], x : Int, y : Int) -> Int {
  for i, e in enemies {
    if e.active && e.x == x && e.y == y {
      return i
    }
  }
  -1
}

///|
pub fn game_rng(game : Game) -> Ref[Int] {
  let r : Ref[Int] = { val: game.rng_state }
  r
}

///|
pub fn sync_rng(game : Game, r : Ref[Int]) -> Unit {
  game.rng_state = r.val
}

///|
pub fn set_message(game : Game, text : String) -> Unit {
  game.message_text = text
  game.message_timer = message_duration
}

///|
pub fn tile_color(kind : TileKind) -> @raylib.Color {
  match kind {
    Floor => color_floor_base
    Wall => color_wall
    Pit => color_pit
    Spike => color_spike
    Ice => color_ice
    Exit => color_exit
    Lava => color_lava
  }
}

///|
pub fn enemy_color(kind : EnemyKind) -> @raylib.Color {
  match kind {
    Slime => @raylib.Color::new(100, 220, 80, 255)
    Skeleton => @raylib.Color::new(220, 220, 200, 255)
    Bat => @raylib.Color::new(160, 80, 200, 255)
    Dragon => @raylib.Color::new(255, 120, 40, 255)
    Mimic => @raylib.Color::new(200, 180, 50, 255)
    Golem => @raylib.Color::new(140, 140, 160, 255)
    Wraith => @raylib.Color::new(100, 180, 255, 255)
    Boss => @raylib.Color::new(255, 40, 40, 255)
    BeatDragon => @raylib.Color::new(255, 60, 0, 255)
    RhythmLich => @raylib.Color::new(120, 0, 200, 255)
  }
}

///|
pub fn rating_color(rating : BeatRating) -> @raylib.Color {
  match rating {
    Perfect => color_perfect
    Good => color_good
    Miss => color_miss
  }
}

///|
pub fn rating_text(rating : BeatRating) -> String {
  match rating {
    Perfect => "PERFECT!"
    Good => "GOOD"
    Miss => "MISS"
  }
}

///|
pub fn bpm_for_floor(floor_num : Int) -> Float {
  if floor_num <= 3 {
    bpm_floor_1_3
  } else if floor_num <= 6 {
    bpm_floor_4_6
  } else if floor_num <= 9 {
    bpm_floor_7_9
  } else {
    bpm_floor_10
  }
}

///|
pub fn perfect_window_for_floor(floor_num : Int) -> Float {
  if floor_num <= 3 {
    perfect_window_early
  } else if floor_num <= 6 {
    beat_window_perfect
  } else {
    perfect_window_late
  }
}

///|
pub fn good_window_for_floor(floor_num : Int) -> Float {
  if floor_num <= 3 {
    good_window_early
  } else if floor_num <= 6 {
    beat_window_good
  } else {
    good_window_late
  }
}

///|
pub fn is_boss_floor(floor_num : Int) -> Bool {
  floor_num == 5 || floor_num == 10
}

///|
pub fn item_color(kind : ItemKind) -> @raylib.Color {
  match kind {
    Gold(_) => color_gold
    HealthPotion => @raylib.Color::new(255, 80, 120, 255)
    ShieldOrb => @raylib.Color::new(100, 180, 255, 255)
    SpeedBoost => @raylib.Color::new(255, 255, 100, 255)
    WeaponUpgrade => @raylib.Color::new(255, 140, 40, 255)
    BeatFreeze => @raylib.Color::new(150, 220, 255, 255)
    SpecialCharge => @raylib.Color::new(200, 120, 255, 255)
    Bomb => @raylib.Color::new(255, 60, 60, 255)
  }
}

///|
pub fn shop_item_name(kind : ShopItemKind) -> String {
  match kind {
    ShopHealthPotion => "Health Potion"
    ShopShield => "Shield Orb"
    ShopWeaponUpgrade => "Weapon Upgrade"
    ShopSpecialCharge => "Special Charge"
    ShopBeatWindow => "Beat Window+"
    ShopWeapon(wk) => weapon_data(wk).name
  }
}

///|
pub fn shop_item_desc(kind : ShopItemKind) -> String {
  match kind {
    ShopHealthPotion => "Restore 3 HP"
    ShopShield => "+2 Shield"
    ShopWeaponUpgrade => "+1 Weapon Damage"
    ShopSpecialCharge => "+1 Special"
    ShopBeatWindow => "Wider beat window"
    ShopWeapon(wk) => {
      let wd = weapon_data(wk)
      "DMG:\{wd.damage} RNG:\{wd.range} CD:\{wd.beat_cost}"
    }
  }
}

///|
pub fn shop_item_price(kind : ShopItemKind) -> Int {
  match kind {
    ShopHealthPotion => price_health_potion
    ShopShield => price_shield
    ShopWeaponUpgrade => price_weapon_upgrade
    ShopSpecialCharge => price_special_charge
    ShopBeatWindow => price_beat_window
    ShopWeapon(_) => 40
  }
}

///|
pub fn make_shop_entry(kind : ShopItemKind) -> ShopEntry {
  {
    kind,
    price: shop_item_price(kind),
    name: shop_item_name(kind),
    desc: shop_item_desc(kind),
  }
}

///|
pub fn compute_score_grade(total : Int) -> ScoreGrade {
  if total >= grade_s_threshold {
    GradeS
  } else if total >= grade_a_threshold {
    GradeA
  } else if total >= grade_b_threshold {
    GradeB
  } else {
    GradeC
  }
}

///|
pub fn grade_text(grade : ScoreGrade) -> String {
  match grade {
    GradeS => "S"
    GradeA => "A"
    GradeB => "B"
    GradeC => "C"
  }
}

///|
pub fn grade_color(grade : ScoreGrade) -> @raylib.Color {
  match grade {
    GradeS => color_perfect
    GradeA => @raylib.Color::new(80, 255, 80, 255)
    GradeB => color_good
    GradeC => @raylib.Color::new(180, 180, 180, 255)
  }
}

///|
pub fn score_rating_mult(rating : BeatRating) -> Float {
  match rating {
    Perfect => score_perfect_mult
    Good => score_good_mult
    Miss => score_miss_mult
  }
}

///|
pub fn spawn_death_particles(
  game : Game,
  sx : Float,
  sy : Float,
  color : @raylib.Color,
) -> Unit {
  let rng = game_rng(game)
  for i in 0..<particle_count_death {
    let angle = Float::from_int(i) * 6.28F / Float::from_int(particle_count_death)
    let speed = 40.0F + Float::from_int(rand_range(rng, 0, 40))
    let vx = speed * cos_approx(angle)
    let vy = speed * sin_approx(angle)
    let p : Particle = {
      x: sx,
      y: sy,
      vx,
      vy,
      life: particle_life,
      max_life: particle_life,
      r: color.r.to_int(),
      g: color.g.to_int(),
      b: color.b.to_int(),
      size: 3.0F,
    }
    game.particles.push(p)
  }
  sync_rng(game, rng)
}

///|
pub fn update_particles(game : Game, dt : Float) -> Unit {
  let mut i = 0
  while i < game.particles.length() {
    let p = game.particles[i]
    p.life = p.life - dt
    if p.life <= 0.0F {
      // Remove particle by swapping with last
      let last = game.particles.length() - 1
      if i < last {
        game.particles[i] = game.particles[last]
      }
      let _ = game.particles.pop()
      // Don't increment i, check swapped particle
    } else {
      p.x = p.x + p.vx * dt
      p.y = p.y + p.vy * dt
      p.vx = p.vx * 0.95F
      p.vy = p.vy * 0.95F
      p.size = p.size * (p.life / p.max_life)
      i = i + 1
    }
  }
}

///|
pub fn cos_approx(angle : Float) -> Float {
  // Simple Taylor approximation: cos(x) ~ 1 - x^2/2 + x^4/24
  // Normalize angle to [-pi, pi]
  let mut a = angle
  while a > 3.14159F {
    a = a - 6.28318F
  }
  while a < -3.14159F {
    a = a + 6.28318F
  }
  let a2 = a * a
  let a4 = a2 * a2
  1.0F - a2 / 2.0F + a4 / 24.0F
}

///|
pub fn sin_approx(angle : Float) -> Float {
  cos_approx(angle - 1.5708F)
}

// === Weapon System ===

///|
pub fn weapon_data(kind : WeaponKind) -> Weapon {
  match kind {
    Sword => { kind: Sword, damage: 2, range: 1, beat_cost: 1, name: "Sword" }
    Spear => { kind: Spear, damage: 2, range: 2, beat_cost: 1, name: "Spear" }
    Whip => { kind: Whip, damage: 1, range: 1, beat_cost: 1, name: "Whip" }
    Hammer =>
      { kind: Hammer, damage: 4, range: 1, beat_cost: 2, name: "Hammer" }
    Bow => { kind: Bow, damage: 2, range: 3, beat_cost: 1, name: "Bow" }
    Staff => { kind: Staff, damage: 1, range: 1, beat_cost: 3, name: "Staff" }
  }
}

///|
/// Returns true if the weapon can fire this beat (respects beat_cost cadence).
pub fn weapon_can_attack(kind : WeaponKind, beat_counter : Int) -> Bool {
  let data = weapon_data(kind)
  beat_counter % data.beat_cost == 0
}

///|
/// Get the list of (dx,dy) offsets a weapon hits relative to the attacker facing a direction.
pub fn weapon_attack_cells(
  kind : WeaponKind,
  dir : Direction,
) -> Array[(Int, Int)] {
  let dx = dir_dx(dir)
  let dy = dir_dy(dir)
  match kind {
    Sword => [(dx, dy)]
    Spear => [(dx, dy), (dx * 2, dy * 2)]
    Whip => {
      // 3 tiles: forward + two diagonals beside forward
      let pdx = dir_dy(dir)
      let pdy = 0 - dir_dx(dir)
      [(dx, dy), (dx + pdx, dy + pdy), (dx - pdx, dy - pdy)]
    }
    Hammer => [(dx, dy)]
    Bow => [(dx, dy), (dx * 2, dy * 2), (dx * 3, dy * 3)]
    Staff => {
      // 3x3 AoE centered on the tile in front
      let cells : Array[(Int, Int)] = []
      for oy = -1; oy <= 1; oy = oy + 1 {
        for ox = -1; ox <= 1; ox = ox + 1 {
          cells.push((dx + ox, dy + oy))
        }
      }
      cells
    }
  }
}

///|
pub fn weapon_base_damage(kind : WeaponKind) -> Int {
  weapon_data(kind).damage
}

///|
pub fn weapon_color(kind : WeaponKind) -> @raylib.Color {
  match kind {
    Sword => @raylib.Color::new(200, 200, 220, 255)
    Spear => @raylib.Color::new(180, 160, 100, 255)
    Whip => @raylib.Color::new(160, 100, 60, 255)
    Hammer => @raylib.Color::new(180, 180, 200, 255)
    Bow => @raylib.Color::new(120, 180, 80, 255)
    Staff => @raylib.Color::new(160, 100, 255, 255)
  }
}

// === Ability System ===

///|
pub fn ability_name(kind : AbilityKind) -> String {
  match kind {
    DoubleStep => "Double Step"
    CounterAttack => "Counter Attack"
    HealBeat => "Heal Beat"
    ShadowDodge => "Shadow Dodge"
    RhythmShield => "Rhythm Shield"
  }
}

///|
pub fn ability_desc(kind : AbilityKind) -> String {
  match kind {
    DoubleStep => "Move 2 tiles on Perfect beats"
    CounterAttack => "Auto-attack enemies that miss you"
    HealBeat => "Heal 1 HP every 16 Perfect beats"
    ShadowDodge => "30% dodge chance on Good beats"
    RhythmShield => "+1 shield every 8 combo streak"
  }
}

///|
pub fn has_ability(player : Player, kind : AbilityKind) -> Bool {
  for a in player.abilities {
    if a == kind {
      return true
    }
  }
  false
}

///|
pub fn make_ability_choice(kind : AbilityKind) -> AbilityChoice {
  { ability: kind, name: ability_name(kind), desc: ability_desc(kind) }
}

// === Floor Theme System ===

///|
pub fn floor_theme(floor_num : Int) -> FloorTheme {
  if floor_num <= 2 {
    Meadow
  } else if floor_num <= 4 {
    Cave
  } else if floor_num == 5 {
    BossArena
  } else if floor_num <= 7 {
    IceDungeon
  } else if floor_num <= 9 {
    Volcano
  } else {
    FinalArena
  }
}

///|
pub fn theme_data(theme : FloorTheme) -> FloorThemeData {
  match theme {
    Meadow =>
      {
        theme,
        bg_color: @raylib.Color::new(15, 25, 15, 255),
        floor_color: @raylib.Color::new(25, 45, 25, 255),
        wall_color: @raylib.Color::new(60, 80, 50, 255),
        accent_color: @raylib.Color::new(80, 180, 80, 255),
        name: "Meadow",
      }
    Cave =>
      {
        theme,
        bg_color: @raylib.Color::new(10, 10, 18, 255),
        floor_color: @raylib.Color::new(20, 20, 35, 255),
        wall_color: @raylib.Color::new(60, 55, 70, 255),
        accent_color: @raylib.Color::new(140, 120, 160, 255),
        name: "Dark Cave",
      }
    BossArena =>
      {
        theme,
        bg_color: @raylib.Color::new(30, 10, 10, 255),
        floor_color: @raylib.Color::new(40, 20, 20, 255),
        wall_color: @raylib.Color::new(100, 40, 40, 255),
        accent_color: @raylib.Color::new(255, 60, 40, 255),
        name: "Boss Arena",
      }
    IceDungeon =>
      {
        theme,
        bg_color: @raylib.Color::new(10, 15, 30, 255),
        floor_color: @raylib.Color::new(20, 30, 55, 255),
        wall_color: @raylib.Color::new(60, 80, 120, 255),
        accent_color: @raylib.Color::new(150, 220, 255, 255),
        name: "Ice Dungeon",
      }
    Volcano =>
      {
        theme,
        bg_color: @raylib.Color::new(30, 10, 5, 255),
        floor_color: @raylib.Color::new(45, 20, 15, 255),
        wall_color: @raylib.Color::new(100, 50, 30, 255),
        accent_color: @raylib.Color::new(255, 100, 30, 255),
        name: "Volcano",
      }
    FinalArena =>
      {
        theme,
        bg_color: @raylib.Color::new(15, 5, 25, 255),
        floor_color: @raylib.Color::new(25, 10, 40, 255),
        wall_color: @raylib.Color::new(70, 30, 100, 255),
        accent_color: @raylib.Color::new(180, 60, 255, 255),
        name: "Final Arena",
      }
  }
}

///|
pub fn themed_tile_color(
  kind : TileKind,
  theme : FloorThemeData?,
) -> @raylib.Color {
  match theme {
    Some(td) =>
      match kind {
        Floor => td.floor_color
        Wall => td.wall_color
        Lava => color_lava
        _ => tile_color(kind)
      }
    None => tile_color(kind)
  }
}

// === Combo Milestone System ===

///|
pub fn check_combo_milestone(combo : Int) -> ComboMilestone {
  if combo == 50 {
    PerfectStorm
  } else if combo == 25 {
    Frenzy
  } else if combo == 10 {
    Fever
  } else {
    NoMilestone
  }
}

///|
pub fn combo_visual_level(combo : Int) -> Int {
  // 0: 0-4, 1: 5-14, 2: 15-29, 3: 30+
  if combo >= 30 {
    3
  } else if combo >= 15 {
    2
  } else if combo >= 5 {
    1
  } else {
    0
  }
}

///|
pub fn milestone_text(ms : ComboMilestone) -> String {
  match ms {
    Fever => "FEVER!"
    Frenzy => "FRENZY!"
    PerfectStorm => "PERFECT STORM!"
    NoMilestone => ""
  }
}

///|
pub fn milestone_color(ms : ComboMilestone) -> @raylib.Color {
  match ms {
    Fever => @raylib.Color::new(255, 200, 0, 255)
    Frenzy => @raylib.Color::new(255, 100, 50, 255)
    PerfectStorm => @raylib.Color::new(255, 50, 255, 255)
    NoMilestone => @raylib.white
  }
}

// === Meta Progression ===

///|
pub fn update_meta_after_run(
  meta : MetaProgress,
  score : Int,
  max_combo_val : Int,
  floors : Int,
  bosses : Int,
  kills : Int,
  perfects : Int,
  weapon : WeaponKind,
) -> Unit {
  meta.total_runs = meta.total_runs + 1
  meta.total_kills = meta.total_kills + kills
  meta.total_perfects = meta.total_perfects + perfects
  if score > meta.best_score {
    meta.best_score = score
  }
  if max_combo_val > meta.highest_combo {
    meta.highest_combo = max_combo_val
  }
  if floors > meta.floors_cleared {
    meta.floors_cleared = floors
  }
  meta.bosses_defeated = meta.bosses_defeated + bosses
  // Record run
  let grade = compute_score_grade(score)
  let record : RunRecord = { score, max_combo: max_combo_val, floors, weapon, grade }
  meta.run_history.push(record)
  // Cap history at 20
  while meta.run_history.length() > 20 {
    let _ = meta.run_history.pop()
  }
  // Unlock weapons based on floors cleared
  check_weapon_unlocks(meta, floors)
}

///|
pub fn check_weapon_unlocks(meta : MetaProgress, floors : Int) -> Unit {
  let unlocks : Array[(Int, WeaponKind)] = [
    (2, Spear), (4, Whip), (5, Hammer), (7, Bow), (10, Staff),
  ]
  for pair in unlocks {
    let (req_floor, wk) = pair
    if floors >= req_floor {
      let mut found = false
      for w in meta.unlocked_weapons {
        if w == wk {
          found = true
          break
        }
      }
      if !found {
        meta.unlocked_weapons.push(wk)
      }
    }
  }
}

///|
pub fn update_floor_mastery(
  meta : MetaProgress,
  floor_num : Int,
  perfect_pct : Int,
) -> Unit {
  if floor_num >= 1 && floor_num <= max_floor {
    let idx = floor_num - 1
    if perfect_pct > meta.floor_mastery[idx] {
      meta.floor_mastery[idx] = perfect_pct
    }
  }
}

///|
pub fn mastery_rating(pct : Int) -> String {
  if pct >= 90 {
    "S"
  } else if pct >= 70 {
    "A"
  } else if pct >= 50 {
    "B"
  } else {
    "C"
  }
}

///|
pub fn all_weapon_kinds() -> Array[WeaponKind] {
  [Sword, Spear, Whip, Hammer, Bow, Staff]
}

///|
pub fn all_ability_kinds() -> Array[AbilityKind] {
  [DoubleStep, CounterAttack, HealBeat, ShadowDodge, RhythmShield]
}
