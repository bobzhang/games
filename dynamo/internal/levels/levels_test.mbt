///|
test "get_level returns valid defs" {
  for i in 0..<20 {
    let def = @levels.get_level(i)
    inspect(def.id == i, content="true")
    inspect(def.magnet_budget > 0, content="true")
    inspect(def.par_magnets > 0, content="true")
    inspect(def.fixed_cells.length() > 0, content="true")
  }
}

///|
test "get_tier_name" {
  inspect(@levels.get_tier_name(0), content="Foundations")
  inspect(@levels.get_tier_name(6), content="Foundations")
  inspect(@levels.get_tier_name(7), content="Generators")
  inspect(@levels.get_tier_name(13), content="Generators")
  inspect(@levels.get_tier_name(14), content="Power Grid")
  inspect(@levels.get_tier_name(19), content="Power Grid")
}

///|
test "get_tier" {
  inspect(@levels.get_tier(0), content="Foundations")
  inspect(@levels.get_tier(10), content="Generators")
  inspect(@levels.get_tier(16), content="PowerGrid")
}

///|
test "load_level places fixed cells" {
  let state = @levels.load_level(0)
  // Level 1 has a Coil at (4,2)
  match state.cells[2][4].component {
    Coil => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
  inspect(state.cells[2][4].fixed, content="true")
}

///|
test "load_level sets budget" {
  let state = @levels.load_level(0)
  inspect(state.magnet_budget, content="1")
  inspect(state.par_magnets, content="1")
}

///|
test "load_level counts devices" {
  let state = @levels.load_level(0)
  inspect(state.devices_total, content="1")
  let state2 = @levels.load_level(7)
  inspect(state2.devices_total, content="2")
}

///|
test "level 3 has pre-placed magnet" {
  let state = @levels.load_level(2)
  inspect(state.cells[3][0].component, content="Magnet(North)")
  inspect(state.cells[3][0].fixed, content="true")
}

///|
test "all levels have at least one device" {
  for i in 0..<20 {
    let state = @levels.load_level(i)
    inspect(state.devices_total > 0, content="true")
  }
}

///|
test "tier 1 levels have magnet budget" {
  for i in 0..<7 {
    let def = @levels.get_level(i)
    inspect(def.magnet_budget > 0, content="true")
  }
}

///|
test "tier 2 levels have coil budgets" {
  for i in 7..<14 {
    let def = @levels.get_level(i)
    inspect(def.coil_budget > 0, content="true")
  }
}

///|
test "tier 3 levels have larger budgets" {
  for i in 14..<20 {
    let def = @levels.get_level(i)
    inspect(def.magnet_budget >= 4, content="true")
  }
}

///|
test "level names are unique" {
  let names : Array[String] = []
  for i in 0..<20 {
    let def = @levels.get_level(i)
    let mut found = false
    for j in 0..<names.length() {
      if names[j] == def.name {
        found = true
      }
    }
    inspect(found, content="false")
    names.push(def.name)
  }
}

///|
test "level fixed cells are within bounds" {
  for i in 0..<20 {
    let def = @levels.get_level(i)
    for j in 0..<def.fixed_cells.length() {
      let p = def.fixed_cells[j]
      inspect(@types.in_bounds(p.col, p.row), content="true")
    }
  }
}
