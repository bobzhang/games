///|
/// Create a slime enemy. Acts every beat.
pub fn make_slime(id : Int, x : Int, y : Int) -> @types.Enemy {
  @types.Enemy::new(id, Slime, x, y, hp=2, damage=1, beat_pattern=[
    true, true, true, true,
  ])
}

///|
/// Create a skeleton enemy. Acts every other beat (strong but slow).
pub fn make_skeleton(id : Int, x : Int, y : Int) -> @types.Enemy {
  @types.Enemy::new(id, Skeleton, x, y, hp=3, damage=2, beat_pattern=[
    true, false, true, false,
  ])
}

///|
/// Create a bat enemy. Fast - acts every beat, low HP.
pub fn make_bat(id : Int, x : Int, y : Int) -> @types.Enemy {
  @types.Enemy::new(id, Bat, x, y, hp=1, damage=1, beat_pattern=[
    true, true, true, true,
  ])
}

///|
/// Create a dragon enemy. Acts on beats 1 and 3, high damage.
pub fn make_dragon(id : Int, x : Int, y : Int) -> @types.Enemy {
  @types.Enemy::new(id, Dragon, x, y, hp=5, damage=3, beat_pattern=[
    true, false, false, true,
  ])
}

///|
/// Create a mimic enemy. Looks inactive, acts rarely but hits hard.
pub fn make_mimic(id : Int, x : Int, y : Int) -> @types.Enemy {
  @types.Enemy::new(id, Mimic, x, y, hp=4, damage=3, beat_pattern=[
    false, false, false, true,
  ])
}

///|
/// Create a golem enemy. Slow, tanky, hits hard.
pub fn make_golem(id : Int, x : Int, y : Int) -> @types.Enemy {
  @types.Enemy::new(id, Golem, x, y, hp=8, damage=2, beat_pattern=[
    true, false, false, true, false, false,
  ])
}

///|
/// Create a wraith enemy. Fast pattern, moderate stats.
pub fn make_wraith(id : Int, x : Int, y : Int) -> @types.Enemy {
  @types.Enemy::new(id, Wraith, x, y, hp=3, damage=2, beat_pattern=[
    true, true, false,
  ])
}

///|
/// Create a boss enemy.
pub fn make_boss(id : Int, x : Int, y : Int) -> @types.Enemy {
  @types.Enemy::new(id, Boss, x, y, hp=20, damage=4, beat_pattern=[
    true, true, true, true,
  ])
}

///|
/// Create a Beat Dragon boss.
pub fn make_beat_dragon(id : Int, x : Int, y : Int) -> @types.Enemy {
  @types.Enemy::new(
    id,
    BeatDragon,
    x,
    y,
    hp=@types.beat_dragon_hp,
    damage=@types.beat_dragon_damage,
    beat_pattern=[true, true, true, true],
  )
}

///|
/// Create a Rhythm Lich boss.
pub fn make_rhythm_lich(id : Int, x : Int, y : Int) -> @types.Enemy {
  @types.Enemy::new(
    id,
    RhythmLich,
    x,
    y,
    hp=@types.rhythm_lich_hp,
    damage=@types.rhythm_lich_damage,
    beat_pattern=[true, true, true, true],
  )
}

///|
/// Create an enemy by kind.
pub fn make_enemy(
  kind : @types.EnemyKind,
  id : Int,
  x : Int,
  y : Int,
) -> @types.Enemy {
  match kind {
    Slime => make_slime(id, x, y)
    Skeleton => make_skeleton(id, x, y)
    Bat => make_bat(id, x, y)
    Dragon => make_dragon(id, x, y)
    Mimic => make_mimic(id, x, y)
    Golem => make_golem(id, x, y)
    Wraith => make_wraith(id, x, y)
    Boss => make_boss(id, x, y)
    BeatDragon => make_beat_dragon(id, x, y)
    RhythmLich => make_rhythm_lich(id, x, y)
  }
}

///|
/// Returns the kinds of enemies that can appear on a given floor.
pub fn floor_enemy_kinds(floor_num : Int) -> Array[@types.EnemyKind] {
  if floor_num <= 2 {
    [Slime]
  } else if floor_num <= 4 {
    [Slime, Bat]
  } else if floor_num <= 7 {
    [Slime, Bat, Skeleton]
  } else if floor_num <= 10 {
    [Slime, Bat, Skeleton, Wraith]
  } else if floor_num <= 14 {
    [Bat, Skeleton, Wraith, Dragon]
  } else if floor_num <= 17 {
    [Skeleton, Wraith, Dragon, Golem, Mimic]
  } else {
    [Skeleton, Wraith, Dragon, Golem, Mimic, Boss]
  }
}

///|
/// Returns the number of enemies to place on a floor.
pub fn floor_enemy_count(floor_num : Int) -> Int {
  let base = 2 + floor_num / 2
  if base > @types.max_enemies_per_floor {
    @types.max_enemies_per_floor
  } else {
    base
  }
}

///|
/// Create an elite version of an enemy: 2x HP, golden outline flag.
pub fn make_elite_enemy(
  kind : @types.EnemyKind,
  id : Int,
  x : Int,
  y : Int,
) -> @types.Enemy {
  let e = make_enemy(kind, id, x, y)
  @types.make_elite(e)
  e
}

