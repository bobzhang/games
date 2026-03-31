///|
pub fn update(game : @types.Game, dt : Float) -> Unit {
  game.frame_count += 1
  game.anim_timer += dt
  // Decay message timer
  if game.message_timer > 0.0 {
    game.message_timer -= dt
    if game.message_timer < 0.0 {
      game.message_timer = 0.0
      game.message_text = ""
    }
  }
  match game.screen {
    Title => update_title(game)
    Battle => update_battle(game, dt)
    EnemyTurn => update_enemy_turn(game, dt)
    Reward => update_reward(game)
    GameOver | Victory => update_end_screen(game)
    _ => ()
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    setup_battle(game, 1)
    game.screen = Battle
    game.message_text = "Deploy your mechs. Arrow keys + Enter."
    game.message_timer = 3.0
  }
}

///|
fn setup_battle(game : @types.Game, mission_id : Int) -> Unit {
  let objective : @types.Objective = match mission_id % 3 {
    0 => DefendGrid(5)
    1 => Survive(6)
    _ => Assassinate(0)
  }
  let battle = @types.new_battle(objective)
  // Place terrain based on mission
  place_terrain(battle, mission_id)
  // Place 3 player mechs in deployment zone (left columns)
  let classes : Array[@types.MechClass] = [Vanguard, Striker, Sentinel]
  for i = 0; i < 3; i = i + 1 {
    let stats = @content.get_mech_stats(classes[i])
    let px = 1
    let py = 1 + i * 3
    let u : @types.CombatUnit = {
      id: i,
      active: true,
      team: Player,
      x: px,
      y: py,
      hp: stats.hp,
      max_hp: stats.hp,
      shield: 0,
      heat: 0,
      max_heat: stats.max_heat,
      stunned: false,
      moved_this_turn: false,
      acted_this_turn: false,
      mech_class: classes[i],
      enemy_type: Rammer,
      intent: March(px, py),
    }
    battle.units.push(u)
    if battle.grid.in_bounds(px, py) {
      battle.grid.set(
        px,
        py,
        { ..battle.grid.get(px, py), occupied_by: u.id },
      )
    }
  }
  // Spawn enemies based on mission
  spawn_enemies(battle, mission_id)
  // Generate initial intents
  generate_enemy_intents(battle)
  game.battle = Some(battle)
}

///|
fn place_terrain(battle : @types.BattleState, mission_id : Int) -> Unit {
  // Set some tiles based on mission layout
  let seed : Ref[UInt] = { val: (mission_id * 7919 + 1234).reinterpret_as_uint() }
  // Add walls
  let wall_count = 3 + mission_id % 4
  for i = 0; i < wall_count; i = i + 1 {
    let wx = @types.rand_range(seed, 2, 6)
    let wy = @types.rand_range(seed, 0, @types.grid_h - 1)
    if battle.grid.in_bounds(wx, wy) {
      battle.grid.set(wx, wy, { kind: Wall, hazard: None, occupied_by: -1 })
    }
  }
  // Add hazard tiles
  if mission_id >= 2 {
    let hx = @types.rand_range(seed, 3, 5)
    let hy = @types.rand_range(seed, 1, 6)
    if battle.grid.in_bounds(hx, hy) {
      battle.grid.set(hx, hy, { kind: Lava, hazard: Fire, occupied_by: -1 })
    }
  }
  if mission_id >= 3 {
    let cx = @types.rand_range(seed, 3, 6)
    let cy = @types.rand_range(seed, 0, 7)
    if battle.grid.in_bounds(cx, cy) {
      battle.grid.set(
        cx,
        cy,
        { kind: Chasm, hazard: None, occupied_by: -1 },
      )
    }
  }
  // Add water/ice patches
  if mission_id % 2 == 0 {
    let ix = @types.rand_range(seed, 2, 5)
    let iy = @types.rand_range(seed, 2, 5)
    if battle.grid.in_bounds(ix, iy) {
      battle.grid.set(ix, iy, { kind: Water, hazard: None, occupied_by: -1 })
    }
  } else {
    let ix = @types.rand_range(seed, 2, 5)
    let iy = @types.rand_range(seed, 2, 5)
    if battle.grid.in_bounds(ix, iy) {
      battle.grid.set(ix, iy, { kind: Ice, hazard: None, occupied_by: -1 })
    }
  }
}

