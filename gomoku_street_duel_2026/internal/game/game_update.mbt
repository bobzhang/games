///|
/// Advances one frame of duel state, human input, and AI turn logic.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.update_timers(dt)

  let start_press : Bool = game.detect_start_press()
  let next_press : Bool = game.detect_next_press()
  let reset_press : Bool = game.detect_reset_press()

  match game.state {
    Title => if start_press { game.reset_round(true) }
    Play => {
      let held_dir : @types.Dir = game.detect_held_dir()
      game.update_cursor_hold(dt, held_dir)

      if game.turn == Human {
        let place_press : Bool = game.detect_place_press()
        let hint_press : Bool = game.detect_hint_press()
        let undo_press : Bool = game.detect_undo_press()
        let clear_press : Bool = game.detect_clear_press()
        let board_tap = game.detect_board_tap()

        if reset_press && game.touch_action_cd <= 0.0 {
          game.touch_action_cd = 0.2
          game.reset_round(true)
        } else if hint_press && game.touch_action_cd <= 0.0 {
          game.touch_action_cd = 0.2
          ignore(game.use_hint())
        } else if undo_press && game.touch_action_cd <= 0.0 {
          game.touch_action_cd = 0.2
          ignore(game.undo_last_turn())
        } else if clear_press && game.touch_action_cd <= 0.0 {
          game.touch_action_cd = 0.12
          @types.clear_hint(game)
          @types.set_message(game, "Hint cleared", 0.45)
        } else if board_tap.0 && game.touch_action_cd <= 0.0 {
          game.touch_action_cd = 0.1
          @types.clear_hint(game)
          ignore(game.place_stone(board_tap.1, board_tap.2, Human))
        } else if place_press && game.touch_action_cd <= 0.0 {
          game.touch_action_cd = 0.1
          @types.clear_hint(game)
          ignore(game.place_stone(game.cursor_x, game.cursor_y, Human))
        }
      }

      game.ai_step()
    }
    Result =>
      if next_press || reset_press {
        let odd_round : Bool = (game.human_wins + game.ai_wins + game.draws) % 2 ==
          1
        game.reset_round(not(odd_round))
      }
  }
}
