///|
/// Configures the first campaign level: East Wing Silent Sweep, with walls, artifacts, and guard patrols.
fn @types.Game::setup_level_1(game : @types.Game) -> Unit {
  game.level_name = "East Wing Silent Sweep"
  game.player_x = 2
  game.player_y = 11
  game.exit_x = 17
  game.exit_y = 2

  @types.add_wall_rect(game, 6, 1, 1, 11)
  @types.carve_floor_rect(game, 6, 5, 1, 2)
  @types.add_wall_rect(game, 6, 7, 12, 1)
  @types.carve_floor_rect(game, 10, 7, 2, 1)
  @types.add_wall_rect(game, 13, 3, 1, 10)
  @types.carve_floor_rect(game, 13, 9, 1, 2)
  @types.add_wall_rect(game, 2, 10, 5, 1)
  @types.carve_floor_rect(game, 4, 10, 2, 1)
  @types.add_wall_rect(game, 15, 2, 1, 4)
  @types.carve_floor_rect(game, 15, 4, 1, 1)

  @types.spawn_artifact(game, 4, 3)
  @types.spawn_artifact(game, 11, 10)
  @types.spawn_artifact(game, 16, 11)

  @types.spawn_guard(
    game,
    [@types.pc(3, 2), @types.pc(10, 2), @types.pc(10, 6), @types.pc(3, 6)],
    6,
    0.00,
  )
  @types.spawn_guard(
    game,
    [@types.pc(16, 3), @types.pc(18, 3), @types.pc(18, 10), @types.pc(16, 10)],
    6,
    0.12,
  )
}

///|
/// Configures the second campaign level: Laser Hall Maze, with a corridor maze and three guards.
fn @types.Game::setup_level_2(game : @types.Game) -> Unit {
  game.level_name = "Laser Hall Maze"
  game.player_x = 2
  game.player_y = 2
  game.exit_x = 18
  game.exit_y = 11

  @types.add_wall_rect(game, 4, 1, 1, 12)
  @types.carve_floor_rect(game, 4, 4, 1, 1)
  @types.carve_floor_rect(game, 4, 9, 1, 1)

  @types.add_wall_rect(game, 9, 1, 1, 12)
  @types.carve_floor_rect(game, 9, 6, 1, 1)

  @types.add_wall_rect(game, 14, 1, 1, 12)
  @types.carve_floor_rect(game, 14, 8, 1, 1)

  @types.add_wall_rect(game, 4, 5, 11, 1)
  @types.carve_floor_rect(game, 7, 5, 1, 1)
  @types.carve_floor_rect(game, 12, 5, 1, 1)

  @types.add_wall_rect(game, 1, 9, 18, 1)
  @types.carve_floor_rect(game, 5, 9, 1, 1)
  @types.carve_floor_rect(game, 15, 9, 1, 1)

  @types.spawn_artifact(game, 6, 11)
  @types.spawn_artifact(game, 10, 3)
  @types.spawn_artifact(game, 13, 7)
  @types.spawn_artifact(game, 17, 2)

  @types.spawn_guard(
    game,
    [@types.pc(6, 2), @types.pc(7, 2), @types.pc(7, 7), @types.pc(6, 7)],
    5,
    0.00,
  )
  @types.spawn_guard(
    game,
    [@types.pc(16, 2), @types.pc(18, 2), @types.pc(18, 7), @types.pc(16, 7)],
    6,
    0.16,
  )
  @types.spawn_guard(
    game,
    [@types.pc(2, 10), @types.pc(3, 10), @types.pc(3, 12), @types.pc(2, 12)],
    5,
    0.28,
  )
}

///|
/// Configures the third campaign level: Grand Vault Orbit, with complex partitions and four guards.
fn @types.Game::setup_level_3(game : @types.Game) -> Unit {
  game.level_name = "Grand Vault Orbit"
  game.player_x = 1
  game.player_y = 12
  game.exit_x = 18
  game.exit_y = 1

  @types.add_wall_rect(game, 5, 1, 1, 12)
  @types.carve_floor_rect(game, 5, 3, 1, 1)
  @types.carve_floor_rect(game, 5, 10, 1, 1)

  @types.add_wall_rect(game, 10, 1, 1, 12)
  @types.carve_floor_rect(game, 10, 7, 1, 1)

  @types.add_wall_rect(game, 15, 1, 1, 12)
  @types.carve_floor_rect(game, 15, 4, 1, 1)
  @types.carve_floor_rect(game, 15, 9, 1, 1)

  @types.add_wall_rect(game, 5, 4, 11, 1)
  @types.carve_floor_rect(game, 8, 4, 1, 1)
  @types.carve_floor_rect(game, 13, 4, 1, 1)

  @types.add_wall_rect(game, 1, 8, 18, 1)
  @types.carve_floor_rect(game, 4, 8, 1, 1)
  @types.carve_floor_rect(game, 11, 8, 1, 1)
  @types.carve_floor_rect(game, 17, 8, 1, 1)

  @types.spawn_artifact(game, 3, 3)
  @types.spawn_artifact(game, 8, 6)
  @types.spawn_artifact(game, 11, 10)
  @types.spawn_artifact(game, 16, 5)
  @types.spawn_artifact(game, 17, 11)

  @types.spawn_guard(
    game,
    [@types.pc(2, 2), @types.pc(4, 2), @types.pc(4, 6), @types.pc(2, 6)],
    6,
    0.00,
  )
  @types.spawn_guard(
    game,
    [@types.pc(11, 2), @types.pc(13, 2), @types.pc(13, 6), @types.pc(11, 6)],
    5,
    0.13,
  )
  @types.spawn_guard(
    game,
    [@types.pc(2, 9), @types.pc(4, 9), @types.pc(4, 12), @types.pc(2, 12)],
    5,
    0.26,
  )
  @types.spawn_guard(
    game,
    [@types.pc(16, 9), @types.pc(18, 9), @types.pc(18, 12), @types.pc(16, 12)],
    6,
    0.34,
  )
}

