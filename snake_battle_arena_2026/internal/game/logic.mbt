///|
fn @types.Game::clear_effects(game : @types.Game) -> Unit {
  for spark in game.sparks {
    spark.active = false
    spark.x = 0.0
    spark.y = 0.0
    spark.vx = 0.0
    spark.vy = 0.0
    spark.life = 0.0
    spark.size = 0.0
    spark.kind = Splash
  }
}

///|
fn @types.Game::spawn_spark(
  game : @types.Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  kind : @types.SparkKind,
) -> Unit {
  for spark in game.sparks {
    if spark.active {
      continue
    }

    spark.active = true
    spark.x = x
    spark.y = y
    spark.vx = vx
    spark.vy = vy
    spark.life = life
    spark.size = size
    spark.kind = kind
    break
  }
}

///|
fn @types.Game::burst(
  game : @types.Game,
  x : Float,
  y : Float,
  n : Int,
  kind : @types.SparkKind,
) -> Unit {
  for _i in 0..<n {
    game.spawn_spark(
      x + @types.randf(-8.0, 8.0),
      y + @types.randf(-8.0, 8.0),
      @types.randf(-240.0, 240.0),
      @types.randf(-260.0, 140.0),
      @types.randf(0.2, 1.0),
      @types.randf(1.2, 5.0),
      kind,
    )
  }
}

///|
fn @types.Game::update_sparks(game : @types.Game, dt : Float) -> Unit {
  for spark in game.sparks {
    if not(spark.active) {
      continue
    }

    spark.life = spark.life - dt
    if spark.life <= 0.0 {
      spark.active = false
      continue
    }

    spark.x = spark.x + spark.vx * dt
    spark.y = spark.y + spark.vy * dt
    spark.vx = spark.vx * (1.0 - dt * 2.3)
    spark.vy = spark.vy * (1.0 - dt * 2.1) + dt * 160.0
  }
}

///|
fn @types.Game::player_segment_at(
  game : @types.Game,
  x : Int,
  y : Int,
  ignore_tail : Bool,
) -> Bool {
  let mut end : Int = game.p_len
  if ignore_tail && game.p_grow <= 0 {
    end = (0).max(end - 1)
  }

  for i in 0..<end {
    if game.p_seg_x[i] == x && game.p_seg_y[i] == y {
      return true
    }
  }

  false
}

///|
fn @types.Game::rival_segment_at(
  game : @types.Game,
  x : Int,
  y : Int,
  ignore_rid : Int,
  ignore_tail : Bool,
) -> Bool {
  for rid in 0..<game.rivals.length() {
    if not(game.rivals[rid].alive) {
      continue
    }

    if ignore_rid >= 0 && rid == ignore_rid {
      if ignore_tail {
        let end : Int = if game.rivals[rid].grow <= 0 {
          (0).max(game.rivals[rid].len - 1)
        } else {
          game.rivals[rid].len
        }

        for i in 0..<end {
          if game.rivals[rid].seg_x[i] == x && game.rivals[rid].seg_y[i] == y {
            return true
          }
        }
      }
      continue
    }

    for i in 0..<game.rivals[rid].len {
      if game.rivals[rid].seg_x[i] == x && game.rivals[rid].seg_y[i] == y {
        return true
      }
    }
  }

  false
}

///|
fn @types.Game::trap_at(game : @types.Game, x : Int, y : Int) -> Bool {
  game.trap_active && game.trap_x == x && game.trap_y == y
}

///|
fn @types.Game::is_cell_empty(game : @types.Game, x : Int, y : Int) -> Bool {
  if game.player_segment_at(x, y, false) {
    return false
  }

  if game.rival_segment_at(x, y, -1, false) {
    return false
  }

  if game.trap_at(x, y) {
    return false
  }

  true
}

