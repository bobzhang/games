///|
pub fn check_targets(grid : @types.Grid) -> Bool {
  for i in 0..<grid.tiles.length() {
    let tile = grid.tiles[i]
    if tile.is_target {
      if tile.weather != tile.target_weather {
        return false
      }
    }
  }
  true
}

///|
pub fn count_targets_met(grid : @types.Grid) -> (Int, Int) {
  let mut met = 0
  let mut total = 0
  for i in 0..<grid.tiles.length() {
    let tile = grid.tiles[i]
    if tile.is_target {
      total += 1
      if tile.weather == tile.target_weather {
        met += 1
      }
    }
  }
  (met, total)
}

///|
pub fn check_stable(
  grid : @types.Grid,
  prev : Array[@types.WeatherState]
) -> Bool {
  if prev.length() != grid.tiles.length() {
    return false
  }
  for i in 0..<grid.tiles.length() {
    if grid.tiles[i].weather != prev[i] {
      return false
    }
  }
  true
}

///|
pub fn calculate_stars(
  targets_met : Bool,
  sources_used : Int,
  turns_taken : Int,
  par_sources : Int,
  par_turns : Int
) -> Int {
  if !targets_met {
    return 0
  }
  let mut stars = 1
  if sources_used <= par_sources {
    stars = 2
  }
  if sources_used <= par_sources && turns_taken <= par_turns {
    stars = 3
  }
  stars
}
