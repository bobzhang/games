///|
let white : @raylib.Color = @raylib.Color::new(255, 255, 255, 255)

///|
let black : @raylib.Color = @raylib.Color::new(0, 0, 0, 255)

///|
let dark_gray : @raylib.Color = @raylib.Color::new(40, 40, 40, 255)

///|
let light_gray : @raylib.Color = @raylib.Color::new(200, 200, 200, 255)

///|
let shadow_color : @raylib.Color = @raylib.Color::new(0, 0, 0, 80)

///|
let title_blue : @raylib.Color = @raylib.Color::new(80, 160, 255, 255)

///|
let gravity_arrow_color : @raylib.Color = @raylib.Color::new(255, 255, 100, 200)

///|
pub fn draw_game(game : @types.Game) -> Unit {
  match game.screen {
    Title => draw_title(game)
    Playing => draw_playing(game)
    LevelComplete => draw_level_complete(game)
    WorldSelect => draw_world_select(game)
    LevelSelect => draw_level_select(game)
    Paused => {
      draw_playing(game)
      draw_pause_overlay(game)
    }
    Editor => @editor.draw_editor(game)
    Statistics => draw_statistics(game)
  }
  // Always draw achievement toasts on top
  draw_achievement_toast(game)
}

///|
fn draw_title(game : @types.Game) -> Unit {
  @raylib.clear_background(dark_gray)
  let text_size = get_text_size(game, 48)
  let sub_size = get_text_size(game, 20)
  let small_size = get_text_size(game, 18)
  @draw.draw_text("GRAVITY PUZZLER", 200, 150, text_size, title_blue)
  @draw.draw_text("Rotate gravity to solve puzzles!", 220, 230, sub_size, light_gray)
  @draw.draw_text(
    "Get the orb to the exit.", 280, 270, sub_size, light_gray,
  )
  // Draw a spinning gravity indicator
  let cx = @types.screen_w / 2
  let cy = 400
  let radius : Float = 40.0
  @raylib.draw_circle_lines(cx, cy, radius, @types.color_player)
  @raylib.draw_circle(cx, cy, 12.0, @types.color_player)
  // Gravity arrow pointing down
  @raylib.draw_triangle(
    @raylib.Vector2::new(Float::from_int(cx), Float::from_int(cy) + radius + 20.0),
    @raylib.Vector2::new(
      Float::from_int(cx) - 12.0, Float::from_int(cy) + radius + 4.0,
    ),
    @raylib.Vector2::new(
      Float::from_int(cx) + 12.0, Float::from_int(cy) + radius + 4.0,
    ),
    gravity_arrow_color,
  )
  @draw.draw_text("[ENTER] Start", 380, 490, 24, white)
  @draw.draw_text("[L] Level Editor  [T] Speedrun Timer", 240, 528, small_size, light_gray)
  @draw.draw_text("[A] Accessibility  [S] Statistics", 260, 558, small_size, light_gray)
  @draw.draw_text("Q/E: Rotate Gravity  Arrows: Move", 220, 588, small_size, light_gray)
  @draw.draw_text("Z: Undo  R: Restart  H: Hint  V: Ghost", 210, 618, small_size, light_gray)
  // Accessibility mode indicator
  let mode_text = match game.accessibility {
    Normal => ""
    HighContrast => "[High Contrast Mode]"
    LargeText => "[Large Text Mode]"
  }
  if mode_text.length() > 0 {
    @draw.draw_text(mode_text, 350, 660, 16, @raylib.Color::new(255, 255, 100, 180))
  }
}

