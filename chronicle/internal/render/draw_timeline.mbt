///|
fn draw_playing(game : @types.Game) -> Unit {
  let case_ = @levels.get_case(game.current_tier, game.current_case_index)
  // Title bar
  draw_title_bar(game, case_)
  // Timeline area
  draw_timeline_slots(game, case_)
  // Cards placed in timeline
  draw_placed_cards(game, case_)
  // Card tray (unplaced cards)
  draw_card_tray(game, case_)
  // Cause link arrows
  draw_cause_links(game, case_)
  // Clue panel
  draw_clue_panel(game, case_)
  // Mode indicator
  draw_mode_indicator(game)
  // Drag preview
  if game.dragging && game.drag_card_id >= 0 {
    match @types.find_card(case_.cards, game.drag_card_id) {
      Some(card) =>
        draw_card_at(
          card,
          game.drag_x - @types.card_width / 2.0,
          game.drag_y - @types.card_height / 2.0,
          true,
          false,
          false,
        )
      None => ()
    }
  }
}

///|
fn draw_title_bar(game : @types.Game, case_ : @types.Case) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    50,
    @types.color_clue_panel_bg,
  )
  @draw.draw_text(case_.title, 20, 12, 24, @types.color_title)
  @draw.draw_text(case_.theme, 350, 16, 18, @types.color_subtitle)
  // Rewind counter
  let rewind_str = "Rewinds: " + game.rewinds.to_string()
  @draw.draw_text(rewind_str, 700, 16, 18, @types.color_hud)
  // Controls hint
  @draw.draw_text(
    "Tab:mode | Enter:check | R:restart | Z:undo",
    20,
    35,
    12,
    @types.color_subtitle,
  )
}

///|
fn draw_timeline_slots(game : @types.Game, case_ : @types.Case) -> Unit {
  let num_slots = case_.cards.length()
  let total_width = Float::from_int(num_slots) * @types.slot_width +
    Float::from_int(num_slots - 1) * @types.card_gap
  let start_x = (Float::from_int(@types.screen_width) - total_width -
    @types.clue_panel_width) /
  2.0
  // Timeline line
  let line_y = Float::to_int(@types.timeline_y + @types.slot_height / 2.0)
  @raylib.draw_line(
    Float::to_int(start_x - 20.0),
    line_y,
    Float::to_int(start_x + total_width + 20.0),
    line_y,
    @types.color_subtitle,
  )
  // Slot numbers
  for i in 0..<num_slots {
    let sx = start_x + Float::from_int(i) * (@types.slot_width + @types.card_gap)
    let sy = @types.timeline_y
    let is_hover = game.hover_slot == i
    let slot_color = if is_hover {
      @types.color_slot_hover
    } else {
      @types.color_slot_empty
    }
    // Draw slot
    @raylib.draw_rectangle(
      Float::to_int(sx),
      Float::to_int(sy),
      Float::to_int(@types.slot_width),
      Float::to_int(@types.slot_height),
      slot_color,
    )
    @raylib.draw_rectangle_lines(
      Float::to_int(sx),
      Float::to_int(sy),
      Float::to_int(@types.slot_width),
      Float::to_int(@types.slot_height),
      @types.color_subtitle,
    )
    // Slot number
    let num = (i + 1).to_string()
    @draw.draw_text(
      num,
      Float::to_int(sx + @types.slot_width / 2.0 - 5.0),
      Float::to_int(sy - 20.0),
      16,
      @types.color_subtitle,
    )
    // Arrow between slots
    if i < num_slots - 1 {
      let arrow_x = Float::to_int(sx + @types.slot_width + 2.0)
      @draw.draw_text(">", arrow_x, line_y - 8, 16, @types.color_subtitle)
    }
  }
}

