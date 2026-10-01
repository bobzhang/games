///|
test "sqrtf" {
  inspect(@types.sqrtf(4.0), content="2")
  inspect(@types.sqrtf(0.0), content="0")
  inspect(@types.sqrtf(1.0), content="1")
}

///|
test "absf" {
  inspect(@types.absf(-3.0), content="3")
  inspect(@types.absf(5.0), content="5")
  inspect(@types.absf(0.0), content="0")
}

///|
test "maxf and minf" {
  inspect(@types.maxf(3.0, 7.0), content="7")
  inspect(@types.maxf(10.0, 2.0), content="10")
  inspect(@types.minf(3.0, 7.0), content="3")
  inspect(@types.minf(10.0, 2.0), content="2")
}

///|
test "clampf" {
  inspect(@types.clampf(5.0, 0.0, 10.0), content="5")
  inspect(@types.clampf(-2.0, 0.0, 10.0), content="0")
  inspect(@types.clampf(15.0, 0.0, 10.0), content="10")
  inspect(@types.clampf(0.0, 0.0, 10.0), content="0")
  inspect(@types.clampf(10.0, 0.0, 10.0), content="10")
}

///|
test "clampi" {
  inspect(@types.clampi(5, 0, 10), content="5")
  inspect(@types.clampi(-2, 0, 10), content="0")
  inspect(@types.clampi(15, 0, 10), content="10")
}

///|
test "maxi and mini" {
  inspect(@types.maxi(3, 7), content="7")
  inspect(@types.maxi(10, 2), content="10")
  inspect(@types.mini(3, 7), content="3")
  inspect(@types.mini(10, 2), content="2")
}

///|
test "vec2i constructor" {
  let v = @types.vec2i(4, 9)
  inspect(v.x, content="4")
  inspect(v.y, content="9")
}

///|
test "dist_i" {
  // Distance between (0,0) and (3,4) = 5.0
  let d = @types.dist_i(@types.vec2i(0, 0), @types.vec2i(3, 4))
  inspect(d, content="5")
  // Distance between same point = 0
  inspect(@types.dist_i(@types.vec2i(2, 2), @types.vec2i(2, 2)), content="0")
}

///|
test "tile_center_x and tile_center_y" {
  let cx = @types.tile_center_x(0)
  let cy = @types.tile_center_y(0)
  // offset + 0 * cell_size + cell_size / 2
  inspect(cx, content="66")
  inspect(cy, content="106")
}

///|
test "pixel_to_tile in bounds" {
  // Pixel at offset + cell_size/2 should be tile (0,0)
  let result = @types.pixel_to_tile(@types.grid_offset_x + 10, @types.grid_offset_y + 10)
  debug_inspect(
    result,
    content=(
      #|Some({ x: 0, y: 0 })
    ),
  )
}

///|
test "pixel_to_tile out of bounds" {
  debug_inspect(@types.pixel_to_tile(0, 0), content="None")
  debug_inspect(@types.pixel_to_tile(-10, -10), content="None")
}

///|
test "sensor_cost" {
  inspect(@types.sensor_cost(Broad), content="1")
  inspect(@types.sensor_cost(Precise), content="2")
  inspect(@types.sensor_cost(Directional), content="3")
}

///|
test "sensor_range" {
  inspect(@types.sensor_range(Broad), content="8")
  inspect(@types.sensor_range(Precise), content="5")
  inspect(@types.sensor_range(Directional), content="6")
}

///|
test "sensor_uncertainty" {
  inspect(@types.sensor_uncertainty(Broad), content="2")
  inspect(@types.sensor_uncertainty(Precise), content="1")
  inspect(@types.sensor_uncertainty(Directional), content="1")
}

///|
test "new_tile" {
  let t = @types.new_tile(Empty)
  inspect(t.kind, content="Empty")
  let t2 = @types.new_tile(Blocked)
  inspect(t2.kind, content="Blocked")
}

///|
test "new_epicenter" {
  let e = @types.new_epicenter(5, 3)
  inspect(e.pos.x, content="5")
  inspect(e.pos.y, content="3")
  inspect(e.found, content="false")
}

///|
test "new_level_score" {
  let s = @types.new_level_score()
  inspect(s.stars, content="0")
  inspect(s.completed, content="false")
  inspect(s.best_budget_used, content="99")
  inspect(s.best_guesses, content="99")
}

///|
test "make_grid" {
  let g = @types.make_grid(3, 4)
  inspect(g.length(), content="3")
  inspect(g[0].length(), content="4")
  inspect(g[0][0].kind, content="Empty")
}

///|
test "compass_angle" {
  inspect(@types.compass_angle(East), content="0")
  // North = -pi/2 ~ -1.5708
  let n = @types.compass_angle(North)
  inspect(n < -1.57 && n > -1.58, content="true")
}

///|
test "next_compass cycles clockwise" {
  inspect(@types.next_compass(North), content="East")
  inspect(@types.next_compass(East), content="South")
  inspect(@types.next_compass(South), content="West")
  inspect(@types.next_compass(West), content="North")
}

///|
test "rng_int range" {
  @types.seed_rng(123)
  let v = @types.rng_int(10)
  inspect(v >= 0 && v < 10, content="true")
}

///|
test "rng_float range" {
  @types.seed_rng(456)
  let v = @types.rng_float()
  inspect(v >= 0.0 && v < 1.0, content="true")
}

///|
test "seed_rng deterministic" {
  @types.seed_rng(999)
  let a = @types.rng_next()
  @types.seed_rng(999)
  let b = @types.rng_next()
  inspect(a == b, content="true")
}

///|
test "tier_start_index" {
  inspect(@types.tier_start_index(Detection), content="0")
  inspect(@types.tier_start_index(Precision), content="8")
  inspect(@types.tier_start_index(Crisis), content="17")
}

///|
test "tier_level_count" {
  inspect(@types.tier_level_count(Detection), content="8")
  inspect(@types.tier_level_count(Precision), content="9")
  inspect(@types.tier_level_count(Crisis), content="8")
}

///|
test "tier_name" {
  inspect(@types.tier_name(Detection), content="Detection")
  inspect(@types.tier_name(Precision), content="Precision")
  inspect(@types.tier_name(Crisis), content="Crisis")
}

///|
test "tier_unlocked" {
  let game = @types.new_game()
  inspect(@types.tier_unlocked(game, Detection), content="true")
  inspect(@types.tier_unlocked(game, Precision), content="false")
  // Complete 4 levels in tier 1
  for i in 0..<4 {
    game.level_scores[i].completed = true
  }
  inspect(@types.tier_unlocked(game, Precision), content="true")
}

///|
test "level_unlocked" {
  let game = @types.new_game()
  inspect(@types.level_unlocked(game, 0), content="true")
  inspect(@types.level_unlocked(game, 1), content="false")
  game.level_scores[0].completed = true
  inspect(@types.level_unlocked(game, 1), content="true")
}

///|
test "sinf and cosf basic values" {
  inspect(@types.sinf(0.0), content="0")
  inspect(@types.cosf(0.0), content="1")
}

///|
test "rng_int with zero max" {
  @types.seed_rng(42)
  inspect(@types.rng_int(0), content="0")
  inspect(@types.rng_int(-5), content="0")
}
