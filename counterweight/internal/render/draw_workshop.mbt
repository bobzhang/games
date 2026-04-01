///|
fn draw_playing(game : @types.Game) -> Unit {
  draw_workshop_bg(game)
  draw_grid(game)
  if game.has_waterfall {
    draw_waterfall(game)
  }
  draw_ropes(game)
  draw_platforms(game)
  draw_weights(game)
  draw_crates(game)
  draw_buckets(game)
  draw_nodes(game)
  draw_target_indicators(game)
  draw_connecting_line(game)
  draw_playing_ui(game)
}

///|
fn draw_workshop_bg(game : @types.Game) -> Unit {
  let ox = game.grid_offset_x
  let oy = game.grid_offset_y
  let gw = @types.grid_cols * @types.cell_size
  let gh = @types.grid_rows * @types.cell_size
  // Workshop panel background
  @raylib.draw_rectangle(
    ox - 10,
    oy - 10,
    gw + 20,
    gh + 20,
    @types.color_grid_bg,
  )
  @raylib.draw_rectangle_lines(
    ox - 10,
    oy - 10,
    gw + 20,
    gh + 20,
    @types.color_pulley_brass,
  )
  // Decorative corner gears
  let time = Float::from_int(game.frame_count) * 0.02
  draw_bg_gear(ox - 5, oy - 5, 18.0, time, @types.color_gear)
  draw_bg_gear(ox + gw + 5, oy - 5, 18.0, -time, @types.color_gear)
  draw_bg_gear(ox - 5, oy + gh + 5, 18.0, -time, @types.color_gear)
  draw_bg_gear(ox + gw + 5, oy + gh + 5, 18.0, time, @types.color_gear)
}

///|
fn draw_bg_gear(
  cx : Int,
  cy : Int,
  radius : Float,
  angle : Float,
  color : @raylib.Color,
) -> Unit {
  let fcx = Float::from_int(cx)
  let fcy = Float::from_int(cy)
  @raylib.draw_circle(cx, cy, radius * 0.65, color)
  @raylib.draw_circle(cx, cy, radius * 0.2, @types.color_bg)
  for i in 0..<6 {
    let a = angle + Float::from_int(i) * 1.0472
    let tx = fcx + @types.cosf(a) * radius
    let ty = fcy + @types.sinf(a) * radius
    @raylib.draw_circle(tx.to_int(), ty.to_int(), radius * 0.18, color)
  }
}

///|
fn draw_grid(game : @types.Game) -> Unit {
  let ox = game.grid_offset_x
  let oy = game.grid_offset_y
  let cs = @types.cell_size
  for row in 0..<=@types.grid_rows {
    let y = oy + row * cs
    @raylib.draw_line(
      ox,
      y,
      ox + @types.grid_cols * cs,
      y,
      @types.color_grid_line,
    )
  }
  for col in 0..<=@types.grid_cols {
    let x = ox + col * cs
    @raylib.draw_line(
      x,
      oy,
      x,
      oy + @types.grid_rows * cs,
      @types.color_grid_line,
    )
  }
}

///|
fn draw_nodes(game : @types.Game) -> Unit {
  let ox = game.grid_offset_x
  let oy = game.grid_offset_y
  for i in 0..<game.nodes.length() {
    let node = game.nodes[i]
    let nx = @types.node_screen_x(node, ox)
    let ny = @types.node_screen_y(node, oy)
    let is_hover = i == game.hover_node
    match node.kind {
      Pulley => draw_pulley_node(nx, ny, is_hover, game)
      Anchor => draw_anchor_node(nx, ny, is_hover)
      WeightHook => draw_hook_node(nx, ny, is_hover, @types.color_weight_hook)
      CrateHook => draw_hook_node(nx, ny, is_hover, @types.color_crate_hook)
      Ratchet => draw_ratchet_node(nx, ny, is_hover, game)
    }
  }
}

