///|
/// Generate noise from player movement
pub fn generate_movement_noise(game : @types.Game) -> Unit {
  let radius = if game.player.running {
    @types.run_noise_radius
  } else {
    @types.walk_noise_radius
  }
  game.noise_x = game.player.gx
  game.noise_y = game.player.gy
  game.noise_radius = radius
  game.noise_timer = @types.noise_decay_time
  if game.player.running {
    @types.push_sound(game, Run)
  } else {
    @types.push_sound(game, Footstep)
  }
}

///|
/// Generate noise from a coin toss
pub fn generate_coin_noise(game : @types.Game, tx : Int, ty : Int) -> Unit {
  if game.player.coins <= 0 {
    return
  }
  game.player.coins -= 1
  game.coin_target_x = tx
  game.coin_target_y = ty
  game.coin_active = true
  game.coin_timer = @types.coin_duration
  game.noise_x = tx
  game.noise_y = ty
  game.noise_radius = @types.coin_noise_radius
  game.noise_timer = @types.coin_duration
  @types.push_sound(game, CoinToss)
  @types.set_message(game, "Coin tossed!", 1.0)
}

///|
/// Update noise state
pub fn update_noise(game : @types.Game, dt : Float) -> Unit {
  if game.noise_timer > 0.0 {
    game.noise_timer -= dt
    if game.noise_timer <= 0.0 {
      game.noise_radius = 0
    }
  }
  if game.coin_active {
    game.coin_timer -= dt
    if game.coin_timer <= 0.0 {
      game.coin_active = false
    }
  }
}

///|
/// Check if player is in a shadow tile
pub fn update_shadow_state(game : @types.Game) -> Unit {
  let px = game.player.gx
  let py = game.player.gy
  if @types.in_bounds(px, py) {
    game.player.in_shadow = game.level.tiles[py][px] is Shadow
  } else {
    game.player.in_shadow = false
  }
}
