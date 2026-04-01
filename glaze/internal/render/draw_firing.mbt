///|
fn draw_firing(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let h = @types.screen_height
  let time = game.fire_timer
  // Dark background with kiln glow
  @raylib.draw_rectangle(0, 0, w, h, @types.color_bg)
  // Kiln frame
  let kiln_x = w / 2 - 250
  let kiln_y = h / 2 - 200
  let kiln_w = 500
  let kiln_h = 400
  // Outer glow effect based on phase
  let glow_alpha = @types.mini(255, (time * 200.0).to_int())
  @raylib.draw_rectangle(
    kiln_x - 10,
    kiln_y - 10,
    kiln_w + 20,
    kiln_h + 20,
    @raylib.Color::new(255, 140, 40, glow_alpha / 3),
  )
  // Kiln border
  @raylib.draw_rectangle(
    kiln_x - 4,
    kiln_y - 4,
    kiln_w + 8,
    kiln_h + 8,
    @raylib.Color::new(200, 100, 30, 255),
  )
  @raylib.draw_rectangle(
    kiln_x,
    kiln_y,
    kiln_w,
    kiln_h,
    @raylib.Color::new(40, 20, 15, 255),
  )
  // Draw the grid in the kiln
  let cs = 60
  let gap = 3
  let grid_total_w = @types.grid_cols * (cs + gap)
  let grid_total_h = @types.grid_rows * (cs + gap)
  let gx = kiln_x + (kiln_w - grid_total_w) / 2
  let gy = kiln_y + (kiln_h - grid_total_h) / 2
  for row in 0..<@types.grid_rows {
    for col in 0..<@types.grid_cols {
      let cx = gx + col * (cs + gap)
      let cy = gy + row * (cs + gap)
      let cell = @types.get_cell(game.grid, row, col)
      let base_color = @types.glaze_to_raylib(cell.glaze)
      // Apply heat effect based on phase
      let heat = @types.minf(time / 1.8, 1.0)
      let rv = base_color.r.to_int()
      let gv = base_color.g.to_int()
      let bv = base_color.b.to_int()
      // Shift towards orange/red as heat increases
      let heat_shift = (heat * 60.0).to_int()
      let nr = @types.mini(255, rv + heat_shift)
      let ng = @types.maxi(0, gv - heat_shift / 2)
      let nb = @types.maxi(0, bv - heat_shift)
      @raylib.draw_rectangle(
        cx,
        cy,
        cs,
        cs,
        @raylib.Color::new(nr, ng, nb, 255),
      )
      // Shimmer effect
      let shimmer = @types.sinf(
        Float::from_int(row * 7 + col * 13) + time * 5.0,
      )
      if shimmer > 0.5 {
        let a = ((shimmer - 0.5) * 100.0).to_int()
        @raylib.draw_rectangle(
          cx,
          cy,
          cs,
          cs,
          @raylib.Color::new(255, 200, 80, a),
        )
      }
    }
  }
  // Phase text
  let phase_text = match game.fire_phase {
    0 => "Heating..."
    1 => "Glazes melting..."
    _ => "Firing complete!"
  }
  let tw = @draw.measure_text(phase_text, 32)
  @draw.draw_text(
    phase_text,
    (w - tw) / 2,
    kiln_y - 50,
    32,
    @types.color_kiln_glow,
  )
  // Fire particles at the bottom
  let fire_y = kiln_y + kiln_h + 10
  for i in 0..<20 {
    let fx = Float::from_int(
      kiln_x + 20 + (i * (kiln_w - 40)) / 20,
    )
    let flicker = @types.sinf(
      Float::from_int(i * 17) + time * 8.0,
    )
    let fy = Float::from_int(fire_y) - flicker * 15.0 - 10.0
    let size : Float = 4.0 + flicker * 3.0
    let fire_r = 255
    let fire_g = @types.mini(255, 100 + (flicker * 80.0).to_int())
    @raylib.draw_circle(
      fx.to_int(),
      fy.to_int(),
      size,
      @raylib.Color::new(fire_r, fire_g, 20, 200),
    )
  }
}
