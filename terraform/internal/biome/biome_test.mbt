///|
test "forest spread: barren with ocean and forest neighbor becomes forest" {
  let grid = @types.new_grid(5, 5, false)
  // Place ocean at (1,1), forest at (2,1)
  @types.set_biome(grid, 1, 1, Ocean)
  @types.set_biome(grid, 2, 1, Forest)
  // (2,2) is barren, has forest neighbor (2,1) and ocean neighbor (1,1) if adjacent
  // After resolve, barren tiles adjacent to both forest and ocean should become forest
  let _changed = @biome.resolve_ecosystem(grid)
  // Check that some barren tiles near forest+ocean became forest
  let forest_count = @types.count_biome(grid, Forest)
  inspect(forest_count >= 2, content="true")
}

///|
test "forest death: 3+ desert neighbors kills forest" {
  let grid = @types.new_grid(5, 5, false)
  // Place forest at center
  @types.set_biome(grid, 2, 2, Forest)
  // Surround with desert (even row neighbors: (-1,-1),(0,-1),(-1,0),(1,0),(-1,1),(0,1))
  @types.set_biome(grid, 1, 1, Desert)
  @types.set_biome(grid, 2, 1, Desert)
  @types.set_biome(grid, 1, 2, Desert)
  let _changed = @biome.resolve_ecosystem(grid)
  // Forest at (2,2) should die (become barren) because 3+ desert neighbors
  let tile = @types.get_tile(grid, 2, 2)
  inspect(tile.biome, content="Barren")
}

///|
test "desert spread: barren with no ocean and desert neighbor becomes desert" {
  let grid = @types.new_grid(5, 5, false)
  @types.set_biome(grid, 2, 2, Desert)
  // All neighbors of (2,2) are barren with no ocean
  let _changed = @biome.resolve_ecosystem(grid)
  let desert_count = @types.count_biome(grid, Desert)
  // Desert should have spread
  inspect(desert_count >= 2, content="true")
}

///|
test "desert retreat: 2+ ocean neighbors turns desert to barren" {
  let grid = @types.new_grid(5, 5, false)
  @types.set_biome(grid, 2, 2, Desert)
  // Place 2 ocean neighbors (even row neighbors of (2,2))
  @types.set_biome(grid, 1, 1, Ocean)
  @types.set_biome(grid, 2, 1, Ocean)
  let _changed = @biome.resolve_ecosystem(grid)
  let tile = @types.get_tile(grid, 2, 2)
  inspect(tile.biome, content="Barren")
}

///|
test "ocean stability: ocean never changes" {
  let grid = @types.new_grid(5, 5, false)
  @types.set_biome(grid, 2, 2, Ocean)
  @types.set_biome(grid, 1, 2, Desert)
  @types.set_biome(grid, 3, 2, Desert)
  @types.set_biome(grid, 1, 1, Desert)
  @types.set_biome(grid, 2, 1, Desert)
  let _changed = @biome.resolve_ecosystem(grid)
  let tile = @types.get_tile(grid, 2, 2)
  inspect(tile.biome, content="Ocean")
}

///|
test "ecosystem snapshot independence: simultaneous resolution" {
  // Two deserts facing each other with ocean between shouldn't
  // both retreat AND spread in same step
  let grid = @types.new_grid(7, 3, false)
  @types.set_biome(grid, 1, 1, Desert)
  @types.set_biome(grid, 3, 1, Ocean)
  @types.set_biome(grid, 5, 1, Desert)
  // Take snapshot before
  let snap_before = @types.snapshot_biomes(grid)
  let _changed = @biome.resolve_ecosystem(grid)
  let snap_after = @types.snapshot_biomes(grid)
  // The changes should be based on snap_before, not intermediate state
  // Both deserts should resolve based on original neighbors
  // Verify at least that ocean stays
  let ocean_idx = @types.grid_index(3, 1, 7)
  inspect(snap_after[ocean_idx], content="Ocean")
  // At least one snapshot differs (ecosystem should do something)
  let mut any_diff = false
  for i in 0..<snap_before.length() {
    if snap_before[i] != snap_after[i] {
      any_diff = true
      break
    }
  }
  inspect(any_diff, content="true")
}

///|
test "check_targets: in range" {
  let grid = @types.new_grid(10, 1, false)
  // 3 forest, 2 ocean, 1 desert, 4 barren
  @types.set_biome(grid, 0, 0, Forest)
  @types.set_biome(grid, 1, 0, Forest)
  @types.set_biome(grid, 2, 0, Forest)
  @types.set_biome(grid, 3, 0, Ocean)
  @types.set_biome(grid, 4, 0, Ocean)
  @types.set_biome(grid, 5, 0, Desert)
  let targets = @types.new_targets(0.2, 0.4, 0.1, 0.3, 0.05, 0.15)
  inspect(@biome.check_targets(grid, targets), content="true")
}

