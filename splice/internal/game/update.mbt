///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count += 1
  game.anim_timer += 1.0 / 60.0
  if game.message_timer > 0.0 {
    game.message_timer -= 1.0 / 60.0
    if game.message_timer <= 0.0 {
      game.message = ""
      game.message_timer = 0.0
    }
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
  if @raylib.is_key_pressed(@raylib.KeyEnter) || @raylib.is_key_pressed(
      @raylib.KeySpace,
    ) {
    game.screen = TierSelect
  }
}

///|
fn update_tier_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.current_tier -= 1
    if game.current_tier < 0 {
      game.current_tier = 2
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.current_tier += 1
    if game.current_tier > 2 {
      game.current_tier = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) || @raylib.is_key_pressed(
      @raylib.KeySpace,
    ) {
    if @levels.is_tier_unlocked(game.current_tier, game.level_scores) {
      game.current_level = 0
      game.screen = LevelSelect
    } else {
      @types.set_message(game, "Complete more levels to unlock!", 2.0)
    }
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = TierSelect
    return
  }
  let count = @types.tier_level_count(game.current_tier)
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.current_level -= 1
    if game.current_level < 0 {
      game.current_level = count - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.current_level += 1
    if game.current_level >= count {
      game.current_level = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.current_level -= 4
    if game.current_level < 0 {
      game.current_level = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.current_level += 4
    if game.current_level >= count {
      game.current_level = count - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) || @raylib.is_key_pressed(
      @raylib.KeySpace,
    ) {
    start_level(game)
  }
}

///|
fn start_level(game : @types.Game) -> Unit {
  let level_idx = @types.tier_level_offset(game.current_tier) +
    game.current_level
  let level = @levels.get_level(level_idx)
  game.current_sequence = @types.copy_sequence(level.start_sequence)
  game.original_sequence = @types.copy_sequence(level.start_sequence)
  game.cursor = 0
  game.selection_start = -1
  game.selection_end = -1
  game.edit_count = 0
  game.ops_history = []
  game.play_state = Editing
  game.selected_op = level.available_ops[0]
  game.insert_base = A
  game.confirm_verify = false
  game.show_help = false
  game.screen = Playing
}

///|
fn update_playing(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  if game.play_state != Editing {
    return
  }
  // Toggle help
  if @raylib.is_key_pressed(@raylib.KeyH) {
    game.show_help = !game.show_help
  }
  // Restart
  if @raylib.is_key_pressed(@raylib.KeyR) {
    let level_idx = @types.tier_level_offset(game.current_tier) +
      game.current_level
    let level = @levels.get_level(level_idx)
    game.current_sequence = @types.copy_sequence(level.start_sequence)
    game.cursor = 0
    @types.clear_selection(game)
    game.edit_count = 0
    game.ops_history = []
    game.play_state = Editing
    game.confirm_verify = false
    @types.set_message(game, "Sequence reset", 1.0)
    return
  }
  // Undo
  if @raylib.is_key_pressed(@raylib.KeyZ) && game.ops_history.length() > 0 {
    undo_last(game)
    return
  }
  // Cursor movement
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    if @raylib.is_key_down(@raylib.KeyLeftShift) || @raylib.is_key_down(
        @raylib.KeyRightShift,
      ) {
      // Extend selection
      if game.selection_start < 0 {
        game.selection_start = game.cursor
        game.selection_end = game.cursor
      }
      game.cursor -= 1
      @types.clamp_cursor(game)
      game.selection_end = game.cursor
    } else {
      game.cursor -= 1
      @types.clamp_cursor(game)
      @types.clear_selection(game)
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    if @raylib.is_key_down(@raylib.KeyLeftShift) || @raylib.is_key_down(
        @raylib.KeyRightShift,
      ) {
      if game.selection_start < 0 {
        game.selection_start = game.cursor
        game.selection_end = game.cursor
      }
      game.cursor += 1
      @types.clamp_cursor(game)
      game.selection_end = game.cursor
    } else {
      game.cursor += 1
      @types.clamp_cursor(game)
      @types.clear_selection(game)
    }
  }
  // Home/End
  if @raylib.is_key_pressed(@raylib.KeyHome) {
    game.cursor = 0
    @types.clear_selection(game)
  }
  if @raylib.is_key_pressed(@raylib.KeyEnd) {
    game.cursor = game.current_sequence.length()
    @types.clear_selection(game)
  }
  // Select operation
  let level_idx = @types.tier_level_offset(game.current_tier) +
    game.current_level
  let level = @levels.get_level(level_idx)
  if @raylib.is_key_pressed(@raylib.KeyOne) && has_op(level, Cut) {
    game.selected_op = Cut
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) && has_op(level, Insert) {
    game.selected_op = Insert
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) && has_op(level, Duplicate) {
    game.selected_op = Duplicate
  }
  if @raylib.is_key_pressed(@raylib.KeyFour) && has_op(level, Invert) {
    game.selected_op = Invert
  }
  if @raylib.is_key_pressed(@raylib.KeyFive) && has_op(level, Delete) {
    game.selected_op = Delete
  }
  // Cycle insert base with Tab
  if @raylib.is_key_pressed(@raylib.KeyTab) {
    game.insert_base = next_base(game.insert_base)
  }
  // Apply operation with Enter
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    if game.confirm_verify {
      verify_sequence(game)
      game.confirm_verify = false
    } else {
      apply_operation(game, level)
    }
  }
  // Verify with V
  if @raylib.is_key_pressed(@raylib.KeyV) {
    verify_sequence(game)
  }
}

///|
fn has_op(level : @types.Level, op : @types.OpKind) -> Bool {
  for i in 0..<level.available_ops.length() {
    if level.available_ops[i] == op {
      return true
    }
  }
  false
}

///|
fn next_base(b : @types.Base) -> @types.Base {
  match b {
    A => T
    T => G
    G => C
    C => A
  }
}

///|
fn apply_operation(game : @types.Game, level : @types.Level) -> Unit {
  let seq = game.current_sequence
  if game.edit_count >= level.edit_budget {
    @types.set_message(game, "Edit budget exhausted!", 1.5)
    return
  }
  match game.selected_op {
    Cut => {
      if game.cursor < 0 || game.cursor >= seq.length() {
        @types.set_message(game, "Invalid cursor position for Cut", 1.0)
        return
      }
      let removed_base = seq[game.cursor]
      let edit : @types.EditOp = {
        kind: Cut,
        position: game.cursor,
        range_start: game.cursor,
        range_end: game.cursor + 1,
        insert_base: A,
        removed: [removed_base],
      }
      game.current_sequence = @dna.cut(seq, game.cursor)
      game.ops_history.push(edit)
      game.edit_count += 1
      @types.clamp_cursor(game)
      @types.clear_selection(game)
    }
    Insert => {
      let edit : @types.EditOp = {
        kind: Insert,
        position: game.cursor,
        range_start: game.cursor,
        range_end: game.cursor,
        insert_base: game.insert_base,
        removed: [],
      }
      game.current_sequence = @dna.insert(seq, game.cursor, game.insert_base)
      game.ops_history.push(edit)
      game.edit_count += 1
      game.cursor += 1
      @types.clamp_cursor(game)
      @types.clear_selection(game)
    }
    Duplicate => {
      if !@types.has_selection(game) {
        @types.set_message(game, "Select a range first (Shift+Arrow)", 1.5)
        return
      }
      let s = @types.selection_min(game)
      let e = @types.selection_max(game)
      let removed = @dna.get_removed(seq, s, e)
      let edit : @types.EditOp = {
        kind: Duplicate,
        position: e,
        range_start: s,
        range_end: e,
        insert_base: A,
        removed,
      }
      game.current_sequence = @dna.duplicate(seq, s, e)
      game.ops_history.push(edit)
      game.edit_count += 1
      @types.clear_selection(game)
    }
    Invert => {
      if !@types.has_selection(game) {
        @types.set_message(game, "Select a range first (Shift+Arrow)", 1.5)
        return
      }
      let s = @types.selection_min(game)
      let e = @types.selection_max(game)
      let removed = @dna.get_removed(seq, s, e)
      let edit : @types.EditOp = {
        kind: Invert,
        position: s,
        range_start: s,
        range_end: e,
        insert_base: A,
        removed,
      }
      game.current_sequence = @dna.invert(seq, s, e)
      game.ops_history.push(edit)
      game.edit_count += 1
      @types.clear_selection(game)
    }
    Delete => {
      if !@types.has_selection(game) {
        @types.set_message(game, "Select a range first (Shift+Arrow)", 1.5)
        return
      }
      let s = @types.selection_min(game)
      let e = @types.selection_max(game)
      let removed = @dna.get_removed(seq, s, e)
      let edit : @types.EditOp = {
        kind: Delete,
        position: s,
        range_start: s,
        range_end: e,
        insert_base: A,
        removed,
      }
      game.current_sequence = @dna.delete(seq, s, e)
      game.ops_history.push(edit)
      game.edit_count += 1
      game.cursor = s
      @types.clamp_cursor(game)
      @types.clear_selection(game)
    }
  }
}

///|
fn undo_last(game : @types.Game) -> Unit {
  if game.ops_history.length() == 0 {
    return
  }
  let last = game.ops_history.pop()
  match last {
    Some(edit) => {
      match edit.kind {
        Cut => {
          // Re-insert the removed base
          game.current_sequence = @dna.insert(
            game.current_sequence,
            edit.position,
            edit.removed[0],
          )
          game.cursor = edit.position
        }
        Insert => {
          // Remove the inserted base
          game.current_sequence = @dna.cut(
            game.current_sequence,
            edit.position,
          )
          game.cursor = edit.position
        }
        Duplicate => {
          // Remove the duplicated range
          let dup_len = edit.range_end - edit.range_start
          game.current_sequence = @dna.delete(
            game.current_sequence,
            edit.range_end,
            edit.range_end + dup_len,
          )
        }
        Invert => {
          // Invert again to restore
          game.current_sequence = @dna.invert(
            game.current_sequence,
            edit.range_start,
            edit.range_end,
          )
        }
        Delete => {
          // Re-insert the deleted bases
          let mut pos = edit.position
          for i in 0..<edit.removed.length() {
            game.current_sequence = @dna.insert(
              game.current_sequence,
              pos,
              edit.removed[i],
            )
            pos += 1
          }
          game.cursor = edit.position
        }
      }
      game.edit_count -= 1
      @types.clamp_cursor(game)
      @types.clear_selection(game)
      @types.set_message(game, "Undo", 0.5)
    }
    None => ()
  }
}

///|
fn verify_sequence(game : @types.Game) -> Unit {
  let level_idx = @types.tier_level_offset(game.current_tier) +
    game.current_level
  let level = @levels.get_level(level_idx)
  let (produced, matched) = @dna.read_and_compare(
    game.current_sequence,
    level.target_traits,
  )
  if matched {
    game.play_state = Verified
    let stars = @types.compute_stars(
      game.edit_count,
      level.par_edits,
      level.min_edits,
    )
    let score = game.level_scores[level_idx]
    score.completed = true
    if stars > score.stars {
      score.stars = stars
    }
    if game.edit_count < score.best_edits {
      score.best_edits = game.edit_count
    }
    game.screen = Results
  } else {
    game.play_state = Failed
    let match_count = @dna.count_matching_traits(produced, level.target_traits)
    let total = level.target_traits.length()
    @types.set_message(
      game,
      match_count.to_string() + "/" + total.to_string() + " traits match. Keep editing!",
      2.0,
    )
    // Reset to editing so player can continue
    game.play_state = Editing
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) || @raylib.is_key_pressed(
      @raylib.KeySpace,
    ) {
    // Go to next level or back to level select
    let count = @types.tier_level_count(game.current_tier)
    if game.current_level + 1 < count {
      game.current_level += 1
      start_level(game)
    } else {
      game.screen = LevelSelect
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}
