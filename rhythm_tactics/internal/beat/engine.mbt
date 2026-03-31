///|
/// Advance the beat timer by `dt` seconds. Returns true when a new beat fires.
pub fn tick(beat : @types.BeatState, dt : Float) -> Bool {
  let bi = beat_interval_secs(beat)
  beat.beat_timer = beat.beat_timer + dt
  // Determine distance to nearest beat edge
  let phase = fmod(beat.beat_timer, bi)
  let time_since = phase
  let time_to = bi - phase
  let dist = @types.minf(time_since, time_to)
  beat.in_window = dist < beat.beat_window
  // Check if a new beat just occurred
  if beat.beat_timer >= bi {
    beat.beat_timer = beat.beat_timer - bi
    beat.beat_count = beat.beat_count + 1
    return true
  }
  false
}

///|
/// Rate the player's input timing against the nearest beat.
pub fn rate_input(beat : @types.BeatState) -> @types.BeatRating {
  let bi = beat_interval_secs(beat)
  let phase = fmod(beat.beat_timer, bi)
  let dist = @types.minf(phase, bi - phase)
  if dist <= beat.perfect_window {
    Perfect
  } else if dist <= beat.good_window {
    Good
  } else {
    Miss
  }
}

///|
/// Update the beat combo based on the rating of the latest input.
pub fn update_combo(
  beat : @types.BeatState,
  rating : @types.BeatRating,
) -> Unit {
  match rating {
    Perfect => {
      beat.combo = beat.combo + 2
      if beat.combo > @types.max_combo {
        beat.combo = @types.max_combo
      }
      if beat.combo > beat.max_combo {
        beat.max_combo = beat.combo
      }
    }
    Good => {
      beat.combo = beat.combo + 1
      if beat.combo > @types.max_combo {
        beat.combo = @types.max_combo
      }
      if beat.combo > beat.max_combo {
        beat.max_combo = beat.combo
      }
    }
    Miss => beat.combo = 0
  }
  beat.last_rating = rating
}

///|
/// Returns the progress [0..1] through the current beat interval.
/// 0 = beat just fired, 1 = next beat about to fire.
pub fn beat_phase(beat : @types.BeatState) -> Float {
  let bi = beat_interval_secs(beat)
  if bi <= 0.0F {
    return 0.0F
  }
  fmod(beat.beat_timer, bi) / bi
}

///|
/// Returns the current combo damage multiplier.
pub fn combo_multiplier(beat : @types.BeatState) -> Float {
  1.0F + Float::from_int(beat.combo) * @types.combo_damage_bonus
}

///|
/// Returns the beat interval in seconds.
pub fn beat_interval(beat : @types.BeatState) -> Float {
  beat_interval_secs(beat)
}

///|
/// Internal helper: compute beat interval from bpm.
fn beat_interval_secs(beat : @types.BeatState) -> Float {
  if beat.bpm <= 0.0F {
    return 1.0F
  }
  let sixty : Float = 60.0
  sixty / beat.bpm
}

///|
/// Check whether an enemy should act this beat based on its pattern.
pub fn enemy_acts_this_beat(enemy : @types.Enemy) -> Bool {
  if enemy.beat_pattern.length() == 0 {
    return true
  }
  let idx = enemy.pattern_idx % enemy.beat_pattern.length()
  enemy.beat_pattern[idx]
}

///|
/// Advance an enemy's beat pattern index.
pub fn advance_enemy_pattern(enemy : @types.Enemy) -> Unit {
  if enemy.beat_pattern.length() > 0 {
    enemy.pattern_idx = (enemy.pattern_idx + 1) % enemy.beat_pattern.length()
  }
}

///|
/// Compute damage accounting for combo bonus and beat rating.
pub fn compute_damage(
  base_damage : Int,
  beat : @types.BeatState,
  rating : @types.BeatRating,
) -> Int {
  let mult = combo_multiplier(beat)
  let rating_mult : Float = match rating {
    Perfect => 1.5
    Good => 1.0
    Miss => 0.5
  }
  let raw = Float::from_int(base_damage) * mult * rating_mult
  let result = raw.to_int()
  if result < 1 {
    1
  } else {
    result
  }
}

///|
/// Reset the beat state for a new floor / new game.
pub fn reset(beat : @types.BeatState) -> Unit {
  beat.beat_timer = 0.0
  beat.beat_count = 0
  beat.in_window = false
  beat.last_rating = Miss
  beat.combo = 0
}

///|
/// Returns the normalized distance to the nearest beat edge (0 = on beat, 1 = furthest).
pub fn beat_accuracy(beat : @types.BeatState) -> Float {
  let bi = beat_interval_secs(beat)
  let phase = fmod(beat.beat_timer, bi)
  let dist = @types.minf(phase, bi - phase)
  let half = bi / 2.0F
  if half > 0.0F {
    dist / half
  } else {
    1.0F
  }
}

///|
/// A pulse value [0..1] that peaks at each beat and decays. Useful for visuals.
pub fn beat_pulse(beat : @types.BeatState) -> Float {
  let p = beat_phase(beat)
  // Sharp attack, exponential decay
  let v = 1.0F - p
  v * v
}

///|
/// Float modulo that handles negative values correctly.
fn fmod(a : Float, b : Float) -> Float {
  if b == 0.0F {
    return 0.0F
  }
  let result = a - Float::from_int((a / b).to_int()) * b
  if result < 0.0F {
    result + b
  } else {
    result
  }
}
