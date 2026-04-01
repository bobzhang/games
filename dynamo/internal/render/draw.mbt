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
  // Animated field line background
  for i in 0..<30 {
    let fi = Float::from_int(i)
    let x1 = ((fi * 97.3 + time * 12.0) % Float::from_int(w)).to_int()
    let y1 = ((fi * 63.7 + time * 6.0) % Float::from_int(h)).to_int()
    let x2 = x1 + 30 + (fi * 17.0 % 50.0).to_int()
    let y2 = y1
    let b1 : Float = fi * 3.0 % 60.0
    let brightness = (b1 + 30.0).to_int()
    @raylib.draw_line_ex(
      @raylib.Vector2::new(Float::from_int(x1), Float::from_int(y1)),
      @raylib.Vector2::new(Float::from_int(x2), Float::from_int(y2)),
      2.0,
      alpha_color(brightness + 40, brightness, brightness, 60),
    )
  }
  // Magnet icon
  let mx = w / 2
  let my = h / 4 - 30
  draw_magnet_icon(mx, my, 40.0)
  // Title
  let title = "DYNAMO"
  let title_w = @draw.measure_text(title, 72)
  let pulse = @types.sinf(time * 2.0) * 0.15 + 0.85
  let alpha = (pulse * 255.0).to_int()
  @draw.draw_text(
    title,
    (w - title_w) / 2,
    h / 4 + 20,
    72,
    alpha_color(255, 200, 60, alpha),
  )
  // Subtitle
  let sub = "Electromagnetic Generator Puzzle"
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
    "20 Levels / 3 Tiers",
    20,
    h - 30,
    16,
    alpha_color(100, 110, 140, 200),
  )
}

