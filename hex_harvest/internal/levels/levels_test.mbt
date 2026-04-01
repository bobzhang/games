///|
test "all_24_levels_load" {
  // Every level index 0..23 should load successfully with valid data
  for i in 0..<@types.total_levels {
    let level = load_level(i)
    assert_true(level.name != "Empty")
    assert_true(level.turn_budget > 0)
    assert_true(level.target_yield > 0)
    assert_true(level.par_turns > 0)
    assert_true(level.par_turns <= level.turn_budget)
    assert_true(level.water_sources.length() > 0)
  }
}

///|
test "out_of_range_level_returns_empty" {
  let level = load_level(24)
  assert_eq(level.name, "Empty")
  let level2 = load_level(99)
  assert_eq(level2.name, "Empty")
}

///|
test "all_levels_have_valid_grid_dimensions" {
  for i in 0..<@types.total_levels {
    let level = load_level(i)
    assert_eq(level.grid.width, @types.grid_cols)
    assert_eq(level.grid.height, @types.grid_rows)
    assert_eq(level.grid.tiles.length(), @types.grid_rows)
    for r in 0..<@types.grid_rows {
      assert_eq(level.grid.tiles[r].length(), @types.grid_cols)
    }
  }
}

///|
test "water_sources_are_in_bounds_and_marked" {
  for i in 0..<@types.total_levels {
    let level = load_level(i)
    for j in 0..<level.water_sources.length() {
      let ws = level.water_sources[j]
      assert_true(@types.hex_in_bounds(ws.col, ws.row))
      let tile = level.grid.tiles[ws.row][ws.col]
      assert_eq(tile.kind, WaterSource)
      assert_true(tile.watered)
    }
  }
}

///|
test "goal_tiles_are_in_bounds_and_marked" {
  for i in 0..<@types.total_levels {
    let level = load_level(i)
    for j in 0..<level.goals.length() {
      let g = level.goals[j]
      assert_true(@types.hex_in_bounds(g.col, g.row))
      let tile = level.grid.tiles[g.row][g.col]
      assert_eq(tile.kind, Goal)
    }
  }
}

///|
test "valley_levels_are_world_0" {
  for i in 0..<@types.levels_per_world {
    let level = load_level(i)
    assert_eq(level.world, 0)
  }
}

///|
test "hills_levels_are_world_1" {
  for i in 0..<@types.levels_per_world {
    let level = load_level(@types.levels_per_world + i)
    assert_eq(level.world, 1)
  }
}

///|
test "peaks_levels_are_world_2" {
  for i in 0..<@types.levels_per_world {
    let level = load_level(@types.levels_per_world * 2 + i)
    assert_eq(level.world, 2)
  }
}

///|
test "river_tiles_have_channel_and_water" {
  for i in 0..<@types.total_levels {
    let level = load_level(i)
    for r in 0..<@types.grid_rows {
      for c in 0..<@types.grid_cols {
        let tile = level.grid.tiles[r][c]
        if tile.kind == River {
          assert_true(tile.has_channel)
          assert_true(tile.watered)
        }
      }
    }
  }
}

///|
test "level_difficulty_progression_within_worlds" {
  // Within each world, target yield should generally increase
  for w in 0..<@types.total_worlds {
    let first = load_level(w * @types.levels_per_world)
    let last = load_level(w * @types.levels_per_world + @types.levels_per_world - 1)
    assert_true(last.target_yield >= first.target_yield)
  }
}

///|
test "no_level_has_zero_plantable_tiles" {
  for i in 0..<@types.total_levels {
    let level = load_level(i)
    let mut plantable = 0
    for r in 0..<@types.grid_rows {
      for c in 0..<@types.grid_cols {
        if @types.tile_plantable(level.grid.tiles[r][c]) {
          plantable += 1
        }
      }
    }
    assert_true(plantable > 0)
  }
}

///|
test "heights_are_in_valid_range" {
  for i in 0..<@types.total_levels {
    let level = load_level(i)
    for r in 0..<@types.grid_rows {
      for c in 0..<@types.grid_cols {
        let h = level.grid.tiles[r][c].height
        assert_true(h >= 0 && h <= 3)
      }
    }
  }
}