///|
fn @types.Game::random_empty_cell(game : @types.Game) -> (Bool, Int, Int) {
  let mut empty_count : Int = 0

  for y in 0..<@types.grid_h {
    for x in 0..<@types.grid_w {
      if game.is_cell_empty(x, y) {
        empty_count = empty_count + 1
      }
    }
  }

  if empty_count <= 0 {
    return (false, 0, 0)
  }

  let pick : Int = @raylib.get_random_value(0, empty_count - 1)
  let mut seen : Int = 0

  for y in 0..<@types.grid_h {
    for x in 0..<@types.grid_w {
      if not(game.is_cell_empty(x, y)) {
        continue
      }

      if seen == pick {
        return (true, x, y)
      }

      seen = seen + 1
    }
  }

  (false, 0, 0)
}

///|
fn @types.Game::spawn_food(game : @types.Game) -> Bool {
  let cell = game.random_empty_cell()
  if not(cell.0) {
    return false
  }

  game.food_x = cell.1
  game.food_y = cell.2
  game.food_kind = if @raylib.get_random_value(0, 99) < 22 {
    Gold
  } else {
    Normal
  }

  true
}

///|
fn @types.Game::spawn_trap(game : @types.Game) -> Bool {
  if game.trap_active {
    return false
  }

  let cell = game.random_empty_cell()
  if not(cell.0) {
    return false
  }

  game.trap_x = cell.1
  game.trap_y = cell.2
  game.trap_active = true
  game.trap_ttl = @types.randf(8.0, 14.0)
  game.trap_flash = 0.0

  let (wx, wy) = @types.cell_world_center(game, game.trap_x, game.trap_y)
  game.burst(wx, wy, 12, Death)
  true
}

///|
fn @types.Game::reset_player(game : @types.Game, cx : Int, cy : Int) -> Unit {
  game.p_alive = true
  game.p_len = 5
  game.p_dir = Right
  game.p_next_dir = Right
  game.p_grow = 0

  for i in 0..<game.p_seg_x.length() {
    game.p_seg_x[i] = -100
    game.p_seg_y[i] = -100
  }

  for i in 0..<game.p_len {
    game.p_seg_x[i] = @types.wrap_x(cx - i)
    game.p_seg_y[i] = cy
  }
}

///|
fn @types.Game::reset_rival(
  game : @types.Game,
  rid : Int,
  cx : Int,
  cy : Int,
  dir : @types.Dir,
) -> Unit {
  let rival = game.rivals[rid]
  rival.alive = true
  rival.len = 4
  rival.dir = dir
  rival.next_dir = dir
  rival.grow = 0

  for i in 0..<rival.seg_x.length() {
    rival.seg_x[i] = -100
    rival.seg_y[i] = -100
  }

  for i in 0..<rival.len {
    let offset : Int = match dir {
      Left => i
      _ => -i
    }
    rival.seg_x[i] = @types.wrap_x(cx + offset)
    rival.seg_y[i] = cy
  }
}

///|
fn @types.Game::start_match(game : @types.Game) -> Unit {
  game.clear_effects()

  game.state = Play
  game.score = 0
  game.lives = @types.lives_default
  game.total_kills = 0
  game.combo = 0
  game.combo_t = 0.0

  game.step_acc = 0.0
  game.game_t = 0.0
  game.ui_t = 0.0

  game.boost_meter = 1.0
  game.boost_on = false
  game.hint_left = 3
  game.hint_t = 0.0

  game.trap_active = false
  game.trap_ttl = 0.0
  game.trap_flash = 0.0

  game.msg_t = 0.0
  game.shake_t = 0.0
  game.touch_cd = 0.0
  game.win = false

  game.reset_player(@types.grid_w / 2, @types.grid_h / 2)

  game.reset_rival(0, 6, 4, Right)
  if game.rivals.length() > 1 {
    game.reset_rival(1, @types.grid_w - 7, @types.grid_h - 5, Left)
  }

  ignore(game.spawn_food())

  @types.set_msg(game, "Collect food and outlast rivals", 1.8)
}

///|
fn @types.Game::cell_hits_player(game : @types.Game, x : Int, y : Int) -> Bool {
  game.player_segment_at(x, y, false)
}

