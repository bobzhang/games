///|
fn alpha_color(r : Int, g : Int, b : Int, a : Int) -> @raylib.Color {
  @raylib.Color::new(r, g, b, a)
}

///|
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@types.color_bg)
  match game.screen {
    Title => draw_title(game)
    LevelSelect => draw_level_select(game)
    Playing => draw_playing(game)
    Simulating => draw_playing(game)
    LevelComplete => {
      draw_playing(game)
      draw_level_complete_overlay(game)
    }
    LevelFailed => {
      draw_playing(game)
      draw_level_failed_overlay(game)
    }
  }
  // Draw message
  if game.message_timer > 0.0 {
    let alpha = @types.mini((game.message_timer * 255.0 * 2.0).to_int(), 255)
    let tw = @draw.measure_text(game.message, 24)
    @draw.draw_text(
      game.message,
      (@types.screen_width - tw) / 2,
      @types.screen_height - 60,
      24,
      alpha_color(255, 255, 200, alpha),
    )
  }
  @fps.draw()
  @raylib.end_drawing()
}

///|
fn draw_title(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time = Float::from_int(game.frame_count) * 0.03
  // Animated circuit-like background
  for i in 0..<40 {
    let fi = Float::from_int(i)
    let x1 = ((fi * 97.3 + time * 15.0) % Float::from_int(w)).to_int()
    let y1 = ((fi * 63.7 + time * 8.0) % Float::from_int(h)).to_int()
    let x2 = x1 + 20 + (fi * 13.0 % 40.0).to_int()
    let y2 = y1
    let b1 : Float = fi * 3.0 % 60.0
    let brightness = (b1 + 40.0).to_int()
    @raylib.draw_line_ex(
      @raylib.Vector2::new(Float::from_int(x1), Float::from_int(y1)),
      @raylib.Vector2::new(Float::from_int(x2), Float::from_int(y2)),
      1.0,
      alpha_color(brightness, brightness + 20, brightness + 40, 80),
    )
  }
  // Lightning bolt icon
  let bolt_x = w / 2
  let bolt_y = h / 4 - 30
  draw_lightning_bolt(bolt_x, bolt_y, 40.0, @types.color_title)
  // Title
  let title = "VOLTAGE"
  let title_w = @draw.measure_text(title, 72)
  let pulse = @types.sinf(time * 2.0) * 0.15 + 0.85
  let alpha = (pulse * 255.0).to_int()
  @draw.draw_text(
    title,
    (w - title_w) / 2,
    h / 4 + 20,
    72,
    alpha_color(255, 220, 80, alpha),
  )
  // Subtitle
  let sub = "Circuit Puzzle"
  let sub_w = @draw.measure_text(sub, 28)
  @draw.draw_text(
    sub,
    (w - sub_w) / 2,
    h / 4 + 100,
    28,
    alpha_color(150, 170, 220, 200),
  )
  // Instructions
  let instr = "Press ENTER to start"
  let iw = @draw.measure_text(instr, 24)
  let blink = @types.sinf(time * 3.0)
  if blink > 0.0 {
    @draw.draw_text(instr, (w - iw) / 2, h * 3 / 4, 24, @types.color_hud_text)
  }
  // Version
  @draw.draw_text(
    "25 Levels / 3 Tiers",
    20,
    h - 30,
    16,
    alpha_color(100, 110, 140, 200),
  )
}

