///|
/// Main draw dispatch -- called once per frame between begin/end drawing.
pub fn draw_frame(game : @types.Game) -> Unit {
  draw_background(game)
  match game.screen {
    Title => draw_title(game)
    Build => draw_build(game)
    Test => draw_test(game)
    Results => draw_results(game)
    LevelSelect => draw_level_select(game)
    Sandbox => draw_sandbox(game)
  }
  draw_message(game)
}

///|
fn draw_background(game : @types.Game) -> Unit {
  ignore(game)
  @raylib.clear_background(@raylib.Color::new(18, 22, 32, 255))
  // Subtle gradient strips
  for i in 0..<20 {
    let y = i * 49
    let a = 8 + i * 2 % 16
    @raylib.draw_rectangle(
      0,
      y,
      @types.screen_w,
      49,
      @raylib.Color::new(20 + i * 3 % 20, 24 + i * 5 % 18, 38 + i * 7 % 22, a),
    )
  }
}

///|
fn draw_title(game : @types.Game) -> Unit {
  let pulse = sinf(Float::from_int(game.frame_count) * 0.03)
  let title_y = 200 + (pulse * 8.0).to_int()
  @draw.draw_text(
    "PHYSICS TOWER",
    @types.screen_w / 2 - 280,
    title_y,
    64,
    @raylib.Color::new(240, 200, 60, 255),
  )
  @draw.draw_text(
    "Bridge Builder meets Jenga",
    @types.screen_w / 2 - 220,
    320,
    28,
    @raylib.Color::new(180, 190, 210, 200),
  )
  @draw.draw_text(
    "Build towers from geometric shapes",
    @types.screen_w / 2 - 240,
    370,
    24,
    @raylib.Color::new(150, 160, 180, 180),
  )
  @draw.draw_text(
    "that must withstand wind, earthquakes, and projectiles",
    @types.screen_w / 2 - 330,
    410,
    24,
    @raylib.Color::new(150, 160, 180, 180),
  )
  // Start button
  let bx = @types.screen_w / 2 - 160
  let by = 520
  let bw = 320
  let bh = 70
  @raylib.draw_rectangle(bx, by, bw, bh, @raylib.Color::new(60, 120, 200, 220))
  @raylib.draw_rectangle_lines(bx, by, bw, bh, @raylib.Color::new(100, 180, 255, 255))
  @draw.draw_text(
    "PRESS ENTER / CLICK",
    bx + 30,
    by + 20,
    28,
    @raylib.Color::new(255, 255, 255, 255),
  )
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  @draw.draw_text(
    "SELECT LEVEL",
    @types.screen_w / 2 - 140,
    60,
    40,
    @raylib.Color::new(240, 200, 60, 255),
  )
  let all_levels = @content.get_levels()
  for i in 0..<all_levels.length() {
    let level = all_levels[i]
    let row = i / 2
    let col = i % 2
    let bx = 300 + col * 560
    let by = 160 + row * 120
    let bw = 500
    let bh = 100
    let hover = @types.pointer_in_rect(
      Float::from_int(@raylib.get_mouse_x()),
      Float::from_int(@raylib.get_mouse_y()),
      bx,
      by,
      bw,
      bh,
    )
    let bg = if hover {
      @raylib.Color::new(60, 80, 120, 200)
    } else {
      @raylib.Color::new(36, 44, 64, 200)
    }
    @raylib.draw_rectangle(bx, by, bw, bh, bg)
    @raylib.draw_rectangle_lines(
      bx,
      by,
      bw,
      bh,
      @raylib.Color::new(100, 140, 200, 180),
    )
    let num_str = (i + 1).to_string()
    @draw.draw_text(
      num_str + ". " + level.name,
      bx + 16,
      by + 12,
      24,
      @raylib.Color::new(220, 220, 240, 255),
    )
    @draw.draw_text(
      level.description,
      bx + 16,
      by + 44,
      18,
      @raylib.Color::new(160, 170, 190, 200),
    )
    let ht = (level.target_height + 0.5).to_int()
    @draw.draw_text(
      "Target: " + ht.to_string() + "px  Budget: " + level.budget.to_string(),
      bx + 16,
      by + 70,
      16,
      @raylib.Color::new(120, 200, 160, 200),
    )
  }
  // Sandbox button
  @raylib.draw_rectangle(
    600,
    780,
    500,
    80,
    @raylib.Color::new(80, 60, 120, 200),
  )
  @raylib.draw_rectangle_lines(
    600,
    780,
    500,
    80,
    @raylib.Color::new(160, 120, 220, 180),
  )
  @draw.draw_text(
    "S - SANDBOX MODE",
    640,
    800,
    28,
    @raylib.Color::new(200, 180, 240, 255),
  )
  ignore(game)
}

