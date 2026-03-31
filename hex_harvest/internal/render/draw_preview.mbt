///|
/// Draw hover highlight on selected hex
fn draw_hover(game : @types.Game) -> Unit {
  if game.hover_col < 0 || game.hover_row < 0 {
    return
  }
  if !@types.hex_in_bounds(game.hover_col, game.hover_row) {
    return
  }
  let (cx, cy) = @hex.hex_screen_pos(game.hover_col, game.hover_row)
  let size = Float::from_int(@types.hex_size)
  let color = if game.hover_valid {
    @types.color_highlight
  } else {
    @types.color_invalid
  }
  draw_hex_filled(cx, cy, size * 0.9, color)
  draw_hex_outline(cx, cy, size * 0.95, @types.color_white)
}

///|
/// Draw water flow preview (where water will spread next turn)
fn draw_water_preview(game : @types.Game) -> Unit {
  let preview = @water.preview_water_flow(game.level.grid)
  let size = Float::from_int(@types.hex_size)
  for i in 0..<preview.length() {
    let coord = preview[i]
    let (cx, cy) = @hex.hex_screen_pos(coord.col, coord.row)
    // Pulsing preview
    let alpha_base = 40
    let pulse = (@types.sinf(Float::from_int(game.frame_count) * 0.1) * 20.0).to_int()
    let alpha = @types.clampi(alpha_base + pulse, 20, 80)
    draw_hex_filled(cx, cy, size * 0.7, @raylib.Color::new(80, 150, 220, alpha))
  }
}

///|
/// Draw adjacency preview highlights
fn draw_adjacency_preview(game : @types.Game) -> Unit {
  if game.hover_col < 0 || game.hover_row < 0 || !game.hover_valid {
    return
  }
  let kind = match game.place_mode {
    CropPlace(k) => k
    ChannelPlace => return
  }
  let adj = @crops.adjacency_preview(
    game.level.grid,
    game.hover_col,
    game.hover_row,
    kind,
  )
  let size = Float::from_int(@types.hex_size)
  for i in 0..<adj.length() {
    let (c, r) = adj[i]
    let (cx, cy) = @hex.hex_screen_pos(c, r)
    draw_hex_outline(cx, cy, size * 0.85, @types.color_adjacency_highlight)
    // Draw small "+" indicator
    @draw.draw_text("+", cx.to_int() - 4, cy.to_int() - 8, 16, @raylib.Color::new(120, 220, 120, 200))
  }
}

///|
/// Draw harvest animation (floating numbers)
fn draw_harvest_anim(game : @types.Game) -> Unit {
  if game.harvest_anim_timer <= 0.0 {
    return
  }
  let t = game.harvest_anim_timer
  let alpha = @types.clampi((t * 255.0).to_int(), 0, 255)
  let t_inv : Float = 1.0 - t
  let float_y = (t_inv * 30.0).to_int()
  for i in 0..<game.newly_harvested.length() {
    let coord = game.newly_harvested[i]
    let (cx, cy) = @hex.hex_screen_pos(coord.col, coord.row)
    @draw.draw_text(
      "+",
      cx.to_int() - 6,
      cy.to_int() - 20 - float_y,
      20,
      @raylib.Color::new(255, 200, 50, alpha),
    )
  }
}

///|
/// Draw message overlay
fn draw_message(game : @types.Game) -> Unit {
  if game.message_timer <= 0.0 {
    return
  }
  let alpha = @types.clampi(
    (game.message_timer * 255.0).to_int(),
    0,
    255,
  )
  let w = @draw.measure_text(game.message, 28)
  let x = (@types.screen_width - w) / 2
  let y = @types.screen_height / 2 - 40
  // Background
  @raylib.draw_rectangle(x - 20, y - 10, w + 40, 50, @raylib.Color::new(0, 0, 0, alpha * 3 / 4))
  @draw.draw_text(
    game.message,
    x,
    y,
    28,
    @raylib.Color::new(255, 240, 200, alpha),
  )
}
