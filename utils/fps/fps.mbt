///|
/// Number of frame-time samples stored in the ring buffer.
let history_len : Int = 160

///|
/// Ring buffer of raw frame-time values (seconds).
let frame_times : Array[Float] = Array::make(160, 1.0 / 60.0)

///|
/// Write cursor into the ring buffer.
let cursor : Ref[Int] = { val: 0 }

///|
/// Records a single frame-time sample.
fn record(dt : Float) -> Unit {
  frame_times[cursor.val] = dt
  cursor.val = (cursor.val + 1) % history_len
}

///|
/// Draws the FPS graph overlay in the bottom-right corner.
///
/// Call once per frame, between `begin_drawing` and `end_drawing`.
/// Automatically records the current frame time from `@raylib.get_frame_time`.
pub fn draw() -> Unit {
  let dt = @raylib.get_frame_time()
  record(dt)
  let screen_w = @raylib.get_screen_width()
  let screen_h = @raylib.get_screen_height()
  let target_fps = 60
  let panel_w = 176
  let panel_h = 78
  let panel_x = screen_w - panel_w - 12
  let panel_y = screen_h - panel_h - 12
  let prev = if cursor.val == 0 { history_len - 1 } else { cursor.val - 1 }
  let latest_dt = frame_times[prev]
  let latest_ms = latest_dt * 1000.0F
  let latest_fps = if latest_dt > 0.0001F {
    (1.0F / latest_dt).to_int()
  } else {
    0
  }
  let target_ms : Float = 1000.0F / Float::from_int(target_fps)
  let white = @raylib.Color::new(252, 252, 252, 255)
  let yellow = @raylib.Color::new(252, 200, 32, 255)
  let green = @raylib.Color::new(80, 220, 120, 255)
  let red = @raylib.Color::new(228, 80, 80, 255)
  // Panel background
  @raylib.draw_rectangle(
    panel_x, panel_y, panel_w, panel_h, @raylib.Color::new(0, 0, 0, 170),
  )
  @raylib.draw_rectangle_lines(
    panel_x, panel_y, panel_w, panel_h, @raylib.Color::new(255, 255, 255, 60),
  )
  // FPS label + value + ms
  @draw.draw_text("FPS", panel_x + 8, panel_y + 6, 16, white)
  let fps_color = if latest_ms <= target_ms {
    green
  } else if latest_ms <= target_ms * 1.5 {
    yellow
  } else {
    red
  }
  @draw.draw_text(latest_fps.to_string(), panel_x + 44, panel_y + 6, 16, fps_color)
  // Truncate ms string to avoid long decimals
  let ms_str = {
    let s = latest_ms.to_string()
    // Show at most 5 chars (e.g. "16.67")
    if s.length() > 5 {
      s[:5].to_string()
    } else {
      s
    }
  }
  @draw.draw_text(ms_str + " ms", panel_x + 92, panel_y + 6, 16, white)
  // Graph area
  let graph_x = panel_x + 8
  let graph_y = panel_y + 28
  let graph_w = panel_w - 16
  let graph_h = panel_h - 38
  @raylib.draw_rectangle(
    graph_x,
    graph_y,
    graph_w,
    graph_h,
    @raylib.Color::new(255, 255, 255, 18),
  )
  // Target FPS line
  let target_line_y = graph_y + graph_h -
    (target_ms / 33.333F * Float::from_int(graph_h)).to_int().clamp(min=0, max=graph_h)
  @raylib.draw_line(
    graph_x,
    target_line_y,
    graph_x + graph_w,
    target_line_y,
    @raylib.Color::new(80, 220, 120, 120),
  )
  // Frame time bars
  let sample_count = if graph_w < history_len { graph_w } else { history_len }
  let mut start = cursor.val - sample_count
  while start < 0 {
    start = start + history_len
  }
  for i in 0..<sample_count {
    let idx = (start + i) % history_len
    let ms = frame_times[idx] * 1000.0F
    let height = (ms / 33.333F * Float::from_int(graph_h))
      .to_int()
      .clamp(min=1, max=graph_h)
    let x = graph_x + i
    let y = graph_y + graph_h - height
    let col = if ms <= target_ms {
      @raylib.Color::new(80, 220, 120, 220)
    } else if ms <= target_ms * 1.5 {
      @raylib.Color::new(252, 200, 32, 220)
    } else {
      @raylib.Color::new(228, 80, 80, 220)
    }
    @raylib.draw_line(x, graph_y + graph_h, x, y, col)
  }
}
