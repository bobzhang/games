///|
fn @types.Game::generate_sequence(game : @types.Game) -> Unit {
  game.sequence.clear()

  let len = @types.sequence_len_for_stage(game.stage)
  let mut prev_ax = 99
  let mut prev_ay = 99

  for i in 0..<len {
    let mut ax = @raylib.get_random_value(
      @types.pose_axis_min, @types.pose_axis_max,
    )
    let ay = @raylib.get_random_value(
      @types.pose_axis_min, @types.pose_axis_max,
    )

    if i > 0 && ax == prev_ax && ay == prev_ay {
      if ax < @types.pose_axis_max {
        ax = ax + 1
      } else {
        ax = ax - 1
      }
    }

    game.sequence.push(@types.Pose::new(ax, ay))
    prev_ax = ax
    prev_ay = ay
  }

  game.history.clear()
  game.target_idx = 0
  game.cue_time_limit = @types.cue_time_for_stage(game.stage)
  game.cue_time_left = game.cue_time_limit
}

///|
fn @types.Game::init_title_scene(game : @types.Game) -> Unit {
  game.state = Title
  game.stage = 1
  game.score = 0
  game.combo = 0
  game.excitement = 0.0
  game.spotlight = @types.spotlight_start
  game.cue_time_left = 0.0
  game.cue_time_limit = @types.cue_base_time
  game.target_idx = 0
  game.sequence.clear()
  game.history.clear()
  @types.reset_current_pose(game)
  game.burst_t = 0.0
  game.burst_cd = 0.0
  game.combo_t = 0.0
  game.beat_t = 0.0
  game.scene_t = 0.0
  game.result_t = 0.0
  game.hit_count = 0
  game.miss_count = 0
  @types.set_message(
    game, "Press ENTER, J, or SPACE to open the curtain.", 99.0,
  )
}

///|
fn @types.Game::start_show(game : @types.Game) -> Unit {
  game.state = Play
  game.stage = 1
  game.score = 0
  game.combo = 0
  game.excitement = 28.0
  game.spotlight = @types.spotlight_start
  game.burst_t = 0.0
  game.burst_cd = 0.0
  game.combo_t = 0.0
  game.result_t = 0.0
  game.hit_count = 0
  game.miss_count = 0
  @types.reset_current_pose(game)
  game.generate_sequence()
  @types.set_message(
    game, "Match each target silhouette before the cue clock runs out.", 3.5,
  )
}

///|
fn @types.Game::apply_pose_axis_input(game : @types.Game) -> Unit {
  if game.input.axis_dx != 0 {
    game.current_pose.ax = (game.current_pose.ax + game.input.axis_dx).clamp(
      min=@types.pose_axis_min,
      max=@types.pose_axis_max,
    )
  }
  if game.input.axis_dy != 0 {
    game.current_pose.ay = (game.current_pose.ay + game.input.axis_dy).clamp(
      min=@types.pose_axis_min,
      max=@types.pose_axis_max,
    )
  }
}

///|
fn @types.Game::try_activate_burst(game : @types.Game) -> Unit {
  if !game.input.burst_pressed {
    return
  }

  if game.burst_cd <= 0.0 {
    game.burst_t = @types.burst_duration
    game.burst_cd = @types.burst_cooldown
    game.excitement = @types.minf(@types.excitement_max, game.excitement + 8.0)
    @types.set_message(game, "Spotlight burst! Time slows for a moment.", 0.9)
  } else {
    @types.set_message(
      game,
      "Burst cooling down: " + game.burst_cd.to_int().to_string() + "s",
      0.45,
    )
  }
}

///|
fn @types.Game::apply_mistake(game : @types.Game, timeout : Bool) -> Unit {
  game.miss_count = game.miss_count + 1
  game.combo = 0
  game.combo_t = 0.0

  let spot_loss = if timeout {
    @types.timeout_spotlight_loss
  } else {
    @types.mistake_spotlight_loss
  }
  let excite_loss = if timeout {
    @types.mistake_excitement_loss + 5.0
  } else {
    @types.mistake_excitement_loss
  }

  game.spotlight = @types.maxf(0.0, game.spotlight - spot_loss)
  game.excitement = @types.maxf(0.0, game.excitement - excite_loss)

  if timeout {
    game.generate_sequence()
    @types.set_message(game, "Cue missed! New sequence enters.", 1.2)
  } else {
    game.cue_time_left = @types.maxf(
      game.cue_time_limit * 0.42,
      game.cue_time_left * 0.72,
    )
    @types.set_message(game, "Silhouette mismatch.", 0.75)
  }
}

///|
fn @types.Game::complete_sequence(game : @types.Game) -> Unit {
  let bonus = 160 + game.stage * 30 + game.combo * 8
  @types.add_score(game, bonus)

  game.stage = game.stage + 1
  game.excitement = @types.minf(@types.excitement_max, game.excitement + 14.0)
  game.spotlight = @types.minf(@types.spotlight_max, game.spotlight + 12.0)

  game.generate_sequence()
  @types.set_message(
    game,
    "Act cleared! Scene " + game.stage.to_string() + " begins.",
    1.5,
  )
}

