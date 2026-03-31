///|
test "fossil age ordering - older below younger" {
  // Slot 0 = bottom (oldest), higher = younger
  let slots : Array[@types.RockKind?] = [
    Some(Sandstone),
    Some(Limestone),
    Some(Shale),
    Some(Granite),
  ]
  // Sandstone(0) is older than Limestone(1)
  inspect(check_fossil_age(slots, 0, 1), content="true")
  // Limestone(1) is NOT older than Sandstone(0)
  inspect(check_fossil_age(slots, 1, 0), content="false")
  // Sandstone(0) is older than Granite(3)
  inspect(check_fossil_age(slots, 0, 3), content="true")
}

///|
test "fossil age - missing rock returns false" {
  let slots : Array[@types.RockKind?] = [Some(Sandstone), None, Some(Shale)]
  // Coal (5) not in slots
  inspect(check_fossil_age(slots, 0, 5), content="false")
}

///|
test "superposition adjacency - directly above" {
  let slots : Array[@types.RockKind?] = [
    Some(Sandstone),
    Some(Limestone),
    Some(Shale),
  ]
  // Limestone directly above Sandstone: pos_above=1, pos_below=0 => 1==0+1
  inspect(check_superposition(slots, 1, 0), content="true")
  // Shale directly above Limestone
  inspect(check_superposition(slots, 2, 1), content="true")
  // Shale NOT directly above Sandstone (gap)
  inspect(check_superposition(slots, 2, 0), content="false")
}

///|
test "superposition - wrong order" {
  let slots : Array[@types.RockKind?] = [
    Some(Limestone),
    Some(Sandstone),
    Some(Shale),
  ]
  // Sandstone(pos=1) directly above Limestone(pos=0)
  inspect(check_superposition(slots, 0, 1), content="true")
  // Limestone(pos=0) NOT directly above Sandstone(pos=1)
  inspect(check_superposition(slots, 1, 0), content="false")
}

///|
test "dating position check" {
  let slots : Array[@types.RockKind?] = [
    Some(Granite),
    Some(Shale),
    Some(Sandstone),
    Some(Limestone),
  ]
  // Granite at slot 0
  inspect(check_dating(slots, 3, 0), content="true")
  // Sandstone at slot 2
  inspect(check_dating(slots, 0, 2), content="true")
  // Granite NOT at slot 1
  inspect(check_dating(slots, 3, 1), content="false")
}

///|
test "dating - missing rock" {
  let slots : Array[@types.RockKind?] = [Some(Sandstone), None]
  // Coal not placed
  inspect(check_dating(slots, 5, 0), content="false")
}

///|
test "intrusion rule - intruder above host" {
  let slots : Array[@types.RockKind?] = [
    Some(Sandstone),
    Some(Limestone),
    Some(Basalt),
    Some(Shale),
  ]
  // Basalt(pos=2) intrudes into Sandstone(pos=0): intruder above host
  inspect(check_intrusion(slots, 4, 0), content="true")
  // Sandstone(pos=0) does NOT intrude into Basalt(pos=2)
  inspect(check_intrusion(slots, 0, 4), content="false")
}

///|
test "unconformity gap check - not adjacent" {
  let slots : Array[@types.RockKind?] = [
    Some(Chalk),
    Some(Sandstone),
    Some(Shale),
    Some(Limestone),
  ]
  // Chalk(pos=0) and Shale(pos=2): not adjacent (diff=2)
  inspect(check_unconformity(slots, 6, 2), content="true")
  // Chalk(pos=0) and Sandstone(pos=1): adjacent (diff=1)
  inspect(check_unconformity(slots, 6, 0), content="false")
}

///|
test "unconformity - adjacent returns false" {
  let slots : Array[@types.RockKind?] = [Some(Chalk), Some(Shale)]
  // Adjacent (diff=1), so unconformity NOT satisfied
  inspect(check_unconformity(slots, 6, 2), content="false")
  // With gap
  let slots2 : Array[@types.RockKind?] = [
    Some(Chalk),
    Some(Sandstone),
    Some(Shale),
  ]
  // diff=2, so unconformity satisfied
  inspect(check_unconformity(slots2, 6, 2), content="true")
}

///|
test "validate all clues" {
  // Correct arrangement: Granite(bottom), Shale, Sandstone, Limestone(top)
  let slots : Array[@types.RockKind?] = [
    Some(Granite),
    Some(Shale),
    Some(Sandstone),
    Some(Limestone),
  ]
  let clues : Array[@types.Clue] = [
    @types.new_clue(Dating, 3, 0, "Granite is the bottom layer"),
    @types.new_clue(
      Superposition, 2, 3, "Shale sits directly above granite",
    ),
    @types.new_clue(FossilAge, 2, 0, "Shale is older than sandstone"),
    @types.new_clue(Dating, 1, 3, "Limestone is the top layer"),
  ]
  let satisfied = validate_all(clues, slots)
  inspect(satisfied, content="4")
  inspect(all_satisfied(clues), content="true")
}

///|
test "validate all - partial satisfaction" {
  // Wrong arrangement
  let slots : Array[@types.RockKind?] = [
    Some(Limestone),
    Some(Granite),
    Some(Sandstone),
    Some(Shale),
  ]
  let clues : Array[@types.Clue] = [
    @types.new_clue(Dating, 3, 0, "Granite is bottom"),
    @types.new_clue(FossilAge, 2, 0, "Shale is older than sandstone"),
  ]
  let satisfied = validate_all(clues, slots)
  // Granite at pos 1, not 0 => fail
  // Shale at pos 3, Sandstone at pos 2 => Shale > Sandstone, so shale NOT older => fail
  inspect(satisfied, content="0")
  inspect(all_satisfied(clues), content="false")
}

///|
test "check_clue dispatches correctly" {
  let slots : Array[@types.RockKind?] = [
    Some(Sandstone),
    Some(Limestone),
    Some(Basalt),
  ]
  let clue_dating = @types.new_clue(Dating, 0, 0, "Sandstone at bottom")
  inspect(check_clue(clue_dating, slots), content="true")
  let clue_super = @types.new_clue(
    Superposition, 1, 0, "Limestone above sandstone",
  )
  inspect(check_clue(clue_super, slots), content="true")
  let clue_intrusion = @types.new_clue(
    Intrusion, 4, 0, "Basalt intrudes sandstone",
  )
  inspect(check_clue(clue_intrusion, slots), content="true")
}

///|
test "find_rock_slot" {
  let slots : Array[@types.RockKind?] = [
    Some(Granite),
    None,
    Some(Sandstone),
  ]
  inspect(@types.find_rock_slot(slots, Granite), content="0")
  inspect(@types.find_rock_slot(slots, Sandstone), content="2")
  inspect(@types.find_rock_slot(slots, Coal), content="-1")
}

///|
test "count_filled_slots and all_slots_filled" {
  let slots : Array[@types.RockKind?] = [Some(Granite), None, Some(Sandstone)]
  inspect(@types.count_filled_slots(slots), content="2")
  inspect(@types.all_slots_filled(slots), content="false")
  let full : Array[@types.RockKind?] = [
    Some(Granite),
    Some(Shale),
    Some(Sandstone),
  ]
  inspect(@types.count_filled_slots(full), content="3")
  inspect(@types.all_slots_filled(full), content="true")
}
