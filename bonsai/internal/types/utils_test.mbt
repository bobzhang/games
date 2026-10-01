///|
test "new_cell defaults" {
  let c = @types.new_cell()
  inspect(c.kind, content="Empty")
  inspect(c.growth_dir, content="Up")
  inspect(c.age, content="0")
  inspect(c.stagnant_turns, content="0")
}

///|
test "new_grid creates correct size" {
  let g = @types.new_grid(5, 3)
  inspect(g.width, content="5")
  inspect(g.height, content="3")
  inspect(g.cells.length(), content="15")
}

///|
test "grid_index" {
  let g = @types.new_grid(4, 3)
  inspect(@types.grid_index(g, 0, 0), content="0")
  inspect(@types.grid_index(g, 3, 0), content="3")
  inspect(@types.grid_index(g, 0, 1), content="4")
  inspect(@types.grid_index(g, 2, 2), content="10")
}

///|
test "grid_in_bounds" {
  let g = @types.new_grid(4, 3)
  inspect(@types.grid_in_bounds(g, 0, 0), content="true")
  inspect(@types.grid_in_bounds(g, 3, 2), content="true")
  inspect(@types.grid_in_bounds(g, -1, 0), content="false")
  inspect(@types.grid_in_bounds(g, 0, -1), content="false")
  inspect(@types.grid_in_bounds(g, 4, 0), content="false")
  inspect(@types.grid_in_bounds(g, 0, 3), content="false")
}

///|
test "grid_get and grid_set_kind round trip" {
  let g = @types.new_grid(3, 3)
  inspect(@types.grid_get(g, 1, 1).kind, content="Empty")
  @types.grid_set_kind(g, 1, 1, Trunk, Up)
  inspect(@types.grid_get(g, 1, 1).kind, content="Trunk")
  inspect(@types.grid_get(g, 1, 1).growth_dir, content="Up")
  inspect(@types.grid_get(g, 1, 1).age, content="0")
}

///|
test "clone_grid is independent" {
  let g = @types.new_grid(3, 3)
  @types.grid_set_kind(g, 0, 0, Trunk, Up)
  let g2 = @types.clone_grid(g)
  @types.grid_set_kind(g, 0, 0, Leaf, UpLeft)
  inspect(g2.cells[0].kind, content="Trunk")
  inspect(g.cells[0].kind, content="Leaf")
}

///|
test "snapshot and restore grid" {
  let g = @types.new_grid(2, 2)
  @types.grid_set_kind(g, 0, 0, Branch, UpRight)
  let snap = @types.snapshot_grid(g)
  @types.grid_set_kind(g, 0, 0, Pruned, Left)
  inspect(g.cells[0].kind, content="Pruned")
  @types.restore_grid(g, snap)
  inspect(g.cells[0].kind, content="Branch")
  inspect(g.cells[0].growth_dir, content="UpRight")
}

///|
test "fork_interval" {
  inspect(@types.fork_interval(Pine), content="3")
  inspect(@types.fork_interval(Maple), content="2")
  inspect(@types.fork_interval(Cherry), content="2")
}

///|
test "species_name" {
  inspect(@types.species_name(Pine), content="Pine")
  inspect(@types.species_name(Maple), content="Maple")
  inspect(@types.species_name(Cherry), content="Cherry")
}

///|
test "tier_name" {
  inspect(@types.tier_name(Tier1), content="Pine Grove")
  inspect(@types.tier_name(Tier2), content="Maple Garden")
  inspect(@types.tier_name(Tier3), content="Cherry Orchard")
}

///|
test "tier_species" {
  inspect(@types.tier_species(Tier1), content="Pine")
  inspect(@types.tier_species(Tier2), content="Maple")
  inspect(@types.tier_species(Tier3), content="Cherry")
}

///|
test "tier_level_count" {
  inspect(@types.tier_level_count(Tier1), content="8")
  inspect(@types.tier_level_count(Tier2), content="9")
  inspect(@types.tier_level_count(Tier3), content="8")
}

///|
test "tier_level_offset" {
  inspect(@types.tier_level_offset(Tier1), content="0")
  inspect(@types.tier_level_offset(Tier2), content="8")
  inspect(@types.tier_level_offset(Tier3), content="17")
}

///|
test "is_branch_or_trunk" {
  inspect(@types.is_branch_or_trunk(Trunk), content="true")
  inspect(@types.is_branch_or_trunk(Branch), content="true")
  inspect(@types.is_branch_or_trunk(Leaf), content="false")
  inspect(@types.is_branch_or_trunk(Empty), content="false")
  inspect(@types.is_branch_or_trunk(Pruned), content="false")
}

///|
test "is_solid" {
  inspect(@types.is_solid(Trunk), content="true")
  inspect(@types.is_solid(Branch), content="true")
  inspect(@types.is_solid(Leaf), content="true")
  inspect(@types.is_solid(Empty), content="false")
  inspect(@types.is_solid(Pruned), content="false")
}

///|
test "cell_screen_x and cell_screen_y" {
  inspect(@types.cell_screen_x(0), content="80")
  inspect(@types.cell_screen_y(0), content="40")
  inspect(@types.cell_screen_x(1), content="116")
  inspect(@types.cell_screen_y(1), content="76")
}

///|
test "screen_to_grid_x and screen_to_grid_y" {
  inspect(@types.screen_to_grid_x(80), content="0")
  inspect(@types.screen_to_grid_y(40), content="0")
  inspect(@types.screen_to_grid_x(116), content="1")
  inspect(@types.screen_to_grid_y(76), content="1")
}

///|
test "dir_dx and dir_dy" {
  inspect(@types.dir_dx(Up), content="0")
  inspect(@types.dir_dy(Up), content="-1")
  inspect(@types.dir_dx(UpLeft), content="-1")
  inspect(@types.dir_dy(UpLeft), content="-1")
  inspect(@types.dir_dx(UpRight), content="1")
  inspect(@types.dir_dy(UpRight), content="-1")
  inspect(@types.dir_dx(Left), content="-1")
  inspect(@types.dir_dy(Left), content="0")
  inspect(@types.dir_dx(Right), content="1")
  inspect(@types.dir_dy(Right), content="0")
}

///|
test "new_level_scores" {
  let scores = @types.new_level_scores()
  inspect(scores.length(), content="25")
  inspect(scores[0].stars, content="0")
  inspect(scores[0].completed, content="false")
}

///|
test "maxi and mini" {
  inspect(@types.maxi(3, 7), content="7")
  inspect(@types.maxi(10, 2), content="10")
  inspect(@types.mini(3, 7), content="3")
  inspect(@types.mini(10, 2), content="2")
}

///|
test "absi" {
  inspect(@types.absi(-5), content="5")
  inspect(@types.absi(3), content="3")
  inspect(@types.absi(0), content="0")
}

///|
test "set_message" {
  let game = @types.new_game()
  @types.set_message(game, "Test", 3.0)
  inspect(game.message, content="Test")
  inspect(game.message_timer, content="3")
}

///|
test "sinf and cosf basic" {
  inspect(@types.sinf(0.0), content="0")
  inspect(@types.cosf(0.0), content="1")
}

///|
test "new_game initial state" {
  let game = @types.new_game()
  inspect(game.screen, content="Title")
  inspect(game.turn, content="0")
  inspect(game.total_prunes, content="0")
  inspect(game.scores.length(), content="25")
  inspect(game.play_state, content="Waiting")
}
