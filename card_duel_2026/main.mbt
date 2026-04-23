///|
/// Screen width in pixels.
let sw : Int = 980

///|
/// Screen height in pixels.
let sh : Int = 700

///|
/// Total number of distinct card types available in the deck.
let card_count : Int = 5

///|
/// Returns the display name of the card identified by the given index.
fn card_name(card : Int) -> String {
  match card {
    0 => "Strike"
    1 => "Guard"
    2 => "Burst"
    3 => "Sap"
    _ => "Repair"
  }
}

///|
/// Returns the energy cost required to play the given card.
fn card_cost(card : Int) -> Int {
  match card {
    0 => 1
    1 => 1
    2 => 2
    3 => 2
    _ => 2
  }
}

///|
/// Returns the short effect description for the given card index.
fn card_desc(card : Int) -> String {
  match card {
    0 => "Deal 6"
    1 => "Gain 7 block"
    2 => "Deal 12"
    3 => "Break block, deal 4"
    _ => "Heal 6"
  }
}

///|
/// Applies damage to a target, absorbing it through block first, and returns the updated HP and block values.
fn deal_damage(hp : Int, block : Int, dmg : Int) -> (Int, Int) {
  let mut hp2 = hp
  let mut block2 = block
  let absorbed = if block2 < dmg { block2 } else { dmg }
  block2 = block2 - absorbed
  let left = dmg - absorbed
  hp2 = hp2 - left
  (hp2, block2)
}

///|
/// Clears the current hand and fills it with three randomly drawn cards.
fn roll_hand(hand : Array[Int]) -> Unit {
  hand.clear()
  for _ in 0..<3 {
    hand.push(@raylib.get_random_value(0, card_count - 1))
  }
}

///|
/// Executes the enemy's two actions for the turn, applying damage or healing effects, and returns updated HP, block values, and an action log string.
fn enemy_turn(
  p_hp : Int,
  p_block : Int,
  e_hp : Int,
  e_block : Int,
  turn_no : Int,
) -> (Int, Int, Int, Int, String) {
  let mut p_hp = p_hp
  let mut p_block = p_block
  let mut e_hp = e_hp
  let mut e_block = e_block
  let mut log = "Enemy turn: "
  for act in 0..<2 {
    let roll = @raylib.get_random_value(0, 99)
    if roll < 55 {
      let dmg = 6 + turn_no / 4
      let (nhp, nblock) = deal_damage(p_hp, p_block, dmg)
      p_hp = nhp
      p_block = nblock
      log = "\{log} Slash(\{dmg})"
    } else if roll < 80 {
      e_block = e_block + 7
      log = "\{log} Guard"
    } else {
      let dmg = 4
      let (nhp, nblock) = deal_damage(p_hp, p_block, dmg)
      p_hp = nhp
      p_block = nblock
      e_hp = e_hp + 3
      log = "\{log} Drain"
    }
    if act == 0 {
      log = "\{log},"
    }
  }
  (p_hp, p_block, e_hp, e_block, log)
}

///|
/// Draws a bounded stat bar with a filled fraction based on the current value.
fn draw_stat_bar(
  x : Int,
  y : Int,
  width : Int,
  height : Int,
  value : Int,
  max_value : Int,
  color : @raylib.Color,
) -> Unit {
  let safe_value = if value < 0 {
    0
  } else if value > max_value {
    max_value
  } else {
    value
  }
  let fill_w = width * safe_value / max_value
  @raylib.draw_rectangle(
    x,
    y,
    width,
    height,
    @raylib.Color::new(8, 10, 16, 210),
  )
  @raylib.draw_rectangle(x, y, fill_w, height, color)
  @raylib.draw_rectangle_lines(
    x,
    y,
    width,
    height,
    @raylib.Color::new(230, 236, 255, 90),
  )
}

