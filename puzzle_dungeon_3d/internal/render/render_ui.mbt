// 2D UI overlay rendering

///|
/// Draws the screen-space HUD and menu overlays that correspond to the current
/// puzzle state, including transient message text and completion banners.
pub fn draw_ui(game : @types.Game) -> Unit {
  match game.state {
    StateMenu => game.draw_menu()
    StatePlaying => game.draw_hud()
    StatePaused => {
      game.draw_hud()
      game.draw_pause_overlay()
    }
    StateLevelComplete => {
      game.draw_hud()
      game.draw_level_complete()
    }
    StateGameOver => game.draw_game_over()
    StateWorldSelect => game.draw_world_select()
    StateFloorSelect => game.draw_floor_select()
    StateCampaignComplete => game.draw_campaign_complete()
    _ => ()
  }
  // Message overlay
  if game.message_timer > 0.0 {
    let alpha = @types.minf(game.message_timer * 2.0, 1.0)
    let a = (alpha * 255.0).to_int()
    let tw = @draw.measure_text(game.message_text, 24)
    @draw.draw_text(
      game.message_text,
      (@types.screen_width - tw) / 2,
      @types.screen_height / 2 + 80,
      24,
      @raylib.Color::new(255, 255, 200, a),
    )
  }
  // Tutorial overlay
  if game.tutorial_active && game.tutorial_text.length() > 0 {
    let panel_w = 500
    let panel_h = 60
    let panel_x = (@types.screen_width - panel_w) / 2
    let panel_y = 50
    @raylib.draw_rectangle(
      panel_x,
      panel_y,
      panel_w,
      panel_h,
      @raylib.Color::new(0, 0, 0, 180),
    )
    @raylib.draw_rectangle_lines(
      panel_x,
      panel_y,
      panel_w,
      panel_h,
      @raylib.Color::new(100, 180, 255, 200),
    )
    let tw = @draw.measure_text(game.tutorial_text, 20)
    @draw.draw_text(
      game.tutorial_text,
      (@types.screen_width - tw) / 2,
      panel_y + 20,
      20,
      @raylib.Color::new(200, 230, 255, 255),
    )
  }
}

///|
fn @types.Game::draw_menu(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(15, 20, 35, 255),
  )
  // Title
  let title = "PUZZLE DUNGEON 3D"
  let tw = @draw.measure_text(title, 48)
  @draw.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    150,
    48,
    @raylib.Color::new(100, 180, 255, 255),
  )
  // Subtitle
  let sub = "Push blocks. Solve puzzles. Ascend."
  let sw = @draw.measure_text(sub, 20)
  @draw.draw_text(
    sub,
    (@types.screen_width - sw) / 2,
    210,
    20,
    @raylib.Color::new(150, 160, 180, 255),
  )
  // Menu items
  let items : Array[String] = ["New Game", "World Select", "Floor Select"]
  for i in 0..<items.length() {
    let y = 320 + i * 50
    let is_selected = game.menu_cursor == i
    let blink_val = @math.sinf(game.menu_blink * 2.0)
    let color = if is_selected {
      if blink_val > 0.0 {
        @raylib.Color::new(255, 255, 100, 255)
      } else {
        @raylib.Color::new(200, 200, 80, 255)
      }
    } else {
      @raylib.Color::new(180, 180, 190, 255)
    }
    let iw = @draw.measure_text(items[i], 30)
    let prefix = if is_selected { "> " } else { "  " }
    let text = prefix + items[i]
    let full_w = @draw.measure_text(text, 30)
    @draw.draw_text(text, (@types.screen_width - full_w) / 2, y, 30, color)
    ignore(iw)
  }
  // Controls hint
  @draw.draw_text(
    "Arrow keys: Navigate | Enter: Select",
    (
      @types.screen_width -
      @draw.measure_text("Arrow keys: Navigate | Enter: Select", 16)
    ) /
    2,
    @types.screen_height - 60,
    16,
    @raylib.Color::new(120, 120, 140, 255),
  )
}

