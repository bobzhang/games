///|
test "check_order correct" {
  let timeline = [0, 1, 2, 3, 4, 5]
  let solution = [0, 1, 2, 3, 4, 5]
  assert_true(check_order(timeline, solution))
}

///|
test "check_order swapped" {
  let timeline = [1, 0, 2, 3, 4, 5]
  let solution = [0, 1, 2, 3, 4, 5]
  assert_false(check_order(timeline, solution))
}

///|
test "check_order partial" {
  let timeline = [0, 1, 3, 2, 4, 5]
  let solution = [0, 1, 2, 3, 4, 5]
  assert_false(check_order(timeline, solution))
}

///|
test "count_correct_positions" {
  let timeline = [0, 1, 3, 2, 4, 5]
  let solution = [0, 1, 2, 3, 4, 5]
  assert_eq(count_correct_positions(timeline, solution), 4)
}

///|
test "check_links correct" {
  let placed = [
    @types.make_link(0, 2),
    @types.make_link(1, 3),
  ]
  let solution = [
    @types.make_link(0, 2),
    @types.make_link(1, 3),
  ]
  assert_true(check_links(placed, solution))
}

///|
test "check_links wrong" {
  let placed = [
    @types.make_link(0, 2),
    @types.make_link(1, 4),
  ]
  let solution = [
    @types.make_link(0, 2),
    @types.make_link(1, 3),
  ]
  assert_false(check_links(placed, solution))
}

///|
test "check_links missing" {
  let placed : Array[@types.CauseLink] = [
    @types.make_link(0, 2),
  ]
  let solution = [
    @types.make_link(0, 2),
    @types.make_link(1, 3),
  ]
  assert_false(check_links(placed, solution))
}

///|
test "check_links extra" {
  let placed = [
    @types.make_link(0, 2),
    @types.make_link(1, 3),
    @types.make_link(2, 4),
  ]
  let solution = [
    @types.make_link(0, 2),
    @types.make_link(1, 3),
  ]
  assert_false(check_links(placed, solution))
}

///|
test "count_correct_links" {
  let placed = [
    @types.make_link(0, 2),
    @types.make_link(1, 4),
    @types.make_link(3, 5),
  ]
  let solution = [
    @types.make_link(0, 2),
    @types.make_link(1, 3),
  ]
  assert_eq(count_correct_links(placed, solution), 1)
}

///|
test "clue Before satisfied" {
  let clue = @types.make_clue(Before, 0, 2, "A before B")
  let timeline = [0, 1, 2, 3]
  assert_true(check_clue_satisfied(clue, timeline))
}

///|
test "clue Before not satisfied" {
  let clue = @types.make_clue(Before, 2, 0, "B before A")
  let timeline = [0, 1, 2, 3]
  assert_false(check_clue_satisfied(clue, timeline))
}

///|
test "clue After satisfied" {
  let clue = @types.make_clue(After, 3, 1, "A after B")
  let timeline = [0, 1, 2, 3]
  assert_true(check_clue_satisfied(clue, timeline))
}

///|
test "clue After not satisfied" {
  let clue = @types.make_clue(After, 0, 2, "A after B but wrong")
  let timeline = [0, 1, 2, 3]
  assert_false(check_clue_satisfied(clue, timeline))
}

///|
test "clue Because satisfied (A before B)" {
  let clue = @types.make_clue(Because, 1, 3, "A caused B")
  let timeline = [0, 1, 2, 3]
  assert_true(check_clue_satisfied(clue, timeline))
}

///|
test "clue Because not satisfied" {
  let clue = @types.make_clue(Because, 3, 1, "B caused A but wrong")
  let timeline = [0, 1, 2, 3]
  assert_false(check_clue_satisfied(clue, timeline))
}

///|
test "clue During satisfied (adjacent)" {
  let clue = @types.make_clue(During, 1, 2, "A during B")
  let timeline = [0, 1, 2, 3]
  assert_true(check_clue_satisfied(clue, timeline))
}

///|
test "clue During not satisfied (not adjacent)" {
  let clue = @types.make_clue(During, 0, 2, "A during B but apart")
  let timeline = [0, 1, 2, 3]
  assert_false(check_clue_satisfied(clue, timeline))
}

///|
test "clue NotAdjacent satisfied" {
  let clue = @types.make_clue(NotAdjacent, 0, 3, "not next to each other")
  let timeline = [0, 1, 2, 3]
  assert_true(check_clue_satisfied(clue, timeline))
}

