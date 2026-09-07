///|
pub fn new_cell(has_paper : Bool, layers : Int) -> PaperCell {
  { has_paper, layers, }
}

///|
pub fn new_paper(width : Int, height : Int) -> Paper {
  let cells : Array[PaperCell] = Array(capacity=width * height)
  let total = width * height
  for _i in 0..<total {
    cells.push({ has_paper: false, layers: 0, })
  }
  { width, height, cells, }
}

///|
pub fn full_paper(width : Int, height : Int) -> Paper {
  let cells : Array[PaperCell] = Array(capacity=width * height)
  let total = width * height
  for _i in 0..<total {
    cells.push({ has_paper: true, layers: 1, })
  }
  { width, height, cells, }
}

///|
pub fn get_cell(paper : Paper, x : Int, y : Int) -> PaperCell {
  if x >= 0 && x < paper.width && y >= 0 && y < paper.height {
    paper.cells[y * paper.width + x]
  } else {
    { has_paper: false, layers: 0, }
  }
}

///|
pub fn set_cell(
  paper : Paper,
  x : Int,
  y : Int,
  has_paper : Bool,
  layers : Int,
) -> Unit {
  if x >= 0 && x < paper.width && y >= 0 && y < paper.height {
    let idx = y * paper.width + x
    paper.cells[idx].has_paper = has_paper
    paper.cells[idx].layers = layers
  }
}

///|
pub fn clone_paper(paper : Paper) -> Paper {
  let cells : Array[PaperCell] = Array(capacity=paper.width * paper.height)
  for i in 0..<paper.cells.length() {
    cells.push({
      has_paper: paper.cells[i].has_paper,
      layers: paper.cells[i].layers,
    })
  }
  { width: paper.width, height: paper.height, cells, }
}

///|
pub fn paper_matches_silhouette(current : Paper, target : Paper) -> Bool {
  if current.width != target.width || current.height != target.height {
    return false
  }
  for i in 0..<current.cells.length() {
    if current.cells[i].has_paper != target.cells[i].has_paper {
      return false
    }
  }
  true
}

///|
pub fn check_layer_requirements(
  paper : Paper,
  checks : Array[LayerCheck],
) -> Bool {
  for i in 0..<checks.length() {
    let chk = checks[i]
    let cell = get_cell(paper, chk.pos.x, chk.pos.y)
    if !cell.has_paper || cell.layers != chk.required_layers {
      return false
    }
  }
  true
}

///|
pub fn single_layer_check_ok(paper : Paper, chk : LayerCheck) -> Bool {
  let cell = get_cell(paper, chk.pos.x, chk.pos.y)
  cell.has_paper && cell.layers == chk.required_layers
}

///|
pub fn count_paper_cells(paper : Paper) -> Int {
  let mut count = 0
  for i in 0..<paper.cells.length() {
    if paper.cells[i].has_paper {
      count += 1
    }
  }
  count
}

///|
pub fn max_layers(paper : Paper) -> Int {
  let mut mx = 0
  for i in 0..<paper.cells.length() {
    if paper.cells[i].has_paper && paper.cells[i].layers > mx {
      mx = paper.cells[i].layers
    }
  }
  mx
}

///|
pub fn make_rect_paper(
  width : Int,
  height : Int,
  x1 : Int,
  y1 : Int,
  x2 : Int,
  y2 : Int,
) -> Paper {
  let p = new_paper(width, height)
  for y in y1..<y2 {
    for x in x1..<x2 {
      set_cell(p, x, y, true, 1)
    }
  }
  p
}

///|
pub fn new_level_score() -> LevelScore {
  { completed: false, stars: Zero, folds_used: 0, }
}

///|
pub fn tier_color(tier : Tier) -> @raylib.Color {
  match tier {
    Folds => color_tier_folds
    Layers => color_tier_layers
    Craft => color_tier_craft
  }
}

///|
pub fn tier_name(tier : Tier) -> String {
  match tier {
    Folds => "Folds"
    Layers => "Layers"
    Craft => "Craft"
  }
}

///|
pub fn tier_level_count(tier : Tier) -> Int {
  match tier {
    Folds => tier1_count
    Layers => tier2_count
    Craft => tier3_count
  }
}

///|
pub fn tier_start_index(tier : Tier) -> Int {
  match tier {
    Folds => 0
    Layers => tier1_count
    Craft => tier1_count + tier2_count
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
pub fn absi(a : Int) -> Int {
  if a < 0 {
    -a
  } else {
    a
  }
}

///|
pub fn clamp_int(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn new_game() -> Game {
  let scores : Array[LevelScore] = Array(capacity=total_levels)
  for _i in 0..<total_levels {
    scores.push(new_level_score())
  }
  let dummy_paper = new_paper(grid_size, grid_size)
  let dummy_level : Level = {
    initial_paper: dummy_paper,
    target_silhouette: new_paper(grid_size, grid_size),
    layer_checks: [],
    par_folds: 1,
    tier: Folds,
    name: "",
  }
  {
    screen: Title,
    current_paper: new_paper(grid_size, grid_size),
    fold_history: [],
    target: dummy_level,
    current_tier: Folds,
    current_level_index: 0,
    fold_dir: Left,
    fold_line: 4,
    play_state: Selecting,
    anim_timer: 0.0,
    scores,
    frame_count: 0,
    message: "",
    message_timer: 0.0,
    hover_button: -1,
    show_target: false,
  }
}