///|
fn @types.Game::damage_player(game : @types.Game, msg : String) -> Unit {
  game.lives = game.lives - 1
  game.combo = 0
  game.combo_t = 0.0
  game.shake_t = @types.maxf(game.shake_t, 0.2)

  let (wx, wy) = @types.cell_world_center(
    game,
    game.p_seg_x[0],
    game.p_seg_y[0],
  )
  game.burst(wx, wy, 22, Death)

  if game.lives <= 0 {
    game.state = Result
    game.win = false
    if game.score > game.best_score {
      game.best_score = game.score
    }
    @types.set_msg(game, "Snake down", 1.6)
    return
  }

  game.reset_player(@types.grid_w / 2, @types.grid_h / 2)
  @types.set_msg(game, msg + "  Lives \{game.lives}", 1.0)
}

///|
fn @types.Game::rival_respawn(game : @types.Game, rid : Int) -> Unit {
  if rid < 0 || rid >= game.rivals.length() {
    return
  }

  game.rivals[rid].deaths = game.rivals[rid].deaths + 1

  let sx : Int = if rid % 2 == 0 { 3 } else { @types.grid_w - 4 }
  let sy : Int = if rid % 2 == 0 { 3 } else { @types.grid_h - 4 }
  let dir : @types.Dir = if rid % 2 == 0 { Right } else { Left }
  game.reset_rival(rid, sx, sy, dir)
}

///|
fn @types.Game::grow_player_after_food(game : @types.Game) -> Unit {
  if game.food_kind == Gold {
    game.p_grow = game.p_grow + 3
    game.score = game.score + 210
    game.combo = game.combo + 2
    @types.set_msg(game, "Gold food!", 0.9)
  } else {
    game.p_grow = game.p_grow + 1
    game.score = game.score + 80
    game.combo = game.combo + 1
  }

  game.combo_t = 1.1

  if game.combo > 1 {
    game.score = game.score + game.combo * 12
  }

  if game.score > game.best_score {
    game.best_score = game.score
  }

  ignore(game.spawn_food())

  if @raylib.get_random_value(0, 99) < 16 {
    ignore(game.spawn_trap())
  }
}

///|
fn @types.Game::shift_player_forward(
  game : @types.Game,
  nx : Int,
  ny : Int,
) -> Unit {
  let cap : Int = game.p_len.min(@types.max_segments - 1)

  for i = cap; i > 0; i = i - 1 {
    game.p_seg_x[i] = game.p_seg_x[i - 1]
    game.p_seg_y[i] = game.p_seg_y[i - 1]
  }

  game.p_seg_x[0] = nx
  game.p_seg_y[0] = ny

  if game.p_grow > 0 {
    game.p_grow = game.p_grow - 1
    game.p_len = @types.max_segments.min(game.p_len + 1)
  }
}

///|
fn @types.Game::player_step(game : @types.Game) -> Unit {
  if not(game.p_alive) {
    return
  }

  if not(@types.opposite_dir(game.p_dir, game.p_next_dir)) {
    game.p_dir = game.p_next_dir
  }

  let nx : Int = @types.wrap_x(game.p_seg_x[0] + @types.dir_dx(game.p_dir))
  let ny : Int = @types.wrap_y(game.p_seg_y[0] + @types.dir_dy(game.p_dir))

  let self_hit : Bool = game.player_segment_at(nx, ny, true)
  let rival_hit : Bool = game.rival_segment_at(nx, ny, -1, false)
  let trap_hit : Bool = game.trap_at(nx, ny)

  if self_hit || rival_hit || trap_hit {
    game.damage_player(if trap_hit { "Trap hit" } else { "Crash" })
    return
  }

  game.shift_player_forward(nx, ny)

  if nx == game.food_x && ny == game.food_y {
    let (wx, wy) = @types.cell_world_center(game, nx, ny)
    game.burst(wx, wy, if game.food_kind == Gold { 16 } else { 10 }, Eat)
    game.grow_player_after_food()
  }
}

