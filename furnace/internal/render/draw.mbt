///|
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@types.color_bg)
  match game.screen {
    Title => draw_title(game)
    LevelSelect => draw_level_select(game)
    Playing => draw_playing(game)
    Simulating => draw_playing(game)
    LevelComplete => draw_level_complete(game)
    LevelFailed => draw_level_failed(game)
  }
  if game.message_timer > 0.0 {
    draw_message(game)
  }
  @fps.draw()
  @raylib.end_drawing()
}

///|
fn draw_title(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time = Float::from_int(game.frame_count) * 0.03
  // Animated rising heat particles
  for i in 0..<40 {
    let fi = Float::from_int(i)
    let px = ((fi * 137.5 + time * 15.0) % Float::from_int(w)).to_int()
    let py_base = Float::from_int(h) -
      (fi * 91.3 + time * 30.0 * (fi % 3.0 + 1.0)) % Float::from_int(h)
    let py = py_base.to_int()
    let heat_val = (fi * 17.0 % 100.0).to_int()
    let cr = 200 + heat_val / 2
    let cg = 80 + heat_val
    let cb = 20
    @raylib.draw_circle(
      px,
      py,
      2.0 + fi % 3.0,
      @raylib.Color::new(cr, cg, cb, 150),
    )
  }
  // Title text
  let title = "FURNACE"
  let title_w = @draw.measure_text(title, 72)
  let pulse = sinf(time * 2.0) * 0.15 + 0.85
  let alpha = (pulse * 255.0).to_int()
  @draw.draw_text(
    title,
    (w - title_w) / 2,
    h / 4 - 20,
    72,
    @raylib.Color::new(255, 120, 40, alpha),
  )
  // Subtitle
  let sub = "HEAT TRANSFER PUZZLE"
  let sub_w = @draw.measure_text(sub, 20)
  @draw.draw_text(sub, (w - sub_w) / 2, h / 4 + 60, 20, @types.color_hud_text)
  // Stars display
  let star_text = "Total Stars: " +
    game.total_stars.to_string() +
    " / " +
    (@types.total_levels * 3).to_string()
  let star_w = @draw.measure_text(star_text, 18)
  @draw.draw_text(
    star_text,
    (w - star_w) / 2,
    h / 2 + 20,
    18,
    @types.color_star_gold,
  )
  // Start prompt
  let start_text = "PRESS ENTER TO START"
  let start_w = @draw.measure_text(start_text, 24)
  let blink = if game.frame_count % 60 < 40 { 255 } else { 100 }
  @draw.draw_text(
    start_text,
    (w - start_w) / 2,
    h * 3 / 4,
    24,
    @raylib.Color::new(220, 215, 230, blink),
  )
  // Controls hint
  @draw.draw_text(
    "Click to place materials  |  Route heat to targets",
    w / 2 - 230,
    h * 3 / 4 + 50,
    16,
    @types.color_hud_dim,
  )
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let w = @types.screen_width
  @draw.draw_text("SELECT LEVEL", w / 2 - 100, 30, 32, @types.color_hud_text)
  let cols = 5
  let btn_w = 180
  let btn_h = 80
  let gap = 15
  let start_x = (w - cols * (btn_w + gap)) / 2
  let start_y = 90
  for i in 0..<@types.total_levels {
    let col = i % cols
    let row = i / cols
    let x = start_x + col * (btn_w + gap)
    let y = start_y + row * (btn_h + gap)
    let level = @levels.get_level(i)
    let unlocked = @types.is_level_unlocked(game, i)
    let progress = game.level_progress[i]
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let hovered = unlocked &&
      mx >= x &&
      mx < x + btn_w &&
      my >= y &&
      my < y + btn_h
    let bg_color = if !unlocked {
      @raylib.Color::new(30, 28, 38, 255)
    } else if hovered {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(x, y, btn_w, btn_h, bg_color)
    // Tier indicator bar
    let tier_color = match level.tier {
      1 => @raylib.Color::new(100, 180, 255, 255)
      2 => @raylib.Color::new(255, 180, 50, 255)
      _ => @raylib.Color::new(200, 100, 255, 255)
    }
    @raylib.draw_rectangle(x, y, 4, btn_h, tier_color)
    // Level number and name
    let num_str = (i + 1).to_string()
    let text_color = if unlocked {
      @types.color_hud_text
    } else {
      @raylib.Color::new(80, 75, 90, 255)
    }
    @draw.draw_text(num_str, x + 12, y + 8, 22, text_color)
    let name = if unlocked { level.name } else { "???" }
    @draw.draw_text(name, x + 12, y + 34, 14, text_color)
    if progress.completed {
      draw_stars_small(x + 12, y + 54, progress.best_stars)
    }
  }
  @draw.draw_text(
    "ESC - Back to Title",
    20,
    @types.screen_height - 40,
    16,
    @types.color_hud_dim,
  )
}

///|
fn draw_playing(game : @types.Game) -> Unit {
  draw_grid(game)
  draw_toolbar(game)
  draw_hud(game)
}

///|
fn draw_grid(game : @types.Game) -> Unit {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  let size = @types.grid_size
  for r in 0..<size {
    for c in 0..<size {
      let x = ox + c * cs
      let y = oy + r * cs
      let tile = game.grid.tiles[r][c]
      let mat_color = @types.material_color(tile.material)
      @raylib.draw_rectangle(x + 1, y + 1, cs - 2, cs - 2, mat_color)
      // Heat overlay
      let temp = tile.temperature
      let threshold : Float = @types.ambient_temp + 5.0
      if temp > threshold {
        let heat_frac = @types.clampf(
          (temp - @types.ambient_temp) / 200.0,
          0.0,
          1.0,
        )
        let h180 : Float = 180.0
        let h200 : Float = 200.0
        let h55 : Float = 55.0
        let h80 : Float = 80.0
        let h40 : Float = 40.0
        let heat_alpha = (heat_frac * h180).to_int()
        let heat_r = (h200 + heat_frac * h55).to_int()
        let heat_g = (h80 - heat_frac * h40).to_int()
        @raylib.draw_rectangle(
          x + 1,
          y + 1,
          cs - 2,
          cs - 2,
          @raylib.Color::new(heat_r, heat_g, 10, heat_alpha),
        )
      }
      // Tile icons
      match tile.kind {
        HeatSource(heat) => {
          draw_heat_source_icon(x, y, cs, game.frame_count)
          let hs = heat.to_int().to_string() + "C"
          @draw.draw_text(hs, x + 4, y + cs - 18, 12, @raylib.white)
        }
        Target(lo, hi) => {
          draw_target_icon(x, y, cs, tile.temperature, lo, hi)
          let range_str = lo.to_int().to_string() +
            "-" +
            hi.to_int().to_string()
          @draw.draw_text(
            range_str,
            x + 4,
            y + cs - 18,
            12,
            @types.color_target,
          )
          if game.sim_running || game.screen == Simulating {
            let temp_str = tile.temperature.to_int().to_string() + "C"
            @draw.draw_text(temp_str, x + 4, y + 4, 12, @raylib.white)
          }
        }
        Normal =>
          if game.sim_running || game.screen == Simulating {
            let above_ambient : Float = @types.ambient_temp + 1.0
            if tile.material != Empty && tile.temperature > above_ambient {
              let temp_str = tile.temperature.to_int().to_string()
              @draw.draw_text(
                temp_str,
                x + cs / 2 - 8,
                y + cs / 2 - 6,
                12,
                @raylib.white,
              )
            }
          }
      }
      // Locked indicator
      if tile.locked {
        match tile.kind {
          HeatSource(_) => ()
          _ =>
            @raylib.draw_rectangle(
              x + cs - 12,
              y + 2,
              10,
              10,
              @raylib.Color::new(180, 180, 180, 150),
            )
        }
      }
      // Hover highlight
      if r == game.hover_row && c == game.hover_col && !tile.locked {
        @raylib.draw_rectangle_lines(x, y, cs, cs, @types.color_selected)
      }
    }
  }
  // Grid lines
  for i in 0..<=size {
    let x = ox + i * cs
    let y = oy + i * cs
    @raylib.draw_line(x, oy, x, oy + size * cs, @types.color_grid_line)
    @raylib.draw_line(ox, y, ox + size * cs, y, @types.color_grid_line)
  }
}

///|
fn draw_heat_source_icon(x : Int, y : Int, cs : Int, frame : Int) -> Unit {
  let cx = x + cs / 2
  let cy = y + cs / 2
  let time = Float::from_int(frame) * 0.05
  let pulse = sinf(time * 3.0) * 3.0 + 12.0
  @raylib.draw_circle(cx, cy, pulse, @raylib.Color::new(255, 100, 30, 180))
  @raylib.draw_circle(cx, cy, 8.0, @types.color_heat_source)
}

///|
fn draw_target_icon(
  x : Int,
  y : Int,
  cs : Int,
  temp : Float,
  lo : Float,
  hi : Float,
) -> Unit {
  let cx = x + cs / 2
  let cy = y + cs / 2
  let in_range = temp >= lo && temp <= hi
  let color = if in_range {
    @types.color_target_met
  } else {
    @types.color_target
  }
  @raylib.draw_rectangle_lines(cx - 10, cy - 10, 20, 20, color)
  @raylib.draw_rectangle_lines(cx - 6, cy - 6, 12, 12, color)
  @raylib.draw_circle(cx, cy, 3.0, color)
}

///|
fn draw_toolbar(game : @types.Game) -> Unit {
  let tx = @types.toolbar_x
  let ty = @types.toolbar_y
  let level = @levels.get_level(game.current_level)
  @raylib.draw_rectangle(tx - 10, ty - 10, 280, 520, @types.color_toolbar_bg)
  // Level title
  let level_title = "Level " +
    (game.current_level + 1).to_string() +
    ": " +
    level.name
  @draw.draw_text(level_title, tx, ty, 18, @types.color_hud_text)
  let tier_str = "Tier " + level.tier.to_string()
  @draw.draw_text(tier_str, tx, ty + 25, 14, @types.color_hud_dim)
  // Materials palette
  @draw.draw_text("MATERIALS", tx, ty + 55, 16, @types.color_hud_text)
  for i = 0; i < level.available_materials.length(); i = i + 1 {
    let mat = level.available_materials[i]
    let my = ty + 80 + i * 50
    let is_selected = match game.tool_mode {
      Place(m) => m == mat
      _ => false
    }
    let swatch_color = @types.material_color(mat)
    @raylib.draw_rectangle(tx, my, 36, 36, swatch_color)
    if is_selected {
      @raylib.draw_rectangle_lines(
        tx - 2,
        my - 2,
        40,
        40,
        @types.color_selected,
      )
    }
    let name = @types.material_name(mat)
    @draw.draw_text(name, tx + 44, my + 2, 16, @types.color_hud_text)
    let cond_str = "k=" + format_float(@types.conductivity(mat), 1)
    @draw.draw_text(cond_str, tx + 44, my + 20, 12, @types.color_hud_dim)
    let key_str = (i + 1).to_string()
    @draw.draw_text(
      key_str,
      tx + 24 - 4,
      my + 10,
      14,
      @raylib.Color::new(150, 150, 150, 200),
    )
  }
  // Eraser
  let eraser_y = ty + 80 + level.available_materials.length() * 50
  let eraser_selected = match game.tool_mode {
    Erase => true
    _ => false
  }
  @raylib.draw_rectangle(
    tx,
    eraser_y,
    36,
    36,
    @raylib.Color::new(180, 60, 60, 255),
  )
  if eraser_selected {
    @raylib.draw_rectangle_lines(
      tx - 2,
      eraser_y - 2,
      40,
      40,
      @types.color_selected,
    )
  }
  @draw.draw_text("Eraser", tx + 44, eraser_y + 2, 16, @types.color_hud_text)
  @draw.draw_text(
    "E",
    tx + 24 - 4,
    eraser_y + 10,
    14,
    @raylib.Color::new(150, 150, 150, 200),
  )
  // Stats
  let stats_y = eraser_y + 55
  let placed = @types.count_placed_materials(game.grid)
  @draw.draw_text(
    "Placed: " +
    placed.to_string() +
    " (par: " +
    level.par_materials.to_string() +
    ")",
    tx,
    stats_y,
    14,
    @types.color_hud_text,
  )
  @draw.draw_text(
    "Par turns: " + level.par_turns.to_string(),
    tx,
    stats_y + 20,
    14,
    @types.color_hud_text,
  )
  if game.sim_running {
    @draw.draw_text(
      "Turn: " + game.sim_turn.to_string(),
      tx,
      stats_y + 40,
      16,
      @raylib.Color::new(255, 200, 50, 255),
    )
  }
  // Action buttons
  let btn_y = stats_y + 70
  draw_button(
    tx,
    btn_y,
    120,
    35,
    if game.sim_running {
      "STOP"
    } else {
      "SIMULATE"
    },
    @raylib.Color::new(50, 160, 80, 255),
  )
  draw_button(
    tx + 130,
    btn_y,
    120,
    35,
    "RESET",
    @raylib.Color::new(160, 80, 50, 255),
  )
  // Controls help
  @draw.draw_text(
    "1-5: Materials  E: Eraser",
    tx,
    btn_y + 50,
    12,
    @types.color_hud_dim,
  )
  @draw.draw_text(
    "SPACE: Simulate  R: Reset",
    tx,
    btn_y + 66,
    12,
    @types.color_hud_dim,
  )
  @draw.draw_text("ESC: Level Select", tx, btn_y + 82, 12, @types.color_hud_dim)
}

///|
fn draw_hud(game : @types.Game) -> Unit {
  let w = @types.screen_width
  @draw.draw_text("FURNACE", 20, 15, 24, @types.color_title_glow)
  let level_info = "Level " +
    (game.current_level + 1).to_string() +
    " / " +
    @types.total_levels.to_string()
  let info_w = @draw.measure_text(level_info, 18)
  @draw.draw_text(level_info, w - info_w - 20, 20, 18, @types.color_hud_text)
  let star_info = "Stars: " + game.total_stars.to_string()
  let star_info_w = @draw.measure_text(star_info, 16)
  @draw.draw_text(
    star_info,
    w - star_info_w - 20,
    45,
    16,
    @types.color_star_gold,
  )
}

///|
fn draw_level_complete(game : @types.Game) -> Unit {
  draw_playing(game)
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 180),
  )
  let w = @types.screen_width
  let h = @types.screen_height
  @draw.draw_text(
    "LEVEL COMPLETE!",
    w / 2 - 130,
    h / 3 - 20,
    36,
    @types.color_target_met,
  )
  draw_stars_large(w / 2 - 60, h / 3 + 40, game.result.stars)
  let result = game.result
  @draw.draw_text(
    "Materials used: " + result.materials_used.to_string(),
    w / 2 - 100,
    h / 3 + 100,
    18,
    @types.color_hud_text,
  )
  @draw.draw_text(
    "Turns taken: " + result.turns_taken.to_string(),
    w / 2 - 100,
    h / 3 + 125,
    18,
    @types.color_hud_text,
  )
  let prompt = if game.current_level < @types.total_levels - 1 {
    "ENTER - Next Level  |  ESC - Level Select"
  } else {
    "ESC - Level Select"
  }
  let pw = @draw.measure_text(prompt, 18)
  @draw.draw_text(
    prompt,
    (w - pw) / 2,
    h * 2 / 3 + 20,
    18,
    @types.color_hud_dim,
  )
}

