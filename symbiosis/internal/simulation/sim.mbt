///|
pub fn simulate_move(game : @types.Game, input : @types.MoveInput) -> Unit {
  match game.current_level {
    None => ()
    Some(level) => {
      // Save snapshot before move
      let snap = @types.make_snapshot(game)
      game.history.push(snap)
      game.move_count += 1
      match input {
        Wait => {
          // Both stay in place - still check switches and gems
          check_switches(game, level)
          check_gems(game, level)
        }
        DirInput(dir) => {
          let luna_dir = dir
          let sol_dir = @types.mirror_direction(dir)
          let luna_delta = @types.direction_delta(luna_dir)
          let sol_delta = @types.direction_delta(sol_dir)
          // Check anchor desync
          let luna_on_anchor = game.luna.on_anchor
          let sol_on_anchor = game.sol.on_anchor
          // Reset anchor flags
          game.luna.on_anchor = false
          game.sol.on_anchor = false
          // Move Luna (unless anchored)
          if !luna_on_anchor {
            let luna_target = @types.vec2i_add(game.luna.pos, luna_delta)
            if can_move_to(level.floor_tiles, luna_target, game.door_states) {
              game.luna.pos = luna_target
              // Ice sliding
              slide_on_ice(
                game.luna,
                level.floor_tiles,
                luna_delta,
                game.door_states,
              )
            }
          }
          // Move Sol (unless anchored)
          if !sol_on_anchor {
            let sol_target = @types.vec2i_add(game.sol.pos, sol_delta)
            if can_move_to(level.ceiling_tiles, sol_target, game.door_states) {
              game.sol.pos = sol_target
              // Ice sliding
              slide_on_ice(
                game.sol,
                level.ceiling_tiles,
                sol_delta,
                game.door_states,
              )
            }
          }
          // Check anchor tiles for next turn
          match @types.tile_at(level.floor_tiles, game.luna.pos) {
            Anchor => game.luna.on_anchor = true
            _ => ()
          }
          match @types.tile_at(level.ceiling_tiles, game.sol.pos) {
            Anchor => game.sol.on_anchor = true
            _ => ()
          }
          // Check switches
          check_switches(game, level)
          // Check gems
          check_gems(game, level)
          // Check pits
          if check_pit(level.floor_tiles, game.luna.pos) {
            game.luna.alive = false
            game.play_state = Failed
            game.message = "Luna fell into a pit!"
            game.message_timer = 2.0
            return
          }
          if check_pit(level.ceiling_tiles, game.sol.pos) {
            game.sol.alive = false
            game.play_state = Failed
            game.message = "Sol fell into a pit!"
            game.message_timer = 2.0
            return
          }
        }
      }
      // Check exit
      match @types.tile_at(level.floor_tiles, game.luna.pos) {
        Exit => game.luna.reached_exit = true
        _ => game.luna.reached_exit = false
      }
      match @types.tile_at(level.ceiling_tiles, game.sol.pos) {
        Exit => game.sol.reached_exit = true
        _ => game.sol.reached_exit = false
      }
      // Check goal
      if check_goal(game, level) {
        game.play_state = Won
        let stars = @types.compute_stars(game)
        let w = level.world
        let l = level.index
        if w >= 0 &&
          w < game.scores.length() &&
          l >= 0 &&
          l < game.scores[w].length() {
          let score = game.scores[w][l]
          score.completed = true
          if game.move_count < score.best_moves {
            score.best_moves = game.move_count
          }
          if stars > score.stars {
            score.stars = stars
          }
          if @types.all_gems_collected(game) {
            score.gem_collected = true
          }
        }
      }
      // Check max moves
      if game.move_count >= @types.max_moves && game.play_state == Active {
        game.play_state = Failed
        game.message = "Out of moves!"
        game.message_timer = 2.0
      }
    }
  }
}

///|
fn can_move_to(
  grid : Array[Array[@types.TileKind]],
  pos : @types.Vec2i,
  door_states : Array[Bool],
) -> Bool {
  if !@types.in_bounds(pos) {
    return false
  }
  let tile = @types.tile_at(grid, pos)
  @types.is_walkable(tile, door_states)
}

///|
fn slide_on_ice(
  character : @types.Character,
  grid : Array[Array[@types.TileKind]],
  delta : @types.Vec2i,
  door_states : Array[Bool],
) -> Unit {
  // If current tile is ice, keep sliding
  let mut count = 0
  while count < 20 {
    match @types.tile_at(grid, character.pos) {
      Ice => {
        let next = @types.vec2i_add(character.pos, delta)
        if can_move_to(grid, next, door_states) {
          character.pos = next
          count += 1
        } else {
          break
        }
      }
      _ => break
    }
  }
}

///|
fn check_switches(game : @types.Game, level : @types.Level) -> Unit {
  // Check if Luna is on a switch
  match @types.tile_at(level.floor_tiles, game.luna.pos) {
    Switch(switch_id) => toggle_linked_doors(game, level, switch_id)
    _ => ()
  }
  // Check if Sol is on a switch
  match @types.tile_at(level.ceiling_tiles, game.sol.pos) {
    Switch(switch_id) => toggle_linked_doors(game, level, switch_id)
    _ => ()
  }
}

///|
fn toggle_linked_doors(
  game : @types.Game,
  level : @types.Level,
  switch_id : Int,
) -> Unit {
  for i in 0..<level.switch_links.length() {
    let link = level.switch_links[i]
    if link.switch_id == switch_id {
      let did = link.door_id
      if did >= 0 && did < game.door_states.length() {
        game.door_states[did] = !game.door_states[did]
      }
    }
  }
}

///|
fn check_gems(game : @types.Game, level : @types.Level) -> Unit {
  // Check Luna picking up floor gems
  for i in 0..<level.gems.length() {
    if i < game.floor_gems_collected.length() && !game.floor_gems_collected[i] {
      if level.gems[i] == game.luna.pos {
        game.floor_gems_collected[i] = true
      }
    }
  }
  // Check Sol picking up ceiling gems
  for i in 0..<level.ceiling_gems.length() {
    if i < game.ceiling_gems_collected.length() &&
      !game.ceiling_gems_collected[i] {
      if level.ceiling_gems[i] == game.sol.pos {
        game.ceiling_gems_collected[i] = true
      }
    }
  }
}

///|
fn check_pit(grid : Array[Array[@types.TileKind]], pos : @types.Vec2i) -> Bool {
  match @types.tile_at(grid, pos) {
    Pit => true
    _ => false
  }
}

///|
fn check_goal(game : @types.Game, level : @types.Level) -> Bool {
  match level.goal {
    BothExit => game.luna.reached_exit && game.sol.reached_exit
    BothSwitch =>
      @types.is_on_switch(level.floor_tiles, game.luna.pos) &&
      @types.is_on_switch(level.ceiling_tiles, game.sol.pos)
    ExitInMoves(n) =>
      game.luna.reached_exit && game.sol.reached_exit && game.move_count <= n
  }
}

///|
pub fn undo_move(game : @types.Game) -> Unit {
  if game.history.length() > 0 {
    let snap = game.history.unsafe_pop()
    @types.restore_snapshot(game, snap)
    game.move_count -= 1
    game.play_state = Active
    game.luna.alive = true
    game.sol.alive = true
    game.message = ""
    game.message_timer = 0.0
  }
}

///|
pub fn restart_level(game : @types.Game) -> Unit {
  match game.current_level {
    None => ()
    Some(level) => @types.init_level(game, level)
  }
}
