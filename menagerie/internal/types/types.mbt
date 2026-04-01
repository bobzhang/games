///|
pub(all) struct Cell {
  mut terrain : Terrain?
  mut fence_top : Bool
  mut fence_left : Bool
  mut animal : Species?
} derive(Show)

///|
pub(all) struct Grid {
  cells : Array[Array[Cell]]
  cols : Int
  rows : Int
} derive(Show)

///|
pub fn Grid::new(cols : Int, rows : Int) -> Grid {
  let cells : Array[Array[Cell]] = []
  for _r in 0..<rows {
    let row : Array[Cell] = []
    for _c in 0..<cols {
      row.push(
        { terrain: None, fence_top: false, fence_left: false, animal: None },
      )
    }
    cells.push(row)
  }
  { cells, cols, rows }
}

///|
pub fn Grid::get(self : Grid, col : Int, row : Int) -> Cell? {
  if col >= 0 && col < self.cols && row >= 0 && row < self.rows {
    Some(self.cells[row][col])
  } else {
    None
  }
}

///|
pub fn Grid::set_terrain(
  self : Grid,
  col : Int,
  row : Int,
  t : Terrain?
) -> Unit {
  if col >= 0 && col < self.cols && row >= 0 && row < self.rows {
    self.cells[row][col].terrain = t
  }
}

///|
pub fn Grid::set_animal(
  self : Grid,
  col : Int,
  row : Int,
  a : Species?
) -> Unit {
  if col >= 0 && col < self.cols && row >= 0 && row < self.rows {
    self.cells[row][col].animal = a
  }
}

///|
pub fn Grid::set_fence_top(
  self : Grid,
  col : Int,
  row : Int,
  v : Bool
) -> Unit {
  if col >= 0 && col < self.cols && row >= 0 && row < self.rows {
    self.cells[row][col].fence_top = v
  }
}

///|
pub fn Grid::set_fence_left(
  self : Grid,
  col : Int,
  row : Int,
  v : Bool
) -> Unit {
  if col >= 0 && col < self.cols && row >= 0 && row < self.rows {
    self.cells[row][col].fence_left = v
  }
}

///|
pub fn Grid::clear(self : Grid) -> Unit {
  for r in 0..<self.rows {
    for c in 0..<self.cols {
      self.cells[r][c].terrain = None
      self.cells[r][c].fence_top = false
      self.cells[r][c].fence_left = false
      self.cells[r][c].animal = None
    }
  }
}

///|
pub(all) struct Enclosure {
  id : Int
  cells : Array[(Int, Int)]
  mut species : Species?
} derive(Show)

///|
pub(all) struct LevelDef {
  id : Int
  tier : Int
  species : Array[Species]
  par_tiles : Int
  bonus_space : Int
  description : String
  preset_terrain : Array[(Int, Int, Terrain)]
  preset_fences : Array[(Int, Int, Bool, Bool)]
} derive(Show)

///|
pub(all) struct LevelResult {
  mut stars : StarRating
  mut all_needs_met : Bool
  mut tiles_used : Int
  mut par_tiles : Int
  mut bonus_met : Bool
  mut messages : Array[String]
} derive(Show)

///|
pub(all) struct ToolSlot {
  tool : Tool
  label : String
  color : @raylib.Color
} derive(Show)

///|
pub(all) struct Game {
  mut screen : Screen
  grid : Grid
  mut current_level : Int
  mut current_tool : Tool
  mut tool_slots : Array[ToolSlot]
  mut enclosures : Array[Enclosure]
  mut level_results : Array[LevelResult?]
  mut stars_earned : Array[Int]
  mut hover_col : Int
  mut hover_row : Int
  mut fence_mode : FenceMode
  mut message : String
  mut message_timer : Float
  mut anim_timer : Float
  mut frame_count : Int
  mut total_stars : Int
  mut levels_completed : Int
  mut level_select_scroll : Int
  mut show_needs_panel : Bool
} derive(Show)

///|
pub(all) enum FenceMode {
  Horizontal
  Vertical
} derive(Eq, Show)
