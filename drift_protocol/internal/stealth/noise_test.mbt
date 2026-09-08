///|
test "movement noise sets correct radius for walking" {
  let game = @types.new_game()
  game.player.running = false
  game.player.gx = 5
  game.player.gy = 5
  @stealth.generate_movement_noise(game)
  inspect(game.noise_radius, content="1")
  inspect(game.noise_x, content="5")
  inspect(game.noise_y, content="5")
  inspect(game.noise_timer > 0.0, content="true")
}

///|
test "movement noise sets correct radius for running" {
  let game = @types.new_game()
  game.player.running = true
  game.player.gx = 5
  game.player.gy = 5
  @stealth.generate_movement_noise(game)
  inspect(game.noise_radius, content="3")
}

///|
test "coin noise depletes coin and sets target" {
  let game = @types.new_game()
  game.player.coins = 2
  @stealth.generate_coin_noise(game, 10, 8)
  inspect(game.player.coins, content="1")
  inspect(game.coin_active, content="true")
  inspect(game.coin_target_x, content="10")
  inspect(game.coin_target_y, content="8")
  inspect(game.noise_radius, content="4")
}

///|
test "coin noise does nothing with zero coins" {
  let game = @types.new_game()
  game.player.coins = 0
  @stealth.generate_coin_noise(game, 10, 8)
  inspect(game.coin_active, content="false")
}

///|
test "noise decays over time" {
  let game = @types.new_game()
  game.noise_timer = 0.3
  game.noise_radius = 3
  @stealth.update_noise(game, 0.2)
  inspect(game.noise_radius, content="3") // Still active
  @stealth.update_noise(game, 0.2)
  inspect(game.noise_radius, content="0") // Decayed
}

///|
test "shadow state detection" {
  let game = @types.new_game()
  // Set up tiles with shadow
  let tiles : Array[Array[@types.TileKind]] = Array::new(capacity=@types.grid_height)
  for _y in 0..<@types.grid_height {
    let row : Array[@types.TileKind] = Array::new(capacity=@types.grid_width)
    for _x in 0..<@types.grid_width {
      row.push(Floor)
    }
    tiles.push(row)
  }
  tiles[5][5] = Shadow
  game.level.tiles = tiles
  // Player on shadow tile
  game.player.gx = 5
  game.player.gy = 5
  @stealth.update_shadow_state(game)
  inspect(game.player.in_shadow, content="true")
  // Player on floor tile
  game.player.gx = 3
  game.player.gy = 3
  @stealth.update_shadow_state(game)
  inspect(game.player.in_shadow, content="false")
}