///|
fn @types.Game::draw_hud(game : @types.Game) -> Unit {
  // Top bar background
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    60,
    @raylib.Color::new(0, 0, 0, 160),
  )
  // Floor name
  let floor_name = "F\{game.current_floor + 1}: \{@levels.get_floor_name(game.current_floor)}"
  @draw.draw_text(floor_name, 10, 6, 20, @raylib.Color::new(200, 220, 255, 255))
  // Moves counter with par
  let par = @levels.get_par_moves(game.current_floor)
  let moves_color = if game.moves <= par {
    @raylib.Color::new(100, 255, 100, 255) // Gold/green: at or under par
  } else if game.moves <= par + @types.star_threshold_2 {
    @raylib.Color::new(255, 255, 100, 255) // Yellow: silver range
  } else {
    @raylib.Color::new(255, 180, 100, 255) // Orange: bronze range
  }
  let moves_text = "Moves: \{game.moves}"
  @draw.draw_text(moves_text, @types.screen_width / 2 - 70, 6, 20, moves_color)
  // Par and star thresholds
  let par_text = "Par: \{par}"
  @draw.draw_text(
    par_text,
    @types.screen_width / 2 - 70,
    28,
    14,
    @raylib.Color::new(180, 180, 200, 255),
  )
  // Star threshold indicators
  let star_info = "*** <=\{par}  ** <=\{par + @types.star_threshold_2}  * >\{par + @types.star_threshold_2}"
  @draw.draw_text(
    star_info,
    @types.screen_width / 2 + 10,
    28,
    12,
    @raylib.Color::new(150, 150, 170, 255),
  )
  // Objectives (second row area)
  let mut obj_x = @types.screen_width - 380
  if game.plates_total > 0 {
    let plates_text = "Plates: \{game.plates_active}/\{game.plates_total}"
    let plate_color = if game.plates_active >= game.plates_total {
      @raylib.Color::new(100, 255, 100, 255)
    } else {
      @raylib.Color::new(255, 200, 100, 255)
    }
    @draw.draw_text(plates_text, obj_x, 6, 18, plate_color)
    obj_x += 130
  }
  if game.diamonds_total > 0 {
    let diamond_text = "Gems: \{game.diamonds_collected}/\{game.diamonds_total}"
    let gem_color = if game.diamonds_collected >= game.diamonds_total {
      @raylib.Color::new(100, 255, 100, 255)
    } else {
      @raylib.Color::new(100, 200, 255, 255)
    }
    @draw.draw_text(diamond_text, obj_x, 6, 18, gem_color)
    obj_x += 120
  }
  // Laser target progress
  if game.laser_targets_total > 0 {
    let target_text = "Targets: \{game.laser_targets_hit}/\{game.laser_targets_total}"
    let target_color = if game.laser_targets_hit >= game.laser_targets_total {
      @raylib.Color::new(100, 255, 100, 255)
    } else {
      // Pulse red for unlit targets
      let pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.1)
      let red_val = 200 + (pulse * 55.0).to_int()
      @raylib.Color::new(red_val.clamp(min=150, max=255), 80, 80, 255)
    }
    @draw.draw_text(target_text, obj_x, 6, 18, target_color)
    // Draw individual target indicators below
    let mut ind_x = obj_x
    for t in 0..<game.laser_targets_total {
      let ind_color = if t < game.laser_targets_hit {
        // Lit: glowing green
        @raylib.Color::new(80, 255, 80, 255)
      } else {
        // Unlit: pulsing red
        let pulse = @math.sinf(
          Float::from_int(game.frame_counter) * 0.12 + Float::from_int(t) * 0.5,
        )
        let rv = 180 + (pulse * 75.0).to_int()
        @raylib.Color::new(rv.clamp(min=120, max=255), 40, 40, 255)
      }
      @raylib.draw_rectangle(ind_x, 28, 12, 12, ind_color)
      ind_x += 16
    }
    obj_x += 130
  }
  if game.keys_held > 0 {
    let key_text = "Keys: \{game.keys_held}"
    @draw.draw_text(
      key_text,
      @types.screen_width - 100,
      6,
      18,
      @raylib.Color::new(255, 215, 0, 255),
    )
  }
  // Undo counter
  let undo_text = "Undo: \{game.undo_count}"
  let undo_color = if game.undo_count == 0 {
    @raylib.Color::new(120, 80, 80, 255)
  } else {
    @raylib.Color::new(200, 200, 220, 255)
  }
  @draw.draw_text(undo_text, 10, 34, 14, undo_color)
  // Undo flash overlay
  if game.undo_flash_timer > 0.0 {
    let alpha_f = game.undo_flash_timer / @types.undo_flash_duration
    let flash_color = if game.undo_is_last {
      // Last undo: red-orange warning flash
      let a = (alpha_f * 100.0).to_int()
      @raylib.Color::new(255, 80, 40, a)
    } else {
      // Normal undo: blue-white rewind flash
      let a = (alpha_f * 60.0).to_int()
      @raylib.Color::new(150, 200, 255, a)
    }
    @raylib.draw_rectangle(
      0, 0, @types.screen_width, @types.screen_height, flash_color,
    )
    // Undo text overlay
    let undo_msg = if game.undo_is_last {
      "Undo (last one!)"
    } else {
      "Undo (\{game.undo_count} remaining)"
    }
    let uw = @draw.measure_text(undo_msg, 28)
    let text_alpha = (alpha_f * 255.0).to_int()
    let text_color = if game.undo_is_last {
      @raylib.Color::new(255, 120, 80, text_alpha)
    } else {
      @raylib.Color::new(200, 220, 255, text_alpha)
    }
    @draw.draw_text(
      undo_msg,
      (@types.screen_width - uw) / 2,
      @types.screen_height / 2 - 20,
      28,
      text_color,
    )
  }
  // Bottom hints
  @raylib.draw_rectangle(
    0,
    @types.screen_height - 30,
    @types.screen_width,
    30,
    @raylib.Color::new(0, 0, 0, 120),
  )
  @draw.draw_text(
    "WASD/Arrows: Move | Z: Undo | R: Restart | Q/E: Rotate | P: Pause",
    10,
    @types.screen_height - 24,
    14,
    @raylib.Color::new(150, 150, 170, 255),
  )
}

