///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count += 1
  game.title_anim += 1.0 / 60.0
  // Update message timer
  if game.message_timer > 0.0 {
    game.message_timer -= 1.0 / 60.0
  }
  match game.screen {
    Title => update_title(game)
    WorldSelect => update_world_select(game)
    LevelSelect => update_level_select(game)
    Programming => update_programming(game)
    Results => update_results(game)
    Sandbox => update_programming(game)
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.screen = WorldSelect
    game.current_world = 0
  }
  if @raylib.is_key_pressed(@raylib.KeyS) {
    // Sandbox mode - go to programming with a basic empty level
    start_sandbox(game)
  }
}

///|
fn update_world_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    if game.current_world < @types.num_worlds - 1 {
      game.current_world += 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    if game.current_world > 0 {
      game.current_world -= 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.screen = LevelSelect
    game.current_level = 0
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = WorldSelect
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    let col = game.current_level % 3
    if col < 2 && game.current_level < @types.levels_per_world - 1 {
      game.current_level += 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    let col = game.current_level % 3
    if col > 0 {
      game.current_level -= 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    if game.current_level + 3 < @types.levels_per_world {
      game.current_level += 3
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    if game.current_level - 3 >= 0 {
      game.current_level -= 3
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    start_level(game, game.current_world, game.current_level)
  }
}

///|
fn start_level(game : @types.Game, world : Int, index : Int) -> Unit {
  let def = @levels.get_level_def(world, index)
  let level = @levels.parse_level(def)
  game.level_def = Some(def)
  game.level = Some(level)
  game.program = @types.new_program()
  @editor.init_editor(game.editor, def.available_commands)
  game.run_state = Editing
  game.trace = None
  game.trace_step = 0
  game.trace_timer = 0.0
  game.run_speed = 1
  game.screen = Programming
}

///|
fn start_sandbox(game : @types.Game) -> Unit {
  let def : @types.LevelDef = {
    world: 0,
    index: 0,
    name: "Sandbox",
    ascii: [
      "............", "............", "............", "............", ".....S......",
      "............", "............", "............", "............",
    ],
    start_x: 5,
    start_y: 4,
    start_dir: East,
    par: 99,
    optimal: 1,
    hint: "Free play! Experiment with commands.",
    available_commands: [
      Move,
      TurnLeft,
      TurnRight,
      Jump,
      Push,
      If(PathAhead),
      If(WallAhead),
      If(AtGoal),
      If(OnColor(Red)),
      If(OnColor(Blue)),
      Loop(2),
      Loop(3),
      Loop(4),
      Loop(5),
    ],
  }
  let level = @levels.parse_level(def)
  game.level_def = Some(def)
  game.level = Some(level)
  game.program = @types.new_program()
  @editor.init_editor(game.editor, def.available_commands)
  game.run_state = Editing
  game.trace = None
  game.trace_step = 0
  game.screen = Sandbox
}

///|
fn update_programming(game : @types.Game) -> Unit {
  match game.run_state {
    Editing => update_editing(game)
    Running => update_running(game)
    Stepping => update_stepping(game)
    Complete => update_complete(game)
    Failed(_) => update_failed(game)
  }
}

///|
fn update_editing(game : @types.Game) -> Unit {
  // Escape - go back
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    if game.editor.palette_open {
      @editor.close_palette(game.editor)
      return
    }
    if game.screen == Sandbox {
      game.screen = Title
    } else {
      game.screen = LevelSelect
    }
    return
  }
  // Navigation
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    @editor.cursor_up(game.editor, game.program)
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    @editor.cursor_down(game.editor, game.program)
  }
  // Space - toggle palette or select from palette
  if @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.editor.palette_open {
      @editor.select_from_palette(game.editor, game.program) |> ignore
    } else {
      @editor.toggle_palette(game.editor)
    }
  }
  // Backspace / Delete - remove command
  if @raylib.is_key_pressed(@raylib.KeyBackspace) ||
    @raylib.is_key_pressed(@raylib.KeyDelete) {
    @editor.delete_at_cursor(game.editor, game.program) |> ignore
  }
  // W/S - move command up/down
  if @raylib.is_key_pressed(@raylib.KeyW) {
    @editor.move_cmd_up(game.editor, game.program) |> ignore
  }
  if @raylib.is_key_pressed(@raylib.KeyS) && !game.editor.palette_open {
    @editor.move_cmd_down(game.editor, game.program) |> ignore
  }
  // C - clear program
  if @raylib.is_key_pressed(@raylib.KeyC) {
    @editor.clear_program(game.editor, game.program)
  }
  // R - reset level
  if @raylib.is_key_pressed(@raylib.KeyR) {
    reset_level(game)
  }
  // Quick add: number keys 1-9 to add command from palette
  let number_keys = [
    @raylib.KeyOne,
    @raylib.KeyTwo,
    @raylib.KeyThree,
    @raylib.KeyFour,
    @raylib.KeyFive,
    @raylib.KeySix,
    @raylib.KeySeven,
    @raylib.KeyEight,
    @raylib.KeyNine,
  ]
  for i in 0..<number_keys.length() {
    if @raylib.is_key_pressed(number_keys[i]) {
      @editor.add_command_by_index(game.editor, game.program, i) |> ignore
    }
  }
  // Enter - run program
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    if game.editor.palette_open {
      @editor.select_from_palette(game.editor, game.program) |> ignore
    } else {
      run_program(game)
    }
  }
  // Tab - step mode
  if @raylib.is_key_pressed(@raylib.KeyTab) {
    start_stepping(game)
  }
}