///|
fn @types.Game::shift_rival_forward(
  game : @types.Game,
  rid : Int,
  nx : Int,
  ny : Int,
) -> Unit {
  let rival = game.rivals[rid]
  let cap : Int = rival.len.min(@types.max_segments - 1)

  for i = cap; i > 0; i = i - 1 {
    rival.seg_x[i] = rival.seg_x[i - 1]
    rival.seg_y[i] = rival.seg_y[i - 1]
  }

  rival.seg_x[0] = nx
  rival.seg_y[0] = ny

  if rival.grow > 0 {
    rival.grow = rival.grow - 1
    rival.len = @types.max_segments.min(rival.len + 1)
  }
}

///|
fn @types.Game::rival_would_collide(
  game : @types.Game,
  rid : Int,
  nx : Int,
  ny : Int,
) -> Bool {
  if game.player_segment_at(nx, ny, false) {
    return true
  }

  if game.rival_segment_at(nx, ny, rid, true) {
    return true
  }

  game.trap_at(nx, ny)
}

///|
fn @types.Game::rival_step(game : @types.Game, rid : Int) -> Unit {
  if rid < 0 || rid >= game.rivals.length() {
    return
  }

  let rival = game.rivals[rid]
  if not(rival.alive) {
    return
  }

  rival.next_dir = game.ai_choose_dir(rid)
  if not(@types.opposite_dir(rival.dir, rival.next_dir)) {
    rival.dir = rival.next_dir
  }

  let nx : Int = @types.wrap_x(rival.seg_x[0] + @types.dir_dx(rival.dir))
  let ny : Int = @types.wrap_y(rival.seg_y[0] + @types.dir_dy(rival.dir))

  let hits_player : Bool = game.cell_hits_player(nx, ny)
  let hits_rival : Bool = game.rival_segment_at(nx, ny, rid, true)
  let hits_trap : Bool = game.trap_at(nx, ny)

  if hits_player {
    if nx == game.p_seg_x[0] && ny == game.p_seg_y[0] {
      game.damage_player("Head clash")
    } else {
      game.total_kills = game.total_kills + 1
      game.score = game.score + 120
      if game.score > game.best_score {
        game.best_score = game.score
      }
      let (wx, wy) = @types.cell_world_center(game, nx, ny)
      game.burst(wx, wy, 14, Splash)
      @types.set_msg(game, "Rival crashed", 0.7)
    }

    game.rival_respawn(rid)
    return
  }

  if hits_rival || hits_trap {
    game.rival_respawn(rid)
    return
  }

  game.shift_rival_forward(rid, nx, ny)

  if nx == game.food_x && ny == game.food_y {
    let grow_gain : Int = if game.food_kind == Gold { 2 } else { 1 }
    let score_gain : Int = if game.food_kind == Gold { 140 } else { 64 }
    let burst_count : Int = if game.food_kind == Gold { 14 } else { 8 }

    rival.grow = rival.grow + grow_gain
    rival.score = rival.score + score_gain

    let (wx, wy) = @types.cell_world_center(game, nx, ny)
    game.burst(wx, wy, burst_count, Eat)
    ignore(game.spawn_food())

    if @raylib.get_random_value(0, 99) < 14 {
      ignore(game.spawn_trap())
    }
  }
}

///|
fn @types.Game::rival_total_score(game : @types.Game) -> Int {
  let mut s : Int = 0
  for rival in game.rivals {
    s = s + rival.score
  }
  s
}

///|
fn @types.Game::update_hint(game : @types.Game) -> Unit {
  if game.hint_t > 0.0 {
    return
  }

  game.hint_x = game.p_seg_x[0]
  game.hint_y = game.p_seg_y[0]
}

