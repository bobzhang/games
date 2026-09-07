///|
pub fn weather_color(w : WeatherState) -> @raylib.Color {
  match w {
    Clear => color_clear
    Sunny => color_sunny
    Rainy => color_rainy
    Cloudy => color_cloudy
    Windy => color_windy
    Stormy => color_stormy
  }
}

///|
pub fn source_color(k : SourceKind) -> @raylib.Color {
  match k {
    Sun => color_source_sun
    Rain => color_source_rain
    Wind => color_source_wind
  }
}

///|
pub fn source_name(k : SourceKind) -> String {
  match k {
    Sun => "Sun"
    Rain => "Rain"
    Wind => "Wind"
  }
}

///|
pub fn weather_name(w : WeatherState) -> String {
  match w {
    Clear => "Clear"
    Sunny => "Sunny"
    Rainy => "Rainy"
    Cloudy => "Cloudy"
    Windy => "Windy"
    Stormy => "Stormy"
  }
}

///|
pub fn tier_name(t : Tier) -> String {
  match t {
    Spring => "Spring"
    Summer => "Summer"
    Monsoon => "Monsoon"
  }
}

///|
pub fn tier_color(t : Tier) -> @raylib.Color {
  match t {
    Spring => color_spring
    Summer => color_summer
    Monsoon => color_monsoon
  }
}

///|
pub fn tier_level_count(t : Tier) -> Int {
  match t {
    Spring => 8
    Summer => 9
    Monsoon => 8
  }
}

///|
pub fn tier_level_offset(t : Tier) -> Int {
  match t {
    Spring => 0
    Summer => 8
    Monsoon => 17
  }
}

///|
pub fn height_color(h : Int) -> @raylib.Color {
  if h <= 0 {
    color_height0
  } else if h == 1 {
    color_height1
  } else {
    color_height2
  }
}

///|
pub fn grid_index(col : Int, row : Int, width : Int) -> Int {
  row * width + col
}

///|
pub fn grid_get(g : Grid, col : Int, row : Int) -> Tile {
  g.tiles[grid_index(col, row, g.width)]
}

///|
pub fn in_bounds(col : Int, row : Int, width : Int, height : Int) -> Bool {
  col >= 0 && col < width && row >= 0 && row < height
}

///|
pub fn wind_dir_dx(d : WindDir) -> Int {
  match d {
    East => 1
    West => -1
    _ => 0
  }
}

///|
pub fn wind_dir_dy(d : WindDir) -> Int {
  match d {
    South => 1
    North => -1
    _ => 0
  }
}

///|
pub fn make_grid(
  width : Int,
  height : Int,
  heights : Array[Int],
  targets : Array[(Int, Int, WeatherState)],
) -> Grid {
  let tiles : Array[Tile] = []
  for r in 0..<height {
    for c in 0..<width {
      let idx = r * width + c
      let h = if idx < heights.length() { heights[idx] } else { 0 }
      let mut is_t = false
      let mut tw : WeatherState = Clear
      for t in 0..<targets.length() {
        let (tc, tr, tw2) = targets[t]
        if tc == c && tr == r {
          is_t = true
          tw = tw2
        }
      }
      tiles.push({
        weather: Clear,
        height: h,
        is_target: is_t,
        target_weather: tw,
      })
    }
  }
  { width, height, tiles, }
}

///|
pub fn clone_weather(g : Grid) -> Array[WeatherState] {
  let result : Array[WeatherState] = []
  for i in 0..<g.tiles.length() {
    result.push(g.tiles[i].weather)
  }
  result
}

///|
pub fn restore_weather(g : Grid, states : Array[WeatherState]) -> Unit {
  for i in 0..<g.tiles.length() {
    if i < states.length() {
      g.tiles[i].weather = states[i]
    }
  }
}

///|
pub fn clear_weather(g : Grid) -> Unit {
  for i in 0..<g.tiles.length() {
    g.tiles[i].weather = Clear
  }
}

///|
pub fn new_level_score() -> LevelScore {
  { stars: 0, completed: false, sources_used: 0, turns_taken: 0, }
}

///|
pub fn new_game() -> Game {
  let scores : Array[LevelScore] = []
  for _i in 0..<total_levels {
    scores.push(new_level_score())
  }
  {
    screen: Title,
    play_state: Placing,
    current_tier: Spring,
    current_level: 0,
    grid: make_grid(grid_cols, grid_rows, [], []),
    placed_sources: [],
    available_sources: [],
    selected_source: 0,
    wind_dir: East,
    turn_count: 0,
    cursor_col: 0,
    cursor_row: 0,
    level_scores: scores,
    history: [],
    anim_timer: 0.0,
    message: "",
    message_timer: 0.0,
    frame_count: 0,
    stable: false,
    prev_weather: [],
  }
}

///|
pub fn set_message(game : Game, msg : String, duration : Float) -> Unit {
  game.message = msg
  game.message_timer = duration
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
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
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

///|
pub fn sinf(a : Float) -> Float {
  Float::from_double(@math.sin(a.to_double()))
}

///|
pub fn cosf(a : Float) -> Float {
  Float::from_double(@math.cos(a.to_double()))
}
