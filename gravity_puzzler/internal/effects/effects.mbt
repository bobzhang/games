///|
/// Per-world ambient effects: falling leaves, crystals, stars, embers, clouds
pub fn update_ambient(game : @types.Game, dt : Float) -> Unit {
  let amb = game.ambient
  let world = game.current_world
  // Update existing ambient particles
  let mut i = 0
  while i < amb.particles.length() {
    let p = amb.particles[i]
    p.life = p.life - dt
    if p.life <= 0.0 {
      let last = amb.particles.length() - 1
      if i < last {
        amb.particles[i] = amb.particles[last]
      }
      ignore(amb.particles.pop())
      continue
    }
    p.x = p.x + p.vx * dt
    p.y = p.y + p.vy * dt
    // Sway for leaves and crystals
    if p.kind == 0 || p.kind == 1 {
      p.x = p.x + Float::from_double(
        @math.sin((p.y * 0.02).to_double()),
      ) * 10.0 * dt
    }
    i = i + 1
  }
  // Spawn new particles
  amb.spawn_timer = amb.spawn_timer + dt
  if amb.spawn_timer >= @types.ambient_spawn_rate && amb.particles.length() < 60 {
    amb.spawn_timer = 0.0
    let rx = rand_float_eff(game) * Float::from_int(@types.screen_w)
    match world {
      0 => {
        // Stone Ruins: falling leaves
        let p = @types.Particle::new(
          rx, -10.0, rand_float_eff(game) * 20.0 - 10.0,
          20.0 + rand_float_eff(game) * 15.0, 6.0 + rand_float_eff(game) * 3.0,
          3.0 + rand_float_eff(game) * 2.0, 120, 100, 60, 0,
        )
        amb.particles.push(p)
      }
      1 => {
        // Crystal Caverns: drifting crystals
        let p = @types.Particle::new(
          rx, -10.0, rand_float_eff(game) * 10.0 - 5.0,
          15.0 + rand_float_eff(game) * 10.0, 8.0 + rand_float_eff(game) * 4.0,
          2.0 + rand_float_eff(game) * 3.0, 160, 120, 255, 1,
        )
        amb.particles.push(p)
      }
      2 => {
        // Void Expanse: drifting stars
        let p = @types.Particle::new(
          rx, rand_float_eff(game) * Float::from_int(@types.screen_h),
          rand_float_eff(game) * 6.0 - 3.0, rand_float_eff(game) * 4.0 - 2.0,
          4.0 + rand_float_eff(game) * 6.0, 1.5 + rand_float_eff(game) * 1.5,
          200, 200, 255, 2,
        )
        amb.particles.push(p)
      }
      3 => {
        // Magma Depths: rising embers
        let p = @types.Particle::new(
          rx, Float::from_int(@types.screen_h) + 10.0,
          rand_float_eff(game) * 16.0 - 8.0,
          -30.0 - rand_float_eff(game) * 20.0, 4.0 + rand_float_eff(game) * 3.0,
          2.0 + rand_float_eff(game) * 3.0, 255, 140, 40, 3,
        )
        amb.particles.push(p)
      }
      _ => {
        // Sky Citadel: drifting clouds
        let p = @types.Particle::new(
          -40.0, 50.0 + rand_float_eff(game) * Float::from_int(@types.screen_h - 100),
          10.0 + rand_float_eff(game) * 8.0, rand_float_eff(game) * 2.0 - 1.0,
          10.0 + rand_float_eff(game) * 8.0, 8.0 + rand_float_eff(game) * 12.0,
          220, 230, 240, 4,
        )
        amb.particles.push(p)
      }
    }
  }
}