///|
fn spawn_enemies(battle : @types.BattleState, mission_id : Int) -> Unit {
  let base_count = 3 + mission_id / 2
  let enemy_count = if base_count > 6 { 6 } else { base_count }
  let all_types : Array[@types.EnemyType] = [
    Rammer, Artillery, Leaper, BeamTurret, MineLayer, ShieldDrone, Splitter,
  ]
  let seed : Ref[UInt] = { val: (mission_id * 31337 + 42).reinterpret_as_uint() }
  for i = 0; i < enemy_count; i = i + 1 {
    let eid = 3 + i
    let etype_idx = @types.rand_range(seed, 0, all_types.length() - 1)
    let etype = all_types[etype_idx]
    let ehp = @content.get_enemy_hp(etype)
    // Place enemies on right side of grid
    let mut ex = @types.rand_range(seed, 5, 7)
    let mut ey = @types.rand_range(seed, 0, @types.grid_h - 1)
    // Find unoccupied floor tile
    let mut attempts = 0
    while attempts < 20 {
      if battle.grid.in_bounds(ex, ey) {
        let tile = battle.grid.get(ex, ey)
        if tile.kind == Floor && tile.occupied_by < 0 {
          break
        }
      }
      ex = @types.rand_range(seed, 5, 7)
      ey = @types.rand_range(seed, 0, @types.grid_h - 1)
      attempts += 1
    }
    let eu : @types.CombatUnit = {
      id: eid,
      active: true,
      team: Enemy,
      x: ex,
      y: ey,
      hp: ehp,
      max_hp: ehp,
      shield: 0,
      heat: 0,
      max_heat: 0,
      stunned: false,
      moved_this_turn: false,
      acted_this_turn: false,
      mech_class: Vanguard,
      enemy_type: etype,
      intent: March(ex, ey),
    }
    battle.units.push(eu)
    if battle.grid.in_bounds(ex, ey) {
      battle.grid.set(
        ex,
        ey,
        { ..battle.grid.get(ex, ey), occupied_by: eu.id },
      )
    }
  }
  // Boss on higher missions
  if mission_id >= 4 {
    let bid = battle.units.length()
    let bx = 7
    let by = 3
    if battle.grid.in_bounds(bx, by) &&
      battle.grid.get(bx, by).occupied_by < 0 {
      let bu : @types.CombatUnit = {
        id: bid,
        active: true,
        team: Enemy,
        x: bx,
        y: by,
        hp: @content.get_enemy_hp(Boss),
        max_hp: @content.get_enemy_hp(Boss),
        shield: 2,
        heat: 0,
        max_heat: 0,
        stunned: false,
        moved_this_turn: false,
        acted_this_turn: false,
        mech_class: Vanguard,
        enemy_type: Boss,
        intent: March(bx, by),
      }
      battle.units.push(bu)
      battle.grid.set(
        bx,
        by,
        { ..battle.grid.get(bx, by), occupied_by: bu.id },
      )
    }
  }
}

