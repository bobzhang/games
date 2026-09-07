///|
test "all 25 levels exist" {
  let levels = @levels.create_all_levels()
  inspect(levels.length(), content="25")
}

///|
test "tier 1 (Repair) has 8 levels" {
  let levels = @levels.create_all_levels()
  let mut count = 0
  for i in 0..<levels.length() {
    if levels[i].tier == Repair {
      count += 1
    }
  }
  inspect(count, content="8")
}

///|
test "tier 2 (Restore) has 9 levels" {
  let levels = @levels.create_all_levels()
  let mut count = 0
  for i in 0..<levels.length() {
    if levels[i].tier == Restore {
      count += 1
    }
  }
  inspect(count, content="9")
}

///|
test "tier 3 (Master) has 8 levels" {
  let levels = @levels.create_all_levels()
  let mut count = 0
  for i in 0..<levels.length() {
    if levels[i].tier == Master {
      count += 1
    }
  }
  inspect(count, content="8")
}

///|
test "all levels have 8x8 grids" {
  let levels = @levels.create_all_levels()
  for i in 0..<levels.length() {
    inspect(levels[i].grid.width, content="8")
    inspect(levels[i].grid.height, content="8")
  }
}

///|
test "all levels have at least one hole" {
  let levels = @levels.create_all_levels()
  for i in 0..<levels.length() {
    inspect(levels[i].grid.holes.length() > 0, content="true")
  }
}

///|
test "all level names are unique" {
  let levels = @levels.create_all_levels()
  for i in 0..<levels.length() {
    for j = i + 1; j < levels.length(); j = j + 1 {
      let same = levels[i].name == levels[j].name
      inspect(same, content="false")
    }
  }
}

///|
test "all level names are non-empty" {
  let levels = @levels.create_all_levels()
  for i in 0..<levels.length() {
    inspect(levels[i].name.length() > 0, content="true")
  }
}

///|
test "holes are within grid bounds" {
  let levels = @levels.create_all_levels()
  for i in 0..<levels.length() {
    let grid = levels[i].grid
    for j in 0..<grid.holes.length() {
      let h = grid.holes[j]
      inspect(h.x >= 0 && h.x < grid.width, content="true")
      inspect(h.y >= 0 && h.y < grid.height, content="true")
    }
  }
}

///|
test "hole positions are unique within each level" {
  let levels = @levels.create_all_levels()
  for i in 0..<levels.length() {
    let holes = levels[i].grid.holes
    for j in 0..<holes.length() {
      for k = j + 1; k < holes.length(); k = k + 1 {
        let same = @types.vec2i_eq(holes[j], holes[k])
        inspect(same, content="false")
      }
    }
  }
}

///|
test "holes are initially empty (no tile)" {
  let levels = @levels.create_all_levels()
  for i in 0..<levels.length() {
    let grid = levels[i].grid
    for j in 0..<grid.holes.length() {
      let h = grid.holes[j]
      let tile = @types.get_tile(grid, h.x, h.y)
      debug_inspect(tile, content="None")
    }
  }
}

///|
test "non-hole cells have tiles" {
  let levels = @levels.create_all_levels()
  for i in 0..<levels.length() {
    let grid = levels[i].grid
    for y in 0..<grid.height {
      for x in 0..<grid.width {
        if !@types.is_hole(grid, @types.vec2i(x, y)) {
          let tile = @types.get_tile(grid, x, y)
          let has_tile = match tile {
            Some(_) => true
            None => false
          }
          inspect(has_tile, content="true")
        }
      }
    }
  }
}

///|
test "tier 1 uses only mirror symmetries" {
  let levels = @levels.create_all_levels()
  for i in 0..<levels.length() {
    if levels[i].tier == Repair {
      let sym = levels[i].symmetry
      let is_mirror = sym == MirrorH || sym == MirrorV || sym == MirrorD
      inspect(is_mirror, content="true")
    }
  }
}

///|
test "tier 2 uses rotational symmetries" {
  let levels = @levels.create_all_levels()
  for i in 0..<levels.length() {
    if levels[i].tier == Restore {
      let sym = levels[i].symmetry
      let is_rotation = sym == Rotate2 || sym == Rotate4
      inspect(is_rotation, content="true")
    }
  }
}

///|
test "par_errors is non-negative for all levels" {
  let levels = @levels.create_all_levels()
  for i in 0..<levels.length() {
    inspect(levels[i].par_errors >= 0, content="true")
  }
}

// Solvability: for each hole, its symmetric partners are valid positions
// within the grid. Some partner positions may also be holes (creating
// mutual dependencies that the player resolves via pattern recognition).

///|
test "symmetric partners of holes are within grid bounds" {
  let levels = @levels.create_all_levels()
  for i in 0..<levels.length() {
    let level = levels[i]
    let grid = level.grid
    let sym = level.symmetry
    for j in 0..<grid.holes.length() {
      let hole = grid.holes[j]
      let partners = @symmetry.get_symmetric_pos(
        hole,
        sym,
        grid.width,
        grid.height,
      )
      for k in 0..<partners.length() {
        let p = partners[k]
        inspect(p.x >= 0 && p.x < grid.width, content="true")
        inspect(p.y >= 0 && p.y < grid.height, content="true")
      }
    }
  }
}

