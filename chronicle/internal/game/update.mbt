///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count = game.frame_count + 1
  game.title_pulse = game.title_pulse + 0.016
  if game.message_timer > 0.0 {
    let dt : Float = 0.016
    game.message_timer = game.message_timer - dt
  }
  match game.screen {
    Title => update_title(game)
    TierSelect => update_tier_select(game)
    CaseSelect => update_case_select(game)
    Playing => update_playing(game)
    Results => update_results(game)
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = TierSelect
  }
}

///|
fn update_tier_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    let idx = @types.tier_index(game.current_tier)
    if idx > 0 {
      game.current_tier = @types.tier_from_index(idx - 1)
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    let idx = @types.tier_index(game.current_tier)
    if idx < 2 {
      game.current_tier = @types.tier_from_index(idx + 1)
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.current_case_index = 0
    game.screen = CaseSelect
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
  }
}

///|
fn update_case_select(game : @types.Game) -> Unit {
  let count = @types.tier_case_count(game.current_tier)
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    if game.current_case_index < count - 1 {
      game.current_case_index += 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    if game.current_case_index > 0 {
      game.current_case_index -= 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    if game.current_case_index + 4 < count {
      game.current_case_index += 4
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    if game.current_case_index >= 4 {
      game.current_case_index -= 4
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    start_case(game)
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = TierSelect
  }
}

///|
fn start_case(game : @types.Game) -> Unit {
  let case_ = @levels.get_case(game.current_tier, game.current_case_index)
  let num_slots = case_.cards.length()
  let slots : Array[Int] = []
  for _i in 0..<num_slots {
    slots.push(-1)
  }
  // Place anchor cards
  for i in 0..<case_.anchors.length() {
    let card_id = case_.anchors[i]
    let fixed = @types.get_fixed_slot(case_.cards, card_id)
    if fixed >= 0 && fixed < num_slots {
      slots[fixed] = card_id
    }
  }
  game.timeline_slots = slots
  game.placed_links = []
  game.rewinds = 0
  game.selected_card = -1
  game.link_from = -1
  game.dragging = false
  game.drag_card_id = -1
  game.hover_slot = -1
  game.hover_card = -1
  game.play_state = Arranging
  game.screen = Playing
}

///|
fn update_playing(game : @types.Game) -> Unit {
  let case_ = @levels.get_case(game.current_tier, game.current_case_index)
  let mx = Float::from_int(@raylib.get_mouse_x())
  let my = Float::from_int(@raylib.get_mouse_y())
  // Tab to toggle mode
  if @raylib.is_key_pressed(@raylib.KeyTab) {
    match game.play_state {
      Arranging => {
        game.play_state = Linking
        game.selected_card = -1
        game.link_from = -1
      }
      Linking => {
        game.play_state = Arranging
        game.link_from = -1
      }
      Validated => ()
    }
  }
  // Enter to validate
  if @raylib.is_key_pressed(@raylib.KeyEnter) && game.play_state != Validated {
    let placed = @types.count_placed(game.timeline_slots)
    if placed == case_.cards.length() {
      let score = @logic.compute_score(
        case_, game.timeline_slots, game.placed_links, game.rewinds,
      )
      game.result_score = score
      // Save score if better
      let ti = @types.tier_index(game.current_tier)
      let ci = game.current_case_index
      if score.stars > game.case_scores[ti][ci].stars {
        game.case_scores[ti][ci] = score
      }
      game.play_state = Validated
      game.screen = Results
    } else {
      game.message = "Place all cards before validating!"
      let t : Float = 2.0
      game.message_timer = t
    }
  }
  // R to restart
  if @raylib.is_key_pressed(@raylib.KeyR) {
    game.rewinds += 1
    start_case(game)
    return
  }
  // Z to undo last placement
  if @raylib.is_key_pressed(@raylib.KeyZ) {
    undo_last(game, case_)
  }
  // Escape to go back
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = CaseSelect
    return
  }
  // Update hover slot
  game.hover_slot = get_slot_at(case_, mx, my)
  // Mode-specific input
  match game.play_state {
    Arranging => update_arranging(game, case_, mx, my)
    Linking => update_linking(game, case_, mx, my)
    Validated => ()
  }
}

///|
fn update_arranging(
  game : @types.Game,
  case_ : @types.Case,
  mx : Float,
  my : Float
) -> Unit {
  // Left click to pick up / place card
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    if !game.dragging {
      // Try to pick up from tray
      let tray_card = get_tray_card_at(game, case_, mx, my)
      if tray_card >= 0 && !@types.is_anchor(case_, tray_card) {
        game.dragging = true
        game.drag_card_id = tray_card
        game.drag_x = mx
        game.drag_y = my
      } else {
        // Try to pick up from timeline
        let slot = get_slot_at(case_, mx, my)
        if slot >= 0 && game.timeline_slots[slot] >= 0 {
          let card_id = game.timeline_slots[slot]
          if !@types.is_anchor(case_, card_id) {
            game.dragging = true
            game.drag_card_id = card_id
            game.timeline_slots[slot] = -1
            game.drag_x = mx
            game.drag_y = my
          }
        }
      }
    }
  }
  // Dragging update
  if game.dragging {
    game.drag_x = mx
    game.drag_y = my
    if @raylib.is_mouse_button_released(@raylib.MouseButtonLeft) {
      // Try to place in slot
      let slot = get_slot_at(case_, mx, my)
      if slot >= 0 && @types.is_slot_empty(game.timeline_slots, slot) {
        game.timeline_slots[slot] = game.drag_card_id
      } else if slot >= 0 && game.timeline_slots[slot] >= 0 {
        // Swap if slot occupied (and not anchor)
        let existing = game.timeline_slots[slot]
        if !@types.is_anchor(case_, existing) {
          // Put existing card back, place dragged card
          game.timeline_slots[slot] = game.drag_card_id
        }
        // If anchor, just don't place
      }
      game.dragging = false
      game.drag_card_id = -1
    }
  }
  // Right-click to remove from timeline
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
    let slot = get_slot_at(case_, mx, my)
    if slot >= 0 && game.timeline_slots[slot] >= 0 {
      let card_id = game.timeline_slots[slot]
      if !@types.is_anchor(case_, card_id) {
        game.timeline_slots[slot] = -1
      }
    }
  }
}

