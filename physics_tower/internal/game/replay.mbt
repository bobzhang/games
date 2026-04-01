///|
/// Time between replayed actions in seconds.
let replay_action_interval : Float = 0.5

///|
/// Starts recording build actions for replay.
pub fn start_recording(game : @types.Game) -> Unit {
  let replay = game.replay
  replay.actions.clear()
  replay.test_height = 0.0
  replay.test_score = 0
  replay.test_passed = false
  replay.playback_index = 0
  replay.playback_timer = 0.0
  replay.is_recording = true
  replay.is_playing = false
}

///|
/// Stops recording and stores the test result.
pub fn stop_recording(
  game : @types.Game,
  height : Float,
  score : Int,
  passed : Bool,
) -> Unit {
  let replay = game.replay
  replay.is_recording = false
  replay.test_height = height
  replay.test_score = score
  replay.test_passed = passed
}

///|
/// Records a piece placement action.
pub fn record_place(
  game : @types.Game,
  kind : @types.PieceKind,
  material : @types.Material,
  x : Float,
  y : Float,
  angle : Float,
) -> Unit {
  if !game.replay.is_recording {
    return
  }
  game.replay.actions.push(Place(kind, material, x, y, angle))
}

///|
/// Records a piece rotation action.
pub fn record_rotate(game : @types.Game, body_id : Int) -> Unit {
  if !game.replay.is_recording {
    return
  }
  game.replay.actions.push(Rotate(body_id))
}

///|
/// Records a blueprint placement action.
pub fn record_blueprint(
  game : @types.Game,
  bp_kind : @types.BlueprintKind,
  x : Float,
  y : Float,
) -> Unit {
  if !game.replay.is_recording {
    return
  }
  game.replay.actions.push(BlueprintPlace(bp_kind, x, y))
}

///|
/// Starts playback of the recorded replay.
pub fn start_playback(game : @types.Game) -> Unit {
  let replay = game.replay
  if replay.actions.length() == 0 {
    return
  }
  replay.is_playing = true
  replay.is_recording = false
  replay.playback_index = 0
  replay.playback_timer = 0.0
  game.screen = ReplayPlayback
}

///|
/// Updates the replay playback, advancing through actions.
/// Returns true when playback is complete.
pub fn update_playback(game : @types.Game, dt : Float) -> Bool {
  let replay = game.replay
  if !replay.is_playing {
    return true
  }
  replay.playback_timer = replay.playback_timer + dt * replay.playback_speed
  let interval = replay_action_interval
  // Calculate how many actions we should have played by now
  let target_idx = (replay.playback_timer / interval).to_int()
  // Process any new actions
  while replay.playback_index < target_idx &&
        replay.playback_index < replay.actions.length() {
    let action = replay.actions[replay.playback_index]
    execute_replay_action(game, action)
    replay.playback_index = replay.playback_index + 1
  }
  // Check if complete
  if replay.playback_index >= replay.actions.length() {
    replay.is_playing = false
    return true
  }
  false
}

///|
/// Executes a single replay action by placing the piece in the world.
fn execute_replay_action(
  game : @types.Game,
  action : @types.ReplayAction,
) -> Unit {
  match action {
    Place(kind, material, x, y, angle) => {
      let id = @physics.add_body(game.world, kind, material, x, y, angle)
      @physics.auto_join(game.world, id)
      // Brief settle
      for _i in 0..<5 {
        @physics.step(game.world, 0.016)
      }
    }
    Rotate(_body_id) =>
      // During replay, rotation is cosmetic - the placed angle already includes it
      ()
    BlueprintPlace(_bp_kind, _x, _y) =>
      // Blueprint placement is decomposed into individual Place actions during recording
      // This action is recorded for metadata purposes
      ()
  }
}

///|
/// Stops playback and returns to the previous screen.
pub fn stop_playback(game : @types.Game) -> Unit {
  game.replay.is_playing = false
  game.replay.playback_index = 0
  game.replay.playback_timer = 0.0
}

///|
/// Saves the current build as a ghost tower overlay for future attempts.
pub fn save_ghost_tower(game : @types.Game) -> Unit {
  let replay = game.replay
  replay.ghost_pieces.clear()
  for body in game.world.bodies {
    if body.active && !body.broken {
      replay.ghost_pieces.push(
        (body.kind, body.material, body.x, body.y, body.angle),
      )
    }
  }
  replay.ghost_visible = true
}

///|
/// Clears the ghost tower overlay.
pub fn clear_ghost_tower(game : @types.Game) -> Unit {
  game.replay.ghost_pieces.clear()
  game.replay.ghost_visible = false
}

///|
/// Toggles ghost tower visibility.
pub fn toggle_ghost(game : @types.Game) -> Unit {
  if game.replay.ghost_pieces.length() > 0 {
    game.replay.ghost_visible = !game.replay.ghost_visible
  }
}

///|
/// Returns the current playback progress as a percentage.
pub fn playback_progress(game : @types.Game) -> Int {
  let replay = game.replay
  if replay.actions.length() == 0 {
    return 100
  }
  replay.playback_index * 100 / replay.actions.length()
}

///|
/// Returns whether the replay has content to play.
pub fn has_replay(game : @types.Game) -> Bool {
  game.replay.actions.length() > 0
}

///|
/// Returns whether ghost tower is visible and has content.
pub fn ghost_visible(game : @types.Game) -> Bool {
  game.replay.ghost_visible && game.replay.ghost_pieces.length() > 0
}

///|
/// Returns the ghost pieces for rendering.
pub fn ghost_pieces(
  game : @types.Game,
) -> Array[(@types.PieceKind, @types.Material, Float, Float, Float)] {
  game.replay.ghost_pieces
}

///|
/// Returns the replay action count.
pub fn replay_action_count(game : @types.Game) -> Int {
  game.replay.actions.length()
}

///|
/// Adjusts playback speed (1.0 = normal, 2.0 = fast, 0.5 = slow).
pub fn set_playback_speed(game : @types.Game, speed : Float) -> Unit {
  game.replay.playback_speed = @types.clampf(speed, 0.25, 4.0)
}

///|
/// Returns the result summary of the replayed build.
pub fn replay_result_summary(game : @types.Game) -> String {
  let replay = game.replay
  let ht = (replay.test_height + 0.5).to_int()
  let result = if replay.test_passed { "PASSED" } else { "FAILED" }
  "Height: " +
  ht.to_string() +
  "px  Score: " +
  replay.test_score.to_string() +
  "  " +
  result
}

///|
/// Updates the replay playback screen.
pub fn update_replay_screen(game : @types.Game, dt : Float) -> Unit {
  let done = update_playback(game, dt)
  if done || @raylib.is_key_pressed(@raylib.KeyEscape) {
    stop_playback(game)
    game.screen = Results
  }
  // Speed controls
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    set_playback_speed(game, game.replay.playback_speed * 2.0)
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    set_playback_speed(game, game.replay.playback_speed * 0.5)
  }
}
