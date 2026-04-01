///|
test "all_20_tablets_exist" {
  for i in 0..<20 {
    let tablet = @levels.get_tablet(i)
    inspect(tablet.theme_name.length() > 0, content="true")
  }
}

///|
test "all_tablets_have_valid_inscriptions" {
  for i in 0..<20 {
    let tablet = @levels.get_tablet(i)
    // Inscription must have at least one symbol
    let syms = @types.get_inscription_symbols_unique(tablet.inscription)
    assert_true(syms.length() > 0)
    // Every symbol in the inscription must be in 0..19 range
    for j in 0..<syms.length() {
      let idx = @types.symbol_index(syms[j])
      assert_true(idx >= 0 && idx < 20)
    }
  }
}

///|
test "all_tablets_have_solvable_mappings" {
  for i in 0..<20 {
    let tablet = @levels.get_tablet(i)
    let unique = @types.get_inscription_symbols_unique(tablet.inscription)
    // Every unique symbol in the inscription must have a solution mapping
    for j in 0..<unique.length() {
      let sym = unique[j]
      let mapped = @types.mapping_get(tablet.solution_mapping, sym)
      assert_true(mapped >= 0)
      assert_true(mapped < 20)
    }
  }
}

///|
test "solution_mappings_are_injective" {
  // Each tablet's solution must not map two different symbols to the same letter
  for i in 0..<20 {
    let tablet = @levels.get_tablet(i)
    let unique = @types.get_inscription_symbols_unique(tablet.inscription)
    let used : Array[Int] = []
    for j in 0..<unique.length() {
      let letter = @types.mapping_get(tablet.solution_mapping, unique[j])
      if letter >= 0 {
        // Check letter not already used
        let mut dup = false
        for k in 0..<used.length() {
          if used[k] == letter {
            dup = true
            break
          }
        }
        assert_false(dup)
        used.push(letter)
      }
    }
  }
}

///|
test "given_mappings_are_subset_of_solution" {
  for i in 0..<20 {
    let tablet = @levels.get_tablet(i)
    // Every given mapping must match the solution exactly
    for s in 0..<@types.symbol_count {
      let given_val = tablet.given_mapping.values[s]
      if given_val >= 0 {
        let sol_val = tablet.solution_mapping.values[s]
        inspect(given_val == sol_val, content="true")
      }
    }
  }
}

///|
test "fully_decoded_with_solution" {
  // Applying the full solution mapping must fully decode every tablet
  for i in 0..<20 {
    let tablet = @levels.get_tablet(i)
    let result = @decoder.is_fully_decoded(
      tablet.solution_mapping,
      tablet.solution_mapping,
      tablet.inscription,
    )
    assert_true(result)
  }
}

///|
test "tier1_tablets_correct_tier_and_given_count" {
  // Tier 1 (Fragments): tablets 0-6, ~40% given
  for i in 0..<7 {
    let tablet = @levels.get_tablet(i)
    inspect(tablet.tier, content="Fragments")
    let unique = @types.get_inscription_symbols_unique(tablet.inscription)
    let unique_count = unique.length()
    let mut given_count = 0
    for s in 0..<@types.symbol_count {
      if tablet.given_mapping.values[s] >= 0 {
        given_count = given_count + 1
      }
    }
    // Given should be > 0 and roughly 30-50% of unique symbols
    assert_true(given_count > 0)
    // At least 20% given for tier 1
    assert_true(given_count * 100 / unique_count >= 20)
  }
}

///|
test "tier2_tablets_correct_tier_and_given_count" {
  // Tier 2 (Scrolls): tablets 7-13, ~25% given
  for i in 7..<14 {
    let tablet = @levels.get_tablet(i)
    inspect(tablet.tier, content="Scrolls")
    let unique = @types.get_inscription_symbols_unique(tablet.inscription)
    let unique_count = unique.length()
    let mut given_count = 0
    for s in 0..<@types.symbol_count {
      if tablet.given_mapping.values[s] >= 0 {
        given_count = given_count + 1
      }
    }
    assert_true(given_count > 0)
    // At least 15% given for tier 2
    assert_true(given_count * 100 / unique_count >= 15)
  }
}

///|
test "tier3_tablets_correct_tier_and_given_count" {
  // Tier 3 (Monuments): tablets 14-19, ~15% given
  for i in 14..<20 {
    let tablet = @levels.get_tablet(i)
    inspect(tablet.tier, content="Monuments")
    let unique = @types.get_inscription_symbols_unique(tablet.inscription)
    let unique_count = unique.length()
    let mut given_count = 0
    for s in 0..<@types.symbol_count {
      if tablet.given_mapping.values[s] >= 0 {
        given_count = given_count + 1
      }
    }
    assert_true(given_count > 0)
    // At least 10% given for tier 3
    assert_true(given_count * 100 / unique_count >= 10)
  }
}

///|
test "decoded_text_has_no_underscores_with_solution" {
  // The decoded text with the solution mapping should have no underscores
  for i in 0..<20 {
    let tablet = @levels.get_tablet(i)
    let decoded = @types.decode_inscription(
      tablet.inscription,
      tablet.solution_mapping,
    )
    let mut has_underscore = false
    // Check character by character - underscore means unmapped symbol
    for j in 0..<decoded.length() {
      if decoded[j] == '_' {
        has_underscore = true
      }
    }
    assert_false(has_underscore)
  }
}

///|
test "par_guesses_are_positive" {
  for i in 0..<20 {
    let tablet = @levels.get_tablet(i)
    assert_true(tablet.par_guesses > 0)
  }
}

///|
test "get_tier_tablets_returns_correct_indices" {
  let t1 = @levels.get_tier_tablets(Fragments)
  inspect(t1.length(), content="7")
  inspect(t1[0], content="0")
  inspect(t1[6], content="6")
  let t2 = @levels.get_tier_tablets(Scrolls)
  inspect(t2.length(), content="7")
  inspect(t2[0], content="7")
  inspect(t2[6], content="13")
  let t3 = @levels.get_tier_tablets(Monuments)
  inspect(t3.length(), content="6")
  inspect(t3[0], content="14")
  inspect(t3[5], content="19")
}

///|
test "inscription_symbols_are_not_all_same" {
  // Each tablet should use at least 3 unique symbols for meaningful puzzle
  for i in 0..<20 {
    let tablet = @levels.get_tablet(i)
    let unique = @types.get_inscription_symbols_unique(tablet.inscription)
    assert_true(unique.length() >= 3)
  }
}

///|
test "given_symbols_leave_work_for_player" {
  // Every tablet must have at least some symbols NOT given
  for i in 0..<20 {
    let tablet = @levels.get_tablet(i)
    let unique = @types.get_inscription_symbols_unique(tablet.inscription)
    let unique_count = unique.length()
    let mut given_count = 0
    for s in 0..<@types.symbol_count {
      if tablet.given_mapping.values[s] >= 0 {
        given_count = given_count + 1
      }
    }
    // Player must have at least 2 symbols to decode
    assert_true(unique_count - given_count >= 2)
  }
}
