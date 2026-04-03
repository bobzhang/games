///|
pub fn new_heddle_row(cols : Int) -> HeddleRow {
  { raised: Array::make(cols, false) }
}

///|
pub fn new_fabric_pattern(
  rows : Int,
  cols : Int,
  warp_colors : Array[Int],
  weft_colors : Array[Int],
) -> FabricPattern {
  let cells : Array[FabricCell] = Array::make(rows * cols, {
    state: WeftOver,
    color_index: 0,
  })
  { rows, cols, cells, warp_colors, weft_colors }
}

///|
pub fn pattern_get(p : FabricPattern, row : Int, col : Int) -> FabricCell {
  p.cells[row * p.cols + col]
}

///|
pub fn pattern_set(
  p : FabricPattern,
  row : Int,
  col : Int,
  cell : FabricCell,
) -> Unit {
  p.cells[row * p.cols + col] = cell
}

///|
pub fn new_level_score() -> LevelScore {
  { stars: 0, completed: false, best_changes: 999 }
}

///|
pub fn new_game() -> Game {
  let level_scores : Array[LevelScore] = []
  for _i in 0..<total_levels {
    level_scores.push(new_level_score())
  }
  let heddles : Array[HeddleRow] = []
  for _i in 0..<grid_rows {
    heddles.push(new_heddle_row(grid_cols))
  }
  {
    screen: Title,
    play_state: Weaving,
    current_level: 0,
    current_tier: Apprentice,
    heddles,
    warp_colors: [0, 1, 0, 1, 0, 1, 0, 1],
    weft_colors: Array::make(grid_rows, 0),
    target: new_fabric_pattern(grid_rows, grid_cols, [0], [0]),
    level_scores,
    heddle_changes: 0,
    selected_row: 0,
    message: "",
    message_timer: 0.0,
    frame_count: 0,
    anim_timer: 0.0,
    tier_select_index: 0,
    show_comparison: false,
    weave_type_guess: Plain,
    has_guessed_type: false,
    show_hint: false,
  }
}

///|
pub fn set_message(game : Game, msg : String, duration : Float) -> Unit {
  game.message = msg
  game.message_timer = duration
}

///|
/// Build player fabric from current heddle configuration
pub fn build_player_fabric(game : Game) -> FabricPattern {
  let p = new_fabric_pattern(
    grid_rows,
    grid_cols,
    game.warp_colors,
    game.weft_colors,
  )
  for row in 0..<grid_rows {
    let heddle = game.heddles[row]
    for col in 0..<grid_cols {
      let state : CellState = if heddle.raised[col] {
        WarpOver
      } else {
        WeftOver
      }
      let ci = if state == WarpOver {
        game.warp_colors[col]
      } else {
        game.weft_colors[row]
      }
      pattern_set(p, row, col, { state, color_index: ci })
    }
  }
  p
}

///|
/// Count how many cells match between player fabric and target
pub fn count_matches(player : FabricPattern, target : FabricPattern) -> Int {
  let mut matches = 0
  let total = target.rows * target.cols
  for i in 0..<total {
    if player.cells[i] == target.cells[i] {
      matches = matches + 1
    }
  }
  matches
}

///|
/// Check if the player fabric exactly matches the target
pub fn patterns_match(player : FabricPattern, target : FabricPattern) -> Bool {
  count_matches(player, target) == target.rows * target.cols
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
pub fn tier_levels(t : Tier) -> (Int, Int) {
  match t {
    Apprentice => (0, tier1_count)
    Journeyman => (tier1_count, tier2_count)
    Master => (tier1_count + tier2_count, tier3_count)
  }
}

///|
pub fn weave_type_name(w : WeaveType) -> String {
  match w {
    Plain => "Plain"
    Twill => "Twill"
    Satin => "Satin"
    Herringbone => "Herringbone"
    Diamond => "Diamond"
    Custom => "Custom"
  }
}

///|
pub fn cell_color(ci : Int) -> @raylib.Color {
  if ci >= 0 && ci < thread_colors.length() {
    thread_colors[ci]
  } else {
    @raylib.Color::new(128, 128, 128, 255)
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
pub fn absi(v : Int) -> Int {
  if v < 0 {
    -v
  } else {
    v
  }
}
