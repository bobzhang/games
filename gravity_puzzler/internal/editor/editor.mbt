///|
let white : @raylib.Color = @raylib.Color::new(255, 255, 255, 255)

///|
let light_gray : @raylib.Color = @raylib.Color::new(200, 200, 200, 255)

///|
let dark_gray : @raylib.Color = @raylib.Color::new(40, 40, 40, 255)

///|
let cursor_color : @raylib.Color = @raylib.Color::new(255, 255, 0, 180)

///|
let panel_bg : @raylib.Color = @raylib.Color::new(30, 30, 40, 230)

///|
/// Initialize the editor with default grid
pub fn init_editor(game : @types.Game) -> Unit {
  let ed = game.editor
  ed.active = true
  ed.cursor_x = 0
  ed.cursor_y = 0
  ed.selected_tile = 0
  ed.selected_entity = -1
  ed.mode = 0
  ed.grid_w = 10
  ed.grid_h = 8
  ed.tiles = Array::make(ed.grid_w * ed.grid_h, Empty)
  ed.entities = []
  ed.test_playing = false
  ed.gravity = Down
  // Fill border with walls
  for y in 0..<ed.grid_h {
    for x in 0..<ed.grid_w {
      if x == 0 || x == ed.grid_w - 1 || y == 0 || y == ed.grid_h - 1 {
        ed.tiles[y * ed.grid_w + x] = Wall
      }
    }
  }
}