///|
/// Clears entities, fills the board as floor, adds border walls, and calls the level-specific setup function.
fn @types.Game::load_level(game : @types.Game, level_idx : Int) -> Unit {
  let safe_idx = level_idx.clamp(min=0, max=game.level_count - 1)
  game.level_index = safe_idx

  @types.clear_entities(game)
  @types.fill_board_floor(game)
  @types.add_border_walls(game)

  if safe_idx == 0 {
    game.setup_level_1()
  } else if safe_idx == 1 {
    game.setup_level_2()
  } else {
    game.setup_level_3()
  }

  game.player_step_t = 0.0
  game.state_t = 0.0
  game.alarm_t = 0.0
}

///|
/// Loads the first level and returns the game to title state.
pub fn reset_to_title(game : @types.Game) -> Unit {
  game.load_level(0)
  game.state = Title
  game.state_t = 0.0
}

///|
/// Loads level 0 and transitions the game to the play state.
fn @types.Game::start_campaign(game : @types.Game) -> Unit {
  game.load_level(0)
  game.state = Play
  game.state_t = 0.0
}

///|
/// Reloads the current level index and restarts play.
fn @types.Game::retry_level(game : @types.Game) -> Unit {
  game.load_level(game.level_index)
  game.state = Play
  game.state_t = 0.0
}

///|
/// Advances to the next level or transitions to campaign-clear if all levels are done.
fn @types.Game::go_to_next_level(game : @types.Game) -> Unit {
  let next_level = game.level_index + 1
  if next_level < game.level_count {
    game.load_level(next_level)
    game.state = Play
    game.state_t = 0.0
  } else {
    game.state = CampaignClear
    game.state_t = 0.0
  }
}

///|
/// Loads the next level in a cycle while keeping the title state, to preview the board.
fn @types.Game::preview_next_title_level(game : @types.Game) -> Unit {
  let next_level = (game.level_index + 1) % game.level_count
  game.load_level(next_level)
  game.state = Title
}

///|
/// Moves the player one step in the given direction if the target cell is walkable and the step timer is ready.
fn @types.Game::try_move_player(
  game : @types.Game,
  dir : @types.Direction,
) -> Unit {
  match dir {
    DirNone => return
    _ => ()
  }
  if game.player_step_t > 0.0 {
    return
  }

  let (dx, dy) = @types.dir_delta(dir)
  let nx = game.player_x + dx
  let ny = game.player_y + dy
  if @types.walkable(game, nx, ny) {
    game.player_x = nx
    game.player_y = ny
  }
  game.player_step_t = @types.player_step_interval
}

///|
/// Marks any artifact at the player's current position as taken and increments the collection counter.
fn @types.Game::collect_artifacts(game : @types.Game) -> Unit {
  for artifact in game.artifacts {
    if artifact.taken {
      continue
    }
    if artifact.x == game.player_x && artifact.y == game.player_y {
      artifact.taken = true
      game.artifacts_collected = game.artifacts_collected + 1
    }
  }
}

///|
/// Steps a guard one tile toward its next patrol waypoint.
fn @types.Game::advance_guard_once(game : @types.Game, guard_idx : Int) -> Unit {
  let path_len = game.guards[guard_idx].path.length()
  if path_len == 0 {
    return
  }

  if game.guards[guard_idx].path_index < 0 ||
    game.guards[guard_idx].path_index >= path_len {
    game.guards[guard_idx].path_index = 0
  }

  let mut target_idx = game.guards[guard_idx].path_index
  let mut target = game.guards[guard_idx].path[target_idx]
  let mut tx = @types.cell_x(target)
  let mut ty = @types.cell_y(target)

  if game.guards[guard_idx].x == tx && game.guards[guard_idx].y == ty {
    target_idx = (target_idx + 1) % path_len
    game.guards[guard_idx].path_index = target_idx
    target = game.guards[guard_idx].path[target_idx]
    tx = @types.cell_x(target)
    ty = @types.cell_y(target)
  }

  let mut dx : Int = 0
  let mut dy : Int = 0
  if game.guards[guard_idx].x < tx {
    dx = 1
  } else if game.guards[guard_idx].x > tx {
    dx = -1
  } else if game.guards[guard_idx].y < ty {
    dy = 1
  } else if game.guards[guard_idx].y > ty {
    dy = -1
  }

  if dx == 0 && dy == 0 {
    return
  }

  let nx = game.guards[guard_idx].x + dx
  let ny = game.guards[guard_idx].y + dy
  if @types.walkable(game, nx, ny) {
    game.guards[guard_idx].x = nx
    game.guards[guard_idx].y = ny
    game.guards[guard_idx].dir_x = dx
    game.guards[guard_idx].dir_y = dy
  } else {
    game.guards[guard_idx].path_index = (game.guards[guard_idx].path_index + 1) %
      path_len
  }
}

