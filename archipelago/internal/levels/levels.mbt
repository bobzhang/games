///|
fn mk(grid : Int, islands : Array[@types.Island], par : Int) -> @types.Level {
  { grid_size: grid, islands, par_bridges: par }
}

///|
fn isl(x : Int, y : Int, c : Int) -> @types.Island {
  @types.island(x, y, c)
}

// ========== Tier 1: Shores (8 levels, 5x5, 4-6 islands) ==========

///|
fn level_01() -> @types.Level {
  mk(5, [isl(0, 0, 2), isl(4, 0, 2), isl(0, 4, 2), isl(4, 4, 2)], 4)
}

///|
fn level_02() -> @types.Level {
  mk(
    5,
    [isl(0, 0, 2), isl(2, 0, 3), isl(4, 0, 1), isl(0, 2, 1), isl(2, 2, 1)],
    5,
  )
}

///|
fn level_03() -> @types.Level {
  mk(
    5,
    [
      isl(1, 0, 2),
      isl(3, 0, 2),
      isl(0, 2, 2),
      isl(4, 2, 2),
      isl(1, 4, 2),
      isl(3, 4, 2),
    ],
    6,
  )
}

///|
fn level_04() -> @types.Level {
  mk(
    5,
    [isl(0, 0, 1), isl(2, 0, 3), isl(4, 0, 2), isl(2, 2, 2), isl(2, 4, 2)],
    5,
  )
}

///|
fn level_05() -> @types.Level {
  mk(
    5,
    [
      isl(0, 0, 3),
      isl(4, 0, 1),
      isl(0, 2, 2),
      isl(2, 2, 3),
      isl(4, 2, 2),
      isl(2, 4, 1),
    ],
    6,
  )
}

///|
fn level_06() -> @types.Level {
  mk(
    5,
    [isl(0, 0, 2), isl(2, 0, 2), isl(4, 0, 2), isl(0, 4, 2), isl(2, 4, 2)],
    5,
  )
}

///|
fn level_07() -> @types.Level {
  mk(
    5,
    [
      isl(0, 0, 2),
      isl(4, 0, 3),
      isl(0, 2, 2),
      isl(4, 2, 3),
      isl(0, 4, 2),
      isl(4, 4, 2),
    ],
    7,
  )
}

///|
fn level_08() -> @types.Level {
  mk(
    5,
    [
      isl(0, 0, 2),
      isl(3, 0, 3),
      isl(0, 2, 3),
      isl(3, 2, 4),
      isl(0, 4, 1),
      isl(3, 4, 1),
    ],
    7,
  )
}

// ========== Tier 2: Straits (9 levels, 7x7, 8-12 islands) ==========

///|
fn level_09() -> @types.Level {
  mk(
    7,
    [
      isl(0, 0, 2),
      isl(3, 0, 2),
      isl(6, 0, 2),
      isl(0, 3, 2),
      isl(3, 3, 4),
      isl(6, 3, 2),
      isl(0, 6, 2),
      isl(3, 6, 2),
      isl(6, 6, 2),
    ],
    10,
  )
}

///|
fn level_10() -> @types.Level {
  mk(
    7,
    [
      isl(1, 0, 2),
      isl(5, 0, 2),
      isl(0, 2, 2),
      isl(3, 2, 4),
      isl(6, 2, 2),
      isl(1, 4, 2),
      isl(5, 4, 2),
      isl(3, 6, 2),
    ],
    9,
  )
}

///|
fn level_11() -> @types.Level {
  mk(
    7,
    [
      isl(0, 0, 3),
      isl(3, 0, 3),
      isl(6, 0, 1),
      isl(0, 3, 3),
      isl(3, 3, 4),
      isl(6, 3, 3),
      isl(0, 6, 1),
      isl(3, 6, 3),
      isl(6, 6, 3),
    ],
    12,
  )
}

///|
fn level_12() -> @types.Level {
  mk(
    7,
    [
      isl(0, 0, 2),
      isl(2, 0, 3),
      isl(5, 0, 1),
      isl(0, 2, 1),
      isl(2, 2, 3),
      isl(5, 2, 3),
      isl(0, 5, 2),
      isl(2, 5, 3),
      isl(5, 5, 2),
    ],
    10,
  )
}

