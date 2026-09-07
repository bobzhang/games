///|
pub fn parse_level(
  name : String,
  tier : @types.Tier,
  ascii : Array[String],
  par_time : Float,
) -> @types.Level {
  let level = @types.new_empty_level()
  level.name = name
  level.tier = tier
  level.par_time = par_time
  let mut guard_id = 0
  let mut power_id_counter = 1
  let mut terminal_count = 0
  for y in 0..<@types.grid_height {
    if y >= ascii.length() {
      continue
    }
    let row = ascii[y]
    for x in 0..<@types.grid_width {
      if x >= row.length() {
        continue
      }
      let ch = row[x]
      // Default floor
      level.tiles[y][x] = Floor
      if ch == '#' {
        level.tiles[y][x] = Wall
      } else if ch == '~' {
        level.tiles[y][x] = Shadow
      } else if ch == 'T' {
        level.tiles[y][x] = Terminal
        terminal_count += 1
        level.terminals.push(@types.new_terminal(x, y, false, power_id_counter))
        power_id_counter += 1
      } else if ch == 'H' {
        level.tiles[y][x] = HighTerminal
        terminal_count += 1
        level.terminals.push(@types.new_terminal(x, y, true, power_id_counter))
        power_id_counter += 1
      } else if ch == 'D' {
        level.tiles[y][x] = Door
        level.doors.push(@types.new_door(x, y, power_id_counter))
        power_id_counter += 1
      } else if ch == 'L' {
        level.tiles[y][x] = LaserGrid
        level.lasers.push(@types.new_laser(x, y, power_id_counter, true, 1))
        power_id_counter += 1
      } else if ch == 'P' {
        level.tiles[y][x] = PowerNode
        let node = @types.new_power_node(x, y, power_id_counter, [])
        level.power_nodes.push(node)
        power_id_counter += 1
      } else if ch == 'X' {
        level.tiles[y][x] = Exit
        level.exit_x = x
        level.exit_y = y
      } else if ch == 'S' {
        level.tiles[y][x] = Start
        level.start_x = x
        level.start_y = y
      } else if ch == 'G' {
        // Patrol guard
        level.guards.push(@types.new_guard(x, y, Patrol, [{ x, y, }]))
        guard_id += 1
      } else if ch == 'N' {
        // Sentinel guard
        level.guards.push(@types.new_guard(x, y, Sentinel, []))
        guard_id += 1
      } else if ch == 'U' {
        // Hunter guard
        level.guards.push(@types.new_guard(x, y, Hunter, [{ x, y, }]))
        guard_id += 1
      } else if ch == 'C' {
        level.tiles[y][x] = CameraTile
        level.cameras.push(@types.new_camera(x, y))
      }
    }
  }
  level.total_data = terminal_count * 100
  // Setup power connections: connect power nodes to nearby doors/lasers
  setup_power_connections(level)
  // Setup patrol routes for guards
  setup_patrol_routes(level)
  ignore(guard_id)
  level
}

///|
fn setup_power_connections(level : @types.Level) -> Unit {
  // Each power node connects to all doors and lasers within 5 tiles
  for i in 0..<level.power_nodes.length() {
    let pn = level.power_nodes[i]
    let connections : Array[Int] = []
    for j in 0..<level.doors.length() {
      let d = level.doors[j]
      if @types.manhattan_dist(pn.gx, pn.gy, d.gx, d.gy) <= 5 {
        connections.push(d.power_id)
        d.power_id = pn.node_id
      }
    }
    for j in 0..<level.lasers.length() {
      let l = level.lasers[j]
      if @types.manhattan_dist(pn.gx, pn.gy, l.gx, l.gy) <= 5 {
        connections.push(l.power_id)
        l.power_id = pn.node_id
      }
    }
    for j in 0..<level.cameras.length() {
      let c = level.cameras[j]
      if @types.manhattan_dist(pn.gx, pn.gy, c.gx, c.gy) <= 5 {
        connections.push(j + 1000) // Camera IDs offset by 1000
      }
    }
    pn.connected_ids = connections
  }
}

///|
fn setup_patrol_routes(level : @types.Level) -> Unit {
  // For patrol guards, create simple patrol routes along walkable tiles
  for i in 0..<level.guards.length() {
    let g = level.guards[i]
    if g.kind is Patrol && g.patrol_points.length() <= 1 {
      let route : Array[@types.Vec2i] = [{ x: g.gx, y: g.gy, }]
      // Try to extend patrol in current row
      let mut cx = g.gx + 1
      while cx < @types.grid_width &&
            @types.tile_walkable(level.tiles[g.gy][cx]) &&
            route.length() < 5 {
        match level.tiles[g.gy][cx] {
          Wall | Door | LaserGrid => break
          _ => {
            route.push({ x: cx, y: g.gy, })
            cx += 1
          }
        }
      }
      if route.length() < 3 {
        // Try vertical
        let mut cy = g.gy + 1
        while cy < @types.grid_height &&
              @types.tile_walkable(level.tiles[cy][g.gx]) &&
              route.length() < 5 {
          match level.tiles[cy][g.gx] {
            Wall | Door | LaserGrid => break
            _ => {
              route.push({ x: g.gx, y: cy, })
              cy += 1
            }
          }
        }
      }
      g.patrol_points = route
    }
  }
}
