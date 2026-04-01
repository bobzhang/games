// Tests for nomad/internal/types utility functions

// --- Float math utilities ---

///|
test "absf with positive value" {
  inspect!(absf(3.5), content="3.5")
}

///|
test "absf with negative value" {
  inspect!(absf(-3.5), content="3.5")
}

///|
test "absf with zero" {
  inspect!(absf(0.0), content="0")
}

///|
test "maxf returns larger value" {
  inspect!(maxf(2.0, 5.0), content="5")
  inspect!(maxf(5.0, 2.0), content="5")
}

///|
test "maxf with equal values" {
  inspect!(maxf(3.0, 3.0), content="3")
}

///|
test "minf returns smaller value" {
  inspect!(minf(2.0, 5.0), content="2")
  inspect!(minf(5.0, 2.0), content="2")
}

///|
test "minf with equal values" {
  inspect!(minf(3.0, 3.0), content="3")
}

///|
test "clampf within range" {
  inspect!(clampf(5.0, 0.0, 10.0), content="5")
}

///|
test "clampf below lower bound" {
  inspect!(clampf(-3.0, 0.0, 10.0), content="0")
}

///|
test "clampf above upper bound" {
  inspect!(clampf(15.0, 0.0, 10.0), content="10")
}

///|
test "clampf at boundaries" {
  inspect!(clampf(0.0, 0.0, 10.0), content="0")
  inspect!(clampf(10.0, 0.0, 10.0), content="10")
}

///|
test "lerpf at t=0 returns a" {
  inspect!(lerpf(1.0, 5.0, 0.0), content="1")
}

///|
test "lerpf at t=1 returns b" {
  inspect!(lerpf(1.0, 5.0, 1.0), content="5")
}

///|
test "lerpf at t=0.5 returns midpoint" {
  inspect!(lerpf(0.0, 10.0, 0.5), content="5")
}

///|
test "maxi returns larger value" {
  inspect!(maxi(3, 7), content="7")
  inspect!(maxi(7, 3), content="7")
}

///|
test "mini returns smaller value" {
  inspect!(mini(3, 7), content="3")
  inspect!(mini(7, 3), content="3")
}

///|
test "sqrtf of 4" {
  inspect!(sqrtf(4.0), content="2")
}

///|
test "sqrtf of 0" {
  inspect!(sqrtf(0.0), content="0")
}

// --- RNG ---

///|
test "rng_int with max 0 returns 0" {
  inspect!(rng_int(0), content="0")
}

///|
test "rng_int with negative max returns 0" {
  inspect!(rng_int(-5), content="0")
}

///|
test "rng deterministic after seed" {
  seed_rng(42)
  let a = rng_next()
  seed_rng(42)
  let b = rng_next()
  inspect!(a == b, content="true")
}

///|
test "rng_int produces value in range" {
  seed_rng(100)
  let v = rng_int(10)
  inspect!(v >= 0 && v < 10, content="true")
}

///|
test "rng_float produces value in 0..1" {
  seed_rng(77)
  let v = rng_float()
  inspect!(v >= 0.0 && v < 1.0, content="true")
}

// --- Hex neighbor math (flat-top, odd-r offset) ---

///|
test "hex_neighbors even row returns 6 neighbors" {
  let neighbors = hex_neighbors({ col: 3, row: 2 })
  inspect!(neighbors.length(), content="6")
}

///|
test "hex_neighbors odd row returns 6 neighbors" {
  let neighbors = hex_neighbors({ col: 3, row: 3 })
  inspect!(neighbors.length(), content="6")
}

///|
test "hex_neighbors even row specific coords" {
  // Even row: offsets are (+1,0), (+1,-1), (0,-1), (-1,0), (0,+1), (+1,+1)
  let neighbors = hex_neighbors({ col: 3, row: 2 })
  inspect!(neighbors[0], content="{col: 4, row: 2}")
  inspect!(neighbors[1], content="{col: 4, row: 1}")
  inspect!(neighbors[2], content="{col: 3, row: 1}")
  inspect!(neighbors[3], content="{col: 2, row: 2}")
  inspect!(neighbors[4], content="{col: 3, row: 3}")
  inspect!(neighbors[5], content="{col: 4, row: 3}")
}

