///|
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(@types.color_bg)
  match game.screen {
    Title => draw_title(game)
    LevelSelect => draw_level_select(game)
    Playing => draw_playing(game)
    Won => draw_won(game)
    Failed => draw_failed(game)
  }
  @raylib.end_drawing()
}

///|
fn color_with_alpha(c : @raylib.Color, alpha : Int) -> @raylib.Color {
  let a = if alpha < 0 {
    0
  } else if alpha > 255 {
    255
  } else {
    alpha
  }
  @raylib.Color::new(c.r.to_int(), c.g.to_int(), c.b.to_int(), a)
}

///|
fn overlay_color(alpha : Int) -> @raylib.Color {
  @raylib.Color::new(0, 0, 0, alpha)
}

///|
fn draw_title(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let title = "BEACON"
  let tw = @draw.measure_text(title, 72)
  let pulse = @types.sinf(game.anim_timer * 2.0) * 0.15 + 0.85
  let alpha = (pulse * 255.0).to_int()
  let title_color = color_with_alpha(@types.color_title, alpha)
  @draw.draw_text(title, (sw - tw) / 2, 200, 72, title_color)
  // Subtitle
  let sub = "Signal Relay Network Puzzle"
  let sw2 = @draw.measure_text(sub, 24)
  @draw.draw_text(sub, (sw - sw2) / 2, 290, 24, @types.color_hud_dim)
  // Prompt
  let prompt = "Press ENTER or CLICK to start"
  let blink = @types.sinf(game.anim_timer * 3.0)
  if blink > 0.0 {
    let pw = @draw.measure_text(prompt, 20)
    @draw.draw_text(prompt, (sw - pw) / 2, 450, 20, @types.color_hud_text)
  }
  // Version
  @draw.draw_text(
    "v1.0", 10, @types.screen_height - 30, 16, @types.color_hud_dim,
  )
  // Decorative signal lines
  draw_title_decoration(game)
}

///|
fn draw_title_decoration(game : @types.Game) -> Unit {
  let sw = Float::from_int(@types.screen_width)
  let cy : Float = 380.0
  let phase = game.anim_timer * 1.5
  for i in 0..<5 {
    let fi = Float::from_int(i)
    let x1 = sw * 0.15 + fi * 40.0
    let x2 = sw * 0.55 + fi * 40.0 + @types.sinf(phase + fi) * 20.0
    let v : Float = 150.0 - fi * 20.0
    let a = v.to_int()
    let c = @raylib.Color::new(0, 200, 255, a)
    @raylib.draw_line(x1.to_int(), cy.to_int(), x2.to_int(), cy.to_int(), c)
    @raylib.draw_circle(x2.to_int(), cy.to_int(), 3.0, c)
  }
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let title = "Select Level"
  let tw = @draw.measure_text(title, 36)
  @draw.draw_text(title, (sw - tw) / 2, 30, 36, @types.color_title)
  // Total stars
  let total_stars = count_total_stars(game)
  let total_text = "Stars: " + total_stars.to_string() + " / 75"
  let tsw = @draw.measure_text(total_text, 20)
  @draw.draw_text(total_text, (sw - tsw) / 2, 75, 20, @types.color_star_gold)
  let start_y = 120 - game.scroll_offset * 200
  let mut cy = start_y
  for tier in 1..=3 {
    let tier_label = @levels.tier_name(tier)
    @draw.draw_text(tier_label, 40, cy, 24, @types.color_hud_text)
    cy += 40
    let count = @levels.tier_level_count(tier)
    let start = @levels.tier_start_index(tier)
    let cols = 5
    for i in 0..<count {
      let idx = start + i
      let col = i % cols
      let row = i / cols
      let bx = 80 + col * 180
      let by = cy + row * 70
      draw_level_button(game, idx, bx, by)
    }
    let rows_used = (count + cols - 1) / cols
    cy += rows_used * 70 + 20
  }
  @draw.draw_text(
    "ESC: Back | Scroll: Up/Down",
    20,
    @types.screen_height - 30,
    16,
    @types.color_hud_dim,
  )
}

