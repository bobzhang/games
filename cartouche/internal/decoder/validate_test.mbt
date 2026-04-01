///|
test "count_correct" {
  let current = @types.new_mapping()
  let solution = @types.new_mapping()
  @types.mapping_set(solution, Circle, 0)
  @types.mapping_set(solution, Triangle, 1)
  @types.mapping_set(solution, Square, 2)
  // No mappings yet
  inspect(@decoder.count_correct(current, solution), content="0")
  // One correct
  @types.mapping_set(current, Circle, 0)
  inspect(@decoder.count_correct(current, solution), content="1")
  // One correct, one wrong
  @types.mapping_set(current, Triangle, 5)
  inspect(@decoder.count_correct(current, solution), content="1")
  // Two correct
  @types.mapping_set(current, Triangle, 1)
  inspect(@decoder.count_correct(current, solution), content="2")
}

///|
test "count_wrong" {
  let current = @types.new_mapping()
  let solution = @types.new_mapping()
  @types.mapping_set(solution, Circle, 0)
  @types.mapping_set(solution, Triangle, 1)
  inspect(@decoder.count_wrong(current, solution), content="0")
  @types.mapping_set(current, Circle, 5) // wrong
  inspect(@decoder.count_wrong(current, solution), content="1")
  @types.mapping_set(current, Triangle, 1) // correct
  inspect(@decoder.count_wrong(current, solution), content="1")
}

///|
test "is_fully_decoded" {
  let inscription = @types.new_inscription([
    @types.make_symbol(Circle),
    @types.make_symbol(Triangle),
    @types.make_space(),
    @types.make_symbol(Circle),
  ])
  let current = @types.new_mapping()
  let solution = @types.new_mapping()
  @types.mapping_set(solution, Circle, 0)
  @types.mapping_set(solution, Triangle, 1)
  // Not decoded
  inspect(
    @decoder.is_fully_decoded(current, solution, inscription),
    content="false",
  )
  // Partially decoded
  @types.mapping_set(current, Circle, 0)
  inspect(
    @decoder.is_fully_decoded(current, solution, inscription),
    content="false",
  )
  // Fully decoded
  @types.mapping_set(current, Triangle, 1)
  inspect(
    @decoder.is_fully_decoded(current, solution, inscription),
    content="true",
  )
}

///|
test "check_mapping_correct and wrong" {
  let current = @types.new_mapping()
  let solution = @types.new_mapping()
  @types.mapping_set(solution, Star, 4)
  @types.mapping_set(current, Star, 4)
  inspect(
    @decoder.check_mapping_correct(current, solution, Star),
    content="true",
  )
  inspect(
    @decoder.check_mapping_wrong(current, solution, Star),
    content="false",
  )
  @types.mapping_set(current, Star, 7)
  inspect(
    @decoder.check_mapping_correct(current, solution, Star),
    content="false",
  )
  inspect(@decoder.check_mapping_wrong(current, solution, Star), content="true")
}

///|
test "compute_stars" {
  let solution = @types.new_mapping()
  let given = @types.new_mapping()
  let tablet : @types.Tablet = {
    inscription: @types.new_inscription([]),
    solution_mapping: solution,
    given_mapping: given,
    theme_name: "Test",
    par_guesses: 5,
    tier: Fragments,
  }
  // Over par with wrongs -> 1 star
  inspect(@decoder.compute_stars(tablet, 8, 2), content="1")
  // At par with wrongs -> 2 stars
  inspect(@decoder.compute_stars(tablet, 5, 1), content="2")
  // Under par with wrongs -> 2 stars
  inspect(@decoder.compute_stars(tablet, 3, 1), content="2")
  // At par no wrongs -> 3 stars
  inspect(@decoder.compute_stars(tablet, 5, 0), content="3")
  // Under par no wrongs -> 3 stars
  inspect(@decoder.compute_stars(tablet, 3, 0), content="3")
}

///|
test "count_mapped" {
  let m = @types.new_mapping()
  inspect(@decoder.count_mapped(m), content="0")
  @types.mapping_set(m, Circle, 0)
  @types.mapping_set(m, Star, 4)
  inspect(@decoder.count_mapped(m), content="2")
}
