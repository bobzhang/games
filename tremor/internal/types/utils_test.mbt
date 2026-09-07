///|
test "sqrtf" {
  inspect(sqrtf(4.0), content="2")
  inspect(sqrtf(0.0), content="0")
  inspect(sqrtf(1.0), content="1")
}

///|
test "absf" {
  inspect(absf(-3.0), content="3")
  inspect(absf(5.0), content="5")
  inspect(absf(0.0), content="0")
}

///|
test "maxf and minf" {
  inspect(maxf(3.0, 7.0), content="7")
  inspect(maxf(10.0, 2.0), content="10")
  inspect(minf(3.0, 7.0), content="3")
  inspect(minf(10.0, 2.0), content="2")
}

///|
test "clampf" {
  inspect(clampf(5.0, 0.0, 10.0), content="5")
  inspect(clampf(-2.0, 0.0, 10.0), content="0")
  inspect(clampf(15.0, 0.0, 10.0), content="10")
  inspect(clampf(0.0, 0.0, 10.0), content="0")
  inspect(clampf(10.0, 0.0, 10.0), content="10")
}

///|
test "clampi" {
  inspect(clampi(5, 0, 10), content="5")
  inspect(clampi(-2, 0, 10), content="0")
  inspect(clampi(15, 0, 10), content="10")
}

///|
test "maxi and mini" {
  inspect(maxi(3, 7), content="7")
  inspect(maxi(10, 2), content="10")
  inspect(mini(3, 7), content="3")
  inspect(mini(10, 2), content="2")
}

///|
test "vec2i constructor" {
  let v = vec2i(4, 9)
  inspect(v.x, content="4")
  inspect(v.y, content="9")
}

///|
test "dist_i" {
  // Distance between (0,0) and (3,4) = 5.0
  let d = dist_i(vec2i(0, 0), vec2i(3, 4))
  inspect(d, content="5")
  // Distance between same point = 0
  inspect(dist_i(vec2i(2, 2), vec2i(2, 2)), content="0")
}

///|
test "tile_center_x and tile_center_y" {
  let cx = tile_center_x(0)
  let cy = tile_center_y(0)
  // offset + 0 * cell_size + cell_size / 2
  inspect(cx, content="66")
  inspect(cy, content="106")
}

///|
test "pixel_to_tile in bounds" {
  // Pixel at offset + cell_size/2 should be tile (0,0)
  let result = pixel_to_tile(grid_offset_x + 10, grid_offset_y + 10)
  debug_inspect(
    result,
    content=(
      #|Some({ x: 0, y: 0 })
    ),
  )
}

///|
test "pixel_to_tile out of bounds" {
  debug_inspect(pixel_to_tile(0, 0), content="None")
  debug_inspect(pixel_to_tile(-10, -10), content="None")
}

///|
test "sensor_cost" {
  inspect(sensor_cost(Broad), content="1")
  inspect(sensor_cost(Precise), content="2")
  inspect(sensor_cost(Directional), content="3")
}

///|
test "sensor_range" {
  inspect(sensor_range(Broad), content="8")
  inspect(sensor_range(Precise), content="5")
  inspect(sensor_range(Directional), content="6")
}

///|
test "sensor_uncertainty" {
  inspect(sensor_uncertainty(Broad), content="2")
  inspect(sensor_uncertainty(Precise), content="1")
  inspect(sensor_uncertainty(Directional), content="1")
}

///|
test "new_tile" {
  let t = new_tile(Empty)
  inspect(t.kind, content="Empty")
  let t2 = new_tile(Blocked)
  inspect(t2.kind, content="Blocked")
}

///|
test "new_epicenter" {
  let e = new_epicenter(5, 3)
  inspect(e.pos.x, content="5")
  inspect(e.pos.y, content="3")
  inspect(e.found, content="false")
}

///|
test "new_level_score" {
  let s = new_level_score()
  inspect(s.stars, content="0")
  inspect(s.completed, content="false")
  inspect(s.best_budget_used, content="99")
  inspect(s.best_guesses, content="99")
}

///|
test "make_grid" {
  let g = make_grid(3, 4)
  inspect(g.length(), content="3")
  inspect(g[0].length(), content="4")
  inspect(g[0][0].kind, content="Empty")
}

///|
test "compass_angle" {
  inspect(compass_angle(East), content="0")
  // North = -pi/2 ~ -1.5708
  let n = compass_angle(North)
  inspect(n < -1.57 && n > -1.58, content="true")
}

///|
test "next_compass cycles clockwise" {
  inspect(next_compass(North), content="East")
  inspect(next_compass(East), content="South")
  inspect(next_compass(South), content="West")
  inspect(next_compass(West), content="North")
}

///|
test "rng_int range" {
  seed_rng(123)
  let v = rng_int(10)
  inspect(v >= 0 && v < 10, content="true")
}

///|
test "rng_float range" {
  seed_rng(456)
  let v = rng_float()
  inspect(v >= 0.0 && v < 1.0, content="true")
}

///|
test "seed_rng deterministic" {
  seed_rng(999)
  let a = rng_next()
  seed_rng(999)
  let b = rng_next()
  inspect(a == b, content="true")
}

///|
test "tier_start_index" {
  inspect(tier_start_index(Detection), content="0")
  inspect(tier_start_index(Precision), content="8")
  inspect(tier_start_index(Crisis), content="17")
}

///|
test "tier_level_count" {
  inspect(tier_level_count(Detection), content="8")
  inspect(tier_level_count(Precision), content="9")
  inspect(tier_level_count(Crisis), content="8")
}

///|
test "tier_name" {
  inspect(tier_name(Detection), content="Detection")
  inspect(tier_name(Precision), content="Precision")
  inspect(tier_name(Crisis), content="Crisis")
}

///|
test "tier_unlocked" {
  let game = new_game()
  inspect(tier_unlocked(game, Detection), content="true")
  inspect(tier_unlocked(game, Precision), content="false")
  // Complete 4 levels in tier 1
  for i in 0..<4 {
    game.level_scores[i].completed = true
  }
  inspect(tier_unlocked(game, Precision), content="true")
}

///|
test "level_unlocked" {
  let game = new_game()
  inspect(level_unlocked(game, 0), content="true")
  inspect(level_unlocked(game, 1), content="false")
  game.level_scores[0].completed = true
  inspect(level_unlocked(game, 1), content="true")
}

///|
test "sinf and cosf basic values" {
  inspect(sinf(0.0), content="0")
  inspect(cosf(0.0), content="1")
}

///|
test "rng_int with zero max" {
  seed_rng(42)
  inspect(rng_int(0), content="0")
  inspect(rng_int(-5), content="0")
}
