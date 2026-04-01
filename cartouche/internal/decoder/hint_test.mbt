///|
test "find_hint returns unmapped symbol" {
  let inscription = @types.new_inscription([
    @types.make_symbol(Circle),
    @types.make_symbol(Triangle),
    @types.make_symbol(Circle),
  ])
  let solution = @types.new_mapping()
  @types.mapping_set(solution, Circle, 0)
  @types.mapping_set(solution, Triangle, 1)
  let given = @types.new_mapping()
  let tablet : @types.Tablet = {
    inscription,
    solution_mapping: solution,
    given_mapping: given,
    theme_name: "Test",
    par_guesses: 5,
    tier: Fragments,
  }
  let current = @types.new_mapping()
  let hint = @decoder.find_hint(tablet, current)
  // Circle appears twice so it should be the hint
  match hint {
    Some(sym) => inspect(@types.symbol_index(sym), content="0")
    None => inspect(false, content="true")
  }
}

///|
test "find_hint skips given symbols" {
  let inscription = @types.new_inscription([
    @types.make_symbol(Circle),
    @types.make_symbol(Triangle),
  ])
  let solution = @types.new_mapping()
  @types.mapping_set(solution, Circle, 0)
  @types.mapping_set(solution, Triangle, 1)
  let given = @types.new_mapping()
  @types.mapping_set(given, Circle, 0) // Circle is given
  let tablet : @types.Tablet = {
    inscription,
    solution_mapping: solution,
    given_mapping: given,
    theme_name: "Test",
    par_guesses: 5,
    tier: Fragments,
  }
  let current = @types.copy_mapping(given)
  let hint = @decoder.find_hint(tablet, current)
  // Should suggest Triangle (not Circle which is given)
  match hint {
    Some(sym) => inspect(sym, content="Triangle")
    None => inspect(false, content="true")
  }
}

///|
test "find_hint returns None when all mapped" {
  let inscription = @types.new_inscription([@types.make_symbol(Circle)])
  let solution = @types.new_mapping()
  @types.mapping_set(solution, Circle, 0)
  let given = @types.new_mapping()
  let tablet : @types.Tablet = {
    inscription,
    solution_mapping: solution,
    given_mapping: given,
    theme_name: "Test",
    par_guesses: 5,
    tier: Fragments,
  }
  let current = @types.new_mapping()
  @types.mapping_set(current, Circle, 0)
  let hint = @decoder.find_hint(tablet, current)
  inspect(hint, content="None")
}

///|
test "get_hint_letter" {
  let solution = @types.new_mapping()
  @types.mapping_set(solution, Star, 4)
  let given = @types.new_mapping()
  let tablet : @types.Tablet = {
    inscription: @types.new_inscription([]),
    solution_mapping: solution,
    given_mapping: given,
    theme_name: "Test",
    par_guesses: 5,
    tier: Fragments,
  }
  inspect(@decoder.get_hint_letter(tablet, Star), content="4")
}