///|
/// Elite Slime: splits into 2 mini slimes on death.
/// Returns up to 2 new enemies to spawn at adjacent tiles.
pub fn elite_slime_split(
  dead_x : Int,
  dead_y : Int,
  next_id : Int,
  floor : @types.Floor,
) -> Array[@types.Enemy] {
  let result : Array[@types.Enemy] = []
  let offsets : Array[(Int, Int)] = [(1, 0), (-1, 0), (0, 1), (0, -1)]
  let mut spawned = 0
  for off in offsets {
    if spawned >= 2 {
      break
    }
    let (dx, dy) = off
    let nx = dead_x + dx
    let ny = dead_y + dy
    if @types.grid_is_walkable(floor.grid, nx, ny) &&
      !(@types.has_enemy_at(floor.enemies, nx, ny)) {
      let mini = make_slime(next_id + spawned, nx, ny)
      result.push(mini)
      spawned = spawned + 1
    }
  }
  result
}

///|
/// Elite Skeleton: returns cross-pattern attack cells (N,S,E,W up to 2 range).
pub fn elite_skeleton_cross_cells(ex : Int, ey : Int) -> Array[(Int, Int)] {
  let cells : Array[(Int, Int)] = []
  let dirs : Array[(Int, Int)] = [(1, 0), (-1, 0), (0, 1), (0, -1)]
  for dir in dirs {
    let (dx, dy) = dir
    for r in 1..=2 {
      cells.push((ex + dx * r, ey + dy * r))
    }
  }
  cells
}

///|
/// Elite Bat: moves 2 tiles per beat instead of 1.
pub fn elite_bat_double_move(
  enemy : @types.Enemy,
  floor : @types.Floor,
  px : Int,
  py : Int,
) -> Unit {
  // Already moved 1 tile via normal AI, move 1 more in same direction
  match enemy.intent {
    Move(dir) => {
      let nx = enemy.x + @types.dir_dx(dir)
      let ny = enemy.y + @types.dir_dy(dir)
      if @types.grid_is_walkable(floor.grid, nx, ny) &&
        !(@types.has_enemy_at(floor.enemies, nx, ny)) &&
        !(nx == px && ny == py) {
        enemy.x = nx
        enemy.y = ny
      }
    }
    _ => ()
  }
}

///|
/// Elite Dragon: fire breath hits in a line of 4 tiles (instead of 3).
pub fn elite_dragon_breath_cells(
  ex : Int,
  ey : Int,
  dir : @types.Direction,
) -> Array[(Int, Int)] {
  let cells : Array[(Int, Int)] = []
  let dx = @types.dir_dx(dir)
  let dy = @types.dir_dy(dir)
  for i in 1..=4 {
    cells.push((ex + dx * i, ey + dy * i))
  }
  cells
}

///|
/// Get a descriptive name for an enemy, including elite prefix.
pub fn enemy_display_name(enemy : @types.Enemy) -> String {
  let prefix = if enemy.is_elite { "Elite " } else { "" }
  let name = match enemy.kind {
    Slime => "Slime"
    Skeleton => "Skeleton"
    Bat => "Bat"
    Dragon => "Dragon"
    Mimic => "Mimic"
    Golem => "Golem"
    Wraith => "Wraith"
    Boss => "Boss"
    BeatDragon => "Beat Dragon"
    RhythmLich => "Rhythm Lich"
  }
  prefix + name
}

///|
/// Get the number of items an enemy drops on death.
pub fn enemy_drop_count(enemy : @types.Enemy) -> Int {
  let base = match enemy.kind {
    Slime => 1
    Skeleton => 1
    Bat => 1
    Dragon => 2
    Mimic => 3
    Golem => 2
    Wraith => 1
    Boss => 3
    BeatDragon => 5
    RhythmLich => 5
  }
  if enemy.is_elite {
    base + @types.elite_drop_bonus
  } else {
    base
  }
}

///|
/// Get the XP value of an enemy (for future progression).
pub fn enemy_xp_value(enemy : @types.Enemy) -> Int {
  let base = enemy.max_hp * 2 + enemy.damage * 3
  if enemy.is_elite { base * 2 } else { base }
}

///|
/// Check if an enemy can be frozen (bosses resist).
pub fn can_freeze_enemy(enemy : @types.Enemy) -> Bool {
  match enemy.kind {
    BeatDragon | RhythmLich => false
    _ => true
  }
}

///|
/// Check if an enemy can be stunned (bosses have shorter stun).
pub fn stun_duration_for(enemy : @types.Enemy) -> Int {
  match enemy.kind {
    BeatDragon | RhythmLich => 1 // Bosses resist stun
    _ => 2
  }
}

///|
/// Calculate total threat value for a floor (for difficulty display).
pub fn floor_total_threat(enemies : Array[@types.Enemy]) -> Int {
  let mut total = 0
  for e in enemies {
    if e.active {
      total = total + e.max_hp * e.damage * (if e.is_elite { 2 } else { 1 })
    }
  }
  total
}

///|
/// Count active enemies on a floor.
pub fn active_enemy_count(enemies : Array[@types.Enemy]) -> Int {
  let mut count = 0
  for e in enemies {
    if e.active {
      count = count + 1
    }
  }
  count
}

///|
/// Count active elite enemies on a floor.
pub fn active_elite_count(enemies : Array[@types.Enemy]) -> Int {
  let mut count = 0
  for e in enemies {
    if e.active && e.is_elite {
      count = count + 1
    }
  }
  count
}
