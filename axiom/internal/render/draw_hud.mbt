///|
pub fn draw_hud(game : @types.Game) -> Unit {
  match game.level_def {
    None => ()
    Some(def) => {
      // Level name header
      let header = "World " + (def.world + 1).to_string() + "-" + (def.index + 1).to_string() + ": " + def.name
      @draw.draw_text(header, @types.grid_offset_x, 8, 20, @types.color_text_bright)
      // Goal progress
      draw_goal_progress(game)
      // Par info
      let par_text = "Par: " + def.par.to_string() + "  Optimal: " + def.optimal.to_string()
      @draw.draw_text(par_text, @types.grid_offset_x, @types.screen_height - 70, 14, @types.color_text_dim)
      // Hint
      @draw.draw_text(def.hint, @types.grid_offset_x, @types.screen_height - 48, 13, @types.color_text_dim)
      // Medal display
      draw_medal_info(game, def)
    }
  }
}

///|
fn draw_goal_progress(game : @types.Game) -> Unit {
  match game.level {
    None => ()
    Some(level) => {
      let total = level.goals.length()
      let collected = get_current_goals_count(game)
      let progress_text = "Goals: " + collected.to_string() + "/" + total.to_string()
      let col = if collected == total {
        @types.color_success
      } else {
        @types.color_goal
      }
      @draw.draw_text(
        progress_text,
        @types.grid_offset_x + 400,
        8,
        18,
        col,
      )
    }
  }
}

///|
fn get_current_goals_count(game : @types.Game) -> Int {
  match game.trace {
    Some(trace) =>
      if game.trace_step >= 0 && game.trace_step < trace.states.length() {
        @types.count_goals_collected(trace.states[game.trace_step].goals_collected)
      } else {
        0
      }
    None => 0
  }
}

///|
fn draw_medal_info(game : @types.Game, def : @types.LevelDef) -> Unit {
  let cmd_count = game.program.commands.length()
  if cmd_count == 0 {
    return
  }
  let medal = @types.medal_from_instructions(cmd_count, def.par, def.optimal)
  let (medal_text, medal_col) = match medal {
    Gold => ("GOLD", @types.color_gold)
    Silver => ("SILVER", @types.color_silver)
    Bronze => ("BRONZE", @types.color_bronze)
    None_ => ("---", @types.color_text_dim)
  }
  let text = "Instructions: " + cmd_count.to_string() + "  Medal: " + medal_text
  @draw.draw_text(
    text,
    @types.grid_offset_x,
    @types.screen_height - 28,
    14,
    medal_col,
  )
}

///|
pub fn draw_star(x : Int, y : Int, filled : Bool) -> Unit {
  let col = if filled {
    @types.color_gold
  } else {
    @types.color_text_dim
  }
  // Simple star as a small filled circle for now
  @raylib.draw_circle(x, y, 8.0, col)
  if !filled {
    @raylib.draw_circle(x, y, 5.0, @types.color_bg)
  }
}

///|
pub fn draw_stars(x : Int, y : Int, count : Int) -> Unit {
  for i in 0..<3 {
    draw_star(x + i * 22, y, i < count)
  }
}
