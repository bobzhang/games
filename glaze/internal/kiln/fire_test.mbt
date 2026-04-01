///|
test "glaze_to_fired converts basic colors" {
  inspect(@kiln.glaze_to_fired(Red), content="FRed")
  inspect(@kiln.glaze_to_fired(Blue), content="FBlue")
  inspect(@kiln.glaze_to_fired(Green), content="FGreen")
  inspect(@kiln.glaze_to_fired(Gold), content="FGold")
  inspect(@kiln.glaze_to_fired(White), content="FWhite")
  inspect(@kiln.glaze_to_fired(Black), content="FBlack")
  inspect(@kiln.glaze_to_fired(Empty), content="FEmpty")
}

///|
test "deepen creates richer shades" {
  inspect(@kiln.deepen(FRed), content="FDeepRed")
  inspect(@kiln.deepen(FBlue), content="FDeepBlue")
  inspect(@kiln.deepen(FGreen), content="FDeepGreen")
  inspect(@kiln.deepen(FGold), content="FDeepGold")
  inspect(@kiln.deepen(FWhite), content="FDeepWhite")
  inspect(@kiln.deepen(FBlack), content="FDeepBlack")
  inspect(@kiln.deepen(FPurple), content="FPurple")
}

///|
test "fire_grid same-color neighbors merge" {
  let grid = @types.new_grid()
  // Place two adjacent reds at (0,0) and (0,1)
  @types.set_glaze(grid, 0, 0, Red)
  @types.set_glaze(grid, 0, 1, Red)
  @kiln.fire_grid(grid)
  inspect(@types.get_cell(grid, 0, 0).fired, content="FDeepRed")
  inspect(@types.get_cell(grid, 0, 1).fired, content="FDeepRed")
}

///|
test "fire_grid Red+Blue blend to Purple" {
  let grid = @types.new_grid()
  @types.set_glaze(grid, 2, 2, Red)
  @types.set_glaze(grid, 2, 3, Blue)
  @kiln.fire_grid(grid)
  inspect(@types.get_cell(grid, 2, 2).fired, content="FPurple")
  inspect(@types.get_cell(grid, 2, 3).fired, content="FPurple")
}

///|
test "fire_grid incompatible Red+Green crack" {
  let grid = @types.new_grid()
  @types.set_glaze(grid, 1, 1, Red)
  @types.set_glaze(grid, 1, 2, Green)
  @kiln.fire_grid(grid)
  inspect(@types.get_cell(grid, 1, 1).fired, content="FCracked")
  inspect(@types.get_cell(grid, 1, 2).fired, content="FCracked")
}

///|
test "fire_grid incompatible Gold+Black crack" {
  let grid = @types.new_grid()
  @types.set_glaze(grid, 3, 3, Gold)
  @types.set_glaze(grid, 3, 4, Black)
  @kiln.fire_grid(grid)
  inspect(@types.get_cell(grid, 3, 3).fired, content="FCracked")
  inspect(@types.get_cell(grid, 3, 4).fired, content="FCracked")
}

///|
test "fire_grid isolated single glaze" {
  let grid = @types.new_grid()
  @types.set_glaze(grid, 3, 3, Gold)
  @kiln.fire_grid(grid)
  inspect(@types.get_cell(grid, 3, 3).fired, content="FGold")
}

///|
test "fire_grid empty stays empty" {
  let grid = @types.new_grid()
  @kiln.fire_grid(grid)
  inspect(@types.get_cell(grid, 0, 0).fired, content="FEmpty")
  inspect(@types.get_cell(grid, 5, 5).fired, content="FEmpty")
}

///|
test "count_matches with full match" {
  let grid = @types.new_grid()
  @types.set_glaze(grid, 0, 0, Red)
  @kiln.fire_grid(grid)
  let target : Array[@types.FiredColor] = []
  for i in 0..<36 {
    if i == 0 {
      target.push(FRed)
    } else {
      target.push(FEmpty)
    }
  }
  inspect(@kiln.count_matches(grid, target), content="36")
}

///|
test "count_cracked counts correctly" {
  let grid = @types.new_grid()
  @types.set_glaze(grid, 0, 0, Red)
  @types.set_glaze(grid, 0, 1, Green)
  @kiln.fire_grid(grid)
  inspect(@kiln.count_cracked(grid), content="2")
}

///|
test "calculate_score perfect 3 stars" {
  let grid = @types.new_grid()
  @kiln.fire_grid(grid)
  let target : Array[@types.FiredColor] = []
  for _i in 0..<36 {
    target.push(FEmpty)
  }
  let score = @kiln.calculate_score(grid, target, 0, 5)
  inspect(score.stars, content="3")
  inspect(score.matched_cells, content="36")
}

///|
test "calculate_score 2 stars when over par" {
  let grid = @types.new_grid()
  @kiln.fire_grid(grid)
  let target : Array[@types.FiredColor] = []
  for _i in 0..<36 {
    target.push(FEmpty)
  }
  let score = @kiln.calculate_score(grid, target, 10, 5)
  inspect(score.stars, content="2")
}
