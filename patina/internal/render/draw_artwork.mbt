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
  idx : Int,
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
    Damaged | Treated =>
      draw_damage_overlay(region, x, y, size, game.frame_count)
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
  // Highlight on hover with tool preview
  if game.hover_region == idx {
    @raylib.draw_rectangle_lines_ex(
      @raylib.Rectangle::new(fx, fy, fs, fs),
      2.0,
      @types.color_highlight,
    )
    // Show preview of what the tool will do
    draw_tool_preview(game, region, x, y, size)
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
  frame : Int,
) -> Unit {
  let fx = Float::from_int(x)
  let fy = Float::from_int(y)
  let fs = Float::from_int(size)
  for i in 0..<region.damage_types.length() {
    let dmg = region.damage_types[i]
    match dmg {
      Crack => {
        // Detailed crack pattern: main fissure with branching fractures
        let crack_color = @types.color_crack
        let dark_crack = @raylib.Color::new(80, 50, 25, 255)
        // Main diagonal crack
        @raylib.draw_line_ex(
          @raylib.Vector2::new(fx + 8.0, fy + 6.0),
          @raylib.Vector2::new(fx + fs * 0.35, fy + fs * 0.3),
          2.5,
          crack_color,
        )
        @raylib.draw_line_ex(
          @raylib.Vector2::new(fx + fs * 0.35, fy + fs * 0.3),
          @raylib.Vector2::new(fx + fs * 0.5, fy + fs * 0.55),
          2.5,
          crack_color,
        )
        @raylib.draw_line_ex(
          @raylib.Vector2::new(fx + fs * 0.5, fy + fs * 0.55),
          @raylib.Vector2::new(fx + fs - 10.0, fy + fs - 8.0),
          2.5,
          crack_color,
        )
        // Branch fractures
        @raylib.draw_line_ex(
          @raylib.Vector2::new(fx + fs * 0.35, fy + fs * 0.3),
          @raylib.Vector2::new(fx + fs - 6.0, fy + 12.0),
          1.5,
          dark_crack,
        )
        @raylib.draw_line_ex(
          @raylib.Vector2::new(fx + fs * 0.5, fy + fs * 0.55),
          @raylib.Vector2::new(fx + 12.0, fy + fs - 14.0),
          1.5,
          dark_crack,
        )
        // Small hairline cracks
        @raylib.draw_line_ex(
          @raylib.Vector2::new(fx + fs * 0.35, fy + fs * 0.3),
          @raylib.Vector2::new(fx + fs * 0.25, fy + fs * 0.5),
          1.0,
          dark_crack,
        )
      }
      Stain => {
        // Organic stain pattern with irregular blobs and spatter
        let time = Float::from_int(frame) * 0.008
        let stain_dark = @raylib.Color::new(50, 40, 30, 200)
        let stain_light = @raylib.Color::new(70, 55, 40, 160)
        // Main stain blob (large, organic)
        let r1 : Float = 14.0 + @types.sinf(time) * 1.5
        @raylib.draw_circle(x + size / 3, y + size / 3, r1, stain_dark)
        // Secondary blob overlapping
        @raylib.draw_circle(
          x + size / 3 + 8,
          y + size / 3 + 6,
          10.0,
          stain_light,
        )
        // Drip trail
        @raylib.draw_circle(
          x + size * 2 / 3,
          y + size * 2 / 3,
          11.0,
          stain_dark,
        )
        @raylib.draw_circle(
          x + size * 2 / 3 - 4,
          y + size * 2 / 3 + 8,
          7.0,
          stain_light,
        )
        // Small spatter dots
        for s in 0..<5 {
          let sf = Float::from_int(s)
          let sx = x + (sf * 17.3 % Float::from_int(size - 10) + 5.0).to_int()
          let sy = y + (sf * 13.7 % Float::from_int(size - 10) + 5.0).to_int()
          @raylib.draw_circle(sx, sy, 3.0, stain_light)
        }
      }
      Fade => {
        // Faded area with diagonal hatching pattern to show color loss
        let fade_color = @raylib.Color::new(230, 225, 215, 160)
        let line_color = @raylib.Color::new(210, 205, 195, 120)
        // Base wash
        @raylib.draw_rectangle(x + 3, y + 3, size - 6, size - 6, fade_color)
        // Diagonal hatching pattern - shows bleached/faded texture
        let step = 8
        let count = size * 2 / step
        for s in 0..<count {
          let offset = s * step
          let x1 = x + offset
          let y1 = y
          let x2 = x
          let y2 = y + offset
          // Clip to region
          if x1 < x + size && y2 < y + size {
            @raylib.draw_line(
              @types.mini(x1, x + size - 1),
              @types.maxi(y1, y),
              @types.maxi(x2, x),
              @types.mini(y2, y + size - 1),
              line_color,
            )
          }
        }
      }
      Flake => {
        // Missing paint patches with exposed underlayer
        let underlayer = @raylib.Color::new(170, 150, 120, 220)
        let edge_color = @raylib.Color::new(140, 120, 90, 255)
        // Irregular flake patches
        @raylib.draw_rectangle(x + 6, y + 10, 20, 16, underlayer)
        @raylib.draw_rectangle_lines(x + 6, y + 10, 20, 16, edge_color)
        @raylib.draw_rectangle(x + size - 30, y + size - 28, 18, 14, underlayer)
        @raylib.draw_rectangle_lines(
          x + size - 30,
          y + size - 28,
          18,
          14,
          edge_color,
        )
        @raylib.draw_rectangle(x + size / 2 - 8, y + 4, 16, 12, underlayer)
        @raylib.draw_rectangle_lines(
          x + size / 2 - 8,
          y + 4,
          16,
          12,
          edge_color,
        )
        // Scattered small flake fragments
        @raylib.draw_rectangle(
          x + size / 2 + 10,
          y + size / 2,
          8,
          6,
          underlayer,
        )
        @raylib.draw_rectangle(x + 10, y + size - 18, 10, 8, underlayer)
      }
    }
  }
  // Show treatment indicators (small colored squares for each treatment applied)
  let dot_y = y + size - 10
  for t in 0..<region.treatments_applied.length() {
    let dot_x = x + 4 + t * 12
    let tc = @types.tool_color(region.treatments_applied[t])
    @raylib.draw_rectangle(dot_x, dot_y, 8, 8, tc)
    @raylib.draw_rectangle_lines(
      dot_x,
      dot_y,
      8,
      8,
      @raylib.Color::new(0, 0, 0, 60),
    )
  }
}

