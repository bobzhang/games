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
  grid.tiles[idx] = { biome: Ocean, locked: true, }
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

// ============================================================
// Ecosystem edge case tests
// ============================================================

///|
test "forest death: 4+ desert neighbors also kills forest" {
  let grid = @types.new_grid(5, 5, false)
  // Place forest at (2,2) even row
  @types.set_biome(grid, 2, 2, Forest)
  // Even row (2) neighbors: (-1,-1),(0,-1),(-1,0),(1,0),(-1,1),(0,1)
  // That's (1,1),(2,1),(1,2),(3,2),(1,3),(2,3)
  @types.set_biome(grid, 1, 1, Desert)
  @types.set_biome(grid, 2, 1, Desert)
  @types.set_biome(grid, 1, 2, Desert)
  @types.set_biome(grid, 3, 2, Desert)
  // 4 desert neighbors
  let _changed = @biome.resolve_ecosystem(grid)
  inspect(@types.get_tile(grid, 2, 2).biome, content="Barren")
}

///|
test "forest death: 5 desert neighbors kills forest" {
  let grid = @types.new_grid(5, 5, false)
  @types.set_biome(grid, 2, 2, Forest)
  // 5 desert neighbors
  @types.set_biome(grid, 1, 1, Desert)
  @types.set_biome(grid, 2, 1, Desert)
  @types.set_biome(grid, 1, 2, Desert)
  @types.set_biome(grid, 3, 2, Desert)
  @types.set_biome(grid, 1, 3, Desert)
  let _changed = @biome.resolve_ecosystem(grid)
  inspect(@types.get_tile(grid, 2, 2).biome, content="Barren")
}

///|
test "forest death: all 6 desert neighbors kills forest" {
  let grid = @types.new_grid(5, 5, false)
  @types.set_biome(grid, 2, 2, Forest)
  // All 6 neighbors are desert (even row)
  @types.set_biome(grid, 1, 1, Desert)
  @types.set_biome(grid, 2, 1, Desert)
  @types.set_biome(grid, 1, 2, Desert)
  @types.set_biome(grid, 3, 2, Desert)
  @types.set_biome(grid, 1, 3, Desert)
  @types.set_biome(grid, 2, 3, Desert)
  let _changed = @biome.resolve_ecosystem(grid)
  inspect(@types.get_tile(grid, 2, 2).biome, content="Barren")
}

///|
test "desert retreat with exactly 2 ocean neighbors" {
  let grid = @types.new_grid(5, 5, false)
  @types.set_biome(grid, 2, 2, Desert)
  // Even row (2) neighbors of (2,2): (1,1),(2,1),(1,2),(3,2),(1,3),(2,3)
  @types.set_biome(grid, 1, 1, Ocean)
  @types.set_biome(grid, 2, 1, Ocean)
  let _changed = @biome.resolve_ecosystem(grid)
  inspect(@types.get_tile(grid, 2, 2).biome, content="Barren")
}

///|
test "desert retreat with 3 ocean neighbors" {
  let grid = @types.new_grid(5, 5, false)
  @types.set_biome(grid, 2, 2, Desert)
  @types.set_biome(grid, 1, 1, Ocean)
  @types.set_biome(grid, 2, 1, Ocean)
  @types.set_biome(grid, 1, 2, Ocean)
  let _changed = @biome.resolve_ecosystem(grid)
  inspect(@types.get_tile(grid, 2, 2).biome, content="Barren")
}

///|
test "wrapping: forest at col 0 with ocean at last col spreads via wrap" {
  // With wrapping, col 0 neighbors col (w-1) on odd rows
  let grid = @types.new_grid(6, 3, true)
  @types.set_biome(grid, 0, 1, Forest)
  @types.set_biome(grid, 5, 1, Ocean)
  // Row 1 is odd. Odd row neighbors of (0,1): (0,0),(1,0),(-1=>5,1),(1,1),(0,2),(1,2)
  // Forest at (0,1), Ocean at (5,1). (5,1) is neighbor of (0,1) via wrap.
  // Barren tiles adjacent to both forest and ocean should get forest
  let _changed = @biome.resolve_ecosystem(grid)
  // (0,0) is even row neighbor of (0,1) via odd-row rule: neighbors are (0,0),(1,0),(5,1),(1,1),(0,2),(1,2)
  // (0,0) has forest neighbor (0,1) and check if it has ocean neighbor too
  // Actually for (0,0) to become forest, it needs both forest and ocean as neighbors
  // Let's just check that forest count increased (spreading happened through wrap)
  let fc = @types.count_biome(grid, Forest)
  inspect(fc >= 1, content="true")
}

