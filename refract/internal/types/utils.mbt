///|
pub fn beam_color_black() -> BeamColor {
  { r: false, g: false, b: false, }
}

///|
pub fn beam_color_red() -> BeamColor {
  { r: true, g: false, b: false, }
}

///|
pub fn beam_color_green() -> BeamColor {
  { r: false, g: true, b: false, }
}

///|
pub fn beam_color_blue() -> BeamColor {
  { r: false, g: false, b: true, }
}

///|
pub fn beam_color_yellow() -> BeamColor {
  { r: true, g: true, b: false, }
}

///|
pub fn beam_color_magenta() -> BeamColor {
  { r: true, g: false, b: true, }
}

///|
pub fn beam_color_cyan() -> BeamColor {
  { r: false, g: true, b: true, }
}

///|
pub fn beam_color_white() -> BeamColor {
  { r: true, g: true, b: true, }
}

///|
pub fn beam_color_add(a : BeamColor, b : BeamColor) -> BeamColor {
  { r: a.r || b.r, g: a.g || b.g, b: a.b || b.b, }
}

///|
pub fn beam_color_remove_channel(
  color : BeamColor,
  filter : FilterColor,
) -> BeamColor {
  match filter {
    Red => { r: false, g: color.g, b: color.b, }
    Green => { r: color.r, g: false, b: color.b, }
    Blue => { r: color.r, g: color.g, b: false, }
  }
}

///|
pub fn beam_color_is_black(c : BeamColor) -> Bool {
  !c.r && !c.g && !c.b
}

///|
pub fn beam_color_channel_count(c : BeamColor) -> Int {
  let mut n = 0
  if c.r {
    n += 1
  }
  if c.g {
    n += 1
  }
  if c.b {
    n += 1
  }
  n
}

///|
pub fn beam_color_to_raylib(c : BeamColor) -> @raylib.Color {
  match (c.r, c.g, c.b) {
    (true, false, false) => color_beam_red
    (false, true, false) => color_beam_green
    (false, false, true) => color_beam_blue
    (true, true, false) => color_beam_yellow
    (true, false, true) => color_beam_magenta
    (false, true, true) => color_beam_cyan
    (true, true, true) => color_beam_white
    _ => @raylib.Color::new(40, 40, 40, 255)
  }
}

///|
pub fn beam_color_display_name(c : BeamColor) -> String {
  match (c.r, c.g, c.b) {
    (true, false, false) => "Red"
    (false, true, false) => "Green"
    (false, false, true) => "Blue"
    (true, true, false) => "Yellow"
    (true, false, true) => "Magenta"
    (false, true, true) => "Cyan"
    (true, true, true) => "White"
    _ => "None"
  }
}

///|
pub fn direction_opposite(d : Direction) -> Direction {
  match d {
    N => S
    E => W
    S => N
    W => E
  }
}

///|
pub fn direction_cw(d : Direction) -> Direction {
  match d {
    N => E
    E => S
    S => W
    W => N
  }
}

///|
pub fn direction_ccw(d : Direction) -> Direction {
  match d {
    N => W
    E => N
    S => E
    W => S
  }
}

///|
pub fn direction_dx(d : Direction) -> Int {
  match d {
    N => 0
    E => 1
    S => 0
    W => -1
  }
}

///|
pub fn direction_dy(d : Direction) -> Int {
  match d {
    N => -1
    E => 0
    S => 1
    W => 0
  }
}

///|
pub fn direction_name(d : Direction) -> String {
  match d {
    N => "N"
    E => "E"
    S => "S"
    W => "W"
  }
}

///|
pub fn vec2i(x : Int, y : Int) -> Vec2i {
  { x, y, }
}

///|
pub fn new_grid_cell() -> GridCell {
  {
    component: None,
    direction: N,
    filter_color: None,
    target_color: None,
    locked: false,
    received_color: None,
  }
}

