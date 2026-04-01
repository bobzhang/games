///|
pub fn star_count(rating : StarRating) -> Int {
  match rating {
    Zero => 0
    One => 1
    Two => 2
    Three => 3
  }
}

///|
pub fn new_level_result() -> LevelResult {
  {
    stars: Zero,
    ingredients_used: 0,
    blend: { hardness: 0.0, flexibility: 0.0, conductivity: 0.0 },
    all_in_range: false,
  }
}

///|
pub fn new_level_progress() -> LevelProgress {
  { best_stars: Zero, completed: false }
}

///|
pub fn new_game() -> Game {
  let progress : Array[LevelProgress] = []
  for _i in 0..<total_levels {
    progress.push(new_level_progress())
  }
  {
    screen: Title,
    current_level: 0,
    crucible: [],
    temperature: Medium,
    blend_result: { hardness: 0.0, flexibility: 0.0, conductivity: 0.0 },
    blend_timer: 0.0,
    blend_animating: false,
    level_progress: progress,
    result: new_level_result(),
    frame_count: 0,
    message: "",
    message_timer: 0.0,
    total_stars: 0,
    hover_metal: -1,
    hover_button: "",
    selected_slot: -1,
  }
}

///|
pub fn clear_crucible(game : Game) -> Unit {
  game.crucible.clear()
  game.blend_result = { hardness: 0.0, flexibility: 0.0, conductivity: 0.0 }
  game.blend_animating = false
  game.blend_timer = 0.0
  game.selected_slot = -1
}

///|
pub fn add_ingredient(game : Game, metal : MetalKind) -> Unit {
  // Check if already in crucible; if so, increase amount
  for i in 0..<game.crucible.length() {
    if game.crucible[i].metal == metal {
      game.crucible[i].amount += 1
      return
    }
  }
  // Otherwise add new ingredient if room
  if game.crucible.length() < max_crucible_slots {
    game.crucible.push({ metal, amount: 1 })
  }
}

///|
pub fn remove_ingredient(game : Game, slot : Int) -> Unit {
  if slot >= 0 && slot < game.crucible.length() {
    let ing = game.crucible[slot]
    if ing.amount > 1 {
      ing.amount -= 1
    } else {
      let _ = game.crucible.remove(slot)
      if game.selected_slot >= game.crucible.length() {
        game.selected_slot = -1
      }
    }
  }
}

///|
pub fn total_ingredient_count(game : Game) -> Int {
  let mut total = 0
  for i in 0..<game.crucible.length() {
    total += game.crucible[i].amount
  }
  total
}

///|
pub fn is_level_unlocked(game : Game, level : Int) -> Bool {
  if level == 0 {
    true
  } else {
    game.level_progress[level - 1].completed
  }
}

///|
pub fn set_message(game : Game, msg : String, duration : Float) -> Unit {
  game.message = msg
  game.message_timer = duration
}

///|
pub fn recalculate_total_stars(game : Game) -> Unit {
  let mut total = 0
  for i in 0..<total_levels {
    total += star_count(game.level_progress[i].best_stars)
  }
  game.total_stars = total
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
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
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
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
pub fn sinf(a : Float) -> Float {
  Float::from_double(@math.sin(a.to_double()))
}

///|
pub fn cosf(a : Float) -> Float {
  Float::from_double(@math.cos(a.to_double()))
}
