///|
test "get_level returns valid defs" {
  for i in 0..<25 {
    let def = @levels.get_level(i)
    inspect(def.id == i, content="true")
    inspect(def.battery_budget > 0, content="true")
    inspect(def.par_batteries > 0, content="true")
    inspect(def.fixed_cells.length() > 0, content="true")
  }
}

///|
test "get_tier_name" {
  inspect(@levels.get_tier_name(0), content="Basics")
  inspect(@levels.get_tier_name(7), content="Basics")
  inspect(@levels.get_tier_name(8), content="Parallel")
  inspect(@levels.get_tier_name(16), content="Parallel")
  inspect(@levels.get_tier_name(17), content="Networks")
  inspect(@levels.get_tier_name(24), content="Networks")
}

///|
test "get_tier" {
  inspect(@levels.get_tier(0), content="Basics")
  inspect(@levels.get_tier(10), content="Parallel")
  inspect(@levels.get_tier(20), content="Networks")
}

///|
test "load_level places fixed cells" {
  let state = @levels.load_level(0)
  // Level 1 has a Device at (5,2)
  match state.cells[2][5].component {
    Device(_) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
  inspect(state.cells[2][5].fixed, content="true")
}

///|
test "load_level sets budget" {
  let state = @levels.load_level(0)
  inspect(state.battery_budget, content="1")
  inspect(state.par_batteries, content="1")
}

///|
test "load_level counts devices" {
  let state = @levels.load_level(0)
  inspect(state.devices_total, content="1")
  let state2 = @levels.load_level(8)
  inspect(state2.devices_total, content="2")
}

///|
test "level 3 has pre-placed battery" {
  let state = @levels.load_level(2)
  inspect(state.cells[3][0].component, content="Battery")
  inspect(state.cells[3][0].fixed, content="true")
}

///|
test "all levels have at least one device" {
  for i in 0..<25 {
    let state = @levels.load_level(i)
    inspect(state.devices_total > 0, content="true")
  }
}

///|
test "tier 3 levels have fuses or switches" {
  for i in 17..<25 {
    let def = @levels.get_level(i)
    let has_extra = def.fuse_budget > 0 || def.switch_budget > 0
    inspect(has_extra, content="true")
  }
}
