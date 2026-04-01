///|
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@types.color_bg)
  match game.screen {
    Title => draw_title(game)
    Playing => draw_playing(game)
    LevelSelect => draw_level_select(game)
    LevelComplete => draw_level_complete(game)
    GameComplete => draw_game_complete(game)
    Paused => {
      draw_playing(game)
      draw_pause_overlay()
    }
  }
  @fps.draw()
  @raylib.end_drawing()
}

///|
fn draw_title(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time : Float = Float::from_int(game.frame_count) * 0.02
  // Animated background particles
  for i in 0..<40 {
    let fi = Float::from_int(i)
    let sx = ((fi * 137.5 + time * 15.0) % Float::from_int(w)).to_int()
    let sy = ((fi * 91.3 + time * 8.0 * (fi % 3.0 + 1.0)) % Float::from_int(h)).to_int()
    let brightness = 40 + (fi * 17.0 % 80.0).to_int()
    let alpha = 120 + (fi * 13.0 % 80.0).to_int()
    @raylib.draw_circle(
      sx,
      sy,
      1.5 + fi % 2.0,
      @raylib.Color::new(brightness, brightness, brightness + 60, alpha),
    )
  }
  // Title
  let title = "M I R A G E"
  let title_w = @draw.measure_text(title, 56)
  let pulse = @types.sinf(time * 2.0) * 0.15 + 0.85
  let alpha = (pulse * 255.0).to_int()
  @draw.draw_text(
    title,
    (w - title_w) / 2,
    h / 4 - 20,
    56,
    @raylib.Color::new(0, 200, 255, alpha),
  )
  // Subtitle
  let sub = "A Perspective Illusion Puzzle"
  let sub_w = @draw.measure_text(sub, 20)
  @draw.draw_text(
    sub,
    (w - sub_w) / 2,
    h / 4 + 50,
    20,
    @raylib.Color::new(160, 170, 200, 200),
  )
  // Controls hint
  let ctrl1 = "WASD/Arrows - Move    Tab - Swap Layer    Space - Merge"
  let ctrl1_w = @draw.measure_text(ctrl1, 14)
  @draw.draw_text(
    ctrl1,
    (w - ctrl1_w) / 2,
    h / 2 + 30,
    14,
    @raylib.Color::new(130, 140, 160, 180),
  )
  let ctrl2 = "R - Reset Level    ESC - Pause"
  let ctrl2_w = @draw.measure_text(ctrl2, 14)
  @draw.draw_text(
    ctrl2,
    (w - ctrl2_w) / 2,
    h / 2 + 52,
    14,
    @raylib.Color::new(130, 140, 160, 180),
  )
  // Start prompt
  let start_text = "PRESS ENTER TO START"
  let start_w = @draw.measure_text(start_text, 24)
  let blink = if game.frame_count % 60 < 40 { 255 } else { 80 }
  @draw.draw_text(
    start_text,
    (w - start_w) / 2,
    h * 3 / 4,
    24,
    @raylib.Color::new(0, 200, 255, blink),
  )
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  // Title
  let title = "SELECT LEVEL"
  let title_w = @draw.measure_text(title, 36)
  @draw.draw_text(
    title,
    (w - title_w) / 2,
    30,
    36,
    @types.color_title,
  )
  // Draw three tier sections
  draw_tier_section(game, Reflection, "Tier 1: Reflection", 0, 7, 90)
  draw_tier_section(game, Overlap, "Tier 2: Overlap", 7, 7, 300)
  draw_tier_section(game, Illusion, "Tier 3: Illusion", 14, 6, 510)
  // Message
  if game.message_timer > 0.0 {
    let msg_w = @draw.measure_text(game.message, 20)
    @draw.draw_text(
      game.message,
      (w - msg_w) / 2,
      680,
      20,
      @raylib.Color::new(255, 80, 80, 220),
    )
  }
  // Back hint
  @draw.draw_text(
    "ESC - Back    Enter - Select",
    20,
    690,
    14,
    @raylib.Color::new(100, 110, 130, 180),
  )
}

