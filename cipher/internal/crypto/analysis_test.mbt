///|
test "letter frequency counts" {
  let counts = @crypto.letter_frequency("AABBC")
  inspect(counts[0], content="2") // A
  inspect(counts[1], content="2") // B
  inspect(counts[2], content="1") // C
  inspect(counts[3], content="0") // D
}

///|
test "letter frequency ignores non-alpha" {
  let counts = @crypto.letter_frequency("A B C")
  inspect(counts[0], content="1")
  inspect(counts[1], content="1")
  inspect(counts[2], content="1")
}

///|
test "letter frequency pct" {
  let pcts = @crypto.letter_frequency_pct("AAAA")
  // A is 100%, rest 0%
  inspect(pcts[0], content="100")
  inspect(pcts[1], content="0")
}

///|
test "count letters" {
  let count = @crypto.count_letters("HELLO WORLD")
  inspect(count, content="10")
}

///|
test "find repeated patterns" {
  let patterns = @crypto.find_repeated_patterns("ABCABCXYZ", 3, 3)
  inspect(patterns.length() > 0, content="true")
  inspect(patterns[0].pattern, content="ABC")
  inspect(patterns[0].count, content="2")
}

///|
test "find repeated patterns none" {
  let patterns = @crypto.find_repeated_patterns("ABCDEFG", 3, 3)
  inspect(patterns.length(), content="0")
}

///|
test "suggest caesar shift" {
  // Encrypt with shift 3, then check suggestion
  let cipher = @crypto.caesar_encrypt(
    "THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG", 3,
  )
  let suggested = @crypto.suggest_caesar_shift(cipher)
  inspect(suggested, content="3")
}
