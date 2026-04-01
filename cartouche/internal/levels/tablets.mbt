///|
fn build_mapping(pairs : Array[(Int, Int)]) -> @types.Mapping {
  let m = @types.new_mapping()
  for i in 0..<pairs.length() {
    let (sym_idx, letter_idx) = pairs[i]
    m.values[sym_idx] = letter_idx
  }
  m
}

///|
fn sym(s : @types.Symbol) -> @types.InscriptionSymbol {
  @types.make_symbol(s)
}

///|
fn gap() -> @types.InscriptionSymbol {
  @types.make_space()
}

// Tier 1: Fragments (7 tablets, 3-4 word inscriptions, 40% given)
// Symbols map: Circle=A(0), Triangle=B(1), Square=C(2), Diamond=D(3), Star=E(4),
// Cross=F(5), Arrow=G(6), Wave=H(7), Spiral=I(8), Dot=J(9),
// Crescent=K(10), Lightning=L(11), Eye=M(12), Hand=N(13), Sun=O(14),
// MoonSym=P(15), Mountain=Q(16), River=R(17), Tree=S(18), Flame=T(19)

///|
fn tablet_01() -> @types.Tablet {
  // "ABLE DICE BEAD" - 3 words
  // A=Circle, B=Triangle, L=Lightning, E=Star
  // D=Diamond, I=Spiral, C=Square,
  // uses: A(0),B(1),L(11),E(4),D(3),I(8),C(2)
  let inscription = @types.new_inscription(
    [
      sym(Circle), sym(Triangle), sym(Lightning), sym(Star), gap(), sym(Diamond),
      sym(Spiral), sym(Square), sym(Star), gap(), sym(Triangle), sym(Star),
      sym(Circle), sym(Diamond),
    ],
  )
  let solution = build_mapping(
    [
      (0, 0), (1, 1), (11, 11), (4, 4), (3, 3), (8, 8), (2, 2),
    ],
  )
  // 40% of 7 unique = 3 given
  let given = build_mapping([(0, 0), (4, 4), (3, 3)])
  {
    inscription,
    solution_mapping: solution,
    given_mapping: given,
    theme_name: "First Words",
    par_guesses: 6,
    tier: Fragments,
  }
}

///|
fn tablet_02() -> @types.Tablet {
  // "FACE CAGE AGED" - 3 words
  // F=Cross, A=Circle, C=Square, E=Star, G=Arrow, D=Diamond
  let inscription = @types.new_inscription(
    [
      sym(Cross), sym(Circle), sym(Square), sym(Star), gap(), sym(Square),
      sym(Circle), sym(Arrow), sym(Star), gap(), sym(Circle), sym(Arrow),
      sym(Star), sym(Diamond),
    ],
  )
  let solution = build_mapping(
    [(5, 5), (0, 0), (2, 2), (4, 4), (6, 6), (3, 3)],
  )
  let given = build_mapping([(5, 5), (0, 0), (4, 4)])
  {
    inscription,
    solution_mapping: solution,
    given_mapping: given,
    theme_name: "Stone Face",
    par_guesses: 5,
    tier: Fragments,
  }
}

///|
fn tablet_03() -> @types.Tablet {
  // "HIKE LIKE SILK" - 3 words
  // H=Wave, I=Spiral, K=Crescent, E=Star, L=Lightning, S=Tree
  let inscription = @types.new_inscription(
    [
      sym(Wave), sym(Spiral), sym(Crescent), sym(Star), gap(), sym(Lightning),
      sym(Spiral), sym(Crescent), sym(Star), gap(), sym(Tree), sym(Spiral),
      sym(Lightning), sym(Crescent),
    ],
  )
  let solution = build_mapping(
    [(7, 7), (8, 8), (10, 10), (4, 4), (11, 11), (18, 18)],
  )
  let given = build_mapping([(7, 7), (4, 4), (11, 11)])
  {
    inscription,
    solution_mapping: solution,
    given_mapping: given,
    theme_name: "Mountain Path",
    par_guesses: 5,
    tier: Fragments,
  }
}

