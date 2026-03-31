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
  // Decay combo timer
  match game.battle {
    Some(b) => {
      if b.combo_timer > 0.0 {
        b.combo_timer -= dt
        if b.combo_timer < 0.0 {
          b.combo_timer = 0.0
          b.combo_text = ""
        }
      }
    }
    None => ()
  }
  match game.screen {
    Title => update_title(game)
    Campaign => update_campaign(game)
    Battle => update_battle(game, dt)
    EnemyTurn => update_enemy_turn(game, dt)
    Reward => update_reward(game)
    UpgradeScreen => update_upgrade_screen(game)
    MissionBriefing => update_mission_briefing(game)
    MissionDebrief => update_mission_debrief(game)
    RunSummary => update_run_summary(game)
    GameOver | Victory => update_end_screen(game)
    _ => ()
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    // Initialize campaign map and go to campaign screen
    game.run.campaign = Some(build_campaign_map())
    game.screen = Campaign
    game.message_text = "Choose your mission path."
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
  battle.mission_id = mission_id
  battle.augments = game.run.augments
  // Place terrain based on mission
  place_terrain(battle, mission_id)
  // Place 3 player mechs in deployment zone (left columns)
  let classes : Array[@types.MechClass] = [Vanguard, Striker, Sentinel]
  for i = 0; i < 3; i = i + 1 {
    let stats = @content.get_augmented_mech_stats(
      classes[i],
      game.run.augments,
    )
    let px = 1
    let py = 1 + i * 3
    let mut shield = 0
    // ShieldGenerator augment: start each battle with 2 shield
    if @types.has_augment(game.run, ShieldGenerator) {
      shield = 2
    }
    let u : @types.CombatUnit = {
      id: i,
      active: true,
      team: Player,
      x: px,
      y: py,
      hp: stats.hp,
      max_hp: stats.hp,
      shield,
      heat: 0,
      max_heat: stats.max_heat,
      stunned: false,
      moved_this_turn: false,
      acted_this_turn: false,
      mech_class: classes[i],
      enemy_type: Rammer,
      intent: March(px, py),
      statuses: [],
      upgrade_tier: 0,
      orbital_used: false,
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
  let tier = get_difficulty_tier(mission_id)
  // Set some tiles based on mission layout
  let seed : Ref[UInt] = { val: (mission_id * 7919 + 1234).reinterpret_as_uint() }
  // Add walls - more on harder missions
  let wall_count = 3 + mission_id % 4 + tier
  for i = 0; i < wall_count; i = i + 1 {
    let wx = @types.rand_range(seed, 2, 6)
    let wy = @types.rand_range(seed, 0, @types.grid_h - 1)
    if battle.grid.in_bounds(wx, wy) {
      battle.grid.set(wx, wy, { kind: Wall, hazard: None, occupied_by: -1 })
    }
  }
  // Add hazard tiles - more variety on harder missions
  if mission_id >= 2 || tier >= 1 {
    let lava_count = 1 + tier / 2
    for j = 0; j < lava_count; j = j + 1 {
      ignore(j)
      let hx = @types.rand_range(seed, 3, 6)
      let hy = @types.rand_range(seed, 1, 6)
      if battle.grid.in_bounds(hx, hy) {
        battle.grid.set(hx, hy, { kind: Lava, hazard: Fire, occupied_by: -1 })
      }
    }
  }
  if mission_id >= 3 || tier >= 1 {
    let chasm_count = 1 + tier / 2
    for j = 0; j < chasm_count; j = j + 1 {
      ignore(j)
      let cx = @types.rand_range(seed, 3, 6)
      let cy = @types.rand_range(seed, 0, 7)
      if battle.grid.in_bounds(cx, cy) {
        battle.grid.set(cx, cy, { kind: Chasm, hazard: None, occupied_by: -1 })
      }
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
  // Expert tier: add acid hazards
  if tier >= 3 {
    let ax = @types.rand_range(seed, 2, 5)
    let ay = @types.rand_range(seed, 2, 5)
    if battle.grid.in_bounds(ax, ay) {
      let tile = battle.grid.get(ax, ay)
      if tile.kind == Floor {
        battle.grid.set(ax, ay, { ..tile, hazard: Acid })
      }
    }
  }
}

///|
/// Get the difficulty tier for a mission (0=Easy, 1=Medium, 2=Hard, 3=Expert).
fn get_difficulty_tier(mission_id : Int) -> Int {
  if mission_id <= 2 {
    0 // Easy: missions 1-2
  } else if mission_id <= 4 {
    1 // Medium: missions 3-4
  } else if mission_id <= 6 {
    2 // Hard: missions 5-6
  } else {
    3 // Expert: missions 7-8+
  }
}

///|
/// Scale enemy HP based on mission difficulty.
/// Formula: base * (1.0 + mission * 0.15), rounded.
fn scale_enemy_hp(base_hp : Int, mission_id : Int) -> Int {
  let scale = 1.0F + Float::from_int(mission_id) * 0.15F
  let scaled = Float::from_int(base_hp) * scale
  let result = scaled.to_int()
  if result < base_hp { base_hp } else { result }
}

///|
/// Get available enemy types based on mission difficulty tier.
fn get_available_enemy_types(tier : Int) -> Array[@types.EnemyType] {
  match tier {
    0 => [Rammer, Artillery, Leaper] // Easy: basic enemies
    1 => [Rammer, Artillery, Leaper, BeamTurret, MineLayer] // Medium
    2 => [Rammer, Artillery, Leaper, BeamTurret, MineLayer, ShieldDrone, Splitter] // Hard
    _ => [Rammer, Artillery, Leaper, BeamTurret, MineLayer, ShieldDrone, Splitter] // Expert: all types
  }
}

///|
fn spawn_enemies(battle : @types.BattleState, mission_id : Int) -> Unit {
  let tier = get_difficulty_tier(mission_id)
  let base_count = 3 + mission_id / 2
  let max_enemies = match tier {
    0 => 4
    1 => 5
    2 => 6
    _ => 7
  }
  let enemy_count = if base_count > max_enemies {
    max_enemies
  } else {
    base_count
  }
  let available_types = get_available_enemy_types(tier)
  let seed : Ref[UInt] = { val: (mission_id * 31337 + 42).reinterpret_as_uint() }
  for i = 0; i < enemy_count; i = i + 1 {
    let eid = 3 + i
    let etype_idx = @types.rand_range(seed, 0, available_types.length() - 1)
    let etype = available_types[etype_idx]
    let base_hp = @content.get_enemy_hp(etype)
    let ehp = scale_enemy_hp(base_hp, mission_id)
    // Enemy shield on harder tiers
    let enemy_shield = if tier >= 2 && i == 0 { 1 } else { 0 }
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
      shield: enemy_shield,
      heat: 0,
      max_heat: 0,
      stunned: false,
      moved_this_turn: false,
      acted_this_turn: false,
      mech_class: Vanguard,
      enemy_type: etype,
      intent: March(ex, ey),
      statuses: [],
      upgrade_tier: 0,
      orbital_used: false,
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
  // Boss on higher missions (tier 1+, i.e. mission 3+)
  if tier >= 1 && mission_id >= 4 {
    let bid = battle.units.length()
    let bx = 7
    let by = 3
    if battle.grid.in_bounds(bx, by) &&
      battle.grid.get(bx, by).occupied_by < 0 {
      let boss_base = @content.get_enemy_hp(Boss)
      let boss_hp = scale_enemy_hp(boss_base, mission_id)
      let boss_shield = if tier >= 2 { 3 } else { 2 }
      let bu : @types.CombatUnit = {
        id: bid,
        active: true,
        team: Enemy,
        x: bx,
        y: by,
        hp: boss_hp,
        max_hp: boss_hp,
        shield: boss_shield,
        heat: 0,
        max_heat: 0,
        stunned: false,
        moved_this_turn: false,
        acted_this_turn: false,
        mech_class: Vanguard,
        enemy_type: Boss,
        intent: March(bx, by),
        statuses: [],
        upgrade_tier: 0,
        orbital_used: false,
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
fn update_battle(game : @types.Game, dt : Float) -> Unit {
  let battle = match game.battle {
    Some(b) => b
    None => return
  }
  // --- Update animations and effects ---
  let animating = @render.update_animations(battle, dt)
  if animating {
    return // block input while animations play
  }
  // --- Mouse/touch input ---
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mouse = @raylib.get_mouse_position()
    let mx = mouse.x.to_int()
    let my = mouse.y.to_int()
    let gx = @types.screen_to_tile_x(mx)
    let gy = @types.screen_to_tile_y(my)
    if battle.grid.in_bounds(gx, gy) {
      battle.cursor_x = gx
      battle.cursor_y = gy
      // Auto-action: click on tile performs context-sensitive action
      handle_mouse_click(game, battle, gx, gy)
    }
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
  // --- B: Barricade (Vanguard) ---
  if @raylib.is_key_pressed(@raylib.KeyB) {
    handle_terrain_ability(game, battle, 6)
  }
  // --- D: Detonate (Striker) ---
  if @raylib.is_key_pressed(@raylib.KeyD) {
    handle_terrain_ability(game, battle, 7)
  }
  // --- M: Deploy Mine (Sentinel) ---
  if @raylib.is_key_pressed(@raylib.KeyM) {
    handle_terrain_ability(game, battle, 8)
  }
  // --- F: Fortress Mode (Vanguard T2) ---
  if @raylib.is_key_pressed(@raylib.KeyF) {
    handle_upgrade_ability(game, battle)
  }
  // --- Escape/Z to cancel/undo ---
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyZ) {
    handle_cancel(game, battle)
  }
}

///|
fn handle_mouse_click(
  game : @types.Game,
  battle : @types.BattleState,
  gx : Int,
  gy : Int,
) -> Unit {
  let mech = match get_selected_unit(battle) {
    Some(u) => u
    None => return
  }
  if mech.acted_this_turn {
    // Check if clicking on a player mech to select it
    let unit_id = find_unit_at(battle, gx, gy)
    match unit_id {
      Some(uid) => {
        let u = battle.units[uid]
        if u.team == Player && u.active && u.hp > 0 {
          battle.selected_mech = uid
          game.message_text = "Selected \{@content.get_mech_stats(u.mech_class).name}"
          game.message_timer = 1.0
        }
      }
      None => ()
    }
    return
  }
  // Check what is at this grid position
  let unit_id = find_unit_at(battle, gx, gy)
  match unit_id {
    Some(uid) => {
      let target = battle.units[uid]
      if target.team == Enemy && target.active && target.hp > 0 {
        // Click on enemy = attack
        let stats = @content.get_augmented_mech_stats(mech.mech_class, battle.augments)
        let dist = @types.manhattan(mech.x, mech.y, gx, gy)
        if dist <= stats.ability_range {
          let ability_id = select_ability_id(mech.mech_class, dist)
          issue_command(game, battle, Attack(ability_id, gx, gy))
        } else {
          game.message_text = "Target out of range (\{dist}/\{stats.ability_range})"
          game.message_timer = 1.5
        }
      } else if target.team == Player && target.active && target.hp > 0 {
        // Click on own mech = select it
        battle.selected_mech = uid
        game.message_text = "Selected \{@content.get_mech_stats(target.mech_class).name}"
        game.message_timer = 1.0
      }
    }
    None => {
      // Click on empty tile = move
      let tile = battle.grid.get(gx, gy)
      if tile.kind == Wall || tile.kind == Chasm {
        game.message_text = "Cannot move there."
        game.message_timer = 1.0
        return
      }
      let stats = @content.get_augmented_mech_stats(mech.mech_class, battle.augments)
      let dist = @types.manhattan(mech.x, mech.y, gx, gy)
      if dist <= stats.move_range && dist > 0 {
        issue_command(game, battle, Move(gx, gy))
      } else if dist == 0 {
        () // clicked on self, no action
      } else {
        game.message_text = "Too far (\{dist}/\{stats.move_range})"
        game.message_timer = 1.5
      }
    }
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
/// Count how many player mechs died in this battle.
fn count_dead_player_mechs(battle : @types.BattleState) -> Int {
  let mut count = 0
  for i = 0; i < battle.units.length(); i = i + 1 {
    let u = battle.units[i]
    if u.team == Player && (!u.active || u.hp <= 0) {
      count += 1
    }
  }
  count
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
        let stats = @content.get_augmented_mech_stats(mech.mech_class, battle.augments)
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
      let stats = @content.get_augmented_mech_stats(mech.mech_class, battle.augments)
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
  // Use snapshot-based undo: restore full state from undo stack
  if @sim.pop_undo(battle) {
    game.message_text = "Undo (Z) - Command undone."
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
  // Save snapshot before executing command (for undo)
  @sim.push_undo(battle)
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
  // Clear undo stack - turn is confirmed
  @sim.clear_undo_stack(battle)
  // simulate_turn writes directly to battle.turn_log; no need to append
  let _ = @sim.simulate_turn(battle, battle.player_commands)
  battle.player_commands = []
  battle.phase = EnemyTurn
  game.screen = EnemyTurn
  game.anim_timer = 0.0
  // Trigger turn transition pulse effect
  @render.trigger_pulse(battle)
  // Queue intent reveal animation for next turn
  @render.queue_intent_reveal(battle)
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
fn update_enemy_turn(game : @types.Game, dt : Float) -> Unit {
  let battle = match game.battle {
    Some(b) => b
    None => return
  }
  // Update animations during enemy turn
  let _animating = @render.update_animations(battle, dt)
  // simulate_turn already resolved everything (player commands, enemy intents,
  // hazards, cleanup, conditions, new intent generation, and turn increment).
  // This state just serves as an animation delay so the player can see results.
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) ||
    game.anim_timer > 1.5 {
    // Check for game-over / victory set by simulate_turn
    match battle.phase {
      GameOver => {
        // Track stats for run summary
        game.run.total_turns += battle.turn
        game.run.total_score += battle.score
        game.run.mechs_lost += count_dead_player_mechs(battle)
        if battle.score > game.run.best_combo {
          game.run.best_combo = battle.score
        }
        game.screen = RunSummary
        return
      }
      Victory => {
        // Stats are tracked in advance_mission (via Reward flow)
        // to avoid double-counting total_turns.
        game.screen = MissionDebrief
        game.message_text = ""
        game.message_timer = 0.0
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
  // Generate offered augments if empty
  if game.run.offered_augments.length() == 0 {
    let seed : Ref[UInt] = { val: game.rng_state }
    game.run.offered_augments = @content.pick_random_augments(
      seed,
      game.run.augments,
      2,
    )
    game.rng_state = seed.val
  }
  // Three reward choices: 1=Pick Augment A, 2=Repair, 3=Grid Power
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    // Pick first offered augment
    if game.run.offered_augments.length() > 0 {
      let aug = game.run.offered_augments[0]
      game.run.augments.push(aug)
      let def = @content.get_augment_def(aug)
      game.message_text = "Acquired: \{def.name}!"
      game.message_timer = 2.0
    }
    game.run.missions_completed += 1
    game.run.offered_augments = []
    advance_mission(game)
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) {
    // Pick second offered augment or repair if only 1 offered
    if game.run.offered_augments.length() > 1 {
      let aug = game.run.offered_augments[1]
      game.run.augments.push(aug)
      let def = @content.get_augment_def(aug)
      game.message_text = "Acquired: \{def.name}!"
      game.message_timer = 2.0
    } else {
      game.message_text = "No second augment available."
      game.message_timer = 1.5
      return
    }
    game.run.missions_completed += 1
    game.run.offered_augments = []
    advance_mission(game)
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) {
    // Repair: heal all mechs
    game.message_text = "All mechs repaired!"
    game.message_timer = 2.0
    game.run.missions_completed += 1
    game.run.offered_augments = []
    advance_mission(game)
  }
  if @raylib.is_key_pressed(@raylib.KeyFour) {
    // Grid power
    game.run.grid_power += 2
    game.message_text = "+2 Grid Power! (now \{game.run.grid_power})"
    game.message_timer = 2.0
    game.run.missions_completed += 1
    game.run.offered_augments = []
    advance_mission(game)
  }
}

///|
fn update_upgrade_screen(game : @types.Game) -> Unit {
  // Key 1: Upgrade Vanguard
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    if @content.try_purchase_upgrade(game.run, Vanguard) {
      let tier = @content.get_upgrade_tier(game.run, Vanguard)
      let def = @content.get_upgrade_def(Vanguard, tier)
      game.message_text = "Vanguard: \{def.name}!"
      game.message_timer = 2.0
    } else {
      game.message_text = "Cannot upgrade (max tier or insufficient GP)."
      game.message_timer = 1.5
    }
  }
  // Key 2: Upgrade Striker
  if @raylib.is_key_pressed(@raylib.KeyTwo) {
    if @content.try_purchase_upgrade(game.run, Striker) {
      let tier = @content.get_upgrade_tier(game.run, Striker)
      let def = @content.get_upgrade_def(Striker, tier)
      game.message_text = "Striker: \{def.name}!"
      game.message_timer = 2.0
    } else {
      game.message_text = "Cannot upgrade (max tier or insufficient GP)."
      game.message_timer = 1.5
    }
  }
  // Key 3: Upgrade Sentinel
  if @raylib.is_key_pressed(@raylib.KeyThree) {
    if @content.try_purchase_upgrade(game.run, Sentinel) {
      let tier = @content.get_upgrade_tier(game.run, Sentinel)
      let def = @content.get_upgrade_def(Sentinel, tier)
      game.message_text = "Sentinel: \{def.name}!"
      game.message_timer = 2.0
    } else {
      game.message_text = "Cannot upgrade (max tier or insufficient GP)."
      game.message_timer = 1.5
    }
  }
  // Enter/Space: Continue to next mission
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    go_to_next_mission(game)
  }
}

///|
fn advance_mission(game : @types.Game) -> Unit {
  // Mark campaign node as completed, accumulate score
  complete_campaign_node(game)
  match game.battle {
    Some(b) => {
      game.run.total_score += b.score
      game.run.total_turns += b.turn
      game.run.mechs_lost += count_dead_player_mechs(b)
      if b.score > game.run.best_combo {
        game.run.best_combo = b.score
      }
    }
    None => ()
  }
  game.run.current_mission += 1
  // Check if campaign is over (final boss beaten)
  if game.screen == Victory {
    return
  }
  // Go to upgrade screen if player has grid power
  if game.run.grid_power >= 2 {
    game.screen = UpgradeScreen
    game.message_text = "Spend Grid Power to upgrade mechs."
    game.message_timer = 3.0
    return
  }
  go_to_next_mission(game)
}

///|
fn go_to_next_mission(game : @types.Game) -> Unit {
  match game.run.campaign {
    Some(_) => {
      // Return to campaign map for next mission choice
      game.screen = Campaign
      game.message_text = "Choose your next mission."
      game.message_timer = 2.0
    }
    None => {
      // Fallback: linear progression
      if game.run.current_mission >= @types.total_missions {
        game.screen = RunSummary
        match game.battle {
          Some(b) => b.phase = Victory
          None => ()
        }
      } else {
        setup_battle(game, game.run.current_mission)
        game.screen = Battle
      }
    }
  }
}

///|
fn handle_terrain_ability(
  game : @types.Game,
  battle : @types.BattleState,
  ability_id : Int,
) -> Unit {
  let mech = match get_selected_unit(battle) {
    Some(u) => u
    None => return
  }
  if mech.acted_this_turn {
    game.message_text = "Mech already acted."
    game.message_timer = 1.0
    return
  }
  // Check class matches ability
  let valid = match ability_id {
    6 => mech.mech_class == Vanguard  // Barricade
    7 => mech.mech_class == Striker   // Detonate
    8 => mech.mech_class == Sentinel  // Deploy Mine
    _ => false
  }
  if !valid {
    let ability_name = match ability_id {
      6 => "Barricade (Vanguard only)"
      7 => "Detonate (Striker only)"
      _ => "Deploy Mine (Sentinel only)"
    }
    game.message_text = ability_name
    game.message_timer = 1.5
    return
  }
  let tx = battle.cursor_x
  let ty = battle.cursor_y
  issue_command(game, battle, Attack(ability_id, tx, ty))
}

///|
fn handle_upgrade_ability(
  game : @types.Game,
  battle : @types.BattleState,
) -> Unit {
  let mech = match get_selected_unit(battle) {
    Some(u) => u
    None => return
  }
  if mech.acted_this_turn {
    game.message_text = "Mech already acted."
    game.message_timer = 1.0
    return
  }
  match mech.mech_class {
    Vanguard => {
      if mech.upgrade_tier >= 3 {
        // Gravity Well
        issue_command(game, battle, Attack(11, mech.x, mech.y))
      } else if mech.upgrade_tier >= 2 {
        // Fortress Mode
        issue_command(game, battle, Attack(10, mech.x, mech.y))
      } else {
        game.message_text = "No upgrade ability available."
        game.message_timer = 1.5
      }
    }
    Sentinel => {
      if mech.upgrade_tier >= 3 && !mech.orbital_used {
        let tx = battle.cursor_x
        let ty = battle.cursor_y
        issue_command(game, battle, Attack(12, tx, ty))
      } else if mech.upgrade_tier >= 3 {
        game.message_text = "Orbital Strike already used!"
        game.message_timer = 1.5
      } else {
        game.message_text = "No upgrade ability available."
        game.message_timer = 1.5
      }
    }
    _ => {
      game.message_text = "No special ability (use F)."
      game.message_timer = 1.5
    }
  }
}

///|
fn update_end_screen(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
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
      campaign: None,
      offered_augments: [],
      upgrade_tiers: [0, 0, 0],
      total_score: 0,
      mechs_lost: 0,
      best_combo: 0,
      total_turns: 0,
    }
  }
}


///|
fn update_mission_briefing(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    game.screen = Battle
    game.message_text = "Deploy your squad!"
    game.message_timer = 2.0
  }
}

///|
fn update_mission_debrief(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    // Transition to reward screen
    game.screen = Reward
    game.message_text = "Mission complete! Choose reward."
    game.message_timer = 3.0
  }
}

///|
fn update_run_summary(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
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
      campaign: None,
      offered_augments: [],
      upgrade_tiers: [0, 0, 0],
      total_score: 0,
      mechs_lost: 0,
      best_combo: 0,
      total_turns: 0,
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
