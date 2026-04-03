///|
test "calc_stars - 1 star just complete" {
  let stars = @layers.calc_stars(10, 5, false)
  inspect(stars, content="1")
}

///|
test "calc_stars - 2 stars at par" {
  let stars = @layers.calc_stars(5, 5, false)
  inspect(stars, content="2")
}

///|
test "calc_stars - 2 stars under par no gem" {
  let stars = @layers.calc_stars(3, 5, false)
  inspect(stars, content="2")
}

///|
test "calc_stars - 3 stars par plus gem" {
  let stars = @layers.calc_stars(5, 5, true)
  inspect(stars, content="3")
}

///|
test "calc_stars - 3 stars under par plus gem" {
  let stars = @layers.calc_stars(2, 5, true)
  inspect(stars, content="3")
}

///|
test "calc_stars - 1 star over par even with gem" {
  let stars = @layers.calc_stars(6, 5, true)
  inspect(stars, content="1")
}

///|
test "can_walk on empty grid" {
  let game = @types.new_game()
  // Empty tiles are not walkable
  inspect(@layers.can_walk(game, 0, 0), content="false")
}

///|
test "can_walk on floor tile" {
  let game = @types.new_game()
  @types.set_tile(game.fg_tiles, 5, 3, Floor)
  game.player.active_layer = Foreground
  inspect(@layers.can_walk(game, 5, 3), content="true")
}

///|
test "can_walk respects active layer" {
  let game = @types.new_game()
  @types.set_tile(game.fg_tiles, 5, 3, Floor)
  @types.set_tile(game.bg_tiles, 5, 3, Wall)
  // Foreground: walkable
  game.player.active_layer = Foreground
  inspect(@layers.can_walk(game, 5, 3), content="true")
  // Background: not walkable
  game.player.active_layer = Background
  inspect(@layers.can_walk(game, 5, 3), content="false")
}

///|
test "can_walk merged mode uses both layers" {
  let game = @types.new_game()
  @types.set_tile(game.fg_tiles, 5, 3, Wall)
  @types.set_tile(game.bg_tiles, 5, 3, Floor)
  game.merge_state = Merged
  // Even though fg is Wall, bg is Floor, so merged = walkable
  inspect(@layers.can_walk(game, 5, 3), content="true")
}

///|
test "can_walk out of bounds" {
  let game = @types.new_game()
  inspect(@layers.can_walk(game, -1, 0), content="false")
  inspect(@layers.can_walk(game, 12, 0), content="false")
  inspect(@layers.can_walk(game, 0, 8), content="false")
}

///|
test "swap_layer toggles between fg and bg" {
  let game = @types.new_game()
  inspect(game.player.active_layer, content="Foreground")
  @layers.swap_layer(game)
  inspect(game.player.active_layer, content="Background")
  inspect(game.swap_count, content="1")
  @layers.swap_layer(game)
  inspect(game.player.active_layer, content="Foreground")
  inspect(game.swap_count, content="2")
}

///|
test "swap_layer blocked in merged mode" {
  let game = @types.new_game()
  game.merge_state = Merged
  let layer_before = game.player.active_layer
  @layers.swap_layer(game)
  inspect(game.player.active_layer == layer_before, content="true")
  inspect(game.swap_count, content="0")
}

///|
test "toggle_merge changes state" {
  let game = @types.new_game()
  inspect(game.merge_state, content="Split")
  @layers.toggle_merge(game)
  inspect(game.merge_state, content="Merged")
  inspect(game.swap_count, content="1")
  @layers.toggle_merge(game)
  inspect(game.merge_state, content="Split")
}

///|
test "check_exit on exit tile" {
  let game = @types.new_game()
  @types.set_tile(game.fg_tiles, 3, 4, Exit)
  game.player.grid_x = 3
  game.player.grid_y = 4
  game.player.active_layer = Foreground
  inspect(@layers.check_exit(game), content="true")
}

///|
test "check_exit on non-exit tile" {
  let game = @types.new_game()
  @types.set_tile(game.fg_tiles, 3, 4, Floor)
  game.player.grid_x = 3
  game.player.grid_y = 4
  game.player.active_layer = Foreground
  inspect(@layers.check_exit(game), content="false")
}

///|
test "check_gem and collect" {
  let game = @types.new_game()
  @types.set_tile(game.fg_tiles, 5, 2, Gem)
  game.player.grid_x = 5
  game.player.grid_y = 2
  game.player.active_layer = Foreground
  inspect(@layers.check_gem(game), content="true")
  inspect(game.gem_collected, content="false")
  @layers.collect_gem(game)
  inspect(game.gem_collected, content="true")
  // Gem tile replaced with floor
  inspect(@types.get_tile(game.fg_tiles, 5, 2), content="Floor")
}

///|
test "check_switch returns switch id" {
  let game = @types.new_game()
  @types.set_tile(game.fg_tiles, 4, 3, Switch(2))
  game.player.grid_x = 4
  game.player.grid_y = 3
  game.player.active_layer = Foreground
  inspect(@layers.check_switch(game), content="2")
}

///|
test "check_switch returns -1 on non-switch" {
  let game = @types.new_game()
  @types.set_tile(game.fg_tiles, 4, 3, Floor)
  game.player.grid_x = 4
  game.player.grid_y = 3
  game.player.active_layer = Foreground
  inspect(@layers.check_switch(game), content="-1")
}

///|
test "active_tiles returns correct layer" {
  let game = @types.new_game()
  @types.set_tile(game.fg_tiles, 0, 0, Floor)
  @types.set_tile(game.bg_tiles, 0, 0, Wall)
  game.player.active_layer = Foreground
  let tiles = @layers.active_tiles(game)
  inspect(tiles[0], content="Floor")
  game.player.active_layer = Background
  let tiles2 = @layers.active_tiles(game)
  inspect(tiles2[0], content="Wall")
}