///|
fn @types.Game::draw_pause_overlay(game : @types.Game) -> Unit {
  ignore(game)
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 150),
  )
  let text = "PAUSED"
  let tw = @draw.measure_text(text, 60)
  @draw.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 60,
    60,
    @raylib.Color::new(255, 255, 255, 255),
  )
  let hint1 = "P: Resume | R: Restart | M: Menu"
  let hw = @draw.measure_text(hint1, 20)
  @draw.draw_text(
    hint1,
    (@types.screen_width - hw) / 2,
    @types.screen_height / 2 + 20,
    20,
    @raylib.Color::new(200, 200, 220, 255),
  )
}

///|
fn @types.Game::draw_level_complete(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 150),
  )
  // Animated title with scale-in effect
  let title_scale = @types.minf(game.complete_timer * 4.0, 1.0)
  let title_size_f : Float = 48.0 * title_scale
  let title_size = title_size_f.to_int().clamp(min=1, max=48)
  let text = "FLOOR COMPLETE!"
  let tw = @draw.measure_text(text, title_size)
  // Color pulse on title
  let pulse = @math.sinf(game.complete_timer * 4.0)
  let title_g = 220 + (pulse * 35.0).to_int()
  @draw.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 120,
    title_size,
    @raylib.Color::new(100, title_g.clamp(min=180, max=255), 120, 255),
  )
  // Stars earned label
  let par = @levels.get_par_moves(game.current_floor)
  let moves_text = "Moves: \{game.moves} (Par: \{par})"
  let mw = @draw.measure_text(moves_text, 24)
  let moves_color = if game.moves <= par {
    @raylib.Color::new(100, 255, 100, 255)
  } else if game.moves <= par + @types.star_threshold_2 {
    @raylib.Color::new(255, 255, 100, 255)
  } else {
    @raylib.Color::new(255, 180, 100, 255)
  }
  @draw.draw_text(
    moves_text,
    (@types.screen_width - mw) / 2,
    @types.screen_height / 2 - 55,
    24,
    moves_color,
  )
  // Rating label
  let rating_text = if game.complete_stars == 3 {
    "GOLD - Perfect!"
  } else if game.complete_stars == 2 {
    "SILVER - Well done!"
  } else {
    "BRONZE - Cleared!"
  }
  let rating_color = if game.complete_stars == 3 {
    @raylib.Color::new(255, 215, 0, 255)
  } else if game.complete_stars == 2 {
    @raylib.Color::new(200, 210, 220, 255)
  } else {
    @raylib.Color::new(210, 150, 80, 255)
  }
  let rw = @draw.measure_text(rating_text, 20)
  @draw.draw_text(
    rating_text,
    (@types.screen_width - rw) / 2,
    @types.screen_height / 2 - 25,
    20,
    rating_color,
  )
  // Draw animated stars with burst effect
  let star_y = @types.screen_height / 2 + 10
  for i in 0..<3 {
    let star_x = @types.screen_width / 2 - 60 + i * 50
    let show_time = Float::from_int(i) * 0.3
    if game.complete_timer > show_time {
      let earned = i < game.complete_stars
      let color = if earned {
        @raylib.Color::new(255, 215, 0, 255)
      } else {
        @raylib.Color::new(80, 80, 80, 255)
      }
      // Star burst glow when first appearing
      let appear_age = game.complete_timer - show_time
      if earned && appear_age < 0.4 {
        let glow_frac : Float = (0.4 - appear_age) / 0.4
        let glow_alpha = (glow_frac * 120.0).to_int()
        @raylib.draw_rectangle(
          star_x - 10,
          star_y - 5,
          40,
          40,
          @raylib.Color::new(255, 230, 80, glow_alpha.clamp(min=0, max=255)),
        )
      }
      @draw.draw_text("*", star_x, star_y, 40, color)
    }
  }
  // Star thresholds legend
  let legend = "*** <=\{par} moves | ** <=\{par + @types.star_threshold_2} moves | * any"
  let lw = @draw.measure_text(legend, 14)
  @draw.draw_text(
    legend,
    (@types.screen_width - lw) / 2,
    @types.screen_height / 2 + 60,
    14,
    @raylib.Color::new(150, 150, 170, 255),
  )
  // Hint
  let hint = "Enter: Next Floor | L: Floor Select | M: Menu"
  let hintw = @draw.measure_text(hint, 18)
  @draw.draw_text(
    hint,
    (@types.screen_width - hintw) / 2,
    @types.screen_height / 2 + 90,
    18,
    @raylib.Color::new(180, 180, 200, 255),
  )
}