///|
fn generate_enemy_intents(battle : @types.BattleState) -> Unit {
  let seed : Ref[UInt] = { val: (battle.turn * 9973 + 5381).reinterpret_as_uint() }
  for i = 0; i < battle.units.length(); i = i + 1 {
    let u = battle.units[i]
    if u.team != Enemy || !u.active || u.hp <= 0 {
      continue i + 1
    }
    // Find nearest player mech
    let mut nearest_dist = 999
    let mut nearest_x = 0
    let mut nearest_y = 0
    for j = 0; j < battle.units.length(); j = j + 1 {
      let p = battle.units[j]
      if p.team == Player && p.active && p.hp > 0 {
        let d = @types.manhattan(u.x, u.y, p.x, p.y)
        if d < nearest_dist {
          nearest_dist = d
          nearest_x = p.x
          nearest_y = p.y
        }
      }
    }
    u.intent = match u.enemy_type {
      Rammer => {
        // March towards nearest player
        let dx = if nearest_x > u.x {
          1
        } else if nearest_x < u.x {
          -1
        } else {
          0
        }
        let dy = if nearest_y > u.y {
          1
        } else if nearest_y < u.y {
          -1
        } else {
          0
        }
        let tx = (u.x + dx).clamp(min=0, max=@types.grid_w - 1)
        let ty = (u.y + dy).clamp(min=0, max=@types.grid_h - 1)
        March(tx, ty)
      }
      Artillery => {
        // Fire line towards nearest player
        let dx = if nearest_x > u.x {
          1
        } else if nearest_x < u.x {
          -1
        } else {
          0
        }
        let dy = if nearest_y > u.y {
          1
        } else if nearest_y < u.y {
          -1
        } else {
          0
        }
        // Prefer cardinal direction
        let (fdx, fdy) = if @types.abs_int(dx) >= @types.abs_int(dy) {
          (dx, 0)
        } else {
          (0, dy)
        }
        FireLine(fdx, fdy, 5)
      }
      BeamTurret => {
        // Fire line in direction of nearest player (cardinal)
        let dx = nearest_x - u.x
        let dy = nearest_y - u.y
        let (fdx, fdy) = if @types.abs_int(dx) >= @types.abs_int(dy) {
          (if dx >= 0 { 1 } else { -1 }, 0)
        } else {
          (0, if dy >= 0 { 1 } else { -1 })
        }
        FireLine(fdx, fdy, @types.grid_w)
      }
      Leaper => {
        // Leap to adjacent tile of nearest player
        let lx = nearest_x + @types.rand_range(seed, -1, 1)
        let ly = nearest_y + @types.rand_range(seed, -1, 1)
        Leap(
          lx.clamp(min=0, max=@types.grid_w - 1),
          ly.clamp(min=0, max=@types.grid_h - 1),
        )
      }
      MineLayer => {
        // Place mine at random adjacent tile
        let mx = u.x + @types.rand_range(seed, -2, 2)
        let my = u.y + @types.rand_range(seed, -2, 2)
        MinePlace(
          mx.clamp(min=0, max=@types.grid_w - 1),
          my.clamp(min=0, max=@types.grid_h - 1),
        )
      }
      ShieldDrone => {
        // March towards nearest ally enemy to shield
        let mut ally_x = u.x
        let mut ally_y = u.y
        let mut ally_dist = 999
        for j = 0; j < battle.units.length(); j = j + 1 {
          let a = battle.units[j]
          if a.team == Enemy && a.active && a.hp > 0 && a.id != u.id {
            let d = @types.manhattan(u.x, u.y, a.x, a.y)
            if d < ally_dist {
              ally_dist = d
              ally_x = a.x
              ally_y = a.y
            }
          }
        }
        let dx = if ally_x > u.x {
          1
        } else if ally_x < u.x {
          -1
        } else {
          0
        }
        let dy = if ally_y > u.y {
          1
        } else if ally_y < u.y {
          -1
        } else {
          0
        }
        March(
          (u.x + dx).clamp(min=0, max=@types.grid_w - 1),
          (u.y + dy).clamp(min=0, max=@types.grid_h - 1),
        )
      }
      Splitter => {
        // Area blast around self
        AreaBlast(u.x, u.y, 1)
      }
      Boss => {
        // Boss alternates between area blast and charge
        if battle.turn % 2 == 0 {
          AreaBlast(nearest_x, nearest_y, 1)
        } else {
          let dx = if nearest_x > u.x {
            1
          } else if nearest_x < u.x {
            -1
          } else {
            0
          }
          let dy = if nearest_y > u.y {
            1
          } else if nearest_y < u.y {
            -1
          } else {
            0
          }
          Charge(dx, dy)
        }
      }
    }
  }
}

