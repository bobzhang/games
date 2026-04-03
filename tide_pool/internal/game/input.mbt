///|
pub fn handle_title_input(game : @types.Game) -> Unit {
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let btn_x = @types.screen_width / 2 - 80
    let btn_y = 460
    if mx >= btn_x && mx < btn_x + 160 && my >= btn_y && my < btn_y + 45 {
      game.screen = LevelSelect
    }
  }
}

///|
pub fn handle_level_select_input(game : @types.Game) -> Unit {
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let cols = 5
    let btn_w = 200
    let btn_h = 70
    let gap = 12
    let start_x = (@types.screen_width - cols * (btn_w + gap)) / 2
    let start_y = 80
    for i in 0..<@types.total_levels {
      let row = i / cols
      let col = i % cols
      let x = start_x + col * (btn_w + gap)
      let y = start_y + row * (btn_h + gap)
      if mx >= x && mx < x + btn_w && my >= y && my < y + btn_h {
        if @types.is_level_unlocked(game.scores, i) {
          game.selected_level = i
          @levels.setup_level(game, i)
          game.screen = Playing
          return
        }
      }
    }
    let back_x = @types.screen_width / 2 - 60
    let back_y = @types.screen_height - 50
    if mx >= back_x && mx < back_x + 120 && my >= back_y && my < back_y + 36 {
      game.screen = Title
    }
  }
}

///|
pub fn handle_playing_input(game : @types.Game) -> Unit {
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  let grid_col = (mx - ox) / cs
  let grid_row = (my - oy) / cs
  if mx >= ox &&
    mx < ox + @types.grid_cols * cs &&
    my >= oy &&
    my < oy + @types.grid_rows * cs {
    game.hover_row = grid_row
    game.hover_col = grid_col
  } else {
    game.hover_row = -1
    game.hover_col = -1
  }
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    handle_playing_click(game, mx, my)
  }
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
    if game.hover_row >= 0 && game.hover_col >= 0 {
      remove_organism(game, game.hover_row, game.hover_col)
    }
  }
}

///|
fn handle_playing_click(game : @types.Game, mx : Int, my : Int) -> Unit {
  let btn_y = @types.screen_height - 56
  if mx >= 40 && mx < 180 && my >= btn_y && my < btn_y + 40 {
    start_simulation(game)
    return
  }
  if mx >= 200 && mx < 300 && my >= btn_y && my < btn_y + 40 {
    match game.current_level {
      Some(_) => @levels.setup_level(game, game.selected_level)
      None => ()
    }
    return
  }
  if mx >= 320 && mx < 420 && my >= btn_y && my < btn_y + 40 {
    game.screen = LevelSelect
    return
  }
  handle_palette_click(game, mx, my)
  handle_grid_click(game, mx, my)
}

///|
fn handle_palette_click(game : @types.Game, mx : Int, my : Int) -> Unit {
  match game.current_level {
    None => ()
    Some(level) => {
      let px = @types.palette_x
      let py = @types.palette_y
      let ss = @types.palette_slot_size
      let gap = @types.palette_gap
      for i in 0..<level.available_organisms.length() {
        let sx = px
        let sy = py + i * (ss + gap)
        if mx >= sx && mx < sx + ss && my >= sy && my < sy + ss {
          let kind = level.available_organisms[i]
          let is_already = match game.selected_organism {
            Some(sel) => sel == kind
            None => false
          }
          if is_already {
            game.selected_organism = None
          } else {
            game.selected_organism = Some(kind)
          }
          return
        }
      }
    }
  }
}

///|
fn handle_grid_click(game : @types.Game, mx : Int, my : Int) -> Unit {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  if mx < ox ||
    mx >= ox + @types.grid_cols * cs ||
    my < oy ||
    my >= oy + @types.grid_rows * cs {
    return
  }
  let col = (mx - ox) / cs
  let row = (my - oy) / cs
  match game.selected_organism {
    None => ()
    Some(kind) => place_organism(game, kind, row, col)
  }
}

///|
fn place_organism(
  game : @types.Game,
  kind : @types.OrganismKind,
  row : Int,
  col : Int,
) -> Unit {
  if !@types.in_grid(row, col) {
    return
  }
  match game.grid[row][col] {
    Empty => ()
    _ => {
      set_message(game, "Cell is occupied!")
      return
    }
  }
  let avail = @types.get_available_count(game, kind)
  if avail <= 0 {
    set_message(game, "No more available!")
    return
  }
  game.grid[row][col] = Organism(kind)
  let idx = @types.organism_index(kind)
  game.organisms_placed[idx] = game.organisms_placed[idx] + 1
  game.organisms.push({
    kind,
    row,
    col,
    alive: true,
    health: @types.max_health,
    submerged: false,
  })
  let profile = @types.get_profile(kind)
  set_message(game, "\{profile.name} placed at (\{row},\{col})")
}

///|
fn remove_organism(game : @types.Game, row : Int, col : Int) -> Unit {
  match game.grid[row][col] {
    Organism(kind) => {
      game.grid[row][col] = Empty
      let idx = @types.organism_index(kind)
      game.organisms_placed[idx] = if game.organisms_placed[idx] > 0 {
        game.organisms_placed[idx] - 1
      } else {
        0
      }
      let new_organisms : Array[@types.OrganismState] = []
      for i in 0..<game.organisms.length() {
        let org = game.organisms[i]
        if !(org.row == row && org.col == col) {
          new_organisms.push(org)
        }
      }
      game.organisms = new_organisms
      let profile = @types.get_profile(kind)
      set_message(game, "\{profile.name} removed from (\{row},\{col})")
    }
    _ => ()
  }
}

///|
fn start_simulation(game : @types.Game) -> Unit {
  if game.organisms.length() == 0 {
    set_message(game, "Place some organisms first!")
    return
  }
  game.screen = Simulating
  game.current_turn = 0
  game.current_cycle = 0
  game.tide_level = 1
  game.tide_phase = Low
  game.sim_log = []
  game.sim_speed_timer = 0.0
  game.play_result = None
  for i in 0..<game.organisms.length() {
    game.organisms[i].health = @types.max_health
    game.organisms[i].alive = true
  }
}

///|
pub fn handle_results_input(game : @types.Game) -> Unit {
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let btn_y = @types.screen_height - 60
    if mx >= @types.screen_width / 2 - 180 &&
      mx < @types.screen_width / 2 - 180 + 140 &&
      my >= btn_y &&
      my < btn_y + 40 {
      @levels.setup_level(game, game.selected_level)
      game.screen = Playing
      return
    }
    if mx >= @types.screen_width / 2 + 40 &&
      mx < @types.screen_width / 2 + 40 + 140 &&
      my >= btn_y &&
      my < btn_y + 40 {
      game.screen = LevelSelect
    }
  }
}

///|
fn set_message(game : @types.Game, msg : String) -> Unit {
  game.message = msg
  game.message_timer = 2.0
}