///|
fn draw_level_button(
  game : @types.Game,
  idx : Int,
  bx : Int,
  by : Int
) -> Unit {
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let hovered = mx >= bx && mx <= bx + 160 && my >= by && my <= by + 55
  let bg = if hovered {
    @types.color_button_hover
  } else {
    @types.color_button
  }
  @raylib.draw_rectangle(bx, by, 160, 55, bg)
  @raylib.draw_rectangle_lines(bx, by, 160, 55, @types.color_grid_line)
  let data = @levels.get_level(idx)
  let label = (idx + 1).to_string() + ". " + data.name
  @draw.draw_text(label, bx + 8, by + 5, 14, @types.color_hud_text)
  let prog = game.progress[idx]
  let sc = @types.star_count(prog.stars)
  for s in 0..<3 {
    let sx = bx + 8 + s * 20
    let sy = by + 28
    let c = if s < sc {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    draw_star_icon(sx, sy, c)
  }
  if prog.completed {
    @draw.draw_text("OK", bx + 130, by + 30, 14, @types.color_receiver_lit)
  }
}

///|
fn draw_star_icon(x : Int, y : Int, color : @raylib.Color) -> Unit {
  let cx = Float::from_int(x) + 7.0
  let cy = Float::from_int(y) + 7.0
  @raylib.draw_circle(cx.to_int(), cy.to_int(), 6.0, color)
  let inner = @raylib.Color::new(
    color.r.to_int() / 2,
    color.g.to_int() / 2,
    color.b.to_int() / 2,
    255,
  )
  @raylib.draw_circle(cx.to_int(), cy.to_int(), 3.0, inner)
}

///|
fn count_total_stars(game : @types.Game) -> Int {
  let mut total = 0
  for i in 0..<@types.total_levels {
    total += @types.star_count(game.progress[i].stars)
  }
  total
}

///|
fn draw_playing(game : @types.Game) -> Unit {
  match (game.level_data, game.level_state) {
    (Some(data), Some(state)) => {
      draw_grid(data, state, game)
      draw_signal_paths(state, game)
      draw_hud(data, state, game)
      draw_cursor(state)
      if game.message_timer > 0.0 {
        let mw = @draw.measure_text(game.message, 20)
        @draw.draw_text(
          game.message,
          (@types.screen_width - mw) / 2,
          @types.screen_height - 60,
          20,
          @types.color_hud_text,
        )
      }
    }
    _ => ()
  }
}

///|
fn draw_grid(
  data : @types.LevelData,
  state : @types.LevelState,
  game : @types.Game
) -> Unit {
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      let tile = state.grid[r][c]
      let sx = @types.tile_screen_x(c)
      let sy = @types.tile_screen_y(r)
      let ts = @types.tile_size
      let elev = data.elevations[r][c]
      let bg_color = elevation_color(elev)
      @raylib.draw_rectangle(sx, sy, ts, ts, bg_color)
      match tile.kind {
        Empty => ()
        Mountain => draw_mountain(sx, sy, ts)
        Transmitter => draw_transmitter(sx, sy, ts, game)
        Receiver => draw_receiver(sx, sy, ts, tile.has_signal, game)
        Tower => draw_tower(sx, sy, ts, tile.has_signal, game)
      }
      @raylib.draw_rectangle_lines(sx, sy, ts, ts, @types.color_grid_line)
      if elev > 0 && tile.kind != Mountain {
        let e_str = "+" + elev.to_string()
        @draw.draw_text(e_str, sx + 2, sy + ts - 14, 10, @types.color_hud_dim)
      }
    }
  }
}

///|
fn elevation_color(elev : Int) -> @raylib.Color {
  match elev {
    0 => @types.color_elevation0
    1 => @types.color_elevation1
    2 => @types.color_elevation2
    _ => @types.color_elevation3
  }
}

