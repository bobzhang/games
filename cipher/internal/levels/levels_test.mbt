///|
test "total level count is 25" {
  let levels = get_all_levels()
  inspect(levels.length(), content="25")
}

///|
test "all levels have non-empty ciphertext" {
  let levels = get_all_levels()
  for i in 0..<levels.length() {
    let level = levels[i]
    assert_true(level.ciphertext.length() > 0)
    assert_true(level.plaintext.length() > 0)
  }
}

///|
test "all levels have matching ciphertext and plaintext length" {
  let levels = get_all_levels()
  for i in 0..<levels.length() {
    let level = levels[i]
    inspect(
      level.ciphertext.length() == level.plaintext.length(),
      content="true",
    )
  }
}

///|
test "level ids are sequential 0 to 24" {
  let levels = get_all_levels()
  for i in 0..<levels.length() {
    inspect(levels[i].id == i, content="true")
  }
}

///|
test "tier 1 recruit levels 0-7 are Caesar" {
  let levels = get_all_levels()
  for i in 0..<8 {
    inspect(levels[i].tier, content="Recruit")
    inspect(levels[i].cipher_kind, content="Caesar")
  }
}

///|
test "tier 2 agent levels 8-16 are Substitution" {
  let levels = get_all_levels()
  for i = 8; i <= 16; i = i + 1 {
    inspect(levels[i].tier, content="Agent")
    inspect(levels[i].cipher_kind, content="Substitution")
  }
}

///|
test "tier 3 cryptographer levels 17-24 are Vigenere" {
  let levels = get_all_levels()
  for i = 17; i <= 24; i = i + 1 {
    inspect(levels[i].tier, content="Cryptographer")
    inspect(levels[i].cipher_kind, content="Vigenere")
  }
}

///|
test "ciphertext differs from plaintext for all levels" {
  let levels = get_all_levels()
  for i in 0..<levels.length() {
    let level = levels[i]
    // At least one character should be different (encryption changed it)
    let mut differs = false
    for j in 0..<level.ciphertext.length() {
      let c = @types.str_char_at(level.ciphertext, j)
      let p = @types.str_char_at(level.plaintext, j)
      if c != p {
        differs = true
        break
      }
    }
    assert_true(differs)
  }
}

///|
test "ciphertext is only uppercase and spaces" {
  let levels = get_all_levels()
  for i in 0..<levels.length() {
    let level = levels[i]
    for j in 0..<level.ciphertext.length() {
      let c = @types.str_char_at(level.ciphertext, j)
      let valid = @types.is_upper(c) || c == ' '
      assert_true(valid)
    }
  }
}

///|
test "par swaps are positive and reasonable" {
  let levels = get_all_levels()
  for i in 0..<levels.length() {
    let level = levels[i]
    assert_true(level.par_swaps > 0)
    // Par should not be unreasonably large (no more than 2x unique letters)
    let unique = @types.count_unique_letters(level.ciphertext)
    assert_true(level.par_swaps <= unique * 3)
  }
}

///|
test "all levels have hint text" {
  let levels = get_all_levels()
  for i in 0..<levels.length() {
    assert_true(levels[i].hint_text.length() > 0)
  }
}

///|
test "all levels have key info" {
  let levels = get_all_levels()
  for i in 0..<levels.length() {
    assert_true(levels[i].key_info.length() > 0)
  }
}

///|
test "caesar levels decrypt correctly via known shifts" {
  let levels = get_all_levels()
  let shifts = [3, 5, 7, 13, 4, 9, 11, 17]
  for i in 0..<8 {
    let level = levels[i]
    let decrypted = @crypto.caesar_decrypt(level.ciphertext, shifts[i])
    inspect(decrypted == level.plaintext, content="true")
  }
}

///|
test "vigenere levels decrypt correctly via known keys" {
  let levels = get_all_levels()
  let keys = [
    "KEY", "SPY", "AGENT", "CODE", "SHADOW", "ENIGMA", "BLETCH", "ULTRAX",
  ]
  for i in 0..<8 {
    let level = levels[17 + i]
    let decrypted = @crypto.vigenere_decrypt(level.ciphertext, keys[i])
    inspect(decrypted == level.plaintext, content="true")
  }
}

///|
test "get_level returns correct level" {
  let level0 = get_level(0)
  inspect(level0.id, content="0")
  inspect(level0.plaintext, content="MEET AT DAWN")
  let level24 = get_level(24)
  inspect(level24.id, content="24")
}

///|
test "total_levels returns 25" {
  inspect(total_levels(), content="25")
}

///|
test "difficulty increases across tiers" {
  let levels = get_all_levels()
  // Average par swaps should increase per tier
  let mut tier1_avg = 0
  for i in 0..<8 {
    tier1_avg = tier1_avg + levels[i].par_swaps
  }
  let mut tier2_avg = 0
  for i = 8; i <= 16; i = i + 1 {
    tier2_avg = tier2_avg + levels[i].par_swaps
  }
  let mut tier3_avg = 0
  for i = 17; i <= 24; i = i + 1 {
    tier3_avg = tier3_avg + levels[i].par_swaps
  }
  // Tier 2 average par should be higher than tier 1
  assert_true(tier2_avg * 8 > tier1_avg * 9)
  // Tier 3 average par should be higher than tier 2
  assert_true(tier3_avg * 9 > tier2_avg * 8)
}
