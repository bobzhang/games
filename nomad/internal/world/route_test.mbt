// Tests for nomad/internal/world route planning and execution

// Helper: create a small 4x4 all-Sand map for testing
///|
fn make_test_map() -> @types.HexMap {
  let m = @types.new_hex_map(4, 4)
  m
}

// Helper: set a tile kind on the map
///|
fn set_tile(m : @types.HexMap, col : Int, row : Int, kind : @types.TileKind) -> Unit {
  m.tiles[row][col] = { kind, }
}

// --- validate_route_step ---

///|
test "validate_route_step adjacent sand tile" {
  let m = make_test_map()
  // (0,0) even row neighbors include (1,0)
  inspect!(
    validate_route_step(m, { col: 0, row: 0 }, { col: 1, row: 0 }),
    content="true",
  )
}

///|
test "validate_route_step non-adjacent tiles" {
  let m = make_test_map()
  inspect!(
    validate_route_step(m, { col: 0, row: 0 }, { col: 3, row: 3 }),
    content="false",
  )
}

///|
test "validate_route_step out of bounds" {
  let m = make_test_map()
  inspect!(
    validate_route_step(m, { col: 0, row: 0 }, { col: -1, row: 0 }),
    content="false",
  )
}

///|
test "validate_route_step into sandstorm blocked" {
  let m = make_test_map()
  set_tile(m, 1, 0, Sandstorm)
  inspect!(
    validate_route_step(m, { col: 0, row: 0 }, { col: 1, row: 0 }),
    content="false",
  )
}

///|
test "validate_route_step into oasis allowed" {
  let m = make_test_map()
  set_tile(m, 1, 0, Oasis)
  inspect!(
    validate_route_step(m, { col: 0, row: 0 }, { col: 1, row: 0 }),
    content="true",
  )
}

///|
test "validate_route_step into destination allowed" {
  let m = make_test_map()
  set_tile(m, 1, 0, Destination)
  inspect!(
    validate_route_step(m, { col: 0, row: 0 }, { col: 1, row: 0 }),
    content="true",
  )
}

///|
test "validate_route_step into ruins allowed" {
  let m = make_test_map()
  set_tile(m, 1, 0, Ruins)
  inspect!(
    validate_route_step(m, { col: 0, row: 0 }, { col: 1, row: 0 }),
    content="true",
  )
}

// --- calculate_route_water_cost ---

///|
test "calculate_route_water_cost empty route" {
  let m = make_test_map()
  let route : Array[@types.HexCoord] = []
  inspect!(calculate_route_water_cost(m, route), content="0")
}

///|
test "calculate_route_water_cost all sand" {
  let m = make_test_map()
  let route : Array[@types.HexCoord] = [
    { col: 1, row: 0 },
    { col: 2, row: 0 },
    { col: 3, row: 0 },
  ]
  // Sand costs 1 each => total 3
  inspect!(calculate_route_water_cost(m, route), content="3")
}

///|
test "calculate_route_water_cost mixed tiles" {
  let m = make_test_map()
  set_tile(m, 1, 0, Dunes) // cost 2
  set_tile(m, 2, 0, Oasis) // cost 0
  // route: Dunes(2) + Oasis(0) + Sand(1) = 3
  let route : Array[@types.HexCoord] = [
    { col: 1, row: 0 },
    { col: 2, row: 0 },
    { col: 3, row: 0 },
  ]
  inspect!(calculate_route_water_cost(m, route), content="3")
}

///|
test "calculate_route_water_cost dunes expensive" {
  let m = make_test_map()
  set_tile(m, 1, 0, Dunes)
  set_tile(m, 2, 0, Dunes)
  set_tile(m, 3, 0, Dunes)
  let route : Array[@types.HexCoord] = [
    { col: 1, row: 0 },
    { col: 2, row: 0 },
    { col: 3, row: 0 },
  ]
  // 3 dunes * 2 = 6
  inspect!(calculate_route_water_cost(m, route), content="6")
}

///|
test "calculate_route_water_cost ruins are free" {
  let m = make_test_map()
  set_tile(m, 1, 0, Ruins)
  set_tile(m, 2, 0, Ruins)
  let route : Array[@types.HexCoord] = [
    { col: 1, row: 0 },
    { col: 2, row: 0 },
  ]
  inspect!(calculate_route_water_cost(m, route), content="0")
}

