///|
pub fn get_level(id : Int) -> @types.LevelDef {
  match id {
    0 => level_01()
    1 => level_02()
    2 => level_03()
    3 => level_04()
    4 => level_05()
    5 => level_06()
    6 => level_07()
    7 => level_08()
    8 => level_09()
    9 => level_10()
    10 => level_11()
    11 => level_12()
    12 => level_13()
    13 => level_14()
    14 => level_15()
    15 => level_16()
    16 => level_17()
    17 => level_18()
    18 => level_19()
    19 => level_20()
    _ => level_01()
  }
}

///|
pub fn load_level(game : @types.Game, id : Int) -> Unit {
  let _level = get_level(id)
  game.current_level = id
  @types.clear_crucible(game)
  game.temperature = Medium
  game.result = @types.new_level_result()
}

///|
pub fn attempt_blend(game : @types.Game) -> Unit {
  let level = get_level(game.current_level)
  if game.crucible.is_empty() {
    @types.set_message(game, "Add metals to the crucible first!", 2.0)
    return
  }
  let result = @forge.blend(game.crucible, game.temperature)
  game.blend_result = result
  game.blend_animating = true
  game.blend_timer = 0.0
  let ingredients_used = @types.total_ingredient_count(game)
  let all_in_range = @forge.check_target(result, level.target)
  let stars = @forge.calculate_stars(
    result,
    level.target,
    ingredients_used,
    level.par_ingredients,
  )
  game.result = { stars, ingredients_used, blend: result, all_in_range }
}

///|
pub fn finish_blend(game : @types.Game) -> Unit {
  if game.result.all_in_range {
    // Update progress
    let progress = game.level_progress[game.current_level]
    progress.completed = true
    if @types.star_count(game.result.stars) >
      @types.star_count(progress.best_stars) {
      progress.best_stars = game.result.stars
    }
    @types.recalculate_total_stars(game)
    game.screen = LevelComplete
  } else {
    game.screen = LevelFailed
  }
}

// ==================== TIER 1: 2 metals, single property (Levels 1-7) ====================

///|
fn level_01() -> @types.LevelDef {
  {
    id: 0,
    name: "Soft Start",
    tier: 1,
    available_metals: [Iron, Copper],
    target: {
      hardness: { min: 40.0, max: 65.0 },
      flexibility: { min: 0.0, max: 100.0 },
      conductivity: { min: 0.0, max: 100.0 },
    },
    par_ingredients: 2,
    hint: "Blend Iron and Copper for medium hardness",
  }
}

///|
fn level_02() -> @types.LevelDef {
  {
    id: 1,
    name: "Conductor",
    tier: 1,
    available_metals: [Copper, Tin],
    target: {
      hardness: { min: 0.0, max: 100.0 },
      flexibility: { min: 0.0, max: 100.0 },
      conductivity: { min: 60.0, max: 85.0 },
    },
    par_ingredients: 2,
    hint: "Copper conducts well; add Tin to moderate",
  }
}

///|
fn level_03() -> @types.LevelDef {
  {
    id: 2,
    name: "Spring Metal",
    tier: 1,
    available_metals: [Tin, Iron],
    target: {
      hardness: { min: 0.0, max: 100.0 },
      flexibility: { min: 45.0, max: 70.0 },
      conductivity: { min: 0.0, max: 100.0 },
    },
    par_ingredients: 2,
    hint: "Tin is very flexible; Iron pulls it down",
  }
}

///|
fn level_04() -> @types.LevelDef {
  {
    id: 3,
    name: "Hard Edge",
    tier: 1,
    available_metals: [Iron, Carbon],
    target: {
      hardness: { min: 82.0, max: 100.0 },
      flexibility: { min: 0.0, max: 100.0 },
      conductivity: { min: 0.0, max: 100.0 },
    },
    par_ingredients: 2,
    hint: "Carbon hardens iron into steel",
  }
}

