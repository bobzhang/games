///|
fn draw_playing(game : @types.Game) -> Unit {
  match game.current_level {
    None => ()
    Some(level) => {
      draw_artwork_grid(game, level)
      draw_tool_palette(game)
      draw_region_info(game, level)
      draw_progress_bar(game, level)
      draw_controls_hint(game)
      // Message overlay
      if game.message_timer > 0.0 {
        let mw = @draw.measure_text(game.message, 20)
        let mx = (@types.screen_width - mw) / 2
        @raylib.draw_rectangle(
          mx - 10,
          @types.screen_height - 90,
          mw + 20,
          30,
          @types.color_panel_bg,
        )
        @draw.draw_text(
          game.message,
          mx,
          @types.screen_height - 85,
          20,
          @types.color_highlight,
        )
      }
    }
  }
}

///|
fn draw_artwork_grid(game : @types.Game, level : @types.Level) -> Unit {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let sz = @types.region_size
  let pad = @types.grid_padding
  let cols = @types.grid_cols
  let total_w = cols * sz + (cols - 1) * pad
  let total_h = @types.grid_rows * sz + (@types.grid_rows - 1) * pad
  // Picture frame
  let frame_pad = 12
  @raylib.draw_rectangle(
    ox - frame_pad - 4,
    oy - frame_pad - 4,
    total_w + frame_pad * 2 + 8,
    total_h + frame_pad * 2 + 8,
    @types.color_frame_gold,
  )
  @raylib.draw_rectangle(
    ox - frame_pad,
    oy - frame_pad,
    total_w + frame_pad * 2,
    total_h + frame_pad * 2,
    @types.color_frame,
  )
  // Canvas background
  @raylib.draw_rectangle(ox, oy, total_w, total_h, @types.color_canvas)
  // Level name
  let name_str = level.name
  let nw = @draw.measure_text(name_str, 22)
  @draw.draw_text(
    name_str,
    ox + (total_w - nw) / 2,
    oy - frame_pad - 30,
    22,
    @types.color_text,
  )
  // Draw each region
  for row in 0..<@types.grid_rows {
    for col in 0..<cols {
      let idx = row * cols + col
      if idx < level.artwork.regions.length() {
        let region = level.artwork.regions[idx]
        let rx = ox + col * (sz + pad)
        let ry = oy + row * (sz + pad)
        draw_region(game, region, rx, ry, sz, idx)
      }
    }
  }
}

///|
fn draw_region(
  game : @types.Game,
  region : @types.Region,
  x : Int,
  y : Int,
  size : Int,
  idx : Int
) -> Unit {
  let fx = Float::from_int(x)
  let fy = Float::from_int(y)
  let fs = Float::from_int(size)
  // Base color based on state
  let base_color = match region.state {
    Pristine => @types.color_canvas
    Damaged => @types.color_canvas_dark
    Treated => @types.color_treated
    Restored => @types.color_restored
    Worsened => @types.color_worsened
    Sealed => @types.color_sealed
  }
  @raylib.draw_rectangle(x, y, size, size, base_color)
  // Draw damage overlays
  match region.state {
    Damaged | Treated => draw_damage_overlay(region, x, y, size, game.frame_count)
    Worsened => {
      draw_damage_overlay(region, x, y, size, game.frame_count)
      // Red X for worsened
      @raylib.draw_line_ex(
        @raylib.Vector2::new(fx + 5.0, fy + 5.0),
        @raylib.Vector2::new(fx + fs - 5.0, fy + fs - 5.0),
        2.0,
        @types.color_worsened,
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(fx + fs - 5.0, fy + 5.0),
        @raylib.Vector2::new(fx + 5.0, fy + fs - 5.0),
        2.0,
        @types.color_worsened,
      )
    }
    Sealed => {
      // Seal pattern - cross hatch
      let count = size / 12 + 1
      for i in 0..<count {
        let offset = i * 12
        @raylib.draw_line(
          x + offset,
          y,
          x + offset,
          y + size,
          @raylib.Color::new(180, 170, 50, 60),
        )
        @raylib.draw_line(
          x,
          y + offset,
          x + size,
          y + offset,
          @raylib.Color::new(180, 170, 50, 60),
        )
      }
    }
    Restored => {
      // Checkmark for restored
      @raylib.draw_line_ex(
        @raylib.Vector2::new(fx + 15.0, fy + fs / 2.0),
        @raylib.Vector2::new(fx + fs / 2.0 - 5.0, fy + fs - 18.0),
        2.5,
        @raylib.Color::new(40, 120, 60, 200),
      )
      @raylib.draw_line_ex(
        @raylib.Vector2::new(fx + fs / 2.0 - 5.0, fy + fs - 18.0),
        @raylib.Vector2::new(fx + fs - 15.0, fy + 18.0),
        2.5,
        @raylib.Color::new(40, 120, 60, 200),
      )
    }
    Pristine => ()
  }
  // Highlight on hover
  if game.hover_region == idx {
    @raylib.draw_rectangle_lines_ex(
      @raylib.Rectangle::new(fx, fy, fs, fs),
      2.0,
      @types.color_highlight,
    )
  }
  // Animation flash
  if game.anim_region == idx && game.anim_timer > 0.0 {
    let alpha = (game.anim_timer * 400.0).to_int()
    let alpha_clamped = if alpha > 255 { 255 } else { alpha }
    @raylib.draw_rectangle(
      x,
      y,
      size,
      size,
      @raylib.Color::new(255, 255, 255, alpha_clamped),
    )
  }
  // Region border
  @raylib.draw_rectangle_lines(
    x,
    y,
    size,
    size,
    @raylib.Color::new(100, 90, 70, 100),
  )
}