///|
fn draw_tier_section(
  game : @types.Game,
  _tier : @types.Tier,
  label : String,
  start_idx : Int,
  count : Int,
  y_offset : Int
) -> Unit {
  let w = @types.screen_width
  // Tier label
  @draw.draw_text(label, 60, y_offset, 20, @types.color_hud_text)
  // Level buttons in a row
  let btn_size = 80
  let gap = 16
  let total_w = count * btn_size + (count - 1) * gap
  let start_x = (w - total_w) / 2
  for i in 0..<count {
    let level_idx = start_idx + i
    let x = start_x + i * (btn_size + gap)
    let y = y_offset + 30
    let unlocked = @types.level_unlocked(game.level_results, level_idx)
    let selected = game.level_select_cursor == level_idx
    let result = game.level_results[level_idx]
    // Button background
    let bg_color = if selected {
      @raylib.Color::new(60, 80, 140, 255)
    } else if unlocked {
      @raylib.Color::new(40, 44, 60, 255)
    } else {
      @raylib.Color::new(25, 25, 35, 255)
    }
    @raylib.draw_rectangle(x, y, btn_size, btn_size, bg_color)
    // Border
    let border_color = if selected {
      @types.color_title
    } else if unlocked {
      @raylib.Color::new(80, 90, 120, 200)
    } else {
      @raylib.Color::new(40, 40, 50, 150)
    }
    @raylib.draw_rectangle_lines(x, y, btn_size, btn_size, border_color)
    // Level number
    let num_str = (level_idx + 1).to_string()
    let num_w = @draw.measure_text(num_str, 24)
    let text_color = if unlocked {
      @raylib.Color::new(220, 225, 240, 255)
    } else {
      @raylib.Color::new(60, 60, 80, 200)
    }
    @draw.draw_text(num_str, x + (btn_size - num_w) / 2, y + 12, 24, text_color)
    // Stars
    if result.completed {
      draw_stars_small(x + 10, y + 50, result.stars)
    } else if !unlocked {
      // Lock icon (just text)
      let lock_w = @draw.measure_text("X", 16)
      @draw.draw_text(
        "X",
        x + (btn_size - lock_w) / 2,
        y + 50,
        16,
        @raylib.Color::new(80, 40, 40, 180),
      )
    }
  }
}

///|
fn draw_stars_small(x : Int, y : Int, count : Int) -> Unit {
  for i in 0..<3 {
    let color = if i < count {
      @types.color_star_filled
    } else {
      @types.color_star_empty
    }
    @draw.draw_text("*", x + i * 22, y, 20, color)
  }
}

///|
fn draw_playing(game : @types.Game) -> Unit {
  let w = @types.screen_width
  // Draw layer indicator
  draw_layer_indicator(game)
  // Draw grid(s)
  match game.merge_state {
    Split => draw_split_view(game)
    Merged => draw_merged_view(game)
  }
  // Draw player
  draw_player(game)
  // Draw HUD
  draw_hud(game)
  // Draw message
  if game.message_timer > 0.0 {
    let alpha = @types.mini(
      (game.message_timer * 3.0 * 255.0).to_int(),
      255,
    )
    let msg_w = @draw.measure_text(game.message, 24)
    @draw.draw_text(
      game.message,
      (w - msg_w) / 2,
      50,
      24,
      @raylib.Color::new(255, 255, 255, alpha),
    )
  }
}

///|
fn draw_layer_indicator(game : @types.Game) -> Unit {
  let w = @types.screen_width
  match game.merge_state {
    Split => {
      let label = match game.player.active_layer {
        Foreground => "FOREGROUND"
        Background => "BACKGROUND"
      }
      let color = match game.player.active_layer {
        Foreground => @types.color_fg_label
        Background => @types.color_bg_label
      }
      let lw = @draw.measure_text(label, 18)
      @draw.draw_text(label, (w - lw) / 2, 96, 18, color)
    }
    Merged => {
      let label = "MERGED"
      let lw = @draw.measure_text(label, 18)
      @draw.draw_text(label, (w - lw) / 2, 96, 18, @types.color_merged)
    }
  }
}