///|
fn level_13() -> @types.Level {
  mk(
    7,
    [
      isl(0, 0, 2),
      isl(3, 0, 4),
      isl(6, 0, 2),
      isl(0, 3, 2),
      isl(6, 3, 2),
      isl(0, 6, 2),
      isl(3, 6, 4),
      isl(6, 6, 2),
      isl(3, 3, 4),
    ],
    12,
  )
}

///|
fn level_14() -> @types.Level {
  mk(
    7,
    [
      isl(1, 0, 3),
      isl(4, 0, 2),
      isl(0, 2, 2),
      isl(3, 2, 5),
      isl(6, 2, 3),
      isl(1, 4, 3),
      isl(4, 4, 4),
      isl(0, 6, 2),
      isl(3, 6, 2),
      isl(6, 6, 2),
    ],
    14,
  )
}

///|
fn level_15() -> @types.Level {
  mk(
    7,
    [
      isl(0, 0, 1),
      isl(2, 0, 3),
      isl(5, 0, 2),
      isl(0, 3, 3),
      isl(2, 3, 4),
      isl(5, 3, 4),
      isl(0, 6, 2),
      isl(2, 6, 3),
      isl(5, 6, 2),
      isl(5, 1, 2),
    ],
    13,
  )
}

///|
fn level_16() -> @types.Level {
  mk(
    7,
    [
      isl(0, 0, 2),
      isl(3, 0, 4),
      isl(6, 0, 2),
      isl(1, 2, 3),
      isl(4, 2, 3),
      isl(0, 4, 2),
      isl(3, 4, 4),
      isl(6, 4, 2),
      isl(1, 6, 2),
      isl(5, 6, 2),
      isl(3, 2, 2),
    ],
    14,
  )
}

///|
fn level_17() -> @types.Level {
  mk(
    7,
    [
      isl(0, 0, 3),
      isl(4, 0, 3),
      isl(6, 0, 2),
      isl(0, 2, 2),
      isl(2, 2, 4),
      isl(4, 2, 4),
      isl(6, 2, 2),
      isl(0, 5, 2),
      isl(2, 5, 2),
      isl(4, 5, 2),
      isl(6, 5, 2),
      isl(2, 0, 2),
    ],
    15,
  )
}

// ========== Tier 3: Ocean (8 levels, 9x9, 12-18 islands) ==========

///|
fn level_18() -> @types.Level {
  mk(
    9,
    [
      isl(0, 0, 2),
      isl(4, 0, 4),
      isl(8, 0, 2),
      isl(0, 3, 3),
      isl(4, 3, 6),
      isl(8, 3, 3),
      isl(0, 6, 2),
      isl(4, 6, 4),
      isl(8, 6, 2),
      isl(2, 1, 2),
      isl(6, 1, 2),
      isl(2, 5, 2),
      isl(6, 5, 2),
      isl(4, 8, 2),
    ],
    19,
  )
}

///|
fn level_19() -> @types.Level {
  mk(
    9,
    [
      isl(0, 0, 2),
      isl(3, 0, 3),
      isl(6, 0, 2),
      isl(8, 0, 2),
      isl(0, 3, 3),
      isl(3, 3, 5),
      isl(6, 3, 4),
      isl(8, 3, 2),
      isl(0, 6, 2),
      isl(3, 6, 4),
      isl(6, 6, 3),
      isl(8, 6, 2),
      isl(0, 8, 2),
      isl(3, 8, 2),
      isl(8, 8, 2),
    ],
    20,
  )
}

///|
fn level_20() -> @types.Level {
  mk(
    9,
    [
      isl(0, 0, 3),
      isl(4, 0, 4),
      isl(8, 0, 2),
      isl(0, 2, 2),
      isl(2, 2, 3),
      isl(6, 2, 3),
      isl(8, 2, 2),
      isl(0, 5, 3),
      isl(2, 5, 4),
      isl(4, 5, 3),
      isl(6, 5, 3),
      isl(8, 5, 2),
      isl(0, 8, 2),
      isl(4, 8, 4),
      isl(8, 8, 2),
    ],
    21,
  )
}