///|
fn draw_build(game : @types.Game) -> Unit {
  draw_world(game)
  draw_ghost(game)
  draw_panel(game)
  draw_build_hud(game)
}

///|
fn draw_sandbox(game : @types.Game) -> Unit {
  draw_world(game)
  draw_ghost(game)
  draw_panel(game)
  draw_sandbox_hud(game)
}

///|
fn draw_test(game : @types.Game) -> Unit {
  draw_world(game)
  draw_test_hud(game)
}

///|
fn draw_results(game : @types.Game) -> Unit {
  draw_world(game)
  draw_results_overlay(game)
}

///|
fn draw_world(game : @types.Game) -> Unit {
  let world = game.world
  // Draw ground
  @raylib.draw_rectangle(
    0,
    world.ground_y.to_int(),
    @types.screen_w,
    @types.screen_h - world.ground_y.to_int(),
    @raylib.Color::new(60, 70, 50, 255),
  )
  @raylib.draw_line(
    0,
    world.ground_y.to_int(),
    @types.screen_w,
    world.ground_y.to_int(),
    @raylib.Color::new(100, 130, 80, 255),
  )
  // Draw build area boundaries
  @raylib.draw_line(
    @types.build_area_left.to_int(),
    @types.build_area_top.to_int(),
    @types.build_area_left.to_int(),
    world.ground_y.to_int(),
    @raylib.Color::new(60, 80, 100, 100),
  )
  @raylib.draw_line(
    @types.build_area_right.to_int(),
    @types.build_area_top.to_int(),
    @types.build_area_right.to_int(),
    world.ground_y.to_int(),
    @raylib.Color::new(60, 80, 100, 100),
  )
  // Draw joints
  for joint in world.joints {
    if !(joint.active) || joint.broken {
      continue
    }
    let a_opt = @physics.find_body(world, joint.body_a)
    let b_opt = @physics.find_body(world, joint.body_b)
    match (a_opt, b_opt) {
      (Some(a), Some(b)) => {
        let (ax, ay) = @physics.local_to_world(a, joint.local_x_a, joint.local_y_a)
        let (bx, by) = @physics.local_to_world(b, joint.local_x_b, joint.local_y_b)
        let stress_ratio : Float = joint.stress / joint.strength
        let r = (100.0F + stress_ratio * 155.0F).to_int().clamp(min=0, max=255)
        let g = (180.0F - stress_ratio * 150.0F).to_int().clamp(min=0, max=255)
        @raylib.draw_line(
          ax.to_int(),
          ay.to_int(),
          bx.to_int(),
          by.to_int(),
          @raylib.Color::new(r, g, 60, 180),
        )
      }
      _ => ()
    }
  }
  // Draw bodies
  for body in world.bodies {
    if !(body.active) {
      continue
    }
    draw_body(body)
  }
  // Draw wind indicator
  if @types.absf(world.wind_force) > 0.1 {
    draw_wind_indicator(world)
  }
  // Draw earthquake indicator
  if world.quake_timer > 0.0 {
    draw_quake_indicator(world)
  }
  // Draw tower height marker
  let height = @physics.measure_tower_height(world)
  if height > 10.0 {
    let top_y = (world.ground_y - height).to_int()
    @raylib.draw_line(
      @types.build_area_left.to_int() - 30,
      top_y,
      @types.build_area_left.to_int() - 5,
      top_y,
      @raylib.Color::new(255, 200, 60, 200),
    )
    let ht = (height + 0.5).to_int()
    @draw.draw_text(
      ht.to_string() + "px",
      @types.build_area_left.to_int() - 80,
      top_y - 10,
      16,
      @raylib.Color::new(255, 200, 60, 200),
    )
  }
}

