///|
pub fn read_and_compare(
  seq : Array[@types.Base],
  target : Array[@types.Trait],
) -> (Array[@types.Trait], Bool) {
  let result = @types.read_sequence(seq)
  let matched = @types.traits_match(result.traits, target)
  (result.traits, matched)
}

///|
pub fn find_start_codon(seq : Array[@types.Base]) -> Int {
  @types.find_start_codon(seq)
}

///|
pub fn find_stop_codon(seq : Array[@types.Base], from : Int) -> Int {
  let mut pos = from
  while pos + 2 < seq.length() {
    if seq[pos] == T && seq[pos + 1] == G && seq[pos + 2] == A {
      return pos
    }
    pos += 3
  }
  -1
}

///|
pub fn get_codon_groups(seq : Array[@types.Base]) -> Array[@types.CodonResult] {
  let groups : Array[@types.CodonResult] = []
  let start = find_start_codon(seq)
  if start < 0 {
    return groups
  }
  // Add the Start codon
  groups.push({
    trait_: Start,
    bases: [seq[start], seq[start + 1], seq[start + 2]],
  })
  let mut pos = start + 3
  while pos + 2 < seq.length() {
    let tr = @types.codon_to_trait(seq[pos], seq[pos + 1], seq[pos + 2])
    groups.push({ trait_: tr, bases: [seq[pos], seq[pos + 1], seq[pos + 2]] })
    if tr == Stop {
      break
    }
    pos += 3
  }
  groups
}

///|
pub fn count_matching_traits(
  produced : Array[@types.Trait],
  target : Array[@types.Trait],
) -> Int {
  let mut count = 0
  let len = if produced.length() < target.length() {
    produced.length()
  } else {
    target.length()
  }
  for i in 0..<len {
    if produced[i] == target[i] {
      count += 1
    }
  }
  count
}