///|
/// Draws one duelist status panel with portrait, HP, and block information.
fn draw_duelist_panel(
  x : Int,
  y : Int,
  width : Int,
  height : Int,
  is_player : Bool,
  hp : Int,
  max_hp : Int,
  block : Int,
) -> Unit {
  let accent = if is_player {
    @raylib.Color::new(80, 170, 255, 255)
  } else {
    @raylib.Color::new(235, 76, 84, 255)
  }
  let bg = if is_player {
    @raylib.Color::new(22, 36, 60, 214)
  } else {
    @raylib.Color::new(62, 26, 34, 214)
  }
  @raylib.draw_rectangle(x, y, width, height, bg)
  @raylib.draw_rectangle_lines(x, y, width, height, accent)
  if is_player {
    ignore(draw_portrait_art(true, x + width - 172, y + 8, 158, 152))
  } else {
    ignore(draw_portrait_art(false, x + 14, y + 8, 158, 152))
  }

  let text_x = if is_player { x + 24 } else { x + 190 }
  let name = if is_player { "PLAYER" } else { "RIVAL" }
  @draw.draw_text(name, text_x, y + 18, 26, @raylib.raywhite)
  @draw.draw_text("HP \{hp}", text_x, y + 58, 24, @raylib.raywhite)
  draw_stat_bar(text_x, y + 88, 146, 14, hp, max_hp, accent)
  @draw.draw_text("Block \{block}", text_x, y + 112, 22, @raylib.lightgray)
  draw_stat_bar(
    text_x,
    y + 140,
    146,
    10,
    block,
    28,
    @raylib.Color::new(160, 178, 200, 255),
  )
}

///|
/// Draws one card in the player's current hand.
fn draw_hand_card(slot : Int, card : Int) -> Unit {
  let x = 120 + slot * 260
  let y = 360
  if !draw_card_frame_art(x, y, 220, 190) {
    @raylib.draw_rectangle(x, y, 220, 190, @raylib.Color::new(34, 34, 46, 255))
    @raylib.draw_rectangle_lines(x, y, 220, 190, @raylib.lightgray)
  }
  @raylib.draw_rectangle(
    x + 12,
    y + 36,
    132,
    118,
    @raylib.Color::new(8, 10, 18, 190),
  )
  @raylib.draw_rectangle_lines(
    x + 12,
    y + 36,
    132,
    118,
    @raylib.Color::new(210, 220, 245, 70),
  )
  ignore(draw_card_icon_art(card, x + 168, y + 98, 86))
  @draw.draw_text("\{slot + 1}", x + 16, y + 12, 26, @raylib.yellow)
  @draw.draw_text(card_name(card), x + 22, y + 48, 26, @raylib.raywhite)
  @draw.draw_text("Cost \{card_cost(card)}", x + 22, y + 84, 22, @raylib.orange)
  @draw.draw_text(card_desc(card), x + 22, y + 118, 19, @raylib.lightgray)
}