///|
fn tablet_04() -> @types.Tablet {
  // "BOLD GOLD TOLD COLD" - 4 words
  // B=Triangle, O=Sun, L=Lightning, D=Diamond, G=Arrow, T=Flame, C=Square
  let inscription = @types.new_inscription(
    [
      sym(Triangle), sym(Sun), sym(Lightning), sym(Diamond), gap(), sym(Arrow),
      sym(Sun), sym(Lightning), sym(Diamond), gap(), sym(Flame), sym(Sun),
      sym(Lightning), sym(Diamond), gap(), sym(Square), sym(Sun),
      sym(Lightning), sym(Diamond),
    ],
  )
  let solution = build_mapping(
    [(1, 1), (14, 14), (11, 11), (3, 3), (6, 6), (19, 19), (2, 2)],
  )
  let given = build_mapping([(14, 14), (11, 11), (3, 3)])
  {
    inscription,
    solution_mapping: solution,
    given_mapping: given,
    theme_name: "Precious Metals",
    par_guesses: 6,
    tier: Fragments,
  }
}

///|
fn tablet_05() -> @types.Tablet {
  // "LIFE FIRE RIFE" - 3 words
  // L=Lightning, I=Spiral, F=Cross, E=Star, R=River
  let inscription = @types.new_inscription(
    [
      sym(Lightning), sym(Spiral), sym(Cross), sym(Star), gap(), sym(Cross),
      sym(Spiral), sym(River), sym(Star), gap(), sym(River), sym(Spiral),
      sym(Cross), sym(Star),
    ],
  )
  let solution = build_mapping(
    [(11, 11), (8, 8), (5, 5), (4, 4), (17, 17)],
  )
  let given = build_mapping([(11, 11), (4, 4)])
  {
    inscription,
    solution_mapping: solution,
    given_mapping: given,
    theme_name: "Sacred Flame",
    par_guesses: 5,
    tier: Fragments,
  }
}

///|
fn tablet_06() -> @types.Tablet {
  // "JADE FADE MADE" - 3 words
  // J=Dot, A=Circle, D=Diamond, E=Star, F=Cross, M=Eye
  let inscription = @types.new_inscription(
    [
      sym(Dot), sym(Circle), sym(Diamond), sym(Star), gap(), sym(Cross),
      sym(Circle), sym(Diamond), sym(Star), gap(), sym(Eye), sym(Circle),
      sym(Diamond), sym(Star),
    ],
  )
  let solution = build_mapping(
    [(9, 9), (0, 0), (3, 3), (4, 4), (5, 5), (12, 12)],
  )
  let given = build_mapping([(0, 0), (3, 3), (4, 4)])
  {
    inscription,
    solution_mapping: solution,
    given_mapping: given,
    theme_name: "Fading Jade",
    par_guesses: 5,
    tier: Fragments,
  }
}

///|
fn tablet_07() -> @types.Tablet {
  // "KING SING RING DING" - 4 words
  // K=Crescent, I=Spiral, N=Hand, G=Arrow, S=Tree, R=River, D=Diamond
  let inscription = @types.new_inscription(
    [
      sym(Crescent), sym(Spiral), sym(Hand), sym(Arrow), gap(), sym(Tree),
      sym(Spiral), sym(Hand), sym(Arrow), gap(), sym(River), sym(Spiral),
      sym(Hand), sym(Arrow), gap(), sym(Diamond), sym(Spiral), sym(Hand),
      sym(Arrow),
    ],
  )
  let solution = build_mapping(
    [(10, 10), (8, 8), (13, 13), (6, 6), (18, 18), (17, 17), (3, 3)],
  )
  let given = build_mapping([(8, 8), (13, 13), (6, 6)])
  {
    inscription,
    solution_mapping: solution,
    given_mapping: given,
    theme_name: "Royal Song",
    par_guesses: 6,
    tier: Fragments,
  }
}

// Tier 2: Scrolls (7 tablets, 5-6 word inscriptions, 25% given)

