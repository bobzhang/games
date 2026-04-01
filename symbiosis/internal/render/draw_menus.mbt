///|
fn draw_title(game : @types.Game) -> Unit {
  ignore(game)
  // Title
  let title = "SYMBIOSIS"
  let tw = @draw.measure_text(title, 60)
  @draw.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    180,
    60,
    @types.color_title,
  )
  // Subtitle
  let sub = "A Mirrored Movement Puzzle"
  let sw = @draw.measure_text(sub, 24)
  @draw.draw_text(
    sub,
    (@types.screen_width - sw) / 2,
    260,
    24,
    @types.color_hud_dim,
  )
  // Characters
  @draw.draw_text("Luna", 460, 340, 28, @types.color_luna)
  @draw.draw_text(" & ", 530, 340, 28, @types.color_hud_text)
  @draw.draw_text("Sol", 575, 340, 28, @types.color_sol)
  // Instructions
  let inst = "Press ENTER to start"
  let iw = @draw.measure_text(inst, 24)
  @draw.draw_text(
    inst,
    (@types.screen_width - iw) / 2,
    450,
    24,
    @types.color_hud_text,
  )
  // Controls hint
  @draw.draw_text(
    "Move both characters with one input.", 380, 520, 18, @types.color_hud_dim,
  )
  @draw.draw_text(
    "Luna walks on the floor. Sol walks on the ceiling.", 320, 550, 18, @types.color_hud_dim,
  )
  @draw.draw_text(
    "Left/Right is MIRRORED for Sol!", 420, 580, 18, @types.color_highlight,
  )
}

///|
fn draw_world_select(game : @types.Game) -> Unit {
  @draw.draw_text("SELECT WORLD", 480, 60, 36, @types.color_title)
  for w in 0..<@types.num_worlds {
    let y = 160 + w * 120
    let unlocked = @levels.world_unlocked(game.scores, w)
    let name = @types.world_name(w)
    let label = "World " + (w + 1).to_string() + ": " + name
    let color = if w == game.selected_world {
      @types.color_highlight
    } else if unlocked {
      @types.color_hud_text
    } else {
      @types.color_hud_dim
    }
    // Selection indicator
    if w == game.selected_world {
      @raylib.draw_rectangle(
        340,
        y - 5,
        600,
        50,
        @raylib.Color::new(60, 60, 80, 150),
      )
      @draw.draw_text(">", 350, y, 28, @types.color_highlight)
    }
    @draw.draw_text(label, 380, y, 28, color)
    if !unlocked {
      @draw.draw_text("(Locked)", 700, y + 5, 20, @types.color_hud_dim)
    } else {
      // Show completion
      let mut completed = 0
      if w < game.scores.length() {
        for l in 0..<game.scores[w].length() {
          if game.scores[w][l].completed {
            completed += 1
          }
        }
      }
      let comp_str = completed.to_string() +
        "/" +
        @types.levels_per_world.to_string()
      @draw.draw_text(comp_str, 700, y + 5, 20, @types.color_hud_dim)
    }
  }
  @draw.draw_text(
    "Up/Down: Select  Enter: Open  Esc: Back",
    400,
    @types.screen_height - 60,
    18,
    @types.color_hud_dim,
  )
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  let world_name = @types.world_name(game.selected_world)
  @draw.draw_text(
    "World " + (game.selected_world + 1).to_string() + ": " + world_name,
    440,
    60,
    32,
    @types.color_title,
  )
  for l in 0..<@types.levels_per_world {
    let y = 140 + l * 70
    let unlocked = @levels.level_unlocked(game.scores, game.selected_world, l)
    let label = "Level " + (l + 1).to_string()
    let color = if l == game.selected_level {
      @types.color_highlight
    } else if unlocked {
      @types.color_hud_text
    } else {
      @types.color_hud_dim
    }
    // Selection indicator
    if l == game.selected_level {
      @raylib.draw_rectangle(
        340,
        y - 5,
        600,
        50,
        @raylib.Color::new(60, 60, 80, 150),
      )
      @draw.draw_text(">", 350, y, 24, @types.color_highlight)
    }
    @draw.draw_text(label, 380, y, 24, color)
    if !unlocked {
      @draw.draw_text("(Locked)", 520, y + 3, 18, @types.color_hud_dim)
    } else {
      // Show stars
      let w = game.selected_world
      if w >= 0 &&
        w < game.scores.length() &&
        l >= 0 &&
        l < game.scores[w].length() {
        let score = game.scores[w][l]
        if score.completed {
          let star_str = stars_string(score.stars)
          @draw.draw_text(star_str, 520, y + 3, 18, @types.color_star_on)
          let best_str = "Best: " + score.best_moves.to_string()
          @draw.draw_text(best_str, 600, y + 3, 18, @types.color_hud_dim)
        }
      }
    }
  }
  @draw.draw_text(
    "Up/Down: Select  Enter: Play  Esc: Back",
    400,
    @types.screen_height - 60,
    18,
    @types.color_hud_dim,
  )
}

///|
fn draw_results(game : @types.Game) -> Unit {
  @draw.draw_text("LEVEL RESULTS", 470, 100, 36, @types.color_title)
  match game.current_level {
    None => ()
    Some(level) => {
      let world_str = @types.world_name(level.world)
      @draw.draw_text(
        "World " +
        (level.world + 1).to_string() +
        ": " +
        world_str +
        " - Level " +
        (level.index + 1).to_string(),
        400,
        170,
        24,
        @types.color_hud_text,
      )
      let moves_str = "Moves: " +
        game.move_count.to_string() +
        " (Par: " +
        level.par_moves.to_string() +
        ")"
      @draw.draw_text(moves_str, 450, 230, 24, @types.color_hud_text)
      let stars = @types.compute_stars(game)
      // Draw stars big
      for i in 0..<3 {
        let sx = 500 + i * 80
        let color = if i < stars {
          @types.color_star_on
        } else {
          @types.color_star_off
        }
        @draw.draw_text("*", sx, 290, 60, color)
      }
      // Gem status
      if @types.all_gems_collected(game) {
        @draw.draw_text("Gems: Collected!", 470, 380, 22, @types.color_gem)
      } else {
        @draw.draw_text("Gems: Missing", 470, 380, 22, @types.color_hud_dim)
      }
      @draw.draw_text(
        "Enter: Next Level  R: Retry  Esc: Level Select", 340, 480, 20, @types.color_hud_dim,
      )
    }
  }
}