///|
fn draw_mountain(sx : Int, sy : Int, ts : Int) -> Unit {
  let cx = Float::from_int(sx + ts / 2)
  let top_y = Float::from_int(sy + 8)
  let bot_y = Float::from_int(sy + ts - 4)
  let half_w = Float::from_int(ts) / 2.5
  @raylib.draw_triangle(
    @raylib.Vector2::new(cx, top_y),
    @raylib.Vector2::new(cx - half_w, bot_y),
    @raylib.Vector2::new(cx + half_w, bot_y),
    @types.color_mountain,
  )
  let cap_y = top_y + Float::from_int(ts) * 0.2
  let cap_w = half_w * 0.4
  @raylib.draw_triangle(
    @raylib.Vector2::new(cx, top_y),
    @raylib.Vector2::new(cx - cap_w, cap_y),
    @raylib.Vector2::new(cx + cap_w, cap_y),
    @types.color_mountain_peak,
  )
}

///|
fn draw_transmitter(sx : Int, sy : Int, ts : Int, game : @types.Game) -> Unit {
  let cx = Float::from_int(sx + ts / 2)
  let cy = Float::from_int(sy + ts / 2)
  let r = Float::from_int(ts) * 0.35
  let pulse = @types.sinf(game.signal_phase * 2.0) * 0.2 + 0.8
  let outer_r = r * (1.0 + pulse * 0.3)
  let alpha = (pulse * 100.0).to_int()
  let ring_color = color_with_alpha(@types.color_transmitter, alpha)
  @raylib.draw_circle_lines(cx.to_int(), cy.to_int(), outer_r, ring_color)
  @raylib.draw_circle(cx.to_int(), cy.to_int(), r, @types.color_transmitter)
  @raylib.draw_circle(
    cx.to_int(),
    cy.to_int(),
    r * 0.4,
    @raylib.Color::new(200, 240, 255, 255),
  )
  @draw.draw_text("TX", sx + ts / 2 - 8, sy + ts / 2 - 6, 12, @raylib.black)
}

///|
fn draw_receiver(
  sx : Int,
  sy : Int,
  ts : Int,
  lit : Bool,
  game : @types.Game
) -> Unit {
  let cx = Float::from_int(sx + ts / 2)
  let cy = Float::from_int(sy + ts / 2)
  let r = Float::from_int(ts) * 0.3
  if lit {
    let glow_r = r * 1.5
    let glow_alpha = (@types.sinf(game.signal_phase * 3.0) * 40.0 + 60.0).to_int()
    let glow_c = @raylib.Color::new(100, 255, 100, glow_alpha)
    @raylib.draw_circle(cx.to_int(), cy.to_int(), glow_r, glow_c)
    @raylib.draw_circle(cx.to_int(), cy.to_int(), r, @types.color_receiver_lit)
    @draw.draw_text("RX", sx + ts / 2 - 8, sy + ts / 2 - 6, 12, @raylib.black)
  } else {
    @raylib.draw_circle(cx.to_int(), cy.to_int(), r, @types.color_receiver)
    @raylib.draw_circle_lines(
      cx.to_int(), cy.to_int(), r + 2.0, @types.color_receiver,
    )
    @draw.draw_text(
      "RX", sx + ts / 2 - 8, sy + ts / 2 - 6, 12, @raylib.white,
    )
  }
}

///|
fn draw_tower(
  sx : Int,
  sy : Int,
  ts : Int,
  has_signal : Bool,
  game : @types.Game
) -> Unit {
  let cx = Float::from_int(sx + ts / 2)
  let cy = Float::from_int(sy + ts / 2)
  let r = Float::from_int(ts) * 0.28
  @raylib.draw_rectangle(
    sx + ts / 4, sy + ts / 2, ts / 2, ts / 2 - 4, @types.color_tower,
  )
  @raylib.draw_circle(
    cx.to_int(), (cy - r * 0.5).to_int(), r * 0.7, @types.color_tower,
  )
  if has_signal {
    let pulse = @types.sinf(game.signal_phase * 2.5) * 0.3 + 0.7
    let ring_r = r * (1.5 + pulse * 0.5)
    let alpha = (pulse * 80.0).to_int()
    let ring_c = color_with_alpha(@types.color_signal_relay, alpha)
    @raylib.draw_circle_lines(cx.to_int(), cy.to_int(), ring_r, ring_c)
  }
}

