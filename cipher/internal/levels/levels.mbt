///|
fn make_caesar(
  id : Int,
  plaintext : String,
  shift : Int,
  par : Int,
  hint : String
) -> @types.Level {
  let ciphertext = @crypto.caesar_encrypt(plaintext, shift)
  {
    id,
    tier: Recruit,
    cipher_kind: Caesar,
    plaintext,
    ciphertext,
    key_info: "shift=" + shift.to_string(),
    par_swaps: par,
    hint_text: hint,
  }
}

///|
fn make_sub_key() -> Array[Int] {
  // Fixed substitution alphabet: QWERTYUIOPASDFGHJKLZXCVBNM
  // A->Q, B->W, C->E, D->R, E->T, F->Y, G->U, H->I, I->O, J->P,
  // K->A, L->S, M->D, N->F, O->G, P->H, Q->J, R->K, S->L, T->Z,
  // U->X, V->C, W->V, X->B, Y->N, Z->M
  [
    16, 22, 4, 17, 19, 24, 20, 8, 14, 15, 0, 18, 3, 5, 6, 7, 9, 10, 11, 25, 23,
    2, 21, 1, 13, 12,
  ]
}

///|
fn make_sub_key2() -> Array[Int] {
  // ZYXWVUTSRQPONMLKJIHGFEDCBA (reverse)
  [
    25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6,
    5, 4, 3, 2, 1, 0,
  ]
}

///|
fn make_sub_key3() -> Array[Int] {
  // JFMAEHOQCTGYSWZDLPNRIVUBKX
  [
    9, 5, 12, 0, 4, 7, 14, 16, 2, 19, 6, 24, 18, 22, 25, 3, 11, 15, 13, 17, 8,
    21, 20, 1, 10, 23,
  ]
}

///|
fn make_substitution(
  id : Int,
  plaintext : String,
  key : Array[Int],
  par : Int,
  hint : String
) -> @types.Level {
  let ciphertext = @crypto.substitution_encrypt(plaintext, key)
  {
    id,
    tier: Agent,
    cipher_kind: Substitution,
    plaintext,
    ciphertext,
    key_info: "substitution",
    par_swaps: par,
    hint_text: hint,
  }
}

///|
fn make_vigenere(
  id : Int,
  plaintext : String,
  key : String,
  par : Int,
  hint : String
) -> @types.Level {
  let ciphertext = @crypto.vigenere_encrypt(plaintext, key)
  {
    id,
    tier: Cryptographer,
    cipher_kind: Vigenere,
    plaintext,
    ciphertext,
    key_info: "key=" + key,
    par_swaps: par,
    hint_text: hint,
  }
}