///|
fn tablet_08() -> @types.Tablet {
  // "BRIGHT LIGHT MIGHT FIGHT NIGHT" - 5 words (but these are 6-letter words, too complex)
  // Let's do: "SAGE BONE MIST DARK HOPE" - 5 words
  // S=Tree, A=Circle, G=Arrow, E=Star, B=Triangle, O=Sun, N=Hand,
  // M=Eye, I=Spiral, T=Flame, D=Diamond, R=River, K=Crescent, H=Wave, P=MoonSym
  let inscription = @types.new_inscription(
    [
      sym(Tree), sym(Circle), sym(Arrow), sym(Star), gap(), sym(Triangle),
      sym(Sun), sym(Hand), sym(Star), gap(), sym(Eye), sym(Spiral), sym(Tree),
      sym(Flame), gap(), sym(Diamond), sym(Circle), sym(River), sym(Crescent),
      gap(), sym(Wave), sym(Sun), sym(MoonSym), sym(Star),
    ],
  )
  let solution = build_mapping(
    [
      (18, 18), (0, 0), (6, 6), (4, 4), (1, 1), (14, 14), (13, 13), (12, 12),
      (8, 8), (19, 19), (3, 3), (17, 17), (10, 10), (7, 7), (15, 15),
    ],
  )
  // 25% of 15 unique = 4 given
  let given = build_mapping([(0, 0), (4, 4), (14, 14), (19, 19)])
  {
    inscription,
    solution_mapping: solution,
    given_mapping: given,
    theme_name: "Ancient Wisdom",
    par_guesses: 14,
    tier: Scrolls,
  }
}

///|
fn tablet_09() -> @types.Tablet {
  // "FABLE NIGHT DREAM GHOST SHORE" - 5 words
  // F=Cross, A=Circle, B=Triangle, L=Lightning, E=Star
  // N=Hand, I=Spiral, G=Arrow, H=Wave, T=Flame
  // D=Diamond, R=River, M=Eye
  // O=Sun, S=Tree
  let inscription = @types.new_inscription(
    [
      sym(Cross), sym(Circle), sym(Triangle), sym(Lightning), sym(Star), gap(),
      sym(Hand), sym(Spiral), sym(Arrow), sym(Wave), sym(Flame), gap(),
      sym(Diamond), sym(River), sym(Star), sym(Circle), sym(Eye), gap(),
      sym(Arrow), sym(Wave), sym(Sun), sym(Tree), sym(Flame), gap(), sym(Tree),
      sym(Wave), sym(Sun), sym(River), sym(Star),
    ],
  )
  let solution = build_mapping(
    [
      (5, 5), (0, 0), (1, 1), (11, 11), (4, 4), (13, 13), (8, 8), (6, 6),
      (7, 7), (19, 19), (3, 3), (17, 17), (12, 12), (14, 14), (18, 18),
    ],
  )
  let given = build_mapping([(0, 0), (4, 4), (7, 7), (18, 18)])
  {
    inscription,
    solution_mapping: solution,
    given_mapping: given,
    theme_name: "Dream Shore",
    par_guesses: 14,
    tier: Scrolls,
  }
}

///|
fn tablet_10() -> @types.Tablet {
  // "BLADE FORGE SMITH CRAFT STEEL" - 5 words
  // B=Tri, L=Light, A=Circ, D=Dia, E=Star
  // F=Cross, O=Sun, R=River, G=Arrow
  // S=Tree, M=Eye, I=Spiral, T=Flame, H=Wave
  // C=Square, K=Crescent (not used)
  let inscription = @types.new_inscription(
    [
      sym(Triangle), sym(Lightning), sym(Circle), sym(Diamond), sym(Star), gap(),
      sym(Cross), sym(Sun), sym(River), sym(Arrow), sym(Star), gap(), sym(Tree),
      sym(Eye), sym(Spiral), sym(Flame), sym(Wave), gap(), sym(Square),
      sym(River), sym(Circle), sym(Cross), sym(Flame), gap(), sym(Tree),
      sym(Flame), sym(Star), sym(Star), sym(Lightning),
    ],
  )
  let solution = build_mapping(
    [
      (1, 1), (11, 11), (0, 0), (3, 3), (4, 4), (5, 5), (14, 14), (17, 17),
      (6, 6), (18, 18), (12, 12), (8, 8), (19, 19), (7, 7), (2, 2),
    ],
  )
  let given = build_mapping([(1, 1), (4, 4), (17, 17), (19, 19)])
  {
    inscription,
    solution_mapping: solution,
    given_mapping: given,
    theme_name: "Forge of Ages",
    par_guesses: 14,
    tier: Scrolls,
  }
}

