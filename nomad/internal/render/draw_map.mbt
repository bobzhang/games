///|
fn draw_hex(
  cx : Float,
  cy : Float,
  size : Float,
  color : @raylib.Color
) -> Unit {
  @raylib.draw_poly(
    @raylib.Vector2::new(cx, cy),
    6,
    size,
    0.0,
    color,
  )
}

///|
fn draw_hex_outline(
  cx : Float,
  cy : Float,
  size : Float,
  color : @raylib.Color
) -> Unit {
  @raylib.draw_poly_lines_ex(
    @raylib.Vector2::new(cx, cy),
    6,
    size,
    0.0,
    2.0,
    color,
  )
}

///|
fn tile_color(kind : @types.TileKind) -> @raylib.Color {
  match kind {
    Sand => @types.color_sand
    Dunes => @types.color_dunes
    Oasis => @types.color_oasis
    TradePost => @types.color_trade
    Ruins => @types.color_ruins
    Sandstorm => @types.color_storm
    Destination => @types.color_destination
  }
}

///|
fn draw_tile_icon(
  cx : Float,
  cy : Float,
  size : Float,
  kind : @types.TileKind,
  anim : Float
) -> Unit {
  let s = size * 0.35
  match kind {
    Sand => ()
    Dunes => {
      // Wavy dune lines
      let y1 = cy - s * 0.3
      let y2 = cy + s * 0.3
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx - s, y1),
        @raylib.Vector2::new(cx, y1 - s * 0.4),
        2.0,
        @types.color_dunes_dark,
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx, y1 - s * 0.4),
        @raylib.Vector2::new(cx + s, y1),
        2.0,
        @types.color_dunes_dark,
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx - s * 0.7, y2),
        @raylib.Vector2::new(cx + s * 0.7, y2),
        2.0,
        @types.color_dunes_dark,
      )
    }
    Oasis => {
      // Water ripple
      let pulse = @types.sinf(anim * 3.0) * 2.0
      @raylib.draw_circle(cx.to_int(), cy.to_int(), s * 0.5 + pulse, @types.color_oasis_light)
      // Palm tree
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx, cy + s * 0.4),
        @raylib.Vector2::new(cx, cy - s * 0.3),
        2.0,
        @raylib.Color::new(60, 100, 40, 255),
      )
      @raylib.draw_circle(
        cx.to_int(),
        (cy - s * 0.4).to_int(),
        s * 0.25,
        @raylib.Color::new(40, 140, 60, 255),
      )
    }
    TradePost => {
      // Tent shape
      let v1 = @raylib.Vector2::new(cx, cy - s * 0.6)
      let v2 = @raylib.Vector2::new(cx - s * 0.5, cy + s * 0.4)
      let v3 = @raylib.Vector2::new(cx + s * 0.5, cy + s * 0.4)
      @raylib.draw_triangle(v1, v2, v3, @types.color_trade_dark)
      // Gold circle
      @raylib.draw_circle(
        cx.to_int(),
        (cy + s * 0.1).to_int(),
        s * 0.15,
        @types.color_gold_text,
      )
    }
    Ruins => {
      // Broken columns
      @raylib.draw_rectangle(
        (cx - s * 0.4).to_int(),
        (cy - s * 0.3).to_int(),
        (s * 0.2).to_int(),
        (s * 0.7).to_int(),
        @types.color_ruins_dark,
      )
      @raylib.draw_rectangle(
        (cx + s * 0.1).to_int(),
        (cy - s * 0.1).to_int(),
        (s * 0.2).to_int(),
        (s * 0.5).to_int(),
        @types.color_ruins_dark,
      )
      // Sparkle for artifact
      let sparkle = @types.sinf(anim * 4.0) * 0.5 + 0.5
      let a = (sparkle * 200.0).to_int()
      @raylib.draw_circle(
        (cx + s * 0.3).to_int(),
        (cy - s * 0.4).to_int(),
        2.0,
        @raylib.Color::new(200, 150, 255, a),
      )
    }
    Sandstorm => {
      // Swirling lines
      let angle = anim * 2.0
      for i in 0..<3 {
        let a = angle + fi(i) * 2.094
        let x1 = cx + @types.cosf(a) * s * 0.3
        let y1 = cy + @types.sinf(a) * s * 0.3
        let x2 = cx + @types.cosf(a + 1.0) * s * 0.6
        let y2 = cy + @types.sinf(a + 1.0) * s * 0.6
        @raylib.draw_line_ex(
          @raylib.Vector2::new(x1, y1),
          @raylib.Vector2::new(x2, y2),
          2.0,
          @raylib.Color::new(120, 90, 50, 180),
        )
      }
    }
    Destination => {
      // Flag
      let pulse = @types.sinf(anim * 2.5) * 3.0
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx, cy + s * 0.5),
        @raylib.Vector2::new(cx, cy - s * 0.5),
        2.0,
        @raylib.Color::new(200, 200, 200, 255),
      )
      let v1 = @raylib.Vector2::new(cx, cy - s * 0.5)
      let v2 = @raylib.Vector2::new(cx + s * 0.5 + pulse, cy - s * 0.3)
      let v3 = @raylib.Vector2::new(cx, cy - s * 0.1)
      @raylib.draw_triangle(v1, v2, v3, @types.color_success)
    }
  }
}