///|
fn @types.Game::lock_current_pose(game : @types.Game) -> Unit {
  if game.sequence.length() <= 0 || game.target_idx >= game.sequence.length() {
    return
  }

  let target = game.sequence[game.target_idx]

  if @types.same_pose(game.current_pose, target) {
    game.history.push(
      @types.Pose::new(game.current_pose.ax, game.current_pose.ay),
    )
    game.target_idx = game.target_idx + 1
    game.hit_count = game.hit_count + 1

    game.combo = (game.combo + 1).clamp(min=0, max=99)
    game.combo_t = @types.combo_hold_time
    if game.combo > game.best_combo {
      game.best_combo = game.combo
    }

    let score_gain = 48 + game.stage * 10 + game.combo * 5
    @types.add_score(game, score_gain)

    game.excitement = @types.minf(
      @types.excitement_max,
      game.excitement +
      @types.correct_excitement_gain +
      Float::from_int(game.combo) * 0.7,
    )
    game.spotlight = @types.minf(
      @types.spotlight_max,
      game.spotlight +
      @types.correct_spotlight_gain +
      Float::from_int(game.combo) * 0.2,
    )
    game.cue_time_left = game.cue_time_limit

    if game.target_idx >= game.sequence.length() {
      game.complete_sequence()
    } else {
      @types.set_message(game, "Great lock!", 0.55)
    }
  } else {
    game.apply_mistake(false)
  }
}

///|
fn @types.Game::undo_last_pose(game : @types.Game) -> Unit {
  if game.history.length() <= 0 || game.target_idx <= 0 {
    @types.set_message(game, "No locked pose to undo.", 0.7)
    return
  }

  let last_idx = game.history.length() - 1
  let pose = game.history[last_idx]
  ignore(game.history.remove(last_idx))

  game.target_idx = game.target_idx - 1
  game.current_pose.ax = pose.ax
  game.current_pose.ay = pose.ay
  game.combo = 0
  game.combo_t = 0.0
  game.spotlight = @types.maxf(0.0, game.spotlight - 5.5)
  game.excitement = @types.maxf(0.0, game.excitement - 3.0)
  game.cue_time_left = @types.maxf(
    game.cue_time_left,
    game.cue_time_limit * 0.65,
  )
  @types.set_message(game, "Last locked pose undone.", 0.85)
}

///|
fn @types.Game::update_title_state(game : @types.Game) -> Unit {
  game.excitement = 18.0 + (0.5 + 0.5 * @math.sinf(game.scene_t * 0.8)) * 14.0
  game.spotlight = @types.spotlight_start + @math.sinf(game.scene_t * 0.6) * 8.0

  if game.input.start_pressed {
    game.start_show()
  }
}

///|
fn @types.Game::update_play_state(game : @types.Game, dt : Float) -> Unit {
  if game.input.pause_pressed {
    game.state = Paused
    @types.set_message(game, "Show paused. Press P to resume.", 99.0)
    return
  }

  game.apply_pose_axis_input()

  if game.input.undo_pressed {
    game.undo_last_pose()
  }

  game.try_activate_burst()

  if game.input.lock_pressed {
    game.lock_current_pose()
  }

  let sim_dt = dt * @types.active_slow_factor(game)

  game.cue_time_left = game.cue_time_left - sim_dt
  game.combo_t = @types.maxf(0.0, game.combo_t - sim_dt)
  if game.combo > 0 && game.combo_t <= 0.0 {
    game.combo = game.combo - 1
    if game.combo > 0 {
      game.combo_t = @types.combo_hold_time * 0.7
    }
  }

  game.excitement = @types.maxf(
    0.0,
    game.excitement - sim_dt * @types.excitement_drain,
  )
  let pressure = @types.spotlight_drain + Float::from_int(game.combo) * 0.22
  game.spotlight = @types.maxf(0.0, game.spotlight - sim_dt * pressure)

  if game.cue_time_left <= 0.0 {
    game.apply_mistake(true)
  }

  if game.spotlight <= 0.0 {
    game.state = Result
    game.result_t = 0.0
    @types.set_message(game, "Spotlight faded. Press R to restart.", 99.0)
  }
}

///|
fn @types.Game::update_paused_state(game : @types.Game) -> Unit {
  if game.input.pause_pressed {
    game.state = Play
    @types.set_message(game, "Show resumed.", 0.8)
  }
}

///|
fn @types.Game::update_result_state(game : @types.Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt

  if game.input.start_pressed {
    game.start_show()
  }
}

///|
/// Initializes the game into a fresh title-scene state.
pub fn init_game(game : @types.Game) -> Unit {
  game.init_title_scene()
}

///|
/// Advances one frame of input sampling and state-specific gameplay updates.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.sample_input()

  game.scene_t = game.scene_t + dt
  game.beat_t = game.beat_t + dt
  game.message_t = @types.maxf(0.0, game.message_t - dt)
  game.burst_t = @types.maxf(0.0, game.burst_t - dt)
  game.burst_cd = @types.maxf(0.0, game.burst_cd - dt)

  if game.input.restart_pressed {
    game.start_show()
    return
  }

  match game.state {
    Title => game.update_title_state()
    Play => game.update_play_state(dt)
    Paused => game.update_paused_state()
    Result => game.update_result_state(dt)
  }
}