///|
fn @types.Game::draw_game_over(game : @types.Game) -> Unit {
  ignore(game)
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(30, 0, 0, 200),
  )
  let text = "STUCK!"
  let tw = @draw.measure_text(text, 60)
  @draw.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 50,
    60,
    @raylib.Color::new(255, 100, 80, 255),
  )
  let hint = "Enter: Retry | M: Menu"
  let hintw = @draw.measure_text(hint, 20)
  @draw.draw_text(
    hint,
    (@types.screen_width - hintw) / 2,
    @types.screen_height / 2 + 30,
    20,
    @raylib.Color::new(200, 180, 180, 255),
  )
}

///|
fn @types.Game::draw_floor_select(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(15, 20, 35, 255),
  )
  let title = "SELECT FLOOR"
  let tw = @draw.measure_text(title, 36)
  @draw.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    30,
    36,
    @raylib.Color::new(200, 220, 255, 255),
  )
  // Grid of floors (6 per row)
  let cols = 6
  let cell_w = 120
  let cell_h = 80
  let start_x = (@types.screen_width - cols * cell_w) / 2
  let start_y = 100
  for i in 0..<@types.max_floors {
    let col = i % cols
    let row = i / cols
    let x = start_x + col * cell_w
    let y = start_y + row * cell_h
    let info = game.floor_info[i]
    let is_selected = game.floor_select_cursor == i
    // Background
    let bg = if is_selected {
      @raylib.Color::new(60, 80, 120, 255)
    } else if info.unlocked {
      @raylib.Color::new(35, 40, 55, 255)
    } else {
      @raylib.Color::new(20, 22, 30, 255)
    }
    @raylib.draw_rectangle(x + 2, y + 2, cell_w - 4, cell_h - 4, bg)
    if is_selected {
      @raylib.draw_rectangle_lines(
        x + 2,
        y + 2,
        cell_w - 4,
        cell_h - 4,
        @raylib.Color::new(200, 220, 255, 255),
      )
    }
    // Floor number
    let num_text = "\{i + 1}"
    let text_color = if info.unlocked {
      @raylib.Color::new(220, 220, 240, 255)
    } else {
      @raylib.Color::new(60, 60, 70, 255)
    }
    @draw.draw_text(num_text, x + 10, y + 10, 24, text_color)
    // Stars
    if info.completed {
      for s in 0..<3 {
        let star_color = if s < info.stars {
          @raylib.Color::new(255, 215, 0, 255)
        } else {
          @raylib.Color::new(60, 60, 70, 255)
        }
        @draw.draw_text("*", x + 10 + s * 16, y + 45, 20, star_color)
      }
    }
    if !info.unlocked {
      @draw.draw_text(
        "LOCKED",
        x + 10,
        y + 45,
        14,
        @raylib.Color::new(80, 60, 60, 255),
      )
    }
  }
  // Selected floor name
  let name = @levels.get_floor_name(game.floor_select_cursor)
  let nw = @draw.measure_text(name, 22)
  @draw.draw_text(
    name,
    (@types.screen_width - nw) / 2,
    @types.screen_height - 70,
    22,
    @raylib.Color::new(200, 220, 255, 255),
  )
  @draw.draw_text(
    "Arrows: Navigate | Enter: Play | Esc: Back",
    (
      @types.screen_width -
      @draw.measure_text("Arrows: Navigate | Enter: Play | Esc: Back", 16)
    ) /
    2,
    @types.screen_height - 35,
    16,
    @raylib.Color::new(120, 120, 140, 255),
  )
}

