///|
fn draw_playing(game : @types.Game) -> Unit {
  draw_cauldron(game)
  draw_palette(game)
  draw_hud(game)
  if game.show_recipe_book {
    draw_recipe_panel(game)
  }
  draw_message(game)
  draw_animations(game)
}

///|
fn draw_cauldron(game : @types.Game) -> Unit {
  let cx = @types.cauldron_x.to_int()
  let cy = @types.cauldron_y.to_int()
  let r = @types.cauldron_radius
  let time : Float = Float::from_int(game.frame_count) * 0.04
  // Cauldron rim (outer circle)
  @raylib.draw_circle(cx, cy, r + 15.0, @types.color_cauldron_rim)
  // Cauldron inner
  @raylib.draw_circle(cx, cy, r + 5.0, @types.color_cauldron_inner)
  // Substance or empty
  match game.cauldron_substance {
    Some(elem) => {
      let color = @types.element_color(elem)
      // Filled cauldron with bubbling effect
      @raylib.draw_circle(cx, cy, r - 5.0, color)
      // Bubbles
      for i in 0..<8 {
        let fi : Float = Float::from_int(i)
        let angle : Float = fi * 0.785 + time * 0.5
        let br : Float = (r - 25.0) * (0.3 + @types.absf(
            @types.sinf(fi * 1.3 + time),
          ) * 0.5)
        let bx : Float = @types.cauldron_x + @types.cosf(angle) * br
        let by : Float = @types.cauldron_y + @types.sinf(angle) * br - @types.absf(
            @types.sinf(time * 2.0 + fi),
          ) * 15.0
        let bubble_size : Float = 4.0 + @types.sinf(fi + time) * 2.0
        let lighter = @raylib.Color::new(
          @types.mini(color.r.to_int() + 60, 255),
          @types.mini(color.g.to_int() + 60, 255),
          @types.mini(color.b.to_int() + 60, 255),
          180,
        )
        @raylib.draw_circle(bx.to_int(), by.to_int(), bubble_size, lighter)
      }
      // Substance name
      let name = @types.element_name(elem)
      let nw = @draw.measure_text(name, 22)
      @draw.draw_text(name, cx - nw / 2, cy + r.to_int() + 25, 22, color)
    }
    None => {
      // Empty cauldron
      @raylib.draw_circle(cx, cy, r - 5.0, @types.color_cauldron_empty)
      let empty = "Empty"
      let ew = @draw.measure_text(empty, 18)
      @draw.draw_text(empty, cx - ew / 2, cy - 9, 18, @types.color_text_dim)
    }
  }
  // Cauldron label
  let label = "Cauldron"
  let lw = @draw.measure_text(label, 16)
  @draw.draw_text(
    label,
    cx - lw / 2,
    cy - r.to_int() - 35,
    16,
    @types.color_text_dim,
  )
}

///|
fn draw_palette(game : @types.Game) -> Unit {
  let base_x = @types.palette_x
  let base_y = @types.palette_y
  let spacing = @types.palette_spacing
  let radius = @types.palette_radius
  let elements = @types.all_base_elements()
  let level = @levels.get_level(game.current_level_index)
  // Palette header
  @draw.draw_text("Elements", 30, 150, 20, @types.color_text_bright)
  for i in 0..<elements.length() {
    let elem = elements[i]
    let ey : Float = base_y + Float::from_int(i) * spacing
    let color = @types.element_color(elem)
    let remaining = @types.budget_get(game.budget, elem)
    let total = @types.budget_get(level.budget, elem)
    if total <= 0 {
      continue
    }
    // Draw element circle
    if remaining > 0 {
      @raylib.draw_circle(base_x.to_int(), ey.to_int(), radius, color)
      // Hover detection
      let mx : Float = Float::from_int(@raylib.get_mouse_x())
      let my : Float = Float::from_int(@raylib.get_mouse_y())
      let dx : Float = mx - base_x
      let dy : Float = my - ey
      if dx * dx + dy * dy < radius * radius {
        @raylib.draw_circle_lines(
          base_x.to_int(),
          ey.to_int(),
          radius + 4.0,
          @types.color_text_bright,
        )
      }
    } else {
      // Depleted - draw dim
      @raylib.draw_circle(
        base_x.to_int(),
        ey.to_int(),
        radius,
        @raylib.Color::new(60, 55, 50, 150),
      )
      @raylib.draw_circle_lines(
        base_x.to_int(),
        ey.to_int(),
        radius,
        @raylib.Color::new(80, 75, 70, 100),
      )
    }
    // Element name
    let name = @types.element_name(elem)
    @draw.draw_text(
      name,
      (base_x + radius + 10.0).to_int(),
      ey.to_int() - 9,
      16,
      if remaining > 0 { color } else { @types.color_text_dim },
    )
    // Count
    let count_text = remaining.to_string() + "/" + total.to_string()
    @draw.draw_text(
      count_text,
      (base_x + radius + 80.0).to_int(),
      ey.to_int() - 9,
      14,
      @types.color_text_dim,
    )
  }
}

