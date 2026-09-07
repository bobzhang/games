///|
test "manhattan_distance" {
  let a = @types.vec2i(2, 3)
  let b = @types.vec2i(5, 7)
  inspect(@types.manhattan_distance(a, b), content="7")
  inspect(@types.manhattan_distance(a, a), content="0")
}

///|
test "manhattan_distance_adjacent" {
  let a = @types.vec2i(3, 3)
  let b = @types.vec2i(4, 3)
  inspect(@types.manhattan_distance(a, b), content="1")
}

///|
test "direction_check_north" {
  let from = @types.vec2i(3, 5)
  let to = @types.vec2i(3, 2)
  inspect(@types.direction_check(from, to, N), content="true")
  inspect(@types.direction_check(from, to, S), content="false")
}

///|
test "direction_check_east" {
  let from = @types.vec2i(2, 3)
  let to = @types.vec2i(5, 3)
  inspect(@types.direction_check(from, to, E), content="true")
  inspect(@types.direction_check(from, to, W), content="false")
}

///|
test "direction_check_diagonal" {
  let from = @types.vec2i(3, 3)
  let to = @types.vec2i(5, 1)
  inspect(@types.direction_check(from, to, NE), content="true")
  inspect(@types.direction_check(from, to, SW), content="false")
}

///|
test "is_adjacent_cardinal" {
  let a = @types.vec2i(3, 3)
  inspect(@types.is_adjacent(a, @types.vec2i(4, 3)), content="true")
  inspect(@types.is_adjacent(a, @types.vec2i(2, 3)), content="true")
  inspect(@types.is_adjacent(a, @types.vec2i(3, 4)), content="true")
  inspect(@types.is_adjacent(a, @types.vec2i(3, 2)), content="true")
}

///|
test "is_adjacent_diagonal" {
  let a = @types.vec2i(3, 3)
  inspect(@types.is_adjacent(a, @types.vec2i(4, 4)), content="true")
  inspect(@types.is_adjacent(a, @types.vec2i(2, 2)), content="true")
}

///|
test "is_adjacent_not" {
  let a = @types.vec2i(3, 3)
  inspect(@types.is_adjacent(a, @types.vec2i(5, 3)), content="false")
  inspect(@types.is_adjacent(a, @types.vec2i(3, 3)), content="false")
}

///|
test "is_between_horizontal" {
  let target = @types.vec2i(3, 2)
  let end_a = @types.vec2i(1, 2)
  let end_b = @types.vec2i(5, 2)
  inspect(@types.is_between(target, end_a, end_b), content="true")
}

///|
test "is_between_vertical" {
  let target = @types.vec2i(2, 3)
  let end_a = @types.vec2i(2, 1)
  let end_b = @types.vec2i(2, 5)
  inspect(@types.is_between(target, end_a, end_b), content="true")
}

///|
test "is_between_diagonal" {
  let target = @types.vec2i(3, 3)
  let end_a = @types.vec2i(1, 1)
  let end_b = @types.vec2i(5, 5)
  inspect(@types.is_between(target, end_a, end_b), content="true")
}

///|
test "is_between_not" {
  let target = @types.vec2i(3, 4)
  let end_a = @types.vec2i(1, 2)
  let end_b = @types.vec2i(5, 2)
  inspect(@types.is_between(target, end_a, end_b), content="false")
}

///|
test "is_between_at_endpoint" {
  let target = @types.vec2i(1, 2)
  let end_a = @types.vec2i(1, 2)
  let end_b = @types.vec2i(5, 2)
  inspect(@types.is_between(target, end_a, end_b), content="false")
}

///|
test "pos_to_index and index_to_pos" {
  let pos = @types.vec2i(3, 5)
  let idx = @types.pos_to_index(pos, 8)
  inspect(idx, content="43")
  let back = @types.index_to_pos(idx, 8)
  inspect(back.x, content="3")
  inspect(back.y, content="5")
}

///|
test "feature_color" {
  let c = @types.feature_color(Mountain)
  inspect(c == @types.color_mountain, content="true")
  let c2 = @types.feature_color(Forest)
  inspect(c2 == @types.color_forest, content="true")
}

///|
test "feature_name" {
  inspect(@types.feature_name(Mountain), content="Mountain")
  inspect(@types.feature_name(River), content="River")
  inspect(@types.feature_name(Town), content="Town")
}

///|
test "tier_name" {
  inspect(@types.tier_name(Surveyor), content="Surveyor")
  inspect(@types.tier_name(Explorer), content="Explorer")
  inspect(@types.tier_name(Master), content="Master")
}

///|
test "compass_name" {
  inspect(@types.compass_name(N), content="north")
  inspect(@types.compass_name(SE), content="southeast")
}

///|
test "tier_level_range" {
  let (s1, e1) = @types.tier_level_range(Surveyor)
  inspect(s1, content="0")
  inspect(e1, content="8")
  let (s2, e2) = @types.tier_level_range(Explorer)
  inspect(s2, content="8")
  inspect(e2, content="17")
  let (s3, e3) = @types.tier_level_range(Master)
  inspect(s3, content="17")
  inspect(e3, content="25")
}

///|
test "level_tier" {
  inspect(@types.level_tier(0), content="Surveyor")
  inspect(@types.level_tier(7), content="Surveyor")
  inspect(@types.level_tier(8), content="Explorer")
  inspect(@types.level_tier(16), content="Explorer")
  inspect(@types.level_tier(17), content="Master")
  inspect(@types.level_tier(24), content="Master")
}

///|
test "find_feature_pos" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  grid[10] = Some(Mountain)
  grid[25] = Some(Town)
  let pos = @types.find_feature_pos(grid, 8, Mountain)
  debug_inspect(
    pos,
    content=(
      #|Some({ x: 2, y: 1 })
    ),
  )
  let pos2 = @types.find_feature_pos(grid, 8, Town)
  debug_inspect(
    pos2,
    content=(
      #|Some({ x: 1, y: 3 })
    ),
  )
  let pos3 = @types.find_feature_pos(grid, 8, Forest)
  debug_inspect(pos3, content="None")
}

///|
test "find_all_feature_positions" {
  let grid : Array[@types.FeatureKind?] = Array::make(64, None)
  grid[5] = Some(Forest)
  grid[20] = Some(Forest)
  grid[35] = Some(Forest)
  let positions = @types.find_all_feature_positions(grid, 8, Forest)
  inspect(positions.length(), content="3")
}

///|
test "new_game initializes correctly" {
  let levels = [
    @types.new_level(
      "Test",
      Surveyor,
      [Mountain, Town],
      [
        @types.new_clue(
          Distance,
          Mountain,
          feature_b=Town,
          distance=3,
          text="test",
        ),
      ],
      2,
    ),
  ]
  let game = @types.new_game(levels)
  inspect(game.screen, content="Title")
  inspect(game.grid.length(), content="64")
  inspect(game.scores.length(), content="1")
  inspect(game.incorrect_count, content="0")
}

///|
test "reset_level clears state" {
  let clue = @types.new_clue(
    Distance,
    Mountain,
    feature_b=Town,
    distance=3,
    text="test",
  )
  clue.status = Satisfied
  let levels = [@types.new_level("Test", Surveyor, [Mountain, Town], [clue], 2)]
  let game = @types.new_game(levels)
  game.grid[5] = Some(Mountain)
  game.total_placements = 5
  game.incorrect_count = 2
  @types.reset_level(game)
  debug_inspect(game.grid[5], content="None")
  inspect(game.total_placements, content="0")
  inspect(game.incorrect_count, content="0")
  inspect(clue.status, content="Pending")
}