///|
fn draw_split_view(game : @types.Game) -> Unit {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let ts = @types.tile_size
  // Draw active layer fully
  let active_tiles = match game.player.active_layer {
    Foreground => game.fg_tiles
    Background => game.bg_tiles
  }
  let inactive_tiles = match game.player.active_layer {
    Foreground => game.bg_tiles
    Background => game.fg_tiles
  }
  let active_is_fg = game.player.active_layer == Foreground
  // Draw inactive layer with dimming
  for row in 0..<@types.grid_rows {
    for col in 0..<@types.grid_cols {
      let x = ox + col * ts
      let y = oy + row * ts
      let idx = row * @types.grid_cols + col
      let tile = inactive_tiles[idx]
      draw_tile(x, y, ts, tile, !active_is_fg, 0.4)
    }
  }
  // Dim overlay on inactive layer area
  @raylib.draw_rectangle(
    ox,
    oy,
    @types.grid_width,
    @types.grid_height,
    @types.color_inactive_overlay,
  )
  // Draw active layer on top
  for row in 0..<@types.grid_rows {
    for col in 0..<@types.grid_cols {
      let x = ox + col * ts
      let y = oy + row * ts
      let idx = row * @types.grid_cols + col
      let tile = active_tiles[idx]
      draw_tile(x, y, ts, tile, active_is_fg, 1.0)
    }
  }
}

///|
fn draw_merged_view(game : @types.Game) -> Unit {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let ts = @types.tile_size
  for row in 0..<@types.grid_rows {
    for col in 0..<@types.grid_cols {
      let x = ox + col * ts
      let y = oy + row * ts
      let idx = row * @types.grid_cols + col
      let fg_tile = game.fg_tiles[idx]
      let bg_tile = game.bg_tiles[idx]
      // In merged view, show both layers blended
      // If either is walkable, show the one that is
      if @types.is_walkable(fg_tile) && @types.is_walkable(bg_tile) {
        // Both walkable - show merged color
        @raylib.draw_rectangle(
          x,
          y,
          ts,
          ts,
          @types.color_merged,
        )
        @raylib.draw_rectangle_lines(
          x,
          y,
          ts,
          ts,
          @raylib.Color::new(200, 160, 220, 80),
        )
      } else if @types.is_walkable(fg_tile) {
        draw_tile(x, y, ts, fg_tile, true, 0.8)
      } else if @types.is_walkable(bg_tile) {
        draw_tile(x, y, ts, bg_tile, false, 0.8)
      } else {
        // Both unwalkable
        draw_tile(x, y, ts, fg_tile, true, 0.6)
      }
    }
  }
}

///|
fn alpha_f(base : Int, mult : Float) -> Int {
  (Float::from_int(base) * mult).to_int()
}

///|
fn draw_tile(
  x : Int,
  y : Int,
  size : Int,
  tile : @types.Tile,
  is_fg : Bool,
  alpha_mult : Float
) -> Unit {
  let base_color = match tile {
    Empty => @types.color_bg
    Floor =>
      if is_fg {
        @types.color_floor_fg
      } else {
        @types.color_floor_bg
      }
    Wall => @types.color_wall
    Gap => @types.color_gap
    Exit => @types.color_exit
    Switch(_) => @types.color_switch
    Platform =>
      if is_fg {
        @types.color_platform_fg
      } else {
        @types.color_platform_bg
      }
    Gem => @types.color_gem
  }
  let a = (Float::from_int(base_color.a.to_int()) * alpha_mult).to_int()
  let color = @raylib.Color::new(
    base_color.r.to_int(),
    base_color.g.to_int(),
    base_color.b.to_int(),
    a,
  )
  @raylib.draw_rectangle(x, y, size, size, color)
  // Grid lines
  let line_alpha = alpha_f(60, alpha_mult)
  @raylib.draw_rectangle_lines(
    x,
    y,
    size,
    size,
    @raylib.Color::new(255, 255, 255, line_alpha),
  )
  // Special tile decorations
  match tile {
    Exit => {
      // Draw an arrow or marker
      let cx = x + size / 2
      let cy = y + size / 2
      let inner = size / 3
      @raylib.draw_rectangle(
        cx - inner / 2,
        cy - inner / 2,
        inner,
        inner,
        @raylib.Color::new(200, 255, 200, alpha_f(200, alpha_mult)),
      )
    }
    Switch(id) => {
      // Draw switch ID
      let id_str = id.to_string()
      let tw = @draw.measure_text(id_str, 16)
      @draw.draw_text(
        id_str,
        x + (size - tw) / 2,
        y + size / 2 - 8,
        16,
        @raylib.Color::new(80, 60, 0, alpha_f(220, alpha_mult)),
      )
    }
    Gem => {
      // Draw gem diamond shape
      let cx = x + size / 2
      let cy = y + size / 2
      let s = size / 4
      @raylib.draw_rectangle(
        cx - s / 2,
        cy - s / 2,
        s,
        s,
        @raylib.Color::new(255, 200, 255, alpha_f(230, alpha_mult)),
      )
    }
    Platform => {
      // Draw platform stripes
      let stripe_color = @raylib.Color::new(
        255,
        255,
        255,
        alpha_f(40, alpha_mult),
      )
      for i in 0..<3 {
        let sy = y + 10 + i * 16
        @raylib.draw_line(x + 4, sy, x + size - 4, sy, stripe_color)
      }
    }
    _ => ()
  }
}