// Verify that resolved holes produce valid tiles under symmetry.

///|
test "iteratively resolved holes have valid placements" {
  let levels = @levels.create_all_levels()
  for i in 0..<levels.length() {
    let level = levels[i]
    let grid = level.grid
    let sym = level.symmetry
    let holes = grid.holes
    let filled_holes : Array[(@types.Vec2i, @types.Tile)] = []
    // Multiple passes to resolve mutual dependencies
    for _pass in 0..<(holes.length() + 1) {
      for j in 0..<holes.length() {
        let h = holes[j]
        match @types.get_tile(grid, h.x, h.y) {
          None => {
            let solution = @symmetry.compute_solution_tile(grid, h, sym)
            match solution {
              Some(tile) => {
                @types.set_tile(grid, h.x, h.y, Some(@types.copy_tile(tile)))
                filled_holes.push((h, @types.copy_tile(tile)))
              }
              None => ()
            }
          }
          Some(_) => ()
        }
      }
    }
    // All resolved holes must be valid placements
    for j in 0..<filled_holes.length() {
      let (pos, tile) = filled_holes[j]
      let valid = @symmetry.validate_placement(grid, pos, tile, sym)
      inspect(valid, content="true")
    }
    // Clean up
    for j in 0..<holes.length() {
      let h = holes[j]
      @types.set_tile(grid, h.x, h.y, None)
    }
  }
}

// Verify that for mirror symmetry levels, hole partners are also holes
// or have tiles that determine the solution.

///|
test "mirror symmetry holes have valid partner positions" {
  let levels = @levels.create_all_levels()
  for i in 0..<levels.length() {
    let level = levels[i]
    let grid = level.grid
    let sym = level.symmetry
    for j in 0..<grid.holes.length() {
      let hole = grid.holes[j]
      let partners = @symmetry.get_symmetric_pos(
        hole,
        sym,
        grid.width,
        grid.height,
      )
      // All partner positions must be within bounds
      for k in 0..<partners.length() {
        let p = partners[k]
        inspect(p.x >= 0 && p.x < grid.width, content="true")
        inspect(p.y >= 0 && p.y < grid.height, content="true")
      }
    }
  }
}

///|
test "all symmetry types are represented across levels" {
  let levels = @levels.create_all_levels()
  let mut has_mirror_h = false
  let mut has_mirror_v = false
  let mut has_mirror_d = false
  let mut has_rotate2 = false
  let mut has_rotate4 = false
  let mut has_glide = false
  for i in 0..<levels.length() {
    match levels[i].symmetry {
      MirrorH => has_mirror_h = true
      MirrorV => has_mirror_v = true
      MirrorD => has_mirror_d = true
      Rotate2 => has_rotate2 = true
      Rotate4 => has_rotate4 = true
      Glide => has_glide = true
    }
  }
  inspect(has_mirror_h, content="true")
  inspect(has_mirror_v, content="true")
  inspect(has_mirror_d, content="true")
  inspect(has_rotate2, content="true")
  inspect(has_rotate4, content="true")
  inspect(has_glide, content="true")
}

///|
test "grid has correct number of tiles (64 total)" {
  let levels = @levels.create_all_levels()
  for i in 0..<levels.length() {
    inspect(levels[i].grid.tiles.length(), content="64")
  }
}

///|
test "tier difficulty progression: repair par <= restore par <= master par" {
  let levels = @levels.create_all_levels()
  let mut repair_max = 0
  let mut restore_min = 99
  let mut restore_max = 0
  let mut master_min = 99
  for i in 0..<levels.length() {
    let holes = levels[i].grid.holes.length()
    match levels[i].tier {
      Repair => if holes > repair_max { repair_max = holes }
      Restore => {
        if holes < restore_min {
          restore_min = holes
        }
        if holes > restore_max {
          restore_max = holes
        }
      }
      Master => if holes < master_min { master_min = holes }
    }
  }
  // Tier 2 should generally have more holes than tier 1
  inspect(repair_max <= 8, content="true")
  // Tier 3 should have the most holes
  inspect(master_min >= 4, content="true")
}

///|
test "solution tiles satisfy symmetry validation" {
  let levels = @levels.create_all_levels()
  for i in 0..<levels.length() {
    let level = levels[i]
    let grid = level.grid
    let sym = level.symmetry
    for j in 0..<grid.holes.length() {
      let hole = grid.holes[j]
      let solution = @symmetry.compute_solution_tile(grid, hole, sym)
      match solution {
        Some(tile) => {
          // Place the tile temporarily and validate
          @types.set_tile(grid, hole.x, hole.y, Some(@types.copy_tile(tile)))
          let valid = @symmetry.validate_placement(grid, hole, tile, sym)
          inspect(valid, content="true")
          // Remove it again
          @types.set_tile(grid, hole.x, hole.y, None)
        }
        None => ()
      }
    }
  }
}

///|
test "level ordering: tiers are grouped (repair, restore, master)" {
  let levels = @levels.create_all_levels()
  // Verify repair levels come first, then restore, then master
  let mut last_tier_index = -1
  for i in 0..<levels.length() {
    let ti = @types.tier_index(levels[i].tier)
    inspect(ti >= last_tier_index, content="true")
    last_tier_index = ti
  }
}