///|
fn run_program(game : @types.Game) -> Unit {
  if game.program.commands.length() == 0 {
    game.message = "Program is empty!"
    game.message_timer = 2.0
    return
  }
  // Reload level fresh
  match game.level_def {
    None => ()
    Some(def) => {
      let level = @levels.reload_level(def)
      game.level = Some(level)
      let trace = @simulator.simulate(game.program, level)
      game.trace = Some(trace)
      game.trace_step = 0
      game.trace_timer = 0.0
      game.run_state = Running
    }
  }
}

///|
fn start_stepping(game : @types.Game) -> Unit {
  if game.program.commands.length() == 0 {
    game.message = "Program is empty!"
    game.message_timer = 2.0
    return
  }
  match game.level_def {
    None => ()
    Some(def) => {
      let level = @levels.reload_level(def)
      game.level = Some(level)
      let trace = @simulator.simulate(game.program, level)
      game.trace = Some(trace)
      game.trace_step = 0
      game.trace_timer = 0.0
      game.run_state = Stepping
    }
  }
}

///|
fn update_running(game : @types.Game) -> Unit {
  // Speed controls
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    game.run_speed = 1
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) {
    game.run_speed = 2
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) {
    game.run_speed = 3
  }
  if @raylib.is_key_pressed(@raylib.KeyFour) {
    game.run_speed = 4
  }
  // Space to pause/step
  if @raylib.is_key_pressed(@raylib.KeySpace) {
    game.run_state = Stepping
    return
  }
  // R to reset
  if @raylib.is_key_pressed(@raylib.KeyR) {
    reset_level(game)
    return
  }
  // Escape to go back to editing
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    reset_level(game)
    return
  }
  // Auto-advance trace
  let speed_delay : Float = match game.run_speed {
    1 => 0.3
    2 => 0.15
    3 => 0.08
    4 => 0.03
    _ => 0.3
  }
  game.trace_timer += 1.0 / 60.0
  if game.trace_timer >= speed_delay {
    game.trace_timer = 0.0
    advance_trace(game)
  }
}

///|
fn update_stepping(game : @types.Game) -> Unit {
  // Space to advance one step
  if @raylib.is_key_pressed(@raylib.KeySpace) {
    advance_trace(game)
  }
  // Enter to switch to running mode
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.run_state = Running
  }
  // R to reset
  if @raylib.is_key_pressed(@raylib.KeyR) {
    reset_level(game)
  }
  // Escape to reset
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    reset_level(game)
  }
}

///|
fn advance_trace(game : @types.Game) -> Unit {
  match game.trace {
    None => ()
    Some(trace) =>
      if game.trace_step < trace.states.length() - 1 {
        game.trace_step += 1
        // Check if last state and robot is dead
        let state = trace.states[game.trace_step]
        if !state.alive {
          game.run_state = Failed(trace.fail_reason)
        }
        // Reached end of trace
      } else if trace.success {
        complete_level(game)
      } else {
        game.run_state = Failed(trace.fail_reason)
      }
  }
}

///|
fn complete_level(game : @types.Game) -> Unit {
  game.run_state = Complete
  if game.screen == Sandbox {
    game.message = "Program executed successfully!"
    game.message_timer = 3.0
    return
  }
  match game.level_def {
    None => ()
    Some(def) => {
      let cmd_count = game.program.commands.length()
      let medal = @types.medal_from_instructions(
        cmd_count,
        def.par,
        def.optimal,
      )
      let score = game.scores[def.world][def.index]
      score.completed = true
      if cmd_count < score.best_instructions {
        score.best_instructions = cmd_count
      }
      // Update medal if better
      let new_stars = @types.medal_stars(medal)
      let old_stars = @types.medal_stars(score.medal)
      if new_stars > old_stars {
        score.medal = medal
      }
      game.total_stars = @types.calculate_total_stars(game.scores)
      game.screen = Results
    }
  }
}

///|
fn update_complete(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyR) {
    reset_level(game)
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    if game.screen == Sandbox {
      game.run_state = Editing
    } else {
      game.screen = LevelSelect
    }
    return
  }
  // In Results screen, Enter goes to results handled differently
  if game.screen == Programming || game.screen == Sandbox {
    if @raylib.is_key_pressed(@raylib.KeyEnter) {
      reset_level(game)
    }
  }
}

///|
fn update_failed(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyR) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) {
    reset_level(game)
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    if game.screen == Sandbox {
      game.run_state = Editing
      reset_level(game)
    } else {
      game.screen = LevelSelect
    }
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    // Go to next level
    let next_level = game.current_level + 1
    if next_level < @types.levels_per_world {
      start_level(game, game.current_world, next_level)
      game.current_level = next_level
    } else {
      // Go back to level select
      game.screen = LevelSelect
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    // Retry level
    start_level(game, game.current_world, game.current_level)
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}

///|
fn reset_level(game : @types.Game) -> Unit {
  match game.level_def {
    None => ()
    Some(def) => {
      let level = @levels.reload_level(def)
      game.level = Some(level)
    }
  }
  game.run_state = Editing
  game.trace = None
  game.trace_step = 0
  game.trace_timer = 0.0
}
