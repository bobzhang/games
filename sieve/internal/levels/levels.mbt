///|
fn make_level(
  tier : @types.Tier,
  level_index : Int,
  prefilled : Array[(Int, Int, Int)],
  constraints : Array[@types.Constraint],
  par_time : Float,
) -> @types.Level {
  let grid = @types.new_grid()
  for i in 0..<prefilled.length() {
    let (row, col, val) = prefilled[i]
    @types.grid_set(grid, row, col, val)
    @types.grid_lock(grid, row, col)
  }
  { tier, grid, constraints, par_time, level_index, }
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
    _ => level_25()
  }
}

// ==========================================
// TIER 1: PRIMES (Levels 1-8)
// RowSum + Unique only, 3-4 empty cells
// ==========================================

///|
fn level_01() -> @types.Level {
  // Row 0: 1+2+3+4+5=15, Row 1 sum=20
  make_level(
    Primes,
    0,
    [
      (0, 0, 1),
      (0, 1, 2),
      (0, 3, 4),
      (0, 4, 5),
      (1, 0, 3),
      (1, 1, 5),
      (1, 2, 4),
      (1, 4, 6),
      (2, 0, 2),
      (2, 1, 4),
      (2, 2, 6),
      (2, 3, 1),
      (2, 4, 8),
      (3, 0, 5),
      (3, 1, 1),
      (3, 2, 7),
      (3, 3, 3),
      (3, 4, 9),
      (4, 0, 4),
      (4, 1, 3),
      (4, 2, 8),
      (4, 3, 2),
    ],
    [
      @types.new_constraint(RowSum, [0, 15]),
      @types.new_constraint(RowSum, [1, 20]),
      @types.new_constraint(Unique, [0, 0]),
    ],
    60.0,
  )
}

///|
fn level_02() -> @types.Level {
  make_level(
    Primes,
    1,
    [
      (0, 0, 3),
      (0, 2, 1),
      (0, 3, 7),
      (0, 4, 4),
      (1, 0, 5),
      (1, 1, 8),
      (1, 2, 2),
      (1, 3, 1),
      (1, 4, 9),
      (2, 0, 7),
      (2, 1, 4),
      (2, 2, 9),
      (2, 3, 3),
      (2, 4, 2),
      (3, 0, 1),
      (3, 1, 6),
      (3, 3, 8),
      (3, 4, 3),
      (4, 0, 9),
      (4, 1, 2),
      (4, 2, 4),
      (4, 3, 5),
    ],
    [
      @types.new_constraint(RowSum, [0, 20]),
      @types.new_constraint(RowSum, [3, 23]),
      @types.new_constraint(Unique, [0, 0]),
    ],
    60.0,
  )
}

///|
fn level_03() -> @types.Level {
  make_level(
    Primes,
    2,
    [
      (0, 0, 2),
      (0, 1, 5),
      (0, 2, 3),
      (0, 4, 8),
      (1, 0, 6),
      (1, 1, 1),
      (1, 2, 7),
      (1, 3, 9),
      (1, 4, 2),
      (2, 0, 8),
      (2, 1, 3),
      (2, 3, 4),
      (2, 4, 6),
      (3, 0, 4),
      (3, 1, 9),
      (3, 2, 1),
      (3, 3, 6),
      (3, 4, 5),
      (4, 0, 1),
      (4, 1, 7),
      (4, 2, 8),
      (4, 3, 2),
      (4, 4, 3),
    ],
    [
      @types.new_constraint(RowSum, [0, 19]),
      @types.new_constraint(RowSum, [2, 26]),
      @types.new_constraint(Unique, [0, 0]),
    ],
    55.0,
  )
}

///|
fn level_04() -> @types.Level {
  make_level(
    Primes,
    3,
    [
      (0, 0, 4),
      (0, 1, 7),
      (0, 2, 2),
      (0, 3, 9),
      (0, 4, 3),
      (1, 0, 8),
      (1, 2, 5),
      (1, 3, 3),
      (1, 4, 1),
      (2, 0, 6),
      (2, 1, 3),
      (2, 2, 9),
      (2, 3, 1),
      (2, 4, 7),
      (3, 0, 2),
      (3, 1, 1),
      (3, 2, 4),
      (3, 4, 8),
      (4, 0, 9),
      (4, 1, 5),
      (4, 2, 8),
      (4, 3, 4),
    ],
    [
      @types.new_constraint(RowSum, [1, 23]),
      @types.new_constraint(RowSum, [3, 21]),
      @types.new_constraint(RowSum, [4, 29]),
      @types.new_constraint(Unique, [0, 1]),
    ],
    50.0,
  )
}

