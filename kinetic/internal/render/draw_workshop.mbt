///|
fn draw_playing(game : @types.Game) -> Unit {
  let level = match game.current_level {
    Some(l) => l
    None => return
  }
  // Draw background panel
  @raylib.draw_rectangle(0, 0, 740, @types.screen_height, @types.color_panel)
  // Draw peg grid
  draw_peg_grid(game)
  // Draw connections (mesh lines)
  draw_connections(game)
  // Draw belts
  draw_belts(game)
  // Draw placed gears
  for i in 0..<game.placed_gears.length() {
    let gear = game.placed_gears[i]
    if gear.active {
      draw_gear(gear, false)
    }
  }
  // Draw input gear marker
  draw_input_marker(level.input)
  // Draw output markers
  for i in 0..<level.outputs.length() {
    draw_output_marker(level.outputs[i])
  }
  // Draw hover preview
  match game.hover_peg {
    Some(pos) =>
      if game.play_state == Placing && game.selected_gear_kind != Belt {
        draw_gear_preview(game, pos)
      }
    None => ()
  }
  // Draw UI panel on right
  draw_ui_panel(game, level)
  // Draw message
  if game.message_timer > 0.0 {
    let tw = @draw.measure_text(game.message, 20)
    @draw.draw_text(
      game.message,
      370 - tw / 2,
      @types.screen_height - 40,
      20,
      @types.color_highlight,
    )
  }
}

///|
fn draw_peg_grid(game : @types.Game) -> Unit {
  for row in 0..<@types.grid_rows {
    for col in 0..<@types.grid_cols {
      let px = @types.peg_screen_x(col).to_int()
      let py = @types.peg_screen_y(row).to_int()
      let is_hover = match game.hover_peg {
        Some(h) => h.x == col && h.y == row
        None => false
      }
      let color = if is_hover {
        @types.color_peg_hover
      } else {
        @types.color_peg
      }
      @raylib.draw_circle(px, py, 4.0, color)
    }
  }
}

///|
fn draw_gear(gear : @types.Gear, preview : Bool) -> Unit {
  let cx = @types.peg_screen_x(gear.pos.x)
  let cy = @types.peg_screen_y(gear.pos.y)
  let radius = @types.gear_pixel_radius(gear.kind)
  let color = @types.gear_color(gear.kind)
  let alpha_f : Float = if preview { 0.5 } else { 1.0 }
  let draw_color = @raylib.fade(color, alpha_f)
  // Draw gear body
  @raylib.draw_circle(cx.to_int(), cy.to_int(), radius, draw_color)
  // Draw center hub
  let hub_base = @raylib.Color::new(60, 55, 50, 255)
  let hub_color = @raylib.fade(hub_base, alpha_f)
  @raylib.draw_circle(cx.to_int(), cy.to_int(), 6.0, hub_color)
  // Draw teeth
  if gear.kind != Belt {
    let tooth_count = @types.gear_tooth_count(gear.kind)
    let tooth_len : Float = 6.0
    let tooth_color = @raylib.fade(@types.color_tooth, alpha_f)
    for i in 0..<tooth_count {
      let angle = gear.angle +
        Float::from_int(i) * 2.0 * @types.pi / Float::from_int(tooth_count)
      let inner_x = cx + @types.cosf(angle) * radius
      let inner_y = cy + @types.sinf(angle) * radius
      let outer_x = cx + @types.cosf(angle) * (radius + tooth_len)
      let outer_y = cy + @types.sinf(angle) * (radius + tooth_len)
      @raylib.draw_line_ex(
        @raylib.Vector2::new(inner_x, inner_y),
        @raylib.Vector2::new(outer_x, outer_y),
        2.0,
        tooth_color,
      )
    }
    // Draw ratchet arrow
    if gear.kind == Ratchet && !preview {
      draw_ratchet_indicator(cx, cy, radius)
    }
  }
  // Draw RPM label if active and not preview
  if !preview && @types.absf(gear.rpm) > 0.01 {
    let rpm_text = gear.rpm.to_int().to_string() + " RPM"
    let tw = @draw.measure_text(rpm_text, 12)
    @draw.draw_text(
      rpm_text,
      cx.to_int() - tw / 2,
      cy.to_int() + radius.to_int() + 10,
      12,
      @types.color_text,
    )
    // Draw direction arrow
    draw_dir_arrow(cx, cy, radius + 16.0, gear.dir, gear.angle)
  }
}

///|
fn draw_ratchet_indicator(cx : Float, cy : Float, radius : Float) -> Unit {
  // Draw a small CW arrow on the ratchet
  let arrow_r = radius * 0.5
  let segments = 8
  for i in 0..<segments {
    let a1 = Float::from_int(i) * @types.pi / Float::from_int(segments)
    let a2 = Float::from_int(i + 1) * @types.pi / Float::from_int(segments)
    let x1 = cx + @types.cosf(a1) * arrow_r
    let y1 = cy + @types.sinf(a1) * arrow_r
    let x2 = cx + @types.cosf(a2) * arrow_r
    let y2 = cy + @types.sinf(a2) * arrow_r
    @raylib.draw_line_ex(
      @raylib.Vector2::new(x1, y1),
      @raylib.Vector2::new(x2, y2),
      2.0,
      @raylib.white,
    )
  }
  // Arrow head
  let tip_angle : Float = @types.pi
  let tip_x = cx + @types.cosf(tip_angle) * arrow_r
  let tip_y = cy + @types.sinf(tip_angle) * arrow_r
  let head1_x = tip_x + @types.cosf(tip_angle + 0.5) * 8.0
  let head1_y = tip_y + @types.sinf(tip_angle + 0.5) * 8.0
  let head2_x = tip_x + @types.cosf(tip_angle - 0.5) * 8.0
  let head2_y = tip_y + @types.sinf(tip_angle - 0.5) * 8.0
  @raylib.draw_line_ex(
    @raylib.Vector2::new(tip_x, tip_y),
    @raylib.Vector2::new(head1_x, head1_y),
    2.0,
    @raylib.white,
  )
  @raylib.draw_line_ex(
    @raylib.Vector2::new(tip_x, tip_y),
    @raylib.Vector2::new(head2_x, head2_y),
    2.0,
    @raylib.white,
  )
}

