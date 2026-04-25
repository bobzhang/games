///|
/// Screen width in pixels.
let sw : Int = 1080

///|
/// Screen height in pixels.
let sh : Int = 720

///|
/// Number of columns on the match-3 board.
let board_w : Int = 8

///|
/// Number of rows on the match-3 board.
let board_h : Int = 8

///|
/// Number of distinct tile colours.
let tile_count : Int = 6

///|
/// Size of each board cell in pixels.
let cell : Int = 64

///|
/// Horizontal pixel offset of the board origin.
let board_px : Int = 284

///|
/// Vertical pixel offset of the board origin.
let board_py : Int = 112

///|
/// Generated art resources used by the renderer.
struct GameArt {
  backdrop : @raylib.Texture
  rose : @raylib.Texture
  marigold : @raylib.Texture
  sunflower : @raylib.Texture
  clover : @raylib.Texture
  hydrangea : @raylib.Texture
  seed : @raylib.Texture
}

///|
/// Returns a copy of `color` with the alpha channel replaced by `alpha`.
fn with_alpha(color : @raylib.Color, alpha : Int) -> @raylib.Color {
  @raylib.Color::new(
    color.r.to_int(),
    color.g.to_int(),
    color.b.to_int(),
    alpha.clamp(min=0, max=255),
  )
}

///|
/// Loads one bilinear-filtered texture from the package resources directory.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "match3_garden_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads the generated garden backdrop and match tile artwork.
fn load_game_art() -> GameArt {
  {
    backdrop: load_art_texture("garden_backdrop.png"),
    rose: load_art_texture("tile_rose.png"),
    marigold: load_art_texture("tile_marigold.png"),
    sunflower: load_art_texture("tile_sunflower.png"),
    clover: load_art_texture("tile_clover.png"),
    hydrangea: load_art_texture("tile_hydrangea.png"),
    seed: load_art_texture("tile_seed.png"),
  }
}

///|
/// Releases the generated textures before closing the window.
fn unload_game_art(art : GameArt) -> Unit {
  @raylib.unload_texture(art.backdrop)
  @raylib.unload_texture(art.rose)
  @raylib.unload_texture(art.marigold)
  @raylib.unload_texture(art.sunflower)
  @raylib.unload_texture(art.clover)
  @raylib.unload_texture(art.hydrangea)
  @raylib.unload_texture(art.seed)
}

///|
/// Draws a texture centered on the destination point.
fn draw_texture_centered(
  texture : @raylib.Texture,
  cx : Float,
  cy : Float,
  w : Float,
  h : Float,
  tint : @raylib.Color,
) -> Unit {
  @raylib.draw_texture_pro(
    texture,
    @raylib.Rectangle::new(
      0.0,
      0.0,
      Float::from_int(texture.width()),
      Float::from_int(texture.height()),
    ),
    @raylib.Rectangle::new(cx, cy, w, h),
    @raylib.Vector2::new(w * 0.5, h * 0.5),
    0.0,
    tint,
  )
}

///|
/// Draws a texture cover-cropped into the destination rectangle.
fn draw_texture_cover(
  texture : @raylib.Texture,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  tint : @raylib.Color,
) -> Unit {
  let source_w : Float = Float::from_int(texture.width())
  let source_h : Float = Float::from_int(texture.height())
  let source_ratio : Float = source_w / source_h
  let dest_ratio : Float = w / h

  let mut src_x : Float = 0.0
  let mut src_y : Float = 0.0
  let mut src_w : Float = source_w
  let mut src_h : Float = source_h

  if source_ratio > dest_ratio {
    src_w = source_h * dest_ratio
    src_x = (source_w - src_w) * 0.5
  } else if source_ratio < dest_ratio {
    src_h = source_w / dest_ratio
    src_y = (source_h - src_h) * 0.5
  }

  @raylib.draw_texture_pro(
    texture,
    @raylib.Rectangle::new(src_x, src_y, src_w, src_h),
    @raylib.Rectangle::new(x, y, w, h),
    @raylib.Vector2::new(0.0, 0.0),
    0.0,
    tint,
  )
}

///|
/// Returns the generated texture associated with a tile type.
fn tile_texture(art : GameArt, tile : Int) -> @raylib.Texture {
  if tile == 0 {
    art.rose
  } else if tile == 1 {
    art.marigold
  } else if tile == 2 {
    art.sunflower
  } else if tile == 3 {
    art.clover
  } else if tile == 4 {
    art.hydrangea
  } else {
    art.seed
  }
}