///|
fn draw_tool_preview(
  game : @types.Game,
  region : @types.Region,
  x : Int,
  y : Int,
  size : Int,
) -> Unit {
  // Only show preview for actionable regions
  match region.state {
    Pristine | Restored | Sealed => return
    _ => ()
  }
  let tool = game.selected_tool
  // Check budget
  match game.current_budget {
    None => return
    Some(b) => {
      let remaining = @types.get_budget_for_tool(b, tool)
      if remaining <= 0 {
        return
      }
    }
  }
  // Predict the outcome of applying the tool
  let preview_text : String = predict_outcome(region, tool)
  let is_danger = preview_is_danger(region, tool)
  // Draw preview indicator at bottom-right of the region
  let fx = Float::from_int(x)
  let fy = Float::from_int(y)
  let fs = Float::from_int(size)
  // Semi-transparent tool color overlay
  let tc = @types.tool_color(tool)
  let overlay_alpha = 50
  @raylib.draw_rectangle(
    x + 2,
    y + 2,
    size - 4,
    size - 4,
    @raylib.Color::new(
      tc.r.to_int(),
      tc.g.to_int(),
      tc.b.to_int(),
      overlay_alpha,
    ),
  )
  // Tool icon indicator in top-right corner
  let icon_size = 14
  let icon_x = x + size - icon_size - 3
  let icon_y = y + 3
  let icon_bg = if is_danger {
    @raylib.Color::new(200, 50, 50, 200)
  } else {
    @raylib.Color::new(tc.r.to_int(), tc.g.to_int(), tc.b.to_int(), 200)
  }
  @raylib.draw_rectangle(icon_x, icon_y, icon_size, icon_size, icon_bg)
  // Tool letter abbreviation
  let abbrev = match tool {
    Clean => "C"
    Fill => "F"
    Retouch => "R"
    Seal => "S"
  }
  @draw.draw_text(
    abbrev,
    icon_x + 2,
    icon_y + 1,
    12,
    @raylib.Color::new(255, 255, 255, 255),
  )
  // Draw outcome text below the region
  let text_w = @draw.measure_text(preview_text, 10)
  let text_x = x + (size - text_w) / 2
  let text_y = y + size - 22
  // Background for text
  @raylib.draw_rectangle(
    text_x - 2,
    text_y - 1,
    text_w + 4,
    13,
    @raylib.Color::new(0, 0, 0, 180),
  )
  let text_color = if is_danger {
    @types.color_worsened
  } else {
    @raylib.Color::new(200, 255, 200, 255)
  }
  @draw.draw_text(preview_text, text_x, text_y, 10, text_color)
  ignore(fx)
  ignore(fy)
  ignore(fs)
}