///|
fn draw_hud(game : @types.Game) -> Unit {
  let w = @types.screen_width
  let level = @levels.get_level(game.current_level_index)
  // Level info bar at top
  @raylib.draw_rectangle(0, 0, w, 40, @types.color_panel_bg)
  // Level number
  let level_num = "Level " + (game.current_level_index - @types.tier_start_index(
      game.current_tier,
    ) + 1).to_string()
  @draw.draw_text(level_num, 15, 8, 20, @types.color_text_bright)
  // Target
  let target_text = "Target: " + @types.element_name(level.target)
  @draw.draw_text(target_text, 180, 8, 20, @types.element_color(level.target))
  // Steps
  let steps = "Steps: " + game.steps_taken.to_string() + " / Par: " + level.par_steps.to_string()
  @draw.draw_text(steps, 450, 8, 18, @types.color_text)
  // Attempts
  let attempts = "Failures: " + game.failed_attempts.to_string()
  @draw.draw_text(attempts, 700, 8, 18, @types.color_text_dim)
  // Controls bar at bottom
  let h = @types.screen_height
  @raylib.draw_rectangle(0, h - 35, w, 35, @types.color_panel_bg)
  @draw.draw_text(
    "Click element to add | R - Restart | Tab - Recipe Book | Z - Undo | ESC - Back",
    15,
    h - 28,
    14,
    @types.color_text_dim,
  )
  // Hint
  let hint = level.hint
  let hint_w = @draw.measure_text(hint, 14)
  @draw.draw_text(hint, w - hint_w - 15, h - 28, 14, @types.color_title_glow)
}

///|
fn draw_message(game : @types.Game) -> Unit {
  if game.message_timer > 0.0 {
    let w = @types.screen_width
    let alpha : Float = @types.minf(game.message_timer * 3.0, 1.0)
    let a : Int = (alpha * 255.0).to_int()
    let mw = @draw.measure_text(game.message, 24)
    let mx = (w - mw) / 2
    let my = 60
    let bg_alpha : Int = (Float::from_int(a) * 0.8).to_int()
    @raylib.draw_rectangle(
      mx - 15,
      my - 5,
      mw + 30,
      35,
      @raylib.Color::new(20, 15, 30, bg_alpha),
    )
    @draw.draw_text(
      game.message,
      mx,
      my,
      24,
      @raylib.Color::new(255, 240, 200, a),
    )
  }
}

///|
fn draw_animations(game : @types.Game) -> Unit {
  if !(game.anim.active) {
    return
  }
  let cx = @types.cauldron_x
  let cy = @types.cauldron_y
  match game.anim.kind {
    Destruction => {
      // Red flash and expanding circles
      let t : Float = 1.0 - game.anim.timer / @types.destroy_anim_duration
      let ring_r : Float = @types.cauldron_radius * (0.5 + t * 1.5)
      let inv_t : Float = 1.0 - t
      let alpha : Int = (inv_t * 200.0).to_int()
      let a = if alpha > 0 { alpha } else { 0 }
      @raylib.draw_circle_lines(
        cx.to_int(),
        cy.to_int(),
        ring_r,
        @raylib.Color::new(255, 60, 40, a),
      )
      @raylib.draw_circle_lines(
        cx.to_int(),
        cy.to_int(),
        ring_r * 0.7,
        @raylib.Color::new(255, 120, 40, a),
      )
      // Particles flying outward
      for i in 0..<12 {
        let fi : Float = Float::from_int(i)
        let angle : Float = fi * 0.524 + t * 2.0
        let dist : Float = t * 100.0
        let px : Float = cx + @types.cosf(angle) * dist
        let py : Float = cy + @types.sinf(angle) * dist
        let size : Float = inv_t * 5.0
        @raylib.draw_circle(
          px.to_int(),
          py.to_int(),
          size,
          @raylib.Color::new(255, 100, 50, a),
        )
      }
    }
    SuccessGlow => {
      // Green glow pulsing outward
      let t : Float = 1.0 - game.anim.timer / @types.success_anim_duration
      let glow_r : Float = @types.cauldron_radius + t * 40.0
      let inv_t : Float = 1.0 - t
      let alpha : Int = (inv_t * 150.0).to_int()
      let a = if alpha > 0 { alpha } else { 0 }
      @raylib.draw_circle(
        cx.to_int(),
        cy.to_int(),
        glow_r,
        @raylib.Color::new(100, 255, 100, a),
      )
      @raylib.draw_circle_lines(
        cx.to_int(),
        cy.to_int(),
        glow_r + 10.0,
        @raylib.Color::new(200, 255, 200, a),
      )
    }
    AddElement => {
      // Element dropping into cauldron
      match game.add_anim_element {
        Some(elem) => {
          let t : Float = 1.0 - game.anim.timer / @types.add_anim_duration
          let drop_y : Float = @types.lerpf(game.add_anim_y, cy, t)
          let color = @types.element_color(elem)
          let size : Float = @types.lerpf(20.0, 8.0, t)
          let inv_fade : Float = 1.0 - t * 0.3
          let alpha : Int = (inv_fade * 255.0).to_int()
          @raylib.draw_circle(
            cx.to_int(),
            drop_y.to_int(),
            size,
            @raylib.Color::new(
              color.r.to_int(),
              color.g.to_int(),
              color.b.to_int(),
              alpha,
            ),
          )
        }
        None => ()
      }
    }
    _ => ()
  }
}
