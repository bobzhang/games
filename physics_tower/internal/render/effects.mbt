///|
/// Draws the stress heat map overlay on all bodies.
/// Bodies glow green -> yellow -> red based on their stress ratio.
pub fn draw_stress_heatmap(game : @types.Game) -> Unit {
  let world = game.world
  for body in world.bodies {
    if !(body.active) || body.broken {
      continue
    }
    let threshold = @types.material_strength(body.material)
    let ratio = @types.clampf(body.stress / threshold, 0.0, 1.0)
    if ratio < 0.05 {
      continue
    }
    let (r, g, b) = stress_to_color(ratio)
    let alpha = (ratio * 120.0 + 30.0).to_int().clamp(min=0, max=180)
    let cx = body.x.to_int()
    let cy = body.y.to_int()
    let hw = (body.width * 0.5).to_int() + 2
    let hh = (body.height * 0.5).to_int() + 2
    if @types.absf(body.angle) < 0.01 {
      @raylib.draw_rectangle(
        cx - hw,
        cy - hh,
        hw * 2,
        hh * 2,
        @raylib.Color::new(r, g, b, alpha),
      )
    } else {
      @raylib.draw_rectangle_pro(
        @raylib.Rectangle::new(
          body.x,
          body.y,
          body.width + 4.0,
          body.height + 4.0,
        ),
        @raylib.Vector2::new(
          (body.width + 4.0) * 0.5,
          (body.height + 4.0) * 0.5,
        ),
        body.angle * 57.2957795,
        @raylib.Color::new(r, g, b, alpha),
      )
    }
  }
}

///|
/// Converts stress ratio (0-1) to a green-yellow-red color.
fn stress_to_color(ratio : Float) -> (Int, Int, Int) {
  if ratio < 0.5 {
    // Green to yellow
    let t = ratio * 2.0
    let r = (t * 255.0).to_int().clamp(min=0, max=255)
    (r, 255, 0)
  } else {
    // Yellow to red
    let t = (ratio - 0.5) * 2.0
    let g = ((1.0F - t) * 255.0F).to_int().clamp(min=0, max=255)
    (255, g, 0)
  }
}

///|
/// Draws wind visualization as particle streams.
pub fn draw_wind_particles(game : @types.Game) -> Unit {
  let dest = game.destruction
  for p in dest.particles {
    let alpha_ratio = p.life / p.max_life
    let alpha = (alpha_ratio * 200.0).to_int().clamp(min=0, max=200)
    let size = (p.size * alpha_ratio).to_int().clamp(min=1, max=10)
    @raylib.draw_circle(
      p.x.to_int(),
      p.y.to_int(),
      Float::from_int(size),
      @raylib.Color::new(p.r, p.g, p.b, alpha),
    )
  }
}

///|
/// Draws earthquake dust particles and screen shake indicator.
pub fn draw_earthquake_effects(game : @types.Game) -> Unit {
  let world = game.world
  if world.quake_timer <= 0.0 {
    return
  }
  // Draw rumble lines at the ground
  let ground_y = world.ground_y.to_int()
  for i in 0..<8 {
    let x1 = @types.build_area_left.to_int() +
      @raylib.get_random_value(0, (@types.build_area_right - @types.build_area_left).to_int())
    let shake = @raylib.get_random_value(-3, 3)
    @raylib.draw_line(
      x1,
      ground_y + shake,
      x1 + @raylib.get_random_value(20, 60),
      ground_y + shake,
      @raylib.Color::new(180, 160, 100, 120),
    )
    ignore(i)
  }
}

///|
/// Draws impact projectile trail and explosion.
pub fn draw_impact_effects(game : @types.Game) -> Unit {
  let dest = game.destruction
  // Impact particles are drawn as part of general particle rendering
  // Draw explosion glow for recent impacts
  for p in dest.particles {
    if p.r == 255 && p.g == 200 && p.b == 60 {
      // This is an impact particle
      let alpha_ratio = p.life / p.max_life
      if alpha_ratio > 0.7 {
        // Recent -- draw glow
        let glow_size = p.size * 3.0
        let alpha = ((alpha_ratio - 0.7) * 3.333 * 80.0).to_int().clamp(
          min=0,
          max=80,
        )
        @raylib.draw_circle(
          p.x.to_int(),
          p.y.to_int(),
          glow_size,
          @raylib.Color::new(255, 180, 40, alpha),
        )
      }
    }
  }
  ignore(game)
}

