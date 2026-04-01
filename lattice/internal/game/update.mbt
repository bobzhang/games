///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count = game.frame_count + 1
  let dt = @types.minf(@raylib.get_frame_time(), 0.05)
  // Update animations
  update_anims(game, dt)
  match game.screen {
    Title => update_title(game)
    ModeSelect => update_mode_select(game)
    DifficultySelect => update_difficulty_select(game)
    Playing => update_playing(game, dt)
    PuzzleSelect => update_puzzle_select(game)
    Results => update_results(game)
  }
}

///|
fn update_anims(game : @types.Game, dt : Float) -> Unit {
  // Update capture animations
  let new_cap_anims : Array[@types.CaptureAnim] = []
  for i in 0..<game.capture_anims.length() {
    let anim = game.capture_anims[i]
    anim.timer = anim.timer + dt
    if anim.timer < @types.capture_anim_time {
      new_cap_anims.push(anim)
    }
  }
  game.capture_anims = new_cap_anims
  // Update pattern animations
  let new_pat_anims : Array[@types.PatternAnim] = []
  for i in 0..<game.pattern_anims.length() {
    let anim = game.pattern_anims[i]
    anim.timer = anim.timer - dt
    if anim.timer > 0.0 {
      new_pat_anims.push(anim)
    }
  }
  game.pattern_anims = new_pat_anims
  // Update score animations (floating text)
  let new_score_anims : Array[@types.ScoreAnim] = []
  for i in 0..<game.score_anims.length() {
    let anim = game.score_anims[i]
    anim.timer = anim.timer - dt
    anim.y = anim.y - 30.0 * dt // float upward
    if anim.timer > 0.0 {
      new_score_anims.push(anim)
    }
  }
  game.score_anims = new_score_anims
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = ModeSelect
    game.menu_selection = 0
  }
}

///|
fn update_mode_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.menu_selection = (game.menu_selection - 1 + 3) % 3
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.menu_selection = (game.menu_selection + 1) % 3
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    match game.menu_selection {
      0 => {
        game.mode = VsAI
        game.screen = DifficultySelect
        game.menu_selection = 1 // Default Normal
      }
      1 => {
        game.mode = Puzzle
        game.puzzle_levels = @levels.create_puzzles()
        game.screen = PuzzleSelect
        game.menu_selection = 0
      }
      _ => {
        game.mode = Local2P
        @types.reset_game(game)
        game.screen = Playing
      }
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
  }
}

///|
fn update_difficulty_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.menu_selection = (game.menu_selection - 1 + 3) % 3
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.menu_selection = (game.menu_selection + 1) % 3
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.difficulty = match game.menu_selection {
      0 => Easy
      1 => Normal
      _ => Hard
    }
    @types.reset_game(game)
    game.screen = Playing
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = ModeSelect
    game.menu_selection = 0
  }
}

///|
fn update_puzzle_select(game : @types.Game) -> Unit {
  let total = game.puzzle_levels.length()
  let cols = 5
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.menu_selection = (game.menu_selection + 1) % total
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.menu_selection = (game.menu_selection - 1 + total) % total
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.menu_selection = (game.menu_selection + cols) % total
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.menu_selection = (game.menu_selection - cols + total) % total
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.current_puzzle = game.menu_selection
    load_puzzle(game)
    game.screen = Playing
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = ModeSelect
    game.menu_selection = 1
  }
}

///|
fn load_puzzle(game : @types.Game) -> Unit {
  if game.current_puzzle < game.puzzle_levels.length() {
    let puzzle = game.puzzle_levels[game.current_puzzle]
    // Copy puzzle board to game board
    for r in 0..<@types.board_size {
      for c in 0..<@types.board_size {
        game.board.cells[r][c] = puzzle.board.cells[r][c]
      }
    }
    game.current_player = puzzle.current_player
    game.play_state = WaitingForMove
    game.black_score = 0
    game.white_score = 0
    game.black_captures = 0
    game.white_captures = 0
    game.move_count = 0
    game.last_move = None
    game.patterns_found = []
    game.puzzle_score = 0
    game.puzzle_solved = false
    game.capture_anims = []
    game.pattern_anims = []
    game.score_anims = []
  }
}

///|
fn update_playing(game : @types.Game, dt : Float) -> Unit {
  // Escape to go back
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = ModeSelect
    game.menu_selection = 0
    return
  }
  // R to restart
  if @raylib.is_key_pressed(@raylib.KeyR) {
    if game.mode == Puzzle {
      load_puzzle(game)
    } else {
      @types.reset_game(game)
    }
    return
  }
  // N for next puzzle
  if game.mode == Puzzle && @raylib.is_key_pressed(@raylib.KeyN) {
    game.current_puzzle = (game.current_puzzle + 1) %
      game.puzzle_levels.length()
    load_puzzle(game)
    return
  }
  match game.play_state {
    WaitingForMove => update_waiting(game)
    AIThinking => update_ai_thinking(game, dt)
    Animating => update_animating(game)
    GameOver => update_game_over_playing(game)
  }
}

///|
fn update_waiting(game : @types.Game) -> Unit {
  // Update hover hex
  let mouse = @raylib.get_mouse_position()
  game.hover_hex = @types.pixel_to_hex(mouse.x, mouse.y, @types.hex_size)
  // Pass
  if @raylib.is_key_pressed(@raylib.KeyP) {
    handle_pass(game)
    return
  }
  // Handle click
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    match game.hover_hex {
      Some(coord) =>
        if @types.in_bounds(coord, @types.board_size) {
          if @types.get_cell(game.board, coord) == Empty {
            make_move(game, coord)
          }
        }
      None => ()
    }
  }
}

