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

///|
test "all case titles are unique" {
  let cases = get_all_cases()
  for i in 0..<cases.length() {
    for j in (i + 1)..<cases.length() {
      assert_true(cases[i].title != cases[j].title)
    }
  }
}

///|
test "card IDs are sequential within each case" {
  let cases = get_all_cases()
  for i in 0..<cases.length() {
    let cards = cases[i].cards
    for j in 0..<cards.length() {
      assert_eq(cards[j].id, j)
    }
  }
}

///|
test "solution order is a permutation of card IDs" {
  let cases = get_all_cases()
  for i in 0..<cases.length() {
    let case_ = cases[i]
    let n = case_.cards.length()
    // Check that every card ID appears exactly once in solution_order
    for id in 0..<n {
      let mut found = false
      for s in 0..<case_.solution_order.length() {
        if case_.solution_order[s] == id {
          found = true
          break
        }
      }
      assert_true(found)
    }
  }
}

///|
test "solution links reference valid card IDs" {
  let cases = get_all_cases()
  for i in 0..<cases.length() {
    let case_ = cases[i]
    let n = case_.cards.length()
    for j in 0..<case_.solution_links.length() {
      let link = case_.solution_links[j]
      assert_true(link.from_id >= 0 && link.from_id < n)
      assert_true(link.to_id >= 0 && link.to_id < n)
      assert_true(link.from_id != link.to_id)
    }
  }
}

///|
test "clue card references are valid" {
  let cases = get_all_cases()
  for i in 0..<cases.length() {
    let case_ = cases[i]
    let n = case_.cards.length()
    for j in 0..<case_.clues.length() {
      let clue = case_.clues[j]
      assert_true(clue.card_a >= 0 && clue.card_a < n)
      assert_true(clue.card_b >= 0 && clue.card_b < n)
      assert_true(clue.card_a != clue.card_b)
    }
  }
}

///|
test "anchor card IDs are valid and have fixed_slot set" {
  let cases = get_all_cases()
  for i in 0..<cases.length() {
    let case_ = cases[i]
    let n = case_.cards.length()
    for j in 0..<case_.anchors.length() {
      let anchor_id = case_.anchors[j]
      assert_true(anchor_id >= 0 && anchor_id < n)
      // The anchor card must have a valid fixed_slot
      let fixed = @types.get_fixed_slot(case_.cards, anchor_id)
      assert_true(fixed >= 0 && fixed < n)
    }
  }
}

///|
test "anchors are in correct positions in solution order" {
  let cases = get_all_cases()
  for i in 0..<cases.length() {
    let case_ = cases[i]
    for j in 0..<case_.anchors.length() {
      let anchor_id = case_.anchors[j]
      let fixed_slot = @types.get_fixed_slot(case_.cards, anchor_id)
      if fixed_slot >= 0 {
        // In the solution, the anchor should be at its fixed slot
        assert_eq(case_.solution_order[fixed_slot], anchor_id)
      }
    }
  }
}

///|
test "each case has at least 2 anchors" {
  let cases = get_all_cases()
  for i in 0..<cases.length() {
    assert_true(cases[i].anchors.length() >= 2)
  }
}

///|
test "all clues are satisfied by solution order" {
  let cases = get_all_cases()
  for i in 0..<cases.length() {
    let case_ = cases[i]
    for j in 0..<case_.clues.length() {
      let satisfied = @logic.check_clue_satisfied(
        case_.clues[j],
        case_.solution_order,
      )
      assert_true(satisfied)
    }
  }
}

///|
test "solution links match cause links in solution" {
  let cases = get_all_cases()
  for i in 0..<cases.length() {
    let case_ = cases[i]
    // In the solution order, cause must come before effect
    for j in 0..<case_.solution_links.length() {
      let link = case_.solution_links[j]
      let from_pos = @types.card_in_slot(case_.solution_order, link.from_id)
      let to_pos = @types.card_in_slot(case_.solution_order, link.to_id)
      assert_true(from_pos >= 0)
      assert_true(to_pos >= 0)
      assert_true(from_pos < to_pos)
    }
  }
}

///|
test "no duplicate solution links" {
  let cases = get_all_cases()
  for i in 0..<cases.length() {
    let links = cases[i].solution_links
    for j in 0..<links.length() {
      for k in (j + 1)..<links.length() {
        let same = links[j].from_id == links[k].from_id &&
          links[j].to_id == links[k].to_id
        assert_false(same)
      }
    }
  }
}

///|
test "tier 1 cases have 1-2 solution links" {
  let cases = get_all_cases()
  for i in 0..<7 {
    let links = cases[i].solution_links.length()
    assert_true(links >= 1 && links <= 2)
  }
}

///|
test "tier 2 cases have 2-3 solution links" {
  let cases = get_all_cases()
  for i in 7..<14 {
    let links = cases[i].solution_links.length()
    assert_true(links >= 2 && links <= 3)
  }
}

///|
test "tier 3 cases have 3-4 solution links" {
  let cases = get_all_cases()
  for i in 14..<20 {
    let links = cases[i].solution_links.length()
    assert_true(links >= 3 && links <= 4)
  }
}

///|
test "compute_score gives 3 stars for perfect solution" {
  let cases = get_all_cases()
  for i in 0..<cases.length() {
    let case_ = cases[i]
    let score = @logic.compute_score(
      case_,
      case_.solution_order,
      case_.solution_links,
      0,
    )
    assert_eq(score.stars, 3)
    assert_true(score.order_correct)
    assert_true(score.links_correct)
    assert_true(score.no_rewinds)
  }
}

///|
test "each clue has non-empty text" {
  let cases = get_all_cases()
  for i in 0..<cases.length() {
    for j in 0..<cases[i].clues.length() {
      assert_true(cases[i].clues[j].text.length() > 0)
    }
  }
}

///|
test "each card has non-empty actor and action" {
  let cases = get_all_cases()
  for i in 0..<cases.length() {
    for j in 0..<cases[i].cards.length() {
      assert_true(cases[i].cards[j].actor.length() > 0)
      assert_true(cases[i].cards[j].action.length() > 0)
    }
  }
}

///|
test "each case has correct tier assigned" {
  let cases = get_all_cases()
  for i in 0..<7 {
    assert_eq(cases[i].tier, Reports)
  }
  for i in 7..<14 {
    assert_eq(cases[i].tier, Investigations)
  }
  for i in 14..<20 {
    assert_eq(cases[i].tier, ColdCases)
  }
}
