///|
/// Try to interact with a terminal adjacent to the player
pub fn try_hack_terminal(game : @types.Game) -> Unit {
  let px = game.player.gx
  let py = game.player.gy
  // Check all terminals for adjacency
  for i in 0..<game.level.terminals.length() {
    let t = game.level.terminals[i]
    if t.hacked {
      continue
    }
    if @types.is_adjacent(px, py, t.gx, t.gy) {
      if t.high_security {
        // Start hack minigame
        start_hack_minigame(game, i)
        return
      } else {
        // Instant hack
        complete_hack(game, i)
        return
      }
    }
  }
  // Check power nodes for adjacency
  for i in 0..<game.level.power_nodes.length() {
    let pn = game.level.power_nodes[i]
    if @types.is_adjacent(px, py, pn.gx, pn.gy) {
      toggle_power_node(game, i)
      return
    }
  }
}

///|
/// Complete a hack on a terminal
pub fn complete_hack(game : @types.Game, terminal_index : Int) -> Unit {
  let t = game.level.terminals[terminal_index]
  t.hacked = true
  game.player.hacked_terminals += 1
  @types.push_sound(game, Hack)
  @types.set_message(game, "Terminal hacked!", 1.5)
}

///|
/// Start the hack minigame for high-security terminals
fn start_hack_minigame(game : @types.Game, terminal_index : Int) -> Unit {
  let hg = game.hack_game
  hg.active = true
  hg.target_terminal = terminal_index
  hg.timer = @types.hack_time_limit
  hg.max_time = @types.hack_time_limit
  hg.current_pos = 0
  hg.success = false
  hg.failed = false
  // Generate random binary sequence
  hg.sequence = Array(capacity=@types.hack_sequence_length)
  hg.input = Array(capacity=@types.hack_sequence_length)
  for _i in 0..<@types.hack_sequence_length {
    hg.sequence.push(@types.rng_int(2))
  }
  game.screen = Hacking
}

///|
/// Update the hack minigame
pub fn update_hack_minigame(game : @types.Game, dt : Float) -> Unit {
  let hg = game.hack_game
  if !hg.active {
    return
  }
  hg.timer -= dt
  if hg.timer <= 0.0 {
    // Time's up - failed
    hg.failed = true
    hg.active = false
    game.screen = Playing
    @types.set_message(game, "Hack failed!", 1.5)
    return
  }
  if hg.success {
    hg.active = false
    if hg.target_terminal >= 0 {
      complete_hack(game, hg.target_terminal)
    }
    game.screen = Playing
    return
  }
}

///|
/// Process input for hack minigame (0 or 1)
pub fn hack_input(game : @types.Game, value : Int) -> Unit {
  let hg = game.hack_game
  if !hg.active || hg.success || hg.failed {
    return
  }
  hg.input.push(value)
  hg.current_pos += 1
  // Check if sequence complete
  if hg.current_pos >= @types.hack_sequence_length {
    // Verify match
    let mut correct = true
    for i in 0..<@types.hack_sequence_length {
      if hg.input[i] != hg.sequence[i] {
        correct = false
        break
      }
    }
    if correct {
      hg.success = true
    } else {
      // Reset for another try
      hg.input = []
      hg.current_pos = 0
      // Generate new sequence
      hg.sequence = Array(capacity=@types.hack_sequence_length)
      for _i in 0..<@types.hack_sequence_length {
        hg.sequence.push(@types.rng_int(2))
      }
      @types.set_message(game, "Wrong sequence!", 0.5)
    }
  }
}
