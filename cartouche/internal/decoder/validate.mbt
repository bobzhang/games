///|
pub fn count_correct(
  current : @types.Mapping,
  solution : @types.Mapping,
) -> Int {
  let mut count = 0
  for i in 0..<@types.symbol_count {
    if current.values[i] >= 0 && current.values[i] == solution.values[i] {
      count += 1
    }
  }
  count
}

///|
pub fn count_wrong(current : @types.Mapping, solution : @types.Mapping) -> Int {
  let mut count = 0
  for i in 0..<@types.symbol_count {
    if current.values[i] >= 0 &&
      solution.values[i] >= 0 &&
      current.values[i] != solution.values[i] {
      count += 1
    }
  }
  count
}

///|
pub fn count_mapped(current : @types.Mapping) -> Int {
  let mut count = 0
  for i in 0..<@types.symbol_count {
    if current.values[i] >= 0 {
      count += 1
    }
  }
  count
}

///|
pub fn is_fully_decoded(
  current : @types.Mapping,
  solution : @types.Mapping,
  inscription : @types.Inscription,
) -> Bool {
  let needed = @types.get_inscription_symbols_unique(inscription)
  for i in 0..<needed.length() {
    let si = @types.symbol_index(needed[i])
    if current.values[si] < 0 || current.values[si] != solution.values[si] {
      return false
    }
  }
  true
}

///|
pub fn check_mapping_correct(
  current : @types.Mapping,
  solution : @types.Mapping,
  sym : @types.Symbol,
) -> Bool {
  let si = @types.symbol_index(sym)
  current.values[si] >= 0 && current.values[si] == solution.values[si]
}

///|
pub fn check_mapping_wrong(
  current : @types.Mapping,
  solution : @types.Mapping,
  sym : @types.Symbol,
) -> Bool {
  let si = @types.symbol_index(sym)
  current.values[si] >= 0 &&
  solution.values[si] >= 0 &&
  current.values[si] != solution.values[si]
}

///|
pub fn compute_stars(
  tablet : @types.Tablet,
  guesses : Int,
  wrong_count : Int,
) -> Int {
  let mut stars = 1
  if guesses <= tablet.par_guesses {
    stars = 2
  }
  if guesses <= tablet.par_guesses && wrong_count == 0 {
    stars = 3
  }
  stars
}