///|
fn draw_lightning_bolt(
  cx : Int,
  cy : Int,
  size : Float,
  color : @raylib.Color,
) -> Unit {
  let x = Float::from_int(cx)
  let y = Float::from_int(cy)
  let s = size * 0.5
  @raylib.draw_triangle(
    @raylib.Vector2::new(x - s * 0.3, y - s),
    @raylib.Vector2::new(x + s * 0.5, y - s),
    @raylib.Vector2::new(x - s * 0.1, y),
    color,
  )
  @raylib.draw_triangle(
    @raylib.Vector2::new(x + s * 0.1, y - s * 0.2),
    @raylib.Vector2::new(x + s * 0.3, y - s * 0.2),
    @raylib.Vector2::new(x - s * 0.2, y + s),
    color,
  )
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  // Header
  let title = "SELECT LEVEL"
  let tw = @draw.measure_text(title, 40)
  @draw.draw_text(title, (w - tw) / 2, 30, 40, @types.color_title)
  // Draw tier headers and level buttons
  let cols = 5
  let btn_w = 180
  let btn_h = 60
  let pad = 15
  let start_x = (w - cols * (btn_w + pad)) / 2
  let mut current_tier = ""
  let mut tier_y = 90
  for i in 0..<@types.total_levels {
    let tier_name = @levels.get_tier_name(i)
    if tier_name != current_tier {
      current_tier = tier_name
      let tier_label = match @levels.get_tier(i) {
        Basics => "TIER 1: BASICS"
        Parallel => "TIER 2: PARALLEL"
        Networks => "TIER 3: NETWORKS"
      }
      @draw.draw_text(
        tier_label,
        start_x,
        tier_y,
        22,
        alpha_color(180, 190, 220, 255),
      )
      tier_y += 30
    }
    let tier_offset = if i < @types.tier1_count {
      i
    } else if i < @types.tier1_count + @types.tier2_count {
      i - @types.tier1_count
    } else {
      i - @types.tier1_count - @types.tier2_count
    }
    let col = tier_offset % cols
    let row = tier_offset / cols
    let bx = start_x + col * (btn_w + pad)
    let by = tier_y + row * (btn_h + pad)
    let accessible = i == 0 || game.level_results[i - 1].completed
    let result = game.level_results[i]
    let bg_color = if i == game.current_level {
      @types.color_button_hover
    } else if accessible {
      @types.color_button
    } else {
      alpha_color(30, 30, 50, 200)
    }
    @raylib.draw_rectangle(bx, by, btn_w, btn_h, bg_color)
    @raylib.draw_rectangle_lines(bx, by, btn_w, btn_h, @types.color_grid_line)
    let def = @levels.get_level(i)
    let num_str = (i + 1).to_string()
    let name_color = if accessible {
      @types.color_hud_text
    } else {
      alpha_color(80, 80, 100, 200)
    }
    @draw.draw_text(num_str, bx + 8, by + 5, 20, name_color)
    @draw.draw_text(def.name, bx + 8, by + 28, 14, name_color)
    if result.completed {
      for s in 0..<3 {
        let star_color = if s < result.stars {
          @types.color_star_filled
        } else {
          @types.color_star_empty
        }
        let sx = bx + btn_w - 55 + s * 18
        draw_star(sx, by + 8, 6.0, star_color)
      }
    }
    if i == @types.tier1_count - 1 ||
      i == @types.tier1_count + @types.tier2_count - 1 {
      let items_in_tier = if i < @types.tier1_count {
        @types.tier1_count
      } else {
        @types.tier2_count
      }
      let rows_in_tier = (items_in_tier + cols - 1) / cols
      tier_y = tier_y + rows_in_tier * (btn_h + pad) + 20
    }
  }
  @draw.draw_text(
    "Arrow keys: select  |  ENTER: play  |  ESC: back",
    20,
    @types.screen_height - 30,
    16,
    alpha_color(120, 130, 160, 200),
  )
}

///|
fn draw_star(cx : Int, cy : Int, radius : Float, color : @raylib.Color) -> Unit {
  let x = Float::from_int(cx)
  let y = Float::from_int(cy)
  let r = radius
  let ir = radius * 0.4
  for i in 0..<5 {
    let fi = Float::from_int(i)
    let a1 = fi * 1.2566 - 1.5708
    let a2 = a1 + 0.6283
    let a3 = a1 + 1.2566
    let x1 = x + @types.cosf(a1) * r
    let y1 = y + @types.sinf(a1) * r
    let x2 = x + @types.cosf(a2) * ir
    let y2 = y + @types.sinf(a2) * ir
    let x3 = x + @types.cosf(a3) * r
    let y3 = y + @types.sinf(a3) * r
    @raylib.draw_triangle(
      @raylib.Vector2::new(x, y),
      @raylib.Vector2::new(x1, y1),
      @raylib.Vector2::new(x2, y2),
      color,
    )
    @raylib.draw_triangle(
      @raylib.Vector2::new(x, y),
      @raylib.Vector2::new(x2, y2),
      @raylib.Vector2::new(x3, y3),
      color,
    )
  }
}

