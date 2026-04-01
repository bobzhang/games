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
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
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
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
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
pub fn tile_index(x : Int, y : Int) -> Int {
  y * grid_cols + x
}

///|
pub fn valid_pos(x : Int, y : Int) -> Bool {
  x >= 0 && x < grid_cols && y >= 0 && y < grid_rows
}

///|
pub fn grid_to_pixel_x(gx : Int) -> Float {
  Float::from_int(grid_offset_x + gx * tile_size)
}

///|
pub fn grid_to_pixel_y(gy : Int) -> Float {
  Float::from_int(grid_offset_y + gy * tile_size)
}

///|
pub fn is_walkable(tile : Tile) -> Bool {
  match tile {
    Floor | Exit | Switch(_) | Platform | Gem => true
    Empty | Wall | Gap => false
  }
}

///|
pub fn is_solid_in_layer(tile : Tile, layer : Layer) -> Bool {
  match tile {
    Platform =>
      match layer {
        Foreground => true
        Background => false
      }
    _ => is_walkable(tile)
  }
}

///|
pub fn get_tile(tiles : Array[Tile], x : Int, y : Int) -> Tile {
  if valid_pos(x, y) {
    tiles[tile_index(x, y)]
  } else {
    Wall
  }
}

///|
pub fn set_tile(tiles : Array[Tile], x : Int, y : Int, t : Tile) -> Unit {
  if valid_pos(x, y) {
    tiles[tile_index(x, y)] = t
  }
}

///|
pub fn new_animation() -> Animation {
  { kind: PlayerMove, timer: 0.0, duration: 0.1, active: false }
}

///|
pub fn start_anim(anim : Animation, kind : AnimKind, duration : Float) -> Unit {
  anim.kind = kind
  anim.timer = 0.0
  anim.duration = duration
  anim.active = true
}

///|
pub fn update_anim(anim : Animation, dt : Float) -> Unit {
  if anim.active {
    anim.timer = anim.timer + dt
    if anim.timer >= anim.duration {
      anim.active = false
      anim.timer = anim.duration
    }
  }
}

///|
pub fn anim_progress(anim : Animation) -> Float {
  if anim.duration > 0.0 {
    clampf(anim.timer / anim.duration, 0.0, 1.0)
  } else {
    1.0
  }
}

///|
pub fn new_player(x : Int, y : Int, layer : Layer) -> Player {
  {
    grid_x: x,
    grid_y: y,
    pixel_x: grid_to_pixel_x(x),
    pixel_y: grid_to_pixel_y(y),
    target_x: grid_to_pixel_x(x),
    target_y: grid_to_pixel_y(y),
    moving: false,
    active_layer: layer,
    move_timer: 0.0,
  }
}

///|
pub fn new_level_result() -> LevelResult {
  { completed: false, stars: 0, best_swaps: 999 }
}

///|
pub fn empty_grid() -> Array[Tile] {
  Array::make(grid_cols * grid_rows, Empty)
}

///|
pub fn new_game() -> Game {
  let level_results : Array[LevelResult] = []
  for _i in 0..<total_levels {
    level_results.push(new_level_result())
  }
  {
    screen: Title,
    player: new_player(1, 1, Foreground),
    fg_tiles: empty_grid(),
    bg_tiles: empty_grid(),
    merge_state: Split,
    current_level: 0,
    swap_count: 0,
    gem_collected: false,
    level_results,
    anim: new_animation(),
    message: "",
    message_timer: 0.0,
    frame_count: 0,
    input_cooldown: 0.0,
    switch_states: Array::make(8, false),
    level_select_cursor: 0,
  }
}

///|
pub fn set_message(game : Game, msg : String, duration : Float) -> Unit {
  game.message = msg
  game.message_timer = duration
}

///|
pub fn tier_name(tier : Tier) -> String {
  match tier {
    Reflection => "Reflection"
    Overlap => "Overlap"
    Illusion => "Illusion"
  }
}

///|
pub fn tier_for_level(level : Int) -> Tier {
  if level < tier1_count {
    Reflection
  } else if level < tier1_count + tier2_count {
    Overlap
  } else {
    Illusion
  }
}

///|
pub fn level_unlocked(results : Array[LevelResult], level : Int) -> Bool {
  if level == 0 {
    true
  } else if level < results.length() {
    results[level - 1].completed
  } else {
    false
  }
}
