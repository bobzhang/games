///|
pub fn draw_title(game : @types.Game) -> Unit {
  let _ = game
  let cx = @types.screen_width / 2
  // Title
  let title = "SURVEYOR"
  let tw = @draw.measure_text(title, 60)
  @draw.draw_text(title, cx - tw / 2, 150, 60, @types.color_title)
  // Subtitle
  let sub = "A Land Division Puzzle"
  let sw = @draw.measure_text(sub, 24)
  @draw.draw_text(sub, cx - sw / 2, 230, 24, @types.color_ui_text)
  // Decorative fence illustration
  let fence_y = 290
  @raylib.draw_rectangle(
    cx - 200,
    fence_y,
    400,
    4,
    @types.color_fence,
  )
  for i in 0..<9 {
    let fx = cx - 200 + i * 50
    @raylib.draw_rectangle(fx - 2, fence_y - 12, 4, 28, @types.color_fence)
  }
  // Instructions
  let inst = "Divide land into regions by drawing fences"
  let iw = @draw.measure_text(inst, 20)
  @draw.draw_text(inst, cx - iw / 2, 340, 20, @types.color_ui_dim)
  let inst2 = "Each region must contain exactly one house"
  let iw2 = @draw.measure_text(inst2, 20)
  @draw.draw_text(inst2, cx - iw2 / 2, 370, 20, @types.color_ui_dim)
  let inst3 = "with the correct area and road access"
  let iw3 = @draw.measure_text(inst3, 20)
  @draw.draw_text(inst3, cx - iw3 / 2, 400, 20, @types.color_ui_dim)
  // Start button
  draw_button(cx - 100, 480, 200, 50, "PLAY", true)
  // Controls
  @draw.draw_text(
    "Press ENTER or click PLAY to begin",
    cx - 150,
    560,
    18,
    @types.color_ui_dim,
  )
}