///|
fn draw_playing(game : @types.Game) -> Unit {
  match game.level_state {
    None => ()
    Some(state) => {
      draw_grid(game)
      draw_connections(state, game)
      draw_components(state, game)
      draw_sparks(game)
      draw_cursor(game)
      draw_hud(game, state)
      if game.show_help {
        draw_help_overlay()
      }
    }
  }
}

///|
fn draw_grid(game : @types.Game) -> Unit {
  let _ = game
  for r in 0..<=@types.grid_rows {
    for c in 0..<=@types.grid_cols {
      let x = @types.grid_offset_x + c * @types.cell_size
      let y = @types.grid_offset_y + r * @types.cell_size
      if c < @types.grid_cols && r < @types.grid_rows {
        @raylib.draw_rectangle(
          x, y, @types.cell_size, @types.cell_size, @types.color_grid_cell,
        )
      }
    }
  }
  // Grid lines
  for c in 0..<=@types.grid_cols {
    let x = Float::from_int(@types.grid_offset_x + c * @types.cell_size)
    let y0 = Float::from_int(@types.grid_offset_y)
    let y1 = Float::from_int(
      @types.grid_offset_y + @types.grid_rows * @types.cell_size,
    )
    @raylib.draw_line_ex(
      @raylib.Vector2::new(x, y0),
      @raylib.Vector2::new(x, y1),
      1.0,
      @types.color_grid_line,
    )
  }
  for r in 0..<=@types.grid_rows {
    let y = Float::from_int(@types.grid_offset_y + r * @types.cell_size)
    let x0 = Float::from_int(@types.grid_offset_x)
    let x1 = Float::from_int(
      @types.grid_offset_x + @types.grid_cols * @types.cell_size,
    )
    @raylib.draw_line_ex(
      @raylib.Vector2::new(x0, y),
      @raylib.Vector2::new(x1, y),
      1.0,
      @types.color_grid_line,
    )
  }
}

