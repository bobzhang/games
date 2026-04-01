///|
fn draw_playing_ui(game : @types.Game, level : @types.Level) -> Unit {
  let sw = @types.screen_width
  let panel_x = @types.grid_offset_x +
    @types.grid_width * @types.cell_render_size +
    30
  let panel_w = sw - panel_x - 20
  // Background panel
  @raylib.draw_rectangle(
    panel_x,
    30,
    panel_w,
    660,
    @raylib.Color::new(30, 26, 22, 200),
  )
  @raylib.draw_rectangle_lines(
    panel_x,
    30,
    panel_w,
    660,
    @raylib.Color::new(80, 70, 55, 150),
  )
  let tx = panel_x + 16
  let mut ty = 45
  // Species name
  @draw.draw_text(
    @types.species_name(level.species),
    tx,
    ty,
    28,
    @types.color_title,
  )
  ty = ty + 40
  // Level info
  let level_str = "Level " + (game.selected_level + 1).to_string()
  @draw.draw_text(level_str, tx, ty, 22, @types.color_hud_text)
  ty = ty + 35
  // Turn counter
  let turn_str = "Turn: " +
    (game.turn + 1).to_string() +
    " / " +
    level.max_turns.to_string()
  @draw.draw_text(turn_str, tx, ty, 20, @types.color_hud_text)
  ty = ty + 30
  // Turn progress bar
  let bar_w = panel_w - 32
  let bar_h = 12
  @raylib.draw_rectangle(
    tx,
    ty,
    bar_w,
    bar_h,
    @raylib.Color::new(50, 45, 38, 255),
  )
  let progress = if level.max_turns > 0 {
    Float::from_int(game.turn) / Float::from_int(level.max_turns)
  } else {
    0.0
  }
  let fill_w = (Float::from_int(bar_w) * progress).to_int()
  let bar_color = if progress < 0.6 {
    @raylib.Color::new(50, 180, 80, 255)
  } else if progress < 0.85 {
    @raylib.Color::new(220, 180, 30, 255)
  } else {
    @raylib.Color::new(200, 60, 40, 255)
  }
  @raylib.draw_rectangle(tx, ty, fill_w, bar_h, bar_color)
  ty = ty + 25
  // Prune budget
  let budget_str = "Prunes: " +
    game.prunes_this_turn.to_string() +
    " / " +
    level.prune_budget_per_turn.to_string()
  @draw.draw_text(budget_str, tx, ty, 20, @types.color_hud_text)
  ty = ty + 30
  // Total prunes vs par
  let total_str = "Total prunes: " +
    game.total_prunes.to_string() +
    " (par: " +
    level.par_prunes.to_string() +
    ")"
  let par_color = if game.total_prunes <= level.par_prunes {
    @raylib.Color::new(50, 200, 80, 255)
  } else {
    @raylib.Color::new(200, 150, 50, 255)
  }
  @draw.draw_text(total_str, tx, ty, 18, par_color)
  ty = ty + 35
  // Zone status
  @draw.draw_text("-- Zones --", tx, ty, 20, @types.color_hud_text)
  ty = ty + 28
  let (req_ok, forb_ok, tip_ok) = @growth.check_zones(game.tree, level.zones)
  // Count zone types
  let mut req_count = 0
  let mut forb_count = 0
  let mut tip_count = 0
  for zone in level.zones {
    match zone.kind {
      Required => req_count = req_count + 1
      Forbidden => forb_count = forb_count + 1
      TipTarget => tip_count = tip_count + 1
    }
  }
  if req_count > 0 {
    let status = if req_ok { "OK" } else { "..." }
    let color = if req_ok {
      @raylib.Color::new(50, 200, 80, 255)
    } else {
      @raylib.Color::new(200, 150, 50, 255)
    }
    @draw.draw_text("Required: " + status, tx, ty, 18, color)
    ty = ty + 24
  }
  if forb_count > 0 {
    let status = if forb_ok { "OK" } else { "FAIL" }
    let color = if forb_ok {
      @raylib.Color::new(50, 200, 80, 255)
    } else {
      @raylib.Color::new(200, 50, 50, 255)
    }
    @draw.draw_text("Forbidden: " + status, tx, ty, 18, color)
    ty = ty + 24
  }
  if tip_count > 0 {
    let status = if tip_ok { "OK" } else { "..." }
    let color = if tip_ok {
      @raylib.Color::new(50, 200, 80, 255)
    } else {
      @raylib.Color::new(200, 150, 50, 255)
    }
    @draw.draw_text("Tip Targets: " + status, tx, ty, 18, color)
    ty = ty + 24
  }
  ty = ty + 15
  // Ghost status
  let ghost_str = if game.show_ghost { "Ghost: ON" } else { "Ghost: OFF" }
  @draw.draw_text(ghost_str, tx, ty, 18, @raylib.Color::new(150, 200, 150, 200))
  ty = ty + 35
  // Controls
  @draw.draw_text("-- Controls --", tx, ty, 20, @types.color_hud_text)
  ty = ty + 28
  let controls = [
    "SPACE  Grow tree", "CLICK  Prune branch", "G      Toggle ghost", "Z      Undo prune",
    "R      Restart", "ESC    Back",
  ]
  for line in controls {
    @draw.draw_text(line, tx, ty, 16, @raylib.Color::new(160, 150, 135, 200))
    ty = ty + 22
  }
  // Play state overlay
  match game.play_state {
    Won => {
      let stars = @growth.calculate_stars(
        game.tree,
        level.zones,
        game.total_prunes,
        level.par_prunes,
      )
      draw_result_overlay("Level Complete!", stars)
    }
    Lost => draw_result_overlay("Out of Turns!", 0)
    _ => ()
  }
  // Message
  if game.message.length() > 0 && game.message_timer > 0.0 {
    let msg_w = @draw.measure_text(game.message, 22)
    let msg_x = @types.grid_offset_x +
      (@types.grid_width * @types.cell_render_size - msg_w) / 2
    let msg_y = @types.screen_height - 50
    @raylib.draw_rectangle(
      msg_x - 10,
      msg_y - 4,
      msg_w + 20,
      30,
      @raylib.Color::new(0, 0, 0, 180),
    )
    @draw.draw_text(
      game.message,
      msg_x,
      msg_y,
      22,
      @raylib.Color::new(255, 240, 200, 255),
    )
  }
}

