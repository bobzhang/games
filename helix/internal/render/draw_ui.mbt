///|
fn draw_hud(game : @types.Game) -> Unit {
  let level = match game.current_level {
    None => return
    Some(l) => l
  }
  // Top bar background
  @raylib.draw_rectangle(0, 0, 1280, 50, @types.color_hud_bg)
  // Level name
  @draw.draw_text(level.name, 10, 12, 22, @types.color_text)
  // Step counter
  let step_text = "Steps: " + game.steps.to_string()
  @draw.draw_text(step_text, 300, 12, 22, @types.color_text)
  // Par
  let par_text = "Par: " + level.par_steps.to_string()
  let par_color = if game.steps <= level.par_steps {
    @types.color_gate_open
  } else {
    @types.color_gate_closed
  }
  @draw.draw_text(par_text, 480, 12, 22, par_color)
  // Pickups
  if level.pickups_total > 0 {
    let pickup_text = "Pickups: " +
      game.pickups_count.to_string() +
      "/" +
      level.pickups_total.to_string()
    @draw.draw_text(pickup_text, 640, 12, 22, @types.color_pickup)
  }
  // Token positions
  let cw_text = "CW: " +
    game.cw_pos.to_string() +
    "/" +
    (level.cw_spiral.cells.length() - 1).to_string()
  @draw.draw_text(cw_text, 880, 12, 18, @types.color_cw_token)
  let ccw_text = "CCW: " +
    game.ccw_pos.to_string() +
    "/" +
    (level.ccw_spiral.cells.length() - 1).to_string()
  @draw.draw_text(ccw_text, 1060, 12, 18, @types.color_ccw_token)
  // Bottom bar - gate status
  @raylib.draw_rectangle(0, 690, 1280, 30, @types.color_hud_bg)
  // Controls reminder
  let controls = "Space/Enter=Step  Z=Undo  R=Restart  Esc=Back"
  @draw.draw_text(controls, 10, 696, 16, @types.color_text_dim)
  // Gate status indicators
  let mut gx = 700
  let cw_cells = level.cw_spiral.cells
  let ccw_cells = level.ccw_spiral.cells
  let mut gate_count = 0
  for i in 0..<cw_cells.length() {
    if cw_cells[i].kind == Gate && gate_count < 10 {
      let col = if cw_cells[i].gate_open {
        @types.color_gate_open
      } else {
        @types.color_gate_closed
      }
      @raylib.draw_rectangle(gx, 696, 14, 14, col)
      let label = "C" + i.to_string()
      @draw.draw_text(label, gx, 696, 10, @types.color_text_dim)
      gx += 26
      gate_count += 1
    }
  }
  for i in 0..<ccw_cells.length() {
    if ccw_cells[i].kind == Gate && gate_count < 20 {
      let col = if ccw_cells[i].gate_open {
        @types.color_gate_open
      } else {
        @types.color_gate_closed
      }
      @raylib.draw_rectangle(gx, 696, 14, 14, col)
      let label = "W" + i.to_string()
      @draw.draw_text(label, gx, 696, 10, @types.color_text_dim)
      gx += 26
      gate_count += 1
    }
  }
  // Message
  if game.message_timer > 0.0 {
    let mw = @draw.measure_text(game.message, 22)
    @raylib.draw_rectangle(
      640 - mw / 2 - 10,
      620,
      mw + 20,
      30,
      @types.color_hud_bg,
    )
    @draw.draw_text(game.message, 640 - mw / 2, 624, 22, @types.color_star_gold)
  }
}