///|
fn draw_components(state : @types.LevelState, game : @types.Game) -> Unit {
  let time = Float::from_int(game.frame_count) * 0.05
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      let cell = state.cells[r][c]
      let cx = @types.cell_center_x(c)
      let cy = @types.cell_center_y(r)
      let icx = cx.to_int()
      let icy = cy.to_int()
      match cell.component {
        Empty => ()
        Battery => {
          let color = if cell.fixed {
            @raylib.Color::new(60, 180, 60, 255)
          } else {
            @types.color_battery
          }
          @raylib.draw_rectangle(icx - 16, icy - 10, 32, 20, color)
          @raylib.draw_rectangle(icx + 14, icy - 5, 6, 10, color)
          @draw.draw_text("+", icx - 12, icy - 10, 16, @raylib.white)
          @draw.draw_text("-", icx + 2, icy - 10, 16, @raylib.white)
          @draw.draw_text("1.5V", icx - 14, icy + 12, 10, color)
        }
        Device(target) => {
          let satisfied = state.simulated &&
            @types.absf(cell.voltage - target) <= @types.voltage_tolerance
          let color = if satisfied {
            @types.color_satisfied
          } else if state.simulated {
            @types.color_unsatisfied
          } else {
            @types.color_device
          }
          let pulse : Float = if satisfied {
            1.0 + @types.sinf(time * 3.0) * 0.1
          } else {
            1.0
          }
          let radius = @types.component_radius * pulse
          @raylib.draw_circle(icx, icy, radius, color)
          @raylib.draw_circle(icx, icy, radius - 4.0, @types.color_grid_cell)
          let v_str = format_voltage(target)
          let vw = @draw.measure_text(v_str, 14)
          @draw.draw_text(v_str, icx - vw / 2, icy - 7, 14, color)
          if state.simulated && cell.voltage > 0.0 {
            let actual = format_voltage(cell.voltage)
            let aw = @draw.measure_text(actual, 10)
            let act_color = if satisfied {
              @types.color_satisfied
            } else {
              @types.color_unsatisfied
            }
            @draw.draw_text(actual, icx - aw / 2, icy + 16, 10, act_color)
          }
        }
        Wire => {
          let color = if cell.powered && state.simulated {
            @types.color_wire_powered
          } else {
            @types.color_wire
          }
          @raylib.draw_circle(icx, icy, 5.0, color)
          if cell.powered && state.simulated {
            @raylib.draw_circle(
              icx,
              icy,
              8.0,
              alpha_color(
                color.r.to_int(),
                color.g.to_int(),
                color.b.to_int(),
                60,
              ),
            )
          }
        }
        Fuse(rating) => {
          let blown = rating == 0.0
          let color = if blown {
            @types.color_fuse_blown
          } else {
            @types.color_fuse
          }
          @raylib.draw_rectangle(icx - 14, icy - 8, 28, 16, color)
          @raylib.draw_rectangle_lines(icx - 14, icy - 8, 28, 16, @raylib.white)
          if blown {
            @draw.draw_text("X", icx - 5, icy - 8, 16, @raylib.red)
          } else {
            let r_str = format_voltage(rating) + "A"
            let rw = @draw.measure_text(r_str, 10)
            @draw.draw_text(r_str, icx - rw / 2, icy - 5, 10, @raylib.white)
          }
        }
        Switch(on) => {
          let color = if on {
            @types.color_switch_on
          } else {
            @types.color_switch_off
          }
          @raylib.draw_rectangle(icx - 12, icy - 12, 24, 24, color)
          @raylib.draw_rectangle_lines(
            icx - 12,
            icy - 12,
            24,
            24,
            @raylib.white,
          )
          let label = if on { "ON" } else { "OFF" }
          let lw = @draw.measure_text(label, 10)
          @draw.draw_text(label, icx - lw / 2, icy - 5, 10, @raylib.white)
          if on {
            @raylib.draw_circle(icx + 6, icy - 14, 4.0, @types.color_switch_on)
          } else {
            @raylib.draw_circle(icx - 6, icy - 14, 4.0, @types.color_switch_off)
          }
        }
      }
      // Fixed indicator
      if cell.fixed && cell.component != Empty {
        @raylib.draw_rectangle(
          icx - 20,
          icy + 20,
          8,
          3,
          alpha_color(200, 200, 200, 100),
        )
      }
    }
  }
}

///|
fn draw_connections(state : @types.LevelState, game : @types.Game) -> Unit {
  let time = Float::from_int(game.frame_count) * 0.08
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      let cell = state.cells[r][c]
      let cx = @types.cell_center_x(c)
      let cy = @types.cell_center_y(r)
      // Right connection
      if cell.connections[3] && c + 1 < @types.grid_cols {
        let nx = @types.cell_center_x(c + 1)
        let color = wire_color(cell.powered && state.simulated, time, c, r)
        @raylib.draw_line_ex(
          @raylib.Vector2::new(cx, cy),
          @raylib.Vector2::new(nx, cy),
          @types.wire_thickness,
          color,
        )
      }
      // Down connection
      if cell.connections[1] && r + 1 < @types.grid_rows {
        let ny = @types.cell_center_y(r + 1)
        let color = wire_color(cell.powered && state.simulated, time, c, r)
        @raylib.draw_line_ex(
          @raylib.Vector2::new(cx, cy),
          @raylib.Vector2::new(cx, ny),
          @types.wire_thickness,
          color,
        )
      }
    }
  }
}