///|
/// Draw ambient particles
pub fn draw_ambient(game : @types.Game) -> Unit {
  let amb = game.ambient
  for i in 0..<amb.particles.length() {
    let p = amb.particles[i]
    let alpha_f = p.life / p.max_life
    let alpha = (alpha_f * 120.0).to_int()
    let a = if alpha > 255 { 255 } else if alpha < 0 { 0 } else { alpha }
    let color = @raylib.Color::new(p.r, p.g, p.b, a)
    match p.kind {
      4 => {
        // Clouds: draw as ellipse (two overlapping circles)
        @raylib.draw_circle(p.x.to_int(), p.y.to_int(), p.size, color)
        @raylib.draw_circle(
          (p.x + p.size * 0.6).to_int(), p.y.to_int(), p.size * 0.8, color,
        )
      }
      _ => @raylib.draw_circle(p.x.to_int(), p.y.to_int(), p.size, color)
    }
  }
}

///|
/// Smooth gravity rotation animation: interpolate the visual rotation angle
pub fn update_gravity_rotation(game : @types.Game, dt : Float) -> Unit {
  let level = match game.level {
    Some(l) => l
    None => return
  }
  let target = @types.gravity_dir_to_angle(level.gravity)
  game.gravity_rot_target = target
  // Smoothly interpolate current angle toward target
  let diff = game.gravity_rot_target - game.gravity_rot_angle
  // Handle wrapping around 360
  let adjusted = if diff > 180.0 {
    diff - 360.0
  } else if diff < -180.0 {
    diff + 360.0
  } else {
    diff
  }
  let abs_adj = if adjusted > 0.0 { adjusted } else { -adjusted }
  if abs_adj > 0.5 {
    game.gravity_rot_angle = game.gravity_rot_angle + adjusted * @types.gravity_rot_speed * dt
    // Wrap to 0..360
    if game.gravity_rot_angle > 360.0 {
      game.gravity_rot_angle = game.gravity_rot_angle - 360.0
    }
    if game.gravity_rot_angle < 0.0 {
      game.gravity_rot_angle = game.gravity_rot_angle + 360.0
    }
  } else {
    game.gravity_rot_angle = game.gravity_rot_target
  }
}

///|
/// Draw gravity rotation visual indicator (rotating arrow in corner)
pub fn draw_gravity_rotation(game : @types.Game) -> Unit {
  let angle = game.gravity_rot_angle
  let rad = angle * 3.14159 / 180.0
  let cx = Float::from_int(@types.screen_w - 80)
  let cy : Float = 30.0
  let len : Float = 22.0
  let tip_x = cx + Float::from_double(@math.sin(rad.to_double())) * len
  let tip_y = cy + Float::from_double(@math.cos(rad.to_double())) * len
  let rot_color = @raylib.Color::new(255, 200, 100, 160)
  @raylib.draw_line(cx.to_int(), cy.to_int(), tip_x.to_int(), tip_y.to_int(), rot_color)
}

///|
/// Update entity bounce timers (triggered when entity lands)
pub fn update_bounce(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.bounce_timers.length() {
    if game.bounce_timers[i] > 0.0 {
      game.bounce_timers[i] = game.bounce_timers[i] - dt
      if game.bounce_timers[i] < 0.0 {
        game.bounce_timers[i] = 0.0
      }
    }
  }
}

///|
/// Trigger a bounce for an entity when it lands
pub fn trigger_bounce(game : @types.Game, entity_id : Int) -> Unit {
  if entity_id >= 0 && entity_id < game.bounce_timers.length() {
    game.bounce_timers[entity_id] = @types.bounce_duration
  }
}

///|
/// Get bounce offset for rendering (vertical squish-stretch)
pub fn get_bounce_offset(game : @types.Game, entity_id : Int) -> Float {
  if entity_id < 0 || entity_id >= game.bounce_timers.length() {
    return 0.0
  }
  let t = game.bounce_timers[entity_id]
  if t <= 0.0 {
    return 0.0
  }
  let progress = t / @types.bounce_duration
  // Bounce: sin curve for a quick squash-and-stretch
  Float::from_double(@math.sin(progress.to_double() * 3.14159)) * 4.0
}

