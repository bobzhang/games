///|
/// Initialize the recipe book with all possible reactions (undiscovered).
pub fn init_recipe_book(book : Array[@types.Recipe]) -> Unit {
  book.clear()
  let reactions = all_reactions()
  for i in 0..<reactions.length() {
    let (substance, input, output) = reactions[i]
    book.push({
      discovered: false,
      input,
      substance,
      output: Transform(output),
    })
  }
}

///|
/// Mark a reaction as discovered in the recipe book.
/// Returns true if this was a new discovery.
pub fn discover_reaction(
  book : Array[@types.Recipe],
  substance : @types.Element,
  input : @types.Element,
  result : @types.ReactionResult,
) -> Bool {
  ignore(result)
  for i in 0..<book.length() {
    let r = book[i]
    if r.substance == substance && r.input == input {
      if !r.discovered {
        r.discovered = true
        return true
      }
      return false
    }
  }
  false
}

///|
/// Count how many unique reactions have been discovered.
/// We count unique outputs, not direction variants.
pub fn count_discovered(book : Array[@types.Recipe]) -> Int {
  let mut count = 0
  for i in 0..<book.length() {
    if book[i].discovered {
      count += 1
    }
  }
  // Each reaction appears twice (both directions), count unique pairs
  count / 2
}

///|
/// Count total unique reactions possible.
pub fn count_total() -> Int {
  @types.total_reactions
}

///|
/// Get all discovered recipes for display (deduplicated).
pub fn get_discovered_recipes(
  book : Array[@types.Recipe],
) -> Array[@types.Recipe] {
  let result : Array[@types.Recipe] = []
  let seen : Array[String] = []
  for i in 0..<book.length() {
    let r = book[i]
    if r.discovered {
      let key = make_recipe_key(r.substance, r.input)
      let mut found = false
      for j in 0..<seen.length() {
        if seen[j] == key {
          found = true
          break
        }
      }
      if !found {
        seen.push(key)
        result.push(r)
      }
    }
  }
  result
}

///|
/// Get all recipes (for display, deduplicated).
pub fn get_all_recipes_deduped(
  book : Array[@types.Recipe],
) -> Array[@types.Recipe] {
  let result : Array[@types.Recipe] = []
  let seen : Array[String] = []
  for i in 0..<book.length() {
    let r = book[i]
    let key = make_recipe_key(r.substance, r.input)
    let mut found = false
    for j in 0..<seen.length() {
      if seen[j] == key {
        found = true
        break
      }
    }
    if !found {
      seen.push(key)
      result.push(r)
    }
  }
  result
}

///|
fn make_recipe_key(a : @types.Element, b : @types.Element) -> String {
  let na = @types.element_name(a)
  let nb = @types.element_name(b)
  if na < nb {
    na + "+" + nb
  } else {
    nb + "+" + na
  }
}
