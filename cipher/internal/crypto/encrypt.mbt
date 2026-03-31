///|
pub fn caesar_encrypt(plaintext : String, shift : Int) -> String {
  let buf = StringBuilder::new()
  let s = ((shift % 26) + 26) % 26
  for i in 0..<plaintext.length() {
    let c = @types.str_char_at(plaintext, i)
    if @types.is_upper(c) {
      let idx = @types.char_to_idx(c)
      let new_idx = (idx + s) % 26
      buf.write_char(@types.idx_to_char(new_idx))
    } else {
      buf.write_char(c)
    }
  }
  buf.to_string()
}

///|
pub fn caesar_decrypt(ciphertext : String, shift : Int) -> String {
  caesar_encrypt(ciphertext, 26 - (((shift % 26) + 26) % 26))
}

///|
pub fn substitution_encrypt(plaintext : String, key : Array[Int]) -> String {
  let buf = StringBuilder::new()
  for i in 0..<plaintext.length() {
    let c = @types.str_char_at(plaintext, i)
    if @types.is_upper(c) {
      let idx = @types.char_to_idx(c)
      buf.write_char(@types.idx_to_char(key[idx]))
    } else {
      buf.write_char(c)
    }
  }
  buf.to_string()
}

///|
pub fn substitution_decrypt(ciphertext : String, key : Array[Int]) -> String {
  let inv : Array[Int] = Array::new(capacity=26)
  for _i in 0..<26 {
    inv.push(0)
  }
  for i in 0..<26 {
    inv[key[i]] = i
  }
  substitution_encrypt(ciphertext, inv)
}

///|
pub fn vigenere_encrypt(plaintext : String, key : String) -> String {
  let buf = StringBuilder::new()
  let mut ki = 0
  let key_len = key.length()
  for i in 0..<plaintext.length() {
    let c = @types.str_char_at(plaintext, i)
    if @types.is_upper(c) {
      let pi = @types.char_to_idx(c)
      let shift = @types.char_to_idx(@types.str_char_at(key, ki % key_len))
      let ci = (pi + shift) % 26
      buf.write_char(@types.idx_to_char(ci))
      ki += 1
    } else {
      buf.write_char(c)
    }
  }
  buf.to_string()
}

///|
pub fn vigenere_decrypt(ciphertext : String, key : String) -> String {
  let buf = StringBuilder::new()
  let mut ki = 0
  let key_len = key.length()
  for i in 0..<ciphertext.length() {
    let c = @types.str_char_at(ciphertext, i)
    if @types.is_upper(c) {
      let ci = @types.char_to_idx(c)
      let shift = @types.char_to_idx(@types.str_char_at(key, ki % key_len))
      let pi = ((ci - shift) + 26) % 26
      buf.write_char(@types.idx_to_char(pi))
      ki += 1
    } else {
      buf.write_char(c)
    }
  }
  buf.to_string()
}