///|
fn level_05() -> @types.Level {
  make_level(
    Primes,
    4,
    [
      (0, 0, 5),
      (0, 1, 1),
      (0, 2, 9),
      (0, 3, 3),
      (0, 4, 7),
      (1, 0, 3),
      (1, 1, 7),
      (1, 3, 8),
      (1, 4, 4),
      (2, 0, 1),
      (2, 1, 9),
      (2, 2, 4),
      (2, 3, 6),
      (2, 4, 5),
      (3, 0, 7),
      (3, 1, 4),
      (3, 2, 6),
      (3, 3, 1),
      (3, 4, 2),
      (4, 0, 8),
      (4, 1, 6),
      (4, 3, 2),
      (4, 4, 9),
    ],
    [
      @types.new_constraint(RowSum, [1, 24]),
      @types.new_constraint(RowSum, [4, 28]),
      @types.new_constraint(Unique, [0, 1]),
      @types.new_constraint(Unique, [0, 4]),
    ],
    50.0,
  )
}

///|
fn level_06() -> @types.Level {
  make_level(
    Primes,
    5,
    [
      (0, 1, 8),
      (0, 2, 6),
      (0, 3, 1),
      (0, 4, 2),
      (1, 0, 4),
      (1, 1, 3),
      (1, 2, 7),
      (1, 3, 5),
      (1, 4, 6),
      (2, 0, 6),
      (2, 1, 9),
      (2, 2, 1),
      (2, 3, 8),
      (2, 4, 3),
      (3, 0, 2),
      (3, 1, 5),
      (3, 3, 9),
      (3, 4, 1),
      (4, 0, 1),
      (4, 1, 7),
      (4, 2, 3),
      (4, 3, 4),
    ],
    [
      @types.new_constraint(RowSum, [0, 21]),
      @types.new_constraint(RowSum, [3, 21]),
      @types.new_constraint(RowSum, [4, 20]),
      @types.new_constraint(Unique, [0, 0]),
    ],
    45.0,
  )
}

///|
fn level_07() -> @types.Level {
  make_level(
    Primes,
    6,
    [
      (0, 0, 9),
      (0, 1, 2),
      (0, 2, 5),
      (0, 3, 8),
      (0, 4, 1),
      (1, 0, 7),
      (1, 2, 3),
      (1, 3, 6),
      (1, 4, 9),
      (2, 0, 3),
      (2, 1, 8),
      (2, 2, 1),
      (2, 3, 4),
      (2, 4, 7),
      (3, 0, 5),
      (3, 1, 6),
      (3, 2, 9),
      (3, 3, 2),
      (4, 0, 1),
      (4, 1, 4),
      (4, 2, 7),
      (4, 4, 6),
    ],
    [
      @types.new_constraint(RowSum, [1, 29]),
      @types.new_constraint(RowSum, [3, 25]),
      @types.new_constraint(RowSum, [4, 21]),
      @types.new_constraint(Unique, [0, 1]),
    ],
    45.0,
  )
}

///|
fn level_08() -> @types.Level {
  make_level(
    Primes,
    7,
    [
      (0, 0, 6),
      (0, 2, 8),
      (0, 3, 5),
      (0, 4, 2),
      (1, 0, 3),
      (1, 1, 9),
      (1, 2, 1),
      (1, 3, 7),
      (1, 4, 5),
      (2, 0, 8),
      (2, 1, 2),
      (2, 2, 4),
      (2, 3, 9),
      (2, 4, 1),
      (3, 0, 1),
      (3, 1, 5),
      (3, 2, 7),
      (3, 3, 3),
      (3, 4, 8),
      (4, 0, 9),
      (4, 1, 4),
      (4, 3, 6),
    ],
    [
      @types.new_constraint(RowSum, [0, 25]),
      @types.new_constraint(RowSum, [4, 25]),
      @types.new_constraint(Unique, [0, 0]),
      @types.new_constraint(Unique, [0, 4]),
    ],
    40.0,
  )
}

// ==========================================
// TIER 2: FACTORS (Levels 9-17)
// + ColProduct + Adjacent + Divisible, 5-7 empty cells
// ==========================================

