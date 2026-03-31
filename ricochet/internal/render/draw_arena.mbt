///|
let ox : Float = @types.arena_offset_x

///|
let oy : Float = @types.arena_offset_y

///|
/// Draw the arena background grid.
fn draw_grid() -> Unit {
  let grid_spacing : Int = 50
  let aw = @types.arena_width.to_int()
  let ah = @types.arena_height.to_int()
  let iox = ox.to_int()
  let ioy = oy.to_int()
  // Vertical grid lines
  for x = 0; x <= aw; x = x + grid_spacing {
    @raylib.draw_line(
      iox + x, ioy, iox + x, ioy + ah, @types.color_grid,
    )
  }
  // Horizontal grid lines
  for y = 0; y <= ah; y = y + grid_spacing {
    @raylib.draw_line(
      iox, ioy + y, iox + aw, ioy + y, @types.color_grid,
    )
  }
}

///|
/// Draw the arena border.
fn draw_arena_border() -> Unit {
  let iox = ox.to_int()
  let ioy = oy.to_int()
  let aw = @types.arena_width.to_int()
  let ah = @types.arena_height.to_int()
  // Glow border
  @raylib.draw_rectangle_lines_ex(
    @raylib.Rectangle::new(ox - 2.0, oy - 2.0, @types.arena_width + 4.0, @types.arena_height + 4.0),
    3.0,
    @types.color_wall_glow,
  )
  // Main border
  @raylib.draw_rectangle_lines(
    iox, ioy, aw, ah, @types.color_wall,
  )
}

///|
/// Draw walls with glow effect.
pub fn draw_walls(level : @types.Level) -> Unit {
  for i in 0..<level.walls.length() {
    let w = level.walls[i]
    let x1 = ox.to_int() + w.p1.x.to_int()
    let y1 = oy.to_int() + w.p1.y.to_int()
    let x2 = ox.to_int() + w.p2.x.to_int()
    let y2 = oy.to_int() + w.p2.y.to_int()
    // Glow
    @raylib.draw_line_ex(
      @raylib.Vector2::new(Float::from_int(x1), Float::from_int(y1)),
      @raylib.Vector2::new(Float::from_int(x2), Float::from_int(y2)),
      5.0,
      @types.color_wall_glow,
    )
    // Main line
    @raylib.draw_line_ex(
      @raylib.Vector2::new(Float::from_int(x1), Float::from_int(y1)),
      @raylib.Vector2::new(Float::from_int(x2), Float::from_int(y2)),
      2.0,
      @types.color_wall,
    )
  }
}

///|
/// Draw targets as pulsing rings.
pub fn draw_targets(level : @types.Level, anim : Float) -> Unit {
  for i in 0..<level.targets.length() {
    let t = level.targets[i]
    let tx = ox.to_int() + t.pos.x.to_int()
    let ty = oy.to_int() + t.pos.y.to_int()
    let r = t.radius.to_int()
    if t.hit {
      // Hit: filled with low alpha
      @raylib.draw_circle(tx, ty, t.radius, @types.color_target_hit)
      @raylib.draw_circle_lines(tx, ty, t.radius, @types.color_target_hit)
    } else {
      // Pulsing ring
      let pulse : Float = 1.0 + 0.15 * @types.sinf(
          anim * 3.0 + Float::from_int(i) * 1.5,
        )
      let pr = Float::from_int(r) * pulse
      @raylib.draw_circle_lines(tx, ty, pr, @types.color_target)
      @raylib.draw_circle_lines(tx, ty, pr - 3.0, @types.color_target)
      // Inner dot
      @raylib.draw_circle(tx, ty, 3.0, @types.color_target)
    }
  }
}

///|
/// Draw splitters as diamond shapes.
pub fn draw_splitters(level : @types.Level, anim : Float) -> Unit {
  for i in 0..<level.splitters.length() {
    let sp = level.splitters[i]
    let sx = ox + sp.pos.x
    let sy = oy + sp.pos.y
    let r = sp.radius
    let pulse : Float = if sp.pulse_timer > 0.0 {
      1.3
    } else {
      1.0 + 0.1 * @types.sinf(anim * 2.0)
    }
    let pr = r * pulse
    // Diamond shape: 4 points
    let top = @raylib.Vector2::new(sx, sy - pr)
    let right = @raylib.Vector2::new(sx + pr, sy)
    let bottom = @raylib.Vector2::new(sx, sy + pr)
    let left = @raylib.Vector2::new(sx - pr, sy)
    @raylib.draw_line_ex(top, right, 2.0, @types.color_splitter)
    @raylib.draw_line_ex(right, bottom, 2.0, @types.color_splitter)
    @raylib.draw_line_ex(bottom, left, 2.0, @types.color_splitter)
    @raylib.draw_line_ex(left, top, 2.0, @types.color_splitter)
    // Center dot
    @raylib.draw_circle(sx.to_int(), sy.to_int(), 3.0, @types.color_splitter)
  }
}