///|
fn draw_body(body : @types.Body) -> Unit {
  let cx = body.x.to_int()
  let cy = body.y.to_int()
  let hw = (body.width * 0.5).to_int()
  let hh = (body.height * 0.5).to_int()
  // Color based on material and stress
  let (base_r, base_g, base_b) = material_color(body.material)
  let stress_ratio : Float = if body.broken {
    1.0F
  } else {
    let threshold = @types.material_strength(body.material)
    @types.clampf(body.stress / threshold, 0.0, 1.0)
  }
  let r = (Float::from_int(base_r) + stress_ratio * Float::from_int(255 - base_r)).to_int()
  let g = (Float::from_int(base_g) * (1.0F - stress_ratio * 0.7F)).to_int()
  let b = (Float::from_int(base_b) * (1.0F - stress_ratio * 0.5F)).to_int()
  let alpha = if body.broken { 120 } else { 230 }
  let color = @raylib.Color::new(
    r.clamp(min=0, max=255),
    g.clamp(min=0, max=255),
    b.clamp(min=0, max=255),
    alpha,
  )
  if @types.absf(body.angle) < 0.01 {
    // Axis-aligned: use simple rectangle
    @raylib.draw_rectangle(cx - hw, cy - hh, hw * 2, hh * 2, color)
    @raylib.draw_rectangle_lines(cx - hw, cy - hh, hw * 2, hh * 2, outline_color(body.material))
  } else {
    // Rotated: draw as rotated rectangle using raylib
    @raylib.draw_rectangle_pro(
      @raylib.Rectangle::new(
        body.x,
        body.y,
        body.width,
        body.height,
      ),
      @raylib.Vector2::new(body.width * 0.5, body.height * 0.5),
      body.angle * 57.2957795, // radians to degrees
      color,
    )
  }
  // Draw piece kind indicator
  match body.kind {
    Triangle => {
      // Small triangle marker
      @raylib.draw_triangle(
        @raylib.Vector2::new(Float::from_int(cx), Float::from_int(cy - hh / 2)),
        @raylib.Vector2::new(
          Float::from_int(cx - hw / 3),
          Float::from_int(cy + hh / 3),
        ),
        @raylib.Vector2::new(
          Float::from_int(cx + hw / 3),
          Float::from_int(cy + hh / 3),
        ),
        @raylib.Color::new(255, 255, 255, 40),
      )
    }
    Arch => {
      // Small arch marker (circle on top)
      @raylib.draw_circle(cx, cy - hh / 3, Float::from_int(hw / 3), @raylib.Color::new(255, 255, 255, 30))
    }
    Cable => {
      // Dashed line appearance
      @raylib.draw_line(
        cx - hw,
        cy,
        cx + hw,
        cy,
        @raylib.Color::new(255, 255, 255, 60),
      )
    }
    _ => ()
  }
  // Broken X marker
  if body.broken {
    @raylib.draw_line(
      cx - hw / 2,
      cy - hh / 2,
      cx + hw / 2,
      cy + hh / 2,
      @raylib.Color::new(255, 60, 60, 200),
    )
    @raylib.draw_line(
      cx + hw / 2,
      cy - hh / 2,
      cx - hw / 2,
      cy + hh / 2,
      @raylib.Color::new(255, 60, 60, 200),
    )
  }
}

///|
fn draw_ghost(game : @types.Game) -> Unit {
  if game.inventory.length() == 0 || game.selected_piece >= game.inventory.length() {
    return
  }
  let (kind, _material, count) = game.inventory[game.selected_piece]
  if count <= 0 {
    return
  }
  let (w, h) = @types.piece_dimensions(kind)
  let cx = game.ghost_x.to_int()
  let cy = game.ghost_y.to_int()
  let hw = (w * 0.5).to_int()
  let hh = (h * 0.5).to_int()
  if @types.absf(game.ghost_angle) < 0.01 {
    @raylib.draw_rectangle(
      cx - hw,
      cy - hh,
      hw * 2,
      hh * 2,
      @raylib.Color::new(100, 200, 255, 80),
    )
    @raylib.draw_rectangle_lines(
      cx - hw,
      cy - hh,
      hw * 2,
      hh * 2,
      @raylib.Color::new(100, 200, 255, 160),
    )
  } else {
    @raylib.draw_rectangle_pro(
      @raylib.Rectangle::new(game.ghost_x, game.ghost_y, w, h),
      @raylib.Vector2::new(w * 0.5, h * 0.5),
      game.ghost_angle * 57.2957795,
      @raylib.Color::new(100, 200, 255, 80),
    )
  }
}

