///|
test "mapping assign and undo" {
  let m = @types.new_mapping()
  // Assign A->B (cipher 0 -> plain 1)
  let entry = @types.assign_mapping(m, 0, 1)
  inspect(m.cipher_to_plain[0], content="1")
  inspect(m.plain_used[1], content="true")
  // Undo
  @types.undo_mapping(m, entry)
  inspect(m.cipher_to_plain[0], content="-1")
  inspect(m.plain_used[1], content="false")
}

///|
test "mapping displacement" {
  let m = @types.new_mapping()
  // Assign cipher A -> plain X
  let _ = @types.assign_mapping(m, 0, 23)
  inspect(m.cipher_to_plain[0], content="23")
  // Now assign cipher B -> plain X (should displace A)
  let entry2 = @types.assign_mapping(m, 1, 23)
  inspect(m.cipher_to_plain[1], content="23")
  inspect(m.cipher_to_plain[0], content="-1") // displaced
  // Undo should restore both
  @types.undo_mapping(m, entry2)
  inspect(m.cipher_to_plain[1], content="-1")
  inspect(m.cipher_to_plain[0], content="23")
}

///|
test "mapping complete" {
  let m = @types.new_mapping()
  inspect(@types.mapping_complete(m), content="false")
  for i in 0..<26 {
    let _ = @types.assign_mapping(m, i, i)
  }
  inspect(@types.mapping_complete(m), content="true")
}

///|
test "char_to_idx and idx_to_char" {
  inspect(@types.char_to_idx('A'), content="0")
  inspect(@types.char_to_idx('Z'), content="25")
  inspect(@types.idx_to_char(0), content="A")
  inspect(@types.idx_to_char(25), content="Z")
}

///|
test "is_upper" {
  inspect(@types.is_upper('A'), content="true")
  inspect(@types.is_upper('Z'), content="true")
  inspect(@types.is_upper(' '), content="false")
}

///|
test "apply_mapping_to_text" {
  let m = @types.new_mapping()
  let _ = @types.assign_mapping(m, 7, 7) // H->H
  let _ = @types.assign_mapping(m, 4, 4) // E->E
  let result = @types.apply_mapping_to_text("HELLO", m)
  // H and E mapped, L and O not
  inspect(result, content="HE___")
}

///|
test "check solution correct" {
  let m = @types.new_mapping()
  // Identity mapping for relevant letters
  // "HI" needs H->H(7->7) and I->I(8->8)
  let _ = @types.assign_mapping(m, 7, 7)
  let _ = @types.assign_mapping(m, 8, 8)
  inspect(@types.check_solution("HI", "HI", m), content="true")
}

///|
test "check solution incomplete" {
  let m = @types.new_mapping()
  inspect(@types.check_solution("HI", "HI", m), content="false")
}

///|
test "count correct" {
  let m = @types.new_mapping()
  let _ = @types.assign_mapping(m, 7, 7) // H->H correct
  let _ = @types.assign_mapping(m, 4, 0) // E->A wrong
  let count = @types.count_correct("HELLO", "HELLO", m)
  inspect(count, content="1") // only H is correct
}

///|
test "count unique letters" {
  inspect(@types.count_unique_letters("HELLO"), content="4") // H E L O
  inspect(@types.count_unique_letters("AAA"), content="1")
  inspect(@types.count_unique_letters("A B C"), content="3")
}

///|
test "calc stars" {
  inspect(@types.calc_stars(5, 10, 0), content="3") // under par, no hints
  inspect(@types.calc_stars(10, 10, 0), content="3") // at par, no hints
  inspect(@types.calc_stars(5, 10, 1), content="2") // under par, with hints
  inspect(@types.calc_stars(15, 10, 0), content="1") // over par
  inspect(@types.calc_stars(15, 10, 1), content="1") // over par with hints
}

///|
test "tier level ranges" {
  let (s1, e1) = @types.tier_level_range(Recruit)
  inspect(s1, content="0")
  inspect(e1, content="7")
  let (s2, e2) = @types.tier_level_range(Agent)
  inspect(s2, content="8")
  inspect(e2, content="16")
  let (s3, e3) = @types.tier_level_range(Cryptographer)
  inspect(s3, content="17")
  inspect(e3, content="24")
}

///|
test "tier for level" {
  inspect(@types.tier_for_level(0), content="Recruit")
  inspect(@types.tier_for_level(7), content="Recruit")
  inspect(@types.tier_for_level(8), content="Agent")
  inspect(@types.tier_for_level(16), content="Agent")
  inspect(@types.tier_for_level(17), content="Cryptographer")
  inspect(@types.tier_for_level(24), content="Cryptographer")
}

///|
test "new game initial state" {
  let game = @types.new_game()
  inspect(game.screen, content="Title")
  inspect(game.swap_count, content="0")
  inspect(game.hints_used, content="0")
  inspect(game.level_scores.length(), content="25")
}

///|
test "reset for level clears state" {
  let game = @types.new_game()
  game.swap_count = 10
  game.hints_used = 3
  let _ = @types.assign_mapping(game.mapping, 0, 1)
  @types.reset_for_level(game)
  inspect(game.swap_count, content="0")
  inspect(game.hints_used, content="0")
  inspect(game.mapping.cipher_to_plain[0], content="-1")
}