///|
fn draw_damage_overlay(
  region : @types.Region,
  x : Int,
  y : Int,
  size : Int,
  frame : Int
) -> Unit {
  let fx = Float::from_int(x)
  let fy = Float::from_int(y)
  let fs = Float::from_int(size)
  for i in 0..<region.damage_types.length() {
    let dmg = region.damage_types[i]
    match dmg {
      Crack => {
        // Brown diagonal crack lines
        @raylib.draw_line_ex(
          @raylib.Vector2::new(fx + 10.0, fy + 8.0),
          @raylib.Vector2::new(fx + fs / 2.0, fy + fs / 2.0),
          2.0,
          @types.color_crack,
        )
        @raylib.draw_line_ex(
          @raylib.Vector2::new(fx + fs / 2.0, fy + fs / 2.0),
          @raylib.Vector2::new(fx + fs - 12.0, fy + fs - 10.0),
          2.0,
          @types.color_crack,
        )
        // Branch
        @raylib.draw_line_ex(
          @raylib.Vector2::new(fx + fs / 2.0, fy + fs / 2.0),
          @raylib.Vector2::new(fx + fs - 8.0, fy + 15.0),
          1.5,
          @types.color_crack,
        )
      }
      Stain => {
        // Dark stain blobs
        let time = Float::from_int(frame) * 0.01
        @raylib.draw_circle(
          x + size / 3,
          y + size / 3,
          12.0 + @types.sinf(time) * 1.0,
          @types.color_stain,
        )
        @raylib.draw_circle(
          x + size * 2 / 3,
          y + size * 2 / 3,
          10.0,
          @types.color_stain,
        )
        @raylib.draw_circle(
          x + size / 2,
          y + size / 2 + 5,
          8.0,
          @types.color_stain,
        )
      }
      Fade => {
        // Pale wash overlay
        @raylib.draw_rectangle(
          x + 3,
          y + 3,
          size - 6,
          size - 6,
          @types.color_fade,
        )
      }
      Flake => {
        // Missing paint chunks
        @raylib.draw_rectangle(
          x + 8,
          y + 12,
          18,
          14,
          @types.color_flake,
        )
        @raylib.draw_rectangle(
          x + size - 28,
          y + size - 26,
          16,
          12,
          @types.color_flake,
        )
        @raylib.draw_rectangle(
          x + size / 2 - 6,
          y + 6,
          14,
          10,
          @types.color_flake,
        )
      }
    }
  }
  // Show treatment indicators (small dots for each treatment applied)
  let dot_y = y + size - 8
  for t in 0..<region.treatments_applied.length() {
    let dot_x = x + 6 + t * 10
    let tc = @types.tool_color(region.treatments_applied[t])
    @raylib.draw_circle(dot_x, dot_y, 3.0, tc)
  }
}