///|
fn draw_signal_paths(state : @types.LevelState, game : @types.Game) -> Unit {
  for i in 0..<state.signal_paths.length() {
    let p = state.signal_paths[i]
    if p.active {
      let x1 = @types.tile_center_x(p.from_col)
      let y1 = @types.tile_center_y(p.from_row)
      let x2 = @types.tile_center_x(p.to_col)
      let y2 = @types.tile_center_y(p.to_row)
      let prog = @types.minf(p.progress, 1.0)
      let ex = x1 + (x2 - x1) * prog
      let ey = y1 + (y2 - y1) * prog
      let pulse = @types.sinf(game.signal_phase * 3.0 + Float::from_int(i))
      let av : Float = 150.0 + pulse * 50.0
      let alpha = av.to_int()
      let c = color_with_alpha(@types.color_signal, alpha)
      @raylib.draw_line_ex(
        @raylib.Vector2::new(x1, y1),
        @raylib.Vector2::new(ex, ey),
        2.0,
        c,
      )
      if prog < 1.0 {
        @raylib.draw_circle(ex.to_int(), ey.to_int(), 4.0, c)
      }
    }
  }
}

///|
fn draw_cursor(state : @types.LevelState) -> Unit {
  let col = state.cursor_col
  let row = state.cursor_row
  if !@types.in_grid(col, row) {
    return
  }
  let sx = @types.tile_screen_x(col)
  let sy = @types.tile_screen_y(row)
  let ts = @types.tile_size
  if state.hover_valid {
    let cx = Float::from_int(sx + ts / 2)
    let cy = Float::from_int(sy + ts / 2)
    let r = Float::from_int(ts) * 0.28
    @raylib.draw_circle(cx.to_int(), cy.to_int(), r, @types.color_tower_ghost)
    @raylib.draw_rectangle_lines(sx, sy, ts, ts, @types.color_tower)
  } else {
    let tile = state.grid[row][col]
    if tile.kind == Empty || tile.kind == Tower {
      @raylib.draw_rectangle(sx, sy, ts, ts, @types.color_blocked)
    }
  }
}

///|
fn draw_hud(
  data : @types.LevelData,
  state : @types.LevelState,
  _game : @types.Game
) -> Unit {
  let sw = @types.screen_width
  let ts = @types.tile_size
  let grid_right = @types.grid_offset_x + @types.grid_cols * ts
  let panel_x = grid_right + 20
  let panel_w = sw - panel_x - 20
  @draw.draw_text(data.name, panel_x, @types.grid_offset_y, 22, @types.color_title)
  let level_str = "Level " + data.id.to_string()
  @draw.draw_text(
    level_str, panel_x, @types.grid_offset_y + 30, 16, @types.color_hud_dim,
  )
  let budget_str = "Towers: " +
    state.towers_placed.to_string() +
    " / " +
    state.budget.to_string()
  @draw.draw_text(
    budget_str, panel_x, @types.grid_offset_y + 60, 18, @types.color_hud_text,
  )
  // Budget bar
  let bar_y = @types.grid_offset_y + 85
  let bar_h = 12
  @raylib.draw_rectangle(panel_x, bar_y, panel_w, bar_h, @types.color_grid_bg)
  if state.budget > 0 {
    let fill = panel_w * state.towers_placed / state.budget
    let bar_color = if state.towers_placed <= data.par_towers {
      @types.color_receiver_lit
    } else {
      @types.color_receiver
    }
    @raylib.draw_rectangle(panel_x, bar_y, fill, bar_h, bar_color)
  }
  @draw.draw_text(
    "Par: " + data.par_towers.to_string() + " towers",
    panel_x,
    bar_y + 20,
    14,
    @types.color_hud_dim,
  )
  @draw.draw_text(
    "Par chain: " + data.par_chain.to_string(),
    panel_x,
    bar_y + 38,
    14,
    @types.color_hud_dim,
  )
  @draw.draw_text(
    "Chain: " + state.relay_chain_length.to_string(),
    panel_x,
    bar_y + 60,
    16,
    @types.color_hud_text,
  )
  // Controls
  let ctrl_y = @types.grid_offset_y + 250
  @draw.draw_text("Controls:", panel_x, ctrl_y, 16, @types.color_hud_text)
  @draw.draw_text(
    "LMB: Place tower", panel_x, ctrl_y + 22, 14, @types.color_hud_dim,
  )
  @draw.draw_text(
    "RMB: Remove tower", panel_x, ctrl_y + 40, 14, @types.color_hud_dim,
  )
  @draw.draw_text(
    "R: Reset level", panel_x, ctrl_y + 58, 14, @types.color_hud_dim,
  )
  @draw.draw_text("ESC: Back", panel_x, ctrl_y + 76, 14, @types.color_hud_dim)
  // Receiver count
  let mut rx_total = 0
  let mut rx_lit = 0
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      if state.grid[r][c].kind == Receiver {
        rx_total += 1
        if state.grid[r][c].has_signal {
          rx_lit += 1
        }
      }
    }
  }
  let rx_str = "Receivers: " +
    rx_lit.to_string() +
    " / " +
    rx_total.to_string()
  let rx_color = if rx_lit == rx_total && rx_total > 0 {
    @types.color_receiver_lit
  } else {
    @types.color_receiver
  }
  @draw.draw_text(rx_str, panel_x, bar_y + 85, 18, rx_color)
}

