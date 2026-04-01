///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count = game.frame_count + 1
  let dt = @types.minf(@raylib.get_frame_time(), 0.05)
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - dt
  }
  update_sparks(game, dt)
  match game.screen {
    Title => update_title(game)
    LevelSelect => update_level_select(game)
    Playing => update_playing(game)
    Simulating => update_simulating(game, dt)
    LevelComplete => update_level_complete(game)
    LevelFailed => update_level_failed(game)
  }
}

///|
fn update_sparks(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.sparks.length() {
    let s = game.sparks[i]
    if s.active {
      s.x = s.x + s.vx * dt
      s.y = s.y + s.vy * dt
      s.life = s.life - dt
      if s.life <= 0.0 {
        s.active = false
      }
    }
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = LevelSelect
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.current_level = @types.mini(
      game.current_level + 1,
      @types.total_levels - 1,
    )
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.current_level = @types.maxi(game.current_level - 1, 0)
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.current_level = @types.mini(
      game.current_level + 5,
      @types.total_levels - 1,
    )
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.current_level = @types.maxi(game.current_level - 5, 0)
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    let accessible = game.current_level == 0 ||
      game.level_results[game.current_level - 1].completed
    if accessible {
      start_level(game, game.current_level)
    } else {
      @types.set_message(game, "Complete previous level first!", 2.0)
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
  }
}

///|
fn start_level(game : @types.Game, level_id : Int) -> Unit {
  game.current_level = level_id
  game.level_state = Some(@levels.load_level(level_id))
  game.cursor_col = 0
  game.cursor_row = 0
  game.tool = PlaceMagnetN
  game.show_help = false
  game.screen = Playing
  let def = @levels.get_level(level_id)
  @types.set_message(game, def.name + ": " + def.description, 3.0)
}

///|
fn update_playing(game : @types.Game) -> Unit {
  match game.level_state {
    None => ()
    Some(state) => {
      // Cursor movement
      if @raylib.is_key_pressed(@raylib.KeyRight) {
        game.cursor_col = @types.mini(game.cursor_col + 1, @types.grid_cols - 1)
      }
      if @raylib.is_key_pressed(@raylib.KeyLeft) {
        game.cursor_col = @types.maxi(game.cursor_col - 1, 0)
      }
      if @raylib.is_key_pressed(@raylib.KeyDown) {
        game.cursor_row = @types.mini(game.cursor_row + 1, @types.grid_rows - 1)
      }
      if @raylib.is_key_pressed(@raylib.KeyUp) {
        game.cursor_row = @types.maxi(game.cursor_row - 1, 0)
      }
      // Tool selection
      if @raylib.is_key_pressed(@raylib.KeyOne) {
        game.tool = PlaceMagnetN
      }
      if @raylib.is_key_pressed(@raylib.KeyTwo) {
        game.tool = PlaceMagnetS
      }
      if @raylib.is_key_pressed(@raylib.KeyThree) {
        game.tool = PlaceCoil
      }
      if @raylib.is_key_pressed(@raylib.KeyFour) {
        game.tool = PlaceWire
      }
      if @raylib.is_key_pressed(@raylib.KeyFive) {
        game.tool = Erase
      }
      // Place / Use tool
      if @raylib.is_key_pressed(@raylib.KeySpace) {
        handle_tool_action(game, state)
      }
      // Simulate
      if @raylib.is_key_pressed(@raylib.KeyS) {
        @circuit.simulate(state)
        game.screen = Simulating
        game.animation_timer = 0.0
        for r in 0..<@types.grid_rows {
          for c in 0..<@types.grid_cols {
            let cell = state.cells[r][c]
            if cell.powered {
              let cx = @types.cell_center_x(c)
              let cy = @types.cell_center_y(r)
              @types.spawn_sparks(
                game.sparks,
                cx,
                cy,
                3,
                @types.color_coil_active,
              )
            }
          }
        }
      }
      // Reset level
      if @raylib.is_key_pressed(@raylib.KeyR) {
        start_level(game, game.current_level)
        @types.set_message(game, "Level reset!", 1.5)
      }
      // Help
      if @raylib.is_key_pressed(@raylib.KeyH) {
        game.show_help = !game.show_help
      }
      // Back to level select
      if @raylib.is_key_pressed(@raylib.KeyEscape) {
        game.level_state = None
        game.screen = LevelSelect
      }
    }
  }
}

///|
fn handle_tool_action(game : @types.Game, state : @types.LevelState) -> Unit {
  let c = game.cursor_col
  let r = game.cursor_row
  match game.tool {
    PlaceMagnetN => {
      let ok = @circuit.place_component(state, c, r, Magnet(North))
      if ok {
        let cx = @types.cell_center_x(c)
        let cy = @types.cell_center_y(r)
        @types.spawn_sparks(game.sparks, cx, cy, 5, @types.color_magnet_n)
        @types.set_message(game, "North magnet placed!", 1.0)
      } else {
        @types.set_message(game, "Cannot place magnet here", 1.0)
      }
    }
    PlaceMagnetS => {
      let ok = @circuit.place_component(state, c, r, Magnet(South))
      if ok {
        let cx = @types.cell_center_x(c)
        let cy = @types.cell_center_y(r)
        @types.spawn_sparks(game.sparks, cx, cy, 5, @types.color_magnet_s)
        @types.set_message(game, "South magnet placed!", 1.0)
      } else {
        @types.set_message(game, "Cannot place magnet here", 1.0)
      }
    }
    PlaceCoil =>
      if state.coil_budget == 0 {
        @types.set_message(game, "No coils available", 1.0)
      } else {
        let ok = @circuit.place_component(state, c, r, Coil)
        if ok {
          let cx = @types.cell_center_x(c)
          let cy = @types.cell_center_y(r)
          @types.spawn_sparks(game.sparks, cx, cy, 3, @types.color_coil)
          @types.set_message(game, "Coil placed!", 1.0)
        } else {
          @types.set_message(game, "Cannot place coil here", 1.0)
        }
      }
    PlaceWire => {
      let ok = @circuit.place_component(state, c, r, Wire)
      if ok {
        @types.set_message(game, "Wire placed!", 0.8)
      } else {
        @types.set_message(game, "Cannot place wire here", 1.0)
      }
    }
    Erase => {
      let ok = @circuit.remove_component(state, c, r)
      if ok {
        @types.set_message(game, "Component removed!", 0.8)
      } else {
        @types.set_message(game, "Cannot remove this", 1.0)
      }
    }
  }
  // Clear simulation state when modifying circuit
  state.simulated = false
  @circuit.reset_simulation(state)
}

///|
fn update_simulating(game : @types.Game, dt : Float) -> Unit {
  game.animation_timer = game.animation_timer + dt
  if game.animation_timer > 1.0 {
    match game.level_state {
      None => game.screen = Playing
      Some(state) => {
        let result = @circuit.evaluate_level(state)
        game.level_results[game.current_level] = result
        if result.completed {
          game.screen = LevelComplete
          for _i in 0..<20 {
            let x = @types.rng_range(100.0, 700.0)
            let y = @types.rng_range(100.0, 500.0)
            @types.spawn_sparks(game.sparks, x, y, 3, @types.color_star_filled)
          }
        } else {
          game.screen = LevelFailed
          @types.spawn_sparks(
            game.sparks,
            400.0,
            300.0,
            10,
            @types.color_unsatisfied,
          )
        }
      }
    }
  }
}

///|
fn update_level_complete(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.current_level < @types.total_levels - 1 {
      start_level(game, game.current_level + 1)
    } else {
      @types.set_message(
        game, "All levels complete! You're a master dynamo engineer!", 3.0,
      )
      game.screen = LevelSelect
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.level_state = None
    game.screen = LevelSelect
  }
}

///|
fn update_level_failed(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.screen = Playing
    match game.level_state {
      None => ()
      Some(state) => @circuit.reset_simulation(state)
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.current_level)
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.level_state = None
    game.screen = LevelSelect
  }
}