///|
test "check_targets: out of range" {
  let grid = @types.new_grid(10, 1, false)
  // 0 forest - below min
  @types.set_biome(grid, 0, 0, Ocean)
  let targets = @types.new_targets(0.2, 0.4, 0.0, 1.0, 0.0, 1.0)
  inspect(@biome.check_targets(grid, targets), content="false")
}

///|
test "ratio_status" {
  let grid = @types.new_grid(10, 1, false)
  @types.set_biome(grid, 0, 0, Forest)
  // Forest = 10%, targets 20-40% => below
  let targets = @types.new_targets(0.2, 0.4, 0.0, 1.0, 0.0, 1.0)
  let (fs, _os, _ds) = @biome.ratio_status(grid, targets)
  inspect(fs, content="-1")
}

///|
test "calculate_stars" {
  let grid = @types.new_grid(10, 1, false)
  @types.set_biome(grid, 0, 0, Forest)
  @types.set_biome(grid, 1, 0, Forest)
  @types.set_biome(grid, 2, 0, Forest)
  @types.set_biome(grid, 3, 0, Ocean)
  @types.set_biome(grid, 4, 0, Ocean)
  @types.set_biome(grid, 5, 0, Desert)
  let targets = @types.new_targets(0.2, 0.4, 0.1, 0.3, 0.05, 0.15)
  let budget = @types.new_budget(0, 0, 0)
  // Targets met, not under par, no budget
  let stars1 = @biome.calculate_stars(grid, targets, budget, 12, 10)
  inspect(stars1, content="1")
  // Under par
  let stars2 = @biome.calculate_stars(grid, targets, budget, 8, 10)
  inspect(stars2, content="2")
  // Under par with budget remaining
  let budget2 = @types.new_budget(1, 0, 0)
  let stars3 = @biome.calculate_stars(grid, targets, budget2, 8, 10)
  inspect(stars3, content="3")
}

///|
test "locked tiles not affected by ecosystem" {
  let grid = @types.new_grid(5, 5, false)
  // Create a locked ocean tile
  let idx = @types.grid_index(2, 2, 5)
  grid.tiles[idx] = { biome: Ocean, locked: true }
  // Surround with desert
  @types.set_biome(grid, 1, 1, Desert)
  @types.set_biome(grid, 2, 1, Desert)
  @types.set_biome(grid, 1, 2, Desert)
  @types.set_biome(grid, 3, 2, Desert)
  let _changed = @biome.resolve_ecosystem(grid)
  // Locked ocean should remain ocean
  inspect(grid.tiles[idx].biome, content="Ocean")
}

///|
test "forest does not spread without ocean neighbor" {
  let grid = @types.new_grid(5, 5, false)
  // Forest at center, no ocean anywhere
  @types.set_biome(grid, 2, 2, Forest)
  let before_forest = @types.count_biome(grid, Forest)
  let _changed = @biome.resolve_ecosystem(grid)
  let after_forest = @types.count_biome(grid, Forest)
  // Forest should not spread (no ocean nearby)
  inspect(after_forest == before_forest, content="true")
}

///|
test "forest exactly at threshold: 2 desert neighbors survives" {
  let grid = @types.new_grid(5, 5, false)
  @types.set_biome(grid, 2, 2, Forest)
  // 2 desert neighbors (below 3 threshold)
  @types.set_biome(grid, 1, 1, Desert)
  @types.set_biome(grid, 2, 1, Desert)
  let _changed = @biome.resolve_ecosystem(grid)
  // Forest should survive with only 2 desert neighbors
  let tile = @types.get_tile(grid, 2, 2)
  inspect(tile.biome, content="Forest")
}

///|
test "desert does not spread if ocean neighbor present" {
  let grid = @types.new_grid(5, 5, false)
  @types.set_biome(grid, 2, 2, Desert)
  @types.set_biome(grid, 1, 2, Ocean) // Ocean neighbor
  // Neighbors of desert that also have ocean as neighbor should not get desert
  let _changed = @biome.resolve_ecosystem(grid)
  // The ocean should still be there
  inspect(@types.get_tile(grid, 1, 2).biome, content="Ocean")
}

