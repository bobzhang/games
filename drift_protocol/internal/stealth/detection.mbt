///|
/// Update detection state for the player
pub fn update_detection(game : @types.Game) -> Unit {
  // Update player visibility state
  game.player.visible = !game.player.in_shadow
  // Player is partially visible in shadow but harder to detect
  // This is handled per-guard in the guard AI detection_speed_at function
}

///|
/// Check if the player is caught (any guard in alert and adjacent)
pub fn check_player_caught(game : @types.Game) -> Bool {
  for i in 0..<game.level.guards.length() {
    let g = game.level.guards[i]
    if g.active &&
      g.alert_state is Alert &&
      @types.manhattan_dist(g.gx, g.gy, game.player.gx, game.player.gy) <= 1 {
      return true
    }
  }
  false
}

///|
/// Get the maximum detection meter among all guards
pub fn max_detection_meter(game : @types.Game) -> Float {
  let mut max_det : Float = 0.0
  for i in 0..<game.level.guards.length() {
    let g = game.level.guards[i]
    if g.active && g.detection_meter > max_det {
      max_det = g.detection_meter
    }
  }
  max_det
}

///|
/// Count guards in each alert state
pub fn count_alert_guards(game : @types.Game) -> (Int, Int, Int) {
  let mut patrolling = 0
  let mut suspicious = 0
  let mut alert = 0
  for i in 0..<game.level.guards.length() {
    let g = game.level.guards[i]
    if g.active {
      match g.alert_state {
        Patrolling => patrolling += 1
        Suspicious => suspicious += 1
        Alert => alert += 1
      }
    }
  }
  (patrolling, suspicious, alert)
}