// --- is_route_valid ---

///|
test "is_route_valid empty route" {
  let m = make_test_map()
  let route : Array[@types.HexCoord] = []
  inspect!(is_route_valid(m, route, { col: 0, row: 0 }), content="false")
}

///|
test "is_route_valid single step adjacent" {
  let m = make_test_map()
  let route : Array[@types.HexCoord] = [{ col: 1, row: 0 }]
  inspect!(is_route_valid(m, route, { col: 0, row: 0 }), content="true")
}

///|
test "is_route_valid first step not adjacent to start" {
  let m = make_test_map()
  let route : Array[@types.HexCoord] = [{ col: 3, row: 3 }]
  inspect!(is_route_valid(m, route, { col: 0, row: 0 }), content="false")
}

///|
test "is_route_valid multi-step valid chain" {
  let m = make_test_map()
  // Even row 0: (0,0)->(1,0)->(2,0)->(3,0) all adjacent
  let route : Array[@types.HexCoord] = [
    { col: 1, row: 0 },
    { col: 2, row: 0 },
    { col: 3, row: 0 },
  ]
  inspect!(is_route_valid(m, route, { col: 0, row: 0 }), content="true")
}

///|
test "is_route_valid broken chain in middle" {
  let m = make_test_map()
  // (1,0) and (3,0) are not adjacent
  let route : Array[@types.HexCoord] = [
    { col: 1, row: 0 },
    { col: 3, row: 0 },
  ]
  inspect!(is_route_valid(m, route, { col: 0, row: 0 }), content="false")
}

///|
test "is_route_valid blocked by sandstorm mid-route" {
  let m = make_test_map()
  set_tile(m, 2, 0, Sandstorm)
  let route : Array[@types.HexCoord] = [
    { col: 1, row: 0 },
    { col: 2, row: 0 },
  ]
  // First step OK, second step into sandstorm => validate_route_step fails
  inspect!(is_route_valid(m, route, { col: 0, row: 0 }), content="false")
}

// --- execute_route_step ---

///|
test "execute_route_step on sand decrements water" {
  let m = make_test_map()
  let caravan = @types.new_caravan({ col: 0, row: 0 }, 10)
  caravan.route = [{ col: 1, row: 0 }]
  caravan.route_index = 0
  let state = execute_route_step(caravan, m)
  // Sand costs 1 water, route is done after 1 step
  inspect!(caravan.water, content="9")
  inspect!(caravan.pos, content="{col: 1, row: 0}")
  inspect!(state, content="Complete")
}

///|
test "execute_route_step on dunes costs 2 water" {
  let m = make_test_map()
  set_tile(m, 1, 0, Dunes)
  let caravan = @types.new_caravan({ col: 0, row: 0 }, 10)
  caravan.route = [{ col: 1, row: 0 }, { col: 2, row: 0 }]
  caravan.route_index = 0
  let state = execute_route_step(caravan, m)
  inspect!(caravan.water, content="8")
  inspect!(state, content="Executing")
}

///|
test "execute_route_step oasis refills water to max" {
  let m = make_test_map()
  set_tile(m, 1, 0, Oasis)
  let caravan = @types.new_caravan({ col: 0, row: 0 }, 10)
  caravan.water = 3 // partially depleted
  caravan.route = [{ col: 1, row: 0 }, { col: 2, row: 0 }]
  caravan.route_index = 0
  let state = execute_route_step(caravan, m)
  // Oasis costs 0 water and refills to max_water
  inspect!(caravan.water, content="10")
  inspect!(state, content="Executing")
}

///|
test "execute_route_step trade post with artifacts sells them" {
  let m = make_test_map()
  set_tile(m, 1, 0, TradePost)
  let caravan = @types.new_caravan({ col: 0, row: 0 }, 10)
  caravan.artifacts = 3
  caravan.route = [{ col: 1, row: 0 }]
  caravan.route_index = 0
  let _state = execute_route_step(caravan, m)
  // TradePost costs 1 water. With 3 artifacts: gold += 3*15 = 45, artifacts reset to 0
  inspect!(caravan.water, content="9")
  inspect!(caravan.gold, content="45")
  inspect!(caravan.artifacts, content="0")
}

