///|
let screen_w : Int = 1320

///|
let screen_h : Int = 860

///|
let cols : Int = 4

///|
let rows : Int = 3

///|
let room_w : Int = 220

///|
let room_h : Int = 170

///|
let grid_x : Int = 170

///|
let grid_y : Int = 170

///|
fn room_idx(x : Int, y : Int) -> Int {
  y * cols + x
}

///|
fn hdoor_idx(x : Int, y : Int) -> Int {
  y * (cols - 1) + x
}

///|
fn vdoor_idx(x : Int, y : Int) -> Int {
  y * cols + x
}

///|
fn inside_rect(px : Float, py : Float, rx : Int, ry : Int, rw : Int, rh : Int) -> Bool {
  px >= Float::from_int(rx) &&
  px <= Float::from_int(rx + rw) &&
  py >= Float::from_int(ry) &&
  py <= Float::from_int(ry + rh)
}

///|
struct Room {
  mut label : String
  mut contam : Float
  mut oxygen : Float
  mut crew : Float
  mut source : Float
  mut purge_t : Float
  mut boost_t : Float
}

///|
fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn room_rect(x : Int, y : Int) -> (Int, Int, Int, Int) {
  (grid_x + x * room_w, grid_y + y * room_h, room_w - 18, room_h - 18)
}

///|
fn avg_crew(rooms : Array[Room]) -> Float {
  let mut total = 0.0F
  let mut count = 0.0F
  for room in rooms {
    total = total + room.crew
    count = count + 1.0F
  }
  if count <= 0.0F { 0.0F } else { total / count }
}

///|
fn reset_sector(sector : Int, rooms : Array[Room], hdoors : Array[Bool], vdoors : Array[Bool]) -> Float {
  let labels = ["Bridge", "Med", "Relay", "Cargo", "Cryo", "Forge", "Vent", "Lab", "Dock", "Core", "Hab", "Bay"]
  for y in 0..<rows {
    for x in 0..<cols {
      let i = room_idx(x, y)
      rooms[i].label = labels[i]
      rooms[i].contam = 4.0F + Float::from_int((x + y * 2) % 3) * 2.0F
      rooms[i].oxygen = 78.0F + Float::from_int((x * 3 + y) % 5) * 3.0F
      rooms[i].crew = 88.0F
      rooms[i].source = 0.0F
      rooms[i].purge_t = 0.0F
      rooms[i].boost_t = 0.0F
    }
  }
  for i in 0..<hdoors.length() {
    hdoors[i] = true
  }
  for i in 0..<vdoors.length() {
    vdoors[i] = true
  }

  if sector == 1 {
    rooms[room_idx(3, 0)].source = 7.0F
    rooms[room_idx(2, 1)].source = 4.0F
    vdoors[vdoor_idx(1, 0)] = false
    70.0F
  } else if sector == 2 {
    rooms[room_idx(3, 0)].source = 8.0F
    rooms[room_idx(2, 1)].source = 7.0F
    rooms[room_idx(0, 2)].source = 5.0F
    hdoors[hdoor_idx(0, 1)] = false
    vdoors[vdoor_idx(2, 1)] = false
    80.0F
  } else {
    rooms[room_idx(3, 0)].source = 10.0F
    rooms[room_idx(2, 1)].source = 8.0F
    rooms[room_idx(0, 2)].source = 7.0F
    rooms[room_idx(1, 0)].source = 6.0F
    hdoors[hdoor_idx(1, 0)] = false
    hdoors[hdoor_idx(1, 1)] = false
    vdoors[vdoor_idx(1, 0)] = false
    90.0F
  }
}

///|
fn room_from_mouse(mx : Float, my : Float) -> Int {
  for y in 0..<rows {
    for x in 0..<cols {
      let rect = room_rect(x, y)
      if inside_rect(mx, my, rect.0, rect.1, rect.2, rect.3) {
        return room_idx(x, y)
      }
    }
  }
  -1
}

///|
fn toggle_door_from_mouse(mx : Float, my : Float, hdoors : Array[Bool], vdoors : Array[Bool]) -> Bool {
  for y in 0..<rows {
    for x in 0..<(cols - 1) {
      let dx = grid_x + x * room_w + room_w - 18
      let dy = grid_y + y * room_h + 44
      if inside_rect(mx, my, dx, dy, 18, 70) {
        let i = hdoor_idx(x, y)
        hdoors[i] = !hdoors[i]
        return true
      }
    }
  }
  for y in 0..<(rows - 1) {
    for x in 0..<cols {
      let dx = grid_x + x * room_w + 68
      let dy = grid_y + y * room_h + room_h - 18
      if inside_rect(mx, my, dx, dy, 70, 18) {
        let i = vdoor_idx(x, y)
        vdoors[i] = !vdoors[i]
        return true
      }
    }
  }
  false
}

