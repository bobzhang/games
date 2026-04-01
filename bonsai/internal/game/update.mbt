///|
pub fn update(game : @types.Game) -> Unit {
  let dt = @raylib.get_frame_time()
  game.frame_count = game.frame_count + 1
  game.anim_timer = game.anim_timer + dt
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - dt
    if game.message_timer <= 0.0 {
      game.message = ""
    }
  }
  match game.screen {
    Title => update_title(game)
    TierSelect => update_tier_select(game)
    LevelSelect => update_level_select(game)
    Playing => update_playing(game)
    Results => update_results(game)
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
  game.title_seed_angle = game.title_seed_angle + 0.01
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    game.screen = TierSelect
  }
}

///|
fn update_tier_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
    return
  }
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    // Three tier buttons at y=250,350,450, centered
    let tiers : Array[@types.Tier] = [Tier1, Tier2, Tier3]
    for i in 0..<3 {
      let by = 250 + i * 100
      if mx >= 440 && mx <= 840 && my >= by && my <= by + 70 {
        // Check if tier is unlocked
        if is_tier_unlocked(game, tiers[i]) {
          game.current_tier = tiers[i]
          game.screen = LevelSelect
          return
        }
      }
    }
  }
}

///|
fn is_tier_unlocked(game : @types.Game, tier : @types.Tier) -> Bool {
  match tier {
    Tier1 => true
    Tier2 => {
      // Need at least 4 stars in tier 1 to unlock tier 2
      let mut stars = 0
      for i in 0..<8 {
        stars = stars + game.scores[i].stars
      }
      stars >= 4
    }
    Tier3 => {
      // Need at least 4 stars in tier 2 to unlock tier 3
      let mut stars = 0
      for i in 8..<17 {
        stars = stars + game.scores[i].stars
      }
      stars >= 4
    }
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = TierSelect
    return
  }
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let offset = @types.tier_level_offset(game.current_tier)
    let count = @types.tier_level_count(game.current_tier)
    // Level buttons in a grid: 4 columns, rows
    for i in 0..<count {
      let col = i % 4
      let row = i / 4
      let bx = 240 + col * 200
      let by = 220 + row * 120
      if mx >= bx && mx <= bx + 160 && my >= by && my <= by + 90 {
        let level_idx = offset + i
        if is_level_unlocked(game, level_idx) {
          start_level(game, level_idx)
          return
        }
      }
    }
  }
}

///|
fn is_level_unlocked(game : @types.Game, index : Int) -> Bool {
  if index == 0 {
    return true
  }
  let offset = @types.tier_level_offset(game.current_tier)
  if index == offset {
    // First level in tier is unlocked if tier is unlocked
    return is_tier_unlocked(game, game.current_tier)
  }
  // Previous level must be completed
  game.scores[index - 1].completed
}

///|
fn start_level(game : @types.Game, index : Int) -> Unit {
  let level = @levels.get_level(index)
  game.current_level = Some(level)
  game.selected_level = index
  game.turn = 0
  game.prunes_this_turn = 0
  game.total_prunes = 0
  game.history = []
  game.play_state = Waiting
  game.show_ghost = false
  game.ghost_tree = None
  game.hover_cell = None
  game.screen = Playing
  // Initialize grid
  let grid = @types.new_grid(@types.grid_width, @types.grid_height)
  // Place trunk at root
  let root_x = 5
  let root_y = 15
  @types.grid_set_kind(grid, root_x, root_y, Trunk, Up)
  // Place initial branches
  for seed in level.initial_branches {
    if @types.grid_in_bounds(grid, seed.x, seed.y) {
      let kind : @types.CellKind = if seed.y == 15 { Trunk } else { Branch }
      @types.grid_set_kind(grid, seed.x, seed.y, kind, seed.dir)
      grid.cells[@types.grid_index(grid, seed.x, seed.y)].age = 1
    }
  }
  game.tree = grid
  @types.set_message(game, "Turn 1 - Click branch to prune, SPACE to grow", 3.0)
}

