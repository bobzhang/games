///|
test "codon_to_trait ATG = Start" {
  inspect(@types.codon_to_trait(A, T, G), content="Start")
}

///|
test "codon_to_trait TGA = Stop" {
  inspect(@types.codon_to_trait(T, G, A), content="Stop")
}

///|
test "codon_to_trait AAA = Strength" {
  inspect(@types.codon_to_trait(A, A, A), content="Strength")
}

///|
test "codon_to_trait TTT = Speed" {
  inspect(@types.codon_to_trait(T, T, T), content="Speed")
}

///|
test "codon_to_trait GGG = Shield" {
  inspect(@types.codon_to_trait(G, G, G), content="Shield")
}

///|
test "codon_to_trait CCC = Stealth" {
  inspect(@types.codon_to_trait(C, C, C), content="Stealth")
}

///|
test "codon_to_trait ATC = Heal" {
  inspect(@types.codon_to_trait(A, T, C), content="Heal")
}

///|
test "codon_to_trait GAT = Poison" {
  inspect(@types.codon_to_trait(G, A, T), content="Poison")
}

///|
test "codon_to_trait TCA = Armor" {
  inspect(@types.codon_to_trait(T, C, A), content="Armor")
}

///|
test "codon_to_trait AGC = Vision" {
  inspect(@types.codon_to_trait(A, G, C), content="Vision")
}

///|
test "codon_to_trait unknown = Neutral" {
  inspect(@types.codon_to_trait(A, A, T), content="Neutral")
  inspect(@types.codon_to_trait(G, C, A), content="Neutral")
}

///|
test "read_sequence basic ATG AAA TGA" {
  let seq : Array[@types.Base] = [A, T, G, A, A, A, T, G, A]
  let result = @types.read_sequence(seq)
  inspect(result.valid, content="true")
  inspect(result.traits.length(), content="3")
  inspect(result.traits[0], content="Start")
  inspect(result.traits[1], content="Strength")
  inspect(result.traits[2], content="Stop")
}

///|
test "read_sequence partial after start" {
  // ATG found at pos 1, then only GA left (not enough for codon)
  let seq : Array[@types.Base] = [A, A, T, G, G, A]
  let result = @types.read_sequence(seq)
  inspect(result.valid, content="true")
  inspect(result.traits.length(), content="1")
  inspect(result.traits[0], content="Start")
}

///|
test "read_sequence no start codon" {
  let seq : Array[@types.Base] = [G, G, G, C, C, C]
  let result = @types.read_sequence(seq)
  inspect(result.valid, content="false")
  inspect(result.traits.length(), content="0")
}

///|
test "read_sequence with prefix" {
  let seq : Array[@types.Base] = [C, C, A, T, G, T, T, T, T, G, A]
  let result = @types.read_sequence(seq)
  inspect(result.valid, content="true")
  inspect(result.traits.length(), content="3")
  inspect(result.traits[0], content="Start")
  inspect(result.traits[1], content="Speed")
  inspect(result.traits[2], content="Stop")
}

///|
test "read_sequence empty" {
  let seq : Array[@types.Base] = []
  let result = @types.read_sequence(seq)
  inspect(result.valid, content="false")
  inspect(result.traits.length(), content="0")
}

///|
test "traits_match identical" {
  let a : Array[@types.Trait] = [Start, Strength, Stop]
  let b : Array[@types.Trait] = [Start, Strength, Stop]
  inspect(@types.traits_match(a, b), content="true")
}

///|
test "traits_match different" {
  let a : Array[@types.Trait] = [Start, Strength, Stop]
  let b : Array[@types.Trait] = [Start, Speed, Stop]
  inspect(@types.traits_match(a, b), content="false")
}

///|
test "traits_match different length" {
  let a : Array[@types.Trait] = [Start, Strength]
  let b : Array[@types.Trait] = [Start, Strength, Stop]
  inspect(@types.traits_match(a, b), content="false")
}

///|
test "copy_sequence" {
  let seq : Array[@types.Base] = [A, T, G]
  let copy = @types.copy_sequence(seq)
  inspect(copy.length(), content="3")
  inspect(copy[0], content="A")
  inspect(copy[1], content="T")
  inspect(copy[2], content="G")
}

///|
test "compute_stars 3 star" {
  inspect(@types.compute_stars(0, 2, 0), content="3")
  inspect(@types.compute_stars(1, 2, 1), content="3")
}

///|
test "compute_stars 2 star" {
  inspect(@types.compute_stars(2, 2, 1), content="2")
  inspect(@types.compute_stars(1, 2, 0), content="2")
}

///|
test "compute_stars 1 star" {
  inspect(@types.compute_stars(3, 2, 1), content="1")
  inspect(@types.compute_stars(5, 2, 0), content="1")
}

///|
test "new_game initial state" {
  let game = @types.new_game()
  inspect(game.screen, content="Title")
  inspect(game.cursor, content="0")
  inspect(game.edit_count, content="0")
  inspect(game.level_scores.length(), content="25")
  inspect(game.frame_count, content="0")
}

///|
test "base_char" {
  inspect(@types.base_char(A), content="A")
  inspect(@types.base_char(T), content="T")
  inspect(@types.base_char(G), content="G")
  inspect(@types.base_char(C), content="C")
}

///|
test "trait_name" {
  inspect(@types.trait_name(Start), content="START")
  inspect(@types.trait_name(Stop), content="STOP")
  inspect(@types.trait_name(Strength), content="STR")
  inspect(@types.trait_name(Speed), content="SPD")
  inspect(@types.trait_name(Neutral), content="---")
}

///|
test "op_name" {
  inspect(@types.op_name(Cut), content="CUT")
  inspect(@types.op_name(Insert), content="INSERT")
  inspect(@types.op_name(Duplicate), content="DUPLICATE")
  inspect(@types.op_name(Invert), content="INVERT")
  inspect(@types.op_name(Delete), content="DELETE")
}

///|
test "tier_level_count" {
  inspect(@types.tier_level_count(0), content="8")
  inspect(@types.tier_level_count(1), content="9")
  inspect(@types.tier_level_count(2), content="8")
}

///|
test "tier_level_offset" {
  inspect(@types.tier_level_offset(0), content="0")
  inspect(@types.tier_level_offset(1), content="8")
  inspect(@types.tier_level_offset(2), content="17")
}