///|
fn draw_level_failed(game : @types.Game) -> Unit {
  draw_playing(game)
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 180),
  )
  let w = @types.screen_width
  let h = @types.screen_height
  @draw.draw_text(
    "NOT ALL TARGETS MET",
    w / 2 - 160,
    h / 3,
    32,
    @types.color_target_fail,
  )
  let grid = game.grid
  let mut fail_y = h / 3 + 50
  for r in 0..<grid.size {
    for c in 0..<grid.size {
      match grid.tiles[r][c].kind {
        Target(lo, hi) => {
          let temp = grid.tiles[r][c].temperature
          let met = temp >= lo && temp <= hi
          let status = if met { "OK" } else { "FAIL" }
          let color = if met {
            @types.color_target_met
          } else {
            @types.color_target_fail
          }
          let msg = "Target (" +
            r.to_string() +
            "," +
            c.to_string() +
            "): " +
            temp.to_int().to_string() +
            "C  [" +
            lo.to_int().to_string() +
            "-" +
            hi.to_int().to_string() +
            "]  " +
            status
          @draw.draw_text(msg, w / 2 - 180, fail_y, 16, color)
          fail_y += 22
        }
        _ => ()
      }
    }
  }
  @draw.draw_text(
    "R - Reset  |  ESC - Level Select",
    w / 2 - 150,
    h * 2 / 3 + 40,
    18,
    @types.color_hud_dim,
  )
}