///|
fn wire_color(powered : Bool, time : Float, c : Int, r : Int) -> @raylib.Color {
  if powered {
    let pulse = @types.sinf(time + Float::from_int(c + r) * 0.5) * 0.3 + 0.7
    let rr = (Float::from_int(@types.color_wire_powered.r.to_int()) * pulse).to_int()
    let gg = (Float::from_int(@types.color_wire_powered.g.to_int()) * pulse).to_int()
    let bb = (Float::from_int(@types.color_wire_powered.b.to_int()) * pulse).to_int()
    @raylib.Color::new(rr, gg, bb, 255)
  } else {
    @types.color_wire
  }
}

///|
fn draw_sparks(game : @types.Game) -> Unit {
  for i in 0..<game.sparks.length() {
    let s = game.sparks[i]
    if s.active {
      let alpha = (s.life / @types.spark_lifetime * 255.0).to_int()
      let a = @types.clampi(alpha, 0, 255)
      @raylib.draw_circle(
        s.x.to_int(),
        s.y.to_int(),
        2.0 + s.life * 3.0,
        alpha_color(
          s.color.r.to_int(),
          s.color.g.to_int(),
          s.color.b.to_int(),
          a,
        ),
      )
    }
  }
}

///|
fn draw_cursor(game : @types.Game) -> Unit {
  match game.screen {
    Playing => {
      let x = @types.grid_offset_x + game.cursor_col * @types.cell_size
      let y = @types.grid_offset_y + game.cursor_row * @types.cell_size
      let pulse : Float = @types.sinf(Float::from_int(game.frame_count) * 0.1)
      let pv : Float = pulse * 60.0
      let alpha = (pv + 160.0).to_int()
      @raylib.draw_rectangle_lines_ex(
        @raylib.Rectangle::new(
          Float::from_int(x) + 1.0,
          Float::from_int(y) + 1.0,
          Float::from_int(@types.cell_size) - 2.0,
          Float::from_int(@types.cell_size) - 2.0,
        ),
        2.0,
        alpha_color(255, 255, 100, alpha),
      )
      let tool_label = match game.tool {
        PlaceBattery => "BAT"
        PlaceWire => "WIRE"
        PlaceFuse => "FUSE"
        PlaceSwitch => "SW"
        Erase => "DEL"
        ToggleSwitch => "TOG"
      }
      let tool_color = match game.tool {
        PlaceBattery => @types.color_battery
        PlaceWire => @types.color_wire
        PlaceFuse => @types.color_fuse
        PlaceSwitch => @types.color_switch_on
        Erase => @raylib.red
        ToggleSwitch => @types.color_switch_on
      }
      @draw.draw_text(tool_label, x + 2, y - 14, 12, tool_color)
    }
    _ => ()
  }
}