///|
fn draw_world_select(game : @types.Game) -> Unit {
  @raylib.clear_background(dark_gray)
  @draw.draw_text("SELECT WORLD", 320, 40, get_text_size(game, 36), white)
  for w in 0..< @types.num_worlds {
    let bx = 80 + w * 160
    let by = 160
    let bw = 140
    let bh = 180
    let theme = @types.world_theme_of(w)
    let bg = if w == game.current_world {
      @types.world_wall_color(theme)
    } else {
      @types.world_floor_color(theme)
    }
    @raylib.draw_rectangle(bx, by, bw, bh, bg)
    if w == game.current_world {
      @raylib.draw_rectangle_lines(bx, by, bw, bh, white)
      // High contrast: double border
      match game.accessibility {
        HighContrast =>
          @raylib.draw_rectangle_lines(bx - 1, by - 1, bw + 2, bh + 2, white)
        _ => ()
      }
    }
    let name = @types.world_name(w)
    @draw.draw_text(name, bx + 10, by + 20, get_text_size(game, 16), white)
    // Show unlock status
    let unlocked = game.levels_unlocked[w]
    let status = if unlocked <= 0 {
      "LOCKED"
    } else {
      unlocked.to_string() + "/10"
    }
    @draw.draw_text(status, bx + 10, by + 55, get_text_size(game, 20), light_gray)
    // Show stars for this world
    let mut world_stars = 0
    for l in 0..< @types.levels_per_world {
      let idx = w * @types.levels_per_world + l
      if idx < game.level_stars.length() {
        world_stars = world_stars + game.level_stars[idx]
      }
    }
    let star_text = world_stars.to_string() + "/30 stars"
    @draw.draw_text(star_text, bx + 10, by + 95, get_text_size(game, 14), @types.color_star_gold)
    // Completion percentage
    if unlocked > 0 {
      let max_stars = @types.levels_per_world * 3
      let pct = if max_stars > 0 { world_stars * 100 / max_stars } else { 0 }
      let pct_text = pct.to_string() + "%"
      @draw.draw_text(pct_text, bx + 10, by + 120, get_text_size(game, 14), light_gray)
    }
  }
  @draw.draw_text(
    "Total Stars: " + game.total_stars.to_string() + "/" + (@types.total_levels * 3).to_string(),
    310, 400, get_text_size(game, 24), @types.color_star_gold,
  )
  // Achievement progress
  let ach_count = count_achievements_unlocked(game)
  let ach_total = game.achievement_state.achievements.length()
  let ach_text = "Achievements: " + ach_count.to_string() + "/" + ach_total.to_string()
  @draw.draw_text(ach_text, 340, 440, get_text_size(game, 18), @raylib.Color::new(255, 215, 0, 200))
  @draw.draw_text("[ENTER] Select  [ESC] Back", 300, 520, get_text_size(game, 20), light_gray)
  @draw.draw_text("[LEFT/RIGHT] Navigate", 340, 560, get_text_size(game, 18), light_gray)
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let theme = @types.world_theme_of(game.current_world)
  @raylib.clear_background(@types.world_bg_color(theme))
  let name = @types.world_name(game.current_world)
  @draw.draw_text(name, 360, 30, 32, white)
  let unlocked = game.levels_unlocked[game.current_world]
  for l in 0..< @types.levels_per_world {
    let col = l % 5
    let row = l / 5
    let bx = 160 + col * 130
    let by = 120 + row * 160
    let bw = 110
    let bh = 130
    let is_unlocked = l < unlocked
    let is_selected = l == game.current_level
    let bg = if is_selected {
      @types.world_wall_color(theme)
    } else if is_unlocked {
      @types.world_floor_color(theme)
    } else {
      @raylib.Color::new(30, 30, 30, 255)
    }
    @raylib.draw_rectangle(bx, by, bw, bh, bg)
    if is_selected {
      @raylib.draw_rectangle_lines(bx, by, bw, bh, white)
    }
    let label = (l + 1).to_string()
    @draw.draw_text(
      label, bx + 45, by + 15, 28, if is_unlocked { white } else { light_gray },
    )
    // Draw stars and best moves
    if is_unlocked {
      let global_idx = game.current_world * @types.levels_per_world + l
      let stars = if global_idx < game.level_stars.length() {
        game.level_stars[global_idx]
      } else {
        0
      }
      draw_star_rating(bx + 18, by + 70, stars, 16.0)
      // Show best moves vs par
      draw_level_best_info(game, bx, by, game.current_world, l)
    }
    // High contrast: extra selection border
    if is_selected {
      match game.accessibility {
        HighContrast => {
          @raylib.draw_rectangle_lines(bx - 1, by - 1, bw + 2, bh + 2, white)
          @raylib.draw_rectangle_lines(bx - 2, by - 2, bw + 4, bh + 4, white)
        }
        _ => ()
      }
    }
  }
  // Show selected level name and hint
  let sel_name = @content.get_level_name(game.current_world, game.current_level)
  @draw.draw_text(
    sel_name, 370, 460, get_text_size(game, 22), white,
  )
  // Show level-specific hint text
  let hint_text = @content.get_level_hint(game.current_world, game.current_level)
  @draw.draw_text(
    hint_text, 200, 490, get_text_size(game, 14),
    @raylib.Color::new(200, 200, 150, 180),
  )
  @draw.draw_text(
    "[ENTER] Play  [ESC] Back", 310, 530, get_text_size(game, 20), light_gray,
  )
}

///|
fn draw_playing(game : @types.Game) -> Unit {
  let level = match game.level {
    Some(l) => l
    None => return
  }
  let theme = @types.world_theme_of(level.world)
  @raylib.clear_background(@types.world_bg_color(theme))
  // Draw ambient background particles
  @effects.draw_ambient(game)
  // Draw grid with accessibility support
  draw_grid_with_access(level, theme, game.accessibility)
  // Draw wall shadows
  @effects.draw_wall_shadows(level)
  // Draw world-specific tiles (pressure plates, mirrors, etc.)
  @effects.draw_world_tiles(level, game.frame_count)
  // Draw exit portal glow
  @effects.draw_exit_glow(level, game.frame_count)
  // Draw entities
  draw_entities(level, game)
  // Draw enemy tracking lines and warnings
  @effects.draw_enemy_tracking_lines(level, game.frame_count)
  @effects.draw_enemy_warning(level, game.frame_count)
  // Draw high contrast overlays if enabled
  match game.accessibility {
    HighContrast => draw_high_contrast_overlays(level)
    _ => ()
  }
  // Draw ghost replay
  @replay.draw_ghost(game)
  // Draw game particles
  @particles.draw_particles(game)
  // Draw HUD
  draw_hud(level, game)
  // Draw ghost HUD info
  @replay.draw_ghost_hud(game)
  // Draw gravity indicator
  draw_gravity_indicator(level, game)
  // Draw gravity rotation visual
  @effects.draw_gravity_rotation(game)
  // Draw hint overlay
  @hints.draw_hint(game)
  // Draw speedrun timer
  @effects.draw_speedrun_timer(game)
  // Draw message
  if game.message_timer > 0.0 {
    let alpha = if game.message_timer < 0.5 {
      (game.message_timer * 2.0 * 255.0).to_int()
    } else {
      255
    }
    let c = @raylib.Color::new(255, 255, 255, alpha)
    @draw.draw_text(game.message_text, 300, 350, 24, c)
  }
}