///|
fn tablet_11() -> @types.Tablet {
  // "FLAME STONE LIGHT EMBER GLADE" - 5 words
  // F=Cross, L=Lightning, A=Circle, M=Eye, E=Star
  // S=Tree, T=Flame, O=Sun, N=Hand
  // I=Spiral, G=Arrow, H=Wave
  // B=Triangle, R=River, D=Diamond
  let inscription = @types.new_inscription(
    [
      sym(Cross), sym(Lightning), sym(Circle), sym(Eye), sym(Star), gap(),
      sym(Tree), sym(Flame), sym(Sun), sym(Hand), sym(Star), gap(),
      sym(Lightning), sym(Spiral), sym(Arrow), sym(Wave), sym(Flame), gap(),
      sym(Star), sym(Eye), sym(Triangle), sym(Star), sym(River), gap(),
      sym(Arrow), sym(Lightning), sym(Circle), sym(Diamond), sym(Star),
    ],
  )
  let solution = build_mapping(
    [
      (5, 5), (11, 11), (0, 0), (12, 12), (4, 4), (18, 18), (19, 19),
      (14, 14), (13, 13), (8, 8), (6, 6), (7, 7), (1, 1), (17, 17), (3, 3),
    ],
  )
  let given = build_mapping([(11, 11), (4, 4), (14, 14), (19, 19)])
  {
    inscription,
    solution_mapping: solution,
    given_mapping: given,
    theme_name: "Ember Light",
    par_guesses: 14,
    tier: Scrolls,
  }
}

///|
fn tablet_12() -> @types.Tablet {
  // "THRONE QUEST NOBLE CHARM FAITH GRACE" - 6 words
  // T=Flame, H=Wave, R=River, O=Sun, N=Hand, E=Star
  // Q=Mountain, U->not available, let me pick different words
  // "THRONE NOBLE CHARM FAITH GRACE STONE" - 6 words
  // T=Flame, H=Wave, R=River, O=Sun, N=Hand, E=Star
  // B=Triangle, L=Lightning, C=Square, A=Circle, M=Eye
  // F=Cross, I=Spiral, G=Arrow, S=Tree
  let inscription = @types.new_inscription(
    [
      sym(Flame), sym(Wave), sym(River), sym(Sun), sym(Hand), sym(Star), gap(),
      sym(Hand), sym(Sun), sym(Triangle), sym(Lightning), sym(Star), gap(),
      sym(Square), sym(Wave), sym(Circle), sym(River), sym(Eye), gap(),
      sym(Cross), sym(Circle), sym(Spiral), sym(Flame), sym(Wave), gap(),
      sym(Arrow), sym(River), sym(Circle), sym(Square), sym(Star), gap(),
      sym(Tree), sym(Flame), sym(Sun), sym(Hand), sym(Star),
    ],
  )
  let solution = build_mapping(
    [
      (19, 19), (7, 7), (17, 17), (14, 14), (13, 13), (4, 4), (1, 1),
      (11, 11), (2, 2), (0, 0), (12, 12), (5, 5), (8, 8), (6, 6), (18, 18),
    ],
  )
  // 25% of 15 = 4 given
  let given = build_mapping([(4, 4), (14, 14), (7, 7), (19, 19)])
  {
    inscription,
    solution_mapping: solution,
    given_mapping: given,
    theme_name: "Royal Decree",
    par_guesses: 15,
    tier: Scrolls,
  }
}