///|
test "hex_neighbors odd row specific coords" {
  // Odd row: offsets are (+1,0), (0,-1), (-1,-1), (-1,0), (-1,+1), (0,+1)
  let neighbors = hex_neighbors({ col: 3, row: 3 })
  inspect!(neighbors[0], content="{col: 4, row: 3}")
  inspect!(neighbors[1], content="{col: 3, row: 2}")
  inspect!(neighbors[2], content="{col: 2, row: 2}")
  inspect!(neighbors[3], content="{col: 2, row: 3}")
  inspect!(neighbors[4], content="{col: 2, row: 4}")
  inspect!(neighbors[5], content="{col: 3, row: 4}")
}

///|
test "hex_are_adjacent true for neighbors" {
  inspect!(hex_are_adjacent({ col: 3, row: 2 }, { col: 4, row: 2 }), content="true")
}

///|
test "hex_are_adjacent false for same cell" {
  inspect!(hex_are_adjacent({ col: 3, row: 2 }, { col: 3, row: 2 }), content="false")
}

///|
test "hex_are_adjacent false for distant cells" {
  inspect!(hex_are_adjacent({ col: 0, row: 0 }, { col: 5, row: 5 }), content="false")
}

///|
test "hex_are_adjacent symmetry" {
  let a : HexCoord = { col: 3, row: 2 }
  let b : HexCoord = { col: 4, row: 2 }
  inspect!(hex_are_adjacent(a, b), content="true")
  inspect!(hex_are_adjacent(b, a), content="true")
}

///|
test "hex_in_bounds valid coord" {
  inspect!(hex_in_bounds({ col: 0, row: 0 }, 10, 8), content="true")
  inspect!(hex_in_bounds({ col: 9, row: 7 }, 10, 8), content="true")
  inspect!(hex_in_bounds({ col: 5, row: 3 }, 10, 8), content="true")
}

///|
test "hex_in_bounds out of bounds" {
  inspect!(hex_in_bounds({ col: -1, row: 0 }, 10, 8), content="false")
  inspect!(hex_in_bounds({ col: 0, row: -1 }, 10, 8), content="false")
  inspect!(hex_in_bounds({ col: 10, row: 0 }, 10, 8), content="false")
  inspect!(hex_in_bounds({ col: 0, row: 8 }, 10, 8), content="false")
}

///|
test "hex_in_bounds zero-size map" {
  inspect!(hex_in_bounds({ col: 0, row: 0 }, 0, 0), content="false")
}

// --- Water cost per tile kind ---

///|
test "water_cost Sand" {
  inspect!(water_cost(Sand), content="1")
}

///|
test "water_cost Dunes" {
  inspect!(water_cost(Dunes), content="2")
}

///|
test "water_cost Oasis" {
  inspect!(water_cost(Oasis), content="0")
}

///|
test "water_cost TradePost" {
  inspect!(water_cost(TradePost), content="1")
}

///|
test "water_cost Ruins" {
  inspect!(water_cost(Ruins), content="0")
}

///|
test "water_cost Sandstorm" {
  inspect!(water_cost(Sandstorm), content="99")
}

///|
test "water_cost Destination" {
  inspect!(water_cost(Destination), content="1")
}

// --- Tile and tier name helpers ---

///|
test "tile_name all variants" {
  inspect!(tile_name(Sand), content="Sand")
  inspect!(tile_name(Dunes), content="Dunes")
  inspect!(tile_name(Oasis), content="Oasis")
  inspect!(tile_name(TradePost), content="Trade Post")
  inspect!(tile_name(Ruins), content="Ruins")
  inspect!(tile_name(Sandstorm), content="Sandstorm")
  inspect!(tile_name(Destination), content="Destination")
}

