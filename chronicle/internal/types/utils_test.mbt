///|
test "find_card found" {
  let cards = [
    make_event_card(0, "A", "act1", "t1", -1),
    make_event_card(1, "B", "act2", "t2", -1),
    make_event_card(2, "C", "act3", "t3", -1),
  ]
  match find_card(cards, 1) {
    Some(c) => assert_eq(c.actor, "B")
    None => fail("should find card 1")
  }
}

///|
test "find_card not found" {
  let cards = [
    make_event_card(0, "A", "act1", "t1", -1),
  ]
  match find_card(cards, 5) {
    Some(_) => fail("should not find card 5")
    None => ()
  }
}

///|
test "card_in_slot" {
  let timeline = [3, -1, 1, 0, -1]
  assert_eq(card_in_slot(timeline, 1), 2)
  assert_eq(card_in_slot(timeline, 0), 3)
  assert_eq(card_in_slot(timeline, 99), -1)
}

///|
test "is_card_placed" {
  let timeline = [0, -1, 2]
  assert_true(is_card_placed(timeline, 0))
  assert_false(is_card_placed(timeline, 1))
  assert_true(is_card_placed(timeline, 2))
}

///|
test "is_slot_empty" {
  let timeline = [0, -1, 2]
  assert_false(is_slot_empty(timeline, 0))
  assert_true(is_slot_empty(timeline, 1))
  assert_false(is_slot_empty(timeline, 2))
}

///|
test "count_placed" {
  let timeline = [0, -1, 2, -1, 4]
  assert_eq(count_placed(timeline), 3)
}

///|
test "link_exists" {
  let links = [make_link(0, 1), make_link(2, 3)]
  assert_true(link_exists(links, 0, 1))
  assert_true(link_exists(links, 2, 3))
  assert_false(link_exists(links, 1, 0))
  assert_false(link_exists(links, 0, 3))
}

///|
test "remove_link" {
  let links = [make_link(0, 1), make_link(2, 3), make_link(4, 5)]
  let result = remove_link(links, 2, 3)
  assert_eq(result.length(), 2)
  assert_true(link_exists(result, 0, 1))
  assert_false(link_exists(result, 2, 3))
  assert_true(link_exists(result, 4, 5))
}

///|
test "tier_index and tier_from_index" {
  assert_eq(tier_index(Reports), 0)
  assert_eq(tier_index(Investigations), 1)
  assert_eq(tier_index(ColdCases), 2)
  assert_eq(tier_from_index(0), Reports)
  assert_eq(tier_from_index(1), Investigations)
  assert_eq(tier_from_index(2), ColdCases)
}

///|
test "tier_case_count" {
  assert_eq(tier_case_count(Reports), 7)
  assert_eq(tier_case_count(Investigations), 7)
  assert_eq(tier_case_count(ColdCases), 6)
}

///|
test "is_anchor" {
  let case_ : Case = {
    cards: [
      make_event_card(0, "A", "act", "t", 0),
      make_event_card(1, "B", "act", "t", -1),
    ],
    solution_order: [0, 1],
    solution_links: [],
    clues: [],
    anchors: [0],
    tier: Reports,
    title: "Test",
    theme: "Test",
  }
  assert_true(is_anchor(case_, 0))
  assert_false(is_anchor(case_, 1))
}

///|
test "get_fixed_slot" {
  let cards = [
    make_event_card(0, "A", "act", "t", 0),
    make_event_card(1, "B", "act", "t", -1),
    make_event_card(2, "C", "act", "t", 2),
  ]
  assert_eq(get_fixed_slot(cards, 0), 0)
  assert_eq(get_fixed_slot(cards, 1), -1)
  assert_eq(get_fixed_slot(cards, 2), 2)
}

///|
test "minf maxf" {
  let a : Float = 3.0
  let b : Float = 5.0
  assert_eq(minf(a, b), a)
  assert_eq(maxf(a, b), b)
}

///|
test "clampf" {
  let lo : Float = 0.0
  let hi : Float = 10.0
  let v1 : Float = -5.0
  let v2 : Float = 5.0
  let v3 : Float = 15.0
  assert_eq(clampf(v1, lo, hi), lo)
  assert_eq(clampf(v2, lo, hi), v2)
  assert_eq(clampf(v3, lo, hi), hi)
}