///|
fn draw_pulley_node(
  cx : Int,
  cy : Int,
  hover : Bool,
  game : @types.Game,
) -> Unit {
  let r = @types.node_radius
  if hover {
    @raylib.draw_circle(cx, cy, r + 4.0, @types.color_hook_highlight)
  }
  // Outer ring
  @raylib.draw_circle(cx, cy, r, @types.color_pulley_brass)
  // Inner hub
  @raylib.draw_circle(cx, cy, r * 0.4, @types.color_pulley_center)
  // Groove
  @raylib.draw_circle_lines(cx, cy, r * 0.75, @types.color_bg)
  // Rotating spokes
  let time = Float::from_int(game.frame_count) * 0.03
  let fcx = Float::from_int(cx)
  let fcy = Float::from_int(cy)
  for i in 0..<4 {
    let a = time + Float::from_int(i) * 1.5708
    let sx = fcx + @types.cosf(a) * r * 0.6
    let sy = fcy + @types.sinf(a) * r * 0.6
    @raylib.draw_line(
      cx,
      cy,
      sx.to_int(),
      sy.to_int(),
      @types.color_pulley_center,
    )
  }
}

///|
fn draw_anchor_node(cx : Int, cy : Int, hover : Bool) -> Unit {
  let r = @types.node_radius * 0.8
  if hover {
    @raylib.draw_circle(cx, cy, r + 4.0, @types.color_hook_highlight)
  }
  // Square anchor
  let half = r.to_int()
  @raylib.draw_rectangle(
    cx - half,
    cy - half,
    half * 2,
    half * 2,
    @types.color_anchor_gray,
  )
  @raylib.draw_rectangle_lines(
    cx - half,
    cy - half,
    half * 2,
    half * 2,
    @raylib.Color::new(180, 180, 190, 255),
  )
  // Cross mark
  let qr = half / 2
  @raylib.draw_line(cx - qr, cy - qr, cx + qr, cy + qr, @types.color_bg)
  @raylib.draw_line(cx - qr, cy + qr, cx + qr, cy - qr, @types.color_bg)
}

///|
fn draw_hook_node(
  cx : Int,
  cy : Int,
  hover : Bool,
  color : @raylib.Color,
) -> Unit {
  let r = @types.node_radius * 0.6
  if hover {
    @raylib.draw_circle(cx, cy, r + 4.0, @types.color_hook_highlight)
  }
  @raylib.draw_circle(cx, cy, r, color)
  // Hook arc
  @raylib.draw_circle_lines(cx, cy + 3, r * 0.5, @types.color_bg)
}

///|
fn draw_ratchet_node(
  cx : Int,
  cy : Int,
  hover : Bool,
  game : @types.Game,
) -> Unit {
  let r = @types.node_radius
  if hover {
    @raylib.draw_circle(cx, cy, r + 4.0, @types.color_hook_highlight)
  }
  // Ratchet is like a pulley but with teeth on one side
  @raylib.draw_circle(cx, cy, r, @types.color_ratchet)
  @raylib.draw_circle(cx, cy, r * 0.35, @types.color_bg)
  // Ratchet teeth indicator (arrow showing one-way)
  let time = Float::from_int(game.frame_count) * 0.02
  let fcx = Float::from_int(cx)
  let fcy = Float::from_int(cy)
  for i in 0..<3 {
    let a = time + Float::from_int(i) * 2.094
    let tx = fcx + @types.cosf(a) * r * 0.7
    let ty = fcy + @types.sinf(a) * r * 0.7
    @raylib.draw_circle(
      tx.to_int(),
      ty.to_int(),
      3.0,
      @raylib.Color::new(60, 30, 15, 255),
    )
  }
}