///|
pub fn draw_tier_select(game : @types.Game) -> Unit {
  let cx = @types.screen_width / 2
  // Header
  let title = "Select Tier"
  let tw = @draw.measure_text(title, 40)
  @draw.draw_text(title, cx - tw / 2, 60, 40, @types.color_title)
  // Three tier buttons
  let tiers : Array[@types.Tier] = [Plots, Districts, Zoning]
  let tier_descriptions : Array[String] = [
    "8 levels - Simple plots with 2-3 houses",
    "9 levels - Districts with road requirements",
    "8 levels - Complex zoning with constraints",
  ]
  for i in 0..<3 {
    let y = 160 + i * 160
    let tier = tiers[i]
    let name = @types.tier_name(tier)
    let desc = tier_descriptions[i]
    // Tier card
    let card_x = cx - 250
    let card_w = 500
    let card_h = 130
    let is_hover = is_mouse_in_rect(card_x, y, card_w, card_h)
    let bg = if is_hover {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(card_x, y, card_w, card_h, bg)
    @raylib.draw_rectangle_lines(
      card_x,
      y,
      card_w,
      card_h,
      @types.color_fence,
    )
    // Tier name
    @draw.draw_text(name, card_x + 20, y + 15, 30, @types.color_title)
    // Description
    @draw.draw_text(desc, card_x + 20, y + 55, 18, @types.color_ui_text)
    // Star count for this tier
    let start = @types.tier_start_idx(tier)
    let count = @types.tier_level_count(tier)
    let mut total_stars = 0
    let max_stars = count * 3
    for j in start..<(start + count) {
      if j < game.level_scores.length() {
        total_stars += game.level_scores[j].stars
      }
    }
    let star_str = total_stars.to_string() + "/" + max_stars.to_string() + " stars"
    @draw.draw_text(
      star_str,
      card_x + card_w - 140,
      y + 20,
      20,
      @types.color_star,
    )
  }
  // Back hint
  @draw.draw_text(
    "Press ESC to go back",
    20,
    @types.screen_height - 30,
    16,
    @types.color_ui_dim,
  )
}

///|
pub fn draw_level_select(game : @types.Game) -> Unit {
  let cx = @types.screen_width / 2
  // Header
  let tier_str = @types.tier_name(game.current_tier) + " - Select Level"
  let tw = @draw.measure_text(tier_str, 36)
  @draw.draw_text(tier_str, cx - tw / 2, 40, 36, @types.color_title)
  let start = @types.tier_start_idx(game.current_tier)
  let count = @types.tier_level_count(game.current_tier)
  // Grid of level buttons
  let cols = 4
  let btn_w = 200
  let btn_h = 120
  let gap = 30
  let total_w = cols * btn_w + (cols - 1) * gap
  let base_x = cx - total_w / 2
  let base_y = 100
  for i in 0..<count {
    let col = i % cols
    let row = i / cols
    let x = base_x + col * (btn_w + gap)
    let y = base_y + row * (btn_h + gap)
    let level_idx = start + i
    let is_hover = is_mouse_in_rect(x, y, btn_w, btn_h)
    let bg = if is_hover {
      @types.color_button_hover
    } else {
      @types.color_button
    }
    @raylib.draw_rectangle(x, y, btn_w, btn_h, bg)
    @raylib.draw_rectangle_lines(x, y, btn_w, btn_h, @types.color_fence)
    // Level number
    let num_str = (level_idx + 1).to_string()
    let nw = @draw.measure_text(num_str, 28)
    @draw.draw_text(num_str, x + btn_w / 2 - nw / 2, y + 12, 28, @types.color_title)
    // Stars
    if level_idx < game.level_scores.length() {
      let score = game.level_scores[level_idx]
      let star_y = y + 50
      let star_base_x = x + btn_w / 2 - 30
      for s in 0..<3 {
        let star_color = if s < score.stars {
          @types.color_star
        } else {
          @types.color_star_empty
        }
        let sx = star_base_x + s * 22
        @raylib.draw_circle(sx + 8, star_y + 8, 8.0, star_color)
      }
      // Completion indicator
      if score.completed {
        @draw.draw_text(
          "Done",
          x + btn_w / 2 - 18,
          y + btn_h - 30,
          16,
          @types.color_satisfied,
        )
      }
    }
  }
  // Back hint
  @draw.draw_text(
    "Press ESC to go back",
    20,
    @types.screen_height - 30,
    16,
    @types.color_ui_dim,
  )
}

///|
pub fn draw_results(game : @types.Game) -> Unit {
  let cx = @types.screen_width / 2
  // Background panel
  let panel_w = 500
  let panel_h = 400
  let panel_x = cx - panel_w / 2
  let panel_y = 160
  @raylib.draw_rectangle(panel_x, panel_y, panel_w, panel_h, @types.color_ui_bg)
  @raylib.draw_rectangle_lines(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @types.color_fence,
  )
  // Title
  let title = if game.result_stars > 0 {
    "Level Complete!"
  } else {
    "Not Yet Complete"
  }
  let tw = @draw.measure_text(title, 36)
  let title_color = if game.result_stars > 0 {
    @types.color_satisfied
  } else {
    @types.color_violated
  }
  @draw.draw_text(title, cx - tw / 2, panel_y + 20, 36, title_color)
  // Stars display
  let star_y = panel_y + 80
  let star_base = cx - 60
  for i in 0..<3 {
    let color = if i < game.result_stars {
      @types.color_star
    } else {
      @types.color_star_empty
    }
    @raylib.draw_circle(star_base + i * 45 + 15, star_y + 15, 20.0, color)
  }
  // Fence count
  let fence_str = "Fences used: " + game.result_fence_count.to_string()
  let fw = @draw.measure_text(fence_str, 22)
  @draw.draw_text(fence_str, cx - fw / 2, panel_y + 140, 22, @types.color_ui_text)
  // Par info
  match game.current_level {
    Some(level) => {
      let par_str = "Par: " +
        level.par_fences.to_string() +
        " fences, 3-star: " +
        level.par_length.to_string()
      let pw = @draw.measure_text(par_str, 18)
      @draw.draw_text(par_str, cx - pw / 2, panel_y + 175, 18, @types.color_ui_dim)
    }
    None => ()
  }
  // Buttons
  let btn_y = panel_y + 240
  draw_button(cx - 220, btn_y, 200, 50, "RETRY", true)
  draw_button(cx + 20, btn_y, 200, 50, "NEXT", game.result_stars > 0)
  // Back
  let back_str = "Press ESC to return to level select"
  let bw = @draw.measure_text(back_str, 16)
  @draw.draw_text(
    back_str,
    cx - bw / 2,
    panel_y + panel_h - 40,
    16,
    @types.color_ui_dim,
  )
}

///|
fn draw_button(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  text : String,
  enabled : Bool
) -> Unit {
  let hover = is_mouse_in_rect(x, y, w, h) && enabled
  let bg = if hover {
    @types.color_button_hover
  } else if enabled {
    @types.color_button
  } else {
    @types.color_ui_dim
  }
  @raylib.draw_rectangle(x, y, w, h, bg)
  @raylib.draw_rectangle_lines(x, y, w, h, @types.color_fence)
  let tw = @draw.measure_text(text, 22)
  let text_color = if enabled {
    @types.color_ui_text
  } else {
    @types.color_ui_bg
  }
  @draw.draw_text(text, x + w / 2 - tw / 2, y + h / 2 - 11, 22, text_color)
}

///|
fn is_mouse_in_rect(x : Int, y : Int, w : Int, h : Int) -> Bool {
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  mx >= x && mx < x + w && my >= y && my < y + h
}
