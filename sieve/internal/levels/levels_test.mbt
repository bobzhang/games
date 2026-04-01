///|
test "all 25 levels load without panic" {
  for i in 0..<25 {
    let _level = @levels.get_level(i)
  }
}

///|
test "correct number of levels per tier" {
  let mut primes_count = 0
  let mut factors_count = 0
  let mut theorem_count = 0
  for i in 0..<25 {
    let level = @levels.get_level(i)
    match level.tier {
      Primes => primes_count += 1
      Factors => factors_count += 1
      Theorem => theorem_count += 1
    }
  }
  inspect(primes_count, content="8")
  inspect(factors_count, content="9")
  inspect(theorem_count, content="8")
}

///|
test "level indices are sequential" {
  for i in 0..<25 {
    let level = @levels.get_level(i)
    inspect(level.level_index, content=i.to_string())
  }
}

///|
test "all levels have at least one constraint" {
  for i in 0..<25 {
    let level = @levels.get_level(i)
    assert_true!(level.constraints.length() > 0)
  }
}

///|
test "all constraint params reference valid grid positions" {
  let gs = @types.grid_size
  for i in 0..<25 {
    let level = @levels.get_level(i)
    for c in level.constraints {
      match c.kind {
        RowSum => {
          let row = c.params[0]
          assert_true!(row >= 0 && row < gs)
          assert_true!(c.params[1] > 0) // sum must be positive
        }
        ColProduct => {
          let col = c.params[0]
          assert_true!(col >= 0 && col < gs)
          assert_true!(c.params[1] > 0) // product must be positive
        }
        Adjacent => {
          assert_true!(c.params[0] >= 0 && c.params[0] < gs) // row1
          assert_true!(c.params[1] >= 0 && c.params[1] < gs) // col1
          assert_true!(c.params[2] >= 0 && c.params[2] < gs) // row2
          assert_true!(c.params[3] >= 0 && c.params[3] < gs) // col2
        }
        NoPrimePair => {
          let row = c.params[0]
          assert_true!(row >= 0 && row < gs)
        }
        Divisible => {
          assert_true!(c.params[0] >= 0 && c.params[0] < gs) // row_a
          assert_true!(c.params[1] >= 0 && c.params[1] < gs) // col_a
          assert_true!(c.params[2] >= 0 && c.params[2] < gs) // row_b
          assert_true!(c.params[3] >= 0 && c.params[3] < gs) // col_b
        }
        Unique => {
          let axis = c.params[0]
          assert_true!(axis == 0 || axis == 1) // 0=row, 1=col
          let index = c.params[1]
          assert_true!(index >= 0 && index < gs)
        }
      }
    }
  }
}

///|
test "pre-filled cells are within value range 1-9" {
  for i in 0..<25 {
    let level = @levels.get_level(i)
    for r in 0..<@types.grid_size {
      for c in 0..<@types.grid_size {
        let val = @types.grid_get(level.grid, r, c)
        if @types.grid_is_locked(level.grid, r, c) {
          assert_true!(val >= 1 && val <= 9)
        }
      }
    }
  }
}

///|
test "pre-filled cells within grid bounds" {
  let gs = @types.grid_size
  for i in 0..<25 {
    let level = @levels.get_level(i)
    for r in 0..<gs {
      for c in 0..<gs {
        // Just verify all cells are accessible
        let _v = @types.grid_get(level.grid, r, c)
      }
    }
  }
}

///|
test "par times are positive" {
  for i in 0..<25 {
    let level = @levels.get_level(i)
    assert_true!(level.par_time > 0.0)
  }
}

///|
test "each level has at least some empty cells to fill" {
  for i in 0..<25 {
    let level = @levels.get_level(i)
    let mut empty_count = 0
    for r in 0..<@types.grid_size {
      for c in 0..<@types.grid_size {
        if !@types.grid_is_locked(level.grid, r, c) {
          empty_count += 1
        }
      }
    }
    assert_true!(empty_count > 0)
  }
}

///|
test "tier assignment matches tier index ranges" {
  // Levels 0-7 should be Primes
  for i in 0..<8 {
    let level = @levels.get_level(i)
    assert_true!(level.tier == Primes)
  }
  // Levels 8-16 should be Factors
  for i in 8..<17 {
    let level = @levels.get_level(i)
    assert_true!(level.tier == Factors)
  }
  // Levels 17-24 should be Theorem
  for i in 17..<25 {
    let level = @levels.get_level(i)
    assert_true!(level.tier == Theorem)
  }
}

///|
test "RowSum targets are achievable with values 1-9" {
  // A row of 5 cells with values 1-9 can sum between 5 (all 1s) and 45 (all 9s)
  for i in 0..<25 {
    let level = @levels.get_level(i)
    for c in level.constraints {
      match c.kind {
        RowSum => {
          let target = c.params[1]
          assert_true!(target >= 5)
          assert_true!(target <= 45)
        }
        _ => ()
      }
    }
  }
}

///|
test "Adjacent constraint cells are actually adjacent" {
  for i in 0..<25 {
    let level = @levels.get_level(i)
    for c in level.constraints {
      match c.kind {
        Adjacent => {
          let r1 = c.params[0]
          let c1 = c.params[1]
          let r2 = c.params[2]
          let c2 = c.params[3]
          // Manhattan distance should be 1 for adjacent cells
          let dist = @types.absi(r1 - r2) + @types.absi(c1 - c2)
          assert_true!(dist == 1)
        }
        _ => ()
      }
    }
  }
}

///|
test "Divisible constraint cells are distinct" {
  for i in 0..<25 {
    let level = @levels.get_level(i)
    for c in level.constraints {
      match c.kind {
        Divisible => {
          // The two cells should not be the same
          let same = c.params[0] == c.params[2] && c.params[1] == c.params[3]
          assert_true!(!same)
        }
        _ => ()
      }
    }
  }
}

///|
test "grid size matches constant" {
  for i in 0..<25 {
    let level = @levels.get_level(i)
    inspect(level.grid.size, content="5")
  }
}

///|
test "constraints start unsatisfied" {
  for i in 0..<25 {
    let level = @levels.get_level(i)
    for c in level.constraints {
      inspect(c.satisfied, content="false")
    }
  }
}