///|
/// Draw wall shadow/depth effect
pub fn draw_wall_shadows(level : @types.Level) -> Unit {
  let shadow = @raylib.Color::new(0, 0, 0, 40)
  for y in 0..<level.height {
    for x in 0..<level.width {
      if @types.get_tile(level, x, y) == Wall {
        let px = @types.grid_offset_x + x * @types.tile_size
        let py = @types.grid_offset_y + y * @types.tile_size
        // Shadow on right and bottom edges
        let right_tile = @types.get_tile(level, x + 1, y)
        if right_tile != Wall {
          @raylib.draw_rectangle(
            px + @types.tile_size, py, 3, @types.tile_size, shadow,
          )
        }
        let bottom_tile = @types.get_tile(level, x, y + 1)
        if bottom_tile != Wall {
          @raylib.draw_rectangle(
            px, py + @types.tile_size, @types.tile_size, 3, shadow,
          )
        }
      }
    }
  }
}

///|
/// Draw exit portal pulsing glow effect
pub fn draw_exit_glow(level : @types.Level, frame_count : Int) -> Unit {
  for y in 0..<level.height {
    for x in 0..<level.width {
      if @types.get_tile(level, x, y) == Exit {
        let px = Float::from_int(@types.grid_offset_x + x * @types.tile_size) + @types.tile_sizef * 0.5
        let py = Float::from_int(@types.grid_offset_y + y * @types.tile_size) + @types.tile_sizef * 0.5
        let pulse_d = @math.sin(frame_count.to_double() * 0.05)
        let pulse = Float::from_double(pulse_d.abs())
        let radius : Float = pulse * 12.0 + 24.0
        let alpha = 40 + (pulse * 40.0).to_int()
        let glow_color = @raylib.Color::new(50, 255, 120, alpha)
        @raylib.draw_circle(px.to_int(), py.to_int(), radius, glow_color)
        // Outer ring
        let outer_alpha = 20 + (pulse * 20.0).to_int()
        let outer_color = @raylib.Color::new(50, 255, 120, outer_alpha)
        @raylib.draw_circle_lines(
          px.to_int(), py.to_int(), radius + 6.0, outer_color,
        )
      }
    }
  }
}

///|
/// Draw speedrun timer display
pub fn draw_speedrun_timer(game : @types.Game) -> Unit {
  if !(game.speedrun_active) {
    return
  }
  let total_secs = game.speedrun_timer.to_int()
  let mins = total_secs / 60
  let secs = total_secs % 60
  let tenths = ((game.speedrun_timer - Float::from_int(total_secs)) * 10.0).to_int()
  let timer_text = mins.to_string() +
    ":" +
    (if secs < 10 { "0" } else { "" }) +
    secs.to_string() +
    "." +
    tenths.to_string()
  @draw.draw_text(
    timer_text,
    @types.screen_w - 120,
    @types.screen_h - 30,
    18,
    @raylib.Color::new(200, 200, 200, 180),
  )
}

///|
/// Update speedrun timer
pub fn update_speedrun_timer(game : @types.Game, dt : Float) -> Unit {
  if game.speedrun_active {
    game.speedrun_timer = game.speedrun_timer + dt
  }
}