///|
/// Draw one-way gates with direction arrows.
pub fn draw_gates(level : @types.Level) -> Unit {
  for i in 0..<level.gates.length() {
    let g = level.gates[i]
    let x1 = ox + g.p1.x
    let y1 = oy + g.p1.y
    let x2 = ox + g.p2.x
    let y2 = oy + g.p2.y
    // Gate line
    @raylib.draw_line_ex(
      @raylib.Vector2::new(x1, y1),
      @raylib.Vector2::new(x2, y2),
      3.0,
      @types.color_gate,
    )
    // Direction arrow at midpoint
    let mx = (x1 + x2) / 2.0
    let my = (y1 + y2) / 2.0
    let arrow_len : Float = 12.0
    let tip_x = mx + g.direction.x * arrow_len
    let tip_y = my + g.direction.y * arrow_len
    @raylib.draw_line_ex(
      @raylib.Vector2::new(mx, my),
      @raylib.Vector2::new(tip_x, tip_y),
      2.0,
      @types.color_gate,
    )
    // Arrowhead
    let perp_x = -g.direction.y * 5.0
    let perp_y = g.direction.x * 5.0
    let base_x = tip_x - g.direction.x * 6.0
    let base_y = tip_y - g.direction.y * 6.0
    @raylib.draw_triangle(
      @raylib.Vector2::new(tip_x, tip_y),
      @raylib.Vector2::new(base_x + perp_x, base_y + perp_y),
      @raylib.Vector2::new(base_x - perp_x, base_y - perp_y),
      @types.color_gate,
    )
  }
}

///|
/// Draw bumpers as glowing circles.
pub fn draw_bumpers(level : @types.Level, anim : Float) -> Unit {
  for i in 0..<level.bumpers.length() {
    let b = level.bumpers[i]
    let bx = ox.to_int() + b.pos.x.to_int()
    let by = oy.to_int() + b.pos.y.to_int()
    let pulse : Float = if b.hit_timer > 0.0 {
      1.4
    } else {
      1.0 + 0.08 * @types.sinf(anim * 4.0 + Float::from_int(i) * 2.0)
    }
    let r = b.radius * pulse
    // Outer glow
    @raylib.draw_circle(
      bx, by, r + 4.0,
      @raylib.Color::new(255, 160, 0, 40),
    )
    // Ring
    @raylib.draw_circle_lines(bx, by, r, @types.color_bumper)
    @raylib.draw_circle_lines(bx, by, r - 3.0, @types.color_bumper)
    // Center
    @raylib.draw_circle(bx, by, 3.0, @types.color_bumper)
  }
}

///|
/// Draw pickups.
pub fn draw_pickups(level : @types.Level, anim : Float) -> Unit {
  for i in 0..<level.pickups.length() {
    let p = level.pickups[i]
    if p.collected {
      continue
    }
    let px = ox.to_int() + p.pos.x.to_int()
    let py = oy.to_int() + p.pos.y.to_int()
    let bob : Float = @types.sinf(anim * 2.5) * 3.0
    let draw_y = Float::from_int(py) + bob
    // Star-like shape
    @raylib.draw_circle(
      px, draw_y.to_int(), p.radius,
      @raylib.Color::new(180, 100, 255, 60),
    )
    @raylib.draw_circle_lines(
      px, draw_y.to_int(), p.radius,
      @types.color_pickup_item,
    )
    @raylib.draw_circle(px, draw_y.to_int(), 3.0, @types.color_pickup_item)
  }
}

///|
/// Draw complete arena: grid, border, all objects.
pub fn draw_arena(game : @types.Game) -> Unit {
  draw_grid()
  draw_arena_border()
  match game.current_level {
    Some(level) => {
      draw_walls(level)
      draw_targets(level, game.anim_timer)
      draw_splitters(level, game.anim_timer)
      draw_gates(level)
      draw_bumpers(level, game.anim_timer)
      draw_pickups(level, game.anim_timer)
    }
    None => ()
  }
}