///|
fn spread_pair(a : Room, b : Room, dt : Float, open : Bool) -> Unit {
  if !open {
    return
  }
  let flow = (a.contam - b.contam) * 0.16F * dt
  a.contam = a.contam - flow
  b.contam = b.contam + flow
  let oxy_flow = (a.oxygen - b.oxygen) * 0.10F * dt
  a.oxygen = a.oxygen - oxy_flow
  b.oxygen = b.oxygen + oxy_flow
}

///|
fn update_systems(
  rooms : Array[Room],
  hdoors : Array[Bool],
  vdoors : Array[Bool],
  dt : Float,
  sector : Int,
  power : Float,
  integrity : Float,
) -> (Float, Float) {
  let mut next_power = power + dt * 10.0F
  if next_power > 100.0F {
    next_power = 100.0F
  }
  let mut next_integrity = integrity

  for room in rooms {
    room.contam = room.contam + room.source * dt * (0.42F + Float::from_int(sector) * 0.08F)
    room.oxygen = room.oxygen + dt * 1.8F

    if room.purge_t > 0.0F {
      room.purge_t = room.purge_t - dt
      room.contam = room.contam - dt * 17.0F
      room.oxygen = room.oxygen - dt * 7.0F
      next_power = next_power - dt * 5.5F
    }
    if room.boost_t > 0.0F {
      room.boost_t = room.boost_t - dt
      room.contam = room.contam - dt * 4.0F
      room.oxygen = room.oxygen + dt * 7.0F
      next_power = next_power - dt * 4.0F
    }

    room.contam = clampf(room.contam, 0.0F, 100.0F)
    room.oxygen = clampf(room.oxygen, 0.0F, 100.0F)
  }

  for y in 0..<rows {
    for x in 0..<(cols - 1) {
      spread_pair(rooms[room_idx(x, y)], rooms[room_idx(x + 1, y)], dt, hdoors[hdoor_idx(x, y)])
    }
  }
  for y in 0..<(rows - 1) {
    for x in 0..<cols {
      spread_pair(rooms[room_idx(x, y)], rooms[room_idx(x, y + 1)], dt, vdoors[vdoor_idx(x, y)])
    }
  }

  for room in rooms {
    let contam_hit = if room.contam > 58.0F { (room.contam - 58.0F) * 0.05F * dt } else { 0.0F }
    let oxy_hit = if room.oxygen < 38.0F { (38.0F - room.oxygen) * 0.07F * dt } else { 0.0F }
    room.crew = clampf(room.crew - contam_hit - oxy_hit, 0.0F, 100.0F)
    if room.contam > 80.0F {
      next_integrity = next_integrity - (room.contam - 80.0F) * 0.035F * dt
    }
  }

  (clampf(next_power, 0.0F, 100.0F), clampf(next_integrity, 0.0F, 100.0F))
}

///|
fn draw_bar(x : Int, y : Int, w : Int, value : Float, col : @raylib.Color) -> Unit {
  @raylib.draw_rectangle(x, y, w, 10, @raylib.Color::new(20, 26, 36, 255))
  @raylib.draw_rectangle(x, y, (Float::from_int(w) * clampf(value, 0.0F, 100.0F) / 100.0F).to_int(), 10, col)
}

///|
fn restore_crew(rooms : Array[Room], crew_vals : Array[Float]) -> Unit {
  for i in 0..<rooms.length() {
    rooms[i].crew = crew_vals[i]
  }
}