///|
fn draw_placed_cards(game : @types.Game, case_ : @types.Case) -> Unit {
  let num_slots = case_.cards.length()
  let total_width = Float::from_int(num_slots) * @types.slot_width +
    Float::from_int(num_slots - 1) * @types.card_gap
  let start_x = (Float::from_int(@types.screen_width) - total_width -
    @types.clue_panel_width) /
  2.0
  for i in 0..<game.timeline_slots.length() {
    let card_id = game.timeline_slots[i]
    if card_id >= 0 {
      match @types.find_card(case_.cards, card_id) {
        Some(card) => {
          let sx = start_x +
            Float::from_int(i) * (@types.slot_width + @types.card_gap)
          let sy = @types.timeline_y + 5.0
          let is_anchor = @types.is_anchor(case_, card_id)
          let is_selected = game.selected_card == card_id ||
            game.link_from == card_id
          // Don't draw if being dragged
          if !(game.dragging && game.drag_card_id == card_id) {
            draw_card_at(
              card, sx + 5.0, sy, false, is_anchor, is_selected,
            )
          }
        }
        None => ()
      }
    }
  }
}

///|
fn draw_card_tray(game : @types.Game, case_ : @types.Case) -> Unit {
  // Background
  @raylib.draw_rectangle(
    0,
    Float::to_int(@types.tray_y),
    Float::to_int(
      Float::from_int(@types.screen_width) - @types.clue_panel_width,
    ),
    Float::to_int(@types.tray_height),
    @raylib.Color::new(40, 35, 50, 200),
  )
  @draw.draw_text(
    "Available Cards (click to select, drag to place):",
    20,
    Float::to_int(@types.tray_y + 5.0),
    14,
    @types.color_subtitle,
  )
  // Unplaced cards
  let mut col = 0
  for i in 0..<case_.cards.length() {
    let card = case_.cards[i]
    if !@types.is_card_placed(game.timeline_slots, card.id) {
      if !(game.dragging && game.drag_card_id == card.id) {
        let cx : Float = 20.0 + Float::from_int(col) * (@types.card_width + 10.0)
        let cy : Float = @types.tray_y + 25.0
        let is_selected = game.selected_card == card.id ||
          game.link_from == card.id
        draw_card_at(card, cx, cy, false, false, is_selected)
      }
      col += 1
    }
  }
}

///|
fn draw_card_at(
  card : @types.EventCard,
  x : Float,
  y : Float,
  is_drag : Bool,
  is_anchor : Bool,
  is_selected : Bool
) -> Unit {
  let bg = if is_drag {
    @raylib.Color::new(255, 245, 220, 230)
  } else if is_anchor {
    @types.color_card_anchor
  } else {
    @types.color_card
  }
  let ix = Float::to_int(x)
  let iy = Float::to_int(y)
  let iw = Float::to_int(@types.card_width)
  let ih = Float::to_int(@types.card_height)
  // Shadow
  @raylib.draw_rectangle(ix + 3, iy + 3, iw, ih, @raylib.Color::new(0, 0, 0, 60))
  // Card body
  @raylib.draw_rectangle(ix, iy, iw, ih, bg)
  // Border
  let border_color = if is_selected {
    @types.color_clue
  } else if is_anchor {
    @raylib.Color::new(140, 130, 110, 255)
  } else {
    @raylib.Color::new(180, 170, 150, 255)
  }
  @raylib.draw_rectangle_lines(ix, iy, iw, ih, border_color)
  if is_selected {
    @raylib.draw_rectangle_lines(ix - 1, iy - 1, iw + 2, ih + 2, border_color)
  }
  // Actor line
  @draw.draw_text(card.actor, ix + 6, iy + 6, 14, @types.color_card_text)
  // Action (truncated)
  let action = truncate_text(card.action, 22)
  @draw.draw_text(
    action,
    ix + 6,
    iy + 24,
    13,
    @raylib.Color::new(80, 70, 60, 255),
  )
  // Time hint
  @draw.draw_text(
    card.time_hint,
    ix + 6,
    iy + 46,
    12,
    @raylib.Color::new(140, 120, 80, 255),
  )
  // Anchor indicator
  if is_anchor {
    @draw.draw_text("FIXED", ix + iw - 45, iy + ih - 18, 11, @raylib.Color::new(160, 80, 80, 255))
  }
  // ID badge
  let id_str = "#" + card.id.to_string()
  @draw.draw_text(
    id_str,
    ix + iw - 25,
    iy + 4,
    11,
    @raylib.Color::new(160, 150, 130, 255),
  )
}