///|
fn update_battle(game : @types.Game, _dt : Float) -> Unit {
  let battle = match game.battle {
    Some(b) => b
    None => return
  }
  // --- Cursor movement ---
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    battle.cursor_x = (battle.cursor_x + 1).clamp(
      min=0,
      max=@types.grid_w - 1,
    )
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    battle.cursor_x = (battle.cursor_x - 1).clamp(
      min=0,
      max=@types.grid_w - 1,
    )
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    battle.cursor_y = (battle.cursor_y + 1).clamp(
      min=0,
      max=@types.grid_h - 1,
    )
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    battle.cursor_y = (battle.cursor_y - 1).clamp(
      min=0,
      max=@types.grid_h - 1,
    )
  }
  // --- Tab to cycle selected mech ---
  if @raylib.is_key_pressed(@raylib.KeyTab) {
    cycle_selected_mech(battle)
  }
  // --- Update hover info ---
  game.hover_info = get_hover_info(battle, battle.cursor_x, battle.cursor_y)
  // --- Enter to confirm action ---
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    handle_enter(game, battle)
  }
  // --- Space to wait/end turn ---
  if @raylib.is_key_pressed(@raylib.KeySpace) {
    handle_wait(game, battle)
  }
  // --- Q to overclock ---
  if @raylib.is_key_pressed(@raylib.KeyQ) {
    handle_overclock(game, battle)
  }
  // --- P to push ---
  if @raylib.is_key_pressed(@raylib.KeyP) {
    handle_push(game, battle)
  }
  // --- Escape to cancel/undo ---
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    handle_cancel(game, battle)
  }
}

///|
fn cycle_selected_mech(battle : @types.BattleState) -> Unit {
  let player_ids = get_player_ids(battle)
  if player_ids.length() == 0 {
    return
  }
  // Find current index
  let mut current_idx = 0
  for i = 0; i < player_ids.length(); i = i + 1 {
    if player_ids[i] == battle.selected_mech {
      current_idx = i
    }
  }
  // Cycle to next that hasn't acted
  let mut next_idx = (current_idx + 1) % player_ids.length()
  let mut checked = 0
  while checked < player_ids.length() {
    let uid = player_ids[next_idx]
    if uid < battle.units.length() {
      let u = battle.units[uid]
      if u.active && u.hp > 0 && !u.acted_this_turn {
        battle.selected_mech = uid
        // Move cursor to mech position
        battle.cursor_x = u.x
        battle.cursor_y = u.y
        return
      }
    }
    next_idx = (next_idx + 1) % player_ids.length()
    checked += 1
  }
  // All acted, just cycle normally
  let next = (current_idx + 1) % player_ids.length()
  battle.selected_mech = player_ids[next]
}

///|
fn get_player_ids(battle : @types.BattleState) -> Array[Int] {
  let ids : Array[Int] = []
  for i = 0; i < battle.units.length(); i = i + 1 {
    if battle.units[i].team == Player && battle.units[i].active &&
      battle.units[i].hp > 0 {
      ids.push(i)
    }
  }
  ids
}

///|
fn get_selected_unit(
  battle : @types.BattleState,
) -> @types.CombatUnit? {
  let sid = battle.selected_mech
  if sid >= 0 && sid < battle.units.length() {
    let u = battle.units[sid]
    if u.active && u.hp > 0 && u.team == Player {
      return Some(u)
    }
  }
  None
}

///|
/// Select the best ability_id for a mech class based on distance to target.
/// Vanguard: 0=Ram (adjacent/close), 1=Tractor Beam (range)
/// Striker:  0=Blade (adjacent), 1=Dash Strike (range)
/// Sentinel: 0=Cannon (range), 1=Artillery (area/far)
fn select_ability_id(class_ : @types.MechClass, dist : Int) -> Int {
  match class_ {
    Vanguard => if dist <= 1 { 0 } else { 1 }
    Striker => if dist <= 1 { 0 } else { 1 }
    Sentinel => if dist <= 4 { 0 } else { 1 }
  }
}

///|
/// Encode a (dx, dy) direction delta into an integer.
/// 0=North, 1=South, 2=East, 3=West.
fn encode_direction(dx : Int, dy : Int) -> Int {
  if @types.abs_int(dy) > @types.abs_int(dx) {
    if dy < 0 { 0 } else { 1 }
  } else {
    if dx > 0 { 2 } else { 3 }
  }
}