///|
fn draw_panel(game : @types.Game) -> Unit {
  let px = @types.panel_x
  let pw = @types.panel_w
  let ph = @types.screen_h - 40
  @raylib.draw_rectangle(px, 20, pw, ph, @raylib.Color::new(20, 26, 40, 220))
  @raylib.draw_rectangle_lines(
    px,
    20,
    pw,
    ph,
    @raylib.Color::new(80, 100, 140, 180),
  )
  @draw.draw_text(
    "PIECES",
    px + 12,
    30,
    20,
    @raylib.Color::new(200, 210, 230, 255),
  )
  // Draw inventory items
  for i in 0..<game.inventory.length() {
    let (kind, material, count) = game.inventory[i]
    let iy = 65 + i * 68
    let selected = i == game.selected_piece
    let bg = if selected {
      @raylib.Color::new(50, 70, 110, 200)
    } else {
      @raylib.Color::new(30, 38, 56, 150)
    }
    @raylib.draw_rectangle(px + 8, iy, pw - 16, 60, bg)
    if selected {
      @raylib.draw_rectangle_lines(
        px + 8,
        iy,
        pw - 16,
        60,
        @raylib.Color::new(100, 180, 255, 200),
      )
    }
    let num_str = (i + 1).to_string()
    @draw.draw_text(
      num_str,
      px + 14,
      iy + 4,
      14,
      @raylib.Color::new(150, 160, 180, 180),
    )
    let name = piece_name(kind) + " (" + material_name(material) + ")"
    let name_color = if count > 0 {
      @raylib.Color::new(220, 220, 240, 255)
    } else {
      @raylib.Color::new(120, 120, 140, 180)
    }
    @draw.draw_text(name, px + 30, iy + 4, 16, name_color)
    @draw.draw_text(
      "x" + count.to_string(),
      px + 30,
      iy + 26,
      18,
      if count > 0 {
        @raylib.Color::new(100, 220, 140, 255)
      } else {
        @raylib.Color::new(220, 80, 80, 200)
      },
    )
    // Draw small piece preview
    let (pw2, ph2) = @types.piece_dimensions(kind)
    let preview_scale : Float = 0.3
    let prw = (pw2 * preview_scale).to_int()
    let prh = (ph2 * preview_scale).to_int()
    let prx = px + pw - 30 - prw / 2
    let pry = iy + 30 - prh / 2
    let (mr, mg, mb) = material_color(material)
    @raylib.draw_rectangle(
      prx - prw / 2,
      pry - prh / 2,
      prw,
      prh,
      @raylib.Color::new(mr, mg, mb, 200),
    )
  }
}

///|
fn draw_build_hud(game : @types.Game) -> Unit {
  @draw.draw_text(
    "BUILD PHASE",
    20,
    10,
    24,
    @raylib.Color::new(100, 220, 140, 255),
  )
  let ht = (game.tower_height + 0.5).to_int()
  @draw.draw_text(
    "Height: " + ht.to_string() + "px",
    20,
    40,
    18,
    @raylib.Color::new(200, 200, 220, 200),
  )
  @draw.draw_text(
    "Bodies: " + game.world.bodies.length().to_string(),
    20,
    64,
    16,
    @raylib.Color::new(180, 180, 200, 180),
  )
  @draw.draw_text(
    "[Click] Place  [R] Rotate  [Z] Undo  [Tab] Cycle  [T/Enter] Test  [Esc] Back",
    20,
    @types.screen_h - 30,
    16,
    @raylib.Color::new(140, 150, 170, 160),
  )
}

