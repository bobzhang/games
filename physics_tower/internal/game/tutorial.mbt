///|
/// Total number of tutorial steps.
let tutorial_total_steps : Int = 3

///|
/// Duration between blinks for tutorial highlights.
let tutorial_blink_period : Float = 1.5

///|
/// Playback speed for tutorial step transitions.
let tutorial_step_delay : Float = 0.5

///|
/// Initializes the tutorial for level 1, first playthrough.
pub fn init_tutorial(game : @types.Game) -> Unit {
  if game.tutorial_shown {
    return
  }
  let tut = game.tutorial
  tut.step = 0
  tut.completed = false
  tut.blink_timer = 0.0
  setup_tutorial_step(tut, 0, game)
}

///|
/// Sets up the visual state for a given tutorial step.
fn setup_tutorial_step(
  tut : @types.TutorialState,
  step : Int,
  game : @types.Game,
) -> Unit {
  ignore(game)
  tut.step = step
  match step {
    0 => {
      // Step 1: Click to place a beam - highlight the piece palette
      tut.message = "Click in the build area to place a piece"
      tut.highlight_x = @types.panel_x
      tut.highlight_y = 60
      tut.highlight_w = @types.panel_w
      tut.highlight_h = 140
      tut.show_arrow = true
      tut.arrow_x = @types.panel_x - 30
      tut.arrow_y = 130
    }
    1 => {
      // Step 2: Press R to rotate - show rotation hint
      tut.message = "Press R to rotate the piece before placing"
      tut.highlight_x = @types.screen_w / 2 - 100
      tut.highlight_y = @types.screen_h - 50
      tut.highlight_w = 200
      tut.highlight_h = 40
      tut.show_arrow = true
      tut.arrow_x = @types.screen_w / 2
      tut.arrow_y = @types.screen_h - 60
    }
    2 => {
      // Step 3: Press T to test - highlight test action
      tut.message = "Press T or Enter to test your tower!"
      tut.highlight_x = @types.screen_w / 2 - 120
      tut.highlight_y = @types.screen_h - 50
      tut.highlight_w = 240
      tut.highlight_h = 40
      tut.show_arrow = true
      tut.arrow_x = @types.screen_w / 2
      tut.arrow_y = @types.screen_h - 60
    }
    _ => {
      tut.completed = true
      tut.show_arrow = false
      tut.message = ""
    }
  }
}

///|
/// Updates the tutorial state each frame. Returns true if tutorial consumed
/// the input (so the game should not process it again).
pub fn update_tutorial(game : @types.Game, dt : Float) -> Bool {
  let tut = game.tutorial
  if tut.completed || game.tutorial_shown {
    return false
  }
  // Update blink timer
  tut.blink_timer = tut.blink_timer + dt
  if tut.blink_timer > tutorial_blink_period * 2.0 {
    tut.blink_timer = 0.0
  }
  // Check for step completion conditions
  match tut.step {
    0 =>
      // Step 1 completes when a piece is placed (bodies > 0)
      if game.world.bodies.length() > 0 {
        advance_tutorial(game)
        return false
      }
    1 =>
      // Step 2 completes when R is pressed
      if @raylib.is_key_pressed(@raylib.KeyR) {
        advance_tutorial(game)
        return false
      }
    2 =>
      // Step 3 completes when T is pressed (will also trigger test)
      if @raylib.is_key_pressed(@raylib.KeyT) ||
        @raylib.is_key_pressed(@raylib.KeyEnter) {
        finish_tutorial(game)
        return false
      }
    _ => ()
  }
  false
}

///|
/// Advances to the next tutorial step.
fn advance_tutorial(game : @types.Game) -> Unit {
  let tut = game.tutorial
  let next = tut.step + 1
  if next >= tutorial_total_steps {
    finish_tutorial(game)
  } else {
    setup_tutorial_step(tut, next, game)
  }
}

///|
/// Marks the tutorial as complete.
fn finish_tutorial(game : @types.Game) -> Unit {
  game.tutorial.completed = true
  game.tutorial.show_arrow = false
  game.tutorial.message = ""
  game.tutorial_shown = true
}

///|
/// Checks if the tutorial should be shown for the current level.
pub fn should_show_tutorial(game : @types.Game) -> Bool {
  game.current_level == 0 && !game.tutorial_shown && !game.tutorial.completed
}

///|
/// Resets the tutorial state for replaying.
pub fn reset_tutorial(game : @types.Game) -> Unit {
  let tut = game.tutorial
  tut.step = 0
  tut.completed = false
  tut.blink_timer = 0.0
  tut.show_arrow = false
  tut.message = ""
}

///|
/// Returns the current tutorial message for display.
pub fn tutorial_message(game : @types.Game) -> String {
  if game.tutorial.completed || game.tutorial_shown {
    return ""
  }
  game.tutorial.message
}

///|
/// Returns the current tutorial step number (1-based for display).
pub fn tutorial_step_number(game : @types.Game) -> Int {
  game.tutorial.step + 1
}

///|
/// Returns total tutorial steps.
pub fn tutorial_total() -> Int {
  tutorial_total_steps
}

///|
/// Returns whether the tutorial highlight should be visible (blink effect).
pub fn tutorial_highlight_visible(game : @types.Game) -> Bool {
  let tut = game.tutorial
  if tut.completed || game.tutorial_shown {
    return false
  }
  // Blink on/off
  tut.blink_timer < tutorial_blink_period
}

///|
/// Returns the highlight rectangle for the current tutorial step.
pub fn tutorial_highlight_rect(game : @types.Game) -> (Int, Int, Int, Int) {
  let tut = game.tutorial
  (tut.highlight_x, tut.highlight_y, tut.highlight_w, tut.highlight_h)
}

///|
/// Returns the arrow position for the current tutorial step.
pub fn tutorial_arrow_pos(game : @types.Game) -> (Int, Int, Bool) {
  let tut = game.tutorial
  (tut.arrow_x, tut.arrow_y, tut.show_arrow)
}

///|
/// Returns the tutorial step delay for playback timing.
pub fn get_tutorial_step_delay() -> Float {
  tutorial_step_delay
}