///|
fn draw_grid_with_access(
  level : @types.Level,
  theme : @types.WorldTheme,
  accessibility : @types.AccessibilityMode
) -> Unit {
  let wall_color = @types.world_wall_color(theme)
  let floor_color = @types.world_floor_color(theme)
  let high_contrast = accessibility == HighContrast
  for y in 0..<level.height {
    for x in 0..<level.width {
      let px = @types.grid_offset_x + x * @types.tile_size
      let py = @types.grid_offset_y + y * @types.tile_size
      let tile = @types.get_tile(level, x, y)
      match tile {
        Wall => {
          @raylib.draw_rectangle(px, py, @types.tile_size, @types.tile_size, wall_color)
          // Wall border
          let border = if high_contrast {
            @raylib.Color::new(255, 255, 255, 120)
          } else {
            shadow_color
          }
          @raylib.draw_rectangle_lines(
            px, py, @types.tile_size, @types.tile_size, border,
          )
          // High contrast: cross-hatch pattern on walls
          if high_contrast {
            let line_color = @raylib.Color::new(255, 255, 255, 40)
            @raylib.draw_line(px, py, px + @types.tile_size, py + @types.tile_size, line_color)
            @raylib.draw_line(px + @types.tile_size, py, px, py + @types.tile_size, line_color)
          }
        }
        Empty =>
          @raylib.draw_rectangle(px, py, @types.tile_size, @types.tile_size, floor_color)
        Exit => {
          @raylib.draw_rectangle(px, py, @types.tile_size, @types.tile_size, floor_color)
          // Exit marker - pulsing green circle
          let pulse_d = @math.sin(Float::from_int(px + py).to_double() * 0.1)
          let pulse = Float::from_double(pulse_d.abs()) * 0.3 + 0.7
          let radius = @types.tile_sizef * 0.35 * pulse
          let cx = Float::from_int(px) + @types.tile_sizef * 0.5
          let cy = Float::from_int(py) + @types.tile_sizef * 0.5
          @raylib.draw_circle(cx.to_int(), cy.to_int(), radius, @types.color_exit)
          @raylib.draw_circle_lines(
            cx.to_int(), cy.to_int(), @types.tile_sizef * 0.4, white,
          )
        }
        Spike => {
          @raylib.draw_rectangle(px, py, @types.tile_size, @types.tile_size, floor_color)
          // Draw spike triangles
          let x1 = Float::from_int(px) + @types.tile_sizef * 0.5
          let y1 = Float::from_int(py) + 4.0
          let x2 = Float::from_int(px) + 4.0
          let y2 = Float::from_int(py) + @types.tile_sizef - 4.0
          let x3 = Float::from_int(px) + @types.tile_sizef - 4.0
          let y3 = y2
          @raylib.draw_triangle(
            @raylib.Vector2::new(x1, y1),
            @raylib.Vector2::new(x2, y2),
            @raylib.Vector2::new(x3, y3),
            @types.color_spike,
          )
        }
        Ice => {
          @raylib.draw_rectangle(px, py, @types.tile_size, @types.tile_size, @types.color_ice)
          // Ice shimmer lines
          @raylib.draw_line(
            px + 8, py + 12, px + 20, py + 8, white,
          )
          @raylib.draw_line(
            px + 28, py + 24, px + 40, py + 20, white,
          )
        }
        Portal(id) => {
          @raylib.draw_rectangle(px, py, @types.tile_size, @types.tile_size, floor_color)
          // Portal ring
          let cx = Float::from_int(px) + @types.tile_sizef * 0.5
          let cy = Float::from_int(py) + @types.tile_sizef * 0.5
          let c = match id {
            1 => @raylib.Color::new(200, 100, 255, 255)
            2 => @raylib.Color::new(100, 200, 255, 255)
            _ => @raylib.Color::new(255, 200, 100, 255)
          }
          @raylib.draw_circle_lines(cx.to_int(), cy.to_int(), 18.0, c)
          @raylib.draw_circle_lines(cx.to_int(), cy.to_int(), 14.0, c)
          let label = id.to_string()
          @draw.draw_text(label, cx.to_int() - 4, cy.to_int() - 8, 16, c)
        }
        Switch(id) => {
          @raylib.draw_rectangle(px, py, @types.tile_size, @types.tile_size, floor_color)
          // Switch button
          @raylib.draw_rectangle(px + 12, py + 12, 24, 24, @types.color_switch)
          let label = id.to_string()
          @draw.draw_text(label, px + 20, py + 14, 16, black)
        }
        Gate(id) => {
          // Gate bars
          @raylib.draw_rectangle(px, py, @types.tile_size, @types.tile_size, @types.color_gate)
          // Vertical bars
          for i in 0..<4 {
            let bx = px + 6 + i * 12
            @raylib.draw_rectangle(
              bx, py + 2, 4, @types.tile_size - 4, @raylib.Color::new(200, 140, 20, 255),
            )
          }
          let label = id.to_string()
          @draw.draw_text(label, px + 18, py + 16, 14, white)
        }
        Crumble => {
          // Crumbling tile - cracked appearance
          @raylib.draw_rectangle(
            px, py, @types.tile_size, @types.tile_size, @types.color_crumble,
          )
          // Crack lines
          @raylib.draw_line(
            px + 8, py + 8, px + 24, py + 24, shadow_color,
          )
          @raylib.draw_line(
            px + 32, py + 4, px + 20, py + 36, shadow_color,
          )
          @raylib.draw_line(
            px + 4, py + 28, px + 16, py + 40, shadow_color,
          )
        }
        Conveyor(dir) => {
          @raylib.draw_rectangle(
            px, py, @types.tile_size, @types.tile_size, @types.color_conveyor,
          )
          // Arrow showing direction
          let cx = Float::from_int(px) + @types.tile_sizef * 0.5
          let cy = Float::from_int(py) + @types.tile_sizef * 0.5
          let (adx, ady) = @types.gravity_vector(dir)
          let ax = cx + Float::from_int(adx) * 12.0
          let ay = cy + Float::from_int(ady) * 12.0
          @raylib.draw_line(
            cx.to_int(), cy.to_int(), ax.to_int(), ay.to_int(), white,
          )
        }
        // World-specific tiles: base floor drawn here, detail in effects
        PressurePlate(_) | Mirror(_) | GravityWell | TimedLava | WindGust(_) =>
          @raylib.draw_rectangle(px, py, @types.tile_size, @types.tile_size, floor_color)
      }
    }
  }
}

