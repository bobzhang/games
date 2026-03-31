///|
test "validate RowSum satisfied" {
  let g = @types.new_grid()
  // Row 0: 1+2+3+4+5=15
  @types.grid_set(g, 0, 0, 1)
  @types.grid_set(g, 0, 1, 2)
  @types.grid_set(g, 0, 2, 3)
  @types.grid_set(g, 0, 3, 4)
  @types.grid_set(g, 0, 4, 5)
  let c = @types.new_constraint(RowSum, [0, 15])
  inspect(@constraints.validate_constraint(g, c), content="true")
}

///|
test "validate RowSum unsatisfied" {
  let g = @types.new_grid()
  @types.grid_set(g, 0, 0, 1)
  @types.grid_set(g, 0, 1, 2)
  @types.grid_set(g, 0, 2, 3)
  @types.grid_set(g, 0, 3, 4)
  @types.grid_set(g, 0, 4, 5)
  let c = @types.new_constraint(RowSum, [0, 20])
  inspect(@constraints.validate_constraint(g, c), content="false")
}

///|
test "validate RowSum with empty" {
  let g = @types.new_grid()
  @types.grid_set(g, 0, 0, 1)
  @types.grid_set(g, 0, 1, 2)
  // rest empty
  let c = @types.new_constraint(RowSum, [0, 3])
  inspect(@constraints.validate_constraint(g, c), content="false")
}

///|
test "validate ColProduct" {
  let g = @types.new_grid()
  // Col 0: 1*2*3*1*1 = 6
  @types.grid_set(g, 0, 0, 1)
  @types.grid_set(g, 1, 0, 2)
  @types.grid_set(g, 2, 0, 3)
  @types.grid_set(g, 3, 0, 1)
  @types.grid_set(g, 4, 0, 1)
  let c = @types.new_constraint(ColProduct, [0, 6])
  inspect(@constraints.validate_constraint(g, c), content="true")
}

///|
test "validate ColProduct unsatisfied" {
  let g = @types.new_grid()
  @types.grid_set(g, 0, 0, 1)
  @types.grid_set(g, 1, 0, 2)
  @types.grid_set(g, 2, 0, 3)
  @types.grid_set(g, 3, 0, 1)
  @types.grid_set(g, 4, 0, 1)
  let c = @types.new_constraint(ColProduct, [0, 10])
  inspect(@constraints.validate_constraint(g, c), content="false")
}

///|
test "validate Adjacent" {
  let g = @types.new_grid()
  @types.grid_set(g, 0, 0, 3)
  @types.grid_set(g, 0, 1, 4)
  let c = @types.new_constraint(Adjacent, [0, 0, 0, 1])
  inspect(@constraints.validate_constraint(g, c), content="true")
}

///|
test "validate Adjacent fail" {
  let g = @types.new_grid()
  @types.grid_set(g, 0, 0, 3)
  @types.grid_set(g, 0, 1, 6)
  let c = @types.new_constraint(Adjacent, [0, 0, 0, 1])
  inspect(@constraints.validate_constraint(g, c), content="false")
}

///|
test "validate NoPrimePair satisfied" {
  let g = @types.new_grid()
  // Row 0: 4, 2, 6, 3, 8 - primes at (0,1) and (0,3), not adjacent
  @types.grid_set(g, 0, 0, 4)
  @types.grid_set(g, 0, 1, 2)
  @types.grid_set(g, 0, 2, 6)
  @types.grid_set(g, 0, 3, 3)
  @types.grid_set(g, 0, 4, 8)
  // Fill other rows to avoid cross-row check issues
  for r in 1..<5 {
    for c in 0..<5 {
      @types.grid_set(g, r, c, 4)
    }
  }
  let c = @types.new_constraint(NoPrimePair, [0])
  inspect(@constraints.validate_constraint(g, c), content="true")
}

///|
test "validate NoPrimePair unsatisfied" {
  let g = @types.new_grid()
  // Row 0: 2, 3, 4, 5, 6 - 2,3 adjacent primes
  @types.grid_set(g, 0, 0, 2)
  @types.grid_set(g, 0, 1, 3)
  @types.grid_set(g, 0, 2, 4)
  @types.grid_set(g, 0, 3, 5)
  @types.grid_set(g, 0, 4, 6)
  for r in 1..<5 {
    for c in 0..<5 {
      @types.grid_set(g, r, c, 4)
    }
  }
  let c = @types.new_constraint(NoPrimePair, [0])
  inspect(@constraints.validate_constraint(g, c), content="false")
}

///|
test "validate Divisible" {
  let g = @types.new_grid()
  @types.grid_set(g, 0, 0, 6)
  @types.grid_set(g, 1, 0, 3)
  let c = @types.new_constraint(Divisible, [0, 0, 1, 0])
  inspect(@constraints.validate_constraint(g, c), content="true")
}

///|
test "validate Divisible fail" {
  let g = @types.new_grid()
  @types.grid_set(g, 0, 0, 7)
  @types.grid_set(g, 1, 0, 3)
  let c = @types.new_constraint(Divisible, [0, 0, 1, 0])
  inspect(@constraints.validate_constraint(g, c), content="false")
}

///|
test "validate Unique row" {
  let g = @types.new_grid()
  @types.grid_set(g, 0, 0, 1)
  @types.grid_set(g, 0, 1, 2)
  @types.grid_set(g, 0, 2, 3)
  @types.grid_set(g, 0, 3, 4)
  @types.grid_set(g, 0, 4, 5)
  let c = @types.new_constraint(Unique, [0, 0])
  inspect(@constraints.validate_constraint(g, c), content="true")
}

///|
test "validate Unique row fail" {
  let g = @types.new_grid()
  @types.grid_set(g, 0, 0, 1)
  @types.grid_set(g, 0, 1, 2)
  @types.grid_set(g, 0, 2, 3)
  @types.grid_set(g, 0, 3, 2)
  @types.grid_set(g, 0, 4, 5)
  let c = @types.new_constraint(Unique, [0, 0])
  inspect(@constraints.validate_constraint(g, c), content="false")
}

///|
test "validate Unique col" {
  let g = @types.new_grid()
  @types.grid_set(g, 0, 0, 1)
  @types.grid_set(g, 1, 0, 2)
  @types.grid_set(g, 2, 0, 3)
  @types.grid_set(g, 3, 0, 4)
  @types.grid_set(g, 4, 0, 5)
  let c = @types.new_constraint(Unique, [1, 0])
  inspect(@constraints.validate_constraint(g, c), content="true")
}

///|
test "validate_all" {
  let g = @types.new_grid()
  @types.grid_set(g, 0, 0, 1)
  @types.grid_set(g, 0, 1, 2)
  @types.grid_set(g, 0, 2, 3)
  @types.grid_set(g, 0, 3, 4)
  @types.grid_set(g, 0, 4, 5)
  let constraints = [
    @types.new_constraint(RowSum, [0, 15]),
    @types.new_constraint(Unique, [0, 0]),
  ]
  let result = @constraints.validate_all(g, constraints)
  inspect(result, content="true")
  inspect(constraints[0].satisfied, content="true")
  inspect(constraints[1].satisfied, content="true")
}
