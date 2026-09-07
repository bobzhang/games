///|
test "rock_name values" {
  inspect(rock_name(Sandstone), content="Sandstone")
  inspect(rock_name(Limestone), content="Limestone")
  inspect(rock_name(Shale), content="Shale")
  inspect(rock_name(Granite), content="Granite")
  inspect(rock_name(Basalt), content="Basalt")
  inspect(rock_name(Coal), content="Coal")
  inspect(rock_name(Chalk), content="Chalk")
  inspect(rock_name(Slate), content="Slate")
}

///|
test "rock_index values" {
  inspect(rock_index(Sandstone), content="0")
  inspect(rock_index(Limestone), content="1")
  inspect(rock_index(Shale), content="2")
  inspect(rock_index(Granite), content="3")
  inspect(rock_index(Basalt), content="4")
  inspect(rock_index(Coal), content="5")
  inspect(rock_index(Chalk), content="6")
  inspect(rock_index(Slate), content="7")
}

///|
test "rock_from_index round trips" {
  inspect(rock_from_index(0), content="Sandstone")
  inspect(rock_from_index(1), content="Limestone")
  inspect(rock_from_index(2), content="Shale")
  inspect(rock_from_index(3), content="Granite")
  inspect(rock_from_index(4), content="Basalt")
  inspect(rock_from_index(5), content="Coal")
  inspect(rock_from_index(6), content="Chalk")
  inspect(rock_from_index(7), content="Slate")
}

///|
test "rock_from_index out of range defaults to slate" {
  inspect(rock_from_index(99), content="Slate")
  inspect(rock_from_index(-1), content="Slate")
}

///|
test "rock_index and rock_from_index are inverses" {
  let rocks : Array[RockKind] = [
    Sandstone,
    Limestone,
    Shale,
    Granite,
    Basalt,
    Coal,
    Chalk,
    Slate,
  ]
  for i in 0..<rocks.length() {
    inspect(rock_from_index(rock_index(rocks[i])) == rocks[i], content="true")
  }
}

///|
test "tier_name values" {
  inspect(tier_name(Surface), content="Surface")
  inspect(tier_name(Bedrock), content="Bedrock")
  inspect(tier_name(DeepCore), content="Deep Core")
}

///|
test "tier_level_range values" {
  debug_inspect(tier_level_range(Surface), content="(0, 7)")
  debug_inspect(tier_level_range(Bedrock), content="(8, 16)")
  debug_inspect(tier_level_range(DeepCore), content="(17, 24)")
}

///|
test "tier_from_level" {
  inspect(tier_from_level(0), content="Surface")
  inspect(tier_from_level(7), content="Surface")
  inspect(tier_from_level(8), content="Bedrock")
  inspect(tier_from_level(16), content="Bedrock")
  inspect(tier_from_level(17), content="DeepCore")
  inspect(tier_from_level(24), content="DeepCore")
}

///|
test "clue_kind_name values" {
  inspect(clue_kind_name(FossilAge), content="Fossil Age")
  inspect(clue_kind_name(Superposition), content="Superposition")
  inspect(clue_kind_name(Dating), content="Dating")
  inspect(clue_kind_name(Intrusion), content="Intrusion")
  inspect(clue_kind_name(Unconformity), content="Unconformity")
}

///|
test "new_clue constructor" {
  let c = new_clue(FossilAge, 1, 2, "test clue")
  inspect(c.kind, content="FossilAge")
  inspect(c.param_a, content="1")
  inspect(c.param_b, content="2")
  inspect(c.text, content="test clue")
  inspect(c.satisfied, content="false")
}

///|
test "new_level constructor" {
  let rocks : Array[RockKind] = [Sandstone, Limestone, Shale]
  let clues : Array[Clue] = [new_clue(Dating, 0, 0, "bottom")]
  let lev = new_level(Surface, "Test Level", rocks, clues, 5)
  inspect(lev.tier, content="Surface")
  inspect(lev.name, content="Test Level")
  inspect(lev.rocks.length(), content="3")
  inspect(lev.clues.length(), content="1")
  inspect(lev.par_moves, content="5")
}

///|
test "new_level_score defaults" {
  let s = new_level_score()
  inspect(s.stars, content="0")
  inspect(s.completed, content="false")
  inspect(s.best_moves, content="999")
}

///|
test "find_rock_slot finds present rock" {
  let slots : Array[RockKind?] = [Some(Granite), Some(Shale), Some(Sandstone)]
  inspect(find_rock_slot(slots, Granite), content="0")
  inspect(find_rock_slot(slots, Sandstone), content="2")
}

///|
test "find_rock_slot returns -1 for missing rock" {
  let slots : Array[RockKind?] = [Some(Granite), None, Some(Sandstone)]
  inspect(find_rock_slot(slots, Coal), content="-1")
}

///|
test "find_rock_slot skips None slots" {
  let slots : Array[RockKind?] = [None, None, Some(Basalt)]
  inspect(find_rock_slot(slots, Basalt), content="2")
}

///|
test "count_filled_slots" {
  let slots : Array[RockKind?] = [Some(Granite), None, Some(Sandstone)]
  inspect(count_filled_slots(slots), content="2")
  let empty : Array[RockKind?] = [None, None, None]
  inspect(count_filled_slots(empty), content="0")
}

///|
test "all_slots_filled true when full" {
  let slots : Array[RockKind?] = [Some(Granite), Some(Shale), Some(Coal)]
  inspect(all_slots_filled(slots), content="true")
}

///|
test "all_slots_filled false when has empty" {
  let slots : Array[RockKind?] = [Some(Granite), None, Some(Coal)]
  inspect(all_slots_filled(slots), content="false")
}

///|
test "save_undo and pop_undo" {
  let g = new_game()
  g.slots = [Some(Sandstone), None, Some(Granite)]
  g.tray = [Limestone, Shale]
  save_undo(g)
  // Modify state
  g.slots[1] = Some(Limestone)
  g.tray = [Shale]
  // Pop should restore
  let ok = pop_undo(g)
  inspect(ok, content="true")
  debug_inspect(g.slots[1], content="None")
  inspect(g.tray.length(), content="2")
}

///|
test "pop_undo returns false when empty" {
  let g = new_game()
  inspect(pop_undo(g), content="false")
}

///|
test "set_message" {
  let g = new_game()
  set_message(g, "Hello!", 2.5)
  inspect(g.message, content="Hello!")
  inspect(g.message_timer, content="2.5")
}

///|
test "mini and maxi" {
  inspect(mini(3, 7), content="3")
  inspect(mini(7, 3), content="3")
  inspect(maxi(3, 7), content="7")
  inspect(maxi(7, 3), content="7")
}

///|
test "absf" {
  inspect(absf(-3.5), content="3.5")
  inspect(absf(3.5), content="3.5")
  inspect(absf(0.0), content="0")
}

///|
test "new_game initializes properly" {
  let g = new_game()
  inspect(g.screen, content="Title")
  inspect(g.current_tier, content="Surface")
  inspect(g.scores.length(), content="25")
  inspect(g.moves, content="0")
  inspect(g.selected_tray, content="-1")
  inspect(g.selected_slot, content="-1")
  inspect(g.play_state, content="Arranging")
}
