///|
/// Save progress to in-memory save data after completing a level
pub fn save_progress(game : @types.Game) -> Unit {
  let level = match game.level {
    Some(l) => l
    None => return
  }
  let world = level.world
  let lvl_num = level.level_num
  let stars = @types.calc_stars(level.moves, level.par_moves)
  let save = game.save_data
  // Update star rating if improved
  if world >= 0 &&
    world < save.star_ratings.length() &&
    lvl_num >= 0 &&
    lvl_num < save.star_ratings[world].length() {
    let current_stars = save.star_ratings[world][lvl_num]
    if stars > current_stars {
      save.star_ratings[world][lvl_num] = stars
    }
  }
  // Update best moves if improved
  if world >= 0 &&
    world < save.best_moves.length() &&
    lvl_num >= 0 &&
    lvl_num < save.best_moves[world].length() {
    let current_best = save.best_moves[world][lvl_num]
    if level.moves < current_best {
      save.best_moves[world][lvl_num] = level.moves
    }
  }
  // Sync levels_unlocked
  for w in 0..<@types.num_worlds {
    if w < save.levels_unlocked.length() && w < game.levels_unlocked.length() {
      if game.levels_unlocked[w] > save.levels_unlocked[w] {
        save.levels_unlocked[w] = game.levels_unlocked[w]
      }
    }
  }
  // Sync achievement state
  for i in 0..<game.achievement_state.achievements.length() {
    if i < save.achievements_unlocked.length() {
      if game.achievement_state.achievements[i].unlocked {
        save.achievements_unlocked[i] = true
      }
    }
  }
}

///|
/// Load progress from save data and apply to game state
pub fn load_progress(game : @types.Game) -> Unit {
  let save = game.save_data
  // Restore levels_unlocked
  for w in 0..<@types.num_worlds {
    if w < save.levels_unlocked.length() && w < game.levels_unlocked.length() {
      if save.levels_unlocked[w] > game.levels_unlocked[w] {
        game.levels_unlocked[w] = save.levels_unlocked[w]
      }
    }
  }
  // Restore star ratings to level_stars array
  let mut total = 0
  for w in 0..<@types.num_worlds {
    if w >= save.star_ratings.length() {
      continue
    }
    for l in 0..<@types.levels_per_world {
      if l >= save.star_ratings[w].length() {
        continue
      }
      let global_idx = w * @types.levels_per_world + l
      if global_idx < game.level_stars.length() {
        let stars = save.star_ratings[w][l]
        if stars > game.level_stars[global_idx] {
          game.level_stars[global_idx] = stars
        }
        total = total + game.level_stars[global_idx]
      }
    }
  }
  game.total_stars = total
  // Restore achievement state
  for i in 0..<save.achievements_unlocked.length() {
    if i < game.achievement_state.achievements.length() {
      if save.achievements_unlocked[i] {
        game.achievement_state.achievements[i].unlocked = true
      }
    }
  }
}

///|
/// Update play time tracking (called each frame)
pub fn update_play_time(game : @types.Game, dt : Float) -> Unit {
  game.stats.total_time_played = game.stats.total_time_played + dt
  game.save_data.total_play_time = game.save_data.total_play_time + dt
}

///|
/// Get total stars for a specific world from save data
pub fn get_world_stars(game : @types.Game, world : Int) -> Int {
  let mut total = 0
  if world >= 0 && world < game.save_data.star_ratings.length() {
    let row = game.save_data.star_ratings[world]
    for l in 0..<row.length() {
      total = total + row[l]
    }
  }
  total
}

///|
/// Get best move count for a specific level from save data
pub fn get_best_moves(game : @types.Game, world : Int, level : Int) -> Int {
  if world >= 0 &&
    world < game.save_data.best_moves.length() &&
    level >= 0 &&
    level < game.save_data.best_moves[world].length() {
    game.save_data.best_moves[world][level]
  } else {
    999
  }
}

///|
/// Get completion percentage for a world
pub fn get_world_completion(game : @types.Game, world : Int) -> Int {
  let max_stars = @types.levels_per_world * 3
  let earned = get_world_stars(game, world)
  if max_stars > 0 {
    earned * 100 / max_stars
  } else {
    0
  }
}

///|
/// Get overall completion percentage
pub fn get_total_completion(game : @types.Game) -> Int {
  let max_stars = @types.total_levels * 3
  let mut earned = 0
  for w in 0..<@types.num_worlds {
    earned = earned + get_world_stars(game, w)
  }
  if max_stars > 0 {
    earned * 100 / max_stars
  } else {
    0
  }
}

///|
/// Count completed levels (any star)
pub fn count_completed_levels(game : @types.Game) -> Int {
  let mut count = 0
  for w in 0..<@types.num_worlds {
    if w < game.save_data.star_ratings.length() {
      let row = game.save_data.star_ratings[w]
      for l in 0..<row.length() {
        if row[l] > 0 {
          count = count + 1
        }
      }
    }
  }
  count
}

///|
/// Get the world with the most completed levels
pub fn get_favorite_world(game : @types.Game) -> Int {
  let mut best_world = 0
  let mut best_count = 0
  for w in 0..<@types.num_worlds {
    if w < game.save_data.star_ratings.length() {
      let row = game.save_data.star_ratings[w]
      let mut count = 0
      for l in 0..<row.length() {
        if row[l] > 0 {
          count = count + 1
        }
      }
      if count > best_count {
        best_count = count
        best_world = w
      }
    }
  }
  best_world
}