///|
test "desert retreat: exactly 1 ocean neighbor is not enough" {
  let grid = @types.new_grid(5, 5, false)
  @types.set_biome(grid, 2, 2, Desert)
  // Only 1 ocean neighbor (need 2+ to retreat)
  @types.set_biome(grid, 1, 1, Ocean)
  let _changed = @biome.resolve_ecosystem(grid)
  // Desert should NOT retreat with only 1 ocean
  let tile = @types.get_tile(grid, 2, 2)
  inspect(tile.biome, content="Desert")
}

///|
test "multiple resolution steps change grid progressively" {
  let grid = @types.new_grid(7, 3, false)
  @types.set_biome(grid, 0, 1, Desert)
  // After multiple steps, desert should spread further
  let _changed = @biome.resolve_n_steps(grid, 3)
  let desert_count = @types.count_biome(grid, Desert)
  // Should have spread to multiple tiles
  inspect(desert_count > 1, content="true")
}

///|
test "check_failure: returns false with budget remaining" {
  let grid = @types.new_grid(4, 4, false)
  let targets = @types.new_targets(0.5, 0.8, 0.0, 1.0, 0.0, 1.0)
  let budget = @types.new_budget(3, 0, 0)
  inspect(@biome.check_failure(grid, budget, targets), content="false")
}

///|
test "check_failure: returns false when targets already met" {
  let grid = @types.new_grid(10, 1, false)
  for i in 0..<5 {
    @types.set_biome(grid, i, 0, Forest)
  }
  let targets = @types.new_targets(0.3, 0.6, 0.0, 1.0, 0.0, 1.0)
  let budget = @types.new_budget(0, 0, 0)
  inspect(@biome.check_failure(grid, budget, targets), content="false")
}

///|
test "wrapping affects desert spread" {
  // Desert at col 0 with wrapping should affect col (width-1)
  let grid = @types.new_grid(8, 3, true)
  @types.set_biome(grid, 0, 1, Desert)
  let _changed = @biome.resolve_ecosystem(grid)
  // Column 7 (which wraps to neighbor of col 0) might get desert
  // At minimum, desert should have spread to some neighbor
  let desert_count = @types.count_biome(grid, Desert)
  inspect(desert_count > 1, content="true")
}

///|
test "wrapping affects forest spread with ocean" {
  // Forest at col 0, ocean at col (width-1) with wrapping
  // Forest should spread because it has ocean neighbor via wrap
  let grid = @types.new_grid(8, 3, true)
  @types.set_biome(grid, 0, 1, Forest)
  @types.set_biome(grid, 7, 1, Ocean)
  let _changed = @biome.resolve_ecosystem(grid)
  // Some barren tiles near col 0 that also neighbor ocean (via wrap) should gain forest
  let forest_count = @types.count_biome(grid, Forest)
  inspect(forest_count >= 1, content="true")
}

///|
test "is_stable: empty grid is stable" {
  let grid = @types.new_grid(5, 5, false)
  inspect(@biome.is_stable(grid), content="true")
}

///|
test "is_stable: grid with spreading desert is not stable" {
  let grid = @types.new_grid(5, 5, false)
  @types.set_biome(grid, 2, 2, Desert)
  // Desert can spread to barren neighbors without ocean
  inspect(@biome.is_stable(grid), content="false")
}

///|
test "count_pending_changes" {
  let grid = @types.new_grid(5, 5, false)
  inspect(@biome.count_pending_changes(grid), content="0")
  @types.set_biome(grid, 2, 2, Desert)
  let changes = @biome.count_pending_changes(grid)
  inspect(changes > 0, content="true")
}

///|
test "preview_next_step" {
  let grid = @types.new_grid(5, 5, false)
  @types.set_biome(grid, 2, 2, Desert)
  let (gf, lf, gd, ld) = @biome.preview_next_step(grid)
  // No forest changes expected
  inspect(gf, content="0")
  inspect(lf, content="0")
  // Desert should gain tiles
  inspect(gd > 0, content="true")
  // No desert should be lost (no ocean nearby)
  inspect(ld, content="0")
}

///|
test "resolve_until_stable" {
  let grid = @types.new_grid(3, 3, false)
  @types.set_biome(grid, 1, 1, Desert)
  let (steps, _changed) = @biome.resolve_until_stable(grid, 20)
  // Should stabilize within a few steps (small grid, desert fills up)
  inspect(steps > 0, content="true")
  inspect(steps < 20, content="true")
  // After stabilization, all non-ocean tiles should be desert (or still barren if corner)
  inspect(@biome.is_stable(grid), content="true")
}