///|
fn draw_dir_arrow(
  cx : Float,
  cy : Float,
  radius : Float,
  dir : @types.RotDir,
  angle : Float
) -> Unit {
  let dir_mult : Float = match dir {
    CW => 1.0
    CCW => -1.0
  }
  let a = angle + dir_mult * 0.3
  let ax = cx + @types.cosf(a) * radius
  let ay = cy + @types.sinf(a) * radius
  let perp = a + dir_mult * @types.pi * 0.5
  let hx = ax + @types.cosf(perp) * 5.0
  let hy = ay + @types.sinf(perp) * 5.0
  @raylib.draw_circle(
    ax.to_int(),
    ay.to_int(),
    3.0,
    @types.color_direction_arrow,
  )
  @raylib.draw_line_ex(
    @raylib.Vector2::new(ax, ay),
    @raylib.Vector2::new(hx, hy),
    2.0,
    @types.color_direction_arrow,
  )
}

///|
fn draw_connections(game : @types.Game) -> Unit {
  for i in 0..<game.connections.length() {
    let conn = game.connections[i]
    if conn.from >= 0 &&
      conn.from < game.placed_gears.length() &&
      conn.to >= 0 &&
      conn.to < game.placed_gears.length() {
      let g1 = game.placed_gears[conn.from]
      let g2 = game.placed_gears[conn.to]
      if g1.active && g2.active && conn.flips_dir {
        let x1 = @types.peg_screen_x(g1.pos.x)
        let y1 = @types.peg_screen_y(g1.pos.y)
        let x2 = @types.peg_screen_x(g2.pos.x)
        let y2 = @types.peg_screen_y(g2.pos.y)
        @raylib.draw_line_ex(
          @raylib.Vector2::new(x1, y1),
          @raylib.Vector2::new(x2, y2),
          1.0,
          @types.color_mesh_line,
        )
      }
    }
  }
}

///|
fn draw_belts(game : @types.Game) -> Unit {
  for i in 0..<game.belts.length() {
    let belt = game.belts[i]
    if belt.active {
      let x1 = @types.peg_screen_x(belt.from_pos.x)
      let y1 = @types.peg_screen_y(belt.from_pos.y)
      let x2 = @types.peg_screen_x(belt.to_pos.x)
      let y2 = @types.peg_screen_y(belt.to_pos.y)
      // Draw belt as two parallel lines
      let dx = x2 - x1
      let dy = y2 - y1
      let len = @types.sqrtf(dx * dx + dy * dy)
      if len > 0.01 {
        let nx = -dy / len * 4.0
        let ny = dx / len * 4.0
        @raylib.draw_line_ex(
          @raylib.Vector2::new(x1 + nx, y1 + ny),
          @raylib.Vector2::new(x2 + nx, y2 + ny),
          2.0,
          @types.color_belt,
        )
        @raylib.draw_line_ex(
          @raylib.Vector2::new(x1 - nx, y1 - ny),
          @raylib.Vector2::new(x2 - nx, y2 - ny),
          2.0,
          @types.color_belt,
        )
      }
    }
  }
}

///|
fn draw_input_marker(input : @types.InputGear) -> Unit {
  let cx = @types.peg_screen_x(input.pos.x)
  let cy = @types.peg_screen_y(input.pos.y)
  let r = @types.gear_pixel_radius(
    match input.radius {
      1 => Small
      3 => Large
      _ => Medium
    },
  )
  @raylib.draw_circle_lines(
    cx.to_int(),
    cy.to_int(),
    r + 12.0,
    @types.color_input,
  )
  let label = "IN " + input.rpm.to_int().to_string() + " RPM"
  let tw = @draw.measure_text(label, 14)
  @draw.draw_text(
    label,
    cx.to_int() - tw / 2,
    cy.to_int() - r.to_int() - 24,
    14,
    @types.color_input,
  )
}

///|
fn draw_output_marker(output : @types.Output) -> Unit {
  let cx = @types.peg_screen_x(output.pos.x)
  let cy = @types.peg_screen_y(output.pos.y)
  let color = if output.satisfied {
    @types.color_output_ok
  } else {
    @types.color_output_marker
  }
  @raylib.draw_circle_lines(cx.to_int(), cy.to_int(), 16.0, color)
  @raylib.draw_circle_lines(cx.to_int(), cy.to_int(), 18.0, color)
  let dir_str : String = match output.target_dir {
    CW => "CW"
    CCW => "CCW"
  }
  let label = output.target_rpm.to_int().to_string() + " " + dir_str
  let tw = @draw.measure_text(label, 12)
  @draw.draw_text(label, cx.to_int() - tw / 2, cy.to_int() + 22, 12, color)
  // Status indicator
  if output.satisfied {
    @draw.draw_text("OK", cx.to_int() - 8, cy.to_int() - 6, 12, color)
  } else {
    @draw.draw_text("?", cx.to_int() - 3, cy.to_int() - 6, 12, color)
  }
}

///|
fn draw_gear_preview(game : @types.Game, pos : @types.Vec2i) -> Unit {
  let preview_gear = @types.new_gear(pos, game.selected_gear_kind)
  draw_gear(preview_gear, true)
}