///|
pub fn get_all_levels() -> Array[@types.Level] {
  let levels : Array[@types.Level] = []
  // TIER 1: RECRUIT - Caesar cipher (8 levels)
  levels.push(
    make_caesar(
      0,
      "MEET AT DAWN",
      3,
      4,
      "The most common letter in English is E",
    ),
  )
  levels.push(
    make_caesar(
      1,
      "THE DROP IS TONIGHT",
      5,
      5,
      "Look for three letter words like THE",
    ),
  )
  levels.push(
    make_caesar(
      2,
      "ABORT THE MISSION NOW",
      7,
      5,
      "Single letter words are usually A or I",
    ),
  )
  levels.push(
    make_caesar(
      3,
      "AGENT FOX REPORT TO BASE",
      13,
      6,
      "Try shifting by 13 - ROT13 is common",
    ),
  )
  levels.push(
    make_caesar(
      4,
      "THE PACKAGE IS IN THE LOCKER",
      4,
      6,
      "THE appears twice in this message",
    ),
  )
  levels.push(
    make_caesar(
      5,
      "RENDEZVOUS AT THE OLD BRIDGE",
      9,
      7,
      "AT and THE are common short words",
    ),
  )
  levels.push(
    make_caesar(
      6,
      "EXTRACT TEAM ALPHA FROM SECTOR NINE",
      11,
      8,
      "TEAM and FROM are four letter words",
    ),
  )
  levels.push(
    make_caesar(
      7,
      "THE EMBASSY CODES HAVE BEEN COMPROMISED",
      17,
      8,
      "BEEN has double letters",
    ),
  )
  // TIER 2: AGENT - Substitution cipher (9 levels)
  let key1 = make_sub_key()
  let key2 = make_sub_key2()
  let key3 = make_sub_key3()
  levels.push(
    make_substitution(
      8,
      "TRUST NO ONE",
      key1,
      8,
      "ONE is a very common three letter word",
    ),
  )
  levels.push(
    make_substitution(
      9,
      "THE MOLE IS IN THE AGENCY",
      key2,
      10,
      "THE appears twice - find it first",
    ),
  )
  levels.push(
    make_substitution(
      10,
      "DEAD DROP UNDER THE PARK BENCH",
      key1,
      12,
      "THE and UNDER are common words",
    ),
  )
  levels.push(
    make_substitution(
      11,
      "SURVEILLANCE TEAM SPOTTED AT NORTH EXIT",
      key3,
      14,
      "Look for double letters in SURVEILLANCE",
    ),
  )
  levels.push(
    make_substitution(
      12,
      "THE INFORMANT WILL MEET AT THE CAFE",
      key2,
      14,
      "WILL has double L - look for repeated letters",
    ),
  )
  levels.push(
    make_substitution(
      13,
      "DESTROY ALL DOCUMENTS BEFORE EXTRACTION",
      key1,
      15,
      "BEFORE and DESTROY are six letter words",
    ),
  )
  levels.push(
    make_substitution(
      14,
      "ENEMY AGENTS HAVE INFILTRATED OUR NETWORK",
      key3,
      16,
      "OUR is a common three letter word",
    ),
  )
  levels.push(
    make_substitution(
      15,
      "THE DOUBLE AGENT WAS FEEDING FALSE INTELLIGENCE",
      key2,
      18,
      "FALSE and DOUBLE have five and six letters",
    ),
  )
  levels.push(
    make_substitution(
      16,
      "CLASSIFIED MATERIAL FOUND IN THE SAFE HOUSE BASEMENT",
      key1,
      20,
      "CLASSIFIED starts with C - a less common letter",
    ),
  )
  // TIER 3: CRYPTOGRAPHER - Vigenere + mixed (8 levels)
  levels.push(
    make_vigenere(
      17,
      "SPY RING EXPOSED",
      "KEY",
      10,
      "The key is three letters long",
    ),
  )
  levels.push(
    make_vigenere(
      18,
      "THE CODE NAME IS FALCON",
      "SPY",
      12,
      "Look for repeated patterns every 3 letters",
    ),
  )
  levels.push(
    make_vigenere(
      19,
      "INTERCEPT ALL RADIO TRANSMISSIONS",
      "AGENT",
      16,
      "The key length is five - look for pattern spacing",
    ),
  )
  levels.push(
    make_vigenere(
      20,
      "THE CIPHER MACHINE HAS BEEN RELOCATED",
      "CODE",
      16,
      "Four letter key - try common spy words",
    ),
  )
  levels.push(
    make_vigenere(
      21,
      "OPERATION MIDNIGHT SUN BEGINS AT ZERO HOUR",
      "SHADOW",
      20,
      "Six letter key - the word means darkness",
    ),
  )
  levels.push(
    make_vigenere(
      22,
      "ALL FIELD AGENTS MUST REPORT TO HEADQUARTERS IMMEDIATELY",
      "ENIGMA",
      22,
      "Named after the famous cipher machine",
    ),
  )
  levels.push(
    make_vigenere(
      23,
      "THE ENEMY HAS BROKEN OUR ENCRYPTION PROTOCOL",
      "BLETCH",
      22,
      "Think Bletchley Park - home of codebreakers",
    ),
  )
  levels.push(
    make_vigenere(
      24,
      "FINAL TRANSMISSION CIPHER COMPROMISED DESTROY ALL EVIDENCE NOW",
      "ULTRAX",
      26,
      "Six letter key - think ULTRA intelligence",
    ),
  )
  levels
}

///|
pub fn get_level(id : Int) -> @types.Level {
  let all = get_all_levels()
  all[id]
}

///|
pub fn total_levels() -> Int {
  25
}
