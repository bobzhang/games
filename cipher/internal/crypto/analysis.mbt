///|
pub fn letter_frequency(text : String) -> Array[Int] {
  let counts : Array[Int] = Array::new(capacity=26)
  for _i in 0..<26 {
    counts.push(0)
  }
  for i in 0..<text.length() {
    let c = @types.str_char_at(text, i)
    if @types.is_upper(c) {
      let idx = @types.char_to_idx(c)
      counts[idx] = counts[idx] + 1
    }
  }
  counts
}

///|
pub fn letter_frequency_pct(text : String) -> Array[Float] {
  let counts = letter_frequency(text)
  let mut total = 0
  for i in 0..<26 {
    total += counts[i]
  }
  let pcts : Array[Float] = Array::new(capacity=26)
  if total == 0 {
    for _i in 0..<26 {
      pcts.push(0.0)
    }
  } else {
    let ft = Float::from_int(total)
    for i in 0..<26 {
      pcts.push(Float::from_int(counts[i]) * 100.0 / ft)
    }
  }
  pcts
}

///|
pub fn count_letters(text : String) -> Int {
  let mut count = 0
  for i in 0..<text.length() {
    let c = @types.str_char_at(text, i)
    if @types.is_upper(c) {
      count += 1
    }
  }
  count
}

///|
pub fn find_repeated_patterns(
  text : String,
  min_len : Int,
  max_len : Int,
) -> Array[@types.PatternMatch] {
  let results : Array[@types.PatternMatch] = []
  let letters = StringBuilder::new()
  let positions : Array[Int] = []
  for i in 0..<text.length() {
    let c = @types.str_char_at(text, i)
    if @types.is_upper(c) {
      letters.write_char(c)
      positions.push(i)
    }
  }
  let clean = letters.to_string()
  let len = clean.length()
  for n = min_len; n <= max_len && n <= len; n = n + 1 {
    let seen_patterns : Array[String] = []
    let seen_positions : Array[Array[Int]] = []
    for i = 0; i <= len - n; i = i + 1 {
      let pat = str_substring(clean, i, i + n)
      let mut found = -1
      for j in 0..<seen_patterns.length() {
        if seen_patterns[j] == pat {
          found = j
          break
        }
      }
      if found >= 0 {
        let pos_list = seen_positions[found]
        let mut dup = false
        for k in 0..<pos_list.length() {
          if pos_list[k] == positions[i] {
            dup = true
            break
          }
        }
        if !dup {
          pos_list.push(positions[i])
        }
      } else {
        let mut has_dup = false
        for j = i + 1; j <= len - n; j = j + 1 {
          let pat2 = str_substring(clean, j, j + n)
          if pat == pat2 {
            has_dup = true
            break
          }
        }
        if has_dup {
          seen_patterns.push(pat)
          seen_positions.push([positions[i]])
        }
      }
    }
    for j in 0..<seen_patterns.length() {
      if seen_positions[j].length() >= 2 {
        results.push({
          pattern: seen_patterns[j],
          positions: seen_positions[j],
          count: seen_positions[j].length(),
        })
      }
    }
  }
  results
}

///|
fn str_substring(s : String, start : Int, end_ : Int) -> String {
  let buf = StringBuilder::new()
  for i = start; i < end_ && i < s.length(); i = i + 1 {
    buf.write_char(@types.str_char_at(s, i))
  }
  buf.to_string()
}

///|
pub fn suggest_caesar_shift(ciphertext : String) -> Int {
  let cipher_freq = letter_frequency_pct(ciphertext)
  let mut best_shift = 0
  let mut best_score : Float = 99999.0
  for shift in 0..<26 {
    let mut score : Float = 0.0
    for i in 0..<26 {
      let shifted = (i + shift) % 26
      let diff = cipher_freq[shifted] - @types.english_freq[i]
      score = score + diff * diff
    }
    if score < best_score {
      best_score = score
      best_shift = shift
    }
  }
  best_shift
}

///|
pub fn get_hint_mapping(
  ciphertext : String,
  plaintext : String,
  current : @types.Mapping,
) -> (Int, Int) {
  for i in 0..<ciphertext.length() {
    let c = @types.str_char_at(ciphertext, i)
    if @types.is_upper(c) {
      let ci = @types.char_to_idx(c)
      let expected = @types.char_to_idx(@types.str_char_at(plaintext, i))
      if current.cipher_to_plain[ci] != expected {
        return (ci, expected)
      }
    }
  }
  (0, 0)
}