///|
fn draw_entities(level : @types.Level, game : @types.Game) -> Unit {
  for i in 0..<level.entities.length() {
    let e = level.entities[i]
    if !(e.active) {
      continue
    }
    // Calculate animated position
    let t : Float = 1.0 - e.slide_timer
    let px = @types.lerp(
      @types.tile_to_pixel_x(e.from_x), @types.tile_to_pixel_x(e.x), t,
    )
    // Apply bounce offset
    let bounce_off = @effects.get_bounce_offset(game, e.id)
    let py = @types.lerp(
      @types.tile_to_pixel_y(e.from_y), @types.tile_to_pixel_y(e.y), t,
    ) - bounce_off
    let cx = px + @types.tile_sizef * 0.5
    let cy = py + @types.tile_sizef * 0.5
    let half = @types.tile_sizef * 0.38
    match e.kind {
      Player => {
        // Player orb - glowing circle
        let pulse_d = @math.sin(game.frame_count.to_double() * 0.1)
        let pulse : Float = Float::from_double(pulse_d.abs()) * 4.0 + half
        @raylib.draw_circle(cx.to_int(), cy.to_int(), pulse, @types.color_player)
        // Inner highlight
        @raylib.draw_circle(
          cx.to_int() - 4, cy.to_int() - 4, half * 0.4, white,
        )
      }
      Box => {
        // Box - filled square
        let bx = px + @types.tile_sizef * 0.12
        let by = py + @types.tile_sizef * 0.12
        let bs = @types.tile_sizef * 0.76
        @raylib.draw_rectangle(
          bx.to_int(), by.to_int(), bs.to_int(), bs.to_int(), @types.color_box,
        )
        @raylib.draw_rectangle_lines(
          bx.to_int(), by.to_int(), bs.to_int(), bs.to_int(), shadow_color,
        )
      }
      Boulder => {
        // Boulder - pentagon approximated as circle with cross
        @raylib.draw_circle(
          cx.to_int(), cy.to_int(), half, @types.color_boulder,
        )
        @raylib.draw_line(
          (cx - half * 0.5).to_int(),
          cy.to_int(),
          (cx + half * 0.5).to_int(),
          cy.to_int(),
          shadow_color,
        )
        @raylib.draw_line(
          cx.to_int(),
          (cy - half * 0.5).to_int(),
          cx.to_int(),
          (cy + half * 0.5).to_int(),
          shadow_color,
        )
      }
      Key => {
        // Key - diamond shape
        let s = half * 0.8
        @raylib.draw_triangle(
          @raylib.Vector2::new(cx, cy - s),
          @raylib.Vector2::new(cx - s, cy),
          @raylib.Vector2::new(cx + s, cy),
          @types.color_key,
        )
        @raylib.draw_triangle(
          @raylib.Vector2::new(cx, cy + s),
          @raylib.Vector2::new(cx + s, cy),
          @raylib.Vector2::new(cx - s, cy),
          @types.color_key,
        )
      }
      Gem => {
        // Gem - star shape (simplified as a bright diamond + circle)
        let s = half * 0.6
        @raylib.draw_circle(
          cx.to_int(), cy.to_int(), s, @types.color_gem,
        )
        @raylib.draw_triangle(
          @raylib.Vector2::new(cx, cy - half),
          @raylib.Vector2::new(cx - s * 0.5, cy),
          @raylib.Vector2::new(cx + s * 0.5, cy),
          @types.color_gem,
        )
        @raylib.draw_triangle(
          @raylib.Vector2::new(cx, cy + half),
          @raylib.Vector2::new(cx + s * 0.5, cy),
          @raylib.Vector2::new(cx - s * 0.5, cy),
          @types.color_gem,
        )
      }
      Enemy => {
        // Enemy - red spiky circle with angry expression
        let enemy_pulse = Float::from_double(@math.sin(game.frame_count.to_double() * 0.12).abs()) * 3.0
        let radius = half + enemy_pulse
        @raylib.draw_circle(cx.to_int(), cy.to_int(), radius, @types.color_enemy)
        // Draw "spikes" around the enemy (4 triangular protrusions)
        let spike_len = half * 0.4
        // Top spike
        @raylib.draw_triangle(
          @raylib.Vector2::new(cx, cy - radius - spike_len),
          @raylib.Vector2::new(cx - 4.0, cy - radius + 2.0),
          @raylib.Vector2::new(cx + 4.0, cy - radius + 2.0),
          @types.color_enemy,
        )
        // Bottom spike
        @raylib.draw_triangle(
          @raylib.Vector2::new(cx, cy + radius + spike_len),
          @raylib.Vector2::new(cx + 4.0, cy + radius - 2.0),
          @raylib.Vector2::new(cx - 4.0, cy + radius - 2.0),
          @types.color_enemy,
        )
        // Left spike
        @raylib.draw_triangle(
          @raylib.Vector2::new(cx - radius - spike_len, cy),
          @raylib.Vector2::new(cx - radius + 2.0, cy + 4.0),
          @raylib.Vector2::new(cx - radius + 2.0, cy - 4.0),
          @types.color_enemy,
        )
        // Right spike
        @raylib.draw_triangle(
          @raylib.Vector2::new(cx + radius + spike_len, cy),
          @raylib.Vector2::new(cx + radius - 2.0, cy - 4.0),
          @raylib.Vector2::new(cx + radius - 2.0, cy + 4.0),
          @types.color_enemy,
        )
        // Eyes (white dots with dark pupils)
        @raylib.draw_circle(
          (cx - 5.0).to_int(), (cy - 3.0).to_int(), 4.0, white,
        )
        @raylib.draw_circle(
          (cx + 5.0).to_int(), (cy - 3.0).to_int(), 4.0, white,
        )
        @raylib.draw_circle(
          (cx - 5.0).to_int(), (cy - 3.0).to_int(), 2.0, black,
        )
        @raylib.draw_circle(
          (cx + 5.0).to_int(), (cy - 3.0).to_int(), 2.0, black,
        )
      }
    }
    // High contrast mode: draw extra border around all entities
    match game.accessibility {
      HighContrast => {
        let border_color = @raylib.Color::new(255, 255, 255, 200)
        @raylib.draw_circle_lines(cx.to_int(), cy.to_int(), half + 2.0, border_color)
      }
      _ => ()
    }
  }
}

