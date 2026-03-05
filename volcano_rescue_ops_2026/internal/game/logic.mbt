///|
fn @types.Game::set_tile(
  game : @types.Game,
  x : Int,
  y : Int,
  t : @types.Tile,
) -> Unit {
  if @types.in_bounds(x, y) {
    game.terrain[@types.cell_index(x, y)] = t
  }
}

///|
fn @types.Game::set_lava(
  game : @types.Game,
  x : Int,
  y : Int,
  v : Bool,
) -> Unit {
  if @types.in_bounds(x, y) {
    game.lava[@types.cell_index(x, y)] = v
  }
}

///|
fn @types.Game::set_message(
  game : @types.Game,
  msg : String,
  ttl : Float,
) -> Unit {
  game.msg = msg
  game.msg_t = ttl
}

///|
fn @types.Game::clear_route(game : @types.Game) -> Unit {
  game.route_len = 0
  game.route_running = false
  game.step_timer = 0.0
  for i in 0..<game.route.length() {
    game.route[i] = None
  }
}

///|
fn @types.Game::push_route_step(game : @types.Game, dir : @types.Dir) -> Bool {
  if game.route_len >= @types.max_route_steps {
    return false
  }

  game.route[game.route_len] = dir
  game.route_len = game.route_len + 1
  true
}

///|
fn @types.Game::pop_route_step(game : @types.Game) -> @types.Dir {
  if game.route_len <= 0 {
    return None
  }

  let dir : @types.Dir = game.route[0]
  for i in 1..<game.route_len {
    game.route[i - 1] = game.route[i]
  }
  game.route_len = game.route_len - 1
  game.route[game.route_len] = None
  dir
}

///|
fn @types.Game::is_walkable(game : @types.Game, x : Int, y : Int) -> Bool {
  @types.in_bounds(x, y) &&
  @types.tile_at(game, x, y) != Rock &&
  not(@types.lava_at(game, x, y))
}

///|
fn @types.Game::clear_sites(game : @types.Game) -> Unit {
  game.site_count = 0
  for site in game.sites {
    site.active = false
    site.x = 0
    site.y = 0
    site.waiting = 0
  }
}

///|
fn @types.Game::add_site(
  game : @types.Game,
  x : Int,
  y : Int,
  waiting : Int,
) -> Unit {
  if game.site_count >= @types.max_sites ||
    waiting <= 0 ||
    not(@types.in_bounds(x, y)) {
    return
  }

  let i : Int = game.site_count
  game.sites[i].active = true
  game.sites[i].x = x
  game.sites[i].y = y
  game.sites[i].waiting = waiting
  game.site_count = game.site_count + 1
}

///|
fn @types.Game::clear_world(game : @types.Game) -> Unit {
  for i in 0..<@types.max_cells {
    game.terrain[i] = Ground
    game.lava[i] = false
    game.lava_buf[i] = false
  }

  game.clear_sites()
  game.clear_route()

  game.selected_tx = -1
  game.selected_ty = -1
  game.last_plan_ok = false
}

///|
fn @types.Game::add_rock_line(
  game : @types.Game,
  x0 : Int,
  y0 : Int,
  x1 : Int,
  y1 : Int,
) -> Unit {
  if x0 == x1 {
    let mut a : Int = y0.min(y1)
    let b : Int = y0.max(y1)
    while a <= b {
      game.set_tile(x0, a, Rock)
      a = a + 1
    }
  } else if y0 == y1 {
    let mut a : Int = x0.min(x1)
    let b : Int = x0.max(x1)
    while a <= b {
      game.set_tile(a, y0, Rock)
      a = a + 1
    }
  }
}

