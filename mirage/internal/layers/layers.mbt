///|
/// Get the tiles for the active layer
pub fn active_tiles(game : @types.Game) -> Array[@types.Tile] {
  match game.player.active_layer {
    Foreground => game.fg_tiles
    Background => game.bg_tiles
  }
}

///|
/// Get the tiles for the inactive layer
pub fn inactive_tiles(game : @types.Game) -> Array[@types.Tile] {
  match game.player.active_layer {
    Foreground => game.bg_tiles
    Background => game.fg_tiles
  }
}

///|
/// Check if a position is walkable in the current state
pub fn can_walk(game : @types.Game, x : Int, y : Int) -> Bool {
  if !@types.valid_pos(x, y) {
    return false
  }
  match game.merge_state {
    Split => {
      let tiles = active_tiles(game)
      let tile = @types.get_tile(tiles, x, y)
      @types.is_walkable(tile)
    }
    Merged => {
      let fg_tile = @types.get_tile(game.fg_tiles, x, y)
      let bg_tile = @types.get_tile(game.bg_tiles, x, y)
      @types.is_walkable(fg_tile) || @types.is_walkable(bg_tile)
    }
  }
}

///|
/// Swap the active layer (foreground <-> background)
pub fn swap_layer(game : @types.Game) -> Unit {
  if game.merge_state == Merged {
    return
  }
  match game.player.active_layer {
    Foreground => game.player.active_layer = Background
    Background => game.player.active_layer = Foreground
  }
  game.swap_count = game.swap_count + 1
  @types.start_anim(game.anim, LayerSwap, @types.anim_swap_duration)
}

///|
/// Toggle merge state
pub fn toggle_merge(game : @types.Game) -> Unit {
  match game.merge_state {
    Split => {
      game.merge_state = Merged
      @types.start_anim(game.anim, Merge, @types.anim_merge_duration)
      game.swap_count = game.swap_count + 1
    }
    Merged => {
      game.merge_state = Split
      @types.start_anim(game.anim, Merge, @types.anim_merge_duration)
    }
  }
}

///|
/// Activate a switch: toggle Platform tiles in the specified group
pub fn activate_switch(game : @types.Game, switch_id : Int) -> Unit {
  if switch_id < game.switch_states.length() {
    game.switch_states[switch_id] = !game.switch_states[switch_id]
  }
  // Toggle platform tiles between Floor and Platform in both layers
  // Switches affect the background layer platforms
  toggle_platforms_for_switch(game.bg_tiles, switch_id)
  @types.start_anim(game.anim, SwitchToggle, 0.2)
}

///|
fn toggle_platforms_for_switch(
  tiles : Array[@types.Tile],
  _switch_id : Int,
) -> Unit {
  for i in 0..<tiles.length() {
    match tiles[i] {
      Platform => tiles[i] = Floor
      _ => ()
    }
  }
}

///|
/// Check if the player is on the exit tile
pub fn check_exit(game : @types.Game) -> Bool {
  let x = game.player.grid_x
  let y = game.player.grid_y
  match game.merge_state {
    Split => {
      let tiles = active_tiles(game)
      let tile = @types.get_tile(tiles, x, y)
      tile == Exit
    }
    Merged => {
      let fg = @types.get_tile(game.fg_tiles, x, y)
      let bg = @types.get_tile(game.bg_tiles, x, y)
      fg == Exit || bg == Exit
    }
  }
}

///|
/// Check if the player is on a gem tile
pub fn check_gem(game : @types.Game) -> Bool {
  let x = game.player.grid_x
  let y = game.player.grid_y
  match game.merge_state {
    Split => {
      let tiles = active_tiles(game)
      let tile = @types.get_tile(tiles, x, y)
      tile == Gem
    }
    Merged => {
      let fg = @types.get_tile(game.fg_tiles, x, y)
      let bg = @types.get_tile(game.bg_tiles, x, y)
      fg == Gem || bg == Gem
    }
  }
}

///|
/// Check if the player is on a switch tile and return its ID
pub fn check_switch(game : @types.Game) -> Int {
  let x = game.player.grid_x
  let y = game.player.grid_y
  let tiles = active_tiles(game)
  let tile = @types.get_tile(tiles, x, y)
  match tile {
    Switch(id) => id
    _ => -1
  }
}

///|
/// Collect the gem at the player position
pub fn collect_gem(game : @types.Game) -> Unit {
  let x = game.player.grid_x
  let y = game.player.grid_y
  // Remove gem from whichever layer has it
  let fg = @types.get_tile(game.fg_tiles, x, y)
  let bg = @types.get_tile(game.bg_tiles, x, y)
  if fg == Gem {
    @types.set_tile(game.fg_tiles, x, y, Floor)
  }
  if bg == Gem {
    @types.set_tile(game.bg_tiles, x, y, Floor)
  }
  game.gem_collected = true
  @types.start_anim(game.anim, GemCollect, @types.anim_gem_duration)
}

///|
/// Calculate stars for level completion
pub fn calc_stars(
  swap_count : Int,
  par_swaps : Int,
  gem_collected : Bool,
) -> Int {
  let mut stars = 1 // Always get 1 star for completing
  if swap_count <= par_swaps {
    stars = 2
    if gem_collected {
      stars = 3
    }
  }
  stars
}
