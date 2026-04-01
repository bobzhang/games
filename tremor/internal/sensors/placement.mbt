///|
pub fn can_place_sensor(game : @types.Game, pos : @types.Vec2i) -> Bool {
  match game.level {
    None => false
    Some(level) => {
      if pos.x < 0 ||
        pos.x >= @types.grid_cols ||
        pos.y < 0 ||
        pos.y >= @types.grid_rows {
        return false
      }
      let tile = level.grid[pos.y][pos.x]
      if tile.kind == Blocked {
        return false
      }
      // Check if a sensor already exists there
      for i in 0..<game.sensors.length() {
        if game.sensors[i].pos == pos {
          return false
        }
      }
      // Check budget
      let cost = @types.sensor_cost(game.selected_sensor)
      if game.budget_used + cost > level.sensor_budget {
        return false
      }
      true
    }
  }
}

///|
pub fn place_sensor(game : @types.Game, pos : @types.Vec2i) -> Bool {
  if !can_place_sensor(game, pos) {
    return false
  }
  let sensor : @types.Sensor = {
    pos,
    kind: game.selected_sensor,
    direction: game.selected_direction,
  }
  game.sensors.push(sensor)
  game.budget_used += @types.sensor_cost(game.selected_sensor)
  game.sensor_place_count += 1
  // Recompute readings for all epicenters
  recompute_readings(game)
  true
}

///|
pub fn remove_last_sensor(game : @types.Game) -> Bool {
  if game.sensors.length() == 0 {
    return false
  }
  let last = game.sensors[game.sensors.length() - 1]
  game.budget_used -= @types.sensor_cost(last.kind)
  let _ = game.sensors.pop()
  recompute_readings(game)
  true
}

///|
pub fn recompute_readings(game : @types.Game) -> Unit {
  game.readings = []
  match game.level {
    None => ()
    Some(level) =>
      for i in 0..<level.epicenters.length() {
        if !level.epicenters[i].found {
          let r = compute_all_readings(
            game.sensors,
            level.epicenters[i].pos,
            level.grid,
          )
          for j in 0..<r.length() {
            game.readings.push(r[j])
          }
        }
      }
  }
}

///|
pub fn remaining_budget(game : @types.Game) -> Int {
  match game.level {
    Some(level) => level.sensor_budget - game.budget_used
    None => 0
  }
}