///|
/// Initializes the game window and runs the Card Duel 2026 main game loop.
fn main {
  @raylib.init_window(sw, sh, "Card Duel 2026")
  @raylib.set_target_fps(60)
  @draw.init_font()
  load_assets()

  let hand : Array[Int] = []
  let mut player_hp = 80
  let mut player_block = 0
  let mut enemy_hp = 95
  let mut enemy_block = 0
  let mut energy = 3
  let mut turn_no = 1
  let mut log = "Play cards with 1/2/3, end turn with E."
  let mut won = false
  let mut lost = false

  roll_hand(hand)

  while !@raylib.window_should_close() {
    if @raylib.is_key_pressed(@raylib.KeyR) {
      player_hp = 80
      player_block = 0
      enemy_hp = 95
      enemy_block = 0
      energy = 3
      turn_no = 1
      log = "New duel begins."
      won = false
      lost = false
      roll_hand(hand)
    }

    if !won && !lost {
      for slot in 0..<hand.length() {
        let key_hit = (slot == 0 && @raylib.is_key_pressed(@raylib.KeyOne)) ||
          (slot == 1 && @raylib.is_key_pressed(@raylib.KeyTwo)) ||
          (slot == 2 && @raylib.is_key_pressed(@raylib.KeyThree))
        if !key_hit {
          continue
        }

        let card = hand[slot]
        let cost = card_cost(card)
        if energy < cost {
          log = "Not enough energy for \{card_name(card)}."
          continue
        }

        energy = energy - cost
        match card {
          0 => {
            let (nhp, nblock) = deal_damage(enemy_hp, enemy_block, 6)
            enemy_hp = nhp
            enemy_block = nblock
            log = "Played Strike for 6."
          }
          1 => {
            player_block = player_block + 7
            log = "Played Guard (+7 block)."
          }
          2 => {
            let (nhp, nblock) = deal_damage(enemy_hp, enemy_block, 12)
            enemy_hp = nhp
            enemy_block = nblock
            log = "Played Burst for 12."
          }
          3 => {
            enemy_block = 0
            let (nhp, nblock) = deal_damage(enemy_hp, enemy_block, 4)
            enemy_hp = nhp
            enemy_block = nblock
            log = "Played Sap (break +4)."
          }
          _ => {
            player_hp = player_hp + 6
            if player_hp > 80 {
              player_hp = 80
            }
            log = "Played Repair (+6 hp)."
          }
        }

        if enemy_hp <= 0 {
          won = true
          break
        }

        ignore(hand.remove(slot))
        break
      }

      if !won && @raylib.is_key_pressed(@raylib.KeyE) {
        let (php, pblk, ehp, eblk, turn_log) = enemy_turn(
          player_hp, player_block, enemy_hp, enemy_block, turn_no,
        )
        player_hp = php
        player_block = pblk
        enemy_hp = ehp
        enemy_block = eblk
        log = turn_log

        turn_no = turn_no + 1
        energy = 3
        player_block = if player_block > 0 { player_block - 2 } else { 0 }
        enemy_block = if enemy_block > 0 { enemy_block - 2 } else { 0 }
        roll_hand(hand)
      }

      if player_hp <= 0 {
        lost = true
      }
      if enemy_hp <= 0 {
        won = true
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(18, 20, 30, 255))
    ignore(draw_backdrop_art())

    @draw.draw_text(
      "CARD DUEL 2026",
      24,
      20,
      34,
      @raylib.Color::new(150, 220, 255, 255),
    )
    @draw.draw_text("Turn \{turn_no}", 28, 60, 24, @raylib.raywhite)
    @draw.draw_text("Energy \{energy}", 160, 60, 24, @raylib.yellow)

    draw_duelist_panel(60, 120, 380, 170, true, player_hp, 80, player_block)
    draw_duelist_panel(540, 120, 380, 170, false, enemy_hp, 95, enemy_block)

    for i in 0..<hand.length() {
      let card = hand[i]
      draw_hand_card(i, card)
    }

    @draw.draw_text(
      "Keys: 1/2/3 play card, E end turn, R restart", 200, 580, 24, @raylib.gray,
    )
    @raylib.draw_rectangle(
      40,
      620,
      900,
      56,
      @raylib.Color::new(12, 14, 24, 220),
    )
    @raylib.draw_rectangle_lines(
      40,
      620,
      900,
      56,
      @raylib.Color::new(150, 190, 230, 80),
    )
    @draw.draw_text(log, 56, 638, 22, @raylib.raywhite)

    if won || lost {
      @raylib.draw_rectangle(
        290,
        250,
        420,
        120,
        @raylib.fade(@raylib.black, 0.78),
      )
      @draw.draw_text(
        if won {
          "VICTORY"
        } else {
          "DEFEAT"
        },
        415,
        287,
        46,
        if won {
          @raylib.lime
        } else {
          @raylib.red
        },
      )
      @draw.draw_text("Press R to rematch", 384, 336, 26, @raylib.raywhite)
    }

    @fps.draw()
    @raylib.end_drawing()
  }

  unload_assets()
  @draw.cleanup()
  @raylib.close_window()
}