///|
/// Draws the greenhouse backdrop and a subtle screen-wide readability wash.
fn draw_background(art : GameArt) -> Unit {
  @raylib.clear_background(@raylib.Color::new(18, 24, 20, 255))
  draw_texture_cover(
    art.backdrop,
    0.0,
    0.0,
    Float::from_int(sw),
    Float::from_int(sh),
    @raylib.Color::new(255, 255, 255, 255),
  )
  @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 14, 12, 74))
}

///|
/// Draws the top status bar.
fn draw_hud(score : Int, moves_left : Int, best_combo : Int) -> Unit {
  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(22.0, 18.0, 1036.0, 72.0),
    0.18,
    12,
    @raylib.Color::new(10, 18, 18, 218),
  )
  @raylib.draw_rectangle_rounded_lines_ex(
    @raylib.Rectangle::new(22.0, 18.0, 1036.0, 72.0),
    0.18,
    12,
    2.0,
    @raylib.Color::new(210, 174, 92, 210),
  )
  @draw.draw_text(
    "MATCH-3 GARDEN 2026",
    44,
    36,
    34,
    @raylib.Color::new(236, 244, 216, 246),
  )
  @draw.draw_text(
    "Score \{score}",
    560,
    36,
    28,
    @raylib.Color::new(226, 244, 238, 238),
  )
  @draw.draw_text(
    "Moves \{moves_left}",
    740,
    36,
    28,
    @raylib.Color::new(254, 226, 116, 240),
  )
  @draw.draw_text(
    "Combo x\{best_combo}",
    910,
    36,
    28,
    @raylib.Color::new(255, 178, 112, 240),
  )
}

///|
/// Draws the complete board, including generated tile icons and selection highlights.
fn draw_board(
  board : Array[Int],
  cur_x : Int,
  cur_y : Int,
  sel_x : Int,
  sel_y : Int,
  art : GameArt,
) -> Unit {
  let board_size = board_w * cell
  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(
      Float::from_int(board_px - 18),
      Float::from_int(board_py - 18),
      Float::from_int(board_size + 36),
      Float::from_int(board_size + 36),
    ),
    0.08,
    10,
    @raylib.Color::new(38, 28, 18, 226),
  )
  @raylib.draw_rectangle_rounded_lines_ex(
    @raylib.Rectangle::new(
      Float::from_int(board_px - 18),
      Float::from_int(board_py - 18),
      Float::from_int(board_size + 36),
      Float::from_int(board_size + 36),
    ),
    0.08,
    10,
    3.0,
    @raylib.Color::new(224, 184, 88, 224),
  )

  for y in 0..<board_h {
    for x in 0..<board_w {
      let v = board[idx(x, y)]
      let px = board_px + x * cell
      let py = board_py + y * cell
      let base = if v >= 0 {
        with_alpha(tile_color(v), 42)
      } else {
        @raylib.Color::new(24, 32, 26, 226)
      }

      @raylib.draw_rectangle_rounded(
        @raylib.Rectangle::new(
          Float::from_int(px + 3),
          Float::from_int(py + 3),
          Float::from_int(cell - 6),
          Float::from_int(cell - 6),
        ),
        0.18,
        8,
        @raylib.Color::new(16, 24, 20, 226),
      )
      @raylib.draw_rectangle_rounded(
        @raylib.Rectangle::new(
          Float::from_int(px + 5),
          Float::from_int(py + 5),
          Float::from_int(cell - 10),
          Float::from_int(cell - 10),
        ),
        0.16,
        8,
        base,
      )
      if v >= 0 {
        draw_texture_centered(
          tile_texture(art, v),
          Float::from_int(px + cell / 2),
          Float::from_int(py + cell / 2),
          58.0,
          58.0,
          @raylib.Color::new(255, 255, 255, 245),
        )
      }

      if x == cur_x && y == cur_y {
        @raylib.draw_rectangle_rounded_lines_ex(
          @raylib.Rectangle::new(
            Float::from_int(px + 3),
            Float::from_int(py + 3),
            Float::from_int(cell - 6),
            Float::from_int(cell - 6),
          ),
          0.18,
          8,
          3.0,
          @raylib.Color::new(255, 238, 126, 248),
        )
      }
      if x == sel_x && y == sel_y {
        @raylib.draw_rectangle_rounded_lines_ex(
          @raylib.Rectangle::new(
            Float::from_int(px + 8),
            Float::from_int(py + 8),
            Float::from_int(cell - 16),
            Float::from_int(cell - 16),
          ),
          0.18,
          8,
          3.0,
          @raylib.Color::new(250, 86, 86, 246),
        )
      }
    }
  }
}

