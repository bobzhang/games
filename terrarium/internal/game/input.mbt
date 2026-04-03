///|
pub fn handle_title_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_mouse_button_pressed(0) {
    let cx = @types.screen_width / 2
    let btn_w = 160
    let btn_h = 50
    let btn_x = cx - btn_w / 2
    let btn_y = 520
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    if @raylib.is_key_pressed(@raylib.KeyEnter) ||
      (mx >= btn_x && mx <= btn_x + btn_w && my >= btn_y && my <= btn_y + btn_h) {
      game.screen = LevelSelect
    }
  }
}

///|
pub fn handle_level_select_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
    return
  }
  if @raylib.is_mouse_button_pressed(0) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let tier_starts = [0, 7, 14]
    let tier_counts = [7, 7, 6]
    for t in 0..<3 {
      let ty = 80 + t * 210
      for i in 0..<tier_counts[t] {
        let level_id = tier_starts[t] + i
        let bx = 40 + i * 170
        let by = ty + 30
        let bw = 155
        let bh = 155
        if mx >= bx && mx <= bx + bw && my >= by && my <= by + bh {
          if @types.is_level_unlocked(game.scores, level_id) {
            game.selected_level = level_id
            start_level(game, level_id)
            return
          }
        }
      }
    }
  }
}

///|
pub fn handle_playing_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    match game.current_level {
      Some(level) => start_level(game, level.id)
      _ => ()
    }
    return
  }
  if @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.organisms.length() > 0 {
      start_simulation(game)
    } else {
      game.message = "Place some organisms first!"
      game.message_timer = 2.0
    }
    return
  }
  update_hover(game)
  handle_palette_click(game)
  handle_grid_click(game)
}

///|
fn update_hover(game : @types.Game) -> Unit {
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let gx = mx - @types.grid_offset_x
  let gy = my - @types.grid_offset_y
  if gx >= 0 &&
    gx < @types.grid_size * @types.cell_size &&
    gy >= 0 &&
    gy < @types.grid_size * @types.cell_size {
    game.hover_col = gx / @types.cell_size
    game.hover_row = gy / @types.cell_size
  } else {
    game.hover_row = -1
    game.hover_col = -1
  }
}

///|
fn handle_palette_click(game : @types.Game) -> Unit {
  if !@raylib.is_mouse_button_pressed(0) {
    return
  }
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  match game.current_level {
    None => ()
    Some(level) => {
      let x = @types.palette_x
      let y = @types.palette_y
      for i in 0..<level.available_organisms.length() {
        let kind = level.available_organisms[i]
        let slot_y = y + i * (@types.palette_slot_size + @types.palette_gap)
        if mx >= x &&
          mx <= x + @types.palette_slot_size &&
          my >= slot_y &&
          my <= slot_y + @types.palette_slot_size {
          if game.selected_organism == Some(kind) {
            game.selected_organism = None
          } else {
            let avail = @types.get_available_count(game, kind)
            if avail > 0 {
              game.selected_organism = Some(kind)
            } else {
              game.message = "No more of this organism available!"
              game.message_timer = 1.5
            }
          }
          return
        }
      }
    }
  }
}

///|
fn handle_grid_click(game : @types.Game) -> Unit {
  if game.hover_row < 0 || game.hover_col < 0 {
    return
  }
  let r = game.hover_row
  let c = game.hover_col
  match game.current_level {
    None => return
    Some(level) => if @types.is_cell_locked(level, r, c) { return }
  }
  if @raylib.is_mouse_button_pressed(0) {
    match game.selected_organism {
      None => ()
      Some(kind) =>
        if game.grid[r][c] == Empty {
          let avail = @types.get_available_count(game, kind)
          if avail > 0 {
            game.grid[r][c] = Organism(kind)
            let idx = @types.organism_index(kind)
            game.organisms_placed[idx] += 1
            game.organisms.push({
              kind,
              row: r,
              col: c,
              alive: true,
              health: 100.0,
            })
          } else {
            game.message = "No more available!"
            game.message_timer = 1.5
          }
        }
    }
  }
  if @raylib.is_mouse_button_pressed(1) {
    match game.grid[r][c] {
      Organism(kind) => {
        game.grid[r][c] = Empty
        let idx = @types.organism_index(kind)
        if game.organisms_placed[idx] > 0 {
          game.organisms_placed[idx] -= 1
        }
        let new_orgs : Array[@types.OrganismState] = []
        for i in 0..<game.organisms.length() {
          let org = game.organisms[i]
          if !(org.row == r && org.col == c) {
            new_orgs.push(org)
          }
        }
        game.organisms = new_orgs
      }
      _ => ()
    }
  }
}

///|
pub fn handle_simulating_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    finish_simulation(game)
  }
}

///|
pub fn handle_results_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  if @raylib.is_mouse_button_pressed(0) {
    let cx = @types.screen_width / 2
    let btn_w = 140
    let btn_h = 40
    let retry_x = cx - btn_w - 20
    let next_x = cx + 20
    let btn_y = 200 + 320 - 70
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    if mx >= retry_x &&
      mx <= retry_x + btn_w &&
      my >= btn_y &&
      my <= btn_y + btn_h {
      match game.current_level {
        Some(level) => start_level(game, level.id)
        _ => ()
      }
      return
    }
    if game.play_result == Victory {
      if mx >= next_x &&
        mx <= next_x + btn_w &&
        my >= btn_y &&
        my <= btn_y + btn_h {
        let next_id = game.selected_level + 1
        if next_id < @types.total_levels &&
          @types.is_level_unlocked(game.scores, next_id) {
          start_level(game, next_id)
        } else {
          game.screen = LevelSelect
        }
        return
      }
    }
  }
}
