// Visual effects for the game

// Draw animated grid background for menus

///|
pub fn draw_grid_background(frame : Int) -> Unit {
  let spacing = 40
  let offset = frame % spacing
  let line_color = @raylib.Color::new(25, 25, 45, 255)
  // Vertical lines
  let mut x = -offset
  while x < @types.screen_width + spacing {
    @raylib.draw_line(x, 0, x, @types.screen_height, line_color)
    x += spacing
  }
  // Horizontal lines
  let mut y = -offset
  while y < @types.screen_height + spacing {
    @raylib.draw_line(0, y, @types.screen_width, y, line_color)
    y += spacing
  }
}

// Draw a pulsing border around a rectangle

///|
pub fn draw_pulse_border(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  frame : Int,
  color : @raylib.Color,
) -> Unit {
  let t : Float = Float::from_int(frame) * 0.05
  let pulse = Float::from_double(@math.sin(t.to_double())) * 0.3 + 0.7
  let alpha = (pulse * Float::from_int(color.a.to_int())).to_int()
  let c = @raylib.Color::new(
    color.r.to_int(),
    color.g.to_int(),
    color.b.to_int(),
    alpha,
  )
  @raylib.draw_rectangle_lines(x, y, w, h, c)
  @raylib.draw_rectangle_lines(x - 1, y - 1, w + 2, h + 2, c)
}

// Draw difficulty dots

///|
pub fn draw_difficulty(x : Int, y : Int, rating : Int) -> Unit {
  for i in 0..<5 {
    let dx = x + i * 12
    let color = if i < rating {
      @raylib.Color::new(255, 200, 50, 255)
    } else {
      @raylib.Color::new(60, 60, 80, 255)
    }
    @raylib.draw_circle(dx + 4, y + 4, 4.0, color)
  }
}

// Draw a progress bar

///|
pub fn draw_progress_bar(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  progress : Float,
  bar_color : @raylib.Color,
  bg_color : @raylib.Color,
) -> Unit {
  @raylib.draw_rectangle(x, y, w, h, bg_color)
  let fill_w = (Float::from_int(w) * @types.clampf(progress, 0.0, 1.0)).to_int()
  @raylib.draw_rectangle(x, y, fill_w, h, bar_color)
  @raylib.draw_rectangle_lines(x, y, w, h, @types.color_grid_line)
}

// Draw completion celebration effect

///|
pub fn draw_completion_particles(cx : Int, cy : Int, frame : Int) -> Unit {
  let pi : Float = 3.14159265
  let particle_count = 12
  let t : Float = Float::from_int(frame) * 0.04
  for i in 0..<particle_count {
    let angle : Float = Float::from_int(i) *
      pi *
      2.0 /
      Float::from_int(particle_count) +
      t
    let radius : Float = 40.0 +
      Float::from_double(@math.sin((t * 2.0 + Float::from_int(i)).to_double())) *
      15.0
    let px = Float::from_int(cx) +
      Float::from_double(@math.cos(angle.to_double())) * radius
    let py = Float::from_int(cy) +
      Float::from_double(@math.sin(angle.to_double())) * radius
    let hue = (i * 30 + frame * 2) % 360
    let color = hue_to_color(hue)
    @raylib.draw_circle(px.to_int(), py.to_int(), 3.0, color)
  }
}

// Simple HSV to RGB conversion for celebration colors

///|
fn hue_to_color(hue : Int) -> @raylib.Color {
  let h = hue % 360
  let sector = h / 60
  let f : Float = Float::from_int(h % 60) / 60.0
  let one : Float = 1.0
  let max_val : Float = 255.0
  let q = (max_val * (one - f)).to_int()
  let t_val = (max_val * f).to_int()
  match sector {
    0 => @raylib.Color::new(255, t_val, 0, 255)
    1 => @raylib.Color::new(q, 255, 0, 255)
    2 => @raylib.Color::new(0, 255, t_val, 255)
    3 => @raylib.Color::new(0, q, 255, 255)
    4 => @raylib.Color::new(t_val, 0, 255, 255)
    _ => @raylib.Color::new(255, 0, q, 255)
  }
}

// Draw a view label with icon