///|
fn level_09() -> @types.Level {
  make_level(
    Factors,
    8,
    [
      (0, 0, 2),
      (0, 2, 1),
      (0, 3, 4),
      (0, 4, 6),
      (1, 0, 3),
      (1, 1, 5),
      (1, 3, 2),
      (1, 4, 1),
      (2, 0, 4),
      (2, 1, 1),
      (2, 2, 6),
      (2, 3, 8),
      (2, 4, 3),
      (3, 1, 8),
      (3, 2, 2),
      (3, 3, 1),
      (3, 4, 9),
      (4, 0, 1),
      (4, 1, 6),
      (4, 2, 9),
      (4, 3, 3),
    ],
    [
      @types.new_constraint(RowSum, [0, 16]),
      @types.new_constraint(RowSum, [1, 15]),
      @types.new_constraint(Adjacent, [0, 0, 0, 1]),
      @types.new_constraint(Unique, [0, 0]),
      @types.new_constraint(Unique, [0, 1]),
    ],
    90.0,
  )
}

///|
fn level_10() -> @types.Level {
  make_level(
    Factors,
    9,
    [
      (0, 0, 1),
      (0, 1, 3),
      (0, 2, 5),
      (0, 3, 7),
      (0, 4, 9),
      (1, 0, 2),
      (1, 2, 6),
      (1, 3, 4),
      (1, 4, 8),
      (2, 0, 9),
      (2, 1, 7),
      (2, 3, 1),
      (2, 4, 5),
      (3, 0, 4),
      (3, 1, 8),
      (3, 2, 1),
      (3, 3, 6),
      (3, 4, 3),
      (4, 0, 6),
      (4, 1, 5),
      (4, 3, 9),
    ],
    [
      @types.new_constraint(RowSum, [1, 23]),
      @types.new_constraint(RowSum, [2, 25]),
      @types.new_constraint(RowSum, [4, 24]),
      @types.new_constraint(Divisible, [1, 2, 1, 0]),
      @types.new_constraint(Unique, [0, 0]),
    ],
    80.0,
  )
}

///|
fn level_11() -> @types.Level {
  make_level(
    Factors,
    10,
    [
      (0, 0, 4),
      (0, 1, 2),
      (0, 2, 8),
      (0, 4, 1),
      (1, 0, 6),
      (1, 1, 9),
      (1, 2, 3),
      (1, 3, 1),
      (1, 4, 5),
      (2, 0, 1),
      (2, 2, 7),
      (2, 3, 9),
      (2, 4, 4),
      (3, 0, 8),
      (3, 1, 7),
      (3, 2, 5),
      (3, 3, 4),
      (3, 4, 2),
      (4, 0, 9),
      (4, 1, 1),
      (4, 3, 6),
    ],
    [
      @types.new_constraint(RowSum, [0, 21]),
      @types.new_constraint(RowSum, [4, 23]),
      @types.new_constraint(Adjacent, [2, 0, 2, 1]),
      @types.new_constraint(Divisible, [0, 2, 0, 0]),
      @types.new_constraint(Unique, [0, 2]),
    ],
    80.0,
  )
}

///|
fn level_12() -> @types.Level {
  make_level(
    Factors,
    11,
    [
      (0, 0, 3),
      (0, 1, 6),
      (0, 3, 9),
      (0, 4, 2),
      (1, 1, 1),
      (1, 2, 8),
      (1, 3, 5),
      (1, 4, 7),
      (2, 0, 9),
      (2, 1, 4),
      (2, 2, 2),
      (2, 3, 7),
      (2, 4, 3),
      (3, 0, 7),
      (3, 1, 8),
      (3, 2, 5),
      (3, 3, 1),
      (3, 4, 6),
      (4, 0, 1),
      (4, 2, 9),
      (4, 4, 8),
    ],
    [
      @types.new_constraint(RowSum, [0, 25]),
      @types.new_constraint(RowSum, [1, 25]),
      @types.new_constraint(RowSum, [4, 27]),
      @types.new_constraint(Adjacent, [0, 0, 0, 1]),
      @types.new_constraint(Divisible, [0, 1, 0, 0]),
      @types.new_constraint(Unique, [0, 0]),
    ],
    75.0,
  )
}