///|
fn handle_enter(game : @types.Game, battle : @types.BattleState) -> Unit {
  let mech = match get_selected_unit(battle) {
    Some(u) => u
    None => return
  }
  if mech.acted_this_turn {
    game.message_text = "Mech already acted this turn."
    game.message_timer = 1.5
    return
  }
  let tx = battle.cursor_x
  let ty = battle.cursor_y
  // Check if cursor is on an enemy -> attack
  let target_id = find_unit_at(battle, tx, ty)
  match target_id {
    Some(tid) => {
      let target = battle.units[tid]
      if target.team == Enemy && target.active && target.hp > 0 {
        // Attack command - auto select best ability based on class and range
        let stats = @content.get_mech_stats(mech.mech_class)
        let dist = @types.manhattan(mech.x, mech.y, tx, ty)
        if dist <= stats.ability_range {
          let ability_id = select_ability_id(mech.mech_class, dist)
          issue_command(game, battle, Attack(ability_id, tx, ty))
        } else {
          game.message_text = "Target out of range (\{dist}/\{stats.ability_range})"
          game.message_timer = 1.5
        }
      } else if target.team == Player {
        // Clicked on own mech - select it
        battle.selected_mech = tid
      }
    }
    None => {
      // Empty tile - move command
      let tile = battle.grid.get(tx, ty)
      if tile.kind == Wall || tile.kind == Chasm {
        game.message_text = "Cannot move there."
        game.message_timer = 1.0
        return
      }
      let stats = @content.get_mech_stats(mech.mech_class)
      let dist = @types.manhattan(mech.x, mech.y, tx, ty)
      if dist <= stats.move_range && dist > 0 {
        issue_command(game, battle, Move(tx, ty))
      } else if dist == 0 {
        game.message_text = "Already there."
        game.message_timer = 1.0
      } else {
        game.message_text = "Too far (\{dist}/\{stats.move_range})"
        game.message_timer = 1.5
      }
    }
  }
}

///|
fn handle_wait(game : @types.Game, battle : @types.BattleState) -> Unit {
  let mech = match get_selected_unit(battle) {
    Some(u) => u
    None => {
      // All mechs acted, transition to enemy turn
      try_end_player_turn(game, battle)
      return
    }
  }
  if mech.acted_this_turn {
    // Try end turn if all acted
    try_end_player_turn(game, battle)
    return
  }
  issue_command(game, battle, Wait)
}

///|
fn handle_overclock(
  game : @types.Game,
  battle : @types.BattleState,
) -> Unit {
  let mech = match get_selected_unit(battle) {
    Some(u) => u
    None => return
  }
  if mech.heat + @types.overclock_heat_cost > mech.max_heat {
    game.message_text = "Too much heat to overclock!"
    game.message_timer = 1.5
    return
  }
  // Overclock: reset acted flag, add heat
  mech.heat += @types.overclock_heat_cost
  mech.acted_this_turn = false
  mech.moved_this_turn = false
  game.message_text = "Overclocked! Heat: \{mech.heat}/\{mech.max_heat}"
  game.message_timer = 2.0
}

///|
fn handle_push(game : @types.Game, battle : @types.BattleState) -> Unit {
  let mech = match get_selected_unit(battle) {
    Some(u) => u
    None => return
  }
  if mech.acted_this_turn {
    game.message_text = "Mech already acted."
    game.message_timer = 1.0
    return
  }
  let tx = battle.cursor_x
  let ty = battle.cursor_y
  // Must be adjacent
  let dist = @types.manhattan(mech.x, mech.y, tx, ty)
  if dist != 1 {
    game.message_text = "Push target must be adjacent."
    game.message_timer = 1.5
    return
  }
  let target_id = find_unit_at(battle, tx, ty)
  match target_id {
    Some(_tid) => {
      // Compute push direction from mech position toward target
      let dx = tx - mech.x
      let dy = ty - mech.y
      // Encode direction: 0=N, 1=S, 2=E, 3=W
      let dir = encode_direction(dx, dy)
      // Let the sim resolver handle the actual push effect
      issue_command(game, battle, Push(tx, ty, dir))
    }
    None => {
      game.message_text = "No unit to push there."
      game.message_timer = 1.0
    }
  }
}