///|
/// Draws the slow-motion indicator when active.
pub fn draw_slow_motion_indicator(game : @types.Game) -> Unit {
  let dest = game.destruction
  if dest.slow_motion <= 0.0 {
    return
  }
  let alpha = (@types.clampf(
      dest.slow_motion / @types.slow_motion_duration,
      0.0,
      1.0,
    ) *
    180.0).to_int()
  @draw.draw_text(
    "SLOW MOTION",
    @types.screen_w / 2 - 80,
    100,
    22,
    @raylib.Color::new(255, 220, 100, alpha),
  )
  // Vignette-like border effect
  let border_alpha = alpha / 3
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    4,
    @raylib.Color::new(255, 200, 60, border_alpha),
  )
  @raylib.draw_rectangle(
    0,
    @types.screen_h - 4,
    @types.screen_w,
    4,
    @raylib.Color::new(255, 200, 60, border_alpha),
  )
  @raylib.draw_rectangle(
    0,
    0,
    4,
    @types.screen_h,
    @raylib.Color::new(255, 200, 60, border_alpha),
  )
  @raylib.draw_rectangle(
    @types.screen_w - 4,
    0,
    4,
    @types.screen_h,
    @raylib.Color::new(255, 200, 60, border_alpha),
  )
}

///|
/// Draws the score tally with star animation on results screen.
pub fn draw_star_tally(game : @types.Game) -> Unit {
  let stars = game.result_stars
  let anim_t = @types.clampf(
    game.star_anim_timer / @types.star_anim_duration,
    0.0,
    1.0,
  )
  // Draw up to 3 stars
  for i in 0..<3 {
    let star_x = @types.screen_w / 2 - 100 + i * 100
    let star_y = 490
    let filled = i < stars
    let star_anim = @types.clampf(
      anim_t * 3.0 - Float::from_int(i),
      0.0,
      1.0,
    )
    if filled && star_anim > 0.0 {
      // Animated filled star
      let scale = 0.5F + star_anim * 0.5F
      let size = (30.0F * scale + 0.5F).to_int()
      let alpha = (star_anim * 255.0).to_int().clamp(min=0, max=255)
      draw_star_shape(star_x, star_y, size, @raylib.Color::new(255, 220, 60, alpha))
      // Sparkle effect during animation
      if star_anim > 0.3 && star_anim < 0.9 {
        let sparkle_alpha = ((star_anim - 0.3) * 200.0).to_int().clamp(
          min=0,
          max=150,
        )
        @raylib.draw_circle(
          star_x,
          star_y,
          Float::from_int(size) * 1.5,
          @raylib.Color::new(255, 255, 200, sparkle_alpha / 3),
        )
      }
    } else if !(filled) {
      // Empty star outline
      draw_star_shape(star_x, star_y, 30, @raylib.Color::new(80, 80, 100, 120))
    }
  }
}