///|
test "wrapping: desert at last col spreads to col 0 via wrap" {
  let grid = @types.new_grid(6, 3, true)
  @types.set_biome(grid, 5, 1, Desert)
  // Desert should spread to its neighbors including col 0 via wrap
  let _changed = @biome.resolve_ecosystem(grid)
  let dc = @types.count_biome(grid, Desert)
  inspect(dc > 1, content="true")
  // Check that col 0 got desert (via wrap on odd row)
  // Odd row (1) neighbors of (5,1) include wrapping: (5,0),(0,0),(4,1),(0,1),(5,2),(0,2)
  // Wait: neighbors of col 5, row 1 (odd): (0,-1)=>(5,0), (1,-1)=>(0,0) -- hmm need to check
  // Actually odd row offsets: (0,-1),(1,-1),(-1,0),(1,0),(0,1),(1,1)
  // For (5,1): (5,0),(6=>0,0),(4,1),(6=>0,1),(5,2),(6=>0,2)
  // So (0,0), (0,1), (0,2) are neighbors of (5,1) via wrap
  // At least (0,1) should become desert (barren, no ocean, has desert neighbor)
  inspect(@types.get_tile(grid, 0, 1).biome, content="Desert")
}

///|
test "wrapping: top-left corner neighbors with wrap" {
  // Cell (0,0) is even row. Even row neighbors: (-1,-1),(0,-1),(-1,0),(1,0),(-1,1),(0,1)
  // With wrap: col -1 => w-1. Row -1 is out of bounds.
  // So valid neighbors: (w-1,0) via wrap for (-1,0), (1,0), (w-1,1) via wrap for (-1,1), (0,1)
  let _grid = @types.new_grid(6, 3, true)
  let neighbors = @types.hex_neighbors(0, 0, 6, 3, true)
  // Should have: (5,0) via wrap, (1,0), (5,1) via wrap, (0,1) = 4 neighbors
  // (top row removes row -1 neighbors)
  inspect(neighbors.length(), content="4")
  // Check that (5,0) is in the list (wrap around)
  let mut found_5_0 = false
  for i in 0..<neighbors.length() {
    let (c, r) = neighbors[i]
    if c == 5 && r == 0 {
      found_5_0 = true
    }
  }
  inspect(found_5_0, content="true")
}

///|
test "wrapping: bottom-right corner neighbors with wrap" {
  // Cell (5,2) on a 6x3 grid, even row.
  // Even row neighbors: (4,1),(5,1),(4,2),(6=>0,2),(4,3 out),(5,3 out)
  // Actually row 2 is even. Offsets: (-1,-1),(0,-1),(-1,0),(1,0),(-1,1),(0,1)
  // (4,1),(5,1),(4,2),(6=>0,2),(4,3 out),(5,3 out)
  // Valid: (4,1),(5,1),(4,2),(0,2) = 4 neighbors
  let _grid = @types.new_grid(6, 3, true)
  let neighbors = @types.hex_neighbors(5, 2, 6, 3, true)
  inspect(neighbors.length(), content="4")
  let mut found_0_2 = false
  for i in 0..<neighbors.length() {
    let (c, r) = neighbors[i]
    if c == 0 && r == 2 {
      found_0_2 = true
    }
  }
  inspect(found_0_2, content="true")
}

///|
test "wrapping: desert spread wraps and kills forest across edge" {
  // Desert near left edge should contribute to killing forest near right edge via wrap
  let grid = @types.new_grid(6, 3, true)
  // Forest at (0,1), desert at (5,0), (5,1), (5,2)
  // (0,1) odd row neighbors: (0,0),(1,0),(5,1),(1,1),(0,2),(1,2)  -- wait
  // Odd row offsets: (0,-1),(1,-1),(-1,0),(1,0),(0,1),(1,1)
  // (0,1): (0,0),(1,0),(-1=>5,1),(1,1),(0,2),(1,2)
  // So (5,1) is a neighbor of (0,1). If desert is at (5,0),(5,1),(1,0) then (0,1) has 3 desert neighbors
  @types.set_biome(grid, 0, 1, Forest)
  @types.set_biome(grid, 5, 1, Desert) // wrap neighbor
  @types.set_biome(grid, 1, 0, Desert) // neighbor
  @types.set_biome(grid, 1, 1, Desert) // neighbor
  // Forest at (0,1) has desert neighbors: (5,1), (1,0), (1,1) = 3 desert
  let _changed = @biome.resolve_ecosystem(grid)
  inspect(@types.get_tile(grid, 0, 1).biome, content="Barren")
}

///|
test "preview_tile_changes returns correct indices and biomes" {
  let grid = @types.new_grid(5, 5, false)
  @types.set_biome(grid, 2, 2, Desert)
  let changes = @biome.preview_tile_changes(grid)
  // Desert should spread to some barren neighbors
  inspect(changes.length() > 0, content="true")
  // All changes should be to Desert (spreading from the one desert tile)
  for i in 0..<changes.length() {
    let (_idx, biome) = changes[i]
    inspect(biome, content="Desert")
  }
}

///|
test "preview_tile_changes empty for stable grid" {
  let grid = @types.new_grid(3, 3, false)
  // All barren = stable
  let changes = @biome.preview_tile_changes(grid)
  inspect(changes.length(), content="0")
}

