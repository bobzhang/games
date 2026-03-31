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
  }
}

///|
fn draw_title(_game : @types.Game) -> Unit {
  @raylib.clear_background(dark_gray)
  @draw.draw_text("GRAVITY PUZZLER", 200, 150, 48, title_blue)
  @draw.draw_text("Rotate gravity to solve puzzles!", 220, 230, 20, light_gray)
  @draw.draw_text(
    "Get the orb to the exit.", 280, 270, 20, light_gray,
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
  @draw.draw_text("[ENTER] Start", 380, 520, 24, white)
  @draw.draw_text("Q/E: Rotate Gravity  Arrows: Move", 220, 580, 18, light_gray)
  @draw.draw_text("Z: Undo  R: Restart", 340, 620, 18, light_gray)
}

///|
fn draw_world_select(game : @types.Game) -> Unit {
  @raylib.clear_background(dark_gray)
  @draw.draw_text("SELECT WORLD", 320, 40, 36, white)
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
    }
    let name = @types.world_name(w)
    @draw.draw_text(name, bx + 10, by + 20, 16, white)
    // Show unlock status
    let unlocked = game.levels_unlocked[w]
    let status = if unlocked <= 0 {
      "LOCKED"
    } else {
      unlocked.to_string() + "/10"
    }
    @draw.draw_text(status, bx + 10, by + 60, 20, light_gray)
    // Show stars for this world
    let mut world_stars = 0
    for l in 0..< @types.levels_per_world {
      let idx = w * @types.levels_per_world + l
      if idx < game.level_stars.length() {
        world_stars = world_stars + game.level_stars[idx]
      }
    }
    let star_text = world_stars.to_string() + " stars"
    @draw.draw_text(star_text, bx + 10, by + 100, 16, @types.color_star_gold)
  }
  @draw.draw_text(
    "Total Stars: " + game.total_stars.to_string(), 360, 400, 24, @types.color_star_gold,
  )
  @draw.draw_text("[ENTER] Select  [ESC] Back", 300, 520, 20, light_gray)
  @draw.draw_text("[LEFT/RIGHT] Navigate", 340, 560, 18, light_gray)
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
    // Draw stars
    if is_unlocked {
      let global_idx = game.current_world * @types.levels_per_world + l
      let stars = if global_idx < game.level_stars.length() {
        game.level_stars[global_idx]
      } else {
        0
      }
      draw_star_rating(bx + 18, by + 70, stars, 16.0)
    }
  }
  @draw.draw_text(
    "[ENTER] Play  [ESC] Back", 310, 500, 20, light_gray,
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
  // Draw grid
  draw_grid(level, theme)
  // Draw entities
  draw_entities(level, game)
  // Draw HUD
  draw_hud(level, game)
  // Draw gravity indicator
  draw_gravity_indicator(level, game)
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
fn draw_grid(level : @types.Level, theme : @types.WorldTheme) -> Unit {
  let wall_color = @types.world_wall_color(theme)
  let floor_color = @types.world_floor_color(theme)
  for y in 0..<level.height {
    for x in 0..<level.width {
      let px = @types.grid_offset_x + x * @types.tile_size
      let py = @types.grid_offset_y + y * @types.tile_size
      let tile = @types.get_tile(level, x, y)
      match tile {
        Wall => {
          @raylib.draw_rectangle(px, py, @types.tile_size, @types.tile_size, wall_color)
          // Wall border
          @raylib.draw_rectangle_lines(
            px, py, @types.tile_size, @types.tile_size, shadow_color,
          )
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
    let py = @types.lerp(
      @types.tile_to_pixel_y(e.from_y), @types.tile_to_pixel_y(e.y), t,
    )
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
fn draw_hud(level : @types.Level, _game : @types.Game) -> Unit {
  // Level name
  @draw.draw_text(level.name, 20, 10, 24, white)
  // World/level indicator
  let wl = "W" +
    (level.world + 1).to_string() +
    "-" +
    (level.level_num + 1).to_string()
  @draw.draw_text(wl, 20, 40, 18, light_gray)
  // Moves counter
  let moves_text = "Moves: " + level.moves.to_string()
  @draw.draw_text(moves_text, 300, 10, 20, white)
  // Par display
  let par_text = "Par: " + level.par_moves.to_string()
  @draw.draw_text(par_text, 300, 36, 16, light_gray)
  // Gems collected
  if level.gems_total > 0 {
    let gems_text = "Gems: " +
      level.gems_collected.to_string() +
      "/" +
      level.gems_total.to_string()
    @draw.draw_text(gems_text, 500, 10, 20, @types.color_gem)
  }
  // Keys collected
  if level.keys_collected > 0 {
    let keys_text = "Keys: " + level.keys_collected.to_string()
    @draw.draw_text(keys_text, 500, 36, 16, @types.color_key)
  }
  // Bottom controls hint
  @draw.draw_text(
    "Q/E:Rotate  Arrows:Move  Z:Undo  R:Restart",
    180,
    @types.screen_h - 30,
    16,
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
  draw_grid(level, theme)
  draw_entities(level, game)
  // Overlay
  @raylib.draw_rectangle(0, 0, @types.screen_w, @types.screen_h, shadow_color)
  @draw.draw_text("LEVEL COMPLETE!", 280, 180, 40, @types.color_exit)
  let moves_text = "Moves: " +
    level.moves.to_string() +
    "  (Par: " +
    level.par_moves.to_string() +
    ")"
  @draw.draw_text(moves_text, 300, 260, 24, white)
  // Star rating
  let stars = @types.calc_stars(level.moves, level.par_moves)
  draw_star_rating(380, 310, stars, 32.0)
  let rating = match stars {
    3 => "PERFECT!"
    2 => "Great!"
    1 => "Good"
    _ => "Complete"
  }
  @draw.draw_text(rating, 400, 370, 28, @types.color_star_gold)
  // Gems info
  if level.gems_total > 0 {
    let gems_text = "Gems: " +
      level.gems_collected.to_string() +
      "/" +
      level.gems_total.to_string()
    @draw.draw_text(gems_text, 400, 420, 20, @types.color_gem)
  }
  @draw.draw_text(
    "[ENTER] Next Level  [ESC] Level Select",
    240,
    500,
    20,
    light_gray,
  )
}

///|
fn draw_pause_overlay(_game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0, 0, @types.screen_w, @types.screen_h, @raylib.Color::new(0, 0, 0, 160),
  )
  @draw.draw_text("PAUSED", 390, 280, 48, white)
  @draw.draw_text("[ESC] Resume", 380, 360, 24, light_gray)
  @draw.draw_text("[Q] Quit to Level Select", 340, 400, 20, light_gray)
}
