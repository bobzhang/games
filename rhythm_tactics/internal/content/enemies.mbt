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
