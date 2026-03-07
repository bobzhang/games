///|
/// Number of grid columns on the battle board.
let gw : Int = 7

///|
/// Number of grid rows on the battle board.
let gh : Int = 5

///|
/// Pixel size of each grid tile.
let tile : Int = 86

///|
/// Horizontal pixel offset for the grid origin.
let ox : Int = 120

///|
/// Vertical pixel offset for the grid origin.
let oy : Int = 120

///|
/// Screen width in pixels.
let sw : Int = 980

///|
/// Screen height in pixels.
let sh : Int = 680

///|
/// Phase constant indicating the preparation/placement phase.
let phase_prep : Int = 0

///|
/// Phase constant indicating the active battle phase.
let phase_battle : Int = 1

///|
/// Represents a combat unit with team, role, grid position, stats, and attack cooldown.
struct Piece {
  mut alive : Bool
  team : Int
  role : Int
  mut x : Int
  mut y : Int
  mut hp : Int
  atk : Int
  rng : Int
  mut cooldown : Float
}

///|
/// Returns the display name string for the given role integer.
fn role_name(role : Int) -> String {
  match role {
    0 => "Tank"
    1 => "Archer"
    _ => "Blade"
  }
}

///|
/// Returns the gold cost to place a unit of the given role.
fn role_cost(role : Int) -> Int {
  match role {
    0 => 5
    1 => 4
    _ => 4
  }
}

///|
/// Returns the base hit points for a unit of the given role.
fn role_hp(role : Int) -> Int {
  match role {
    0 => 24
    1 => 13
    _ => 16
  }
}

///|
/// Returns the base attack damage for a unit of the given role.
fn role_atk(role : Int) -> Int {
  match role {
    0 => 5
    1 => 6
    _ => 7
  }
}

///|
/// Returns the attack range in grid tiles for a unit of the given role.
fn role_rng(role : Int) -> Int {
  match role {
    0 => 1
    1 => 3
    _ => 1
  }
}

///|
/// Creates and returns a new Piece with stats derived from the given team, role, and grid position.
fn setup_piece(team : Int, role : Int, x : Int, y : Int) -> Piece {
  {
    alive: true,
    team,
    role,
    x,
    y,
    hp: role_hp(role),
    atk: role_atk(role),
    rng: role_rng(role),
    cooldown: 0.0,
  }
}

///|
/// Returns the Manhattan distance between two grid positions.
fn manhattan(ax : Int, ay : Int, bx : Int, by : Int) -> Int {
  (ax - bx).abs() + (ay - by).abs()
}

///|
/// Returns the index of the nearest enemy unit to the unit at the given index, or -1 if none exists.
fn find_target(units : Array[Piece], idx : Int) -> Int {
  let self = units[idx]
  for i in 0..<units.length(); best = -1, best_d = 1_000_000 {
    if i == idx || !units[i].alive || units[i].team == self.team {
      continue
    }
    let d = manhattan(self.x, self.y, units[i].x, units[i].y)
    if d < best_d {
      continue i, d
    }
  } nobreak {
    best
  }
}

///|
/// Returns true if any alive unit currently occupies the given grid position.
fn occupied(units : Array[Piece], x : Int, y : Int) -> Bool {
  for unit in units {
    if unit.alive && unit.x == x && unit.y == y {
      return true
    }
  }
  false
}

///|
/// Converts the placement board state into live Piece units for the player team.
fn copy_board_to_units(board : Array[Int], units : Array[Piece]) -> Unit {
  units.clear()
  for y in 0..<gh {
    for x in 0..<gw {
      let role = board[y * gw + x]
      if role >= 0 {
        units.push(setup_piece(0, role, x, y))
      }
    }
  }
}

///|
/// Spawns enemy units scaled to the current round number and appends them to the units array.
fn spawn_enemy_round(round : Int, units : Array[Piece]) -> Unit {
  let enemy_count = 2 + round
  for _ in 0..<enemy_count {
    let role = @raylib.get_random_value(0, 2)
    let ex = gw - 1 - @raylib.get_random_value(0, 1)
    let ey = @raylib.get_random_value(0, gh - 1)
    units.push(setup_piece(1, role, ex, ey))
  }
}

///|
/// Returns the count of alive units belonging to the specified team.
fn alive_team(units : Array[Piece], team : Int) -> Int {
  let mut n = 0
  for unit in units {
    if unit.alive && unit.team == team {
      n = n + 1
    }
  }
  n
}

