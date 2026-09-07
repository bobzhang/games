///|
test "new_grid creates 36 cells" {
  let grid = @types.new_grid()
  inspect(grid.cells.length(), content="36")
}

///|
test "all cells start Empty" {
  let grid = @types.new_grid()
  for i in 0..<grid.cells.length() {
    inspect(grid.cells[i].glaze, content="Empty")
    inspect(grid.cells[i].fired, content="FEmpty")
  }
}

///|
test "set_glaze and get_cell" {
  let grid = @types.new_grid()
  @types.set_glaze(grid, 2, 3, Red)
  inspect(@types.get_cell(grid, 2, 3).glaze, content="Red")
}

///|
test "clear_grid resets all" {
  let grid = @types.new_grid()
  @types.set_glaze(grid, 0, 0, Blue)
  @types.set_glaze(grid, 5, 5, Gold)
  @types.clear_grid(grid)
  inspect(@types.get_cell(grid, 0, 0).glaze, content="Empty")
  inspect(@types.get_cell(grid, 5, 5).glaze, content="Empty")
}

///|
test "grid_index maps correctly" {
  inspect(@types.grid_index(0, 0), content="0")
  inspect(@types.grid_index(0, 5), content="5")
  inspect(@types.grid_index(1, 0), content="6")
  inspect(@types.grid_index(5, 5), content="35")
}

///|
test "glaze_name returns names" {
  inspect(@types.glaze_name(Red), content="Red")
  inspect(@types.glaze_name(Empty), content="Empty")
}

///|
test "fired_name returns names" {
  inspect(@types.fired_name(FPurple), content="Purple")
  inspect(@types.fired_name(FDeepRed), content="Deep Red")
  inspect(@types.fired_name(FCracked), content="Cracked!")
}

///|
test "tier_level_range" {
  debug_inspect(@types.tier_level_range(Beginner), content="(0, 7)")
  debug_inspect(@types.tier_level_range(Intermediate), content="(7, 14)")
  debug_inspect(@types.tier_level_range(Advanced), content="(14, 20)")
}

///|
test "tier_from_index roundtrip" {
  for i in 0..<3 {
    inspect(@types.tier_index(@types.tier_from_index(i)), content="\{i}")
  }
}

///|
test "is_incompatible pairs" {
  inspect(@types.is_incompatible(Red, Green), content="true")
  inspect(@types.is_incompatible(Green, Red), content="true")
  inspect(@types.is_incompatible(Gold, Black), content="true")
  inspect(@types.is_incompatible(Black, Gold), content="true")
  inspect(@types.is_incompatible(Red, Blue), content="false")
  inspect(@types.is_incompatible(White, Black), content="false")
}

///|
test "glaze_index and from_index roundtrip" {
  let glazes : Array[@types.GlazeColor] = [Red, Blue, Green, Gold, White, Black]
  for i in 0..<glazes.length() {
    let g = glazes[i]
    inspect(@types.glaze_from_index(@types.glaze_index(g)) == g, content="true")
  }
}

///|
test "new_game initializes correctly" {
  let game = @types.new_game()
  inspect(game.screen, content="Title")
  inspect(game.selected_tier, content="Beginner")
  inspect(game.moves_used, content="0")
  inspect(game.level_scores.length(), content="20")
}

///|
test "sinf and cosf" {
  let s = @types.sinf(0.0)
  let c = @types.cosf(0.0)
  inspect(s == 0.0, content="true")
  inspect(c == 1.0, content="true")
}

///|
test "mini maxi clampi" {
  inspect(@types.mini(3, 5), content="3")
  inspect(@types.maxi(3, 5), content="5")
  inspect(@types.clampi(10, 0, 5), content="5")
  inspect(@types.clampi(-1, 0, 5), content="0")
  inspect(@types.clampi(3, 0, 5), content="3")
}

///|
test "minf maxf absf" {
  inspect(@types.minf(3.0, 5.0) == 3.0, content="true")
  inspect(@types.maxf(3.0, 5.0) == 5.0, content="true")
  inspect(@types.absf(-3.0) == 3.0, content="true")
}
