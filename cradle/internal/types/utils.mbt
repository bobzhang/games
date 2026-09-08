///|
pub fn cosf(a : Float) -> Float {
  Float::from_double(@math.cos(a.to_double()))
}

///|
pub fn sinf(a : Float) -> Float {
  Float::from_double(@math.sin(a.to_double()))
}

///|
pub fn sqrtf(a : Float) -> Float {
  Float::from_double(a.to_double().sqrt())
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
pub fn vec2f(x : Float, y : Float) -> Vec2f {
  { x, y, }
}

///|
pub fn vec2f_dist(a : Vec2f, b : Vec2f) -> Float {
  let dx = a.x - b.x
  let dy = a.y - b.y
  sqrtf(dx * dx + dy * dy)
}

///|
pub fn peg_position(index : Int) -> Vec2f {
  let angle = Float::from_int(index) * 2.0 * pi / Float::from_int(peg_count) -
    pi / 2.0
  let x = frame_center_x + frame_radius * cosf(angle)
  let y = frame_center_y + frame_radius * sinf(angle)
  { x, y, }
}

///|
pub fn make_pegs() -> Array[Peg] {
  let pegs : Array[Peg] = Array::new(capacity=peg_count)
  for i in 0..<peg_count {
    pegs.push({ index: i, pos: peg_position(i), })
  }
  pegs
}

///|
pub fn tier_for_level(level_index : Int) -> Tier {
  if level_index < 8 {
    Lines
  } else if level_index < 17 {
    Weave
  } else {
    Art
  }
}

///|
pub fn tier_start_level(tier : Tier) -> Int {
  match tier {
    Lines => 0
    Weave => 8
    Art => 17
  }
}

///|
pub fn tier_level_count(tier : Tier) -> Int {
  match tier {
    Lines => 8
    Weave => 9
    Art => 8
  }
}

///|
pub fn tier_color(tier : Tier) -> @raylib.Color {
  match tier {
    Lines => color_tier_lines
    Weave => color_tier_weave
    Art => color_tier_art
  }
}

///|
pub fn tier_name(tier : Tier) -> String {
  match tier {
    Lines => "LINES"
    Weave => "WEAVE"
    Art => "ART"
  }
}

///|
pub fn new_level_score() -> LevelScore {
  { completed: false, stars: 0, strings_used: 0, }
}

///|
pub fn new_game(levels : Array[Level]) -> Game {
  let scores : Array[LevelScore] = Array::new(capacity=levels.length())
  for _i in 0..<levels.length() {
    scores.push(new_level_score())
  }
  {
    screen: Title,
    play_state: Placing,
    selected_tier: Lines,
    selected_level: 0,
    current_level: 0,
    pegs: make_pegs(),
    strings: [],
    intersections: [],
    targets: [],
    selected_peg: -1,
    hovered_peg: -1,
    level_data: levels,
    scores,
    frame_count: 0,
    message: "",
    message_timer: 0.0,
  }
}

///|
pub fn start_level(game : Game, level_index : Int) -> Unit {
  game.current_level = level_index
  game.play_state = Placing
  game.strings = []
  game.intersections = []
  game.selected_peg = -1
  game.hovered_peg = -1
  game.message = ""
  game.message_timer = 0.0
  let level = game.level_data[level_index]
  let targets : Array[TargetDot] = Array::new(capacity=level.targets.length())
  for i in 0..<level.targets.length() {
    targets.push({ pos: level.targets[i], hit: false, })
  }
  game.targets = targets
  game.screen = Playing
}

///|
pub fn set_message(game : Game, msg : String, duration : Float) -> Unit {
  game.message = msg
  game.message_timer = duration
}

///|
pub fn count_stars(game : Game, level_index : Int, strings_used : Int) -> Int {
  let level = game.level_data[level_index]
  // Check all targets hit
  let mut all_hit = true
  for i in 0..<game.targets.length() {
    if !game.targets[i].hit {
      all_hit = false
      break
    }
  }
  if !all_hit {
    return 0
  }
  // 1 star: all targets hit
  let mut stars = 1
  // 2 stars: within par
  if strings_used <= level.par_strings {
    stars = 2
  }
  // 3 stars: par + all tight tolerance
  if strings_used <= level.par_strings {
    let mut all_tight = true
    for i in 0..<game.targets.length() {
      if !game.targets[i].hit {
        all_tight = false
        break
      }
      // Check if matched intersection is within tight tolerance
      let mut found_tight = false
      for j in 0..<game.intersections.length() {
        if game.intersections[j].matched_target == i {
          let d = vec2f_dist(game.intersections[j].pos, game.targets[i].pos)
          if d <= tight_tolerance {
            found_tight = true
            break
          }
        }
      }
      if !found_tight {
        all_tight = false
        break
      }
    }
    if all_tight {
      stars = 3
    }
  }
  stars
}