///|
fn update_linking(
  game : @types.Game,
  case_ : @types.Case,
  mx : Float,
  my : Float
) -> Unit {
  ignore(case_)
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    // Find card at mouse position in timeline
    let card_id = get_timeline_card_at(game, mx, my)
    if card_id >= 0 {
      if game.link_from < 0 {
        // First card of link
        game.link_from = card_id
      } else if game.link_from != card_id {
        // Second card - create link
        let from = game.link_from
        let to = card_id
        if @types.link_exists(game.placed_links, from, to) {
          // Remove existing link
          game.placed_links = @types.remove_link(game.placed_links, from, to)
        } else {
          game.placed_links.push(@types.make_link(from, to))
        }
        game.link_from = -1
      } else {
        // Clicked same card, deselect
        game.link_from = -1
      }
    } else {
      game.link_from = -1
    }
  }
  // Right-click to remove a link
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
    let card_id = get_timeline_card_at(game, mx, my)
    if card_id >= 0 {
      // Remove all links involving this card
      let new_links : Array[@types.CauseLink] = []
      for i in 0..<game.placed_links.length() {
        let lnk = game.placed_links[i]
        if !(lnk.from_id == card_id || lnk.to_id == card_id) {
          new_links.push(lnk)
        }
      }
      game.placed_links = new_links
    }
    game.link_from = -1
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.screen = CaseSelect
    game.play_state = Arranging
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    game.rewinds = 0
    start_case(game)
  }
}

///|
fn get_slot_at(case_ : @types.Case, mx : Float, my : Float) -> Int {
  let num_slots = case_.cards.length()
  let total_width = Float::from_int(num_slots) * @types.slot_width +
    Float::from_int(num_slots - 1) * @types.card_gap
  let start_x = (Float::from_int(@types.screen_width) - total_width -
    @types.clue_panel_width) /
  2.0
  for i in 0..<num_slots {
    let sx = start_x + Float::from_int(i) * (@types.slot_width + @types.card_gap)
    let sy = @types.timeline_y
    if mx >= sx &&
      mx <= sx + @types.slot_width &&
      my >= sy &&
      my <= sy + @types.slot_height {
      return i
    }
  }
  -1
}

///|
fn get_tray_card_at(
  game : @types.Game,
  case_ : @types.Case,
  mx : Float,
  my : Float
) -> Int {
  let mut col = 0
  for i in 0..<case_.cards.length() {
    let card = case_.cards[i]
    if !@types.is_card_placed(game.timeline_slots, card.id) {
      let cx : Float = 20.0 + Float::from_int(col) * (@types.card_width + 10.0)
      let cy : Float = @types.tray_y + 25.0
      if mx >= cx &&
        mx <= cx + @types.card_width &&
        my >= cy &&
        my <= cy + @types.card_height {
        return card.id
      }
      col += 1
    }
  }
  -1
}

///|
fn get_timeline_card_at(
  game : @types.Game,
  mx : Float,
  my : Float
) -> Int {
  // Check if mouse is over any card in the timeline
  let case_ = @levels.get_case(game.current_tier, game.current_case_index)
  let num_slots = case_.cards.length()
  let total_width = Float::from_int(num_slots) * @types.slot_width +
    Float::from_int(num_slots - 1) * @types.card_gap
  let start_x = (Float::from_int(@types.screen_width) - total_width -
    @types.clue_panel_width) /
  2.0
  for i in 0..<game.timeline_slots.length() {
    if game.timeline_slots[i] >= 0 {
      let sx = start_x +
        Float::from_int(i) * (@types.slot_width + @types.card_gap)
      let sy = @types.timeline_y
      if mx >= sx &&
        mx <= sx + @types.slot_width &&
        my >= sy &&
        my <= sy + @types.slot_height {
        return game.timeline_slots[i]
      }
    }
  }
  -1
}

///|
fn undo_last(game : @types.Game, case_ : @types.Case) -> Unit {
  // Undo: remove last placed non-anchor card from timeline
  let mut last_slot = -1
  for i in 0..<game.timeline_slots.length() {
    if game.timeline_slots[i] >= 0 &&
      !@types.is_anchor(case_, game.timeline_slots[i]) {
      last_slot = i
    }
  }
  if last_slot >= 0 {
    game.timeline_slots[last_slot] = -1
  }
}