///|
test "tier_name all variants" {
  inspect!(tier_name(OasisTrail), content="Oasis Trail")
  inspect!(tier_name(DuneSea), content="Dune Sea")
  inspect!(tier_name(LostCity), content="Lost City")
}

///|
test "tier_level_range OasisTrail" {
  inspect!(tier_level_range(OasisTrail), content="(0, 7)")
}

///|
test "tier_level_range DuneSea" {
  inspect!(tier_level_range(DuneSea), content="(8, 16)")
}

///|
test "tier_level_range LostCity" {
  inspect!(tier_level_range(LostCity), content="(17, 24)")
}

///|
test "level_tier boundaries" {
  inspect!(level_tier(0), content="OasisTrail")
  inspect!(level_tier(7), content="OasisTrail")
  inspect!(level_tier(8), content="DuneSea")
  inspect!(level_tier(16), content="DuneSea")
  inspect!(level_tier(17), content="LostCity")
  inspect!(level_tier(24), content="LostCity")
}

// --- Constructors ---

///|
test "new_hex_tile creates tile with given kind" {
  let tile = new_hex_tile(Oasis)
  inspect!(tile.kind, content="Oasis")
}

///|
test "new_hex_map dimensions and default tiles" {
  let m = new_hex_map(4, 3)
  inspect!(m.width, content="4")
  inspect!(m.height, content="3")
  inspect!(m.tiles.length(), content="3")
  inspect!(m.tiles[0].length(), content="4")
  // All tiles default to Sand
  inspect!(m.tiles[0][0].kind, content="Sand")
  inspect!(m.tiles[2][3].kind, content="Sand")
}

///|
test "new_hex_map zero size" {
  let m = new_hex_map(0, 0)
  inspect!(m.width, content="0")
  inspect!(m.height, content="0")
  inspect!(m.tiles.length(), content="0")
}

///|
test "new_caravan initial state" {
  let c = new_caravan({ col: 2, row: 3 }, 15)
  inspect!(c.pos, content="{col: 2, row: 3}")
  inspect!(c.water, content="15")
  inspect!(c.max_water, content="15")
  inspect!(c.gold, content="0")
  inspect!(c.artifacts, content="0")
  inspect!(c.route.length(), content="0")
  inspect!(c.route_index, content="0")
}

///|
test "new_level_score defaults" {
  let s = new_level_score()
  inspect!(s.stars, content="0")
  inspect!(s.best_gold, content="0")
  inspect!(s.best_artifacts, content="0")
  inspect!(s.completed, content="false")
}

///|
test "new_game initial state" {
  let g = new_game()
  inspect!(g.screen, content="Title")
  inspect!(g.play_state, content="Planning")
  inspect!(g.current_tier, content="OasisTrail")
  inspect!(g.current_level, content="0")
  inspect!(g.scores.length(), content="25")
  inspect!(g.route.length(), content="0")
  inspect!(g.message, content="")
}

///|
test "set_message updates game" {
  let g = new_game()
  set_message(g, "Water low!", 2.5)
  inspect!(g.message, content="Water low!")
  inspect!(g.message_timer, content="2.5")
}

// --- hex_to_pixel basic consistency ---

///|
test "hex_to_pixel returns tuple" {
  let (x, y) = hex_to_pixel({ col: 0, row: 0 }, 38.0)
  // Just check the values are finite positive numbers near expected offsets
  inspect!(x > 0.0, content="true")
  inspect!(y > 0.0, content="true")
}

///|
test "hex_to_pixel odd row shifts y" {
  let (_, y0) = hex_to_pixel({ col: 0, row: 0 }, 38.0)
  let (_, y1) = hex_to_pixel({ col: 0, row: 1 }, 38.0)
  // Odd row should have a larger y due to row offset + half-height shift
  inspect!(y1 > y0, content="true")
}
