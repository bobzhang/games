///|
pub fn get_level(id : Int) -> @types.LevelDef {
  match id {
    0 => get_level_1()
    1 => get_level_2()
    2 => get_level_3()
    3 => get_level_4()
    4 => get_level_5()
    5 => get_level_6()
    6 => get_level_7()
    7 => get_level_8()
    8 => get_level_9()
    9 => get_level_10()
    10 => get_level_11()
    11 => get_level_12()
    12 => get_level_13()
    13 => get_level_14()
    14 => get_level_15()
    15 => get_level_16()
    16 => get_level_17()
    17 => get_level_18()
    18 => get_level_19()
    _ => get_level_20()
  }
}

///|
pub fn get_tier_for_level(id : Int) -> @types.Tier {
  if id < 7 {
    Shallow
  } else if id < 14 {
    Middle
  } else {
    Deep
  }
}

///|
pub fn get_level_name(id : Int) -> String {
  get_level(id).name
}

///|
pub fn setup_level(game : @types.Game, level_id : Int) -> Unit {
  let level = get_level(level_id)
  game.current_level = Some(level)
  game.current_turn = 0
  game.current_cycle = 0
  game.tide_level = 1
  game.tide_phase = Low
  game.play_result = None
  game.sim_log = []
  game.selected_organism = None
  @types.clear_grid(game)
  for i in 0..<level.rock_cells.length() {
    let (r, c) = level.rock_cells[i]
    if @types.in_grid(r, c) {
      game.grid[r][c] = Rock
    }
  }
}