///|
fn @types.Game::add_rock_block(
  game : @types.Game,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Unit {
  for yy in y..<(y + h) {
    for xx in x..<(x + w) {
      game.set_tile(xx, yy, Rock)
    }
  }
}

///|
fn @types.Game::add_depot(game : @types.Game, x : Int, y : Int) -> Unit {
  if @types.in_bounds(x, y) {
    game.set_tile(x, y, Depot)
  }
}

///|
fn @types.Game::add_lava_seed(game : @types.Game, x : Int, y : Int) -> Unit {
  if @types.in_bounds(x, y) && @types.tile_at(game, x, y) != Rock {
    game.set_lava(x, y, true)
  }
}

///|
fn @types.Game::setup_level_0(game : @types.Game) -> Unit {
  game.start_x = 1
  game.start_y = 8
  game.shelter_x = 13
  game.shelter_y = 1
  game.goal_rescue = 11
  game.mission_limit = 205.0
  game.lava_interval = 1.58

  game.add_rock_line(4, 0, 4, 8)
  game.set_tile(4, 2, Ground)
  game.set_tile(4, 5, Ground)
  game.set_tile(4, 7, Ground)

  game.add_rock_line(7, 4, 14, 4)
  game.set_tile(9, 4, Ground)
  game.set_tile(12, 4, Ground)

  game.add_rock_block(8, 0, 2, 2)
  game.add_rock_block(10, 6, 2, 2)
  game.add_rock_block(1, 4, 2, 1)

  game.add_depot(2, 3)
  game.add_depot(11, 8)

  game.add_lava_seed(0, 0)
  game.add_lava_seed(7, 0)
  game.add_lava_seed(14, 9)

  game.add_site(3, 7, 4)
  game.add_site(8, 8, 3)
  game.add_site(12, 6, 5)
  game.add_site(6, 2, 3)
}

///|
fn @types.Game::setup_level_1(game : @types.Game) -> Unit {
  game.start_x = 0
  game.start_y = 5
  game.shelter_x = 14
  game.shelter_y = 8
  game.goal_rescue = 13
  game.mission_limit = 225.0
  game.lava_interval = 1.42

  game.add_rock_line(2, 0, 2, 8)
  game.set_tile(2, 2, Ground)
  game.set_tile(2, 6, Ground)

  game.add_rock_line(6, 1, 6, 9)
  game.set_tile(6, 3, Ground)
  game.set_tile(6, 7, Ground)

  game.add_rock_line(9, 0, 13, 0)
  game.add_rock_line(9, 5, 14, 5)
  game.set_tile(11, 5, Ground)

  game.add_rock_block(10, 2, 2, 2)
  game.add_rock_block(4, 7, 1, 3)

  game.add_depot(5, 1)
  game.add_depot(10, 6)

  game.add_lava_seed(14, 0)
  game.add_lava_seed(13, 1)
  game.add_lava_seed(7, 9)

  game.add_site(1, 1, 4)
  game.add_site(4, 8, 3)
  game.add_site(8, 4, 3)
  game.add_site(11, 2, 4)
  game.add_site(13, 6, 3)
}

///|
fn @types.Game::setup_level_2(game : @types.Game) -> Unit {
  game.start_x = 7
  game.start_y = 9
  game.shelter_x = 1
  game.shelter_y = 0
  game.goal_rescue = 15
  game.mission_limit = 245.0
  game.lava_interval = 1.31

  game.add_rock_line(3, 2, 12, 2)
  game.set_tile(5, 2, Ground)
  game.set_tile(8, 2, Ground)
  game.set_tile(10, 2, Ground)

  game.add_rock_line(4, 6, 11, 6)
  game.set_tile(6, 6, Ground)
  game.set_tile(9, 6, Ground)

  game.add_rock_line(12, 3, 12, 9)
  game.set_tile(12, 5, Ground)
  game.set_tile(12, 8, Ground)

  game.add_rock_block(0, 4, 2, 2)
  game.add_rock_block(7, 4, 2, 1)

  game.add_depot(6, 5)
  game.add_depot(13, 2)

  game.add_lava_seed(14, 4)
  game.add_lava_seed(14, 5)
  game.add_lava_seed(13, 4)
  game.add_lava_seed(0, 9)

  game.add_site(2, 8, 4)
  game.add_site(5, 4, 5)
  game.add_site(8, 8, 4)
  game.add_site(10, 1, 4)
  game.add_site(13, 7, 3)
}

///|
fn @types.Game::finalize_level_setup(game : @types.Game) -> Unit {
  game.set_tile(game.shelter_x, game.shelter_y, Shelter)
  game.set_tile(game.start_x, game.start_y, Ground)

  game.truck_x = game.start_x
  game.truck_y = game.start_y

  game.total_civilians = @types.total_waiting(game)
  game.goal_rescue = game.goal_rescue.clamp(min=1, max=game.total_civilians)

  game.carrying = 0
  game.rescued = 0
  game.lost = 0

  game.heat = 14.0 + Float::from_int(game.level_index * 4)
  game.fuel = @types.max_fuel
  game.coolant = @types.max_coolant

  game.mission_time = 0.0
  game.lava_timer = 0.0
  game.result = None
  game.state = Play

  game.clear_route()

  game.set_message(
    "Mission " + (game.level_index + 1).to_string() + " underway",
    1.4,
  )
}

///|
fn @types.Game::load_level(game : @types.Game, index : Int) -> Unit {
  game.clear_world()

  game.level_index = index.clamp(min=0, max=@types.level_count - 1)

  if game.level_index == 0 {
    game.setup_level_0()
  } else if game.level_index == 1 {
    game.setup_level_1()
  } else {
    game.setup_level_2()
  }

  game.finalize_level_setup()
}

///|
fn @types.Game::restart_level(game : @types.Game) -> Unit {
  game.load_level(game.level_index)
}

///|
fn @types.Game::start_campaign(game : @types.Game) -> Unit {
  game.load_level(0)
}

///|
fn @types.Game::next_level_or_title(game : @types.Game) -> Unit {
  if @types.has_next_level(game) {
    game.load_level(game.level_index + 1)
  } else {
    game.state = Title
    game.result = None
    game.msg = ""
    game.msg_t = 0.0
    game.route_len = 0
    game.route_running = false
    game.selected_tx = -1
    game.selected_ty = -1
    game.last_plan_ok = false
  }
}

///|
fn @types.Game::append_manual_step(
  game : @types.Game,
  dir : @types.Dir,
) -> Bool {
  if dir == None {
    return false
  }

  let ok : Bool = game.push_route_step(dir)
  game.last_plan_ok = ok
  game.selected_tx = -1
  game.selected_ty = -1

  if not(ok) {
    game.set_message("Route queue full", 0.8)
  }

  ok
}

///|
fn @types.Game::begin_route(game : @types.Game) -> Unit {
  if game.route_len <= 0 {
    game.set_message("Route queue is empty", 0.8)
    return
  }

  game.route_running = true
  game.step_timer = 0.0
  game.set_message("Convoy moving", 0.55)
}

///|
fn @types.Game::clear_planned_route(game : @types.Game) -> Unit {
  if game.route_len > 0 {
    game.clear_route()
    game.set_message("Route queue cleared", 0.55)
  }
}

///|
fn @types.Game::use_coolant(game : @types.Game) -> Unit {
  if game.coolant < 18.0 {
    game.set_message("Coolant too low", 0.7)
    return
  }

  game.coolant = @types.clampf(game.coolant - 18.0, 0.0, @types.max_coolant)
  game.heat = @types.clampf(game.heat - 28.0, 0.0, @types.max_heat)
  game.set_message("Emergency spray deployed", 0.75)
}

///|
fn @types.Game::plan_route_to(game : @types.Game, tx : Int, ty : Int) -> Bool {
  game.selected_tx = tx
  game.selected_ty = ty

  if not(@types.in_bounds(tx, ty)) {
    game.last_plan_ok = false
    return false
  }

  if not(game.is_walkable(tx, ty)) {
    game.last_plan_ok = false
    game.set_message("Target cell is blocked", 0.85)
    return false
  }

  let start : Int = @types.cell_index(game.truck_x, game.truck_y)
  let goal : Int = @types.cell_index(tx, ty)

  let q : Array[Int] = Array::make(@types.max_cells, 0)
  let parent : Array[Int] = Array::make(@types.max_cells, -1)
  let parent_dir : Array[@types.Dir] = Array::make(@types.max_cells, None)
  let visited : Array[Bool] = Array::make(@types.max_cells, false)

  let mut head : Int = 0
  let mut tail : Int = 0

  q[tail] = start
  tail = tail + 1
  visited[start] = true

  while head < tail && not(visited[goal]) {
    let cur : Int = q[head]
    head = head + 1

    let cx : Int = cur % @types.grid_w
    let cy : Int = cur / @types.grid_w

    for k in 0..<4 {
      let dir : @types.Dir = if k == 0 {
        Up
      } else if k == 1 {
        Down
      } else if k == 2 {
        Left
      } else {
        Right
      }

      let nx : Int = cx + @types.route_dx(dir)
      let ny : Int = cy + @types.route_dy(dir)

      if not(@types.in_bounds(nx, ny)) {
        continue
      }
      if not(game.is_walkable(nx, ny)) {
        continue
      }

      let nidx : Int = @types.cell_index(nx, ny)
      if visited[nidx] {
        continue
      }

      visited[nidx] = true
      parent[nidx] = cur
      parent_dir[nidx] = dir
      q[tail] = nidx
      tail = tail + 1
    }
  }

  if not(visited[goal]) {
    game.last_plan_ok = false
    game.set_message("No safe path available", 0.95)
    return false
  }

  let rev : Array[@types.Dir] = Array::make(@types.max_route_steps, None)
  let mut rev_len : Int = 0
  let mut cur : Int = goal

  while cur != start {
    if rev_len >= @types.max_route_steps {
      game.last_plan_ok = false
      game.set_message("Path exceeds queue limit", 0.95)
      return false
    }

    let d : @types.Dir = parent_dir[cur]
    if d == None {
      game.last_plan_ok = false
      game.set_message("Planner failed", 0.95)
      return false
    }

    rev[rev_len] = d
    rev_len = rev_len + 1
    cur = parent[cur]

    if cur < 0 {
      game.last_plan_ok = false
      game.set_message("Planner failed", 0.95)
      return false
    }
  }

  game.clear_route()

  let mut i : Int = rev_len - 1
  while i >= 0 {
    ignore(game.push_route_step(rev[i]))
    i = i - 1
  }

  game.last_plan_ok = true

  if rev_len > 0 {
    game.set_message("Route planned: " + rev_len.to_string() + " steps", 0.9)
  } else {
    game.set_message("Already at target", 0.7)
  }

  true
}

///|
fn @types.Game::pickup_civilians(game : @types.Game) -> Unit {
  if game.carrying >= @types.vehicle_capacity {
    return
  }

  for i in 0..<game.site_count {
    if not(game.sites[i].active) || game.sites[i].waiting <= 0 {
      continue
    }

    if game.sites[i].x != game.truck_x || game.sites[i].y != game.truck_y {
      continue
    }

    let room : Int = @types.vehicle_capacity - game.carrying
    if room <= 0 {
      return
    }

    let take : Int = room.min(game.sites[i].waiting)
    if take <= 0 {
      continue
    }

    game.sites[i].waiting = game.sites[i].waiting - take
    game.carrying = game.carrying + take

    game.set_message("Picked up " + take.to_string() + " civilians", 0.85)
  }
}

///|
fn @types.Game::dropoff_civilians(game : @types.Game) -> Unit {
  if game.carrying <= 0 {
    return
  }

  if game.truck_x == game.shelter_x && game.truck_y == game.shelter_y {
    let delivered : Int = game.carrying
    game.rescued = game.rescued + delivered
    game.carrying = 0

    game.set_message("Delivered " + delivered.to_string() + " civilians", 0.9)
  }
}

///|
fn @types.Game::tile_is_depot(game : @types.Game, x : Int, y : Int) -> Bool {
  @types.tile_at(game, x, y) == Depot
}

///|
fn @types.Game::process_arrival(game : @types.Game) -> Unit {
  game.pickup_civilians()
  game.dropoff_civilians()
}

///|
fn @types.Game::move_step(game : @types.Game, dir : @types.Dir) -> Bool {
  if dir == None {
    return false
  }

  if game.fuel < @types.move_fuel_cost {
    game.route_running = false
    game.set_message("Insufficient fuel", 0.75)
    return false
  }

  let nx : Int = game.truck_x + @types.route_dx(dir)
  let ny : Int = game.truck_y + @types.route_dy(dir)

  if not(game.is_walkable(nx, ny)) {
    game.route_running = false
    game.set_message("Route blocked by lava or debris", 0.9)
    return false
  }

  game.truck_x = nx
  game.truck_y = ny
  game.fuel = @types.clampf(
    game.fuel - @types.move_fuel_cost,
    0.0,
    @types.max_fuel,
  )
  game.heat = @types.clampf(
    game.heat + @types.move_heat_gain,
    0.0,
    @types.max_heat,
  )

  game.process_arrival()
  true
}

///|
fn @types.Game::update_route_run(game : @types.Game, dt : Float) -> Unit {
  if not(game.route_running) {
    return
  }

  game.step_timer = game.step_timer + dt

  while game.step_timer >= @types.step_interval {
    game.step_timer = game.step_timer - @types.step_interval

    if game.route_len <= 0 {
      game.route_running = false
      break
    }

    let dir : @types.Dir = game.pop_route_step()
    if dir == None {
      game.route_running = false
      break
    }

    if not(game.move_step(dir)) {
      break
    }
  }
}

///|
fn @types.Game::lava_pressure(game : @types.Game) -> Int {
  let mut pressure : Int = 0

  for oy in -1..<=1 {
    for ox in -1..<=1 {
      let nx : Int = game.truck_x + ox
      let ny : Int = game.truck_y + oy
      if @types.lava_at(game, nx, ny) {
        let add : Int = if ox == 0 && oy == 0 { 4 } else { 2 }
        pressure = pressure + add
      }
    }
  }

  pressure
}

///|
fn @types.Game::update_passive_heat_and_supply(
  game : @types.Game,
  dt : Float,
) -> Unit {
  let pressure : Int = game.lava_pressure()

  let mut heat_gain : Float = 1.2 + Float::from_int(pressure) * 0.34
  heat_gain = heat_gain + Float::from_int(game.carrying) * 0.24
  if game.route_running {
    heat_gain = heat_gain + 0.25
  }

  let mut cooling : Float = 0.95

  if game.tile_is_depot(game.truck_x, game.truck_y) {
    cooling = cooling + 5.6
    game.fuel = @types.clampf(game.fuel + dt * 23.0, 0.0, @types.max_fuel)
    game.coolant = @types.clampf(
      game.coolant + dt * 16.0,
      0.0,
      @types.max_coolant,
    )
  }

  game.fuel = @types.clampf(
    game.fuel - dt * (0.36 + Float::from_int(game.carrying) * 0.06),
    0.0,
    @types.max_fuel,
  )

  game.heat = @types.clampf(
    game.heat + (heat_gain - cooling) * dt,
    0.0,
    @types.max_heat,
  )
}

///|
fn @types.Game::burn_sites_from_lava(game : @types.Game) -> Unit {
  let mut losses : Int = 0

  for i in 0..<game.site_count {
    if not(game.sites[i].active) || game.sites[i].waiting <= 0 {
      continue
    }

    if @types.lava_at(game, game.sites[i].x, game.sites[i].y) {
      losses = losses + game.sites[i].waiting
      game.lost = game.lost + game.sites[i].waiting
      game.sites[i].waiting = 0
    }
  }

  if losses > 0 {
    game.set_message(losses.to_string() + " civilians lost to lava", 1.0)
  }
}

///|
fn @types.Game::spread_chance(
  game : @types.Game,
  nx : Int,
  ny : Int,
  base : Int,
) -> Int {
  let mut chance : Int = base

  if @types.tile_at(game, nx, ny) == Depot {
    chance = chance + 8
  }

  if nx == game.shelter_x && ny == game.shelter_y {
    chance = chance - 12
  }

  if nx == game.truck_x && ny == game.truck_y {
    chance = chance + 10
  }

  chance.clamp(min=6, max=95)
}

///|
fn @types.Game::try_spread_to(
  game : @types.Game,
  nx : Int,
  ny : Int,
  base : Int,
) -> Unit {
  if not(@types.in_bounds(nx, ny)) {
    return
  }
  if @types.tile_at(game, nx, ny) == Rock {
    return
  }

  let idx : Int = @types.cell_index(nx, ny)
  if game.lava[idx] || game.lava_buf[idx] {
    return
  }

  let chance : Int = game.spread_chance(nx, ny, base)
  if @raylib.get_random_value(0, 99) < chance {
    game.lava_buf[idx] = true
  }
}

///|
fn @types.Game::spread_lava_once(game : @types.Game) -> Unit {
  for i in 0..<@types.max_cells {
    game.lava_buf[i] = game.lava[i]
  }

  let base : Int = 28 + game.level_index * 8

  for y in 0..<@types.grid_h {
    for x in 0..<@types.grid_w {
      if not(@types.lava_at(game, x, y)) {
        continue
      }

      game.try_spread_to(x + 1, y, base)
      game.try_spread_to(x - 1, y, base)
      game.try_spread_to(x, y + 1, base)
      game.try_spread_to(x, y - 1, base)
    }
  }

  for i in 0..<@types.max_cells {
    game.lava[i] = game.lava_buf[i]
  }

  game.burn_sites_from_lava()
}

///|
fn @types.Game::finish_mission(
  game : @types.Game,
  win : Bool,
  reason : String,
) -> Unit {
  game.state = Result
  game.result = if win { Win } else { Lose }
  game.clear_route()
  game.set_message(reason, 2.8)
}

///|
fn @types.Game::evaluate_mission_state(game : @types.Game) -> Unit {
  if game.rescued >= game.goal_rescue {
    game.finish_mission(true, "Rescue quota achieved")
    return
  }

  if game.heat >= @types.max_heat {
    game.finish_mission(false, "Vehicle overheated")
    return
  }

  if game.mission_time >= game.mission_limit {
    game.finish_mission(false, "Mission timer expired")
    return
  }

  if @types.lava_at(game, game.truck_x, game.truck_y) {
    game.finish_mission(false, "Convoy consumed by lava")
    return
  }

  if @types.lava_at(game, game.shelter_x, game.shelter_y) {
    game.finish_mission(false, "Shelter overrun")
    return
  }

  let remaining_possible : Int = game.rescued +
    game.carrying +
    @types.total_waiting(game)
  if remaining_possible < game.goal_rescue {
    game.finish_mission(false, "Rescue quota no longer possible")
    return
  }

  if game.fuel <= 0.0 && not(game.tile_is_depot(game.truck_x, game.truck_y)) {
    if game.route_len <= 0 && not(game.route_running) {
      game.finish_mission(false, "Fuel exhausted")
    }
  }
}

///|
fn @types.Game::update_play(game : @types.Game, dt : Float) -> Unit {
  if game.state != Play {
    return
  }

  game.mission_time = game.mission_time + dt

  game.update_route_run(dt)
  game.update_passive_heat_and_supply(dt)

  game.lava_timer = game.lava_timer + dt
  while game.lava_timer >= game.lava_interval {
    game.lava_timer = game.lava_timer - game.lava_interval
    game.spread_lava_once()
  }

  game.process_arrival()
  game.evaluate_mission_state()
}

///|
fn @types.Game::update_timers(game : @types.Game, dt : Float) -> Unit {
  game.ui_t = game.ui_t + dt

  if game.msg_t > 0.0 {
    game.msg_t = @types.clampf(game.msg_t - dt, 0.0, 1000.0)
  }

  if game.touch_cd > 0.0 {
    game.touch_cd = @types.clampf(game.touch_cd - dt, 0.0, 1000.0)
  }
}

///|
/// Advances one frame of mission logic, input, and state transitions.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  // Handle F11 toggle
  if @raylib.is_key_pressed(@raylib.KeyF11) {
    @raylib.toggle_borderless_windowed()
  }

  // Read mouse/touch state
  let mouse = @raylib.get_mouse_position()
  game.mouse_x = mouse.x
  game.mouse_y = mouse.y
  game.mouse_hold = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)
  game.mouse_press = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)
  let mut tc : Int = @raylib.get_touch_point_count()
  if tc < 0 {
    tc = 0
  }
  game.touch_count = tc

  game.update_timers(dt)

  match game.state {
    Title =>
      if detect_start_press(
          game.mouse_x,
          game.mouse_y,
          game.mouse_press,
          game.touch_count,
        ) {
        game.start_campaign()
      }
    Play => {
      let restart_press : Bool = detect_restart_press(
        game.mouse_x,
        game.mouse_y,
        game.mouse_press,
        game.touch_count,
      )

      if restart_press && game.touch_cd <= 0.0 {
        game.touch_cd = 0.2
        game.restart_level()
      } else {
        let dir : @types.Dir = detect_dir_press(
          game.mouse_x,
          game.mouse_y,
          game.mouse_press,
          game.touch_count,
        )
        if dir != None && game.touch_cd <= 0.0 {
          game.touch_cd = 0.08
          ignore(game.append_manual_step(dir))
        }

        let tap = detect_map_target(
          game.mouse_x,
          game.mouse_y,
          game.mouse_press,
          game.touch_count,
        )
        if tap.0 && game.touch_cd <= 0.0 {
          game.touch_cd = 0.12
          ignore(game.plan_route_to(tap.1, tap.2))
        }

        if detect_execute_press(
            game.mouse_x,
            game.mouse_y,
            game.mouse_press,
            game.touch_count,
          ) &&
          game.touch_cd <= 0.0 {
          game.touch_cd = 0.14
          game.begin_route()
        }

        if detect_clear_route_press(
            game.mouse_x,
            game.mouse_y,
            game.mouse_press,
            game.touch_count,
          ) &&
          game.touch_cd <= 0.0 {
          game.touch_cd = 0.14
          game.clear_planned_route()
        }

        if detect_coolant_press(
            game.mouse_x,
            game.mouse_y,
            game.mouse_press,
            game.touch_count,
          ) &&
          game.touch_cd <= 0.0 {
          game.touch_cd = 0.18
          game.use_coolant()
        }
      }

      game.update_play(dt)
    }
    _ =>
      if detect_restart_press(
          game.mouse_x,
          game.mouse_y,
          game.mouse_press,
          game.touch_count,
        ) &&
        game.touch_cd <= 0.0 {
        game.touch_cd = 0.2
        game.restart_level()
      } else if detect_next_press(
          game.mouse_x,
          game.mouse_y,
          game.mouse_press,
          game.touch_count,
        ) &&
        game.touch_cd <= 0.0 &&
        game.result == Win {
        game.touch_cd = 0.2
        game.next_level_or_title()
      }
  }
}