///|
fn @types.Game::use_hint(game : @types.Game) -> Bool {
  if game.state != Play {
    return false
  }
  if game.hint_left <= 0 {
    @types.set_msg(game, "No hints", 0.6)
    return false
  }

  let best = game.suggest_player_dir()
  match best {
    None => {
      @types.set_msg(game, "No safe hint", 0.7)
      return false
    }
    _ => ()
  }
  let best_dir = best.unwrap()

  game.hint_left = game.hint_left - 1
  game.p_next_dir = best_dir

  let nx : Int = @types.wrap_x(game.p_seg_x[0] + @types.dir_dx(best_dir))
  let ny : Int = @types.wrap_y(game.p_seg_y[0] + @types.dir_dy(best_dir))
  game.hint_x = nx
  game.hint_y = ny
  game.hint_t = 1.4

  @types.set_msg(game, "Hint: move now", 0.8)
  true
}

///|
fn @types.Game::check_timeout(game : @types.Game) -> Unit {
  if game.game_t < @types.match_time_limit {
    return
  }

  game.state = Result
  game.win = game.score >= game.rival_total_score()

  if game.score > game.best_score {
    game.best_score = game.score
  }

  if game.win {
    @types.set_msg(game, "Arena secured", 1.5)
  } else {
    @types.set_msg(game, "Rivals won", 1.5)
  }
}

///|
fn @types.Game::step_once(game : @types.Game) -> Unit {
  if game.state != Play {
    return
  }

  game.player_step()
  if game.state != Play {
    return
  }

  for rid in 0..<game.rivals.length() {
    game.rival_step(rid)
    if game.state != Play {
      return
    }
  }

  if game.combo_t > 0.0 {
    game.combo_t = game.combo_t - 0.08
  } else if game.combo > 0 {
    game.combo = game.combo - 1
    game.combo_t = 0.26
  }

  if @raylib.get_random_value(0, 999) < 8 {
    ignore(game.spawn_trap())
  }
}

///|
fn @types.Game::update_play(game : @types.Game, dt : Float) -> Unit {
  game.ui_t = game.ui_t + dt

  if game.state == Play {
    game.game_t = game.game_t + dt
  }

  if game.msg_t > 0.0 {
    game.msg_t = game.msg_t - dt
  }
  if game.shake_t > 0.0 {
    game.shake_t = game.shake_t - dt
  }
  if game.hint_t > 0.0 {
    game.hint_t = game.hint_t - dt
  }
  if game.touch_cd > 0.0 {
    game.touch_cd = game.touch_cd - dt
  }

  if game.trap_active {
    game.trap_ttl = game.trap_ttl - dt
    game.trap_flash = game.trap_flash + dt
    if game.trap_ttl <= 0.0 {
      game.trap_active = false
      game.trap_ttl = 0.0
      game.trap_flash = 0.0
    }
  }

  game.update_sparks(dt)

  if game.state != Play {
    return
  }

  let base_step : Float = if game.boost_on { 0.078 } else { 0.118 }

  if game.boost_on {
    game.boost_meter = @types.clampf(game.boost_meter - dt * 0.52, 0.0, 1.0)
    if game.boost_meter <= 0.0 {
      game.boost_on = false
    }
  } else {
    game.boost_meter = @types.clampf(game.boost_meter + dt * 0.22, 0.0, 1.0)
  }

  game.step_acc = game.step_acc + dt

  while game.step_acc >= base_step {
    game.step_acc = game.step_acc - base_step
    game.step_once()

    if game.state != Play {
      break
    }
  }

  game.update_hint()
  game.check_timeout()
}

///|
/// Capture controls and advance one frame of arena simulation.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.mouse_x = @raylib.get_mouse_x() |> Float::from_int
  game.mouse_y = @raylib.get_mouse_y() |> Float::from_int
  game.touch_count = @raylib.get_touch_point_count()
  game.mouse_hold = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) ||
    game.touch_count > 0
  let clamped_dt : Float = @types.clampf(dt, 0.0, 0.04)
  match game.state {
    Title => {
      game.update_title_input()
      game.update_play(clamped_dt)
    }
    Play => {
      game.update_play_input(clamped_dt)
      game.update_play(clamped_dt)
    }
    _ => {
      game.update_result_input()
      game.update_play(clamped_dt)
    }
  }
}
