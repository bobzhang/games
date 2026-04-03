///|
fn draw_planning(game : @types.Game) -> Unit {
  draw_grid(game)
  draw_soil_bars(game)
  draw_season_tabs(game)
  draw_crop_palette(game)
  draw_hud(game)
  draw_hover_info(game)
  draw_message(game)
  draw_controls(game)
}

///|
fn draw_simulate(game : @types.Game) -> Unit {
  draw_grid(game)
  draw_soil_bars(game)
  draw_sim_hud(game)
  draw_harvest_flash(game)
  draw_growth_anim(game)
  draw_message(game)
}

///|
fn draw_grid(game : @types.Game) -> Unit {
  let goal = @levels.load_level(game.level_index)
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      let x = @types.cell_x(c)
      let y = @types.cell_y(r)
      let s = @types.cell_size
      let plot = game.grid[r][c]
      // Check if locked
      let locked = is_locked(c, r, goal.locked_plots)
      if locked {
        @raylib.draw_rectangle(x, y, s, s, @types.color_locked)
        @raylib.draw_rectangle_lines(x, y, s, s, @types.color_grid_line)
        // Rock pattern
        @raylib.draw_rectangle(
          x + 20,
          y + 20,
          25,
          20,
          @raylib.Color::new(90, 85, 75, 200),
        )
        @raylib.draw_rectangle(
          x + 50,
          y + 40,
          20,
          25,
          @raylib.Color::new(85, 80, 70, 200),
        )
        @raylib.draw_rectangle(
          x + 30,
          y + 55,
          30,
          18,
          @raylib.Color::new(95, 88, 78, 200),
        )
        continue
      }
      // Soil background
      let soil_col = @types.soil_color(plot.soil)
      @raylib.draw_rectangle(x, y, s, s, soil_col)
      // Crop display
      match plot.state {
        Empty => draw_empty_plot(x, y, s)
        Planted => draw_planted_plot(x, y, s, plot)
        Growing => draw_growing_plot(x, y, s, plot)
        Mature => draw_mature_plot(x, y, s, plot)
        Harvested => draw_harvested_plot(x, y, s)
        Withered => draw_withered_plot(x, y, s)
      }
      // Grid lines
      @raylib.draw_rectangle_lines(x, y, s, s, @types.color_grid_line)
      // Hover highlight
      if c == game.hover_col && r == game.hover_row && game.screen == Planning {
        if game.hover_valid {
          @raylib.draw_rectangle(x, y, s, s, @types.color_highlight)
        } else {
          @raylib.draw_rectangle(x, y, s, s, @types.color_invalid)
        }
      }
    }
  }
}

///|
fn is_locked(col : Int, row : Int, locked : Array[(Int, Int)]) -> Bool {
  for i in 0..<locked.length() {
    let (lc, lr) = locked[i]
    if lc == col && lr == row {
      return true
    }
  }
  false
}

///|
fn draw_empty_plot(x : Int, y : Int, s : Int) -> Unit {
  // Small furrow lines
  let line_col = @raylib.Color::new(130, 100, 60, 60)
  for i in 0..<3 {
    let ly = y + 25 + i * 20
    @raylib.draw_line(x + 10, ly, x + s - 10, ly, line_col)
  }
}

///|
fn draw_planted_plot(x : Int, y : Int, s : Int, plot : @types.Plot) -> Unit {
  let cc = @types.crop_color(plot.crop)
  // Small seed dots
  let alpha_col = @raylib.Color::new(
    cc.r.to_int(),
    cc.g.to_int(),
    cc.b.to_int(),
    120,
  )
  for i in 0..<4 {
    let dx = 20 + i * 18
    let dy = 40 + i % 2 * 20
    @raylib.draw_circle(x + dx, y + dy, 4.0, alpha_col)
  }
  // Crop name
  @draw.draw_text(
    @types.crop_name(plot.crop),
    x + 5,
    y + s - 18,
    12,
    @types.color_dark_text,
  )
}

///|
fn draw_growing_plot(x : Int, y : Int, s : Int, plot : @types.Plot) -> Unit {
  let cc = @types.crop_color(plot.crop)
  // Growing sprouts
  let mid_x = x + s / 2
  for i in 0..<3 {
    let sx = mid_x - 20 + i * 20
    let sy = y + 60
    let height = 25
    @raylib.draw_line(sx, sy, sx, sy - height, cc)
    // Small leaves
    @raylib.draw_circle(sx - 4, sy - height + 5, 4.0, cc)
    @raylib.draw_circle(sx + 4, sy - height + 5, 4.0, cc)
  }
  @draw.draw_text(
    @types.crop_name(plot.crop),
    x + 5,
    y + s - 18,
    12,
    @types.color_dark_text,
  )
}

