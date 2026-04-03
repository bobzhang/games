///|
fn draw_playing(game : @types.Game) -> Unit {
  draw_toolbar(game)
  draw_grid(game)
  draw_hud(game)
  draw_needs_panel(game)
}

///|
fn draw_paused(game : @types.Game) -> Unit {
  draw_playing(game)
  // Overlay
  let sw = @types.screen_width
  let sh = @types.screen_height
  @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 160))
  let txt = "PAUSED"
  let tw = @draw.measure_text(txt, 48)
  @draw.draw_text(txt, (sw - tw) / 2, sh / 2 - 60, 48, @types.color_title)
  let sub = "ESC / SPACE: Resume  |  Q: Quit to menu"
  let sub_w = @draw.measure_text(sub, 20)
  @draw.draw_text(sub, (sw - sub_w) / 2, sh / 2 + 10, 20, @types.color_hud_text)
}

///|
fn draw_level_complete(game : @types.Game) -> Unit {
  draw_playing(game)
  // Overlay
  let sw = @types.screen_width
  let sh = @types.screen_height
  @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(0, 0, 0, 180))
  let txt = "LEVEL COMPLETE!"
  let tw = @draw.measure_text(txt, 48)
  @draw.draw_text(txt, (sw - tw) / 2, sh / 2 - 100, 48, @types.color_success)
  // Stars (centered)
  let stars = game.stars_earned[game.current_level]
  let star_gap = 4
  let star_size = 36
  let total_w = 3 * star_size + 2 * star_gap
  let star_x = sw / 2 - total_w / 2
  draw_stars(stars, star_x, sh / 2 - 30, star_size, star_gap)
  // Result details
  match game.level_results[game.current_level] {
    Some(result) => {
      let detail = "Tiles used: \{result.tiles_used} / Par: \{result.par_tiles}"
      let dw = @draw.measure_text(detail, 20)
      @draw.draw_text(
        detail,
        (sw - dw) / 2,
        sh / 2 + 20,
        20,
        @types.color_hud_text,
      )
      if result.bonus_met {
        let bonus = "Bonus space achieved!"
        let bw = @draw.measure_text(bonus, 18)
        @draw.draw_text(
          bonus,
          (sw - bw) / 2,
          sh / 2 + 50,
          18,
          @types.color_star_gold,
        )
      }
    }
    None => ()
  }
  // Options
  let opts = "SPACE: Menu  |  R: Retry  |  N: Next Level"
  let ow = @draw.measure_text(opts, 18)
  @draw.draw_text(opts, (sw - ow) / 2, sh / 2 + 90, 18, @types.color_hud_text)
}

///|
fn draw_stars(count : Int, x : Int, y : Int, size : Int, gap : Int) -> Unit {
  for i in 0..<3 {
    let col = if i < count {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    @draw.draw_text("*", x + i * (size + gap), y, size, col)
  }
}