///|
/// Draws a simple star shape using triangles.
fn draw_star_shape(cx : Int, cy : Int, size : Int, color : @raylib.Color) -> Unit {
  let s = Float::from_int(size)
  let fcx = Float::from_int(cx)
  let fcy = Float::from_int(cy)
  // Draw a simple 5-pointed star approximation using triangles
  // Top triangle
  @raylib.draw_triangle(
    @raylib.Vector2::new(fcx, fcy - s),
    @raylib.Vector2::new(fcx - s * 0.3, fcy - s * 0.15),
    @raylib.Vector2::new(fcx + s * 0.3, fcy - s * 0.15),
    color,
  )
  // Left triangle
  @raylib.draw_triangle(
    @raylib.Vector2::new(fcx - s, fcy - s * 0.3),
    @raylib.Vector2::new(fcx - s * 0.15, fcy + s * 0.1),
    @raylib.Vector2::new(fcx - s * 0.3, fcy - s * 0.15),
    color,
  )
  // Right triangle
  @raylib.draw_triangle(
    @raylib.Vector2::new(fcx + s * 0.3, fcy - s * 0.15),
    @raylib.Vector2::new(fcx + s * 0.15, fcy + s * 0.1),
    @raylib.Vector2::new(fcx + s, fcy - s * 0.3),
    color,
  )
  // Bottom-left triangle
  @raylib.draw_triangle(
    @raylib.Vector2::new(fcx - s * 0.15, fcy + s * 0.1),
    @raylib.Vector2::new(fcx - s * 0.6, fcy + s),
    @raylib.Vector2::new(fcx, fcy + s * 0.35),
    color,
  )
  // Bottom-right triangle
  @raylib.draw_triangle(
    @raylib.Vector2::new(fcx + s * 0.15, fcy + s * 0.1),
    @raylib.Vector2::new(fcx, fcy + s * 0.35),
    @raylib.Vector2::new(fcx + s * 0.6, fcy + s),
    color,
  )
  // Center pentagon fill
  @raylib.draw_triangle(
    @raylib.Vector2::new(fcx, fcy - s * 0.15),
    @raylib.Vector2::new(fcx - s * 0.3, fcy - s * 0.15),
    @raylib.Vector2::new(fcx - s * 0.15, fcy + s * 0.1),
    color,
  )
  @raylib.draw_triangle(
    @raylib.Vector2::new(fcx, fcy - s * 0.15),
    @raylib.Vector2::new(fcx - s * 0.15, fcy + s * 0.1),
    @raylib.Vector2::new(fcx, fcy + s * 0.35),
    color,
  )
  @raylib.draw_triangle(
    @raylib.Vector2::new(fcx, fcy - s * 0.15),
    @raylib.Vector2::new(fcx, fcy + s * 0.35),
    @raylib.Vector2::new(fcx + s * 0.15, fcy + s * 0.1),
    color,
  )
  @raylib.draw_triangle(
    @raylib.Vector2::new(fcx, fcy - s * 0.15),
    @raylib.Vector2::new(fcx + s * 0.15, fcy + s * 0.1),
    @raylib.Vector2::new(fcx + s * 0.3, fcy - s * 0.15),
    color,
  )
}

///|
/// Draws the upgrade shop screen.
pub fn draw_upgrade_screen(game : @types.Game) -> Unit {
  @draw.draw_text(
    "UPGRADES",
    @types.screen_w / 2 - 80,
    60,
    40,
    @raylib.Color::new(240, 200, 60, 255),
  )
  @draw.draw_text(
    "Score: " + game.total_score.to_string(),
    @types.screen_w / 2 - 60,
    110,
    24,
    @raylib.Color::new(100, 220, 140, 255),
  )
  for i in 0..<game.upgrades.length() {
    let upgrade = game.upgrades[i]
    let ux = 300
    let uy = 170 + i * 80
    let uw = 1100
    let uh = 70
    let bg = if upgrade.purchased {
      @raylib.Color::new(40, 80, 40, 180)
    } else if game.total_score >= upgrade.cost {
      @raylib.Color::new(40, 50, 80, 200)
    } else {
      @raylib.Color::new(30, 30, 40, 150)
    }
    @raylib.draw_rectangle(ux, uy, uw, uh, bg)
    @raylib.draw_rectangle_lines(
      ux,
      uy,
      uw,
      uh,
      if upgrade.purchased {
        @raylib.Color::new(100, 200, 100, 180)
      } else {
        @raylib.Color::new(80, 100, 140, 180)
      },
    )
    let name_color = if upgrade.purchased {
      @raylib.Color::new(120, 200, 120, 255)
    } else {
      @raylib.Color::new(220, 220, 240, 255)
    }
    let status = if upgrade.purchased {
      " [OWNED]"
    } else {
      " [" + upgrade.cost.to_string() + " pts]"
    }
    @draw.draw_text(
      (i + 1).to_string() + ". " + upgrade.name + status,
      ux + 16,
      uy + 10,
      20,
      name_color,
    )
    @draw.draw_text(
      upgrade.description,
      ux + 16,
      uy + 38,
      16,
      @raylib.Color::new(160, 170, 190, 200),
    )
  }
  @draw.draw_text(
    "[1-8] Buy Upgrade  [Esc] Back to Level Select",
    @types.screen_w / 2 - 260,
    @types.screen_h - 40,
    18,
    @raylib.Color::new(140, 150, 170, 160),
  )
}