///|
fn @types.Game::draw_world_select(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(15, 20, 35, 255),
  )
  let title = "SELECT WORLD"
  let tw = @draw.measure_text(title, 36)
  @draw.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    60,
    36,
    @raylib.Color::new(200, 220, 255, 255),
  )
  // Total stars earned display
  let total_stars = @types.count_total_stars(game)
  let total_max = @types.max_floors * 3
  let stars_text = "Total Stars: \{total_stars}/\{total_max}"
  let stw = @draw.measure_text(stars_text, 20)
  @draw.draw_text(
    stars_text,
    (@types.screen_width - stw) / 2,
    105,
    20,
    @raylib.Color::new(255, 215, 0, 255),
  )
  // Draw world cards
  let card_w = 160
  let card_h = 200
  let gap = 20
  let total_w = @types.num_worlds * card_w + (@types.num_worlds - 1) * gap
  let start_x = (@types.screen_width - total_w) / 2
  let start_y = 160
  for i in 0..<@types.num_worlds {
    let x = start_x + i * (card_w + gap)
    let y = start_y
    let is_selected = game.world_select_cursor == i
    let unlocked = @types.is_world_unlocked(game, i)
    // Card background
    let world = @types.int_to_world(i)
    let (ar, ag, ab) = @types.get_world_accent_color(world)
    let bg = if is_selected {
      @raylib.Color::new(ar, ag, ab, 180)
    } else if unlocked {
      @raylib.Color::new(ar / 3, ag / 3, ab / 3, 200)
    } else {
      @raylib.Color::new(20, 22, 30, 200)
    }
    @raylib.draw_rectangle(x, y, card_w, card_h, bg)
    if is_selected {
      @raylib.draw_rectangle_lines(
        x,
        y,
        card_w,
        card_h,
        @raylib.Color::new(255, 255, 255, 255),
      )
    }
    // World name
    let name = @types.get_world_name(world)
    let nw = @draw.measure_text(name, 18)
    let name_color = if unlocked {
      @raylib.Color::new(240, 240, 255, 255)
    } else {
      @raylib.Color::new(80, 80, 90, 255)
    }
    @draw.draw_text(name, x + (card_w - nw) / 2, y + 20, 18, name_color)
    // Floor range
    let first = i * @types.floors_per_world + 1
    let last = (i + 1) * @types.floors_per_world
    let range_text = "Floors \{first}-\{last}"
    let rw = @draw.measure_text(range_text, 14)
    @draw.draw_text(
      range_text,
      x + (card_w - rw) / 2,
      y + 50,
      14,
      if unlocked {
        @raylib.Color::new(180, 180, 200, 255)
      } else {
        @raylib.Color::new(60, 60, 70, 255)
      },
    )
    // Completion progress and star info
    if unlocked {
      let mut completed = 0
      let floor_start = i * @types.floors_per_world
      for f in floor_start..<(floor_start + @types.floors_per_world) {
        if game.floor_info[f].completed {
          completed += 1
        }
      }
      let prog_text = "\{completed}/\{@types.floors_per_world} floors"
      let pw = @draw.measure_text(prog_text, 14)
      @draw.draw_text(
        prog_text,
        x + (card_w - pw) / 2,
        y + 80,
        14,
        @raylib.Color::new(200, 200, 220, 255),
      )
      // Show star count for this world
      let world_stars = @types.count_world_stars(game, i)
      let max_stars = @types.floors_per_world * 3
      let star_text = "* \{world_stars}/\{max_stars}"
      let sw2 = @draw.measure_text(star_text, 16)
      @draw.draw_text(
        star_text,
        x + (card_w - sw2) / 2,
        y + 100,
        16,
        @raylib.Color::new(255, 215, 0, 255),
      )
    } else {
      let req = @types.world_star_requirement(i)
      let current = @types.count_total_stars(game)
      let lock_text = "LOCKED"
      let lw = @draw.measure_text(lock_text, 18)
      @draw.draw_text(
        lock_text,
        x + (card_w - lw) / 2,
        y + 85,
        18,
        @raylib.Color::new(100, 60, 60, 255),
      )
      // Show star requirement
      let req_text = "Need \{req} stars (\{current}/\{req})"
      let rw2 = @draw.measure_text(req_text, 12)
      let req_color = if current >= req {
        @raylib.Color::new(100, 255, 100, 255)
      } else {
        @raylib.Color::new(180, 120, 80, 255)
      }
      @draw.draw_text(req_text, x + (card_w - rw2) / 2, y + 110, 12, req_color)
    }
  }
  // Hint
  @draw.draw_text(
    "Left/Right: Navigate | Enter: Select | Esc: Back",
    (
      @types.screen_width -
      @draw.measure_text("Left/Right: Navigate | Enter: Select | Esc: Back", 16)
    ) /
    2,
    @types.screen_height - 50,
    16,
    @raylib.Color::new(120, 120, 140, 255),
  )
}

///|
fn @types.Game::draw_campaign_complete(game : @types.Game) -> Unit {
  ignore(game)
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(10, 20, 40, 255),
  )
  let text = "CONGRATULATIONS!"
  let tw = @draw.measure_text(text, 48)
  @draw.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    200,
    48,
    @raylib.Color::new(255, 215, 0, 255),
  )
  let sub = "You completed all 30 floors!"
  let sw = @draw.measure_text(sub, 24)
  @draw.draw_text(
    sub,
    (@types.screen_width - sw) / 2,
    270,
    24,
    @raylib.Color::new(200, 220, 255, 255),
  )
  let hint = "Press Enter to return to menu"
  let hw = @draw.measure_text(hint, 18)
  @draw.draw_text(
    hint,
    (@types.screen_width - hw) / 2,
    350,
    18,
    @raylib.Color::new(150, 150, 170, 255),
  )
}
