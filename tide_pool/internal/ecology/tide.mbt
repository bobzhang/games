///|
pub fn advance_tide(game : @types.Game) -> Unit {
  let (level, phase) = @types.get_tide_for_turn(game.current_turn)
  game.tide_level = level
  game.tide_phase = phase
}

///|
pub fn update_submersion(game : @types.Game) -> Unit {
  for i in 0..<game.organisms.length() {
    let org = game.organisms[i]
    if org.alive {
      let depth = @types.get_depth_at_col(game, org.col)
      org.submerged = @types.is_submerged(game.tide_level, depth, org.row)
    }
  }
}

///|
pub fn get_water_row(tide_level : Int, depth : Int) -> Int {
  @types.grid_rows - tide_level - depth
}