///|
fn draw_won(game : @types.Game) -> Unit {
  draw_playing(game)
  @raylib.draw_rectangle(
    0, 0, @types.screen_width, @types.screen_height, overlay_color(180),
  )
  let sw = @types.screen_width
  let title = "Level Complete!"
  let tw = @draw.measure_text(title, 42)
  @draw.draw_text(title, (sw - tw) / 2, 200, 42, @types.color_receiver_lit)
  match game.level_state {
    Some(state) => {
      let prog = game.progress[game.current_level]
      let sc = @types.star_count(prog.stars)
      let star_start_x = sw / 2 - sc * 25
      for s in 0..<3 {
        let star_x = star_start_x + s * 50
        let c = if s < sc {
          @types.color_star_gold
        } else {
          @types.color_star_empty
        }
        @raylib.draw_circle(star_x, 290, 18.0, c)
      }
      let towers_str = "Towers used: " + state.towers_placed.to_string()
      let tsw2 = @draw.measure_text(towers_str, 22)
      @draw.draw_text(towers_str, (sw - tsw2) / 2, 340, 22, @types.color_hud_text)
      let chain_str = "Relay chain: " + state.relay_chain_length.to_string()
      let csw = @draw.measure_text(chain_str, 22)
      @draw.draw_text(chain_str, (sw - csw) / 2, 370, 22, @types.color_hud_text)
    }
    _ => ()
  }
  let prompt = if game.current_level < @types.total_levels - 1 {
    "ENTER: Next Level | ESC: Level Select"
  } else {
    "All levels complete! ESC: Level Select"
  }
  let pw = @draw.measure_text(prompt, 18)
  @draw.draw_text(prompt, (sw - pw) / 2, 430, 18, @types.color_hud_dim)
}

///|
fn draw_failed(game : @types.Game) -> Unit {
  draw_playing(game)
  @raylib.draw_rectangle(
    0, 0, @types.screen_width, @types.screen_height, overlay_color(180),
  )
  let sw = @types.screen_width
  let title = "Out of Towers!"
  let tw = @draw.measure_text(title, 36)
  @draw.draw_text(title, (sw - tw) / 2, 280, 36, @types.color_receiver)
  let prompt = "R: Retry | ESC: Level Select"
  let pw = @draw.measure_text(prompt, 18)
  @draw.draw_text(prompt, (sw - pw) / 2, 350, 18, @types.color_hud_dim)
  ignore(game)
}
