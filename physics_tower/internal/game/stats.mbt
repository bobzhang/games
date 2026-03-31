///|
/// Records a piece placement in the statistics.
pub fn record_piece_placed(game : @types.Game, material : @types.Material) -> Unit {
  let stats = game.statistics
  stats.total_pieces_placed = stats.total_pieces_placed + 1
  let mat_idx = material_index(material)
  stats.materials_used[mat_idx] = stats.materials_used[mat_idx] + 1
}

///|
/// Records a build (entering test phase).
pub fn record_build(game : @types.Game) -> Unit {
  game.statistics.total_builds = game.statistics.total_builds + 1
  game.statistics.total_tests_run = game.statistics.total_tests_run + 1
}

///|
/// Records breaks that occurred during a test.
pub fn record_breaks(game : @types.Game, break_count : Int) -> Unit {
  game.statistics.total_breaks = game.statistics.total_breaks + break_count
}

///|
/// Records the result of a level test.
pub fn record_level_result(
  game : @types.Game,
  level_idx : Int,
  height : Float,
  stars : Int,
  passed : Bool
) -> Unit {
  let stats = game.statistics
  // Check if level was previously completed BEFORE updating best height/stars
  let already_completed = if level_idx >= 0 &&
    level_idx < stats.best_heights.length() {
    stats.level_stars[level_idx] > 0
  } else {
    false
  }
  // Update best height
  if level_idx >= 0 && level_idx < stats.best_heights.length() {
    if height > stats.best_heights[level_idx] {
      stats.best_heights[level_idx] = height
    }
    // Update stars (keep best)
    if stars > stats.level_stars[level_idx] {
      let old_stars = stats.level_stars[level_idx]
      stats.level_stars[level_idx] = stars
      // Add the new stars earned
      stats.stars_earned = stats.stars_earned + (stars - old_stars)
    }
  }
  if passed && !(already_completed) {
    stats.levels_completed = stats.levels_completed + 1
  }
}

///|
/// Records a challenge completion.
pub fn record_challenge_complete(game : @types.Game) -> Unit {
  game.statistics.challenges_completed = game.statistics.challenges_completed + 1
}

///|
/// Returns total stars earned across all levels.
pub fn total_stars(game : @types.Game) -> Int {
  game.statistics.stars_earned
}

///|
/// Returns the completion percentage (levels completed / total levels).
pub fn completion_percentage(game : @types.Game) -> Int {
  let total = game.statistics.best_heights.length()
  if total == 0 {
    return 0
  }
  let mut completed = 0
  for i in 0..<total {
    if game.statistics.level_stars[i] > 0 {
      completed = completed + 1
    }
  }
  completed * 100 / total
}

///|
/// Returns the star count for a specific world.
pub fn world_stars(game : @types.Game, world_idx : Int) -> Int {
  let worlds = @content.get_worlds()
  if world_idx < 0 || world_idx >= worlds.length() {
    return 0
  }
  let w = worlds[world_idx]
  let mut stars = 0
  for i = w.level_start; i <= w.level_end; i = i + 1 {
    if i < game.statistics.level_stars.length() {
      stars = stars + game.statistics.level_stars[i]
    }
  }
  stars
}

///|
/// Returns the max possible stars for a specific world.
pub fn world_max_stars(world_idx : Int) -> Int {
  let worlds = @content.get_worlds()
  if world_idx < 0 || world_idx >= worlds.length() {
    return 0
  }
  let w = worlds[world_idx]
  (w.level_end - w.level_start + 1) * 3
}

///|
/// Returns material usage as [wood, stone, steel].
pub fn material_usage(game : @types.Game) -> (Int, Int, Int) {
  let m = game.statistics.materials_used
  (m[0], m[1], m[2])
}

///|
/// Returns the best height for a level.
pub fn best_height_for_level(game : @types.Game, level_idx : Int) -> Float {
  if level_idx >= 0 && level_idx < game.statistics.best_heights.length() {
    game.statistics.best_heights[level_idx]
  } else {
    0.0
  }
}

///|
/// Returns stars for a specific level.
pub fn stars_for_level(game : @types.Game, level_idx : Int) -> Int {
  if level_idx >= 0 && level_idx < game.statistics.level_stars.length() {
    game.statistics.level_stars[level_idx]
  } else {
    0
  }
}

///|
/// Returns the material index for statistics tracking.
fn material_index(mat : @types.Material) -> Int {
  match mat {
    Wood => 0
    Stone => 1
    Steel => 2
  }
}

///|
/// Returns formatted statistics summary lines.
pub fn stats_summary(game : @types.Game) -> Array[String] {
  let stats = game.statistics
  let lines : Array[String] = Array::new(capacity=12)
  lines.push("Total Pieces Placed: " + stats.total_pieces_placed.to_string())
  lines.push("Total Tests Run: " + stats.total_tests_run.to_string())
  lines.push("Total Builds: " + stats.total_builds.to_string())
  lines.push("Total Breaks: " + stats.total_breaks.to_string())
  lines.push("Levels Completed: " + stats.levels_completed.to_string())
  lines.push("Stars Earned: " + stats.stars_earned.to_string())
  lines.push("Challenges Completed: " + stats.challenges_completed.to_string())
  let pct = completion_percentage(game)
  lines.push("Completion: " + pct.to_string() + "%")
  let (wood, stone, steel) = material_usage(game)
  lines.push(
    "Materials - Wood: " +
    wood.to_string() +
    "  Stone: " +
    stone.to_string() +
    "  Steel: " +
    steel.to_string(),
  )
  lines
}

///|
/// Updates the stats screen. Returns to level select on Escape.
pub fn update_stats_screen(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}
