///|
test "rate_input returns Perfect when near beat edge" {
  let beat = @types.BeatState::new(120.0)
  beat.beat_timer = 0.01 // Very close to beat
  beat.perfect_window = 0.08
  beat.good_window = 0.15
  let rating = rate_input(beat)
  inspect!(rating, content="Perfect")
}

///|
test "rate_input returns Good when in good window" {
  let beat = @types.BeatState::new(120.0)
  beat.beat_timer = 0.12 // Between perfect and good window
  beat.perfect_window = 0.08
  beat.good_window = 0.15
  let rating = rate_input(beat)
  inspect!(rating, content="Good")
}

///|
test "rate_input returns Miss when far from beat" {
  let beat = @types.BeatState::new(120.0)
  beat.beat_timer = 0.25 // Far from beat edge (half of 0.5s interval)
  beat.perfect_window = 0.08
  beat.good_window = 0.15
  let rating = rate_input(beat)
  inspect!(rating, content="Miss")
}

///|
test "update_combo increases on Perfect" {
  let beat = @types.BeatState::new(120.0)
  beat.combo = 0
  update_combo(beat, Perfect)
  inspect!(beat.combo, content="2")
  update_combo(beat, Perfect)
  inspect!(beat.combo, content="4")
}

///|
test "update_combo increases by 1 on Good" {
  let beat = @types.BeatState::new(120.0)
  beat.combo = 5
  update_combo(beat, Good)
  inspect!(beat.combo, content="6")
}

///|
test "update_combo resets on Miss" {
  let beat = @types.BeatState::new(120.0)
  beat.combo = 15
  update_combo(beat, Miss)
  inspect!(beat.combo, content="0")
}

///|
test "update_combo tracks max_combo" {
  let beat = @types.BeatState::new(120.0)
  update_combo(beat, Perfect)
  update_combo(beat, Perfect)
  update_combo(beat, Perfect)
  inspect!(beat.max_combo, content="6")
  update_combo(beat, Miss)
  inspect!(beat.max_combo, content="6")
  inspect!(beat.combo, content="0")
}

///|
test "update_combo caps at max_combo" {
  let beat = @types.BeatState::new(120.0)
  beat.combo = 98
  update_combo(beat, Perfect)
  inspect!(beat.combo, content="99")
}

///|
test "enemy_acts_this_beat with alternating pattern" {
  let enemy = @types.Enemy::new(
    0, Slime, 3, 3, hp=2, damage=1, beat_pattern=[true, false, true, false],
  )
  enemy.pattern_idx = 0
  inspect!(enemy_acts_this_beat(enemy), content="true")
  advance_enemy_pattern(enemy)
  inspect!(enemy_acts_this_beat(enemy), content="false")
  advance_enemy_pattern(enemy)
  inspect!(enemy_acts_this_beat(enemy), content="true")
  advance_enemy_pattern(enemy)
  inspect!(enemy_acts_this_beat(enemy), content="false")
}

///|
test "enemy_acts_this_beat with empty pattern always acts" {
  let enemy = @types.Enemy::new(
    0, Bat, 1, 1, hp=1, damage=1, beat_pattern=[],
  )
  inspect!(enemy_acts_this_beat(enemy), content="true")
}

///|
test "compute_damage with zero combo" {
  let beat = @types.BeatState::new(120.0)
  beat.combo = 0
  let dmg = compute_damage(2, beat, Perfect)
  // base=2, combo_mult=1.0, rating_mult=1.5 => 3
  inspect!(dmg, content="3")
}

///|
test "compute_damage with combo multiplier" {
  let beat = @types.BeatState::new(120.0)
  beat.combo = 10
  // combo_mult = 1.0 + 10*0.1 = 2.0
  let dmg = compute_damage(2, beat, Perfect)
  // base=2, combo_mult=2.0, rating_mult=1.5 => 6
  inspect!(dmg, content="6")
}

///|
test "compute_damage Miss gives minimum 1" {
  let beat = @types.BeatState::new(120.0)
  beat.combo = 0
  let dmg = compute_damage(1, beat, Miss)
  // base=1, combo_mult=1.0, rating_mult=0.5 => 0 -> clamped to 1
  inspect!(dmg, content="1")
}

///|
test "beat_phase progresses correctly" {
  let beat = @types.BeatState::new(120.0)
  // At 120 BPM, interval = 0.5s
  beat.beat_timer = 0.0
  let p0 = beat_phase(beat)
  inspect!(p0, content="0")
  beat.beat_timer = 0.25
  let p50 = beat_phase(beat)
  inspect!(p50, content="0.5")
}

///|
test "tick fires beat at interval boundary" {
  let beat = @types.BeatState::new(120.0)
  // 120 BPM = 0.5s interval
  let fired1 = tick(beat, 0.3)
  inspect!(fired1, content="false")
  let fired2 = tick(beat, 0.3)
  // 0.3+0.3 = 0.6 >= 0.5, should fire
  inspect!(fired2, content="true")
  inspect!(beat.beat_count, content="1")
}

///|
test "reset clears beat state" {
  let beat = @types.BeatState::new(120.0)
  beat.combo = 15
  beat.beat_count = 42
  beat.beat_timer = 0.35
  reset(beat)
  inspect!(beat.combo, content="0")
  inspect!(beat.beat_count, content="0")
  inspect!(beat.beat_timer, content="0")
}