///|
fn draw_map(game : @types.Game) -> Unit {
  let level = match game.level {
    Some(lv) => lv
    None => return
  }
  let map = level.map
  let size = @types.hex_size
  // Draw all hex tiles
  for row in 0..<map.height {
    for col in 0..<map.width {
      let tile = map.tiles[row][col]
      let coord : @types.HexCoord = { col, row }
      let (cx, cy) = @types.hex_to_pixel(coord, size)
      // Base hex
      draw_hex(cx, cy, size * 0.95, tile_color(tile.kind))
      draw_hex_outline(cx, cy, size * 0.95, @types.color_hex_outline)
      // Icon
      draw_tile_icon(cx, cy, size, tile.kind, game.anim_timer)
    }
  }
  // Highlight start
  let (sx, sy) = @types.hex_to_pixel(level.start, size)
  draw_hex_outline(sx, sy, size * 0.98, @types.color_caravan)
  // Highlight destination with glow
  let (dx, dy) = @types.hex_to_pixel(level.destination, size)
  let glow = @types.sinf(game.anim_timer * 3.0) * 4.0
  draw_hex_outline(dx, dy, size + glow, @types.color_dest_glow)
}

///|
fn draw_route(game : @types.Game) -> Unit {
  let size = @types.hex_size
  let level = match game.level {
    Some(lv) => lv
    None => return
  }
  // Draw planned route lines
  if game.route.length() > 0 {
    // Line from start to first route hex
    let (sx, sy) = @types.hex_to_pixel(level.start, size)
    let (fx, fy) = @types.hex_to_pixel(game.route[0], size)
    @raylib.draw_line_ex(
      @raylib.Vector2::new(sx, sy),
      @raylib.Vector2::new(fx, fy),
      3.0,
      @types.color_route,
    )
    // Lines between route hexes
    for i in 1..<game.route.length() {
      let (x1, y1) = @types.hex_to_pixel(game.route[i - 1], size)
      let (x2, y2) = @types.hex_to_pixel(game.route[i], size)
      @raylib.draw_line_ex(
        @raylib.Vector2::new(x1, y1),
        @raylib.Vector2::new(x2, y2),
        3.0,
        @types.color_route,
      )
    }
    // Draw route step numbers
    for i in 0..<game.route.length() {
      let (rx, ry) = @types.hex_to_pixel(game.route[i], size)
      let num = (i + 1).to_string()
      let nw = @draw.measure_text(num, 14)
      @draw.draw_text(
        num,
        rx.to_int() - nw / 2,
        ry.to_int() - 7,
        14,
        @types.color_caravan,
      )
    }
  }
  // Draw hover preview line
  match game.hover_hex {
    Some(hh) =>
      if game.play_state == Planning {
        let last = if game.route.length() > 0 {
          game.route[game.route.length() - 1]
        } else {
          level.start
        }
        if @types.hex_are_adjacent(last, hh) &&
          @types.hex_in_bounds(hh, level.map.width, level.map.height) {
          let tile = level.map.tiles[hh.row][hh.col]
          if tile.kind != Sandstorm {
            let (lx, ly) = @types.hex_to_pixel(last, size)
            let (hx, hy) = @types.hex_to_pixel(hh, size)
            @raylib.draw_line_ex(
              @raylib.Vector2::new(lx, ly),
              @raylib.Vector2::new(hx, hy),
              2.0,
              @types.color_route_preview,
            )
          }
        }
      }
    None => ()
  }
}

///|
fn draw_caravan(game : @types.Game) -> Unit {
  let size = @types.hex_size
  let (cx, cy) = @types.hex_to_pixel(game.caravan.pos, size)
  // Caravan body - a small camel/cart shape
  let r = size * 0.3
  @raylib.draw_circle(cx.to_int(), cy.to_int(), r, @types.color_caravan)
  @raylib.draw_circle(
    cx.to_int(),
    cy.to_int(),
    r * 0.6,
    @raylib.Color::new(240, 120, 60, 255),
  )
  // Direction indicator dot
  @raylib.draw_circle(cx.to_int(), (cy - r * 0.3).to_int(), 3.0, @raylib.Color::new(255, 255, 255, 200))
}
