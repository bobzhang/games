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
pub fn maxi(a : Int, b : Int) -> Int {
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
pub fn vec2i(x : Int, y : Int) -> Vec2i {
  { x, y }
}

///|
pub fn phase_color(phase : Int) -> @raylib.Color {
  match phase % 4 {
    0 => color_emitter_p0
    1 => color_emitter_p1
    2 => color_emitter_p2
    3 => color_emitter_p3
    _ => color_emitter_p0
  }
}

///|
pub fn new_wave_tile() -> WaveTile {
  {
    amplitude: 0.0,
    phase: 0,
    has_wall: false,
    object: Empty,
    is_target: false,
    target_min: 0.0,
    target_max: 1.0,
    target_phase: -1,
    target_satisfied: false,
    wave_fronts: [],
  }
}

///|
pub fn new_wave_grid() -> WaveGrid {
  let tiles : Array[WaveTile] = Array::new(capacity=grid_width * grid_height)
  for _i in 0..<(grid_width * grid_height) {
    tiles.push(new_wave_tile())
  }
  { width: grid_width, height: grid_height, tiles }
}

///|
pub fn grid_index(x : Int, y : Int) -> Int {
  y * grid_width + x
}

///|
pub fn grid_get(grid : WaveGrid, x : Int, y : Int) -> WaveTile {
  grid.tiles[grid_index(x, y)]
}

///|
pub fn grid_in_bounds(x : Int, y : Int) -> Bool {
  x >= 0 && x < grid_width && y >= 0 && y < grid_height
}

///|
pub fn tile_screen_x(gx : Int) -> Float {
  Float::from_int(grid_offset_x + gx * tile_size)
}

///|
pub fn tile_screen_y(gy : Int) -> Float {
  Float::from_int(grid_offset_y + gy * tile_size)
}

///|
pub fn tile_center_x(gx : Int) -> Float {
  Float::from_int(grid_offset_x + gx * tile_size + tile_size / 2)
}

///|
pub fn tile_center_y(gy : Int) -> Float {
  Float::from_int(grid_offset_y + gy * tile_size + tile_size / 2)
}

///|
pub fn screen_to_grid_x(sx : Int) -> Int {
  (sx - grid_offset_x) / tile_size
}

///|
pub fn screen_to_grid_y(sy : Int) -> Int {
  (sy - grid_offset_y) / tile_size
}

///|
pub fn clone_grid(src : WaveGrid) -> WaveGrid {
  let tiles : Array[WaveTile] = Array::new(capacity=src.tiles.length())
  for i in 0..<src.tiles.length() {
    let t = src.tiles[i]
    tiles.push({
      amplitude: t.amplitude,
      phase: t.phase,
      has_wall: t.has_wall,
      object: t.object,
      is_target: t.is_target,
      target_min: t.target_min,
      target_max: t.target_max,
      target_phase: t.target_phase,
      target_satisfied: t.target_satisfied,
      wave_fronts: [],
    })
  }
  { width: src.width, height: src.height, tiles }
}

///|
pub fn new_level_score() -> LevelScore {
  { completed: false, stars: 0, objects_used: 0, ticks_used: 0 }
}

///|
pub fn new_game() -> Game {
  let scores : Array[LevelScore] = Array::new(capacity=total_levels)
  for _i in 0..<total_levels {
    scores.push(new_level_score())
  }
  {
    screen: Title,
    grid: new_wave_grid(),
    edit_grid: new_wave_grid(),
    current_level: 0,
    current_tier: 0,
    play_state: Editing,
    sim_tick: 0,
    sim_timer: 0.0,
    selected_slot: 0,
    cursor_x: 0,
    cursor_y: 0,
    scores,
    frame_count: 0,
    objects_placed: 0,
    emitter_phase: 0,
    message: "",
    message_timer: 0.0,
    sim_speed: 1.0,
  }
}

///|
pub fn placeable_kind_name(k : PlaceableKind) -> String {
  match k {
    PlaceEmitter => "Emitter"
    PlaceReflector => "Reflector"
    PlacePhaseShifter => "Phase Shifter"
    PlaceAbsorber => "Absorber"
  }
}

///|
pub fn placeable_kind_color(k : PlaceableKind) -> @raylib.Color {
  match k {
    PlaceEmitter => color_emitter_p0
    PlaceReflector => color_reflector
    PlacePhaseShifter => color_phase_shifter
    PlaceAbsorber => color_absorber
  }
}

///|
pub fn tile_kind_name(k : TileKind) -> String {
  match k {
    Empty => "Empty"
    Wall => "Wall"
    Target => "Target"
    Emitter(_) => "Emitter"
    Reflector => "Reflector"
    PhaseShifter => "Shifter"
    Absorber => "Absorber"
  }
}

// Direction helpers: dx, dy for direction index 0-3

///|
pub fn dir_dx(d : Int) -> Int {
  match d {
    0 => 0 // up
    1 => 1 // right
    2 => 0 // down
    3 => -1 // left
    _ => 0
  }
}

///|
pub fn dir_dy(d : Int) -> Int {
  match d {
    0 => -1 // up
    1 => 0 // right
    2 => 1 // down
    3 => 0 // left
    _ => 0
  }
}

///|
pub fn opposite_dir(d : Int) -> Int {
  (d + 2) % 4
}

///|
pub fn count_target_info(grid : WaveGrid) -> (Int, Int) {
  let mut satisfied = 0
  let mut total = 0
  for y in 0..<grid.height {
    for x in 0..<grid.width {
      let tile = grid_get(grid, x, y)
      if tile.is_target {
        total += 1
        if tile.target_satisfied {
          satisfied += 1
        }
      }
    }
  }
  (satisfied, total)
}