///|
/// Update editor state
pub fn update_editor(game : @types.Game) -> Unit {
  let ed = game.editor
  if !ed.active {
    return
  }
  // Test play mode
  if ed.test_playing {
    if @raylib.is_key_pressed(@raylib.KeyEscape) {
      ed.test_playing = false
      game.screen = Editor
    }
    return
  }
  // Exit editor
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    ed.active = false
    game.screen = Title
    return
  }
  // Move cursor
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    if ed.cursor_x > 0 {
      ed.cursor_x = ed.cursor_x - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    if ed.cursor_x < ed.grid_w - 1 {
      ed.cursor_x = ed.cursor_x + 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    if ed.cursor_y > 0 {
      ed.cursor_y = ed.cursor_y - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    if ed.cursor_y < ed.grid_h - 1 {
      ed.cursor_y = ed.cursor_y + 1
    }
  }
  // Toggle mode: tile placement (0) vs entity placement (1)
  if @raylib.is_key_pressed(@raylib.KeyTab) {
    ed.mode = if ed.mode == 0 { 1 } else { 0 }
  }
  // Cycle through tile types with [ and ]
  if @raylib.is_key_pressed(@raylib.KeyLeftBracket) {
    if ed.mode == 0 {
      ed.selected_tile = if ed.selected_tile > 0 {
        ed.selected_tile - 1
      } else {
        @types.editor_tile_count - 1
      }
    } else {
      ed.selected_entity = if ed.selected_entity > 0 {
        ed.selected_entity - 1
      } else {
        @types.editor_entity_count - 1
      }
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyRightBracket) {
    if ed.mode == 0 {
      ed.selected_tile = (ed.selected_tile + 1) % @types.editor_tile_count
    } else {
      ed.selected_entity = (ed.selected_entity + 1) % @types.editor_entity_count
    }
  }
  // Place tile/entity with Enter or Space
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if ed.mode == 0 {
      // Place tile
      let tile = @types.tile_from_index(ed.selected_tile)
      let idx = ed.cursor_y * ed.grid_w + ed.cursor_x
      if idx >= 0 && idx < ed.tiles.length() {
        ed.tiles[idx] = tile
      }
    } else {
      // Place entity
      let kind = @types.entity_kind_from_index(ed.selected_entity)
      let eid = ed.entities.length()
      // Remove any entity at this position first
      remove_entity_at(ed, ed.cursor_x, ed.cursor_y)
      ed.entities.push(@types.Entity::new(eid, kind, ed.cursor_x, ed.cursor_y))
    }
  }
  // Delete tile/entity with D or Backspace
  if @raylib.is_key_pressed(@raylib.KeyD) ||
    @raylib.is_key_pressed(@raylib.KeyBackspace) {
    if ed.mode == 0 {
      let idx = ed.cursor_y * ed.grid_w + ed.cursor_x
      if idx >= 0 && idx < ed.tiles.length() {
        ed.tiles[idx] = Empty
      }
    } else {
      remove_entity_at(ed, ed.cursor_x, ed.cursor_y)
    }
  }
  // Cycle gravity direction with G
  if @raylib.is_key_pressed(@raylib.KeyG) {
    ed.gravity = @types.rotate_gravity_cw(ed.gravity)
  }
  // Test play with T
  if @raylib.is_key_pressed(@raylib.KeyT) {
    test_play_editor_level(game)
  }
  // Save/encode level with S
  if @raylib.is_key_pressed(@raylib.KeyS) {
    let encoded = encode_editor_level(ed)
    game.message_text = "Level encoded: " +
      encoded.length().to_string() +
      " chars"
    game.message_timer = @types.message_duration
  }
}

///|
fn remove_entity_at(ed : @types.EditorState, x : Int, y : Int) -> Unit {
  let mut i = 0
  while i < ed.entities.length() {
    let e = ed.entities[i]
    if e.x == x && e.y == y {
      // Remove by swapping with last
      let last = ed.entities.length() - 1
      if i < last {
        ed.entities[i] = ed.entities[last]
      }
      ignore(ed.entities.pop())
      continue
    }
    i = i + 1
  }
}

///|
/// Convert editor state to a playable level for testing
fn test_play_editor_level(game : @types.Game) -> Unit {
  let ed = game.editor
  // Check if there's a player
  let mut has_player = false
  for i in 0..<ed.entities.length() {
    if ed.entities[i].kind == Player {
      has_player = true
    }
  }
  if !has_player {
    game.message_text = "Place a Player (P) first!"
    game.message_timer = @types.message_duration
    return
  }
  // Build level from editor state
  let tiles_copy : Array[@types.TileKind] = Array::make(
    ed.tiles.length(),
    Empty,
  )
  for i in 0..<ed.tiles.length() {
    tiles_copy[i] = ed.tiles[i]
  }
  let entities_copy : Array[@types.Entity] = []
  let mut gems_total = 0
  for i in 0..<ed.entities.length() {
    let e = ed.entities[i]
    entities_copy.push(@types.Entity::new(i, e.kind, e.x, e.y))
    if e.kind == Gem {
      gems_total = gems_total + 1
    }
  }
  let level : @types.Level = {
    width: ed.grid_w,
    height: ed.grid_h,
    tiles: tiles_copy,
    entities: entities_copy,
    gravity: ed.gravity,
    moves: 0,
    gems_collected: 0,
    gems_total,
    keys_collected: 0,
    par_moves: 10,
    world: 0,
    level_num: 0,
    name: "Custom Level",
    completed: false,
    player_dead: false,
  }
  game.level = Some(level)
  game.undo_stack = []
  game.settling = false
  game.settle_timer = 0.0
  ed.test_playing = true
  game.screen = Playing
  ignore(@physics.settle_all(level))
}

///|
/// Draw the editor UI
pub fn draw_editor(game : @types.Game) -> Unit {
  let ed = game.editor
  if !ed.active {
    return
  }
  @raylib.clear_background(dark_gray)
  // Draw grid
  let floor_color = @raylib.Color::new(60, 60, 70, 255)
  let wall_color = @raylib.Color::new(140, 130, 120, 255)
  for y in 0..<ed.grid_h {
    for x in 0..<ed.grid_w {
      let px = @types.grid_offset_x + x * @types.tile_size
      let py = @types.grid_offset_y + y * @types.tile_size
      let idx = y * ed.grid_w + x
      let tile = if idx < ed.tiles.length() { ed.tiles[idx] } else { Empty }
      let color = match tile {
        Wall => wall_color
        Exit => @types.color_exit
        Spike => @types.color_spike
        Ice => @types.color_ice
        Portal(_) => @types.color_portal
        Switch(_) => @types.color_switch
        Gate(_) => @types.color_gate
        Crumble => @types.color_crumble
        Conveyor(_) => @types.color_conveyor
        PressurePlate(_) => @types.color_pressure_plate
        Mirror(_) => @types.color_mirror
        GravityWell => @types.color_gravity_well
        TimedLava => @types.color_timed_lava
        WindGust(_) => @types.color_wind_gust
        Empty => floor_color
      }
      @raylib.draw_rectangle(px, py, @types.tile_size, @types.tile_size, color)
      @raylib.draw_rectangle_lines(
        px,
        py,
        @types.tile_size,
        @types.tile_size,
        @raylib.Color::new(50, 50, 50, 100),
      )
    }
  }
  // Draw entities
  for i in 0..<ed.entities.length() {
    let e = ed.entities[i]
    let px = @types.grid_offset_x + e.x * @types.tile_size
    let py = @types.grid_offset_y + e.y * @types.tile_size
    let cx = Float::from_int(px) + @types.tile_sizef * 0.5
    let cy = Float::from_int(py) + @types.tile_sizef * 0.5
    let color = match e.kind {
      Player => @types.color_player
      Box => @types.color_box
      Boulder => @types.color_boulder
      Key => @types.color_key
      Gem => @types.color_gem
      Enemy => @types.color_enemy
    }
    @raylib.draw_circle(cx.to_int(), cy.to_int(), 14.0, color)
    let label = match e.kind {
      Player => "P"
      Box => "B"
      Boulder => "R"
      Key => "K"
      Gem => "G"
      Enemy => "N"
    }
    @draw.draw_text(label, cx.to_int() - 5, cy.to_int() - 8, 16, white)
  }
  // Draw cursor
  let cpx = @types.grid_offset_x + ed.cursor_x * @types.tile_size
  let cpy = @types.grid_offset_y + ed.cursor_y * @types.tile_size
  @raylib.draw_rectangle_lines(
    cpx, cpy, @types.tile_size, @types.tile_size, cursor_color,
  )
  @raylib.draw_rectangle_lines(
    cpx + 1,
    cpy + 1,
    @types.tile_size - 2,
    @types.tile_size - 2,
    cursor_color,
  )
  // Draw panel
  draw_editor_panel(ed)
  // Draw controls help
  @draw.draw_text("LEVEL EDITOR", 360, 10, 24, white)
  @draw.draw_text(
    "Arrows:Move  Tab:Mode  [/]:Cycle  Enter:Place  D:Delete",
    100,
    @types.screen_h - 50,
    14,
    light_gray,
  )
  @draw.draw_text(
    "T:Test  G:Gravity  S:Save  ESC:Exit",
    240,
    @types.screen_h - 28,
    14,
    light_gray,
  )
  // Show message if any
  if game.message_timer > 0.0 {
    @draw.draw_text(game.message_text, 300, 350, 20, white)
  }
}

///|
fn draw_editor_panel(ed : @types.EditorState) -> Unit {
  // Right side panel showing current selection
  let panel_x = 700
  let panel_y = 80
  let panel_w = 240
  let panel_h = 500
  @raylib.draw_rectangle(panel_x, panel_y, panel_w, panel_h, panel_bg)
  @raylib.draw_rectangle_lines(panel_x, panel_y, panel_w, panel_h, light_gray)
  let mode_text = if ed.mode == 0 { "Mode: TILES" } else { "Mode: ENTITIES" }
  @draw.draw_text(mode_text, panel_x + 10, panel_y + 10, 18, white)
  if ed.mode == 0 {
    // Show tile types
    let tile_names = [
      "Empty", "Wall", "Exit", "Spike", "Ice", "Portal 1", "Portal 2", "Switch",
      "Gate", "Crumble", "Conveyor", "Pressure", "Mirror", "Grav Well", "Lava",
    ]
    for i in 0..<tile_names.length() {
      let ty = panel_y + 40 + i * 22
      let selected = i == ed.selected_tile
      let color = if selected {
        @raylib.Color::new(255, 255, 100, 255)
      } else {
        light_gray
      }
      let prefix = if selected { "> " } else { "  " }
      @draw.draw_text(prefix + tile_names[i], panel_x + 10, ty, 14, color)
    }
  } else {
    // Show entity types
    let entity_names = ["Player", "Box", "Boulder", "Key", "Gem", "Enemy"]
    for i in 0..<entity_names.length() {
      let ty = panel_y + 40 + i * 22
      let selected = i == ed.selected_entity
      let color = if selected {
        @raylib.Color::new(255, 255, 100, 255)
      } else {
        light_gray
      }
      let prefix = if selected { "> " } else { "  " }
      @draw.draw_text(prefix + entity_names[i], panel_x + 10, ty, 14, color)
    }
  }
  // Show gravity direction
  let grav_text = match ed.gravity {
    Down => "Gravity: DOWN"
    Up => "Gravity: UP"
    Left => "Gravity: LEFT"
    Right => "Gravity: RIGHT"
  }
  @draw.draw_text(
    grav_text,
    panel_x + 10,
    panel_y + panel_h - 60,
    16,
    light_gray,
  )
  // Show cursor position
  let pos_text = "Cursor: " +
    ed.cursor_x.to_string() +
    "," +
    ed.cursor_y.to_string()
  @draw.draw_text(
    pos_text,
    panel_x + 10,
    panel_y + panel_h - 35,
    14,
    light_gray,
  )
}

///|
/// Encode the editor level as a string for saving/sharing
pub fn encode_editor_level(ed : @types.EditorState) -> String {
  let buf = StringBuilder::new()
  // Header: width,height,gravity
  buf.write_string(ed.grid_w.to_string())
  buf.write_char('x')
  buf.write_string(ed.grid_h.to_string())
  buf.write_char(':')
  let grav_ch = match ed.gravity {
    Down => 'D'
    Up => 'U'
    Left => 'L'
    Right => 'R'
  }
  buf.write_char(grav_ch)
  buf.write_char('\n')
  // Grid data: one char per tile
  for y in 0..<ed.grid_h {
    for x in 0..<ed.grid_w {
      let idx = y * ed.grid_w + x
      let tile = if idx < ed.tiles.length() { ed.tiles[idx] } else { Empty }
      // Check for entity at this position
      let mut entity_ch : Char = '\u0000'
      for i in 0..<ed.entities.length() {
        let e = ed.entities[i]
        if e.x == x && e.y == y {
          entity_ch = match e.kind {
            Player => 'P'
            Box => 'B'
            Boulder => 'R'
            Key => 'K'
            Gem => 'G'
            Enemy => 'N'
          }
        }
      }
      if entity_ch != '\u0000' {
        buf.write_char(entity_ch)
      } else {
        let ch = match tile {
          Wall => '#'
          Exit => 'E'
          Spike => 'S'
          Ice => 'I'
          Portal(1) => '1'
          Portal(2) => '2'
          Portal(_) => '3'
          Switch(1) => 'W'
          Switch(_) => 'X'
          Gate(1) => 'D'
          Gate(_) => 'F'
          Crumble => 'C'
          Conveyor(Right) => '>'
          Conveyor(Left) => '<'
          Conveyor(Up) => '^'
          Conveyor(Down) => 'v'
          PressurePlate(_) => 'p'
          Mirror(1) => '/'
          Mirror(_) => '\\'
          GravityWell => 'O'
          TimedLava => 'L'
          WindGust(_) => '~'
          Empty => '.'
        }
        buf.write_char(ch)
      }
    }
    buf.write_char('\n')
  }
  buf.to_string()
}

///|
/// Decode a saved level string and populate the editor
pub fn decode_editor_level(ed : @types.EditorState, data : String) -> Bool {
  if data.length() < 5 {
    return false
  }
  // Parse header line: WxH:G
  let lines = split_lines_ed(data)
  if lines.length() < 2 {
    return false
  }
  let header = lines[0]
  // Find 'x' separator
  let mut x_pos = -1
  let mut colon_pos = -1
  for i in 0..<header.length() {
    let ch = Int::unsafe_to_char(header[i].to_int())
    if ch == 'x' && x_pos < 0 {
      x_pos = i
    }
    if ch == ':' {
      colon_pos = i
    }
  }
  if x_pos < 0 || colon_pos < 0 {
    return false
  }
  // Parse dimensions (simple integer parsing)
  let w = parse_int_ed(header, 0, x_pos)
  let h = parse_int_ed(header, x_pos + 1, colon_pos)
  if w <= 0 || h <= 0 || w > @types.grid_max_w || h > @types.grid_max_h {
    return false
  }
  // Parse gravity
  if colon_pos + 1 < header.length() {
    let g_ch = Int::unsafe_to_char(header[colon_pos + 1].to_int())
    ed.gravity = match g_ch {
      'U' => Up
      'L' => Left
      'R' => Right
      _ => Down
    }
  }
  ed.grid_w = w
  ed.grid_h = h
  ed.tiles = Array::make(w * h, Empty)
  ed.entities = []
  // Parse grid rows
  let mut next_id = 0
  for row in 1..<lines.length() {
    let y = row - 1
    if y >= h {
      break
    }
    let line = lines[row]
    for x in 0..<line.length() {
      if x >= w {
        break
      }
      let ch = Int::unsafe_to_char(line[x].to_int())
      let idx = y * w + x
      match ch {
        '#' => ed.tiles[idx] = Wall
        'E' => ed.tiles[idx] = Exit
        'S' => ed.tiles[idx] = Spike
        'I' => ed.tiles[idx] = Ice
        'C' => ed.tiles[idx] = Crumble
        '1' => ed.tiles[idx] = Portal(1)
        '2' => ed.tiles[idx] = Portal(2)
        'W' => ed.tiles[idx] = Switch(1)
        'D' => ed.tiles[idx] = Gate(1)
        'P' => {
          ed.entities.push(@types.Entity::new(next_id, Player, x, y))
          next_id = next_id + 1
        }
        'B' => {
          ed.entities.push(@types.Entity::new(next_id, Box, x, y))
          next_id = next_id + 1
        }
        'R' => {
          ed.entities.push(@types.Entity::new(next_id, Boulder, x, y))
          next_id = next_id + 1
        }
        'K' => {
          ed.entities.push(@types.Entity::new(next_id, Key, x, y))
          next_id = next_id + 1
        }
        'G' => {
          ed.entities.push(@types.Entity::new(next_id, Gem, x, y))
          next_id = next_id + 1
        }
        'N' => {
          ed.entities.push(@types.Entity::new(next_id, Enemy, x, y))
          next_id = next_id + 1
        }
        _ => ()
      }
    }
  }
  true
}

///|
fn split_lines_ed(s : String) -> Array[String] {
  let lines : Array[String] = []
  let buf = StringBuilder::new()
  for i in 0..<s.length() {
    let ch = Int::unsafe_to_char(s[i].to_int())
    if ch == '\n' {
      lines.push(buf.to_string())
      buf.reset()
    } else if ch == '\r' {
      ()
    } else {
      buf.write_char(ch)
    }
  }
  let last = buf.to_string()
  if last.length() > 0 {
    lines.push(last)
  }
  lines
}

///|
fn parse_int_ed(s : String, start : Int, end_pos : Int) -> Int {
  let mut result = 0
  for i in start..<end_pos {
    if i < s.length() {
      let d = s[i].to_int() - 48
      if d >= 0 && d <= 9 {
        result = result * 10 + d
      }
    }
  }
  result
}