///|
fn draw_ropes(game : @types.Game) -> Unit {
  let ox = game.grid_offset_x
  let oy = game.grid_offset_y
  for i in 0..<game.ropes.length() {
    let r = game.ropes[i]
    if r.active {
      let from_node = game.nodes[r.from_node]
      let to_node = game.nodes[r.to_node]
      let fx = @types.node_screen_x(from_node, ox)
      let fy = @types.node_screen_y(from_node, oy)
      let tx = @types.node_screen_x(to_node, ox)
      let ty = @types.node_screen_y(to_node, oy)
      let color = if r.broken {
        @types.color_rope_break
      } else if r.breakable {
        @raylib.Color::new(200, 130, 80, 255)
      } else {
        @types.color_rope
      }
      if r.broken {
        // Draw broken rope as two dangling halves
        let mid_x = (fx + tx) / 2
        let mid_y = (fy + ty) / 2 + 20
        @raylib.draw_line_ex(
          @raylib.Vector2::new(Float::from_int(fx), Float::from_int(fy)),
          @raylib.Vector2::new(Float::from_int(mid_x), Float::from_int(mid_y)),
          @types.rope_thickness,
          color,
        )
        @raylib.draw_line_ex(
          @raylib.Vector2::new(Float::from_int(tx), Float::from_int(ty)),
          @raylib.Vector2::new(
            Float::from_int(mid_x + 5),
            Float::from_int(mid_y + 10),
          ),
          @types.rope_thickness,
          color,
        )
      } else {
        @raylib.draw_line_ex(
          @raylib.Vector2::new(Float::from_int(fx), Float::from_int(fy)),
          @raylib.Vector2::new(Float::from_int(tx), Float::from_int(ty)),
          @types.rope_thickness,
          color,
        )
        // Draw load indicator for breakable ropes
        if r.breakable {
          let mid_x = (fx + tx) / 2
          let mid_y = (fy + ty) / 2
          @raylib.draw_circle(
            mid_x,
            mid_y,
            4.0,
            @raylib.Color::new(255, 160, 60, 200),
          )
        }
      }
    }
  }
}

///|
fn draw_weights(game : @types.Game) -> Unit {
  let ox = game.grid_offset_x
  let oy = game.grid_offset_y
  for i in 0..<game.weights.length() {
    let w = game.weights[i]
    if w.active {
      let node = game.nodes[w.node_id]
      let nx = @types.node_screen_x(node, ox)
      let base_ny = @types.grid_to_screen_y(node.pos.y, oy)
      let height_offset = (w.current_y * Float::from_int(@types.cell_size)).to_int()
      let ny = base_ny + height_offset + 20
      let ww = @types.weight_width.to_int()
      let wh = @types.weight_height.to_int()
      // Bob animation
      let bob = if w.bob_timer > 0.0 {
        (@types.sinf(w.bob_timer * 15.0) * 3.0 * w.bob_timer).to_int()
      } else {
        0
      }
      let dy = ny + bob
      // Draw rope from hook to weight
      @raylib.draw_line_ex(
        @raylib.Vector2::new(Float::from_int(nx), Float::from_int(base_ny)),
        @raylib.Vector2::new(Float::from_int(nx), Float::from_int(dy)),
        1.5,
        @types.color_rope,
      )
      // Weight body
      @raylib.draw_rectangle(
        nx - ww / 2,
        dy - wh / 2,
        ww,
        wh,
        @types.color_weight_iron,
      )
      @raylib.draw_rectangle(
        nx - ww / 2 + 3,
        dy - wh / 2 + 3,
        ww - 6,
        wh - 6,
        @types.color_weight_dark,
      )
      @raylib.draw_rectangle_lines(
        nx - ww / 2,
        dy - wh / 2,
        ww,
        wh,
        @raylib.Color::new(140, 145, 155, 255),
      )
      // Mass label
      let mass_str = w.mass.to_int().to_string()
      let msw = @draw.measure_text(mass_str, 16)
      @draw.draw_text(
        mass_str,
        nx - msw / 2,
        dy - 8,
        16,
        @raylib.Color::new(220, 220, 230, 255),
      )
    }
  }
}

