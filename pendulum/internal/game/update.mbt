///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count = game.frame_count + 1
  game.anim_timer = game.anim_timer + 1.0 / 60.0
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - 1.0 / 60.0
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
  // Animate title pendulum
  game.title_angle = game.title_angle + 0.03
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
  // Mouse click on tier buttons
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let sw = @types.screen_width
    let tiers : Array[@types.Tier] = [Swing, Wrap, Launch]
    for i = 0; i < 3; i = i + 1 {
      let bx = sw / 2 - 200
      let by = 160 + i * 160
      let bw = 400
      let bh = 130
      if mx >= bx && mx < bx + bw && my >= by && my < by + bh {
        game.selected_tier = tiers[i]
        game.screen = LevelSelect
        return
      }
    }
  }
  // Keyboard shortcuts
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    game.selected_tier = Swing
    game.screen = LevelSelect
  } else if @raylib.is_key_pressed(@raylib.KeyTwo) {
    game.selected_tier = Wrap
    game.screen = LevelSelect
  } else if @raylib.is_key_pressed(@raylib.KeyThree) {
    game.selected_tier = Launch
    game.screen = LevelSelect
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = TierSelect
    return
  }
  let tier = game.selected_tier
  let count = @types.tier_level_count(tier)
  let offset = @types.tier_level_offset(tier)
  // Mouse click
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let sw = @types.screen_width
    let cols = 4
    let bw = 140
    let bh = 120
    let gap = 20
    let total_w = cols * bw + (cols - 1) * gap
    let start_x = (sw - total_w) / 2
    let start_y = 110
    for i = 0; i < count; i = i + 1 {
      let col = i % cols
      let row = i / cols
      let bx = start_x + col * (bw + gap)
      let by = start_y + row * (bh + gap)
      if mx >= bx && mx < bx + bw && my >= by && my < by + bh {
        game.selected_level = offset + i
        start_level(game, offset + i)
        return
      }
    }
  }
}

///|
fn start_level(game : @types.Game, level_id : Int) -> Unit {
  let level = @levels.get_level(level_id)
  game.current_level = Some(level)
  game.screen = Playing
  game.play_state = Ready
  game.tick_count = 0
  game.history = []
  game.message = "Press SPACE to swing"
  game.message_timer = 2.0
  // Init collected array
  game.collected = []
  for _i = 0; _i < level.collectibles.length(); _i = _i + 1 {
    game.collected.push(false)
  }
  // Init rope
  game.rope.anchor = level.anchor_pos
  game.rope.length = level.rope_length
  game.rope.wrapped_pegs = []
  // Init weight - start at bottom of arc
  let arc = @physics.compute_arc(level.anchor_pos, level.rope_length)
  game.arc_points = arc
  if arc.length() > 0 {
    let bottom = @physics.find_bottom_index(arc)
    game.weight.arc_index = bottom
    game.weight.pos = @types.vec2i(arc[bottom].gx, arc[bottom].gy)
  } else {
    game.weight.pos = @types.vec2i(
      level.anchor_pos.x,
      level.anchor_pos.y + level.rope_length,
    )
    game.weight.arc_index = 0
  }
  game.weight.state = Swinging
  game.weight.swing_dir = Right
  game.weight.launch_vel = @types.vec2f_zero()
  game.weight.launch_pos = @types.vec2f_zero()
  game.play_state = Simulating
}

///|
fn update_playing(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  match game.current_level {
    None => return
    Some(level) => {
      // Restart
      if @raylib.is_key_pressed(@raylib.KeyR) {
        start_level(game, level.id)
        return
      }
      // Undo
      if @raylib.is_key_pressed(@raylib.KeyZ) {
        undo_tick(game)
        return
      }
      // Won state - go to results
      if game.play_state == Won {
        if @raylib.is_key_pressed(@raylib.KeyEnter) ||
          @raylib.is_key_pressed(@raylib.KeySpace) {
          game.screen = Results
        }
        return
      }
      // Lost state
      if game.play_state == Lost {
        return
      }
      // Cut rope
      if @raylib.is_key_pressed(@raylib.KeyC) ||
        @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
        if game.weight.state == Swinging {
          // Save history before cut
          game.history.push(
            @types.new_history_entry(
              game.weight, game.rope, game.tick_count, game.collected,
            ),
          )
          @physics.cut_rope(game.weight, game.rope, game.arc_points)
        }
      }
      // Advance tick
      if @raylib.is_key_pressed(@raylib.KeySpace) ||
        @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        // Don't advance on menu clicks
        if game.weight.state == Swinging || game.weight.state == Launched {
          // Save history
          game.history.push(
            @types.new_history_entry(
              game.weight, game.rope, game.tick_count, game.collected,
            ),
          )
          game.tick_count = game.tick_count + 1
          @physics.tick_swing(
            game.weight,
            game.rope,
            game.arc_points,
            level.pegs,
            level.walls,
            level.goal_pos,
            level.collectibles,
            game.collected,
          )
          // Check if arc changed due to wrap
          if game.weight.state == Swinging {
            let new_arc = @physics.compute_arc(
              game.rope.anchor, game.rope.length,
            )
            if new_arc.length() != game.arc_points.length() {
              // Arc changed due to peg wrap
              let old_pos = game.weight.pos
              game.arc_points = new_arc
              game.weight.arc_index = @types.find_arc_index_for_pos(
                new_arc, old_pos,
              )
            }
            // Also check goal while swinging
            @physics.check_goal_on_swing(game.weight, level.goal_pos)
          }
          // Check for win/loss
          if game.weight.state == AtGoal {
            game.play_state = Won
            game.message = "Level Complete!"
            game.message_timer = 2.0
            // Update score
            let mut got = 0
            for i = 0; i < game.collected.length(); i = i + 1 {
              if game.collected[i] {
                got = got + 1
              }
            }
            let stars = @physics.compute_stars(
              game.tick_count,
              level.par_ticks,
              level.collectibles.length(),
              got,
            )
            let score = game.scores[level.id]
            score.completed = true
            if stars > score.stars {
              score.stars = stars
            }
            if game.tick_count < score.best_ticks {
              score.best_ticks = game.tick_count
            }
            score.collectibles_got = @types.maxi(score.collectibles_got, got)
          } else if game.weight.state == Stopped {
            game.play_state = Lost
            game.message = "Weight stopped! Press R to retry"
            game.message_timer = 3.0
          }
        }
      }
    }
  }
}

///|
fn undo_tick(game : @types.Game) -> Unit {
  if game.history.length() == 0 {
    return
  }
  let entry = game.history.unsafe_pop()
  game.tick_count = @types.restore_from_history(
    entry, game.weight, game.rope, game.collected,
  )
  // Recompute arc
  let arc = @physics.compute_arc(game.rope.anchor, game.rope.length)
  game.arc_points = arc
  game.play_state = Simulating
  game.message = ""
  game.message_timer = 0.0
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    match game.current_level {
      Some(level) => start_level(game, level.id)
      None => ()
    }
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    // Next level
    match game.current_level {
      Some(level) => {
        let next_id = level.id + 1
        if next_id < @types.total_levels {
          start_level(game, next_id)
        } else {
          game.screen = TierSelect
        }
      }
      None => game.screen = TierSelect
    }
  }
}