///|
/// Runs the main game loop for Auto Chess Micro 2026, handling placement, battle simulation, and rendering.
fn main {
  @raylib.init_window(sw, sh, "Auto Chess Micro 2026")
  @raylib.set_target_fps(60)

  let board : Array[Int] = Array::make(gw * gh, -1)
  let units : Array[Piece] = []

  let mut gold = 12
  let mut life = 12
  let mut round = 1
  let mut selected_role = 0
  let mut phase = phase_prep
  let mut message = "Prep phase: choose role 1/2/3, click left side tiles, ENTER to fight."
  let mut won = false
  let mut lost = false

  while !@raylib.window_should_close() {
    let dt = @raylib.get_frame_time()

    if @raylib.is_key_pressed(@raylib.KeyR) {
      for i in 0..<board.length() {
        board[i] = -1
      }
      units.clear()
      gold = 12
      life = 12
      round = 1
      selected_role = 0
      phase = phase_prep
      message = "Prep phase reset."
      won = false
      lost = false
    }

    if !won && !lost {
      if phase == phase_prep {
        if @raylib.is_key_pressed(@raylib.KeyOne) {
          selected_role = 0
        }
        if @raylib.is_key_pressed(@raylib.KeyTwo) {
          selected_role = 1
        }
        if @raylib.is_key_pressed(@raylib.KeyThree) {
          selected_role = 2
        }

        if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
          let mx = @raylib.get_mouse_x()
          let my = @raylib.get_mouse_y()
          let gx = (mx - ox) / tile
          let gy = (my - oy) / tile
          if gx >= 0 && gx < 3 && gy >= 0 && gy < gh {
            let i = gy * gw + gx
            if board[i] == -1 {
              let c = role_cost(selected_role)
              if gold >= c {
                board[i] = selected_role
                gold = gold - c
                message = "Placed \{role_name(selected_role)}."
              } else {
                message = "Not enough gold."
              }
            } else {
              board[i] = -1
              gold = gold + 2
              message = "Removed unit (+2 gold refund)."
            }
          }
        }

        if @raylib.is_key_pressed(@raylib.KeyEnter) {
          copy_board_to_units(board, units)
          if alive_team(units, 0) == 0 {
            message = "Place at least one unit first."
          } else {
            spawn_enemy_round(round, units)
            phase = phase_battle
            message = "Battle started."
          }
        }
      } else {
        for i in 0..<units.length() {
          if !units[i].alive {
            continue
          }
          units[i].cooldown = units[i].cooldown - dt
          let target_i = find_target(units, i)
          if target_i < 0 {
            continue
          }
          let dist = manhattan(
            units[i].x,
            units[i].y,
            units[target_i].x,
            units[target_i].y,
          )
          if dist <= units[i].rng {
            if units[i].cooldown <= 0.0 {
              units[i].cooldown = 0.55
              units[target_i].hp = units[target_i].hp - units[i].atk
              if units[target_i].hp <= 0 {
                units[target_i].alive = false
              }
            }
          } else {
            // Move one step towards target if cell free.
            let mut nx = units[i].x
            let mut ny = units[i].y
            if (units[target_i].x - units[i].x).abs() >=
              (units[target_i].y - units[i].y).abs() {
              let sx = if units[target_i].x > units[i].x { 1 } else { -1 }
              nx = nx + sx
            } else {
              let sy = if units[target_i].y > units[i].y { 1 } else { -1 }
              ny = ny + sy
            }
            if nx >= 0 &&
              nx < gw &&
              ny >= 0 &&
              ny < gh &&
              !occupied(units, nx, ny) {
              units[i].x = nx
              units[i].y = ny
            }
          }
        }

        let a0 = alive_team(units, 0)
        let a1 = alive_team(units, 1)
        if a0 == 0 || a1 == 0 {
          if a1 == 0 {
            gold = gold + 6 + round
            round = round + 1
            message = "Victory! Bonus gold gained."
          } else {
            life = life - 1
            gold = gold + 4
            message = "Defeat! You lose 1 life."
          }
          units.clear()
          phase = phase_prep
        }
      }

      if life <= 0 {
        lost = true
      }
      if round > 10 {
        won = true
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(18, 20, 28, 255))

    @raylib.draw_text("AUTO CHESS MICRO 2026", 22, 18, 34, @raylib.skyblue)
    @raylib.draw_text("Round \{round}", 24, 58, 24, @raylib.raywhite)
    @raylib.draw_text("Gold \{gold}", 170, 58, 24, @raylib.gold)
    @raylib.draw_text("Life \{life}", 300, 58, 24, @raylib.lime)

    for y in 0..<gh {
      for x in 0..<gw {
        let px = ox + x * tile
        let py = oy + y * tile
        let left_side = x < 3
        @raylib.draw_rectangle(
          px,
          py,
          tile - 2,
          tile - 2,
          if left_side {
            @raylib.Color::new(38, 52, 70, 255)
          } else {
            @raylib.Color::new(70, 38, 44, 255)
          },
        )
      }
    }

    if phase == phase_prep {
      for y in 0..<gh {
        for x in 0..<gw {
          let role = board[y * gw + x]
          if role >= 0 {
            let px = ox + x * tile
            let py = oy + y * tile
            let col = if role == 0 {
              @raylib.darkblue
            } else if role == 1 {
              @raylib.green
            } else {
              @raylib.orange
            }
            @raylib.draw_rectangle(px + 12, py + 12, tile - 26, tile - 26, col)
          }
        }
      }
    } else {
      for unit in units {
        if unit.alive {
          let px = ox + unit.x * tile
          let py = oy + unit.y * tile
          let col = if unit.team == 0 {
            if unit.role == 0 {
              @raylib.darkblue
            } else if unit.role == 1 {
              @raylib.green
            } else {
              @raylib.orange
            }
          } else {
            @raylib.red
          }
          @raylib.draw_rectangle(px + 12, py + 12, tile - 26, tile - 26, col)
          @raylib.draw_text(
            "\{unit.hp}",
            px + 18,
            py + 16,
            22,
            @raylib.raywhite,
          )
        }
      }
    }

    @raylib.draw_text(
      "1 Tank(5)  2 Archer(4)  3 Blade(4)  ENTER start battle  R restart", 180, 580,
      22, @raylib.gray,
    )
    @raylib.draw_rectangle(
      40,
      620,
      900,
      44,
      @raylib.Color::new(24, 24, 34, 255),
    )
    @raylib.draw_text(message, 52, 634, 22, @raylib.raywhite)

    if won || lost {
      @raylib.draw_rectangle(
        300,
        250,
        420,
        120,
        @raylib.fade(@raylib.black, 0.8),
      )
      @raylib.draw_text(
        if won {
          "CHAMPION"
        } else {
          "ELIMINATED"
        },
        380,
        286,
        46,
        if won {
          @raylib.lime
        } else {
          @raylib.red
        },
      )
      @raylib.draw_text("Press R to restart", 390, 334, 26, @raylib.raywhite)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