///|
fn level_13() -> @types.Level {
  make_level(
    Factors,
    12,
    [
      (0, 0, 5),
      (0, 1, 1),
      (0, 2, 4),
      (0, 3, 8),
      (0, 4, 7),
      (1, 0, 2),
      (1, 2, 9),
      (1, 3, 3),
      (2, 0, 8),
      (2, 1, 7),
      (2, 3, 1),
      (2, 4, 9),
      (3, 0, 1),
      (3, 1, 4),
      (3, 2, 6),
      (3, 3, 5),
      (3, 4, 3),
      (4, 0, 9),
      (4, 1, 6),
      (4, 2, 3),
      (4, 3, 2),
    ],
    [
      @types.new_constraint(RowSum, [1, 21]),
      @types.new_constraint(RowSum, [2, 30]),
      @types.new_constraint(RowSum, [4, 25]),
      @types.new_constraint(Adjacent, [1, 0, 1, 1]),
      @types.new_constraint(Divisible, [2, 3, 2, 0]),
    ],
    75.0,
  )
}

///|
fn level_14() -> @types.Level {
  make_level(
    Factors,
    13,
    [
      (0, 0, 7),
      (0, 1, 4),
      (0, 3, 2),
      (0, 4, 9),
      (1, 0, 1),
      (1, 1, 8),
      (1, 2, 5),
      (1, 4, 6),
      (2, 0, 9),
      (2, 1, 2),
      (2, 2, 3),
      (2, 3, 6),
      (2, 4, 1),
      (3, 0, 4),
      (3, 1, 6),
      (3, 2, 1),
      (3, 3, 8),
      (3, 4, 5),
      (4, 0, 5),
      (4, 2, 8),
      (4, 3, 4),
    ],
    [
      @types.new_constraint(RowSum, [0, 25]),
      @types.new_constraint(RowSum, [1, 23]),
      @types.new_constraint(RowSum, [4, 23]),
      @types.new_constraint(Divisible, [0, 3, 0, 0]),
      @types.new_constraint(Adjacent, [4, 0, 4, 1]),
      @types.new_constraint(Unique, [0, 0]),
    ],
    70.0,
  )
}

///|
fn level_15() -> @types.Level {
  make_level(
    Factors,
    14,
    [
      (0, 0, 8),
      (0, 1, 3),
      (0, 2, 6),
      (0, 3, 1),
      (0, 4, 7),
      (1, 1, 9),
      (1, 2, 2),
      (1, 3, 7),
      (1, 4, 4),
      (2, 0, 6),
      (2, 2, 1),
      (2, 3, 9),
      (2, 4, 8),
      (3, 0, 1),
      (3, 1, 7),
      (3, 3, 4),
      (3, 4, 2),
      (4, 0, 9),
      (4, 1, 4),
      (4, 2, 8),
      (4, 3, 3),
    ],
    [
      @types.new_constraint(RowSum, [1, 27]),
      @types.new_constraint(RowSum, [2, 27]),
      @types.new_constraint(RowSum, [3, 20]),
      @types.new_constraint(RowSum, [4, 29]),
      @types.new_constraint(Adjacent, [2, 0, 2, 1]),
      @types.new_constraint(Divisible, [3, 3, 3, 4]),
    ],
    65.0,
  )
}

///|
fn level_16() -> @types.Level {
  make_level(
    Factors,
    15,
    [
      (0, 0, 2),
      (0, 2, 4),
      (0, 3, 8),
      (0, 4, 5),
      (1, 0, 7),
      (1, 1, 6),
      (1, 3, 2),
      (1, 4, 9),
      (2, 0, 5),
      (2, 1, 8),
      (2, 2, 1),
      (2, 3, 3),
      (2, 4, 6),
      (3, 0, 9),
      (3, 2, 7),
      (3, 3, 1),
      (3, 4, 4),
      (4, 0, 4),
      (4, 1, 1),
      (4, 2, 6),
      (4, 3, 9),
    ],
    [
      @types.new_constraint(RowSum, [0, 22]),
      @types.new_constraint(RowSum, [1, 27]),
      @types.new_constraint(RowSum, [3, 24]),
      @types.new_constraint(RowSum, [4, 22]),
      @types.new_constraint(Adjacent, [3, 0, 3, 1]),
      @types.new_constraint(Divisible, [0, 2, 0, 0]),
      @types.new_constraint(Unique, [0, 0]),
    ],
    60.0,
  )
}

///|
fn level_17() -> @types.Level {
  make_level(
    Factors,
    16,
    [
      (0, 0, 1),
      (0, 1, 5),
      (0, 3, 9),
      (0, 4, 3),
      (1, 0, 8),
      (1, 2, 4),
      (1, 3, 6),
      (1, 4, 1),
      (2, 0, 3),
      (2, 1, 7),
      (2, 2, 9),
      (2, 3, 2),
      (2, 4, 5),
      (3, 1, 4),
      (3, 2, 1),
      (3, 3, 8),
      (3, 4, 7),
      (4, 0, 9),
      (4, 1, 8),
      (4, 2, 6),
      (4, 4, 4),
    ],
    [
      @types.new_constraint(RowSum, [0, 25]),
      @types.new_constraint(RowSum, [1, 26]),
      @types.new_constraint(RowSum, [3, 26]),
      @types.new_constraint(RowSum, [4, 30]),
      @types.new_constraint(Divisible, [1, 2, 1, 0]),
      @types.new_constraint(Adjacent, [0, 0, 0, 1]),
      @types.new_constraint(Unique, [0, 2]),
    ],
    55.0,
  )
}

