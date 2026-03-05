///|
fn @types.Game::clear_dynamic_world(game : @types.Game) -> Unit {
  for i in 0..<game.enemies.length() {
    game.enemies[i] = @types.Enemy::inactive()
  }
  for i in 0..<game.coins.length() {
    game.coins[i] = @types.Coin::inactive()
  }
}

///|
fn @types.Game::alloc_enemy(game : @types.Game) -> Int {
  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      return i
    }
  }
  -1
}

///|
fn @types.Game::alloc_coin(game : @types.Game) -> Int {
  for i in 0..<game.coins.length() {
    if not(game.coins[i].active) {
      return i
    }
  }
  -1
}

///|
fn @types.Game::add_enemy_spawn(
  game : @types.Game,
  tx : Int,
  stand_tile_y : Int,
  dir : Int,
) -> Unit {
  let idx = game.alloc_enemy()
  if idx < 0 {
    return
  }
  let x = @types.tile_center_x(tx)
  let y = @types.tile_top(stand_tile_y) - @types.enemy_half_h() - 0.01
  game.enemies[idx] = @types.Enemy::spawn(x, y, dir)
}

///|
fn @types.Game::add_coin_spawn(game : @types.Game, tx : Int, ty : Int) -> Unit {
  let idx = game.alloc_coin()
  if idx < 0 {
    return
  }
  let x = @types.tile_center_x(tx)
  let y = @types.tile_center_y(ty)
  game.coins[idx] = @types.Coin::spawn(x, y, @types.randf(0.0, 6.28))
}

///|
fn @types.Game::carve_gap(game : @types.Game, tx0 : Int, tx1 : Int) -> Unit {
  for x in tx0..<=tx1 {
    for y in @types.ground_row..<@types.world_tiles_h {
      @types.set_tile(game, x, y, Empty)
    }
  }
}

///|
fn @types.Game::add_pipe(game : @types.Game, tx : Int, height : Int) -> Unit {
  let top = @types.ground_row - height
  @types.fill_rect_tile(game, tx, top, 2, height, Pipe)
}

///|
fn @types.Game::add_brick_row(
  game : @types.Game,
  tx : Int,
  ty : Int,
  len : Int,
) -> Unit {
  for x in tx..<(tx + len) {
    @types.set_tile(game, x, ty, Brick)
  }
}

///|
fn @types.Game::add_question(game : @types.Game, tx : Int, ty : Int) -> Unit {
  @types.set_tile(game, tx, ty, Question)
}

///|
fn @types.Game::fill_ground(game : @types.Game) -> Unit {
  @types.fill_rect_tile(
    game,
    0,
    @types.ground_row,
    @types.world_tiles_w,
    @types.world_tiles_h - @types.ground_row,
    Ground,
  )
}