///|
fn level_05() -> @types.LevelDef {
  {
    id: 4,
    name: "Precious Wire",
    tier: 1,
    available_metals: [Gold, Copper],
    target: {
      hardness: { min: 0.0, max: 100.0 },
      flexibility: { min: 0.0, max: 100.0 },
      conductivity: { min: 88.0, max: 100.0 },
    },
    par_ingredients: 2,
    hint: "Both Gold and Copper are excellent conductors",
  }
}

///|
fn level_06() -> @types.LevelDef {
  {
    id: 5,
    name: "Rust Guard",
    tier: 1,
    available_metals: [Iron, Zinc],
    target: {
      hardness: { min: 50.0, max: 70.0 },
      flexibility: { min: 0.0, max: 100.0 },
      conductivity: { min: 0.0, max: 100.0 },
    },
    par_ingredients: 2,
    hint: "Zinc and Iron make a balanced alloy",
  }
}

///|
fn level_07() -> @types.LevelDef {
  {
    id: 6,
    name: "Flex Circuit",
    tier: 1,
    available_metals: [Tin, Gold],
    target: {
      hardness: { min: 0.0, max: 100.0 },
      flexibility: { min: 68.0, max: 82.0 },
      conductivity: { min: 0.0, max: 100.0 },
    },
    par_ingredients: 3,
    hint: "Tin and Gold together are quite flexible",
  }
}

// ==================== TIER 2: 3-4 metals, dual property, temperature matters (Levels 8-14) ====================

///|
fn level_08() -> @types.LevelDef {
  {
    id: 7,
    name: "Bronze Age",
    tier: 2,
    available_metals: [Copper, Tin, Iron],
    target: {
      hardness: { min: 30.0, max: 50.0 },
      flexibility: { min: 50.0, max: 75.0 },
      conductivity: { min: 0.0, max: 100.0 },
    },
    par_ingredients: 3,
    hint: "Classic bronze: Copper and Tin. Temperature matters!",
  }
}

///|
fn level_09() -> @types.LevelDef {
  {
    id: 8,
    name: "Forge Steel",
    tier: 2,
    available_metals: [Iron, Carbon, Zinc],
    target: {
      hardness: { min: 78.0, max: 95.0 },
      flexibility: { min: 15.0, max: 35.0 },
      conductivity: { min: 0.0, max: 100.0 },
    },
    par_ingredients: 3,
    hint: "High temperature amplifies hardness",
  }
}

///|
fn level_10() -> @types.LevelDef {
  {
    id: 9,
    name: "Golden Flex",
    tier: 2,
    available_metals: [Gold, Tin, Copper],
    target: {
      hardness: { min: 0.0, max: 100.0 },
      flexibility: { min: 60.0, max: 80.0 },
      conductivity: { min: 65.0, max: 85.0 },
    },
    par_ingredients: 3,
    hint: "Low temp preserves both flex and conductivity",
  }
}

///|
fn level_11() -> @types.LevelDef {
  {
    id: 10,
    name: "Rigid Wire",
    tier: 2,
    available_metals: [Iron, Copper, Carbon],
    target: {
      hardness: { min: 55.0, max: 75.0 },
      flexibility: { min: 0.0, max: 100.0 },
      conductivity: { min: 45.0, max: 65.0 },
    },
    par_ingredients: 4,
    hint: "Balance iron's hardness with copper's conductivity",
  }
}

///|
fn level_12() -> @types.LevelDef {
  {
    id: 11,
    name: "Galvanize",
    tier: 2,
    available_metals: [Iron, Zinc, Tin],
    target: {
      hardness: { min: 40.0, max: 60.0 },
      flexibility: { min: 40.0, max: 60.0 },
      conductivity: { min: 0.0, max: 100.0 },
    },
    par_ingredients: 3,
    hint: "Equal parts make balanced properties",
  }
}

