///|
test "find_start_codon at beginning" {
  let seq : Array[@types.Base] = [A, T, G, A, A, A]
  inspect(@dna.find_start_codon(seq), content="0")
}

///|
test "find_start_codon in middle" {
  let seq : Array[@types.Base] = [C, C, C, A, T, G, A, A, A]
  inspect(@dna.find_start_codon(seq), content="3")
}

///|
test "find_start_codon returns first occurrence" {
  let seq : Array[@types.Base] = [A, T, G, A, T, G]
  inspect(@dna.find_start_codon(seq), content="0")
}

///|
test "find_start_codon no ATG at all" {
  let seq : Array[@types.Base] = [A, A, A, T, T, T, G, G, G]
  inspect(@dna.find_start_codon(seq), content="-1")
}

///|
test "find_start_codon too short" {
  let seq : Array[@types.Base] = [A, T]
  inspect(@dna.find_start_codon(seq), content="-1")
}

///|
test "find_start_codon exactly three bases" {
  let seq : Array[@types.Base] = [A, T, G]
  inspect(@dna.find_start_codon(seq), content="0")
}

///|
test "find_start_codon not ATG (partial match AT)" {
  let seq : Array[@types.Base] = [A, T, C, G, A, T]
  inspect(@dna.find_start_codon(seq), content="-1")
}

///|
test "find_stop_codon from start" {
  let seq : Array[@types.Base] = [A, T, G, T, G, A]
  inspect(@dna.find_stop_codon(seq, 3), content="3")
}

///|
test "find_stop_codon skips non-stop codons" {
  // Seq: ATG ATG AAA TGA -- from pos 3, reads in 3-step: pos 3=ATG, pos 6=AAA, pos 9=TGA
  let seq : Array[@types.Base] = [A, T, G, A, T, G, A, A, A, T, G, A]
  inspect(@dna.find_stop_codon(seq, 3), content="9")
}

///|
test "find_stop_codon not found" {
  let seq : Array[@types.Base] = [A, T, G, A, A, A, G, G, G]
  inspect(@dna.find_stop_codon(seq, 3), content="-1")
}

///|
test "get_codon_groups empty on no start" {
  let seq : Array[@types.Base] = [G, G, G, C, C, C]
  let groups = @dna.get_codon_groups(seq)
  inspect(groups.length(), content="0")
}

///|
test "get_codon_groups single start codon only" {
  let seq : Array[@types.Base] = [A, T, G]
  let groups = @dna.get_codon_groups(seq)
  inspect(groups.length(), content="1")
  inspect(groups[0].trait_, content="Start")
}

///|
test "get_codon_groups start then stop" {
  let seq : Array[@types.Base] = [A, T, G, T, G, A]
  let groups = @dna.get_codon_groups(seq)
  inspect(groups.length(), content="2")
  inspect(groups[0].trait_, content="Start")
  inspect(groups[1].trait_, content="Stop")
}

///|
test "get_codon_groups with traits" {
  let seq : Array[@types.Base] = [A, T, G, A, A, A, G, G, G, T, T, T, T, G, A]
  let groups = @dna.get_codon_groups(seq)
  inspect(groups.length(), content="5")
  inspect(groups[0].trait_, content="Start")
  inspect(groups[1].trait_, content="Strength")
  inspect(groups[2].trait_, content="Shield")
  inspect(groups[3].trait_, content="Speed")
  inspect(groups[4].trait_, content="Stop")
}

///|
test "get_codon_groups stops at first stop codon" {
  let seq : Array[@types.Base] = [A, T, G, T, G, A, A, A, A]
  let groups = @dna.get_codon_groups(seq)
  inspect(groups.length(), content="2")
  inspect(groups[1].trait_, content="Stop")
}

///|
test "get_codon_groups with neutral codons" {
  let seq : Array[@types.Base] = [A, T, G, A, A, T, T, G, A]
  let groups = @dna.get_codon_groups(seq)
  inspect(groups.length(), content="3")
  inspect(groups[1].trait_, content="Neutral")
  inspect(groups[2].trait_, content="Stop")
}

///|
test "get_codon_groups bases array correct" {
  let seq : Array[@types.Base] = [A, T, G, G, A, T, T, G, A]
  let groups = @dna.get_codon_groups(seq)
  assert_eq(groups[0].bases.length(), 3)
  assert_eq(groups[0].bases[0], A)
  assert_eq(groups[0].bases[1], T)
  assert_eq(groups[0].bases[2], G)
  assert_eq(groups[1].bases[0], G)
  assert_eq(groups[1].bases[1], A)
  assert_eq(groups[1].bases[2], T)
}

///|
test "get_codon_groups with prefix before ATG" {
  let seq : Array[@types.Base] = [C, C, A, T, G, A, A, A, T, G, A]
  let groups = @dna.get_codon_groups(seq)
  inspect(groups.length(), content="3")
  inspect(groups[0].trait_, content="Start")
  inspect(groups[1].trait_, content="Strength")
  inspect(groups[2].trait_, content="Stop")
}

///|
test "read_and_compare with empty sequence" {
  let seq : Array[@types.Base] = []
  let target : Array[@types.Trait] = [Start, Stop]
  let (traits, matched) = @dna.read_and_compare(seq, target)
  inspect(traits.length(), content="0")
  inspect(matched, content="false")
}

///|
test "read_and_compare with no stop codon" {
  let seq : Array[@types.Base] = [A, T, G, A, A, A]
  let target : Array[@types.Trait] = [Start, Strength, Stop]
  let (traits, matched) = @dna.read_and_compare(seq, target)
  inspect(traits.length(), content="2")
  inspect(matched, content="false")
}

///|
test "read_and_compare with multiple ATGs" {
  // read_sequence finds the first ATG
  let seq : Array[@types.Base] = [A, T, G, A, T, G, T, G, A]
  let target : Array[@types.Trait] = [Start, Start, Stop]
  let (traits, matched) = @dna.read_and_compare(seq, target)
  // First ATG at pos 0, then ATG at pos 3, then TGA at pos 6
  inspect(traits.length(), content="3")
  inspect(matched, content="true")
}

///|
test "count_matching_traits empty arrays" {
  let a : Array[@types.Trait] = []
  let b : Array[@types.Trait] = []
  inspect(@dna.count_matching_traits(a, b), content="0")
}

///|
test "count_matching_traits different lengths" {
  let a : Array[@types.Trait] = [Start, Strength]
  let b : Array[@types.Trait] = [Start, Strength, Stop]
  // Only compares up to shorter length
  inspect(@dna.count_matching_traits(a, b), content="2")
}

///|
test "count_matching_traits no matches" {
  let a : Array[@types.Trait] = [Start, Strength, Stop]
  let b : Array[@types.Trait] = [Stop, Speed, Start]
  inspect(@dna.count_matching_traits(a, b), content="0")
}

///|
test "find_start_codon single base" {
  let seq : Array[@types.Base] = [A]
  inspect(@dna.find_start_codon(seq), content="-1")
}

///|
test "get_codon_groups incomplete trailing codon ignored" {
  // After ATG, only 2 bases left (not enough for a codon)
  let seq : Array[@types.Base] = [A, T, G, A, A]
  let groups = @dna.get_codon_groups(seq)
  inspect(groups.length(), content="1")
  inspect(groups[0].trait_, content="Start")
}