///|
fn tablet_13() -> @types.Tablet {
  // "CRANE BISON MOOSE EAGLE TIGER" - 5 words but uses U - skip
  // "CRANE ROBIN FINCH DHOLE STOIC" - still messy
  // Better: "CORAL BEACH DRIFT AMBER SHELL" - 5 words
  // C=Square, O=Sun, R=River, A=Circle, L=Lightning
  // B=Triangle, E=Star, H=Wave
  // D=Diamond, I=Spiral, F=Cross, T=Flame
  // M=Eye, S=Tree
  let inscription = @types.new_inscription(
    [
      sym(Square), sym(Sun), sym(River), sym(Circle), sym(Lightning), gap(),
      sym(Triangle), sym(Star), sym(Circle), sym(Square), sym(Wave), gap(),
      sym(Diamond), sym(River), sym(Spiral), sym(Cross), sym(Flame), gap(),
      sym(Circle), sym(Eye), sym(Triangle), sym(Star), sym(River), gap(),
      sym(Tree), sym(Wave), sym(Star), sym(Lightning), sym(Lightning),
    ],
  )
  let solution = build_mapping(
    [
      (2, 2), (14, 14), (17, 17), (0, 0), (11, 11), (1, 1), (4, 4), (7, 7),
      (3, 3), (8, 8), (5, 5), (19, 19), (12, 12), (18, 18),
    ],
  )
  let given = build_mapping([(0, 0), (4, 4), (14, 14), (17, 17)])
  {
    inscription,
    solution_mapping: solution,
    given_mapping: given,
    theme_name: "Ocean Scroll",
    par_guesses: 13,
    tier: Scrolls,
  }
}

///|
fn tablet_14() -> @types.Tablet {
  // "RELIC GLYPH... too many unique letters, use simpler
  // "STORM REIGN BLADE FROST NIGHT GLEAM" - 6 words
  // S=Tree, T=Flame, O=Sun, R=River, M=Eye
  // E=Star, I=Spiral, G=Arrow, N=Hand
  // B=Triangle, L=Lightning, A=Circle, D=Diamond
  // F=Cross, H=Wave
  let inscription = @types.new_inscription(
    [
      sym(Tree), sym(Flame), sym(Sun), sym(River), sym(Eye), gap(), sym(River),
      sym(Star), sym(Spiral), sym(Arrow), sym(Hand), gap(), sym(Triangle),
      sym(Lightning), sym(Circle), sym(Diamond), sym(Star), gap(), sym(Cross),
      sym(River), sym(Sun), sym(Tree), sym(Flame), gap(), sym(Hand), sym(Spiral),
      sym(Arrow), sym(Wave), sym(Flame), gap(), sym(Arrow), sym(Lightning),
      sym(Star), sym(Circle), sym(Eye),
    ],
  )
  let solution = build_mapping(
    [
      (18, 18), (19, 19), (14, 14), (17, 17), (12, 12), (4, 4), (8, 8),
      (6, 6), (13, 13), (1, 1), (11, 11), (0, 0), (3, 3), (5, 5), (7, 7),
    ],
  )
  // 25% of 15 = 4 given
  let given = build_mapping([(4, 4), (14, 14), (17, 17), (19, 19)])
  {
    inscription,
    solution_mapping: solution,
    given_mapping: given,
    theme_name: "Frost Reign",
    par_guesses: 15,
    tier: Scrolls,
  }
}

// Tier 3: Monuments (6 tablets, 7-8 word inscriptions, 15% given)

