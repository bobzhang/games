///|
test "all 20 levels load without error" {
  let levels = get_all_levels()
  inspect(levels.length(), content="20")
}

///|
test "all levels have valid grid size" {
  let levels = get_all_levels()
  for i in 0..<levels.length() {
    let level = levels[i]
    inspect(level.initial_block.size, content="8")
    inspect(level.target_shape.size, content="8")
  }
}

///|
test "all levels have non-empty names" {
  let levels = get_all_levels()
  for i in 0..<levels.length() {
    assert_true(levels[i].name.length() > 0)
  }
}

///|
test "initial blocks have solid cells" {
  let levels = get_all_levels()
  for i in 0..<levels.length() {
    let grid = levels[i].initial_block
    let mut solid_count = 0
    for j in 0..<(grid.size * grid.size) {
      if grid.cells[j] {
        solid_count += 1
      }
    }
    assert_true(solid_count > 0)
  }
}

///|
test "target shapes have solid cells" {
  let levels = get_all_levels()
  for i in 0..<levels.length() {
    let grid = levels[i].target_shape
    let mut solid_count = 0
    for j in 0..<(grid.size * grid.size) {
      if grid.cells[j] {
        solid_count += 1
      }
    }
    assert_true(solid_count > 0)
  }
}

///|
test "target has fewer or equal solid cells than initial" {
  // Erosion removes material, so target should have <= initial solid cells
  let levels = get_all_levels()
  for i in 0..<levels.length() {
    let initial = levels[i].initial_block
    let target = levels[i].target_shape
    let mut initial_count = 0
    let mut target_count = 0
    for j in 0..<(initial.size * initial.size) {
      if initial.cells[j] {
        initial_count += 1
      }
    }
    for j in 0..<(target.size * target.size) {
      if target.cells[j] {
        target_count += 1
      }
    }
    assert_true(target_count <= initial_count)
  }
}

///|
test "all force budgets are non-negative" {
  let levels = get_all_levels()
  for i in 0..<levels.length() {
    let b = levels[i].budget
    assert_true(b.water >= 0)
    assert_true(b.wind >= 0)
    assert_true(b.frost >= 0)
    assert_true(b.heat >= 0)
  }
}

///|
test "all levels have positive total force budget" {
  let levels = get_all_levels()
  for i in 0..<levels.length() {
    let b = levels[i].budget
    let total = b.water + b.wind + b.frost + b.heat
    assert_true(total > 0)
  }
}

///|
test "par forces is positive for all levels" {
  let levels = get_all_levels()
  for i in 0..<levels.length() {
    assert_true(levels[i].par_forces > 0)
  }
}

///|
test "par forces does not exceed total budget" {
  let levels = get_all_levels()
  for i in 0..<levels.length() {
    let b = levels[i].budget
    let total = b.water + b.wind + b.frost + b.heat
    assert_true(levels[i].par_forces <= total)
  }
}

///|
test "tier 1 levels are Clay tier (indices 0-6)" {
  let levels = get_all_levels()
  for i in 0..<7 {
    inspect(levels[i].tier, content="Clay")
  }
}

///|
test "tier 2 levels are Stone tier (indices 7-13)" {
  let levels = get_all_levels()
  for i in 7..<14 {
    inspect(levels[i].tier, content="Stone")
  }
}

///|
test "tier 3 levels are Crystal tier (indices 14-19)" {
  let levels = get_all_levels()
  for i in 14..<20 {
    inspect(levels[i].tier, content="Crystal")
  }
}

///|
test "clay tier levels use only water and wind" {
  let levels = get_all_levels()
  for i in 0..<7 {
    let b = levels[i].budget
    inspect(b.frost, content="0")
    inspect(b.heat, content="0")
  }
}

///|
test "stone tier levels use no heat" {
  let levels = get_all_levels()
  for i in 7..<14 {
    let b = levels[i].budget
    inspect(b.heat, content="0")
  }
}

///|
test "crystal tier levels use heat" {
  // At least some crystal levels should use heat
  let levels = get_all_levels()
  let mut any_heat = false
  for i in 14..<20 {
    if levels[i].budget.heat > 0 {
      any_heat = true
    }
  }
  inspect(any_heat, content="true")
}

///|
test "target is a subset of initial where initial is solid" {
  // Where target is solid, initial must also be solid
  // (cannot add material through erosion)
  let levels = get_all_levels()
  for i in 0..<levels.length() {
    let initial = levels[i].initial_block
    let target = levels[i].target_shape
    for j in 0..<(initial.size * initial.size) {
      if target.cells[j] {
        inspect(initial.cells[j], content="true")
      }
    }
  }
}

///|
test "grid cell arrays have correct length" {
  let levels = get_all_levels()
  for i in 0..<levels.length() {
    inspect(levels[i].initial_block.cells.length(), content="64")
    inspect(levels[i].target_shape.cells.length(), content="64")
  }
}

///|
test "total levels constant is 20" {
  inspect(@types.total_levels, content="20")
}

///|
test "level count function matches constant" {
  inspect(level_count(), content="20")
}