///|
fn draw_gravity_indicator(level : @types.Level, game : @types.Game) -> Unit {
  // Draw gravity direction indicator in top-right
  let ix = @types.screen_w - 80
  let iy = 30
  let radius : Float = 28.0
  @raylib.draw_circle_lines(ix, iy, radius, light_gray)
  // Arrow direction
  let (dx, dy) = @types.gravity_vector(level.gravity)
  let ax = Float::from_int(ix) + Float::from_int(dx) * 18.0
  let ay = Float::from_int(iy) + Float::from_int(dy) * 18.0
  @raylib.draw_line(ix, iy, ax.to_int(), ay.to_int(), gravity_arrow_color)
  // Arrow head
  let ahx = Float::from_int(ix) + Float::from_int(dx) * radius
  let ahy = Float::from_int(iy) + Float::from_int(dy) * radius
  @raylib.draw_circle(ahx.to_int(), ahy.to_int(), 6.0, gravity_arrow_color)
  // Label
  let dir_label = match level.gravity {
    Down => "v"
    Up => "^"
    Left => "<"
    Right => ">"
  }
  @draw.draw_text(dir_label, ix - 4, iy - 8, 18, gravity_arrow_color)
  // Gravity rotation animation
  if game.gravity_anim_timer > 0.0 {
    let progress : Float = 1.0 - game.gravity_anim_timer / @types.gravity_anim_duration
    let fade : Float = 1.0 - progress
    let alpha = (fade * 128.0).to_int()
    let c = @raylib.Color::new(255, 255, 100, alpha)
    @raylib.draw_circle_lines(ix, iy, radius + 8.0, c)
  }
}