///|
fn draw_sandbox_hud(game : @types.Game) -> Unit {
  @draw.draw_text(
    "SANDBOX MODE",
    20,
    10,
    24,
    @raylib.Color::new(200, 180, 240, 255),
  )
  let ht = (game.tower_height + 0.5).to_int()
  @draw.draw_text(
    "Height: " + ht.to_string() + "px",
    20,
    40,
    18,
    @raylib.Color::new(200, 200, 220, 200),
  )
  let active = @physics.count_active_bodies(game.world)
  let broken = @physics.count_broken_bodies(game.world)
  @draw.draw_text(
    "Active: " + active.to_string() + "  Broken: " + broken.to_string(),
    20,
    64,
    16,
    @raylib.Color::new(180, 180, 200, 180),
  )
  @draw.draw_text(
    "[Click] Place  [R] Rotate  [Z] Undo  [T] Physics  [W] Wind  [E] Quake  [I] Impact  [C] Clear  [V] Reset  [Esc] Back",
    20,
    @types.screen_h - 30,
    14,
    @raylib.Color::new(140, 150, 170, 160),
  )
}

///|
fn draw_test_hud(game : @types.Game) -> Unit {
  let phase_name = match game.screen {
    Test => {
      let levels = @content.get_levels()
      let level = levels[game.current_level]
      if game.test_phase < level.test_kinds.length() {
        match level.test_kinds[game.test_phase] {
          Wind => "WIND TEST"
          Earthquake => "EARTHQUAKE TEST"
          Impact => "IMPACT TEST"
        }
      } else {
        "SETTLING..."
      }
    }
    _ => "TEST"
  }
  @draw.draw_text(
    phase_name,
    20,
    10,
    28,
    @raylib.Color::new(255, 120, 80, 255),
  )
  let timer_str = (game.test_timer + 0.5).to_int().to_string()
  @draw.draw_text(
    "Time: " + timer_str + "s",
    20,
    46,
    20,
    @raylib.Color::new(200, 200, 220, 200),
  )
  let active = @physics.count_active_bodies(game.world)
  let broken = @physics.count_broken_bodies(game.world)
  @draw.draw_text(
    "Active: " + active.to_string() + "  Broken: " + broken.to_string(),
    20,
    74,
    18,
    @raylib.Color::new(180, 180, 200, 180),
  )
  @draw.draw_text(
    "[Esc] Skip test",
    20,
    @types.screen_h - 30,
    16,
    @raylib.Color::new(140, 150, 170, 160),
  )
}

///|
fn draw_results_overlay(game : @types.Game) -> Unit {
  // Semi-transparent overlay
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(0, 0, 0, 140),
  )
  @draw.draw_text(
    "RESULTS",
    @types.screen_w / 2 - 80,
    180,
    48,
    @raylib.Color::new(240, 200, 60, 255),
  )
  let ht = (game.tower_height + 0.5).to_int()
  @draw.draw_text(
    "Tower Height: " + ht.to_string() + " px",
    @types.screen_w / 2 - 150,
    280,
    28,
    @raylib.Color::new(200, 220, 240, 255),
  )
  let active = @physics.count_active_bodies(game.world)
  let total = game.world.bodies.length()
  @draw.draw_text(
    "Survived: " + active.to_string() + " / " + total.to_string(),
    @types.screen_w / 2 - 130,
    330,
    24,
    @raylib.Color::new(180, 200, 220, 230),
  )
  @draw.draw_text(
    "Score: " + game.score.to_string(),
    @types.screen_w / 2 - 80,
    380,
    32,
    @raylib.Color::new(100, 220, 140, 255),
  )
  let best_ht = (game.best_height + 0.5).to_int()
  @draw.draw_text(
    "Best Height: " + best_ht.to_string() + " px",
    @types.screen_w / 2 - 120,
    430,
    22,
    @raylib.Color::new(160, 180, 200, 200),
  )
  // Retry button
  @raylib.draw_rectangle(560, 600, 280, 60, @raylib.Color::new(60, 120, 200, 220))
  @raylib.draw_rectangle_lines(560, 600, 280, 60, @raylib.Color::new(100, 180, 255, 255))
  @draw.draw_text("RETRY (R)", 620, 616, 24, @raylib.Color::new(255, 255, 255, 255))
  // Next level button
  @raylib.draw_rectangle(880, 600, 280, 60, @raylib.Color::new(60, 160, 80, 220))
  @raylib.draw_rectangle_lines(880, 600, 280, 60, @raylib.Color::new(100, 220, 120, 255))
  @draw.draw_text("NEXT LEVEL", 930, 616, 24, @raylib.Color::new(255, 255, 255, 255))
  @draw.draw_text(
    "[Enter/Space] Level Select  [R] Retry  [Esc] Back",
    @types.screen_w / 2 - 280,
    @types.screen_h - 40,
    18,
    @raylib.Color::new(140, 150, 170, 160),
  )
}