///|
fn draw_crates(game : @types.Game) -> Unit {
  let ox = game.grid_offset_x
  let oy = game.grid_offset_y
  for i in 0..<game.crates.length() {
    let c = game.crates[i]
    if c.active {
      let node = game.nodes[c.node_id]
      let nx = @types.node_screen_x(node, ox)
      let base_ny = @types.grid_to_screen_y(node.pos.y, oy)
      let height_offset = (c.current_y * Float::from_int(@types.cell_size)).to_int()
      let ny = base_ny + height_offset + 20
      let cs = @types.crate_size.to_int()
      // Rope from hook
      @raylib.draw_line_ex(
        @raylib.Vector2::new(Float::from_int(nx), Float::from_int(base_ny)),
        @raylib.Vector2::new(Float::from_int(nx), Float::from_int(ny)),
        1.5,
        @types.color_rope,
      )
      // Crate body
      let border_color = if c.at_target {
        @types.color_success
      } else {
        @types.color_crate_dark
      }
      @raylib.draw_rectangle(
        nx - cs / 2,
        ny - cs / 2,
        cs,
        cs,
        @types.color_crate_wood,
      )
      @raylib.draw_rectangle_lines(
        nx - cs / 2,
        ny - cs / 2,
        cs,
        cs,
        border_color,
      )
      // Wood grain lines
      @raylib.draw_line(
        nx - cs / 2 + 5,
        ny - cs / 2 + 8,
        nx + cs / 2 - 5,
        ny - cs / 2 + 8,
        @types.color_crate_dark,
      )
      @raylib.draw_line(
        nx - cs / 2 + 5,
        ny + cs / 2 - 8,
        nx + cs / 2 - 5,
        ny + cs / 2 - 8,
        @types.color_crate_dark,
      )
      // Mass label
      let mass_str = c.mass.to_int().to_string()
      let msw = @draw.measure_text(mass_str, 16)
      @draw.draw_text(
        mass_str,
        nx - msw / 2,
        ny - 8,
        16,
        @raylib.Color::new(255, 240, 210, 255),
      )
      // At-target glow
      if c.at_target {
        @raylib.draw_circle(
          nx,
          ny,
          Float::from_int(cs / 2 + 5),
          @types.color_target_glow,
        )
      }
    }
  }
}

///|
fn draw_buckets(game : @types.Game) -> Unit {
  let ox = game.grid_offset_x
  let oy = game.grid_offset_y
  for i in 0..<game.buckets.length() {
    let b = game.buckets[i]
    if b.active {
      let node = game.nodes[b.node_id]
      let nx = @types.node_screen_x(node, ox)
      let base_ny = @types.grid_to_screen_y(node.pos.y, oy)
      let height_offset = (b.current_y * Float::from_int(@types.cell_size)).to_int()
      let ny = base_ny + height_offset + 20
      let bw = @types.bucket_width.to_int()
      let bh = @types.bucket_height.to_int()
      // Rope
      @raylib.draw_line_ex(
        @raylib.Vector2::new(Float::from_int(nx), Float::from_int(base_ny)),
        @raylib.Vector2::new(Float::from_int(nx), Float::from_int(ny)),
        1.5,
        @types.color_rope,
      )
      // Bucket body
      @raylib.draw_rectangle(
        nx - bw / 2,
        ny - bh / 2,
        bw,
        bh,
        @types.color_bucket,
      )
      @raylib.draw_rectangle_lines(
        nx - bw / 2,
        ny - bh / 2,
        bw,
        bh,
        @raylib.Color::new(150, 115, 80, 255),
      )
      // Water fill level
      let fill_ratio = if b.max_mass > 0.0 {
        (b.mass - 1.0) / (b.max_mass - 1.0)
      } else {
        0.0
      }
      let fill_h = (Float::from_int(bh - 4) *
      @types.clampf(fill_ratio, 0.0, 1.0)).to_int()
      if fill_h > 0 {
        @raylib.draw_rectangle(
          nx - bw / 2 + 2,
          ny + bh / 2 - fill_h - 2,
          bw - 4,
          fill_h,
          @types.color_water,
        )
      }
      // Mass label
      let mass_str = b.mass.to_int().to_string()
      let msw = @draw.measure_text(mass_str, 14)
      @draw.draw_text(
        mass_str,
        nx - msw / 2,
        ny - 7,
        14,
        @raylib.Color::new(220, 220, 230, 255),
      )
    }
  }
}

