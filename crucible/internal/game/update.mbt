///|
pub fn update(game : @types.Game) -> Unit {
  let dt = @raylib.get_frame_time()
  game.frame_count += 1
  // Update animation timer
  if game.anim.active {
    game.anim.timer -= dt
    if game.anim.timer <= 0.0 {
      game.anim.active = false
      game.anim.kind = None
      // If success animation ended, show results
      if game.play_state == Success {
        game.screen = Results
      }
    }
  }
  // Update message timer
  if game.message_timer > 0.0 {
    game.message_timer -= dt
  }
  match game.screen {
    Title => update_title(game)
    TierSelect => update_tier_select(game)
    LevelSelect => update_level_select(game)
    Playing => update_playing(game)
    Results => update_results(game)
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.screen = TierSelect
  }
}

///|
fn update_tier_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
    return
  }
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let w = @types.screen_width
    let h = @types.screen_height
    let tiers : Array[@types.Tier] = [Apprentice, Journeyman, Master]
    for i in 0..<3 {
      let tier = tiers[i]
      let card_w = 300
      let card_h = 200
      let card_x = (w - card_w * 3 - 60) / 2 + i * (card_w + 30)
      let card_y = h / 2 - card_h / 2
      if mx >= card_x && mx <= card_x + card_w && my >= card_y && my <= card_y +
        card_h {
        if @levels.is_tier_unlocked(tier, game.level_scores) {
          game.current_tier = tier
          game.screen = LevelSelect
        }
      }
    }
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = TierSelect
    return
  }
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let w = @types.screen_width
    let start = @types.tier_start_index(game.current_tier)
    let count = @types.tier_level_count(game.current_tier)
    let cols = 5
    let btn_w = 160
    let btn_h = 100
    let gap = 20
    let grid_w = cols * btn_w + (cols - 1) * gap
    let base_x = (w - grid_w) / 2
    let base_y = 120
    for i in 0..<count {
      let col = i % cols
      let row = i / cols
      let bx = base_x + col * (btn_w + gap)
      let by = base_y + row * (btn_h + gap)
      if mx >= bx && mx <= bx + btn_w && my >= by && my <= by + btn_h {
        let level_idx = start + i
        start_level(game, level_idx)
        return
      }
    }
  }
}

///|
fn start_level(game : @types.Game, level_idx : Int) -> Unit {
  let level = @levels.get_level(level_idx)
  game.current_level_index = level_idx
  game.screen = Playing
  game.play_state = Idle
  game.cauldron_substance = None
  game.cauldron_history = []
  game.budget = @types.copy_budget(level.budget)
  game.steps_taken = 0
  game.failed_attempts = 0
  game.total_attempts = 0
  game.show_recipe_book = false
  game.message = ""
  game.message_timer = 0.0
  game.anim.active = false
  game.anim.kind = None
  game.selected_element = None
  game.add_anim_element = None
  // Initialize recipe book if empty
  if game.recipe_book.length() == 0 {
    @alchemy.init_recipe_book(game.recipe_book)
  }
}

///|
fn restart_level(game : @types.Game) -> Unit {
  start_level(game, game.current_level_index)
}

///|
fn update_playing(game : @types.Game) -> Unit {
  // Don't process input during animations
  if game.anim.active {
    return
  }
  // ESC - back to level select
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  // R - restart
  if @raylib.is_key_pressed(@raylib.KeyR) {
    restart_level(game)
    return
  }
  // Tab - toggle recipe book
  if @raylib.is_key_pressed(@raylib.KeyTab) {
    game.show_recipe_book = !(game.show_recipe_book)
    return
  }
  // Z - undo last addition
  if @raylib.is_key_pressed(@raylib.KeyZ) {
    undo_last(game)
    return
  }
  // Mouse click on element palette
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let clicked = detect_palette_click(game)
    match clicked {
      Some(elem) => add_element_to_cauldron(game, elem)
      None => ()
    }
  }
}

///|
fn detect_palette_click(game : @types.Game) -> @types.Element? {
  let mx = Float::from_int(@raylib.get_mouse_x())
  let my = Float::from_int(@raylib.get_mouse_y())
  let base_x = @types.palette_x
  let base_y = @types.palette_y
  let spacing = @types.palette_spacing
  let radius = @types.palette_radius
  let elements = @types.all_base_elements()
  let level = @levels.get_level(game.current_level_index)
  for i in 0..<elements.length() {
    let elem = elements[i]
    let total = @types.budget_get(level.budget, elem)
    if total <= 0 {
      continue
    }
    let remaining = @types.budget_get(game.budget, elem)
    if remaining <= 0 {
      continue
    }
    let ey = base_y + Float::from_int(i) * spacing
    let dx = mx - base_x
    let dy = my - ey
    if dx * dx + dy * dy < radius * radius {
      return Some(elem)
    }
  }
  None
}