///|
/// Draws the challenge select screen.
pub fn draw_challenge_select(game : @types.Game) -> Unit {
  ignore(game)
  @draw.draw_text(
    "CHALLENGE MODES",
    @types.screen_w / 2 - 140,
    60,
    40,
    @raylib.Color::new(240, 160, 60, 255),
  )
  let modes = @challenge.get_challenge_modes()
  for i in 0..<modes.length() {
    let mode = modes[i]
    let bx = @types.screen_w / 2 - 300
    let by = 160 + i * 130
    let bw = 600
    let bh = 110
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
      @raylib.Color::new(200, 140, 60, 180),
    )
    @draw.draw_text(
      (i + 1).to_string() + ". " + @challenge.challenge_mode_name(mode),
      bx + 16,
      by + 12,
      28,
      @raylib.Color::new(240, 200, 100, 255),
    )
    @draw.draw_text(
      @challenge.challenge_mode_description(mode),
      bx + 16,
      by + 50,
      18,
      @raylib.Color::new(180, 190, 210, 200),
    )
  }
  @draw.draw_text(
    "[1-4] Select Challenge  [Esc] Back",
    @types.screen_w / 2 - 200,
    @types.screen_h - 40,
    18,
    @raylib.Color::new(140, 150, 170, 160),
  )
}

///|
/// Draws the challenge HUD overlay during gameplay.
pub fn draw_challenge_hud(game : @types.Game) -> Unit {
  match game.challenge_state {
    None => ()
    Some(cs) => {
      let mode_name = @challenge.challenge_mode_name(cs.mode)
      @draw.draw_text(
        mode_name,
        20,
        10,
        24,
        @raylib.Color::new(240, 160, 60, 255),
      )
      let status = @challenge.challenge_status_text(cs)
      @draw.draw_text(
        status,
        20,
        40,
        20,
        @raylib.Color::new(200, 200, 220, 200),
      )
      let ht = (game.tower_height + 0.5).to_int()
      @draw.draw_text(
        "Height: " + ht.to_string() + "px",
        20,
        66,
        18,
        @raylib.Color::new(180, 200, 220, 200),
      )
      // Draw target line for precision mode
      match cs.mode {
        Precision => {
          let target_y = (game.world.ground_y - cs.target_height).to_int()
          @raylib.draw_line(
            @types.build_area_left.to_int(),
            target_y,
            @types.build_area_right.to_int(),
            target_y,
            @raylib.Color::new(255, 100, 100, 150),
          )
          @draw.draw_text(
            "TARGET",
            @types.build_area_left.to_int() - 70,
            target_y - 8,
            14,
            @raylib.Color::new(255, 100, 100, 150),
          )
          // Tolerance band
          let tol_top = target_y - @types.precision_tolerance.to_int()
          let tol_bot = target_y + @types.precision_tolerance.to_int()
          @raylib.draw_rectangle(
            @types.build_area_left.to_int(),
            tol_top,
            (@types.build_area_right - @types.build_area_left).to_int(),
            tol_bot - tol_top,
            @raylib.Color::new(100, 255, 100, 20),
          )
        }
        _ => ()
      }
    }
  }
}