///|
pub fn new_grid() -> Grid {
  let total = grid_width * grid_height
  let cells : Array[GridCell] = Array::new(capacity=total)
  for _i in 0..<total {
    cells.push(new_grid_cell())
  }
  { width: grid_width, height: grid_height, cells, }
}

///|
pub fn grid_get(grid : Grid, x : Int, y : Int) -> GridCell? {
  if x >= 0 && x < grid.width && y >= 0 && y < grid.height {
    Some(grid.cells[y * grid.width + x])
  } else {
    None
  }
}

///|
pub fn grid_in_bounds(grid : Grid, x : Int, y : Int) -> Bool {
  x >= 0 && x < grid.width && y >= 0 && y < grid.height
}

///|
pub fn grid_clear(grid : Grid) -> Unit {
  for i in 0..<grid.cells.length() {
    let cell = grid.cells[i]
    cell.component = None
    cell.direction = N
    cell.filter_color = None
    cell.target_color = None
    cell.locked = false
    cell.received_color = None
  }
}

///|
pub fn grid_clear_received(grid : Grid) -> Unit {
  for i in 0..<grid.cells.length() {
    grid.cells[i].received_color = None
  }
}

///|
pub fn new_level_score() -> LevelScore {
  { stars: 0, solved: false, components_used: 0, beam_crossings: 0, }
}

///|
pub fn component_kind_name(kind : ComponentKind) -> String {
  match kind {
    Source => "Source"
    Mirror => "Mirror"
    Prism => "Prism"
    Filter => "Filter"
    Combiner => "Combiner"
    Receiver => "Receiver"
  }
}

///|
pub fn filter_color_name(fc : FilterColor) -> String {
  match fc {
    Red => "Red"
    Green => "Green"
    Blue => "Blue"
  }
}

///|
pub fn tier_name(t : Tier) -> String {
  match t {
    Spectrum => "Spectrum"
    Prisms => "Prisms"
    Synthesis => "Synthesis"
  }
}

///|
pub fn tier_index(t : Tier) -> Int {
  match t {
    Spectrum => 0
    Prisms => 1
    Synthesis => 2
  }
}

///|
pub fn index_to_tier(i : Int) -> Tier {
  match i {
    0 => Spectrum
    1 => Prisms
    _ => Synthesis
  }
}

///|
pub fn mirror_reflect(incoming : Direction, facing : Direction) -> Direction? {
  // Mirror has 4 orientations: N=NE-SW slash, E=NW-SE backslash, S=NE-SW, W=NW-SE
  // N/S facing = "/" mirror, E/W facing = "\" mirror
  match facing {
    N | S =>
      // "/" mirror: N->E, E->N, S->W, W->S
      match incoming {
        N => Some(E)
        E => Some(N)
        S => Some(W)
        W => Some(S)
      }
    E | W =>
      // "\" mirror: N->W, W->N, S->E, E->S
      match incoming {
        N => Some(W)
        W => Some(N)
        S => Some(E)
        E => Some(S)
      }
  }
}

///|
pub fn sinf(a : Float) -> Float {
  Float::from_double(@math.cos(a.to_double()))
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
pub fn count_placed_components(grid : Grid) -> Int {
  let mut count = 0
  for i in 0..<grid.cells.length() {
    let cell = grid.cells[i]
    match cell.component {
      Some(kind) =>
        if !cell.locked {
          match kind {
            Source | Receiver => ()
            _ => count += 1
          }
        }
      None => ()
    }
  }
  count
}

///|
pub fn new_game() -> Game {
  let scores : Array[LevelScore] = Array::new(capacity=24)
  for _i in 0..<24 {
    scores.push(new_level_score())
  }
  {
    screen: Title,
    selected_tier: Spectrum,
    selected_level: 0,
    grid: new_grid(),
    beams: [],
    play_state: Placing,
    palette: [],
    selected_palette: 0,
    current_level_index: 0,
    current_tier_index: 0,
    hover_x: -1,
    hover_y: -1,
    scores,
    frame_count: 0,
    par_count: 0,
    level_name: "",
    show_help: false,
  }
}