///|
fn add_element_to_cauldron(game : @types.Game, elem : @types.Element) -> Unit {
  // Try to spend from budget
  if !(@types.budget_spend(game.budget, elem)) {
    @types.set_message(game, "No more " + @types.element_name(elem) + " remaining!")
    return
  }
  game.steps_taken += 1
  game.total_attempts += 1
  match game.cauldron_substance {
    None => {
      // First element - just place it
      game.cauldron_substance = Some(elem)
      game.cauldron_history.push(elem)
      // Start add animation
      let elem_idx = element_palette_index(elem)
      game.add_anim_element = Some(elem)
      game.add_anim_y = @types.palette_y + Float::from_int(elem_idx) * @types.palette_spacing
      @types.start_anim(game, AddElement, @types.add_anim_duration)
    }
    Some(current) => {
      // React with current substance
      let result = @alchemy.react(current, elem)
      // Discover the reaction
      let is_new = @alchemy.discover_reaction(
        game.recipe_book, current, elem, result,
      )
      // Also discover reverse direction
      ignore(
        @alchemy.discover_reaction(game.recipe_book, elem, current, result),
      )
      if is_new {
        game.discovered_count = @alchemy.count_discovered(game.recipe_book)
      }
      match result {
        Transform(new_elem) => {
          game.cauldron_substance = Some(new_elem)
          game.cauldron_history.push(elem)
          @types.set_message(
            game,
            @types.element_name(current) + " + " + @types.element_name(elem) +
            " = " +
            @types.element_name(new_elem) +
            (if is_new { " (NEW!)" } else { "" }),
          )
          // Start add animation
          let elem_idx = element_palette_index(elem)
          game.add_anim_element = Some(elem)
          game.add_anim_y = @types.palette_y + Float::from_int(elem_idx) * @types.palette_spacing
          @types.start_anim(game, AddElement, @types.add_anim_duration)
          // Check if target produced
          let level = @levels.get_level(game.current_level_index)
          if new_elem == level.target {
            // Level complete!
            handle_level_complete(game)
          }
        }
        Destroy => {
          game.cauldron_substance = None
          game.cauldron_history = []
          game.failed_attempts += 1
          @types.set_message(game, "Destruction! The substance was destroyed.")
          @types.start_anim(game, Destruction, @types.destroy_anim_duration)
        }
        NoReaction => {
          // Return the element to budget
          refund_element(game.budget, elem)
          game.steps_taken -= 1
          game.total_attempts -= 1
          @types.set_message(game, "No reaction. Try a different combination.")
        }
      }
    }
  }
}

///|
fn handle_level_complete(game : @types.Game) -> Unit {
  let level = @levels.get_level(game.current_level_index)
  game.play_state = Success
  // Calculate stars
  let mut stars = 1 // Always get 1 star for completing
  if game.steps_taken <= level.par_steps {
    stars = 2
    if game.failed_attempts == 0 {
      stars = 3
    }
  }
  game.result_stars = stars
  game.result_steps = game.steps_taken
  // Update level score
  let score = game.level_scores[game.current_level_index]
  score.completed = true
  if stars > score.stars {
    score.stars = stars
  }
  if score.best_steps == 0 || game.steps_taken < score.best_steps {
    score.best_steps = game.steps_taken
  }
  @types.start_anim(game, SuccessGlow, @types.success_anim_duration)
}

///|
fn undo_last(game : @types.Game) -> Unit {
  if game.cauldron_history.length() == 0 {
    @types.set_message(game, "Nothing to undo.")
    return
  }
  // Full restart and replay all but last element
  let history = game.cauldron_history
  let new_history : Array[@types.Element] = []
  for i in 0..<(history.length() - 1) {
    new_history.push(history[i])
  }
  // Refund the last element that was added
  let last = history[history.length() - 1]
  refund_element(game.budget, last)
  game.steps_taken -= 1
  // Replay from scratch
  game.cauldron_substance = None
  game.cauldron_history = []
  if new_history.length() > 0 {
    game.cauldron_substance = Some(new_history[0])
    game.cauldron_history.push(new_history[0])
    for i in 1..<new_history.length() {
      let current = game.cauldron_substance
      match current {
        Some(curr) => {
          let result = @alchemy.react(curr, new_history[i])
          match result {
            Transform(new_elem) => {
              game.cauldron_substance = Some(new_elem)
              game.cauldron_history.push(new_history[i])
            }
            _ => ()
          }
        }
        None => ()
      }
    }
  }
  @types.set_message(game, "Undone last addition.")
}

///|
fn refund_element(budget : @types.ElementBudget, elem : @types.Element) -> Unit {
  match elem {
    Fire => budget.fire += 1
    Water => budget.water += 1
    Earth => budget.earth += 1
    Air => budget.air += 1
    Light => budget.light += 1
    Shadow => budget.shadow += 1
    _ => ()
  }
}

///|
fn element_palette_index(elem : @types.Element) -> Int {
  match elem {
    Fire => 0
    Water => 1
    Earth => 2
    Air => 3
    Light => 4
    Shadow => 5
    _ => 0
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    // Next level
    let next = game.current_level_index + 1
    if next < @types.total_levels {
      start_level(game, next)
    } else {
      game.screen = TierSelect
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}