///|
fn handle_cancel(game : @types.Game, battle : @types.BattleState) -> Unit {
  if battle.player_commands.length() > 0 {
    // Undo last command
    let _cmd = battle.player_commands.pop()
    // Un-act the previous mech
    let prev_idx = battle.player_commands.length()
    let player_ids = get_player_ids(battle)
    if prev_idx < player_ids.length() {
      let uid = player_ids[prev_idx]
      if uid < battle.units.length() {
        battle.units[uid].acted_this_turn = false
        battle.units[uid].moved_this_turn = false
        battle.selected_mech = uid
      }
    }
    game.message_text = "Command undone."
    game.message_timer = 1.0
  } else {
    game.message_text = "Nothing to undo."
    game.message_timer = 1.0
  }
}

///|
fn issue_command(
  game : @types.Game,
  battle : @types.BattleState,
  cmd : @types.Command,
) -> Unit {
  battle.player_commands.push(cmd)
  let sid = battle.selected_mech
  if sid < battle.units.length() {
    battle.units[sid].acted_this_turn = true
    match cmd {
      Move(_, _) => battle.units[sid].moved_this_turn = true
      _ => ()
    }
  }
  // Check if all player mechs have acted
  let all_acted = check_all_acted(battle)
  if all_acted {
    // Auto-execute all commands and transition to enemy turn
    execute_player_commands(game, battle)
  } else {
    // Advance to next unacted mech
    advance_to_next_mech(battle)
    let stats = match get_selected_unit(battle) {
      Some(u) => @content.get_mech_stats(u.mech_class)
      None => @content.get_mech_stats(Vanguard)
    }
    game.message_text = "\{stats.name}: choose action"
    game.message_timer = 2.0
  }
}

///|
fn check_all_acted(battle : @types.BattleState) -> Bool {
  let ids = get_player_ids(battle)
  for i = 0; i < ids.length(); i = i + 1 {
    let u = battle.units[ids[i]]
    if !u.acted_this_turn {
      return false
    }
  }
  true
}

///|
fn advance_to_next_mech(battle : @types.BattleState) -> Unit {
  let ids = get_player_ids(battle)
  for i = 0; i < ids.length(); i = i + 1 {
    let u = battle.units[ids[i]]
    if !u.acted_this_turn {
      battle.selected_mech = ids[i]
      battle.cursor_x = u.x
      battle.cursor_y = u.y
      return
    }
  }
}

///|
fn execute_player_commands(
  game : @types.Game,
  battle : @types.BattleState,
) -> Unit {
  // simulate_turn writes directly to battle.turn_log; no need to append
  let _ = @sim.simulate_turn(battle, battle.player_commands)
  battle.player_commands = []
  battle.phase = EnemyTurn
  game.screen = EnemyTurn
  game.anim_timer = 0.0
}

///|
fn try_end_player_turn(
  game : @types.Game,
  battle : @types.BattleState,
) -> Unit {
  // Fill remaining commands with Wait
  let ids = get_player_ids(battle)
  for i = 0; i < ids.length(); i = i + 1 {
    if !battle.units[ids[i]].acted_this_turn {
      battle.player_commands.push(Wait)
      battle.units[ids[i]].acted_this_turn = true
    }
  }
  execute_player_commands(game, battle)
}

///|
fn update_enemy_turn(game : @types.Game, _dt : Float) -> Unit {
  let battle = match game.battle {
    Some(b) => b
    None => return
  }
  // simulate_turn already resolved everything (player commands, enemy intents,
  // hazards, cleanup, conditions, new intent generation, and turn increment).
  // This state just serves as an animation delay so the player can see results.
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    game.anim_timer > 1.5 {
    // Check for game-over / victory set by simulate_turn
    match battle.phase {
      GameOver => {
        game.screen = GameOver
        return
      }
      Victory => {
        game.screen = Reward
        game.message_text = "Mission complete! Choose reward."
        game.message_timer = 3.0
        return
      }
      _ => ()
    }
    // Transition back to player turn
    battle.phase = Battle
    game.screen = Battle
    game.anim_timer = 0.0
    // Select first alive mech
    battle.selected_mech = 0
    let ids = get_player_ids(battle)
    if ids.length() > 0 {
      battle.selected_mech = ids[0]
      battle.cursor_x = battle.units[ids[0]].x
      battle.cursor_y = battle.units[ids[0]].y
    }
    game.message_text = "Turn \{battle.turn} - Plan your moves"
    game.message_timer = 2.0
  }
}