///|
/// Advances all guard step timers and calls `advance_guard_once` whenever the interval elapses.
fn @types.Game::update_guards(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.guards.length() {
    game.guards[i].step_timer = game.guards[i].step_timer - dt
    while game.guards[i].step_timer <= 0.0 {
      game.guards[i].step_timer = game.guards[i].step_timer +
        @types.guard_step_interval
      game.advance_guard_once(i)
    }
  }
}

///|
/// Returns true when the current level is the last one in the campaign.
fn @types.Game::current_level_is_last(game : @types.Game) -> Bool {
  game.level_index + 1 >= game.level_count
}

///|
/// Transitions to the campaign-clear or win state depending on whether this is the final level.
fn @types.Game::complete_level(game : @types.Game) -> Unit {
  if game.current_level_is_last() {
    game.state = CampaignClear
  } else {
    game.state = Win
  }
  game.state_t = 0.0
}

///|
/// Transitions to the lose state and starts the alarm flash timer.
fn @types.Game::trigger_loss(game : @types.Game) -> Unit {
  game.state = Lose
  game.state_t = 0.0
  game.alarm_t = @types.alarm_flash_time
}

///|
/// Runs one frame of active play: handles restart input, advances guards, moves the player, checks collection and exit, and tests for detection.
fn @types.Game::update_play(
  game : @types.Game,
  dt : Float,
  input : @types.FrameInput,
) -> Unit {
  if input.restart_pressed {
    game.retry_level()
    return
  }

  if game.player_step_t > 0.0 {
    game.player_step_t = game.player_step_t - dt
    if game.player_step_t < 0.0 {
      game.player_step_t = 0.0
    }
  }

  game.update_guards(dt)
  game.try_move_player(input.move_dir)
  game.collect_artifacts()

  if @types.exit_unlocked(game) &&
    game.player_x == game.exit_x &&
    game.player_y == game.exit_y {
    game.complete_level()
    return
  }

  if @types.player_spotted(game) {
    game.trigger_loss()
  }
}

///|
/// Returns true when enough time has elapsed since the last state change to allow menu actions.
fn @types.Game::actions_ready(game : @types.Game) -> Bool {
  game.state_t >= @types.menu_action_delay
}

///|
/// Handles title-screen input to start the campaign or preview the next level.
fn @types.Game::update_title(
  game : @types.Game,
  input : @types.FrameInput,
) -> Unit {
  if !game.actions_ready() {
    return
  }

  if input.start_pressed {
    game.start_campaign()
  } else if input.next_pressed {
    game.preview_next_title_level()
  }
}

///|
/// Handles win-screen input to advance to the next level or retry.
fn @types.Game::update_win(
  game : @types.Game,
  input : @types.FrameInput,
) -> Unit {
  if !game.actions_ready() {
    return
  }

  if input.next_pressed {
    game.go_to_next_level()
  } else if input.retry_pressed || input.restart_pressed {
    game.retry_level()
  }
}

///|
/// Handles lose-screen input to retry the current level.
fn @types.Game::update_lose(
  game : @types.Game,
  input : @types.FrameInput,
) -> Unit {
  if !game.actions_ready() {
    return
  }

  if input.retry_pressed || input.next_pressed || input.start_pressed {
    game.retry_level()
  }
}

///|
/// Handles campaign-clear input to return to the title screen.
fn @types.Game::update_campaign_clear(
  game : @types.Game,
  input : @types.FrameInput,
) -> Unit {
  if !game.actions_ready() {
    return
  }

  if input.start_pressed || input.next_pressed || input.retry_pressed {
    reset_to_title(game)
  }
}

///|
/// Advances one frame of museum gameplay and campaign menu state.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  let input = game.gather_input()

  let mut capped_dt = dt
  if capped_dt < 0.0 {
    capped_dt = 0.0
  }
  if capped_dt > 0.05 {
    capped_dt = 0.05
  }

  game.state_t = game.state_t + capped_dt
  game.pulse_t = game.pulse_t + capped_dt

  if game.alarm_t > 0.0 {
    game.alarm_t = game.alarm_t - capped_dt
    if game.alarm_t < 0.0 {
      game.alarm_t = 0.0
    }
  }

  match game.state {
    Title => game.update_title(input)
    Play => game.update_play(capped_dt, input)
    Win => game.update_win(input)
    Lose => game.update_lose(input)
    CampaignClear => game.update_campaign_clear(input)
  }
}