///|
fn draw_platforms(game : @types.Game) -> Unit {
  let ox = game.grid_offset_x
  let oy = game.grid_offset_y
  for i in 0..<game.platforms.length() {
    let p = game.platforms[i]
    if p.active {
      let node = game.nodes[p.node_id]
      let nx = @types.node_screen_x(node, ox)
      let ny = @types.node_screen_y(node, oy)
      let hw = (p.width / 2.0).to_int()
      @raylib.draw_rectangle(nx - hw, ny - 4, hw * 2, 8, @types.color_platform)
      @raylib.draw_rectangle_lines(
        nx - hw,
        ny - 4,
        hw * 2,
        8,
        @raylib.Color::new(140, 110, 80, 255),
      )
    }
  }
}

///|
fn draw_target_indicators(game : @types.Game) -> Unit {
  let ox = game.grid_offset_x
  let oy = game.grid_offset_y
  let time = Float::from_int(game.frame_count) * 0.05
  for i in 0..<game.targets.length() {
    let t = game.targets[i]
    if t.crate_index >= 0 && t.crate_index < game.crates.length() {
      let c = game.crates[t.crate_index]
      if c.active {
        let node = game.nodes[c.node_id]
        let nx = @types.node_screen_x(node, ox)
        let base_ny = @types.grid_to_screen_y(node.pos.y, oy)
        let target_offset = (t.target_height * Float::from_int(@types.cell_size)).to_int()
        let ty = base_ny + target_offset + 20
        // Dashed target line
        let dash_offset = (@types.sinf(time) * 5.0).to_int()
        let line_w = 40
        for d in 0..<(line_w / 8) {
          let dx = nx - line_w / 2 + d * 8 + dash_offset
          @raylib.draw_line(dx, ty, dx + 4, ty, @types.color_target_gold)
        }
        // Target marker
        @raylib.draw_circle(
          nx + line_w / 2 + 8,
          ty,
          4.0,
          @types.color_target_gold,
        )
        @raylib.draw_circle(
          nx - line_w / 2 - 8,
          ty,
          4.0,
          @types.color_target_gold,
        )
      }
    }
  }
}

///|
fn draw_waterfall(game : @types.Game) -> Unit {
  let ox = game.grid_offset_x
  let oy = game.grid_offset_y
  let wx = @types.grid_to_screen_x(game.waterfall_x, ox)
  let time = Float::from_int(game.frame_count) * 0.1
  // Water streams
  for row in 0..<@types.grid_rows {
    let y = oy + row * @types.cell_size
    for s in 0..<3 {
      let offset = (@types.sinf(
        time + Float::from_int(row) * 0.5 + Float::from_int(s),
      ) *
      3.0).to_int()
      let sx = wx + offset + (s - 1) * 4
      @raylib.draw_line(
        sx,
        y,
        sx + 1,
        y + @types.cell_size,
        @types.color_waterfall,
      )
    }
  }
}

///|
fn draw_connecting_line(game : @types.Game) -> Unit {
  match game.play_state {
    ConnectingRope(from_id) => {
      let ox = game.grid_offset_x
      let oy = game.grid_offset_y
      let from_node = game.nodes[from_id]
      let fx = @types.node_screen_x(from_node, ox)
      let fy = @types.node_screen_y(from_node, oy)
      let mx = @raylib.get_mouse_x()
      let my = @raylib.get_mouse_y()
      @raylib.draw_line_ex(
        @raylib.Vector2::new(Float::from_int(fx), Float::from_int(fy)),
        @raylib.Vector2::new(Float::from_int(mx), Float::from_int(my)),
        2.0,
        @types.color_connect_line,
      )
    }
    _ => ()
  }
}