///|
fn find_unit_at(
  battle : @types.BattleState,
  x : Int,
  y : Int,
) -> Int? {
  if !battle.grid.in_bounds(x, y) {
    return None
  }
  let tile = battle.grid.get(x, y)
  if tile.occupied_by >= 0 && tile.occupied_by < battle.units.length() {
    Some(tile.occupied_by)
  } else {
    None
  }
}

///|
fn update_reward(game : @types.Game) -> Unit {
  // Three reward choices: 1=Repair, 2=Augment, 3=Power
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    // Repair: heal all mechs to full
    match game.battle {
      Some(b) => {
        for i = 0; i < b.units.length(); i = i + 1 {
          let u = b.units[i]
          if u.team == Player && u.active {
            u.hp = u.max_hp
            u.shield = 0
            u.heat = 0
          }
        }
      }
      None => ()
    }
    game.run.missions_completed += 1
    game.message_text = "All mechs repaired!"
    game.message_timer = 2.0
    advance_mission(game)
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) {
    // Augment: +1 max HP to all mechs
    match game.battle {
      Some(b) => {
        for i = 0; i < b.units.length(); i = i + 1 {
          let u = b.units[i]
          if u.team == Player {
            u.max_hp += 1
            u.hp += 1
          }
        }
      }
      None => ()
    }
    game.run.missions_completed += 1
    game.message_text = "Max HP increased!"
    game.message_timer = 2.0
    advance_mission(game)
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) {
    // Grid power: increase grid power
    game.run.grid_power += 1
    game.run.missions_completed += 1
    game.message_text = "Grid power increased!"
    game.message_timer = 2.0
    advance_mission(game)
  }
}

///|
fn advance_mission(game : @types.Game) -> Unit {
  game.run.current_mission += 1
  if game.run.current_mission >= 5 {
    // Victory - completed all missions
    game.screen = Victory
    match game.battle {
      Some(b) => b.phase = Victory
      None => ()
    }
  } else {
    // Start next battle
    setup_battle(game, game.run.current_mission)
    game.screen = Battle
  }
}

///|
fn update_end_screen(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = Title
    game.battle = None
    game.anim_timer = 0.0
    game.run = {
      current_mission: 0,
      missions_completed: 0,
      squad: [0, 1, 2],
      augments: [],
      grid_power: 3,
      reputation: 0,
    }
  }
}

///|
fn get_hover_info(
  battle : @types.BattleState,
  cx : Int,
  cy : Int,
) -> String {
  if !battle.grid.in_bounds(cx, cy) {
    return ""
  }
  let tile = battle.grid.get(cx, cy)
  let mut info = "(\{cx},\{cy}) \{tile.kind}"
  if tile.hazard != None {
    info = info + " [\{tile.hazard}]"
  }
  if tile.occupied_by >= 0 && tile.occupied_by < battle.units.length() {
    let u = battle.units[tile.occupied_by]
    let name = match u.team {
      Player => {
        let stats = @content.get_mech_stats(u.mech_class)
        stats.name
      }
      Enemy => @content.get_enemy_name(u.enemy_type)
    }
    info = info + " | \{name} HP:\{u.hp}/\{u.max_hp}"
    if u.shield > 0 {
      info = info + " Shield:\{u.shield}"
    }
    if u.heat > 0 {
      info = info + " Heat:\{u.heat}/\{u.max_heat}"
    }
    if u.stunned {
      info = info + " [STUNNED]"
    }
    if u.acted_this_turn {
      info = info + " [ACTED]"
    }
  }
  info
}
