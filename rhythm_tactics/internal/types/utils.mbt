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
pub fn direction_from_to(fx : Int, fy : Int, tx : Int, ty : Int) -> Direction {
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
  let r : Ref[Int] = { val: game.rng_state, }
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
    ShopSpell(sk) => spell_data(sk).name
    ShopManaPotion => "Mana Potion"
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
    ShopSpell(sk) => {
      let sd = spell_data(sk)
      "\{sd.desc} [Mana:\{sd.mana_cost}]"
    }
    ShopManaPotion => "Restore 5 Mana"
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
    ShopSpell(_) => 35
    ShopManaPotion => 15
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
    let angle = Float::from_int(i) *
      6.28F /
      Float::from_int(particle_count_death)
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
    Sword => { kind: Sword, damage: 2, range: 1, beat_cost: 1, name: "Sword", }
    Spear => { kind: Spear, damage: 2, range: 2, beat_cost: 1, name: "Spear", }
    Whip => { kind: Whip, damage: 1, range: 1, beat_cost: 1, name: "Whip", }
    Hammer =>
      { kind: Hammer, damage: 4, range: 1, beat_cost: 2, name: "Hammer", }
    Bow => { kind: Bow, damage: 2, range: 3, beat_cost: 1, name: "Bow", }
    Staff => { kind: Staff, damage: 1, range: 1, beat_cost: 3, name: "Staff", }
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
  { ability: kind, name: ability_name(kind), desc: ability_desc(kind), }
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
  let record : RunRecord = {
    score,
    max_combo: max_combo_val,
    floors,
    weapon,
    grade,
  }
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
    (2, Spear),
    (4, Whip),
    (5, Hammer),
    (7, Bow),
    (10, Staff),
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

// ============================================================
// === Spell System ===
// ============================================================

///|
pub fn spell_data(kind : SpellKind) -> SpellData {
  match kind {
    Fireball =>
      {
        kind,
        element: Fire,
        name: "Fireball",
        desc: "3 dmg, 1 tile range",
        mana_cost: 3,
        beat_cooldown: 2,
        damage: 3,
        range: 1,
        aoe_radius: 0,
      }
    FrostNova =>
      {
        kind,
        element: Ice,
        name: "Frost Nova",
        desc: "1 dmg, freezes adjacent",
        mana_cost: 4,
        beat_cooldown: 3,
        damage: 1,
        range: 0,
        aoe_radius: 1,
      }
    ChainLightning =>
      {
        kind,
        element: Lightning,
        name: "Chain Lightning",
        desc: "2 dmg, chains to 3",
        mana_cost: 5,
        beat_cooldown: 3,
        damage: 2,
        range: 3,
        aoe_radius: 0,
      }
    ShadowStep =>
      {
        kind,
        element: Dark,
        name: "Shadow Step",
        desc: "Teleport to empty tile",
        mana_cost: 2,
        beat_cooldown: 2,
        damage: 0,
        range: 5,
        aoe_radius: 0,
      }
    Inferno =>
      {
        kind,
        element: Fire,
        name: "Inferno",
        desc: "3x3 area, 2 dmg",
        mana_cost: 6,
        beat_cooldown: 4,
        damage: 2,
        range: 2,
        aoe_radius: 1,
      }
    Blizzard =>
      {
        kind,
        element: Ice,
        name: "Blizzard",
        desc: "Freeze all enemies 2 beats",
        mana_cost: 7,
        beat_cooldown: 5,
        damage: 0,
        range: 99,
        aoe_radius: 99,
      }
    ThunderStrike =>
      {
        kind,
        element: Lightning,
        name: "Thunder Strike",
        desc: "5 dmg, single, stuns",
        mana_cost: 6,
        beat_cooldown: 4,
        damage: 5,
        range: 2,
        aoe_radius: 0,
      }
    VoidPulse =>
      {
        kind,
        element: Dark,
        name: "Void Pulse",
        desc: "Push adjacent enemies 2 tiles",
        mana_cost: 4,
        beat_cooldown: 3,
        damage: 1,
        range: 0,
        aoe_radius: 1,
      }
  }
}

///|
pub fn element_color(elem : Element) -> @raylib.Color {
  match elem {
    Fire => @raylib.Color::new(255, 100, 30, 255)
    Ice => @raylib.Color::new(100, 200, 255, 255)
    Lightning => @raylib.Color::new(255, 255, 100, 255)
    Dark => @raylib.Color::new(160, 80, 220, 255)
  }
}

///|
pub fn spell_color(kind : SpellKind) -> @raylib.Color {
  element_color(spell_data(kind).element)
}

///|
pub fn can_cast_spell(player : Player, slot : Int) -> Bool {
  if slot < 0 || slot >= 4 {
    return false
  }
  match player.spell_slots.spells[slot] {
    None => false
    Some(kind) => {
      let data = spell_data(kind)
      player.mana >= data.mana_cost && player.spell_slots.cooldowns[slot] <= 0
    }
  }
}

///|
pub fn equip_spell(player : Player, kind : SpellKind) -> Bool {
  // Find first empty slot
  for i in 0..<4 {
    match player.spell_slots.spells[i] {
      None => {
        player.spell_slots.spells[i] = Some(kind)
        return true
      }
      _ => continue
    }
  }
  false
}

///|
pub fn has_spell(player : Player, kind : SpellKind) -> Bool {
  for s in player.learned_spells {
    if s == kind {
      return true
    }
  }
  false
}

///|
pub fn all_spell_kinds() -> Array[SpellKind] {
  [
    Fireball,
    FrostNova,
    ChainLightning,
    ShadowStep,
    Inferno,
    Blizzard,
    ThunderStrike,
    VoidPulse,
  ]
}

///|
pub fn tick_spell_cooldowns(player : Player) -> Unit {
  for i in 0..<4 {
    if player.spell_slots.cooldowns[i] > 0 {
      player.spell_slots.cooldowns[i] = player.spell_slots.cooldowns[i] - 1
    }
  }
}

// ============================================================
// === Elite Enemy System ===
// ============================================================

///|
pub fn make_elite(enemy : Enemy) -> Unit {
  enemy.is_elite = true
  enemy.hp = enemy.hp * elite_hp_mult
  // max_hp is immutable, but we track elite via is_elite flag
}

///|
pub fn should_spawn_elite(floor_num : Int, rng : Ref[Int]) -> Bool {
  if floor_num < elite_floor_threshold {
    return false
  }
  let chance = 10 + (floor_num - elite_floor_threshold) * 5
  let roll = rand_range(rng, 0, 99)
  roll < chance
}

///|
pub fn elite_suffix(kind : EnemyKind) -> String {
  match kind {
    Slime => "Splits on death"
    Skeleton => "Cross attack"
    Bat => "Double move"
    Dragon => "Line breath"
    _ => "Enhanced"
  }
}

// ============================================================
// === Curse / Run Modifier System ===
// ============================================================

///|
pub fn curse_name(kind : CurseKind) -> String {
  match kind {
    DoubleTime => "Double Time"
    GlassCannon => "Glass Cannon"
    BlindBeat => "Blind Beat"
    Swarm => "Swarm"
  }
}

///|
pub fn curse_desc(kind : CurseKind) -> String {
  match kind {
    DoubleTime => "BPM +20%, but +50% score"
    GlassCannon => "2x damage dealt, 1 HP max"
    BlindBeat => "Beat hidden, Perfect +50ms"
    Swarm => "2x enemies, 2x drops"
  }
}

///|
pub fn has_curse(curses : CurseState, kind : CurseKind) -> Bool {
  for c in curses.active_curses {
    if c == kind {
      return true
    }
  }
  false
}

///|
pub fn curse_color(kind : CurseKind) -> @raylib.Color {
  match kind {
    DoubleTime => @raylib.Color::new(255, 180, 40, 255)
    GlassCannon => @raylib.Color::new(255, 60, 60, 255)
    BlindBeat => @raylib.Color::new(100, 100, 180, 255)
    Swarm => @raylib.Color::new(80, 200, 80, 255)
  }
}

///|
pub fn all_curse_kinds() -> Array[CurseKind] {
  [DoubleTime, GlassCannon, BlindBeat, Swarm]
}

// ============================================================
// === Achievement System ===
// ============================================================

///|
pub fn check_achievement(
  state : AchievementState,
  kind : AchievementKind,
) -> Bool {
  for a in state.achievements {
    if a.kind == kind && !a.unlocked {
      a.unlocked = true
      state.toasts.push({ text: "Achievement: " + a.name, timer: 3.0, })
      return true
    }
  }
  false
}

///|
pub fn is_achievement_unlocked(
  state : AchievementState,
  kind : AchievementKind,
) -> Bool {
  for a in state.achievements {
    if a.kind == kind {
      return a.unlocked
    }
  }
  false
}

///|
pub fn update_achievement_toasts(state : AchievementState, dt : Float) -> Unit {
  let mut i = 0
  while i < state.toasts.length() {
    state.toasts[i].timer = state.toasts[i].timer - dt
    if state.toasts[i].timer <= 0.0 {
      let last = state.toasts.length() - 1
      if i < last {
        state.toasts[i] = state.toasts[last]
      }
      let _ = state.toasts.pop()
    } else {
      i = i + 1
    }
  }
}

// ============================================================
// === Damage Numbers ===
// ============================================================

///|
pub fn spawn_damage_number(
  game : Game,
  x : Float,
  y : Float,
  value : Int,
  rating : BeatRating,
) -> Unit {
  let color = match rating {
    Perfect => color_perfect
    Good => color_good
    Miss => color_miss
  }
  let dn : DamageNumber = {
    x,
    y,
    vy: -damage_number_speed,
    life: damage_number_life,
    value,
    color,
  }
  game.damage_numbers.push(dn)
}

///|
pub fn update_damage_numbers(game : Game, dt : Float) -> Unit {
  let mut i = 0
  while i < game.damage_numbers.length() {
    let dn = game.damage_numbers[i]
    dn.life = dn.life - dt
    if dn.life <= 0.0 {
      let last = game.damage_numbers.length() - 1
      if i < last {
        game.damage_numbers[i] = game.damage_numbers[last]
      }
      let _ = game.damage_numbers.pop()
    } else {
      dn.y = dn.y + dn.vy * dt
      dn.vy = dn.vy * 0.95
      i = i + 1
    }
  }
}

// ============================================================
// === Trail Particles (player movement on beat) ===
// ============================================================

///|
pub fn spawn_trail_particles(game : Game, sx : Float, sy : Float) -> Unit {
  let rng = game_rng(game)
  for _ in 0..<trail_particle_count {
    let angle = Float::from_int(rand_range(rng, 0, 628)) / 100.0F
    let speed = 15.0F + Float::from_int(rand_range(rng, 0, 20))
    let p : Particle = {
      x: sx,
      y: sy,
      vx: speed * cos_approx(angle),
      vy: speed * sin_approx(angle),
      life: trail_particle_life,
      max_life: trail_particle_life,
      r: 80,
      g: 200,
      b: 255,
      size: 2.0F,
    }
    game.trail_particles.push(p)
  }
  sync_rng(game, rng)
}

///|
pub fn update_trail_particles(game : Game, dt : Float) -> Unit {
  let mut i = 0
  while i < game.trail_particles.length() {
    let p = game.trail_particles[i]
    p.life = p.life - dt
    if p.life <= 0.0 {
      let last = game.trail_particles.length() - 1
      if i < last {
        game.trail_particles[i] = game.trail_particles[last]
      }
      let _ = game.trail_particles.pop()
    } else {
      p.x = p.x + p.vx * dt
      p.y = p.y + p.vy * dt
      p.vx = p.vx * 0.9
      p.vy = p.vy * 0.9
      p.size = 2.0 * (p.life / p.max_life)
      i = i + 1
    }
  }
}

// ============================================================
// === Beat-synced death explosion ===
// ============================================================

///|
pub fn queue_death_explosion(
  game : Game,
  sx : Float,
  sy : Float,
  color : @raylib.Color,
) -> Unit {
  game.pending_death_explosions.push((sx, sy, color))
}

///|
pub fn flush_death_explosions(game : Game) -> Unit {
  for explosion in game.pending_death_explosions {
    let (sx, sy, color) = explosion
    spawn_death_particles(game, sx, sy, color)
  }
  game.pending_death_explosions.clear()
}

///|
pub fn screen_pulse_for_bpm(bpm : Float) -> Float {
  // Faster BPM = more intense screen pulse (0.5 at 100, 1.0 at 160+)
  clampf((bpm - 80.0) / 80.0, 0.3, 1.2)
}

// ============================================================
// === Spell Cast Particles ===
// ============================================================

///|
pub fn spawn_spell_particles(
  game : Game,
  sx : Float,
  sy : Float,
  element : Element,
) -> Unit {
  let (r, g, b) = match element {
    Fire => (255, 100, 30)
    Ice => (100, 200, 255)
    Lightning => (255, 255, 100)
    Dark => (160, 80, 220)
  }
  let rng = game_rng(game)
  let count = 8
  for i in 0..<count {
    let angle = Float::from_int(i) * 6.28F / Float::from_int(count)
    let speed = 30.0F + Float::from_int(rand_range(rng, 0, 30))
    let p : Particle = {
      x: sx,
      y: sy,
      vx: speed * cos_approx(angle),
      vy: speed * sin_approx(angle),
      life: 0.5F,
      max_life: 0.5F,
      r,
      g,
      b,
      size: 3.0F,
    }
    game.particles.push(p)
  }
  sync_rng(game, rng)
}

// ============================================================
// === Enhanced Death Explosion (more particles for bosses) ===
// ============================================================

///|
pub fn spawn_boss_death_particles(
  game : Game,
  sx : Float,
  sy : Float,
  color : @raylib.Color,
) -> Unit {
  let rng = game_rng(game)
  let count = 30
  for i in 0..<count {
    let angle = Float::from_int(i) * 6.28F / Float::from_int(count)
    let speed = 60.0F + Float::from_int(rand_range(rng, 0, 80))
    let vx = speed * cos_approx(angle)
    let vy = speed * sin_approx(angle)
    let p : Particle = {
      x: sx,
      y: sy,
      vx,
      vy,
      life: 1.0F,
      max_life: 1.0F,
      r: color.r.to_int(),
      g: color.g.to_int(),
      b: color.b.to_int(),
      size: 4.0F,
    }
    game.particles.push(p)
  }
  // Add secondary ring
  for i in 0..<20 {
    let angle = Float::from_int(i) * 6.28F / 20.0F
    let speed = 100.0F + Float::from_int(rand_range(rng, 0, 40))
    let p : Particle = {
      x: sx,
      y: sy,
      vx: speed * cos_approx(angle),
      vy: speed * sin_approx(angle),
      life: 0.7F,
      max_life: 0.7F,
      r: 255,
      g: 255,
      b: 200,
      size: 2.0F,
    }
    game.particles.push(p)
  }
  sync_rng(game, rng)
}

// ============================================================
// === Spell Cast Flash Effect ===
// ============================================================

///|
pub fn spell_border_flash(game : Game, element : Element) -> Unit {
  let color = element_color(element)
  game.border_flash_color = Some(color)
  game.border_flash_timer = 0.3
}

// ============================================================
// === Player Direction Arrow Character ===
// ============================================================

///|
pub fn direction_arrow(dir : Direction) -> String {
  match dir {
    North => "^"
    South => "v"
    East => ">"
    West => "<"
  }
}

// ============================================================
// === Mana Cost Color ===
// ============================================================

///|
pub fn mana_cost_affordable(player : Player, cost : Int) -> Bool {
  player.mana >= cost
}

// ============================================================
// === Enemy Threat Level (for UI display) ===
// ============================================================

///|
pub fn enemy_threat_level(enemy : Enemy) -> String {
  let base = enemy.max_hp * enemy.damage
  let elite_mult = if enemy.is_elite { 2 } else { 1 }
  let threat = base * elite_mult
  if threat >= 20 {
    "!!!"
  } else if threat >= 10 {
    "!!"
  } else if threat >= 5 {
    "!"
  } else {
    ""
  }
}

// ============================================================
// === Floor Theme ambient sound hint (visual text) ===
// ============================================================

///|
pub fn theme_ambient_text(theme : FloorTheme) -> String {
  match theme {
    Meadow => "Birds chirp to the beat..."
    Cave => "Echoes reverberate..."
    BossArena => "The ground trembles..."
    IceDungeon => "Crystals hum..."
    Volcano => "Lava bubbles rhythmically..."
    FinalArena => "Reality bends to the music..."
  }
}

// ============================================================
// === Combo encouragement text ===
// ============================================================

///|
pub fn combo_encouragement(combo : Int) -> String {
  if combo >= 40 {
    "UNSTOPPABLE!"
  } else if combo >= 30 {
    "LEGENDARY!"
  } else if combo >= 20 {
    "INCREDIBLE!"
  } else if combo >= 10 {
    "GREAT!"
  } else if combo >= 5 {
    "NICE!"
  } else {
    ""
  }
}

// ============================================================
// === Spell Slot Summary ===
// ============================================================

///|
pub fn spell_slot_summary(player : Player) -> String {
  let mut result = ""
  for i in 0..<4 {
    if result.length() > 0 {
      result = result + " | "
    }
    match player.spell_slots.spells[i] {
      None => result = result + "\{i + 1}:---"
      Some(kind) => {
        let data = spell_data(kind)
        let cd = player.spell_slots.cooldowns[i]
        if cd > 0 {
          result = result + "\{i + 1}:\{data.name}[CD\{cd}]"
        } else if player.mana >= data.mana_cost {
          result = result + "\{i + 1}:\{data.name}*"
        } else {
          result = result + "\{i + 1}:\{data.name}"
        }
      }
    }
  }
  result
}

// ============================================================
// === Curse Risk/Reward Summary ===
// ============================================================

///|
pub fn curse_risk_text(kind : CurseKind) -> String {
  match kind {
    DoubleTime => "RISK: Faster beats  |  REWARD: +50% score"
    GlassCannon => "RISK: 1 HP max  |  REWARD: 2x damage"
    BlindBeat => "RISK: Beat hidden  |  REWARD: Wider Perfect"
    Swarm => "RISK: 2x enemies  |  REWARD: 2x drops"
  }
}

// ============================================================
// === Run Statistics Summary ===
// ============================================================

///|
pub fn run_stats_summary(
  floors : Int,
  kills : Int,
  perfects : Int,
  max_combo_val : Int,
  score : Int,
) -> String {
  let grade = compute_score_grade(score)
  "F\{floors} K\{kills} P\{perfects} C\{max_combo_val} = \{grade_text(grade)}"
}

// ============================================================
// === Floor difficulty estimation ===
// ============================================================

///|
pub fn floor_difficulty_text(floor_num : Int) -> String {
  if floor_num <= 2 {
    "Easy"
  } else if floor_num <= 4 {
    "Normal"
  } else if floor_num == 5 {
    "BOSS"
  } else if floor_num <= 7 {
    "Hard"
  } else if floor_num <= 9 {
    "Very Hard"
  } else {
    "EXTREME"
  }
}

///|
pub fn floor_difficulty_color(floor_num : Int) -> @raylib.Color {
  if floor_num <= 2 {
    @raylib.Color::new(80, 200, 80, 255)
  } else if floor_num <= 4 {
    @raylib.Color::new(200, 200, 80, 255)
  } else if floor_num == 5 {
    @raylib.Color::new(255, 80, 40, 255)
  } else if floor_num <= 7 {
    @raylib.Color::new(255, 140, 40, 255)
  } else if floor_num <= 9 {
    @raylib.Color::new(255, 60, 60, 255)
  } else {
    @raylib.Color::new(200, 40, 255, 255)
  }
}

// ============================================================
// === Sound Event Queue System ===
// ============================================================

///|
pub fn push_sound(game : Game, event : SoundEvent) -> Unit {
  game.sound_queue.push(event)
}

///|
pub fn clear_sound_queue(game : Game) -> Unit {
  game.sound_queue.clear()
}

///|
pub fn drain_sound_queue(game : Game) -> Array[SoundEvent] {
  let result : Array[SoundEvent] = []
  for ev in game.sound_queue {
    result.push(ev)
  }
  game.sound_queue.clear()
  result
}

// ============================================================
// === Weapon Visual Effects ===
// ============================================================

///|
pub fn spawn_weapon_effect(
  game : Game,
  kind : WeaponKind,
  x : Float,
  y : Float,
  dir : Direction,
) -> Unit {
  let effect = WeaponEffect::new(kind, x, y, dir)
  game.weapon_effects.push(effect)
}

///|
pub fn update_weapon_effects(game : Game, dt : Float) -> Unit {
  let mut i = 0
  while i < game.weapon_effects.length() {
    let ef = game.weapon_effects[i]
    ef.timer = ef.timer - dt
    if ef.timer <= 0.0 {
      let last = game.weapon_effects.length() - 1
      if i < last {
        game.weapon_effects[i] = game.weapon_effects[last]
      }
      let _ = game.weapon_effects.pop()
    } else {
      i = i + 1
    }
  }
}

///|
pub fn weapon_effect_color(kind : WeaponKind) -> @raylib.Color {
  match kind {
    Sword => @raylib.Color::new(220, 220, 240, 220)
    Spear => @raylib.Color::new(200, 180, 120, 220)
    Whip => @raylib.Color::new(180, 120, 80, 220)
    Hammer => @raylib.Color::new(200, 200, 220, 240)
    Bow => @raylib.Color::new(140, 200, 100, 220)
    Staff => @raylib.Color::new(180, 120, 255, 220)
  }
}

// ============================================================
// === Boss Phase Management ===
// ============================================================

///|
pub fn boss_phase_from_hp(
  kind : EnemyKind,
  hp : Int,
  max_hp : Int,
) -> BossPhase {
  let frac = Float::from_int(hp) / Float::from_int(max_hp)
  match kind {
    BeatDragon =>
      if frac > dragon_phase2_threshold {
        Phase1
      } else if frac > dragon_phase3_threshold {
        Phase2
      } else {
        Phase3
      }
    RhythmLich =>
      if frac > lich_phase2_threshold {
        Phase1
      } else if frac > lich_phase3_threshold {
        Phase2
      } else {
        Phase3
      }
    _ => Phase1
  }
}

///|
pub fn check_boss_phase_transition(
  game : Game,
  kind : EnemyKind,
  hp : Int,
  max_hp : Int,
) -> Bool {
  let new_phase = boss_phase_from_hp(kind, hp, max_hp)
  match kind {
    BeatDragon => {
      let old = game.boss_phases.dragon_phase
      if old != new_phase {
        game.boss_phases.dragon_phase = new_phase
        push_sound(game, BossPhaseChange)
        game.screen_shake = 8.0
        true
      } else {
        false
      }
    }
    RhythmLich => {
      let old = game.boss_phases.lich_phase
      if old != new_phase {
        game.boss_phases.lich_phase = new_phase
        push_sound(game, BossPhaseChange)
        game.screen_shake = 8.0
        // Phase 3 enables double summon
        if new_phase == Phase3 {
          game.boss_phases.lich_double_summon = true
        }
        true
      } else {
        false
      }
    }
    _ => false
  }
}

///|
pub fn boss_phase_name(phase : BossPhase) -> String {
  match phase {
    Phase1 => "Phase 1"
    Phase2 => "Phase 2"
    Phase3 => "Phase 3"
  }
}

///|
pub fn boss_phase_color(phase : BossPhase) -> @raylib.Color {
  match phase {
    Phase1 => @raylib.Color::new(100, 200, 100, 255)
    Phase2 => @raylib.Color::new(255, 200, 50, 255)
    Phase3 => @raylib.Color::new(255, 60, 40, 255)
  }
}

// ============================================================
// === Run Statistics Tracking ===
// ============================================================

///|
pub fn start_floor_stats(game : Game, floor_num : Int) -> Unit {
  game.current_floor_stats = FloorStats::new(floor_num)
}

///|
pub fn finalize_floor_stats(game : Game) -> Unit {
  let stats = FloorStats::new(game.current_floor_stats.floor_num)
  stats.enemies_killed = game.current_floor_stats.enemies_killed
  stats.perfects_hit = game.current_floor_stats.perfects_hit
  stats.items_collected = game.current_floor_stats.items_collected
  stats.spells_cast = game.current_floor_stats.spells_cast
  stats.damage_taken = game.current_floor_stats.damage_taken
  stats.damage_dealt = game.current_floor_stats.damage_dealt
  game.run_stats.floor_history.push(stats)
}

///|
pub fn record_weapon_usage(game : Game, kind : WeaponKind) -> Unit {
  for wu in game.run_stats.weapon_usage {
    let (wk, _count) = wu
    if wk == kind {
      // MoonBit tuples in arrays are immutable, so update total
      game.run_stats.total_damage_dealt = game.run_stats.total_damage_dealt
      break
    }
  }
  // Track via simple counter
  let mut found = false
  let new_usage : Array[(WeaponKind, Int)] = []
  for wu in game.run_stats.weapon_usage {
    let (wk, count) = wu
    if wk == kind {
      new_usage.push((wk, count + 1))
      found = true
    } else {
      new_usage.push((wk, count))
    }
  }
  if !found {
    new_usage.push((kind, 1))
  }
  game.run_stats.weapon_usage = new_usage
}

///|
pub fn record_spell_usage(game : Game, kind : SpellKind) -> Unit {
  let new_usage : Array[(SpellKind, Int)] = []
  let mut found = false
  for su in game.run_stats.spell_usage {
    let (sk, count) = su
    if sk == kind {
      new_usage.push((sk, count + 1))
      found = true
    } else {
      new_usage.push((sk, count))
    }
  }
  if !found {
    new_usage.push((kind, 1))
  }
  game.run_stats.spell_usage = new_usage
  game.run_stats.total_spells_cast = game.run_stats.total_spells_cast + 1
  game.current_floor_stats.spells_cast = game.current_floor_stats.spells_cast +
    1
}

///|
pub fn most_used_weapon(stats : RunStats) -> (WeaponKind, Int) {
  let mut best_kind : WeaponKind = Sword
  let mut best_count = 0
  for wu in stats.weapon_usage {
    let (wk, count) = wu
    if count > best_count {
      best_count = count
      best_kind = wk
    }
  }
  (best_kind, best_count)
}

///|
pub fn grade_distance_text(score : Int) -> String {
  if score >= grade_s_threshold {
    "MAX GRADE!"
  } else if score >= grade_a_threshold {
    let needed = grade_s_threshold - score
    "\{needed} pts to S"
  } else if score >= grade_b_threshold {
    let needed = grade_a_threshold - score
    "\{needed} pts to A"
  } else {
    let needed = grade_b_threshold - score
    "\{needed} pts to B"
  }
}

///|
pub fn reset_run_stats(game : Game) -> Unit {
  game.run_stats.floor_history.clear()
  game.run_stats.weapon_usage = [
    (Sword, 0),
    (Spear, 0),
    (Whip, 0),
    (Hammer, 0),
    (Bow, 0),
    (Staff, 0),
  ]
  game.run_stats.spell_usage.clear()
  game.run_stats.total_items = 0
  game.run_stats.total_spells_cast = 0
  game.run_stats.total_damage_dealt = 0
  game.run_stats.total_damage_taken = 0
}

///|
pub fn reset_boss_phases(game : Game) -> Unit {
  game.boss_phases.dragon_phase = Phase1
  game.boss_phases.lich_phase = Phase1
  game.boss_phases.dragon_charge_cooldown = 0
  game.boss_phases.lich_teleport_cooldown = 0
  game.boss_phases.dragon_4dir_cooldown = 0
  game.boss_phases.lich_double_summon = false
}

// ============================================================
// === Weapon Switch Flash ===
// ============================================================

///|
pub fn trigger_weapon_switch_flash(game : Game) -> Unit {
  game.weapon_switch_flash = weapon_switch_flash_duration
  push_sound(game, WeaponSwitch)
}

///|
pub fn update_weapon_switch_flash(game : Game, dt : Float) -> Unit {
  if game.weapon_switch_flash > 0.0 {
    game.weapon_switch_flash = game.weapon_switch_flash - dt
    if game.weapon_switch_flash < 0.0 {
      game.weapon_switch_flash = 0.0
    }
  }
}

// ============================================================
// === Combo Milestone Burst Particles ===
// ============================================================

///|
pub fn spawn_milestone_burst(game : Game, ms : ComboMilestone) -> Unit {
  let (r, g, b) = match ms {
    Fever => (255, 200, 0)
    Frenzy => (255, 100, 50)
    PerfectStorm => (255, 50, 255)
    NoMilestone => (255, 255, 255)
  }
  let rng = game_rng(game)
  let cx = Float::from_int(tile_screen_x(game.player.x) + tile_size / 2)
  let cy = Float::from_int(tile_screen_y(game.player.y) + tile_size / 2)
  let count = 16
  for i in 0..<count {
    let angle = Float::from_int(i) * 6.28F / Float::from_int(count)
    let speed = 50.0F + Float::from_int(rand_range(rng, 0, 50))
    let vx = speed * cos_approx(angle)
    let vy = speed * sin_approx(angle)
    let p : Particle = {
      x: cx,
      y: cy,
      vx,
      vy,
      life: 0.8F,
      max_life: 0.8F,
      r,
      g,
      b,
      size: 4.0F,
    }
    game.particles.push(p)
  }
  sync_rng(game, rng)
}