///|
fn predict_outcome(region : @types.Region, tool : @types.ToolKind) -> String {
  match tool {
    Clean => {
      let has_stain = @types.region_has_damage(region, Stain)
      let has_crack = @types.region_has_damage(region, Crack)
      if region.stain_permanent {
        return "WORSEN!"
      }
      if has_stain {
        if has_crack && !@types.region_has_treatment(region, Fill) {
          return "WORSEN: crack!"
        }
        return "Remove stain"
      }
      if has_crack {
        return "WORSEN: crack!"
      }
      "No effect"
    }
    Fill => {
      let has_crack = @types.region_has_damage(region, Crack)
      let has_flake = @types.region_has_damage(region, Flake)
      let has_stain = @types.region_has_damage(region, Stain)
      if has_crack || has_flake {
        return "Fix structure"
      }
      if has_stain {
        return "WORSEN: set stain!"
      }
      "No effect"
    }
    Retouch => {
      let has_fade = @types.region_has_damage(region, Fade)
      let has_flake = @types.region_has_damage(region, Flake)
      if has_fade {
        return "Restore color"
      }
      if has_flake {
        return "Fragile fix"
      }
      "Touch up"
    }
    Seal => {
      if region.damage_types.length() > 0 {
        return "Seal damage in"
      }
      if region.state == Worsened || region.fragile || region.stain_permanent {
        return "Seal (imperfect)"
      }
      "Restore!"
    }
  }
}

///|
fn preview_is_danger(region : @types.Region, tool : @types.ToolKind) -> Bool {
  match tool {
    Clean => {
      let has_crack = @types.region_has_damage(region, Crack)
      let has_stain = @types.region_has_damage(region, Stain)
      if region.stain_permanent {
        return true
      }
      if has_crack && !@types.region_has_treatment(region, Fill) {
        return true
      }
      if !has_stain && has_crack {
        return true
      }
      false
    }
    Fill => {
      let has_crack = @types.region_has_damage(region, Crack)
      let has_flake = @types.region_has_damage(region, Flake)
      let has_stain = @types.region_has_damage(region, Stain)
      if !has_crack && !has_flake && has_stain {
        return true
      }
      false
    }
    Retouch => {
      let has_flake = @types.region_has_damage(region, Flake)
      has_flake
    }
    Seal =>
      region.damage_types.length() > 0 ||
      region.state == Worsened ||
      region.fragile ||
      region.stain_permanent
  }
}