///|
fn truncate_text(s : String, max_len : Int) -> String {
  if s.length() <= max_len {
    s
  } else {
    s[0:max_len - 2].to_string() + ".."
  }
}

///|
fn draw_cause_links(game : @types.Game, case_ : @types.Case) -> Unit {
  let num_slots = case_.cards.length()
  let total_width = Float::from_int(num_slots) * @types.slot_width +
    Float::from_int(num_slots - 1) * @types.card_gap
  let start_x = (Float::from_int(@types.screen_width) - total_width -
    @types.clue_panel_width) /
  2.0
  for i in 0..<game.placed_links.length() {
    let link = game.placed_links[i]
    let from_slot = @types.card_in_slot(game.timeline_slots, link.from_id)
    let to_slot = @types.card_in_slot(game.timeline_slots, link.to_id)
    if from_slot >= 0 && to_slot >= 0 {
      let fx = start_x +
        Float::from_int(from_slot) * (@types.slot_width + @types.card_gap) +
        @types.slot_width / 2.0
      let fy = @types.timeline_y - 5.0
      let tx = start_x +
        Float::from_int(to_slot) * (@types.slot_width + @types.card_gap) +
        @types.slot_width / 2.0
      let ty = @types.timeline_y - 5.0
      // Curved arrow above timeline
      let mid_y = fy - 30.0 -
        Float::from_int(@types.absf(tx - fx).to_int()) * 0.15
      // Draw arrow line segments
      let color = if game.play_state == Validated {
        if is_link_correct(link, case_.solution_links) {
          @types.color_link_correct
        } else {
          @types.color_link_wrong
        }
      } else {
        @types.color_link_arrow
      }
      // Simple arc: from -> mid -> to
      let steps = 12
      for s in 0..<steps {
        let t1 = Float::from_int(s) / Float::from_int(steps)
        let t2 = Float::from_int(s + 1) / Float::from_int(steps)
        let x1 = bezier_point(fx, (fx + tx) / 2.0, tx, t1)
        let y1 = bezier_point(fy, mid_y, ty, t1)
        let x2 = bezier_point(fx, (fx + tx) / 2.0, tx, t2)
        let y2 = bezier_point(fy, mid_y, ty, t2)
        @raylib.draw_line(
          Float::to_int(x1),
          Float::to_int(y1),
          Float::to_int(x2),
          Float::to_int(y2),
          color,
        )
      }
      // Arrowhead at end
      @raylib.draw_triangle(
        @raylib.Vector2::new(tx, ty),
        @raylib.Vector2::new(tx - 8.0, ty - 12.0),
        @raylib.Vector2::new(tx + 8.0, ty - 12.0),
        color,
      )
      // Label
      let mid_x = (fx + tx) / 2.0
      @draw.draw_text(
        "cause",
        Float::to_int(mid_x - 15.0),
        Float::to_int(mid_y - 12.0),
        11,
        color,
      )
    }
  }
  // Draw link-in-progress
  if game.link_from >= 0 && game.play_state == Linking {
    let from_slot = @types.card_in_slot(game.timeline_slots, game.link_from)
    if from_slot >= 0 {
      let fx = start_x +
        Float::from_int(from_slot) * (@types.slot_width + @types.card_gap) +
        @types.slot_width / 2.0
      let fy = @types.timeline_y - 5.0
      let mx = Float::from_int(@raylib.get_mouse_x())
      let my = Float::from_int(@raylib.get_mouse_y())
      @raylib.draw_line(
        Float::to_int(fx),
        Float::to_int(fy),
        Float::to_int(mx),
        Float::to_int(my),
        @types.color_link_arrow,
      )
    }
  }
}