///|
fn tablet_15() -> @types.Tablet {
  // "BRIGHT FALCON DESERT ORACLE TEMPLE SACRED MOSAIC" - 7 words
  // Too many unique letters. Use A-T only.
  // "SHORE DRIFT CORAL AMBER FLAME STONE LIGHT" - 7 words
  // S=Tree, H=Wave, O=Sun, R=River, E=Star
  // D=Diamond, I=Spiral, F=Cross, T=Flame
  // C=Square, A=Circle, L=Lightning
  // M=Eye, B=Triangle, N=Hand, G=Arrow
  let inscription = @types.new_inscription(
    [
      sym(Tree), sym(Wave), sym(Sun), sym(River), sym(Star), gap(), sym(Diamond),
      sym(River), sym(Spiral), sym(Cross), sym(Flame), gap(), sym(Square),
      sym(Sun), sym(River), sym(Circle), sym(Lightning), gap(), sym(Circle),
      sym(Eye), sym(Triangle), sym(Star), sym(River), gap(), sym(Cross),
      sym(Lightning), sym(Circle), sym(Eye), sym(Star), gap(), sym(Tree),
      sym(Flame), sym(Sun), sym(Hand), sym(Star), gap(), sym(Lightning),
      sym(Spiral), sym(Arrow), sym(Wave), sym(Flame),
    ],
  )
  let solution = build_mapping(
    [
      (18, 18), (7, 7), (14, 14), (17, 17), (4, 4), (3, 3), (8, 8), (5, 5),
      (19, 19), (2, 2), (0, 0), (11, 11), (12, 12), (1, 1), (13, 13), (6, 6),
    ],
  )
  // 15% of 16 = 2-3 given
  let given = build_mapping([(4, 4), (14, 14), (17, 17)])
  {
    inscription,
    solution_mapping: solution,
    given_mapping: given,
    theme_name: "Coastal Monument",
    par_guesses: 18,
    tier: Monuments,
  }
}

///|
fn tablet_16() -> @types.Tablet {
  // "ANCIENT SCRIPT DECODE CIPHER MASTER GOLDEN TABLET" - 7 words
  // Too many letters. Simpler:
  // "FALCON GRAIL STORM BLADE NIGHT FORGE CREST" - 7 words
  // F=Cross, A=Circle, L=Lightning, C=Square, O=Sun, N=Hand
  // G=Arrow, R=River, I=Spiral, T=Flame
  // S=Tree, M=Eye, B=Triangle, D=Diamond, E=Star, H=Wave
  let inscription = @types.new_inscription(
    [
      sym(Cross), sym(Circle), sym(Lightning), sym(Square), sym(Sun),
      sym(Hand), gap(), sym(Arrow), sym(River), sym(Circle), sym(Spiral),
      sym(Lightning), gap(), sym(Tree), sym(Flame), sym(Sun), sym(River),
      sym(Eye), gap(), sym(Triangle), sym(Lightning), sym(Circle), sym(Diamond),
      sym(Star), gap(), sym(Hand), sym(Spiral), sym(Arrow), sym(Wave),
      sym(Flame), gap(), sym(Cross), sym(Sun), sym(River), sym(Arrow),
      sym(Star), gap(), sym(Square), sym(River), sym(Star), sym(Tree),
      sym(Flame),
    ],
  )
  let solution = build_mapping(
    [
      (5, 5), (0, 0), (11, 11), (2, 2), (14, 14), (13, 13), (6, 6), (17, 17),
      (8, 8), (19, 19), (18, 18), (12, 12), (1, 1), (3, 3), (4, 4), (7, 7),
    ],
  )
  let given = build_mapping([(4, 4), (14, 14)])
  {
    inscription,
    solution_mapping: solution,
    given_mapping: given,
    theme_name: "Falcon Crest",
    par_guesses: 19,
    tier: Monuments,
  }
}