///|
fn @types.Game::build_level_geometry(game : @types.Game) -> Unit {
  @types.clear_tiles(game)
  game.fill_ground()

  game.carve_gap(48, 51)
  game.carve_gap(92, 95)
  game.carve_gap(138, 142)
  game.carve_gap(174, 176)
  game.carve_gap(209, 212)

  game.add_pipe(28, 3)
  game.add_pipe(40, 4)
  game.add_pipe(70, 3)
  game.add_pipe(106, 5)
  game.add_pipe(146, 4)
  game.add_pipe(164, 6)
  game.add_pipe(192, 4)

  game.add_brick_row(22, 12, 5)
  game.add_question(23, 12)
  game.add_question(25, 12)

  game.add_brick_row(58, 11, 6)
  game.add_question(61, 11)

  game.add_brick_row(82, 12, 5)
  game.add_question(84, 12)

  game.add_brick_row(118, 10, 4)
  game.add_question(119, 10)
  game.add_question(121, 10)

  game.add_brick_row(152, 12, 8)
  game.add_question(155, 12)
  game.add_question(157, 12)

  game.add_brick_row(181, 11, 7)
  game.add_question(184, 11)

  // Stair near the end.
  @types.fill_rect_tile(
    game,
    200,
    @types.ground_row - 1,
    1,
    1,
    Ground,
  )
  @types.fill_rect_tile(
    game,
    201,
    @types.ground_row - 2,
    1,
    2,
    Ground,
  )
  @types.fill_rect_tile(
    game,
    202,
    @types.ground_row - 3,
    1,
    3,
    Ground,
  )
  @types.fill_rect_tile(
    game,
    203,
    @types.ground_row - 4,
    1,
    4,
    Ground,
  )
  @types.fill_rect_tile(
    game,
    204,
    @types.ground_row - 5,
    1,
    5,
    Ground,
  )
  @types.fill_rect_tile(
    game,
    205,
    @types.ground_row - 6,
    1,
    6,
    Ground,
  )

  // Flag pole and castle.
  let flag_tx = 214
  for ty in 8..<@types.ground_row {
    @types.set_tile(game, flag_tx, ty, FlagPole)
  }

  @types.fill_rect_tile(
    game,
    222,
    @types.ground_row - 5,
    6,
    5,
    Castle,
  )
  @types.fill_rect_tile(
    game,
    224,
    @types.ground_row - 7,
    2,
    2,
    Castle,
  )

  game.flag_x = @types.tile_center_x(flag_tx)
  game.flag_top_y = @types.tile_top(8)
  game.flag_bottom_y = @types.tile_top(@types.ground_row) -
    @types.player_half_h() -
    0.01
  game.castle_x = @types.tile_left(226) + @types.tile_size_f
  game.start_y = @types.tile_top(@types.ground_row) -
    @types.player_half_h() -
    0.01
}

///|
fn @types.Game::populate_level_entities(game : @types.Game) -> Unit {
  game.clear_dynamic_world()

  game.add_enemy_spawn(18, @types.ground_row, -1)
  game.add_enemy_spawn(33, @types.ground_row, -1)
  game.add_enemy_spawn(45, @types.ground_row, -1)
  game.add_enemy_spawn(64, @types.ground_row, -1)
  game.add_enemy_spawn(76, @types.ground_row, -1)
  game.add_enemy_spawn(88, @types.ground_row, -1)
  game.add_enemy_spawn(103, @types.ground_row, -1)
  game.add_enemy_spawn(115, @types.ground_row, -1)
  game.add_enemy_spawn(132, @types.ground_row, -1)
  game.add_enemy_spawn(150, @types.ground_row, -1)
  game.add_enemy_spawn(170, @types.ground_row, -1)
  game.add_enemy_spawn(188, @types.ground_row, -1)
  game.add_enemy_spawn(198, @types.ground_row - 6, -1)

  for x = 8; x < 36; x = x + 3 {
    game.add_coin_spawn(x, 13)
  }
  for x = 54; x < 88; x = x + 4 {
    game.add_coin_spawn(x, 10)
  }
  for x = 100; x < 133; x = x + 3 {
    game.add_coin_spawn(x, 9)
  }
  for x = 146; x < 180; x = x + 3 {
    game.add_coin_spawn(x, 11)
  }
  for x = 184; x < 212; x = x + 2 {
    game.add_coin_spawn(x, 8)
  }
}

///|
fn @types.Game::reset_player_pose(
  game : @types.Game,
  give_invuln : Bool,
) -> Unit {
  let player = game.player
  player.x = @types.player_start_x
  player.y = game.start_y
  player.vx = 0.0
  player.vy = 0.0
  player.facing = 1
  player.on_ground = false
  player.coyote_t = 0.0
  player.jump_buf_t = 0.0
  player.reached_flag = false
  player.flag_phase = 0
  player.invuln_t = if give_invuln { @types.player_invuln_time } else { 0.0 }
}

///|
fn @types.Game::build_level(game : @types.Game) -> Unit {
  game.build_level_geometry()
  game.populate_level_entities()
  game.reset_player_pose(false)
  game.camera_x = 0.0
  game.shake_t = 0.0
}

///|
fn @types.Game::reset_full_run(game : @types.Game) -> Unit {
  game.build_level()
  @particles.clear_particles(game)

  let player = game.player
  player.lives = 3
  player.coins = 0
  player.score = 0

  game.time_left = @types.start_time_seconds
  game.time_accum = 0.0
  game.elapsed = 0.0
  game.state = Playing
}