///|
/// Draws the challenge results screen.
pub fn draw_challenge_results(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(0, 0, 0, 140),
  )
  @draw.draw_text(
    "CHALLENGE COMPLETE",
    @types.screen_w / 2 - 180,
    180,
    44,
    @raylib.Color::new(240, 200, 60, 255),
  )
  match game.challenge_state {
    None => ()
    Some(cs) => {
      let mode_name = @challenge.challenge_mode_name(cs.mode)
      @draw.draw_text(
        mode_name,
        @types.screen_w / 2 - 80,
        250,
        28,
        @raylib.Color::new(240, 160, 60, 255),
      )
      @draw.draw_text(
        "Score: " + cs.challenge_score.to_string(),
        @types.screen_w / 2 - 80,
        310,
        32,
        @raylib.Color::new(100, 220, 140, 255),
      )
      let stars = @challenge.challenge_stars(cs)
      draw_star_tally_at(
        @types.screen_w / 2 - 100,
        380,
        stars,
        game.star_anim_timer,
      )
    }
  }
  @draw.draw_text(
    "[Enter] Continue  [R] Retry  [Esc] Back",
    @types.screen_w / 2 - 240,
    @types.screen_h - 40,
    18,
    @raylib.Color::new(140, 150, 170, 160),
  )
}

///|
/// Draws stars at a specific position with animation.
fn draw_star_tally_at(x : Int, y : Int, stars : Int, anim_timer : Float) -> Unit {
  let anim_t = @types.clampf(anim_timer / @types.star_anim_duration, 0.0, 1.0)
  for i in 0..<3 {
    let star_x = x + i * 100
    let filled = i < stars
    let star_anim = @types.clampf(
      anim_t * 3.0 - Float::from_int(i),
      0.0,
      1.0,
    )
    if filled && star_anim > 0.0 {
      let scale = 0.5F + star_anim * 0.5F
      let size = (25.0F * scale + 0.5F).to_int()
      let alpha = (star_anim * 255.0).to_int().clamp(min=0, max=255)
      draw_star_shape(star_x, y, size, @raylib.Color::new(255, 220, 60, alpha))
    } else if !(filled) {
      draw_star_shape(star_x, y, 25, @raylib.Color::new(80, 80, 100, 120))
    }
  }
}

///|
/// Draws the blueprint ghost preview when a blueprint is selected.
pub fn draw_blueprint_ghost(game : @types.Game) -> Unit {
  if game.selected_blueprint < 0 ||
    game.selected_blueprint >= game.blueprints.length() {
    return
  }
  let bp = game.blueprints[game.selected_blueprint]
  let cx = game.ghost_x
  let cy = game.ghost_y
  for p in bp.pieces {
    let (kind, _, ox, oy, _) = p
    let (w, h) = @types.piece_dimensions(kind)
    let px = (cx + ox).to_int()
    let py = (cy + oy).to_int()
    let hw = (w * 0.5).to_int()
    let hh = (h * 0.5).to_int()
    @raylib.draw_rectangle(
      px - hw,
      py - hh,
      hw * 2,
      hh * 2,
      @raylib.Color::new(100, 255, 100, 50),
    )
    @raylib.draw_rectangle_lines(
      px - hw,
      py - hh,
      hw * 2,
      hh * 2,
      @raylib.Color::new(100, 255, 100, 120),
    )
  }
  // Draw blueprint name
  @draw.draw_text(
    bp.name + " [" + bp.cost.to_string() + "]",
    cx.to_int() - 40,
    cy.to_int() - 20,
    14,
    @raylib.Color::new(100, 255, 100, 180),
  )
}

///|
/// Draws the collapse replay overlay.
pub fn draw_replay_overlay(game : @types.Game) -> Unit {
  let dest = game.destruction
  if !(dest.replay_active) {
    return
  }
  let alpha = (@types.clampf(
      dest.replay_timer / 3.0,
      0.0,
      1.0,
    ) *
    200.0).to_int()
  @draw.draw_text(
    "REPLAY",
    @types.screen_w / 2 - 50,
    60,
    28,
    @raylib.Color::new(255, 100, 100, alpha),
  )
  // Red border
  let border_alpha = alpha / 3
  @raylib.draw_rectangle_lines(
    2,
    2,
    @types.screen_w - 4,
    @types.screen_h - 4,
    @raylib.Color::new(255, 60, 60, border_alpha),
  )
}
