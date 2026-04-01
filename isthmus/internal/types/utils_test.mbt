///|
test "new_tile creates with correct defaults" {
  let t = @types.new_tile(3, false)
  inspect(t.height, content="3")
  inspect(t.is_settlement, content="false")
  inspect(t.is_sand, content="false")
}

///|
test "new_grid creates correct size" {
  let g = @types.new_grid(12, 10)
  inspect(g.width, content="12")
  inspect(g.height, content="10")
  inspect(g.tiles.length(), content="120")
}

///|
test "grid_index and grid_get" {
  let g = @types.new_grid(4, 3)
  g.tiles[5].height = 7
  // Index 5 = (1, 1) in 4-wide grid
  inspect(@types.grid_index(g, 1, 1), content="5")
  let tile = @types.grid_get(g, 1, 1)
  inspect(tile.height, content="7")
}

///|
test "grid_in_bounds" {
  let g = @types.new_grid(4, 3)
  inspect(@types.grid_in_bounds(g, 0, 0), content="true")
  inspect(@types.grid_in_bounds(g, 3, 2), content="true")
  inspect(@types.grid_in_bounds(g, 4, 0), content="false")
  inspect(@types.grid_in_bounds(g, -1, 0), content="false")
  inspect(@types.grid_in_bounds(g, 0, 3), content="false")
}

///|
test "tile_is_above_water" {
  let t = @types.new_tile(3, false)
  inspect(@types.tile_is_above_water(t, 2), content="true")
  inspect(@types.tile_is_above_water(t, 3), content="false")
  inspect(@types.tile_is_above_water(t, 4), content="false")
}

///|
test "tile_kind" {
  let land = @types.new_tile(3, false)
  inspect(@types.tile_kind(land, 2), content="Land")
  inspect(@types.tile_kind(land, 3), content="Water")
  let settlement = @types.new_tile(5, true)
  inspect(@types.tile_kind(settlement, 2), content="Settlement")
  inspect(@types.tile_kind(settlement, 5), content="Water")
  let sand : @types.Tile = { height: 3, is_settlement: false, is_sand: true }
  inspect(@types.tile_kind(sand, 2), content="Sand")
}

///|
test "copy_grid produces independent copy" {
  let g = @types.new_grid(3, 3)
  g.tiles[0].height = 5
  let g2 = @types.copy_grid(g)
  inspect(g2.tiles[0].height, content="5")
  g2.tiles[0].height = 10
  inspect(g.tiles[0].height, content="5")
}

///|
test "snapshot and restore" {
  let g = @types.new_grid(3, 3)
  g.tiles[0].height = 5
  g.tiles[4].is_settlement = true
  let snap = @types.snapshot_grid(g, 2, 10)
  g.tiles[0].height = 99
  g.tiles[4].is_settlement = false
  @types.restore_snapshot(g, snap)
  inspect(g.tiles[0].height, content="5")
  inspect(g.tiles[4].is_settlement, content="true")
  inspect(snap.sea_level, content="2")
  inspect(snap.sand_remaining, content="10")
}

///|
test "grid_from_level" {
  let level : @types.Level = {
    grid_width: 3,
    grid_height: 2,
    heights: [0, 1, 2, 3, 4, 5],
    settlements: [1, 4],
    max_sea_level: 3,
    sand_budget: 10,
    par_sand: 5,
    name: "Test",
    tier: Shores,
  }
  let g = @types.grid_from_level(level)
  inspect(g.width, content="3")
  inspect(g.height, content="2")
  inspect(g.tiles[0].height, content="0")
  inspect(g.tiles[2].height, content="2")
  inspect(g.tiles[5].height, content="5")
  inspect(g.tiles[1].is_settlement, content="true")
  inspect(g.tiles[4].is_settlement, content="true")
  inspect(g.tiles[0].is_settlement, content="false")
}

///|
test "maxi and mini" {
  inspect(@types.maxi(3, 7), content="7")
  inspect(@types.maxi(7, 3), content="7")
  inspect(@types.mini(3, 7), content="3")
  inspect(@types.mini(7, 3), content="3")
}

///|
test "absi" {
  inspect(@types.absi(5), content="5")
  inspect(@types.absi(-5), content="5")
  inspect(@types.absi(0), content="0")
}

///|
test "clampf" {
  inspect(@types.clampf(0.5, 0.0, 1.0), content="0.5")
  inspect(@types.clampf(-1.0, 0.0, 1.0), content="0")
  inspect(@types.clampf(2.0, 0.0, 1.0), content="1")
}

///|
test "new_level_scores creates correct count" {
  let scores = @types.new_level_scores()
  inspect(scores.length(), content="20")
  inspect(scores[0].completed, content="false")
  inspect(scores[0].stars, content="0")
}

///|
test "new_game defaults" {
  let game = @types.new_game()
  inspect(game.screen, content="Title")
  inspect(game.play_state, content="Placing")
  inspect(game.sea_level, content="0")
  inspect(game.turn, content="0")
  inspect(game.never_disconnected, content="true")
  inspect(game.level_scores.length(), content="20")
}

///|
test "tier helpers" {
  inspect(@types.tier_index(Shores), content="0")
  inspect(@types.tier_index(Straits), content="1")
  inspect(@types.tier_index(Archipelago), content="2")
  inspect(@types.tier_from_index(0), content="Shores")
  inspect(@types.tier_from_index(1), content="Straits")
  inspect(@types.tier_from_index(2), content="Archipelago")
  inspect(@types.tier_start_level(Shores), content="0")
  inspect(@types.tier_start_level(Straits), content="7")
  inspect(@types.tier_start_level(Archipelago), content="14")
  inspect(@types.tier_level_count(Shores), content="7")
  inspect(@types.tier_level_count(Straits), content="7")
  inspect(@types.tier_level_count(Archipelago), content="6")
}

///|
test "settlement_positions" {
  let g = @types.new_grid(3, 3)
  g.tiles[1].is_settlement = true
  g.tiles[5].is_settlement = true
  g.tiles[7].is_settlement = true
  let pos = @types.settlement_positions(g)
  inspect(pos.length(), content="3")
  inspect(pos[0], content="1")
  inspect(pos[1], content="5")
  inspect(pos[2], content="7")
}

///|
test "index_to_xy" {
  let g = @types.new_grid(4, 3)
  let (x0, y0) = @types.index_to_xy(g, 0)
  inspect(x0, content="0")
  inspect(y0, content="0")
  let (x5, y5) = @types.index_to_xy(g, 5)
  inspect(x5, content="1")
  inspect(y5, content="1")
  let (x11, y11) = @types.index_to_xy(g, 11)
  inspect(x11, content="3")
  inspect(y11, content="2")
}
