///|
test "vec2i constructor" {
  let v = vec2i(3, 7)
  inspect(v.x, content="3")
  inspect(v.y, content="7")
}

///|
test "vec2i_add" {
  let a = vec2i(2, 3)
  let b = vec2i(5, -1)
  let c = vec2i_add(a, b)
  inspect(c.x, content="7")
  inspect(c.y, content="2")
}

///|
test "vec2i_eq" {
  inspect(vec2i_eq(vec2i(1, 2), vec2i(1, 2)), content="true")
  inspect(vec2i_eq(vec2i(1, 2), vec2i(3, 2)), content="false")
  inspect(vec2i_eq(vec2i(1, 2), vec2i(1, 3)), content="false")
}

///|
test "dir_dx and dir_dy" {
  inspect(dir_dx(East), content="1")
  inspect(dir_dx(West), content="-1")
  inspect(dir_dx(North), content="0")
  inspect(dir_dx(South), content="0")
  inspect(dir_dy(South), content="1")
  inspect(dir_dy(North), content="-1")
  inspect(dir_dy(East), content="0")
  inspect(dir_dy(West), content="0")
}

///|
test "dir_delta" {
  let d = dir_delta(East)
  inspect(d.x, content="1")
  inspect(d.y, content="0")
  let d2 = dir_delta(North)
  inspect(d2.x, content="0")
  inspect(d2.y, content="-1")
}

///|
test "turn_left cycles counterclockwise" {
  inspect(turn_left(North), content="West")
  inspect(turn_left(West), content="South")
  inspect(turn_left(South), content="East")
  inspect(turn_left(East), content="North")
}

///|
test "turn_right cycles clockwise" {
  inspect(turn_right(North), content="East")
  inspect(turn_right(East), content="South")
  inspect(turn_right(South), content="West")
  inspect(turn_right(West), content="North")
}

///|
test "dir_name" {
  inspect(dir_name(North), content="North")
  inspect(dir_name(South), content="South")
  inspect(dir_name(East), content="East")
  inspect(dir_name(West), content="West")
}

///|
test "new_grid creates correct dimensions" {
  let g = new_grid(4, 3)
  inspect(g.width, content="4")
  inspect(g.height, content="3")
  inspect(grid_get(g, 0, 0), content="Floor")
}

///|
test "grid_in_bounds" {
  let g = new_grid(5, 5)
  inspect(grid_in_bounds(g, 0, 0), content="true")
  inspect(grid_in_bounds(g, 4, 4), content="true")
  inspect(grid_in_bounds(g, -1, 0), content="false")
  inspect(grid_in_bounds(g, 0, -1), content="false")
  inspect(grid_in_bounds(g, 5, 0), content="false")
  inspect(grid_in_bounds(g, 0, 5), content="false")
}

///|
test "grid_get returns Wall for out of bounds" {
  let g = new_grid(3, 3)
  inspect(grid_get(g, -1, 0), content="Wall")
  inspect(grid_get(g, 10, 10), content="Wall")
}

///|
test "grid_set and grid_get round trip" {
  let g = new_grid(3, 3)
  grid_set(g, 1, 1, Wall)
  inspect(grid_get(g, 1, 1), content="Wall")
  grid_set(g, 2, 0, Goal)
  inspect(grid_get(g, 2, 0), content="Goal")
}

///|
test "grid_set out of bounds is a no-op" {
  let g = new_grid(3, 3)
  grid_set(g, -1, 0, Wall) // should not crash
  grid_set(g, 100, 100, Wall) // should not crash
}

///|
test "new_robot" {
  let r = new_robot(5, 3, East)
  inspect(r.pos.x, content="5")
  inspect(r.pos.y, content="3")
  inspect(r.dir, content="East")
  inspect(r.alive, content="true")
}

///|
test "new_program" {
  let p = new_program()
  inspect(p.commands.length(), content="0")
  inspect(p.max_slots, content="20")
}

///|
test "new_editor_state" {
  let cmds : Array[CommandKind] = [Move, TurnLeft, TurnRight]
  let ed = new_editor_state(cmds)
  inspect(ed.cursor, content="0")
  inspect(ed.palette_open, content="false")
  inspect(ed.palette_commands.length(), content="3")
  inspect(ed.loop_count, content="2")
}

///|
test "new_level_score defaults" {
  let s = new_level_score()
  inspect(s.completed, content="false")
  inspect(s.best_instructions, content="999")
  inspect(s.medal, content="None_")
}

///|
test "clone_robot creates independent copy" {
  let r = new_robot(1, 2, North)
  let r2 = clone_robot(r)
  r.pos = vec2i(99, 99)
  inspect(r2.pos.x, content="1")
}

///|
test "clone_goals_collected creates independent copy" {
  let gc : Array[Bool] = [true, false, true]
  let gc2 = clone_goals_collected(gc)
  gc[1] = true
  inspect(gc2[1], content="false")
}

