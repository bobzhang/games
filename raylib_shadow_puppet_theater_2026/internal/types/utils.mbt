///|
/// Clamps an integer into the inclusive range [`lo`, `hi`].
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  v.clamp(min=lo, max=hi)
}

///|
/// Clamps a float into the inclusive range [`lo`, `hi`].
pub fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
/// Returns the smaller of two floating-point values.
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
/// Returns the larger of two floating-point values.
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
/// Returns sine of `v` where `v` is in radians.
pub fn sinf(v : Float) -> Float {
  @math.sinf(v)
}

///|
/// Returns true when two poses match on both axes.
pub fn same_pose(a : Pose, b : Pose) -> Bool {
  a.ax == b.ax && a.ay == b.ay
}

///|
/// Sets the current message banner text and duration.
pub fn set_message(game : Game, text : String, ttl : Float) -> Unit {
  game.message = text
  game.message_t = ttl
}

///|
/// Adds score delta while keeping score non-negative and updating best score.
pub fn add_score(game : Game, delta : Int) -> Unit {
  game.score = (0).max(game.score + delta)
  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
/// Resets the current live pose to the neutral center position.
pub fn reset_current_pose(game : Game) -> Unit {
  game.current_pose.ax = 0
  game.current_pose.ay = 0
}

///|
/// Returns the current target pose or neutral pose when sequence is exhausted.
pub fn target_pose(game : Game) -> Pose {
  if game.target_idx < game.sequence.length() {
    game.sequence[game.target_idx]
  } else {
    Pose::new(0, 0)
  }
}

///|
/// Returns active time-scale multiplier based on burst state.
pub fn active_slow_factor(game : Game) -> Float {
  if game.burst_t > 0.0 {
    burst_slow_factor
  } else {
    1.0
  }
}
