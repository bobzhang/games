///|
fn draw_title(game : @types.Game) -> Unit {
  // Background animation
  let t = game.title_anim
  for i in 0..<20 {
    let fi = Float::from_int(i)
    let x = Float::from_int((Float::from_int(i * 67) + t * 20.0).to_int() % @types.screen_width)
    let y = Float::from_int((Float::from_int(i * 43) + t * 15.0).to_int() % @types.screen_height)
    let sz = (sinf(t + fi) * 3.0 + 5.0)
    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      sz,
      @raylib.Color::new(0, 180, 255, 40),
    )
  }
  // Title text
  let title = "AXIOM"
  let tw = @draw.measure_text(title, 72)
  let pulse = (sinf(t * 2.0) * 10.0).to_int()
  @draw.draw_text(
    title,
    @types.screen_width / 2 - tw / 2,
    160 + pulse,
    72,
    @types.color_robot,
  )
  // Subtitle
  let sub = "Programming Puzzle Game"
  let sw = @draw.measure_text(sub, 24)
  @draw.draw_text(
    sub,
    @types.screen_width / 2 - sw / 2,
    250,
    24,
    @types.color_text_dim,
  )
  // Total stars
  let stars_text = "Stars: " + game.total_stars.to_string() + "/" + (@types.num_worlds * @types.levels_per_world * 3).to_string()
  let stw = @draw.measure_text(stars_text, 20)
  @draw.draw_text(
    stars_text,
    @types.screen_width / 2 - stw / 2,
    310,
    20,
    @types.color_gold,
  )
  // Menu options
  let opts = ["[Enter] Play", "[S] Sandbox", "[Esc] Quit"]
  for i in 0..<opts.length() {
    let ow = @draw.measure_text(opts[i], 22)
    @draw.draw_text(
      opts[i],
      @types.screen_width / 2 - ow / 2,
      420 + i * 45,
      22,
      @types.color_text,
    )
  }
  // Version
  @draw.draw_text("v1.0", @types.screen_width - 60, @types.screen_height - 30, 14, @types.color_text_dim)
}

///|
fn draw_world_select(game : @types.Game) -> Unit {
  // Header
  @draw.draw_text("SELECT WORLD", 40, 30, 32, @types.color_text_bright)
  @draw.draw_text("[Esc] Back", 40, 70, 16, @types.color_text_dim)
  // Draw 4 world cards
  for w in 0..<@types.num_worlds {
    let cx = 160 + w * 260
    let cy = 200
    let cw = 230
    let ch = 340
    let selected = w == game.current_world
    let wcol = @types.world_color(w)
    // Card background
    if selected {
      @raylib.draw_rectangle(cx - 4, cy - 4, cw + 8, ch + 8, wcol)
    }
    @raylib.draw_rectangle(cx, cy, cw, ch, @types.color_panel_bg)
    @raylib.draw_rectangle_lines(cx, cy, cw, ch, if selected { wcol } else { @types.color_grid_line })
    // World number
    let wnum = "World " + (w + 1).to_string()
    @draw.draw_text(wnum, cx + 10, cy + 10, 20, wcol)
    // World name
    @draw.draw_text(@types.world_name(w), cx + 10, cy + 38, 18, @types.color_text)
    // Stars for this world
    let world_stars = count_world_stars(game, w)
    let max_stars = @types.levels_per_world * 3
    let star_text = "Stars: " + world_stars.to_string() + "/" + max_stars.to_string()
    @draw.draw_text(star_text, cx + 10, cy + 70, 16, @types.color_gold)
    // Progress bar
    let bar_w = cw - 20
    let filled_w = if max_stars > 0 {
      bar_w * world_stars / max_stars
    } else {
      0
    }
    @raylib.draw_rectangle(cx + 10, cy + 95, bar_w, 8, @types.color_slot_bg)
    @raylib.draw_rectangle(cx + 10, cy + 95, filled_w, 8, wcol)
    // Completed levels
    let completed = count_world_completed(game, w)
    let comp_text = "Completed: " + completed.to_string() + "/" + @types.levels_per_world.to_string()
    @draw.draw_text(comp_text, cx + 10, cy + 115, 14, @types.color_text_dim)
    // World description
    let desc = match w {
      0 => "Learn the basics:\nMove, Turn Left,\nTurn Right"
      1 => "Add jumping:\nLeap over gaps\nand walls"
      2 => "Logic gates:\nIf conditions,\ncolor tiles"
      3 => "Full mastery:\nPush blocks,\nloop commands"
      _ => ""
    }
    @draw.draw_text(desc, cx + 10, cy + 150, 14, @types.color_text_dim)
    // Selection hint
    if selected {
      @draw.draw_text("[Enter] Select", cx + 10, cy + ch - 30, 14, wcol)
    }
  }
  // Controls
  @draw.draw_text("[Left/Right] Navigate  [Enter] Select  [Esc] Back", 40, @types.screen_height - 40, 16, @types.color_text_dim)
}

///|
fn count_world_stars(game : @types.Game, world : Int) -> Int {
  let mut total = 0
  if world < game.scores.length() {
    for l in 0..<game.scores[world].length() {
      total += @types.medal_stars(game.scores[world][l].medal)
    }
  }
  total
}

