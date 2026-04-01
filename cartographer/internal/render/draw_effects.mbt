///|
fn draw_parchment_texture(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  seed : Int,
) -> Unit {
  // Deterministic pseudo-random stipple dots for aged paper effect
  let dot_color = @types.color_parchment_dark
  let spacing = 12
  let mut hash = seed
  for row in 0..<(h / spacing) {
    for col in 0..<(w / spacing) {
      // Simple hash for deterministic pseudo-random placement
      hash = (hash * 1103515245 + 12345).land(0x7FFFFFFF)
      let offset_x = hash % 6 - 3
      hash = (hash * 1103515245 + 12345).land(0x7FFFFFFF)
      let offset_y = hash % 6 - 3
      let dx = x + col * spacing + spacing / 2 + offset_x
      let dy = y + row * spacing + spacing / 2 + offset_y
      if dx >= x && dx < x + w && dy >= y && dy < y + h {
        // Only draw every other dot for subtlety
        if hash % 3 == 0 {
          @raylib.draw_pixel(dx, dy, dot_color)
          @raylib.draw_pixel(dx + 1, dy, dot_color)
        }
      }
    }
  }
  // Edge darkening for aged look
  let edge_color = @raylib.Color::new(200, 185, 155, 40)
  let edge_w = 8
  @raylib.draw_rectangle(x, y, w, edge_w, edge_color)
  @raylib.draw_rectangle(x, y + h - edge_w, w, edge_w, edge_color)
  @raylib.draw_rectangle(x, y, edge_w, h, edge_color)
  @raylib.draw_rectangle(x + w - edge_w, y, edge_w, h, edge_color)
}

///|
fn draw_corner_flourish(cx : Int, cy : Int) -> Unit {
  // Small decorative corner mark
  let color = @types.color_compass_ring
  let s = 6
  @raylib.draw_line(cx - s, cy, cx + s, cy, color)
  @raylib.draw_line(cx, cy - s, cx, cy + s, color)
}
