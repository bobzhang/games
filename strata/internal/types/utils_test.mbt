///|
test "rock_name values" {
  inspect(@types.rock_name(Sandstone), content="Sandstone")
  inspect(@types.rock_name(Limestone), content="Limestone")
  inspect(@types.rock_name(Shale), content="Shale")
  inspect(@types.rock_name(Granite), content="Granite")
  inspect(@types.rock_name(Basalt), content="Basalt")
  inspect(@types.rock_name(Coal), content="Coal")
  inspect(@types.rock_name(Chalk), content="Chalk")
  inspect(@types.rock_name(Slate), content="Slate")
}

///|
test "rock_index values" {
  inspect(@types.rock_index(Sandstone), content="0")
  inspect(@types.rock_index(Limestone), content="1")
  inspect(@types.rock_index(Shale), content="2")
  inspect(@types.rock_index(Granite), content="3")
  inspect(@types.rock_index(Basalt), content="4")
  inspect(@types.rock_index(Coal), content="5")
  inspect(@types.rock_index(Chalk), content="6")
  inspect(@types.rock_index(Slate), content="7")
}

///|
test "rock_from_index round trips" {
  inspect(@types.rock_from_index(0), content="Sandstone")
  inspect(@types.rock_from_index(1), content="Limestone")
  inspect(@types.rock_from_index(2), content="Shale")
  inspect(@types.rock_from_index(3), content="Granite")
  inspect(@types.rock_from_index(4), content="Basalt")
  inspect(@types.rock_from_index(5), content="Coal")
  inspect(@types.rock_from_index(6), content="Chalk")
  inspect(@types.rock_from_index(7), content="Slate")
}

///|
test "rock_from_index out of range defaults to slate" {
  inspect(@types.rock_from_index(99), content="Slate")
  inspect(@types.rock_from_index(-1), content="Slate")
}

///|
test "rock_index and rock_from_index are inverses" {
  let rocks : Array[@types.RockKind] = [
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
    inspect(@types.rock_from_index(@types.rock_index(rocks[i])) == rocks[i], content="true")
  }
}

///|
test "tier_name values" {
  inspect(@types.tier_name(Surface), content="Surface")
  inspect(@types.tier_name(Bedrock), content="Bedrock")
  inspect(@types.tier_name(DeepCore), content="Deep Core")
}

///|
test "tier_level_range values" {
  debug_inspect(@types.tier_level_range(Surface), content="(0, 7)")
  debug_inspect(@types.tier_level_range(Bedrock), content="(8, 16)")
  debug_inspect(@types.tier_level_range(DeepCore), content="(17, 24)")
}

///|
test "tier_from_level" {
  inspect(@types.tier_from_level(0), content="Surface")
  inspect(@types.tier_from_level(7), content="Surface")
  inspect(@types.tier_from_level(8), content="Bedrock")
  inspect(@types.tier_from_level(16), content="Bedrock")
  inspect(@types.tier_from_level(17), content="DeepCore")
  inspect(@types.tier_from_level(24), content="DeepCore")
}

///|
test "clue_kind_name values" {
  inspect(@types.clue_kind_name(FossilAge), content="Fossil Age")
  inspect(@types.clue_kind_name(Superposition), content="Superposition")
  inspect(@types.clue_kind_name(Dating), content="Dating")
  inspect(@types.clue_kind_name(Intrusion), content="Intrusion")
  inspect(@types.clue_kind_name(Unconformity), content="Unconformity")
}

///|
test "new_clue constructor" {
  let c = @types.new_clue(FossilAge, 1, 2, "test clue")
  inspect(c.kind, content="FossilAge")
  inspect(c.param_a, content="1")
  inspect(c.param_b, content="2")
  inspect(c.text, content="test clue")
  inspect(c.satisfied, content="false")
}