///|
fn main {
  @raylib.init_window(screen_w, screen_h, "Orbital Quarantine 2026")
  @raylib.set_target_fps(60)

  let rooms : Array[Room] = Array::makei(cols * rows, fn(_i) {
    { label: "", contam: 0.0F, oxygen: 100.0F, crew: 100.0F, source: 0.0F, purge_t: 0.0F, boost_t: 0.0F }
  })
  let hdoors : Array[Bool] = Array::make((cols - 1) * rows, true)
  let vdoors : Array[Bool] = Array::make(cols * (rows - 1), true)

  let mut title = true
  let mut sector = 1
  let mut timer = reset_sector(sector, rooms, hdoors, vdoors)
  let mut power : Float = 100.0F
  let mut integrity : Float = 100.0F
  let mut paused = true
  let mut over = false
  let mut won = false
  let mut msg = "Seal doors, purge rooms, and keep the crew alive."

  while !@raylib.window_should_close() {
    let frame_dt = @raylib.get_frame_time()
    let dt = if frame_dt > 0.05F { 0.05F } else { frame_dt }
    let mouse = @raylib.get_mouse_position()

    if title {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        title = false
        sector = 1
        timer = reset_sector(sector, rooms, hdoors, vdoors)
        power = 100.0F
        integrity = 100.0F
        paused = true
        over = false
        won = false
        msg = "Sector 1 online. Press Space to start time."
      }
    } else if over {
      if @raylib.is_key_pressed(@raylib.KeyR) {
        title = false
        sector = 1
        timer = reset_sector(sector, rooms, hdoors, vdoors)
        power = 100.0F
        integrity = 100.0F
        paused = true
        over = false
        won = false
        msg = "Sector 1 online. Press Space to start time."
      }
    } else {
      if @raylib.is_key_pressed(@raylib.KeySpace) {
        paused = !paused
        msg = if paused { "Simulation paused." } else { "Simulation live." }
      }
      if @raylib.is_key_pressed(@raylib.KeyR) {
        sector = 1
        timer = reset_sector(sector, rooms, hdoors, vdoors)
        power = 100.0F
        integrity = 100.0F
        paused = true
        msg = "Station reset."
      }

      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        if toggle_door_from_mouse(mouse.x, mouse.y, hdoors, vdoors) {
          msg = "Door state toggled."
        } else {
          let room_i = room_from_mouse(mouse.x, mouse.y)
          if room_i >= 0 && power >= 18.0F {
            rooms[room_i].purge_t = 4.5F
            power = power - 18.0F
            msg = "Purge pulse armed in \{rooms[room_i].label}."
          }
        }
      }
      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
        let room_i = room_from_mouse(mouse.x, mouse.y)
        if room_i >= 0 && power >= 14.0F {
          rooms[room_i].boost_t = 6.0F
          power = power - 14.0F
          msg = "Oxygen boost routed to \{rooms[room_i].label}."
        }
      }

      if !paused {
        let next = update_systems(rooms, hdoors, vdoors, dt, sector, power, integrity)
        power = next.0
        integrity = next.1
        timer = timer - dt

        if integrity <= 0.0F || avg_crew(rooms) <= 0.0F {
          over = true
          won = false
          msg = "Containment failure."
        } else if timer <= 0.0F {
          if sector < 3 {
            let carry_crew = Array::makei(rooms.length(), fn(i) { rooms[i].crew })
            sector = sector + 1
            timer = reset_sector(sector, rooms, hdoors, vdoors)
            restore_crew(rooms, carry_crew)
            power = clampf(power + 18.0F, 0.0F, 100.0F)
            integrity = clampf(integrity + 10.0F, 0.0F, 100.0F)
            paused = true
            msg = "Sector \{sector} breach map loaded."
          } else {
            over = true
            won = true
            msg = "Station stabilized through all quarantine sectors."
          }
        }
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(8, 12, 20, 255))

    if title {
      @raylib.draw_rectangle_gradient_v(0, 0, screen_w, screen_h, @raylib.Color::new(12, 20, 34, 255), @raylib.Color::new(4, 8, 14, 255))
      @raylib.draw_text("ORBITAL QUARANTINE 2026", 230, 150, 58, @raylib.Color::new(236, 246, 255, 255))
      @raylib.draw_text("Seal compartments. Spend power. Keep oxygen and crew online.", 250, 246, 30, @raylib.Color::new(143, 206, 255, 255))
      @raylib.draw_text("Left click room: Purge contamination", 350, 390, 28, @raylib.Color::new(255, 214, 118, 255))
      @raylib.draw_text("Right click room: Oxygen boost", 350, 430, 28, @raylib.Color::new(255, 214, 118, 255))
      @raylib.draw_text("Click door links: Seal or open", 350, 470, 28, @raylib.Color::new(255, 214, 118, 255))
      @raylib.draw_text("Space: Pause / resume", 350, 510, 28, @raylib.Color::new(255, 214, 118, 255))
      @raylib.draw_rectangle(420, 630, 440, 82, @raylib.Color::new(44, 90, 124, 255))
      @raylib.draw_text("PRESS ENTER TO START", 474, 658, 30, @raylib.Color::new(244, 249, 255, 255))
    } else {
      @raylib.draw_rectangle(80, 60, 1160, 92, @raylib.Color::new(14, 22, 34, 255))
      @raylib.draw_text("Sector \{sector}/3", 104, 86, 32, @raylib.Color::new(237, 242, 248, 255))
      @raylib.draw_text(if paused { "PAUSED" } else { "LIVE" }, 290, 86, 32, if paused { @raylib.Color::new(255, 211, 112, 255) } else { @raylib.Color::new(140, 236, 182, 255) })
      @raylib.draw_text("Time \{timer.to_int()}s", 420, 86, 30, @raylib.Color::new(199, 216, 232, 255))
      @raylib.draw_text("Power", 620, 72, 22, @raylib.Color::new(215, 226, 236, 255))
      draw_bar(620, 100, 160, power, @raylib.Color::new(255, 204, 104, 255))
      @raylib.draw_text("Integrity", 830, 72, 22, @raylib.Color::new(215, 226, 236, 255))
      draw_bar(830, 100, 160, integrity, @raylib.Color::new(114, 219, 255, 255))
      @raylib.draw_text("Crew", 1040, 72, 22, @raylib.Color::new(215, 226, 236, 255))
      draw_bar(1040, 100, 150, avg_crew(rooms), @raylib.Color::new(134, 234, 170, 255))

      for y in 0..<rows {
        for x in 0..<cols {
          let i = room_idx(x, y)
          let rect = room_rect(x, y)
          let base_r = (36.0F + rooms[i].contam * 1.8F).to_int().clamp(min=20, max=180)
          let base_g = (74.0F + rooms[i].oxygen * 1.1F).to_int().clamp(min=30, max=185)
          let base_b = if rooms[i].boost_t > 0.0F { 150 } else { 104 }
          @raylib.draw_rectangle(rect.0, rect.1, rect.2, rect.3, @raylib.Color::new(base_r, base_g, base_b, 255))
          @raylib.draw_rectangle_lines(rect.0, rect.1, rect.2, rect.3, @raylib.Color::new(10, 16, 24, 255))
          @raylib.draw_text(rooms[i].label, rect.0 + 14, rect.1 + 14, 24, @raylib.Color::new(244, 247, 252, 255))
          draw_bar(rect.0 + 14, rect.1 + 52, rect.2 - 28, rooms[i].contam, @raylib.Color::new(242, 104, 104, 255))
          draw_bar(rect.0 + 14, rect.1 + 72, rect.2 - 28, rooms[i].oxygen, @raylib.Color::new(116, 214, 255, 255))
          draw_bar(rect.0 + 14, rect.1 + 92, rect.2 - 28, rooms[i].crew, @raylib.Color::new(126, 228, 164, 255))
          @raylib.draw_text("PURGE", rect.0 + 14, rect.1 + rect.3 - 44, 20, if rooms[i].purge_t > 0.0F { @raylib.Color::new(255, 232, 178, 255) } else { @raylib.Color::new(46, 70, 92, 255) })
          @raylib.draw_text("BOOST", rect.0 + 104, rect.1 + rect.3 - 44, 20, if rooms[i].boost_t > 0.0F { @raylib.Color::new(226, 248, 255, 255) } else { @raylib.Color::new(46, 70, 92, 255) })
        }
      }

      for y in 0..<rows {
        for x in 0..<(cols - 1) {
          let dx = grid_x + x * room_w + room_w - 18
          let dy = grid_y + y * room_h + 46
          @raylib.draw_rectangle(dx + 2, dy, 14, 66, if hdoors[hdoor_idx(x, y)] { @raylib.Color::new(120, 220, 158, 255) } else { @raylib.Color::new(230, 92, 92, 255) })
        }
      }
      for y in 0..<(rows - 1) {
        for x in 0..<cols {
          let dx = grid_x + x * room_w + 72
          let dy = grid_y + y * room_h + room_h - 18
          @raylib.draw_rectangle(dx, dy + 2, 66, 14, if vdoors[vdoor_idx(x, y)] { @raylib.Color::new(120, 220, 158, 255) } else { @raylib.Color::new(230, 92, 92, 255) })
        }
      }

      @raylib.draw_rectangle(80, 742, 1160, 78, @raylib.Color::new(14, 22, 34, 255))
      @raylib.draw_text(msg, 102, 770, 28, @raylib.Color::new(235, 242, 248, 255))
      @raylib.draw_text("Left click: purge  |  Right click: boost  |  Space: pause", 642, 772, 22, @raylib.Color::new(255, 214, 118, 255))

      if over {
        @raylib.draw_rectangle(0, 0, screen_w, screen_h, @raylib.fade(@raylib.black, 0.6F))
        @raylib.draw_text(if won { "QUARANTINE HELD" } else { "STATION LOST" }, 360, 250, 62, if won { @raylib.Color::new(142, 242, 188, 255) } else { @raylib.Color::new(255, 120, 120, 255) })
        @raylib.draw_text(msg, 320, 340, 34, @raylib.Color::new(238, 244, 248, 255))
        @raylib.draw_text("Press R to restart", 482, 430, 30, @raylib.Color::new(255, 214, 118, 255))
      }
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
