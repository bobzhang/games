///|
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@types.color_bg)
  match game.screen {
    Title => draw_title(game)
    LevelSelect => draw_level_select(game)
    Playing => draw_playing(game)
    Paused => {
      draw_playing(game)
      draw_pause_overlay()
    }
    LevelComplete => {
      draw_playing(game)
      draw_level_complete(game)
    }
    LevelFailed => {
      draw_playing(game)
      draw_level_failed(game)
    }
  }
  @fps.draw()
  @raylib.end_drawing()
}

///|
fn draw_title(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time = Float::from_int(game.frame_count) * 0.02
  // Decorative gears in background
  draw_bg_gears(game.frame_count)
  // Title
  let title = "CLOCKWORK"
  let title_w = @draw.measure_text(title, 72)
  let pulse = @types.sinf(time * 2.0) * 0.1 + 0.9
  let alpha = (pulse * 255.0).to_int()
  @draw.draw_text(
    title,
    (w - title_w) / 2,
    h / 4 - 20,
    72,
    @raylib.Color::new(210, 180, 80, alpha),
  )
  // Subtitle
  let sub = "A Gear Mechanism Puzzle"
  let sub_w = @draw.measure_text(sub, 20)
  @draw.draw_text(
    sub,
    (w - sub_w) / 2,
    h / 4 + 60,
    20,
    @types.color_hud_text,
  )
  // Instructions
  @draw.draw_text(
    "Place gears to ring bells at the right time",
    w / 2 - 220,
    h / 2 + 20,
    18,
    @raylib.Color::new(180, 170, 140, 200),
  )
  @draw.draw_text(
    "LMB - Place    RMB - Remove    Space/Enter - Start    R - Reset",
    w / 2 - 290,
    h / 2 + 50,
    16,
    @raylib.Color::new(150, 140, 110, 200),
  )
  // Start prompt
  let start_text = "PRESS ENTER TO BEGIN"
  let start_w = @draw.measure_text(start_text, 24)
  let blink = if game.frame_count % 60 < 40 { 255 } else { 100 }
  @draw.draw_text(
    start_text,
    (w - start_w) / 2,
    h * 3 / 4,
    24,
    @raylib.Color::new(210, 180, 80, blink),
  )
}

///|
fn draw_bg_gears(frame : Int) -> Unit {
  let time = Float::from_int(frame) * 0.01
  let gx : Array[Float] = [150.0, 400.0, 900.0, 1100.0, 700.0]
  let gy : Array[Float] = [200.0, 500.0, 150.0, 450.0, 600.0]
  let gr : Array[Float] = [60.0, 40.0, 50.0, 45.0, 55.0]
  let gt : Array[Int] = [12, 8, 10, 9, 11]
  for i in 0..<5 {
    let fi = Float::from_int(i)
    let dir : Float = if i % 2 == 0 { 1.0 } else { -1.0 }
    let angle = time * (1.0 + fi * 0.3) * dir
    let alpha = 30 + (fi * 5.0).to_int()
    draw_gear_shape(
      gx[i].to_int(),
      gy[i].to_int(),
      gr[i],
      gt[i],
      angle,
      @raylib.Color::new(210, 180, 80, alpha),
    )
  }
}