///|
/// Draws the bottom message bar.
fn draw_message(msg : String) -> Unit {
  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(24.0, 642.0, 1032.0, 56.0),
    0.22,
    10,
    @raylib.Color::new(10, 16, 18, 224),
  )
  @raylib.draw_rectangle_rounded_lines_ex(
    @raylib.Rectangle::new(24.0, 642.0, 1032.0, 56.0),
    0.22,
    10,
    2.0,
    @raylib.Color::new(196, 164, 86, 196),
  )
  @draw.draw_text(msg, 44, 659, 23, @raylib.Color::new(234, 242, 224, 238))
}

///|
/// Draws the final score overlay once the move budget is exhausted.
fn draw_game_over(score : Int) -> Unit {
  @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 116))
  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(270.0, 244.0, 540.0, 190.0),
    0.12,
    10,
    @raylib.Color::new(8, 14, 18, 236),
  )
  @raylib.draw_rectangle_rounded_lines_ex(
    @raylib.Rectangle::new(270.0, 244.0, 540.0, 190.0),
    0.12,
    10,
    3.0,
    @raylib.Color::new(118, 198, 232, 230),
  )
  @draw.draw_text("GARDEN SHIFT ENDED", 326, 278, 38, @raylib.skyblue)
  @draw.draw_text("Final score: \{score}", 398, 328, 28, @raylib.raywhite)
  @draw.draw_text("Press R to start a new shift", 354, 370, 26, @raylib.white)
}

///|
/// Converts 2D board coordinates into a flat row-major index.
fn idx(x : Int, y : Int) -> Int {
  y * board_w + x
}

///|
/// Returns the display colour for a tile type integer.
fn tile_color(t : Int) -> @raylib.Color {
  if t == 0 {
    @raylib.red
  } else if t == 1 {
    @raylib.orange
  } else if t == 2 {
    @raylib.yellow
  } else if t == 3 {
    @raylib.lime
  } else if t == 4 {
    @raylib.skyblue
  } else {
    @raylib.brown
  }
}

///|
/// Returns a random tile type in the range [0, tile_count - 1].
fn random_tile() -> Int {
  @raylib.get_random_value(0, tile_count - 1)
}

///|
/// Fills the board with random tiles, retrying each cell up to 30 times to avoid placing an immediate 3-in-a-row.
fn fill_board_no_matches(board : Array[Int]) -> Unit {
  for y in 0..<board_h {
    for x in 0..<board_w {
      let mut t = random_tile()
      let mut retry_count = 0
      while retry_count < 30 {
        let mut bad = false
        if x >= 2 {
          let a = board[idx(x - 1, y)]
          let b = board[idx(x - 2, y)]
          if a == t && b == t {
            bad = true
          }
        }
        if y >= 2 {
          let a = board[idx(x, y - 1)]
          let b = board[idx(x, y - 2)]
          if a == t && b == t {
            bad = true
          }
        }
        if !bad {
          break
        }
        t = random_tile()
        retry_count = retry_count + 1
      }
      board[idx(x, y)] = t
    }
  }
}

///|
/// Scans the board for horizontal and vertical runs of 3 or more identical tiles, marking them in `marks`, and returns the total count of marked tiles.
fn mark_matches(board : Array[Int], marks : Array[Bool]) -> Int {
  for i in 0..<marks.length() {
    marks[i] = false
  }

  for y in 0..<board_h {
    let mut x = 0
    while x < board_w {
      let t = board[idx(x, y)]
      if t < 0 {
        x = x + 1
        continue
      }
      let mut len = 1
      while x + len < board_w && board[idx(x + len, y)] == t {
        len = len + 1
      }
      if len >= 3 {
        for k in 0..<len {
          marks[idx(x + k, y)] = true
        }
      }
      x = x + len
    }
  }

  for x in 0..<board_w {
    let mut y = 0
    while y < board_h {
      let t = board[idx(x, y)]
      if t < 0 {
        y = y + 1
        continue
      }
      let mut len = 1
      while y + len < board_h && board[idx(x, y + len)] == t {
        len = len + 1
      }
      if len >= 3 {
        for k in 0..<len {
          marks[idx(x, y + k)] = true
        }
      }
      y = y + len
    }
  }

  let mut count = 0
  for mark in marks {
    if mark {
      count = count + 1
    }
  }
  count
}

///|
/// Removes all marked tiles, drops remaining tiles downward per column, fills empty top slots with new random tiles, and returns the number of tiles removed.
fn apply_matches_and_refill(board : Array[Int], marks : Array[Bool]) -> Int {
  let mut removed = 0
  for i in 0..<board.length() {
    if marks[i] {
      board[i] = -1
      removed = removed + 1
    }
  }

  for x in 0..<board_w {
    let mut write = board_h - 1
    for y = board_h - 1; y >= 0; y = y - 1 {
      let v = board[idx(x, y)]
      if v >= 0 {
        board[idx(x, write)] = v
        write = write - 1
      }
    }
    while write >= 0 {
      board[idx(x, write)] = random_tile()
      write = write - 1
    }
  }

  removed
}