///|
fn handle_pass(game : @types.Game) -> Unit {
  match game.current_player {
    Black => game.black_passed = true
    White => game.white_passed = true
  }
  // If both passed, game over
  if game.black_passed && game.white_passed {
    end_game(game)
    return
  }
  game.current_player = @types.opponent(game.current_player)
  // If AI's turn, trigger AI
  if game.mode == VsAI && game.current_player == White {
    game.play_state = AIThinking
    game.ai_delay = 0.0
  }
}

///|
fn make_move(game : @types.Game, coord : @types.HexCoord) -> Unit {
  let player = game.current_player
  // Place stone
  @types.set_cell(game.board, coord, Occupied(player))
  game.last_move = Some(coord)
  game.move_count = game.move_count + 1
  // Reset pass flags
  match player {
    Black => game.black_passed = false
    White => game.white_passed = false
  }
  // Resolve captures
  let captured = @board.resolve_captures_cascading(game.board, player)
  for i in 0..<captured.length() {
    game.capture_anims.push({ pos: captured[i], timer: 0.0 })
  }
  if captured.length() > 0 {
    // Floating score animation at center of captured stones
    let mut sum_x : Float = 0.0
    let mut sum_y : Float = 0.0
    for i in 0..<captured.length() {
      let (px, py) = @types.hex_to_pixel(captured[i], @types.hex_size)
      sum_x = sum_x + px
      sum_y = sum_y + py
    }
    let cx = sum_x / Float::from_int(captured.length())
    let cy = sum_y / Float::from_int(captured.length())
    game.score_anims.push({
      x: cx,
      y: cy - 20.0,
      text: "+" + captured.length().to_string() + " cap",
      timer: @types.score_anim_time,
    })
  }
  match player {
    Black => game.black_captures = game.black_captures + captured.length()
    White => game.white_captures = game.white_captures + captured.length()
  }
  // Score patterns
  let old_black = game.black_score
  let old_white = game.white_score
  game.black_score = @board.score_patterns(game.board, Black) +
    game.black_captures
  game.white_score = @board.score_patterns(game.board, White) +
    game.white_captures
  // Track pattern animations for newly scored patterns
  let new_patterns = @board.find_all_patterns(game.board, player)
  game.patterns_found = new_patterns
  for i in 0..<new_patterns.length() {
    let p = new_patterns[i]
    game.pattern_anims.push({
      kind: p.kind,
      positions: p.positions,
      timer: @types.pattern_anim_time,
    })
    // Create floating score animation at pattern center
    if p.positions.length() > 0 {
      let mut sum_x : Float = 0.0
      let mut sum_y : Float = 0.0
      for j in 0..<p.positions.length() {
        let (px, py) = @types.hex_to_pixel(p.positions[j], @types.hex_size)
        sum_x = sum_x + px
        sum_y = sum_y + py
      }
      let cx = sum_x / Float::from_int(p.positions.length())
      let cy = sum_y / Float::from_int(p.positions.length())
      game.score_anims.push({
        x: cx,
        y: cy,
        text: "+" + p.points.to_string(),
        timer: @types.score_anim_time,
      })
    }
  }
  // Puzzle mode: check score from this single move
  if game.mode == Puzzle {
    let score_gain = match player {
      Black => game.black_score - old_black
      White => game.white_score - old_white
    }
    game.puzzle_score = score_gain
    if game.current_puzzle < game.puzzle_levels.length() {
      let puzzle = game.puzzle_levels[game.current_puzzle]
      if score_gain >= puzzle.target_score {
        game.puzzle_solved = true
      }
    }
  }
  // Check for game end (board full)
  if @types.count_empty(game.board) == 0 {
    end_game(game)
    return
  }
  // Switch turns
  game.current_player = @types.opponent(player)
  // Trigger AI if needed
  if game.mode == VsAI && game.current_player == White {
    game.play_state = AIThinking
    game.ai_delay = 0.0
  }
}

///|
fn update_ai_thinking(game : @types.Game, dt : Float) -> Unit {
  game.ai_delay = game.ai_delay + dt
  if game.ai_delay >= @types.ai_think_delay {
    let move_opt = @ai.select_move(game.board, White, game.difficulty)
    match move_opt {
      Some(coord) => {
        make_move(game, coord)
        if game.play_state == AIThinking {
          game.play_state = WaitingForMove
        }
      }
      None => {
        // AI passes
        handle_pass(game)
        game.play_state = WaitingForMove
      }
    }
  }
}

///|
fn update_animating(game : @types.Game) -> Unit {
  // Transition back to waiting when animations finish
  if game.capture_anims.length() == 0 {
    game.play_state = WaitingForMove
  }
}

///|
fn update_game_over_playing(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = Results
  }
}

///|
fn end_game(game : @types.Game) -> Unit {
  // Final score calculation
  game.black_score = @board.score_patterns(game.board, Black) +
    game.black_captures
  game.white_score = @board.score_patterns(game.board, White) +
    game.white_captures
  game.play_state = GameOver
  if game.black_score > game.white_score {
    game.winner = Some(Black)
    game.result_message = "Black Wins!"
  } else if game.white_score > game.black_score {
    game.winner = Some(White)
    game.result_message = "White Wins!"
  } else {
    game.winner = None
    game.result_message = "Draw!"
  }
  game.screen = Results
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.mode == Puzzle {
      // Go to next puzzle
      game.current_puzzle = (game.current_puzzle + 1) %
        game.puzzle_levels.length()
      load_puzzle(game)
      game.screen = Playing
    } else {
      @types.reset_game(game)
      game.screen = Playing
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = ModeSelect
    game.menu_selection = 0
  }
}