// ==========================================
// TIER 3: THEOREM (Levels 18-25)
// All constraints, 7-10 empty cells, tight solutions
// ==========================================

///|
fn level_18() -> @types.Level {
  make_level(
    Theorem,
    17,
    [
      (0, 0, 4),
      (0, 2, 6),
      (0, 4, 8),
      (1, 1, 3),
      (1, 3, 9),
      (2, 0, 2),
      (2, 2, 1),
      (2, 4, 5),
      (3, 1, 7),
      (3, 3, 4),
      (4, 0, 6),
      (4, 1, 1),
      (4, 2, 8),
      (4, 3, 2),
      (4, 4, 9),
    ],
    [
      @types.new_constraint(RowSum, [0, 29]),
      @types.new_constraint(RowSum, [4, 26]),
      @types.new_constraint(NoPrimePair, [0]),
      @types.new_constraint(Adjacent, [0, 0, 1, 0]),
      @types.new_constraint(Divisible, [0, 4, 0, 0]),
      @types.new_constraint(Unique, [0, 0]),
      @types.new_constraint(Unique, [0, 2]),
    ],
    120.0,
  )
}

///|
fn level_19() -> @types.Level {
  make_level(
    Theorem,
    18,
    [
      (0, 0, 9),
      (0, 3, 1),
      (0, 4, 4),
      (1, 0, 6),
      (1, 2, 8),
      (1, 4, 2),
      (2, 1, 5),
      (2, 2, 3),
      (2, 3, 7),
      (3, 0, 8),
      (3, 1, 4),
      (3, 4, 6),
      (4, 0, 1),
      (4, 2, 9),
      (4, 3, 5),
      (4, 4, 3),
    ],
    [
      @types.new_constraint(RowSum, [0, 23]),
      @types.new_constraint(RowSum, [1, 23]),
      @types.new_constraint(NoPrimePair, [2]),
      @types.new_constraint(Adjacent, [3, 0, 3, 1]),
      @types.new_constraint(Divisible, [1, 0, 1, 4]),
      @types.new_constraint(Unique, [0, 0]),
      @types.new_constraint(Unique, [0, 4]),
    ],
    110.0,
  )
}

///|
fn level_20() -> @types.Level {
  make_level(
    Theorem,
    19,
    [
      (0, 1, 6),
      (0, 3, 4),
      (1, 0, 8),
      (1, 2, 1),
      (1, 4, 5),
      (2, 1, 9),
      (2, 3, 2),
      (3, 0, 4),
      (3, 2, 7),
      (3, 4, 1),
      (4, 0, 1),
      (4, 1, 2),
      (4, 2, 5),
      (4, 3, 8),
      (4, 4, 9),
    ],
    [
      @types.new_constraint(RowSum, [1, 21]),
      @types.new_constraint(RowSum, [4, 25]),
      @types.new_constraint(NoPrimePair, [2]),
      @types.new_constraint(Adjacent, [0, 1, 0, 2]),
      @types.new_constraint(Divisible, [3, 2, 3, 4]),
      @types.new_constraint(Unique, [0, 1]),
      @types.new_constraint(Unique, [0, 3]),
    ],
    110.0,
  )
}

///|
fn level_21() -> @types.Level {
  make_level(
    Theorem,
    20,
    [
      (0, 0, 1),
      (0, 4, 9),
      (1, 1, 8),
      (1, 3, 4),
      (2, 0, 6),
      (2, 2, 3),
      (2, 4, 7),
      (3, 1, 2),
      (3, 3, 9),
      (4, 0, 5),
      (4, 1, 4),
      (4, 2, 8),
      (4, 3, 1),
      (4, 4, 6),
    ],
    [
      @types.new_constraint(RowSum, [0, 24]),
      @types.new_constraint(RowSum, [2, 25]),
      @types.new_constraint(RowSum, [4, 24]),
      @types.new_constraint(NoPrimePair, [1]),
      @types.new_constraint(Adjacent, [0, 0, 1, 0]),
      @types.new_constraint(Divisible, [2, 0, 2, 2]),
      @types.new_constraint(Unique, [0, 0]),
      @types.new_constraint(Unique, [0, 4]),
    ],
    100.0,
  )
}