///|
fn draw_hud(level : @types.Level, game : @types.Game) -> Unit {
  let name_size = get_text_size(game, 24)
  let info_size = get_text_size(game, 20)
  let sub_size = get_text_size(game, 16)
  let small_size = get_text_size(game, 14)
  // Level name
  @draw.draw_text(level.name, 20, 10, name_size, white)
  // World/level indicator
  let wl = "W" +
    (level.world + 1).to_string() +
    "-" +
    (level.level_num + 1).to_string()
  @draw.draw_text(wl, 20, 40, get_text_size(game, 18), light_gray)
  // Moves counter
  let moves_text = "Moves: " + level.moves.to_string()
  @draw.draw_text(moves_text, 300, 10, info_size, white)
  // Par display
  let par_text = "Par: " + level.par_moves.to_string()
  @draw.draw_text(par_text, 300, 36, sub_size, light_gray)
  // Gems collected
  if level.gems_total > 0 {
    let gems_text = "Gems: " +
      level.gems_collected.to_string() +
      "/" +
      level.gems_total.to_string()
    @draw.draw_text(gems_text, 500, 10, info_size, @types.color_gem)
  }
  // Keys collected
  if level.keys_collected > 0 {
    let keys_text = "Keys: " + level.keys_collected.to_string()
    @draw.draw_text(keys_text, 500, 36, sub_size, @types.color_key)
  }
  // Hints remaining
  let hints_left = @hints.hints_remaining(game)
  let hint_text = "Hints: " + hints_left.to_string()
  @draw.draw_text(
    hint_text, 660, 36, sub_size, @raylib.Color::new(255, 255, 100, 180),
  )
  // Enemy count if enemies present
  let enemy_count = @types.count_active_enemies(level)
  if enemy_count > 0 {
    let enemy_text = "Enemies: " + enemy_count.to_string()
    @draw.draw_text(
      enemy_text, 660, 56, sub_size, @types.color_enemy,
    )
  }
  // Bottom controls hint
  @draw.draw_text(
    "Q/E:Rotate  Arrows:Move  Z:Undo  R:Restart  H:Hint  V:Ghost",
    110,
    @types.screen_h - 30,
    small_size,
    @raylib.Color::new(150, 150, 150, 180),
  )
}

///|
fn draw_star_rating(x : Int, y : Int, stars : Int, size : Float) -> Unit {
  for i in 0..<3 {
    let sx = Float::from_int(x + i * (size.to_int() + 8))
    let sy = Float::from_int(y)
    let c = if i < stars {
      match i {
        0 => @types.color_star_gold
        1 => @types.color_star_silver
        _ => @types.color_star_bronze
      }
    } else {
      @types.color_star_empty
    }
    // Draw a simple star shape (diamond)
    let half = size * 0.5
    let cx = sx + half
    let cy = sy + half
    @raylib.draw_triangle(
      @raylib.Vector2::new(cx, cy - half),
      @raylib.Vector2::new(cx - half * 0.5, cy),
      @raylib.Vector2::new(cx + half * 0.5, cy),
      c,
    )
    @raylib.draw_triangle(
      @raylib.Vector2::new(cx, cy + half * 0.7),
      @raylib.Vector2::new(cx + half * 0.5, cy),
      @raylib.Vector2::new(cx - half * 0.5, cy),
      c,
    )
  }
}

///|
fn draw_level_complete(game : @types.Game) -> Unit {
  let level = match game.level {
    Some(l) => l
    None => return
  }
  let theme = @types.world_theme_of(level.world)
  @raylib.clear_background(@types.world_bg_color(theme))
  // Draw the completed grid in background
  draw_grid_with_access(level, theme, game.accessibility)
  draw_entities(level, game)
  // Overlay
  @raylib.draw_rectangle(0, 0, @types.screen_w, @types.screen_h, shadow_color)
  @draw.draw_text("LEVEL COMPLETE!", 280, 170, get_text_size(game, 40), @types.color_exit)
  let moves_text = "Moves: " +
    level.moves.to_string() +
    "  (Par: " +
    level.par_moves.to_string() +
    ")"
  @draw.draw_text(moves_text, 300, 240, get_text_size(game, 24), white)
  // Best moves display
  let best = @game.get_best_moves(game, level.world, level.level_num)
  if best < 999 {
    let best_text = "Best: " + best.to_string() + " moves"
    @draw.draw_text(best_text, 300, 270, get_text_size(game, 16), light_gray)
  }
  // Star rating
  let stars = @types.calc_stars(level.moves, level.par_moves)
  draw_star_rating(380, 300, stars, 32.0)
  let rating = match stars {
    3 => "PERFECT!"
    2 => "Great!"
    1 => "Good"
    _ => "Complete"
  }
  @draw.draw_text(rating, 400, 360, get_text_size(game, 28), @types.color_star_gold)
  // Gems info
  if level.gems_total > 0 {
    let gems_text = "Gems: " +
      level.gems_collected.to_string() +
      "/" +
      level.gems_total.to_string()
    @draw.draw_text(gems_text, 400, 400, get_text_size(game, 20), @types.color_gem)
  }
  // No-undo and no-hint badges
  let mut badge_y = 430
  if !(game.used_undo_this_level) {
    @draw.draw_text(
      "No Undo!", 400, badge_y, get_text_size(game, 16),
      @raylib.Color::new(100, 255, 200, 255),
    )
    badge_y = badge_y + 22
  }
  if !(game.used_hint_this_level) {
    @draw.draw_text(
      "No Hints!", 400, badge_y, get_text_size(game, 16),
      @raylib.Color::new(255, 255, 100, 255),
    )
  }
  @draw.draw_text(
    "[ENTER] Next Level  [ESC] Level Select",
    240,
    500,
    get_text_size(game, 20),
    light_gray,
  )
}

