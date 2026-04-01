///|
fn draw_playing(game : @types.Game) -> Unit {
  draw_plane_bg()
  draw_target_polygon(game)
  draw_hull(game)
  draw_points(game)
  draw_snap_preview(game)
  draw_playing_ui(game)
}

///|
fn draw_plane_bg() -> Unit {
  let px = @types.plane_x.to_int()
  let py = @types.plane_y.to_int()
  let pw = @types.plane_width.to_int()
  let ph = @types.plane_height.to_int()
  // Background
  @raylib.draw_rectangle(px, py, pw, ph, @types.color_plane_bg)
  // Grid lines
  let grid = @types.grid_snap.to_int()
  let mut gx = px
  while gx <= px + pw {
    let color = if (gx - px) % (grid * 5) == 0 {
      @types.color_grid_major
    } else {
      @types.color_grid
    }
    @raylib.draw_line(gx, py, gx, py + ph, color)
    gx += grid
  }
  let mut gy = py
  while gy <= py + ph {
    let color = if (gy - py) % (grid * 5) == 0 {
      @types.color_grid_major
    } else {
      @types.color_grid
    }
    @raylib.draw_line(px, gy, px + pw, gy, color)
    gy += grid
  }
  // Border
  @raylib.draw_rectangle_lines(
    px - 1,
    py - 1,
    pw + 2,
    ph + 2,
    @types.color_ui_dim,
  )
}

///|
fn draw_target_polygon(game : @types.Game) -> Unit {
  let verts = game.target.vertices
  let n = verts.length()
  if n < 2 {
    return
  }
  // Fill
  if n >= 3 {
    // Draw filled triangles from centroid
    let mut cx : Float = 0.0
    let mut cy : Float = 0.0
    for i in 0..<n {
      cx += verts[i].x
      cy += verts[i].y
    }
    cx /= Float::from_int(n)
    cy /= Float::from_int(n)
    for i in 0..<n {
      let a = verts[i]
      let b = verts[(i + 1) % n]
      @raylib.draw_triangle(
        @raylib.Vector2::new(cx, cy),
        @raylib.Vector2::new(a.x, a.y),
        @raylib.Vector2::new(b.x, b.y),
        @types.color_target_fill,
      )
    }
  }
  // Dashed outline
  let time = Float::from_int(game.frame_count) * 0.05
  for i in 0..<n {
    let a = verts[i]
    let b = verts[(i + 1) % n]
    draw_dashed_line(a.x, a.y, b.x, b.y, @types.color_target, time)
  }
  // Vertex markers
  for i in 0..<n {
    let v = verts[i]
    @raylib.draw_circle_lines(
      v.x.to_int(),
      v.y.to_int(),
      5.0,
      @types.color_target,
    )
  }
}

///|
fn draw_dashed_line(
  x1 : Float,
  y1 : Float,
  x2 : Float,
  y2 : Float,
  color : @raylib.Color,
  time_offset : Float,
) -> Unit {
  let dx = x2 - x1
  let dy = y2 - y1
  let len = @types.sqrtf(dx * dx + dy * dy)
  if len < 1.0 {
    return
  }
  let dash_len : Float = 10.0
  let gap_len : Float = 6.0
  let cycle = dash_len + gap_len
  let nx = dx / len
  let ny = dy / len
  let mut t : Float = time_offset * 3.0 % cycle - cycle
  while t < len {
    let start = @types.maxf(t, 0.0)
    let end = @types.minf(t + dash_len, len)
    if end > start {
      @raylib.draw_line(
        (x1 + nx * start).to_int(),
        (y1 + ny * start).to_int(),
        (x1 + nx * end).to_int(),
        (y1 + ny * end).to_int(),
        color,
      )
    }
    t += cycle
  }
}

///|
fn draw_hull(game : @types.Game) -> Unit {
  let hull = game.current_hull
  let n = hull.length()
  if n < 2 {
    return
  }
  // Fill
  if n >= 3 {
    let mut cx : Float = 0.0
    let mut cy : Float = 0.0
    for i in 0..<n {
      cx += hull[i].x
      cy += hull[i].y
    }
    cx /= Float::from_int(n)
    cy /= Float::from_int(n)
    for i in 0..<n {
      let a = hull[i]
      let b = hull[(i + 1) % n]
      @raylib.draw_triangle(
        @raylib.Vector2::new(cx, cy),
        @raylib.Vector2::new(a.x, a.y),
        @raylib.Vector2::new(b.x, b.y),
        @types.color_hull_fill,
      )
    }
  }
  // Edges with match coloring
  for i in 0..<n {
    let a = hull[i]
    let b = hull[(i + 1) % n]
    let edge_color = if edge_matches_any_target(a, b, game.target.vertices) {
      @types.color_match
    } else {
      @types.color_hull
    }
    @raylib.draw_line_ex(
      @raylib.Vector2::new(a.x, a.y),
      @raylib.Vector2::new(b.x, b.y),
      2.0,
      edge_color,
    )
  }
}

///|
fn edge_matches_any_target(
  ha : @types.Point,
  hb : @types.Point,
  target_verts : Array[@types.Point],
) -> Bool {
  let tn = target_verts.length()
  if tn < 2 {
    return false
  }
  for i in 0..<tn {
    let ta = target_verts[i]
    let tb = target_verts[(i + 1) % tn]
    let tol = @types.tolerance
    let d1 = @types.point_to_segment_dist(ta, ha, hb)
    let d2 = @types.point_to_segment_dist(tb, ha, hb)
    let d3 = @types.point_to_segment_dist(ha, ta, tb)
    let d4 = @types.point_to_segment_dist(hb, ta, tb)
    if d1 < tol && d2 < tol && d3 < tol && d4 < tol {
      return true
    }
  }
  false
}

///|
fn draw_points(game : @types.Game) -> Unit {
  let hull = game.current_hull
  for i in 0..<game.placed_points.length() {
    let p = game.placed_points[i]
    let on_hull = @geometry.is_point_on_hull(p, hull)
    let is_hover_remove = game.hover_remove == i
    if is_hover_remove {
      // Highlight for removal
      @raylib.draw_circle(
        p.x.to_int(),
        p.y.to_int(),
        @types.point_radius + 4.0,
        @types.color_hover_remove,
      )
    }
    if on_hull {
      // Hull vertex - larger, bright
      @raylib.draw_circle(
        p.x.to_int(),
        p.y.to_int(),
        @types.hull_point_radius,
        @types.color_point,
      )
      @raylib.draw_circle_lines(
        p.x.to_int(),
        p.y.to_int(),
        @types.hull_point_radius + 2.0,
        @types.color_point,
      )
    } else {
      // Interior point - dimmer, smaller
      @raylib.draw_circle(
        p.x.to_int(),
        p.y.to_int(),
        @types.point_radius,
        @types.color_point_interior,
      )
    }
  }
}

///|
fn draw_snap_preview(game : @types.Game) -> Unit {
  match game.snap_preview {
    Some(p) =>
      if game.play_state != Completed {
        @raylib.draw_circle(
          p.x.to_int(),
          p.y.to_int(),
          @types.point_radius,
          @types.color_snap,
        )
        // Crosshair
        let s = 10
        @raylib.draw_line(
          p.x.to_int() - s,
          p.y.to_int(),
          p.x.to_int() + s,
          p.y.to_int(),
          @types.color_snap,
        )
        @raylib.draw_line(
          p.x.to_int(),
          p.y.to_int() - s,
          p.x.to_int(),
          p.y.to_int() + s,
          @types.color_snap,
        )
      }
    None => ()
  }
}
