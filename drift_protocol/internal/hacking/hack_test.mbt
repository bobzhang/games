///|
test "hack_input correct sequence marks success" {
  let game = @types.new_game()
  let t = @types.new_terminal(3, 3, true, 1)
  game.level.terminals = [t]
  // Manually set up hack minigame
  let hg = game.hack_game
  hg.active = true
  hg.target_terminal = 0
  hg.timer = 3.0
  hg.max_time = 3.0
  hg.current_pos = 0
  hg.success = false
  hg.failed = false
  hg.sequence = [0, 1, 0, 1]
  hg.input = []
  game.screen = Hacking
  // Feed the correct sequence
  @hacking.hack_input(game, 0)
  @hacking.hack_input(game, 1)
  @hacking.hack_input(game, 0)
  @hacking.hack_input(game, 1)
  inspect(hg.success, content="true")
  inspect(hg.current_pos, content="4")
}

///|
test "hack_input wrong sequence resets input" {
  let game = @types.new_game()
  let t = @types.new_terminal(3, 3, true, 1)
  game.level.terminals = [t]
  @types.seed_rng(100)
  let hg = game.hack_game
  hg.active = true
  hg.target_terminal = 0
  hg.timer = 3.0
  hg.max_time = 3.0
  hg.current_pos = 0
  hg.success = false
  hg.failed = false
  hg.sequence = [0, 1, 0, 1]
  hg.input = []
  game.screen = Hacking
  // Feed wrong sequence
  @hacking.hack_input(game, 1) // wrong
  @hacking.hack_input(game, 1)
  @hacking.hack_input(game, 0)
  @hacking.hack_input(game, 1)
  // Should reset - not successful
  inspect(hg.success, content="false")
  inspect(hg.current_pos, content="0")
  inspect(game.message, content="Wrong sequence!")
}

///|
test "hack_input ignores input when inactive" {
  let game = @types.new_game()
  let hg = game.hack_game
  hg.active = false
  hg.sequence = [0, 1, 0, 1]
  hg.input = []
  hg.current_pos = 0
  @hacking.hack_input(game, 0)
  inspect(hg.current_pos, content="0")
  inspect(hg.input.length(), content="0")
}

///|
test "hack_input ignores input when already succeeded" {
  let game = @types.new_game()
  let hg = game.hack_game
  hg.active = true
  hg.success = true
  hg.sequence = [0, 1, 0, 1]
  hg.input = []
  hg.current_pos = 0
  @hacking.hack_input(game, 0)
  inspect(hg.current_pos, content="0")
}

///|
test "hack_input ignores input when already failed" {
  let game = @types.new_game()
  let hg = game.hack_game
  hg.active = true
  hg.failed = true
  hg.sequence = [0, 1, 0, 1]
  hg.input = []
  hg.current_pos = 0
  @hacking.hack_input(game, 0)
  inspect(hg.current_pos, content="0")
}

///|
test "update_hack_minigame times out correctly" {
  let game = @types.new_game()
  let t = @types.new_terminal(3, 3, true, 1)
  game.level.terminals = [t]
  let hg = game.hack_game
  hg.active = true
  hg.target_terminal = 0
  hg.timer = 0.1
  hg.max_time = 3.0
  hg.current_pos = 0
  hg.success = false
  hg.failed = false
  hg.sequence = [0, 1, 0, 1]
  hg.input = []
  game.screen = Hacking
  // Advance past timer
  @hacking.update_hack_minigame(game, 0.2)
  inspect(hg.failed, content="true")
  inspect(hg.active, content="false")
  inspect(game.screen, content="Playing")
  inspect(game.message, content="Hack failed!")
}

///|
test "update_hack_minigame completes on success" {
  let game = @types.new_game()
  let t = @types.new_terminal(3, 3, true, 1)
  game.level.terminals = [t]
  let hg = game.hack_game
  hg.active = true
  hg.target_terminal = 0
  hg.timer = 2.0
  hg.max_time = 3.0
  hg.success = true
  hg.failed = false
  game.screen = Hacking
  @hacking.update_hack_minigame(game, 0.016)
  inspect(hg.active, content="false")
  inspect(t.hacked, content="true")
  inspect(game.screen, content="Playing")
}
