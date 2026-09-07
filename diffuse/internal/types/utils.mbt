///|
pub fn ink_empty() -> InkColor {
  { c: false, m: false, y: false, }
}

///|
pub fn ink_cyan() -> InkColor {
  { c: true, m: false, y: false, }
}

///|
pub fn ink_magenta() -> InkColor {
  { c: false, m: true, y: false, }
}

///|
pub fn ink_yellow() -> InkColor {
  { c: false, m: false, y: true, }
}

///|
pub fn ink_blue() -> InkColor {
  { c: true, m: true, y: false, }
}

///|
pub fn ink_green() -> InkColor {
  { c: true, m: false, y: true, }
}

///|
pub fn ink_red() -> InkColor {
  { c: false, m: true, y: true, }
}

///|
pub fn ink_black() -> InkColor {
  { c: true, m: true, y: true, }
}

///|
pub fn ink_from_channel(ch : InkChannel) -> InkColor {
  match ch {
    Cyan => ink_cyan()
    Magenta => ink_magenta()
    Yellow => ink_yellow()
  }
}

///|
pub fn ink_mix(a : InkColor, b : InkColor) -> InkColor {
  { c: a.c || b.c, m: a.m || b.m, y: a.y || b.y, }
}

///|
pub fn ink_add_channel(ink : InkColor, ch : InkChannel) -> InkColor {
  match ch {
    Cyan => { c: true, m: ink.m, y: ink.y, }
    Magenta => { c: ink.c, m: true, y: ink.y, }
    Yellow => { c: ink.c, m: ink.m, y: true, }
  }
}

///|
pub fn ink_is_empty(ink : InkColor) -> Bool {
  !ink.c && !ink.m && !ink.y
}

///|
pub fn ink_equals(a : InkColor, b : InkColor) -> Bool {
  a.c == b.c && a.m == b.m && a.y == b.y
}

///|
pub fn ink_to_color(ink : InkColor) -> @raylib.Color {
  match (ink.c, ink.m, ink.y) {
    (false, false, false) => color_paper
    (true, false, false) => color_cyan
    (false, true, false) => color_magenta
    (false, false, true) => color_yellow
    (true, true, false) => color_blue
    (true, false, true) => color_green
    (false, true, true) => color_red
    (true, true, true) => color_black
  }
}

///|
pub fn ink_display_name(ink : InkColor) -> String {
  match (ink.c, ink.m, ink.y) {
    (false, false, false) => "Empty"
    (true, false, false) => "Cyan"
    (false, true, false) => "Magenta"
    (false, false, true) => "Yellow"
    (true, true, false) => "Blue"
    (true, false, true) => "Green"
    (false, true, true) => "Red"
    (true, true, true) => "Black"
  }
}

///|
pub fn channel_to_color(ch : InkChannel) -> @raylib.Color {
  match ch {
    Cyan => color_cyan
    Magenta => color_magenta
    Yellow => color_yellow
  }
}

///|
pub fn channel_name(ch : InkChannel) -> String {
  match ch {
    Cyan => "Cyan"
    Magenta => "Magenta"
    Yellow => "Yellow"
  }
}

///|
pub fn make_tile(kind : TileKind) -> Tile {
  { kind, ink: ink_empty(), target_color: ink_empty(), }
}

///|
pub fn make_target_tile(target : InkColor) -> Tile {
  { kind: Target, ink: ink_empty(), target_color: target, }
}

///|
pub fn make_grid(w : Int, h : Int) -> Grid {
  let tiles : Array[Tile] = []
  for i = 0; i < w * h; i = i + 1 {
    tiles.push(make_tile(Paper))
  }
  { width: w, height: h, tiles, }
}

///|
pub fn grid_index(g : Grid, col : Int, row : Int) -> Int {
  row * g.width + col
}

///|
pub fn grid_get(g : Grid, col : Int, row : Int) -> Tile {
  g.tiles[grid_index(g, col, row)]
}

///|
pub fn grid_set(g : Grid, col : Int, row : Int, tile : Tile) -> Unit {
  g.tiles[grid_index(g, col, row)] = tile
}

///|
pub fn grid_in_bounds(g : Grid, col : Int, row : Int) -> Bool {
  col >= 0 && col < g.width && row >= 0 && row < g.height
}

///|
pub fn clone_tile(t : Tile) -> Tile {
  {
    kind: t.kind,
    ink: { c: t.ink.c, m: t.ink.m, y: t.ink.y, },
    target_color: {
      c: t.target_color.c,
      m: t.target_color.m,
      y: t.target_color.y,
    },
  }
}

///|
pub fn clone_tiles(tiles : Array[Tile]) -> Array[Tile] {
  let result : Array[Tile] = []
  for i in 0..<tiles.length() {
    result.push(clone_tile(tiles[i]))
  }
  result
}

///|
pub fn clone_budget(b : InkBudget) -> InkBudget {
  { cyan: b.cyan, magenta: b.magenta, yellow: b.yellow, }
}

///|
pub fn budget_get(b : InkBudget, ch : InkChannel) -> Int {
  match ch {
    Cyan => b.cyan
    Magenta => b.magenta
    Yellow => b.yellow
  }
}

///|
pub fn budget_use(b : InkBudget, ch : InkChannel) -> Unit {
  match ch {
    Cyan => b.cyan = b.cyan - 1
    Magenta => b.magenta = b.magenta - 1
    Yellow => b.yellow = b.yellow - 1
  }
}

///|
pub fn tier_for_level(idx : Int) -> Tier {
  if idx < tier1_count {
    Watercolor
  } else if idx < tier1_count + tier2_count {
    Pigment
  } else {
    Palette
  }
}

///|
pub fn tier_name(t : Tier) -> String {
  match t {
    Watercolor => "Watercolor"
    Pigment => "Pigment"
    Palette => "Palette"
  }
}

///|
pub fn tier_start_index(t : Tier) -> Int {
  match t {
    Watercolor => 0
    Pigment => tier1_count
    Palette => tier1_count + tier2_count
  }
}

///|
pub fn tier_level_count(t : Tier) -> Int {
  match t {
    Watercolor => tier1_count
    Pigment => tier2_count
    Palette => tier3_count
  }
}

///|
pub fn new_level_score() -> LevelScore {
  { completed: false, stars: Zero, drops_used: 0, }
}

///|
pub fn new_game() -> Game {
  let scores : Array[LevelScore] = []
  for i = 0; i < total_levels; i = i + 1 {
    ignore(i)
    scores.push(new_level_score())
  }
  {
    screen: Title,
    selected_tier: Watercolor,
    selected_level: 0,
    grid: make_grid(grid_width, grid_height),
    budget: { cyan: 0, magenta: 0, yellow: 0, },
    par_drops: 0,
    drops_used: 0,
    turn: 0,
    selected_channel: Cyan,
    play_state: Placing,
    level_name: "",
    scores,
    history: [],
    hover_col: -1,
    hover_row: -1,
    frame_count: 0,
    spread_timer: 0.0,
    show_preview: true,
  }
}

///|
pub fn star_count(s : StarRating) -> Int {
  match s {
    Zero => 0
    One => 1
    Two => 2
    Three => 3
  }
}