///|
pub fn draw_view_label(
  x : Int,
  y : Int,
  label : String,
  icon_type : @types.ViewKind,
  color : @raylib.Color,
) -> Unit {
  // Draw small axis indicator
  match icon_type {
    Top => {
      // XZ plane indicator
      @raylib.draw_line(x, y + 10, x + 12, y + 10, color)
      @raylib.draw_line(x, y + 10, x, y, color)
      @draw.draw_text("x", x + 13, y + 5, 10, color)
      @draw.draw_text("z", x - 8, y - 5, 10, color)
    }
    Front => {
      // XY plane indicator
      @raylib.draw_line(x, y + 10, x + 12, y + 10, color)
      @raylib.draw_line(x, y + 10, x, y, color)
      @draw.draw_text("x", x + 13, y + 5, 10, color)
      @draw.draw_text("y", x - 8, y - 5, 10, color)
    }
    Side => {
      // ZY plane indicator
      @raylib.draw_line(x, y + 10, x + 12, y + 10, color)
      @raylib.draw_line(x, y + 10, x, y, color)
      @draw.draw_text("z", x + 13, y + 5, 10, color)
      @draw.draw_text("y", x - 8, y - 5, 10, color)
    }
  }
  @draw.draw_text(label, x + 25, y, 14, color)
}

// Draw a tooltip box

///|
pub fn draw_tooltip(x : Int, y : Int, text : String) -> Unit {
  let tw = @draw.measure_text(text, 14)
  let pad = 6
  let bx = x - pad
  let by = y - pad
  let bw = tw + pad * 2
  let bh = 14 + pad * 2
  @raylib.draw_rectangle(bx, by, bw, bh, @raylib.Color::new(0, 0, 0, 200))
  @raylib.draw_rectangle_lines(bx, by, bw, bh, @types.color_grid_line)
  @draw.draw_text(text, x, y, 14, @types.color_text)
}

// Draw a voxel count display with bar

///|
pub fn draw_voxel_budget_bar(
  x : Int,
  y : Int,
  filled : Int,
  budget : Int,
) -> Unit {
  let w = 120
  let h = 12
  let progress : Float = Float::from_int(filled) / Float::from_int(budget)
  let bar_color = if filled > budget {
    @types.color_unmatched
  } else if filled == budget {
    @raylib.Color::new(255, 200, 50, 255)
  } else {
    @types.color_matched
  }
  draw_progress_bar(
    x,
    y,
    w,
    h,
    progress,
    bar_color,
    @raylib.Color::new(30, 30, 50, 255),
  )
  let text = filled.to_string() + "/" + budget.to_string()
  @draw.draw_text(text, x + w + 8, y - 2, 14, @types.color_text)
}

// Animate text appearance (fade in character by character)

///|
pub fn draw_animated_text(
  text : String,
  x : Int,
  y : Int,
  size : Int,
  color : @raylib.Color,
  reveal_count : Int,
) -> Unit {
  // Simple: draw the full text if reveal_count exceeds length
  let len = text.length()
  if reveal_count >= len {
    @draw.draw_text(text, x, y, size, color)
  } else if reveal_count > 0 {
    // Draw substring
    let sub = text[:reveal_count].to_owned()
    @draw.draw_text(sub, x, y, size, color)
  }
}

// Draw connection lines between two points

///|
pub fn draw_connection_indicator(
  x1 : Int,
  y1 : Int,
  x2 : Int,
  y2 : Int,
  connected : Bool,
  frame : Int,
) -> Unit {
  let color = if connected {
    @types.color_matched
  } else {
    @types.color_unmatched
  }
  if connected {
    @raylib.draw_line(x1, y1, x2, y2, color)
  } else {
    // Draw dashed line for disconnected
    let segments = 8
    for i in 0..<segments {
      if i % 2 == frame / 10 % 2 {
        let t1 : Float = Float::from_int(i) / Float::from_int(segments)
        let t2 : Float = Float::from_int(i + 1) / Float::from_int(segments)
        let sx = Float::from_int(x1) + Float::from_int(x2 - x1) * t1
        let sy = Float::from_int(y1) + Float::from_int(y2 - y1) * t1
        let ex = Float::from_int(x1) + Float::from_int(x2 - x1) * t2
        let ey = Float::from_int(y1) + Float::from_int(y2 - y1) * t2
        @raylib.draw_line(
          sx.to_int(),
          sy.to_int(),
          ex.to_int(),
          ey.to_int(),
          color,
        )
      }
    }
  }
}
