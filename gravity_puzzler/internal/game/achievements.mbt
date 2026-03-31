///|
/// Check all achievements after a level is completed
pub fn check_achievements_on_complete(game : @types.Game) -> Unit {
  let level = match game.level {
    Some(l) => l
    None => return
  }
  let stars = @types.calc_stars(level.moves, level.par_moves)
  // FirstStep: complete any level
  try_unlock_achievement(game, FirstStep)
  // Speedster: complete any level in under 10 moves
  if level.moves < 10 {
    try_unlock_achievement(game, Speedster)
  }
  // Minimalist: complete a level at exactly par
  if level.moves == level.par_moves {
    try_unlock_achievement(game, Minimalist)
  }
  // UndoFree: complete without using undo
  if !(game.used_undo_this_level) {
    try_unlock_achievement(game, UndoFree)
  }
  // GhostRacer: beat ghost replay best
  if game.ghost.best_moves < 999 && level.moves < game.ghost.best_moves {
    try_unlock_achievement(game, GhostRacer)
  }
  // NoHints: complete a level without hints
  if !(game.used_hint_this_level) {
    check_no_hints_world(game)
  }
  // Perfectionist: 3 stars on 10+ levels
  if stars == 3 {
    game.stats.levels_with_3_stars = game.stats.levels_with_3_stars + 1
    if game.stats.levels_with_3_stars >= 10 {
      try_unlock_achievement(game, Perfectionist)
    }
    // Update streak
    game.stats.current_streak = game.stats.current_streak + 1
    if game.stats.current_streak > game.stats.best_streak {
      game.stats.best_streak = game.stats.current_streak
    }
  } else {
    game.stats.current_streak = 0
  }
  // WorldMaster: all 3 stars in a world
  check_world_master(game, level.world)
  // AllWorlds: all 5 worlds unlocked
  check_all_worlds(game)
  // GemCollector: 20+ gems total
  if game.stats.total_gems_collected >= 20 {
    try_unlock_achievement(game, GemCollector)
  }
  // KeyMaster: 10+ keys total
  if game.stats.total_keys_collected >= 10 {
    try_unlock_achievement(game, KeyMaster)
  }
  // Completionist: all 3 stars on all 50 levels
  check_completionist(game)
}

///|
/// Check achievements related to gravity rotation count
pub fn check_achievements_on_rotate(game : @types.Game) -> Unit {
  game.stats.total_gravity_rotations = game.stats.total_gravity_rotations + 1
  if game.stats.total_gravity_rotations >= 50 {
    try_unlock_achievement(game, GravitySpinner)
  }
}

///|
/// Check achievements related to move count
pub fn check_achievements_on_move(game : @types.Game) -> Unit {
  game.stats.total_moves = game.stats.total_moves + 1
}

///|
/// Check achievements when entering editor
pub fn check_achievements_on_editor(game : @types.Game) -> Unit {
  try_unlock_achievement(game, Explorer)
}

///|
/// Track ice slide for achievement
pub fn track_ice_slide(game : @types.Game) -> Unit {
  game.stats.total_ice_slides = game.stats.total_ice_slides + 1
  if game.stats.total_ice_slides >= 20 {
    try_unlock_achievement(game, IceSlider)
  }
}

///|
/// Track gem collection for stats
pub fn track_gem_collected(game : @types.Game) -> Unit {
  game.stats.total_gems_collected = game.stats.total_gems_collected + 1
}

///|
/// Track key collection for stats
pub fn track_key_collected(game : @types.Game) -> Unit {
  game.stats.total_keys_collected = game.stats.total_keys_collected + 1
}

///|
/// Track deaths for stats
pub fn track_death(game : @types.Game) -> Unit {
  game.stats.total_deaths = game.stats.total_deaths + 1
}

///|
/// Track undo usage
pub fn track_undo(game : @types.Game) -> Unit {
  game.stats.total_undos = game.stats.total_undos + 1
  game.used_undo_this_level = true
}