///|
fn count_world_completed(game : @types.Game, world : Int) -> Int {
  let mut total = 0
  if world < game.scores.length() {
    for l in 0..<game.scores[world].length() {
      if game.scores[world][l].completed {
        total += 1
      }
    }
  }
  total
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let wcol = @types.world_color(game.current_world)
  // Header
  let header = "World " + (game.current_world + 1).to_string() + ": " + @types.world_name(game.current_world)
  @draw.draw_text(header, 40, 30, 32, wcol)
  @draw.draw_text("[Esc] Back", 40, 70, 16, @types.color_text_dim)
  // Draw 3x3 grid of level cards
  for i in 0..<@types.levels_per_world {
    let col = i % 3
    let row = i / 3
    let cx = 140 + col * 340
    let cy = 120 + row * 185
    let cw = 310
    let ch = 165
    let selected = i == game.current_level
    let score = game.scores[game.current_world][i]
    // Card background
    if selected {
      @raylib.draw_rectangle(cx - 3, cy - 3, cw + 6, ch + 6, wcol)
    }
    let card_bg = if score.completed {
      @raylib.Color::new(30, 40, 30, 220)
    } else {
      @types.color_panel_bg
    }
    @raylib.draw_rectangle(cx, cy, cw, ch, card_bg)
    @raylib.draw_rectangle_lines(cx, cy, cw, ch, if selected { wcol } else { @types.color_grid_line })
    // Level number and name
    let level_def = @types.LevelDef::{
      world: game.current_world,
      index: i,
      name: "",
      ascii: [],
      start_x: 0,
      start_y: 0,
      start_dir: East,
      par: 0,
      optimal: 0,
      hint: "",
      available_commands: [],
    }
    let _ = level_def
    let lnum = (game.current_world + 1).to_string() + "-" + (i + 1).to_string()
    @draw.draw_text(lnum, cx + 10, cy + 8, 22, wcol)
    // Stars
    let star_count = @types.medal_stars(score.medal)
    draw_stars(cx + 80, cy + 18, star_count)
    // Completed indicator
    if score.completed {
      @draw.draw_text("DONE", cx + cw - 60, cy + 10, 14, @types.color_success)
    }
    // Best score
    if score.best_instructions < 999 {
      let best_text = "Best: " + score.best_instructions.to_string() + " cmds"
      @draw.draw_text(best_text, cx + 10, cy + 40, 14, @types.color_text_dim)
    }
    // Level hint (abbreviated)
    if selected {
      @draw.draw_text("[Enter] Play", cx + 10, cy + ch - 30, 14, wcol)
    }
  }
  // Controls
  @draw.draw_text("[Arrows] Navigate  [Enter] Play  [Esc] Back", 40, @types.screen_height - 40, 16, @types.color_text_dim)
}

///|
fn draw_programming(game : @types.Game) -> Unit {
  // Draw the grid world on the left
  draw_grid(game)
  // Draw the program panel on the right
  draw_program_panel(game)
  // Draw the HUD
  draw_hud(game)
}

///|
fn draw_results(game : @types.Game) -> Unit {
  // Background
  @raylib.draw_rectangle(0, 0, @types.screen_width, @types.screen_height, @raylib.Color::new(0, 0, 0, 180))
  // Results panel
  let px = @types.screen_width / 2 - 250
  let py = 120
  let pw = 500
  let ph = 450
  @raylib.draw_rectangle(px, py, pw, ph, @types.color_panel_bg)
  @raylib.draw_rectangle_lines(px, py, pw, ph, @types.color_success)
  @draw.draw_text("LEVEL COMPLETE!", px + 120, py + 20, 32, @types.color_success)
  match game.level_def {
    None => ()
    Some(def) => {
      let name = "World " + (def.world + 1).to_string() + "-" + (def.index + 1).to_string() + ": " + def.name
      let nw = @draw.measure_text(name, 20)
      @draw.draw_text(name, px + pw / 2 - nw / 2, py + 65, 20, @types.color_text)
      let cmd_count = game.program.commands.length()
      let medal = @types.medal_from_instructions(cmd_count, def.par, def.optimal)
      let stars = @types.medal_stars(medal)
      // Big stars
      for i in 0..<3 {
        let sx = px + pw / 2 - 60 + i * 50
        let sy = py + 110
        draw_star(sx, sy, i < stars)
      }
      // Stats
      @draw.draw_text(
        "Instructions used: " + cmd_count.to_string(),
        px + 40,
        py + 160,
        20,
        @types.color_text,
      )
      @draw.draw_text(
        "Par: " + def.par.to_string(),
        px + 40,
        py + 195,
        18,
        @types.color_text_dim,
      )
      @draw.draw_text(
        "Optimal: " + def.optimal.to_string(),
        px + 40,
        py + 225,
        18,
        @types.color_text_dim,
      )
      let medal_name = match medal {
        Gold => "GOLD"
        Silver => "SILVER"
        Bronze => "BRONZE"
        None_ => "NONE"
      }
      let medal_col = match medal {
        Gold => @types.color_gold
        Silver => @types.color_silver
        Bronze => @types.color_bronze
        None_ => @types.color_text_dim
      }
      @draw.draw_text("Medal: " + medal_name, px + 40, py + 265, 24, medal_col)
    }
  }
  // Options
  @draw.draw_text("[Enter] Next Level", px + 40, py + 330, 20, @types.color_text)
  @draw.draw_text("[R] Retry (improve score)", px + 40, py + 365, 20, @types.color_text_dim)
  @draw.draw_text("[Esc] Level Select", px + 40, py + 400, 20, @types.color_text_dim)
}