///|
test "new_level constructor" {
  let rocks : Array[@types.RockKind] = [Sandstone, Limestone, Shale]
  let clues : Array[@types.Clue] = [@types.new_clue(Dating, 0, 0, "bottom")]
  let lev = @types.new_level(Surface, "Test Level", rocks, clues, 5)
  inspect(lev.tier, content="Surface")
  inspect(lev.name, content="Test Level")
  inspect(lev.rocks.length(), content="3")
  inspect(lev.clues.length(), content="1")
  inspect(lev.par_moves, content="5")
}

///|
test "new_level_score defaults" {
  let s = @types.new_level_score()
  inspect(s.stars, content="0")
  inspect(s.completed, content="false")
  inspect(s.best_moves, content="999")
}

///|
test "find_rock_slot finds present rock" {
  let slots : Array[@types.RockKind?] = [Some(Granite), Some(Shale), Some(Sandstone)]
  inspect(@types.find_rock_slot(slots, Granite), content="0")
  inspect(@types.find_rock_slot(slots, Sandstone), content="2")
}

///|
test "find_rock_slot returns -1 for missing rock" {
  let slots : Array[@types.RockKind?] = [Some(Granite), None, Some(Sandstone)]
  inspect(@types.find_rock_slot(slots, Coal), content="-1")
}

///|
test "find_rock_slot skips None slots" {
  let slots : Array[@types.RockKind?] = [None, None, Some(Basalt)]
  inspect(@types.find_rock_slot(slots, Basalt), content="2")
}

///|
test "count_filled_slots" {
  let slots : Array[@types.RockKind?] = [Some(Granite), None, Some(Sandstone)]
  inspect(@types.count_filled_slots(slots), content="2")
  let empty : Array[@types.RockKind?] = [None, None, None]
  inspect(@types.count_filled_slots(empty), content="0")
}

///|
test "all_slots_filled true when full" {
  let slots : Array[@types.RockKind?] = [Some(Granite), Some(Shale), Some(Coal)]
  inspect(@types.all_slots_filled(slots), content="true")
}

///|
test "all_slots_filled false when has empty" {
  let slots : Array[@types.RockKind?] = [Some(Granite), None, Some(Coal)]
  inspect(@types.all_slots_filled(slots), content="false")
}

///|
test "save_undo and pop_undo" {
  let g = @types.new_game()
  g.slots = [Some(Sandstone), None, Some(Granite)]
  g.tray = [Limestone, Shale]
  @types.save_undo(g)
  // Modify state
  g.slots[1] = Some(Limestone)
  g.tray = [Shale]
  // Pop should restore
  let ok = @types.pop_undo(g)
  inspect(ok, content="true")
  debug_inspect(g.slots[1], content="None")
  inspect(g.tray.length(), content="2")
}

///|
test "pop_undo returns false when empty" {
  let g = @types.new_game()
  inspect(@types.pop_undo(g), content="false")
}

///|
test "set_message" {
  let g = @types.new_game()
  @types.set_message(g, "Hello!", 2.5)
  inspect(g.message, content="Hello!")
  inspect(g.message_timer, content="2.5")
}

///|
test "mini and maxi" {
  inspect(@types.mini(3, 7), content="3")
  inspect(@types.mini(7, 3), content="3")
  inspect(@types.maxi(3, 7), content="7")
  inspect(@types.maxi(7, 3), content="7")
}

///|
test "absf" {
  inspect(@types.absf(-3.5), content="3.5")
  inspect(@types.absf(3.5), content="3.5")
  inspect(@types.absf(0.0), content="0")
}

///|
test "new_game initializes properly" {
  let g = @types.new_game()
  inspect(g.screen, content="Title")
  inspect(g.current_tier, content="Surface")
  inspect(g.scores.length(), content="25")
  inspect(g.moves, content="0")
  inspect(g.selected_tray, content="-1")
  inspect(g.selected_slot, content="-1")
  inspect(g.play_state, content="Arranging")
}