///|
fn draw_player(game : @types.Game) -> Unit {
  let px = game.player.pixel_x.to_int()
  let py = game.player.pixel_y.to_int()
  let ts = @types.tile_size
  let margin = 8
  // Player body
  @raylib.draw_rectangle(
    px + margin,
    py + margin,
    ts - margin * 2,
    ts - margin * 2,
    @types.color_player,
  )
  // Inner highlight
  let inner_margin = 14
  @raylib.draw_rectangle(
    px + inner_margin,
    py + inner_margin,
    ts - inner_margin * 2,
    ts - inner_margin * 2,
    @raylib.Color::new(100, 255, 240, 180),
  )
  // Border
  @raylib.draw_rectangle_lines(
    px + margin,
    py + margin,
    ts - margin * 2,
    ts - margin * 2,
    @raylib.Color::new(0, 255, 220, 200),
  )
}

///|
fn draw_hud(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let level_def = @levels.get_level(game.current_level)
  // Level name and number
  let level_str = "Level " +
    (game.current_level + 1).to_string() +
    ": " +
    level_def.name
  @draw.draw_text(level_str, 20, 10, 18, @types.color_hud_text)
  // Tier
  let tier_str = @types.tier_name(level_def.tier)
  @draw.draw_text(
    tier_str,
    20,
    34,
    14,
    @raylib.Color::new(120, 130, 160, 200),
  )
  // Swap counter
  let swap_str = "Swaps: " +
    game.swap_count.to_string() +
    " / Par: " +
    level_def.par_swaps.to_string()
  let swap_w = @draw.measure_text(swap_str, 16)
  @draw.draw_text(swap_str, w - swap_w - 20, 10, 16, @types.color_hud_text)
  // Gem status
  let gem_str = if game.gem_collected { "Gem: YES" } else { "Gem: --" }
  let gem_w = @draw.measure_text(gem_str, 14)
  let gem_color = if game.gem_collected {
    @types.color_gem
  } else {
    @raylib.Color::new(80, 80, 100, 180)
  }
  @draw.draw_text(gem_str, w - gem_w - 20, 32, 14, gem_color)
  // Controls reminder at bottom
  let h = @types.screen_height
  @draw.draw_text(
    "Tab:Swap  Space:Merge  R:Reset  ESC:Pause",
    20,
    h - 24,
    12,
    @raylib.Color::new(80, 90, 110, 160),
  )
}

///|
fn draw_pause_overlay() -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  @raylib.draw_rectangle(0, 0, w, h, @raylib.Color::new(0, 0, 0, 160))
  let text = "PAUSED"
  let tw = @draw.measure_text(text, 48)
  @draw.draw_text(
    text,
    (w - tw) / 2,
    h / 3,
    48,
    @raylib.Color::new(200, 210, 230, 255),
  )
  let hint = "ESC/P - Resume    Q - Quit to Menu"
  let hw = @draw.measure_text(hint, 18)
  @draw.draw_text(
    hint,
    (w - hw) / 2,
    h / 3 + 70,
    18,
    @raylib.Color::new(140, 150, 170, 200),
  )
}

