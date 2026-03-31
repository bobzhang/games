///|
pub fn get_level(world : Int, index : Int) -> @types.Level {
  match (world, index) {
    (0, 0) => level_1_1()
    (0, 1) => level_1_2()
    (0, 2) => level_1_3()
    (0, 3) => level_1_4()
    (0, 4) => level_1_5()
    (0, 5) => level_1_6()
    (0, 6) => level_1_7()
    (1, 0) => level_2_1()
    (1, 1) => level_2_2()
    (1, 2) => level_2_3()
    (1, 3) => level_2_4()
    (1, 4) => level_2_5()
    (1, 5) => level_2_6()
    (1, 6) => level_2_7()
    (2, 0) => level_3_1()
    (2, 1) => level_3_2()
    (2, 2) => level_3_3()
    (2, 3) => level_3_4()
    (2, 4) => level_3_5()
    (2, 5) => level_3_6()
    (2, 6) => level_3_7()
    (3, 0) => level_4_1()
    (3, 1) => level_4_2()
    (3, 2) => level_4_3()
    (3, 3) => level_4_4()
    (3, 4) => level_4_5()
    (3, 5) => level_4_6()
    (3, 6) => level_4_7()
    _ => level_1_1()
  }
}

///|
pub fn world_unlocked(scores : Array[Array[@types.LevelScore]], world : Int) -> Bool {
  if world <= 0 {
    return true
  }
  // Need at least 4 levels completed in previous world
  let prev = world - 1
  if prev >= scores.length() {
    return false
  }
  let mut completed = 0
  for i in 0..<scores[prev].length() {
    if scores[prev][i].completed {
      completed += 1
    }
  }
  completed >= 4
}

///|
pub fn level_unlocked(
  scores : Array[Array[@types.LevelScore]],
  world : Int,
  level : Int
) -> Bool {
  if !(world_unlocked(scores, world)) {
    return false
  }
  if level <= 0 {
    return true
  }
  // Previous level must be completed
  if world >= 0 && world < scores.length() && level - 1 >= 0 &&
    level - 1 < scores[world].length() {
    scores[world][level - 1].completed
  } else {
    false
  }
}