///|
test "clue NotAdjacent not satisfied" {
  let clue = @types.make_clue(NotAdjacent, 1, 2, "should not be adjacent")
  let timeline = [0, 1, 2, 3]
  assert_false(check_clue_satisfied(clue, timeline))
}

///|
test "check_all_clues all satisfied" {
  let clues = [
    @types.make_clue(Before, 0, 2, "A before B"),
    @types.make_clue(After, 3, 1, "C after D"),
  ]
  let timeline = [0, 1, 2, 3]
  assert_true(check_all_clues(clues, timeline))
}

///|
test "check_all_clues one fails" {
  let clues = [
    @types.make_clue(Before, 0, 2, "A before B"),
    @types.make_clue(Before, 3, 1, "D before B - wrong"),
  ]
  let timeline = [0, 1, 2, 3]
  assert_false(check_all_clues(clues, timeline))
}

///|
test "check_anchors correct" {
  let c = @types.make_event_card
  let case_ : @types.Case = {
    cards: [
      c(0, "A", "act", "time", 0),
      c(1, "B", "act", "time", -1),
      c(2, "C", "act", "time", 2),
    ],
    solution_order: [0, 1, 2],
    solution_links: [],
    clues: [],
    anchors: [0, 2],
    tier: Reports,
    title: "Test",
    theme: "Test",
  }
  let timeline = [0, 1, 2]
  assert_true(check_anchors(case_, timeline))
}

///|
test "check_anchors wrong position" {
  let c = @types.make_event_card
  let case_ : @types.Case = {
    cards: [
      c(0, "A", "act", "time", 0),
      c(1, "B", "act", "time", -1),
      c(2, "C", "act", "time", 2),
    ],
    solution_order: [0, 1, 2],
    solution_links: [],
    clues: [],
    anchors: [0, 2],
    tier: Reports,
    title: "Test",
    theme: "Test",
  }
  let timeline = [2, 1, 0]
  assert_false(check_anchors(case_, timeline))
}

///|
test "compute_score three stars" {
  let c = @types.make_event_card
  let case_ : @types.Case = {
    cards: [
      c(0, "A", "act", "t", 0),
      c(1, "B", "act", "t", -1),
      c(2, "C", "act", "t", -1),
    ],
    solution_order: [0, 1, 2],
    solution_links: [@types.make_link(0, 1)],
    clues: [],
    anchors: [0],
    tier: Reports,
    title: "Test",
    theme: "Test",
  }
  let score = compute_score(
    case_, [0, 1, 2], [@types.make_link(0, 1)], 0,
  )
  assert_eq(score.stars, 3)
  assert_true(score.order_correct)
  assert_true(score.links_correct)
  assert_true(score.no_rewinds)
}

///|
test "compute_score one star (order only)" {
  let c = @types.make_event_card
  let case_ : @types.Case = {
    cards: [
      c(0, "A", "act", "t", 0),
      c(1, "B", "act", "t", -1),
      c(2, "C", "act", "t", -1),
    ],
    solution_order: [0, 1, 2],
    solution_links: [@types.make_link(0, 1)],
    clues: [],
    anchors: [0],
    tier: Reports,
    title: "Test",
    theme: "Test",
  }
  let score = compute_score(case_, [0, 1, 2], [], 0)
  assert_eq(score.stars, 1)
  assert_true(score.order_correct)
  assert_false(score.links_correct)
}

///|
test "compute_score zero stars" {
  let c = @types.make_event_card
  let case_ : @types.Case = {
    cards: [
      c(0, "A", "act", "t", -1),
      c(1, "B", "act", "t", -1),
      c(2, "C", "act", "t", -1),
    ],
    solution_order: [0, 1, 2],
    solution_links: [@types.make_link(0, 1)],
    clues: [],
    anchors: [],
    tier: Reports,
    title: "Test",
    theme: "Test",
  }
  let score = compute_score(case_, [2, 1, 0], [], 0)
  assert_eq(score.stars, 0)
  assert_false(score.order_correct)
}

///|
test "compute_score two stars (with rewinds)" {
  let c = @types.make_event_card
  let case_ : @types.Case = {
    cards: [
      c(0, "A", "act", "t", -1),
      c(1, "B", "act", "t", -1),
    ],
    solution_order: [0, 1],
    solution_links: [@types.make_link(0, 1)],
    clues: [],
    anchors: [],
    tier: Reports,
    title: "Test",
    theme: "Test",
  }
  let score = compute_score(
    case_, [0, 1], [@types.make_link(0, 1)], 2,
  )
  assert_eq(score.stars, 2)
  assert_false(score.no_rewinds)
}