///|
fn draw_message(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let msg_w = @draw.measure_text(game.message, 20)
  let alpha = @types.clampf(game.message_timer * 255.0, 0.0, 255.0).to_int()
  @raylib.draw_rectangle(
    (w - msg_w) / 2 - 10,
    @types.screen_height - 60,
    msg_w + 20,
    30,
    @raylib.Color::new(0, 0, 0, alpha),
  )
  @draw.draw_text(
    game.message,
    (w - msg_w) / 2,
    @types.screen_height - 55,
    20,
    @raylib.Color::new(255, 220, 150, alpha),
  )
}

///|
fn draw_stars_small(x : Int, y : Int, rating : @types.StarRating) -> Unit {
  let count = @types.star_count(rating)
  for i in 0..<3 {
    let color = if i < count {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    @draw.draw_text("*", x + i * 14, y, 16, color)
  }
}

///|
fn draw_stars_large(x : Int, y : Int, rating : @types.StarRating) -> Unit {
  let count = @types.star_count(rating)
  for i in 0..<3 {
    let color = if i < count {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    @draw.draw_text("*", x + i * 36, y, 40, color)
  }
}

///|
fn draw_button(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  text : String,
  color : @raylib.Color,
) -> Unit {
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let hovered = mx >= x && mx < x + w && my >= y && my < y + h
  let bg = if hovered {
    let cr = color.r.to_int() + 30
    let cg = color.g.to_int() + 30
    let cb = color.b.to_int() + 30
    let ca = color.a.to_int()
    @raylib.Color::new(cr, cg, cb, ca)
  } else {
    color
  }
  @raylib.draw_rectangle(x, y, w, h, bg)
  let tw = @draw.measure_text(text, 16)
  @draw.draw_text(text, x + (w - tw) / 2, y + (h - 16) / 2, 16, @raylib.white)
}

///|
fn sinf(a : Float) -> Float {
  Float::from_double(@math.sin(a.to_double()))
}

///|
fn format_float(v : Float, decimals : Int) -> String {
  if decimals <= 0 {
    return v.to_int().to_string()
  }
  let mut mult = 1
  for _i in 0..<decimals {
    mult *= 10
  }
  let scaled = (v * Float::from_int(mult)).to_int()
  let integer_part = scaled / mult
  let frac_part = scaled % mult
  let frac_abs = if frac_part < 0 { -frac_part } else { frac_part }
  integer_part.to_string() + "." + frac_abs.to_string()
}