///|
fn draw_mature_plot(x : Int, y : Int, s : Int, plot : @types.Plot) -> Unit {
  let cc = @types.crop_color(plot.crop)
  // Full crop icon
  let mid_x = x + s / 2
  let mid_y = y + s / 2
  match plot.crop {
    Wheat =>
      // Wheat stalks
      for i in 0..<5 {
        let sx = mid_x - 24 + i * 12
        @raylib.draw_line(sx, y + 75, sx, y + 25, cc)
        @raylib.draw_circle(sx, y + 22, 5.0, cc)
      }
    Corn => {
      // Tall corn stalk
      @raylib.draw_rectangle(mid_x - 4, y + 15, 8, 65, cc)
      @raylib.draw_rectangle(
        mid_x - 15,
        y + 25,
        12,
        20,
        @raylib.Color::new(80, 200, 60, 255),
      )
      @raylib.draw_rectangle(
        mid_x + 3,
        y + 35,
        12,
        20,
        @raylib.Color::new(80, 200, 60, 255),
      )
      @raylib.draw_circle(
        mid_x,
        y + 12,
        8.0,
        @raylib.Color::new(220, 200, 60, 255),
      )
    }
    Tomato => {
      // Tomato cluster
      @raylib.draw_circle(mid_x, mid_y, 15.0, cc)
      @raylib.draw_circle(mid_x - 12, mid_y + 8, 10.0, cc)
      @raylib.draw_circle(mid_x + 12, mid_y + 8, 10.0, cc)
      // Stem
      @raylib.draw_line(
        mid_x,
        mid_y - 15,
        mid_x,
        mid_y - 25,
        @raylib.Color::new(50, 130, 50, 255),
      )
    }
    Potato => {
      // Underground potato blobs
      @raylib.draw_rectangle(
        x + 15,
        y + 50,
        s - 30,
        30,
        @raylib.Color::new(160, 130, 70, 200),
      )
      @raylib.draw_circle(mid_x - 12, y + 60, 10.0, cc)
      @raylib.draw_circle(mid_x + 12, y + 60, 10.0, cc)
      @raylib.draw_circle(mid_x, y + 55, 12.0, cc)
      // Green top
      @raylib.draw_line(mid_x, y + 45, mid_x - 8, y + 30, @types.color_clover)
      @raylib.draw_line(mid_x, y + 45, mid_x + 8, y + 30, @types.color_clover)
    }
    Carrot =>
      // Orange carrots
      for i in 0..<3 {
        let cx = mid_x - 18 + i * 18
        @raylib.draw_triangle(
          @raylib.Vector2::new(Float::from_int(cx - 6), Float::from_int(y + 40)),
          @raylib.Vector2::new(Float::from_int(cx + 6), Float::from_int(y + 40)),
          @raylib.Vector2::new(Float::from_int(cx), Float::from_int(y + 75)),
          cc,
        )
        @raylib.draw_line(cx, y + 40, cx - 5, y + 28, @types.color_clover)
        @raylib.draw_line(cx, y + 40, cx + 5, y + 28, @types.color_clover)
      }
    Pumpkin => {
      // Round pumpkin
      @raylib.draw_circle(mid_x, mid_y + 5, 22.0, cc)
      @raylib.draw_circle(
        mid_x - 10,
        mid_y + 5,
        18.0,
        @raylib.Color::new(200, 110, 15, 255),
      )
      @raylib.draw_circle(
        mid_x + 10,
        mid_y + 5,
        18.0,
        @raylib.Color::new(200, 110, 15, 255),
      )
      // Stem
      @raylib.draw_rectangle(
        mid_x - 3,
        mid_y - 20,
        6,
        12,
        @raylib.Color::new(80, 130, 40, 255),
      )
    }
    Clover => {
      // Three-leaf clover
      for i in 0..<3 {
        let angle = Float::from_int(i) * @types.pi * 2.0 / 3.0 - @types.pi / 2.0
        let lx = Float::from_int(mid_x) + 12.0 * @types.cosf(angle)
        let ly = Float::from_int(mid_y) + 12.0 * @types.sinf(angle)
        @raylib.draw_circle(lx.to_int(), ly.to_int(), 10.0, cc)
      }
      @raylib.draw_line(
        mid_x,
        mid_y + 5,
        mid_x,
        mid_y + 30,
        @raylib.Color::new(40, 140, 60, 255),
      )
    }
    Fallow => ()
  }
  @draw.draw_text(
    @types.crop_name(plot.crop),
    x + 5,
    y + s - 18,
    12,
    @types.color_dark_text,
  )
}