///|
fn bezier_point(p0 : Float, p1 : Float, p2 : Float, t : Float) -> Float {
  let one : Float = 1.0
  let two : Float = 2.0
  let u = one - t
  u * u * p0 + two * u * t * p1 + t * t * p2
}

///|
fn is_link_correct(
  link : @types.CauseLink,
  solution : Array[@types.CauseLink]
) -> Bool {
  for i in 0..<solution.length() {
    if solution[i].from_id == link.from_id && solution[i].to_id == link.to_id {
      return true
    }
  }
  false
}

///|
fn draw_clue_panel(game : @types.Game, case_ : @types.Case) -> Unit {
  let px = Float::to_int(@types.clue_panel_x)
  let py = Float::to_int(@types.clue_panel_y)
  let pw = Float::to_int(@types.clue_panel_width)
  let ph = @types.screen_height - 20
  // Background
  @raylib.draw_rectangle(px, py, pw, ph, @types.color_clue_panel_bg)
  @raylib.draw_rectangle_lines(px, py, pw, ph, @types.color_subtitle)
  @draw.draw_text("CLUES", px + 130, py + 10, 24, @types.color_clue)
  // Clues list
  for i in 0..<case_.clues.length() {
    let clue = case_.clues[i]
    let cy = py + 50 + i * 70
    if cy + 60 < ph {
      // Clue kind badge
      let kind_str = @types.clue_kind_label(clue.kind)
      let badge_color = match clue.kind {
        Before => @raylib.Color::new(80, 150, 200, 255)
        After => @raylib.Color::new(200, 150, 80, 255)
        Because => @raylib.Color::new(200, 80, 80, 255)
        During => @raylib.Color::new(80, 200, 150, 255)
        NotAdjacent => @raylib.Color::new(180, 100, 180, 255)
      }
      @raylib.draw_rectangle(px + 10, cy, 90, 20, badge_color)
      @draw.draw_text(
        kind_str,
        px + 15,
        cy + 3,
        13,
        @raylib.Color::new(30, 25, 20, 255),
      )
      // Satisfaction indicator
      if game.play_state == Validated {
        let satisfied = check_clue_in_timeline(clue, game.timeline_slots)
        let check_str = if satisfied { "OK" } else { "X" }
        let check_col = if satisfied {
          @types.color_correct
        } else {
          @types.color_wrong
        }
        @draw.draw_text(check_str, px + pw - 35, cy + 3, 14, check_col)
      }
      // Clue text (may wrap)
      let clue_text = truncate_text(clue.text, 40)
      @draw.draw_text(
        clue_text,
        px + 10,
        cy + 24,
        14,
        @types.color_hud,
      )
      // Card references
      let ref_str = "[#" +
        clue.card_a.to_string() +
        " -> #" +
        clue.card_b.to_string() +
        "]"
      @draw.draw_text(ref_str, px + 10, cy + 44, 12, @types.color_subtitle)
    }
  }
}

///|
fn check_clue_in_timeline(clue : @types.Clue, timeline : Array[Int]) -> Bool {
  let pos_a = @types.card_in_slot(timeline, clue.card_a)
  let pos_b = @types.card_in_slot(timeline, clue.card_b)
  if pos_a < 0 || pos_b < 0 {
    return false
  }
  match clue.kind {
    Before => pos_a < pos_b
    After => pos_a > pos_b
    Because => pos_a < pos_b
    During => {
      let diff = pos_a - pos_b
      diff == 1 || diff == -1
    }
    NotAdjacent => {
      let diff = pos_a - pos_b
      !(diff == 1 || diff == -1)
    }
  }
}
