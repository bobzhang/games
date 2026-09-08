///|
pub fn hex_key(q : Int, r : Int) -> String {
  q.to_string() + "," + r.to_string()
}

///|
pub fn new_hex_cell() -> HexCell {
  {
    component: None,
    direction: E,
    filter_color: None,
    crystal_face: None,
    target_color: None,
    locked: false,
    received_color: None,
  }
}

///|
pub fn new_hex_grid() -> HexGrid {
  let cells : Map[String, HexCell] = Map([])
  let radius = grid_radius
  // Generate axial coords for hex grid with given radius.
  // For a hex grid of radius R, valid cells are those where
  // |q| <= R, |r| <= R, and |q+r| <= R.
  for q in -radius..<=radius {
    for r in -radius..<=radius {
      let s = -q - r
      if absint(s) <= radius {
        cells[hex_key(q, r)] = new_hex_cell()
      }
    }
  }
  { radius, cells, }
}

///|
pub fn grid_get(grid : HexGrid, q : Int, r : Int) -> HexCell? {
  grid.cells.get(hex_key(q, r))
}

///|
pub fn grid_in_bounds(grid : HexGrid, q : Int, r : Int) -> Bool {
  grid.cells.contains(hex_key(q, r))
}

///|
pub fn grid_clear(grid : HexGrid) -> Unit {
  for _k, cell in grid.cells {
    cell.component = None
    cell.direction = E
    cell.filter_color = None
    cell.crystal_face = None
    cell.target_color = None
    cell.locked = false
    cell.received_color = None
  }
}

///|
pub fn grid_clear_received(grid : HexGrid) -> Unit {
  for _k, cell in grid.cells {
    cell.received_color = None
  }
}

///|
pub fn grid_cell_count(grid : HexGrid) -> Int {
  grid.cells.length()
}

///|
/// Convert axial hex coords to pixel coords (flat-top hex).
/// For flat-top hexes:
///   x = size * (3/2 * q)
///   y = size * (sqrt(3)/2 * q + sqrt(3) * r)
pub fn hex_to_pixel_x(q : Int, _r : Int) -> Float {
  let fq = Float::from_int(q)
  let size = Float::from_int(hex_size)
  Float::from_int(grid_offset_x) + size * 1.5 * fq
}

///|
pub fn hex_to_pixel_y(q : Int, r : Int) -> Float {
  let fq = Float::from_int(q)
  let fr = Float::from_int(r)
  let size = Float::from_int(hex_size)
  Float::from_int(grid_offset_y) +
  size * (hex_inner_ratio * fq + 2.0 * hex_inner_ratio * fr)
}

///|
/// Convert pixel coords to nearest hex axial coords (flat-top).
pub fn pixel_to_hex(px : Float, py : Float) -> (Int, Int) {
  let size = Float::from_int(hex_size)
  let x = px - Float::from_int(grid_offset_x)
  let y = py - Float::from_int(grid_offset_y)
  // For flat-top hex:
  // q = 2/3 * x / size
  // r = (-1/3 * x + sqrt(3)/3 * y) / size
  let fq = x * 2.0 / 3.0 / size
  let fr = (-x / 3.0 + y / (2.0 * hex_inner_ratio)) / size
  hex_round(fq, fr)
}

///|
fn roundf(v : Float) -> Int {
  if v >= 0.0 {
    (v + 0.5).to_int()
  } else {
    (v - 0.5).to_int()
  }
}

///|
/// Round fractional hex coords to nearest integer hex.
fn hex_round(fq : Float, fr : Float) -> (Int, Int) {
  let fs = -fq - fr
  let mut q = roundf(fq)
  let mut r = roundf(fr)
  let s = roundf(fs)
  let q_diff = absf(Float::from_int(q) - fq)
  let r_diff = absf(Float::from_int(r) - fr)
  let s_diff = absf(Float::from_int(s) - fs)
  if q_diff > r_diff && q_diff > s_diff {
    q = -r - s
  } else if r_diff > s_diff {
    r = -q - s
  }
  (q, r)
}

///|
pub fn absint(v : Int) -> Int {
  if v < 0 {
    -v
  } else {
    v
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
pub fn new_level_score() -> LevelScore {
  { stars: 0, solved: false, components_used: 0, }
}

///|
pub fn component_kind_name(kind : ComponentKind) -> String {
  match kind {
    Source => "Source"
    Crystal => "Crystal"
    Filter => "Filter"
    Mirror => "Mirror"
    Target => "Target"
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
pub fn crystal_face_name(cf : CrystalFace) -> String {
  match cf {
    Left60 => "L60"
    Right60 => "R60"
  }
}

///|
pub fn tier_name(t : Tier) -> String {
  match t {
    Fundamentals => "Fundamentals"
    Chromatics => "Chromatics"
    Mastery => "Mastery"
  }
}

///|
pub fn tier_index(t : Tier) -> Int {
  match t {
    Fundamentals => 0
    Chromatics => 1
    Mastery => 2
  }
}

///|
pub fn index_to_tier(i : Int) -> Tier {
  match i {
    0 => Fundamentals
    1 => Chromatics
    _ => Mastery
  }
}

///|
pub fn count_placed_components(grid : HexGrid) -> Int {
  let mut count = 0
  for _k, cell in grid.cells {
    match cell.component {
      Some(kind) =>
        if !cell.locked {
          match kind {
            Source | Target => ()
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
  let scores : Array[LevelScore] = Array::new(capacity=20)
  for _i in 0..<20 {
    scores.push(new_level_score())
  }
  {
    screen: Title,
    selected_tier: Fundamentals,
    selected_level: 0,
    grid: new_hex_grid(),
    beams: [],
    play_state: Placing,
    palette: [],
    selected_palette: 0,
    current_level_index: 0,
    current_tier_index: 0,
    hover_q: 0,
    hover_r: 0,
    hover_valid: false,
    scores,
    frame_count: 0,
    par_count: 0,
    level_name: "",
    show_help: false,
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

///|
/// Get all valid hex coordinates in the grid, sorted consistently.
pub fn grid_all_coords(grid : HexGrid) -> Array[(Int, Int)] {
  let coords : Array[(Int, Int)] = []
  let radius = grid.radius
  for q in -radius..<=radius {
    for r in -radius..<=radius {
      let s = -q - r
      if absint(s) <= radius {
        coords.push((q, r))
      }
    }
  }
  coords
}
