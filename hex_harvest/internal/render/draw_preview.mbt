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
  // Show removable indicator for right-click on tiles with crops
  if @types.hex_in_bounds(game.hover_col, game.hover_row) {
    let tile = game.level.grid.tiles[game.hover_row][game.hover_col]
    match tile.crop {
      Some(_) =>
        if tile.crop_state != Harvested {
          // Show "X" indicator for crop removal
          @draw.draw_text(
            "X",
            cx.to_int() + (size * 0.3).to_int(),
            cy.to_int() - (size * 0.5).to_int(),
            12,
            @raylib.Color::new(200, 60, 60, 140),
          )
        }
      None => ()
    }
  }
}

///|
/// Draw water flow preview showing exact next-turn water path
fn draw_water_preview(game : @types.Game) -> Unit {
  let preview = @water.preview_water_flow(game.level.grid)
  let size = Float::from_int(@types.hex_size)
  for i in 0..<preview.length() {
    let coord = preview[i]
    let (cx, cy) = @hex.hex_screen_pos(coord.col, coord.row)
    // Pulsing preview with directional flow arrow
    let alpha_base = 50
    let pulse = (@types.sinf(Float::from_int(game.frame_count) * 0.1) * 25.0).to_int()
    let alpha = @types.clampi(alpha_base + pulse, 25, 90)
    draw_hex_filled(cx, cy, size * 0.7, @raylib.Color::new(80, 150, 220, alpha))
    // Draw flow direction arrow from nearest watered source
    draw_flow_arrow(game, coord.col, coord.row, cx, cy, size, alpha)
  }
}

///|
/// Draw a small arrow from the watered neighbor toward this cell
fn draw_flow_arrow(
  game : @types.Game,
  col : Int,
  row : Int,
  cx : Float,
  cy : Float,
  size : Float,
  alpha : Int
) -> Unit {
  let neighbors = @hex.valid_neighbors(col, row)
  for i in 0..<neighbors.length() {
    let (nc, nr) = neighbors[i]
    let ntile = game.level.grid.tiles[nr][nc]
    if ntile.watered {
      let (nx, ny) = @hex.hex_screen_pos(nc, nr)
      // Draw a small line from neighbor edge toward center
      let dx = cx - nx
      let dy = cy - ny
      let len = @types.sqrtf(dx * dx + dy * dy)
      if len > 0.1 {
        let ndx = dx / len
        let ndy = dy / len
        let start_x = cx - ndx * size * 0.5
        let start_y = cy - ndy * size * 0.5
        let end_x = cx - ndx * size * 0.15
        let end_y = cy - ndy * size * 0.15
        @raylib.draw_line_ex(
          @raylib.Vector2::new(start_x, start_y),
          @raylib.Vector2::new(end_x, end_y),
          2.0,
          @raylib.Color::new(60, 130, 220, alpha + 40),
        )
        // Arrowhead
        let ah_size = size * 0.1
        let perp_x = -ndy
        let perp_y = ndx
        @raylib.draw_triangle(
          @raylib.Vector2::new(end_x, end_y),
          @raylib.Vector2::new(
            end_x - ndx * ah_size + perp_x * ah_size * 0.5,
            end_y - ndy * ah_size + perp_y * ah_size * 0.5,
          ),
          @raylib.Vector2::new(
            end_x - ndx * ah_size - perp_x * ah_size * 0.5,
            end_y - ndy * ah_size - perp_y * ah_size * 0.5,
          ),
          @raylib.Color::new(60, 130, 220, alpha + 40),
        )
      }
      break // Only draw from first watered neighbor
    }
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
    @draw.draw_text(
      "+",
      cx.to_int() - 4,
      cy.to_int() - 8,
      16,
      @raylib.Color::new(120, 220, 120, 200),
    )
  }
}

///|
/// Draw projected yield display in HUD area
fn draw_projected_yield(game : @types.Game) -> Unit {
  let proj = @crops.projected_yield(game.level.grid)
  if proj > 0 {
    let total = game.yield_collected + proj
    let text = "Projected: " + total.to_string()
    let x = 720 + 200
    let y = 10 + 5
    @draw.draw_text(
      text,
      x + 170,
      y,
      16,
      @raylib.Color::new(180, 220, 120, 200),
    )
  }
}

///|
/// Draw click confirmation feedback (expanding ring)
fn draw_click_feedback(game : @types.Game) -> Unit {
  if game.click_feedback_timer <= 0.0 {
    return
  }
  if !@types.hex_in_bounds(game.click_feedback_col, game.click_feedback_row) {
    return
  }
  let (cx, cy) = @hex.hex_screen_pos(
    game.click_feedback_col,
    game.click_feedback_row,
  )
  let size = Float::from_int(@types.hex_size)
  let max_time : Float = 0.3
  let t : Float = @types.clampf(
    (max_time - game.click_feedback_timer) * 3.333,
    0.0,
    1.0,
  )
  let ring_size : Float = size * (0.5 + t * 0.6)
  let fade : Float = 1.0 - t
  let alpha = @types.clampi((fade * 200.0).to_int(), 0, 200)
  draw_hex_outline(
    cx,
    cy,
    ring_size,
    @raylib.Color::new(255, 255, 200, alpha),
  )
}

///|
/// Draw turn phase indicator during staged resolution
fn draw_phase_indicator(game : @types.Game) -> Unit {
  match game.turn_phase {
    Idle => ()
    _ => {
      let phase_text = match game.turn_phase {
        Placing => "Placing..."
        Flowing => "Water flowing..."
        Growing => "Crops growing..."
        Harvesting => "Harvesting!"
        Idle => ""
      }
      let tw = @draw.measure_text(phase_text, 18)
      @draw.draw_text(
        phase_text,
        (@types.screen_width - tw) / 2,
        @types.screen_height - 65,
        18,
        @raylib.Color::new(200, 220, 180, 200),
      )
    }
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
  @raylib.draw_rectangle(
    x - 20,
    y - 10,
    w + 40,
    50,
    @raylib.Color::new(0, 0, 0, alpha * 3 / 4),
  )
  @draw.draw_text(
    game.message,
    x,
    y,
    28,
    @raylib.Color::new(255, 240, 200, alpha),
  )
}
