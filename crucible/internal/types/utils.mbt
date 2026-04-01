///|
pub fn element_name(e : Element) -> String {
  match e {
    Fire => "Fire"
    Water => "Water"
    Earth => "Earth"
    Air => "Air"
    Light => "Light"
    Shadow => "Shadow"
    Steam => "Steam"
    Mud => "Mud"
    Magma => "Magma"
    Ice => "Ice"
    Lightning => "Lightning"
    Dust => "Dust"
    Void => "Void"
    Storm => "Storm"
    Obsidian => "Obsidian"
    Clay => "Clay"
  }
}

///|
pub fn element_color(e : Element) -> @raylib.Color {
  match e {
    Fire => @raylib.Color::new(230, 60, 40, 255)
    Water => @raylib.Color::new(50, 100, 230, 255)
    Earth => @raylib.Color::new(60, 180, 60, 255)
    Air => @raylib.Color::new(240, 230, 60, 255)
    Light => @raylib.Color::new(250, 250, 250, 255)
    Shadow => @raylib.Color::new(160, 60, 200, 255)
    Steam => @raylib.Color::new(180, 180, 190, 255)
    Mud => @raylib.Color::new(130, 90, 50, 255)
    Magma => @raylib.Color::new(255, 140, 30, 255)
    Ice => @raylib.Color::new(100, 220, 240, 255)
    Lightning => @raylib.Color::new(255, 215, 0, 255)
    Dust => @raylib.Color::new(200, 180, 140, 255)
    Void => @raylib.Color::new(20, 10, 30, 255)
    Storm => @raylib.Color::new(30, 50, 140, 255)
    Obsidian => @raylib.Color::new(60, 55, 65, 255)
    Clay => @raylib.Color::new(190, 120, 80, 255)
  }
}

///|
pub fn is_base_element(e : Element) -> Bool {
  match e {
    Fire | Water | Earth | Air | Light | Shadow => true
    _ => false
  }
}

///|
pub fn tier_name(t : Tier) -> String {
  match t {
    Apprentice => "Apprentice"
    Journeyman => "Journeyman"
    Master => "Master"
  }
}

///|
pub fn tier_level_count(t : Tier) -> Int {
  match t {
    Apprentice => 8
    Journeyman => 9
    Master => 8
  }
}

///|
pub fn tier_start_index(t : Tier) -> Int {
  match t {
    Apprentice => 0
    Journeyman => 8
    Master => 17
  }
}

///|
pub fn new_budget(
  fire : Int,
  water : Int,
  earth : Int,
  air : Int,
  light : Int,
  shadow : Int,
) -> ElementBudget {
  { fire, water, earth, air, light, shadow }
}

///|
pub fn copy_budget(b : ElementBudget) -> ElementBudget {
  {
    fire: b.fire,
    water: b.water,
    earth: b.earth,
    air: b.air,
    light: b.light,
    shadow: b.shadow,
  }
}

///|
pub fn budget_get(b : ElementBudget, e : Element) -> Int {
  match e {
    Fire => b.fire
    Water => b.water
    Earth => b.earth
    Air => b.air
    Light => b.light
    Shadow => b.shadow
    _ => 0
  }
}

///|
pub fn budget_spend(b : ElementBudget, e : Element) -> Bool {
  match e {
    Fire =>
      if b.fire > 0 {
        b.fire -= 1
        true
      } else {
        false
      }
    Water =>
      if b.water > 0 {
        b.water -= 1
        true
      } else {
        false
      }
    Earth =>
      if b.earth > 0 {
        b.earth -= 1
        true
      } else {
        false
      }
    Air =>
      if b.air > 0 {
        b.air -= 1
        true
      } else {
        false
      }
    Light =>
      if b.light > 0 {
        b.light -= 1
        true
      } else {
        false
      }
    Shadow =>
      if b.shadow > 0 {
        b.shadow -= 1
        true
      } else {
        false
      }
    _ => false
  }
}

///|
pub fn new_anim() -> AnimState {
  { timer: 0.0, active: false, kind: None }
}

///|
pub fn new_level_score() -> LevelScore {
  { completed: false, stars: 0, best_steps: 0 }
}

///|
pub fn all_base_elements() -> Array[Element] {
  [Fire, Water, Earth, Air, Light, Shadow]
}

///|
pub fn new_game() -> Game {
  let recipe_book : Array[Recipe] = []
  let level_scores : Array[LevelScore] = []
  for _i in 0..<total_levels {
    level_scores.push(new_level_score())
  }
  {
    screen: Title,
    play_state: Idle,
    cauldron_substance: None,
    cauldron_history: [],
    recipe_book,
    current_tier: Apprentice,
    current_level_index: 0,
    level_scores,
    budget: new_budget(0, 0, 0, 0, 0, 0),
    steps_taken: 0,
    failed_attempts: 0,
    total_attempts: 0,
    discovered_count: 0,
    show_recipe_book: false,
    message: "",
    message_timer: 0.0,
    anim: new_anim(),
    frame_count: 0,
    selected_element: None,
    add_anim_element: None,
    add_anim_y: 0.0,
    result_stars: 0,
    result_steps: 0,
  }
}

///|
pub fn set_message(game : Game, msg : String) -> Unit {
  game.message = msg
  game.message_timer = message_duration
}

///|
pub fn start_anim(game : Game, kind : AnimKind, duration : Float) -> Unit {
  game.anim.active = true
  game.anim.kind = kind
  game.anim.timer = duration
}

///|
pub fn sinf(a : Float) -> Float {
  Float::from_double(@math.sin(a.to_double()))
}

///|
pub fn cosf(a : Float) -> Float {
  Float::from_double(@math.cos(a.to_double()))
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
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
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
pub fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}
