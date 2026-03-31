///|
test "all 20 cases loaded" {
  let cases = get_all_cases()
  assert_eq(cases.length(), 20)
}

///|
test "tier 1 has 7 cases" {
  let mut count = 0
  let cases = get_all_cases()
  for i in 0..<cases.length() {
    if cases[i].tier == Reports {
      count += 1
    }
  }
  assert_eq(count, 7)
}

///|
test "tier 2 has 7 cases" {
  let mut count = 0
  let cases = get_all_cases()
  for i in 0..<cases.length() {
    if cases[i].tier == Investigations {
      count += 1
    }
  }
  assert_eq(count, 7)
}

///|
test "tier 3 has 6 cases" {
  let mut count = 0
  let cases = get_all_cases()
  for i in 0..<cases.length() {
    if cases[i].tier == ColdCases {
      count += 1
    }
  }
  assert_eq(count, 6)
}

///|
test "tier 1 cases have 6 cards" {
  let cases = get_all_cases()
  for i in 0..<7 {
    assert_eq(cases[i].cards.length(), 6)
  }
}

///|
test "tier 2 cases have 7 cards" {
  let cases = get_all_cases()
  for i in 7..<14 {
    assert_eq(cases[i].cards.length(), 7)
  }
}

///|
test "tier 3 cases have 8 cards" {
  let cases = get_all_cases()
  for i in 14..<20 {
    assert_eq(cases[i].cards.length(), 8)
  }
}

///|
test "solution order length matches card count" {
  let cases = get_all_cases()
  for i in 0..<cases.length() {
    assert_eq(cases[i].solution_order.length(), cases[i].cards.length())
  }
}

///|
test "each case has at least one clue" {
  let cases = get_all_cases()
  for i in 0..<cases.length() {
    assert_true(cases[i].clues.length() > 0)
  }
}

///|
test "each case has at least one anchor" {
  let cases = get_all_cases()
  for i in 0..<cases.length() {
    assert_true(cases[i].anchors.length() > 0)
  }
}

///|
test "get_case returns correct case" {
  let case_ = get_case(Reports, 0)
  assert_eq(case_.title, "The Warehouse Fire")
  let case2 = get_case(Investigations, 0)
  assert_eq(case2.title, "The Lab Incident")
  let case3 = get_case(ColdCases, 0)
  assert_eq(case3.title, "The Cover-Up")
}