///|
fn level_13() -> @types.LevelDef {
  {
    id: 12,
    name: "Circuit Board",
    tier: 2,
    available_metals: [Copper, Gold, Zinc],
    target: {
      hardness: { min: 0.0, max: 100.0 },
      flexibility: { min: 40.0, max: 60.0 },
      conductivity: { min: 72.0, max: 90.0 },
    },
    par_ingredients: 3,
    hint: "High conductivity with moderate flex",
  }
}

///|
fn level_14() -> @types.LevelDef {
  {
    id: 13,
    name: "Heat Blade",
    tier: 2,
    available_metals: [Iron, Carbon, Copper, Tin],
    target: {
      hardness: { min: 65.0, max: 85.0 },
      flexibility: { min: 25.0, max: 45.0 },
      conductivity: { min: 0.0, max: 100.0 },
    },
    par_ingredients: 4,
    hint: "High temp boosts hardness; add flex from Tin",
  }
}

// ==================== TIER 3: All metals, triple targets, tight (Levels 15-20) ====================

///|
fn level_15() -> @types.LevelDef {
  {
    id: 14,
    name: "Master Alloy",
    tier: 3,
    available_metals: [Iron, Copper, Tin, Gold, Carbon, Zinc],
    target: {
      hardness: { min: 45.0, max: 60.0 },
      flexibility: { min: 45.0, max: 60.0 },
      conductivity: { min: 45.0, max: 60.0 },
    },
    par_ingredients: 4,
    hint: "Balance all three properties near 50",
  }
}

///|
fn level_16() -> @types.LevelDef {
  {
    id: 15,
    name: "Precision Steel",
    tier: 3,
    available_metals: [Iron, Copper, Tin, Gold, Carbon, Zinc],
    target: {
      hardness: { min: 70.0, max: 82.0 },
      flexibility: { min: 20.0, max: 35.0 },
      conductivity: { min: 35.0, max: 50.0 },
    },
    par_ingredients: 4,
    hint: "Hard with moderate conductivity; careful with temp",
  }
}

///|
fn level_17() -> @types.LevelDef {
  {
    id: 16,
    name: "Superconductor",
    tier: 3,
    available_metals: [Iron, Copper, Tin, Gold, Carbon, Zinc],
    target: {
      hardness: { min: 15.0, max: 30.0 },
      flexibility: { min: 50.0, max: 65.0 },
      conductivity: { min: 82.0, max: 96.0 },
    },
    par_ingredients: 4,
    hint: "Maximize conductivity with Gold and Copper",
  }
}

///|
fn level_18() -> @types.LevelDef {
  {
    id: 17,
    name: "Flex Armor",
    tier: 3,
    available_metals: [Iron, Copper, Tin, Gold, Carbon, Zinc],
    target: {
      hardness: { min: 50.0, max: 65.0 },
      flexibility: { min: 55.0, max: 70.0 },
      conductivity: { min: 30.0, max: 48.0 },
    },
    par_ingredients: 5,
    hint: "Hard AND flexible? Temperature choice is critical",
  }
}

///|
fn level_19() -> @types.LevelDef {
  {
    id: 18,
    name: "Golden Shield",
    tier: 3,
    available_metals: [Iron, Copper, Tin, Gold, Carbon, Zinc],
    target: {
      hardness: { min: 38.0, max: 52.0 },
      flexibility: { min: 38.0, max: 52.0 },
      conductivity: { min: 62.0, max: 78.0 },
    },
    par_ingredients: 4,
    hint: "Balanced with high conductivity; use Gold wisely",
  }
}

///|
fn level_20() -> @types.LevelDef {
  {
    id: 19,
    name: "Perfection",
    tier: 3,
    available_metals: [Iron, Copper, Tin, Gold, Carbon, Zinc],
    target: {
      hardness: { min: 48.0, max: 56.0 },
      flexibility: { min: 48.0, max: 56.0 },
      conductivity: { min: 48.0, max: 56.0 },
    },
    par_ingredients: 4,
    hint: "Exact center on all three. Good luck!",
  }
}
