///|
/// Pushes a sound event onto the queue.
pub fn push_sound(game : @types.Game, event : @types.SoundEvent) -> Unit {
  game.sound_queue.push(event)
}

///|
/// Clears the sound queue (call at end of frame after audio reads it).
pub fn clear_sound_queue(game : @types.Game) -> Unit {
  game.sound_queue.clear()
}

///|
/// Returns the current sound queue for reading by the audio/render system.
pub fn get_sound_queue(game : @types.Game) -> Array[@types.SoundEvent] {
  game.sound_queue
}

///|
/// Returns true if the queue contains a specific event type.
pub fn has_sound_event(game : @types.Game, target : @types.SoundEvent) -> Bool {
  for event in game.sound_queue {
    if event == target {
      return true
    }
  }
  false
}

///|
/// Returns the count of events of a specific type in the queue.
pub fn count_sound_events(
  game : @types.Game,
  target : @types.SoundEvent,
) -> Int {
  let mut count = 0
  for event in game.sound_queue {
    if event == target {
      count = count + 1
    }
  }
  count
}

///|
/// Returns a display name for a sound event (for debug).
pub fn sound_event_name(event : @types.SoundEvent) -> String {
  match event {
    PlacePiece => "place_piece"
    RotatePiece => "rotate_piece"
    StartTest => "start_test"
    BodyBreak => "body_break"
    JointBreak => "joint_break"
    TestPass => "test_pass"
    TestFail => "test_fail"
    LevelComplete => "level_complete"
    WindStart => "wind_start"
    EarthquakeStart => "earthquake_start"
    ImpactHit => "impact_hit"
    ButtonClick => "button_click"
    StarEarned => "star_earned"
  }
}

///|
/// Returns the priority of a sound event (higher = more important).
/// Used to prevent too many sounds playing simultaneously.
pub fn sound_event_priority(event : @types.SoundEvent) -> Int {
  match event {
    LevelComplete => 10
    StarEarned => 9
    TestPass => 8
    TestFail => 8
    BodyBreak => 7
    JointBreak => 6
    ImpactHit => 6
    EarthquakeStart => 5
    WindStart => 5
    StartTest => 4
    PlacePiece => 3
    RotatePiece => 2
    ButtonClick => 1
  }
}

///|
/// Filters the sound queue to only the highest priority events
/// when too many events are queued in a single frame.
pub fn filter_sound_queue(
  game : @types.Game,
  max_events : Int,
) -> Array[@types.SoundEvent] {
  let queue = game.sound_queue
  if queue.length() <= max_events {
    return queue
  }
  // Sort by priority (bubble sort is fine for small arrays)
  let sorted : Array[@types.SoundEvent] = Array::new(capacity=queue.length())
  for event in queue {
    sorted.push(event)
  }
  for i in 0..<sorted.length() {
    for j = i + 1; j < sorted.length(); j = j + 1 {
      if sound_event_priority(sorted[i]) < sound_event_priority(sorted[j]) {
        let tmp = sorted[i]
        sorted[i] = sorted[j]
        sorted[j] = tmp
      }
    }
  }
  // Take top N
  let result : Array[@types.SoundEvent] = Array::new(capacity=max_events)
  for i in 0..<max_events {
    if i < sorted.length() {
      result.push(sorted[i])
    }
  }
  result
}

///|
/// Pushes sounds for break events detected during physics.
pub fn emit_break_sounds(game : @types.Game) -> Unit {
  // Check for newly broken bodies
  for body in game.world.bodies {
    if body.broken && body.active {
      let speed = @types.absf(body.vx) + @types.absf(body.vy)
      if speed > 50.0 {
        push_sound(game, BodyBreak)
      }
    }
  }
  // Check for newly broken joints
  for joint in game.world.joints {
    if joint.broken && !joint.active {
      push_sound(game, JointBreak)
    }
  }
}

///|
/// Pushes sounds for hazard events.
pub fn emit_hazard_sounds(game : @types.Game) -> Unit {
  let world = game.world
  if @types.absf(world.wind_force) > 0.1 {
    if !has_sound_event(game, WindStart) {
      push_sound(game, WindStart)
    }
  }
  if world.quake_timer > 0.0 {
    if !has_sound_event(game, EarthquakeStart) {
      push_sound(game, EarthquakeStart)
    }
  }
}