///|
fn draw_harvested_plot(x : Int, y : Int, s : Int) -> Unit {
  // Stubble
  let stub_col = @raylib.Color::new(160, 140, 100, 150)
  for i in 0..<5 {
    let sx = x + 10 + i * 18
    @raylib.draw_line(sx, y + s - 15, sx, y + s - 25, stub_col)
  }
}

///|
fn draw_withered_plot(x : Int, y : Int, s : Int) -> Unit {
  // Wilted brown
  let mid_x = x + s / 2
  @raylib.draw_line(
    mid_x - 10,
    y + 60,
    mid_x - 10,
    y + 35,
    @types.color_withered,
  )
  @raylib.draw_line(
    mid_x + 10,
    y + 60,
    mid_x + 10,
    y + 35,
    @types.color_withered,
  )
  @raylib.draw_line(
    mid_x - 10,
    y + 35,
    mid_x - 18,
    y + 45,
    @types.color_withered,
  )
  @raylib.draw_line(
    mid_x + 10,
    y + 35,
    mid_x + 18,
    y + 45,
    @types.color_withered,
  )
  @draw.draw_text("Withered", x + 15, y + s - 18, 12, @types.color_withered)
}

///|
fn draw_soil_bars(game : @types.Game) -> Unit {
  let goal = @levels.load_level(game.level_index)
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      let locked = is_locked(c, r, goal.locked_plots)
      if locked {
        continue
      }
      let x = @types.cell_x(c)
      let y = @types.cell_y(r)
      let s = @types.cell_size
      let plot = game.grid[r][c]
      // Small nutrient bars at top of each cell
      let bar_w = (s - 12) / 3
      let bar_h = 6
      let bar_y = y + 3
      // Nitrogen
      let n_fill = plot.soil.nitrogen * bar_w / @types.max_nutrient
      @raylib.draw_rectangle(x + 3, bar_y, bar_w, bar_h, @types.color_bar_bg)
      @raylib.draw_rectangle(x + 3, bar_y, n_fill, bar_h, @types.color_n_bar)
      // Phosphorus
      let p_fill = plot.soil.phosphorus * bar_w / @types.max_nutrient
      @raylib.draw_rectangle(
        x + 3 + bar_w + 2,
        bar_y,
        bar_w,
        bar_h,
        @types.color_bar_bg,
      )
      @raylib.draw_rectangle(
        x + 3 + bar_w + 2,
        bar_y,
        p_fill,
        bar_h,
        @types.color_p_bar,
      )
      // Potassium
      let k_fill = plot.soil.potassium * bar_w / @types.max_nutrient
      @raylib.draw_rectangle(
        x + 3 + (bar_w + 2) * 2,
        bar_y,
        bar_w,
        bar_h,
        @types.color_bar_bg,
      )
      @raylib.draw_rectangle(
        x + 3 + (bar_w + 2) * 2,
        bar_y,
        k_fill,
        bar_h,
        @types.color_k_bar,
      )
    }
  }
}

///|
fn draw_harvest_flash(game : @types.Game) -> Unit {
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      let flash = game.harvest_flash[r][c]
      if flash > 0.0 {
        let x = @types.cell_x(c)
        let y = @types.cell_y(r)
        let s = @types.cell_size
        let alpha = (flash * 200.0).to_int()
        let a = @types.clampi(alpha, 0, 255)
        @raylib.draw_rectangle(x, y, s, s, @raylib.Color::new(255, 255, 100, a))
      }
    }
  }
}

///|
fn draw_growth_anim(game : @types.Game) -> Unit {
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      let anim = game.growth_anim[r][c]
      if anim > 0.0 {
        let x = @types.cell_x(c)
        let y = @types.cell_y(r)
        let s = @types.cell_size
        let alpha = (anim * 120.0).to_int()
        let a = @types.clampi(alpha, 0, 255)
        @raylib.draw_rectangle(x, y, s, s, @raylib.Color::new(100, 255, 100, a))
      }
    }
  }
}