///|
fn draw_pause_overlay(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0, 0, @types.screen_w, @types.screen_h, @raylib.Color::new(0, 0, 0, 160),
  )
  @draw.draw_text("PAUSED", 390, 280, get_text_size(game, 48), white)
  @draw.draw_text("[ESC] Resume", 380, 360, get_text_size(game, 24), light_gray)
  @draw.draw_text("[Q] Quit to Level Select", 340, 400, get_text_size(game, 20), light_gray)
}

///|
/// Draw the statistics screen
fn draw_statistics(game : @types.Game) -> Unit {
  @raylib.clear_background(dark_gray)
  let title_size = get_text_size(game, 36)
  let heading_size = get_text_size(game, 22)
  let text_size = get_text_size(game, 18)
  let small_size = get_text_size(game, 16)
  @draw.draw_text("STATISTICS", 370, 30, title_size, white)
  let stats = game.stats
  let sx = 200
  let mut sy = 90
  let gap = 30
  // Section: Gameplay Stats
  @draw.draw_text("-- Gameplay --", sx, sy, heading_size, @types.color_player)
  sy = sy + gap + 4
  @draw.draw_text(
    "Total Moves: " + stats.total_moves.to_string(), sx, sy, text_size, light_gray,
  )
  sy = sy + gap
  @draw.draw_text(
    "Gravity Rotations: " + stats.total_gravity_rotations.to_string(), sx, sy, text_size, light_gray,
  )
  sy = sy + gap
  @draw.draw_text(
    "Levels Completed: " + stats.total_levels_completed.to_string(), sx, sy, text_size, light_gray,
  )
  sy = sy + gap
  @draw.draw_text(
    "Total Stars: " + game.total_stars.to_string() + "/" + (@types.total_levels * 3).to_string(),
    sx, sy, text_size, @types.color_star_gold,
  )
  sy = sy + gap
  @draw.draw_text(
    "3-Star Levels: " + stats.levels_with_3_stars.to_string(), sx, sy, text_size, light_gray,
  )
  sy = sy + gap
  @draw.draw_text(
    "Best 3-Star Streak: " + stats.best_streak.to_string(), sx, sy, text_size, light_gray,
  )
  // Section: Collection Stats
  sy = sy + gap + 10
  @draw.draw_text("-- Collection --", sx, sy, heading_size, @types.color_gem)
  sy = sy + gap + 4
  @draw.draw_text(
    "Gems Collected: " + stats.total_gems_collected.to_string(), sx, sy, text_size, @types.color_gem,
  )
  sy = sy + gap
  @draw.draw_text(
    "Keys Collected: " + stats.total_keys_collected.to_string(), sx, sy, text_size, @types.color_key,
  )
  // Right column
  let rx = 550
  let mut ry = 90
  // Section: Challenge Stats
  @draw.draw_text("-- Challenge --", rx, ry, heading_size, @types.color_spike)
  ry = ry + gap + 4
  @draw.draw_text(
    "Deaths: " + stats.total_deaths.to_string(), rx, ry, text_size, @types.color_spike,
  )
  ry = ry + gap
  @draw.draw_text(
    "Undos Used: " + stats.total_undos.to_string(), rx, ry, text_size, light_gray,
  )
  ry = ry + gap
  @draw.draw_text(
    "Hints Used: " + stats.hint_uses.to_string(), rx, ry, text_size, light_gray,
  )
  ry = ry + gap
  @draw.draw_text(
    "Ice Slides: " + stats.total_ice_slides.to_string(), rx, ry, text_size, light_gray,
  )
  // Time played
  ry = ry + gap + 10
  @draw.draw_text("-- Time --", rx, ry, heading_size, title_blue)
  ry = ry + gap + 4
  let total_secs = stats.total_time_played.to_int()
  let mins = total_secs / 60
  let secs = total_secs % 60
  let hours = mins / 60
  let time_text = if hours > 0 {
    hours.to_string() + "h " + (mins % 60).to_string() + "m " + secs.to_string() + "s"
  } else {
    mins.to_string() + "m " + secs.to_string() + "s"
  }
  @draw.draw_text(
    "Time Played: " + time_text, rx, ry, text_size, light_gray,
  )
  // Favorite world
  ry = ry + gap
  let fav = @game.get_favorite_world(game)
  @draw.draw_text(
    "Favorite World: " + @types.world_name(fav), rx, ry, text_size, light_gray,
  )
  // Achievement summary
  ry = ry + gap + 10
  @draw.draw_text("-- Achievements --", rx, ry, heading_size, @raylib.Color::new(255, 215, 0, 255))
  ry = ry + gap + 4
  let ach_count = count_achievements_unlocked(game)
  let ach_total = game.achievement_state.achievements.length()
  @draw.draw_text(
    "Unlocked: " + ach_count.to_string() + "/" + ach_total.to_string(), rx, ry, text_size,
    @raylib.Color::new(255, 215, 0, 200),
  )
  // Show individual achievements
  ry = ry + gap
  let max_show = 5
  let mut shown = 0
  for i in 0..<game.achievement_state.achievements.length() {
    if shown >= max_show {
      break
    }
    let ach = game.achievement_state.achievements[i]
    if ach.unlocked {
      @draw.draw_text(
        "* " + ach.name, rx, ry, small_size,
        @raylib.Color::new(255, 215, 0, 160),
      )
      ry = ry + 22
      shown = shown + 1
    }
  }
  // Overall completion
  let completion = @game.get_total_completion(game)
  @draw.draw_text(
    "Overall Completion: " + completion.to_string() + "%",
    350, 600, get_text_size(game, 22),
    @types.color_star_gold,
  )
  // Draw completion bar
  let bar_x = 350
  let bar_y = 635
  let bar_w = 260
  let bar_h = 16
  let bar_bg = @raylib.Color::new(60, 60, 60, 200)
  let bar_fill = @types.color_star_gold
  @raylib.draw_rectangle(bar_x, bar_y, bar_w, bar_h, bar_bg)
  let fill_w = bar_w * completion / 100
  if fill_w > 0 {
    @raylib.draw_rectangle(bar_x, bar_y, fill_w, bar_h, bar_fill)
  }
  @raylib.draw_rectangle_lines(bar_x, bar_y, bar_w, bar_h, light_gray)
  @draw.draw_text("[ESC] Back", 420, 670, get_text_size(game, 20), light_gray)
}