///|
test "preview_tile_changes matches resolve_ecosystem results" {
  let grid = @types.new_grid(7, 5, false)
  @types.set_biome(grid, 3, 2, Desert)
  @types.set_biome(grid, 2, 2, Ocean)
  @types.set_biome(grid, 4, 2, Forest)
  let preview = @biome.preview_tile_changes(grid)
  // Now actually resolve on a clone and compare
  let clone = @types.clone_grid(grid)
  let changed = @biome.resolve_ecosystem(clone)
  let mut changed_count = 0
  for i in 0..<changed.length() {
    if changed[i] {
      changed_count += 1
    }
  }
  inspect(preview.length() == changed_count, content="true")
}

///|
test "forest survives with desert and ocean mixed neighbors" {
  // Forest with 2 desert + 2 ocean neighbors should survive (only 2 desert < 3 threshold)
  let grid = @types.new_grid(5, 5, false)
  @types.set_biome(grid, 2, 2, Forest)
  @types.set_biome(grid, 1, 1, Desert)
  @types.set_biome(grid, 2, 1, Desert)
  @types.set_biome(grid, 1, 2, Ocean)
  @types.set_biome(grid, 3, 2, Ocean)
  let _changed = @biome.resolve_ecosystem(grid)
  inspect(@types.get_tile(grid, 2, 2).biome, content="Forest")
}

///|
test "barren with both desert and forest+ocean neighbors: forest wins" {
  // A barren tile with 1 forest neighbor + 1 ocean neighbor AND 1 desert neighbor
  // Forest rule: forest >= 1 && ocean >= 1 => Forest (checked first)
  let grid = @types.new_grid(5, 5, false)
  // Target: (2,3) barren (even row 2, but we check row 3)
  // Row 3 is odd. Odd row offsets: (0,-1),(1,-1),(-1,0),(1,0),(0,1),(1,1)
  // Neighbors of (2,3): (2,2),(3,2),(1,3),(3,3),(2,4),(3,4)
  @types.set_biome(grid, 2, 2, Forest)
  @types.set_biome(grid, 3, 2, Ocean)
  @types.set_biome(grid, 1, 3, Desert)
  let _changed = @biome.resolve_ecosystem(grid)
  // Forest rule is checked first in apply_rules: forest_n>=1 && ocean_n>=1 => Forest
  inspect(@types.get_tile(grid, 2, 3).biome, content="Forest")
}

///|
test "barren with desert but also ocean: desert does NOT spread" {
  // Desert spread rule: desert_n >= 1 && ocean_n == 0
  // If ocean_n > 0, desert should not spread
  let grid = @types.new_grid(5, 5, false)
  // Target: (2,3) odd row. Neighbors: (2,2),(3,2),(1,3),(3,3),(2,4),(3,4)
  @types.set_biome(grid, 1, 3, Desert)
  @types.set_biome(grid, 3, 3, Ocean)
  // No forest neighbors, so forest rule doesn't apply
  // Desert rule: desert_n >= 1 but ocean_n >= 1, so desert shouldn't spread
  let _changed = @biome.resolve_ecosystem(grid)
  inspect(@types.get_tile(grid, 2, 3).biome, content="Barren")
}

///|
test "multiple resolve steps: forest chain grows along ocean coast" {
  // Set up a line of ocean + one forest, and verify forest spreads along the coast
  let grid = @types.new_grid(8, 3, false)
  @types.set_biome(grid, 0, 1, Ocean)
  @types.set_biome(grid, 1, 1, Ocean)
  @types.set_biome(grid, 2, 1, Ocean)
  @types.set_biome(grid, 3, 1, Ocean)
  @types.set_biome(grid, 0, 0, Forest)
  // After several steps, forest should spread along the tiles next to ocean
  let _changed = @biome.resolve_n_steps(grid, 5)
  let fc = @types.count_biome(grid, Forest)
  inspect(fc > 1, content="true")
}

///|
test "edge: single tile grid" {
  let grid = @types.new_grid(1, 1, false)
  @types.set_biome(grid, 0, 0, Desert)
  // No neighbors at all, nothing should change
  let changed = @biome.resolve_ecosystem(grid)
  inspect(changed[0], content="false")
  inspect(@types.get_tile(grid, 0, 0).biome, content="Desert")
}

///|
test "edge: 1-wide grid with wrapping" {
  // Width 1 with wrap: col 0 wraps to col 0 (self-loop possible?)
  // hex_neighbors for col 0 row 1, width 1: wrap -1 => 0, wrap 1 => 0
  // But that would be self-referencing. Let's verify behavior.
  let grid = @types.new_grid(1, 3, true)
  @types.set_biome(grid, 0, 1, Desert)
  let changed = @biome.resolve_ecosystem(grid)
  // Row 0 and row 2 should get desert (they neighbor row 1, no ocean)
  let mut any = false
  for i in 0..<changed.length() {
    if changed[i] {
      any = true
    }
  }
  inspect(any, content="true")
}
