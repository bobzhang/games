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
        Floor | Ice | Exit | Spike => true
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
