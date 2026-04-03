///|
test "tile_index basic" {
  inspect(@types.tile_index(0, 0), content="0")
  inspect(@types.tile_index(1, 0), content="1")
  inspect(@types.tile_index(0, 1), content="12")
  inspect(@types.tile_index(11, 7), content="95")
}

///|
test "valid_pos boundary checks" {
  inspect(@types.valid_pos(0, 0), content="true")
  inspect(@types.valid_pos(11, 7), content="true")
  inspect(@types.valid_pos(12, 0), content="false")
  inspect(@types.valid_pos(0, 8), content="false")
  inspect(@types.valid_pos(-1, 0), content="false")
  inspect(@types.valid_pos(0, -1), content="false")
}

///|
test "grid_to_pixel conversions" {
  let x = @types.grid_to_pixel_x(0)
  inspect(x, content="96")
  let y = @types.grid_to_pixel_y(0)
  inspect(y, content="120")
  let x2 = @types.grid_to_pixel_x(1)
  inspect(x2, content="160")
}

///|
test "is_walkable for each tile type" {
  inspect(@types.is_walkable(Floor), content="true")
  inspect(@types.is_walkable(Exit), content="true")
  inspect(@types.is_walkable(Switch(0)), content="true")
  inspect(@types.is_walkable(Platform), content="true")
  inspect(@types.is_walkable(Gem), content="true")
  inspect(@types.is_walkable(Wall), content="false")
  inspect(@types.is_walkable(Gap), content="false")
  inspect(@types.is_walkable(Empty), content="false")
}

///|
test "is_solid_in_layer platform behavior" {
  // Platform is solid in foreground, not in background
  inspect(@types.is_solid_in_layer(Platform, Foreground), content="true")
  inspect(@types.is_solid_in_layer(Platform, Background), content="false")
  // Floor is solid in both
  inspect(@types.is_solid_in_layer(Floor, Foreground), content="true")
  inspect(@types.is_solid_in_layer(Floor, Background), content="true")
  // Wall is not walkable in either
  inspect(@types.is_solid_in_layer(Wall, Foreground), content="false")
  inspect(@types.is_solid_in_layer(Wall, Background), content="false")
}

///|
test "get_tile and set_tile" {
  let tiles = @types.empty_grid()
  inspect(@types.get_tile(tiles, 0, 0), content="Empty")
  @types.set_tile(tiles, 5, 3, Floor)
  inspect(@types.get_tile(tiles, 5, 3), content="Floor")
  // Out of bounds returns Wall
  inspect(@types.get_tile(tiles, -1, 0), content="Wall")
  inspect(@types.get_tile(tiles, 12, 0), content="Wall")
}

///|
test "clampf" {
  inspect(@types.clampf(0.5, 0.0, 1.0), content="0.5")
  inspect(@types.clampf(-1.0, 0.0, 1.0), content="0")
  inspect(@types.clampf(2.0, 0.0, 1.0), content="1")
}

///|
test "clampi" {
  inspect(@types.clampi(5, 0, 10), content="5")
  inspect(@types.clampi(-1, 0, 10), content="0")
  inspect(@types.clampi(15, 0, 10), content="10")
}

///|
test "absf" {
  inspect(@types.absf(5.0), content="5")
  inspect(@types.absf(-5.0), content="5")
  inspect(@types.absf(0.0), content="0")
}

///|
test "minf and maxf" {
  inspect(@types.minf(3.0, 7.0), content="3")
  inspect(@types.maxf(3.0, 7.0), content="7")
}

///|
test "mini and maxi" {
  inspect(@types.mini(3, 7), content="3")
  inspect(@types.maxi(3, 7), content="7")
}

///|
test "lerpf" {
  inspect(@types.lerpf(0.0, 10.0, 0.0), content="0")
  inspect(@types.lerpf(0.0, 10.0, 1.0), content="10")
  inspect(@types.lerpf(0.0, 10.0, 0.5), content="5")
}

///|
test "sinf and cosf" {
  inspect(@types.sinf(0.0), content="0")
  inspect(@types.cosf(0.0), content="1")
}

///|
test "animation lifecycle" {
  let anim = @types.new_animation()
  inspect(anim.active, content="false")
  @types.start_anim(anim, LayerSwap, 0.5)
  inspect(anim.active, content="true")
  inspect(anim.kind, content="LayerSwap")
  @types.update_anim(anim, 0.25)
  inspect(anim.active, content="true")
  let progress = @types.anim_progress(anim)
  inspect(progress, content="0.5")
  @types.update_anim(anim, 0.3)
  inspect(anim.active, content="false")
}

///|
test "new_player initial state" {
  let p = @types.new_player(3, 4, Foreground)
  inspect(p.grid_x, content="3")
  inspect(p.grid_y, content="4")
  inspect(p.active_layer, content="Foreground")
  inspect(p.moving, content="false")
}

///|
test "new_game initializes correctly" {
  let game = @types.new_game()
  inspect(game.screen, content="Title")
  inspect(game.current_level, content="0")
  inspect(game.swap_count, content="0")
  inspect(game.gem_collected, content="false")
  inspect(game.merge_state, content="Split")
  inspect(game.level_results.length(), content="20")
  inspect(game.fg_tiles.length(), content="96")
  inspect(game.bg_tiles.length(), content="96")
}

///|
test "new_level_result defaults" {
  let r = @types.new_level_result()
  inspect(r.completed, content="false")
  inspect(r.stars, content="0")
  inspect(r.best_swaps, content="999")
}

///|
test "tier_for_level" {
  inspect(@types.tier_for_level(0), content="Reflection")
  inspect(@types.tier_for_level(6), content="Reflection")
  inspect(@types.tier_for_level(7), content="Overlap")
  inspect(@types.tier_for_level(13), content="Overlap")
  inspect(@types.tier_for_level(14), content="Illusion")
  inspect(@types.tier_for_level(19), content="Illusion")
}

///|
test "tier_name" {
  inspect(@types.tier_name(Reflection), content="Reflection")
  inspect(@types.tier_name(Overlap), content="Overlap")
  inspect(@types.tier_name(Illusion), content="Illusion")
}

///|
test "level_unlocked" {
  let results : Array[@types.LevelResult] = []
  for _i in 0..<20 {
    results.push(@types.new_level_result())
  }
  // Level 0 always unlocked
  inspect(@types.level_unlocked(results, 0), content="true")
  // Level 1 locked until level 0 completed
  inspect(@types.level_unlocked(results, 1), content="false")
  results[0].completed = true
  inspect(@types.level_unlocked(results, 1), content="true")
  // Level 2 still locked
  inspect(@types.level_unlocked(results, 2), content="false")
}

///|
test "set_message" {
  let game = @types.new_game()
  @types.set_message(game, "Hello", 1.5)
  inspect(game.message, content="Hello")
  inspect(game.message_timer, content="1.5")
}

///|
test "empty_grid size" {
  let grid = @types.empty_grid()
  inspect(grid.length(), content="96")
  // All empty
  let mut all_empty = true
  for i in 0..<grid.length() {
    if grid[i] != Empty {
      all_empty = false
      break
    }
  }
  inspect(all_empty, content="true")
}