///|
fn draw_hud(game : @types.Game, state : @types.LevelState) -> Unit {
  let panel_x = @types.grid_offset_x + @types.grid_cols * @types.cell_size + 20
  let panel_w = @types.screen_width - panel_x - 20
  let panel_y = @types.grid_offset_y
  let panel_h = @types.grid_rows * @types.cell_size
  @raylib.draw_rectangle(panel_x, panel_y, panel_w, panel_h, @types.color_panel)
  @raylib.draw_rectangle_lines(
    panel_x, panel_y, panel_w, panel_h, @types.color_grid_line,
  )
  let x = panel_x + 12
  let mut y = panel_y + 10
  let def = @levels.get_level(game.current_level)
  @draw.draw_text(
    "Level " + (game.current_level + 1).to_string(),
    x,
    y,
    22,
    @types.color_title,
  )
  y += 28
  @draw.draw_text(def.name, x, y, 18, @types.color_hud_text)
  y += 24
  @draw.draw_text(def.description, x, y, 12, alpha_color(150, 160, 190, 220))
  y += 30
  @raylib.draw_line_ex(
    @raylib.Vector2::new(Float::from_int(x), Float::from_int(y)),
    @raylib.Vector2::new(
      Float::from_int(panel_x + panel_w - 12),
      Float::from_int(y),
    ),
    1.0,
    @types.color_grid_line,
  )
  y += 10
  // Budget
  @draw.draw_text("BUDGET", x, y, 14, @types.color_title)
  y += 20
  let bat_str = "Batteries: " +
    state.batteries_used.to_string() +
    "/" +
    state.battery_budget.to_string()
  let bat_color = if state.batteries_used > state.battery_budget {
    @types.color_unsatisfied
  } else {
    @types.color_hud_text
  }
  @draw.draw_text(bat_str, x, y, 14, bat_color)
  y += 18
  @draw.draw_text(
    "Par: " + state.par_batteries.to_string(),
    x,
    y,
    12,
    alpha_color(150, 160, 190, 200),
  )
  y += 20
  if state.fuse_budget > 0 {
    let fuse_str = "Fuses: " +
      state.fuses_used.to_string() +
      "/" +
      state.fuse_budget.to_string()
    @draw.draw_text(fuse_str, x, y, 14, @types.color_fuse)
    y += 18
  }
  if state.switch_budget > 0 {
    let sw_str = "Switches: " +
      state.switches_used.to_string() +
      "/" +
      state.switch_budget.to_string()
    @draw.draw_text(sw_str, x, y, 14, @types.color_switch_on)
    y += 18
  }
  y += 10
  // Devices status
  @draw.draw_text("DEVICES", x, y, 14, @types.color_title)
  y += 20
  if state.simulated {
    let dev_str = state.devices_satisfied.to_string() +
      "/" +
      state.devices_total.to_string() +
      " powered"
    let dev_color = if state.devices_satisfied == state.devices_total {
      @types.color_satisfied
    } else {
      @types.color_unsatisfied
    }
    @draw.draw_text(dev_str, x, y, 14, dev_color)
  } else {
    @draw.draw_text(
      state.devices_total.to_string() + " need power",
      x,
      y,
      14,
      @types.color_device,
    )
  }
  y += 30
  // Tool selection
  @draw.draw_text("TOOLS", x, y, 14, @types.color_title)
  y += 20
  let tools : Array[(@types.ToolMode, String, String)] = [
    (PlaceBattery, "1", "Battery"),
    (PlaceWire, "2", "Wire"),
    (PlaceFuse, "3", "Fuse"),
    (PlaceSwitch, "4", "Switch"),
    (Erase, "5", "Erase"),
    (ToggleSwitch, "6", "Toggle"),
  ]
  for i in 0..<tools.length() {
    let (mode, key, name) = tools[i]
    let active = game.tool == mode
    let color = if active { @types.color_title } else { @types.color_hud_text }
    let prefix = if active { "> " } else { "  " }
    @draw.draw_text(prefix + "[" + key + "] " + name, x, y, 13, color)
    y += 16
  }
  y += 15
  // Controls
  @draw.draw_text("CONTROLS", x, y, 14, @types.color_title)
  y += 18
  let controls = [
    "Arrows: move", "SPACE: place/use", "R: reset level", "S: simulate", "H: help",
    "ESC: back",
  ]
  for i in 0..<controls.length() {
    @draw.draw_text(controls[i], x, y, 11, alpha_color(140, 150, 180, 200))
    y += 14
  }
  // Level title bar at top
  @raylib.draw_rectangle(0, 0, @types.screen_width, 50, @types.color_hud_bg)
  let tier_name = @levels.get_tier_name(game.current_level)
  @draw.draw_text(tier_name + " - " + def.name, 20, 12, 26, @types.color_title)
}