///|
fn draw_magnet_icon(cx : Int, cy : Int, size : Float) -> Unit {
  let x = Float::from_int(cx)
  let y = Float::from_int(cy)
  let s = size * 0.5
  // U-shape magnet
  @raylib.draw_rectangle(
    (x - s).to_int(),
    (y - s).to_int(),
    (s * 0.4).to_int(),
    (s * 2.0).to_int(),
    @types.color_magnet_n,
  )
  @raylib.draw_rectangle(
    (x + s * 0.6).to_int(),
    (y - s).to_int(),
    (s * 0.4).to_int(),
    (s * 2.0).to_int(),
    @types.color_magnet_s,
  )
  @raylib.draw_rectangle(
    (x - s).to_int(),
    (y + s * 0.6).to_int(),
    (s * 2.0).to_int(),
    (s * 0.4).to_int(),
    alpha_color(150, 150, 150, 255),
  )
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let title = "SELECT LEVEL"
  let tw = @draw.measure_text(title, 40)
  @draw.draw_text(title, (w - tw) / 2, 30, 40, @types.color_title)
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
        Foundations => "TIER 1: FOUNDATIONS"
        Generators => "TIER 2: GENERATORS"
        PowerGrid => "TIER 3: POWER GRID"
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
      draw_field_lines(state, game)
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
fn draw_field_lines(state : @types.LevelState, game : @types.Game) -> Unit {
  let time = Float::from_int(game.frame_count) * 0.05
  if !state.simulated {
    return
  }
  for i in 0..<state.field_lines.length() {
    let fl = state.field_lines[i]
    let sx = @types.cell_center_x(fl.start_col)
    let sy = @types.cell_center_y(fl.start_row)
    let ex = @types.cell_center_x(fl.end_col)
    let ey = @types.cell_center_y(fl.end_row)
    let base_alpha = if fl.captured { 160 } else { 80 }
    let pulse = @types.sinf(time * 2.0 + Float::from_int(i) * 0.7) * 30.0
    let alpha = @types.clampi((Float::from_int(base_alpha) + pulse).to_int(), 40, 220)
    let color = if fl.captured {
      alpha_color(255, 120, 60, alpha)
    } else {
      alpha_color(200, 80, 80, alpha)
    }
    @raylib.draw_line_ex(
      @raylib.Vector2::new(sx, sy),
      @raylib.Vector2::new(ex, ey),
      if fl.captured { 3.0 } else { 2.0 },
      color,
    )
    // Draw arrowhead at endpoint
    if fl.captured {
      draw_field_arrow(ex, ey, sx, sy, color)
    }
  }
}

///|
fn draw_field_arrow(
  ex : Float,
  ey : Float,
  sx : Float,
  sy : Float,
  color : @raylib.Color,
) -> Unit {
  let dx = ex - sx
  let dy = ey - sy
  let len = @types.sqrtf(dx * dx + dy * dy)
  if len < 1.0 {
    return
  }
  let nx = dx / len
  let ny = dy / len
  let arrow_size : Float = 8.0
  let ax = ex - nx * arrow_size
  let ay = ey - ny * arrow_size
  let px = -ny * arrow_size * 0.5
  let py = nx * arrow_size * 0.5
  @raylib.draw_triangle(
    @raylib.Vector2::new(ex, ey),
    @raylib.Vector2::new(ax + px, ay + py),
    @raylib.Vector2::new(ax - px, ay - py),
    color,
  )
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
        Magnet(polarity) => {
          let color = match polarity {
            North => @types.color_magnet_n
            South => @types.color_magnet_s
          }
          let fixed_color = if cell.fixed {
            alpha_color(
              color.r.to_int() - 30,
              color.g.to_int(),
              color.b.to_int(),
              255,
            )
          } else {
            color
          }
          // Draw magnet body
          @raylib.draw_rectangle(icx - 16, icy - 14, 32, 28, fixed_color)
          @raylib.draw_rectangle_lines(icx - 16, icy - 14, 32, 28, @raylib.white)
          let label = match polarity {
            North => "N"
            South => "S"
          }
          let lw = @draw.measure_text(label, 20)
          @draw.draw_text(label, icx - lw / 2, icy - 10, 20, @raylib.white)
          // Magnetic field glow
          @raylib.draw_circle(
            icx,
            icy,
            @types.component_radius + 4.0,
            alpha_color(
              color.r.to_int(),
              color.g.to_int(),
              color.b.to_int(),
              30,
            ),
          )
        }
        Coil => {
          let active = cell.powered && state.simulated
          let color = if active {
            @types.color_coil_active
          } else {
            @types.color_coil
          }
          let pulse : Float = if active {
            1.0 + @types.sinf(time * 4.0) * 0.15
          } else {
            1.0
          }
          let base_r : Float = 22.0
          let radius : Float = base_r * pulse
          // Draw coil as concentric circles
          @raylib.draw_circle(icx, icy, radius, color)
          @raylib.draw_circle(
            icx,
            icy,
            radius - 4.0,
            @types.color_grid_cell,
          )
          @raylib.draw_circle(icx, icy, radius - 8.0, color)
          @raylib.draw_circle(
            icx,
            icy,
            radius - 12.0,
            @types.color_grid_cell,
          )
          // Show field line count when simulated
          if state.simulated && cell.field_lines > 0 {
            let fl_str = cell.field_lines.to_string()
            let fw = @draw.measure_text(fl_str, 12)
            @draw.draw_text(fl_str, icx - fw / 2, icy + 16, 12, color)
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
        Device(target) => {
          let satisfied = state.simulated &&
            @types.absf(cell.wattage - target) <= @types.wattage_tolerance
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
          // Device: filled circle with ring
          @raylib.draw_circle(icx, icy, radius, color)
          @raylib.draw_circle(
            icx, icy, radius - 4.0, @types.color_grid_cell,
          )
          // Show target wattage
          let w_str = format_watts(target)
          let ww = @draw.measure_text(w_str, 14)
          @draw.draw_text(w_str, icx - ww / 2, icy - 7, 14, color)
          // Show actual wattage when simulated
          if state.simulated && cell.wattage > 0.0 {
            let actual = format_watts(cell.wattage)
            let aw = @draw.measure_text(actual, 10)
            let act_color = if satisfied {
              @types.color_satisfied
            } else {
              @types.color_unsatisfied
            }
            @draw.draw_text(actual, icx - aw / 2, icy + 16, 10, act_color)
          }
        }
      }
      // Fixed indicator
      if cell.fixed && cell.component != Empty {
        @raylib.draw_rectangle(
          icx - 20,
          icy + 22,
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
        PlaceMagnetN => "N"
        PlaceMagnetS => "S"
        PlaceCoil => "COIL"
        PlaceWire => "WIRE"
        Erase => "DEL"
      }
      let tool_color = match game.tool {
        PlaceMagnetN => @types.color_magnet_n
        PlaceMagnetS => @types.color_magnet_s
        PlaceCoil => @types.color_coil
        PlaceWire => @types.color_wire
        Erase => @raylib.red
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
  let mag_str = "Magnets: " +
    state.magnets_used.to_string() +
    "/" +
    state.magnet_budget.to_string()
  let mag_color = if state.magnets_used > state.magnet_budget {
    @types.color_unsatisfied
  } else {
    @types.color_hud_text
  }
  @draw.draw_text(mag_str, x, y, 14, mag_color)
  y += 18
  @draw.draw_text(
    "Par: " + state.par_magnets.to_string(),
    x,
    y,
    12,
    alpha_color(150, 160, 190, 200),
  )
  y += 20
  if state.coil_budget > 0 {
    let coil_str = "Coils: " +
      state.coils_used.to_string() +
      "/" +
      state.coil_budget.to_string()
    @draw.draw_text(coil_str, x, y, 14, @types.color_coil)
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
    y += 18
    let power_str = "Total: " + format_watts(state.total_power)
    @draw.draw_text(power_str, x, y, 12, alpha_color(150, 160, 190, 200))
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
    (PlaceMagnetN, "1", "Magnet N"),
    (PlaceMagnetS, "2", "Magnet S"),
    (PlaceCoil, "3", "Coil"),
    (PlaceWire, "4", "Wire"),
    (Erase, "5", "Erase"),
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
    "Arrows: move", "SPACE: place", "R: reset level", "S: simulate", "H: help",
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
    "Magnets used: " + result.magnets_used.to_string(),
    px + 40,
    sy + 25,
    18,
    @types.color_hud_text,
  )
  @draw.draw_text(
    "Power generated: " + format_watts(result.total_watts),
    px + 40,
    sy + 50,
    18,
    @types.color_hud_text,
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
    "Check magnet placement and coil routing",
    px + 30,
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
  let ph = 420
  let px = (w - pw) / 2
  let py = (h - ph) / 2
  @raylib.draw_rectangle(px, py, pw, ph, @types.color_panel)
  @raylib.draw_rectangle_lines(px, py, pw, ph, @types.color_title)
  let title = "HOW TO PLAY"
  let tw = @draw.measure_text(title, 30)
  @draw.draw_text(title, (w - tw) / 2, py + 15, 30, @types.color_title)
  let mut yy = py + 55
  let rules = [
    "Route magnetic field lines through coils!", "", "MAGNETS emit field lines in 4 directions",
    "  N (red) and S (blue) both work the same", "", "COILS capture field lines to generate power",
    "  Each captured line = 1.5W of power", "", "WIRES route power from coils to devices",
    "  Connect coils to devices with wires", "", "DEVICES need exact wattage (+-0.2W)",
    "", "SCORING:", "  1 star: All devices powered",
    "  2 stars: Use par magnets or fewer", "  3 stars: Par magnets + minimal coils",
    "", "Press H to close",
  ]
  for i in 0..<rules.length() {
    @draw.draw_text(rules[i], px + 25, yy, 14, @types.color_hud_text)
    yy += 20
  }
}

///|
fn format_watts(w : Float) -> String {
  let whole = w.to_int()
  let frac = ((w - Float::from_int(whole)) * 10.0 + 0.5).to_int()
  if frac == 0 || frac == 10 {
    if frac == 10 {
      (whole + 1).to_string() + "W"
    } else {
      whole.to_string() + "W"
    }
  } else {
    whole.to_string() + "." + frac.to_string() + "W"
  }
}