///|
test "execute_route_step trade post without artifacts gives 5 gold" {
  let m = make_test_map()
  set_tile(m, 1, 0, TradePost)
  let caravan = @types.new_caravan({ col: 0, row: 0 }, 10)
  caravan.route = [{ col: 1, row: 0 }]
  caravan.route_index = 0
  let _state = execute_route_step(caravan, m)
  inspect!(caravan.gold, content="5")
  inspect!(caravan.artifacts, content="0")
}

///|
test "execute_route_step ruins grants artifact" {
  let m = make_test_map()
  set_tile(m, 1, 0, Ruins)
  let caravan = @types.new_caravan({ col: 0, row: 0 }, 10)
  caravan.route = [{ col: 1, row: 0 }]
  caravan.route_index = 0
  // Seed RNG so roll >= 30 (no sandstorm penalty); seed 1 gives roll=38
  @types.seed_rng(1)
  let _state = execute_route_step(caravan, m)
  inspect!(caravan.artifacts, content="1")
  // Ruins cost 0 water, check water unchanged (no storm hit)
  inspect!(caravan.water, content="10")
}

///|
test "execute_route_step ruins sandstorm risk triggers" {
  let m = make_test_map()
  set_tile(m, 1, 0, Ruins)
  let caravan = @types.new_caravan({ col: 0, row: 0 }, 10)
  caravan.route = [{ col: 1, row: 0 }]
  caravan.route_index = 0
  // Find a seed where rng_int(100) < 30
  // Try seeds until we find one that triggers the sandstorm
  let mut found_seed = 0
  for s in 0..<200 {
    @types.seed_rng(s)
    let roll = @types.rng_int(100)
    if roll < 30 {
      found_seed = s
      break
    }
  }
  @types.seed_rng(found_seed)
  let _state = execute_route_step(caravan, m)
  // Artifact collected + storm hit: water should be 10 - 0 (ruins cost) - 3 (storm) = 7
  inspect!(caravan.artifacts, content="1")
  inspect!(caravan.water, content="7")
}

///|
test "execute_route_step fails when water runs out" {
  let m = make_test_map()
  set_tile(m, 1, 0, Dunes) // costs 2
  let caravan = @types.new_caravan({ col: 0, row: 0 }, 1)
  caravan.water = 1
  caravan.route = [{ col: 1, row: 0 }]
  caravan.route_index = 0
  let state = execute_route_step(caravan, m)
  inspect!(state, content="Failed")
  inspect!(caravan.water, content="0")
}

///|
test "execute_route_step complete when route_index at end" {
  let m = make_test_map()
  let caravan = @types.new_caravan({ col: 1, row: 0 }, 10)
  caravan.route = [{ col: 1, row: 0 }]
  caravan.route_index = 1 // already past end
  let state = execute_route_step(caravan, m)
  inspect!(state, content="Complete")
}

///|
test "execute_route_step multi-step continues as Executing" {
  let m = make_test_map()
  let caravan = @types.new_caravan({ col: 0, row: 0 }, 10)
  caravan.route = [{ col: 1, row: 0 }, { col: 2, row: 0 }, { col: 3, row: 0 }]
  caravan.route_index = 0
  let state1 = execute_route_step(caravan, m)
  inspect!(state1, content="Executing")
  inspect!(caravan.route_index, content="1")
  let state2 = execute_route_step(caravan, m)
  inspect!(state2, content="Executing")
  inspect!(caravan.route_index, content="2")
  let state3 = execute_route_step(caravan, m)
  inspect!(state3, content="Complete")
  inspect!(caravan.route_index, content="3")
  inspect!(caravan.water, content="7") // 10 - 3 sand steps
}