///|
fn level_22() -> @types.Level {
  make_level(
    Theorem,
    21,
    [
      (0, 0, 8),
      (0, 3, 6),
      (1, 1, 1),
      (1, 4, 3),
      (2, 0, 4),
      (2, 2, 9),
      (3, 1, 5),
      (3, 3, 8),
      (3, 4, 1),
      (4, 0, 2),
      (4, 1, 7),
      (4, 2, 4),
      (4, 3, 3),
      (4, 4, 9),
    ],
    [
      @types.new_constraint(RowSum, [0, 28]),
      @types.new_constraint(RowSum, [4, 25]),
      @types.new_constraint(NoPrimePair, [1]),
      @types.new_constraint(NoPrimePair, [3]),
      @types.new_constraint(Adjacent, [2, 0, 2, 1]),
      @types.new_constraint(Divisible, [0, 0, 0, 3]),
      @types.new_constraint(Unique, [0, 0]),
      @types.new_constraint(Unique, [0, 2]),
    ],
    100.0,
  )
}

///|
fn level_23() -> @types.Level {
  make_level(
    Theorem,
    22,
    [
      (0, 0, 3),
      (0, 4, 7),
      (1, 2, 6),
      (1, 3, 1),
      (2, 0, 9),
      (2, 1, 4),
      (2, 4, 8),
      (3, 1, 6),
      (3, 3, 9),
      (4, 0, 7),
      (4, 2, 1),
      (4, 3, 4),
      (4, 4, 2),
    ],
    [
      @types.new_constraint(RowSum, [0, 25]),
      @types.new_constraint(RowSum, [2, 28]),
      @types.new_constraint(RowSum, [4, 20]),
      @types.new_constraint(NoPrimePair, [0]),
      @types.new_constraint(NoPrimePair, [3]),
      @types.new_constraint(Adjacent, [1, 2, 1, 3]),
      @types.new_constraint(Divisible, [2, 0, 2, 1]),
      @types.new_constraint(Unique, [0, 0]),
    ],
    95.0,
  )
}

///|
fn level_24() -> @types.Level {
  make_level(
    Theorem,
    23,
    [
      (0, 1, 9),
      (0, 3, 1),
      (1, 0, 4),
      (1, 4, 8),
      (2, 2, 5),
      (2, 3, 6),
      (3, 0, 6),
      (3, 1, 1),
      (3, 4, 4),
      (4, 0, 8),
      (4, 1, 3),
      (4, 2, 9),
      (4, 3, 2),
      (4, 4, 7),
    ],
    [
      @types.new_constraint(RowSum, [0, 25]),
      @types.new_constraint(RowSum, [3, 22]),
      @types.new_constraint(RowSum, [4, 29]),
      @types.new_constraint(NoPrimePair, [0]),
      @types.new_constraint(NoPrimePair, [2]),
      @types.new_constraint(Adjacent, [1, 0, 2, 0]),
      @types.new_constraint(Divisible, [1, 4, 1, 0]),
      @types.new_constraint(Unique, [0, 1]),
      @types.new_constraint(Unique, [0, 3]),
    ],
    90.0,
  )
}

///|
fn level_25() -> @types.Level {
  make_level(
    Theorem,
    24,
    [
      (0, 0, 5),
      (0, 4, 6),
      (1, 2, 4),
      (1, 3, 8),
      (2, 0, 8),
      (2, 1, 6),
      (3, 1, 9),
      (3, 4, 1),
      (4, 0, 2),
      (4, 1, 1),
      (4, 2, 7),
      (4, 3, 5),
      (4, 4, 9),
    ],
    [
      @types.new_constraint(RowSum, [0, 27]),
      @types.new_constraint(RowSum, [2, 28]),
      @types.new_constraint(RowSum, [4, 24]),
      @types.new_constraint(NoPrimePair, [0]),
      @types.new_constraint(NoPrimePair, [1]),
      @types.new_constraint(NoPrimePair, [3]),
      @types.new_constraint(Adjacent, [0, 0, 0, 1]),
      @types.new_constraint(Divisible, [2, 0, 2, 1]),
      @types.new_constraint(Unique, [0, 0]),
      @types.new_constraint(Unique, [0, 2]),
    ],
    85.0,
  )
}
