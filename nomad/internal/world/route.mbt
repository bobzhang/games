///|
pub fn validate_route_step(
  map : @types.HexMap,
  from : @types.HexCoord,
  to : @types.HexCoord,
) -> Bool {
  // Must be adjacent
  if !@types.hex_are_adjacent(from, to) {
    return false
  }
  // Must be in bounds
  if !@types.hex_in_bounds(to, map.width, map.height) {
    return false
  }
  // Cannot step into sandstorm
  let tile = map.tiles[to.row][to.col]
  if tile.kind == Sandstorm {
    return false
  }
  true
}

///|
pub fn calculate_route_water_cost(
  map : @types.HexMap,
  route : Array[@types.HexCoord],
) -> Int {
  let mut total = 0
  for i in 0..<route.length() {
    let coord = route[i]
    if @types.hex_in_bounds(coord, map.width, map.height) {
      let tile = map.tiles[coord.row][coord.col]
      total += @types.water_cost(tile.kind)
    }
  }
  total
}

///|
pub fn execute_route_step(
  caravan : @types.Caravan,
  map : @types.HexMap,
) -> @types.PlayState {
  if caravan.route_index >= caravan.route.length() {
    // Check if we reached destination
    return Complete
  }
  let next = caravan.route[caravan.route_index]
  let tile = map.tiles[next.row][next.col]
  // Apply water cost
  let cost = @types.water_cost(tile.kind)
  caravan.water -= cost
  if caravan.water < 0 {
    caravan.water = 0
    return Failed
  }
  // Move caravan
  caravan.pos = next
  caravan.route_index += 1
  // Apply tile effects
  match tile.kind {
    Oasis => caravan.water = caravan.max_water
    TradePost =>
      // Sell artifacts for gold, or gain some gold
      if caravan.artifacts > 0 {
        caravan.gold += caravan.artifacts * 15
        caravan.artifacts = 0
      } else {
        caravan.gold += 5
      }
    Ruins => {
      // Collect artifact, but 30% sandstorm risk
      caravan.artifacts += 1
      // Check for sandstorm (resolved with rng)
      let roll = @types.rng_int(100)
      if roll < 30 {
        // Sandstorm hits! Lose 3 water
        caravan.water -= 3
        if caravan.water < 0 {
          caravan.water = 0
          return Failed
        }
      }
    }
    _ => ()
  }
  // Check if reached end of route
  if caravan.route_index >= caravan.route.length() {
    Complete
  } else {
    Executing
  }
}

///|
pub fn is_route_valid(
  map : @types.HexMap,
  route : Array[@types.HexCoord],
  start : @types.HexCoord,
) -> Bool {
  if route.length() == 0 {
    return false
  }
  // First step must be adjacent to start
  if !@types.hex_are_adjacent(start, route[0]) {
    return false
  }
  // Each step must be adjacent to previous
  for i in 1..<route.length() {
    if !validate_route_step(map, route[i - 1], route[i]) {
      return false
    }
  }
  true
}

///|
pub fn calculate_stars(
  reached_dest : Bool,
  gold : Int,
  gold_target : Int,
  artifacts : Int,
  total_artifacts : Int,
) -> Int {
  if !reached_dest {
    return 0
  }
  let mut stars = 1
  if gold >= gold_target {
    stars = 2
  }
  if gold >= gold_target && artifacts >= total_artifacts {
    stars = 3
  }
  stars
}
