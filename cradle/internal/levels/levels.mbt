///|
pub fn make_all_levels() -> Array[@types.Level] {
  let levels : Array[@types.Level] = []
  // ============================================================
  // TIER 1: LINES (8 levels) - 2-3 targets, 2-4 strings
  // ============================================================

  // Level 1: "First Cross" - single X at center
  levels.push({
    peg_count: @types.peg_count,
    targets: [@types.vec2f(480.0, 360.0)],
    par_strings: 2,
    tier: Lines,
    name: "First Cross",
  })
  // Level 2: "Twin Points" - two targets on vertical axis
  levels.push({
    peg_count: @types.peg_count,
    targets: [@types.vec2f(480.0, 300.0), @types.vec2f(480.0, 420.0)],
    par_strings: 3,
    tier: Lines,
    name: "Twin Points",
  })
  // Level 3: "Side by Side" - two targets horizontal
  levels.push({
    peg_count: @types.peg_count,
    targets: [@types.vec2f(420.0, 360.0), @types.vec2f(540.0, 360.0)],
    par_strings: 3,
    tier: Lines,
    name: "Side by Side",
  })
  // Level 4: "Diagonal" - two targets on diagonal
  levels.push({
    peg_count: @types.peg_count,
    targets: [@types.vec2f(430.0, 310.0), @types.vec2f(530.0, 410.0)],
    par_strings: 3,
    tier: Lines,
    name: "Diagonal",
  })
  // Level 5: "Triangle Tip" - three targets forming a small triangle near center
  levels.push({
    peg_count: @types.peg_count,
    targets: [
      @types.vec2f(480.0, 310.0),
      @types.vec2f(440.0, 390.0),
      @types.vec2f(520.0, 390.0),
    ],
    par_strings: 4,
    tier: Lines,
    name: "Triangle Tip",
  })
  // Level 6: "Off Center" - two targets not on axes
  levels.push({
    peg_count: @types.peg_count,
    targets: [@types.vec2f(420.0, 320.0), @types.vec2f(540.0, 400.0)],
    par_strings: 3,
    tier: Lines,
    name: "Off Center",
  })
  // Level 7: "Three in Line" - three targets roughly on a line
  levels.push({
    peg_count: @types.peg_count,
    targets: [
      @types.vec2f(400.0, 360.0),
      @types.vec2f(480.0, 360.0),
      @types.vec2f(560.0, 360.0),
    ],
    par_strings: 4,
    tier: Lines,
    name: "Three in Line",
  })
  // Level 8: "Diamond Core"
  levels.push({
    peg_count: @types.peg_count,
    targets: [
      @types.vec2f(480.0, 300.0),
      @types.vec2f(540.0, 360.0),
      @types.vec2f(480.0, 420.0),
    ],
    par_strings: 4,
    tier: Lines,
    name: "Diamond Core",
  })
  // ============================================================
  // TIER 2: WEAVE (9 levels) - 4-6 targets, 4-6 strings
  // ============================================================

  // Level 9: "Square"
  levels.push({
    peg_count: @types.peg_count,
    targets: [
      @types.vec2f(440.0, 320.0),
      @types.vec2f(520.0, 320.0),
      @types.vec2f(440.0, 400.0),
      @types.vec2f(520.0, 400.0),
    ],
    par_strings: 4,
    tier: Weave,
    name: "Square",
  })
  // Level 10: "Kite"
  levels.push({
    peg_count: @types.peg_count,
    targets: [
      @types.vec2f(480.0, 280.0),
      @types.vec2f(430.0, 360.0),
      @types.vec2f(530.0, 360.0),
      @types.vec2f(480.0, 430.0),
    ],
    par_strings: 4,
    tier: Weave,
    name: "Kite",
  })
  // Level 11: "Pentagon Path"
  levels.push({
    peg_count: @types.peg_count,
    targets: [
      @types.vec2f(480.0, 290.0),
      @types.vec2f(540.0, 340.0),
      @types.vec2f(520.0, 410.0),
      @types.vec2f(440.0, 410.0),
      @types.vec2f(420.0, 340.0),
    ],
    par_strings: 5,
    tier: Weave,
    name: "Pentagon Path",
  })
  // Level 12: "Crosshatch"
  levels.push({
    peg_count: @types.peg_count,
    targets: [
      @types.vec2f(440.0, 330.0),
      @types.vec2f(520.0, 330.0),
      @types.vec2f(480.0, 360.0),
      @types.vec2f(440.0, 390.0),
      @types.vec2f(520.0, 390.0),
    ],
    par_strings: 5,
    tier: Weave,
    name: "Crosshatch",
  })
  // Level 13: "Hourglass"
  levels.push({
    peg_count: @types.peg_count,
    targets: [
      @types.vec2f(430.0, 300.0),
      @types.vec2f(530.0, 300.0),
      @types.vec2f(480.0, 360.0),
      @types.vec2f(430.0, 420.0),
      @types.vec2f(530.0, 420.0),
    ],
    par_strings: 5,
    tier: Weave,
    name: "Hourglass",
  })
  // Level 14: "Arrow"
  levels.push({
    peg_count: @types.peg_count,
    targets: [
      @types.vec2f(480.0, 290.0),
      @types.vec2f(440.0, 340.0),
      @types.vec2f(520.0, 340.0),
      @types.vec2f(480.0, 380.0),
      @types.vec2f(480.0, 430.0),
    ],
    par_strings: 5,
    tier: Weave,
    name: "Arrow",
  })
  // Level 15: "Web Center"
  levels.push({
    peg_count: @types.peg_count,
    targets: [
      @types.vec2f(480.0, 320.0),
      @types.vec2f(520.0, 350.0),
      @types.vec2f(510.0, 400.0),
      @types.vec2f(450.0, 400.0),
      @types.vec2f(440.0, 350.0),
      @types.vec2f(480.0, 370.0),
    ],
    par_strings: 6,
    tier: Weave,
    name: "Web Center",
  })
  // Level 16: "Zigzag"
  levels.push({
    peg_count: @types.peg_count,
    targets: [
      @types.vec2f(420.0, 310.0),
      @types.vec2f(500.0, 330.0),
      @types.vec2f(440.0, 360.0),
      @types.vec2f(520.0, 380.0),
      @types.vec2f(450.0, 410.0),
    ],
    par_strings: 6,
    tier: Weave,
    name: "Zigzag",
  })
  // Level 17: "Lattice"
  levels.push({
    peg_count: @types.peg_count,
    targets: [
      @types.vec2f(440.0, 320.0),
      @types.vec2f(520.0, 320.0),
      @types.vec2f(440.0, 360.0),
      @types.vec2f(520.0, 360.0),
      @types.vec2f(440.0, 400.0),
      @types.vec2f(520.0, 400.0),
    ],
    par_strings: 6,
    tier: Weave,
    name: "Lattice",
  })
  // ============================================================
  // TIER 3: ART (8 levels) - 6-8 targets, 6-8 strings
  // ============================================================

  // Level 18: "Star Points"
  levels.push({
    peg_count: @types.peg_count,
    targets: [
      @types.vec2f(480.0, 290.0),
      @types.vec2f(530.0, 330.0),
      @types.vec2f(520.0, 390.0),
      @types.vec2f(480.0, 420.0),
      @types.vec2f(440.0, 390.0),
      @types.vec2f(430.0, 330.0),
    ],
    par_strings: 6,
    tier: Art,
    name: "Star Points",
  })
  // Level 19: "Double Diamond"
  levels.push({
    peg_count: @types.peg_count,
    targets: [
      @types.vec2f(480.0, 280.0),
      @types.vec2f(530.0, 330.0),
      @types.vec2f(480.0, 360.0),
      @types.vec2f(430.0, 330.0),
      @types.vec2f(530.0, 390.0),
      @types.vec2f(480.0, 420.0),
      @types.vec2f(430.0, 390.0),
    ],
    par_strings: 7,
    tier: Art,
    name: "Double Diamond",
  })
  // Level 20: "Spiral Core"
  levels.push({
    peg_count: @types.peg_count,
    targets: [
      @types.vec2f(480.0, 310.0),
      @types.vec2f(520.0, 330.0),
      @types.vec2f(530.0, 370.0),
      @types.vec2f(510.0, 400.0),
      @types.vec2f(470.0, 410.0),
      @types.vec2f(440.0, 380.0),
      @types.vec2f(450.0, 340.0),
    ],
    par_strings: 7,
    tier: Art,
    name: "Spiral Core",
  })
  // Level 21: "Constellation"
  levels.push({
    peg_count: @types.peg_count,
    targets: [
      @types.vec2f(450.0, 300.0),
      @types.vec2f(510.0, 300.0),
      @types.vec2f(540.0, 350.0),
      @types.vec2f(520.0, 410.0),
      @types.vec2f(460.0, 420.0),
      @types.vec2f(420.0, 370.0),
      @types.vec2f(480.0, 355.0),
    ],
    par_strings: 7,
    tier: Art,
    name: "Constellation",
  })
  // Level 22: "Octagon"
  levels.push({
    peg_count: @types.peg_count,
    targets: [
      @types.vec2f(480.0, 290.0),
      @types.vec2f(530.0, 310.0),
      @types.vec2f(545.0, 360.0),
      @types.vec2f(530.0, 410.0),
      @types.vec2f(480.0, 430.0),
      @types.vec2f(430.0, 410.0),
      @types.vec2f(415.0, 360.0),
      @types.vec2f(430.0, 310.0),
    ],
    par_strings: 8,
    tier: Art,
    name: "Octagon",
  })
  // Level 23: "Mandala"
  levels.push({
    peg_count: @types.peg_count,
    targets: [
      @types.vec2f(480.0, 300.0),
      @types.vec2f(530.0, 330.0),
      @types.vec2f(530.0, 390.0),
      @types.vec2f(480.0, 420.0),
      @types.vec2f(430.0, 390.0),
      @types.vec2f(430.0, 330.0),
      @types.vec2f(480.0, 360.0),
      @types.vec2f(505.0, 345.0),
    ],
    par_strings: 8,
    tier: Art,
    name: "Mandala",
  })
  // Level 24: "Starburst"
  levels.push({
    peg_count: @types.peg_count,
    targets: [
      @types.vec2f(480.0, 295.0),
      @types.vec2f(535.0, 320.0),
      @types.vec2f(545.0, 375.0),
      @types.vec2f(515.0, 415.0),
      @types.vec2f(460.0, 420.0),
      @types.vec2f(425.0, 385.0),
      @types.vec2f(430.0, 325.0),
      @types.vec2f(470.0, 350.0),
    ],
    par_strings: 8,
    tier: Art,
    name: "Starburst",
  })
  // Level 25: "Masterpiece"
  levels.push({
    peg_count: @types.peg_count,
    targets: [
      @types.vec2f(460.0, 300.0),
      @types.vec2f(500.0, 300.0),
      @types.vec2f(535.0, 340.0),
      @types.vec2f(535.0, 380.0),
      @types.vec2f(500.0, 420.0),
      @types.vec2f(460.0, 420.0),
      @types.vec2f(425.0, 380.0),
      @types.vec2f(425.0, 340.0),
    ],
    par_strings: 8,
    tier: Art,
    name: "Masterpiece",
  })
  levels
}
