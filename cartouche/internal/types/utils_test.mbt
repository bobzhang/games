///|
test "symbol_index round-trip" {
  let symbols = @types.all_symbols()
  for i in 0..<symbols.length() {
    let idx = @types.symbol_index(symbols[i])
    inspect(idx, content=i.to_string())
    let sym = @types.symbol_from_index(idx)
    inspect(sym == symbols[i], content="true")
  }
}

///|
test "letter_from_index and letter_index" {
  for i in 0..<20 {
    let letter = @types.letter_from_index(i)
    let idx = @types.letter_index(letter)
    inspect(idx, content=i.to_string())
  }
  inspect(@types.letter_from_index(99), content="?")
  inspect(@types.letter_index("Z"), content="-1")
}

///|
test "new_mapping all unmapped" {
  let m = @types.new_mapping()
  for i in 0..<20 {
    inspect(m.values[i], content="-1")
  }
}

///|
test "mapping set and get" {
  let m = @types.new_mapping()
  @types.mapping_set(m, Circle, 0)
  inspect(@types.mapping_get(m, Circle), content="0")
  inspect(@types.mapping_get(m, Triangle), content="-1")
  @types.mapping_set(m, Triangle, 5)
  inspect(@types.mapping_get(m, Triangle), content="5")
}

///|
test "mapping clear" {
  let m = @types.new_mapping()
  @types.mapping_set(m, Star, 4)
  inspect(@types.mapping_get(m, Star), content="4")
  @types.mapping_clear(m, Star)
  inspect(@types.mapping_get(m, Star), content="-1")
}

///|
test "copy_mapping is independent" {
  let m = @types.new_mapping()
  @types.mapping_set(m, Circle, 0)
  let m2 = @types.copy_mapping(m)
  @types.mapping_set(m2, Circle, 5)
  inspect(@types.mapping_get(m, Circle), content="0")
  inspect(@types.mapping_get(m2, Circle), content="5")
}

///|
test "is_letter_used" {
  let m = @types.new_mapping()
  inspect(@types.is_letter_used(m, 0), content="false")
  @types.mapping_set(m, Circle, 0)
  inspect(@types.is_letter_used(m, 0), content="true")
  inspect(@types.is_letter_used(m, 1), content="false")
}

///|
test "find_symbol_for_letter" {
  let m = @types.new_mapping()
  @types.mapping_set(m, Diamond, 3)
  inspect(@types.find_symbol_for_letter(m, 3), content="3")
  inspect(@types.find_symbol_for_letter(m, 0), content="-1")
}

///|
test "decode_inscription partial" {
  let inscription = @types.new_inscription(
    [
      @types.make_symbol(Circle),
      @types.make_symbol(Triangle),
      @types.make_space(),
      @types.make_symbol(Square),
    ],
  )
  let m = @types.new_mapping()
  @types.mapping_set(m, Circle, 0) // A
  // Triangle unmapped, Square unmapped
  let decoded = @types.decode_inscription(inscription, m)
  inspect(decoded, content="A_ _")
}

///|
test "decode_inscription full" {
  let inscription = @types.new_inscription(
    [
      @types.make_symbol(Circle),
      @types.make_symbol(Triangle),
      @types.make_space(),
      @types.make_symbol(Square),
    ],
  )
  let m = @types.new_mapping()
  @types.mapping_set(m, Circle, 0) // A
  @types.mapping_set(m, Triangle, 1) // B
  @types.mapping_set(m, Square, 2) // C
  let decoded = @types.decode_inscription(inscription, m)
  inspect(decoded, content="AB C")
}

///|
test "get_inscription_symbols_unique" {
  let inscription = @types.new_inscription(
    [
      @types.make_symbol(Circle),
      @types.make_symbol(Triangle),
      @types.make_space(),
      @types.make_symbol(Circle),
      @types.make_symbol(Star),
    ],
  )
  let unique = @types.get_inscription_symbols_unique(inscription)
  inspect(unique.length(), content="3")
}

///|
test "new_game initial state" {
  let game = @types.new_game()
  inspect(game.screen, content="Title")
  inspect(game.scores.length(), content="20")
  inspect(game.guesses, content="0")
  inspect(game.wrong_count, content="0")
}

///|
test "tier operations" {
  inspect(@types.tier_tablet_offset(Fragments), content="0")
  inspect(@types.tier_tablet_offset(Scrolls), content="7")
  inspect(@types.tier_tablet_offset(Monuments), content="14")
  inspect(@types.tier_tablet_count(Fragments), content="7")
  inspect(@types.tier_tablet_count(Scrolls), content="7")
  inspect(@types.tier_tablet_count(Monuments), content="6")
}

///|
test "is_given_symbol" {
  let m = @types.new_mapping()
  @types.mapping_set(m, Circle, 0)
  let solution = @types.new_mapping()
  @types.mapping_set(solution, Circle, 0)
  @types.mapping_set(solution, Triangle, 1)
  let tablet : @types.Tablet = {
    inscription: @types.new_inscription([]),
    solution_mapping: solution,
    given_mapping: m,
    theme_name: "Test",
    par_guesses: 5,
    tier: Fragments,
  }
  inspect(@types.is_given_symbol(tablet, Circle), content="true")
  inspect(@types.is_given_symbol(tablet, Triangle), content="false")
}

///|
test "sinf and cosf" {
  inspect(@types.sinf(0.0), content="0")
  inspect(@types.cosf(0.0), content="1")
}

///|
test "absf" {
  inspect(@types.absf(5.0), content="5")
  inspect(@types.absf(-5.0), content="5")
}

///|
test "clampf" {
  inspect(@types.clampf(0.5, 0.0, 1.0), content="0.5")
  inspect(@types.clampf(-1.0, 0.0, 1.0), content="0")
  inspect(@types.clampf(2.0, 0.0, 1.0), content="1")
}
