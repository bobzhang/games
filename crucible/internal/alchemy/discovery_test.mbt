///|
test "recipe book initialization" {
  let book : Array[@types.Recipe] = []
  init_recipe_book(book)
  // Should have 24 entries (12 reactions * 2 directions)
  assert_eq(book.length(), 24)
  // All should be undiscovered
  for i in 0..<book.length() {
    assert_eq(book[i].discovered, false)
  }
}

///|
test "discover new reaction returns true" {
  let book : Array[@types.Recipe] = []
  init_recipe_book(book)
  let is_new = discover_reaction(
    book,
    @types.Fire,
    @types.Water,
    @types.Transform(@types.Steam),
  )
  assert_eq(is_new, true)
}

///|
test "discover same reaction twice returns false second time" {
  let book : Array[@types.Recipe] = []
  init_recipe_book(book)
  let first = discover_reaction(
    book,
    @types.Fire,
    @types.Water,
    @types.Transform(@types.Steam),
  )
  assert_eq(first, true)
  let second = discover_reaction(
    book,
    @types.Fire,
    @types.Water,
    @types.Transform(@types.Steam),
  )
  assert_eq(second, false)
}

///|
test "count discovered" {
  let book : Array[@types.Recipe] = []
  init_recipe_book(book)
  assert_eq(count_discovered(book), 0)
  // Discover fire+water in both directions
  ignore(
    discover_reaction(
      book,
      @types.Fire,
      @types.Water,
      @types.Transform(@types.Steam),
    ),
  )
  ignore(
    discover_reaction(
      book,
      @types.Water,
      @types.Fire,
      @types.Transform(@types.Steam),
    ),
  )
  // Should count as 1 unique reaction
  assert_eq(count_discovered(book), 1)
}

///|
test "get discovered recipes deduplicates" {
  let book : Array[@types.Recipe] = []
  init_recipe_book(book)
  // Discover both directions
  ignore(
    discover_reaction(
      book,
      @types.Fire,
      @types.Water,
      @types.Transform(@types.Steam),
    ),
  )
  ignore(
    discover_reaction(
      book,
      @types.Water,
      @types.Fire,
      @types.Transform(@types.Steam),
    ),
  )
  let discovered = get_discovered_recipes(book)
  // Should have exactly 1 entry (deduplicated)
  assert_eq(discovered.length(), 1)
}