///|
test "clone_blocks creates independent copy" {
  let blocks : Array[Vec2i] = [vec2i(1, 2), vec2i(3, 4)]
  let blocks2 = clone_blocks(blocks)
  blocks[0] = vec2i(99, 99)
  inspect(blocks2[0].x, content="1")
}

///|
test "all_goals_collected" {
  inspect(all_goals_collected([true, true, true]), content="true")
  inspect(all_goals_collected([true, false, true]), content="false")
  inspect(all_goals_collected([]), content="true")
}

///|
test "count_goals_collected" {
  inspect(count_goals_collected([true, false, true, true]), content="3")
  inspect(count_goals_collected([false, false]), content="0")
  inspect(count_goals_collected([]), content="0")
}

///|
test "tile_color_name" {
  inspect(tile_color_name(Red), content="Red")
  inspect(tile_color_name(Blue), content="Blue")
  inspect(tile_color_name(Green), content="Green")
}

///|
test "condition_name" {
  inspect(condition_name(PathAhead), content="PathAhead")
  inspect(condition_name(WallAhead), content="WallAhead")
  inspect(condition_name(AtGoal), content="AtGoal")
  inspect(condition_name(OnColor(Red)), content="OnRed")
  inspect(condition_name(OnColor(Blue)), content="OnBlue")
}

///|
test "medal_from_instructions" {
  inspect(medal_from_instructions(3, 5, 3), content="Gold")
  inspect(medal_from_instructions(2, 5, 3), content="Gold")
  inspect(medal_from_instructions(4, 5, 3), content="Silver")
  inspect(medal_from_instructions(5, 5, 3), content="Silver")
  inspect(medal_from_instructions(6, 5, 3), content="Bronze")
}

///|
test "medal_stars" {
  inspect(medal_stars(Gold), content="3")
  inspect(medal_stars(Silver), content="2")
  inspect(medal_stars(Bronze), content="1")
  inspect(medal_stars(None_), content="0")
}

///|
test "maxi and mini" {
  inspect(maxi(3, 7), content="7")
  inspect(maxi(10, 2), content="10")
  inspect(mini(3, 7), content="3")
  inspect(mini(10, 2), content="2")
}

///|
test "absf" {
  inspect(absf(-3.5), content="3.5")
  inspect(absf(2.0), content="2")
  inspect(absf(0.0), content="0")
}

///|
test "is_tile_walkable" {
  inspect(is_tile_walkable(Floor), content="true")
  inspect(is_tile_walkable(Goal), content="true")
  inspect(is_tile_walkable(Start), content="true")
  inspect(is_tile_walkable(ColorTile(Red)), content="true")
  inspect(is_tile_walkable(Wall), content="false")
  inspect(is_tile_walkable(Gap), content="false")
}

///|
test "is_tile_solid" {
  inspect(is_tile_solid(Wall), content="true")
  inspect(is_tile_solid(Floor), content="false")
  inspect(is_tile_solid(Gap), content="false")
}

///|
test "is_tile_gap" {
  inspect(is_tile_gap(Gap), content="true")
  inspect(is_tile_gap(Floor), content="false")
  inspect(is_tile_gap(Wall), content="false")
}

///|
test "has_block_at and find_block_index" {
  let blocks : Array[Vec2i] = [vec2i(1, 2), vec2i(5, 3)]
  inspect(has_block_at(blocks, 1, 2), content="true")
  inspect(has_block_at(blocks, 5, 3), content="true")
  inspect(has_block_at(blocks, 0, 0), content="false")
  inspect(find_block_index(blocks, 1, 2), content="0")
  inspect(find_block_index(blocks, 5, 3), content="1")
  inspect(find_block_index(blocks, 9, 9), content="-1")
}

///|
test "tile_screen and tile_center coordinates" {
  inspect(tile_screen_x(0), content="16")
  inspect(tile_screen_y(0), content="36")
  inspect(tile_center_x(0), content="44")
  inspect(tile_center_y(0), content="64")
}

///|
test "world_name" {
  inspect(world_name(0), content="Basics")
  inspect(world_name(1), content="Leaps")
  inspect(world_name(2), content="Logic")
  inspect(world_name(3), content="Mastery")
  inspect(world_name(99), content="???")
}

///|
test "calculate_total_stars" {
  let scores : Array[Array[LevelScore]] = []
  let world1 : Array[LevelScore] = [
    { completed: true, best_instructions: 3, medal: Gold },
    { completed: true, best_instructions: 5, medal: Silver },
  ]
  scores.push(world1)
  inspect(calculate_total_stars(scores), content="5")
}

///|
test "make_robot_state" {
  let robot = new_robot(2, 3, South)
  let gc : Array[Bool] = [false, true]
  let blocks : Array[Vec2i] = [vec2i(4, 5)]
  let state = make_robot_state(robot, gc, blocks, 7)
  inspect(state.pos.x, content="2")
  inspect(state.pos.y, content="3")
  inspect(state.dir, content="South")
  inspect(state.alive, content="true")
  inspect(state.cmd_index, content="7")
  inspect(state.goals_collected[1], content="true")
  inspect(state.blocks[0].x, content="4")
}