///|
fn draw_gear_shape(
  cx : Int,
  cy : Int,
  radius : Float,
  teeth : Int,
  angle : Float,
  color : @raylib.Color
) -> Unit {
  let fcx = Float::from_int(cx)
  let fcy = Float::from_int(cy)
  // Draw gear body
  @raylib.draw_circle_lines(cx, cy, radius * 0.6, color)
  @raylib.draw_circle_lines(cx, cy, radius, color)
  // Draw teeth
  let tooth_angle = @types.two_pi / Float::from_int(teeth)
  for i in 0..<teeth {
    let a = angle + Float::from_int(i) * tooth_angle
    let inner_x = fcx + @types.cosf(a) * radius * 0.85
    let inner_y = fcy + @types.sinf(a) * radius * 0.85
    let outer_x = fcx + @types.cosf(a) * radius
    let outer_y = fcy + @types.sinf(a) * radius
    @raylib.draw_line(
      inner_x.to_int(),
      inner_y.to_int(),
      outer_x.to_int(),
      outer_y.to_int(),
      color,
    )
  }
  // Center dot
  @raylib.draw_circle(cx, cy, 3.0, color)
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let tier : @types.Tier = match game.tier_scroll {
    0 => Ticks
    1 => Timing
    _ => Clockwork
  }
  let tier_str = @types.tier_name(tier)
  // Header
  let header = "SELECT LEVEL - " + tier_str
  let header_w = @draw.measure_text(header, 36)
  @draw.draw_text(
    header,
    (w - header_w) / 2,
    40,
    36,
    @types.color_title,
  )
  // Tier navigation arrows
  if game.tier_scroll > 0 {
    @draw.draw_text(
      "< ",
      120,
      45,
      30,
      @types.color_hud_text,
    )
  }
  if game.tier_scroll < 2 {
    @draw.draw_text(
      " >",
      w - 160,
      45,
      30,
      @types.color_hud_text,
    )
  }
  // Tier description
  let desc = match tier {
    Ticks => "Simple gear trains to ring bells"
    Timing => "Cams and escapements for precise timing"
    Clockwork => "Complex mechanisms with multiple bells"
  }
  let desc_w = @draw.measure_text(desc, 16)
  @draw.draw_text(
    desc,
    (w - desc_w) / 2,
    90,
    16,
    @raylib.Color::new(150, 140, 110, 200),
  )
  let unlocked = @levels.tier_unlocked(game, tier)
  if !unlocked {
    let lock_msg = "Locked - earn more stars in previous tier"
    let lock_w = @draw.measure_text(lock_msg, 20)
    @draw.draw_text(
      lock_msg,
      (w - lock_w) / 2,
      350,
      20,
      @types.color_fail,
    )
    // Navigation hint
    @draw.draw_text(
      "ESC - Back    Left/Right - Change Tier",
      w / 2 - 180,
      @types.screen_height - 50,
      16,
      @raylib.Color::new(150, 140, 110, 200),
    )
    return
  }
  // Draw level buttons
  let (start, end) = @levels.levels_in_tier(tier)
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  for i = start; i < end; i = i + 1 {
    let idx = i - start
    let bx = 200 + (idx % 4) * 220
    let by = 280 + (idx / 4) * 120
    let hovered = mx >= bx && mx < bx + 200 && my >= by && my < by + 100
    let bg_color = if hovered {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(bx, by, 200, 100, bg_color)
    @raylib.draw_rectangle_lines(
      bx,
      by,
      200,
      100,
      @types.color_grid_line,
    )
    // Level number and name
    let num = (i + 1).to_string()
    @draw.draw_text(
      num,
      bx + 10,
      by + 8,
      20,
      @types.color_title,
    )
    let name = @levels.level_name(i)
    @draw.draw_text(
      name,
      bx + 10,
      by + 35,
      16,
      @types.color_hud_text,
    )
    // Stars
    let stars = game.level_stars[i]
    for s in 0..<3 {
      let sx = bx + 10 + s * 22
      let sy = by + 65
      let star_color = if s < stars {
        @types.color_star_filled
      } else {
        @types.color_star_empty
      }
      draw_star(sx + 8, sy + 8, 8.0, star_color)
    }
  }
  // Total stars for this tier
  let mut total_stars = 0
  for i = start; i < end; i = i + 1 {
    total_stars += game.level_stars[i]
  }
  let max_stars = (end - start) * 3
  let star_str = "Stars: " +
    total_stars.to_string() +
    "/" +
    max_stars.to_string()
  @draw.draw_text(
    star_str,
    w / 2 - 50,
    130,
    18,
    @types.color_star_filled,
  )
  // Navigation hint
  @draw.draw_text(
    "ESC - Back    Left/Right - Change Tier    1-7 - Quick Select",
    w / 2 - 260,
    @types.screen_height - 50,
    16,
    @raylib.Color::new(150, 140, 110, 200),
  )
}

///|
fn draw_star(cx : Int, cy : Int, size : Float, color : @raylib.Color) -> Unit {
  let fcx = Float::from_int(cx)
  let fcy = Float::from_int(cy)
  // Simple 5-point star
  for i in 0..<5 {
    let a1 = Float::from_int(i) * @types.two_pi / 5.0 - @types.pi / 2.0
    let a2 = Float::from_int(i + 1) * @types.two_pi / 5.0 - @types.pi / 2.0
    let x1 = fcx + @types.cosf(a1) * size
    let y1 = fcy + @types.sinf(a1) * size
    let x2 = fcx + @types.cosf(a2) * size
    let y2 = fcy + @types.sinf(a2) * size
    let am = (a1 + a2) / 2.0
    let mx = fcx + @types.cosf(am) * size * 0.4
    let my = fcy + @types.sinf(am) * size * 0.4
    @raylib.draw_triangle(
      @raylib.Vector2::new(fcx, fcy),
      @raylib.Vector2::new(x1, y1),
      @raylib.Vector2::new(mx, my),
      color,
    )
    @raylib.draw_triangle(
      @raylib.Vector2::new(fcx, fcy),
      @raylib.Vector2::new(mx, my),
      @raylib.Vector2::new(x2, y2),
      color,
    )
  }
}

///|
fn draw_playing(game : @types.Game) -> Unit {
  draw_grid()
  draw_connections(game)
  draw_components(game)
  draw_hover(game)
  draw_toolbar(game)
  draw_hud(game)
}

///|
fn draw_grid() -> Unit {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  let cols = @types.grid_cols
  let rows = @types.grid_rows
  // Grid background
  @raylib.draw_rectangle(
    ox,
    oy,
    cols * cs,
    rows * cs,
    @types.color_grid_bg,
  )
  // Grid lines
  for i in 0..=cols {
    @raylib.draw_line(
      ox + i * cs,
      oy,
      ox + i * cs,
      oy + rows * cs,
      @types.color_grid_line,
    )
  }
  for i in 0..=rows {
    @raylib.draw_line(
      ox,
      oy + i * cs,
      ox + cols * cs,
      oy + i * cs,
      @types.color_grid_line,
    )
  }
  // Pegs at intersections
  for r in 0..=rows {
    for c in 0..=cols {
      let px = ox + c * cs
      let py = oy + r * cs
      @raylib.draw_circle(px, py, 3.0, @types.color_peg)
    }
  }
}

///|
fn draw_connections(game : @types.Game) -> Unit {
  for i in 0..<game.components.length() {
    let c = game.components[i]
    if !c.active {
      continue
    }
    let cx = @types.cell_center_x(c.col)
    let cy = @types.cell_center_y(c.row)
    for j in 0..<c.connected_to.length() {
      let idx = c.connected_to[j]
      if idx > i {
        // Draw each connection only once
        let other = game.components[idx]
        let ox = @types.cell_center_x(other.col)
        let oy = @types.cell_center_y(other.row)
        @raylib.draw_line(
          cx.to_int(),
          cy.to_int(),
          ox.to_int(),
          oy.to_int(),
          @types.color_connection,
        )
      }
    }
  }
}

///|
fn draw_components(game : @types.Game) -> Unit {
  for i in 0..<game.components.length() {
    let c = game.components[i]
    if !c.active {
      continue
    }
    let cx = @types.cell_center_x(c.col).to_int()
    let cy = @types.cell_center_y(c.row).to_int()
    match c.kind {
      Gear(size) => draw_gear_component(cx, cy, size, c)
      Cam => draw_cam_component(cx, cy, c)
      Spring => draw_spring_component(cx, cy, c)
      Escapement => draw_escapement_component(cx, cy, c)
      Bell => draw_bell_component(cx, cy, c)
    }
    // Fixed indicator
    if c.fixed {
      @raylib.draw_circle(cx, cy, 4.0, @raylib.Color::new(255, 255, 255, 100))
    }
  }
}

///|
fn draw_gear_component(
  cx : Int,
  cy : Int,
  size : @types.GearSize,
  comp : @types.Component
) -> Unit {
  let radius = @types.gear_radius(size)
  let teeth = @types.gear_teeth(size)
  let color = match size {
    Small => @types.color_gear_copper
    Medium => @types.color_gear_gold
    Large => @types.color_gear_silver
  }
  draw_gear_shape(cx, cy, radius, teeth, comp.rotation, color)
  // Direction indicator
  if comp.rotation_speed > 0.0 {
    let dir_str = if comp.clockwise { "CW" } else { "CC" }
    @draw.draw_text(
      dir_str,
      cx - 8,
      cy - 6,
      12,
      @raylib.Color::new(255, 255, 255, 120),
    )
  }
}

///|
fn draw_cam_component(
  cx : Int,
  cy : Int,
  comp : @types.Component
) -> Unit {
  let fcx = Float::from_int(cx)
  let fcy = Float::from_int(cy)
  // Cam body - ellipse-like shape
  let r = @types.cam_radius
  @raylib.draw_circle(cx, cy, r, @types.color_cam)
  @raylib.draw_circle_lines(cx, cy, r, @raylib.Color::new(200, 180, 130, 255))
  // Cam offset indicator (pushing arm)
  let offset = comp.cam_offset
  let dir_x : Float = match comp.cam_dir {
    PushRight => 1.0
    PushLeft => -1.0
    _ => 0.0
  }
  let dir_y : Float = match comp.cam_dir {
    PushDown => 1.0
    PushUp => -1.0
    _ => 0.0
  }
  let end_x = fcx + dir_x * (r + @types.absf(offset))
  let end_y = fcy + dir_y * (r + @types.absf(offset))
  @raylib.draw_line(
    cx,
    cy,
    end_x.to_int(),
    end_y.to_int(),
    @raylib.Color::new(220, 200, 140, 255),
  )
  // Push head
  @raylib.draw_circle(end_x.to_int(), end_y.to_int(), 4.0, @types.color_cam)
}

///|
fn draw_spring_component(
  cx : Int,
  cy : Int,
  comp : @types.Component
) -> Unit {
  let r : Float = 18.0
  // Spring coils
  let energy = comp.spring_energy
  let coil_color = if comp.spring_released {
    @raylib.Color::new(150, 255, 180, 255)
  } else {
    @types.color_spring
  }
  // Draw zigzag spring shape
  let segments = 6
  let seg_h : Float = r * 2.0 / Float::from_int(segments)
  let base_y : Float = Float::from_int(cy) - r
  let fcx : Float = Float::from_int(cx)
  for i in 0..<segments {
    let fi = Float::from_int(i)
    let y1 : Float = base_y + fi * seg_h
    let y2 : Float = base_y + (fi + 1.0) * seg_h
    let x_off : Float = 12.0 * (1.0 - energy * 0.3)
    let x1_off : Float = if i % 2 == 0 { x_off } else { -x_off }
    let x2_off : Float = if (i + 1) % 2 == 0 { x_off } else { -x_off }
    let x1 : Float = fcx + x1_off
    let x2 : Float = fcx + x2_off
    @raylib.draw_line(
      x1.to_int(),
      y1.to_int(),
      x2.to_int(),
      y2.to_int(),
      coil_color,
    )
  }
  // Energy bar
  let bar_w : Float = 24.0
  let bar_h : Float = 4.0
  let bar_x : Float = Float::from_int(cx) - bar_w / 2.0
  let bar_y : Float = Float::from_int(cy) + r + 4.0
  @raylib.draw_rectangle(
    bar_x.to_int(),
    bar_y.to_int(),
    bar_w.to_int(),
    bar_h.to_int(),
    @raylib.Color::new(40, 40, 40, 200),
  )
  @raylib.draw_rectangle(
    bar_x.to_int(),
    bar_y.to_int(),
    (bar_w * energy).to_int(),
    bar_h.to_int(),
    coil_color,
  )
}

///|
fn draw_escapement_component(
  cx : Int,
  cy : Int,
  comp : @types.Component
) -> Unit {
  let fcx = Float::from_int(cx)
  let fcy = Float::from_int(cy)
  let r : Float = 22.0
  // Anchor/escapement shape
  @raylib.draw_circle_lines(cx, cy, r, @types.color_escapement)
  // Pendulum arm oscillating
  let swing : Float = @types.sinf(comp.escapement_phase * @types.two_pi) * 0.5
  let arm_x : Float = fcx + @types.sinf(swing) * r * 1.2
  let arm_y : Float = fcy + @types.cosf(swing) * r * 1.2
  @raylib.draw_line(
    cx,
    cy,
    arm_x.to_int(),
    arm_y.to_int(),
    @types.color_escapement,
  )
  @raylib.draw_circle(arm_x.to_int(), arm_y.to_int(), 5.0, @types.color_escapement)
  // Lock indicator
  if comp.escapement_locked {
    @draw.draw_text(
      "X",
      cx - 4,
      cy - 6,
      12,
      @raylib.Color::new(255, 100, 100, 200),
    )
  }
}

///|
fn draw_bell_component(
  cx : Int,
  cy : Int,
  comp : @types.Component
) -> Unit {
  let fcx = Float::from_int(cx)
  let fcy = Float::from_int(cy)
  let ringing = comp.bell_ring_timer > 0.0
  let color = if ringing {
    @types.color_bell_ringing
  } else if comp.bell_rung {
    @types.color_success
  } else {
    @types.color_bell
  }
  // Bell dome
  @raylib.draw_circle(cx, cy - 5, 16.0, color)
  // Bell base
  @raylib.draw_rectangle(cx - 14, cy + 8, 28, 6, color)
  // Clapper
  @raylib.draw_circle(cx, cy + 4, 4.0, @raylib.Color::new(100, 80, 40, 255))
  // Ring waves
  if ringing {
    let wave_r : Float = 20.0 + (1.0 - comp.bell_ring_timer / @types.bell_ring_duration) * 30.0
    let wave_alpha = (comp.bell_ring_timer / @types.bell_ring_duration * 200.0).to_int()
    @raylib.draw_circle_lines(
      cx,
      cy,
      wave_r,
      @raylib.Color::new(255, 240, 100, wave_alpha),
    )
  }
  // Target tick label
  let tick_str = "@" + comp.bell_target_tick.to_string()
  let tw = @draw.measure_text(tick_str, 12)
  @draw.draw_text(
    tick_str,
    cx - tw / 2,
    cy + 18,
    12,
    @types.color_hud_text,
  )
  // Check mark if rung
  if comp.bell_rung {
    let _ = fcx
    let _ = fcy
    @draw.draw_text(
      "OK",
      cx + 14,
      cy - 18,
      12,
      @types.color_success,
    )
  }
}

///|
fn draw_hover(game : @types.Game) -> Unit {
  if game.sim.state != Idle {
    return
  }
  let hc = game.hover_col
  let hr = game.hover_row
  if !@types.grid_valid(hc, hr) {
    return
  }
  let px = @types.grid_offset_x + hc * @types.cell_size
  let py = @types.grid_offset_y + hr * @types.cell_size
  let occupied = @types.grid_get(game, hc, hr) >= 0
  let color = if occupied || game.selected_palette < 0 {
    @types.color_invalid
  } else {
    @types.color_highlight
  }
  @raylib.draw_rectangle(
    px,
    py,
    @types.cell_size,
    @types.cell_size,
    color,
  )
}

///|
fn draw_toolbar(game : @types.Game) -> Unit {
  let toolbar_y = @types.grid_offset_y +
    @types.grid_rows * @types.cell_size +
    20
  let palette = game.level_def.palette
  // Toolbar background
  @raylib.draw_rectangle(
    @types.grid_offset_x - 10,
    toolbar_y - 10,
    palette.available.length() * 80 + 20,
    80,
    @types.color_toolbar_bg,
  )
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  for i in 0..<palette.available.length() {
    let bx = @types.grid_offset_x + i * 80
    let by = toolbar_y
    let hovered = mx >= bx && mx < bx + 70 && my >= by && my < by + 60
    let selected = game.selected_palette == i
    // Button background
    let bg = if selected {
      @types.color_selected
    } else if hovered {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(bx, by, 70, 60, bg)
    if selected {
      @raylib.draw_rectangle_lines(
        bx - 1,
        by - 1,
        72,
        62,
        @types.color_star_filled,
      )
    }
    // Component icon
    let kind = palette.available[i]
    let color = @types.component_color(kind)
    let icon_cx = bx + 35
    let icon_cy = by + 24
    match kind {
      Gear(size) => {
        let r = @types.gear_radius(size) * 0.5
        draw_gear_shape(icon_cx, icon_cy, r, @types.gear_teeth(size), 0.0, color)
      }
      Cam => @raylib.draw_circle(icon_cx, icon_cy, 10.0, color)
      Spring => {
        @raylib.draw_line(icon_cx - 8, icon_cy - 8, icon_cx + 8, icon_cy - 4, color)
        @raylib.draw_line(icon_cx + 8, icon_cy - 4, icon_cx - 8, icon_cy, color)
        @raylib.draw_line(icon_cx - 8, icon_cy, icon_cx + 8, icon_cy + 4, color)
        @raylib.draw_line(icon_cx + 8, icon_cy + 4, icon_cx - 8, icon_cy + 8, color)
      }
      Escapement =>
        @raylib.draw_circle_lines(icon_cx, icon_cy, 10.0, color)
      Bell => {
        @raylib.draw_circle(icon_cx, icon_cy - 2, 8.0, color)
        @raylib.draw_rectangle(icon_cx - 7, icon_cy + 5, 14, 3, color)
      }
    }
    // Count
    let count = palette.counts[i]
    let count_str = count.to_string()
    @draw.draw_text(
      count_str,
      bx + 55,
      by + 44,
      14,
      if count > 0 {
        @types.color_hud_text
      } else {
        @types.color_fail
      },
    )
  }
  // Simulation state hint
  let hint_x = @types.grid_offset_x +
    palette.available.length() * 80 +
    20
  if game.sim.state == Idle {
    @draw.draw_text(
      "ENTER/SPACE - Run",
      hint_x,
      toolbar_y + 5,
      14,
      @types.color_hud_text,
    )
    @draw.draw_text(
      "R - Reset  D - Deselect",
      hint_x,
      toolbar_y + 25,
      14,
      @raylib.Color::new(150, 140, 110, 200),
    )
  } else if game.sim.state == Running {
    @draw.draw_text(
      "Simulating... R - Stop",
      hint_x,
      toolbar_y + 5,
      14,
      @types.color_success,
    )
    @draw.draw_text(
      "Up/Down - Speed",
      hint_x,
      toolbar_y + 25,
      14,
      @raylib.Color::new(150, 140, 110, 200),
    )
  }
}

///|
fn draw_hud(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let sim = game.sim
  // Right panel
  let panel_x = @types.grid_offset_x + @types.grid_cols * @types.cell_size + 30
  let panel_y = @types.grid_offset_y
  let panel_w = w - panel_x - 20
  // Level info
  @raylib.draw_rectangle(
    panel_x,
    panel_y,
    panel_w,
    400,
    @types.color_hud_bg,
  )
  @draw.draw_text(
    "Level " + (game.current_level + 1).to_string(),
    panel_x + 10,
    panel_y + 10,
    22,
    @types.color_title,
  )
  @draw.draw_text(
    game.level_def.name,
    panel_x + 10,
    panel_y + 38,
    18,
    @types.color_hud_text,
  )
  @draw.draw_text(
    game.level_def.description,
    panel_x + 10,
    panel_y + 65,
    13,
    @raylib.Color::new(180, 170, 140, 220),
  )
  // Simulation status
  let status_y = panel_y + 100
  @draw.draw_text(
    "Tick: " + sim.tick.to_string(),
    panel_x + 10,
    status_y,
    16,
    @types.color_hud_text,
  )
  let speed_str = "Speed: " + sim.speed_mult.to_string() + "x"
  @draw.draw_text(
    speed_str,
    panel_x + 10,
    status_y + 22,
    16,
    @types.color_hud_text,
  )
  let placed = @types.count_placed_components(game)
  let par = game.level_def.par_components
  let comp_color = if placed <= par {
    @types.color_success
  } else {
    @types.color_hud_text
  }
  @draw.draw_text(
    "Parts: " + placed.to_string() + " / par " + par.to_string(),
    panel_x + 10,
    status_y + 44,
    16,
    comp_color,
  )
  // Bell targets
  let bell_y = status_y + 80
  @draw.draw_text(
    "Bell Targets:",
    panel_x + 10,
    bell_y,
    16,
    @types.color_title,
  )
  let targets = game.level_def.bell_targets
  for i in 0..<targets.length() {
    let target = targets[i]
    let rung = check_bell_rung_at(game, target)
    let bell_color = if rung {
      @types.color_success
    } else {
      @types.color_hud_text
    }
    let marker = if rung { "[OK] " } else { "[ ] " }
    @draw.draw_text(
      marker + "Tick " + target.to_string(),
      panel_x + 10,
      bell_y + 22 + i * 20,
      14,
      bell_color,
    )
  }
  // Current stars
  let stars_y = bell_y + 22 + targets.length() * 20 + 20
  @draw.draw_text(
    "Best: ",
    panel_x + 10,
    stars_y,
    16,
    @types.color_hud_text,
  )
  let best = game.level_stars[game.current_level]
  for s in 0..<3 {
    let sx = panel_x + 70 + s * 22
    let star_c = if s < best {
      @types.color_star_filled
    } else {
      @types.color_star_empty
    }
    draw_star(sx, stars_y + 8, 8.0, star_c)
  }
  // Message display
  if game.message_timer > 0.0 {
    let msg_w = @draw.measure_text(game.message, 20)
    @draw.draw_text(
      game.message,
      (w - msg_w) / 2,
      20,
      20,
      @types.color_title,
    )
  }
}

///|
fn check_bell_rung_at(game : @types.Game, target_tick : Int) -> Bool {
  for i in 0..<game.sim.bells_rung.length() {
    if game.sim.bells_rung[i] == target_tick {
      return true
    }
  }
  false
}

///|
fn draw_pause_overlay() -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  @raylib.draw_rectangle(0, 0, w, h, @raylib.Color::new(0, 0, 0, 150))
  let text = "PAUSED"
  let tw = @draw.measure_text(text, 48)
  @draw.draw_text(
    text,
    (w - tw) / 2,
    h / 3,
    48,
    @types.color_title,
  )
  @draw.draw_text(
    "ESC/P - Resume    Q - Quit to Menu",
    w / 2 - 160,
    h / 2,
    18,
    @types.color_hud_text,
  )
}

///|
fn draw_level_complete(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  @raylib.draw_rectangle(0, 0, w, h, @raylib.Color::new(0, 0, 0, 180))
  let text = "LEVEL COMPLETE!"
  let tw = @draw.measure_text(text, 48)
  @draw.draw_text(
    text,
    (w - tw) / 2,
    h / 4,
    48,
    @types.color_success,
  )
  // Stars
  let stars = game.level_stars[game.current_level]
  for s in 0..<3 {
    let sx = w / 2 - 50 + s * 50
    let star_c = if s < stars {
      @types.color_star_filled
    } else {
      @types.color_star_empty
    }
    draw_star(sx, h / 3 + 30, 20.0, star_c)
  }
  // Star descriptions
  let desc1 = if stars >= 1 { "All bells rang!" } else { "Ring all bells" }
  let desc2 = if stars >= 2 {
    "At or under par!"
  } else {
    "Use fewer components"
  }
  let desc3 = if stars >= 3 {
    "Perfect timing!"
  } else {
    "Ring in correct order at par"
  }
  @draw.draw_text(
    desc1,
    w / 2 - 80,
    h / 2 + 10,
    16,
    if stars >= 1 {
      @types.color_success
    } else {
      @types.color_hud_text
    },
  )
  @draw.draw_text(
    desc2,
    w / 2 - 80,
    h / 2 + 35,
    16,
    if stars >= 2 {
      @types.color_success
    } else {
      @types.color_hud_text
    },
  )
  @draw.draw_text(
    desc3,
    w / 2 - 120,
    h / 2 + 60,
    16,
    if stars >= 3 {
      @types.color_success
    } else {
      @types.color_hud_text
    },
  )
  @draw.draw_text(
    "ENTER - Next Level    R - Retry    ESC - Menu",
    w / 2 - 210,
    h * 3 / 4,
    18,
    @types.color_hud_text,
  )
}

///|
fn draw_level_failed(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let _ = game
  @raylib.draw_rectangle(0, 0, w, h, @raylib.Color::new(0, 0, 0, 180))
  let text = "MECHANISM FAILED"
  let tw = @draw.measure_text(text, 48)
  @draw.draw_text(
    text,
    (w - tw) / 2,
    h / 3,
    48,
    @types.color_fail,
  )
  @draw.draw_text(
    "Not all bells rang in time.",
    w / 2 - 120,
    h / 2,
    18,
    @types.color_hud_text,
  )
  @draw.draw_text(
    "ENTER/R - Retry    ESC - Menu",
    w / 2 - 140,
    h * 3 / 4,
    18,
    @types.color_hud_text,
  )
}