///|
fn draw_wind_indicator(world : @types.World) -> Unit {
  let dir = if world.wind_force > 0.0 { 1 } else { -1 }
  let cx = @types.screen_w / 2
  let cy = 30
  let len = (@types.absf(world.wind_force) * 0.5).to_int().clamp(min=10, max=200)
  @raylib.draw_line(
    cx,
    cy,
    cx + dir * len,
    cy,
    @raylib.Color::new(100, 180, 255, 200),
  )
  // Arrowhead
  @raylib.draw_line(
    cx + dir * len,
    cy,
    cx + dir * (len - 12),
    cy - 6,
    @raylib.Color::new(100, 180, 255, 200),
  )
  @raylib.draw_line(
    cx + dir * len,
    cy,
    cx + dir * (len - 12),
    cy + 6,
    @raylib.Color::new(100, 180, 255, 200),
  )
  @draw.draw_text("WIND", cx - 20, cy - 18, 14, @raylib.Color::new(100, 180, 255, 180))
}

///|
fn draw_quake_indicator(world : @types.World) -> Unit {
  ignore(world)
  let pulse = @raylib.get_random_value(0, 4)
  @draw.draw_text(
    "QUAKE",
    @types.screen_w / 2 - 30 + pulse,
    52 + pulse,
    18,
    @raylib.Color::new(255, 160, 60, 220),
  )
}

///|
fn draw_message(game : @types.Game) -> Unit {
  if game.message_timer <= 0.0 {
    return
  }
  let alpha = @types.clampf(game.message_timer * 255.0, 0.0, 255.0).to_int()
  let tw = @draw.measure_text(game.message_text, 24)
  let mx = (@types.screen_w - tw) / 2
  @raylib.draw_rectangle(
    mx - 16,
    @types.screen_h / 2 - 28,
    tw + 32,
    48,
    @raylib.Color::new(0, 0, 0, alpha * 3 / 4),
  )
  @draw.draw_text(
    game.message_text,
    mx,
    @types.screen_h / 2 - 16,
    24,
    @raylib.Color::new(255, 240, 200, alpha),
  )
}

///|
fn material_color(mat : @types.Material) -> (Int, Int, Int) {
  match mat {
    Wood => (160, 120, 60)
    Stone => (140, 140, 150)
    Steel => (100, 140, 200)
  }
}

///|
fn outline_color(mat : @types.Material) -> @raylib.Color {
  match mat {
    Wood => @raylib.Color::new(200, 160, 80, 200)
    Stone => @raylib.Color::new(180, 180, 190, 200)
    Steel => @raylib.Color::new(140, 180, 240, 200)
  }
}

///|
fn piece_name(kind : @types.PieceKind) -> String {
  match kind {
    Beam => "Beam"
    Block => "Block"
    Triangle => "Tri"
    Arch => "Arch"
    Cable => "Cable"
  }
}

///|
fn material_name(mat : @types.Material) -> String {
  match mat {
    Wood => "Wood"
    Stone => "Stone"
    Steel => "Steel"
  }
}

///|
fn sinf(angle : Float) -> Float {
  Float::from_double(@math.sin(angle.to_double()))
}

///|
/// Returns level names for display.
pub fn get_level_names() -> Array[String] {
  let levels = @content.get_levels()
  let names : Array[String] = Array::new(capacity=levels.length())
  for level in levels {
    names.push(level.name)
  }
  names
}