///|
fn tablet_17() -> @types.Tablet {
  // "DRAGON PRINCE KNIGHT CASTLE BRIDGE FOREST MAGIC" - too many unique
  // "SHIELD KNIGHT DRAGON CASTLE THRONE BRIDGE ANCIENT" - too many
  // Simple: "MIST BONE LAKE CRAG FERN SILK JADE PLOT" - 8 short words
  // M=Eye, I=Spiral, S=Tree, T=Flame
  // B=Triangle, O=Sun, N=Hand, E=Star
  // L=Lightning, A=Circle, K=Crescent
  // C=Square, R=River, G=Arrow
  // F=Cross, D=Diamond, P=MoonSym, H=Wave (not used in these words)
  // Actually: PLOT uses P,L,O,T
  let inscription = @types.new_inscription(
    [
      sym(Eye), sym(Spiral), sym(Tree), sym(Flame), gap(), sym(Triangle),
      sym(Sun), sym(Hand), sym(Star), gap(), sym(Lightning), sym(Circle),
      sym(Crescent), sym(Star), gap(), sym(Square), sym(River), sym(Circle),
      sym(Arrow), gap(), sym(Cross), sym(Star), sym(River), sym(Hand), gap(),
      sym(Tree), sym(Spiral), sym(Lightning), sym(Crescent), gap(), sym(Dot),
      sym(Circle), sym(Diamond), sym(Star), gap(), sym(MoonSym), sym(Lightning),
      sym(Sun), sym(Flame),
    ],
  )
  let solution = build_mapping(
    [
      (12, 12), (8, 8), (18, 18), (19, 19), (1, 1), (14, 14), (13, 13),
      (4, 4), (11, 11), (0, 0), (10, 10), (2, 2), (17, 17), (6, 6), (5, 5),
      (3, 3), (9, 9), (15, 15),
    ],
  )
  // 15% of 18 = 3 given
  let given = build_mapping([(4, 4), (14, 14), (18, 18)])
  {
    inscription,
    solution_mapping: solution,
    given_mapping: given,
    theme_name: "Lost Archive",
    par_guesses: 20,
    tier: Monuments,
  }
}

///|
fn tablet_18() -> @types.Tablet {
  // "BLADE FROST GLEAM SHINE CORAL DRIFT NIGHT" - 7 words
  // B=Tri, L=Light, A=Circ, D=Dia, E=Star
  // F=Cross, R=River, O=Sun, S=Tree, T=Flame
  // G=Arrow, M=Eye, H=Wave, I=Spiral, N=Hand
  // C=Square
  let inscription = @types.new_inscription(
    [
      sym(Triangle), sym(Lightning), sym(Circle), sym(Diamond), sym(Star), gap(),
      sym(Cross), sym(River), sym(Sun), sym(Tree), sym(Flame), gap(), sym(Arrow),
      sym(Lightning), sym(Star), sym(Circle), sym(Eye), gap(), sym(Tree),
      sym(Wave), sym(Spiral), sym(Hand), sym(Star), gap(), sym(Square),
      sym(Sun), sym(River), sym(Circle), sym(Lightning), gap(), sym(Diamond),
      sym(River), sym(Spiral), sym(Cross), sym(Flame), gap(), sym(Hand),
      sym(Spiral), sym(Arrow), sym(Wave), sym(Flame),
    ],
  )
  let solution = build_mapping(
    [
      (1, 1), (11, 11), (0, 0), (3, 3), (4, 4), (5, 5), (17, 17), (14, 14),
      (18, 18), (19, 19), (6, 6), (12, 12), (7, 7), (8, 8), (13, 13), (2, 2),
    ],
  )
  let given = build_mapping([(4, 4), (14, 14)])
  {
    inscription,
    solution_mapping: solution,
    given_mapping: given,
    theme_name: "Frozen Shore",
    par_guesses: 19,
    tier: Monuments,
  }
}