///|
/// Swaps the tile values at board positions (x1, y1) and (x2, y2).
fn swap_tiles(
  board : Array[Int],
  x1 : Int,
  y1 : Int,
  x2 : Int,
  y2 : Int,
) -> Unit {
  let a = idx(x1, y1)
  let b = idx(x2, y2)
  let t = board[a]
  board[a] = board[b]
  board[b] = t
}

///|
/// Entry point: opens the window and runs the main game loop handling input, match resolution, and rendering.
fn main {
  @raylib.init_window(sw, sh, "Match-3 Garden 2026")
  defer @raylib.close_window()
  @raylib.set_target_fps(60)
  @draw.init_font()
  defer @draw.cleanup()
  let art = load_game_art()
  defer unload_game_art(art)

  let board : Array[Int] = Array::make(board_w * board_h, 0)
  fill_board_no_matches(board)
  let marks : Array[Bool] = Array::make(board_w * board_h, false)

  let mut cur_x = 0
  let mut cur_y = 0
  let mut sel_x = -1
  let mut sel_y = -1

  let mut moves_left = 30
  let mut score = 0
  let mut best_combo = 0
  let mut msg = "Arrow keys move, Enter/Space select+swap, R restart"

  while !@raylib.window_should_close() {
    if @raylib.is_key_pressed(@raylib.KeyR) {
      fill_board_no_matches(board)
      cur_x = 0
      cur_y = 0
      sel_x = -1
      sel_y = -1
      moves_left = 30
      score = 0
      best_combo = 0
      msg = "Garden reset. Plan your chain reactions!"
    }

    if moves_left > 0 {
      if @raylib.is_key_pressed(@raylib.KeyLeft) ||
        @raylib.is_key_pressed(@raylib.KeyA) {
        if cur_x > 0 {
          cur_x = cur_x - 1
        }
      }
      if @raylib.is_key_pressed(@raylib.KeyRight) ||
        @raylib.is_key_pressed(@raylib.KeyD) {
        if cur_x < board_w - 1 {
          cur_x = cur_x + 1
        }
      }
      if @raylib.is_key_pressed(@raylib.KeyUp) ||
        @raylib.is_key_pressed(@raylib.KeyW) {
        if cur_y > 0 {
          cur_y = cur_y - 1
        }
      }
      if @raylib.is_key_pressed(@raylib.KeyDown) ||
        @raylib.is_key_pressed(@raylib.KeyS) {
        if cur_y < board_h - 1 {
          cur_y = cur_y + 1
        }
      }

      if @raylib.is_key_pressed(@raylib.KeyEnter) ||
        @raylib.is_key_pressed(@raylib.KeySpace) {
        if sel_x < 0 {
          sel_x = cur_x
          sel_y = cur_y
          msg = "Tile selected. Pick one adjacent tile to swap."
        } else {
          let dx = (sel_x - cur_x).abs()
          let dy = (sel_y - cur_y).abs()
          if dx + dy == 1 {
            swap_tiles(board, sel_x, sel_y, cur_x, cur_y)
            let mut matched = mark_matches(board, marks)
            if matched <= 0 {
              swap_tiles(board, sel_x, sel_y, cur_x, cur_y)
              msg = "No match. Swap cancelled."
            } else {
              moves_left = moves_left - 1
              let mut combo = 1
              let mut total_removed = 0
              while matched > 0 {
                let removed = apply_matches_and_refill(board, marks)
                total_removed = total_removed + removed
                score = score + removed * 10 * combo
                if combo > best_combo {
                  best_combo = combo
                }
                combo = combo + 1
                matched = mark_matches(board, marks)
              }
              msg = "Great! Cleared \{total_removed} flowers, combo x\{combo - 1}."
            }
            sel_x = -1
            sel_y = -1
          } else {
            sel_x = cur_x
            sel_y = cur_y
            msg = "Not adjacent. Selection moved to cursor tile."
          }
        }
      }
    }

    @raylib.begin_drawing()
    draw_background(art)
    draw_hud(score, moves_left, best_combo)
    draw_board(board, cur_x, cur_y, sel_x, sel_y, art)
    draw_message(msg)

    if moves_left <= 0 {
      draw_game_over(score)
    }

    @fps.draw()
    @raylib.end_drawing()
  }
}
