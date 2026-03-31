///|
test "cut removes base at position" {
  let seq : Array[@types.Base] = [A, T, G, C]
  let result = @dna.cut(seq, 2)
  inspect(result.length(), content="3")
  inspect(result[0], content="A")
  inspect(result[1], content="T")
  inspect(result[2], content="C")
}

///|
test "cut at start" {
  let seq : Array[@types.Base] = [A, T, G]
  let result = @dna.cut(seq, 0)
  inspect(result.length(), content="2")
  inspect(result[0], content="T")
  inspect(result[1], content="G")
}

///|
test "cut at end" {
  let seq : Array[@types.Base] = [A, T, G]
  let result = @dna.cut(seq, 2)
  inspect(result.length(), content="2")
  inspect(result[0], content="A")
  inspect(result[1], content="T")
}

///|
test "cut out of bounds" {
  let seq : Array[@types.Base] = [A, T, G]
  let result = @dna.cut(seq, 5)
  inspect(result.length(), content="3")
}

///|
test "insert adds base at position" {
  let seq : Array[@types.Base] = [A, T, G]
  let result = @dna.insert(seq, 1, C)
  inspect(result.length(), content="4")
  inspect(result[0], content="A")
  inspect(result[1], content="C")
  inspect(result[2], content="T")
  inspect(result[3], content="G")
}

///|
test "insert at start" {
  let seq : Array[@types.Base] = [A, T]
  let result = @dna.insert(seq, 0, G)
  inspect(result.length(), content="3")
  inspect(result[0], content="G")
  inspect(result[1], content="A")
  inspect(result[2], content="T")
}

///|
test "insert at end" {
  let seq : Array[@types.Base] = [A, T]
  let result = @dna.insert(seq, 2, C)
  inspect(result.length(), content="3")
  inspect(result[0], content="A")
  inspect(result[1], content="T")
  inspect(result[2], content="C")
}

///|
test "duplicate copies range" {
  let seq : Array[@types.Base] = [A, T, G, C]
  let result = @dna.duplicate(seq, 1, 3)
  inspect(result.length(), content="6")
  inspect(result[0], content="A")
  inspect(result[1], content="T")
  inspect(result[2], content="G")
  inspect(result[3], content="T")
  inspect(result[4], content="G")
  inspect(result[5], content="C")
}

///|
test "duplicate full sequence" {
  let seq : Array[@types.Base] = [A, T]
  let result = @dna.duplicate(seq, 0, 2)
  inspect(result.length(), content="4")
  inspect(result[0], content="A")
  inspect(result[1], content="T")
  inspect(result[2], content="A")
  inspect(result[3], content="T")
}

///|
test "invert reverses range" {
  let seq : Array[@types.Base] = [A, T, G, C]
  let result = @dna.invert(seq, 0, 4)
  inspect(result.length(), content="4")
  inspect(result[0], content="C")
  inspect(result[1], content="G")
  inspect(result[2], content="T")
  inspect(result[3], content="A")
}

///|
test "invert partial range" {
  let seq : Array[@types.Base] = [A, T, G, C]
  let result = @dna.invert(seq, 1, 3)
  inspect(result.length(), content="4")
  inspect(result[0], content="A")
  inspect(result[1], content="G")
  inspect(result[2], content="T")
  inspect(result[3], content="C")
}

///|
test "invert single element" {
  let seq : Array[@types.Base] = [A, T, G]
  let result = @dna.invert(seq, 1, 2)
  inspect(result.length(), content="3")
  inspect(result[0], content="A")
  inspect(result[1], content="T")
  inspect(result[2], content="G")
}

///|
test "delete removes range" {
  let seq : Array[@types.Base] = [A, T, G, C, A]
  let result = @dna.delete(seq, 1, 3)
  inspect(result.length(), content="3")
  inspect(result[0], content="A")
  inspect(result[1], content="C")
  inspect(result[2], content="A")
}

///|
test "delete from start" {
  let seq : Array[@types.Base] = [A, T, G, C]
  let result = @dna.delete(seq, 0, 2)
  inspect(result.length(), content="2")
  inspect(result[0], content="G")
  inspect(result[1], content="C")
}

///|
test "delete to end" {
  let seq : Array[@types.Base] = [A, T, G, C]
  let result = @dna.delete(seq, 2, 4)
  inspect(result.length(), content="2")
  inspect(result[0], content="A")
  inspect(result[1], content="T")
}

///|
test "get_removed extracts range" {
  let seq : Array[@types.Base] = [A, T, G, C]
  let removed = @dna.get_removed(seq, 1, 3)
  inspect(removed.length(), content="2")
  inspect(removed[0], content="T")
  inspect(removed[1], content="G")
}

///|
test "read_and_compare match" {
  let seq : Array[@types.Base] = [A, T, G, A, A, A, T, G, A]
  let target : Array[@types.Trait] = [Start, Strength, Stop]
  let (_, matched) = @dna.read_and_compare(seq, target)
  inspect(matched, content="true")
}

///|
test "read_and_compare no match" {
  let seq : Array[@types.Base] = [A, T, G, T, T, T, T, G, A]
  let target : Array[@types.Trait] = [Start, Strength, Stop]
  let (_, matched) = @dna.read_and_compare(seq, target)
  inspect(matched, content="false")
}

///|
test "find_start_codon" {
  let seq : Array[@types.Base] = [C, C, A, T, G, A, A, A]
  inspect(@dna.find_start_codon(seq), content="2")
}

///|
test "find_start_codon not found" {
  let seq : Array[@types.Base] = [A, A, A, T, T, T]
  inspect(@dna.find_start_codon(seq), content="-1")
}

///|
test "count_matching_traits" {
  let a : Array[@types.Trait] = [Start, Strength, Stop]
  let b : Array[@types.Trait] = [Start, Speed, Stop]
  inspect(@dna.count_matching_traits(a, b), content="2")
}

///|
test "count_matching_traits all match" {
  let a : Array[@types.Trait] = [Start, Strength, Stop]
  let b : Array[@types.Trait] = [Start, Strength, Stop]
  inspect(@dna.count_matching_traits(a, b), content="3")
}

///|
test "get_codon_groups" {
  let seq : Array[@types.Base] = [A, T, G, A, A, A, T, G, A]
  let groups = @dna.get_codon_groups(seq)
  inspect(groups.length(), content="3")
  inspect(groups[0].trait_, content="Start")
  inspect(groups[1].trait_, content="Strength")
  inspect(groups[2].trait_, content="Stop")
}

///|
test "edit count tracking through cut" {
  let seq : Array[@types.Base] = [A, T, G, C, A, A, A, T, G, A]
  // Cut at position 3 (the extra C)
  let result = @dna.cut(seq, 3)
  inspect(result.length(), content="9")
  let read = @types.read_sequence(result)
  inspect(read.traits.length(), content="3")
  inspect(read.traits[1], content="Strength")
}

///|
test "edit count tracking through insert" {
  let seq : Array[@types.Base] = [A, T, G, A, A, T, G, A]
  // Insert A at position 5 to make AAA
  let result = @dna.insert(seq, 5, A)
  inspect(result.length(), content="9")
  let read = @types.read_sequence(result)
  inspect(read.traits[1], content="Strength")
}