///|
fn tablet_19() -> @types.Tablet {
  // "NOBLE FORGE CREST LIGHT STORM BLADE REIGN GHOST" - 8 words
  // N=Hand, O=Sun, B=Tri, L=Light, E=Star
  // F=Cross, R=River, G=Arrow
  // C=Square, S=Tree, T=Flame
  // I=Spiral, H=Wave, M=Eye
  // A=Circle, D=Diamond
  let inscription = @types.new_inscription(
    [
      sym(Hand), sym(Sun), sym(Triangle), sym(Lightning), sym(Star), gap(),
      sym(Cross), sym(Sun), sym(River), sym(Arrow), sym(Star), gap(),
      sym(Square), sym(River), sym(Star), sym(Tree), sym(Flame), gap(),
      sym(Lightning), sym(Spiral), sym(Arrow), sym(Wave), sym(Flame), gap(),
      sym(Tree), sym(Flame), sym(Sun), sym(River), sym(Eye), gap(),
      sym(Triangle), sym(Lightning), sym(Circle), sym(Diamond), sym(Star), gap(),
      sym(River), sym(Star), sym(Spiral), sym(Arrow), sym(Hand), gap(),
      sym(Arrow), sym(Wave), sym(Sun), sym(Tree), sym(Flame),
    ],
  )
  let solution = build_mapping(
    [
      (13, 13), (14, 14), (1, 1), (11, 11), (4, 4), (5, 5), (17, 17), (6, 6),
      (2, 2), (18, 18), (19, 19), (8, 8), (7, 7), (12, 12), (0, 0), (3, 3),
    ],
  )
  // 15% of 16 = 2-3 given
  let given = build_mapping([(4, 4), (14, 14), (19, 19)])
  {
    inscription,
    solution_mapping: solution,
    given_mapping: given,
    theme_name: "Grand Monument",
    par_guesses: 20,
    tier: Monuments,
  }
}

///|
fn tablet_20() -> @types.Tablet {
  // "THRONE FALCON BRIDGE DESERT KNIGHT ORACLE SACRED MOSAIC"
  // Too many letters beyond T(19). Simpler:
  // "FIRST STONE CRACK LIGHT DRIFT AMBER FORGE BLEND" - 8 words
  // F=Cross, I=Spiral, R=River, S=Tree, T=Flame
  // O=Sun, N=Hand, E=Star
  // C=Square, A=Circle, K=Crescent
  // L=Lightning, G=Arrow, H=Wave
  // D=Diamond, M=Eye, B=Triangle
  let inscription = @types.new_inscription(
    [
      sym(Cross), sym(Spiral), sym(River), sym(Tree), sym(Flame), gap(),
      sym(Tree), sym(Flame), sym(Sun), sym(Hand), sym(Star), gap(), sym(Square),
      sym(River), sym(Circle), sym(Square), sym(Crescent), gap(),
      sym(Lightning), sym(Spiral), sym(Arrow), sym(Wave), sym(Flame), gap(),
      sym(Diamond), sym(River), sym(Spiral), sym(Cross), sym(Flame), gap(),
      sym(Circle), sym(Eye), sym(Triangle), sym(Star), sym(River), gap(),
      sym(Cross), sym(Sun), sym(River), sym(Arrow), sym(Star), gap(),
      sym(Triangle), sym(Lightning), sym(Star), sym(Hand), sym(Diamond),
    ],
  )
  let solution = build_mapping(
    [
      (5, 5), (8, 8), (17, 17), (18, 18), (19, 19), (14, 14), (13, 13),
      (4, 4), (2, 2), (0, 0), (10, 10), (11, 11), (6, 6), (7, 7), (3, 3),
      (12, 12), (1, 1),
    ],
  )
  // 15% of 17 = 2-3 given
  let given = build_mapping([(4, 4), (14, 14)])
  {
    inscription,
    solution_mapping: solution,
    given_mapping: given,
    theme_name: "Final Cartouche",
    par_guesses: 22,
    tier: Monuments,
  }
}

///|
pub fn get_tablet(index : Int) -> @types.Tablet {
  match index {
    0 => tablet_01()
    1 => tablet_02()
    2 => tablet_03()
    3 => tablet_04()
    4 => tablet_05()
    5 => tablet_06()
    6 => tablet_07()
    7 => tablet_08()
    8 => tablet_09()
    9 => tablet_10()
    10 => tablet_11()
    11 => tablet_12()
    12 => tablet_13()
    13 => tablet_14()
    14 => tablet_15()
    15 => tablet_16()
    16 => tablet_17()
    17 => tablet_18()
    18 => tablet_19()
    _ => tablet_20()
  }
}

///|
pub fn get_tier_tablets(tier : @types.Tier) -> Array[Int] {
  let offset = @types.tier_tablet_offset(tier)
  let count = @types.tier_tablet_count(tier)
  let result : Array[Int] = []
  for i in offset..<(offset + count) {
    result.push(i)
  }
  result
}