///|
/// Draw the level select screen with best moves info
fn draw_level_best_info(game : @types.Game, bx : Int, by : Int, world : Int, level : Int) -> Unit {
  let best = @game.get_best_moves(game, world, level)
  if best < 999 {
    let par = @content.get_par_moves(world, level)
    let text = "Best:" + best.to_string() + "/" + par.to_string()
    let color = if best <= par {
      @types.color_star_gold
    } else {
      light_gray
    }
    @draw.draw_text(text, bx + 8, by + 95, get_text_size(game, 11), color)
  }
}

///|
/// Draw achievement toast notification (slides in from top)
fn draw_achievement_toast(game : @types.Game) -> Unit {
  let ach_state = game.achievement_state
  if ach_state.current_toast < 0 {
    return
  }
  if ach_state.current_toast >= ach_state.achievements.length() {
    return
  }
  let ach = ach_state.achievements[ach_state.current_toast]
  let progress : Float = ach_state.toast_timer / @types.toast_display_duration
  // Slide in from top: starts at -80, slides to y=10
  let point_two : Float = 0.2
  let point_eight : Float = 0.8
  let one : Float = 1.0
  let ninety : Float = 90.0
  let slide_in : Float = if progress > point_eight {
    let t : Float = (one - progress) / point_two
    -80.0 + t * ninety
  } else if progress < point_two {
    let t : Float = progress / point_two
    10.0 - (one - t) * ninety
  } else {
    10.0
  }
  let toast_y = slide_in.to_int()
  let toast_x = @types.screen_w / 2 - 180
  let toast_w = 360
  let toast_h = 70
  let bg_color = @raylib.Color::new(20, 20, 40, 220)
  @raylib.draw_rectangle(toast_x, toast_y, toast_w, toast_h, bg_color)
  let border_color = @raylib.Color::new(255, 215, 0, 200)
  @raylib.draw_rectangle_lines(toast_x, toast_y, toast_w, toast_h, border_color)
  // Trophy star
  let icon_cx = Float::from_int(toast_x + 30)
  let icon_cy = Float::from_int(toast_y + 35)
  let gold = @raylib.Color::new(255, 215, 0, 255)
  @raylib.draw_triangle(
    @raylib.Vector2::new(icon_cx, icon_cy - 12.0),
    @raylib.Vector2::new(icon_cx - 7.0, icon_cy + 2.0),
    @raylib.Vector2::new(icon_cx + 7.0, icon_cy + 2.0),
    gold,
  )
  @raylib.draw_triangle(
    @raylib.Vector2::new(icon_cx, icon_cy + 10.0),
    @raylib.Vector2::new(icon_cx + 7.0, icon_cy + 2.0),
    @raylib.Vector2::new(icon_cx - 7.0, icon_cy + 2.0),
    gold,
  )
  let text_size = get_text_size(game, 14)
  let name_size = get_text_size(game, 18)
  @draw.draw_text(
    "Achievement Unlocked!", toast_x + 55, toast_y + 10, text_size, gold,
  )
  @draw.draw_text(
    ach.name, toast_x + 55, toast_y + 35, name_size, white,
  )
}

///|
/// Draw high contrast pattern overlays on all non-empty tiles
fn draw_high_contrast_overlays(level : @types.Level) -> Unit {
  for y in 0..<level.height {
    for x in 0..<level.width {
      let px = @types.grid_offset_x + x * @types.tile_size
      let py = @types.grid_offset_y + y * @types.tile_size
      let tile = @types.get_tile(level, x, y)
      match tile {
        Empty | Wall => ()
        _ => @effects.draw_high_contrast_tile_overlay(px, py, tile)
      }
    }
  }
}

///|
/// Get text size based on accessibility mode
fn get_text_size(game : @types.Game, base : Int) -> Int {
  match game.accessibility {
    LargeText => {
      let scaled = (Float::from_int(base) * 1.4).to_int()
      scaled
    }
    _ => base
  }
}

///|
/// Count unlocked achievements (used by render)
fn count_achievements_unlocked(game : @types.Game) -> Int {
  let mut count = 0
  for i in 0..<game.achievement_state.achievements.length() {
    if game.achievement_state.achievements[i].unlocked {
      count = count + 1
    }
  }
  count
}
