///|
test "xyz_to_idx and idx_to_xyz round trip" {
  for x in 0..<3 {
    for y in 0..<3 {
      for z in 0..<3 {
        let idx = @types.xyz_to_idx(x, y, z, 3)
        let pos = @types.idx_to_xyz(idx, 3)
        inspect(pos.x == x, content="true")
        inspect(pos.y == y, content="true")
        inspect(pos.z == z, content="true")
      }
    }
  }
}

///|
test "xyz_to_idx 4x4x4 round trip" {
  for x in 0..<4 {
    for y in 0..<4 {
      for z in 0..<4 {
        let idx = @types.xyz_to_idx(x, y, z, 4)
        let pos = @types.idx_to_xyz(idx, 4)
        inspect(pos.x == x, content="true")
        inspect(pos.y == y, content="true")
        inspect(pos.z == z, content="true")
      }
    }
  }
}

///|
test "new_voxel_grid is empty" {
  let g = @types.new_voxel_grid(3)
  inspect(g.size, content="3")
  inspect(g.cells.length(), content="27")
  for i in 0..<27 {
    inspect(g.cells[i], content="false")
  }
}

///|
test "new_voxel_grid 5x5x5" {
  let g = @types.new_voxel_grid(5)
  inspect(g.size, content="5")
  inspect(g.cells.length(), content="125")
}

///|
test "copy_grid is independent" {
  let g = @types.new_voxel_grid(3)
  g.cells[0] = true
  let g2 = @types.copy_grid(g)
  inspect(g2.cells[0], content="true")
  g2.cells[0] = false
  inspect(g.cells[0], content="true")
  inspect(g2.cells[0], content="false")
}

///|
test "silhouette_from_bits" {
  let s = @types.silhouette_from_bits(3, 3, [0b111, 0b010, 0b010])
  inspect(s.width, content="3")
  inspect(s.height, content="3")
  // Row 0: 111
  inspect(s.cells[0], content="true")
  inspect(s.cells[1], content="true")
  inspect(s.cells[2], content="true")
  // Row 1: 010
  inspect(s.cells[3], content="false")
  inspect(s.cells[4], content="true")
  inspect(s.cells[5], content="false")
  // Row 2: 010
  inspect(s.cells[6], content="false")
  inspect(s.cells[7], content="true")
  inspect(s.cells[8], content="false")
}

///|
test "cell_size_for_grid" {
  inspect(@types.cell_size_for_grid(3), content="40")
  inspect(@types.cell_size_for_grid(4), content="30")
  inspect(@types.cell_size_for_grid(5), content="24")
}

///|
test "new_game initial state" {
  let game = @types.new_game()
  inspect(game.screen, content="Title")
  inspect(game.play_state, content="Editing")
  inspect(game.moves, content="0")
  inspect(game.scores.length(), content="30")
  inspect(game.current_tier, content="0")
  inspect(game.current_level, content="0")
}

///|
test "level_index" {
  inspect(@types.level_index(0, 0), content="0")
  inspect(@types.level_index(0, 9), content="9")
  inspect(@types.level_index(1, 0), content="10")
  inspect(@types.level_index(2, 5), content="25")
}

///|
test "tier_name" {
  inspect(@types.tier_name(0), content="Shapes")
  inspect(@types.tier_name(1), content="Structures")
  inspect(@types.tier_name(2), content="Sculptures")
}

///|
test "absf" {
  inspect(@types.absf(5.0), content="5")
  inspect(@types.absf(-5.0), content="5")
  inspect(@types.absf(0.0), content="0")
}

///|
test "maxf and minf" {
  inspect(@types.maxf(3.0, 7.0), content="7")
  inspect(@types.minf(3.0, 7.0), content="3")
}

///|
test "maxi and mini" {
  inspect(@types.maxi(3, 7), content="7")
  inspect(@types.mini(3, 7), content="3")
}

///|
test "clampf" {
  inspect(@types.clampf(0.5, 0.0, 1.0), content="0.5")
  inspect(@types.clampf(-1.0, 0.0, 1.0), content="0")
  inspect(@types.clampf(2.0, 0.0, 1.0), content="1")
}