///|
test "execute_route_step ruins storm can cause failure with low water" {
  let m = make_test_map()
  set_tile(m, 1, 0, Ruins)
  let caravan = @types.new_caravan({ col: 0, row: 0 }, 10)
  caravan.water = 2 // low water
  caravan.route = [{ col: 1, row: 0 }]
  caravan.route_index = 0
  // Find seed that triggers storm (roll < 30)
  let mut found_seed = 0
  for s in 0..<200 {
    @types.seed_rng(s)
    let roll = @types.rng_int(100)
    if roll < 30 {
      found_seed = s
      break
    }
  }
  @types.seed_rng(found_seed)
  let state = execute_route_step(caravan, m)
  // Ruins cost 0, but storm hits -3, so 2-3 = -1 => clamped to 0, Failed
  inspect!(state, content="Failed")
  inspect!(caravan.water, content="0")
  // Artifact was still collected before the storm check
  inspect!(caravan.artifacts, content="1")
}

// --- calculate_stars ---

///|
test "calculate_stars not reached destination" {
  inspect!(calculate_stars(false, 100, 50, 5, 5), content="0")
}

///|
test "calculate_stars reached but below gold target" {
  inspect!(calculate_stars(true, 10, 50, 0, 3), content="1")
}

///|
test "calculate_stars reached and met gold target" {
  inspect!(calculate_stars(true, 50, 50, 0, 3), content="2")
}

///|
test "calculate_stars reached gold target exceeded" {
  inspect!(calculate_stars(true, 100, 50, 0, 3), content="2")
}

///|
test "calculate_stars 3 stars requires gold and all artifacts" {
  inspect!(calculate_stars(true, 50, 50, 3, 3), content="3")
}

///|
test "calculate_stars gold met but missing artifacts gets 2" {
  inspect!(calculate_stars(true, 50, 50, 2, 3), content="2")
}

///|
test "calculate_stars all artifacts but not enough gold gets 1" {
  inspect!(calculate_stars(true, 10, 50, 3, 3), content="1")
}

// --- Integration: full route execution scenario ---

///|
test "integration: plan and execute short route through oasis" {
  let m = make_test_map()
  set_tile(m, 1, 0, Sand)
  set_tile(m, 2, 0, Oasis)
  set_tile(m, 3, 0, Destination)
  let start : @types.HexCoord = { col: 0, row: 0 }
  let route : Array[@types.HexCoord] = [
    { col: 1, row: 0 },
    { col: 2, row: 0 },
    { col: 3, row: 0 },
  ]
  // Validate
  inspect!(is_route_valid(m, route, start), content="true")
  // Water cost: Sand(1) + Oasis(0) + Destination(1) = 2
  inspect!(calculate_route_water_cost(m, route), content="2")
  // Execute
  let caravan = @types.new_caravan(start, 5)
  caravan.route = route
  caravan.route_index = 0
  let s1 = execute_route_step(caravan, m) // Sand: 5-1=4
  inspect!(s1, content="Executing")
  inspect!(caravan.water, content="4")
  let s2 = execute_route_step(caravan, m) // Oasis: refill to 5
  inspect!(s2, content="Executing")
  inspect!(caravan.water, content="5")
  let s3 = execute_route_step(caravan, m) // Destination: 5-1=4
  inspect!(s3, content="Complete")
  inspect!(caravan.water, content="4")
  inspect!(caravan.pos, content="{col: 3, row: 0}")
}

///|
test "integration: trade post sell artifacts for gold" {
  let m = make_test_map()
  set_tile(m, 1, 0, Ruins)
  set_tile(m, 2, 0, TradePost)
  let start : @types.HexCoord = { col: 0, row: 0 }
  let caravan = @types.new_caravan(start, 20)
  caravan.route = [{ col: 1, row: 0 }, { col: 2, row: 0 }]
  caravan.route_index = 0
  // Seed RNG to avoid sandstorm at ruins (roll >= 30)
  // Find a safe seed
  let mut safe_seed = 0
  for s in 0..<200 {
    @types.seed_rng(s)
    let roll = @types.rng_int(100)
    if roll >= 30 {
      safe_seed = s
      break
    }
  }
  @types.seed_rng(safe_seed)
  let _s1 = execute_route_step(caravan, m) // Ruins: +1 artifact
  inspect!(caravan.artifacts, content="1")
  let _s2 = execute_route_step(caravan, m) // TradePost: sell 1 artifact for 15 gold
  inspect!(caravan.gold, content="15")
  inspect!(caravan.artifacts, content="0")
}
