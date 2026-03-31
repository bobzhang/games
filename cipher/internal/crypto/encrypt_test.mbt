///|
test "caesar encrypt basic" {
  let result = @crypto.caesar_encrypt("HELLO", 3)
  inspect(result, content="KHOOR")
}

///|
test "caesar encrypt preserves spaces" {
  let result = @crypto.caesar_encrypt("MEET AT DAWN", 3)
  inspect(result, content="PHHW DW GDZQ")
}

///|
test "caesar decrypt roundtrip" {
  let plain = "THE DROP IS TONIGHT"
  let cipher = @crypto.caesar_encrypt(plain, 5)
  let decrypted = @crypto.caesar_decrypt(cipher, 5)
  inspect(decrypted, content="THE DROP IS TONIGHT")
}

///|
test "caesar encrypt shift 13 ROT13" {
  let result = @crypto.caesar_encrypt("AGENT", 13)
  inspect(result, content="NTRAG")
  let back = @crypto.caesar_encrypt(result, 13)
  inspect(back, content="AGENT")
}

///|
test "substitution encrypt basic" {
  // Simple swap: A->B, B->C, ..., Z->A (shift by 1 as substitution)
  let key : Array[Int] = [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21,
    22, 23, 24, 25, 0,
  ]
  let result = @crypto.substitution_encrypt("ABC", key)
  inspect(result, content="BCD")
}

///|
test "substitution decrypt roundtrip" {
  let key : Array[Int] = [
    25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6,
    5, 4, 3, 2, 1, 0,
  ]
  let plain = "TRUST NO ONE"
  let cipher = @crypto.substitution_encrypt(plain, key)
  let decrypted = @crypto.substitution_decrypt(cipher, key)
  inspect(decrypted, content="TRUST NO ONE")
}

///|
test "substitution preserves non-alpha" {
  let key : Array[Int] = [
    25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6,
    5, 4, 3, 2, 1, 0,
  ]
  let result = @crypto.substitution_encrypt("A B C", key)
  inspect(result, content="Z Y X")
}

///|
test "vigenere encrypt basic" {
  let result = @crypto.vigenere_encrypt("HELLO", "KEY")
  inspect(result, content="RIJVS")
}

///|
test "vigenere decrypt roundtrip" {
  let plain = "SPY RING EXPOSED"
  let key = "KEY"
  let cipher = @crypto.vigenere_encrypt(plain, key)
  let decrypted = @crypto.vigenere_decrypt(cipher, key)
  inspect(decrypted, content="SPY RING EXPOSED")
}

///|
test "vigenere preserves spaces" {
  let result = @crypto.vigenere_encrypt("A B", "A")
  // key A means shift 0
  inspect(result, content="A B")
}

///|
test "vigenere key wraps" {
  let plain = "ABCDEF"
  let cipher = @crypto.vigenere_encrypt(plain, "AB")
  // A+A=A, B+B=C, C+A=C, D+B=E, E+A=E, F+B=G
  inspect(cipher, content="ACCEEG")
}
