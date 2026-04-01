///|
test "is_base_element" {
  assert_eq(is_base_element(Fire), true)
  assert_eq(is_base_element(Water), true)
  assert_eq(is_base_element(Earth), true)
  assert_eq(is_base_element(Air), true)
  assert_eq(is_base_element(Light), true)
  assert_eq(is_base_element(Shadow), true)
  assert_eq(is_base_element(Steam), false)
  assert_eq(is_base_element(Mud), false)
  assert_eq(is_base_element(Clay), false)
  assert_eq(is_base_element(Storm), false)
}

///|
test "budget_spend and budget_get" {
  let b = new_budget(3, 2, 1, 0, 0, 0)
  assert_eq(budget_get(b, Fire), 3)
  assert_eq(budget_get(b, Water), 2)
  assert_eq(budget_spend(b, Fire), true)
  assert_eq(budget_get(b, Fire), 2)
  assert_eq(budget_spend(b, Air), false) // 0 budget
  assert_eq(budget_get(b, Air), 0)
}

///|
test "budget_spend depletes" {
  let b = new_budget(1, 0, 0, 0, 0, 0)
  assert_eq(budget_spend(b, Fire), true)
  assert_eq(budget_spend(b, Fire), false) // Now depleted
  assert_eq(budget_get(b, Fire), 0)
}

///|
test "copy_budget is independent" {
  let b = new_budget(3, 2, 1, 0, 0, 0)
  let c = copy_budget(b)
  ignore(budget_spend(c, Fire))
  assert_eq(budget_get(b, Fire), 3) // Original unchanged
  assert_eq(budget_get(c, Fire), 2) // Copy changed
}

///|
test "tier_start_index and tier_level_count" {
  assert_eq(tier_start_index(Apprentice), 0)
  assert_eq(tier_level_count(Apprentice), 8)
  assert_eq(tier_start_index(Journeyman), 8)
  assert_eq(tier_level_count(Journeyman), 9)
  assert_eq(tier_start_index(Master), 17)
  assert_eq(tier_level_count(Master), 8)
}

///|
test "element_name returns correct strings" {
  assert_eq(element_name(Fire), "Fire")
  assert_eq(element_name(Steam), "Steam")
  assert_eq(element_name(Clay), "Clay")
  assert_eq(element_name(Obsidian), "Obsidian")
}

///|
test "all_base_elements returns 6" {
  let bases = all_base_elements()
  assert_eq(bases.length(), 6)
}

///|
test "budget_get for compound elements returns 0" {
  let b = new_budget(1, 1, 1, 1, 1, 1)
  assert_eq(budget_get(b, Steam), 0)
  assert_eq(budget_get(b, Clay), 0)
}