///|
fn update_playing(game : @types.Game) -> Unit {
  match game.current_level {
    None => {
      game.screen = TierSelect
      return
    }
    Some(level) => {
      if game.play_state == Won || game.play_state == Lost {
        // Wait for key to go to results
        if @raylib.is_key_pressed(@raylib.KeyEnter) ||
          @raylib.is_key_pressed(@raylib.KeySpace) {
          game.screen = Results
        }
        return
      }
      // Handle input
      // ESC: back to level select
      if @raylib.is_key_pressed(@raylib.KeyEscape) {
        game.screen = LevelSelect
        return
      }
      // R: restart level
      if @raylib.is_key_pressed(@raylib.KeyR) {
        start_level(game, game.selected_level)
        return
      }
      // Z: undo last prune (restore from history)
      if @raylib.is_key_pressed(@raylib.KeyZ) && game.history.length() > 0 {
        let snap = game.history.unsafe_pop()
        @types.restore_grid(game.tree, snap)
        if game.prunes_this_turn > 0 {
          game.prunes_this_turn = game.prunes_this_turn - 1
          game.total_prunes = game.total_prunes - 1
        }
        game.ghost_tree = None
        @types.set_message(game, "Undo!", 1.0)
        return
      }
      // G: toggle ghost preview
      if @raylib.is_key_pressed(@raylib.KeyG) {
        game.show_ghost = !game.show_ghost
        if game.show_ghost {
          game.ghost_tree = Some(
            @growth.preview_two_turns(game.tree, level.species),
          )
          @types.set_message(game, "Ghost preview ON", 1.0)
        } else {
          game.ghost_tree = None
          @types.set_message(game, "Ghost preview OFF", 1.0)
        }
        return
      }
      // SPACE/ENTER: advance turn (grow)
      if @raylib.is_key_pressed(@raylib.KeySpace) ||
        @raylib.is_key_pressed(@raylib.KeyEnter) {
        advance_turn(game, level)
        return
      }
      // Mouse: hover and click to prune
      let mx = @raylib.get_mouse_x()
      let my = @raylib.get_mouse_y()
      let gx = @types.screen_to_grid_x(mx)
      let gy = @types.screen_to_grid_y(my)
      if @types.grid_in_bounds(game.tree, gx, gy) {
        game.hover_cell = Some({ x: gx, y: gy })
      } else {
        game.hover_cell = None
      }
      // Click to prune
      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        if @types.grid_in_bounds(game.tree, gx, gy) {
          let cell = @types.grid_get(game.tree, gx, gy)
          if (cell.kind == Branch || cell.kind == Leaf) &&
            game.prunes_this_turn < level.prune_budget_per_turn {
            // Save state for undo
            game.history.push(@types.snapshot_grid(game.tree))
            let removed = @growth.prune_at(game.tree, gx, gy)
            if removed > 0 {
              game.prunes_this_turn = game.prunes_this_turn + 1
              game.total_prunes = game.total_prunes + 1
              // Update ghost if showing
              if game.show_ghost {
                game.ghost_tree = Some(
                  @growth.preview_two_turns(game.tree, level.species),
                )
              }
              @types.set_message(
                game,
                "Pruned " + removed.to_string() + " cells",
                1.5,
              )
            } else {
              // Undo the snapshot since nothing was pruned
              let _ = game.history.unsafe_pop()
            }
          } else if cell.kind == Trunk {
            @types.set_message(game, "Can't prune the trunk!", 1.5)
          } else if game.prunes_this_turn >= level.prune_budget_per_turn {
            @types.set_message(game, "No more prunes this turn!", 1.5)
          }
        }
      }
    }
  }
}

///|
fn advance_turn(game : @types.Game, level : @types.Level) -> Unit {
  game.turn = game.turn + 1
  game.prunes_this_turn = 0
  // Clear undo history for new turn
  game.history = []
  // Grow
  let new_tree = @growth.grow_one_turn(game.tree, level.species)
  // Copy result back
  for i in 0..<game.tree.cells.length() {
    game.tree.cells[i].kind = new_tree.cells[i].kind
    game.tree.cells[i].growth_dir = new_tree.cells[i].growth_dir
    game.tree.cells[i].age = new_tree.cells[i].age
    game.tree.cells[i].stagnant_turns = new_tree.cells[i].stagnant_turns
  }
  // Update ghost
  if game.show_ghost {
    game.ghost_tree = Some(@growth.preview_two_turns(game.tree, level.species))
  }
  // Check win/lose
  if game.turn >= level.max_turns {
    // Game over - check zones
    let stars = @growth.calculate_stars(
      game.tree,
      level.zones,
      game.total_prunes,
      level.par_prunes,
    )
    if stars > 0 {
      game.play_state = Won
      // Update scores
      let idx = game.selected_level
      if stars > game.scores[idx].stars {
        game.scores[idx].stars = stars
      }
      game.scores[idx].completed = true
      @types.set_message(
        game,
        "Level Complete! " + stars.to_string() + " stars! Press SPACE",
        5.0,
      )
    } else {
      game.play_state = Lost
      @types.set_message(game, "Zones not satisfied. Press SPACE", 5.0)
    }
  } else {
    let turn_str = (game.turn + 1).to_string()
    let max_str = level.max_turns.to_string()
    @types.set_message(game, "Turn " + turn_str + "/" + max_str, 1.5)
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = LevelSelect
    return
  }
  // R: retry
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.selected_level)
  }
}