///|
/// Draw world-specific new tile types
pub fn draw_world_tiles(level : @types.Level, frame_count : Int) -> Unit {
  for y in 0..<level.height {
    for x in 0..<level.width {
      let px = @types.grid_offset_x + x * @types.tile_size
      let py = @types.grid_offset_y + y * @types.tile_size
      let tile = @types.get_tile(level, x, y)
      match tile {
        PressurePlate(_) => {
          let floor_color = @types.world_floor_color(@types.world_theme_of(level.world))
          @raylib.draw_rectangle(
            px, py, @types.tile_size, @types.tile_size, floor_color,
          )
          // Pressure plate: indented rectangle
          @raylib.draw_rectangle(
            px + 8, py + 8, @types.tile_size - 16, @types.tile_size - 16,
            @types.color_pressure_plate,
          )
          @raylib.draw_rectangle_lines(
            px + 8, py + 8, @types.tile_size - 16, @types.tile_size - 16,
            @raylib.Color::new(180, 160, 100, 255),
          )
        }
        Mirror(id) => {
          let floor_color = @types.world_floor_color(@types.world_theme_of(level.world))
          @raylib.draw_rectangle(
            px, py, @types.tile_size, @types.tile_size, floor_color,
          )
          // Mirror: diagonal line
          if id == 1 {
            // "/" mirror
            @raylib.draw_line(
              px + @types.tile_size - 6, py + 6, px + 6,
              py + @types.tile_size - 6, @types.color_mirror,
            )
          } else {
            // "\" mirror
            @raylib.draw_line(
              px + 6, py + 6, px + @types.tile_size - 6,
              py + @types.tile_size - 6, @types.color_mirror,
            )
          }
          // Shimmer
          let shimmer_d = @math.sin((frame_count + px + py).to_double() * 0.08)
          let shimmer = Float::from_double(shimmer_d.abs())
          let alpha = 80 + (shimmer * 80.0).to_int()
          @raylib.draw_circle(
            px + @types.tile_size / 2, py + @types.tile_size / 2, 6.0,
            @raylib.Color::new(220, 240, 255, alpha),
          )
        }
        GravityWell => {
          let floor_color = @types.world_floor_color(@types.world_theme_of(level.world))
          @raylib.draw_rectangle(
            px, py, @types.tile_size, @types.tile_size, floor_color,
          )
          // Gravity well: concentric rings pulsing inward
          let cx = px + @types.tile_size / 2
          let cy = py + @types.tile_size / 2
          let pulse_d = @math.sin(frame_count.to_double() * 0.1)
          let pulse = Float::from_double(pulse_d.abs())
          @raylib.draw_circle_lines(
            cx, cy, 16.0 - pulse * 4.0, @types.color_gravity_well,
          )
          @raylib.draw_circle_lines(
            cx, cy, 10.0 - pulse * 2.0,
            @raylib.Color::new(140, 40, 255, 180),
          )
          @raylib.draw_circle(cx, cy, 4.0, @types.color_gravity_well)
        }
        TimedLava => {
          // Lava: pulsing orange/red
          let pulse_d = @math.sin(frame_count.to_double() * 0.12)
          let pulse = Float::from_double(pulse_d.abs())
          let r = 200 + (pulse * 55.0).to_int()
          let g = 60 + (pulse * 40.0).to_int()
          let lava_color = @raylib.Color::new(r, g, 10, 255)
          @raylib.draw_rectangle(
            px, py, @types.tile_size, @types.tile_size, lava_color,
          )
          // Bubble effect
          let bx = px + 12 + (frame_count % 20)
          let by = py + 8 + ((frame_count + 7) % 16)
          @raylib.draw_circle(
            bx, by, 3.0, @raylib.Color::new(255, 200, 40, 120),
          )
        }
        WindGust(dir) => {
          let floor_color = @types.world_floor_color(@types.world_theme_of(level.world))
          @raylib.draw_rectangle(
            px, py, @types.tile_size, @types.tile_size, floor_color,
          )
          // Wind lines showing direction
          let (dx, dy) = @types.gravity_vector(dir)
          let cx = px + @types.tile_size / 2
          let cy = py + @types.tile_size / 2
          let wind_color = @types.color_wind_gust
          for ln in 0..<3 {
            let offset = Float::from_int(ln) * 8.0 - 8.0
            let sx = Float::from_int(cx) - Float::from_int(dx) * 12.0 + Float::from_int(dy) * offset
            let sy = Float::from_int(cy) - Float::from_int(dy) * 12.0 + Float::from_int(dx) * offset
            let ex = Float::from_int(cx) + Float::from_int(dx) * 12.0 + Float::from_int(dy) * offset
            let ey = Float::from_int(cy) + Float::from_int(dy) * 12.0 + Float::from_int(dx) * offset
            @raylib.draw_line(
              sx.to_int(), sy.to_int(), ex.to_int(), ey.to_int(), wind_color,
            )
          }
        }
        _ => ()
      }
    }
  }
}