///|
/// Track hint usage
pub fn track_hint_used(game : @types.Game) -> Unit {
  game.stats.hint_uses = game.stats.hint_uses + 1
  game.used_hint_this_level = true
}

///|
/// Try to unlock an achievement; if newly unlocked, queue a toast
fn try_unlock_achievement(game : @types.Game, kind : @types.AchievementKind) -> Unit {
  let ach_state = game.achievement_state
  for i in 0..<ach_state.achievements.length() {
    let ach = ach_state.achievements[i]
    if ach.kind == kind && !(ach.unlocked) {
      ach.unlocked = true
      ach_state.toast_queue.push(i)
      // Also mark in save data
      if i < game.save_data.achievements_unlocked.length() {
        game.save_data.achievements_unlocked[i] = true
      }
      break
    }
  }
}

///|
/// Check if a specific world has all 3 stars on every level
fn check_world_master(game : @types.Game, world : Int) -> Unit {
  let start = world * @types.levels_per_world
  let mut all_3_stars = true
  for l in 0..< @types.levels_per_world {
    let idx = start + l
    if idx < game.level_stars.length() {
      if game.level_stars[idx] < 3 {
        all_3_stars = false
        break
      }
    } else {
      all_3_stars = false
      break
    }
  }
  if all_3_stars {
    try_unlock_achievement(game, WorldMaster(world))
  }
}

///|
/// Check if all worlds are unlocked
fn check_all_worlds(game : @types.Game) -> Unit {
  let mut all_unlocked = true
  for w in 0..< @types.num_worlds {
    if game.levels_unlocked[w] <= 0 {
      all_unlocked = false
      break
    }
  }
  if all_unlocked {
    try_unlock_achievement(game, AllWorlds)
  }
}

///|
/// Check no-hints achievement for the current world
fn check_no_hints_world(game : @types.Game) -> Unit {
  // Check if the whole current world was completed without hints
  // For simplicity, we unlock this if the player completed a level without hints
  // and the world has had no hints used (tracked by hints_remaining being at initial)
  let world = game.current_world
  if world >= 0 && world < game.hints.hints_remaining.length() {
    if game.hints.hints_remaining[world] == 3 {
      // All hints still remaining means none were used
      let unlocked = game.levels_unlocked[world]
      if unlocked >= @types.levels_per_world {
        try_unlock_achievement(game, NoHints)
      }
    }
  }
}

///|
/// Check if player has all 3 stars on all 50 levels
fn check_completionist(game : @types.Game) -> Unit {
  let mut all_perfect = true
  for i in 0..< @types.total_levels {
    if i < game.level_stars.length() {
      if game.level_stars[i] < 3 {
        all_perfect = false
        break
      }
    } else {
      all_perfect = false
      break
    }
  }
  if all_perfect {
    try_unlock_achievement(game, Completionist)
  }
}

///|
/// Update achievement toast display (called each frame)
pub fn update_achievement_toasts(game : @types.Game, dt : Float) -> Unit {
  let ach_state = game.achievement_state
  // If currently showing a toast, count down
  if ach_state.current_toast >= 0 {
    ach_state.toast_timer = ach_state.toast_timer - dt
    if ach_state.toast_timer <= 0.0 {
      ach_state.current_toast = -1
      ach_state.toast_timer = 0.0
    }
    return
  }
  // If there are queued toasts, show the next one
  if ach_state.toast_queue.length() > 0 {
    match ach_state.toast_queue.pop() {
      Some(idx) => {
        ach_state.current_toast = idx
        ach_state.toast_timer = @types.toast_display_duration
      }
      None => ()
    }
  }
}

///|
/// Get total unlocked achievement count
pub fn unlocked_count(game : @types.Game) -> Int {
  let mut count = 0
  for i in 0..<game.achievement_state.achievements.length() {
    if game.achievement_state.achievements[i].unlocked {
      count = count + 1
    }
  }
  count
}

///|
/// Get total achievement count
pub fn total_achievement_count(game : @types.Game) -> Int {
  game.achievement_state.achievements.length()
}