///|
fn draw_level_complete_overlay(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  @raylib.draw_rectangle(0, 0, w, h, alpha_color(0, 0, 0, 180))
  let pw = 400
  let ph = 300
  let px = (w - pw) / 2
  let py = (h - ph) / 2
  @raylib.draw_rectangle(px, py, pw, ph, @types.color_panel)
  @raylib.draw_rectangle_lines(px, py, pw, ph, @types.color_title)
  let title = "LEVEL COMPLETE!"
  let tw = @draw.measure_text(title, 36)
  @draw.draw_text(title, (w - tw) / 2, py + 20, 36, @types.color_satisfied)
  let result = game.level_results[game.current_level]
  let star_y = py + 80
  for i in 0..<3 {
    let color = if i < result.stars {
      @types.color_star_filled
    } else {
      @types.color_star_empty
    }
    draw_star(w / 2 - 50 + i * 50, star_y, 16.0, color)
  }
  let sy = py + 130
  @draw.draw_text(
    "Devices: " +
    result.devices_powered.to_string() +
    "/" +
    result.devices_total.to_string(),
    px + 40,
    sy,
    18,
    @types.color_hud_text,
  )
  @draw.draw_text(
    "Batteries used: " + result.batteries_used.to_string(),
    px + 40,
    sy + 25,
    18,
    @types.color_hud_text,
  )
  let fuse_color = if result.fuses_blown > 0 {
    @types.color_unsatisfied
  } else {
    @types.color_hud_text
  }
  @draw.draw_text(
    "Fuses blown: " + result.fuses_blown.to_string(),
    px + 40,
    sy + 50,
    18,
    fuse_color,
  )
  @draw.draw_text(
    "ENTER: next level  |  ESC: level select",
    px + 30,
    py + ph - 40,
    16,
    alpha_color(150, 160, 190, 200),
  )
}

///|
fn draw_level_failed_overlay(game : @types.Game) -> Unit {
  let _ = game
  let w = @types.screen_width
  let h = @types.screen_height
  @raylib.draw_rectangle(0, 0, w, h, alpha_color(0, 0, 0, 180))
  let pw = 400
  let ph = 200
  let px = (w - pw) / 2
  let py = (h - ph) / 2
  @raylib.draw_rectangle(px, py, pw, ph, @types.color_panel)
  @raylib.draw_rectangle_lines(px, py, pw, ph, @types.color_unsatisfied)
  let title = "NOT ALL DEVICES POWERED"
  let tw = @draw.measure_text(title, 24)
  @draw.draw_text(title, (w - tw) / 2, py + 30, 24, @types.color_unsatisfied)
  @draw.draw_text(
    "Check your circuit connections",
    px + 40,
    py + 80,
    18,
    @types.color_hud_text,
  )
  @draw.draw_text(
    "SPACE: try again  |  ESC: level select",
    px + 40,
    py + ph - 40,
    16,
    alpha_color(150, 160, 190, 200),
  )
}

///|
fn draw_help_overlay() -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  @raylib.draw_rectangle(0, 0, w, h, alpha_color(0, 0, 0, 200))
  let pw = 500
  let ph = 400
  let px = (w - pw) / 2
  let py = (h - ph) / 2
  @raylib.draw_rectangle(px, py, pw, ph, @types.color_panel)
  @raylib.draw_rectangle_lines(px, py, pw, ph, @types.color_title)
  let title = "HOW TO PLAY"
  let tw = @draw.measure_text(title, 30)
  @draw.draw_text(title, (w - tw) / 2, py + 15, 30, @types.color_title)
  let mut yy = py + 55
  let rules = [
    "Wire batteries to power devices!", "", "SERIES: Batteries in a chain ADD voltage",
    "  2 batteries = 3V, 3 = 4.5V, etc.", "", "DEVICES need exact voltage (+-0.1V)",
    "", "FUSES blow if overloaded (2x rated current)", "SWITCHES toggle circuit paths on/off",
    "", "SCORING:", "  1 star: All devices powered", "  2 stars: Par batteries used",
    "  3 stars: Par + no blown fuses", "", "Press H to close",
  ]
  for i in 0..<rules.length() {
    @draw.draw_text(rules[i], px + 25, yy, 14, @types.color_hud_text)
    yy += 20
  }
}

///|
fn format_voltage(v : Float) -> String {
  let whole = v.to_int()
  let frac = ((v - Float::from_int(whole)) * 10.0 + 0.5).to_int()
  if frac == 0 {
    whole.to_string() + "V"
  } else {
    whole.to_string() + "." + frac.to_string() + "V"
  }
}