///|
fn rand_float_eff(game : @types.Game) -> Float {
  let v = @types.rand_next(game)
  Float::from_double((v % 10000U).to_double() / 10000.0)
}

///|
/// Draw high-contrast pattern overlay for a tile
pub fn draw_high_contrast_tile_overlay(
  px : Int,
  py : Int,
  tile : @types.TileKind
) -> Unit {
  let pattern_color = @raylib.Color::new(255, 255, 255, 50)
  let border_color = @raylib.Color::new(255, 255, 255, 150)
  match tile {
    Exit => {
      // Checkered pattern for exit
      let half = @types.tile_size / 2
      @raylib.draw_rectangle(px, py, half, half, pattern_color)
      @raylib.draw_rectangle(
        px + half, py + half, half, half, pattern_color,
      )
      @raylib.draw_rectangle_lines(
        px, py, @types.tile_size, @types.tile_size, border_color,
      )
    }
    Spike => {
      // X pattern for spikes
      @raylib.draw_line(
        px + 4, py + 4, px + @types.tile_size - 4, py + @types.tile_size - 4,
        border_color,
      )
      @raylib.draw_line(
        px + @types.tile_size - 4, py + 4, px + 4, py + @types.tile_size - 4,
        border_color,
      )
      @raylib.draw_rectangle_lines(
        px, py, @types.tile_size, @types.tile_size, border_color,
      )
    }
    Ice => {
      // Horizontal lines for ice
      for i in 0..<4 {
        let ly = py + 8 + i * 10
        @raylib.draw_line(px + 4, ly, px + @types.tile_size - 4, ly, border_color)
      }
      @raylib.draw_rectangle_lines(
        px, py, @types.tile_size, @types.tile_size, border_color,
      )
    }
    Portal(_) => {
      // Double circle for portals
      let cx = px + @types.tile_size / 2
      let cy = py + @types.tile_size / 2
      @raylib.draw_circle_lines(cx, cy, 20.0, border_color)
      @raylib.draw_circle_lines(cx, cy, 16.0, border_color)
    }
    Crumble => {
      // Dashed border for crumble
      @raylib.draw_rectangle_lines(
        px + 2, py + 2, @types.tile_size - 4, @types.tile_size - 4, border_color,
      )
      @raylib.draw_rectangle_lines(
        px + 6, py + 6, @types.tile_size - 12, @types.tile_size - 12, pattern_color,
      )
    }
    Switch(_) => {
      // Circle with dot for switches
      let cx = px + @types.tile_size / 2
      let cy = py + @types.tile_size / 2
      @raylib.draw_circle_lines(cx, cy, 16.0, border_color)
      @raylib.draw_circle(cx, cy, 4.0, border_color)
    }
    Gate(_) => {
      // Bold vertical lines for gates
      for i in 0..<5 {
        let gx = px + 4 + i * 10
        @raylib.draw_line(gx, py + 2, gx, py + @types.tile_size - 2, border_color)
      }
    }
    Conveyor(_) => {
      // Chevrons for conveyor
      @raylib.draw_rectangle_lines(
        px, py, @types.tile_size, @types.tile_size, border_color,
      )
    }
    TimedLava => {
      // Wavy lines for lava
      @raylib.draw_rectangle_lines(
        px, py, @types.tile_size, @types.tile_size,
        @raylib.Color::new(255, 100, 50, 200),
      )
      @raylib.draw_rectangle_lines(
        px + 3, py + 3, @types.tile_size - 6, @types.tile_size - 6,
        @raylib.Color::new(255, 100, 50, 150),
      )
    }
    GravityWell => {
      // Spiral lines for gravity well
      let cx = px + @types.tile_size / 2
      let cy = py + @types.tile_size / 2
      @raylib.draw_circle_lines(cx, cy, 18.0, border_color)
      @raylib.draw_circle_lines(cx, cy, 12.0, border_color)
      @raylib.draw_circle_lines(cx, cy, 6.0, border_color)
    }
    WindGust(_) => {
      // Triple lines for wind
      for i in 0..<3 {
        let ly = py + 10 + i * 12
        @raylib.draw_line(px + 8, ly, px + @types.tile_size - 8, ly, border_color)
      }
    }
    PressurePlate(_) => {
      // Bracket markers for pressure plates
      @raylib.draw_rectangle_lines(
        px + 6, py + 6, @types.tile_size - 12, @types.tile_size - 12, border_color,
      )
    }
    Mirror(_) => {
      // Sparkle for mirror
      let cx = px + @types.tile_size / 2
      let cy = py + @types.tile_size / 2
      @raylib.draw_circle_lines(cx, cy, 14.0, border_color)
    }
    _ => ()
  }
}