///|
fn draw_level_complete(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let level_def = @levels.get_level(game.current_level)
  let result = game.level_results[game.current_level]
  // Background dim
  @raylib.draw_rectangle(0, 0, w, h, @raylib.Color::new(0, 0, 0, 180))
  // Title
  let title = "LEVEL COMPLETE!"
  let title_w = @draw.measure_text(title, 40)
  @draw.draw_text(
    title,
    (w - title_w) / 2,
    h / 4 - 20,
    40,
    @types.color_exit,
  )
  // Level name
  let name_str = level_def.name
  let name_w = @draw.measure_text(name_str, 24)
  @draw.draw_text(
    name_str,
    (w - name_w) / 2,
    h / 4 + 40,
    24,
    @types.color_hud_text,
  )
  // Swap count
  let swap_str = "Swaps: " +
    game.swap_count.to_string() +
    "  (Par: " +
    level_def.par_swaps.to_string() +
    ")"
  let swap_w = @draw.measure_text(swap_str, 20)
  @draw.draw_text(
    swap_str,
    (w - swap_w) / 2,
    h / 2 - 20,
    20,
    @types.color_hud_text,
  )
  // Stars
  draw_stars_large(w / 2 - 60, h / 2 + 30, result.stars)
  // Gem status
  let gem_str = if game.gem_collected {
    "Gem Collected!"
  } else {
    "Gem: Not Found"
  }
  let gem_w = @draw.measure_text(gem_str, 18)
  let gem_color = if game.gem_collected {
    @types.color_gem
  } else {
    @raylib.Color::new(100, 100, 120, 200)
  }
  @draw.draw_text(gem_str, (w - gem_w) / 2, h / 2 + 80, 18, gem_color)
  // Continue hint
  let hint = if game.current_level < @types.total_levels - 1 {
    "Enter - Next Level    ESC - Level Select"
  } else {
    "Enter/ESC - Level Select"
  }
  let hint_w = @draw.measure_text(hint, 16)
  @draw.draw_text(
    hint,
    (w - hint_w) / 2,
    h * 3 / 4 + 20,
    16,
    @raylib.Color::new(140, 150, 170, 200),
  )
}

///|
fn draw_stars_large(x : Int, y : Int, count : Int) -> Unit {
  for i in 0..<3 {
    let color = if i < count {
      @types.color_star_filled
    } else {
      @types.color_star_empty
    }
    @draw.draw_text("*", x + i * 44, y, 36, color)
  }
}

///|
fn draw_game_complete(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  @raylib.draw_rectangle(0, 0, w, h, @raylib.Color::new(0, 0, 0, 200))
  let title = "CONGRATULATIONS!"
  let title_w = @draw.measure_text(title, 44)
  @draw.draw_text(
    title,
    (w - title_w) / 2,
    h / 4,
    44,
    @raylib.Color::new(255, 215, 0, 255),
  )
  let sub = "All levels completed!"
  let sub_w = @draw.measure_text(sub, 24)
  @draw.draw_text(
    sub,
    (w - sub_w) / 2,
    h / 4 + 60,
    24,
    @types.color_hud_text,
  )
  // Total stars
  let mut total_stars = 0
  let max_stars = @types.total_levels * 3
  for i in 0..<game.level_results.length() {
    total_stars = total_stars + game.level_results[i].stars
  }
  let star_str = "Stars: " +
    total_stars.to_string() +
    " / " +
    max_stars.to_string()
  let star_w = @draw.measure_text(star_str, 24)
  @draw.draw_text(
    star_str,
    (w - star_w) / 2,
    h / 2 + 20,
    24,
    @types.color_star_filled,
  )
  let hint = "Press Enter to return to Level Select"
  let hint_w = @draw.measure_text(hint, 16)
  @draw.draw_text(
    hint,
    (w - hint_w) / 2,
    h * 3 / 4,
    16,
    @raylib.Color::new(140, 150, 170, 200),
  )
}