///|
fn draw_result_overlay(text : String, stars : Int) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  // Darken overlay
  @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 120))
  // Box
  let bw = 400
  let bh = 200
  let bx = (sw - bw) / 2
  let by = (sh - bh) / 2
  @raylib.draw_rectangle(bx, by, bw, bh, @raylib.Color::new(40, 36, 30, 240))
  @raylib.draw_rectangle_lines(
    bx,
    by,
    bw,
    bh,
    @raylib.Color::new(100, 180, 80, 200),
  )
  // Text
  let tw = @draw.measure_text(text, 30)
  @draw.draw_text(text, (sw - tw) / 2, by + 30, 30, @types.color_title)
  // Stars
  for i in 0..<3 {
    let star_x = bx + bw / 2 - 60 + i * 50
    let star_y = by + 80
    let color = if i < stars {
      @types.color_star_on
    } else {
      @types.color_star_off
    }
    draw_star(star_x, star_y, 18.0, color)
  }
  // Continue prompt
  let prompt = "Press SPACE to continue"
  let pw = @draw.measure_text(prompt, 18)
  @draw.draw_text(
    prompt,
    (sw - pw) / 2,
    by + bh - 40,
    18,
    @types.color_hud_text,
  )
}

///|
fn draw_star(cx : Int, cy : Int, radius : Float, color : @raylib.Color) -> Unit {
  // Simple 5-pointed star using triangles
  let fcx = Float::from_int(cx)
  let fcy = Float::from_int(cy)
  let pi : Float = 3.14159
  for i in 0..<5 {
    let angle1 : Float = Float::from_int(i) * pi * 2.0 / 5.0 - pi / 2.0
    let angle2 : Float = Float::from_int(i + 1) * pi * 2.0 / 5.0 - pi / 2.0
    let x1 = fcx + @types.cosf(angle1) * radius
    let y1 = fcy + @types.sinf(angle1) * radius
    let x2 = fcx + @types.cosf(angle2) * radius
    let y2 = fcy + @types.sinf(angle2) * radius
    @raylib.draw_triangle(
      @raylib.Vector2::new(fcx, fcy),
      @raylib.Vector2::new(x1, y1),
      @raylib.Vector2::new(x2, y2),
      color,
    )
  }
}