///|
/// Draw enemy warning indicator (flashing exclamation near enemies)
pub fn draw_enemy_warning(
  level : @types.Level,
  frame_count : Int
) -> Unit {
  let enemies = @types.find_enemies(level)
  if enemies.length() == 0 {
    return
  }
  let player = match @types.find_player(level) {
    Some(p) => p
    None => return
  }
  // Check distance to nearest enemy
  let mut min_dist = 999
  for i in 0..<enemies.length() {
    let e = enemies[i]
    let dx = player.x - e.x
    let dy = player.y - e.y
    let abs_dx = if dx > 0 { dx } else { -dx }
    let abs_dy = if dy > 0 { dy } else { -dy }
    let dist = abs_dx + abs_dy
    if dist < min_dist {
      min_dist = dist
    }
  }
  // Show warning if enemy is close (within 3 tiles)
  if min_dist <= 3 {
    let pulse = Float::from_double(@math.sin(frame_count.to_double() * 0.2).abs())
    let alpha = (pulse * 200.0).to_int() + 55
    let a = if alpha > 255 { 255 } else { alpha }
    let warning_color = @raylib.Color::new(255, 60, 60, a)
    // Draw flashing "!" near the player
    let px = @types.tile_to_pixel_x(player.x) + @types.tile_sizef * 0.5
    let py = @types.tile_to_pixel_y(player.y) - 16.0
    @draw.draw_text(
      "!", px.to_int() - 3, py.to_int(), 20, warning_color,
    )
  }
}

///|
/// Draw enemy proximity lines (thin red lines from enemy to player)
pub fn draw_enemy_tracking_lines(
  level : @types.Level,
  frame_count : Int
) -> Unit {
  let enemies = @types.find_enemies(level)
  if enemies.length() == 0 {
    return
  }
  let player = match @types.find_player(level) {
    Some(p) => p
    None => return
  }
  let px = @types.tile_to_pixel_x(player.x) + @types.tile_sizef * 0.5
  let py = @types.tile_to_pixel_y(player.y) + @types.tile_sizef * 0.5
  let pulse = Float::from_double(@math.sin(frame_count.to_double() * 0.1).abs())
  let alpha = (pulse * 60.0).to_int() + 20
  let line_color = @raylib.Color::new(255, 60, 60, alpha)
  for i in 0..<enemies.length() {
    let e = enemies[i]
    let ex = @types.tile_to_pixel_x(e.x) + @types.tile_sizef * 0.5
    let ey = @types.tile_to_pixel_y(e.y) + @types.tile_sizef * 0.5
    @raylib.draw_line(
      px.to_int(), py.to_int(), ex.to_int(), ey.to_int(), line_color,
    )
  }
}