///|
fn level_21() -> @types.Level {
  mk(
    9,
    [
      isl(0, 0, 2),
      isl(2, 0, 3),
      isl(5, 0, 3),
      isl(8, 0, 2),
      isl(0, 3, 3),
      isl(2, 3, 5),
      isl(5, 3, 5),
      isl(8, 3, 3),
      isl(0, 6, 2),
      isl(2, 6, 3),
      isl(5, 6, 3),
      isl(8, 6, 2),
      isl(2, 8, 1),
      isl(5, 8, 1),
    ],
    19,
  )
}

///|
fn level_22() -> @types.Level {
  mk(
    9,
    [
      isl(0, 0, 2),
      isl(3, 0, 4),
      isl(6, 0, 2),
      isl(8, 0, 2),
      isl(0, 2, 3),
      isl(3, 2, 4),
      isl(6, 2, 4),
      isl(8, 2, 3),
      isl(1, 4, 3),
      isl(4, 4, 4),
      isl(7, 4, 3),
      isl(0, 6, 2),
      isl(3, 6, 4),
      isl(6, 6, 4),
      isl(8, 6, 2),
      isl(0, 8, 2),
      isl(3, 8, 2),
      isl(8, 8, 2),
    ],
    26,
  )
}

///|
fn level_23() -> @types.Level {
  mk(
    9,
    [
      isl(0, 0, 3),
      isl(2, 0, 2),
      isl(5, 0, 4),
      isl(8, 0, 2),
      isl(0, 2, 3),
      isl(2, 2, 4),
      isl(5, 2, 4),
      isl(8, 2, 3),
      isl(0, 5, 3),
      isl(2, 5, 4),
      isl(5, 5, 4),
      isl(8, 5, 3),
      isl(0, 8, 2),
      isl(2, 8, 3),
      isl(5, 8, 2),
      isl(8, 8, 2),
    ],
    24,
  )
}

///|
fn level_24() -> @types.Level {
  mk(
    9,
    [
      isl(0, 0, 2),
      isl(4, 0, 4),
      isl(8, 0, 2),
      isl(0, 2, 2),
      isl(2, 2, 4),
      isl(4, 2, 4),
      isl(6, 2, 4),
      isl(8, 2, 2),
      isl(0, 5, 2),
      isl(2, 5, 4),
      isl(4, 5, 6),
      isl(6, 5, 4),
      isl(8, 5, 2),
      isl(0, 8, 2),
      isl(4, 8, 4),
      isl(8, 8, 2),
    ],
    25,
  )
}

///|
fn level_25() -> @types.Level {
  mk(
    9,
    [
      isl(0, 0, 3),
      isl(3, 0, 4),
      isl(6, 0, 3),
      isl(8, 0, 2),
      isl(0, 2, 3),
      isl(3, 2, 6),
      isl(6, 2, 5),
      isl(8, 2, 3),
      isl(0, 5, 3),
      isl(3, 5, 6),
      isl(6, 5, 5),
      isl(8, 5, 3),
      isl(0, 8, 2),
      isl(3, 8, 4),
      isl(6, 8, 2),
      isl(8, 8, 2),
      isl(1, 4, 1),
      isl(5, 4, 1),
    ],
    29,
  )
}

///|
pub fn get_level(index : Int) -> @types.Level {
  match index {
    0 => level_01()
    1 => level_02()
    2 => level_03()
    3 => level_04()
    4 => level_05()
    5 => level_06()
    6 => level_07()
    7 => level_08()
    8 => level_09()
    9 => level_10()
    10 => level_11()
    11 => level_12()
    12 => level_13()
    13 => level_14()
    14 => level_15()
    15 => level_16()
    16 => level_17()
    17 => level_18()
    18 => level_19()
    19 => level_20()
    20 => level_21()
    21 => level_22()
    22 => level_23()
    23 => level_24()
    24 => level_25()
    _ => level_01()
  }
}
